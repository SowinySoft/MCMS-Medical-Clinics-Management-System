"""Phase 5 - Reach: Patient portal tests.

Verifies the self-service portal is strictly scoped to the authenticated
patient's OWN record and gated by consent:
  * appointments / results / bills return only the caller's rows
  * results & bills are 403 until data_sharing consent is granted
  * consents list + toggle work
  * a patient (patient.portal perm) cannot reach clinical data of others
"""

import json

import pytest
from django.contrib.auth.models import User

pytestmark = pytest.mark.django_db(transaction=True)


def _make_patient_user_and_records():
    """Create a patient auth_user + app_user (patient role) + own party/patient
    and a few records, returning (auth_user, patient_id)."""
    import uuid as _uuid
    from datetime import timedelta

    from django.utils import timezone

    from apps.billing.models import Invoice
    from apps.clinic.models import Appointment
    from apps.core.models import AppUser, Party
    from apps.emr.models import Encounter, Patient
    from apps.lab.models import LabOrder, Result, Sample

    tag = _uuid.uuid4().hex[:8]
    PT = f"pt_p5_{tag}"
    auth_user = User.objects.create(username=PT, is_active=True)
    party = Party.objects.create(party_type="person", display_name=f"PtP5-{tag}",
                                 is_active=True, preferred_language="en", gender="female")
    patient = Patient.objects.create(party_id=party.party_id, mrn=f"MRNP5-{tag}")
    enc = Encounter.objects.create(mrn=patient, patient_id=patient.patient_id,
                                   status="planned", class_field="ambulatory")
    # app_user linked to the same username + patient role
    au = AppUser.objects.create(user_id=90000 + int(tag[:6], 16) % 9000, party_id=party.party_id,
                                username=PT, password_hash="x", role="patient",
                                is_active=True, failed_logins=0)
    from django.db import connection
    with connection.cursor() as cur:
        cur.execute("INSERT INTO mcms_core.user_role_map (user_id, role_id) "
                    "SELECT %s, r.role_id FROM mcms_core.role r WHERE r.code='patient' "
                    "ON CONFLICT DO NOTHING", [au.user_id])

    future = timezone.now() + timedelta(days=3)
    Appointment.objects.create(patient_id=patient.patient_id, mrn=patient.mrn,
                               clinician_user_id=1, department_id=1, starts_at=future,
                               ends_at=future + timedelta(hours=1), status="booked",
                               patient_confirmed=False)
    Invoice.objects.create(patient_id=patient.patient_id, mrn=patient.mrn,
                                 invoice_no=f"INV-P5-{tag}",
                                 issued_by=1, status="issued", subtotal=100, tax_amount=5,
                                 discount_amount=0, insurance_covers=0, patient_pays=105,
                                 issued_at=timezone.now())
    order = LabOrder.objects.create(patient_id=patient.patient_id, encounter_id=enc.encounter_id,
                                    order_no=f"ORD-P5-{tag}", mrn=patient.mrn,
                                    requested_by=1, order_priority="routine",
                                    requested_at=timezone.now())
    sample = Sample.objects.create(lab_order_id=order.order_id, specimen_type="blood",
                                   sample_no=f"SMP-P5-{tag}", collected_at=timezone.now())
    Result.objects.create(sample_id=sample.sample_id, test_id=1, flag="normal",
                          verified_at=timezone.now(), value_numeric=5.0)
    return auth_user, patient.patient_id


def _client(client, auth_user):
    client.force_login(auth_user)
    return client


def test_patient_portal_appointments_scoped(client):
    auth_user, pid = _make_patient_user_and_records()
    c = _client(client, auth_user)
    r = c.get("/api/patient/appointments/")
    assert r.status_code == 200, r.content[:200]
    assert r.data["patient_id"] == pid
    assert len(r.data["appointments"]) == 1
    assert r.data["appointments"][0]["patient_id"] == pid


def test_patient_portal_results_blocked_without_consent(client):
    auth_user, pid = _make_patient_user_and_records()
    c = _client(client, auth_user)
    r = c.get("/api/patient/results/")
    assert r.status_code == 403
    assert r.data["consent_required"] == "data_sharing"


def test_patient_portal_results_visible_with_consent(client):
    auth_user, pid = _make_patient_user_and_records()
    c = _client(client, auth_user)
    # grant consent via the portal toggle
    t = c.post("/api/patient/toggle_consent/", data=json.dumps({"consent_type": "data_sharing", "granted": True}), content_type="application/json")
    assert t.status_code == 200 and t.data["granted"] is True
    r = c.get("/api/patient/results/")
    assert r.status_code == 200, r.content[:200]
    assert len(r.data["results"]) == 1
    # revoke -> 403 again
    c.post("/api/patient/toggle_consent/",
           data=json.dumps({"consent_type": "data_sharing", "granted": False}),
           content_type="application/json")
    r2 = c.get("/api/patient/results/")
    assert r2.status_code == 403


def test_patient_portal_bills_scoped_and_consent_gated(client):
    auth_user, pid = _make_patient_user_and_records()
    c = _client(client, auth_user)
    # no consent -> blocked
    assert c.get("/api/patient/bills/").status_code == 403
    c.post("/api/patient/toggle_consent/", data=json.dumps({"consent_type": "data_sharing", "granted": True}), content_type="application/json")
    r = c.get("/api/patient/bills/")
    assert r.status_code == 200
    assert len(r.data["bills"]) == 1
    assert r.data["bills"][0]["patient_id"] == pid


def test_patient_portal_consents_list_and_toggle(client):
    auth_user, pid = _make_patient_user_and_records()
    c = _client(client, auth_user)
    r = c.get("/api/patient/consents/")
    assert r.status_code == 200
    # data_sharing currently not granted for this fresh patient
    types = {x["consent_type"] for x in r.data["consents"]}
    assert "data_sharing" in types
    ds = next(x for x in r.data["consents"] if x["consent_type"] == "data_sharing")
    assert ds["granted"] is False
    # toggle on
    c.post("/api/patient/toggle_consent/", data=json.dumps({"consent_type": "data_sharing", "granted": True}), content_type="application/json")
    r2 = c.get("/api/patient/consents/")
    ds2 = next(x for x in r2.data["consents"] if x["consent_type"] == "data_sharing")
    assert ds2["granted"] is True
