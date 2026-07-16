"""Phase 17.1 - Reports: HR/payroll + vital records + high-demand ops.

Verifies each new report endpoint returns 200 with real seeded data:
  * monthly_payroll  - period header + department_summary + per-employee lines
  * birth_certificates / death_certificates - need at least one issued cert
  * claims_status     - status breakdown + turnaround
  * lab_turnaround    - by_priority / by_facility
  * appointment_utilization - kv KPIs
The payroll + claims seed lives in sql/39_report_seed.sql (applied to the
test DB by the build scripts), so these assert against real rows.
"""
import pytest
from django.db import connection

pytestmark = pytest.mark.django_db(transaction=True)


def _issue_a_birth(admin_client):
    import uuid
    uid = uuid.uuid4().hex[:12]
    with connection.cursor() as cur:
        cur.execute("SELECT facility_id FROM mcms_core.facility WHERE code='TERT'")
        fac = cur.fetchone()[0]
        cur.execute(
            "INSERT INTO mcms_core.party (party_type, display_name) VALUES ('person', %s) RETURNING party_id",
            [f"VR-{uid}"])
        mother_party = cur.fetchone()[0]
        cur.execute(
            "INSERT INTO mcms_emr.patient (mrn, facility_id, party_id) VALUES (%s,%s,%s) RETURNING patient_id",
            [f"VR-{uid}", fac, mother_party])
        mother_pid = cur.fetchone()[0]
    r = admin_client.post("/api/vital_records/issue_birth/", {
        "mother_patient_id": mother_pid,
        "birth_datetime": "2026-07-10T08:30:00+00:00",
        "facility_id": fac,
    }, format="json")
    assert r.status_code == 201, r.content


def _issue_a_death(admin_client):
    import uuid
    uid = uuid.uuid4().hex[:12]
    with connection.cursor() as cur:
        cur.execute("SELECT facility_id FROM mcms_core.facility WHERE code='TERT'")
        fac = cur.fetchone()[0]
        cur.execute(
            "INSERT INTO mcms_core.party (party_type, display_name) VALUES ('person', %s) RETURNING party_id",
            [f"VRD-{uid}"])
        party = cur.fetchone()[0]
        cur.execute(
            "INSERT INTO mcms_emr.patient (mrn, facility_id, party_id) VALUES (%s,%s,%s) RETURNING patient_id",
            [f"VRD-{uid}", fac, party])
        pid = cur.fetchone()[0]
    r = admin_client.post("/api/vital_records/issue_death/", {
        "patient_id": pid,
        "death_datetime": "2026-07-12T09:00:00+00:00",
        "cause_icd10": "I21.9",
        "facility_id": fac,
    }, format="json")
    assert r.status_code == 201, r.content


def test_monthly_payroll_report(admin_client):
    r = admin_client.get("/api/reports/monthly_payroll/")
    assert r.status_code == 200, r.content
    body = r.json()
    assert body["period"]["code"] == "2026-07"
    assert len(body["lines"]) >= 1
    assert body["totals"]["employees"] == len(body["lines"])
    assert body["totals"]["net"] > 0


def test_birth_certificates_report(admin_client):
    _issue_a_birth(admin_client)
    r = admin_client.get("/api/reports/birth_certificates/?since=2026-07-01&until=2026-08-01")
    assert r.status_code == 200, r.content
    assert isinstance(r.json(), list)
    assert len(r.json()) >= 1


def test_death_certificates_report(admin_client):
    _issue_a_death(admin_client)
    r = admin_client.get("/api/reports/death_certificates/?since=2026-07-01&until=2026-08-01")
    assert r.status_code == 200, r.content
    assert isinstance(r.json(), list)
    assert len(r.json()) >= 1


def test_claims_status_report(admin_client):
    r = admin_client.get("/api/reports/claims_status/")
    assert r.status_code == 200, r.content
    body = r.json()
    assert "by_status" in body
    assert "turnaround" in body
    assert len(body["by_status"]) >= 1


def test_lab_turnaround_report(admin_client):
    r = admin_client.get("/api/reports/lab_turnaround/")
    assert r.status_code == 200, r.content
    body = r.json()
    assert "by_priority" in body and "by_facility" in body


def test_appointment_utilization_report(admin_client):
    r = admin_client.get("/api/reports/appointment_utilization/")
    assert r.status_code == 200, r.content
    assert "total_appointments" in r.json()


def test_payroll_read_perm_seeded():
    with connection.cursor() as cur:
        cur.execute("SELECT 1 FROM mcms_core.permission WHERE code='payroll.read'")
        assert cur.fetchone(), "payroll.read permission missing"
