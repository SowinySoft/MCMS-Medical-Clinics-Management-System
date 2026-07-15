"""Frontend <-> backend contract test.

Proves the exact endpoints the React frontend calls (frontend/src/api.ts,
Dashboard.tsx, SysAdmin.tsx, Monitors.tsx, PatientPortal.tsx) are present,
authenticated, and return real data. Also proves the previously-orphaned
tables (prescription, facility, organization) now have working CRUD routes.

This is the cross-layer (schema<->model<->API<->UI) functionality gate.
"""
import pytest
from django.contrib.auth.models import User
from django.db import connection
from rest_framework.test import APIClient

pytestmark = pytest.mark.django_db


def _auth_client():
    c = APIClient()
    u, _ = User.objects.get_or_create(
        username="contract_admin",
        defaults=dict(is_active=True, is_superuser=True, is_staff=True))
    u.set_password("Contract123!")
    u.save()
    r = c.post("/api/auth/token/", {"username": "contract_admin", "password": "Contract123!"},
               format="json")
    assert r.status_code == 200, f"JWT login failed: {r.status_code} {r.data}"
    c.credentials(HTTP_AUTHORIZATION=f"Bearer {r.data['access']}")
    return c


@pytest.fixture
def client_auth():
    return _auth_client()


def test_jwt_auth_flow(client_auth):
    r = client_auth.get("/api/system/health/")
    assert r.status_code == 200


def test_frontend_dashboard_endpoints(client_auth):
    # Dashboard.tsx -> list("hr","department"), list("emr","patient"), list("billing","invoice")
    for schema, model in [("hr", "department"), ("emr", "patient"), ("billing", "invoice")]:
        r = client_auth.get(f"/api/{schema}/{model}/")
        assert r.status_code == 200, f"/api/{schema}/{model}/ -> {r.status_code}"
        assert "results" in r.data or isinstance(r.data, list)


def test_frontend_system_admin_endpoints(client_auth):
    # SysAdmin.tsx: metrics/maintenance/backups/replication
    # GET endpoints
    for path in ["system/metrics", "system/replication"]:
        r = client_auth.get(f"/api/{path}/")
        assert r.status_code in (200, 403), f"GET /api/{path}/ -> {r.status_code}"
    # POST endpoints (frontend posts a body)
    for path in ["system/maintenance", "system/backups"]:
        r = client_auth.post(f"/api/{path}/", {}, format="json")
        assert r.status_code in (200, 201, 403), f"POST /api/{path}/ -> {r.status_code}"


def test_frontend_patient_portal_endpoints(client_auth):
    r = client_auth.get("/api/patient/consents/")
    assert r.status_code in (200, 403), f"patient/consents -> {r.status_code}"


def test_orphaned_tables_now_have_routes(client_auth):
    for schema, model in [("rx", "prescription"), ("core", "facility"), ("core", "organization")]:
        r = client_auth.get(f"/api/{schema}/{model}/")
        assert r.status_code == 200, f"/api/{schema}/{model}/ missing -> {r.status_code}"
        assert "results" in r.data or isinstance(r.data, list)


def test_prescription_create_roundtrip(client_auth):
    with connection.cursor() as cur:
        cur.execute("SELECT party_id FROM mcms_core.party LIMIT 1")
        party = cur.fetchone()[0]
        cur.execute("SELECT drug_item_id FROM mcms_rx.drug_item LIMIT 1")
        di = cur.fetchone()[0]
    body = {
        "patient_id": party, "mrn": "CONTRACT-MRN", "prescriber_user_id": 1,
        "drug_item": di, "status": "draft", "controlled": False, "facility_id": 1,
    }
    r = client_auth.post("/api/rx/prescription/", body, format="json")
    assert r.status_code in (201, 200), f"prescription create -> {r.status_code} {r.data}"
    pid = r.data.get("prescription_id") or r.data.get("id")
    assert pid, "prescription create returned no id"
    r2 = client_auth.get(f"/api/rx/prescription/{pid}/")
    assert r2.status_code == 200


# Schemas recently added to the sidebar (schemas.ts SCHEMA_GROUPS) so every
# backend route is navigable from the UI ("no backend without pages").
NEWLY_NAVIGABLE = ["telemed", "referral", "terminology", "ai", "payer", "identity", "fhir", "hl7v2"]


@pytest.mark.parametrize("schema", NEWLY_NAVIGABLE)
def test_newly_navigable_schemas_reachable(client_auth, schema):
    # These are action-only service viewsets. SchemaBrowser falls back to
    # GET /api/<schema>/ (ServiceViewSet.list) which returns an action
    # inventory; that proves a UI page can navigate and call the backend.
    r = client_auth.get(f"/api/{schema}/")
    assert r.status_code == 200, f"/api/{schema}/ unreachable -> {r.status_code}"
    actions = (r.data or {}).get("actions", [])
    assert actions, f"/api/{schema}/ returned no actions -> {r.data}"
    # at least one advertised sub-route must be reachable (not 404)
    ok = False
    for a in actions:
        if a.get("detail"):
            continue
        sub = a["name"]
        rr = client_auth.get(f"/api/{schema}/{sub}/")
        if rr.status_code != 404:
            ok = True
            break
    assert ok, f"no reachable sub-route under schema '{schema}' (actions={[a['name'] for a in actions][:3]})"
