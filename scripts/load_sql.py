#!/usr/bin/env python
"""Load the MCMS SQL schema + seeds into the database via psycopg.

miget's Python runtime does not ship `psql`, and the prior deploy relied on
`psql -f sql/mcms_schema.sql` (a file that does not exist in the repo). This
loader runs the real numbered SQL files using psycopg directly, so the domain
schema is created on every container start without psql.

The SQL files are plain DDL/DML (pg_dump output) with no COPY-stdin or psql
meta-commands, but they contain dollar-quoted function bodies ($tag$ / $$)
whose internal semicolons must NOT be treated as statement separators. We
split on ';' with a correct dollar-quote-aware state machine.

Run from anywhere:  python scripts/load_sql.py
Idempotent: the SQL files use CREATE ... IF NOT EXISTS / ON CONFLICT.
"""
import os
import sys
import glob
import re
import psycopg

REPO_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SQL_DIR = os.path.join(REPO_ROOT, "sql")

# Skip the combined dump by default — it is applied FIRST (below) as the
# authoritative schema source so the deployed DB matches the Django models
# exactly (the numbered files have drifted from the models over time). The
# environment-specific search_path mover is still skipped (Django tables live
# in `public` after migrate; moving them would break the running app).
SKIP = {"94_move_django_to_public.sql"}


def _apply_schema_dump(conn, repo_root):
    """Apply sql/mcms_schema.sql (faithful pg_dump) as the schema source of
    truth. This guarantees every Django model column (e.g. appointment.no_show_at,
    app_user.facility_id) exists on the deployed DB, matching what the test DB
    (rebuild_test_db.sh from-sql mode) builds. Returns True on FATAL."""
    path = os.path.join(repo_root, "sql", "mcms_schema.sql")
    if not os.path.exists(path):
        return False
    with open(path, "r", encoding="utf-8") as fh:
        text = fh.read()
    # pg_dump 18 emits `\restrict <token>` / `\unrestrict <token>` security
    # lines (and possibly other backslash metacommands) that PostgreSQL cannot
    # parse via the raw exec_ path; strip any line beginning with a backslash.
    text = re.sub(r"^[ \t]*\\.*$", "", text, flags=re.MULTILINE)
    text = re.sub(r'\bAUTHORIZATION\s+"?postgres"?\b', '', text, flags=re.IGNORECASE)
    text = re.sub(r'\bOWNER\s+TO\s+"?postgres"?\b', '', text, flags=re.IGNORECASE)
    try:
        conn.rollback()
    except Exception:
        pass
    res = conn.pgconn.exec_(text.encode("utf-8"))
    cur = res
    fatal = False
    while cur is not None:
        em = cur.error_message.decode("utf-8", "replace")
        if em.strip():
            benign = any(s in em for s in (
                "already exists", "does not exist", "duplicate",
                "unique constraint", "cannot", "No schema has been",
                "permission denied",
            ))
            if not benign:
                fatal = True
                print(f"   !! mcms_schema.sql: {em[:200]}")
        try:
            cur = cur.next()
        except Exception:
            cur = None
    return fatal

_DOLLAR = re.compile(r"\$([A-Za-z_][A-Za-z0-9_]*)?\$")


def database_url():
    url = os.environ.get("DATABASE_URL")
    if url:
        return url
    try:
        import django
        os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
        django.setup()
        from django.conf import settings
        db = settings.DATABASES["default"]
        return (f"postgres://{db['USER']}:{db['PASSWORD']}@"
                f"{db['HOST']}:{db['PORT']}/{db['NAME']}")
    except Exception:
        return None


def split_statements(sql: str):
    """Split SQL into statements on ';' outside of dollar-quoted blocks,
    strings, and -- comments. Correctly handles $tag$ / $$ delimiters."""
    statements = []
    buf = []
    i, n = 0, len(sql)
    in_dollar = False
    dollar_close = ""

    while i < n:
        ch = sql[i]
        nxt = sql[i + 1] if i + 1 < n else ""

        if in_dollar:
            buf.append(ch)
            if ch == "$" and sql[i:i + len(dollar_close)] == dollar_close:
                in_dollar = False
                dollar_close = ""
                i += len(dollar_close)
                continue
            i += 1
            continue

        # Start of a dollar-quoted block: $$ or $tag$
        if ch == "$" and (nxt == "$" or nxt.isalpha()):
            m = _DOLLAR.match(sql, i)
            if m:
                tag = m.group(0)  # e.g. $$ or $f$
                in_dollar = True
                dollar_close = tag
                buf.append(tag)
                i += len(tag)
                continue

        if ch == "'":
            buf.append(ch)
            i += 1
            while i < n:
                buf.append(sql[i])
                if sql[i] == "'":
                    if i + 1 < n and sql[i + 1] == "'":
                        buf.append(sql[i + 1])
                        i += 2
                        continue
                    break
                i += 1
            i += 1
            continue

        if ch == "-" and nxt == "-":
            while i < n and sql[i] != "\n":
                i += 1
            continue

        if ch == ";" and not in_dollar:
            stmt = "".join(buf).strip()
            if stmt:
                statements.append(stmt)
            buf = []
            i += 1
            continue

        buf.append(ch)
        i += 1

    tail = "".join(buf).strip()
    if tail:
        statements.append(tail)
    return statements


def main():
    url = database_url()
    if not url:
        print("ERROR: DATABASE_URL is not set.", file=sys.stderr)
        sys.exit(1)

    files = sorted(
        f for f in glob.glob(os.path.join(SQL_DIR, "[0-9]*.sql"))
        if os.path.basename(f) not in SKIP
    )
    if not files:
        print(f"ERROR: no SQL files found in {SQL_DIR}", file=sys.stderr)
        sys.exit(1)

    print(f">> load_sql: {len(files)} SQL files to apply")
    conn = psycopg.connect(url, autocommit=True)

    # 0) Authoritative schema from the faithful pg_dump (matches Django models).
    #    Applied first so the numbered seed files below find their tables.
    dump_fatal = _apply_schema_dump(conn, REPO_ROOT)
    print(f">> applied mcms_schema.sql{'' if not dump_fatal else ' (FATAL)'}")


    def _run_file(path):
        name = os.path.basename(path)
        with open(path, "r", encoding="utf-8") as fh:
            text = fh.read()
        # pg_dump emits `AUTHORIZATION postgres` / `OWNER TO postgres` on
        # schemas/tables. On miget the DB role is NOT `postgres`, so those
        # clauses fail ("must be able to SET ROLE postgres") and abort the
        # whole file. Strip them so objects are owned by the current role.
        text = re.sub(r'\bAUTHORIZATION\s+"?postgres"?\b', '', text,
                      flags=re.IGNORECASE)
        text = re.sub(r'\bOWNER\s+TO\s+"?postgres"?\b', '', text,
                      flags=re.IGNORECASE)
        # Raw pgconn.exec_() bypasses psycopg's autocommit, so a failing
        # multi-statement script aborts the PG transaction and poisons later
        # files. Roll back first to clear any aborted state.
        try:
            conn.rollback()
        except Exception:
            pass
        res = conn.pgconn.exec_(text.encode("utf-8"))
        cur_res = res
        fatal = False
        while cur_res is not None:
            em = cur_res.error_message.decode("utf-8", "replace")
            if em.strip():
                benign = any(s in em for s in (
                    "already exists", "does not exist", "duplicate",
                    "unique constraint", "cannot", "No schema has been",
                    "permission denied",
                ))
                if not benign:
                    fatal = True
                    print(f"   !! {name}: {em[:200]}")
            try:
                nxt = cur_res.next()
            except Exception:
                nxt = None
            cur_res = nxt
        return fatal

    try:
        failed = []
        for path in files:
            name = os.path.basename(path)
            fatal = _run_file(path)
            print(f">> applied {name}{' (FATAL - will retry)' if fatal else ''}")
            if fatal:
                failed.append(path)
        # Second pass: re-run files that failed (resolves load-order
        # dependencies, e.g. seeds inserting into event_log before the hash
        # column is added by a later file).
        if failed:
            print(f">> load_sql: second pass for {len(failed)} files...")
            for path in failed:
                name = os.path.basename(path)
                fatal = _run_file(path)
                print(f">> re-applied {name}{' (still FATAL)' if fatal else ' (ok)'}")
        print(">> load_sql complete.")
    finally:
        conn.close()


if __name__ == "__main__":
    main()
