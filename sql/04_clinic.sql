-- ============================================================
-- MCMS · 04 · CLINIC (outpatient)
-- Appointments, schedule, queue, consultations, clinic rooms.
-- ============================================================

BEGIN;

-- ---------- Clinic Rooms ----------
CREATE TABLE mcms_clinic.room (
   room_id            BIGSERIAL PRIMARY KEY,
   department_id      BIGINT NOT NULL REFERENCES mcms_hr.department(department_id),
   code               TEXT NOT NULL UNIQUE,
   name               TEXT NOT NULL,
   capacity           INT DEFAULT 1,
   equipment          TEXT[],
   is_active          BOOLEAN NOT NULL DEFAULT TRUE,
   created_at         timestamptz NOT NULL DEFAULT now(),
   updated_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_clinic.room (department_id);

-- ---------- Appointment Slots ----------
CREATE TYPE mcms_clinic.slot_status AS ENUM ('open','held','booked','blocked','noshow','completed');

CREATE TABLE mcms_clinic.appointment (
   appointment_id      BIGSERIAL PRIMARY KEY,
   mrn                 TEXT NOT NULL REFERENCES mcms_emr.patient(mrn) ON DELETE CASCADE,
   patient_id         BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   clinician_user_id   BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   room_id             BIGINT REFERENCES mcms_clinic.room(room_id),
   department_id        BIGINT NOT NULL REFERENCES mcms_hr.department(department_id),
   starts_at           timestamptz NOT NULL,
   ends_at             timestamptz NOT NULL CHECK (ends_at > starts_at),
   status              mcms_clinic.slot_status NOT NULL DEFAULT 'booked',
   reason              TEXT,
   booked_by           BIGINT REFERENCES mcms_core.app_user(user_id),
   encounter_id        BIGINT REFERENCES mcms_emr.encounter(encounter_id),
   created_at          timestamptz NOT NULL DEFAULT now(),
   updated_at          timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_clinic.appointment (patient_id);
CREATE INDEX ON mcms_clinic.appointment (clinician_user_id, starts_at);
CREATE INDEX ON mcms_clinic.appointment (department_id, starts_at);
CREATE INDEX ON mcms_clinic.appointment (status);

-- emit appointment events
CREATE OR REPLACE FUNCTION mcms_clinic.fn_appt_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE pid BIGINT;
BEGIN
   SELECT party_id INTO pid FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event(
      CASE WHEN (TG_OP='INSERT') THEN 'appointment_booked'
           WHEN (TG_OP='UPDATE' AND NEW.status='cancelled') THEN 'appointment_cancelled'
           WHEN (TG_OP='UPDATE' AND NEW.status='completed') THEN 'appointment_completed'
           ELSE NULL END,
      'info', NEW.clinician_user_id, pid,
      'mcms_clinic','appointment', NEW.appointment_id,
      jsonb_build_object('starts_at', NEW.starts_at, 'department_id', NEW.department_id,
                         'status', NEW.status::text)
   );
   RETURN NEW;
END$$;
CREATE TRIGGER trg_appt_event AFTER INSERT OR UPDATE OF status ON mcms_clinic.appointment
FOR EACH ROW EXECUTE FUNCTION mcms_clinic.fn_appt_event();

-- ---------- Walk-in Queue ----------
CREATE TYPE mcms_clinic.queue_status AS ENUM ('waiting','called','in_consult','done','diverted');

CREATE TABLE mcms_clinic.patient_queue (
   queue_id            BIGSERIAL PRIMARY KEY,
   patient_id          BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   mrn                 TEXT NOT NULL,
   department_id        BIGINT NOT NULL REFERENCES mcms_hr.department(department_id),
   assigned_clinician   BIGINT REFERENCES mcms_core.app_user(user_id),
   room_id             BIGINT REFERENCES mcms_clinic.room(room_id),
   priority            INT NOT NULL DEFAULT 5 CHECK (priority BETWEEN 0 AND 9),
   status              mcms_clinic.queue_status NOT NULL DEFAULT 'waiting',
   checked_in_at       timestamptz NOT NULL DEFAULT now(),
   called_at           timestamptz,
   started_at          timestamptz,
   finished_at         timestamptz,
   encounter_id        BIGINT REFERENCES mcms_emr.encounter(encounter_id)
);
CREATE INDEX ON mcms_clinic.patient_queue (department_id, status, priority DESC, checked_in_at);
CREATE INDEX ON mcms_clinic.patient_queue (patient_id);

-- ---------- Consultation (one appointment → one consult) ----------
CREATE TYPE mcms_clinic.consult_status AS ENUM ('in_progress','completed','no_show','rescheduled','cancelled');

CREATE TABLE mcms_clinic.consultation (
   consultation_id      BIGSERIAL PRIMARY KEY,
   appointment_id       BIGINT REFERENCES mcms_clinic.appointment(appointment_id) ON DELETE SET NULL,
   queue_id             BIGINT REFERENCES mcms_clinic.patient_queue(queue_id) ON DELETE SET NULL,
   encounter_id         BIGINT NOT NULL REFERENCES mcms_emr.encounter(encounter_id),
   room_id              BIGINT REFERENCES mcms_clinic.room(room_id),
   clinician_user_id    BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   duration_minutes     INT CHECK (duration_minutes >= 0),
   subjective           TEXT,                              -- SOAP subjective (S)
   objective            TEXT,                              -- (O)
   assessment           TEXT,                              -- (A)
   plan                 TEXT,                              -- (P)
   follow_up_days       INT,
   status               mcms_clinic.consult_status NOT NULL DEFAULT 'in_progress',
   started_at           timestamptz NOT NULL DEFAULT now(),
   completed_at         timestamptz,
   created_at           timestamptz NOT NULL DEFAULT now(),
   updated_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_clinic.consultation (clinician_user_id);
CREATE INDEX ON mcms_clinic.consultation (encounter_id);

CREATE OR REPLACE FUNCTION mcms_clinic.fn_consult_event()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
   IF (TG_OP='UPDATE' AND OLD.status <> NEW.status AND NEW.status='completed') THEN
      PERFORM mcms_core.emit_event('consultation_completed','info', NEW.clinician_user_id, NULL,
         'mcms_clinic','consultation', NEW.consultation_id,
         jsonb_build_object('duration_minutes', NEW.duration_minutes, 'encounter_id', NEW.encounter_id));
   END IF;
   RETURN NEW;
END$$;
CREATE TRIGGER trg_consult_event AFTER UPDATE ON mcms_clinic.consultation
FOR EACH ROW EXECUTE FUNCTION mcms_clinic.fn_consult_event();

CREATE TRIGGER trg_room_touch BEFORE UPDATE ON mcms_clinic.room
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER trg_appt_touch BEFORE UPDATE ON mcms_clinic.appointment
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER trg_consult_touch BEFORE UPDATE ON mcms_clinic.consultation
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();

COMMIT;
