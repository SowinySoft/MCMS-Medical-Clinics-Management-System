"""Medical Waste Records Management — CRUD, RBAC and the quantity->cost trace.

Verifies the new mcms_waste domain end-to-end against the real rebuilt DB:
  * the auto-router exposes /api/waste/<model>/ for every table (page contract);
  * a disposal manifest's total_cost is DB-COMPUTED (GENERATED ALWAYS) from
    total_weight_kg * unit_cost_per_kg — the app never sends it, and sending
    it must not corrupt the computed value (the accounting trace);
  * cost allocation ties a manifest's cost/weight to a department + period;
  * RBAC: waste.read gates the endpoints (accountant has it; sysadmin admin.all).
"""
import uuid
from decimal import Decimal

import pytest
from django.db import connection

pytestmark = pytest.mark.django_db(transaction=True)


def _first_department_id():
    with connection.cursor() as cur:
        cur.execute("SELECT department_id FROM mcms_hr.department "
                    "ORDER BY department_id LIMIT 1")
        row = cur.fetchone()
    return row[0] if row else None


def test_waste_endpoints_are_registered(admin_client):
    """Every waste table is navigable from the API root (no page w/o backend)."""
    r = admin_client.get("/api/")
    assert r.status_code == 200
    keys = set(r.data.keys())
    for slug in ("waste/waste-stream", "waste/waste-container",
                 "waste/waste-collection", "waste/waste-disposal-manifest",
                 "waste/waste-cost-allocation"):
        assert slug in keys, f"{slug} missing from API root"


def test_waste_stream_crud(admin_client):
    code = f"TST-{uuid.uuid4().hex[:8].upper()}"
    r = admin_client.post("/api/waste/waste-stream/", {
        "code": code, "name": "Test Stream", "kind": "infectious",
        "color_code": "red", "unit_cost_per_kg": "2.5000",
    }, format="json")
    assert r.status_code == 201, r.content
    sid = r.data["stream_id"]

    r = admin_client.patch(f"/api/waste/waste-stream/{sid}/",
                           {"name": "Renamed"}, format="json")
    assert r.status_code == 200, r.content
    assert r.data["name"] == "Renamed"

    r = admin_client.delete(f"/api/waste/waste-stream/{sid}/")
    assert r.status_code == 204, r.content


def test_manifest_total_cost_is_db_computed(admin_client):
    """The core accounting trace: total_cost = weight * rate, computed by the DB.

    We deliberately POST a bogus total_cost to prove it is ignored (read-only
    GENERATED column) and the DB value is authoritative.
    """
    manifest_no = f"MT-{uuid.uuid4().hex[:10].upper()}"
    r = admin_client.post("/api/waste/waste-disposal-manifest/", {
        "manifest_no": manifest_no,
        "carrier_vendor": "TestCarrier",
        "treatment_method": "incineration",
        "disposal_datetime": "2026-07-17T10:00:00+00:00",
        "total_weight_kg": "12.000",
        "unit_cost_per_kg": "3.5000",
        "total_cost": "999999.00",   # bogus — must be ignored (GENERATED)
        "status": "open",
    }, format="json")
    assert r.status_code == 201, r.content
    mid = r.data["manifest_id"]

    # 12.000 * 3.5000 = 42.0000, NOT the bogus 999999
    assert Decimal(str(r.data["total_cost"])) == Decimal("42.0000"), r.data

    # confirm straight from the DB too
    with connection.cursor() as cur:
        cur.execute("SELECT total_cost FROM mcms_waste.waste_disposal_manifest "
                    "WHERE manifest_id=%s", [mid])
        assert cur.fetchone()[0] == Decimal("42.0000")

    admin_client.delete(f"/api/waste/waste-disposal-manifest/{mid}/")


def test_cost_allocation_links_department_and_period(admin_client):
    dept = _first_department_id()
    assert dept is not None, "no department seeded"

    manifest_no = f"MA-{uuid.uuid4().hex[:10].upper()}"
    r = admin_client.post("/api/waste/waste-disposal-manifest/", {
        "manifest_no": manifest_no,
        "disposal_datetime": "2026-07-17T10:00:00+00:00",
        "total_weight_kg": "8.000",
        "unit_cost_per_kg": "4.0000",
        "status": "certified",
    }, format="json")
    assert r.status_code == 201, r.content
    mid = r.data["manifest_id"]
    computed = Decimal(str(r.data["total_cost"]))
    assert computed == Decimal("32.0000")

    r = admin_client.post("/api/waste/waste-cost-allocation/", {
        "manifest": mid, "department": dept, "period_month": "2026-07-01",
        "allocated_weight_kg": "8.000", "allocated_cost": str(computed),
        "cost_center_code": "CC-TEST",
    }, format="json")
    assert r.status_code == 201, r.content
    aid = r.data["allocation_id"]

    admin_client.delete(f"/api/waste/waste-cost-allocation/{aid}/")
    admin_client.delete(f"/api/waste/waste-disposal-manifest/{mid}/")


def test_accountant_can_read_waste(acc1_client):
    """Accountant (waste.read) can list waste records for cost tracing."""
    r = acc1_client.get("/api/waste/waste-stream/")
    assert r.status_code == 200, r.content
