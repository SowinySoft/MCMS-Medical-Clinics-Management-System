"""Phase 17 - Vital Records (Birth / Death Certificates) tests.

Covers: birth issues + creates newborn patient; death issues + flips
patient.is_deceased (guard trigger emits patient_deceased event); certificate
immutability (amend creates new row, never edits issued); cause-of-death ICD-10
validation; FHIR bundle export; HL7/ext inbound draft; RBAC seeds present.
"""
import uuid

import pytest
from django.db import connection

pytestmark = pytest.mark.django_db(transaction=True)


def _fac_id(cur, code="TERT"):
    cur.execute("SELECT facility_id FROM mcms_core.facility WHERE code=%s", [code])
    return cur.fetchone()[0]


def _make_patient(cur, uid, fac):
    cur.execute(
        "INSERT INTO mcms_core.party (party_type, display_name) "
        "VALUES ('person', %s) RETURNING party_id", [f"VR-{uid}"])
    party = cur.fetchone()[0]
    cur.execute(
        "INSERT INTO mcms_emr.patient (mrn, facility_id, party_id) "
        "VALUES (%s, %s, %s) RETURNING patient_id", [f"VR-{uid}", fac, party])
    return cur.fetchone()[0], party


def test_birth_certificate_creates_newborn(admin_client):
    uid = uuid.uuid4().hex[:12]
    with connection.cursor() as cur:
        fac = _fac_id(cur)
        mother_pid, _ = _make_patient(cur, uid, fac)
    r = admin_client.post("/api/vital_records/issue_birth/", {
        "mother_patient_id": mother_pid,
        "birth_datetime": "2026-07-16T08:30:00+00:00",
        "facility_id": fac,
    }, format="json")
    assert r.status_code == 201, r.content
    body = r.json()
    assert body["status"] == "issued"
    assert body["newborn_patient_id"]
    # newborn now exists as a real patient
    with connection.cursor() as cur:
        cur.execute("SELECT 1 FROM mcms_emr.patient WHERE patient_id=%s",
                    [body["newborn_patient_id"]])
        assert cur.fetchone()
        cur.execute("SELECT date_of_birth FROM mcms_core.party p "
                    "JOIN mcms_emr.patient pt ON pt.party_id=p.party_id "
                    "WHERE pt.patient_id=%s", [body["newborn_patient_id"]])
        assert str(cur.fetchone()[0]) == "2026-07-16"


def test_death_certificate_flips_is_deceased_and_emits_event(admin_client):
    uid = uuid.uuid4().hex[:12]
    with connection.cursor() as cur:
        fac = _fac_id(cur)
        pid, party = _make_patient(cur, uid, fac)
    r = admin_client.post("/api/vital_records/issue_death/", {
        "patient_id": pid,
        "death_datetime": "2026-07-16T09:00:00+00:00",
        "cause_icd10": "I21.9",
        "facility_id": fac,
    }, format="json")
    assert r.status_code == 201, r.content
    body = r.json()
    assert body["status"] == "issued"
    assert body["subject_party_id"] == party
    with connection.cursor() as cur:
        cur.execute("SELECT is_deceased FROM mcms_emr.patient WHERE patient_id=%s", [pid])
        assert cur.fetchone()[0] is True
        # guard trigger emitted the event attributed to the patient's PARTY
        cur.execute(
            "SELECT 1 FROM mcms_core.event_log "
            "WHERE kind='patient_deceased' AND subject_party_id=%s", [party])
        assert cur.fetchone(), "patient_deceased event missing"


def test_death_bad_icd10_rejected(admin_client):
    uid = uuid.uuid4().hex[:12]
    with connection.cursor() as cur:
        fac = _fac_id(cur)
        pid, _ = _make_patient(cur, uid, fac)
    r = admin_client.post("/api/vital_records/issue_death/", {
        "patient_id": pid,
        "death_datetime": "2026-07-16T09:00:00+00:00",
        "cause_icd10": "NOT-A-CODE",
        "facility_id": fac,
    }, format="json")
    assert r.status_code == 400


def test_death_double_issue_rejected(admin_client):
    uid = uuid.uuid4().hex[:12]
    with connection.cursor() as cur:
        fac = _fac_id(cur)
        pid, _ = _make_patient(cur, uid, fac)
    body = {"patient_id": pid, "death_datetime": "2026-07-16T09:00:00+00:00",
            "cause_icd10": "I21.9", "facility_id": fac}
    r1 = admin_client.post("/api/vital_records/issue_death/", body, format="json")
    assert r1.status_code == 201
    r2 = admin_client.post("/api/vital_records/issue_death/", body, format="json")
    assert r2.status_code == 409


def test_immutability_amend_creates_new_row(admin_client):
    uid = uuid.uuid4().hex[:12]
    with connection.cursor() as cur:
        fac = _fac_id(cur)
        pid, _ = _make_patient(cur, uid, fac)
    r = admin_client.post("/api/vital_records/issue_death/", {
        "patient_id": pid, "death_datetime": "2026-07-16T09:00:00+00:00",
        "cause_icd10": "I21.9", "facility_id": fac}, format="json")
    cert_id = r.json()["death_cert_id"]
    # amend
    a = admin_client.post("/api/vital_records/amend/", {
        "kind": "death", "cert_id": cert_id}, format="json")
    assert a.status_code == 201, a.content
    new_id = a.json()["new_cert_id"]
    assert new_id != cert_id
    with connection.cursor() as cur:
        cur.execute(
            "SELECT status FROM mcms_vital_records.death_certificate "
            "WHERE death_cert_id IN (%s,%s)", [cert_id, new_id])
        statuses = {row[0] for row in cur.fetchall()}
        assert statuses == {"amended", "issued"}


def test_amend_draft_rejected(admin_client):
    uid = uuid.uuid4().hex[:12]
    with connection.cursor() as cur:
        fac = _fac_id(cur)
        pid, _ = _make_patient(cur, uid, fac)
        cur.execute(
            "INSERT INTO mcms_vital_records.death_certificate "
            "(registration_no, patient_id, facility_id, death_datetime, status) "
            "VALUES (%s,%s,%s,%s,'draft') RETURNING death_cert_id",
            [f"DRAFT-{uid}", pid, fac, "2026-07-16T09:00:00+00:00"])
        cert_id = cur.fetchone()[0]
    a = admin_client.post("/api/vital_records/amend/", {
        "kind": "death", "cert_id": cert_id}, format="json")
    assert a.status_code == 409


def test_fhir_bundle_export(admin_client):
    uid = uuid.uuid4().hex[:12]
    with connection.cursor() as cur:
        fac = _fac_id(cur)
        pid, _ = _make_patient(cur, uid, fac)
    r = admin_client.post("/api/vital_records/issue_death/", {
        "patient_id": pid, "death_datetime": "2026-07-16T09:00:00+00:00",
        "cause_icd10": "I21.9", "facility_id": fac}, format="json")
    cid = r.json()["death_cert_id"]
    exp = admin_client.get(f"/api/vital_records/export_bundle/?kind=death&cert_id={cid}")
    assert exp.status_code == 200
    assert exp.json()["resourceType"] == "Bundle"


def test_external_ingest_creates_draft(admin_client):
    uid = uuid.uuid4().hex[:12]
    with connection.cursor() as cur:
        fac = _fac_id(cur)
        pid, _ = _make_patient(cur, uid, fac)
    r = admin_client.post("/api/vital_records/import_bundle/", {
        "kind": "death", "patient_id": pid,
        "death_datetime": "2026-07-16T09:00:00+00:00",
        "cause_icd10": "I21.9", "facility_id": fac}, format="json")
    assert r.status_code == 201
    assert r.json()["status"] == "draft"


def test_rbac_permissions_seeded():
    with connection.cursor() as cur:
        cur.execute("SELECT code FROM mcms_core.permission "
                    "WHERE code IN ('vital_records.read','vital_records.register','vital_records.certify')")
        codes = {row[0] for row in cur.fetchall()}
        assert codes == {"vital_records.read", "vital_records.register", "vital_records.certify"}


def test_viewset_declares_perms():
    from apps.vital_records.views import VitalRecordsViewSet
    assert VitalRecordsViewSet.required_perms["issue"] == "vital_records.register"
    assert VitalRecordsViewSet.required_perms["GET"] == "vital_records.read"
