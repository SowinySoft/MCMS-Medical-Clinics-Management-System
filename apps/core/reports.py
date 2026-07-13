"""
MCMS reporting module.

Read-only analytical endpoints over the live schema. Each report is a plain
SQL query (parameterised) returning aggregated rows — no ORM models, because
reports span multiple schemas/joins. All endpoints are RBAC-gated by
`required_perms` (inherited from BaseModelViewSet isn't used here; we apply
HasRolePermission directly). Reports are safe SELECTs.

Sections: financial summary, patient census / encounters, pharmacy dispense
log, emergency triage acuity, lab/rad volume, and event-store activity.
"""
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.db import connection
from apps.core.permissions import HasRolePermission
from datetime import date


def _rows(sql, params=None):
    with connection.cursor() as cur:
        cur.execute(sql, params or [])
        cols = [d[0] for d in cur.description]
        return [dict(zip(cols, row)) for row in cur.fetchall()]


class ReportViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated, HasRolePermission]
    required_perms = {
        "financial_summary": "billing.read",
        "patient_census": "emr.read",
        "pharmacy_dispense": "pharmacy.dispense",
        "emergency_acuity": "emr.read",
        "diagnosis_volume": "lab_rad.result",
        "event_activity": "patient.read",
    }

    def _guard(self, request, key):
        from apps.core.permissions import effective_perms
        perms = effective_perms(request)
        if "admin.all" in perms or key in perms:
            return None
        return Response({"detail": "Forbidden"}, status=status.HTTP_403_FORBIDDEN)

    @action(detail=False, methods=["get"])
    def financial_summary(self, request):
        denied = self._guard(request, "billing.read")
        if denied: return denied
        since = request.query_params.get("since")
        since_clause = "AND issued_at >= %s" if since else ""
        params = [since] if since else []
        sql = f"""
            SELECT
                COUNT(*)                                            AS invoices,
                COALESCE(SUM(total),0)::numeric(12,2)               AS total_billed,
                COALESCE(SUM(insurance_covers),0)::numeric(12,2)    AS insurance_covers,
                COALESCE(SUM(patient_pays),0)::numeric(12,2)        AS patient_pays,
                COALESCE(SUM(CASE WHEN status='paid' THEN total ELSE 0 END),0)::numeric(12,2) AS collected
            FROM mcms_billing.invoice
            WHERE 1=1 {since_clause}
        """
        return Response(_rows(sql, params)[0])

    @action(detail=False, methods=["get"])
    def patient_census(self, request):
        denied = self._guard(request, "emr.read")
        if denied: return denied
        sql = """
            SELECT
                (SELECT COUNT(*) FROM mcms_emr.patient)                              AS total_patients,
                (SELECT COUNT(*) FROM mcms_emr.encounter WHERE status='in_progress') AS active_encounters,
                (SELECT COUNT(*) FROM mcms_emr.encounter WHERE status='finished')    AS closed_encounters,
                (SELECT COUNT(*) FROM mcms_icu.admission WHERE status='active')      AS icu_active,
                (SELECT COUNT(*) FROM mcms_emergency.triage WHERE status='in_treatment') AS er_active
        """
        return Response(_rows(sql)[0])

    @action(detail=False, methods=["get"])
    def pharmacy_dispense(self, request):
        denied = self._guard(request, "pharmacy.dispense")
        if denied: return denied
        limit = int(request.query_params.get("limit", 50))
        sql = """
            SELECT d.dispensation_id, d.mrn, di.generic_name AS drug, d.quantity,
                   d.dispensed_at, u.username AS dispensed_by
            FROM mcms_rx.dispensation d
            LEFT JOIN mcms_rx.drug_item di ON di.drug_item_id = d.drug_item_id
            LEFT JOIN mcms_core.app_user u ON u.user_id = d.dispensed_by
            ORDER BY d.dispensed_at DESC NULLS LAST
            LIMIT %s
        """
        return Response(_rows(sql, [limit]))

    @action(detail=False, methods=["get"])
    def emergency_acuity(self, request):
        denied = self._guard(request, "emr.read")
        if denied: return denied
        sql = """
            SELECT esi_level, COUNT(*) AS tramses
            FROM mcms_emergency.triage
            GROUP BY esi_level ORDER BY esi_level
        """
        return Response(_rows(sql))

    @action(detail=False, methods=["get"])
    def diagnosis_volume(self, request):
        denied = self._guard(request, "lab_rad.result")
        if denied: return denied
        sql = """
            SELECT 'lab' AS domain, COUNT(*) AS orders FROM mcms_lab.lab_order
            UNION ALL
            SELECT 'radiology', COUNT(*) FROM mcms_rad.study_request
        """
        return Response(_rows(sql))

    @action(detail=False, methods=["get"])
    def event_activity(self, request):
        denied = self._guard(request, "patient.read")
        if denied: return denied
        sql = """
            SELECT kind, COUNT(*) AS events
            FROM mcms_core.event_log
            GROUP BY kind ORDER BY events DESC
        """
        return Response(_rows(sql))
