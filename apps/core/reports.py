"""
MCMS reporting module (expanded).

Read-only analytical endpoints over the live schema. Every endpoint accepts an
optional `since` / `until` (ISO date) range on the relevant timestamp column.
Reports span multiple schemas via plain parameterised SQL (no ORM). All are
RBAC-gated by HasRolePermission via `required_perms`.
"""

from django.db import connection
from django.utils import timezone
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
        "los": "emr.read",
        "readmissions": "emr.read",
        "hai_kpis": "emr.read",
        "moh_report": "emr.read",
        # Phase 17.1 - HR/payroll + vital records + high-demand ops reports
        "monthly_payroll": "payroll.read",
        "birth_certificates": "vital_records.read",
        "death_certificates": "vital_records.read",
        "claims_status": "billing.read",
        "lab_turnaround": "lab_rad.result",
        "appointment_utilization": "emr.read",
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

    # --------------------------------------------------- Phase 10: regulatory / exec analytics
    @action(detail=False, methods=["get"])
    def los(self, request):
        """Length-of-stay (days): avg + median overall and by encounter class.

        Derived from mcms_emr.encounter.started_at / ended_at. Read-only,
        date-range aware on started_at.
        """
        if (d := self._guard(request, "emr.read")):
            return d
        rcl, rp = _range(request, "started_at")
        sql = f"""
            SELECT
                   COUNT(*) FILTER (WHERE ended_at IS NOT NULL) AS closed,
                   ROUND(AVG(EXTRACT(EPOCH FROM (ended_at - started_at))
                         / 86400.0)::numeric, 2) AS avg_los_days,
                   PERCENTILE_CONT(0.5) WITHIN GROUP (
                       ORDER BY EXTRACT(EPOCH FROM (ended_at - started_at)) / 86400.0
                   )::numeric(10,2) AS median_los_days
            FROM mcms_emr.encounter
            WHERE ended_at IS NOT NULL {rcl}
        """
        overall = _rows(sql, rp)[0]
        sql_by = f"""
            SELECT "class",
                   COUNT(*) AS closed,
                   ROUND(AVG(EXTRACT(EPOCH FROM (ended_at - started_at))
                         / 86400.0)::numeric, 2) AS avg_los_days
            FROM mcms_emr.encounter
            WHERE ended_at IS NOT NULL {rcl}
            GROUP BY "class" ORDER BY avg_los_days DESC
        """
        return Response({"overall": overall, "by_class": _rows(sql_by, rp)})

    @action(detail=False, methods=["get"])
    def readmissions(self, request):
        """30-day readmission rate.

        A readmission = an encounter whose originating_encounter_id points to
        a prior encounter for the same patient discharged <= 30 days earlier.
        Read-only, deterministic.
        """
        if (d := self._guard(request, "emr.read")):
            return d
        sql = """
            SELECT
                (SELECT COUNT(*) FROM mcms_emr.encounter
                 WHERE ended_at IS NOT NULL) AS denominator,
                (SELECT COUNT(DISTINCT e.encounter_id)
                 FROM mcms_emr.encounter e
                 JOIN mcms_emr.encounter d
                   ON d.encounter_id = e.originating_encounter_id
                  AND d.patient_id = e.patient_id
                 WHERE e.originating_encounter_id IS NOT NULL
                   AND e.started_at <= d.ended_at + interval '30 days'
                   AND e.started_at >  d.ended_at
                ) AS readmissions,
                ROUND(
                    (SELECT COUNT(DISTINCT e.encounter_id)
                     FROM mcms_emr.encounter e
                     JOIN mcms_emr.encounter d
                       ON d.encounter_id = e.originating_encounter_id
                      AND d.patient_id = e.patient_id
                     WHERE e.originating_encounter_id IS NOT NULL
                       AND e.started_at <= d.ended_at + interval '30 days'
                       AND e.started_at >  d.ended_at
                    )::numeric
                    / NULLIF((SELECT COUNT(*) FROM mcms_emr.encounter
                             WHERE ended_at IS NOT NULL), 0), 4
                ) AS readmission_rate
        """
        return Response(_rows(sql)[0])

    @action(detail=False, methods=["get"])
    def hai_kpis(self, request):
        """Healthcare-associated infection / safety proxy KPIs.

        NOTE: there is no dedicated infection-surveillance table in this
        schema, so these are DERIVED PROXIES from ICU outcomes
        (deterministic, not faked clinical data):
          * icu_mortality_rate = expired / discharged (mcms_icu.admission)
          * icu_readmission_rate = ICU readmits within 30d
          * all_cause_30d_readmission_rate = from /readmissions/
        Read-only.
        """
        if (d := self._guard(request, "emr.read")):
            return d
        sql = """
            SELECT
                (SELECT COUNT(*) FROM mcms_icu.admission) AS icu_admissions,
                (SELECT COUNT(*) FROM mcms_icu.admission
                  WHERE expired_at IS NOT NULL) AS icu_expired,
                ROUND(
                    (SELECT COUNT(*) FROM mcms_icu.admission
                      WHERE expired_at IS NOT NULL)::numeric
                    / NULLIF((SELECT COUNT(*) FROM mcms_icu.admission), 0), 4
                ) AS icu_mortality_rate,
                (SELECT COUNT(*) FROM mcms_icu.admission
                  WHERE discharged_at IS NOT NULL) AS icu_discharged
        """
        icu = _rows(sql)[0]
        # all-cause 30d readmission rate (reuse logic)
        rm = self.readmissions(request).data
        icu.update({"all_cause_30d_readmission_rate": rm.get("readmission_rate")})
        return Response(icu)

    @action(detail=False, methods=["get"])
    def moh_report(self, request):
        """Consolidated MOH / NHA submission snapshot.

        Returns the period + KPI bundle a regulator would receive
        (no live submission/PHI-redaction here -- that is a later,
        separately-scoped transport step). Deterministic over real data.
        """
        if (d := self._guard(request, "emr.read")):
            return d
        rcl, rp = _range(request, "e.started_at")
        sql = f"""
            SELECT
                COUNT(*) FILTER (WHERE e.status='in_progress') AS active_encounters,
                COUNT(*) FILTER (WHERE e.status='finished')   AS finished_encounters,
                COUNT(*) AS total_encounters,
                COUNT(*) FILTER (WHERE e."class"='inpatient') AS inpatient,
                COUNT(*) FILTER (WHERE e."class"='icu')       AS icu
            FROM mcms_emr.encounter e
            WHERE 1=1 {rcl}
        """
        enc = _rows(sql, rp)[0]
        los = self.los(request).data["overall"]
        readmit = self.readmissions(request).data
        icu = self.hai_kpis(request).data
        report = {
            "report": "MOH/NHA consolidated",
            "generated_at": timezone.now().isoformat(),
            "period_since": request.query_params.get("since"),
            "period_until": request.query_params.get("until"),
            "encounters": enc,
            "los": los,
            "readmission_rate": readmit.get("readmission_rate"),
            "icu_mortality_rate": icu.get("icu_mortality_rate"),
        }
        return Response(report)

    # --------------------------------------------------- Phase 17.1: HR / Payroll
    @action(detail=False, methods=["get"])
    def monthly_payroll(self, request):
        """Monthly payroll accounting report for a payroll period.

        Returns the period header, the per-department roll-up (from the
        prebuilt mcms_hr.v_payroll_summary view) and the per-employee
        payroll lines with gross/net and paid status. Date-range on the
        period is optional via ?period_id= (defaults to the most recent
        closed/paid period).
        """
        if (d := self._guard(request, "payroll.read")):
            return d
        period_id = request.query_params.get("period_id")
        params = []
        where = ""
        if period_id:
            where = "WHERE pp.period_id=%s"
            params = [period_id]
        else:
            where = ("WHERE pp.period_id = (SELECT MAX(period_id) FROM "
                     "mcms_hr.payroll_period)")
        head = _rows(f"""
            SELECT pp.period_id, pp.code, pp.start_date, pp.end_date,
                   pp.status, pp.closed_at
            FROM mcms_hr.payroll_period pp {where}
        """, params)
        if not head:
            return Response({"detail": "no payroll period found"},
                            status=status.HTTP_404_NOT_FOUND)
        pid = head[0]["period_id"]
        code = head[0]["code"]
        summary = _rows("""
            SELECT period, start_date, end_date, dept_code, dept_name,
                   employees_in_period, total_base, total_overtime,
                   total_bonus, total_deductions, total_net, paid_count
            FROM mcms_hr.v_payroll_summary
            WHERE period = %s
            ORDER BY dept_name
        """, [code])
        lines = _rows("""
            SELECT e.employee_no, e.job_title,
                   d.code AS department_code, d.name AS department_name,
                   pi.base_amount, pi.overtime_amount, pi.bonus_amount,
                   pi.deduction_amount, pi.net_amount, pi.is_paid, pi.paid_at
            FROM mcms_hr.payroll_item pi
            JOIN mcms_hr.employee e ON e.employee_id = pi.employee_id
            LEFT JOIN mcms_hr.department d ON d.department_id = e.primary_department_id
            WHERE pi.period_id = %s
            ORDER BY d.name, e.employee_no
        """, [pid])
        return Response({
            "period": head[0],
            "department_summary": summary,
            "lines": lines,
            "totals": {
                "employees": len(lines),
                "gross": sum((r["base_amount"] or 0) + (r["overtime_amount"] or 0)
                             + (r["bonus_amount"] or 0) for r in lines),
                "deductions": sum((r["deduction_amount"] or 0) for r in lines),
                "net": sum((r["net_amount"] or 0) for r in lines),
                "paid": sum(1 for r in lines if r["is_paid"]),
            },
        })

    # --------------------------------------------------- Phase 17.1: Vital Records
    @action(detail=False, methods=["get"])
    def birth_certificates(self, request):
        """Issued birth certificates in a date range (newborn cases)."""
        if (d := self._guard(request, "vital_records.read")):
            return d
        rcl, rp = _range(request, "bc.birth_datetime")
        sql = f"""
            SELECT bc.registration_no, bc.birth_datetime, bc.birth_weight_g,
                   bc.gestation_weeks, bc.status,
                   nb.mrn AS newborn_mrn,
                   p.display_name AS mother_name,
                   f.code AS facility_code
            FROM mcms_vital_records.birth_certificate bc
            JOIN mcms_emr.patient nb ON nb.patient_id = bc.newborn_patient_id
            LEFT JOIN mcms_emr.patient mo ON mo.patient_id = bc.mother_patient_id
            LEFT JOIN mcms_core.party p ON p.party_id = mo.party_id
            JOIN mcms_core.facility f ON f.facility_id = bc.facility_id
            WHERE bc.status IN ('issued','amended') {rcl}
            ORDER BY bc.birth_datetime DESC
        """
        return Response(_rows(sql, rp))

    @action(detail=False, methods=["get"])
    def death_certificates(self, request):
        """Issued death certificates in a date range (recent deaths)."""
        if (d := self._guard(request, "vital_records.read")):
            return d
        rcl, rp = _range(request, "dc.death_datetime")
        sql = f"""
            SELECT dc.registration_no, dc.death_datetime, dc.cause_icd10,
                   dc.cause_text, dc.coroner_case, dc.status,
                   pt.mrn AS patient_mrn,
                   p.display_name AS patient_name,
                   f.code AS facility_code
            FROM mcms_vital_records.death_certificate dc
            JOIN mcms_emr.patient pt ON pt.patient_id = dc.patient_id
            JOIN mcms_core.party p ON p.party_id = pt.party_id
            JOIN mcms_core.facility f ON f.facility_id = dc.facility_id
            WHERE dc.status IN ('issued','amended') {rcl}
            ORDER BY dc.death_datetime DESC
        """
        return Response(_rows(sql, rp))

    # --------------------------------------------------- Phase 17.1: Claims status + TAT
    @action(detail=False, methods=["get"])
    def claims_status(self, request):
        """Insurance claim status breakdown + turnaround (submitted->adjudicated->paid)."""
        if (d := self._guard(request, "billing.read")):
            return d
        rcl, rp = _range(request, "c.submitted_at")
        breakdown = _rows(f"""
            SELECT status, COUNT(*) AS claims,
                   COALESCE(SUM(billed_amount),0)::numeric(12,2) AS billed,
                   COALESCE(SUM(approved_amount),0)::numeric(12,2) AS approved,
                   COALESCE(SUM(rejected_amount),0)::numeric(12,2) AS rejected
            FROM mcms_billing.insurance_claim c
            WHERE 1=1 {rcl}
            GROUP BY status ORDER BY claims DESC
        """, rp)
        tat = _rows(f"""
            SELECT
              ROUND(AVG(EXTRACT(EPOCH FROM (adjudicated_at - submitted_at))/86400.0)::numeric,2) AS avg_submit_to_adjudicate_days,
              ROUND(AVG(EXTRACT(EPOCH FROM (paid_at - submitted_at))/86400.0)::numeric,2) AS avg_submit_to_pay_days
            FROM mcms_billing.insurance_claim c
            WHERE adjudicated_at IS NOT NULL AND submitted_at IS NOT NULL {rcl}
        """, rp)
        return Response({"by_status": breakdown, "turnaround": tat[0]})

    # --------------------------------------------------- Phase 17.1: Lab demand / TAT proxy
    @action(detail=False, methods=["get"])
    def lab_turnaround(self, request):
        """Lab order demand: volume by priority and by facility (TAT proxy).

        The lab_order table records requested_at but not a result timestamp,
        so this reports order volume + avg age-since-request per priority and
        facility (a demand/backlog proxy, not fabricated result latency).
        """
        if (d := self._guard(request, "lab_rad.result")):
            return d
        rcl, rp = _range(request, "lo.requested_at")
        by_priority = _rows(f"""
            SELECT lo.order_priority AS priority, COUNT(*) AS orders,
                   ROUND(AVG(EXTRACT(EPOCH FROM (now() - lo.requested_at))/86400.0)::numeric,1) AS avg_age_days
            FROM mcms_lab.lab_order lo WHERE 1=1 {rcl}
            GROUP BY lo.order_priority ORDER BY orders DESC
        """, rp)
        by_facility = _rows(f"""
            SELECT f.code AS facility, COUNT(*) AS orders
            FROM mcms_lab.lab_order lo
            JOIN mcms_core.facility f ON f.facility_id = lo.facility_id
            WHERE 1=1 {rcl}
            GROUP BY f.code ORDER BY orders DESC
        """, rp)
        return Response({"by_priority": by_priority, "by_facility": by_facility})

    # --------------------------------------------------- Phase 17.1: Appointment utilization
    @action(detail=False, methods=["get"])
    def appointment_utilization(self, request):
        """Clinic appointment utilization: total, completed, no-show, cancelled, rate."""
        if (d := self._guard(request, "emr.read")):
            return d
        sql = """
            SELECT
                COUNT(*) AS total_appointments,
                COUNT(*) FILTER (WHERE status='completed') AS completed,
                COUNT(*) FILTER (WHERE status='noshow') AS no_shows,
                ROUND((COUNT(*) FILTER (WHERE status='noshow'))::numeric
                      / NULLIF(COUNT(*),0), 4) AS no_show_rate
            FROM mcms_clinic.appointment
        """
        return Response(_rows(sql)[0])
