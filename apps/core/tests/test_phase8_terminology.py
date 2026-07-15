"""Phase 8 - Terminology service tests.

Covers the resolve / search / validate API over the seeded concept table,
and LOINC capture during HL7 ORU ingestion. Deterministic + offline (the
concept table is seeded from real catalog codes in the test DB).
"""

import uuid

import pytest

pytestmark = pytest.mark.django_db(transaction=True)


def _cid():
    return "MSG" + uuid.uuid4().hex[:12].upper()


def _adt(mrn, cid):
    return "\r".join([
        f"MSH|^~\\&|HIS|FAC1|MCMS|MCMS|20260715120000||ADT^A01|{cid}|P|2.5",
        f"PID|1||{mrn}^^^HIS^MR||DOE^JOHN||19800101|M",
        "PV1|1|I|WARD^101^A",
    ])


def _oru(mrn, cid, use_loinc=True):
    obx3 = "718-7^Hemoglobin^LN" if use_loinc else "HGB^Hemoglobin"
    return "\r".join([
        f"MSH|^~\\&|LIS|FAC1|MCMS|MCMS|20260715120000||ORU^R01|{cid}|P|2.5",
        f"PID|1||{mrn}^^^HIS^MR||DOE^JOHN||19800101|M",
        "OBR|1||LAB123|CBC^Complete Blood Count",
        f"OBX|1|NM|{obx3}||9.1|g/dL|13.0-17.0|L",
    ])


# --------------------------------------------------------------------- resolve
def test_resolve_known_loinc(admin_client):
    r = admin_client.get("/api/terminology/resolve/?system=loinc&code=718-7")
    assert r.status_code == 200, r.data
    assert r.data["code"] == "718-7"
    assert r.data["code_system"] == "loinc"
    assert r.data["display"]


def test_resolve_unknown_code_is_404(admin_client):
    r = admin_client.get("/api/terminology/resolve/?system=loinc&code=ZZZ-0")
    assert r.status_code == 404


def test_resolve_missing_params_is_400(admin_client):
    r = admin_client.get("/api/terminology/resolve/?system=loinc")
    assert r.status_code == 400


# --------------------------------------------------------------------- search
def test_search_by_query(admin_client):
    r = admin_client.get("/api/terminology/search/?system=loinc&q=hemoglobin")
    assert r.status_code == 200
    assert r.data["count"] >= 1
    assert any("hemoglobin" in (row["display"] or "").lower() for row in r.data["results"])


def test_search_icd10(admin_client):
    r = admin_client.get("/api/terminology/search/?system=icd10&q=diabetes")
    assert r.status_code == 200
    assert r.data["count"] >= 1


# --------------------------------------------------------------------- validate
def test_validate_batch(admin_client):
    r = admin_client.post("/api/terminology/validate/",
                          data={"system": "loinc", "codes": ["718-7", "ZZZ-0"]},
                          format="json")
    assert r.status_code == 200, r.data
    assert r.data["results"]["718-7"] is True
    assert r.data["results"]["ZZZ-0"] is False
    assert r.data["valid_count"] == 1
    assert r.data["total"] == 2


def test_validate_bad_system_is_400(admin_client):
    r = admin_client.post("/api/terminology/validate/",
                          data={"system": "bogus", "codes": ["x"]}, format="json")
    assert r.status_code == 400


# --------------------------------------------------------------------- ORU capture
def test_oru_captures_loinc_code(admin_client):
    mrn = f"MRN{uuid.uuid4().hex[:8].upper()}"
    admin_client.post("/api/hl7v2/ingest/", data={"message": _adt(mrn, _cid())}, format="json")
    r = admin_client.post("/api/hl7v2/ingest/",
                          data={"message": _oru(mrn, _cid(), use_loinc=True)}, format="json")
    assert r.status_code == 200, r.data
    codes = (r.data.get("actions") or {}).get("codes") or []
    assert any(c["system"] == "loinc" and c["code"] == "718-7" and c["valid"] for c in codes)


def test_oru_without_loinc_has_no_codes(admin_client):
    mrn = f"MRN{uuid.uuid4().hex[:8].upper()}"
    admin_client.post("/api/hl7v2/ingest/", data={"message": _adt(mrn, _cid())}, format="json")
    r = admin_client.post("/api/hl7v2/ingest/",
                          data={"message": _oru(mrn, _cid(), use_loinc=False)}, format="json")
    assert r.status_code == 200, r.data
    assert (r.data.get("actions") or {}).get("codes") == []
