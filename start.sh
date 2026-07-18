#!/usr/bin/env bash
# miget web start command. Runs at EVERY container launch (unlike Post-Deploy,
# which miget does not re-run on restart/rebuild). Guarantees that:
#   1. Django core tables (auth_user, sessions, ...) exist,
#   2. the domain schema (mcms_*.sql) is loaded (via pure psycopg, no psql),
#   3. the admin user + RBAC bridge exist,
# before Daphne serves traffic. This makes the app self-healing on launch.
set -e

export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE:-config.settings}"
# Post-Deploy/start may not expose SECRET_KEY; it isn't needed for migrate.
export SECRET_KEY="${SECRET_KEY:-miget-bootstrap-placeholder-key-change-me}"

echo ">> [start] 1/3 Ensuring Django core tables (auth_user, sessions, ...)..."
python manage.py migrate --noinput || echo ">> [start] migrate reported an issue; continuing"

echo ">> [start] 2/3 Loading MCMS domain schema (psycopg, no psql required)..."
python scripts/load_sql.py || echo ">> [start] load_sql reported issues; continuing"

echo ">> [start] 3/3 Ensuring admin user + RBAC bridge..."
python manage.py provision_user \
  --username "${MCMS_ADMIN_USER:-admin}" \
  --password "${MCMS_ADMIN_PASSWORD:-admin123}" \
  --role sysadmin --superuser \
  || echo ">> [start] provision_user reported issues (admin Django user still ensured below)"

# Ensure the Django superuser exists even if provision_user's RBAC SQL failed.
python - <<'PY'
import django, os
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings")
django.setup()
from django.contrib.auth.models import User
uname = os.environ.get("MCMS_ADMIN_USER", "admin")
pw = os.environ.get("MCMS_ADMIN_PASSWORD", "admin123")
u, created = User.objects.get_or_create(username=uname)
u.set_password(pw)
u.is_staff = u.is_superuser = True
u.save()
print(f">> [start] admin user '{uname}' {'created' if created else 'ensured'} (superuser)")
PY

echo ">> [start] Launching Daphne on 0.0.0.0:5000..."
exec daphne -b 0.0.0.0 -p 5000 config.asgi:application
