"""Phase 4 - Fly: Intelligence tests.

Covers:
  * AI coding assist: deterministic ICD-10 suggestion from free text.
  * Predictions (ReportViewSet): no-show risk, bed demand, inventory reorder.
  * Anomaly alerts: a non-normal verified lab result emits a critical/warning
    event_log row (surfaces in LiveFeed).
"""

import uuid

import pytest
from django.utils import timezone

pytestmark = pytest.mark.django_db(transaction=True)

_S = uuid.uuid4().hex[:8]


def _party(tag):
    from apps.core.models import Party
    return Party.objects.create(
        party_type="person", display_name=f"P-{tag}", is_active=True,
        preferred_language="en", gender="female",
    )


def _patient(party, tag):
    from apps.emr.models import Patient
    return Patient.objects.create(party_id=party.party_id, mrn=f"MRNPH4-{tag}")


def test_ai_suggest_codes_ranks_icd10(admin_client):
    """Free-text note yields ranked ICD-10 candidates from mcms_core.lookup."""
    note = "Patient presents with chest pain and shortness of breath, suspected myocardial infarction"
    r = admin_client.post("/api/ai/suggest_codes/", {"text": note}, format="json")
    assert r.status_code == 200, r.content[:200]
    cands = r.data["candidates"]
    assert cands, "expected at least one candidate"
    # I21.9 (Acute myocardial infarction) must be present and rank high
    codes = [c["code"] for c in cands]
    assert "I21.9" in codes
    top = cands[0]
    assert top["namespace"] == "icd10"
    assert top["score"] >= 1
    assert "matched" in top and isinstance(top["matched"], list)


def test_ai_suggest_codes_empty_text_rejected(admin_client):
    r = admin_client.post("/api/ai/suggest_codes/", {"text": "   "}, format="json")
    assert r.status_code == 400


def test_ai_suggest_codes_abbreviation_expands(admin_client):
    # 'htn' should map to hypertension -> I10
    r = admin_client.post("/api/ai/suggest_codes/", {"text": "known htn, on treatment"}, format="json")
    assert r.status_code == 200
    codes = [c["code"] for c in r.data["candidates"]]
    assert "I10" in codes


def test_no_show_risk_returns_upcoming(admin_client):
    """Historical noshow patient gets a higher risk score than a clean one."""
    from datetime import timedelta

    from django.utils import timezone

    from apps.clinic.models import Appointment
    future = timezone.now() + timedelta(days=2)

    # patient A: history of 2 no-shows, 0 kept
    pa = _party(f"nsa{_S}")
    pta = _patient(pa, f"nsa{_S}")
    for _ in range(2):
        Appointment.objects.create(
            patient_id=pta.patient_id, mrn=pta.mrn, clinician_user_id=1,
            department_id=1, starts_at=timezone.now() - timedelta(days=10),
            ends_at=timezone.now() - timedelta(days=10) + timedelta(hours=1),
            status="noshow", patient_confirmed=False)
    Appointment.objects.create(
        patient_id=pta.patient_id, mrn=pta.mrn, clinician_user_id=1,
        department_id=1, starts_at=future,
        ends_at=future + timedelta(hours=1), status="booked",
        patient_confirmed=False)

    # patient B: clean history, confirmed
    pb = _party(f"nsb{_S}")
    ptb = _patient(pb, f"nsb{_S}")
    Appointment.objects.create(
        patient_id=ptb.patient_id, mrn=ptb.mrn, clinician_user_id=1,
        department_id=1, starts_at=future,
        ends_at=future + timedelta(hours=1), status="booked",
        patient_confirmed=True)

    r = admin_client.get("/api/reports/no_show_risk/")
    assert r.status_code == 200, r.content[:200]
    rows = r.data
    assert isinstance(rows, list) and len(rows) >= 2
    by_patient = {row["patient_id"]: row for row in rows}
    risk_a = by_patient[pta.patient_id]["risk"]
    risk_b = by_patient[ptb.patient_id]["risk"]
    assert risk_a > risk_b


def test_bed_demand_reports_occupancy(admin_client):
    r = admin_client.get("/api/reports/bed_demand/")
    assert r.status_code == 200, r.content[:200]
    d = r.data
    assert "total_beds" in d and "occupied_now" in d and "available_now" in d
    assert d["total_beds"] >= d["occupied_now"]


def test_inventory_reorder_lists_low_stock(admin_client):
    """An item at/below reorder_level appears in the reorder report."""
    from apps.erp.models import InventoryItem, InventoryStock
    item = InventoryItem.objects.create(
        code=f"PH4-{_S}", name="Reorder Test Item", type="consumable",
        unit="unit", reorder_level=10, reorder_qty=20, cost_per_unit=1.0,
        is_active=True)
    InventoryStock.objects.create(
        item_id=item.item_id, department_id=1, qty_on_hand=3, qty_reserved=0)
    r = admin_client.get("/api/reports/inventory_reorder/")
    assert r.status_code == 200, r.content[:200]
    rows = r.data
    codes = [x["code"] for x in rows]
    assert f"PH4-{_S}" in codes
    row = next(x for x in rows if x["code"] == f"PH4-{_S}")
    assert row["deficit"] >= 0
    assert row["suggested_order_qty"] == 20


def test_abnormal_lab_emits_anomaly_event(admin_client):
    """A critical verified result emits event_log(severity=critical) -> LiveFeed."""
    from apps.emr.models import Encounter
    from apps.lab.models import LabOrder, Result, Sample
    pa = _party(f"lab{_S}")
    pt = _patient(pa, f"lab{_S}")
    enc = Encounter.objects.create(mrn=pt, patient_id=pt.patient_id,
                                   status="in_progress", class_field="ambulatory")
    order = LabOrder.objects.create(patient_id=pt.patient_id,
                                    encounter_id=enc.encounter_id,
                                    order_no=f"ORD-PH4-{_S}", mrn=pt.mrn,
                                    requested_by=1, order_priority="routine",
                                    requested_at=timezone.now())
    sample = Sample.objects.create(lab_order_id=order.order_id,
                                   specimen_type="blood", sample_no=f"SMP-PH4-{_S}",
                                   collected_at=timezone.now())
    res = Result.objects.create(sample_id=sample.sample_id, test_id=1,
                                flag="critical", verified_at=timezone.now(),
                                value_numeric=99.9)
    # verify the anomaly event landed
    from django.db import connection
    with connection.cursor() as cur:
        cur.execute(
            "SELECT severity, payload->>'flag' FROM mcms_core.event_log "
            "WHERE kind='abnormal_result_alert' AND source_id=%s",
            [res.result_id])
        rows = cur.fetchall()
    assert rows, "expected an abnormal_result_alert event"
    assert rows[0][0] == "critical"
    assert rows[0][1] == "critical"
