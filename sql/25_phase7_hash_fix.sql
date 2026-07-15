-- ============================================================
-- Phase 7 fix: make the event-chain hash backslash-safe.
-- The original fn_event_insert() hashed `concat(...)::bytea`, but casting
-- TEXT -> BYTEA interprets backslash escapes, so any payload containing a
-- backslash (e.g. HL7 v2's '\&' encoding chars, Windows paths) raised
-- "invalid input syntax for type bytea" and broke the audit chain.
-- convert_to(text, 'UTF8') is the correct, escape-free TEXT->BYTEA path.
-- Idempotent: CREATE OR REPLACE.
-- ============================================================

CREATE OR REPLACE FUNCTION mcms_core.fn_event_insert()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
DECLARE
  ch  TEXT;
  ph  TEXT;
  calc TEXT;
BEGIN
  NEW.seq := nextval('mcms_core.event_log_seq');
  SELECT e.hash INTO ph
    FROM mcms_core.event_log e
   ORDER BY e.seq DESC LIMIT 1;
  NEW.prev_hash := ph;
  calc := encode(sha256(convert_to(concat(
      COALESCE(ph, ''), '|',
      NEW.seq, '|',
      NEW.kind::text, '|',
      COALESCE(NEW.source_schema, ''), '|',
      COALESCE(NEW.source_table, ''), '|',
      COALESCE(NEW.source_id::text, ''), '|',
      NEW.payload::text, '|',
      COALESCE(NEW.actor_user_id::text, ''), '|',
      COALESCE(NEW.subject_party_id::text, '')
    ), 'UTF8')), 'hex');
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
$function$;
