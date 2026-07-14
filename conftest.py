"""Pytest fixtures for MCMS backend tests.

Note on auth: the dev Postgres instance can flap between data directories, so
we authenticate tests via `force_authenticate` against the real `auth_user`
rows rather than relying on a password round-trip. This still exercises the
full RBAC matrix (mcms_core.role/permission/role_permission/user_role_map),
which is the part we actually want to test.

Note on DB: our domain models are inspectdb-generated with managed=False, so
Django migrations create no tables. We point tests at a dedicated `mcms_test`
database (restored from a pg_dump via scripts/rebuild_test_db.sh) and disable
pytest-django's database setup so it never drops/recreates that DB.
"""
import django.test.utils as _tu

# No-op DB setup: prevent pytest-django from dropping/recreating the pre-built
# `mcms_test` (which would otherwise wipe our restored schema+data every run).
_tu.setup_databases = lambda *a, **k: None  # type: ignore[assignment]
_tu.teardown_databases = lambda *a, **k: None  # type: ignore[assignment]

import pytest
from rest_framework.test import APIClient
from django.contrib.auth.models import User


@pytest.fixture(scope="session")
def django_db_setup():
    import django
    django.setup()


def _client_for(username):
    c = APIClient()
    # get_or_create: the dev Postgres can flap between data directories, so we
    # don't assume auth_user rows pre-exist on the instance we land on.
    user, _ = User.objects.get_or_create(
        username=username,
        defaults={"is_active": True, "is_superuser": username == "admin"},
    )
    c.force_authenticate(user=user)
    return c


@pytest.fixture
def api():
    return APIClient()


@pytest.fixture
def admin_client():
    return _client_for("admin")


@pytest.fixture
def acc1_client():
    """Accountant (billing.read only) — used to assert RBAC denials."""
    return _client_for("acc1")


@pytest.fixture
def api_root(admin_client):
    r = admin_client.get("/api/")
    assert r.status_code == 200
    return r.data
