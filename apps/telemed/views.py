"""Phase 11 - Telemedicine + eRX / formulary.

Deterministic, offline clinical-ordering layer:
  * telemed.visit     - virtual consultation record (video/phone/chat)
  * rx.prescription   - eRX order over the formulary (mcms_rx.drug_item),
                        with a drug-interaction check (mcms_rx.drug_interaction)
                        and formulary validation at sign time.
No live video transport / pharmacy gateway here (separate, later-scoped steps).
"""

from django.db import connection
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.core.permissions import HasRolePermission, effective_perms


def _app_user_id(request):
    uname = request.user.get_username()
    with connection.cursor() as cur:
        cur.execute("SELECT user_id FROM mcms_core.app_user WHERE username=%s", [uname])
        row = cur.fetchone()
    return row[0] if row else None


def _rows(sql, params=None):
    with connection.cursor() as cur:
        cur.execute(sql, params or [])
        cols = [d[0] for d in cur.description]
        return [dict(zip(cols, row, strict=False)) for row in cur.fetchall()]


def _guard(request, key):
    perms = effective_perms(request)
    if "admin.all" in perms or key in perms:
        return None
    return Response({"detail": "Forbidden"}, status=status.HTTP_403_FORBIDDEN)


def _interactions(drug_item_id, patient_id):
    """Drug-drug interactions for a prescribed drug vs the patient's active
    prescriptions (deterministic lookup over mcms_rx.drug_interaction)."""
    with connection.cursor() as cur:
        cur.execute(
            """SELECT di.severity, di.clinical_effect, di.management,
                      b.generic_name AS other_drug
               FROM mcms_rx.drug_interaction di
               JOIN mcms_rx.drug_item a ON a.drug_item_id = di.drug_item_id_a
               JOIN mcms_rx.drug_item b ON b.drug_item_id = di.drug_item_id_b
               WHERE (di.drug_item_id_a = %s OR di.drug_item_id_b = %s)
                 AND EXISTS (
                   SELECT 1 FROM mcms_rx.prescription p
                   WHERE p.patient_id = %s AND p.status IN ('signed','dispensed')
                     AND p.drug_item_id IN (di.drug_item_id_a, di.drug_item_id_b)
                     AND p.drug_item_id <> %s
                 )""",
            [drug_item_id, drug_item_id, patient_id, drug_item_id])
        cols = [d[0] for d in cur.description]
        return [dict(zip(cols, r, strict=False)) for r in cur.fetchall()]


class TelemedViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated, HasRolePermission]
    required_perms = {
        "GET": "emr.read",
        "POST": "emr.write",
        "PATCH": "emr.write",
    }

    @action(detail=False, methods=["post"])
    def visit(self, request):
        """Start a virtual visit (teleconsultation)."""
        if (d := _guard(request, "emr.write")):
            return d
        patient_id = request.data.get("patient_id")
        mrn = request.data.get("mrn")
        mode = request.data.get("mode", "video")
        encounter_id = request.data.get("encounter_id")
        appointment_id = request.data.get("appointment_id")
        if not patient_id or not mrn:
            return Response({"detail": "patient_id and mrn required"},
                            status=status.HTTP_400_BAD_REQUEST)
        if mode not in ("video", "phone", "chat"):
            return Response({"detail": "mode must be video|phone|chat"},
                            status=status.HTTP_400_BAD_REQUEST)
        uid = _app_user_id(request)
        with connection.cursor() as cur:
            cur.execute(
                """INSERT INTO mcms_telemed.visit
                   (patient_id, mrn, clinician_user_id, encounter_id,
                    appointment_id, mode, status, facility_id)
                   VALUES (%s,%s,%s,%s,%s,%s,'in_progress',1)
                   RETURNING visit_id, started_at""",
                [patient_id, mrn, uid, encounter_id, appointment_id, mode])
            vid, started = cur.fetchone()
        return Response({"visit_id": vid, "mode": mode, "status": "in_progress",
                         "started_at": started.isoformat()},
                        status=status.HTTP_201_CREATED)

    @action(detail=True, methods=["get"])
    def visit_status(self, request, pk=None):
        if (d := _guard(request, "emr.read")):
            return d
        rows = _rows(
            "SELECT visit_id, mode, status, started_at, ended_at "
            "FROM mcms_telemed.visit WHERE visit_id=%s", [pk])
        if not rows:
            return Response({"detail": "not found"}, status=status.HTTP_404_NOT_FOUND)
        return Response(rows[0])

    # ------------------------------------------------------------------ eRX
    @action(detail=False, methods=["post"])
    def prescription(self, request):
        """Create + sign an eRX over the formulary.

        Runs formulary validation (drug must be active) and a drug-interaction
        check vs the patient's active prescriptions. Interaction severity is
        reported (not blocking) so the clinician decides.
        """
        if (d := _guard(request, "rx.prescribe")):
            return d
        patient_id = request.data.get("patient_id")
        mrn = request.data.get("mrn")
        drug_item_id = request.data.get("drug_item_id")
        if not (patient_id and mrn and drug_item_id):
            return Response({"detail": "patient_id, mrn, drug_item_id required"},
                            status=status.HTTP_400_BAD_REQUEST)
        # formulary validation
        drug = _rows(
            "SELECT drug_item_id, generic_name, controlled_substance, is_active "
            "FROM mcms_rx.drug_item WHERE drug_item_id=%s", [drug_item_id])
        if not drug:
            return Response({"detail": "drug not in formulary"},
                            status=status.HTTP_404_NOT_FOUND)
        if not drug[0]["is_active"]:
            return Response({"detail": "drug is not active in formulary"},
                            status=status.HTTP_422_UNPROCESSABLE_ENTITY)
        uid = _app_user_id(request)
        inter = _interactions(drug_item_id, patient_id)
        severity = None
        if inter:
            rank = {"low": 1, "moderate": 2, "high": 3}
            severity = max(inter, key=lambda x: rank.get(x["severity"], 0))["severity"]
        with connection.cursor() as cur:
            cur.execute(
                """INSERT INTO mcms_rx.prescription
                   (patient_id, mrn, prescriber_user_id, drug_item_id,
                    dose, route, frequency, duration_days, quantity, notes,
                    status, interaction_severity, controlled, signed_at,
                    facility_id)
                   VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,'signed',%s,%s,now(),1)
                   RETURNING prescription_id""",
                [patient_id, mrn, uid, drug_item_id,
                 request.data.get("dose"), request.data.get("route"),
                 request.data.get("frequency"), request.data.get("duration_days"),
                 request.data.get("quantity"), request.data.get("notes"),
                 severity, bool(drug[0]["controlled_substance"])])
            rx_id = cur.fetchone()[0]
        return Response({
            "prescription_id": rx_id,
            "drug": drug[0]["generic_name"],
            "controlled": bool(drug[0]["controlled_substance"]),
            "status": "signed",
            "interactions": inter,
            "interaction_severity": severity,
        }, status=status.HTTP_201_CREATED)

    @action(detail=False, methods=["get"])
    def formulary(self, request):
        """Search the formulary (mcms_rx.drug_item)."""
        if (d := _guard(request, "emr.read")):
            return d
        q = request.query_params.get("q", "")
        atc = request.query_params.get("atc")
        controlled = request.query_params.get("controlled")
        clauses, params = [], []
        if q:
            clauses.append("(generic_name ILIKE %s OR brand_name ILIKE %s)")
            params += [f"%{q}%", f"%{q}%"]
        if atc:
            clauses.append("atc_code=%s"); params.append(atc)
        if controlled in ("true", "1"):
            clauses.append("controlled_substance=true")
        where = (" WHERE " + " AND ".join(clauses)) if clauses else ""
        limit = int(request.query_params.get("limit", 50))
        rows = _rows(
            f"SELECT drug_item_id, generic_name, brand_name, drug_class, form, "
            f"strength, atc_code, controlled_substance, is_active "
            f"FROM mcms_rx.drug_item{where} ORDER BY generic_name LIMIT %s",
            params + [limit])
        return Response(rows)
