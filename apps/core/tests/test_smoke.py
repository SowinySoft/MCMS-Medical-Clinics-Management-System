"""Smoke tests — validate the harness connects to the live DB and RBAC works."""
import pytest
from django.db import connection

pytestmark = pytest.mark.django_db(transaction=True)


def test_db_connectivity():
    with connection.cursor() as cur:
        cur.execute("SELECT 1")
        assert cur.fetchone()[0] == 1


def test_admin_can_list_api_root(api_root):
    # api_root fixture already asserts 200
    assert any("core/address" in str(k) for k in api_root), "API root should list domain routes"


def test_rbac_sysadmin_only(admin_client, acc1_client):
    # /api/system/metrics/ requires admin.all
    assert admin_client.get("/api/system/metrics/").status_code == 200
    assert acc1_client.get("/api/system/metrics/").status_code == 403
