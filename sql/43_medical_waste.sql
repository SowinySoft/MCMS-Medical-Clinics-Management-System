-- ============================================================
-- Feature: Medical Waste Records Management  (schema mcms_waste)
-- ============================================================
-- Cradle-to-grave clinical/medical waste tracking with quantity (kg)
-- and cost accounting so Finance can trace waste volume + disposal cost
-- per department / period.
--
--   waste_stream            - waste category reference + default cost rate
--   waste_container         - a physical bin/bag from an origin department
--   waste_collection        - a pickup event carrying the traced weight (kg)
--   waste_disposal_manifest - final disposal; total_cost is DB-COMPUTED
--                             (GENERATED ALWAYS) from weight x rate, never
--                             hand-entered (same pattern as billing.invoice.total)
--   waste_cost_allocation   - accounts bridge: rolls manifest cost/weight up
--                             to a department + period (+ optional cost centre)
--
-- RBAC: waste.read / waste.manage.
-- Idempotent (safe to re-run): IF NOT EXISTS + ON CONFLICT throughout.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS mcms_waste AUTHORIZATION postgres;

-- per-facility manifest number generator
CREATE SEQUENCE IF NOT EXISTS mcms_waste.manifest_no_seq AS bigint START WITH 1;

-- ----------------------------------------------------------- STREAM
CREATE TABLE IF NOT EXISTS mcms_waste.waste_stream (
  stream_id               bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  code                    text NOT NULL UNIQUE,
  name                    text NOT NULL,
  kind                    text NOT NULL
    CHECK (kind IN ('sharps','infectious','pathological','pharmaceutical',
                    'chemical','cytotoxic','radioactive','general')),
  color_code              text,
  hazard_class            text,
  default_disposal_method text,
  unit_cost_per_kg        numeric(12,4) NOT NULL DEFAULT 0
    CHECK (unit_cost_per_kg >= 0),
  currency                text NOT NULL DEFAULT 'SAR',
  is_active               boolean NOT NULL DEFAULT true,
  created_at              timestamp with time zone NOT NULL DEFAULT now(),
  updated_at              timestamp with time zone NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------- CONTAINER
CREATE TABLE IF NOT EXISTS mcms_waste.waste_container (
  container_id  bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  barcode       text NOT NULL UNIQUE,
  stream_id     bigint NOT NULL REFERENCES mcms_waste.waste_stream(stream_id),
  department_id bigint NOT NULL REFERENCES mcms_hr.department(department_id),
  capacity_kg   numeric(10,3) CHECK (capacity_kg IS NULL OR capacity_kg >= 0),
  status        text NOT NULL DEFAULT 'open'
    CHECK (status IN ('open','sealed','collected','disposed')),
  opened_at     timestamp with time zone NOT NULL DEFAULT now(),
  created_at    timestamp with time zone NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------- COLLECTION
CREATE TABLE IF NOT EXISTS mcms_waste.waste_collection (
  collection_id        bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  container_id         bigint NOT NULL REFERENCES mcms_waste.waste_container(container_id),
  weight_kg            numeric(10,3) NOT NULL CHECK (weight_kg >= 0),
  collected_by_user_id bigint,
  collection_datetime  timestamp with time zone NOT NULL DEFAULT now(),
  storage_location     text,
  created_at           timestamp with time zone NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------- DISPOSAL MANIFEST
CREATE TABLE IF NOT EXISTS mcms_waste.waste_disposal_manifest (
  manifest_id         bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  manifest_no         text NOT NULL UNIQUE,
  carrier_vendor      text,
  treatment_method    text
    CHECK (treatment_method IS NULL OR treatment_method IN
      ('autoclave','incineration','chemical','microwave','landfill','encapsulation','other')),
  disposal_datetime   timestamp with time zone NOT NULL DEFAULT now(),
  total_weight_kg     numeric(12,3) NOT NULL DEFAULT 0 CHECK (total_weight_kg >= 0),
  unit_cost_per_kg    numeric(12,4) NOT NULL DEFAULT 0 CHECK (unit_cost_per_kg >= 0),
  -- cost is DB-computed; the app must NOT insert/update this column.
  total_cost          numeric(16,4) GENERATED ALWAYS AS (total_weight_kg * unit_cost_per_kg) STORED,
  currency            text NOT NULL DEFAULT 'SAR',
  certificate_ref     text,
  certified_by_user_id bigint,
  status              text NOT NULL DEFAULT 'open'
    CHECK (status IN ('open','certified','cancelled')),
  created_at          timestamp with time zone NOT NULL DEFAULT now(),
  updated_at          timestamp with time zone NOT NULL DEFAULT now()
);

-- ----------------------------------------------------------- COST ALLOCATION (accounts bridge)
CREATE TABLE IF NOT EXISTS mcms_waste.waste_cost_allocation (
  allocation_id       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  manifest_id         bigint NOT NULL REFERENCES mcms_waste.waste_disposal_manifest(manifest_id),
  department_id       bigint NOT NULL REFERENCES mcms_hr.department(department_id),
  period_month        date NOT NULL,           -- first day of the accounting month
  allocated_weight_kg numeric(12,3) NOT NULL DEFAULT 0 CHECK (allocated_weight_kg >= 0),
  allocated_cost      numeric(16,4) NOT NULL DEFAULT 0 CHECK (allocated_cost >= 0),
  cost_center_code    text,                     -- soft link to GL/cost-centre (no dedicated table yet)
  created_at          timestamp with time zone NOT NULL DEFAULT now(),
  UNIQUE (manifest_id, department_id, period_month)
);

-- ----------------------------------------------------------- INDEXES
CREATE INDEX IF NOT EXISTS ix_wcontainer_stream   ON mcms_waste.waste_container (stream_id);
CREATE INDEX IF NOT EXISTS ix_wcontainer_dept     ON mcms_waste.waste_container (department_id);
CREATE INDEX IF NOT EXISTS ix_wcontainer_status   ON mcms_waste.waste_container (status);
CREATE INDEX IF NOT EXISTS ix_wcollection_cont    ON mcms_waste.waste_collection (container_id);
CREATE INDEX IF NOT EXISTS ix_wcollection_dt      ON mcms_waste.waste_collection (collection_datetime);
CREATE INDEX IF NOT EXISTS ix_wmanifest_status    ON mcms_waste.waste_disposal_manifest (status);
CREATE INDEX IF NOT EXISTS ix_wmanifest_dt        ON mcms_waste.waste_disposal_manifest (disposal_datetime);
CREATE INDEX IF NOT EXISTS ix_walloc_manifest     ON mcms_waste.waste_cost_allocation (manifest_id);
CREATE INDEX IF NOT EXISTS ix_walloc_dept         ON mcms_waste.waste_cost_allocation (department_id);
CREATE INDEX IF NOT EXISTS ix_walloc_period       ON mcms_waste.waste_cost_allocation (period_month);

-- ----------------------------------------------------------- RBAC seeds
INSERT INTO mcms_core.permission (code, description)
VALUES
  ('waste.read',   'View medical waste records, quantities and costs'),
  ('waste.manage', 'Create/edit medical waste records and disposal manifests')
ON CONFLICT (code) DO NOTHING;

-- read: nurse, reception, accountant, store_mgr, sysadmin
INSERT INTO mcms_core.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM mcms_core.role r, mcms_core.permission p
WHERE p.code = 'waste.read'
  AND r.code IN ('nurse','reception','accountant','store_mgr','sysadmin')
ON CONFLICT DO NOTHING;

-- manage: store_mgr + sysadmin (defaults), plus accountant (finance costing)
INSERT INTO mcms_core.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM mcms_core.role r, mcms_core.permission p
WHERE p.code = 'waste.manage'
  AND r.code IN ('store_mgr','sysadmin','accountant')
ON CONFLICT DO NOTHING;

-- ----------------------------------------------------------- Demo seed (idempotent)
-- Reference streams (so the table is navigable and reports have data).
INSERT INTO mcms_waste.waste_stream (code, name, kind, color_code, hazard_class, default_disposal_method, unit_cost_per_kg)
VALUES
  ('SHARPS', 'Sharps',              'sharps',        'yellow', 'UN3291', 'incineration', 3.5000),
  ('INFECT', 'Infectious',          'infectious',    'red',    'UN3291', 'autoclave',    2.2500),
  ('PHARMA', 'Pharmaceutical',      'pharmaceutical','white',  'UN3249', 'incineration', 4.0000),
  ('CYTO',   'Cytotoxic',           'cytotoxic',     'purple', 'UN3249', 'incineration', 6.5000),
  ('GEN',    'General (non-hazard)','general',        'black',  NULL,     'landfill',     0.4000)
ON CONFLICT (code) DO NOTHING;

-- A container in the first available department, one collection, one manifest,
-- and a cost allocation so the quantity->cost trace has real rows.
DO $$
DECLARE
  v_dept   bigint;
  v_stream bigint;
  v_cont   bigint;
  v_man    bigint;
BEGIN
  SELECT department_id INTO v_dept FROM mcms_hr.department ORDER BY department_id LIMIT 1;
  SELECT stream_id     INTO v_stream FROM mcms_waste.waste_stream WHERE code='SHARPS';
  IF v_dept IS NULL OR v_stream IS NULL THEN
    RETURN;  -- no departments seeded yet; skip demo rows
  END IF;

  IF NOT EXISTS (SELECT 1 FROM mcms_waste.waste_container WHERE barcode='WC-DEMO-0001') THEN
    INSERT INTO mcms_waste.waste_container (barcode, stream_id, department_id, capacity_kg, status)
    VALUES ('WC-DEMO-0001', v_stream, v_dept, 10.000, 'collected')
    RETURNING container_id INTO v_cont;

    INSERT INTO mcms_waste.waste_collection (container_id, weight_kg, collection_datetime, storage_location)
    VALUES (v_cont, 7.500, now(), 'Central Waste Store');

    INSERT INTO mcms_waste.waste_disposal_manifest
      (manifest_no, carrier_vendor, treatment_method, total_weight_kg, unit_cost_per_kg, certificate_ref, status)
    VALUES ('M' || to_char(now(),'YYYYMM') || '-' || lpad(nextval('mcms_waste.manifest_no_seq')::text, 6, '0'),
            'EnviroClean Ltd', 'incineration', 7.500, 3.5000, 'CERT-DEMO-0001', 'certified')
    RETURNING manifest_id INTO v_man;

    INSERT INTO mcms_waste.waste_cost_allocation
      (manifest_id, department_id, period_month, allocated_weight_kg, allocated_cost, cost_center_code)
    SELECT v_man, v_dept, date_trunc('month', now())::date, 7.500, total_cost, 'CC-WASTE'
    FROM mcms_waste.waste_disposal_manifest WHERE manifest_id = v_man;
  END IF;
END $$;
