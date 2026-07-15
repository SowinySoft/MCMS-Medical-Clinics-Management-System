-- ============================================================
-- Phase 16: Cross-facility linkage + learned-from-history
-- Extends Phase 15 systematic linkage with:
--   1) to_facility_id on referral_linkage_rule -> cross-facility recs
--   2) seeds facilities (live mcms had only DEFAULT) so referrals +
--      facility recommendations are possible
--   3) learned mode (handled in app) aggregates accepted/completed
--      historical referrals to rank targets by real acceptance frequency.
-- Idempotent: facility inserts keyed on code; backfill joined on code.
-- ============================================================

-- org (idempotent)
INSERT INTO mcms_core.organization (organization_id, code, name_en, name_ar)
VALUES (1, 'HQ', 'National HQ', 'المقر الوطني')
ON CONFLICT (organization_id) DO NOTHING;
-- explicit ids avoid colliding with the DEFAULT facility (id 1) that
-- 23_multitenancy seeds (and which does not advance the serial sequence).
INSERT INTO mcms_core.facility (facility_id, organization_id, code, name_en, name_ar)
VALUES
    (2, 1, 'TERT', 'National Tertiary Centre', 'المركز الوطني التخصصي'),
    (3, 1, 'DIST', 'District General Hospital',  'مستشفى المنطقة العام'),
    (4, 1, 'CANC', 'Regional Cancer Centre',     'المركز الإقليمي للأورام')
ON CONFLICT (code) DO NOTHING;

-- column for cross-facility recommendation
ALTER TABLE mcms_emr.referral_linkage_rule
    ADD COLUMN IF NOT EXISTS to_facility_id BIGINT
    REFERENCES mcms_core.facility(facility_id) ON DELETE RESTRICT;

-- reset then backfill to_facility_id by joining on facility CODE
UPDATE mcms_emr.referral_linkage_rule SET to_facility_id = NULL;
UPDATE mcms_emr.referral_linkage_rule r
SET to_facility_id = f.facility_id
FROM mcms_hr.department d, mcms_core.facility f
WHERE d.department_id = r.to_department_id
  AND f.code = CASE WHEN d.code IN ('ONC-NM', 'ONC-UNIT') THEN 'CANC' ELSE 'TERT' END;

-- explicit cross-facility rule: district internal medicine -> tertiary cardio
INSERT INTO mcms_emr.referral_linkage_rule
    (from_department_id, to_department_id, to_facility_id, priority, rationale)
SELECT f.department_id, t.department_id, tf.facility_id, 5,
       'Cross-facility: district internal medicine -> tertiary cardiology'
FROM mcms_hr.department f, mcms_hr.department t, mcms_core.facility tf
WHERE f.code = 'MED-GIM' AND t.code = 'CARD-DIS' AND tf.code = 'TERT'
ON CONFLICT DO NOTHING;
