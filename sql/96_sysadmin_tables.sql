-- SysAdmin control-panel backing tables.
-- backup_log : records every pg_dump backup attempt/result.
-- system_flag: key/value flags (e.g. maintenance_mode) the panel can toggle.
CREATE TABLE IF NOT EXISTS mcms_core.backup_log (
    backup_id   BIGSERIAL PRIMARY KEY,
    started_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    finished_at TIMESTAMPTZ,
    filename    TEXT,
    size_bytes  BIGINT,
    status      TEXT NOT NULL DEFAULT 'running',   -- running|ok|error
    detail      TEXT,
    triggered_by TEXT
);

CREATE TABLE IF NOT EXISTS mcms_core.system_flag (
    flag        TEXT PRIMARY KEY,
    value       TEXT NOT NULL,
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO mcms_core.system_flag (flag, value) VALUES
    ('maintenance_mode', 'false'),
    ('last_schema_sync', 'never')
ON CONFLICT (flag) DO NOTHING;
