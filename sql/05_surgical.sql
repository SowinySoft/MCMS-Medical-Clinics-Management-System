-- ============================================================
-- MCMS · 05 · SURGICAL
-- Operating rooms, surgery scheduling, surgical teams,
-- pre/op/post op notes, intra-op vitals, instrument trays.
-- ============================================================

BEGIN;

-- ---------- Operating Rooms ----------
CREATE TYPE mcms_surgical.or_status AS ENUM ('available','busy','cleaning','maintenance','disabled');

CREATE TABLE mcms_surgical.operating_room (
   or_id               BIGSERIAL PRIMARY KEY,
   department_id       BIGINT NOT NULL REFERENCES mcms_hr.department(department_id),
   code                TEXT NOT NULL UNIQUE,
   name                TEXT NOT NULL,
   room_type           TEXT NOT NULL CHECK (room_type IN ('general','cardiac','ortho','neuro','day_case','hybrid')),
   status              mcms_surgical.or_status NOT NULL DEFAULT 'available',
   is_active           BOOLEAN NOT NULL DEFAULT TRUE,
   created_at          timestamptz NOT NULL DEFAULT now(),
   updated_at          timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_surgical.operating_room (department_id);

-- ---------- Surgical Procedures Catalog ----------
CREATE TABLE mcms_surgical.procedure_catalog (
   proc_cat_id         BIGSERIAL PRIMARY KEY,
   cpt_code            TEXT NOT NULL UNIQUE,                 -- CPT or local code
   name                TEXT NOT NULL,
   body_site           TEXT,
   default_duration_min INT,
   notes               TEXT,
   created_at          timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_surgical.procedure_catalog (name);

-- ---------- Surgeries ----------
CREATE TYPE mcms_surgical.surg_status AS ENUM (
   'scheduled','pre_op','patient_in_or','incision_start','in_progress',
   'closure_start','patient_out_or','recovery','completed','cancelled','on_hold'
);

CREATE TABLE mcms_surgical.surgery (
   surgery_id          BIGSERIAL PRIMARY KEY,
   operation_no        TEXT NOT NULL UNIQUE,
   encounter_id        BIGINT NOT NULL REFERENCES mcms_emr.encounter(encounter_id),
   patient_id          BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   or_id               BIGINT NOT NULL REFERENCES mcms_surgical.operating_room(or_id),
   surgeon_user_id     BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   anaesthetist_user_id BIGINT REFERENCES mcms_core.app_user(user_id),
   primary_dept_id     BIGINT NOT NULL REFERENCES mcms_hr.department(department_id),
   procedure_id         BIGINT NOT NULL REFERENCES mcms_surgical.procedure_catalog(proc_cat_id),
   laterality           TEXT CHECK (laterality IN ('left','right','bilateral','na')),
   status              mcms_surgical.surg_status NOT NULL DEFAULT 'scheduled',
   scheduled_at         timestamptz,
   incision_at          timestamptz,
   closure_at           timestamptz,
   patient_in_or_at     timestamptz,
   patient_out_or_at    timestamptz,
   anaesthesia_type     TEXT,                               -- 'GA','spinal','local','sedation'
   blood_loss_ml        INT CHECK (blood_loss_ml >= 0),
   tourniquet_time_minutes INT CHECK (tourniquet_time_minutes >= 0),
   complications         TEXT,
   notes                 TEXT,
   created_at            timestamptz NOT NULL DEFAULT now(),
   updated_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_surgical.surgery (patient_id);
CREATE INDEX ON mcms_surgical.surgery (surgeon_user_id, scheduled_at);
CREATE INDEX ON mcms_surgical.surgery (or_id, scheduled_at);
CREATE INDEX ON mcms_surgical.surgery (status, scheduled_at);

-- ---------- Surgical Team ----------
CREATE TYPE mcms_surgical.team_role AS ENUM ('surgeon','first_assist','second_assist','scrub_nurse','circulating_nurse','anaesthetist','anaesthesia_tech','perfussionist','runner');

CREATE TABLE mcms_surgical.surgical_team (
   surg_team_id         BIGSERIAL PRIMARY KEY,
   surgery_id           BIGINT NOT NULL REFERENCES mcms_surgical.surgery(surgery_id) ON DELETE CASCADE,
   user_id             BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   role                 mcms_surgical.team_role NOT NULL,
   joined_at            timestamptz,
   left_at              timestamptz,
   UNIQUE (surgery_id, user_id, role)
);
CREATE INDEX ON mcms_surgical.surgical_team (surgery_id);

-- ---------- Pre-op Checklist ----------
CREATE TABLE mcms_surgical.pre_op_checklist (
   poc_id             BIGSERIAL PRIMARY KEY,
   surgery_id         BIGINT NOT NULL REFERENCES mcms_surgical.surgery(surgery_id) ON DELETE CASCADE,
   fasting_confirmed  BOOLEAN DEFAULT FALSE,
   consent_signed     BOOLEAN DEFAULT FALSE,
   site_marked        BOOLEAN DEFAULT FALSE,
   antibiotics_given  BOOLEAN DEFAULT FALSE,
   iv_secured         BOOLEAN DEFAULT FALSE,
   labs_checked       BOOLEAN DEFAULT FALSE,
   imaging_checked    BOOLEAN DEFAULT FALSE,
   risk_score          TEXT,
   checklist_by       BIGINT REFERENCES mcms_core.app_user(user_id),
   completed_at        timestamptz,
   created_at         timestamptz NOT NULL DEFAULT now(),
   UNIQUE (surgery_id)
);

-- ---------- Intra-op Vitals ----------
CREATE TABLE mcms_surgical.intra_op_vitals (
   iov_id             BIGSERIAL PRIMARY KEY,
   surgery_id         BIGINT NOT NULL REFERENCES mcms_surgical.surgery(surgery_id) ON DELETE CASCADE,
   recorded_at        timestamptz NOT NULL DEFAULT now(),
   recorded_by        BIGINT REFERENCES mcms_core.app_user(user_id),
   hr_bpm             INT CHECK (hr_bpm BETWEEN 10 AND 280),
   sbp_mmhg           INT,
   dbp_mmhg           INT,
   spo2_pct           NUMERIC(4,1),
   etco2_mmhg         INT,
   anaesthesia_depth  INT,                                  -- BIS 0-100
   temp_c             NUMERIC(4,1),
   urine_ml            INT,
   notes              TEXT
);
CREATE INDEX ON mcms_surgical.intra_op_vitals (surgery_id, recorded_at);

-- ---------- Post-op Notes ----------
CREATE TABLE mcms_surgical.post_op_note (
   pon_id             BIGSERIAL PRIMARY KEY,
   surgery_id         BIGINT NOT NULL REFERENCES mcms_surgical.surgery(surgery_id) ON DELETE CASCADE,
   written_at         timestamptz NOT NULL DEFAULT now(),
   written_by         BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   recovery_room      TEXT,
   pain_score         INT CHECK (pain_score BETWEEN 0 AND 10),
   findings           TEXT NOT NULL,
   instructions       TEXT,
   follow_up_days     INT,
   is_signed          BOOLEAN DEFAULT FALSE,
   signed_at          timestamptz
);
CREATE INDEX ON mcms_surgical.post_op_note (surgery_id);

-- ---------- Surgery events ----------
CREATE OR REPLACE FUNCTION mcms_surgical.fn_surg_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE ev_kind mcms_core.event_kind;
BEGIN
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
      PERFORM mcms_core.emit_event(ev_kind, 'info', NEW.surgeon_user_id, NEW.patient_id,
         'mcms_surgical','surgery', NEW.surgery_id,
         jsonb_build_object('operation_no', NEW.operation_no, 'or_id', NEW.or_id,
                            'procedure_id', NEW.procedure_id, 'status', NEW.status::text));
   END IF;
   RETURN NEW;
END$$;
CREATE TRIGGER trg_surg_event AFTER INSERT OR UPDATE OF status ON mcms_surgical.surgery
FOR EACH ROW EXECUTE FUNCTION mcms_surgical.fn_surg_event();

-- OR status change when surgery transitions between phases
CREATE OR REPLACE FUNCTION mcms_surgical.fn_or_busy_on_surgery()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
   IF (TG_OP='UPDATE' AND NEW.status IN ('patient_in_or','incision_start','in_progress','closure_start')) THEN
      UPDATE mcms_surgical.operating_room SET status='busy', updated_at=now()
      WHERE or_id = NEW.or_id;
   ELSIF (TG_OP='UPDATE' AND NEW.status IN ('patient_out_or','recovery','completed','cancelled') OR
          (TG_OP='DELETE')) THEN
      UPDATE mcms_surgical.operating_room SET status='cleaning', updated_at=now()
      WHERE or_id = OLD.or_id;
   END IF;
   RETURN COALESCE(NEW, OLD);
END$$;
CREATE TRIGGER trg_or_busy AFTER INSERT OR UPDATE OR DELETE ON mcms_surgical.surgery
FOR EACH ROW EXECUTE FUNCTION mcms_surgical.fn_or_busy_on_surgery();

-- trigger fires statement-level AFTER per transaction only, so cleaner is async via the event channel.

CREATE TRIGGER trg_or_touch BEFORE UPDATE ON mcms_surgical.operating_room
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER trg_surg_touch BEFORE UPDATE ON mcms_surgical.surgery
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();

COMMIT;
