#!/usr/bin/env bash
# rebuild_test_db.sh — reproduce the MCMS pytest database deterministically.
#
# Why this exists:
#   * Our domain models are inspectdb-generated with managed=False, so Django
#     migrations create no tables. pytest-django would otherwise drop+recreate
#     an EMPTY test DB. We instead restore a faithful pg_dump of `mcms` into a
#     dedicated `mcms_test` database, then copy auth_user (the dump's data
#     insert for that table is occasionally skipped on restore, so we copy it
#     explicitly from the live `mcms`).
#   * This makes the test DB self-healing after a Postgres data-directory swap
#     or any loss of `mcms_test`.
#
# Usage:
#   ./scripts/rebuild_test_db.sh            # uses MCPMS_DB_* env or defaults
#   MCPMS_DB_NAME=mcms ./scripts/rebuild_test_db.sh
#
# Requirements: psql/pg_dump on PATH, PGPASSWORD set (or use ~/.pgpass).

set -euo pipefail

# ---- config (override via env) -------------------------------------------
DB_HOST="${MCMS_DB_HOST:-127.0.0.1}"
DB_PORT="${MCMS_DB_PORT:-5432}"
DB_USER="${MCMS_DB_USER:-postgres}"
export PGPASSWORD="${MCMS_DB_PASSWORD:-postgres}"

LIVE_DB="${MCMS_DB_NAME:-mcms}"          # source of truth (has the data)
TEST_DB="${MCMS_TEST_DB:-mcms_test}"     # DB pytest-django reuses
DUMP="${MCMS_TEST_DUMP:-backups/mcms_20260714_223750.sql}"

# Resolve the dump path relative to the repo root (parent of scripts/).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DUMP_PATH="$REPO_ROOT/${DUMP}"

# psql/pg_dump are native Windows binaries and cannot read MSYS-style paths
# like /d/MCMS/...; convert to a Windows path (D:\MCMS\...) when possible.
winpath() {
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$1"
  else
    # crude /c/foo -> C:\foo conversion
    echo "$1" | sed -E 's|^/([a-zA-Z])/|\U\1:\\|; s|/|\\|g'
  fi
}
DUMP_WIN="$(winpath "$DUMP_PATH")"

echo ">> LIVE_DB=$LIVE_DB  TEST_DB=$TEST_DB  DUMP=$DUMP_PATH"

if [ ! -f "$DUMP_PATH" ]; then
  echo "!! Dump not found: $DUMP_PATH" >&2
  echo "   Create one with: pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER -d $LIVE_DB -f $DUMP" >&2
  exit 1
fi

PSQL="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -v ON_ERROR_STOP=0"
PGDUMP="pg_dump -h $DB_HOST -p $DB_PORT -U $DB_USER"

echo ">> Dropping + recreating $TEST_DB"
$PSQL -d postgres -c "DROP DATABASE IF EXISTS $TEST_DB;" >/dev/null
$PSQL -d postgres -c "CREATE DATABASE $TEST_DB OWNER $DB_USER;" >/dev/null

echo ">> Restoring schema + data from dump"
$PSQL -d "$TEST_DB" -f "$DUMP_WIN" >/dev/null

echo ">> Copying auth_user (dump data-insert is occasionally skipped on restore)"
$PGDUMP -d "$LIVE_DB" -t public.auth_user -t public.auth_user_groups \
       -t public.auth_user_user_permissions --data-only --inserts 2>/dev/null \
  | $PSQL -d "$TEST_DB" >/dev/null

echo ">> Verifying"
TABLES=$($PSQL -d "$TEST_DB" -tAc "SELECT count(*) FROM information_schema.tables WHERE table_schema LIKE 'mcms_%';")
USERS=$($PSQL -d "$TEST_DB" -tAc "SELECT string_agg(username,',') FROM public.auth_user WHERE username IN ('admin','acc1');")
echo "   mcms_* tables: $TABLES"
echo "   auth users (admin,acc1): ${USERS:-MISSING}"

if [ "$TABLES" -lt 80 ] || [ -z "$USERS" ]; then
  echo "!! Rebuild failed — tables=$TABLES users=${USERS:-none}" >&2
  exit 1
fi

echo ">> OK: $TEST_DB is ready for pytest (run: pytest --no-migrations)"
