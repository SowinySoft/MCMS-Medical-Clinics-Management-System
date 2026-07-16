-- ============================================================
-- Phase 17.1: Reports support seed
-- ============================================================
-- 1) RBAC: payroll.read permission + role maps
-- 2) HR seed: a July-2026 payroll period with employees + payroll items
--    (so the Monthly Payroll Accounting report has real rows)
-- 3) Billing seed: a few insurance_claims across statuses
--    (so the Claims Status / TAT report has real rows)
-- All values are clearly demo/test data; idempotent via ON CONFLICT / guards.
-- ============================================================

-- ---------- 1) RBAC
INSERT INTO mcms_core.permission (code, description)
VALUES ('payroll.read', 'View payroll / HR accounting reports')
ON CONFLICT (code) DO NOTHING;

INSERT INTO mcms_core.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM mcms_core.role r, mcms_core.permission p
WHERE p.code = 'payroll.read'
  AND r.code IN ('admin','hr_clerk','billing_clerk')
ON CONFLICT DO NOTHING;

-- ---------- 2) Payroll period + employees + items (July 2026)
INSERT INTO mcms_hr.payroll_period (code, start_date, end_date, status, closed_at)
VALUES ('2026-07', '2026-07-01', '2026-07-31', 'paid', now())
ON CONFLICT (code) DO NOTHING;

-- parties for the demo employees (fixed ids avoid collision + re-run safely)
INSERT INTO mcms_core.party (party_id, party_type, display_name)
VALUES
  (990001,'person','Payroll Test A'),(990002,'person','Payroll Test B'),
  (990003,'person','Payroll Test C'),(990004,'person','Payroll Test D'),
  (990005,'person','Payroll Test E'),(990006,'person','Payroll Test F')
ON CONFLICT (party_id) DO NOTHING;

-- keep the party sequence ahead of the explicit IDs we just inserted
-- (otherwise the deep-integrity audit flags the sequence as out-of-sync)
SELECT setval('mcms_core.party_party_id_seq',
              GREATEST(990006, (SELECT COALESCE(max(party_id),0) FROM mcms_core.party)));

INSERT INTO mcms_hr.employee
  (party_id, employee_no, primary_department_id, job_title, role,
   contract_type, status, base_salary_monthly, hired_at)
VALUES
  (990001,'EMP-9001',1,'Nurse','nurse','permanent','active',4200.00,'2024-01-15'),
  (990002,'EMP-9002',1,'Clerk','receptionist','permanent','active',3100.00,'2024-03-01'),
  (990003,'EMP-9003',2,'Cardiologist','physician','permanent','active',11500.00,'2023-06-10'),
  (990004,'EMP-9004',2,'Technician','lab_tech','permanent','active',5200.00,'2024-02-20'),
  (990005,'EMP-9005',3,'Surgeon','surgeon','permanent','active',13200.00,'2022-09-05'),
  (990006,'EMP-9006',3,'Therapist','physio_therapist','contract','active',4800.00,'2025-01-12')
ON CONFLICT (employee_no) DO NOTHING;

-- payroll items for the period (net_amount is GENERATED; is_paid/paid_at
-- default as needed — the generic audit trigger now logs these rows safely,
-- since fn_generic_audit derives the PK without casting boolean columns).
INSERT INTO mcms_hr.payroll_item
  (period_id, employee_id, base_amount, overtime_amount, deduction_amount, bonus_amount)
SELECT
  (SELECT period_id FROM mcms_hr.payroll_period WHERE code='2026-07'),
  e.employee_id, v.base, v.ot, v.ded, v.bonus
FROM (VALUES
  ('EMP-9001',4200.00,120.00,380.00,0.00),
  ('EMP-9002',3100.00,  0.00,290.00,50.00),
  ('EMP-9003',11500.00, 0.00,1500.00,800.00),
  ('EMP-9004',5200.00,300.00,520.00,0.00),
  ('EMP-9005',13200.00, 0.00,1900.00,1500.00),
  ('EMP-9006',4800.00,240.00,430.00,0.00)
) v(eno, base, ot, ded, bonus)
JOIN mcms_hr.employee e ON e.employee_no = v.eno
ON CONFLICT DO NOTHING;

-- ---------- 3) Insurance claims across statuses
-- invoice_id is NOT NULL; reuse an existing invoice. claim_status enum:
-- {draft,submitted,processing,approved,partial_paid,rejected,paid}
INSERT INTO mcms_billing.insurance_claim
  (invoice_id, patient_id, insurance_provider, policy_no, facility_id,
   claim_no_external, status, billed_amount, approved_amount,
   rejected_amount, submitted_at, adjudicated_at, paid_at)
SELECT i.invoice_id, (SELECT MIN(patient_id) FROM mcms_emr.patient), 'MOH', 'POL-9001',
       (SELECT facility_id FROM mcms_core.facility LIMIT 1),
       'CLM-9001','submitted', 1500.00, 0, 0,
       now()-'5 days'::interval, null, null
FROM (SELECT invoice_id FROM mcms_billing.invoice ORDER BY invoice_id LIMIT 1) i
WHERE NOT EXISTS (SELECT 1 FROM mcms_billing.insurance_claim WHERE claim_no_external='CLM-9001');

INSERT INTO mcms_billing.insurance_claim
  (invoice_id, patient_id, insurance_provider, policy_no, facility_id,
   claim_no_external, status, billed_amount, approved_amount,
   rejected_amount, submitted_at, adjudicated_at, paid_at)
SELECT i.invoice_id, (SELECT MIN(patient_id) FROM mcms_emr.patient), 'MOH', 'POL-9002',
       (SELECT facility_id FROM mcms_core.facility LIMIT 1),
       'CLM-9002','processing', 2400.00, 2100.00, 0,
       now()-'10 days'::interval, now()-'4 days'::interval, null
FROM (SELECT invoice_id FROM mcms_billing.invoice ORDER BY invoice_id LIMIT 1) i
WHERE NOT EXISTS (SELECT 1 FROM mcms_billing.insurance_claim WHERE claim_no_external='CLM-9002');

INSERT INTO mcms_billing.insurance_claim
  (invoice_id, patient_id, insurance_provider, policy_no, facility_id,
   claim_no_external, status, billed_amount, approved_amount,
   rejected_amount, submitted_at, adjudicated_at, paid_at)
SELECT i.invoice_id, (SELECT MIN(patient_id) FROM mcms_emr.patient), 'MOH', 'POL-9003',
       (SELECT facility_id FROM mcms_core.facility LIMIT 1),
       'CLM-9003','paid', 3200.00, 3000.00, 0,
       now()-'20 days'::interval, now()-'12 days'::interval, now()-'6 days'::interval
FROM (SELECT invoice_id FROM mcms_billing.invoice ORDER BY invoice_id LIMIT 1) i
WHERE NOT EXISTS (SELECT 1 FROM mcms_billing.insurance_claim WHERE claim_no_external='CLM-9003');

INSERT INTO mcms_billing.insurance_claim
  (invoice_id, patient_id, insurance_provider, policy_no, facility_id,
   claim_no_external, status, billed_amount, approved_amount,
   rejected_amount, submitted_at, adjudicated_at, paid_at)
SELECT i.invoice_id, (SELECT MIN(patient_id) FROM mcms_emr.patient), 'MOH', 'POL-9004',
       (SELECT facility_id FROM mcms_core.facility LIMIT 1),
       'CLM-9004','rejected', 900.00, 0, 900.00,
       now()-'15 days'::interval, now()-'9 days'::interval, null
FROM (SELECT invoice_id FROM mcms_billing.invoice ORDER BY invoice_id LIMIT 1) i
WHERE NOT EXISTS (SELECT 1 FROM mcms_billing.insurance_claim WHERE claim_no_external='CLM-9004');
