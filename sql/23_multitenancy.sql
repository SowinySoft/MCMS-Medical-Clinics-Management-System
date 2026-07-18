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

-- 4) Stamp facility_id on every clinical/financial table (backfilled to
--    facility 1) so the app's facility-scoped querysets work uniformly and
--    ORM inserts (which always set facility_id) never fail. Done dynamically
--    over all mcms_* tables so the list can never drift from the models.
DO $$ DECLARE
  t TEXT;
BEGIN
  FOR t IN
    SELECT format('%s.%s', n.nspname, c.relname)
    FROM pg_class c
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname LIKE 'mcms_%'
      AND c.relkind = 'r'
      AND NOT EXISTS (
        SELECT 1 FROM information_schema.columns col
        WHERE col.table_schema = n.nspname
          AND col.table_name   = c.relname
          AND col.column_name  = 'facility_id'
      )
  LOOP
    EXECUTE format('ALTER TABLE %s ADD COLUMN facility_id BIGINT NOT NULL DEFAULT 1', t);
  END LOOP;
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
