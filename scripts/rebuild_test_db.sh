#!/usr/bin/env bash
# rebuild_test_db.sh — reproduce the MCMS pytest database deterministically.
#
# Why this exists:
#   * Our domain models are inspectdb-generated with managed=False, so Django
#     migrations create no tables. We build `mcms_test` from a committed
#     schema-only dump (sql/mcms_schema.sql) + reference seed (sql/90,91) +
#     test identity (sql/97), OR restore a faithful pg_dump of `mcms` (local
#     dev only — dumps are gitignored).
#   * This makes the test DB self-healing after a Postgres data-directory swap
#     or any loss of `mcms_test`, and lets CI rebuild it with no secrets/dumps.
#
# Usage:
#   ./scripts/rebuild_test_db.sh                 # from-sql if no dump, else dump
#   MODE=from-sql  ./scripts/rebuild_test_db.sh  # CI: build purely from sql/
#   MODE=from-dump ./scripts/rebuild_test_db.sh  # local: restore backups/*.sql
#
# Requirements: psql/pg_dump on PATH, PGPASSWORD set (or use ~/.pgpass).

set -euo pipefail

# ---- config (override via env) -------------------------------------------
DB_HOST="${MCMS_DB_HOST:-127.0.0.1}"
DB_PORT="${MCMS_DB_PORT:-5432}"
DB_USER="${MCMS_DB_USER:-postgres}"
export PGPASSWORD="${MCMS_DB_PASSWORD:-postgres}"

LIVE_DB="${MCMS_DB_NAME:-mcms}"          # source of truth (local dump mode)
TEST_DB="${MCMS_TEST_DB:-mcms_test}"     # DB pytest-django reuses
DUMP="${MCMS_TEST_DUMP:-backups/mcms_20260714_223750.sql}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DUMP_PATH="$REPO_ROOT/${DUMP}"

# On Windows/MSYS, psql/pg_dump are native binaries that cannot read MSYS-style
# paths like /d/MCMS/...; convert to a Windows path (D:\MCMS\...). On Linux/macOS
# (e.g. GitHub Actions) psql reads POSIX paths directly, so return them as-is.
case "$(uname -s 2>/dev/null || echo unknown)" in
  MINGW*|MSYS*|CYGWIN*) _IS_WINDOWS=1 ;;
  *)                     _IS_WINDOWS=0 ;;
esac

winpath() {
  if [ "$_IS_WINDOWS" != "1" ]; then
    echo "$1"
  elif command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$1"
  else
    echo "$1" | sed -E 's|^/([a-zA-Z])/|\U\1:\\|; s|/|\\|g'
  fi
}

PSQL="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -v ON_ERROR_STOP=0"

# Decide mode
MODE="${MODE:-auto}"
if [ "$MODE" = "auto" ]; then
  if [ -f "$DUMP_PATH" ]; then MODE=from-dump; else MODE=from-sql; fi
fi

echo ">> TEST_DB=$TEST_DB  MODE=$MODE"

# ---- drop + recreate the test database -----------------------------------
# Force-drop: terminate any lingering connections (a live Daphne or psql can
# hold the DB open and make a plain DROP silently no-op, leaving stale schemas
# that then collide with the schema dump). WITH (FORCE) requires PG13+.
$PSQL -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='$TEST_DB' AND pid <> pg_backend_pid();" >/dev/null 2>&1 || true
$PSQL -d postgres -c "DROP DATABASE IF EXISTS $TEST_DB WITH (FORCE);" >/dev/null 2>&1 || \
  $PSQL -d postgres -c "DROP DATABASE IF EXISTS $TEST_DB;" >/dev/null
$PSQL -d postgres -c "CREATE DATABASE $TEST_DB OWNER $DB_USER TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'C' LC_CTYPE 'C';" >/dev/null 2>&1 || \
  $PSQL -d postgres -c "CREATE DATABASE $TEST_DB OWNER $DB_USER;" >/dev/null
# ensure the client speaks UTF8 (Arabic role names in seed data)
export PGCLIENTENCODING=UTF8

if [ "$MODE" = "from-dump" ]; then
  DUMP_WIN="$(winpath "$DUMP_PATH")"
  echo ">> Restoring schema + data from dump: $DUMP_PATH"
  $PSQL -d "$TEST_DB" -f "$DUMP_WIN" >/dev/null
  echo ">> Copying auth_user (dump data-insert is occasionally skipped on restore)"
  pg_dump -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$LIVE_DB" \
    -t public.auth_user -t public.auth_user_groups \
    -t public.auth_user_user_permissions --data-only --inserts 2>/dev/null \
    | $PSQL -d "$TEST_DB" >/dev/null
else
  # from-sql: build deterministically from committed artifacts (CI-safe, no
  # secrets/dumps). The ordered sql/00..96 scripts assume Django's core tables
  # already exist (they only MOVE them in 94), so we use the committed
  # schema-only dump instead, then apply reference seed + test identity.
  echo ">> Building from committed schema dump + seed (deterministic)"
  $PSQL -d "$TEST_DB" -f "$(winpath "$REPO_ROOT/sql/mcms_schema.sql")" >/dev/null
  for s in 90_seed.sql 91_merge_seed.sql 97_test_users.sql 98_trust.sql 99_cds_seed.sql 21_phase2.sql 22_phase5.sql 23_multitenancy.sql 24_phase7_hl7.sql 25_phase7_hash_fix.sql 26_phase8_terminology.sql 27_phase9_payer.sql 28_phase11_telemed.sql; do
    echo "   applying $s"
    $PSQL -d "$TEST_DB" -f "$(winpath "$REPO_ROOT/sql/$s")" >/dev/null
  done
fi

# ---- verify ----------------------------------------------------------------
TABLES=$($PSQL -d "$TEST_DB" -tAc "SELECT count(*) FROM information_schema.tables WHERE table_schema LIKE 'mcms_%';")
USERS=$($PSQL -d "$TEST_DB" -tAc "SELECT string_agg(username,',') FROM public.auth_user WHERE username IN ('admin','acc1');")
echo "   mcms_* tables: $TABLES"
echo "   auth users (admin,acc1): ${USERS:-MISSING}"

if [ "${TABLES:-0}" -lt 80 ] || [ -z "$USERS" ]; then
  echo "!! Rebuild failed — tables=$TABLES users=${USERS:-none}" >&2
  exit 1
fi

echo ">> OK: $TEST_DB is ready for pytest (run: pytest --no-migrations)"
