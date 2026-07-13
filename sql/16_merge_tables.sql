-- =====================================================================
-- MCMS MERGE MIGRATION  PART 2 : new departments & cross-cutting tables
-- G3 dialysis · G4 nursery/neonatal · G5 drug interactions/alternatives
-- G6 notifications · G7 RBAC role catalog + permission matrix
-- =====================================================================
BEGIN;

-- ---------------------------------------------------------------------
-- G3  DIALYSIS UNIT
-- ---------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS mcms_dialysis;

DO $$ BEGIN
  CREATE TYPE mcms_dialysis.dialysis_status AS ENUM
    ('scheduled','in_progress','completed','aborted','no_show','cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE mcms_dialysis.modality AS ENUM
    ('hemodialysis','peritoneal','hemofiltration','hemodiafiltration','crrt');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS mcms_dialysis.station (
    station_id      BIGSERIAL PRIMARY KEY,
    code            TEXT NOT NULL UNIQUE,
    name            TEXT NOT NULL,
    department_id   BIGINT REFERENCES mcms_hr.department(department_id),
    has_ro_water    BOOLEAN NOT NULL DEFAULT TRUE,
    status          mcms_icu.bed_status NOT NULL DEFAULT 'available',
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS mcms_dialysis.session (
    session_id        BIGSERIAL PRIMARY KEY,
    patient_id        BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id),
    encounter_id      BIGINT REFERENCES mcms_emr.encounter(encounter_id),
    station_id        BIGINT REFERENCES mcms_dialysis.station(station_id),
    nurse_user_id     BIGINT REFERENCES mcms_core.app_user(user_id),
    nephrologist_user_id BIGINT REFERENCES mcms_core.app_user(user_id),
    modality          mcms_dialysis.modality NOT NULL DEFAULT 'hemodialysis',
    scheduled_at      TIMESTAMPTZ NOT NULL,
    started_at        TIMESTAMPTZ,
    ended_at          TIMESTAMPTZ,
    duration_minutes  INT,
    -- pre-session criteria
    pre_weight_kg     NUMERIC(6,2),
    pre_bp            TEXT,
    dry_weight_kg     NUMERIC(6,2),
    -- post-session criteria
    post_weight_kg    NUMERIC(6,2),
    post_bp           TEXT,
    fluid_removed_ml  INT,
    blood_flow_rate   INT,
    dialysate_flow    INT,
    heparin_units     INT,
    kt_v              NUMERIC(4,2),          -- dialysis adequacy
    complications     TEXT,
    status            mcms_dialysis.dialysis_status NOT NULL DEFAULT 'scheduled',
    notes             TEXT,
    created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_dial_sess_patient ON mcms_dialysis.session(patient_id);
CREATE INDEX IF NOT EXISTS ix_dial_sess_sched   ON mcms_dialysis.session(scheduled_at);

-- ---------------------------------------------------------------------
-- G4  NURSERY / NEONATAL UNIT
-- ---------------------------------------------------------------------
CREATE SCHEMA IF NOT EXISTS mcms_nursery;

DO $$ BEGIN
  CREATE TYPE mcms_nursery.cot_status AS ENUM
    ('available','occupied','cleaning','maintenance');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS mcms_nursery.cot (
    cot_id        BIGSERIAL PRIMARY KEY,
    code          TEXT NOT NULL UNIQUE,
    name          TEXT NOT NULL,
    department_id BIGINT REFERENCES mcms_hr.department(department_id),
    is_incubator  BOOLEAN NOT NULL DEFAULT FALSE,
    has_phototherapy BOOLEAN NOT NULL DEFAULT FALSE,
    status        mcms_nursery.cot_status NOT NULL DEFAULT 'available',
    created_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS mcms_nursery.neonate_record (
    neonate_id      BIGSERIAL PRIMARY KEY,
    patient_id      BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id),
    mother_party_id BIGINT REFERENCES mcms_core.party(party_id),
    cot_id          BIGINT REFERENCES mcms_nursery.cot(cot_id),
    gestational_age_weeks NUMERIC(4,1),
    birth_weight_g  INT,
    apgar_1min      INT CHECK (apgar_1min BETWEEN 0 AND 10),
    apgar_5min      INT CHECK (apgar_5min BETWEEN 0 AND 10),
    admitted_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    discharged_at   TIMESTAMPTZ,
    notes           TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_neonate_patient ON mcms_nursery.neonate_record(patient_id);

-- growth chart / feeding / thermal follow-up entries
CREATE TABLE IF NOT EXISTS mcms_nursery.growth_entry (
    entry_id      BIGSERIAL PRIMARY KEY,
    neonate_id    BIGINT NOT NULL REFERENCES mcms_nursery.neonate_record(neonate_id) ON DELETE CASCADE,
    recorded_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    weight_g      INT,
    length_cm     NUMERIC(5,2),
    head_circ_cm  NUMERIC(5,2),
    temperature_c NUMERIC(4,1),
    feeding_type  TEXT,            -- breast / formula / NG / TPN
    feed_volume_ml INT,
    nurse_user_id BIGINT REFERENCES mcms_core.app_user(user_id),
    notes         TEXT
);
CREATE INDEX IF NOT EXISTS ix_growth_neonate ON mcms_nursery.growth_entry(neonate_id);

-- ---------------------------------------------------------------------
-- G5  PHARMACY: DRUG INTERACTIONS & ALTERNATIVES  (RxNorm/ATC ready)
-- ---------------------------------------------------------------------
DO $$ BEGIN
  CREATE TYPE mcms_rx.interaction_severity AS ENUM
    ('minor','moderate','major','contraindicated');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS mcms_rx.drug_interaction (
    interaction_id  BIGSERIAL PRIMARY KEY,
    drug_item_id_a  BIGINT NOT NULL REFERENCES mcms_rx.drug_item(drug_item_id),
    drug_item_id_b  BIGINT NOT NULL REFERENCES mcms_rx.drug_item(drug_item_id),
    severity        mcms_rx.interaction_severity NOT NULL DEFAULT 'moderate',
    mechanism       TEXT,
    clinical_effect TEXT,
    management      TEXT,
    source_ref      TEXT,               -- e.g. RxNorm/DrugBank citation
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_interaction_pair UNIQUE (drug_item_id_a, drug_item_id_b),
    CONSTRAINT ck_interaction_distinct CHECK (drug_item_id_a <> drug_item_id_b)
);
CREATE INDEX IF NOT EXISTS ix_interaction_a ON mcms_rx.drug_interaction(drug_item_id_a);
CREATE INDEX IF NOT EXISTS ix_interaction_b ON mcms_rx.drug_interaction(drug_item_id_b);

CREATE TABLE IF NOT EXISTS mcms_rx.drug_alternative (
    alternative_id     BIGSERIAL PRIMARY KEY,
    drug_item_id       BIGINT NOT NULL REFERENCES mcms_rx.drug_item(drug_item_id),
    alt_drug_item_id   BIGINT NOT NULL REFERENCES mcms_rx.drug_item(drug_item_id),
    reason             TEXT,            -- generic-equivalent / therapeutic / shortage
    is_generic_equiv   BOOLEAN NOT NULL DEFAULT FALSE,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT uq_alt_pair UNIQUE (drug_item_id, alt_drug_item_id),
    CONSTRAINT ck_alt_distinct CHECK (drug_item_id <> alt_drug_item_id)
);

-- add RxNorm code to drug_item (ATC already present)
ALTER TABLE mcms_rx.drug_item
    ADD COLUMN IF NOT EXISTS rxnorm_code TEXT;

-- ---------------------------------------------------------------------
-- G6  NOTIFICATIONS  (in-app + email + SMS)
-- ---------------------------------------------------------------------
DO $$ BEGIN
  CREATE TYPE mcms_core.notification_channel AS ENUM ('in_app','email','sms','push');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE mcms_core.notification_status AS ENUM
    ('pending','sent','delivered','read','failed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE IF NOT EXISTS mcms_core.notification (
    notification_id BIGSERIAL PRIMARY KEY,
    recipient_user_id  BIGINT REFERENCES mcms_core.app_user(user_id),
    recipient_party_id BIGINT REFERENCES mcms_core.party(party_id),
    category        TEXT NOT NULL,       -- surgery / appointment / lab / radiology / followup
    channel         mcms_core.notification_channel NOT NULL DEFAULT 'in_app',
    subject         TEXT,
    body            TEXT NOT NULL,
    status          mcms_core.notification_status NOT NULL DEFAULT 'pending',
    source_schema   TEXT,
    source_table    TEXT,
    source_id       BIGINT,
    sent_at         TIMESTAMPTZ,
    read_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ix_notif_user   ON mcms_core.notification(recipient_user_id);
CREATE INDEX IF NOT EXISTS ix_notif_party  ON mcms_core.notification(recipient_party_id);
CREATE INDEX IF NOT EXISTS ix_notif_status ON mcms_core.notification(status);

-- ---------------------------------------------------------------------
-- G7  RBAC ROLE CATALOG + PERMISSION MATRIX
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS mcms_core.role (
    role_id     BIGSERIAL PRIMARY KEY,
    code        TEXT NOT NULL UNIQUE,
    name_en     TEXT NOT NULL,
    name_ar     TEXT,
    description TEXT,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS mcms_core.permission (
    permission_id BIGSERIAL PRIMARY KEY,
    code          TEXT NOT NULL UNIQUE,      -- e.g. billing.write, emr.read
    description   TEXT
);

CREATE TABLE IF NOT EXISTS mcms_core.role_permission (
    role_id       BIGINT NOT NULL REFERENCES mcms_core.role(role_id) ON DELETE CASCADE,
    permission_id BIGINT NOT NULL REFERENCES mcms_core.permission(permission_id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE IF NOT EXISTS mcms_core.user_role_map (
    user_id    BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id) ON DELETE CASCADE,
    role_id    BIGINT NOT NULL REFERENCES mcms_core.role(role_id) ON DELETE CASCADE,
    -- ABAC attribute: scope the role to a department/shift
    department_id BIGINT REFERENCES mcms_hr.department(department_id),
    PRIMARY KEY (user_id, role_id)
);

COMMIT;
