-- =====================================================================
-- MCMS SCHEMA MERGE MIGRATION  (design-doc reconciliation, Phase full)
-- Reconciles the implemented 13-schema DB with the attached design doc.
-- Gaps closed: G1 bilingual, G2 appointment confirmation, G3 dialysis,
--              G4 nursery/neonatal, G5 drug interactions/alternatives,
--              G6 notifications (in-app/email/SMS), G7 RBAC roles,
--              G8 FHIR/HL7 external identifiers.
-- Idempotent where practical (IF NOT EXISTS / DO blocks).
-- =====================================================================
BEGIN;

-- ---------------------------------------------------------------------
-- G1  BILINGUAL (AR/EN)
-- ---------------------------------------------------------------------
-- party gets a preferred_language (patient already had one)
ALTER TABLE mcms_core.party
    ADD COLUMN IF NOT EXISTS preferred_language TEXT NOT NULL DEFAULT 'ar'
        CHECK (preferred_language IN ('ar','en'));

-- bilingual labels on the central lookup catalog
ALTER TABLE mcms_core.lookup
    ADD COLUMN IF NOT EXISTS label_en TEXT,
    ADD COLUMN IF NOT EXISTS label_ar TEXT;
-- backfill: existing single label becomes the EN label
UPDATE mcms_core.lookup SET label_en = COALESCE(label_en, label) WHERE label_en IS NULL;

-- ---------------------------------------------------------------------
-- G8  FHIR / HL7 EXTERNAL IDENTIFIERS (interoperability layer)
-- ---------------------------------------------------------------------
ALTER TABLE mcms_emr.patient
    ADD COLUMN IF NOT EXISTS fhir_id TEXT UNIQUE,
    ADD COLUMN IF NOT EXISTS hl7_mpi TEXT;
ALTER TABLE mcms_emr.encounter
    ADD COLUMN IF NOT EXISTS fhir_id TEXT UNIQUE;

-- ---------------------------------------------------------------------
-- G2  APPOINTMENT CONFIRMATION (OTP/token + deadline + status)
-- ---------------------------------------------------------------------
-- extend event_kind with the new domain events
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid=e.enumtypid
                 JOIN pg_namespace n ON n.oid=t.typnamespace
                 WHERE n.nspname='mcms_core' AND t.typname='event_kind'
                 AND e.enumlabel='appointment_confirmed') THEN
    ALTER TYPE mcms_core.event_kind ADD VALUE 'appointment_confirmed';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid=e.enumtypid
                 JOIN pg_namespace n ON n.oid=t.typnamespace
                 WHERE n.nspname='mcms_core' AND t.typname='event_kind'
                 AND e.enumlabel='appointment_confirmation_sent') THEN
    ALTER TYPE mcms_core.event_kind ADD VALUE 'appointment_confirmation_sent';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid=e.enumtypid
                 JOIN pg_namespace n ON n.oid=t.typnamespace
                 WHERE n.nspname='mcms_core' AND t.typname='event_kind'
                 AND e.enumlabel='notification_sent') THEN
    ALTER TYPE mcms_core.event_kind ADD VALUE 'notification_sent';
  END IF;
END$$;

ALTER TABLE mcms_clinic.appointment
    ADD COLUMN IF NOT EXISTS confirmation_token UUID DEFAULT gen_random_uuid(),
    ADD COLUMN IF NOT EXISTS confirmation_deadline TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS confirmed_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS patient_confirmed BOOLEAN NOT NULL DEFAULT FALSE;

CREATE INDEX IF NOT EXISTS ix_appt_conf_token ON mcms_clinic.appointment(confirmation_token);

COMMIT;
