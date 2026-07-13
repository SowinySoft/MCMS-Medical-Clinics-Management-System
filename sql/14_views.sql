-- ============================================================
-- MCMS · 14 · Reporting Views
-- Cross-cutting views for clinical, operational, financial and inventory
-- reporting across all schemas. Each view is read-only and can be
-- consumed by Django REST Framework / serializers or BI tools.
-- ============================================================

-- ---------- 1. Patient 360° summary ----------
-- Per patient: demographics + recent encounter + open diagnoses + allergies count + last vitals.
CREATE OR REPLACE VIEW mcms_emr.v_patient_360 AS
SELECT
   p.patient_id,
   p.mrn,
   pr.display_name,
   pr.gender,
   pr.date_of_birth,
   age(pr.date_of_birth) AS age,
   pr.blood_type,
   (SELECT COUNT(*) FROM mcms_emr.allergy a WHERE a.patient_id=p.patient_id AND a.is_active)   AS active_allergies,
   (SELECT COUNT(*) FROM mcms_emr.diagnosis d WHERE d.patient_id=p.patient_id AND d.status='active') AS active_dx,
   (SELECT COUNT(*) FROM mcms_emr.encounter e WHERE e.patient_id=p.patient_id)                  AS encounter_count,
   (SELECT encounter_id FROM mcms_emr.encounter e WHERE e.patient_id=p.patient_id ORDER BY started_at DESC NULLS LAST LIMIT 1) AS latest_encounter_id,
   (SELECT status   FROM mcms_emr.encounter e WHERE e.patient_id=p.patient_id ORDER BY started_at DESC NULLS LAST LIMIT 1) AS latest_encounter_status,
   p.insurance_provider,
   p.insurance_policy_no
FROM mcms_emr.patient p
JOIN mcms_core.party pr ON pr.party_id = p.party_id;

-- ---------- 2. Encounter timeline ----------
-- All encounters for a patient with attending clinician name + dept.
CREATE OR REPLACE VIEW mcms_emr.v_encounter_timeline AS
SELECT
   e.encounter_id,
   e.mrn,
   p.display_name AS patient_name,
   e.class,
   e.status,
   e.reason_for_visit,
   d.code          AS dept_code,
   d.name          AS dept_name,
   pr.display_name AS attending,
   u.role          AS attending_role,
   e.started_at,
   e.ended_at,
   age(now(), e.started_at) AS duration_running
FROM mcms_emr.encounter e
JOIN mcms_emr.patient pt ON pt.patient_id = e.patient_id
JOIN mcms_core.party p   ON p.party_id = pt.party_id
LEFT JOIN mcms_hr.department d ON d.department_id = e.department_id
LEFT JOIN mcms_core.app_user u ON u.user_id = e.attending_user_id
LEFT JOIN mcms_core.party pr  ON pr.party_id = u.party_id;

-- ---------- 3. Daily census (admission / discharge counts) ----------
-- Per day per department: encounters opened + closed + currently-in-progress.
CREATE OR REPLACE VIEW mcms_emr.v_daily_census AS
SELECT
   d.department_id,
   d.code AS dept_code,
   d.name AS dept_name,
   e.started_at::date AS day,
   COUNT(*) FILTER (WHERE e.status='in_progress') AS in_progress,
   COUNT(*) FILTER (WHERE e.status='finished')    AS finished_today,
   COUNT(*) AS total_opened
FROM mcms_emr.encounter e
JOIN mcms_hr.department d ON d.department_id = e.department_id
WHERE e.started_at IS NOT NULL
GROUP BY d.department_id, d.code, d.name, e.started_at::date;

-- ---------- 4. ED triage board ----------
-- Real-time view of ED: triage wait, ESI, status, disposition.
CREATE OR REPLACE VIEW mcms_emergency.v_ed_board AS
SELECT
   t.triage_id,
   t.ed_visit_no,
   p.display_name AS patient_name,
   p.gender,
   age(p.date_of_birth) AS age,
   t.presentation_time,
   t.chief_complaint,
   t.esi_level,
   t.trauma_alert,
   t.vital_sbp_mmhg,
   t.vital_spo2_pct,
   t.vital_gcs,
   t.status,
   t.disposition,
   EXTRACT(EPOCH FROM (now() - t.presentation_time))/60::int AS minutes_in_ed,
   pn.display_name AS triage_nurse
FROM mcms_emergency.triage t
JOIN mcms_emr.patient pt ON pt.patient_id = t.patient_id
JOIN mcms_core.party p   ON p.party_id = pt.party_id
LEFT JOIN mcms_core.app_user u  ON u.user_id = t.triage_nurse_user_id
LEFT JOIN mcms_core.party pn   ON pn.party_id = u.party_id
WHERE t.status NOT IN ('discharged','ama','died');

-- ---------- 5. Surgery schedule board ----------
CREATE OR REPLACE VIEW mcms_surgical.v_surgery_board AS
SELECT
   s.surgery_id,
   s.operation_no,
   pt.mrn,
   p.display_name AS patient_name,
   pc.cpt_code,
   pc.name         AS procedure_name,
   or_room.code    AS or_code,
   or_room.status  AS or_status,
   s.laterality,
   s.status,
   s.scheduled_at,
   s.incision_at,
   s.closure_at,
   surg.display_name AS surgeon,
   an.display_name   AS anaesthetist,
   d.code            AS primary_dept
FROM mcms_surgical.surgery s
JOIN mcms_emr.patient pt   ON pt.patient_id = s.patient_id
JOIN mcms_core.party p     ON p.party_id = pt.party_id
JOIN mcms_surgical.procedure_catalog pc ON pc.proc_cat_id = s.procedure_id
JOIN mcms_surgical.operating_room or_room ON or_room.or_id = s.or_id
LEFT JOIN mcms_core.app_user u_surg ON u_surg.user_id = s.surgeon_user_id
LEFT JOIN mcms_core.party    surg   ON surg.party_id = u_surg.party_id
LEFT JOIN mcms_core.app_user u_ane  ON u_ane.user_id  = s.anaesthetist_user_id
LEFT JOIN mcms_core.party    an     ON an.party_id    = u_ane.party_id
LEFT JOIN mcms_hr.department d      ON d.department_id = s.primary_dept_id
WHERE s.status NOT IN ('completed','cancelled')
ORDER BY s.scheduled_at;

-- ---------- 6. ICU live bed board ----------
CREATE OR REPLACE VIEW mcms_icu.v_bed_board AS
SELECT
   b.bed_id,
   b.room_code,
   b.bed_label,
   b.status,
   b.level,
   b.has_ventilator,
   b.has_dialysis,
   d.code AS dept_code,
   a.patient_id,
   pt.mrn,
   p.display_name AS patient_name,
   a.admitted_at
FROM mcms_icu.bed b
JOIN mcms_hr.department d ON d.department_id = b.department_id
LEFT JOIN mcms_icu.admission a ON a.bed_id = b.bed_id AND a.status IN ('admitted','active')
LEFT JOIN mcms_emr.patient pt ON pt.patient_id = a.patient_id
LEFT JOIN mcms_core.party p   ON p.party_id = pt.party_id;

-- ---------- 7. Pharmacy low-stock report ----------
-- All drugs whose total on-hand is at/below reorder level.
CREATE OR REPLACE VIEW mcms_rx.v_low_stock AS
SELECT
   di.drug_item_id,
   di.generic_name,
   di.brand_name,
   COALESCE(SUM(dl.on_hand_qty) FILTER (WHERE dl.status='on_hand'), 0) AS qty_on_hand,
   di.reorder_level,
   di.reorder_qty,
   COUNT(*) FILTER (WHERE dl.lot_id IS NOT NULL) AS lot_count,
   COUNT(*) FILTER (WHERE dl.expires_on < now()::date AND dl.status='on_hand') AS expiring_lots
FROM mcms_rx.drug_item di
LEFT JOIN mcms_rx.drug_lot dl ON dl.drug_item_id = di.drug_item_id
GROUP BY di.drug_item_id, di.generic_name, di.brand_name, di.reorder_level, di.reorder_qty
HAVING COALESCE(SUM(dl.on_hand_qty) FILTER (WHERE dl.status='on_hand'), 0) <= di.reorder_level;

-- ---------- 8. Lab turn-around time (TAT) by test ----------
CREATE OR REPLACE VIEW mcms_lab.v_tat AS
WITH base AS (
   SELECT tc.test_id, tc.name AS test_name, tc.category,
          (EXTRACT(EPOCH FROM (r.verified_at - s.collected_at))/60)::numeric(10,1) AS minutes
   FROM mcms_lab.result r
   JOIN mcms_lab.sample s        ON s.sample_id = r.sample_id
   JOIN mcms_lab.test_catalog tc ON tc.test_id  = r.test_id
   WHERE r.verified_at IS NOT NULL
)
SELECT
   test_id,
   test_name,
   category,
   COUNT(*)                    AS results_count,
   AVG(minutes)                AS avg_minutes,
   PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY minutes) AS p50_minutes,
   PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY minutes) AS p95_minutes
FROM base
GROUP BY test_id, test_name, category;

-- ---------- 9. Radiology study pipeline ----------
CREATE OR REPLACE VIEW mcms_rad.v_study_pipeline AS
SELECT
   sr.study_id,
   sr.accession_no,
   p.display_name AS patient_name,
   pt.mrn,
   ec.name         AS exam,
   ms.code         AS suite,
   sr.status,
   sr.priority,
   sr.requested_by,
   sr.scheduled_at,
   sr.started_at,
   sr.completed_at,
   sr.verified_at
FROM mcms_rad.study_request sr
JOIN mcms_emr.patient pt ON pt.patient_id = sr.patient_id
JOIN mcms_core.party   p  ON p.party_id   = pt.party_id
JOIN mcms_rad.exam_catalog ec ON ec.exam_id = sr.exam_id
LEFT JOIN mcms_rad.modality_suite ms ON ms.suite_id = sr.suite_id
WHERE sr.status NOT IN ('verified','cancelled');

-- ---------- 10. Revenue by department / service type ----------
CREATE OR REPLACE VIEW mcms_billing.v_revenue_by_dept AS
SELECT
   sp.service_type,
   d.code  AS dept_code,
   d.name  AS dept_name,
   COUNT(DISTINCT i.invoice_id) AS invoice_count,
   SUM(il.line_total)           AS gross_revenue,
   AVG(il.line_total)           AS avg_line_value
FROM mcms_billing.invoice_line il
JOIN mcms_billing.invoice i   ON i.invoice_id = il.invoice_id
JOIN mcms_billing.service_price sp ON sp.service_id = il.service_id
LEFT JOIN mcms_hr.department d ON d.department_id = sp.department_id
GROUP BY sp.service_type, d.code, d.name;

-- ---------- 11. Outstanding invoices aging ----------
CREATE OR REPLACE VIEW mcms_billing.v_invoice_aging AS
SELECT
   i.invoice_id,
   i.invoice_no,
   pt.mrn,
   p.display_name AS patient_name,
   i.status,
   i.total,
   i.issued_at,
   i.due_date,
   COALESCE(pay.paid, 0)         AS paid_amount,
   i.total - COALESCE(pay.paid, 0) AS balance,
   CASE
     WHEN now()::date < i.due_date  THEN 'current'
     WHEN now()::date < i.due_date + interval '30 days'  THEN '1-30'
     WHEN now()::date < i.due_date + interval '60 days'  THEN '31-60'
     WHEN now()::date < i.due_date + interval '90 days'  THEN '61-90'
     ELSE 'over_90'
   END AS aging_bucket
FROM mcms_billing.invoice i
JOIN mcms_emr.patient pt ON pt.patient_id = i.patient_id
JOIN mcms_core.party p   ON p.party_id   = pt.party_id
LEFT JOIN (SELECT invoice_id, SUM(amount) AS paid FROM mcms_billing.payment GROUP BY 1) pay
       ON pay.invoice_id = i.invoice_id
WHERE i.status NOT IN ('paid','draft','cancelled');

-- ---------- 12. Patient ledger (consolidated across departments) ----------
-- One row per chargeable item consolidated across departments.
CREATE OR REPLACE VIEW mcms_billing.v_patient_ledger AS
SELECT
   i.invoice_id,
   i.invoice_no,
   pt.mrn,
   p.display_name AS patient_name,
   il.line_id,
   il.description AS line_description,
   sp.service_type,
   d.name         AS dept_name,
   il.qty,
   il.unit_price,
   il.line_total,
   i.issued_at,
   i.status AS invoice_status
FROM mcms_billing.invoice_line il
JOIN mcms_billing.invoice i     ON i.invoice_id = il.invoice_id
JOIN mcms_emr.patient pt         ON pt.patient_id = i.patient_id
JOIN mcms_core.party p          ON p.party_id   = pt.party_id
LEFT JOIN mcms_billing.service_price sp ON sp.service_id = il.service_id
LEFT JOIN mcms_hr.department d   ON d.department_id = sp.department_id;

-- ---------- 13. Event log timeline (System-wide audit feed) ----------
CREATE OR REPLACE VIEW mcms_core.v_event_feed AS
SELECT
   e.seq,
   e.occurred_at,
   e.kind,
   e.severity,
   e.channel,
   e.source_schema,
   e.source_table,
   e.source_id,
   e.payload,
   pr.display_name AS actor_name,
   u.role          AS actor_role,
   psubj.display_name AS subject_name
FROM mcms_core.event_log e
LEFT JOIN mcms_core.app_user u  ON u.user_id  = e.actor_user_id
LEFT JOIN mcms_core.party    pr ON pr.party_id = u.party_id
LEFT JOIN mcms_core.party    psubj ON psubj.party_id = e.subject_party_id
ORDER BY e.seq DESC;

-- ---------- 14. HR payroll summary ----------
CREATE OR REPLACE VIEW mcms_hr.v_payroll_summary AS
SELECT
   pp.code          AS period,
   pp.start_date,
   pp.end_date,
   d.code           AS dept_code,
   d.name           AS dept_name,
   COUNT(DISTINCT pi.employee_id)   AS employees_in_period,
   SUM(pi.base_amount)             AS total_base,
   SUM(pi.overtime_amount)         AS total_overtime,
   SUM(pi.bonus_amount)             AS total_bonus,
   SUM(pi.deduction_amount)         AS total_deductions,
   SUM(pi.net_amount)               AS total_net,
   COUNT(*) FILTER (WHERE pi.is_paid) AS paid_count
FROM mcms_hr.payroll_period pp
JOIN mcms_hr.payroll_item pi ON pi.period_id = pp.period_id
JOIN mcms_hr.employee e      ON e.employee_id = pi.employee_id
LEFT JOIN mcms_hr.department d ON d.department_id = e.primary_department_id
GROUP BY pp.code, pp.start_date, pp.end_date, d.code, d.name;

-- ---------- 15. Physiotherapy session throughput ----------
CREATE OR REPLACE VIEW mcms_physio.v_session_throughput AS
SELECT
   tp.plan_id,
   pt.mrn,
   p.display_name AS patient_name,
   u.username     AS therapist,
   tp.diagnosis,
   tp.sessions_planned,
   tp.sessions_completed,
   tp.status,
   COUNT(s.session_id) FILTER (WHERE s.status='completed') AS completed_sessions_count,
   COUNT(s.session_id) FILTER (WHERE s.status='no_show')   AS no_shows
FROM mcms_physio.treatment_plan tp
JOIN mcms_emr.patient pt ON pt.patient_id = tp.patient_id
JOIN mcms_core.party p   ON p.party_id   = pt.party_id
LEFT JOIN mcms_core.app_user u ON u.user_id = tp.therapist_user_id
LEFT JOIN mcms_physio.session s ON s.plan_id = tp.plan_id
GROUP BY tp.plan_id, pt.mrn, p.display_name, u.username, tp.diagnosis, tp.sessions_planned, tp.sessions_completed, tp.status;

-- ---------- 16. ERP stock per department ----------
CREATE OR REPLACE VIEW mcms_erp.v_department_stock AS
SELECT
   ii.item_id,
   ii.code,
   ii.name,
   ii.type,
   d.code AS dept_code,
   d.name AS dept_name,
   isk.qty_on_hand,
   isk.qty_reserved,
   (isk.qty_on_hand - isk.qty_reserved) AS qty_available,
   ii.reorder_level,
   CASE WHEN isk.qty_on_hand <= ii.reorder_level THEN 'REORDER' ELSE 'OK' END AS stock_state
FROM mcms_erp.inventory_stock isk
JOIN mcms_erp.inventory_item ii  ON ii.item_id = isk.item_id
JOIN mcms_hr.department d       ON d.department_id = isk.department_id;
