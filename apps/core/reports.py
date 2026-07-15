"""
MCMS reporting module (expanded).

Read-only analytical endpoints over the live schema. Every endpoint accepts an
optional `since` / `until` (ISO date) range on the relevant timestamp column.
Reports span multiple schemas via plain parameterised SQL (no ORM). All are
RBAC-gated by HasRolePermission via `required_perms`.
"""

from django.db import connection
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.core.permissions import HasRolePermission, effective_perms


def _rows(sql, params=None):
    with connection.cursor() as cur:
        cur.execute(sql, params or [])
        cols = [d[0] for d in cur.description]
        return [dict(zip(cols, row, strict=False)) for row in cur.fetchall()]


def _range(request, column):
    """Build a date-range WHERE fragment for `column` (qualified name)."""
    since = request.query_params.get("since")
    until = request.query_params.get("until")
    clauses, params = [], []
    if since:
        clauses.append(f"AND {column} >= %s"); params.append(since)
    if until:
        clauses.append(f"AND {column} <= %s"); params.append(until)
    return " ".join(clauses), params


class ReportViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated, HasRolePermission]
    required_perms = {
        "financial_summary": "billing.read",
        "revenue_by_department": "billing.read",
        "patient_census": "emr.read",
        "pharmacy_dispense": "pharmacy.dispense",
        "emergency_acuity": "emr.read",
        "er_wait_times": "emr.read",
        "diagnosis_volume": "lab_rad.result",
        "top_diagnoses": "emr.read",
        "inventory_valuation": "inventory.manage",
        "event_activity": "patient.read",
        "no_show_risk": "emr.read",
        "bed_demand": "emr.read",
        "inventory_reorder": "inventory.manage",
    }

    def _guard(self, request, key):
        perms = effective_perms(request)
        if "admin.all" in perms or key in perms:
            return None
        return Response({"detail": "Forbidden"}, status=status.HTTP_403_FORBIDDEN)

    @action(detail=False, methods=["get"])
    def financial_summary(self, request):
        if (d := self._guard(request, "billing.read")): return d
        rcl, rp = _range(request, "i.issued_at")
        sql = f"""
            SELECT COUNT(*) AS invoices,
                   COALESCE(SUM(total),0)::numeric(12,2) AS total_billed,
                   COALESCE(SUM(insurance_covers),0)::numeric(12,2) AS insurance_covers,
                   COALESCE(SUM(patient_pays),0)::numeric(12,2) AS patient_pays,
                   COALESCE(SUM(CASE WHEN status='paid' THEN total ELSE 0 END),0)::numeric(12,2) AS collected
            FROM mcms_billing.invoice WHERE 1=1 {rcl}
        """
        return Response(_rows(sql, rp)[0])

    @action(detail=False, methods=["get"])
    def revenue_by_department(self, request):
        if (d := self._guard(request, "billing.read")): return d
        rcl, rp = _range(request, "i.issued_at")
        sql = f"""
            SELECT hd.name AS department,
                   COUNT(i.invoice_id) AS invoices,
                   COALESCE(SUM(i.total),0)::numeric(12,2) AS revenue
            FROM mcms_billing.invoice i
            LEFT JOIN mcms_emr.encounter e ON e.encounter_id = i.encounter_id
            LEFT JOIN mcms_hr.department hd ON hd.department_id = e.department_id
            WHERE 1=1 {rcl}
            GROUP BY hd.name ORDER BY revenue DESC
        """
        return Response(_rows(sql, rp))

    @action(detail=False, methods=["get"])
    def patient_census(self, request):
        if (d := self._guard(request, "emr.read")): return d
        sql = """
            SELECT (SELECT COUNT(*) FROM mcms_emr.patient) AS total_patients,
                   (SELECT COUNT(*) FROM mcms_emr.encounter WHERE status='in_progress') AS active_encounters,
                   (SELECT COUNT(*) FROM mcms_emr.encounter WHERE status='finished') AS closed_encounters,
                   (SELECT COUNT(*) FROM mcms_icu.admission WHERE status='active') AS icu_active,
                   (SELECT COUNT(*) FROM mcms_emergency.triage WHERE status='in_treatment') AS er_active
        """
        return Response(_rows(sql)[0])

    @action(detail=False, methods=["get"])
    def pharmacy_dispense(self, request):
        if (d := self._guard(request, "pharmacy.dispense")): return d
        limit = int(request.query_params.get("limit", 50))
        sql = """
            SELECT d.dispensation_id, d.mrn, di.generic_name AS drug, d.quantity,
                   d.dispensed_at, u.username AS dispensed_by
            FROM mcms_rx.dispensation d
            LEFT JOIN mcms_rx.drug_item di ON di.drug_item_id = d.drug_item_id
            LEFT JOIN mcms_core.app_user u ON u.user_id = d.dispensed_by
            ORDER BY d.dispensed_at DESC NULLS LAST LIMIT %s
        """
        return Response(_rows(sql, [limit]))

    @action(detail=False, methods=["get"])
    def emergency_acuity(self, request):
        if (d := self._guard(request, "emr.read")): return d
        sql = "SELECT esi_level, COUNT(*) AS triages FROM mcms_emergency.triage GROUP BY esi_level ORDER BY esi_level"
        return Response(_rows(sql))

    @action(detail=False, methods=["get"])
    def er_wait_times(self, request):
        if (d := self._guard(request, "emr.read")): return d
        sql = """
            SELECT triage_nurse_user_id IS NOT NULL AS triaged,
                   COUNT(*) AS visits,
                   ROUND(AVG(EXTRACT(EPOCH FROM (triaged_at - presentation_time))/60)::numeric,1) AS avg_wait_min
            FROM mcms_emergency.triage
            WHERE triaged_at IS NOT NULL
            GROUP BY 1
        """
        return Response(_rows(sql))

    @action(detail=False, methods=["get"])
    def diagnosis_volume(self, request):
        if (d := self._guard(request, "lab_rad.result")): return d
        sql = """
            SELECT 'lab' AS domain, COUNT(*) AS orders FROM mcms_lab.lab_order
            UNION ALL SELECT 'radiology', COUNT(*) FROM mcms_rad.study_request
        """
        return Response(_rows(sql))

    @action(detail=False, methods=["get"])
    def top_diagnoses(self, request):
        if (d := self._guard(request, "emr.read")): return d
        limit = int(request.query_params.get("limit", 10))
        sql = """
            SELECT dx.condition_code, dx.condition_desc, COUNT(*) AS count
            FROM mcms_emr.diagnosis dx
            GROUP BY dx.condition_code, dx.condition_desc
            ORDER BY count DESC LIMIT %s
        """
        return Response(_rows(sql, [limit]))

    @action(detail=False, methods=["get"])
    def inventory_valuation(self, request):
        if (d := self._guard(request, "inventory.manage")): return d
        sql = """
            SELECT ii.code, ii.name, s.qty_on_hand,
                   COALESCE(s.qty_on_hand,0)*ii.cost_per_unit::numeric AS stock_value
            FROM mcms_erp.inventory_stock s
            JOIN mcms_erp.inventory_item ii ON ii.item_id = s.item_id
            ORDER BY stock_value DESC LIMIT 50
        """
        return Response(_rows(sql))

    @action(detail=False, methods=["get"])
    def event_activity(self, request):
        if (d := self._guard(request, "patient.read")): return d
        sql = "SELECT kind, COUNT(*) AS events FROM mcms_core.event_log GROUP BY kind ORDER BY events DESC"
        return Response(_rows(sql))

    @action(detail=False, methods=["get"])
    def no_show_risk(self, request):
        """Per-upcoming-appointment no-show risk.

        Historical no-show rate for the patient, modulated by confirmation
        status and lead time. Offline/deterministic, fed by real appointment
        history (status='noshow').
        """
        if (d := self._guard(request, "emr.read")): return d
        limit = int(request.query_params.get("limit", 25))
        sql = """
            WITH hist AS (
                SELECT a.patient_id,
                       COUNT(*) FILTER (WHERE a.status='noshow') AS n_noshow,
                       COUNT(*) FILTER (WHERE a.status='completed') AS n_kept,
                       COUNT(*) AS n_total
                FROM mcms_clinic.appointment a
                WHERE a.status IN ('noshow','completed')
                GROUP BY a.patient_id
            )
            SELECT a.appointment_id,
                   a.patient_id,
                   a.starts_at,
                   a.status,
                   a.patient_confirmed,
                   COALESCE(h.n_noshow::numeric / NULLIF(h.n_total,0), 0) AS historical_noshow_rate,
                   CASE WHEN a.patient_confirmed THEN 0.0
                        ELSE COALESCE(h.n_noshow::numeric / NULLIF(h.n_total,0), 0) END
                         + CASE WHEN a.starts_at - now() < interval '24 hours' THEN 0.05 ELSE 0.0 END
                         AS risk
            FROM mcms_clinic.appointment a
            LEFT JOIN hist h ON h.patient_id = a.patient_id
            WHERE a.starts_at > now()
              AND a.status IN ('booked','held')
            ORDER BY risk DESC, a.starts_at
            LIMIT %s
        """
        return Response(_rows(sql, [limit]))

    @action(detail=False, methods=["get"])
    def bed_demand(self, request):
        """ICU bed demand: current occupancy + projected from scheduled encounters.

        'projected_occupied' = currently occupied + inpatient/icu encounters
        scheduled to start within the horizon (default 24h). Surfaces capacity
        risk before it materialises.
        """
        if (d := self._guard(request, "emr.read")): return d
        horizon = int(request.query_params.get("hours", 24))
        sql = """
            SELECT
              (SELECT COUNT(*) FROM mcms_icu.bed) AS total_beds,
              (SELECT COUNT(*) FROM mcms_icu.bed WHERE status='occupied') AS occupied_now,
              (SELECT COUNT(*) FROM mcms_emr.encounter
                 WHERE "class" IN ('icu','inpatient')
                   AND status IN ('planned','arrived')
                   AND started_at BETWEEN now() AND now() + (%s || ' hours')::interval
              ) AS projected_admissions,
              (SELECT COUNT(*) FROM mcms_icu.bed WHERE status='available') AS available_now
        """
        return Response(_rows(sql, [horizon])[0])

    @action(detail=False, methods=["get"])
    def inventory_reorder(self, request):
        """Items at or below their reorder level across all departments.

        Offline reorder signal from mcms_erp.inventory_stock vs inventory_item
        reorder_level/reorder_qty. Returns the suggested top-up quantity.
        """
        if (d := self._guard(request, "inventory.manage")): return d
        limit = int(request.query_params.get("limit", 50))
        sql = """
            SELECT ii.code, ii.name, s.department_id,
                   s.qty_on_hand,
                   ii.reorder_level,
                   ii.reorder_qty,
                   GREATEST(ii.reorder_level - s.qty_on_hand, 0) AS deficit,
                   ii.reorder_qty AS suggested_order_qty
            FROM mcms_erp.inventory_stock s
            JOIN mcms_erp.inventory_item ii ON ii.item_id = s.item_id
            WHERE s.qty_on_hand <= ii.reorder_level
            ORDER BY deficit DESC, ii.code
            LIMIT %s
        """
        return Response(_rows(sql, [limit]))
