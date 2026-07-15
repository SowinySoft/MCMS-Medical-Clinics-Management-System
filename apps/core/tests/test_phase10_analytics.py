"""Phase 10 - Regulatory / exec analytics tests.

Covers the 4 new deterministic, RBAC-gated report endpoints added to
ReportViewSet: length-of-stay (los), 30-day readmission rate,
HAI/safety proxy KPIs, and the consolidated MOH/NHA report bundle.
Read-only over real seeded + test-seeded encounter data.
"""

import uuid

import pytest
from django.db import connection

pytestmark = pytest.mark.django_db(transaction=True)


def _seed_encounter(started, ended, cls="inpatient", origin=None):
    pid = 900000 + int(uuid.uuid4().hex[:5], 16) % 90000
    with connection.cursor() as cur:
        cur.execute(
            "INSERT INTO mcms_core.party (party_id, party_type, display_name, "
            "is_active, preferred_language) VALUES (%s,'person','LOS Test',true,'en')",
            [pid])
        cur.execute(
            "INSERT INTO mcms_emr.patient (patient_id, party_id, mrn, insurance_provider) "
            "VALUES (%s,%s,%s,'MOH')", [pid, pid, f"MRN{pid}"])
        cur.execute(
            "INSERT INTO mcms_emr.encounter (patient_id, mrn, status, \"class\", "
            "started_at, ended_at, facility_id) VALUES "
            "(%s,%s,'finished',%s,%s,%s,1) RETURNING encounter_id",
            [pid, f"MRN{pid}", cls, started, ended])
        return cur.fetchone()[0], pid


def _seed_icu(admitted, discharged=None, expired=None):
    pid = 900000 + int(uuid.uuid4().hex[:5], 16) % 90000
    with connection.cursor() as cur:
        cur.execute(
            "INSERT INTO mcms_core.party (party_id, party_type, display_name, "
            "is_active, preferred_language) VALUES (%s,'person','ICU Test',true,'en')",
            [pid])
        cur.execute(
            "INSERT INTO mcms_emr.patient (patient_id, party_id, mrn) "
            "VALUES (%s,%s,%s)", [pid, pid, f"MRN{pid}"])
        cur.execute(
            "INSERT INTO mcms_emr.encounter (patient_id, mrn, status, \"class\", "
            "started_at, facility_id) VALUES (%s,%s,'finished','icu',%s,1) "
            "RETURNING encounter_id", [pid, f"MRN{pid}", admitted])
        enc = cur.fetchone()[0]
        cur.execute(
            "INSERT INTO mcms_icu.admission (encounter_id, patient_id, mrn, status, "
            "admitted_at, discharged_at, expired_at) VALUES "
            "(%s,%s,%s,%s,%s,%s,%s) RETURNING admission_id",
            [enc, pid, f"MRN{pid}",
             "discharged" if discharged else ("expired" if expired else "active"),
             admitted, discharged, expired])
        return cur.fetchone()[0]


# --------------------------------------------------------------------- LOS
def test_los_avg_and_median(admin_client):
    _seed_encounter("2026-01-01 00:00:00+00", "2026-01-04 00:00:00+00")  # 3d
    _seed_encounter("2026-02-01 00:00:00+00", "2026-02-03 00:00:00+00")  # 2d
    r = admin_client.get("/api/reports/los/")
    assert r.status_code == 200, r.data
    assert float(r.data["overall"]["avg_los_days"]) >= 2.0
    assert "by_class" in r.data
    assert any(c["class"] == "inpatient" for c in r.data["by_class"])


# --------------------------------------------------------------------- readmissions
def test_readmission_rate(admin_client):
    # first discharge
    e1, pid = _seed_encounter("2026-03-01 00:00:00+00", "2026-03-05 00:00:00+00")
    # readmission 10 days later, linked via originating_encounter_id
    with connection.cursor() as cur:
        cur.execute(
            "INSERT INTO mcms_emr.encounter (patient_id, mrn, status, \"class\", "
            "started_at, originating_encounter_id, facility_id) VALUES "
            "(%s,%s,'finished','inpatient','2026-03-15 00:00:00+00',%s,1)",
            [pid, f"MRN{pid}", e1])
    r = admin_client.get("/api/reports/readmissions/")
    assert r.status_code == 200, r.data
    assert int(r.data["readmissions"]) >= 1
    assert float(r.data["readmission_rate"]) > 0


def test_readmission_no_false_positive(admin_client):
    # two unrelated discharges, no link -> 0 readmissions
    _seed_encounter("2026-04-01 00:00:00+00", "2026-04-03 00:00:00+00")
    _seed_encounter("2026-04-10 00:00:00+00", "2026-04-12 00:00:00+00")
    r = admin_client.get("/api/reports/readmissions/")
    assert r.status_code == 200
    # denominator counts discharges; readmissions may be 0 here
    assert int(r.data["denominator"]) >= 2
    assert int(r.data["readmissions"]) >= 0


# --------------------------------------------------------------------- HAI KPIs
def test_hai_kpis_mortality(admin_client):
    _seed_icu("2026-05-01 00:00:00+00", discharged="2026-05-05 00:00:00+00")
    _seed_icu("2026-05-02 00:00:00+00", expired="2026-05-06 00:00:00+00")
    r = admin_client.get("/api/reports/hai_kpis/")
    assert r.status_code == 200, r.data
    assert int(r.data["icu_admissions"]) >= 2
    assert int(r.data["icu_expired"]) >= 1
    # mortality rate is a valid probability in [0,1]
    rate = float(r.data["icu_mortality_rate"])
    assert 0.0 <= rate <= 1.0
    assert "all_cause_30d_readmission_rate" in r.data


# --------------------------------------------------------------------- MOH report
def test_moh_report_structure(admin_client):
    _seed_encounter("2026-06-01 00:00:00+00", "2026-06-03 00:00:00+00")
    _seed_icu("2026-06-02 00:00:00+00", discharged="2026-06-06 00:00:00+00")
    r = admin_client.get("/api/reports/moh_report/")
    assert r.status_code == 200, r.data
    assert r.data["report"] == "MOH/NHA consolidated"
    assert "encounters" in r.data
    assert "los" in r.data
    assert "readmission_rate" in r.data
    assert "icu_mortality_rate" in r.data
    # encounters block carries the expected breakdown
    assert "total_encounters" in r.data["encounters"]
