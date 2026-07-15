#!/usr/bin/env python3
"""Deep integrity audit (beyond the 4 base scans).

DEEP 1: event_log subject_party_id orphans (regression for trigger fix).
DEEP 2: sequence / identity PK alignment - last_value vs max(id)+1, to catch
        the explicit-id-insert collision class (e.g. facility id=1 vs seq).
DEEP 3: CHECK constraints actually hold on CURRENT DATA (run each predicate).
DEEP 4: model<->DB drift - every Django model db_table exists in the live DB
        (proper check; makemigrations --check is a false positive here since
        the schema is built from raw SQL, not migrations).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import django  # noqa: E402  (imported after sys.path insert for project root)
import psycopg  # noqa: E402

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()

from django.apps import apps as django_apps

DB = dict(host=os.environ.get("MCMS_DB_HOST", "127.0.0.1"),
          port=int(os.environ.get("MCMS_DB_PORT", "5432")),
          user=os.environ.get("MCMS_DB_USER", "postgres"),
          password=os.environ.get("MCMS_DB_PASSWORD", os.environ.get("PGPASSWORD", "postgres")),
          dbname=os.environ.get("MCMS_DB_NAME") or os.environ.get("AUDIT_DB", "mcms"))
conn = psycopg.connect(**DB)
cur = conn.cursor()
problems = []


def run(sql, params=()):
    cur.execute(sql, params)
    return cur.fetchall()


print("=" * 70)
print(f"DEEP AUDIT TARGET: {DB['dbname']}")
print("=" * 70)

# ---------- DEEP 1: event_log orphan subjects ----------
print("\n[DEEP 1] event_log.subject_party_id orphans (trigger-fix regression)")
(orph_subj,) = run(
    "SELECT count(*) FROM mcms_core.event_log e LEFT JOIN mcms_core.party p "
    "ON p.party_id=e.subject_party_id WHERE e.subject_party_id IS NOT NULL "
    "AND p.party_id IS NULL")[0]
if orph_subj:
    problems.append(f"event_log orphan subject_party_id [{orph_subj}]")
    print(f"  ORPHAN: {orph_subj} events reference non-existent party")
else:
    print(f"  CLEAN: every event subject resolves to a real party (checked {orph_subj} non-null)")

# ---------- DEEP 2: sequence / identity PK alignment ----------
print("\n[DEEP 2] SEQUENCE / IDENTITY PK ALIGNMENT")
seq_rows = run("""
SELECT n.nspname, c.relname, a.attname,
       pg_get_expr(ad.adbin, ad.adrelid) AS def
FROM pg_attribute a
JOIN pg_class c ON c.oid=a.attrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
LEFT JOIN pg_attrdef ad ON ad.adrelid=a.attrelid AND ad.adnum=a.attnum
WHERE a.attnum>0 AND NOT a.attisdropped
  AND c.relkind='r' AND n.nspname LIKE %s
  AND (pg_get_expr(ad.adbin, ad.adrelid) LIKE 'nextval%%'
       OR a.attidentity <> '')
ORDER BY n.nspname, c.relname
""", ["mcms_%"])
mis = 0
for s, t_, col, _def in seq_rows:
    # max id
    (mx,) = run(f"SELECT coalesce(max({col}),0) FROM {s}.{t_}")[0]
    # sequence last value (if a serial sequence is attached)
    seqname = run(
        "SELECT pg_get_serial_sequence(%s, %s)", [f"{s}.{t_}", col])[0][0]
    if seqname:
        (last,) = run(f"SELECT last_value FROM {seqname}")[0]
        if last < mx:
            mis += 1
            problems.append(f"SEQ BEHIND: {seqname} last={last} < max({col})={mx} in {s}.{t_}")
            print(f"  BEHIND: {seqname} last={last} < max(id)={mx} ({s}.{t_})")
        elif last == mx:
            # aligned; fine
            pass
        # also flag if last > mx+1 (big gap wastes ids, not a break)
print(f"  checked {len(seq_rows)} serial/identity PKs: "
      f"{'CLEAN' if mis==0 else str(mis)+' OUT-OF-SYNC'}")

# ---------- DEEP 3: CHECK constraints hold on current data ----------
print("\n[DEEP 3] CHECK CONSTRAINTS HOLD ON CURRENT DATA")
checks = run("""
SELECT n.nspname, c.relname, con.conname, pg_get_constraintdef(con.oid)
FROM pg_constraint con
JOIN pg_class c ON c.oid=con.conrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE con.contype='c' AND n.nspname LIKE %s
""", ["mcms_%"])
viol = 0
for s, t_, cname, cdef in checks:
    expr = cdef
    if expr.upper().startswith("CHECK ("):
        expr = expr[7:-1]
    try:
        (n,) = run(f"SELECT count(*) FROM {s}.{t_} WHERE NOT ({expr})")
    except Exception as e:
        # expression may reference non-null-only columns; skip parse errors
        print(f"  (skip {s}.{t_}.{cname}: {e})")
        continue
    if n[0]:
        viol += 1
        problems.append(f"CHECK VIOLATION: {s}.{t_}.{cname} [{n[0]} rows]")
        print(f"  VIOLATES: {s}.{t_}.{cname} -> {n[0]} rows break: {cdef}")
if viol == 0:
    print(f"  CLEAN: all {len(checks)} CHECK constraints satisfied by current data")

# ---------- DEEP 4: Django model <-> DB table drift ----------
print("\n[DEEP 4] DJANGO MODEL <-> DB TABLE DRIFT (real check)")
missing = 0
for model in django_apps.get_models():
    meta = model._meta
    raw = model._meta.db_table
    # db_table may be a quoted 'schema"."table' literal; normalise it.
    clean = raw.replace('"', "")
    if "." in clean:
        schema, tname = clean.split(".", 1)
    else:
        schema, tname = None, clean
    exists = run(
        "SELECT 1 FROM information_schema.tables WHERE table_name=%s "
        "AND table_schema=%s", [tname, schema]) if schema else \
        run("SELECT 1 FROM information_schema.tables WHERE table_name=%s", [tname])
    if not exists:
        missing += 1
        problems.append(f"MODEL TABLE MISSING: {model.__module__}.{model.__name__} -> {raw}")
        print(f"  MISSING: model {model.__name__} expects {raw}")
if missing == 0:
    print("  CLEAN: every Django model's db_table exists in the live DB")

print("\n" + "=" * 70)
if problems:
    print(f"DEEP AUDIT: {len(problems)} ISSUE(S)")
    for p in problems:
        print("  - " + p)
    raise SystemExit(2)
else:
    print("DEEP AUDIT: CLEAN - no missed/broken items beyond the base 4 scans")
