-- ============================================================
-- MCMS · 99 · Cross-schema FK patches + view helpers
-- Adds FK links that could not be declared inline because the source
-- table was created before the target table (load order issue).
-- Also creates useful cross-cutting reporting views.
-- ============================================================

BEGIN;

-- encounter.department_id → hr.department (added in 02_emr before 03_hr existed)
DO $$ BEGIN
   IF NOT EXISTS (
      SELECT 1 FROM pg_constraint WHERE conname='encounter_department_id_fkey'
        AND conrelid='mcms_emr.encounter'::regclass
   ) THEN
     ALTER TABLE mcms_emr.encounter
       ADD CONSTRAINT encounter_department_id_fkey
       FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);
   END IF;
END$$;

-- drug_lot.purchase_order_id → erp.purchase_order
DO $$ BEGIN
   IF NOT EXISTS (
      SELECT 1 FROM pg_constraint WHERE conname='drug_lot_po_fkey'
        AND conrelid='mcms_rx.drug_lot'::regclass
   ) THEN
     ALTER TABLE mcms_rx.drug_lot
       ADD CONSTRAINT drug_lot_po_fkey
       FOREIGN KEY (purchase_order_id) REFERENCES mcms_erp.purchase_order(po_id);
   END IF;
END$$;

-- patient_queue.mrn must match patient.mrn
DO $$ BEGIN
   IF NOT EXISTS (
      SELECT 1 FROM pg_constraint WHERE conname='pq_mrn_fkey'
        AND conrelid='mcms_clinic.patient_queue'::regclass
   ) THEN
     ALTER TABLE mcms_clinic.patient_queue
       ADD CONSTRAINT pq_mrn_fkey
       FOREIGN KEY (mrn) REFERENCES mcms_emr.patient(mrn) ON DELETE CASCADE;
   END IF;
END$$;

-- dispensation.mrn matches patient.mrn
DO $$ BEGIN
   IF NOT EXISTS (
      SELECT 1 FROM pg_constraint WHERE conname='disp_mrn_fkey'
        AND conrelid='mcms_rx.dispensation'::regclass
   ) THEN
     ALTER TABLE mcms_rx.dispensation
       ADD CONSTRAINT disp_mrn_fkey
       FOREIGN KEY (mrn) REFERENCES mcms_emr.patient(mrn) ON DELETE CASCADE;
   END IF;
END$$;

-- invoice_line.source_table/source_id is intentionally loose (not FK'd) because it
-- points anywhere; we keep it as JSON-ish polymorphic.

COMMIT;
