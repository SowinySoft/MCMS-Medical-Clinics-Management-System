-- ============================================================
-- Integrity cleanup: drop redundant duplicate indexes
-- ============================================================
-- Each pair below is a UNIQUE constraint (whose backing index enforces
-- uniqueness + serves lookups) plus a separately-created standalone index on
-- the SAME columns. The standalone index is pure redundancy (extra write/
-- storage cost, no added guarantee). The UNIQUE constraint remains and still
-- provides the index. Re-run safe (IF EXISTS).
-- ============================================================

DROP INDEX IF EXISTS mcms_emr.patient_mrn_idx;
DROP INDEX IF EXISTS mcms_erp.supplier_party_id_idx;
DROP INDEX IF EXISTS mcms_terminology.ix_concept_sys_code;
