"""Phase 9 - Payer integration tests.

Covers eligibility verification and the deterministic claim submit/EOB
round-trip, plus idempotency and unknown-payer rejection. All against
the real seeded payer registry + insurance_claim table.
"""

import uuid

import pytest
from django.db import connection

pytestmark = pytest.mark.django_db(transaction=True)


def _patient_with_policy(payer_code="MOH"):
    with connection.cursor() as cur:
        pid = 900000 + int(uuid.uuid4().hex[:5], 16) % 90000
        cur.execute(
            "INSERT INTO mcms_core.party (party_id, party_type, display_name, "
            "is_active, preferred_language) VALUES (%s,'person','Payer Test',true,'en')",
            [pid])
        cur.execute(
            "INSERT INTO mcms_emr.patient (patient_id, party_id, mrn, "
            "insurance_provider, insurance_policy_no, insurance_group_no, "
            "coverage_verified) VALUES (%s,%s,%s,%s,%s,'G1',false)",
            [pid, pid, f"MRN{pid}", payer_code, f"POL{pid}"])
    return pid


def _claim(patient_id, payer_code="MOH", billed=100.00, rejected=0.00):
    with connection.cursor() as cur:
        # an invoice to attach to
        cur.execute(
            "INSERT INTO mcms_billing.invoice (invoice_no, patient_id, mrn, "
            "issued_by, status, subtotal, tax_amount, discount_amount, "
            "insurance_covers, patient_pays, currency, issued_at) "
            "VALUES (%s,%s,%s,1,'issued',%s,0,0,0,0,'USD',now()) "
            "RETURNING invoice_id",
            [f"INV{uuid.uuid4().hex[:8].upper()}", patient_id, f"MRN{patient_id}",
             billed])
        inv = cur.fetchone()[0]
        cur.execute(
            "INSERT INTO mcms_billing.insurance_claim "
            "(invoice_id, policy_no, insurance_provider, patient_id, billed_amount, "
            "rejected_amount, status) VALUES (%s,%s,%s,%s,%s,%s,'draft') "
            "RETURNING claim_id",
            [inv, f"POL{patient_id}", payer_code, patient_id, billed, rejected])
        return cur.fetchone()[0]


def _admin_post(client, url, data):
    return client.post(url, data=data, format="json")


# --------------------------------------------------------------------- eligibility
def test_eligibility_verified_for_active_policy(admin_client):
    pid = _patient_with_policy("MOH")
    r = _admin_post(admin_client, "/api/payer/eligibility/check/",
                          {"patient_id": pid, "payer_code": "MOH"})
    assert r.status_code == 200, r.data
    assert r.data["status"] == "verified"
    assert r.data["policy_no"]
    # patient.coverage_verified stamped
    with connection.cursor() as cur:
        cur.execute("SELECT coverage_verified FROM mcms_emr.patient WHERE patient_id=%s", [pid])
        assert cur.fetchone()[0] is True


def test_eligibility_denied_unknown_payer(admin_client):
    pid = _patient_with_policy("MOH")
    r = _admin_post(admin_client, "/api/payer/eligibility/check/",
                          {"patient_id": pid, "payer_code": "ZZZ"})
    assert r.status_code == 404


def test_eligibility_denied_no_policy(admin_client):
    pid = _patient_with_policy("MOH")
    with connection.cursor() as cur:
        cur.execute("UPDATE mcms_emr.patient SET insurance_policy_no=NULL WHERE patient_id=%s", [pid])
    r = _admin_post(admin_client, "/api/payer/eligibility/check/",
                          {"patient_id": pid, "payer_code": "MOH"})
    assert r.status_code == 200
    assert r.data["status"] == "denied"


# --------------------------------------------------------------------- claim submit / EOB
def test_claim_submit_approved_paid(admin_client):
    pid = _patient_with_policy("MOH")
    cid = _claim(pid, "MOH", billed=100.00)
    r = _admin_post(admin_client, f"/api/payer/{cid}/submit/", {})
    assert r.status_code == 200, r.data
    assert r.data["status"] == "approved"
    assert r.data["approved_amount"] == "100.00"
    assert r.data["claim_no_external"]
    # claim advanced to paid + EOB written
    with connection.cursor() as cur:
        cur.execute("SELECT status FROM mcms_billing.insurance_claim WHERE claim_id=%s", [cid])
        assert cur.fetchone()[0] == "paid"
        cur.execute("SELECT count(*) FROM mcms_billing.claim_response WHERE claim_id=%s", [cid])
        assert cur.fetchone()[0] == 1


def test_claim_submit_partial(admin_client):
    pid = _patient_with_policy("MOH")
    cid = _claim(pid, "MOH", billed=100.00, rejected=30.00)
    r = _admin_post(admin_client, f"/api/payer/{cid}/submit/", {})
    assert r.status_code == 200, r.data
    assert r.data["status"] == "partial"
    assert r.data["approved_amount"] == "70.00"
    assert r.data["rejected_amount"] == "30.00"


def test_claim_submit_rejected_zero_billed(admin_client):
    pid = _patient_with_policy("MOH")
    cid = _claim(pid, "MOH", billed=0.00)
    r = _admin_post(admin_client, f"/api/payer/{cid}/submit/", {})
    assert r.status_code == 200, r.data
    assert r.data["status"] == "rejected"
    assert r.data["approved_amount"] == "0.00"


def test_claim_submit_idempotent(admin_client):
    pid = _patient_with_policy("MOH")
    cid = _claim(pid, "MOH", billed=100.00)
    r1 = _admin_post(admin_client, f"/api/payer/{cid}/submit/", {})
    r2 = _admin_post(admin_client, f"/api/payer/{cid}/submit/", {})
    assert r1.status_code == 200
    assert r2.status_code == 200
    assert "no re-submit" in r2.data["detail"].lower()
    # EOB written exactly once
    with connection.cursor() as cur:
        cur.execute("SELECT count(*) FROM mcms_billing.claim_response WHERE claim_id=%s", [cid])
        assert cur.fetchone()[0] == 1


def test_claim_submit_unknown_payer_rejected(admin_client):
    pid = _patient_with_policy("MOH")
    cid = _claim(pid, "ZZZ", billed=100.00)  # payer_code ZZZ not in registry
    r = _admin_post(admin_client, f"/api/payer/{cid}/submit/", {})
    assert r.status_code == 422
