-- ============================================================
-- MCMS · 12 · BILLING
-- Services price list, invoices, line items, payments, insurance claims,
-- co-payments, refund. Other modules (lab, rad, surgery, icu, pharmacy)
-- all emit billing events feeding the invoice.
-- ============================================================

BEGIN;

CREATE TYPE mcms_billing.inv_status AS ENUM ('draft','issued','partial','paid','disputed','cancelled','refunded');
CREATE TYPE mcms_billing.claim_status AS ENUM ('draft','submitted','processing','approved','partial_paid','rejected','paid');
CREATE TYPE mcms_billing.pay_method AS ENUM ('cash','card','cheque','bank_transfer','insurance','wallet');

-- ---------- Service Price List ----------
-- Each billable entity points to a category + department for cross-cutting reports.
CREATE TYPE mcms_billing.service_type AS ENUM (
   'consultation','procedure','surgery_or','surgery_surgeon_fee','anaesthesia','lab_test','imaging',
   'pharmacy','icu_bed','emr_document','physio_session','emergency_triage','ambulance','diagnostic_fee',
   'room_charge','maternity','consumable','other'
);

CREATE TABLE mcms_billing.service_price (
   service_id           BIGSERIAL PRIMARY KEY,
   code                 TEXT NOT NULL UNIQUE,                   -- 'SVC-CONSULT-GEN', 'SVC-CT-CHEST'
   name                 TEXT NOT NULL,
   service_type         mcms_billing.service_type NOT NULL,
   department_id        BIGINT REFERENCES mcms_hr.department(department_id),
   unit_price           NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
   currency             TEXT NOT NULL DEFAULT 'SAR',           -- can be USD/EGP/...
   is_taxable           BOOLEAN NOT NULL DEFAULT TRUE,
   is_active            BOOLEAN NOT NULL DEFAULT TRUE,
   effective_from        DATE NOT NULL DEFAULT CURRENT_DATE,
   effective_to          DATE,
   created_at           timestamptz NOT NULL DEFAULT now(),
   updated_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_billing.service_price (service_type);
CREATE INDEX ON mcms_billing.service_price (department_id);

-- ---------- Invoice ----------
CREATE TABLE mcms_billing.invoice (
   invoice_id           BIGSERIAL PRIMARY KEY,
   invoice_no           TEXT NOT NULL UNIQUE,
   patient_id           BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   mrn                  TEXT NOT NULL,
   encounter_id         BIGINT REFERENCES mcms_emr.encounter(encounter_id),
   issued_by             BIGINT NOT NULL REFERENCES mcms_core.app_user(user_id),
   status               mcms_billing.inv_status NOT NULL DEFAULT 'draft',
   subtotal             NUMERIC(14,2) NOT NULL DEFAULT 0,
   tax_amount           NUMERIC(14,2) NOT NULL DEFAULT 0,
   discount_amount      NUMERIC(14,2) NOT NULL DEFAULT 0,
   insurance_covers     NUMERIC(14,2) NOT NULL DEFAULT 0,
   patient_pays         NUMERIC(14,2) NOT NULL DEFAULT 0,
   total                NUMERIC(14,2) GENERATED ALWAYS AS (subtotal + tax_amount - discount_amount) STORED,
   currency             TEXT NOT NULL DEFAULT 'SAR',
   issued_at            timestamptz NOT NULL DEFAULT now(),
   due_date             DATE,
   paid_at              timestamptz,
   notes                TEXT,
   created_at           timestamptz NOT NULL DEFAULT now(),
   updated_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_billing.invoice (patient_id, issued_at DESC);
CREATE INDEX ON mcms_billing.invoice (encounter_id);
CREATE INDEX ON mcms_billing.invoice (status);

-- ---------- Invoice Line Items (lock-in price/qty at time of issue) ----------
CREATE TABLE mcms_billing.invoice_line (
   line_id            BIGSERIAL PRIMARY KEY,
   invoice_id         BIGINT NOT NULL REFERENCES mcms_billing.invoice(invoice_id) ON DELETE CASCADE,
   service_id          BIGINT REFERENCES mcms_billing.service_price(service_id),
   source_schema       TEXT,                          -- mcms_lab.result, mcms_rx.dispensation ...
   source_table        TEXT,
   source_id          BIGINT,
   description        TEXT NOT NULL,
   qty                NUMERIC(8,2) NOT NULL DEFAULT 1 CHECK (qty > 0),
   unit_price         NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),
   line_total         NUMERIC(14,2) GENERATED ALWAYS AS (qty * unit_price) STORED,
   created_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_billing.invoice_line (invoice_id);
CREATE INDEX ON mcms_billing.invoice_line (service_id);

-- ---------- Payment ----------
CREATE TABLE mcms_billing.payment (
   payment_id          BIGSERIAL PRIMARY KEY,
   invoice_id          BIGINT NOT NULL REFERENCES mcms_billing.invoice(invoice_id) ON DELETE CASCADE,
   method              mcms_billing.pay_method NOT NULL,
   amount              NUMERIC(14,2) NOT NULL CHECK (amount > 0),
   currency            TEXT NOT NULL DEFAULT 'SAR',
   paid_at             timestamptz NOT NULL DEFAULT now(),
   received_by         BIGINT REFERENCES mcms_core.app_user(user_id),
   txn_ref              TEXT,                          -- bank/processor reference
   notes                TEXT
);
CREATE INDEX ON mcms_billing.payment (invoice_id);

-- ---------- Insurance Claim ----------
CREATE TABLE mcms_billing.insurance_claim (
   claim_id            BIGSERIAL PRIMARY KEY,
   invoice_id          BIGINT NOT NULL REFERENCES mcms_billing.invoice(invoice_id) ON DELETE CASCADE,
   policy_no           TEXT NOT NULL,
   insurance_provider     TEXT NOT NULL,
   patient_id          BIGINT NOT NULL REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE,
   billed_amount        NUMERIC(14,2) NOT NULL,
   approved_amount      NUMERIC(14,2),
   rejected_amount     NUMERIC(14,2) NOT NULL DEFAULT 0,
   status               mcms_billing.claim_status NOT NULL DEFAULT 'draft',
   submitted_at        timestamptz,
   adjudicated_at      timestamptz,
   paid_at             timestamptz,
   claim_no_external   TEXT,
   notes               TEXT,
   created_at          timestamptz NOT NULL DEFAULT now(),
   updated_at          timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_billing.insurance_claim (invoice_id);
CREATE INDEX ON mcms_billing.insurance_claim (status);

-- ---------- Events ----------
CREATE OR REPLACE FUNCTION mcms_billing.fn_invoice_event()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
   IF (TG_OP='INSERT' AND NEW.status IN ('issued','partial','paid')) THEN
      PERFORM mcms_core.emit_event('invoice_issued','info', NEW.issued_by, NEW.patient_id,
         'mcms_billing','invoice', NEW.invoice_id,
         jsonb_build_object('invoice_no', NEW.invoice_no, 'total', NEW.total));
   END IF;
   RETURN NEW;
END$$;
CREATE TRIGGER trg_inv_event AFTER INSERT ON mcms_billing.invoice
FOR EACH ROW EXECUTE FUNCTION mcms_billing.fn_invoice_event();

CREATE OR REPLACE FUNCTION mcms_billing.fn_payment_event()
RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
   inv mcms_billing.invoice%ROWTYPE;
   paid NUMERIC(14,2);
BEGIN
   SELECT * INTO inv FROM mcms_billing.invoice WHERE invoice_id = NEW.invoice_id;
   SELECT COALESCE(SUM(amount),0) INTO paid FROM mcms_billing.payment WHERE invoice_id = NEW.invoice_id;
   IF inv.total > 0 AND paid >= inv.total AND inv.status <> 'paid' THEN
     UPDATE mcms_billing.invoice SET status='paid', paid_at = now() WHERE invoice_id = NEW.invoice_id;
   END IF;
   PERFORM mcms_core.emit_event('payment_received','info', NEW.received_by, NULL,
      'mcms_billing','payment', NEW.payment_id,
      jsonb_build_object('invoice_id', NEW.invoice_id, 'amount', NEW.amount, 'method', NEW.method::text));
   RETURN NEW;
END$$;
CREATE TRIGGER trg_payment_event AFTER INSERT ON mcms_billing.payment
FOR EACH ROW EXECUTE FUNCTION mcms_billing.fn_payment_event();

CREATE OR REPLACE FUNCTION mcms_billing.fn_claim_event()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
   IF (TG_OP='UPDATE' AND OLD.status <> NEW.status AND NEW.status='submitted') THEN
      PERFORM mcms_core.emit_event('insurance_claim_submitted','info', NULL, NULL,
         'mcms_billing','insurance_claim', NEW.claim_id,
         jsonb_build_object('provider', NEW.insurance_provider,'amount', NEW.billed_amount));
   END IF;
   RETURN NEW;
END$$;
CREATE TRIGGER trg_claim_event AFTER UPDATE OF status ON mcms_billing.insurance_claim
FOR EACH ROW EXECUTE FUNCTION mcms_billing.fn_claim_event();

CREATE TRIGGER trg_invoice_touch BEFORE UPDATE ON mcms_billing.invoice
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER trg_svc_price_touch BEFORE UPDATE ON mcms_billing.service_price
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER trg_claim_touch BEFORE UPDATE ON mcms_billing.insurance_claim
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();

COMMIT;
