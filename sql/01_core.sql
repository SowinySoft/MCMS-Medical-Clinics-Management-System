-- ============================================================
-- MCMS · 01 · CORE
-- Parties (persons/orgs), users, addresses, enums, reference,
-- and the EVENT ENGINE that drives the whole ERP/event model.
-- ============================================================

BEGIN;

-- ---------- Enums ----------
CREATE TYPE mcms_core.party_type AS ENUM ('person','organization');
CREATE TYPE mcms_core.gender_type AS ENUM ('male','female','other','unknown');
CREATE TYPE mcms_core.blood_type AS ENUM ('a+','a-','b+','b-','ab+','ab-','o+','o-','unknown');
CREATE TYPE mcms_core.user_role AS ENUM (
   'admin','physician','surgeon','nurse','pharmacist','lab_tech','radiologist',
   'physio_therapist','receptionist','billing_clerk','hr_clerk','inventory_clerk','icu_specialist','er_physician','readonly'
);
CREATE TYPE mcms_core.event_kind AS ENUM (
   -- clinical
   'encounter_opened','encounter_closed','diagnosis_recorded','vitals_taken','prescription_issued',
   'appointment_booked','appointment_cancelled','appointment_completed',
   'consultation_completed','note_added','allergy_added','immunization_given',
   -- surgical
   'surgery_scheduled','surgery_started','surgery_completed','surgery_cancelled',
   -- emergency
   'triage_recorded','ed_admitted','ed_discharged','resuscitation_initiated',
   -- pharmacy
   'medication_dispensed','medication_administered','low_stock_alert','purchase_order_raised',
   -- lab
   'lab_order_placed','sample_collected','result_verified','result_rejected',
   -- radiology
   'study_requested','study_completed','report_finalised',
   -- icu
   'icu_admit','icu_discharge','ventilator_started','ventilator_stopped','deterioration_alert',
   -- physio
   'physio_session_completed',
   -- admin / erp
   'invoice_issued','payment_received','insurance_claim_submitted','employee_hired','employee_offboarded',
   -- system
   'login','logout','audit_note'
);
CREATE TYPE mcms_core.event_severity AS ENUM ('info','warning','critical');

-- ---------- Parties ----------
CREATE TABLE mcms_core.party (
   party_id        BIGSERIAL PRIMARY KEY,
   party_type      mcms_core.party_type NOT NULL,
   code            TEXT UNIQUE,
   display_name    TEXT NOT NULL,
   legal_name       TEXT,
   gender          mcms_core.gender_type,
   date_of_birth   DATE,
   blood_type      mcms_core.blood_type DEFAULT 'unknown',
   tax_id          TEXT,
   national_id     TEXT,
   is_active       BOOLEAN NOT NULL DEFAULT TRUE,
   created_at      timestamptz NOT NULL DEFAULT now(),
   updated_at      timestamptz NOT NULL DEFAULT now(),
   CHECK (display_name <> '')
);
CREATE INDEX ON mcms_core.party (party_type);
CREATE INDEX ON mcms_core.party (gender);
CREATE INDEX ON mcms_core.party USING GIN (to_tsvector('simple', display_name));

-- ---------- Addresses ----------
CREATE TABLE mcms_core.address (
   address_id     BIGSERIAL PRIMARY KEY,
   party_id       BIGINT NOT NULL REFERENCES mcms_core.party(party_id) ON DELETE CASCADE,
   label          TEXT NOT NULL,                                 -- home, work, billing
   line1          TEXT, line2 TEXT,
   city           TEXT, region TEXT, postal_code TEXT,
   country        TEXT NOT NULL DEFAULT 'Unknown',
   latitude       DOUBLE PRECISION,
   longitude      DOUBLE PRECISION,
   is_primary     BOOLEAN NOT NULL DEFAULT FALSE,
   created_at     timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_core.address (party_id);

-- ---------- Contact (phone/email, multi-per-party) ----------
CREATE TABLE mcms_core.contact (
   contact_id     BIGSERIAL PRIMARY KEY,
   party_id       BIGINT NOT NULL REFERENCES mcms_core.party(party_id) ON DELETE CASCADE,
   kind           TEXT NOT NULL CHECK (kind IN ('phone','mobile','email','fax','web')),
   value          TEXT NOT NULL,
   is_primary     BOOLEAN NOT NULL DEFAULT FALSE,
   verified_at    timestamptz,
   created_at     timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_core.contact (party_id);
CREATE INDEX ON mcms_core.contact (value);

-- ---------- Users (clinical & admin staff login) ----------
CREATE TABLE mcms_core.app_user (
   user_id         BIGSERIAL PRIMARY KEY,
   party_id        BIGINT NOT NULL REFERENCES mcms_core.party(party_id) ON DELETE CASCADE,
   username        TEXT NOT NULL UNIQUE,
   password_hash   TEXT NOT NULL,                            -- bcrypt/argon2
   role            mcms_core.user_role NOT NULL DEFAULT 'readonly',
   specialization  TEXT,                                    -- cardiology, ortho, anaesthesia...
   is_active       BOOLEAN NOT NULL DEFAULT TRUE,
   last_login_at   timestamptz,
   failed_logins   INT NOT NULL DEFAULT 0,
   locked_until    timestamptz,
   created_at      timestamptz NOT NULL DEFAULT now(),
   updated_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_core.app_user (role);

-- ---------- Reference catalog (generic key-value dimension) ----------
CREATE TABLE mcms_core.lookup (
   lookup_id        BIGSERIAL PRIMARY KEY,
   namespace        TEXT NOT NULL,                          -- icd10_chapter, cpt_code, currency...
   code             TEXT NOT NULL,
   label            TEXT NOT NULL,
   parent_code       TEXT,
   sort_order        INT DEFAULT 0,
   is_active         BOOLEAN NOT NULL DEFAULT TRUE,
   UNIQUE (namespace, code)
);
CREATE INDEX ON mcms_core.lookup (namespace);
CREATE INDEX ON mcms_core.lookup (parent_code);

-- ---------- Event engine ----------
-- Single append-only log; one INSERT = one domain event consumed by LISTEN/NOTIFY.
CREATE TABLE mcms_core.event_log (
   event_id        BIGSERIAL PRIMARY KEY,
   seq             BIGINT NOT NULL,                        -- global monotonic seq (trigger assigned)
   occurred_at     timestamptz NOT NULL DEFAULT now(),
   kind            mcms_core.event_kind NOT NULL,
   severity        mcms_core.event_severity NOT NULL DEFAULT 'info',
   actor_user_id   BIGINT REFERENCES mcms_core.app_user(user_id),
   subject_party_id BIGINT REFERENCES mcms_core.party(party_id),
   source_schema   TEXT,
   source_table    TEXT,
   source_id       BIGINT,                                 -- PK of the row that emitted it
   payload         JSONB NOT NULL DEFAULT '{}'::jsonb,
   channel         TEXT NOT NULL DEFAULT 'mcms',
   CONSTRAINT event_source_pair_chk CHECK (
       (source_schema IS NULL AND source_table IS NULL AND source_id IS NULL)
       OR (source_schema IS NOT NULL AND source_table IS NOT NULL AND source_id IS NOT NULL)
   )
);
CREATE UNIQUE INDEX event_seq_uq ON mcms_core.event_log (seq);
CREATE INDEX ON mcms_core.event_log (kind, occurred_at DESC);
CREATE INDEX ON mcms_core.event_log USING GIN (payload);
CREATE INDEX ON mcms_core.event_log (subject_party_id);
CREATE INDEX ON mcms_core.event_log (actor_user_id);
CREATE INDEX ON mcms_core.event_log (source_schema, source_table, source_id);

-- monotonic sequence injector + NOTIFY fan-out
CREATE OR REPLACE FUNCTION mcms_core.fn_event_insert()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   ch TEXT;
BEGIN
   NEW.seq := nextval('mcms_core.event_log_seq');
   ch := COALESCE(NEW.channel, 'mcms');
   PERFORM pg_notify(ch, json_build_object(
        'event_id', NEW.event_id,
        'seq',       NEW.seq,
        'kind',      NEW.kind::text,
        'subject_party_id', NEW.subject_party_id,
        'source_table', NEW.source_table,
        'source_id', NEW.source_id
   )::text);
   RETURN NEW;
END$$;

CREATE SEQUENCE IF NOT EXISTS mcms_core.event_log_seq;

CREATE TRIGGER trg_event_log_insert
BEFORE INSERT ON mcms_core.event_log
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_event_insert();

-- convenience: any module emits an event by calling this
CREATE OR REPLACE FUNCTION mcms_core.emit_event(
   p_kind            mcms_core.event_kind,
   p_severity        mcms_core.event_severity DEFAULT 'info',
   p_actor_user_id   BIGINT DEFAULT NULL,
   p_subject_party_id BIGINT DEFAULT NULL,
   p_source_schema   TEXT DEFAULT NULL,
   p_source_table    TEXT DEFAULT NULL,
   p_source_id       BIGINT DEFAULT NULL,
   p_payload         JSONB DEFAULT '{}'::jsonb,
   p_channel         TEXT DEFAULT 'mcms'
) RETURNS BIGINT LANGUAGE sql AS $$
   INSERT INTO mcms_core.event_log
     (kind, severity, actor_user_id, subject_party_id, source_schema, source_table, source_id, payload, channel)
   VALUES (p_kind, p_severity, p_actor_user_id, p_subject_party_id, p_source_schema, p_source_table, p_source_id, p_payload, p_channel)
   RETURNING event_id;
$$;

-- audit trail (who/what/when for any table row)
CREATE TABLE mcms_core.audit_trail (
   audit_id        BIGSERIAL PRIMARY KEY,
   table_schema    TEXT NOT NULL,
   table_name      TEXT NOT NULL,
   row_id          BIGINT NOT NULL,
   action          TEXT NOT NULL CHECK (action IN ('insert','update','delete')),
   changed_by      BIGINT REFERENCES mcms_core.app_user(user_id),
   changed_at      timestamptz NOT NULL DEFAULT now(),
   before          JSONB,
   after           JSONB,
   event_id        BIGINT REFERENCES mcms_core.event_log(event_id)
);
CREATE INDEX ON mcms_core.audit_trail (table_schema, table_name, row_id);
CREATE INDEX ON mcms_core.audit_trail (changed_at DESC);

-- updated_at stamp helper for any table
CREATE OR REPLACE FUNCTION mcms_core.fn_touch()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END$$;

COMMIT;
