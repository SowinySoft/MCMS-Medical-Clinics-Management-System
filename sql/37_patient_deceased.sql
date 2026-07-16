-- ============================================================
-- Phase 17 / Step 0: close patient.is_deceased drift
-- ============================================================
-- The Django Patient model (apps/emr/models.py) expects is_deceased,
-- but the live mcms_emr.patient table does not have it yet -> drift.
-- Add the column so death state is expressible and the lifecycle
-- guard (38) can react to it.
-- ============================================================

ALTER TABLE mcms_emr.patient
  ADD COLUMN IF NOT EXISTS is_deceased boolean NOT NULL DEFAULT false;

COMMENT ON COLUMN mcms_emr.patient.is_deceased
  IS 'Lifecycle flag set true when a death certificate is issued (immutable once set).';
