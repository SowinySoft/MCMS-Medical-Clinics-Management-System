#!/usr/bin/env bash
# Bootstrap integration gate — simulates the miget deploy environment.
#
# Why this exists: every prior deploy bug (missing psql, wrong schema filename,
# AUTHORIZATION postgres on a non-postgres role, auth_user/app_user missing)
# escaped CI because the test DB was always built by a SUPERUSER (postgres) and
# never via the actual production entrypoint (start.sh). This script reproduces
# miget exactly:
#   1. create a fresh database owned by a NON-superuser role (appuser),
#   2. run the real production entrypoint (start.sh) which does
#      migrate + load_sql + provision_user + daphne,
#   3. assert admin login returns HTTP 200.
#
# Exit non-zero (failing CI) if login != 200 or the schema fails to load.
set -euo pipefail

DB="${BOOT_DB:-mcms_boot}"
ROLE="${BOOT_ROLE:-appuser}"
PW="${BOOT_PW:-apppw}"
HOST="${BOOT_HOST:-127.0.0.1}"
PORT="${BOOT_PORT:-5432}"
ADMIN_PW="${MCMS_ADMIN_PASSWORD:-admin123}"

# 1) Create role + fresh DB as the postgres superuser (available in CI / local).
python - <<PY
import os, psycopg
url = os.environ.get("BOOT_SUPERUSER_URL",
                     f"postgres://postgres:postgres@{os.environ.get('BOOT_HOST','127.0.0.1')}:"
                     f"{os.environ.get('BOOT_PORT','5432')}/postgres")
db = os.environ["BOOT_DB"]; role = os.environ["BOOT_ROLE"]; pw = os.environ["BOOT_PW"]
conn = psycopg.connect(url, autocommit=True)
with conn.cursor() as c:
    c.execute("SELECT 1 FROM pg_roles WHERE rolname=%s", [role])
    if not c.fetchone():
        # DDL cannot use bound params; quote the literal safely.
        from psycopg import sql as _sql
        c.execute(_sql.SQL("CREATE ROLE {} LOGIN PASSWORD {}").format(
            _sql.Identifier(role), _sql.Literal(pw)))
    c.execute("SELECT 1 FROM pg_database WHERE datname=%s", [db])
    if c.fetchone():
        c.execute(f"DROP DATABASE {db}")
    c.execute(f"CREATE DATABASE {db} OWNER {role}")
    c.execute(f"GRANT ALL ON DATABASE {db} TO {role}")
print(f"prepared database {db} owned by {role}")
PY

# 2) Run the REAL production entrypoint as the non-superuser role.
export DATABASE_URL="postgres://${ROLE}:${PW}@${HOST}:${PORT}/${DB}"
export MCMS_ADMIN_PASSWORD="${ADMIN_PW}"
echo ">> running start.sh (production entrypoint) as ${ROLE} ..."
bash start.sh > /tmp/bootstrap_test.log 2>&1 &
SRV=$!
trap 'kill $SRV 2>/dev/null || true' EXIT

# 3) Wait for Daphne to accept connections.
for i in $(seq 1 90); do
  if curl -fs -o /dev/null "http://127.0.0.1:5000/api/system/health/" 2>/dev/null; then
    echo ">> server up after ${i} tries"
    break
  fi
  sleep 2
done

# 4) Assert admin login returns 200.
CODE=$(curl -s -o /tmp/bootstrap_login.json -w "%{http_code}" -X POST \
  "http://127.0.0.1:5000/api/auth/token/" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"admin\",\"password\":\"${ADMIN_PW}\"}" || echo "000")

if [ "$CODE" = "200" ]; then
  echo "BOOTSTRAP TEST PASSED: admin login -> 200"
  exit 0
else
  echo "BOOTSTRAP TEST FAILED: login returned HTTP ${CODE}"
  echo "--- login response ---"; cat /tmp/bootstrap_login.json; echo
  echo "--- start.sh log (tail) ---"; tail -40 /tmp/bootstrap_test.log
  exit 1
fi
