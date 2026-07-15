"""Integrity regression test - real orphan-FK / trigger / enum / structure sweep.

Runs the same catalog-driven checks as scripts/audit_integrity.py against the
live target DB (AUDIT_DB env, defaults to mcms_test) and FAILS if any
referential-integrity, disabled-trigger, bad-enum, null-in-notnull, or
structural-cohesion violation is found. This keeps "strongly confirm integrity"
enforced in CI rather than as a one-off manual step.
"""
import os

import psycopg

AUDIT_DB = os.environ.get("AUDIT_DB", "mcms_test")
DB = dict(host="127.0.0.1", port=5432, user="postgres",
          password=os.environ.get("PGPASSWORD", "postgres"), dbname=AUDIT_DB)


def _run(cur, sql, params=()):
    cur.execute(sql, params)
    return cur.fetchall()


def test_database_integrity():
    conn = psycopg.connect(**DB)
    cur = conn.cursor()
    problems = []

    # 1) orphan FK (single-col)
    fks = _run(cur, """
        SELECT ccon.relnamespace::regnamespace::text, ccon.relname,
               (SELECT attname FROM pg_attribute WHERE attrelid=con.conrelid AND attnum=con.conkey[1]),
               cp.relnamespace::regnamespace::text, cp.relname,
               (SELECT attname FROM pg_attribute WHERE attrelid=con.confrelid AND attnum=con.confkey[1])
        FROM pg_constraint con
        JOIN pg_class ccon ON ccon.oid=con.conrelid
        JOIN pg_class cp ON cp.oid=con.confrelid
        WHERE con.contype='f' AND array_length(con.conkey,1)=1
    """)
    for cs, ct, cc, ps, pt, pc in fks:
        (n,) = _run(cur, f"SELECT count(*) FROM {cs}.{ct} c LEFT JOIN {ps}.{pt} p "
                        f"ON c.{cc}=p.{pc} WHERE c.{cc} IS NOT NULL AND p.{pc} IS NULL")[0]
        if n:
            problems.append(f"orphan FK {cs}.{ct}.{cc}->{ps}.{pt}.{pc} [{n}]")

    # 2) disabled triggers
    for s, t_, g in _run(cur, "SELECT n.nspname,c.relname,t.tgname FROM pg_trigger t "
                              "JOIN pg_class c ON c.oid=t.tgrelid JOIN pg_namespace n ON n.oid=c.relnamespace "
                              "WHERE t.tgenabled='D' AND NOT t.tgisinternal"):
        problems.append(f"disabled trigger {s}.{t_}.{g}")

    # 3a) enum coverage
    for s, t_, col, typoid in _run(cur, """
        SELECT n.nspname,c.relname,a.attname,a.atttypid FROM pg_attribute a
        JOIN pg_class c ON c.oid=a.attrelid JOIN pg_namespace n ON n.oid=c.relnamespace
        JOIN pg_type x ON x.oid=a.atttypid
        WHERE a.attnum>0 AND NOT a.attisdropped AND x.typtype='e' AND c.relkind='r'
          AND n.nspname LIKE %s""", ["mcms_%"]):
        allowed = [r[0] for r in _run(cur, "SELECT enumlabel FROM pg_enum WHERE enumtypid=%s", [typoid])]
        ph = ", ".join(["%s"] * len(allowed))
        (bad,) = _run(cur, f"SELECT count(*) FROM {s}.{t_} WHERE {col} IS NOT NULL "
                           f"AND {col}::text NOT IN ({ph})", allowed)[0]
        if bad:
            problems.append(f"bad enum {s}.{t_}.{col} [{bad}]")

    # 3b) not-null violations
    for s, t_, col in _run(cur, """
        SELECT n.nspname,c.relname,a.attname FROM pg_attribute a
        JOIN pg_class c ON c.oid=a.attrelid JOIN pg_namespace n ON n.oid=c.relnamespace
        WHERE a.attnum>0 AND NOT a.attisdropped AND a.attnotnull AND c.relkind='r'
          AND n.nspname LIKE %s""", ["mcms_%"]):
        (bad,) = _run(cur, f"SELECT count(*) FROM {s}.{t_} WHERE {col} IS NULL")[0]
        if bad:
            problems.append(f"null in not-null {s}.{t_}.{col} [{bad}]")

    # 4b) duplicate indexes
    for s, t_, idx in _run(cur, """
        SELECT n.nspname,c.relname,string_agg(i.indexrelid::regclass::text,' | ')
        FROM pg_index i JOIN pg_class c ON c.oid=i.indrelid JOIN pg_namespace n ON n.oid=c.relnamespace
        WHERE n.nspname LIKE %s GROUP BY n.nspname,c.relname,i.indkey,i.indpred HAVING count(*)>1
    """, ["mcms_%"]):
        problems.append(f"duplicate index {s}.{t_}: {idx}")

    conn.close()
    assert not problems, "INTEGRITY VIOLATIONS:\n  " + "\n  ".join(problems)
