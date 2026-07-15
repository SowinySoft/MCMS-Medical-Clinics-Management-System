-- ============================================================
-- Phase 8: Terminology service
-- Single canonical source of truth for clinical codes across systems
-- (LOINC, SNOMED CT, RxNorm, ATC, CPT, ICD-10). Seeded from the
-- codes already present in the domain catalogs so validation/resolve
-- works against REAL data (no external multi-GB distribution files).
-- Idempotent; safe to re-run.
-- ============================================================

CREATE SCHEMA IF NOT EXISTS mcms_terminology;

-- Canonical concept: one row per (system, code).
CREATE TABLE IF NOT EXISTS mcms_terminology.concept (
    concept_id   bigserial PRIMARY KEY,
    code_system  text NOT NULL,                      -- 'loinc','snomed','rxnorm','atc','cpt','icd10'
    code         text NOT NULL,
    display      text NOT NULL,
    display_ar   text,
    synonyms     text,                                -- pipe-separated alt terms
    source       text,                                -- where the concept came from
    facility_id  bigint NOT NULL DEFAULT 1,           -- Phase 6 multi-tenancy
    created_at   timestamptz NOT NULL DEFAULT now(),
    UNIQUE (code_system, code)
);
CREATE INDEX IF NOT EXISTS ix_concept_display ON mcms_terminology.concept (code_system, display text_pattern_ops);

-- Backfill from existing catalog columns (only where a code is present).
-- LOINC from the lab test catalog (display = test name).
INSERT INTO mcms_terminology.concept (code_system, code, display, source)
SELECT 'loinc', t.loinc_code, t.name, 'mcms_lab.test_catalog'
FROM mcms_lab.test_catalog t
WHERE t.loinc_code IS NOT NULL AND t.loinc_code <> ''
ON CONFLICT (code_system, code) DO NOTHING;

-- SNOMED CT from the radiology exam catalog.
INSERT INTO mcms_terminology.concept (code_system, code, display, source)
SELECT 'snomed', e.snomed_code, e.name, 'mcms_rad.exam_catalog'
FROM mcms_rad.exam_catalog e
WHERE e.snomed_code IS NOT NULL AND e.snomed_code <> ''
ON CONFLICT (code_system, code) DO NOTHING;

-- RxNorm + ATC from the drug item catalog.
INSERT INTO mcms_terminology.concept (code_system, code, display, source)
SELECT 'rxnorm', d.rxnorm_code, COALESCE(d.generic_name, d.brand_name), 'mcms_rx.drug_item'
FROM mcms_rx.drug_item d
WHERE d.rxnorm_code IS NOT NULL AND d.rxnorm_code <> ''
ON CONFLICT (code_system, code) DO NOTHING;

INSERT INTO mcms_terminology.concept (code_system, code, display, source)
SELECT 'atc', d.atc_code, COALESCE(d.generic_name, d.brand_name), 'mcms_rx.drug_item'
FROM mcms_rx.drug_item d
WHERE d.atc_code IS NOT NULL AND d.atc_code <> ''
ON CONFLICT (code_system, code) DO NOTHING;

-- CPT from the surgical procedure catalog.
INSERT INTO mcms_terminology.concept (code_system, code, display, source)
SELECT 'cpt', p.cpt_code, p.name, 'mcms_surgical.procedure_catalog'
FROM mcms_surgical.procedure_catalog p
WHERE p.cpt_code IS NOT NULL AND p.cpt_code <> ''
ON CONFLICT (code_system, code) DO NOTHING;

-- ICD-10 from the curated lookup table (already namespaced 'icd10').
INSERT INTO mcms_terminology.concept (code_system, code, display, display_ar, source)
SELECT 'icd10', l.code, l.label, l.label_ar, 'mcms_core.lookup'
FROM mcms_core.lookup l
WHERE l.namespace = 'icd10' AND l.code IS NOT NULL AND l.code <> ''
ON CONFLICT (code_system, code) DO NOTHING;
