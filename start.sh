#!/usr/bin/env bash
# miget web start command. Runs at EVERY container launch (unlike Post-Deploy,
# which miget does not re-run on restart/rebuild). Guarantees Django core
# tables (auth_user) and the admin user exist before Daphne serves traffic,
# so login works even if the one-time Post-Deploy never created them.
set -e

export DJANGO_SETTINGS_MODULE="${DJANGO_SETTINGS_MODULE:-config.settings}"
# Post-Deploy/start may not expose SECRET_KEY; it isn't needed for migrate.
export SECRET_KEY="${SECRET_KEY:-miget-bootstrap-placeholder-key-change-me}"

echo ">> [start] Ensuring Django core tables (auth_user, sessions, ...)..."
python manage.py migrate --noinput || echo ">> [start] migrate reported an issue; continuing"

echo ">> [start] Ensuring admin user (${MCMS_ADMIN_USER:-admin})..."
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
