-- Generic audit/event trigger so EVERY domain write emits a row to
-- mcms_core.event_log, making the WebSocket live feed truthful for all 89
-- tables (23 already have dedicated fn_*_event triggers; this covers the rest).
-- After INSERT/UPDATE/DELETE on any domain table without a dedicated event
-- trigger, write a minimal event row the consumer can stream.

-- Extend event_kind enum with generic CRUD labels so the fallback audit
-- trigger can emit semantically-correct kinds (the dedicated triggers use
-- specific clinical labels; this covers the remaining 66 tables).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid=e.enumtypid
    WHERE t.typname='event_kind' AND e.enumlabel='create'
  ) THEN
    ALTER TYPE mcms_core.event_kind ADD VALUE IF NOT EXISTS 'create';
    ALTER TYPE mcms_core.event_kind ADD VALUE IF NOT EXISTS 'update';
    ALTER TYPE mcms_core.event_kind ADD VALUE IF NOT EXISTS 'delete';
  END IF;
END $$;

CREATE OR REPLACE FUNCTION mcms_core.fn_generic_audit()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
  v_kind   mcms_core.event_kind;
  v_schema text := TG_TABLE_SCHEMA;
  v_table  text := TG_TABLE_NAME;
  v_row    jsonb;
  v_id     bigint := NULL;
  k        text;
BEGIN
  v_kind := CASE TG_OP
    WHEN 'INSERT' THEN 'create'::mcms_core.event_kind
    WHEN 'UPDATE' THEN 'update'::mcms_core.event_kind
    WHEN 'DELETE' THEN 'delete'::mcms_core.event_kind
    ELSE 'audit_note'::mcms_core.event_kind
  END;

  v_row := CASE TG_OP WHEN 'DELETE' THEN to_jsonb(OLD) ELSE to_jsonb(NEW) END;

  -- derive the PK value generically, preferring the real primary key.
  -- Guard every cast: only treat a key as an id when its JSON value is an
  -- integer string, so boolean/text columns (e.g. is_paid) never break the
  -- bigint cast. (A bare to_jsonb(NEW)->>'is_paid' is "false", which is not
  -- a valid bigint and used to abort the whole trigger on tables like
  -- mcms_hr.payroll_item.)
  IF v_row ? 'id' AND v_row->>'id' ~ '^[0-9]+$' THEN
    v_id := (v_row->>'id')::bigint;
  ELSIF v_row ? (v_table || '_id') AND v_row->>(v_table || '_id') ~ '^[0-9]+$' THEN
    v_id := (v_row->>(v_table || '_id'))::bigint;
  ELSE
    FOR k IN SELECT jsonb_object_keys(v_row) LOOP
      IF k LIKE '%_id' AND v_row->>k ~ '^[0-9]+$' THEN
        v_id := (v_row->>k)::bigint;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  INSERT INTO mcms_core.event_log
    (seq, occurred_at, kind, severity, source_schema, source_table, source_id, payload, channel)
  VALUES (
    nextval('mcms_core.event_log_seq'),
    now(),
    v_kind,
    'info'::mcms_core.event_severity,
    v_schema,
    v_table,
    v_id,
    v_row,
    'db-trigger'
  );
  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Attach to every domain table that does NOT already have a dedicated event trigger.
DO $$
DECLARE
  r record;
  tg text;
BEGIN
  FOR r IN
    SELECT n.nspname AS s, t.relname AS t
    FROM pg_class t JOIN pg_namespace n ON n.oid = t.relnamespace
    WHERE n.nspname LIKE 'mcms_%' AND t.relkind = 'r'
      AND NOT (n.nspname = 'mcms_core' AND t.relname = 'event_log')
      AND NOT EXISTS (
        SELECT 1 FROM pg_trigger tg
        WHERE tg.tgrelid = t.oid AND NOT tg.tgisinternal
          AND tg.tgfoid::regproc::text LIKE '%fn_%event%'
      )
  LOOP
    tg := 'trg_' || r.s || '_' || r.t || '_audit';
    EXECUTE format('DROP TRIGGER IF EXISTS %I ON %I.%I;', tg, r.s, r.t);
    EXECUTE format(
      'CREATE TRIGGER %I AFTER INSERT OR UPDATE OR DELETE ON %I.%I
       FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();',
      tg, r.s, r.t
    );
  END LOOP;
END $$;
