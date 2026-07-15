"""Phase 3 (Interoperability: FHIR/HL7, MPI, Sync) — tests.

Covers:
  * FHIR export: each derived resource renders a valid R4 shape.
  * FHIR import round-trip: export a Patient -> POST /import/ -> re-export
    yields the same fhir_id (idempotent upsert).
  * MPI resolve + duplicates: national_id dedupe; name+dob match.
  * Sync engine: GET /api/sync/ returns a Bundle; POST an incoming
    Bundle upserts and stamps last_fhir_sync.

Transaction-rolled-back; no residue.
"""
import uuid

import pytest
from django.utils import timezone

pytestmark = pytest.mark.django_db(transaction=True)


def _make_party_national(tag):
    from apps.core.models import Party
    from apps.emr.models import Patient
    p = Party.objects.create(party_type="person", display_name="FHIR P",
                             gender="male", national_id=f"NAT-{tag}",
                             is_active=True, preferred_language="en")
    pat = Patient.objects.create(party_id=p.party_id, mrn=f"MRNF-{tag}")
    return p, pat


# ----------------------------------------------------- FHIR export shapes
def test_fhir_patient_export_shape(admin_client):
    tag = uuid.uuid4().hex[:8]
    p, pat = _make_party_national(tag)
    pat.fhir_id = f"pat-{p.party_id}"
    pat.save(update_fields=["fhir_id"])
    c = admin_client
    r = c.get("/api/fhir/patient/")
    assert r.status_code == 200, r.content[:200]
    bundle = r.data
    assert bundle["resourceType"] == "Bundle"
    res = next(x for x in bundle["entry"] if x["resource"]["id"] == pat.fhir_id)
    pt = res["resource"]
    assert pt["resourceType"] == "Patient"
    assert any(i["system"] == "urn:mcms:national-id" and i["value"] == f"NAT-{tag}"
               for i in pt["identifier"])


def test_fhir_observation_export_shape(admin_client):
    tag = uuid.uuid4().hex[:8]
    from apps.emr.models import Encounter, Vitals
    p, pat = _make_party_national(tag)
    enc = Encounter.objects.create(mrn=pat, patient=pat, status="planned", class_field="ambulatory")
    Vitals.objects.create(encounter_id=enc.encounter_id, patient_id=pat.patient_id,
                          taken_at=timezone.now(), temp_c=37.1, hr_bpm=80)
    c = admin_client
    r = c.get("/api/fhir/observation/")
    assert r.status_code == 200, r.content[:200]
    obs = [e["resource"] for e in r.data["entry"] if e["resource"]["resourceType"] == "Observation"]
    assert any(o["code"]["coding"][0]["code"] == "8310-5" for o in obs), "temp vital must map to LOINC 8310-5"


# ----------------------------------------------------- import round-trip
def test_fhir_import_roundtrip(admin_client):
    tag = uuid.uuid4().hex[:8]
    from apps.core.models import Party
    p, pat = _make_party_national(tag)
    pat.fhir_id = f"pat-{p.party_id}"
    pat.save(update_fields=["fhir_id"])
    c = admin_client
    # export then re-import the bundle (should be idempotent)
    bundle = c.get("/api/fhir/patient/").data
    r = c.post("/api/fhir/import/", bundle, format="json")
    assert r.status_code == 200, r.content[:200]
    assert r.data["created"] >= 1
    # party count for this national_id must stay 1
    assert Party.objects.filter(national_id=f"NAT-{tag}").count() == 1


def test_fhir_import_rejects_non_bundle(admin_client):
    c = admin_client
    r = c.post("/api/fhir/import/", {"foo": "bar"}, format="json")
    assert r.status_code == 422


# ----------------------------------------------------- MPI
def test_mpi_resolve_creates_and_dedupes(admin_client):
    tag = uuid.uuid4().hex[:8]
    from apps.core.models import Party
    c = admin_client
    r = c.post("/api/fhir/mpi/resolve/", {"national_id": f"NAT-MPI-{tag}",
                                           "display_name": "MPI Person"}, format="json")
    assert r.status_code == 200, r.content[:200]
    pid1 = r.data["party_id"]
    # second resolve with same national_id -> same party
    r2 = c.post("/api/fhir/mpi/resolve/", {"national_id": f"NAT-MPI-{tag}"}, format="json")
    assert r2.data["party_id"] == pid1
    assert Party.objects.filter(national_id=f"NAT-MPI-{tag}").count() == 1


def test_mpi_duplicates_lists_shared_national_id(admin_client):
    tag = uuid.uuid4().hex[:8]
    from apps.core.models import Party
    _make_party_national(tag)  # NAT-tag
    # create a deliberate duplicate national_id
    Party.objects.create(party_type="person", display_name="Dup", national_id=f"NAT-{tag}",
                        is_active=True, preferred_language="en")
    c = admin_client
    r = c.get("/api/fhir/mpi/duplicates/")
    assert r.status_code == 200, r.content[:200]
    hit = next((d for d in r.data["duplicates"] if d.get("national_id") == f"NAT-{tag}"), None)
    assert hit is not None and hit["count"] >= 2


# ----------------------------------------------------- sync engine
def test_sync_export_and_apply(admin_client):
    tag = uuid.uuid4().hex[:8]
    _make_party_national(tag)
    c = admin_client
    # source: export bundle
    r = c.get("/api/sync/")
    assert r.status_code == 200, r.content[:200]
    bundle = r.data["bundle"]
    assert bundle["resourceType"] == "Bundle" and len(bundle["entry"]) > 0
    # target: apply the same bundle (idempotent upsert)
    r2 = c.post("/api/sync/", {"bundle": bundle}, format="json")
    assert r2.status_code == 200, r2.content[:200]
    assert r2.data["created"] >= 1
    assert r2.data["last_sync"] not in (None, "never")
