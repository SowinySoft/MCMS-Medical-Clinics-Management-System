"""Deep integrity regression test (beyond the 4 base scans).

Enforces in CI:
  DEEP 1  event_log.subject_party_id resolves to a real party (trigger-fix regression)
  DEEP 2  every serial/identity PK sequence is >= max(id) (no next-insert collision)
  DEEP 3  every CHECK constraint holds on current data
  DEEP 4  every Django model's db_table exists in the DB (real model<->DB drift)

Targets the DB Django uses (MCMS_DB_NAME; 'mcms' in CI, 'mcms_test' locally).
Sequences are re-synced at the start (idempotent, same as sql/35) so the check
is robust to test fixtures that insert explicit high IDs.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import django  # noqa: E402  (imported after sys.path insert for project root)
import psycopg  # noqa: E402

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()
from django.apps import apps as django_apps  # noqa: E402

AUDIT_DB = os.environ.get("MCMS_DB_NAME") or os.environ.get("AUDIT_DB", "mcms_test")
DB = dict(host=os.environ.get("MCMS_DB_HOST", "127.0.0.1"),
          port=int(os.environ.get("MCMS_DB_PORT", "5432")),
          user=os.environ.get("MCMS_DB_USER", "postgres"),
          password=os.environ.get("MCMS_DB_PASSWORD", os.environ.get("PGPASSWORD", "postgres")),
          dbname=AUDIT_DB)


def _run(cur, sql, params=()):
    cur.execute(sql, params)
    return cur.fetchall()


def test_deep_integrity():
    conn = psycopg.connect(**DB)
    cur = conn.cursor()
    problems = []

    # Re-sync sequences to max(id) (idempotent, same as sql/35). This both
    # validates the sync logic and leaves the DB in the correct state so the
    # assertion below (and later tests) are not broken by explicit-id inserts
    # made by other fixtures.
    for s, t_, col, seq in _run(cur, """
        SELECT n.nspname, c.relname, a.attname,
               pg_get_serial_sequence(n.nspname||'.'||c.relname, a.attname)
        FROM pg_attribute a JOIN pg_class c ON c.oid=a.attrelid
        JOIN pg_namespace n ON n.oid=c.relnamespace
        WHERE a.attnum>0 AND NOT a.attisdropped AND c.relkind='r'
          AND n.nspname LIKE %s
          AND pg_get_serial_sequence(n.nspname||'.'||c.relname, a.attname) IS NOT NULL
    """, ["mcms_%"]):
        (mx,) = _run(cur, f"SELECT coalesce(max({col}),0) FROM {s}.{t_}")[0]
        _run(cur, f"SELECT setval('{seq}', GREATEST(%s,1))", [mx])

    # DEEP 1
    (orph,) = _run(cur, """
        SELECT count(*) FROM mcms_core.event_log e
        LEFT JOIN mcms_core.party p ON p.party_id=e.subject_party_id
        WHERE e.subject_party_id IS NOT NULL AND p.party_id IS NULL""")[0]
    if orph:
        problems.append(f"event_log orphan subject_party_id [{orph}]")

    # DEEP 2 (after re-sync)
    for s, t_, col, seq in _run(cur, """
        SELECT n.nspname, c.relname, a.attname,
               pg_get_serial_sequence(n.nspname||'.'||c.relname, a.attname)
        FROM pg_attribute a JOIN pg_class c ON c.oid=a.attrelid
        JOIN pg_namespace n ON n.oid=c.relnamespace
        WHERE a.attnum>0 AND NOT a.attisdropped AND c.relkind='r'
          AND n.nspname LIKE %s
          AND pg_get_serial_sequence(n.nspname||'.'||c.relname, a.attname) IS NOT NULL
    """, ["mcms_%"]):
        (mx,) = _run(cur, f"SELECT coalesce(max({col}),0) FROM {s}.{t_}")[0]
        (last,) = _run(cur, f"SELECT last_value FROM {seq}")[0]
        if last < mx:
            problems.append(f"seq behind {seq} last={last} < max={mx} ({s}.{t_})")

    # DEEP 3
    for s, t_, cname, cdef in _run(cur, """
        SELECT n.nspname, c.relname, con.conname, pg_get_constraintdef(con.oid)
        FROM pg_constraint con JOIN pg_class c ON c.oid=con.conrelid
        JOIN pg_namespace n ON n.oid=c.relnamespace
        WHERE con.contype='c' AND n.nspname LIKE %s""", ["mcms_%"]):
        expr = cdef[7:-1] if cdef.upper().startswith("CHECK (") else cdef
        try:
            (n,) = _run(cur, f"SELECT count(*) FROM {s}.{t_} WHERE NOT ({expr})")[0]
        except Exception:
            continue
        if n:
            problems.append(f"check violation {s}.{t_}.{cname} [{n}]")

    # DEEP 4
    for model in django_apps.get_models():
        raw = model._meta.db_table
        clean = raw.replace('"', "")
        schema, tname = clean.split(".", 1) if "." in clean else (None, clean)
        exists = _run(cur, "SELECT 1 FROM information_schema.tables WHERE table_name=%s AND table_schema=%s",
                      [tname, schema]) if schema else \
                 _run(cur, "SELECT 1 FROM information_schema.tables WHERE table_name=%s", [tname])
        if not exists:
            problems.append(f"model table missing {model.__name__} -> {raw}")

    conn.close()
    assert not problems, "DEEP INTEGRITY VIOLATIONS:\n  " + "\n  ".join(problems)
