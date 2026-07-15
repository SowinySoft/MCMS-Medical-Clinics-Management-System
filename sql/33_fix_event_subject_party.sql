-- ============================================================
-- Phase 16 fix-up: event subject must be a PARTY, not a patient
-- ============================================================
-- Every trigger below emits an event via mcms_core.emit_event(..., p_subject_party_id, ...)
-- whose 4th argument is a FOREIGN KEY to mcms_core.party(party_id). Several triggers were
-- passing the PATIENT id (mcms_emr.patient.patient_id) instead of the patient's party id
-- (mcms_emr.patient.party_id). For party ids 1..N that coincided this went unnoticed, but it
-- is a real referential-integrity / semantic defect: the event is attributed to the wrong
-- subject (and hard-fails once a patient_id does not exist in party).
--
-- Fix: resolve the subject to patient.party_id via a join/subquery. Idempotent
-- (CREATE OR REPLACE). Re-run safe.
-- ============================================================

-- ---------- 02_emr: encounter opened / closed ----------
CREATE OR REPLACE FUNCTION mcms_emr.fn_encounter_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   v_party BIGINT;
   v_mrn TEXT;
   v_uid BIGINT;
BEGIN
   SELECT p.party_id, p.mrn INTO v_party, v_mrn
     FROM mcms_emr.patient p WHERE p.patient_id = NEW.patient_id;
   SELECT a.party_id INTO v_uid FROM mcms_core.app_user a WHERE a.user_id = NEW.attending_user_id;
   IF (TG_OP = 'INSERT') THEN
      PERFORM mcms_core.emit_event(
         'encounter_opened','info', NEW.attending_user_id, v_party,
         'mcms_emr','encounter', NEW.encounter_id,
         jsonb_build_object('mrn', v_mrn, 'class', NEW.class::text, 'reason', NEW.reason_for_visit)
      );
   ELSIF (TG_OP = 'UPDATE' AND OLD.status <> NEW.status) THEN
      IF NEW.status = 'finished' THEN
        PERFORM mcms_core.emit_event('encounter_closed','info', NEW.attending_user_id, v_party,
            'mcms_emr','encounter', NEW.encounter_id,
            jsonb_build_object('mrn', v_mrn, 'class', NEW.class::text));
      END IF;
   END IF;
   RETURN NEW;
END$$;

-- ---------- 06_emergency: triage / resus ----------
CREATE OR REPLACE FUNCTION mcms_emergency.fn_triage_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   IF (TG_OP='INSERT') THEN
      PERFORM mcms_core.emit_event('triage_recorded','info', NEW.triage_nurse_user_id, v_party,
         'mcms_emergency','triage', NEW.triage_id,
         jsonb_build_object('ed_visit_no', NEW.ed_visit_no,'esi_level', NEW.esi_level,
                            'trauma_alert', NEW.trauma_alert));
      IF NEW.trauma_alert THEN
         PERFORM mcms_core.emit_event('ed_admitted','warning', NULL, v_party,
            'mcms_emergency','triage', NEW.triage_id,
            jsonb_build_object('esi_level', NEW.esi_level,'trauma', true));
      END IF;
   ELSIF (TG_OP='UPDATE' AND OLD.status <> NEW.status AND NEW.status='discharged') THEN
      PERFORM mcms_core.emit_event('ed_discharged','info', NULL, v_party,
         'mcms_emergency','triage', NEW.triage_id,
         jsonb_build_object('disposition', NEW.disposition));
   END IF;
   RETURN NEW;
END$$;

CREATE OR REPLACE FUNCTION mcms_emergency.fn_resus_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event('resuscitation_initiated','critical', NEW.team_leader_id, v_party,
      'mcms_emergency','resuscitation', NEW.resus_id,
      jsonb_build_object('code_type', NEW.code_type, 'code_initiated_at', NEW.code_initiated_at));
   RETURN NEW;
END$$;

-- ---------- 07_rx: dispense / administer ----------
CREATE OR REPLACE FUNCTION mcms_rx.fn_dispense_event_and_stock()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   bal INT;
   drugrow mcms_rx.drug_item%ROWTYPE;
   v_party BIGINT;
BEGIN
   IF NEW.lot_id IS NOT NULL THEN
      UPDATE mcms_rx.drug_lot
         SET on_hand_qty = on_hand_qty - NEW.quantity
       WHERE lot_id = NEW.lot_id AND on_hand_qty >= NEW.quantity
       RETURNING on_hand_qty INTO bal;
      IF bal IS NULL THEN
          RAISE EXCEPTION 'Insufficient stock in lot %', NEW.lot_id
            USING ERRCODE = '40001';
      END IF;
      bal := bal;
      INSERT INTO mcms_rx.stock_movement (drug_item_id, lot_id, movement_type, qty_delta, balance_after, performed_by, reason)
      VALUES (NEW.drug_item_id, NEW.lot_id, 'dispense', -NEW.quantity, bal, NEW.dispensed_by,
              'dispense to patient ' || NEW.mrn);
   END IF;

   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event('medication_dispensed','info', NEW.dispensed_by, v_party,
      'mcms_rx','dispensation', NEW.dispensation_id,
      jsonb_build_object('drug_item_id', NEW.drug_item_id, 'qty', NEW.quantity, 'mrn', NEW.mrn));

   SELECT * INTO drugrow FROM mcms_rx.drug_item WHERE drug_item_id = NEW.drug_item_id;
   SELECT COALESCE(SUM(on_hand_qty), 0) INTO bal FROM mcms_rx.drug_lot WHERE drug_item_id = NEW.drug_item_id AND status = 'on_hand';
   IF drugrow.reorder_level > 0 AND bal <= drugrow.reorder_level THEN
       PERFORM mcms_core.emit_event('low_stock_alert','warning', NULL, NULL,
          'mcms_rx','drug_item', NEW.drug_item_id,
          jsonb_build_object('drug', drugrow.generic_name, 'on_hand', bal, 'reorder_level', drugrow.reorder_level),
          p_channel := 'mcms_inventory');
   END IF;
   RETURN NEW;
END$$;

CREATE OR REPLACE FUNCTION mcms_rx.fn_administer_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event('medication_administered','info', NEW.administered_by, v_party,
      'mcms_rx','administration', NEW.administer_id,
      jsonb_build_object('drug_item_id', NEW.drug_item_id, 'dose', NEW.dose_given));
   RETURN NEW;
END$$;

-- ---------- 08_lab: lab order / result ----------
CREATE OR REPLACE FUNCTION mcms_lab.fn_lab_order_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event('lab_order_placed','info', NEW.requested_by, v_party,
      'mcms_lab','lab_order', NEW.order_id,
      jsonb_build_object('order_no', NEW.order_no, 'priority', NEW.order_priority::text, 'panel_id', NEW.panel_id));
   RETURN NEW;
END$$;

CREATE OR REPLACE FUNCTION mcms_lab.fn_result_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   samp mcms_lab.sample%ROWTYPE;
   pid BIGINT;
   v_party BIGINT;
   sev mcms_core.event_severity;
BEGIN
   SELECT * INTO samp FROM mcms_lab.sample WHERE sample_id = NEW.sample_id;
   SELECT patient_id INTO pid FROM mcms_lab.lab_order WHERE order_id = samp.lab_order_id;
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = pid;
   sev := CASE WHEN NEW.flag='critical' THEN 'critical' ELSE 'info' END;
   IF (TG_OP='UPDATE' AND NEW.verified_at IS NOT NULL) THEN
      PERFORM mcms_core.emit_event('result_verified', sev, NEW.verified_by, v_party,
         'mcms_lab','result', NEW.result_id,
         jsonb_build_object('test_id', NEW.test_id, 'flag', NEW.flag::text,
                            'value_text', NEW.value_text, 'value_numeric', NEW.value_numeric,
                            'critical', NEW.flag='critical'),
         p_channel := CASE WHEN NEW.flag='critical' THEN 'mcms_critical' ELSE 'mcms' END);
   END IF;
   RETURN NEW;
END$$;

-- ---------- 10_icu: vitals / admit / discharge / vent ----------
CREATE OR REPLACE FUNCTION mcms_icu.fn_vitals_alert_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   crit BOOLEAN := FALSE;
   pid BIGINT;
   v_party BIGINT;
BEGIN
   crit := (NEW.hr_bpm IS NOT NULL AND NEW.hr_bpm > 130)
        OR (NEW.sbp_mmhg IS NOT NULL AND NEW.sbp_mmhg < 90)
        OR (NEW.spo2_pct IS NOT NULL AND NEW.spo2_pct < 88)
        OR (NEW.gcs   IS NOT NULL AND NEW.gcs   < 8);
   IF crit THEN
      SELECT patient_id INTO pid FROM mcms_icu.admission WHERE admission_id = NEW.admission_id;
      SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = pid;
      PERFORM mcms_core.emit_event('deterioration_alert','critical', NULL, v_party,
         'mcms_icu','vitals_stream', NEW.stream_id,
         jsonb_build_object('hr', NEW.hr_bpm, 'sbp', NEW.sbp_mmhg,
                            'spo2', NEW.spo2_pct, 'gcs', NEW.gcs),
         p_channel := 'mcms_critical');
   END IF;
   RETURN NEW;
END$$;

CREATE OR REPLACE FUNCTION mcms_icu.fn_admission_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   IF (TG_OP='INSERT') THEN
      PERFORM mcms_core.emit_event('icu_admit','warning', NULL, v_party,
         'mcms_icu','admission', NEW.admission_id,
         jsonb_build_object('bed_id', NEW.bed_id, 'reason', NEW.admit_reason));
      IF NEW.bed_id IS NOT NULL THEN
         UPDATE mcms_icu.bed SET status='occupied' WHERE bed_id = NEW.bed_id;
         INSERT INTO mcms_icu.bed_stay (admission_id, bed_id, assigned_at)
         VALUES (NEW.admission_id, NEW.bed_id, now())
         ON CONFLICT DO NOTHING;
      END IF;
   ELSIF (TG_OP='UPDATE' AND OLD.status <> NEW.status AND NEW.status IN ('discharged','transferred','expired')) THEN
      PERFORM mcms_core.emit_event('icu_discharge','info', NULL, v_party,
         'mcms_icu','admission', NEW.admission_id,
         jsonb_build_object('destination', NEW.discharge_destination,'status', NEW.status::text));
      UPDATE mcms_icu.bed_stay SET released_at = now() WHERE admission_id = NEW.admission_id AND released_at IS NULL;
      UPDATE mcms_icu.bed
         SET status='cleaning'
       WHERE bed_id IN (SELECT bed_id FROM mcms_icu.bed_stay WHERE admission_id = NEW.admission_id)
          OR bed_id = NEW.bed_id;
   END IF;
   RETURN NEW;
END$$;

CREATE OR REPLACE FUNCTION mcms_icu.fn_vent_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party
     FROM mcms_emr.patient p
     JOIN mcms_icu.admission a ON a.patient_id = p.patient_id
    WHERE a.admission_id = NEW.admission_id;
   IF (TG_OP='INSERT' AND NEW.support_kind='mechanical_ventilation' AND NEW.stopped_at IS NULL) THEN
      PERFORM mcms_core.emit_event('ventilator_started','warning', NULL, v_party,
         'mcms_icu','support_session', NEW.session_id,
         jsonb_build_object('started_at', NEW.started_at));
   ELSIF (TG_OP='UPDATE' AND OLD.stopped_at IS NULL AND NEW.stopped_at IS NOT NULL AND NEW.support_kind='mechanical_ventilation') THEN
      PERFORM mcms_core.emit_event('ventilator_stopped','info', NULL, v_party,
         'mcms_icu','support_session', NEW.session_id,
         jsonb_build_object('stopped_at', NEW.stopped_at, 'stopped_reason', NEW.stopped_reason));
   END IF;
   RETURN NEW;
END$$;

-- ---------- 11_physio: session completed ----------
CREATE OR REPLACE FUNCTION mcms_physio.fn_session_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   IF (TG_OP='UPDATE' AND OLD.status <> NEW.status AND NEW.status='completed') THEN
      PERFORM mcms_core.emit_event('physio_session_completed','info', NEW.therapist_user_id, v_party,
         'mcms_physio','session', NEW.session_id,
         jsonb_build_object('plan_id', NEW.plan_id, 'therapy_id', NEW.therapy_id,
                            'session_no', NEW.sessions_in_seq));
      UPDATE mcms_physio.treatment_plan
         SET sessions_completed = sessions_completed + 1,
             status = CASE WHEN sessions_completed + 1 >= sessions_planned THEN 'completed'::mcms_physio.plan_status
                           ELSE status END
       WHERE plan_id = NEW.plan_id;
   END IF;
   RETURN NEW;
END$$;

-- ---------- 12_billing: invoice issued ----------
CREATE OR REPLACE FUNCTION mcms_billing.fn_invoice_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   IF (TG_OP='INSERT' AND NEW.status IN ('issued','partial','paid')) THEN
      PERFORM mcms_core.emit_event('invoice_issued','info', NEW.issued_by, v_party,
         'mcms_billing','invoice', NEW.invoice_id,
         jsonb_build_object('invoice_no', NEW.invoice_no, 'total', NEW.total));
   END IF;
   RETURN NEW;
END$$;
