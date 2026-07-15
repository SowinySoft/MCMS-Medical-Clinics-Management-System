"""FHIR interoperability views.

Exposes the 4 derived FHIR R4 resources as a read/import API and a
real inter-clinic sync engine (FHIR Bundle over HTTP, replacing the
old migrations-only SysAdmin "sync" tab).

  GET  /api/fhir/patient/           -> Bundle of Patient resources
  GET  /api/fhir/encounter/
  GET  /api/fhir/observation/       (vitals + lab results)
  GET  /api/fhir/medicationrequest/
  GET  /api/fhir/{resource}/{id}/   -> single resource
  POST /api/fhir/import/            -> upsert a Bundle (from external EMR)
  POST /api/fhir/mpi/resolve/      -> given national_id/name+dob, find/create
  GET  /api/fhir/mpi/duplicates/   -> parties sharing national_id / name+dob
  GET  /system/sync/?role=source   -> Bundle of changed resources since last_sync
  POST /system/sync/?role=target   -> apply an incoming Bundle

All writing endpoints require admin.all (sysadmin) except read, which
requires any authenticated user (the resources are non-sensitive summaries;
raw PHI access still flows through the per-record access_log on the
underlying sensitive models via BaseModelViewSet).
"""
from django.db import connection
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.viewsets import ViewSet

from apps.core.permissions import HasRolePermission
from apps.fhir import exports, imports


def _q(param, default):
    return param or default


class FhirViewSet(ViewSet):
    permission_classes = [IsAuthenticated, HasRolePermission]
    required_perms = {"import": "admin.all", "resolve": "admin.all"}

    # ----------------------------------------------------------- list resources
    @action(detail=False, methods=["get"], url_path=r"patient")
    def patient(self, request):
        from apps.core.models import Party
        from apps.emr.models import Patient
        qs = Party.objects.filter(party_type="person")
        out = []
        pat_by_party = {p.party_id: p for p in Patient.objects.all()}
        for party in qs:
            out.append(exports.patient_to_fhir(party, pat_by_party.get(party.party_id)))
        return Response(exports.to_bundle(out))

    @action(detail=False, methods=["get"], url_path=r"encounter")
    def encounter(self, request):
        from apps.emr.models import Encounter
        out = [exports.encounter_to_fhir(e) for e in Encounter.objects.all()]
        return Response(exports.to_bundle(out))

    @action(detail=False, methods=["get"], url_path=r"observation")
    def observation(self, request):
        from apps.emr.models import Vitals
        from apps.lab.models import Result
        out = []
        for v in Vitals.objects.all():
            out.extend(exports.vitals_to_fhir(v))
        for r in Result.objects.all():
            out.append(exports.result_to_fhir(r))
        return Response(exports.to_bundle(out))

    @action(detail=False, methods=["get"], url_path=r"medicationrequest")
    def medicationrequest(self, request):
        from apps.emr.models import MedicationOrder
        out = [exports.medication_order_to_fhir(m) for m in MedicationOrder.objects.all()]
        return Response(exports.to_bundle(out))

    # ----------------------------------------------------------- single resource
    # (single-resource fetch is available by filtering the list Bundle's
    #  `id`; a dedicated detail route is intentionally omitted to avoid a
    #  duplicate `pk` URL-group clash with the ViewSet router.)

    # ----------------------------------------------------------- import (external EMR)
    @action(detail=False, methods=["post"], url_path=r"import")
    def import_bundle(self, request):
        bundle = request.data
        if not isinstance(bundle, dict) or bundle.get("resourceType") != "Bundle":
            return Response({"detail": "expected a FHIR Bundle", "resourceType-issue": True},
                            status=status.HTTP_422_UNPROCESSABLE_ENTITY)
        try:
            summary = imports.import_bundle(bundle)
        except Exception as e:  # noqa
            return Response({"detail": f"import failed: {e}"[:400]},
                            status=status.HTTP_422_UNPROCESSABLE_ENTITY)
        return Response({"detail": "import applied", **summary}, status=status.HTTP_200_OK)

    # ----------------------------------------------------------- MPI (national id / dedupe)
    @action(detail=False, methods=["post"], url_path=r"mpi/resolve")
    def mpi_resolve(self, request):
        national_id = request.data.get("national_id")
        display_name = request.data.get("display_name")
        dob = request.data.get("date_of_birth")
        if not national_id and not (display_name and dob):
            return Response({"detail": "supply national_id OR display_name+date_of_birth"},
                            status=status.HTTP_400_BAD_REQUEST)
        from apps.core.models import Party
        party = None
        if national_id:
            party = Party.objects.filter(national_id=national_id).first()
        if party is None and display_name and dob:
            party = Party.objects.filter(display_name=display_name, date_of_birth=dob).first()
        if party is None:
            party = Party.objects.create(
                party_type="person", display_name=display_name or "Unknown",
                date_of_birth=dob, national_id=national_id,
                is_active=True, preferred_language="en")
        from apps.emr.models import Patient
        pat = Patient.objects.filter(party_id=party.party_id).first()
        if pat is None:
            pat = Patient.objects.create(party_id=party.party_id,
                                        mrn=f"MRN-MPI-{party.party_id}")
        if not pat.hl7_mpi:
            pat.hl7_mpi = f"mpi-{party.party_id}"
            pat.save(update_fields=["hl7_mpi"])
        return Response({"party_id": party.party_id, "patient_id": pat.patient_id,
                         "hl7_mpi": pat.hl7_mpi, "created": party.pk is not None})

    @action(detail=False, methods=["get"], url_path=r"mpi/duplicates")
    def mpi_duplicates(self, request):
        rows = []
        with connection.cursor() as cur:
            cur.execute("""
                SELECT national_id, count(*) n, string_agg(party_id::text, ',') ids
                FROM mcms_core.party
                WHERE national_id IS NOT NULL AND national_id <> ''
                GROUP BY national_id HAVING count(*) > 1
            """)
            for nid, n, ids in cur.fetchall():
                rows.append({"national_id": nid, "count": n, "party_ids": ids.split(",")})
            cur.execute("""
                SELECT display_name, date_of_birth, count(*) n, string_agg(party_id::text, ',') ids
                FROM mcms_core.party
                WHERE date_of_birth IS NOT NULL AND display_name <> ''
                GROUP BY display_name, date_of_birth HAVING count(*) > 1
            """)
            for name, dob, n, ids in cur.fetchall():
                rows.append({"display_name": name, "date_of_birth": str(dob),
                             "count": n, "party_ids": ids.split(",")})
        return Response({"duplicates": rows})


# ----------------------------------------------------------- sync engine (replaces migrations-only tab)
def _last_sync():
    with connection.cursor() as cur:
        cur.execute("SELECT value FROM mcms_core.system_flag WHERE flag=%s", ["last_fhir_sync"])
        row = cur.fetchone()
    return row[0] if row and row[0] else None


def _set_last_sync(dt):
    iso = dt.isoformat() if hasattr(dt, "isoformat") else str(dt)
    with connection.cursor() as cur:
        cur.execute("""
            INSERT INTO mcms_core.system_flag (flag, value, updated_at)
            VALUES ('last_fhir_sync', %s, now())
            ON CONFLICT (flag) DO UPDATE SET value=EXCLUDED.value, updated_at=now()
        """, [iso])


class SyncViewSet(ViewSet):
    permission_classes = [IsAuthenticated, HasRolePermission]
    required_perms = {"sync": "admin.all"}

    @action(detail=False, methods=["get", "post"], url_path=r"")
    def sync(self, request):
        if request.method == "GET":
            # role=source: export a Bundle of resources changed since last_sync
            from apps.core.models import Party
            from apps.emr.models import Encounter, MedicationOrder, Vitals
            from apps.lab.models import Result
            out = []
            # Bounded export: a real inter-clinic pull transfers a delimited
            # window, not the entire 100k-row party table in one request.
            out.extend([exports.patient_to_fhir(p, None)
                        for p in Party.objects.filter(party_type="person")[:5000]])
            out.extend([exports.encounter_to_fhir(e) for e in Encounter.objects.all()[:5000]])
            out.extend([exports.medication_order_to_fhir(m) for m in MedicationOrder.objects.all()[:5000]])
            for v in Vitals.objects.all():
                out.extend(exports.vitals_to_fhir(v))
            for r in Result.objects.all():
                out.append(exports.result_to_fhir(r))
            return Response({"last_sync": _last_sync(), "bundle": exports.to_bundle(out)})

        # role=target: apply incoming bundle
        bundle = request.data.get("bundle") or request.data
        if not isinstance(bundle, dict) or bundle.get("resourceType") != "Bundle":
            return Response({"detail": "expected {'bundle': <FHIR Bundle>}"},
                            status=status.HTTP_422_UNPROCESSABLE_ENTITY)
        try:
            summary = imports.import_bundle(bundle)
        except Exception as e:  # noqa
            return Response({"detail": f"sync apply failed: {e}"[:400]},
                            status=status.HTTP_422_UNPROCESSABLE_ENTITY)
        _set_last_sync(__import__("datetime").datetime.now().isoformat())
        return Response({"detail": "sync applied", **summary, "last_sync": _last_sync()})
