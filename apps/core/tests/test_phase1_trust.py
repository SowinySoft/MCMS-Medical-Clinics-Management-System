"""Phase 1 (Trust) — safety & compliance tests.

Covers:
  * Immutable hash-chained event_log (tamper-evident) + verify_event_chain()
  * Attestation / e-sign: POST /sign/ locks a record (PUT -> 423)
  * Per-record read-access logging on sensitive tables (mcms_core.access_log)
  * Consent CRUD (mcms_core.consent)
  * Drug-drug interaction CDS (/medication-order/check_interactions/)

Runs in a transaction (rolled back) leaving no residue.
"""
import uuid

import pytest
from django.db import connection

pytestmark = pytest.mark.django_db(transaction=True)

_S = uuid.uuid4().hex[:8]


def _mk_patient():
    """Create party -> patient -> encounter via ORM; return (patient, encounter)."""
    from apps.core.models import Party
    from apps.emr.models import Encounter, Patient
    party = Party.objects.create(party_type="person", display_name="P1 Test",
                                 is_active=True, preferred_language="en")
    patient = Patient.objects.create(party_id=party.party_id, mrn=f"MRN-{_S}-{uuid.uuid4().hex[:6]}")
    enc = Encounter.objects.create(mrn=patient, patient=patient,
                                   status="planned", class_field="ambulatory")
    return patient, enc


# ---------------------------------------------------------------- hash chain
def test_event_log_hash_chain_is_tamper_evident():
    with connection.cursor() as cur:
        # append two events -> trigger computes prev_hash + hash linking each
        # row to the current chain head. Capture them to verify locally so the
        # assertion is independent of any rows other tests may have appended.
        ids = []
        for i in range(2):
            cur.execute(
                "INSERT INTO mcms_core.event_log (kind, payload, channel) "
                "VALUES ('login', %s, 'test') RETURNING event_id, seq, prev_hash, hash",
                [f'{{"n": {i}}}'],
            )
            row = cur.fetchone()
            assert row[3], "hash must be populated by trigger"
            ids.append(row[0])
        # the second row's prev_hash must equal the first row's hash (chained)
        cur.execute("SELECT prev_hash, hash FROM mcms_core.event_log WHERE event_id=%s", [ids[0]])
        first_prev, first_hash = cur.fetchone()
        cur.execute("SELECT prev_hash, hash FROM mcms_core.event_log WHERE event_id=%s", [ids[1]])
        second_prev, second_hash = cur.fetchone()
        assert second_prev == first_hash, "each row must chain to the previous hash"
        # global chain verifies clean immediately after well-formed appends
        cur.execute("SELECT count(*) FROM mcms_core.verify_event_chain()")
        assert cur.fetchone()[0] == 0, "well-formed chain must verify"
        # tamper: mutate a payload without recomputing hash -> chain breaks
        cur.execute("UPDATE mcms_core.event_log SET payload='{\"n\": 999}' WHERE event_id=%s", [ids[1]])
        cur.execute("SELECT count(*) FROM mcms_core.verify_event_chain()")
        assert cur.fetchone()[0] >= 1, "tampering must be detected"
        # restore so we don't poison the chain for other tests in this DB
        cur.execute("UPDATE mcms_core.event_log SET payload=%s, hash=%s WHERE event_id=%s",
                    ['{"n": 1}', second_hash, ids[1]])


# ---------------------------------------------------------------- attestation
def test_diagnosis_sign_locks_record(admin_client):
    from apps.emr.models import Diagnosis
    patient, enc = _mk_patient()
    dx = Diagnosis.objects.create(encounter=enc, patient=patient,
                                  condition_code="J06.9", condition_desc="URI",
                                  role="working", status="active")
    # sign it
    r = admin_client.post(f"/api/emr/diagnosis/{dx.diagnosis_id}/sign/")
    assert r.status_code == 200, r.data
    dx.refresh_from_db()
    assert dx.signed is True and dx.signed_at is not None

    # a signed record is locked: PUT must be rejected
    r = admin_client.put(f"/api/emr/diagnosis/{dx.diagnosis_id}/",
                         {"condition_desc": "changed"}, format="json")
    assert r.status_code == 423, f"signed record must be locked, got {r.status_code}"


# ---------------------------------------------------------------- read log
def test_sensitive_read_is_logged(admin_client):
    from apps.core.models import AccessLog
    from apps.emr.models import Diagnosis
    patient, enc = _mk_patient()
    dx = Diagnosis.objects.create(encounter=enc, patient=patient,
                                  condition_code="F32.9", condition_desc="Depression",
                                  role="working", status="active")
    before = AccessLog.objects.filter(row_id=dx.diagnosis_id).count()
    r = admin_client.get(f"/api/emr/diagnosis/{dx.diagnosis_id}/")
    assert r.status_code == 200
    after = AccessLog.objects.filter(row_id=dx.diagnosis_id).count()
    assert after == before + 1, "read of a sensitive record must be logged"


# ---------------------------------------------------------------- consent
def test_consent_crud(admin_client):
    from apps.core.models import Party
    party = Party.objects.create(party_type="person", display_name="Consent Test",
                                 is_active=True, preferred_language="en")
    r = admin_client.post("/api/core/consent/", {
        "party": party.party_id, "consent_type": "data_sharing",
        "granted": True,
    }, format="json")
    assert r.status_code in (200, 201), r.data
    cid = r.data.get("consent_id") or r.data.get("id")
    assert cid
    # unique per (party, type): duplicate should 400
    r2 = admin_client.post("/api/core/consent/", {
        "party": party.party_id, "consent_type": "data_sharing", "granted": False,
    }, format="json")
    assert r2.status_code == 400


# ---------------------------------------------------------------- CDS
def test_drug_interaction_cds(admin_client):
    from django.utils import timezone

    from apps.emr.models import MedicationOrder
    patient, enc = _mk_patient()
    # active order for drug_item 1 (Paracetamol)
    MedicationOrder.objects.create(
        patient=patient, encounter=enc, prescriber_user_id=1,
        drug_item_id=1, drug_name="Paracetamol", dose="500mg",
        route="po", frequency="TID", refill_count=0, status="active",
        ordered_at=timezone.now(),
    )
    # candidate: drug_item 2 (Ibuprofen) -> interacts with Paracetamol (seed row 1,2)
    r = admin_client.post("/api/emr/medication-order/check_interactions/", {
        "patient_id": patient.patient_id, "drug_item_id": 2,
    }, format="json")
    assert r.status_code == 200, r.data
    inter = r.data.get("interactions", [])
    assert any(i["severity"] for i in inter), f"expected an interaction, got {inter}"
