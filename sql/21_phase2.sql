-- 21_phase2.sql : Phase 2 (Survive->Trust bridge: Workflow completeness)
--
-- 1) Referral workflow (mcms_emr.referral + referral_status enum) reusing
--    encounter/diagnosis.
-- 2) Notification engine: triggers on clinical/business events INSERT notification
--    rows (+ pg_notify for the WS channel) — appointment reminders,
--    abnormal/critical lab results, insurance claim status changes.
-- 3) Scheduling hardening: appointment no-show + reminder tracking columns.
-- 4) Lab/Rad auto-route: a verified/abnormal result auto-creates a
--    clinical_note attached to the encounter.
--
-- Idempotent: ALL objects use IF NOT EXISTS / CREATE OR REPLACE /
-- DROP ... IF EXISTS, so re-applying on a DB that already has Phase 2
-- pieces (e.g. the live mcms) is a clean no-op.

-- ---------------------------------------------------------------- 1) referral
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'referral_status') THEN
    CREATE TYPE mcms_emr.referral_status AS ENUM
      ('draft','pending','accepted','declined','completed','cancelled');
  END IF;
END $$;

CREATE TABLE IF NOT EXISTS mcms_emr.referral (
  referral_id     bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  from_encounter_id bigint NOT NULL REFERENCES mcms_emr.encounter(encounter_id),
  to_encounter_id   bigint REFERENCES mcms_emr.encounter(encounter_id),
  from_user_id       bigint NOT NULL REFERENCES mcms_core.app_user(user_id),
  to_user_id         bigint REFERENCES mcms_core.app_user(user_id),
  to_department_id   bigint REFERENCES mcms_hr.department(department_id),
  diagnosis_id       bigint REFERENCES mcms_emr.diagnosis(diagnosis_id),
  reason             text,
  clinical_summary   text,
  urgency           text NOT NULL DEFAULT 'routine',
  status             mcms_emr.referral_status NOT NULL DEFAULT 'draft',
  responded_at       timestamptz,
  created_at         timestamptz NOT NULL DEFAULT now(),
  updated_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_referral_from ON mcms_emr.referral(from_encounter_id);
CREATE INDEX IF NOT EXISTS ix_referral_to_user ON mcms_emr.referral(to_user_id);
CREATE INDEX IF NOT EXISTS ix_referral_status ON mcms_emr.referral(status);

DROP TRIGGER IF EXISTS trg_referral_audit ON mcms_emr.referral;
CREATE TRIGGER trg_referral_audit
  AFTER INSERT OR UPDATE OR DELETE ON mcms_emr.referral
  FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();
DROP TRIGGER IF EXISTS trg_referral_touch ON mcms_emr.referral;
CREATE TRIGGER trg_referral_touch
  BEFORE INSERT OR UPDATE ON mcms_emr.referral
  FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();

-- extend note_type enum to cover auto-routed lab/rad results
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid=e.enumtypid
    WHERE t.typname='note_type' AND e.enumlabel='lab_result'
  ) THEN
    ALTER TYPE mcms_emr.note_type ADD VALUE IF NOT EXISTS 'lab_result';
  END IF;
END $$;

CREATE OR REPLACE FUNCTION mcms_core.fn_make_notification(
  p_category text, p_subject text, p_body text,
  p_recipient_user_id bigint, p_recipient_party_id bigint,
  p_source_schema text, p_source_table text, p_source_id bigint
) RETURNS void LANGUAGE plpgsql AS $f$
BEGIN
  INSERT INTO mcms_core.notification
    (recipient_user_id, recipient_party_id, category, channel, subject, body,
     status, source_schema, source_table, source_id)
  VALUES (p_recipient_user_id, p_recipient_party_id, p_category, 'in_app',
          p_subject, p_body, 'pending', p_source_schema, p_source_table, p_source_id);
  -- WS broadcast is done by trg_notify_after_insert -> fn_notify_broadcast,
  -- so we don't notify here (avoids double delivery).
END;
$f$;

-- WS delivery: every new notification is broadcast on the 'notifications' channel.
CREATE OR REPLACE FUNCTION mcms_core.fn_notify_broadcast() RETURNS trigger
LANGUAGE plpgsql AS $f$
BEGIN
  PERFORM pg_notify('notifications', json_build_object(
    'notification_id', NEW.notification_id, 'category', NEW.category,
    'subject', NEW.subject, 'recipient_user_id', NEW.recipient_user_id,
    'recipient_party_id', NEW.recipient_party_id,
    'source_table', NEW.source_table, 'source_id', NEW.source_id)::text);
  RETURN NEW;
END;
$f$;
DROP TRIGGER IF EXISTS trg_notify_after_insert ON mcms_core.notification;
CREATE TRIGGER trg_notify_after_insert
  AFTER INSERT ON mcms_core.notification
  FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_notify_broadcast();

-- ---------------------------------------------------------------- 2a) appointment reminder
CREATE OR REPLACE FUNCTION mcms_clinic.fn_appointment_reminder() RETURNS trigger LANGUAGE plpgsql AS $f$
DECLARE v_party bigint;
BEGIN
  SELECT p.party_id INTO v_party FROM mcms_emr.patient p WHERE p.patient_id = NEW.patient_id;
  PERFORM mcms_core.fn_make_notification(
    'appointment_reminder',
    'Appointment booked',
    'Appointment on ' || to_char(NEW.starts_at, 'YYYY-MM-DD HH24:MI') || ' (' || NEW.status || ').',
    NEW.clinician_user_id, v_party,
    'mcms_clinic', 'appointment', NEW.appointment_id);
  RETURN NEW;
END;
$f$;
DROP TRIGGER IF EXISTS trg_appointment_reminder ON mcms_clinic.appointment;
CREATE TRIGGER trg_appointment_reminder
  AFTER INSERT ON mcms_clinic.appointment
  FOR EACH ROW EXECUTE FUNCTION mcms_clinic.fn_appointment_reminder();

-- ---------------------------------------------------------------- 2b) lab result -> notify + auto-route
CREATE OR REPLACE FUNCTION mcms_lab.fn_result_critical() RETURNS trigger LANGUAGE plpgsql AS $f$
DECLARE
  v_patient bigint; v_party bigint; v_encounter bigint;
  v_test text; v_cat text;
BEGIN
  IF NEW.flag = 'pending' OR NEW.flag IS NULL THEN RETURN NEW; END IF;
  SELECT lo.patient_id, lo.encounter_id, tc.name
    INTO v_patient, v_encounter, v_test
    FROM mcms_lab.sample s
    JOIN mcms_lab.lab_order lo ON lo.order_id = s.lab_order_id
    JOIN mcms_lab.test_catalog tc ON tc.test_id = NEW.test_id
    WHERE s.sample_id = NEW.sample_id;
  SELECT p.party_id INTO v_party FROM mcms_emr.patient p WHERE p.patient_id = v_patient;

  v_cat := CASE WHEN NEW.flag = 'critical' THEN 'critical_result'
                ELSE 'abnormal_result' END;
  PERFORM mcms_core.fn_make_notification(
    v_cat,
    v_cat || ': ' || v_test,
    'Result for ' || v_test || ' flagged ' || NEW.flag || '.',
    NULL, v_party,
    'mcms_lab', 'result', NEW.result_id);

  -- auto-route: attach a clinical note to the encounter (if any)
  IF v_encounter IS NOT NULL THEN
    INSERT INTO mcms_emr.clinical_note
      (encounter_id, patient_id, note_type, title, body, author_user_id, signed, created_at, updated_at)
    VALUES (v_encounter, v_patient, 'lab_result',
            'Lab result: ' || v_test,
            'Auto-routed from mcms_lab.result #' || NEW.result_id ||
            ' | flag=' || NEW.flag ||
            ' | value=' || COALESCE(NEW.value_text, NEW.value_numeric::text),
            COALESCE(NEW.verified_by, NEW.analysed_by),
            false, now(), now());
  END IF;
  RETURN NEW;
END;
$f$;
DROP TRIGGER IF EXISTS trg_result_critical ON mcms_lab.result;
CREATE TRIGGER trg_result_critical
  AFTER INSERT OR UPDATE OF flag ON mcms_lab.result
  FOR EACH ROW EXECUTE FUNCTION mcms_lab.fn_result_critical();

-- ---------------------------------------------------------------- 2c) insurance claim -> notify
CREATE OR REPLACE FUNCTION mcms_billing.fn_claim_notify() RETURNS trigger LANGUAGE plpgsql AS $f$
DECLARE v_party bigint;
BEGIN
  SELECT p.party_id INTO v_party FROM mcms_emr.patient p WHERE p.patient_id = NEW.patient_id;
  PERFORM mcms_core.fn_make_notification(
    'claim_update',
    'Insurance claim ' || NEW.status,
    'Claim #' || NEW.claim_id || ' for invoice #' || NEW.invoice_id || ' is now ' || NEW.status || '.',
    NULL, v_party,
    'mcms_billing', 'insurance_claim', NEW.claim_id);
  RETURN NEW;
END;
$f$;
DROP TRIGGER IF EXISTS trg_claim_notify ON mcms_billing.insurance_claim;
CREATE TRIGGER trg_claim_notify
  AFTER INSERT OR UPDATE OF status ON mcms_billing.insurance_claim
  FOR EACH ROW EXECUTE FUNCTION mcms_billing.fn_claim_notify();

-- extend event_kind enum to cover no-show appointments
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid=e.enumtypid
    WHERE t.typname='event_kind' AND e.enumlabel='appointment_noshow'
  ) THEN
    ALTER TYPE mcms_core.event_kind ADD VALUE IF NOT EXISTS 'appointment_noshow';
  END IF;
END $$;

-- ---------------------------------------------------------------- fix pre-existing appointment trigger
-- fn_appt_event compared NEW.status='cancelled' where NEW.status is the
-- slot_status enum; PG coerced the literal 'cancelled' to slot_status
-- (which has no such label) and hard-errored on EVERY appointment
-- write. Cast to text so the comparison is type-safe and only matches
-- when a real cancelled-like status exists (slot_status has none, so it's a
-- no-op branch, but it no longer breaks inserts).
CREATE OR REPLACE FUNCTION mcms_clinic.fn_appt_event() RETURNS trigger
LANGUAGE plpgsql AS $f$
DECLARE pid BIGINT;
BEGIN
   SELECT party_id INTO pid FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event(
      CASE WHEN (TG_OP='INSERT') THEN 'appointment_booked'::mcms_core.event_kind
           WHEN (TG_OP='UPDATE' AND NEW.status::text='cancelled') THEN 'appointment_cancelled'::mcms_core.event_kind
           WHEN (TG_OP='UPDATE' AND NEW.status::text='completed') THEN 'appointment_completed'::mcms_core.event_kind
           WHEN (TG_OP='UPDATE' AND NEW.status::text='noshow') THEN 'appointment_noshow'::mcms_core.event_kind
           ELSE NULL END,
      'info', NEW.clinician_user_id, pid,
      'mcms_clinic','appointment', NEW.appointment_id,
      jsonb_build_object('starts_at', NEW.starts_at, 'department_id', NEW.department_id,
                         'status', NEW.status::text)
   );
   RETURN NEW;
END;
$f$;
DROP TRIGGER IF EXISTS trg_appt_event ON mcms_clinic.appointment;
CREATE TRIGGER trg_appt_event
  AFTER INSERT OR UPDATE OF status ON mcms_clinic.appointment
  FOR EACH ROW EXECUTE FUNCTION mcms_clinic.fn_appt_event();

-- ---------------------------------------------------------------- 3) scheduling columns
ALTER TABLE mcms_clinic.appointment
  ADD COLUMN IF NOT EXISTS no_show_at timestamptz;
ALTER TABLE mcms_clinic.appointment
  ADD COLUMN IF NOT EXISTS reminder_sent_at timestamptz;
