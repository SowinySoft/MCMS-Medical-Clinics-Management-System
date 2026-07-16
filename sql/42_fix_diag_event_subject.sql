-- ============================================================
-- Phase 17.1 fix (part 3): diagnosis event subject = PARTY id
-- ============================================================
-- fn_diag_event() selected e.patient_id (the patient id) from the encounter
-- and passed it as emit_event()'s 4th argument (p_subject_party_id). The
-- event_log_subject_party_id_fkey constraint rejected it -> test_phase1_trust
-- failures (diagnosis creation fires trg_diag_event). Same systemic class as
-- 33/40/41. Resolve the diagnosis row's own patient -> party id.
CREATE OR REPLACE FUNCTION mcms_emr.fn_diag_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_pid BIGINT;
BEGIN
   SELECT p.party_id INTO v_pid
     FROM mcms_emr.patient p WHERE p.patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event(
      'diagnosis_recorded','info', NEW.recorded_by, v_pid,
      'mcms_emr','diagnosis', NEW.diagnosis_id,
      jsonb_build_object('code', NEW.condition_code,'desc', NEW.condition_desc,
                         'role', NEW.role::text,'status', NEW.status::text));
   RETURN NEW;
END$$;
