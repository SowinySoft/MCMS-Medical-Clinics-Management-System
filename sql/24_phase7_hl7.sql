-- ============================================================
-- Phase 7: HL7 v2 ingestion audit + idempotency log
-- Idempotent. Stores every ingested HL7 v2 message keyed on its
-- MSH-10 Message Control ID so re-delivery is a no-op (AA ack, no
-- duplicate side effects). Facility-scoped (Phase 6).
-- ============================================================

CREATE TABLE IF NOT EXISTS mcms_core.hl7_message (
    hl7_message_id     BIGSERIAL PRIMARY KEY,
    message_control_id TEXT NOT NULL UNIQUE,   -- MSH-10 (idempotency key)
    message_type       TEXT NOT NULL,          -- MSH-9, e.g. 'ADT^A01'
    sending_app        TEXT,                    -- MSH-3
    sending_facility   TEXT,                    -- MSH-4
    raw                TEXT NOT NULL,           -- original message
    ack_code           TEXT NOT NULL DEFAULT 'AA',  -- AA=accept, AE=error, AR=reject
    error_detail       TEXT,
    actions            JSONB NOT NULL DEFAULT '{}'::jsonb,  -- summary of side effects
    facility_id        BIGINT NOT NULL DEFAULT 1
                       REFERENCES mcms_core.facility(facility_id),
    received_by        BIGINT REFERENCES mcms_core.app_user(user_id),
    received_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS ix_hl7_message_type ON mcms_core.hl7_message(message_type);
CREATE INDEX IF NOT EXISTS ix_hl7_message_facility ON mcms_core.hl7_message(facility_id);
CREATE INDEX IF NOT EXISTS ix_hl7_message_received ON mcms_core.hl7_message(received_at);
