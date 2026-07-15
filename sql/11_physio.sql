-- ============================================================
-- MCMS · 11 · PHYSIO (Physical Therapy)
-- Therapy catalog, treatment plans, scheduled sessions, exercises.
-- ============================================================

BEGIN;

-- ---------- Therapy Catalog ----------
CREATE TYPE mcms_physio.therapy_type AS ENUM (
   'manual_therapy','electrotherapy','therapeutic_exercise','hydrotherapy',
   'cryotherapy','heat_therapy','ultrasound','traction','laser','taping',
   'rehabilitation','sports_injury','neuro_rehab','post_surgical','ergonomic'
);

CREATE TABLE mcms_physio.therapy_catalog (
   therapy_id           BIGSERIAL PRIMARY KEY,
   code                 TEXT NOT NULL UNIQUE,
   name                  TEXT NOT NULL,
   type                  mcms_physio.therapy_type NOT NULL,
   body_region           TEXT,
   duration_minutes      INT NOT NULL CHECK (duration_minutes > 0),
   equipment            TEXT[],
   is_active            BOOLEAN NOT NULL DEFAULT TRUE,
   created_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_physio.therapy_catalog (type);
CREATE INDEX ON mcms_physio.therapy_catalog (body_region);

-- ---------- Treatment Plan ----------
CREATE TYPE mcms_physio.plan_status AS ENUM ('active','completed','discontinued','on_hold');

CREATE TABLE mcms_physio.treatment_plan (
   plan_id                BIGSERIAL PRIMARY KEY,
   patient_id             BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   encounter_id           BIGINT REFERENCES mcms_emr.encounter(encounter_id),
   therapist_user_id      BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   diagnosis              TEXT,                          -- reason for referral
   treatment_goals        TEXT,
   sessions_planned        INT NOT NULL DEFAULT 1,
   sessions_completed      INT NOT NULL DEFAULT 0,
   frequency              TEXT,                          -- '2x/week'
   starts_on              DATE,
   ends_on                DATE,
   status                 mcms_physio.plan_status NOT NULL DEFAULT 'active',
   notes                  TEXT,
   created_at             timestamptz NOT NULL DEFAULT now(),
   updated_at             timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_physio.treatment_plan (patient_id);
CREATE INDEX ON mcms_physio.treatment_plan (therapist_user_id);

-- ---------- Session ----------
CREATE TYPE mcms_physio.session_status AS ENUM ('scheduled','in_progress','completed','no_show','cancelled');

CREATE TABLE mcms_physio.session (
   session_id             BIGSERIAL PRIMARY KEY,
   plan_id                BIGINT NOT NULL REFERENCES mcms_physio.treatment_plan(plan_id) ON DELETE CASCADE,
   patient_id             BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   therapist_user_id      BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   therapy_id             BIGINT REFERENCES mcms_physio.therapy_catalog(therapy_id),
   room_id                BIGINT REFERENCES mcms_clinic.room(room_id),
   sessions_in_seq        INT,                           -- 1,2,3 .. sessions_planned
   scheduled_at           timestamptz NOT NULL,
   duration_minutes        INT NOT NULL DEFAULT 30,
   pain_before_score      INT CHECK (pain_before_score IS NULL OR pain_before_score BETWEEN 0 AND 10),
   pain_after_score       INT CHECK (pain_after_score  IS NULL OR pain_after_score  BETWEEN 0 AND 10),
   rom_before             TEXT,                          -- 'shoulder flexion 90 degrees'
   rom_after              TEXT,
   subjective             TEXT,
   interventions          TEXT,
   status                 mcms_physio.session_status NOT NULL DEFAULT 'scheduled',
   started_at             timestamptz,
   completed_at           timestamptz,
   notes                  TEXT,
   created_at             timestamptz NOT NULL DEFAULT now(),
   updated_at             timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_physio.session (plan_id);
CREATE INDEX ON mcms_physio.session (therapist_user_id, scheduled_at);
CREATE INDEX ON mcms_physio.session (patient_id, scheduled_at DESC);
CREATE INDEX ON mcms_physio.session (status);

-- ---------- Event ----------
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
CREATE TRIGGER trg_physio_event AFTER UPDATE OF status ON mcms_physio.session
FOR EACH ROW EXECUTE FUNCTION mcms_physio.fn_session_event();

CREATE TRIGGER trg_plan_touch BEFORE UPDATE ON mcms_physio.treatment_plan
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER tgt_session_touch BEFORE UPDATE ON mcms_physio.session
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();

COMMIT;
