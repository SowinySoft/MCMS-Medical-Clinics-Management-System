#!/usr/bin/env bash
# setup_db.sh — build the PRODUCTION `mcms` database from committed artifacts.
#
# Mirrors scripts/rebuild_test_db.sh (from-sql mode) but targets the live
# `mcms` database and provisions real users from env (via manage.py
# provision_user). Used by the Docker web container entrypoint on first boot.
#
# Requirements: psql/pg_dump on PATH, PGPASSWORD set (or ~/.pgpass).
set -euo pipefail

DB_HOST="${MCMS_DB_HOST:-db}"
DB_PORT="${MCMS_DB_PORT:-5432}"
DB_USER="${MCMS_DB_USER:-postgres}"
export PGPASSWORD="${MCMS_DB_PASSWORD:-postgres}"

LIVE_DB="${MCMS_DB_NAME:-mcms}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

winpath() {
  if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else echo "$1" | sed -E 's|^/([a-zA-Z])/|\U\1:\\|; s|/|\\|g'; fi
}

PSQL="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -v ON_ERROR_STOP=0"
export PGCLIENTENCODING=UTF8

echo ">> Ensuring database '$LIVE_DB' exists"
$PSQL -d postgres -c "SELECT 1 FROM pg_database WHERE datname='$LIVE_DB'" | grep -q 1 || \
  $PSQL -d postgres -c "CREATE DATABASE $LIVE_DB OWNER $DB_USER TEMPLATE template0 ENCODING 'UTF8' LC_COLLATE 'C' LC_CTYPE 'C';"

TABLES=$($PSQL -d "$LIVE_DB" -tAc "SELECT count(*) FROM information_schema.tables WHERE table_schema LIKE 'mcms_%';" || echo 0)
if [ "${TABLES:-0}" -ge 80 ]; then
  echo ">> '$LIVE_DB' already has schema ($TABLES tables) — skipping schema build"
else
  echo ">> Building schema + seed + test users from committed sql/"
  $PSQL -d "$LIVE_DB" -f "$(winpath "$REPO_ROOT/sql/mcms_schema.sql")" >/dev/null
  for s in 90_seed.sql 91_merge_seed.sql 97_test_users.sql; do
    echo "   applying $s"
    $PSQL -d "$LIVE_DB" -f "$(winpath "$REPO_ROOT/sql/$s")" >/dev/null
  done
fi

# Provision real users from env (idempotent via provision_user's ON CONFLICT).
ADMIN_USER="${MCMS_ADMIN_USER:-admin}"
ADMIN_PASS="${MCMS_ADMIN_PASS:-admin123}"
ACC1_USER="${MCMS_ACC1_USER:-acc1}"
ACC1_PASS="${MCMS_ACC1_PASS:-acc1123}"

python -m manage.py provision_user --username "$ADMIN_USER" --password "$ADMIN_PASS" --role sysadmin --party-name "System Administrator" --superuser
python -m manage.py provision_user --username "$ACC1_USER"  --password "$ACC1_PASS"  --role accountant --party-name "Acc1 Clerk"

echo ">> OK: '$LIVE_DB' is ready"
