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

# 0) Django core + axes tables (idempotent). Domain tables are managed=False
#    (built from the SQL dump below), so migrate only creates Django's own
#    tables (auth_user, axes_*, contenttypes, sessions, ...). django-axes is
#    enabled in prod and REQUIRES its tables or every login 500s.
python manage.py migrate --noinput >/dev/null 2>&1 || true

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
