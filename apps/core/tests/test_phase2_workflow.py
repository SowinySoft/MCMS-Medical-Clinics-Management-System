"""Phase 2 (Workflow completeness) — tests.

Covers:
  * Scheduling: appointment confirm / mark_no_show / calendar feed.
  * Referral workflow: accept / decline.
  * Insurance claim lifecycle: adjudicate (draft->submitted->paid).
  * Notification engine: an abnormal lab result auto-creates a notification
    row + a clinical_note attached to the encounter (lab auto-route).

Runs in a transaction (rolled back) leaving no residue.
"""
import uuid
from datetime import timedelta

import pytest
from django.utils import timezone

pytestmark = pytest.mark.django_db(transaction=True)

_S = uuid.uuid4().hex[:8]


def _mk_patient():
    from apps.core.models import AppUser, Party
    from apps.emr.models import Encounter, Patient
    party = Party.objects.create(party_type="person", display_name="P2 Test",
                                 is_active=True, preferred_language="en")
    patient = Patient.objects.create(party_id=party.party_id,
                                   mrn=f"MRN2-{_S}-{uuid.uuid4().hex[:6]}")
    enc = Encounter.objects.create(mrn=patient, patient=patient,
                                 status="planned", class_field="ambulatory")
    return patient, enc, AppUser.objects.get(user_id=1)


# ------------------------------------------------------ scheduling
def test_appointment_confirm_and_noshow(admin_client):
    from apps.clinic.models import Appointment
    patient, enc, _ = _mk_patient()
    appt = Appointment.objects.create(
        mrn=patient.mrn, patient_id=patient.patient_id,
        clinician_user_id=1, department_id=1,
        starts_at=timezone.now(), ends_at=timezone.now() + timedelta(minutes=30),
        status="booked", booked_by=1, patient_confirmed=False,
    )
    r = admin_client.post(f"/api/clinic/appointment/{appt.appointment_id}/confirm/")
    assert r.status_code == 200, r.data
    appt.refresh_from_db()
    assert appt.patient_confirmed is True

    r = admin_client.post(f"/api/clinic/appointment/{appt.appointment_id}/mark_no_show/")
    assert r.status_code == 200, r.data
    appt.refresh_from_db()
    assert appt.status == "noshow" and appt.no_show_at is not None


def test_appointment_calendar_feed(admin_client):
    from apps.clinic.models import Appointment
    patient, enc, _ = _mk_patient()
    Appointment.objects.create(
        mrn=patient.mrn, patient_id=patient.patient_id,
        clinician_user_id=1, department_id=1,
        starts_at=timezone.now(), ends_at=timezone.now() + timedelta(minutes=30),
        status="booked", booked_by=1, patient_confirmed=False,
    )
    r = admin_client.get("/api/clinic/appointment/calendar/")
    assert r.status_code == 200, r.data
    assert isinstance(r.data, (list, dict))  # list or paginated dict


# ------------------------------------------------------ referral
def test_referral_accept_decline(admin_client):
    from apps.emr.models import Referral
    patient, enc, au = _mk_patient()
    ref = Referral.objects.create(
        from_encounter=enc, from_user=au,
        urgency="routine", status="draft",
    )
    r = admin_client.post(f"/api/emr/referral/{ref.referral_id}/accept/")
    assert r.status_code == 200 and r.data["status"] == "accepted", r.data
    ref.refresh_from_db()
    assert ref.status == "accepted"

    # a second referral to exercise decline
    ref2 = Referral.objects.create(
        from_encounter=enc, from_user=au,
        urgency="routine", status="pending",
    )
    r = admin_client.post(f"/api/emr/referral/{ref2.referral_id}/decline/")
    assert r.status_code == 200 and r.data["status"] == "declined", r.data


# ------------------------------------------------------ insurance claim lifecycle
def test_claim_lifecycle_adjudicate(admin_client):
    from apps.billing.models import InsuranceClaim, Invoice
    patient, enc, _ = _mk_patient()
    inv = Invoice.objects.create(
        invoice_no=f"INV2-{_S}-{uuid.uuid4().hex[:6]}", patient_id=patient.patient_id,
        mrn=patient.mrn, issued_by=1, status="issued",
        subtotal=100, tax_amount=5, discount_amount=0,
        insurance_covers=0, patient_pays=105, currency="SAR",
        issued_at=timezone.now(),
    )
    claim = InsuranceClaim.objects.create(
        invoice_id=inv.invoice_id, policy_no="POL-1",
        insurance_provider="ACME", patient_id=patient.patient_id,
        billed_amount=105, rejected_amount=0, status="draft",
    )
    for st in ("submitted", "approved", "paid"):
        r = admin_client.post(
            f"/api/billing/insurance-claim/{claim.claim_id}/adjudicate/",
            {"status": st}, format="json")
        assert r.status_code == 200, (st, r.data)
    claim.refresh_from_db()
    assert claim.status == "paid" and claim.paid_at is not None


# ------------------------------------------------------ notification engine (lab auto-route)
def test_abnormal_lab_result_autoroutes_and_notifies(admin_client):
    from apps.core.models import Notification
    from apps.emr.models import ClinicalNote
    from apps.lab.models import LabOrder, Result, Sample
    patient, enc, _ = _mk_patient()
    order = LabOrder.objects.create(
        order_no=f"ORD2-{_S}", encounter_id=enc.encounter_id,
        patient_id=patient.patient_id, mrn=patient.mrn,
        requested_by=1, order_priority="routine", requested_at=timezone.now(),
    )
    sample = Sample.objects.create(
        sample_no=f"SMP2-{_S}", lab_order_id=order.order_id,
        specimen_type="blood", collected_at=timezone.now(),
    )
    before = Notification.objects.filter(source_table="result").count()
    nnotes = ClinicalNote.objects.filter(encounter=enc, note_type="lab_result").count()
    # simulate a verified abnormal result (the trigger fires on flag change)
    Result.objects.create(
        sample_id=sample.sample_id, test_id=1,
        value_numeric=99, unit="mg/dL", ref_range="70-100",
        flag="high", analysed_by=1, analysed_at=timezone.now(),
        verified_by=1, verified_at=timezone.now(),
    )
    nnotes2 = ClinicalNote.objects.filter(encounter=enc, note_type="lab_result").count()
    after = Notification.objects.filter(source_table="result").count()
    assert nnotes2 == nnotes + 1, "abnormal result must auto-route a clinical note"
    assert after == before + 1, "abnormal result must raise a notification"
