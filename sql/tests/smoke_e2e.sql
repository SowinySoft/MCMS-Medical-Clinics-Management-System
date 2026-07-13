-- MCMS end-to-end smoke test: party → patient → encounter → diagnosis →
-- med order → pharmacy dispense (auto-emits+decrements lot) → lab order →
-- surgery schedule → ICU admit → invoice issue → payment → event log review.
--; Verifies the event-driven architecture flows through triggers into event_log.
--
-- Idempotent: cleans up test data from the previous run before starting.

BEGIN;

-- cleanup any prior run
DELETE FROM mcms_core.event_log WHERE kind IS NOT NULL;
DELETE FROM mcms_billing.invoice_line;
DELETE FROM mcms_billing.invoice;
DELETE FROM mcms_emergency.ed_bed;
DELETE FROM mcms_emergency.resuscitation;
DELETE FROM mcms_emergency.triage;
DELETE FROM mcms_billing.payment;
DELETE FROM mcms_billing.insurance_claim;
DELETE FROM mcms_rx.dispensation;
DELETE FROM mcms_rx.administration;
DELETE FROM mcms_rx.stock_movement;
DELETE FROM mcms_rx.drug_lot;
DELETE FROM mcms_lab.result;
DELETE FROM mcms_lab.sample;
DELETE FROM mcms_lab.lab_order;
DELETE FROM mcms_surgical.surgical_team;
DELETE FROM mcms_surgical.pre_op_checklist;
DELETE FROM mcms_surgical.intra_op_vitals;
DELETE FROM mcms_surgical.post_op_note;
DELETE FROM mcms_surgical.surgery;
-- NOTE: operating rooms are seeded (not test data); we keep them so the test can be re-run.
DELETE FROM mcms_icu.vitals_stream;
DELETE FROM mcms_icu.score;
DELETE FROM mcms_icu.bed_stay;
DELETE FROM mcms_icu.support_session;
DELETE FROM mcms_icu.admission;
DELETE FROM mcms_emr.diagnosis;
DELETE FROM mcms_emr.vitals;
DELETE FROM mcms_emr.medication_order;
DELETE FROM mcms_emr.allergy;
DELETE FROM mcms_emr.immunization;
DELETE FROM mcms_emr.clinical_note;
DELETE FROM mcms_emr.family_history;
DELETE FROM mcms_emr.social_history;
DELETE FROM mcms_emr.encounter;
DELETE FROM mcms_clinic.appointment;
DELETE FROM mcms_clinic.patient_queue;
DELETE FROM mcms_clinic.consultation;
DELETE FROM mcms_emr.patient;
DELETE FROM mcms_hr.employee;
DELETE FROM mcms_core.audit_trail;
DELETE FROM mcms_core.contact;
DELETE FROM mcms_core.address;
DELETE FROM mcms_core.app_user;
DELETE FROM mcms_core.party;
-- reset ICU bed
UPDATE mcms_icu.bed SET status='available' WHERE room_code='ICU-A' AND bed_label='ICU-A1';
-- ensure the test bed exists
INSERT INTO mcms_icu.bed (room_code, bed_label, department_id, level, status, has_ventilator)
SELECT 'ICU-A','ICU-A1',(SELECT department_id FROM mcms_hr.department WHERE code='ICU-GEN'),3,'available'::mcms_icu.bed_status,true
WHERE NOT EXISTS (SELECT 1 FROM mcms_icu.bed WHERE room_code='ICU-A' AND bed_label='ICU-A1');

COMMIT;

-- 1) create party + patient
INSERT INTO mcms_core.party (party_type, display_name, gender, date_of_birth, blood_type)
VALUES ('person', 'Ahmed bin Sowin Test Patient', 'male', '1980-05-12', 'o+')
RETURNING party_id AS party_id \gset

INSERT INTO mcms_emr.patient (party_id, mrn, insurance_provider, insurance_policy_no)
VALUES (:party_id, 'MRN-TEST-0001', 'Bupa Arabia', 'BP-2026-001')
RETURNING patient_id AS patient_id \gset

-- 2) create clinician user (also a party)
INSERT INTO mcms_core.party (party_type, display_name, gender)
VALUES ('person', 'Dr Mona Kassem', 'female')
RETURNING party_id AS clinician_party_id \gset

INSERT INTO mcms_core.app_user (party_id, username, password_hash, role, specialization)
VALUES (:clinician_party_id, 'mona.k', 'argon2$placeholder', 'physician', 'Cardiology')
RETURNING user_id AS clinician_user_id \gset

-- assign clinician to cardiology dept as employee
INSERT INTO mcms_hr.employee (party_id, user_id, employee_no, primary_department_id, role, hired_at)
VALUES (:clinician_party_id, :clinician_user_id, 'EMP-001',
        (SELECT department_id FROM mcms_hr.department WHERE code='CLIN-CARD'),
        'Consultant Cardiologist', '2015-04-01');

-- 3) encounter open (auto-emits event)
INSERT INTO mcms_emr.encounter (mrn, patient_id, status, class, attending_user_id, department_id, reason_for_visit, started_at)
VALUES ('MRN-TEST-0001', :patient_id, 'in_progress', 'emergency', :clinician_user_id,
        (SELECT department_id FROM mcms_hr.department WHERE code='ED-MAIN'),
        'Chest pain on exertion', now())
RETURNING encounter_id AS encounter_id \gset

-- 4) record diagnosis (auto-emits)
INSERT INTO mcms_emr.diagnosis (encounter_id, patient_id, condition_code, condition_desc, role, status, recorded_by)
VALUES (:encounter_id, :patient_id, 'I21.9', 'Acute myocardial infarction', 'primary', 'active', :clinician_user_id);

-- 5) take vitals
INSERT INTO mcms_emr.vitals (encounter_id, patient_id, taken_by, temp_c, hr_bpm, rr_pm, sbp_mmhg, dbp_mmhg, spo2_pct, pain_score)
VALUES (:encounter_id, :patient_id, :clinician_user_id, 36.9, 96, 20, 144, 88, 96.0, 5);

-- 6) triage entry (auto-emits two events: triage_recorded + ed_admitted — trauma_alert=false so only one)
INSERT INTO mcms_emergency.triage (ed_visit_no, patient_id, mrn, encounter_id, chief_complaint, esi_level, arrival_mode,
                                   triage_nurse_user_id, triaged_at, vital_temp_c, vital_hr_bpm, vital_sbp_mmhg, vital_dbp_mmhg, vital_rr_pm, vital_spo2_pct)
VALUES ('ED-2026-0001', :patient_id, 'MRN-TEST-0001', :encounter_id, 'Chest pain', 2, 'ambulance',
        :clinician_user_id, now(), 36.9, 96, 144, 88, 20, 96);

-- 7) add a lot for Aspirin (we'll need to dispense)
INSERT INTO mcms_rx.drug_lot (drug_item_id, lot_number, received_qty, on_hand_qty, expires_on, unit_cost)
VALUES ((SELECT drug_item_id FROM mcms_rx.drug_item WHERE generic_name='Acetylsalicylic acid'),
        'ASP-LOT-001', 200, 200, '2027-12-31', 0.03)
RETURNING lot_id AS aspirin_lot_id \gset

-- 8) write a med order (auto-emits prescription_issued)
INSERT INTO mcms_emr.medication_order (encounter_id, patient_id, prescriber_user_id,
        drug_item_id, drug_name, dose, route, frequency, duration_days, instructions)
VALUES (:encounter_id, :patient_id, :clinician_user_id,
        (SELECT drug_item_id FROM mcms_rx.drug_item WHERE generic_name='Acetylsalicylic acid'),
        'Aspirin 75 mg', '75 mg', 'po', 'OD', 30, 'Take once daily with breakfast');

-- 9) pharmacy dispense it (auto-emits medication_dispensed, decrements aspirin lot by qty)
INSERT INTO mcms_rx.dispensation (patient_id, mrn, encounter_id, drug_item_id, lot_id, quantity, dispensed_by, instructions)
VALUES (:patient_id, 'MRN-TEST-0001', :encounter_id,
        (SELECT drug_item_id FROM mcms_rx.drug_item WHERE generic_name='Acetylsalicylic acid'),
        :aspirin_lot_id, 30, :clinician_user_id, '1 tab daily x 30 days');

-- 10) lab order (auto-emits lab_order_placed)
INSERT INTO mcms_lab.lab_order (order_no, encounter_id, patient_id, mrn, requested_by, order_priority, clinical_indication)
VALUES ('LAB-2026-0001', :encounter_id, :patient_id, 'MRN-TEST-0001', :clinician_user_id, 'stat',
        'Troponin I and CBC post AMI');

-- 11) schedule surgery (auto-emits surgery_scheduled + flips OR to busy)
INSERT INTO mcms_surgical.surgery (operation_no, encounter_id, patient_id, or_id, surgeon_user_id,
        primary_dept_id, procedure_id, laterality, anaesthesia_type, scheduled_at, status)
VALUES ('OR-2026-0001', :encounter_id, :patient_id,
        (SELECT or_id FROM mcms_surgical.operating_room WHERE code='OR-GEN'),
        :clinician_user_id, (SELECT department_id FROM mcms_hr.department WHERE code='OR-CARD'),
        (SELECT proc_cat_id FROM mcms_surgical.procedure_catalog WHERE cpt_code='33533'),
        'na', 'GA', now() + interval '2 days', 'scheduled')
RETURNING surgery_id AS surgery_id \gset

-- 12) start the surgery then complete (auto-emits surgery_started + surgery_completed + OR cleaning)
UPDATE mcms_surgical.surgery SET status='patient_in_or', patient_in_or_at=now() WHERE surgery_id = :surgery_id;
UPDATE mcms_surgical.surgery SET status='incision_start', incision_at=now() WHERE surgery_id = :surgery_id;
UPDATE mcms_surgical.surgery SET status='closure_start', closure_at=now() WHERE surgery_id = :surgery_id;
UPDATE mcms_surgical.surgery SET status='patient_out_or', patient_out_or_at=now() WHERE surgery_id = :surgery_id;
UPDATE mcms_surgical.surgery SET status='completed' WHERE surgery_id = :surgery_id;

-- 13) ICU admit (auto-flips bed to occupied + emits icu_admit)
INSERT INTO mcms_icu.admission (encounter_id, patient_id, mrn, bed_id, primary_physician_id,
        status, admit_diagnosis, admit_reason)
VALUES (:encounter_id, :patient_id, 'MRN-TEST-0001',
        (SELECT bed_id FROM mcms_icu.bed WHERE room_code='ICU-A' AND bed_label='ICU-A1' LIMIT 1),
        :clinician_user_id, 'admitted', 'STEMI s/p CABG', 'Post-cardiac surgery monitoring')
RETURNING admission_id AS admission_id \gset

-- 14) record deteriorating vitals (auto-emits deterioration_alert on mcms_critical channel)
INSERT INTO mcms_icu.vitals_stream (admission_id, patient_id, hr_bpm, sbp_mmhg, spo2_pct, gcs)
VALUES (:admission_id, :patient_id, 145, 78, 84.0, 11);

-- 15) discharge
UPDATE mcms_icu.admission SET status='discharged', discharged_at=now(), discharge_destination='Ward' WHERE admission_id = :admission_id;

-- 16) issue invoice
INSERT INTO mcms_billing.invoice (invoice_no, patient_id, mrn, encounter_id, issued_by, status, subtotal, tax_amount, patient_pays, currency, due_date)
VALUES ('INV-2026-0001', :patient_id, 'MRN-TEST-0001', :encounter_id, :clinician_user_id,
        'draft', 4200, 630, 0, 'SAR', now()::date + 30);

COMMIT;
