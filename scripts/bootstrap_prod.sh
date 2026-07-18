#!/usr/bin/env bash
# Bootstrap the MCMS schema + reference seed against a live database given only
# a DATABASE_URL (the convention miget / most PaaS inject). Idempotent: applies
# the schema dump + numbered SQL files with ON_ERROR_STOP=0 so re-runs on an
# already-built database do not abort (CREATE ... IF NOT EXISTS in numbered files).
#
# Usage (miget Post-Deploy Command):
#   bash scripts/bootstrap_prod.sh
# Requires: psql on PATH, DATABASE_URL exported.
set -u

if [ -z "${DATABASE_URL:-}" ]; then
  echo "ERROR: DATABASE_URL is not set. miget injects it automatically." >&2
  exit 1
fi

# Parse postgres://user:pass@host:port/db  (URL-decode not needed for miget's
# already-safe creds, but strip the scheme and split on the standard delimiters)
URL="${DATABASE_URL}"
URL="${URL#postgres://}"
URL="${URL#postgresql://}"
DB_USER="${URL%%:*}"
REST="${URL#*:}"
DB_PASS="${REST%%@*}"
REST="${URL#*@}"
DB_HOST="${REST%%:*}"
REST="${REST#*:}"
DB_PORT="${REST%%/*}"
DB_NAME="${REST#*/}"

export PGPASSWORD="$DB_PASS"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PSQL="psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -v ON_ERROR_STOP=0"

echo ">> Bootstrapping MCMS schema into $DB_NAME@$DB_HOST:$DB_PORT"

# 0) Django core tables (auth_user, django_session, contenttypes, admin, ...).
#    Domain tables are managed=False and come from the SQL dump below, so
#    migrate only builds Django's own tables. Login REQUIRES auth_user.
#    Self-healing: if a prior (silently-failed) migrate left auth "recorded as
#    applied but table missing", a plain re-run would skip it — so we detect
#    that and force a clean re-migrate.
export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE:-config.settings}"
# Post-Deploy may not expose SECRET_KEY; migrate doesn't need a strong one.
export SECRET_KEY="${SECRET_KEY:-miget-bootstrap-placeholder-key-change-me}"

echo ">> Running Django migrate (core tables)..."
python manage.py migrate --noinput
echo ">> migrate exit: $?"

# Check whether auth_user actually exists despite migrate reporting success.
AUTH_EXISTS=$(python - <<'PY'
import django, os, sys
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()
from django.db import connection
with connection.cursor() as cur:
    cur.execute("SELECT to_regclass('public.auth_user')")
print("YES" if cur.fetchone()[0] else "NO")
PY
)
echo ">> auth_user present after migrate: $AUTH_EXISTS"

if [ "$AUTH_EXISTS" = "NO" ]; then
  echo ">> auth_user missing despite migrate (migration state corrupt). Forcing clean re-migrate..."
  # Un-apply auth migrations (fake) so they re-run and actually create the table.
  python manage.py migrate auth zero --fake || true
  python manage.py migrate --noinput
  echo ">> re-migrate exit: $?"
  AUTH_EXISTS=$(python - <<'PY'
import django, os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()
from django.db import connection
with connection.cursor() as cur:
    cur.execute("SELECT to_regclass('public.auth_user')")
print("YES" if cur.fetchone()[0] else "NO")
PY
)
  echo ">> auth_user present after forced re-migrate: $AUTH_EXISTS"
fi

if [ "$AUTH_EXISTS" = "NO" ]; then
  echo "FATAL: auth_user could not be created. Login will fail. Inspect the migrate output above."
  # Do not abort the whole script (domain schema may still load), but flag it.
fi

# 1) base schema dump (pg_dump output; tolerant re-run)
$PSQL -f "$REPO_ROOT/sql/mcms_schema.sql" >/dev/null 2>&1 || true

# 2) numbered domain + seed files (all use CREATE ... IF NOT EXISTS)
for s in 90_seed.sql 91_merge_seed.sql 97_test_users.sql 98_trust.sql 99_cds_seed.sql \
         21_phase2.sql 22_phase5.sql 23_multitenancy.sql 24_phase7_hl7.sql \
         25_phase7_hash_fix.sql 26_phase8_terminology.sql 27_phase9_payer.sql \
         28_phase11_telemed.sql 29_phase13_identity.sql 30_phase14_departments.sql \
         31_phase15_linkage.sql 32_phase16_facility_linkage.sql 33_fix_event_subject_party.sql \
         34_integrity_cleanup.sql 35_fix_sequences.sql 36_perf_indexes.sql \
         37_patient_deceased.sql 38_vital_records.sql 40_fix_prescription_event.sql \
         41_fix_event_subject_party_p2.sql 42_fix_diag_event_subject.sql \
         43_medical_waste.sql 95_generic_audit_triggers.sql; do
  if [ -f "$REPO_ROOT/sql/$s" ]; then
    $PSQL -f "$REPO_ROOT/sql/$s" >/dev/null 2>&1 || true
  fi
done

echo ">> Schema bootstrap complete."
