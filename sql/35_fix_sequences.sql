-- ============================================================
-- Integrity cleanup #2: advance sequences that fell behind max(id)
-- ============================================================
-- Tables seeded by bulk/explicit-id inserts (and Django fixtures) populate the
-- PK with explicit values, which does NOT advance the owning sequence. The
-- next application INSERT using nextval() would collide (duplicate key),
-- breaking writes. Re-sync each affected sequence to max(id). Idempotent and
-- safe: setval to max(id) means the next nextval() returns max(id)+1. Empty
-- tables (max=0) are set to 1 so the sequence stays in its valid 1.. range.
-- ============================================================

DO $$
DECLARE
  r RECORD;
  mx BIGINT;
BEGIN
  FOR r IN
    SELECT n.nspname AS s, c.relname AS t, a.attname AS col,
           pg_get_serial_sequence(n.nspname||'.'||c.relname, a.attname) AS seq
    FROM pg_attribute a
    JOIN pg_class c ON c.oid = a.attrelid
    JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE a.attnum > 0 AND NOT a.attisdropped
      AND c.relkind = 'r' AND n.nspname LIKE 'mcms_%'
      AND pg_get_serial_sequence(n.nspname||'.'||c.relname, a.attname) IS NOT NULL
  LOOP
    EXECUTE format('SELECT coalesce(max(%I),0) FROM %I.%I', r.col, r.s, r.t)
      INTO mx;
    -- GREATEST(mx,1): empty tables keep the sequence valid at 1 (next nextval=2).
    EXECUTE format('SELECT setval(%L, %L)', r.seq, GREATEST(mx, 1));
  END LOOP;
END $$;
