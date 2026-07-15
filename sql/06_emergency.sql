-- ============================================================
-- MCMS · 06 · EMERGENCY
-- ED triage, admissions, trauma levels, resuscitation events.
-- ============================================================

BEGIN;

-- ---------- Triage ----------
-- ESI = Emergency Severity Index (1-5: 1=resus, 5=non-urgent)
CREATE TYPE mcms_emergency.triage_status AS ENUM ('awaiting','triaged','in_treatment','admitted','transferred','discharged','ama','died');

CREATE TABLE mcms_emergency.triage (
   triage_id          BIGSERIAL PRIMARY KEY,
   ed_visit_no       TEXT NOT NULL UNIQUE,
   patient_id        BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   mrn               TEXT NOT NULL REFERENCES mcms_emr.patient(mrn) ON DELETE CASCADE,
   encounter_id        BIGINT NOT NULL REFERENCES mcms_emr.encounter(encounter_id),
   presentation_time  timestamptz NOT NULL DEFAULT now(),
   chief_complaint   TEXT NOT NULL,
   esi_level          INT NOT NULL CHECK (esi_level BETWEEN 1 AND 5),
   arrival_mode        TEXT CHECK (arrival_mode IN ('walk_in','ambulance','helicopter','transfer','police')),
   trauma_alert       BOOLEAN NOT NULL DEFAULT FALSE,
   vital_temp_c      NUMERIC(4,1) CHECK (vital_temp_c IS NULL OR vital_temp_c BETWEEN 28 AND 45),
   vital_hr_bpm       INT CHECK (vital_hr_bpm IS NULL OR vital_hr_bpm BETWEEN 10 AND 280),
   vital_sbp_mmhg     INT,
   vital_dbp_mmhg     INT,
   vital_rr_pm        INT,
   vital_spo2_pct     NUMERIC(4,1),
   vital_pain_score   INT CHECK (vital_pain_score IS NULL OR vital_pain_score BETWEEN 0 AND 10),
   vital_gcs          INT CHECK (vital_gcs IS NULL OR vital_gcs BETWEEN 3 AND 15),
   allergies_known    TEXT,
   meds_on_arrival    TEXT[],
   triage_nurse_user_id BIGINT REFERENCES mcms_core.app_user(user_id),
   triaged_at         timestamptz,
   status             mcms_emergency.triage_status NOT NULL DEFAULT 'awaiting',
   disposition        TEXT,
   disposition_destination TEXT,                                 -- 'Ward 4A', 'ICU', 'Mortuary'
   disposition_at     timestamptz,
   created_at         timestamptz NOT NULL DEFAULT now(),
   updated_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_emergency.triage (encounter_id);
CREATE INDEX ON mcms_emergency.triage (esi_level, status, presentation_time DESC);
CREATE INDEX ON mcms_emergency.triage (patient_id);

-- ---------- Resuscitation Events ----------
-- Log every documented code / resus call; lets you reconstruct the timeline.
CREATE TABLE mcms_emergency.resuscitation (
   resus_id          BIGSERIAL PRIMARY KEY,
   triage_id         BIGINT REFERENCES mcms_emergency.triage(triage_id) ON DELETE CASCADE,
   encounter_id      BIGINT NOT NULL REFERENCES mcms_emr.encounter(encounter_id),
   patient_id        BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   code_initiated_at timestamptz NOT NULL DEFAULT now(),
   code_type         TEXT CHECK (code_type IN ('medical','trauma','cardiac','respiratory','paediatric','obstetric')),
   team_leader_id    BIGINT REFERENCES mcms_core.app_user(user_id),
   airway            TEXT,                         -- ET tube / LMA / bag_mask ...
   interventions     TEXT[],
   iv_access         TEXT,
   meds_administered  TEXT[],
   rosc              BOOLEAN DEFAULT FALSE,        -- Return Of Spontaneous Circulation
   rosc_at           timestamptz,
   duration_minutes  INT CHECK (duration_minutes >= 0),
   outcome           TEXT,                        -- 'ROSC','expired','transferred to ICU' ...
   notes             TEXT,
   created_at        timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_emergency.resuscitation (triage_id);
CREATE INDEX ON mcms_emergency.resuscitation (patient_id);

-- ---------- ED Bed / Observation ----------
CREATE TABLE mcms_emergency.ed_bed (
   ed_bed_id         BIGSERIAL PRIMARY KEY,
   triage_id         BIGINT NOT NULL REFERENCES mcms_emergency.triage(triage_id) ON DELETE CASCADE,
   bed_label         TEXT NOT NULL,               -- ED-1, RESUS-1, OBS-A...
   assigned_at       timestamptz NOT NULL DEFAULT now(),
   released_at       timestamptz,
   observation_minutes INT,
   notes             TEXT
);
CREATE INDEX ON mcms_emergency.ed_bed (triage_id);

-- ---------- Events ----------
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
CREATE TRIGGER trg_triage_event AFTER INSERT OR UPDATE OF status ON mcms_emergency.triage
FOR EACH ROW EXECUTE FUNCTION mcms_emergency.fn_triage_event();

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
CREATE TRIGGER trg_resus_event AFTER INSERT ON mcms_emergency.resuscitation
FOR EACH ROW EXECUTE FUNCTION mcms_emergency.fn_resus_event();

CREATE TRIGGER trg_triage_touch BEFORE UPDATE ON mcms_emergency.triage
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();

COMMIT;
