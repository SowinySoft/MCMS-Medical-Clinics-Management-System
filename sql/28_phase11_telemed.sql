-- ============================================================
-- Phase 11: Telemedicine + eRX / formulary
--   * mcms_telemed.visit   - virtual consultation record
--   * mcms_rx.prescription - eRX order with drug-interaction check
-- (Formulary = existing mcms_rx.drug_item; interactions =
--  existing mcms_rx.drug_interaction.)
-- ============================================================

CREATE SCHEMA IF NOT EXISTS mcms_telemed;

-- Virtual visit (teleconsultation). Carries the same SOAP shape as an
-- in-person clinic consultation but is flagged virtual + records the
-- delivery mode. Links to a real encounter for continuity of care.
CREATE TABLE IF NOT EXISTS mcms_telemed.visit (
    visit_id        bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id      bigint NOT NULL,
    mrn             text   NOT NULL,
    clinician_user_id bigint NOT NULL,
    encounter_id    bigint,                      -- continuity link
    appointment_id  bigint,
    mode            text NOT NULL DEFAULT 'video'
                    CHECK (mode IN ('video','phone','chat')),
    status          text NOT NULL DEFAULT 'in_progress'
                    CHECK (status IN ('in_progress','completed','cancelled')),
    subjective      text,
    objective       text,
    assessment      text,
    plan            text,
    started_at      timestamptz NOT NULL DEFAULT now(),
    ended_at        timestamptz,
    facility_id     bigint NOT NULL DEFAULT 1,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_telemed_visit_patient ON mcms_telemed.visit (patient_id);
CREATE INDEX IF NOT EXISTS ix_telemed_visit_encounter ON mcms_telemed.visit (encounter_id);

-- eRX prescription. References the formulary (mcms_rx.drug_item). Status
-- draft -> signed -> dispensed. Drug-interaction warnings are computed at
-- sign time (see apps/telemed) and surfaced, but do not block (severity is
-- reported so the clinician decides).
CREATE TABLE IF NOT EXISTS mcms_rx.prescription (
    prescription_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    encounter_id    bigint,
    visit_id        bigint,                      -- telemed link (nullable)
    patient_id      bigint NOT NULL,
    mrn             text   NOT NULL,
    prescriber_user_id bigint NOT NULL,
    drug_item_id    bigint NOT NULL
                    REFERENCES mcms_rx.drug_item (drug_item_id),
    dose            text,
    route           text,
    frequency       text,
    duration_days   integer,
    quantity        numeric(10,2),
    notes           text,
    status          text NOT NULL DEFAULT 'draft'
                    CHECK (status IN ('draft','signed','dispensed','cancelled')),
    interaction_severity text,                  -- max severity seen at sign
    controlled      boolean DEFAULT false,
    signed_at       timestamptz,
    dispensed_at    timestamptz,
    facility_id     bigint NOT NULL DEFAULT 1,
    created_at      timestamptz NOT NULL DEFAULT now(),
    updated_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_rx_prescription_patient ON mcms_rx.prescription (patient_id);
CREATE INDEX IF NOT EXISTS ix_rx_prescription_drug ON mcms_rx.prescription (drug_item_id);

-- ---- Permission: prescribe (eRX) ----
INSERT INTO mcms_core.permission (code, description)
SELECT 'rx.prescribe', 'Create / sign electronic prescriptions'
WHERE NOT EXISTS (
    SELECT 1 FROM mcms_core.permission WHERE code = 'rx.prescribe'
);

-- Grant rx.prescribe to clinical roles (doctor, nurse, pharmacist).
INSERT INTO mcms_core.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM mcms_core.role r, mcms_core.permission p
WHERE r.code IN ('doctor','nurse','pharmacist')
  AND p.code = 'rx.prescribe'
  AND NOT EXISTS (
    SELECT 1 FROM mcms_core.role_permission rp
    WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
  );
