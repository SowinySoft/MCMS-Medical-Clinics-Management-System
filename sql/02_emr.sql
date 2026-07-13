-- ============================================================
-- MCMS · 02 · EMR
-- Electronic medical records — patients (party), encounters,
-- diagnoses (ICD-10), vitals, allergies, immunizations, prescriptions,
-- clinical notes, problem list, family/social history.
-- ============================================================

BEGIN;

-- ---------- Patients (party_role on top of party) ----------
CREATE TABLE mcms_emr.patient (
   patient_id          BIGSERIAL PRIMARY KEY,
   party_id            BIGINT NOT NULL UNIQUE REFERENCES mcms_core.party(party_id) ON DELETE CASCADE,
   mrn                 TEXT NOT NULL UNIQUE,                                -- medical record number
   emergency_contact_name   TEXT,
   emergency_contact_phone  TEXT,
   next_of_kin_party_id     BIGINT REFERENCES mcms_core.party(party_id),
   insurance_provider        TEXT,
   insurance_policy_no       TEXT,
   insurance_group_no       TEXT,
   coverage_verified     BOOLEAN DEFAULT FALSE,
   coverage_verified_at  timestamptz,
   preferred_language    TEXT,
   organ_donor           BOOLEAN DEFAULT FALSE,
   living_will           BOOLEAN DEFAULT FALSE,
   created_at            timestamptz NOT NULL DEFAULT now(),
   updated_at            timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_emr.patient (mrn);
CREATE INDEX ON mcms_emr.patient (insurance_provider);

-- ---------- Encounters ----------
CREATE TYPE mcms_emr.encounter_status AS ENUM ('planned','arrived','in_progress','on_leave','finished','cancelled','no_show');
CREATE TYPE mcms_emr.encounter_class AS ENUM ('ambulatory','emergency','inpatient','home','virtual','surgical','icu');

CREATE TABLE mcms_emr.encounter (
   encounter_id           BIGSERIAL PRIMARY KEY,
   mrn                    TEXT NOT NULL REFERENCES mcms_emr.patient(mrn) ON DELETE CASCADE,
   patient_id             BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   status                 mcms_emr.encounter_status NOT NULL DEFAULT 'planned',
   class                  mcms_emr.encounter_class NOT NULL DEFAULT 'ambulatory',
   attending_user_id      BIGINT REFERENCES mcms_core.app_user(user_id),
   referring_user_id      BIGINT REFERENCES mcms_core.app_user(user_id),
   department_id          BIGINT,                          -- referential → mcms_hr.department (FK added later)
   reason_for_visit       TEXT,
   chief_complaint        TEXT,
   started_at             timestamptz,
   ended_at               timestamptz,
   bed_assign_id          BIGINT,                          -- bed allocation link (inpatient)
   originating_encounter_id BIGINT REFERENCES mcms_emr.encounter(encounter_id),
   created_at             timestamptz NOT NULL DEFAULT now(),
   updated_at             timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_emr.encounter (patient_id);
CREATE INDEX ON mcms_emr.encounter (status, started_at DESC);
CREATE INDEX ON mcms_emr.encounter (attending_user_id);
CREATE INDEX ON mcms_emr.encounter (class, status);

-- encounter status transitions emit events
CREATE OR REPLACE FUNCTION mcms_emr.fn_encounter_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   v_pid BIGINT;
   v_mrn TEXT;
   v_uid BIGINT;
BEGIN
   SELECT p.patient_id, p.mrn INTO v_pid, v_mrn FROM mcms_emr.patient p WHERE p.patient_id = NEW.patient_id;
   SELECT a.party_id INTO v_uid FROM mcms_core.app_user a WHERE a.user_id = NEW.attending_user_id;
   IF (TG_OP = 'INSERT') THEN
      PERFORM mcms_core.emit_event(
         'encounter_opened','info', NEW.attending_user_id, v_pid,
         'mcms_emr','encounter', NEW.encounter_id,
         jsonb_build_object('mrn', v_mrn, 'class', NEW.class::text, 'reason', NEW.reason_for_visit)
      );
   ELSIF (TG_OP = 'UPDATE' AND OLD.status <> NEW.status) THEN
      IF NEW.status = 'finished' THEN
        PERFORM mcms_core.emit_event('encounter_closed','info', NEW.attending_user_id, v_pid,
            'mcms_emr','encounter', NEW.encounter_id,
            jsonb_build_object('mrn', v_mrn, 'class', NEW.class::text));
      END IF;
   END IF;
   RETURN NEW;
END$$;
CREATE TRIGGER trg_encounter_event
AFTER INSERT OR UPDATE ON mcms_emr.encounter
FOR EACH ROW EXECUTE FUNCTION mcms_emr.fn_encounter_event();

-- ---------- Diagnoses (problem list) ----------
CREATE TYPE mcms_emr.diagnosis_role AS ENUM ('admitting','working','differential','primary','secondary');
CREATE TYPE mcms_emr.diagnosis_status AS ENUM ('active','resolved','recurrent','ruled_out','chronic');

CREATE TABLE mcms_emr.diagnosis (
   diagnosis_id        BIGSERIAL PRIMARY KEY,
   encounter_id        BIGINT NOT NULL REFERENCES mcms_emr.encounter(encounter_id) ON DELETE CASCADE,
   patient_id          BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   condition_code      TEXT NOT NULL,                    -- ICD-10 (e.g. E11.9)
   condition_desc      TEXT NOT NULL,
   role                mcms_emr.diagnosis_role NOT NULL DEFAULT 'working',
   status              mcms_emr.diagnosis_status NOT NULL DEFAULT 'active',
   onset_date          DATE,
   resolved_at          timestamptz,
   recorded_by          BIGINT REFERENCES mcms_core.app_user(user_id),
   is_chronic          BOOLEAN DEFAULT FALSE,
   created_at          timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_emr.diagnosis (patient_id);
CREATE INDEX ON mcms_emr.diagnosis (encounter_id);
CREATE INDEX ON mcms_emr.diagnosis (condition_code);

CREATE OR REPLACE FUNCTION mcms_emr.fn_diag_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE v_pid BIGINT;
BEGIN
   SELECT e.patient_id INTO v_pid FROM mcms_emr.encounter e WHERE e.encounter_id = NEW.encounter_id;
   PERFORM mcms_core.emit_event(
      'diagnosis_recorded','info', NEW.recorded_by, v_pid,
      'mcms_emr','diagnosis', NEW.diagnosis_id,
      jsonb_build_object('code', NEW.condition_code,'desc', NEW.condition_desc,
                         'role', NEW.role::text,'status', NEW.status::text));
   RETURN NEW;
END$$;
CREATE TRIGGER trg_diag_event AFTER INSERT ON mcms_emr.diagnosis
FOR EACH ROW EXECUTE FUNCTION mcms_emr.fn_diag_event();

-- ---------- Vitals (per-encounter stream) ----------
CREATE TABLE mcms_emr.vitals (
   vital_id           BIGSERIAL PRIMARY KEY,
   encounter_id       BIGINT NOT NULL REFERENCES mcms_emr.encounter(encounter_id) ON DELETE CASCADE,
   patient_id         BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   taken_at           timestamptz NOT NULL DEFAULT now(),
   taken_by           BIGINT REFERENCES mcms_core.app_user(user_id),
   temp_c             NUMERIC(4,1) CHECK (temp_c > 25 AND temp_c < 50),
   hr_bpm             INT CHECK (hr_bpm BETWEEN 10 AND 280),
   rr_pm              INT CHECK (rr_pm BETWEEN 4 AND 80),
   sbp_mmhg           INT CHECK (sbp_mmhg BETWEEN 30 AND 280),
   dbp_mmhg           INT CHECK (dbp_mmhg BETWEEN 10 AND 200),
   spo2_pct           NUMERIC(4,1) CHECK (spo2_pct BETWEEN 0 AND 100),
   weight_kg          NUMERIC(5,2),
   height_cm          NUMERIC(5,1),
   bmi                NUMERIC(4,1) GENERATED ALWAYS AS (CASE WHEN height_cm > 0 AND weight_kg IS NOT NULL THEN (weight_kg / NULLIF(POWER(height_cm/100.0,2),0))::numeric ELSE NULL END) STORED,
   pain_score         INT CHECK (pain_score BETWEEN 0 AND 10),
   glucose_mgdl       INT,
   CONSTRAINT vitals_bp_chk CHECK (dbp_mmhg IS NULL OR sbp_mmhg IS NULL OR dbp_mmhg <= sbp_mmhg)
);
CREATE INDEX ON mcms_emr.vitals (encounter_id, taken_at);
CREATE INDEX ON mcms_emr.vitals (patient_id, taken_at DESC);

-- ---------- Allergies ----------
CREATE TYPE mcms_emr.allergy_severity AS ENUM ('mild','moderate','severe','fatal','unknown');

CREATE TABLE mcms_emr.allergy (
   allergy_id           BIGSERIAL PRIMARY KEY,
   patient_id           BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   substance            TEXT NOT NULL,
   reaction             TEXT,
   severity             mcms_emr.allergy_severity NOT NULL DEFAULT 'unknown',
   onset_age            TEXT,
   noted_on              timestamptz NOT NULL DEFAULT now(),
   noted_by              BIGINT REFERENCES mcms_core.app_user(user_id),
   is_active            BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE INDEX ON mcms_emr.allergy (patient_id);
CREATE INDEX ON mcms_emr.allergy (substance);

-- ---------- Immunizations ----------
CREATE TABLE mcms_emr.immunization (
   immunization_id    BIGSERIAL PRIMARY KEY,
   patient_id         BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   vaccine_code       TEXT NOT NULL,
   vaccine_name       TEXT NOT NULL,
   dose_number        INT,
   given_at           timestamptz NOT NULL DEFAULT now(),
   given_by           BIGINT REFERENCES mcms_core.app_user(user_id),
   lot_number         TEXT,
   site               TEXT,                           -- left_arm, right_arm, oral
   reaction           TEXT
);
CREATE INDEX ON mcms_emr.immunization (patient_id, given_at DESC);

-- ---------- Clinical Notes ----------
CREATE TYPE mcms_emr.note_type AS ENUM ('progress','history','exam','assessment','plan','nursing','discharge','consult','op_note','ed_note');

CREATE TABLE mcms_emr.clinical_note (
   note_id            BIGSERIAL PRIMARY KEY,
   encounter_id       BIGINT NOT NULL REFERENCES mcms_emr.encounter(encounter_id) ON DELETE CASCADE,
   patient_id         BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   note_type          mcms_emr.note_type NOT NULL,
   title              TEXT,
   body               TEXT NOT NULL,
   author_user_id     BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   coauthor_ids       BIGINT[],
   signed             BOOLEAN NOT NULL DEFAULT FALSE,
   signed_at          timestamptz,
   amended_at         timestamptz,
   created_at         timestamptz NOT NULL DEFAULT now(),
   updated_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_emr.clinical_note (encounter_id, created_at DESC);
CREATE INDEX ON mcms_emr.clinical_note (patient_id);
CREATE INDEX ON mcms_emr.clinical_note USING GIN (to_tsvector('english', body));

-- ---------- Medication Orders (RX hook to pharmacy) ----------
-- Medication order originates here; pharmacist dispenses from mcms_rx.dispensation.
CREATE TYPE mcms_emr.med_order_status AS ENUM ('active','on_hold','cancelled','completed','expired');
CREATE TYPE mcms_emr.med_route AS ENUM ('po','iv','im','sc','inh','top','pr','sl','gt','ng');

CREATE TABLE mcms_emr.medication_order (
   order_id            BIGSERIAL PRIMARY KEY,
   encounter_id        BIGINT REFERENCES mcms_emr.encounter(encounter_id) ON DELETE CASCADE,
   patient_id          BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   prescriber_user_id  BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   drug_item_id        BIGINT,                               -- → mcms_rx.drug_item
   drug_name           TEXT NOT NULL,
   dose                TEXT NOT NULL,                       -- '500 mg'
   route               mcms_emr.med_route NOT NULL,
   frequency           TEXT NOT NULL,                       -- 'BID', 'Q8H'
   duration_days       INT,
   prn                BOOLEAN DEFAULT FALSE,
   refill_count        INT NOT NULL DEFAULT 0,
   instructions        TEXT,
   status              mcms_emr.med_order_status NOT NULL DEFAULT 'active',
   ordered_at          timestamptz NOT NULL DEFAULT now(),
   created_at          timestamptz NOT NULL DEFAULT now(),
   updated_at          timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_emr.medication_order (patient_id);
CREATE INDEX ON mcms_emr.medication_order (encounter_id);
CREATE INDEX ON mcms_emr.medication_order (status);

CREATE OR REPLACE FUNCTION mcms_emr.fn_med_order_event()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
   PERFORM mcms_core.emit_event(
      'prescription_issued','info', NEW.prescriber_user_id, NEW.patient_id,
      'mcms_emr','medication_order', NEW.order_id,
      jsonb_build_object('drug_name', NEW.drug_name, 'dose', NEW.dose,
                         'route', NEW.route::text, 'frequency', NEW.frequency));
   RETURN NEW;
END$$;
CREATE TRIGGER trg_med_order_event AFTER INSERT ON mcms_emr.medication_order
FOR EACH ROW EXECUTE FUNCTION mcms_emr.fn_med_order_event();

-- ---------- Family / Social History ----------
CREATE TABLE mcms_emr.family_history (
   fh_id              BIGSERIAL PRIMARY KEY,
   patient_id         BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   relative           TEXT NOT NULL,                       -- mother, father...
   relationship       TEXT,
   condition_code     TEXT,
   condition_desc     TEXT NOT NULL,
   age_at_onset       INT,
   is_deceased        BOOLEAN DEFAULT FALSE,
   recorded_at        timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_emr.family_history (patient_id);

CREATE TABLE mcms_emr.social_history (
   sh_id              BIGSERIAL PRIMARY KEY,
   patient_id         BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   tobacco_status     TEXT,                       -- never/former/current
   packs_per_day       NUMERIC(4,1),
   years_smoked       INT,
   alcohol_status     TEXT,
   drinks_per_week    INT,
   illicit_drugs      TEXT[],
   occupation        TEXT,
   relationship_status TEXT,
   recorded_at       timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_emr.social_history (patient_id);

-- ---------- Add updated_at auto-tamp trigger to patient ----------
CREATE TRIGGER trg_patient_touch BEFORE UPDATE ON mcms_emr.patient
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER trg_encounter_touch BEFORE UPDATE ON mcms_emr.encounter
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER trg_note_touch BEFORE UPDATE ON mcms_emr.clinical_note
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER trg_med_order_touch BEFORE UPDATE ON mcms_emr.medication_order
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();

COMMIT;
