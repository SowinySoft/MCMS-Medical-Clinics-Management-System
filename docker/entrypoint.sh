#!/usr/bin/env bash
# Container entrypoint: wait for Postgres, build/verify the mcms DB, run Daphne.
set -euo pipefail

DB_HOST="${MCMS_DB_HOST:-db}"
DB_PORT="${MCMS_DB_PORT:-5432}"
DB_USER="${MCMS_DB_USER:-postgres}"
export PGPASSWORD="${MCMS_DB_PASSWORD:-postgres}"

echo ">> Waiting for Postgres at $DB_HOST:$DB_PORT ..."
for i in $(seq 1 30); do
  if pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" >/dev/null 2>&1; then
    echo ">> Postgres is up"
    break
  fi
  sleep 2
done

echo ">> Setting up database"
bash scripts/setup_db.sh

echo ">> Running Daphne (HTTP + WebSocket) on :8010"
exec daphne -b 0.0.0.0 -p 8010 config.asgi:application
