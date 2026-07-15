-- ============================================================
-- MCMS · 08 · LAB
-- Test catalog, panels, sample collection, results.
-- Linkable to clinical encounter + diagnostic orders.
-- ============================================================

BEGIN;

-- ---------- Specimen Types ----------
CREATE TYPE mcms_lab.specimen_type AS ENUM ('blood','urine','stool','sputum','tissue','csf','swab','fluid','other');
CREATE TYPE mcms_lab.sample_status AS ENUM ('collected','in_transit','received','in_progress','resulted','rejected','cancelled');
CREATE TYPE mcms_lab.workup_phase AS ENUM ('pending','running','paused','completed','invalid');

-- ---------- Test Catalog ----------
CREATE TABLE mcms_lab.test_catalog (
   test_id             BIGSERIAL PRIMARY KEY,
   loinc_code          TEXT,                                -- LOINC international code
   name                TEXT NOT NULL,
   category            TEXT,                                -- hematology, chemistry, microbiology, pathology...
   specimen_type       mcms_lab.specimen_type NOT NULL,
   volume_required      NUMERIC(6,2),                       -- mL
   unit                TEXT,
   ref_low             NUMERIC,
   ref_high            NUMERIC,
   turnaround_minutes  INT,
   is_active           BOOLEAN DEFAULT TRUE,
   created_at          timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_lab.test_catalog (category);
CREATE INDEX ON mcms_lab.test_catalog (loinc_code);

-- ---------- Panel ----------
CREATE TABLE mcms_lab.test_panel (
   panel_id            BIGSERIAL PRIMARY KEY,
   code                TEXT NOT NULL UNIQUE,
   name                TEXT NOT NULL,
   created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE mcms_lab.test_panel_item (
   ppi_id               BIGSERIAL PRIMARY KEY,
   panel_id             BIGINT NOT NULL REFERENCES mcms_lab.test_panel(panel_id) ON DELETE CASCADE,
   test_id              BIGINT NOT NULL REFERENCES mcms_lab.test_catalog(test_id),
   sort_order            INT DEFAULT 0
);
-- ---------- Lab Requisition (panel) ----------
CREATE TYPE mcms_lab.order_priority AS ENUM ('routine','urgent','stat','asap');

CREATE TABLE mcms_lab.lab_order (
   order_id             BIGSERIAL PRIMARY KEY,
   order_no             TEXT NOT NULL UNIQUE,
   encounter_id         BIGINT NOT NULL REFERENCES mcms_emr.encounter(encounter_id),
   patient_id           BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   mrn                  TEXT NOT NULL,
   requested_by         BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   order_priority       mcms_lab.order_priority NOT NULL DEFAULT 'routine',
   panel_id             BIGINT REFERENCES mcms_lab.test_panel(panel_id),
   clinical_indication  TEXT,
   requested_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_lab.lab_order (patient_id);
CREATE INDEX ON mcms_lab.lab_order (encounter_id);
CREATE INDEX ON mcms_lab.lab_order (order_priority, requested_at);

-- ---------- Sample ----------
CREATE TABLE mcms_lab.sample (
   sample_id            BIGSERIAL PRIMARY KEY,
   sample_no            TEXT NOT NULL UNIQUE,
   lab_order_id         BIGINT NOT NULL REFERENCES mcms_lab.lab_order(order_id) ON DELETE CASCADE,
   test_ids             BIGINT[],
   specimen_type        mcms_lab.specimen_type NOT NULL,
   volume_collected     NUMERIC(6,2),
   collected_at         timestamptz NOT NULL DEFAULT now(),
   collected_by         BIGINT REFERENCES mcms_core.app_user(user_id),
   received_at          timestamptz,
   received_by          BIGINT REFERENCES mcms_core.app_user(user_id),
   status               mcms_lab.sample_status NOT NULL DEFAULT 'collected',
   rejected_reason      TEXT
);
CREATE INDEX ON mcms_lab.sample (lab_order_id);
CREATE INDEX ON mcms_lab.sample (status);

-- ---------- Result ----------
CREATE TYPE mcms_lab.result_flag AS ENUM ('normal','low','high','critical','abnormal','pending');

CREATE TABLE mcms_lab.result (
   result_id            BIGSERIAL PRIMARY KEY,
   sample_id            BIGINT NOT NULL REFERENCES mcms_lab.sample(sample_id) ON DELETE CASCADE,
   test_id              BIGINT NOT NULL REFERENCES mcms_lab.test_catalog(test_id),
   value_text           TEXT,
   value_numeric        NUMERIC(14,4),
   unit                 TEXT,
   ref_range             TEXT,
   flag                 mcms_lab.result_flag NOT NULL DEFAULT 'pending',
   analysed_by          BIGINT REFERENCES mcms_core.app_user(user_id),
   analysed_at          timestamptz,
   verified_by          BIGINT REFERENCES mcms_core.app_user(user_id),
   verified_at          timestamptz,
   rejected_at          timestamptz,
   rejected_reason      TEXT,
   created_at           timestamptz NOT NULL DEFAULT now(),
   UNIQUE (sample_id, test_id)
);
CREATE INDEX ON mcms_lab.result (sample_id);
CREATE INDEX ON mcms_lab.result (flag);

-- ---------- Events ----------
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
CREATE TRIGGER trg_lab_order_event AFTER INSERT ON mcms_lab.lab_order
FOR EACH ROW EXECUTE FUNCTION mcms_lab.fn_lab_order_event();

CREATE OR REPLACE FUNCTION mcms_lab.fn_sample_event()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
   IF (NEW.status = 'collected' AND ((TG_OP='INSERT') OR (TG_OP='UPDATE' AND OLD.status <> NEW.status))) THEN
      PERFORM mcms_core.emit_event('sample_collected','info', NEW.collected_by, NULL,
         'mcms_lab','sample', NEW.sample_id,
         jsonb_build_object('sample_no', NEW.sample_no, 'specimen_type', NEW.specimen_type::text));
   ELSIF (TG_OP='UPDATE' AND NEW.status = 'rejected' AND OLD.status <> 'rejected') THEN
      PERFORM mcms_core.emit_event('result_rejected','warning', NEW.received_by, NULL,
         'mcms_lab','sample', NEW.sample_id,
         jsonb_build_object('rejected_reason', COALESCE(NEW.rejected_reason,'')));
   END IF;
   RETURN NEW;
END$$;
CREATE TRIGGER trg_sample_event AFTER INSERT OR UPDATE OF status ON mcms_lab.sample
FOR EACH ROW EXECUTE FUNCTION mcms_lab.fn_sample_event();

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
CREATE TRIGGER trg_result_event AFTER INSERT OR UPDATE OF verified_at ON mcms_lab.result
FOR EACH ROW EXECUTE FUNCTION mcms_lab.fn_result_event();

COMMIT;
