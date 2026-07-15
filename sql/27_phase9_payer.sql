-- ============================================================
-- Phase 9: Payer integration (deterministic offline simulator)
-- Adds a payer registry + eligibility check + claim response (EOB)
-- on top of the existing mcms_billing.insurance_claim lifecycle.
-- No live clearinghouse: the payer round-trip is simulated with
-- stable, explainable mock rules so it is CI-testable.
-- Idempotent; safe to re-run.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS mcms_billing;

-- Payer registry. mock_mode=true means the claim round-trip is simulated.
CREATE TABLE IF NOT EXISTS mcms_billing.payer (
    payer_id       bigserial PRIMARY KEY,
    payer_code     text NOT NULL UNIQUE,           -- e.g. 'MOH','NHIF','AXA'
    name           text NOT NULL,
    supports_eligibility boolean NOT NULL DEFAULT true,
    supports_claims    boolean NOT NULL DEFAULT true,
    mock_mode      boolean NOT NULL DEFAULT true,
    is_active      boolean NOT NULL DEFAULT true,
    created_at     timestamptz NOT NULL DEFAULT now()
);

-- Eligibility check (verify active coverage before billing).
CREATE TABLE IF NOT EXISTS mcms_billing.eligibility_check (
    eligibility_id  bigserial PRIMARY KEY,
    patient_id     bigint NOT NULL,
    payer_code     text NOT NULL,
    policy_no      text,
    status         text NOT NULL,                 -- 'verified' | 'denied' | 'pending'
    reason         text,
    raw_response   text,                              -- simulated payer payload
    checked_at     timestamptz NOT NULL DEFAULT now(),
    facility_id    bigint NOT NULL DEFAULT 1,
    UNIQUE (patient_id, payer_code, checked_at)
);
CREATE INDEX IF NOT EXISTS ix_elig_patient ON mcms_billing.eligibility_check (patient_id, payer_code);

-- Claim response / Explanation of Benefits (EOB) for a submitted claim.
CREATE TABLE IF NOT EXISTS mcms_billing.claim_response (
    response_id    bigserial PRIMARY KEY,
    claim_id       bigint NOT NULL REFERENCES mcms_billing.insurance_claim (claim_id)
                                              ON DELETE CASCADE,
    payer_code     text NOT NULL,
    status         text NOT NULL,                 -- 'approved' | 'partial' | 'rejected'
    approved_amount numeric(14,2) NOT NULL DEFAULT 0,
    rejected_amount numeric(14,2) NOT NULL DEFAULT 0,
    remittance     text,                              -- simulated 835-style note
    received_at    timestamptz NOT NULL DEFAULT now(),
    facility_id    bigint NOT NULL DEFAULT 1
);
CREATE INDEX IF NOT EXISTS ix_claim_resp_claim ON mcms_billing.claim_response (claim_id);

-- Seed deterministic mock payers.
INSERT INTO mcms_billing.payer (payer_code, name, supports_eligibility, supports_claims, mock_mode)
VALUES
    ('MOH',  'Ministry of Health',        true,  true,  true),
    ('NHIF', 'National Health Insurance',  true,  true,  true),
    ('AXA',  'AXA Gulf Insurance',     true,  true,  true)
ON CONFLICT (payer_code) DO NOTHING;
