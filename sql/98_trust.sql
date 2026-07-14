-- 98_trust.sql : Phase 1 (Trust) — safety & compliance schema
--
-- 1) Immutable hash-chained event_log (tamper-evident audit trail)
-- 2) Consent management (mcms_core.consent)
-- 3) Per-record read-access log (mcms_core.access_log) for sensitive tables
-- 4) Attestation / e-sign columns on diagnosis + medication_order + clinical_note
--
-- Applied by scripts/rebuild_test_db.sh (from-sql) and scripts/setup_db.sh.

-- ---------------------------------------------------------------- 1) hash chain
ALTER TABLE mcms_core.event_log ADD COLUMN IF NOT EXISTS prev_hash text;
ALTER TABLE mcms_core.event_log ADD COLUMN IF NOT EXISTS hash text;

DROP FUNCTION IF EXISTS mcms_core.fn_event_insert() CASCADE;
CREATE FUNCTION mcms_core.fn_event_insert() RETURNS trigger
LANGUAGE plpgsql AS $f$
DECLARE
  ch  TEXT;
  ph  TEXT;
  calc TEXT;
BEGIN
  NEW.seq := nextval('mcms_core.event_log_seq');
  -- previous chain head (highest seq so far)
  SELECT e.hash INTO ph
    FROM mcms_core.event_log e
   ORDER BY e.seq DESC LIMIT 1;
  NEW.prev_hash := ph;
  calc := encode(sha256(concat(
      COALESCE(ph, ''), '|',
      NEW.seq, '|',
      NEW.kind::text, '|',
      COALESCE(NEW.source_schema, ''), '|',
      COALESCE(NEW.source_table, ''), '|',
      COALESCE(NEW.source_id::text, ''), '|',
      NEW.payload::text, '|',
      COALESCE(NEW.actor_user_id::text, ''), '|',
      COALESCE(NEW.subject_party_id::text, '')
    )::bytea), 'hex');
  NEW.hash := calc;
  ch := COALESCE(NEW.channel, 'mcms');
  PERFORM pg_notify(ch, json_build_object(
      'event_id', NEW.event_id, 'seq', NEW.seq, 'kind', NEW.kind::text,
      'subject_party_id', NEW.subject_party_id,
      'source_table', NEW.source_table, 'source_id', NEW.source_id,
      'hash', NEW.hash
   )::text);
  RETURN NEW;
END;
$f$;

CREATE TRIGGER trg_event_log_insert BEFORE INSERT ON mcms_core.event_log
  FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_event_insert();

-- Backfill the existing chain so verification passes on legacy rows.
DO $$
DECLARE
  r RECORD;
  prev TEXT := NULL;
  calc TEXT;
BEGIN
  FOR r IN SELECT event_id, seq, kind, source_schema, source_table, source_id,
                  payload, actor_user_id, subject_party_id, hash
             FROM mcms_core.event_log ORDER BY seq LOOP
    calc := encode(sha256(concat(
        COALESCE(prev, ''), '|',
        r.seq, '|', r.kind::text, '|',
        COALESCE(r.source_schema, ''), '|',
        COALESCE(r.source_table, ''), '|',
        COALESCE(r.source_id::text, ''), '|',
        r.payload::text, '|',
        COALESCE(r.actor_user_id::text, ''), '|',
        COALESCE(r.subject_party_id::text, '')
      )::bytea), 'hex');
    UPDATE mcms_core.event_log
       SET prev_hash = prev, hash = calc
     WHERE event_id = r.event_id;
    prev := calc;
  END LOOP;
END $$;

-- Verification: returns the first seq where the stored hash is wrong (NULL = ok)
CREATE OR REPLACE FUNCTION mcms_core.verify_event_chain()
RETURNS TABLE(broken_at bigint) AS $f$
DECLARE
  r RECORD;
  prev TEXT := NULL;
  calc TEXT;
BEGIN
  FOR r IN SELECT event_id, seq, kind, source_schema, source_table, source_id,
                  payload, actor_user_id, subject_party_id, prev_hash, hash
             FROM mcms_core.event_log ORDER BY seq LOOP
    calc := encode(sha256(concat(
        COALESCE(prev, ''), '|',
        r.seq, '|', r.kind::text, '|',
        COALESCE(r.source_schema, ''), '|',
        COALESCE(r.source_table, ''), '|',
        COALESCE(r.source_id::text, ''), '|',
        r.payload::text, '|',
        COALESCE(r.actor_user_id::text, ''), '|',
        COALESCE(r.subject_party_id::text, '')
      )::bytea), 'hex');
    IF calc <> r.hash OR prev IS DISTINCT FROM r.prev_hash THEN
      broken_at := r.seq; RETURN NEXT;
    END IF;
    prev := r.hash;
  END LOOP;
END;
$f$ LANGUAGE plpgsql;

-- ---------------------------------------------------------------- 2) consent
DO $$ BEGIN
  CREATE TYPE mcms_core.consent_type AS ENUM
    ('data_sharing','contact_sms','contact_email','research','psycho_disclosure');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS mcms_core.consent (
  consent_id   bigserial PRIMARY KEY,
  party_id     bigint NOT NULL REFERENCES mcms_core.party(party_id) ON DELETE CASCADE,
  consent_type mcms_core.consent_type NOT NULL,
  granted      boolean NOT NULL DEFAULT false,
  granted_at   timestamptz,
  revoked_at   timestamptz,
  granted_by   bigint REFERENCES mcms_core.app_user(user_id),
  note         text,
  UNIQUE (party_id, consent_type)
);
CREATE INDEX IF NOT EXISTS ix_consent_party ON mcms_core.consent(party_id);

-- ---------------------------------------------------------------- 3) access log
CREATE TABLE IF NOT EXISTS mcms_core.access_log (
  access_id       bigserial PRIMARY KEY,
  reader_user_id  bigint REFERENCES mcms_core.app_user(user_id),
  subject_party_id bigint REFERENCES mcms_core.party(party_id),
  table_schema    text NOT NULL,
  table_name      text NOT NULL,
  row_id          bigint NOT NULL,
  read_at         timestamptz NOT NULL DEFAULT now(),
  reason          text
);
CREATE INDEX IF NOT EXISTS ix_access_log_party ON mcms_core.access_log(subject_party_id, read_at DESC);
CREATE INDEX IF NOT EXISTS ix_access_log_table ON mcms_core.access_log(table_schema, table_name, row_id);

-- ---------------------------------------------------------------- 4) attestation
ALTER TABLE mcms_emr.diagnosis
  ADD COLUMN IF NOT EXISTS signed boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS signed_at timestamptz,
  ADD COLUMN IF NOT EXISTS signed_by bigint REFERENCES mcms_core.app_user(user_id);

ALTER TABLE mcms_emr.medication_order
  ADD COLUMN IF NOT EXISTS signed boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS signed_at timestamptz,
  ADD COLUMN IF NOT EXISTS signed_by bigint REFERENCES mcms_core.app_user(user_id);

ALTER TABLE mcms_emr.clinical_note
  ADD COLUMN IF NOT EXISTS signed_by bigint REFERENCES mcms_core.app_user(user_id);
