-- ============================================================
-- Phase 17.1 fix: prescription_issued audit event subject is a PARTY id
-- ============================================================
-- fn_med_order_event() was passing NEW.patient_id as the 4th argument to
-- mcms_core.emit_event(), but that argument is p_subject_party_id (a PARTY
-- id). The event_log_subject_party_id_fkey constraint rejected the insert.
-- This is the same systemic class as sql/33_fix_event_subject_party.sql;
-- prescription_issued was added later and slipped through that sweep.
-- Fix: resolve the patient's party_id before emitting the event.
CREATE OR REPLACE FUNCTION mcms_emr.fn_med_order_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event(
      'prescription_issued','info', NEW.prescriber_user_id, v_party,
      'mcms_emr','medication_order', NEW.order_id,
      jsonb_build_object('drug_name', NEW.drug_name, 'dose', NEW.dose,
                         'route', NEW.route::text, 'frequency', NEW.frequency));
   RETURN NEW;
END$$;
