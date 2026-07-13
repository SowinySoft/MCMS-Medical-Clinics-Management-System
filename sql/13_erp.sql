-- ============================================================
-- MCMS · 13 · ERP
-- Inventory across departments (consumables, instruments, capital equipment),
-- purchase orders, suppliers (party_role), stock movements,
-- goods receipts, GL accounts for posting.
-- Inventory complements mcms_rx.drug_lot - this schema covers non-drug stock.
-- ============================================================

BEGIN;

-- ---------- General Ledger Accounts ----------
CREATE TYPE mcms_erp.account_type AS ENUM ('asset','liability','equity','revenue','expense','cash','bank','control');

CREATE TABLE mcms_erp.gl_account (
   account_id           BIGSERIAL PRIMARY KEY,
   code                 TEXT NOT NULL UNIQUE,                    -- '1000-CASH','4000-REVENUE'...
   name                 TEXT NOT NULL,
   account_type         mcms_erp.account_type NOT NULL,
   parent_account_id    BIGINT REFERENCES mcms_erp.gl_account(account_id),
   is_postable          BOOLEAN NOT NULL DEFAULT TRUE,
   is_active            BOOLEAN NOT NULL DEFAULT TRUE
);
CREATE INDEX ON mcms_erp.gl_account (account_type);
CREATE INDEX ON mcms_erp.gl_account (parent_account_id);

-- ---------- Item (non-drug inventory) ----------
CREATE TYPE mcms_erp.item_type AS ENUM ('consumable','instrument','capital','medical_supply','office','ppe','utility','other');

CREATE TABLE mcms_erp.inventory_item (
   item_id              BIGSERIAL PRIMARY KEY,
   code                 TEXT NOT NULL UNIQUE,
   name                 TEXT NOT NULL,
   type                 mcms_erp.item_type NOT NULL DEFAULT 'other',
   unit                 TEXT,                                  -- pcs, box, litre
   reorder_level        INT NOT NULL DEFAULT 0,
   reorder_qty          INT NOT NULL DEFAULT 0,
   cost_per_unit        NUMERIC(12,2) NOT NULL DEFAULT 0,
   is_active             BOOLEAN NOT NULL DEFAULT TRUE,
   created_at           timestamptz NOT NULL DEFAULT now(),
   updated_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_erp.inventory_item (type);

-- ---------- Item Stock per Department ----------
CREATE TABLE mcms_erp.inventory_stock (
   stock_id             BIGSERIAL PRIMARY KEY,
   item_id              BIGINT NOT NULL REFERENCES mcms_erp.inventory_item(item_id) ON DELETE CASCADE,
   department_id        BIGINT NOT NULL REFERENCES mcms_hr.department(department_id),
   qty_on_hand          INT NOT NULL CHECK (qty_on_hand >= 0),
   qty_reserved          INT NOT NULL DEFAULT 0,
   last_count_at        timestamptz,
   updated_at           timestamptz NOT NULL DEFAULT now(),
   UNIQUE (item_id, department_id)
);
CREATE INDEX ON mcms_erp.inventory_stock (department_id);

-- ---------- Document numbering ----------
CREATE TYPE mcms_erp.po_status AS ENUM ('draft','pending_approval','approved','sent','partial_received','received','closed','cancelled');
CREATE TYPE mcms_erp.grn_status AS ENUM ('pending','received','partial','rejected','cancelled');

-- ---------- Supplier (party_role) ----------
CREATE TABLE mcms_erp.supplier (
   supplier_id          BIGSERIAL PRIMARY KEY,
   party_id             BIGINT NOT NULL UNIQUE REFERENCES mcms_core.party(party_id) ON DELETE CASCADE,
   supplier_code        TEXT NOT NULL UNIQUE,
   contact_user_id      BIGINT REFERENCES mcms_core.app_user(user_id),
   payment_terms_days   INT NOT NULL DEFAULT 30,
   is_active            BOOLEAN NOT NULL DEFAULT TRUE,
   created_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_erp.supplier (party_id);

-- ---------- Purchase Order ----------
CREATE TABLE mcms_erp.purchase_order (
   po_id                BIGSERIAL PRIMARY KEY,
   po_no                TEXT NOT NULL UNIQUE,
   supplier_id          BIGINT NOT NULL REFERENCES mcms_erp.supplier(supplier_id),
   requested_by          BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   approved_by          BIGINT REFERENCES mcms_core.app_user(user_id),
   status                mcms_erp.po_status NOT NULL DEFAULT 'draft',
   expected_at           DATE,
   ordered_at            timestamptz NOT NULL DEFAULT now(),
   received_at           timestamptz,
   closed_at            timestamptz,
   notes                TEXT,
   created_at           timestamptz NOT NULL DEFAULT now(),
   updated_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_erp.purchase_order (supplier_id);
CREATE INDEX ON mcms_erp.purchase_order (status);

-- ---------- PO Lines ----------
-- Each line points to either an inventory item OR a drug lot requisition.
CREATE TABLE mcms_erp.purchase_order_line (
   line_id              BIGSERIAL PRIMARY KEY,
   po_id                BIGINT NOT NULL REFERENCES mcms_erp.purchase_order(po_id) ON DELETE CASCADE,
   item_id              BIGINT REFERENCES mcms_erp.inventory_item(item_id),
   drug_item_id         BIGINT REFERENCES mcms_rx.drug_item(drug_item_id),
   item_description     TEXT NOT NULL,
   qty                  INT NOT NULL CHECK (qty > 0),
   unit_price           NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
   qty_received         INT NOT NULL DEFAULT 0,
   line_total            NUMERIC(14,2) GENERATED ALWAYS AS (qty * unit_price) STORED,
   CHECK (item_id IS NOT NULL OR drug_item_id IS NOT NULL)
);
CREATE INDEX ON mcms_erp.purchase_order_line (po_id);

-- ---------- Goods Receipt Note ----------
CREATE TABLE mcms_erp.goods_receipt (
   grn_id                 BIGSERIAL PRIMARY KEY,
   grn_no                 TEXT NOT NULL UNIQUE,
   po_id                  BIGINT REFERENCES mcms_erp.purchase_order(po_id),
   supplier_id            BIGINT NOT NULL REFERENCES mcms_erp.supplier(supplier_id),
   received_by            BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   received_at            timestamptz NOT NULL DEFAULT now(),
   status                 mcms_erp.grn_status NOT NULL DEFAULT 'received',
   notes                  TEXT
);
CREATE INDEX ON mcms_erp.goods_receipt (po_id);
CREATE INDEX ON mcms_erp.goods_receipt (supplier_id);

-- ---------- GRN Lines update stock ----------
CREATE TABLE mcms_erp.goods_receipt_line (
   line_id              BIGSERIAL PRIMARY KEY,
   grn_id               BIGINT NOT NULL REFERENCES mcms_erp.goods_receipt(grn_id) ON DELETE CASCADE,
   po_line_id           BIGINT REFERENCES mcms_erp.purchase_order_line(line_id),
   item_id              BIGINT REFERENCES mcms_erp.inventory_item(item_id),
   drug_item_id         BIGINT REFERENCES mcms_rx.drug_item(drug_item_id),
   qty_received         INT NOT NULL CHECK (qty_received > 0),
   lot_number           TEXT,                            -- new lot for drugs
   expiration_date         DATE,
   unit_cost            NUMERIC(12,2)
);
CREATE INDEX ON mcms_erp.goods_receipt_line (grn_id);

-- ---------- Stock Movements (internal issue/return/transfers between departments) ----------
CREATE TYPE mcms_erp.move_type AS ENUM ('issue','return','transfer_in','transfer_out','adjust_in','adjust_out','write_off','initial','count_variance');

CREATE TABLE mcms_erp.stock_movement (
   movement_id          BIGSERIAL PRIMARY KEY,
   item_id              BIGINT NOT NULL REFERENCES mcms_erp.inventory_item(item_id),
   from_department_id   BIGINT REFERENCES mcms_hr.department(department_id),
   to_department_id     BIGINT REFERENCES mcms_hr.department(department_id),
   qty_delta            INT NOT NULL,                 -- negative for out
   movement_type        mcms_erp.move_type NOT NULL,
   reference_table      TEXT,                          -- link to source doc (po_line, grn, dispensation)
   reference_id        BIGINT,
   performed_by         BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   performed_at         timestamptz NOT NULL DEFAULT now(),
   reason               TEXT
);
CREATE INDEX ON mcms_erp.stock_movement (item_id, performed_at);
CREATE INDEX ON mcms_erp.stock_movement (from_department_id);
CREATE INDEX ON mcms_erp.stock_movement (to_department_id);

-- ---------- Purchase Order Line receipt handler ----------
-- Receiving goods against a PO line: stock up inventory, update po_line.qty_received, raise event if complete.
CREATE OR REPLACE FUNCTION mcms_erp.fn_grn_line_insert()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   inv   mcms_erp.inventory_item%ROWTYPE;
   stock mcms_erp.inventory_stock%ROWTYPE;
   po_line mcms_erp.purchase_order_line%ROWTYPE;
   cnt INT;
   newlot BIGINT;
   pid BIGINT;
BEGIN
   IF NEW.item_id IS NOT NULL THEN
      -- Insert into inventory_stock if not exists, or increment qty.
      SELECT * INTO stock FROM mcms_erp.inventory_stock WHERE item_id = NEW.item_id AND department_id = (
         SELECT COALESCE(to_department_id, from_department_id) FROM mcms_erp.goods_receipt g, mcms_erp.purchase_order p
         WHERE g.grn_id = NEW.grn_id AND (g.po_id = p.po_id)
         LIMIT 1);
      -- Determine the receiving department; default: link via PO that requested by user's primary dept
      PERFORM mcms_erp.upsert_stock(NEW.item_id, NEW.qty_received, NULL);
   ELSIF NEW.drug_item_id IS NOT NULL THEN
      INSERT INTO mcms_rx.drug_lot (drug_item_id, lot_number, received_qty, on_hand_qty, expires_on, supplier_party_id, unit_cost)
      VALUES (NEW.drug_item_id, NEW.lot_number, NEW.qty_received, NEW.qty_received, NEW.expiration_date,
              (SELECT s.party_id FROM mcms_erp.supplier s JOIN mcms_erp.goods_receipt g ON g.supplier_id = s.supplier_id WHERE g.grn_id = NEW.grn_id),
              NEW.unit_cost)
      RETURNING lot_id INTO newlot;
   END IF;

   -- Update po_line.qty_received
   IF NEW.po_line_id IS NOT NULL THEN
      UPDATE mcms_erp.purchase_order_line
         SET qty_received = qty_received + NEW.qty_received
       WHERE line_id = NEW.po_line_id
       RETURNING * INTO po_line;
   END IF;

   -- If all lines received, mark PO as 'received'
   IF (SELECT COUNT(*) FROM mcms_erp.purchase_order_line WHERE po_id = po_line.po_id AND qty_received < qty) = 0 THEN
      UPDATE mcms_erp.purchase_order SET status='received', received_at=now()
       WHERE po_id = po_line.po_id AND status IN ('sent','partial_received','approved');
   ELSE
      UPDATE mcms_erp.purchase_order SET status='partial_received' WHERE po_id = po_line.po_id AND status IN ('approved','sent');
   END IF;

   PERFORM mcms_core.emit_event('purchase_order_raised','info', NULL, NULL,
      'mcms_erp','goods_receipt_line', NEW.line_id,
      jsonb_build_object('grn_id', NEW.grn_id, 'item_id', NEW.item_id, 'drug_item_id', NEW.drug_item_id,
                         'qty_received', NEW.qty_received),
      p_channel := 'mcms_inventory');
   RETURN NEW;
END$$;

CREATE OR REPLACE FUNCTION mcms_erp.upsert_stock(p_item_id BIGINT, p_qty INT, p_dept_id BIGINT)
RETURNS VOID LANGUAGE plpgsql AS $$
DECLARE sid BIGINT;
BEGIN
   INSERT INTO mcms_erp.inventory_stock (item_id, department_id, qty_on_hand)
   VALUES (p_item_id, COALESCE(p_dept_id, (SELECT MIN(department_id) FROM mcms_hr.department)),
           p_qty)
   ON CONFLICT (item_id, department_id)
   DO UPDATE SET qty_on_hand = inventory_stock.qty_on_hand + p_qty,
                 updated_at = now()
   RETURNING stock_id INTO sid;
END$$;

CREATE TRIGGER trg_grn_line AFTER INSERT ON mcms_erp.goods_receipt_line
FOR EACH ROW EXECUTE FUNCTION mcms_erp.fn_grn_line_insert();

CREATE TRIGGER trg_po_touch BEFORE UPDATE ON mcms_erp.purchase_order
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER tgt_inv_item_touch BEFORE UPDATE ON mcms_erp.inventory_item
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();

COMMIT;
