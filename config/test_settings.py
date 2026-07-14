"""Test settings — reuse the live mcms DB.

Our domain models are inspectdb-generated with managed=False, so Django
migrations create no tables. We point tests at the live `mcms` database (which
already has all 89 tables + triggers + RBAC matrix) and tell pytest-django to
reuse it rather than clone into test_mcms. Tests are written to be
non-destructive (read-only by default; the e2e path creates+deletes in a txn).
"""
from .settings import *  # noqa: F401,F403
from .settings import _SCHEMAS  # noqa: F401
import os as _os

DEBUG = False

# Reuse a dedicated test database (mcms_test) instead of the live `mcms`,
# so pytest-django's setup never clobbers production data.
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": _os.environ.get("MCMS_DB_NAME", "mcms_test"),
        "USER": _os.environ.get("MCMS_DB_USER", "postgres"),
        "PASSWORD": _os.environ.get("MCMS_DB_PASSWORD", "postgres"),
        "HOST": _os.environ.get("MCMS_DB_HOST", "127.0.0.1"),
        "PORT": _os.environ.get("MCMS_DB_PORT", "5432"),
        "TEST": {
            "NAME": _os.environ.get("MCMS_DB_NAME", "mcms_test"),
            "CREATE_DB": False,
            "MIRROR": None,
        },
        "OPTIONS": {"options": f"-c search_path={_SCHEMAS}"},
    }
}

# No migrations run for unmanaged models; skip them entirely.
class _NoMigrations(dict):
    def __contains__(self, item): return True
    def __getitem__(self, item): return None
    def get(self, item, default=None): return None
MIGRATION_MODULES = _NoMigrations()

# Match production: axes enabled (tables exist). Tests do few logins.
AXES_ENABLED = True
