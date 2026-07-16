-- ============================================================
-- Phase 17 / Step 1+4+6: Vital Records (Birth / Death Certificates)
-- ============================================================
-- Dedicated domain schema for civil-registry-grade vital records.
-- * birth_certificate  - issued on a delivery; may create the newborn patient
-- * death_certificate  - issued on a death; flips patient.is_deceased
-- * Immutability: a certificate is issued (attested) then amend-only
--   (amend creates a NEW row referencing amended_from). Never UPDATE issued.
-- * Cause of death validated against mcms_terminology.concept (icd10).
-- * RBAC seeds: vital_records.{read,register,certify}.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS mcms_vital_records;

-- extend event_kind with the vital-records event (idempotent; psql -f is
-- autocommit so ALTER TYPE ADD VALUE is allowed here)
ALTER TYPE mcms_core.event_kind ADD VALUE IF NOT EXISTS 'patient_deceased';

-- per-facility registration number generators
CREATE SEQUENCE IF NOT EXISTS mcms_vital_records.birth_reg_no_seq
  AS bigint START WITH 1;
CREATE SEQUENCE IF NOT EXISTS mcms_vital_records.death_reg_no_seq
  AS bigint START WITH 1;

-- ----------------------------------------------------------- BIRTH
CREATE TABLE IF NOT EXISTS mcms_vital_records.birth_certificate (
  birth_cert_id      bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  registration_no    text NOT NULL,
  newborn_patient_id  bigint NOT NULL REFERENCES mcms_emr.patient(patient_id),
  mother_patient_id   bigint REFERENCES mcms_emr.patient(patient_id),
  father_party_id     bigint REFERENCES mcms_core.party(party_id),
  delivery_encounter_id bigint REFERENCES mcms_emr.encounter(encounter_id),
  facility_id         bigint NOT NULL REFERENCES mcms_core.facility(facility_id),
  birth_datetime      timestamp with time zone NOT NULL,
  birth_weight_g      numeric(7,1),
  gestation_weeks     numeric(4,1),
  place_of_birth      text,
  attendant_user_id   bigint,
  registrar_user_id   bigint,
  certifier_user_id   bigint,
  status              text NOT NULL DEFAULT 'draft'
                        CHECK (status IN ('draft','issued','amended')),
  signed_at           timestamp with time zone,
  amended_from        bigint REFERENCES mcms_vital_records.birth_certificate(birth_cert_id),
  created_at          timestamp with time zone NOT NULL DEFAULT now(),
  updated_at          timestamp with time zone NOT NULL DEFAULT now(),
  UNIQUE (registration_no, facility_id)
);

-- ----------------------------------------------------------- DEATH
CREATE TABLE IF NOT EXISTS mcms_vital_records.death_certificate (
  death_cert_id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  registration_no     text NOT NULL,
  patient_id          bigint NOT NULL REFERENCES mcms_emr.patient(patient_id),
  facility_id          bigint NOT NULL REFERENCES mcms_core.facility(facility_id),
  death_datetime       timestamp with time zone NOT NULL,
  cause_icd10         text,
  cause_text           text,
  certifying_clinician_user_id bigint,
  coroner_case        boolean NOT NULL DEFAULT false,
  registrar_user_id    bigint,
  status               text NOT NULL DEFAULT 'draft'
                         CHECK (status IN ('draft','issued','amended')),
  signed_at            timestamp with time zone,
  amended_from         bigint REFERENCES mcms_vital_records.death_certificate(death_cert_id),
  created_at           timestamp with time zone NOT NULL DEFAULT now(),
  updated_at           timestamp with time zone NOT NULL DEFAULT now(),
  UNIQUE (registration_no, facility_id)
  -- cause of death is validated in the application layer against
  -- mcms_terminology.concept (code_system='icd10'); the concept.code column
  -- has no unique constraint, so we intentionally do NOT FK it here.
);

-- ----------------------------------------------------------- indexes (hot FK filters)
CREATE INDEX IF NOT EXISTS ix_birth_newborn ON mcms_vital_records.birth_certificate (newborn_patient_id);
CREATE INDEX IF NOT EXISTS ix_birth_mother  ON mcms_vital_records.birth_certificate (mother_patient_id);
CREATE INDEX IF NOT EXISTS ix_birth_facility ON mcms_vital_records.birth_certificate (facility_id);
CREATE INDEX IF NOT EXISTS ix_birth_status  ON mcms_vital_records.birth_certificate (status);
CREATE INDEX IF NOT EXISTS ix_death_patient ON mcms_vital_records.death_certificate (patient_id);
CREATE INDEX IF NOT EXISTS ix_death_facility ON mcms_vital_records.death_certificate (facility_id);
CREATE INDEX IF NOT EXISTS ix_death_status  ON mcms_vital_records.death_certificate (status);
CREATE INDEX IF NOT EXISTS ix_death_cause   ON mcms_vital_records.death_certificate (cause_icd10);

-- ----------------------------------------------------------- Step 4: patient death guard
-- On transition is_deceased false->true, prevent re-activation and emit an
-- event attributed to the patient's PARTY (the fixed emit_event signature).
CREATE OR REPLACE FUNCTION mcms_vital_records.fn_patient_deceased_guard()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.is_deceased IS TRUE AND OLD.is_deceased IS NOT TRUE THEN
    -- immutable: never allow flipping a deceased patient back to alive
    PERFORM mcms_core.emit_event(
      'patient_deceased', 'info', NULL, NEW.party_id,
      'mcms_emr', 'patient', NEW.patient_id, '{}'::jsonb);
  END IF;
  -- reject any attempt to un-decease (defensive; also enforced in app layer)
  IF OLD.is_deceased IS TRUE AND NEW.is_deceased IS NOT TRUE THEN
    RAISE EXCEPTION 'patient % is deceased and cannot be reactivated', OLD.patient_id;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_patient_deceased_guard ON mcms_emr.patient;
CREATE TRIGGER trg_patient_deceased_guard
  BEFORE UPDATE ON mcms_emr.patient
  FOR EACH ROW
  WHEN (OLD.is_deceased IS DISTINCT FROM NEW.is_deceased)
  EXECUTE FUNCTION mcms_vital_records.fn_patient_deceased_guard();

-- ----------------------------------------------------------- Step 6: RBAC seeds
INSERT INTO mcms_core.permission (code, description)
VALUES
  ('vital_records.read',    'View birth/death certificates'),
  ('vital_records.register','Register (issue) birth/death certificates'),
  ('vital_records.certify', 'Certify cause of death / clinical attestation')
ON CONFLICT (code) DO NOTHING;

-- map permissions to existing roles (role codes per mcms_core.role)
INSERT INTO mcms_core.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM mcms_core.role r, mcms_core.permission p
WHERE p.code = 'vital_records.read'
  AND r.code IN ('admin','physician','surgeon','nurse','receptionist',
                 'er_physician','icu_specialist','readonly','patient')
ON CONFLICT DO NOTHING;

INSERT INTO mcms_core.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM mcms_core.role r, mcms_core.permission p
WHERE p.code = 'vital_records.register'
  AND r.code IN ('admin','receptionist')
ON CONFLICT DO NOTHING;

INSERT INTO mcms_core.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM mcms_core.role r, mcms_core.permission p
WHERE p.code = 'vital_records.certify'
  AND r.code IN ('admin','physician','surgeon','er_physician','icu_specialist')
ON CONFLICT DO NOTHING;
