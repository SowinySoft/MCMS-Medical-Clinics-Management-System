#!/usr/bin/env bash
# local_test_fast.sh — fast, reliable local signal without the full ~25-min suite.
#
# Why: the full pytest run hangs / throws teardown errors under load on this
# machine, so it is NOT a trustworthy local gate (CI is). This runner gives a
# sub-minute pre-push check: the static emit_event lint + a small representative
# slice of the backend tests. Run the FULL suite only in CI.
#
# Usage:
#   bash scripts/local_test_fast.sh                 # lint + emit_event guard + smoke slice
#   bash scripts/local_test_fast.sh --all           # full suite (slow; mirrors CI)
#   bash scripts/local_test_fast.sh <testfile>...   # run specific test files
set -euo pipefail

cd "$(dirname "$0")/.."
export PGPASSWORD="${MCMS_DB_PASSWORD:-postgres}"
export MCMS_DB_PASSWORD="${MCMS_DB_PASSWORD:-postgres}"
export MCMS_DB_USER="${MCMS_DB_USER:-postgres}"
export MCMS_DB_HOST="${MCMS_DB_HOST:-127.0.0.1}"
export MCMS_DB_PORT="${MCMS_DB_PORT:-5432}"
export MCMS_DB_NAME="${MCMS_DB_NAME:-mcms_test}"
export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE:-config.test_settings}"
export PYTHONPATH="$(pwd)${PYTHONPATH:+:$PYTHONPATH}"

PYTHON_BIN="$(pwd)/.venv/Scripts/python.exe"
if [ ! -x "$PYTHON_BIN" ]; then
  PYTHON_BIN="$(pwd)/.venv/bin/python"
fi
if [ ! -x "$PYTHON_BIN" ]; then
  PYTHON_BIN="${PYTHON:-python}"
fi
PY="$PYTHON_BIN"

if [ "${1:-}" = "--all" ]; then
  echo ">> FULL suite (slow, mirrors CI)"
  $PY -m pytest --no-migrations -p no:cacheprovider
  exit $?
fi

if [ $# -gt 0 ]; then
  echo ">> Running requested test files: $*"
  $PY -m pytest --no-migrations -p no:cacheprovider "$@"
  exit $?
fi

echo ">> 1/3 emit_event subject-party lint (static)"
$PY scripts/audit_emit_event.py

echo ">> 2/3 ERD generator determinism check"
$PY scripts/gen_erd.py >/dev/null
git diff --exit-code -- docs/erd_per_schema.html docs/erd_schema_diagram.html docs/erd_schema_cards.html \
  || { echo "!! docs/*.html drift — run: python scripts/gen_erd.py && git add docs/ && commit"; exit 1; }

echo ">> 3/3 smoke slice (representative backend tests, fast)"
$PY -m pytest --no-migrations -p no:cacheprovider \
  apps/core/tests/test_emit_event_subject.py \
  apps/core/tests/test_frontend_contract.py \
  apps/core/tests/test_phase1_trust.py \
  apps/core/tests/test_reports_phase17.py

echo ">> OK: fast local gate passed. Run full suite in CI."
