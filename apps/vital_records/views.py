"""Phase 17 - Vital Records (Birth / Death Certificates).

Service-style ViewSet (extends ServiceViewSet so it is navigable from the
frontend SchemaBrowser via GET /api/vital_records/). The two lifecycle
actions perform the real side-effects:

  * issue(birth)  -> creates the newborn party + patient, then stamps the
                     certificate issued + signed_at + registration_no.
  * issue(death)  -> sets patient.is_deceased = true (fires the guard
                     trigger, which emits the patient_deceased event) and
                     stamps the certificate issued.
  * amend(...)    -> never UPDATEs an issued cert; creates a NEW row with
                     amended_from pointing at the prior one.

Certificates are attestation-locked: an issued cert cannot be edited; the
app layer enforces status and rejects invalid cause-of-death ICD-10 via the
terminology service.
"""
import uuid

from django.db import connection
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response

from apps.core.permissions import HasRolePermission
from apps.core.service_viewset import ServiceViewSet
from apps.terminology import resolver


def _actor_user_id(request):
    from apps.core.models import AppUser
    au = AppUser.objects.filter(
        username=request.user.get_username()).first()
    return au.user_id if au else None


def _facility_id(request):
    from apps.core.models import AppUser
    au = AppUser.objects.filter(
        username=request.user.get_username()).first()
    return au.facility_id if au else None


def _next_reg_no(cur, seq):
    cur.execute(f"SELECT nextval('{seq}')")
    return cur.fetchone()[0]


def _validate_icd10(code):
    if not code:
        return True
    return resolver.resolve("icd10", code) is not None


class VitalRecordsViewSet(ServiceViewSet):
    permission_classes = [HasRolePermission]
    # GET inventory is open to any authed user; mutations need real perms.
    required_perms = {
        "GET": "vital_records.read",
        "issue": "vital_records.register",
        "amend": "vital_records.register",
        "export_bundle": "vital_records.read",
        "import_bundle": "vital_records.register",
    }

    # --------------------------------------------------- birth issue
    @action(detail=False, methods=["post"])
    def issue_birth(self, request):
        b = request.data
        mother_pid = b.get("mother_patient_id")
        father_party = b.get("father_party_id")
        enc = b.get("delivery_encounter_id")
        facility = b.get("facility_id") or _facility_id(request)
        birth_dt = b.get("birth_datetime")
        if not (mother_pid and facility and birth_dt):
            return Response({"detail": "mother_patient_id, facility_id, "
                            "birth_datetime required"},
                            status=status.HTTP_400_BAD_REQUEST)

        with connection.cursor() as cur:
            # mother's party for naming / linking
            cur.execute("SELECT party_id, mrn FROM mcms_emr.patient "
                        "WHERE patient_id=%s", [mother_pid])
            row = cur.fetchone()
            if not row:
                return Response({"detail": "mother patient not found"},
                                status=status.HTTP_404_NOT_FOUND)
            # (row[0] is mother's party; we only needed to confirm existence)
            cur.execute(
                "INSERT INTO mcms_core.party (party_type, display_name, "
                "date_of_birth) VALUES ('person', %s, %s) RETURNING party_id",
                [b.get("newborn_name", "Newborn"), birth_dt[:10]])
            nb_party = cur.fetchone()[0]
            mrn = b.get("mrn") or f"BIRTH-{uuid.uuid4().hex[:10].upper()}"
            cur.execute(
                "INSERT INTO mcms_emr.patient (party_id, mrn, facility_id) "
                "VALUES (%s, %s, %s) RETURNING patient_id",
                [nb_party, mrn, facility])
            nb_pid = cur.fetchone()[0]
            reg = _next_reg_no(cur, "mcms_vital_records.birth_reg_no_seq")
            reg_no = f"B{facility}-{reg:08d}"
            cur.execute(
                """INSERT INTO mcms_vital_records.birth_certificate
                   (registration_no, newborn_patient_id, mother_patient_id,
                    father_party_id, delivery_encounter_id, facility_id,
                    birth_datetime, birth_weight_g, gestation_weeks,
                    place_of_birth, attendant_user_id, registrar_user_id,
                    certifier_user_id, status, signed_at)
                   VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,'issued',now())
                   RETURNING birth_cert_id""",
                [reg_no, nb_pid, mother_pid, father_party, enc, facility,
                 birth_dt, b.get("birth_weight_g"), b.get("gestation_weeks"),
                 b.get("place_of_birth"), b.get("attendant_user_id"),
                 _actor_user_id(request), b.get("certifier_user_id")])
            cid = cur.fetchone()[0]
        return Response({"birth_cert_id": cid, "registration_no": reg_no,
                         "newborn_patient_id": nb_pid, "status": "issued"},
                        status=status.HTTP_201_CREATED)

    # --------------------------------------------------- death issue
    @action(detail=False, methods=["post"])
    def issue_death(self, request):
        b = request.data
        pid = b.get("patient_id")
        facility = b.get("facility_id") or _facility_id(request)
        death_dt = b.get("death_datetime")
        cause = b.get("cause_icd10")
        if not (pid and facility and death_dt):
            return Response({"detail": "patient_id, facility_id, "
                            "death_datetime required"},
                            status=status.HTTP_400_BAD_REQUEST)
        if not _validate_icd10(cause):
            return Response({"detail": f"cause_icd10 {cause!r} is not a "
                            "valid ICD-10 code"},
                            status=status.HTTP_400_BAD_REQUEST)

        with connection.cursor() as cur:
            cur.execute("SELECT party_id, is_deceased FROM mcms_emr.patient "
                        "WHERE patient_id=%s", [pid])
            row = cur.fetchone()
            if not row:
                return Response({"detail": "patient not found"},
                                status=status.HTTP_404_NOT_FOUND)
            party_id, already = row[0], row[1]
            if already:
                return Response({"detail": "patient already deceased"},
                                status=status.HTTP_409_CONFLICT)
            # Flip the flag -> fires trg_patient_deceased_guard (emits event)
            cur.execute(
                "UPDATE mcms_emr.patient SET is_deceased=true, "
                "updated_at=now() WHERE patient_id=%s", [pid])
            reg = _next_reg_no(cur, "mcms_vital_records.death_reg_no_seq")
            reg_no = f"D{facility}-{reg:08d}"
            cur.execute(
                """INSERT INTO mcms_vital_records.death_certificate
                   (registration_no, patient_id, facility_id, death_datetime,
                    cause_icd10, cause_text, certifying_clinician_user_id,
                    coroner_case, registrar_user_id, status, signed_at)
                   VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,'issued',now())
                   RETURNING death_cert_id""",
                [reg_no, pid, facility, death_dt, cause, b.get("cause_text"),
                 b.get("certifying_clinician_user_id"),
                 bool(b.get("coroner_case", False)),
                 _actor_user_id(request)])
            cid = cur.fetchone()[0]
        return Response({"death_cert_id": cid, "registration_no": reg_no,
                         "patient_id": pid, "subject_party_id": party_id,
                         "status": "issued"},
                        status=status.HTTP_201_CREATED)

    # --------------------------------------------------- amend (immutability)
    @action(detail=False, methods=["post"])
    def amend(self, request):
        kind = request.data.get("kind")
        prev_id = request.data.get("cert_id")
        if kind not in ("birth", "death") or not prev_id:
            return Response({"detail": "kind (birth|death) and cert_id required"},
                            status=status.HTTP_400_BAD_REQUEST)
        tbl = ("mcms_vital_records.birth_certificate" if kind == "birth"
               else "mcms_vital_records.death_certificate")
        with connection.cursor() as cur:
            cur.execute(f"SELECT registration_no, facility_id, status "
                        f"FROM {tbl} WHERE "
                        f"{'birth_cert_id' if kind=='birth' else 'death_cert_id'}=%s",
                        [prev_id])
            row = cur.fetchone()
            if not row:
                return Response({"detail": "certificate not found"},
                                status=status.HTTP_404_NOT_FOUND)
            reg_no, fac_id, prev_status = row
            if prev_status != "issued":
                return Response({"detail": "only issued certificates can be "
                                "amended"}, status=status.HTTP_409_CONFLICT)
            # mark prior amended, insert a NEW row (fresh registration_no)
            # referencing it; the original is never edited (immutability).
            new_reg = _next_reg_no(
                cur,
                "mcms_vital_records.death_reg_no_seq" if kind == "death"
                else "mcms_vital_records.birth_reg_no_seq")
            new_reg_no = f"{'D' if kind == 'death' else 'B'}{fac_id}-{new_reg:08d}"
            cur.execute(
                f"UPDATE {tbl} SET status='amended' WHERE "
                f"{'birth_cert_id' if kind == 'birth' else 'death_cert_id'}=%s",
                [prev_id])
            cur.execute(
                f"INSERT INTO {tbl} (registration_no, facility_id, status, "
                f"amended_from, "
                f"{'newborn_patient_id, mother_patient_id, birth_datetime' if kind == 'birth' else 'patient_id, death_datetime, cause_icd10, cause_text, coroner_case'}) "
                f"SELECT %s, facility_id, 'issued', %s, "
                f"{'newborn_patient_id, mother_patient_id, birth_datetime' if kind == 'birth' else 'patient_id, death_datetime, cause_icd10, cause_text, coroner_case'} "
                f"FROM {tbl} WHERE "
                f"{'birth_cert_id' if kind == 'birth' else 'death_cert_id'}=%s "
                f"RETURNING {'birth_cert_id' if kind == 'birth' else 'death_cert_id'}",
                [new_reg_no, prev_id, prev_id])
            new_id = cur.fetchone()[0]
            return Response({"detail": "amended", "new_cert_id": new_id,
                             "registration_no": new_reg_no, "status": "issued"},
                            status=status.HTTP_201_CREATED)

    # --------------------------------------------------- FHIR bundle export
    @action(detail=False, methods=["get"])
    def export_bundle(self, request):
        kind = request.query_params.get("kind", "birth")
        cid = request.query_params.get("cert_id")
        if not cid:
            return Response({"detail": "cert_id required"},
                            status=status.HTTP_400_BAD_REQUEST)
        with connection.cursor() as cur:
            if kind == "birth":
                cur.execute(
                    "SELECT bc.registration_no, p.mrn, pr.date_of_birth, "
                    "bc.birth_datetime, bc.status "
                    "FROM mcms_vital_records.birth_certificate bc "
                    "JOIN mcms_emr.patient p ON p.patient_id=bc.newborn_patient_id "
                    "JOIN mcms_core.party pr ON pr.party_id=p.party_id "
                    "WHERE bc.birth_cert_id=%s", [cid])
            else:
                cur.execute(
                    "SELECT dc.registration_no, p.mrn, pr.date_of_birth, "
                    "dc.death_datetime, dc.cause_icd10, dc.status "
                    "FROM mcms_vital_records.death_certificate dc "
                    "JOIN mcms_emr.patient p ON p.patient_id=dc.patient_id "
                    "JOIN mcms_core.party pr ON pr.party_id=p.party_id "
                    "WHERE dc.death_cert_id=%s", [cid])
            row = cur.fetchone()
        if not row:
            return Response({"detail": "certificate not found"},
                            status=status.HTTP_404_NOT_FOUND)
        bundle = {"resourceType": "Bundle", "type": "collection",
                  "entry": [{"resource": dict(zip(
                      ["registration_no", "mrn", "date_of_birth",
                       "event_datetime", "cause_or_status"][:len(row)], row, strict=False))}]}
        return Response(bundle)

    # --------------------------------------------------- HL7/ext inbound -> draft
    @action(detail=False, methods=["post"])
    def import_bundle(self, request):
        """Accept an external birth/death notification (FHIR-ish or HL7 ORU/ADT
        shape) and create a DRAFT certificate. Validation/issuance happens
        separately via issue_* (keeps ingestion decoupled from attestation)."""
        b = request.data
        kind = b.get("kind")
        if kind not in ("birth", "death"):
            return Response({"detail": "kind (birth|death) required"},
                            status=status.HTTP_400_BAD_REQUEST)
        fac = b.get("facility_id") or _facility_id(request)
        with connection.cursor() as cur:
            if kind == "birth":
                mother_pid = b.get("mother_patient_id")
                cur.execute(
                    "INSERT INTO mcms_vital_records.birth_certificate "
                    "(registration_no, newborn_patient_id, mother_patient_id, "
                    "facility_id, birth_datetime, status) VALUES (%s,%s,%s,%s,%s,'draft') "
                    "RETURNING birth_cert_id",
                    [f"DRAFT-{uuid.uuid4().hex[:8].upper()}",
                     b.get("newborn_patient_id"), mother_pid, fac,
                     b.get("birth_datetime")])
                cid = cur.fetchone()[0]
            else:
                pid = b.get("patient_id")
                cur.execute(
                    "INSERT INTO mcms_vital_records.death_certificate "
                    "(registration_no, patient_id, facility_id, death_datetime, "
                    "cause_icd10, status) VALUES (%s,%s,%s,%s,%s,'draft') "
                    "RETURNING death_cert_id",
                    [f"DRAFT-{uuid.uuid4().hex[:8].upper()}", pid, fac,
                     b.get("death_datetime"), b.get("cause_icd10")])
                cid = cur.fetchone()[0]
        return Response({"detail": "draft created", "kind": kind,
                         "cert_id": cid, "status": "draft"},
                        status=status.HTTP_201_CREATED)
