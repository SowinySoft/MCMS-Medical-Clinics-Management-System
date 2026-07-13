-- ============================================================
-- MCMS · 07 · RX (Pharmacy)
-- Drug catalog, inventory lots, dispensations, admin records,
-- purchase orders (supplier-side cross-link to mcms_erp).
-- Stock movements emit low_stock_alert events.
-- ============================================================

BEGIN;

-- ---------- Drug Catalog ----------
CREATE TYPE mcms_rx.drug_class AS ENUM (
   'antibiotic','analgesic','antihypertensive','antidiabetic','anticoagulant',
   'antihistamine','antidepressant','antipsychotic','corticosteroid','nsaid','antacid','diuretic',
   'cardiac','respiratory','gi','cns','hormone','vitamin','vaccine','iv_fluid','controlled','anaesthesia','other'
);
CREATE TYPE mcms_rx.route_type AS ENUM ('po','iv','im','sc','inh','top','pr','sl','gt');

CREATE TABLE mcms_rx.drug_item (
   drug_item_id        BIGSERIAL PRIMARY KEY,
   generic_name        TEXT NOT NULL,
   brand_name           TEXT,
   drug_class           mcms_rx.drug_class NOT NULL DEFAULT 'other',
   form                TEXT,                              -- tablet, capsule, vial, syrup ...
   strength             TEXT,                              -- '500 mg'
   unit                TEXT,
   atc_code             TEXT,                              -- Anatomical Therapeutic Chemical
   controlled_substance BOOLEAN NOT NULL DEFAULT FALSE,
   requires_cold_chain   BOOLEAN NOT NULL DEFAULT FALSE,
   manufacturer         TEXT,
   reorder_level         INT NOT NULL DEFAULT 10,
   reorder_qty           INT NOT NULL DEFAULT 50,
   is_active            BOOLEAN NOT NULL DEFAULT TRUE,
   cost_per_unit        NUMERIC(10,2) NOT NULL DEFAULT 0,
   sale_price_per_unit  NUMERIC(10,2) NOT NULL DEFAULT 0,
   created_at           timestamptz NOT NULL DEFAULT now(),
   updated_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_rx.drug_item (drug_class);
CREATE INDEX ON mcms_rx.drug_item USING GIN (to_tsvector('english', generic_name || ' ' || COALESCE(brand_name,'')));

-- ---------- Inventory lots ----------
CREATE TYPE mcms_rx.lot_status AS ENUM ('on_hand','dispensed','expired','quarantined','returned');

CREATE TABLE mcms_rx.drug_lot (
   lot_id              BIGSERIAL PRIMARY KEY,
   drug_item_id        BIGINT NOT NULL REFERENCES mcms_rx.drug_item(drug_item_id) ON DELETE CASCADE,
   lot_number          TEXT NOT NULL,
   received_qty        INT NOT NULL CHECK (received_qty > 0),
   on_hand_qty         INT NOT NULL CHECK (on_hand_qty >= 0),
   manufactured_on     DATE,
   expires_on          DATE NOT NULL,
   received_at         timestamptz NOT NULL DEFAULT now(),
   supplier_party_id   BIGINT REFERENCES mcms_core.party(party_id),
   purchase_order_id   BIGINT,                              -- → mcms_erp.purchase_order
   unit_cost           NUMERIC(10,2) NOT NULL CHECK (unit_cost >= 0),
   status              mcms_rx.lot_status NOT NULL DEFAULT 'on_hand',
   UNIQUE (drug_item_id, lot_number)
);
CREATE INDEX ON mcms_rx.drug_lot (drug_item_id);
CREATE INDEX ON mcms_rx.drug_lot (expires_on);
CREATE INDEX ON mcms_rx.drug_lot (status);

-- ---------- Dispensations ----------
CREATE TABLE mcms_rx.dispensation (
   dispensation_id     BIGSERIAL PRIMARY KEY,
   patient_id          BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   mrn                 TEXT NOT NULL,
   encounter_id        BIGINT REFERENCES mcms_emr.encounter(encounter_id),
   med_order_id        BIGINT REFERENCES mcms_emr.medication_order(order_id),
   drug_item_id        BIGINT NOT NULL REFERENCES mcms_rx.drug_item(drug_item_id),
   lot_id              BIGINT REFERENCES mcms_rx.drug_lot(lot_id),
   quantity            INT NOT NULL CHECK (quantity > 0),
   dispensed_at        timestamptz NOT NULL DEFAULT now(),
   dispensed_by        BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   instructions        TEXT,
   notes               TEXT
);
CREATE INDEX ON mcms_rx.dispensation (patient_id, dispensed_at DESC);
CREATE INDEX ON mcms_rx.dispensation (med_order_id);

-- ---------- Administration (inpatient drug given) ----------
CREATE TABLE mcms_rx.administration (
   administer_id       BIGSERIAL PRIMARY KEY,
   patient_id          BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   med_order_id        BIGINT REFERENCES mcms_emr.medication_order(order_id),
   drug_item_id        BIGINT NOT NULL REFERENCES mcms_rx.drug_item(drug_item_id),
   dose_given          TEXT NOT NULL,
   dose_at             timestamptz NOT NULL DEFAULT now(),
   administered_by     BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   witnessed_by        BIGINT REFERENCES mcms_core.app_user(user_id),
   site                TEXT,
   notes               TEXT
);
CREATE INDEX ON mcms_rx.administration (patient_id, dose_at DESC);

-- ---------- Stock adjustments ----------
CREATE TYPE mcms_rx.move_type AS ENUM ('reception','dispense','adjust_in','adjust_out','return','expiry','waste','transfer');

CREATE TABLE mcms_rx.stock_movement (
   movement_id          BIGSERIAL PRIMARY KEY,
   drug_item_id         BIGINT NOT NULL REFERENCES mcms_rx.drug_item(drug_item_id),
   lot_id               BIGINT REFERENCES mcms_rx.drug_lot(lot_id),
   movement_type         mcms_rx.move_type NOT NULL,
   qty_delta            INT NOT NULL,
   balance_after         INT NOT NULL,
   related_movement_id  BIGINT REFERENCES mcms_rx.stock_movement(movement_id),
   reason               TEXT,
   performed_by         BIGINT REFERENCES mcms_core.app_user(user_id),
   performed_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_rx.stock_movement (drug_item_id, performed_at);
CREATE INDEX ON mcms_rx.stock_movement (movement_type);

-- ---------- Dispensation event + lot decrement ----------
CREATE OR REPLACE FUNCTION mcms_rx.fn_dispense_event_and_stock()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   bal INT;
   drugrow mcms_rx.drug_item%ROWTYPE;
BEGIN
   -- decrement lot on_hand (assumed new lot_id is set)
   IF NEW.lot_id IS NOT NULL THEN
      UPDATE mcms_rx.drug_lot
         SET on_hand_qty = on_hand_qty - NEW.quantity
       WHERE lot_id = NEW.lot_id AND on_hand_qty >= NEW.quantity
       RETURNING on_hand_qty INTO bal;
      IF bal IS NULL THEN
          RAISE EXCEPTION 'Insufficient stock in lot %', NEW.lot_id
            USING ERRCODE = '40001';   -- 40001 serialization_failure handled by caller / DDL abort
      END IF;

      -- balance_after for stock_movement
      bal := bal;
      INSERT INTO mcms_rx.stock_movement (drug_item_id, lot_id, movement_type, qty_delta, balance_after, performed_by, reason)
      VALUES (NEW.drug_item_id, NEW.lot_id, 'dispense', -NEW.quantity, bal, NEW.dispensed_by,
              'dispense to patient ' || NEW.mrn);
   END IF;

   PERFORM mcms_core.emit_event('medication_dispensed','info', NEW.dispensed_by, NEW.patient_id,
      'mcms_rx','dispensation', NEW.dispensation_id,
      jsonb_build_object('drug_item_id', NEW.drug_item_id, 'qty', NEW.quantity, 'mrn', NEW.mrn));

   -- low stock check
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
CREATE TRIGGER trg_dispense_event AFTER INSERT ON mcms_rx.dispensation
FOR EACH ROW EXECUTE FUNCTION mcms_rx.fn_dispense_event_and_stock();

-- Administration event
CREATE OR REPLACE FUNCTION mcms_rx.fn_administer_event()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
   PERFORM mcms_core.emit_event('medication_administered','info', NEW.administered_by, NEW.patient_id,
      'mcms_rx','administration', NEW.administer_id,
      jsonb_build_object('drug_item_id', NEW.drug_item_id, 'dose', NEW.dose_given));
   RETURN NEW;
END$$;
CREATE TRIGGER trg_admin_event AFTER INSERT ON mcms_rx.administration
FOR EACH ROW EXECUTE FUNCTION mcms_rx.fn_administer_event();

-- expired-lot scan emits warning event (manually invoked)
CREATE OR REPLACE FUNCTION mcms_rx.scan_expired_lots()
RETURNS INT LANGUAGE plpgsql AS $$
DECLARE n INT;
BEGIN
   UPDATE mcms_rx.drug_lot SET status='expired'
    WHERE expires_on < now()::date AND status='on_hand'
    RETURNING drug_item_id INTO n;
   PERFORM mcms_core.emit_event('low_stock_alert','warning', NULL, NULL,
       'mcms_rx','drug_lot', NULL,
       jsonb_build_object('note', 'expired lot quarantine done'));
   RETURN n;
END$$;

CREATE TRIGGER trg_drug_touch BEFORE UPDATE ON mcms_rx.drug_item
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();

COMMIT;
