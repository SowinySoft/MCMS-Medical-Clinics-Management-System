-- ============================================================
-- Phase 5 (part 1): ensure the 'patient' user_role enum value exists.
--
-- This is split from 22_phase5.sql on purpose. load_sql.py (used by the
-- miget deploy) executes each SQL file as ONE transaction via psycopg's
-- raw exec_, whereas psql (used by the test-DB builder) auto-commits per
-- statement. A freshly-added enum value cannot be USED inside the same
-- transaction that added it ("unsafe use of new value ... must be committed
-- before they can be used"). By giving the ADD VALUE its own file it commits
-- in its own transaction, so 22_phase5.sql's INSERT 'patient' succeeds
-- whether or not the value already existed (mcms_schema.sql seeds it on a
-- fresh DB; this is a safe no-op there).
-- ============================================================

-- patient user_role so a patient can log in with a scoped role
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid=e.enumtypid
    WHERE t.typname='user_role' AND e.enumlabel='patient'
  ) THEN
    ALTER TYPE mcms_core.user_role ADD VALUE IF NOT EXISTS 'patient';
  END IF;
END $$;
