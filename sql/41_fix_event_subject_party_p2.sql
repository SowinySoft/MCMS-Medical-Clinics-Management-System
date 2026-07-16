-- ============================================================
-- Phase 17.1 fix (part 2): surgery + radiology audit subjects are PARTY ids
-- ============================================================
-- Same systemic class as sql/33 / sql/40: emit_event()'s 4th argument is
-- p_subject_party_id (a PARTY id), but fn_surg_event() and fn_study_event()
-- passed NEW.patient_id. event_log_subject_party_id_fkey rejected it.
-- Resolve the patient's party_id inside each trigger before emitting.

CREATE OR REPLACE FUNCTION mcms_surgical.fn_surg_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE ev_kind mcms_core.event_kind; v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   IF TG_OP='INSERT' THEN
      ev_kind := 'surgery_scheduled';
   ELSIF TG_OP='UPDATE' AND OLD.status <> NEW.status THEN
      ev_kind := CASE NEW.status
         WHEN 'incision_start' THEN 'surgery_started'
         WHEN 'completed'       THEN 'surgery_completed'
         WHEN 'cancelled'       THEN 'surgery_cancelled'
         ELSE NULL END;
   END IF;
   IF ev_kind IS NOT NULL THEN
      PERFORM mcms_core.emit_event(ev_kind, 'info', NEW.surgeon_user_id, v_party,
         'mcms_surgical','surgery', NEW.surgery_id,
         jsonb_build_object('operation_no', NEW.operation_no, 'or_id', NEW.or_id,
                            'procedure_id', NEW.procedure_id, 'status', NEW.status::text));
   END IF;
   RETURN NEW;
END$$;

CREATE OR REPLACE FUNCTION mcms_rad.fn_study_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE ev mcms_core.event_kind; v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   IF (TG_OP = 'INSERT') THEN ev := 'study_requested';
   ELSIF (TG_OP='UPDATE' AND OLD.status <> NEW.status) THEN
      ev := CASE NEW.status
         WHEN 'completed' THEN 'study_completed'
         WHEN 'verified'  THEN 'report_finalised'
         ELSE NULL END;
   ELSE ev := NULL;
   END IF;
   IF ev IS NOT NULL THEN
      PERFORM mcms_core.emit_event(ev, 'info', NEW.requested_by, v_party,
         'mcms_rad','study_request', NEW.study_id,
         jsonb_build_object('accession_no', NEW.accession_no,
                            'status', NEW.status::text,
                            'priority', NEW.priority::text));
   END IF;
   RETURN NEW;
END$$;
