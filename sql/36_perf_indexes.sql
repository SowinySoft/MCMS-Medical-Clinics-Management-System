-- ============================================================
-- Integrity/perf cleanup: indexes on hot filter columns
-- ============================================================
-- The auto-router scopes multi-tenant list endpoints with
-- WHERE facility_id = %s (apps/core/base.py get_queryset), and common
-- lookups filter on mrn / drug_item_id / prescriber_user_id. Several of
-- these columns were created WITHOUT an index, forcing a sequential scan
-- on every scoped list call. This adds the missing indexes. Idempotent.
-- ============================================================

CREATE INDEX IF NOT EXISTS ix_claim_response_facility ON mcms_billing.claim_response (facility_id);
CREATE INDEX IF NOT EXISTS ix_eligibility_check_facility ON mcms_billing.eligibility_check (facility_id);
CREATE INDEX IF NOT EXISTS ix_insurance_claim_facility ON mcms_billing.insurance_claim (facility_id);
CREATE INDEX IF NOT EXISTS ix_invoice_mrn ON mcms_billing.invoice (mrn);
CREATE INDEX IF NOT EXISTS ix_invoice_line_facility ON mcms_billing.invoice_line (facility_id);
CREATE INDEX IF NOT EXISTS ix_patient_queue_facility ON mcms_clinic.patient_queue (facility_id);
CREATE INDEX IF NOT EXISTS ix_app_user_facility ON mcms_core.app_user (facility_id);
CREATE INDEX IF NOT EXISTS ix_ed_bed_facility ON mcms_emergency.ed_bed (facility_id);
CREATE INDEX IF NOT EXISTS ix_clinical_note_facility ON mcms_emr.clinical_note (facility_id);
CREATE INDEX IF NOT EXISTS ix_diagnosis_facility ON mcms_emr.diagnosis (facility_id);
CREATE INDEX IF NOT EXISTS ix_medication_order_drug_item ON mcms_emr.medication_order (drug_item_id);
CREATE INDEX IF NOT EXISTS ix_medication_order_facility ON mcms_emr.medication_order (facility_id);
CREATE INDEX IF NOT EXISTS ix_referral_facility ON mcms_emr.referral (facility_id);
CREATE INDEX IF NOT EXISTS ix_vitals_facility ON mcms_emr.vitals (facility_id);
CREATE INDEX IF NOT EXISTS ix_purchase_order_facility ON mcms_erp.purchase_order (facility_id);
CREATE INDEX IF NOT EXISTS ix_purchase_order_line_facility ON mcms_erp.purchase_order_line (facility_id);
CREATE INDEX IF NOT EXISTS ix_admission_facility ON mcms_icu.admission (facility_id);
CREATE INDEX IF NOT EXISTS ix_admission_mrn ON mcms_icu.admission (mrn);
CREATE INDEX IF NOT EXISTS ix_bed_facility ON mcms_icu.bed (facility_id);
CREATE INDEX IF NOT EXISTS ix_bed_stay_facility ON mcms_icu.bed_stay (facility_id);
CREATE INDEX IF NOT EXISTS ix_vitals_stream_facility ON mcms_icu.vitals_stream (facility_id);
CREATE INDEX IF NOT EXISTS ix_lab_order_facility ON mcms_lab.lab_order (facility_id);
CREATE INDEX IF NOT EXISTS ix_lab_order_mrn ON mcms_lab.lab_order (mrn);
CREATE INDEX IF NOT EXISTS ix_sample_facility ON mcms_lab.sample (facility_id);
CREATE INDEX IF NOT EXISTS ix_study_request_mrn ON mcms_rad.study_request (mrn);
CREATE INDEX IF NOT EXISTS ix_prescription_facility ON mcms_rx.prescription (facility_id);
CREATE INDEX IF NOT EXISTS ix_prescription_mrn ON mcms_rx.prescription (mrn);
CREATE INDEX IF NOT EXISTS ix_prescription_prescriber ON mcms_rx.prescription (prescriber_user_id);
CREATE INDEX IF NOT EXISTS ix_intra_op_vitals_facility ON mcms_surgical.intra_op_vitals (facility_id);
CREATE INDEX IF NOT EXISTS ix_post_op_note_facility ON mcms_surgical.post_op_note (facility_id);
CREATE INDEX IF NOT EXISTS ix_visit_facility ON mcms_telemed.visit (facility_id);
CREATE INDEX IF NOT EXISTS ix_visit_mrn ON mcms_telemed.visit (mrn);
CREATE INDEX IF NOT EXISTS ix_concept_facility ON mcms_terminology.concept (facility_id);
