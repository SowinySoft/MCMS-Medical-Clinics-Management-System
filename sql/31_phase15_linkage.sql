-- ============================================================
-- Phase 15: Systematic referral / linkage recommendations
-- Deterministic, offline rule engine that maps a clinical context
-- (source department and/or diagnosis code) to recommended target
-- departments for referral/linkage. Read-only recommendation surface
-- over mcms_emr.referral_linkage_rule; the actual referral write path
-- remains mcms_emr.referral.
-- ============================================================

CREATE TABLE IF NOT EXISTS mcms_emr.referral_linkage_rule (
    rule_id        BIGSERIAL PRIMARY KEY,
    from_department_id BIGINT REFERENCES mcms_hr.department(department_id) ON DELETE RESTRICT,
    diagnosis_code TEXT,
    code_system    TEXT,
    to_department_id   BIGINT NOT NULL REFERENCES mcms_hr.department(department_id) ON DELETE RESTRICT,
    priority       INTEGER NOT NULL DEFAULT 100,
    rationale      TEXT,
    is_active      BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (from_department_id, diagnosis_code, code_system, to_department_id)
);

-- helper: resolve a department_id by its stable code (idempotent vs row id)
-- Seed systematic rules: diagnosis (ICD-10) -> target specialty
INSERT INTO mcms_emr.referral_linkage_rule
    (diagnosis_code, code_system, to_department_id, priority, rationale)
SELECT 'I21.9', 'icd10', d.department_id, 10, 'Acute myocardial infarction requires cardiology review'
FROM mcms_hr.department d WHERE d.code = 'CARD-DIS'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (diagnosis_code, code_system, to_department_id, priority, rationale)
SELECT 'I10', 'icd10', d.department_id, 20, 'Essential hypertension -> cardiology / cardiovascular'
FROM mcms_hr.department d WHERE d.code = 'CARD-DIS'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (diagnosis_code, code_system, to_department_id, priority, rationale)
SELECT 'E78.5', 'icd10', d.department_id, 30, 'Hypercholesterolaemia -> cardiovascular risk clinic'
FROM mcms_hr.department d WHERE d.code = 'CARD-DIS'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (diagnosis_code, code_system, to_department_id, priority, rationale)
SELECT 'C50.9', 'icd10', d.department_id, 10, 'Breast malignancy -> clinical oncology & nuclear medicine'
FROM mcms_hr.department d WHERE d.code = 'ONC-NM'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (diagnosis_code, code_system, to_department_id, priority, rationale)
SELECT 'C50.9', 'icd10', d.department_id, 20, 'Breast malignancy -> oncology unit'
FROM mcms_hr.department d WHERE d.code = 'ONC-UNIT'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (diagnosis_code, code_system, to_department_id, priority, rationale)
SELECT 'E11.9', 'icd10', d.department_id, 10, 'Type 2 diabetes -> general internal medicine'
FROM mcms_hr.department d WHERE d.code = 'MED-GIM'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (diagnosis_code, code_system, to_department_id, priority, rationale)
SELECT 'J20.9', 'icd10', d.department_id, 10, 'Acute bronchitis -> chest diseases'
FROM mcms_hr.department d WHERE d.code = 'CHEST'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (diagnosis_code, code_system, to_department_id, priority, rationale)
SELECT 'J00', 'icd10', d.department_id, 20, 'Acute nasopharyngitis / URTI -> chest diseases'
FROM mcms_hr.department d WHERE d.code = 'CHEST'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (diagnosis_code, code_system, to_department_id, priority, rationale)
SELECT 'A09', 'icd10', d.department_id, 10, 'Infectious gastroenteritis -> general internal medicine'
FROM mcms_hr.department d WHERE d.code = 'MED-GIM'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (diagnosis_code, code_system, to_department_id, priority, rationale)
SELECT 'I63.9', 'icd10', d.department_id, 10, 'Cerebral infarction -> neurology & psychiatry'
FROM mcms_hr.department d WHERE d.code = 'NEU-PSY'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (diagnosis_code, code_system, to_department_id, priority, rationale)
SELECT 'I60.9', 'icd10', d.department_id, 10, 'Subarachnoid haemorrhage -> neurology & psychiatry'
FROM mcms_hr.department d WHERE d.code = 'NEU-PSY'
ON CONFLICT DO NOTHING;

-- Seed systematic rules: source department -> target specialty (dept-only)
INSERT INTO mcms_emr.referral_linkage_rule
    (from_department_id, to_department_id, priority, rationale)
SELECT f.department_id, t.department_id, 10, 'Outpatient workup -> diagnostic radiology for imaging'
FROM mcms_hr.department f, mcms_hr.department t
WHERE f.code = 'CLIN-GEN' AND t.code = 'RAD-DX'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (from_department_id, to_department_id, priority, rationale)
SELECT f.department_id, t.department_id, 10, 'Imaging study -> nuclear medicine for oncologic scans'
FROM mcms_hr.department f, mcms_hr.department t
WHERE f.code = 'RAD-MAIN' AND t.code = 'ONC-NM'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (from_department_id, to_department_id, priority, rationale)
SELECT f.department_id, t.department_id, 20, 'Pathology finding -> oncology review'
FROM mcms_hr.department f, mcms_hr.department t
WHERE f.code = 'LAB-PATH' AND t.code = 'ONC-UNIT'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (from_department_id, to_department_id, priority, rationale)
SELECT f.department_id, t.department_id, 30, 'Suspicious skin lesion -> oncology review'
FROM mcms_hr.department f, mcms_hr.department t
WHERE f.code = 'DERM-VEN' AND t.code = 'ONC-UNIT'
ON CONFLICT DO NOTHING;

INSERT INTO mcms_emr.referral_linkage_rule
    (from_department_id, to_department_id, priority, rationale)
SELECT f.department_id, t.department_id, 10, 'Emergency triage -> cardiology for acute cardiac cases'
FROM mcms_hr.department f, mcms_hr.department t
WHERE f.code = 'ED-MAIN' AND t.code = 'CARD-DIS'
ON CONFLICT DO NOTHING;
