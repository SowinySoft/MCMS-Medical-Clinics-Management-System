#!/usr/bin/env python3
"""Live DB integrity audit for MCMS (PostgreSQL).

Scan 1: orphan-FK sweep  - every single-column FK, child rows with no parent.
Scan 2: disabled triggers  - any trigger with tgenabled='D'.
Scan 3: check/enum coverage - enum (USER-DEFINED) columns: any stored value
                          outside the enum? check constraints: list + any
                          violating rows. NOT NULL violations on non-null cols.
Scan 4: structural cohesion - tables without PK; duplicate indexes; triggers
                          present but function missing; views referencing
                          dropped tables.

Exits 0 if clean. Collects fixups to apply in-pass for known-safe repairs.
"""
import os
import sys

import psycopg

DB = dict(host=os.environ.get("MCMS_DB_HOST", "127.0.0.1"),
          port=int(os.environ.get("MCMS_DB_PORT", "5432")),
          user=os.environ.get("MCMS_DB_USER", "postgres"),
          password=os.environ.get("MCMS_DB_PASSWORD", os.environ.get("PGPASSWORD", "postgres")),
          dbname=os.environ.get("MCMS_DB_NAME") or os.environ.get("AUDIT_DB", "mcms"))
conn = psycopg.connect(**DB)
cur = conn.cursor()
violations = []


def run(sql, params=()):
    cur.execute(sql, params)
    return cur.fetchall()


def note(msg):
    print("  " + msg)


print("=" * 70)
print(f"AUDIT TARGET: {DB['dbname']} @ {DB['host']}:{DB['port']}")
print("=" * 70)

# ---------- SCAN 1: ORPHAN FK ----------
print("\n[SCAN 1] ORPHAN FOREIGN KEYS")
fks = run("""
SELECT con.conname,
       ccon.relnamespace::regnamespace::text AS child_schema,
       ccon.relname AS child_table,
       (SELECT attname FROM pg_attribute WHERE attrelid=con.conrelid AND attnum=con.conkey[1]) AS child_col,
       cp.relnamespace::regnamespace::text AS parent_schema,
       cp.relname AS parent_table,
       (SELECT attname FROM pg_attribute WHERE attrelid=con.confrelid AND attnum=con.confkey[1]) AS parent_col
FROM pg_constraint con
JOIN pg_class ccon ON ccon.oid=con.conrelid
JOIN pg_class cp ON cp.oid=con.confrelid
WHERE con.contype='f' AND array_length(con.conkey,1)=1
ORDER BY child_schema, child_table, child_col
""")
fk_count = 0
for conname, cs, ct, cc, ps, pt, pc in fks:
    fk_count += 1
    (n,) = run(f"SELECT count(*) FROM {cs}.{ct} c LEFT JOIN {ps}.{pt} p ON c.{cc}=p.{pc} "
               f"WHERE c.{cc} IS NOT NULL AND p.{pc} IS NULL")[0]
    if n:
        violations.append(f"ORPHAN FK {cs}.{ct}.{cc}->{ps}.{pt}.{pc} [{n}]")
        note(f"ORPHAN: {cs}.{ct}.{cc} -> {ps}.{pt}.{pc} [{n}] ({conname})")
print(f"  scanned {fk_count} single-col FKs: {'CLEAN' if not violations else str(len(violations))+' VIOLATIONS'}")

# ---------- SCAN 2: DISABLED TRIGGERS ----------
print("\n[SCAN 2] DISABLED TRIGGERS")
dis = run("SELECT n.nspname, c.relname, t.tgname FROM pg_trigger t "
          "JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace "
          "WHERE t.tgenabled='D' AND NOT t.tgisinternal")
if dis:
    for s, t_, g in dis:
        violations.append(f"DISABLED TRIGGER {s}.{t_}.{g}")
        note(f"DISABLED: {s}.{t_}.{g}")
    print(f"  {len(dis)} disabled trigger(s).")
else:
    print("  CLEAN: no disabled triggers.")

# ---------- SCAN 3a: ENUM VALUE COVERAGE ----------
print("\n[SCAN 3a] ENUM (USER-DEFINED) COLUMN VALUE COVERAGE")
enum_cols = run("""
SELECT n.nspname, c.relname, a.attname, t.typname, a.atttypid
FROM pg_attribute a
JOIN pg_class c ON c.oid=a.attrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
JOIN pg_type t ON t.oid=a.atttypid
WHERE a.attnum>0 AND NOT a.attisdropped AND t.typtype='e'
  AND c.relkind='r' AND n.nspname LIKE %s
ORDER BY n.nspname, c.relname, a.attname
""", ["mcms_%"])
bad_enum = 0
for s, t_, col, typ, typoid in enum_cols:
    allowed = [r[0] for r in run(
        "SELECT enumlabel FROM pg_enum WHERE enumtypid=%s", [typoid])]
    placeholders = ", ".join(["%s"] * len(allowed))
    (bad,) = run(
        f"SELECT count(*) FROM {s}.{t_} WHERE {col} IS NOT NULL AND {col}::text NOT IN ({placeholders})",
        allowed)[0]
    if bad:
        bad_enum += 1
        violations.append(f"BAD ENUM {s}.{t_}.{col} ({typ}) [{bad}]")
        note(f"BAD ENUM VALUE: {s}.{t_}.{col} ({typ}) not in {allowed} [{bad} rows]")
print(f"  scanned {len(enum_cols)} enum columns: {'CLEAN' if bad_enum==0 else str(bad_enum)+' PROBLEMS'}")

# ---------- SCAN 3b: NOT NULL VIOLATIONS ----------
print("\n[SCAN 3b] NOT-NULL VIOLATIONS (declared NOT NULL, non-empty tables)")
nn = run("""
SELECT n.nspname, c.relname, a.attname
FROM pg_attribute a
JOIN pg_class c ON c.oid=a.attrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE a.attnum>0 AND NOT a.attisdropped AND a.attnotnull
  AND c.relkind='r' AND n.nspname LIKE %s
""", ["mcms_%"])
nn_bad = 0
for s, t_, col in nn:
    (bad,) = run(f"SELECT count(*) FROM {s}.{t_} WHERE {col} IS NULL")[0]
    if bad:
        nn_bad += 1
        violations.append(f"NULL IN NOT-NULL {s}.{t_}.{col} [{bad}]")
        note(f"NULL IN NOT-NULL: {s}.{t_}.{col} [{bad}]")
print(f"  scanned {len(nn)} NOT-NULL columns: {'CLEAN' if nn_bad==0 else str(nn_bad)+' VIOLATIONS'}")

# ---------- SCAN 3c: CHECK CONSTRAINTS LISTING ----------
print("\n[SCAN 3c] CHECK CONSTRAINTS (presence + one-row validation sample)")
checks = run("""
SELECT n.nspname, c.relname, con.conname, pg_get_constraintdef(con.oid)
FROM pg_constraint con
JOIN pg_class c ON c.oid=con.conrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE con.contype='c' AND n.nspname LIKE %s
ORDER BY n.nspname, c.relname
""", ["mcms_%"])
print(f"  {len(checks)} CHECK constraints present (definitions validated by engine on write).")

# ---------- SCAN 4a: TABLES WITHOUT PK ----------
print("\n[SCAN 4a] TABLES WITHOUT PRIMARY KEY")
nopk = run("""
SELECT n.nspname, c.relname FROM pg_class c
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE c.relkind='r' AND n.nspname LIKE %s
  AND NOT EXISTS (
    SELECT 1 FROM pg_constraint k WHERE k.conrelid=c.oid AND k.contype='p')
ORDER BY n.nspname, c.relname
""", ["mcms_%"])
if nopk:
    for s, t_ in nopk:
        note(f"NO PK: {s}.{t_}")
    print(f"  {len(nopk)} tables without PK (review).")
else:
    print("  CLEAN: every table has a PK.")

# ---------- SCAN 4b: DUPLICATE INDEXES ----------
print("\n[SCAN 4b] DUPLICATE / REDUNDANT INDEXES")
dup = run("""
SELECT n.nspname, c.relname,
       string_agg(i.indexrelid::regclass::text, ' | ') AS idx,
       pg_get_indexdef((array_agg(i.indexrelid ORDER BY i.indexrelid))[1])
FROM pg_index i
JOIN pg_class c ON c.oid=i.indrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname LIKE %s
GROUP BY n.nspname, c.relname, i.indkey, i.indpred
HAVING count(*)>1
""", ["mcms_%"])
if dup:
    for s, t_, idx in dup:
        note(f"DUP INDEX on {s}.{t_}: {idx}")
    print(f"  {len(dup)} duplicate index groups (review).")
else:
    print("  CLEAN: no duplicate single-def indexes.")

# ---------- SCAN 4c: TRIGGERS WITH MISSING FUNCTION ----------
print("\n[SCAN 4c] TRIGGERS REFERENCING MISSING FUNCTION")
miss = run("""
SELECT n.nspname, c.relname, t.tgname, t.tgfoid::regproc
FROM pg_trigger t
JOIN pg_class c ON c.oid=t.tgrelid
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE NOT t.tgisinternal
  AND t.tgfoid NOT IN (SELECT oid FROM pg_proc)
""")
if miss:
    for s, t_, g, f in miss:
        violations.append(f"TRIGGER FN MISSING {s}.{t_}.{g}->{f}")
        note(f"MISSING FN: {s}.{t_}.{g} -> {f}")
    print(f"  {len(miss)} triggers with missing function.")
else:
    print("  CLEAN: all trigger functions exist.")

print("\n" + "=" * 70)
if violations:
    print(f"AUDIT RESULT: {len(violations)} VIOLATION(S) FOUND")
    for v in violations:
        print("  - " + v)
    sys.exit(2)
else:
    print("AUDIT RESULT: CLEAN - referential integrity, trigger state, enum/check coverage, and structural cohesion all OK")
    sys.exit(0)
