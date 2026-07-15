-- ============================================================
-- MCMS · 10 · ICU
-- ICU bed boards, vitals streams (minute-resolution), ventilator sessions,
-- scores (APACHE II, GCS), support orders (vasopressors, sedation, RRT).
-- ============================================================

BEGIN;

CREATE TYPE mcms_icu.bed_status AS ENUM ('available','occupied','cleaning','maintenance','reserved');
CREATE TYPE mcms_icu.icu_status AS ENUM ('admitted','active','discharged','transferred','expired');
CREATE TYPE mcms_icu.support_kind AS ENUM ('mechanical_ventilation','non_invasive_ventilation','vasopressor','sedation','rrt','ecmo','hypothermia','prone_position');

-- ---------- ICU Bed Registry ----------
CREATE TABLE mcms_icu.bed (
   bed_id           BIGSERIAL PRIMARY KEY,
   room_code        TEXT NOT NULL,
   bed_label        TEXT NOT NULL,                        -- 'ICU-A1', 'ICU-B4'
   department_id    BIGINT NOT NULL REFERENCES mcms_hr.department(department_id),
   level            INT CHECK (level IN (1,2,3)),         -- ICU level
   status           mcms_icu.bed_status NOT NULL DEFAULT 'available',
   has_ventilator   BOOLEAN NOT NULL DEFAULT FALSE,
   has_dialysis     BOOLEAN NOT NULL DEFAULT FALSE,
   is_isolation    BOOLEAN NOT NULL DEFAULT FALSE,
   UNIQUE (room_code, bed_label),
   created_at       timestamptz NOT NULL DEFAULT now(),
   updated_at       timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_icu.bed (department_id);
CREATE INDEX ON mcms_icu.bed (status);

-- ---------- ICU Admission ----------
CREATE TABLE mcms_icu.admission (
   admission_id        BIGSERIAL PRIMARY KEY,
   encounter_id        BIGINT NOT NULL REFERENCES mcms_emr.encounter(encounter_id),
   patient_id          BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   mrn                 TEXT NOT NULL,
   bed_id              BIGINT REFERENCES mcms_icu.bed(bed_id),
   primary_physician_id BIGINT REFERENCES mcms_core.app_user(user_id),
   attending_nurse_id   BIGINT REFERENCES mcms_core.app_user(user_id),
   status              mcms_icu.icu_status NOT NULL DEFAULT 'admitted',
   admit_diagnosis     TEXT,
   admit_reason        TEXT,
   admitted_at         timestamptz NOT NULL DEFAULT now(),
   discharged_at       timestamptz,
   discharge_destination TEXT,
   expired_at          timestamptz,                  -- patient expired (death) timestamp
   notes               TEXT
);
CREATE INDEX ON mcms_icu.admission (patient_id);
CREATE INDEX ON mcms_icu.admission (encounter_id);
CREATE INDEX ON mcms_icu.admission (status, admitted_at DESC);

-- ---------- Bed Reservation / Snapshot ----------
CREATE TABLE mcms_icu.bed_stay (
   stay_id            BIGSERIAL PRIMARY KEY,
   admission_id        BIGINT NOT NULL REFERENCES mcms_icu.admission(admission_id) ON DELETE CASCADE,
   bed_id              BIGINT NOT NULL REFERENCES mcms_icu.bed(bed_id),
   assigned_at        timestamptz NOT NULL DEFAULT now(),
   released_at        timestamptz
);
CREATE INDEX ON mcms_icu.bed_stay (admission_id);
CREATE INDEX ON mcms_icu.bed_stay (bed_id, assigned_at DESC);

-- ---------- Vitals Stream (high-frequency) ----------
CREATE TABLE mcms_icu.vitals_stream (
   stream_id          BIGSERIAL PRIMARY KEY,
   admission_id        BIGINT NOT NULL REFERENCES mcms_icu.admission(admission_id) ON DELETE CASCADE,
   patient_id         BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   recorded_at        timestamptz NOT NULL DEFAULT now(),
   charted_by         BIGINT REFERENCES mcms_core.app_user(user_id),
   temp_c             NUMERIC(4,1),
   hr_bpm             INT,
   rr_pm              INT,
   sbp_mmhg           INT, dbp_mmhg INT, mbp_mmhg INT,
   spo2_pct           NUMERIC(4,1),
   etco2_mmhg         INT,
   cvp_cmh2o          INT,
   urine_ml_hour      INT,
   gcs                INT CHECK (gcs BETWEEN 3 AND 15),
   pupils             TEXT,                              -- 'L 3mm reactive / R 4mm fixed'
   notes              TEXT
);
CREATE INDEX ON mcms_icu.vitals_stream (admission_id, recorded_at);

-- ---------- Support / Device Sessions ----------
CREATE TABLE mcms_icu.support_session (
   session_id           BIGSERIAL PRIMARY KEY,
   admission_id         BIGINT NOT NULL REFERENCES mcms_icu.admission(admission_id) ON DELETE CASCADE,
   support_kind         mcms_icu.support_kind NOT NULL,
   started_at           timestamptz NOT NULL DEFAULT now(),
   stopped_at           timestamptz,
   parameters           JSONB,                            -- mode, fiO2, peep, drug, dose...
   stopped_reason       TEXT
);
CREATE INDEX ON mcms_icu.support_session (admission_id);

-- ---------- Scores (per assessment) ----------
CREATE TABLE mcms_icu.score (
   score_id           BIGSERIAL PRIMARY KEY,
   admission_id        BIGINT NOT NULL REFERENCES mcms_icu.admission(admission_id) ON DELETE CASCADE,
   type                TEXT NOT NULL,                    -- 'apache_ii','gcs','sofa','rass',...
   raw                 INT,
   computed_value      NUMERIC(5,2),
   interpretation      TEXT,                            -- 'severe ARDS', 'mild distress'...
   assessed_at         timestamptz NOT NULL DEFAULT now(),
   assessed_by         BIGINT REFERENCES mcms_core.app_user(user_id)
);
CREATE INDEX ON mcms_icu.score (admission_id, type, assessed_at DESC);

-- ---------- Pseudo-deterioration rule: emit critical alert if HR > 130 OR SBP < 90 OR SpO2 < 88 ----------
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
CREATE TRIGGER trg_icu_vitals_alert AFTER INSERT ON mcms_icu.vitals_stream
FOR EACH ROW EXECUTE FUNCTION mcms_icu.fn_vitals_alert_event();

-- ---------- ICU admit/discharge events ----------
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
      -- Release any open bed_stay rows for this admission AND flip the admission.bed_id to cleaning.
      UPDATE mcms_icu.bed_stay SET released_at = now() WHERE admission_id = NEW.admission_id AND released_at IS NULL;
      UPDATE mcms_icu.bed
         SET status='cleaning'
       WHERE bed_id IN (SELECT bed_id FROM mcms_icu.bed_stay WHERE admission_id = NEW.admission_id)
          OR bed_id = NEW.bed_id;
   END IF;
   RETURN NEW;
END$$;
CREATE TRIGGER trg_icu_admission_event AFTER INSERT OR UPDATE OF status ON mcms_icu.admission
FOR EACH ROW EXECUTE FUNCTION mcms_icu.fn_admission_event();

-- Ventilator session events
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
CREATE TRIGGER trg_vent_event AFTER INSERT OR UPDATE ON mcms_icu.support_session
FOR EACH ROW EXECUTE FUNCTION mcms_icu.fn_vent_event();

CREATE TRIGGER trg_bed_touch BEFORE UPDATE ON mcms_icu.bed
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();

COMMIT;
