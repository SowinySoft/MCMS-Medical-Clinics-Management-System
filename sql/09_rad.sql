-- ============================================================
-- MCMS · 09 · RADILOGY (mcms_rad)
-- Imaging study catalog, modality scheduling, request, study execution, dictated report.
-- ============================================================

BEGIN;

CREATE TYPE mcms_rad.modality_type AS ENUM (
   'xray','fluoroscopy','ct','mri','us','mammography','pet','nm','dexa','angio','other'
);
CREATE TYPE mcms_rad.study_status AS ENUM (
   'requested','scheduled','patient_arrived','in_progress','completed','reported','verified','cancelled'
);
CREATE TYPE mcms_rad.order_priority AS ENUM ('routine','urgent','stat','asap');

-- ---------- Modality-equipped rooms ----------
CREATE TABLE mcms_rad.modality_suite (
   suite_id           BIGSERIAL PRIMARY KEY,
   department_id      BIGINT NOT NULL REFERENCES mcms_hr.department(department_id),
   code               TEXT NOT NULL UNIQUE,
   name               TEXT NOT NULL,
   modality            mcms_rad.modality_type NOT NULL,
   is_active           BOOLEAN NOT NULL DEFAULT TRUE,
   created_at         timestamptz NOT NULL DEFAULT now(),
   updated_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_rad.modality_suite (modality);

-- ---------- Exam Catalog ----------
CREATE TABLE mcms_rad.exam_catalog (
   exam_id            BIGSERIAL PRIMARY KEY,
   snomed_code        TEXT,
   name               TEXT NOT NULL,
   body_part          TEXT,
   default_modality    mcms_rad.modality_type NOT NULL,
   contrast_used       BOOLEAN NOT NULL DEFAULT FALSE,
   duration_minutes   INT CHECK (duration_minutes > 0),
   created_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_rad.exam_catalog (default_modality);
CREATE INDEX ON mcms_rad.exam_catalog (body_part);

-- ---------- Rad Study (request → study → report) ----------
CREATE TABLE mcms_rad.study_request (
   study_id            BIGSERIAL PRIMARY KEY,
   accession_no        TEXT NOT NULL UNIQUE,
   encounter_id        BIGINT NOT NULL REFERENCES mcms_emr.encounter(encounter_id),
   patient_id          BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   mrn                 TEXT NOT NULL,
   exam_id             BIGINT NOT NULL REFERENCES mcms_rad.exam_catalog(exam_id),
   suite_id             BIGINT REFERENCES mcms_rad.modality_suite(suite_id),
   requested_by         BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   priority             mcms_rad.order_priority NOT NULL DEFAULT 'routine',
   clinical_indication  TEXT,
   status              mcms_rad.study_status NOT NULL DEFAULT 'requested',
   scheduled_at        timestamptz,
   started_at           timestamptz,
   completed_at        timestamptz,
   image_count         INT CHECK (image_count IS NULL OR image_count >= 0),
   radiation_dose_msv    NUMERIC(7,3),        -- millisieverts
   contrast_data       JSONB,                -- includes contrast agent, volume, rate, CT DLP
   findings            TEXT,
   impression           TEXT,
   reported_by          BIGINT REFERENCES mcms_core.app_user(user_id),
   reported_at          timestamptz,
   verified_by         BIGINT REFERENCES mcms_core.app_user(user_id),
   verified_at          timestamptz,
   cancelled_reason    TEXT,
   created_at           timestamptz NOT NULL DEFAULT now(),
   updated_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_rad.study_request (patient_id);
CREATE INDEX ON mcms_rad.study_request (encounter_id);
CREATE INDEX ON mcms_rad.study_request (suite_id, scheduled_at);
CREATE INDEX ON mcms_rad.study_request (status, requested_by);
CREATE INDEX ON mcms_rad.study_request USING GIN (to_tsvector('english', COALESCE(findings,'') || ' ' || COALESCE(impression,'')));

-- ---------- Series/images for each study ----------
CREATE TYPE mcms_rad.image_type AS ENUM ('dicom','png','jpg','webp');

CREATE TABLE mcms_rad.image_instance (
   image_id           BIGSERIAL PRIMARY KEY,
   study_id            BIGINT NOT NULL REFERENCES mcms_rad.study_request(study_id) ON DELETE CASCADE,
   series_number       INT NOT NULL,
   instance_number    INT NOT NULL,
   sop_instance_uid   TEXT,                              -- DICOM UID
   image_type         mcms_rad.image_type NOT NULL DEFAULT 'dicom',
   storage_uri         TEXT NOT NULL,                    -- s3://, file://, visus...
   rows               INT,
   columns            INT,
   bits_allocated     INT,
   created_at         timestamptz NOT NULL DEFAULT now(),
   UNIQUE (study_id, series_number, instance_number)
);
CREATE INDEX ON mcms_rad.image_instance (study_id);

-- ---------- Events ----------
CREATE OR REPLACE FUNCTION mcms_rad.fn_study_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE ev mcms_core.event_kind;
BEGIN
   IF (TG_OP = 'INSERT') THEN ev := 'study_requested';
   ELSIF (TG_OP='UPDATE' AND OLD.status <> NEW.status) THEN
      ev := CASE NEW.status
         WHEN 'completed' THEN 'study_completed'
         WHEN 'verified'  THEN 'report_finalised'
         ELSE NULL END;
   ELSE ev := NULL;
   END IF;
   IF ev IS NOT NULL THEN
      PERFORM mcms_core.emit_event(ev, 'info', NEW.requested_by, NEW.patient_id,
         'mcms_rad','study_request', NEW.study_id,
         jsonb_build_object('accession_no', NEW.accession_no,
                            'status', NEW.status::text,
                            'priority', NEW.priority::text));
   END IF;
   RETURN NEW;
END$$;
CREATE TRIGGER trg_rad_event AFTER INSERT OR UPDATE OF status ON mcms_rad.study_request
FOR EACH ROW EXECUTE FUNCTION mcms_rad.fn_study_event();

CREATE TRIGGER trg_rad_suite_touch BEFORE UPDATE ON mcms_rad.modality_suite
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER trg_rad_study_touch BEFORE UPDATE ON mcms_rad.study_request
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();

COMMIT;
