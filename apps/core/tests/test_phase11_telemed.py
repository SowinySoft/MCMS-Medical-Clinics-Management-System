"""Phase 11 - Telemedicine + eRX / formulary tests.

Covers virtual-visit creation, eRX sign with drug-interaction checking and
formulary validation, and formulary search. Deterministic, offline, over
real seeded data (mcms_rx.drug_item / drug_interaction).
"""

import uuid

import pytest
from django.db import connection

pytestmark = pytest.mark.django_db(transaction=True)


def _patient():
    pid = 900000 + int(uuid.uuid4().hex[:5], 16) % 90000
    with connection.cursor() as cur:
        cur.execute(
            "INSERT INTO mcms_core.party (party_id, party_type, display_name, "
            "is_active, preferred_language) VALUES (%s,'person','TM Test',true,'en')",
            [pid])
        cur.execute(
            "INSERT INTO mcms_emr.patient (patient_id, party_id, mrn) "
            "VALUES (%s,%s,%s)", [pid, pid, f"MRN{pid}"])
    return pid, f"MRN{pid}"


# --------------------------------------------------------------------- virtual visit
def test_start_virtual_visit(admin_client):
    pid, mrn = _patient()
    r = admin_client.post("/api/telemed/visit/",
                          data={"patient_id": pid, "mrn": mrn, "mode": "video"},
                          format="json")
    assert r.status_code == 201, r.data
    vid = r.data["visit_id"]
    assert r.data["status"] == "in_progress"
    assert r.data["mode"] == "video"
    # status lookup
    s = admin_client.get(f"/api/telemed/{vid}/visit_status/")
    assert s.status_code == 200
    assert s.data["status"] == "in_progress"


def test_visit_rejects_bad_mode(admin_client):
    pid, mrn = _patient()
    r = admin_client.post("/api/telemed/visit/",
                          data={"patient_id": pid, "mrn": mrn, "mode": "teleport"},
                          format="json")
    assert r.status_code == 400


# --------------------------------------------------------------------- eRX
def test_erx_sign_clean(admin_client):
    pid, mrn = _patient()
    r = admin_client.post("/api/telemed/prescription/",
                          data={"patient_id": pid, "mrn": mrn,
                                "drug_item_id": 1, "dose": "500mg",
                                "route": "PO", "frequency": "BID",
                                "duration_days": 5},
                          format="json")
    assert r.status_code == 201, r.data
    assert r.data["status"] == "signed"
    assert r.data["drug"] == "Paracetamol"
    assert r.data["interaction_severity"] is None


def test_erx_flags_interaction(admin_client):
    pid, mrn = _patient()
    # seed a fresh, deterministic interaction between two formulary drugs
    # (drug 1 and drug 3) plus an active prescription for drug 3, so a new
    # prescription for drug 1 must surface the warning.
    with connection.cursor() as cur:
        cur.execute(
            "INSERT INTO mcms_rx.drug_interaction "
            "(drug_item_id_a, drug_item_id_b, severity, clinical_effect) "
            "VALUES (1,3,'major','test interaction') "
            "ON CONFLICT ON CONSTRAINT uq_interaction_pair DO NOTHING")
        cur.execute(
            "INSERT INTO mcms_rx.prescription "
            "(patient_id, mrn, prescriber_user_id, drug_item_id, status, "
            "signed_at, facility_id) VALUES (%s,%s,1,3,'signed',now(),1)",
            [pid, mrn])
    r = admin_client.post("/api/telemed/prescription/",
                          data={"patient_id": pid, "mrn": mrn,
                                "drug_item_id": 1},
                          format="json")
    assert r.status_code == 201, r.data
    assert r.data["interaction_severity"] in ("low", "moderate", "high")
    assert len(r.data["interactions"]) >= 1


def test_erx_rejects_inactive_drug(admin_client):
    pid, mrn = _patient()
    # create an inactive formulary drug for this test (deterministic)
    with connection.cursor() as cur:
        cur.execute(
            "INSERT INTO mcms_rx.drug_item (generic_name, is_active) "
            "VALUES ('ZZINACTIVE', false) RETURNING drug_item_id", [])
        did = cur.fetchone()[0]
    r = admin_client.post("/api/telemed/prescription/",
                          data={"patient_id": pid, "mrn": mrn,
                                "drug_item_id": did},
                          format="json")
    assert r.status_code == 422


def test_erx_unknown_drug_404(admin_client):
    pid, mrn = _patient()
    r = admin_client.post("/api/telemed/prescription/",
                          data={"patient_id": pid, "mrn": mrn,
                                "drug_item_id": 999999},
                          format="json")
    assert r.status_code == 404


# --------------------------------------------------------------------- formulary
def test_formulary_search(admin_client):
    r = admin_client.get("/api/telemed/formulary/?q=amox")
    assert r.status_code == 200, r.data
    names = [d["generic_name"] for d in r.data]
    assert any("Amoxicillin" in n for n in names)


def test_formulary_controlled_filter(admin_client):
    r = admin_client.get("/api/telemed/formulary/?controlled=true")
    assert r.status_code == 200
    # every returned item is controlled (or empty list)
    assert all(d["controlled_substance"] for d in r.data)
