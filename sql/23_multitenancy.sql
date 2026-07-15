-- ============================================================
-- Phase 6: Multi-tenancy / multi-facility
-- Idempotent: safe to re-apply. Adds an organization -> facility
-- hierarchy and stamps facility_id on every clinical/financial row,
-- backfilled to a seeded "default" facility so existing data is scoped
-- (never orphaned). App users get a facility scope ('*' = cross-facility
-- for sysadmins). Enforcement is at the queryset layer (the DB role is
-- superuser, so PostgreSQL Row-Level Security would be silently bypassed).
-- ============================================================

-- 1) Organization (national / regional parent)
CREATE TABLE IF NOT EXISTS mcms_core.organization (
    organization_id   BIGSERIAL PRIMARY KEY,
    code              TEXT NOT NULL UNIQUE,
    name_en           TEXT NOT NULL,
    name_ar           TEXT,
    parent_org_id     BIGINT REFERENCES mcms_core.organization(organization_id),
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
INSERT INTO mcms_core.organization (organization_id, code, name_en, name_ar)
VALUES (1, 'HQ', 'National HQ', 'المقر الوطني')
ON CONFLICT (organization_id) DO NOTHING;

-- 2) Facility (hospital / clinic)
CREATE TABLE IF NOT EXISTS mcms_core.facility (
    facility_id       BIGSERIAL PRIMARY KEY,
    organization_id   BIGINT NOT NULL REFERENCES mcms_core.organization(organization_id),
    code              TEXT NOT NULL UNIQUE,
    name_en           TEXT NOT NULL,
    name_ar           TEXT,
    parent_facility_id BIGINT REFERENCES mcms_core.facility(facility_id),
    is_active         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
-- default facility every existing row is tagged to
INSERT INTO mcms_core.facility (facility_id, organization_id, code, name_en, name_ar)
VALUES (1, 1, 'DEFAULT', 'Default Facility', 'المنشأة الافتراضية')
ON CONFLICT (facility_id) DO NOTHING;

-- 3) app_user facility scope. NULL/'*' = cross-facility (sysadmin).
ALTER TABLE mcms_core.app_user
    ADD COLUMN IF NOT EXISTS facility_id BIGINT REFERENCES mcms_core.facility(facility_id);

-- 4) Stamp facility_id on clinical/financial tables (backfilled to facility 1).
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='mcms_emr' AND table_name='patient' AND column_name='facility_id'
  ) THEN
    ALTER TABLE mcms_emr.patient       ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_emr.encounter      ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_emr.diagnosis      ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_emr.vitals         ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_emr.clinical_note  ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_emr.referral       ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_emr.medication_order ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_clinic.appointment ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_clinic.patient_queue ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_billing.invoice    ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_billing.invoice_line ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_billing.insurance_claim ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_lab.lab_order      ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_lab.sample         ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_lab.result         ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_icu.admission      ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_icu.bed_stay       ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_icu.bed            ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_icu.vitals_stream  ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_emergency.ed_bed   ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_surgical.intra_op_vitals ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_surgical.post_op_note ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_erp.purchase_order ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    ALTER TABLE mcms_erp.purchase_order_line ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1;
    -- keep a DEFAULT of the seeded default facility (id 1) so both API and
    -- direct ORM inserts are scoped automatically; column stays NOT NULL.
    ALTER TABLE mcms_emr.patient       ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_emr.encounter      ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_emr.diagnosis      ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_emr.vitals         ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_emr.clinical_note  ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_emr.referral       ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_emr.medication_order ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_clinic.appointment ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_clinic.patient_queue ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_billing.invoice    ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_billing.invoice_line ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_billing.insurance_claim ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_lab.lab_order      ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_lab.sample         ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_lab.result         ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_icu.admission      ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_icu.bed_stay       ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_icu.bed            ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_icu.vitals_stream  ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_emergency.ed_bed   ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_surgical.intra_op_vitals ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_surgical.post_op_note ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_erp.purchase_order ALTER COLUMN facility_id SET DEFAULT 1;
    ALTER TABLE mcms_erp.purchase_order_line ALTER COLUMN facility_id SET DEFAULT 1;
  END IF;
END $$;

-- 5) Helpful indexes for the facility scoping clause.
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname='ix_patient_facility') THEN
    CREATE INDEX ix_patient_facility ON mcms_emr.patient(facility_id);
    CREATE INDEX ix_encounter_facility ON mcms_emr.encounter(facility_id);
    CREATE INDEX ix_appointment_facility ON mcms_clinic.appointment(facility_id);
    CREATE INDEX ix_invoice_facility ON mcms_billing.invoice(facility_id);
    CREATE INDEX ix_result_facility ON mcms_lab.result(facility_id);
  END IF;
END $$;

-- 6) Helper: resolve the caller's facility scope from app_user.
--    Returns the facility_id, or NULL meaning "cross-facility / all".
CREATE OR REPLACE FUNCTION mcms_core.fn_user_facility(p_username TEXT)
RETURNS BIGINT AS $$
  SELECT facility_id FROM mcms_core.app_user WHERE username = p_username;
$$ LANGUAGE sql STABLE;
