"""Phase 7 - HL7 v2 ingestion tests.

Covers the parser (unit) and the ingest API (integration): ADT creates a
patient + encounter, SIU books an appointment, ORU lands a lab_result note,
idempotency (MSH-10) is a no-op, and unsupported/malformed messages return the
right ACK. Deterministic and offline.
"""

import uuid

import pytest

pytestmark = pytest.mark.django_db(transaction=True)


def _cid():
    return "MSG" + uuid.uuid4().hex[:12].upper()


def _adt(mrn, cid, trigger="A01", family="DOE", given="JOHN"):
    return "\r".join([
        f"MSH|^~\\&|HIS|FAC1|MCMS|MCMS|20260715120000||ADT^{trigger}|{cid}|P|2.5",
        f"PID|1||{mrn}^^^HIS^MR||{family}^{given}||19800101|M",
        "PV1|1|I|WARD^101^A||||||||||||||||||||||||||||||||||||||20260715120000",
    ])


def _siu(mrn, cid):
    return "\r".join([
        f"MSH|^~\\&|SCHED|FAC1|MCMS|MCMS|20260715120000||SIU^S12|{cid}|P|2.5",
        "SCH||||||Routine checkup|||||^^^20260801090000^20260801093000",
        f"PID|1||{mrn}^^^HIS^MR||DOE^JOHN||19800101|M",
    ])


def _oru(mrn, cid):
    return "\r".join([
        f"MSH|^~\\&|LIS|FAC1|MCMS|MCMS|20260715120000||ORU^R01|{cid}|P|2.5",
        f"PID|1||{mrn}^^^HIS^MR||DOE^JOHN||19800101|M",
        "OBR|1||LAB123|CBC^Complete Blood Count",
        "OBX|1|NM|WBC^White Blood Cells||7.2|10^9/L|4.0-11.0|N",
        "OBX|2|NM|HGB^Hemoglobin||9.1|g/dL|13.0-17.0|L",
    ])


# --------------------------------------------------------------------- parser unit
def test_parser_splits_msh_fields():
    from apps.hl7v2.parser import Message
    msg = Message(_adt("MRNX", "C1"))
    assert msg.msh.get(9, comp=1) == "ADT"
    assert msg.msh.get(9, comp=2) == "A01"
    assert msg.msh.get(10) == "C1"
    assert msg.seg("PID").get(5, comp=1) == "DOE"


def test_parser_strips_mllp_framing():
    from apps.hl7v2.parser import Message
    framed = "\x0b" + _adt("MRNY", "C2").replace("\r", "\r") + "\x1c\r"
    msg = Message(framed)
    assert msg.msh.get(9, comp=1) == "ADT"


# --------------------------------------------------------------------- ADT
def test_ingest_adt_creates_patient_and_encounter(admin_client):
    mrn, cid = f"MRN{uuid.uuid4().hex[:8].upper()}", _cid()
    r = admin_client.post("/api/hl7v2/ingest/",
                          data={"message": _adt(mrn, cid)}, format="json")
    assert r.status_code == 200, r.data
    assert r.data["ack"] == "AA"
    acts = r.data["actions"]
    assert acts["patient_created"] is True
    assert "encounter_id" in acts
    # verify in DB
    from django.db import connection
    with connection.cursor() as cur:
        cur.execute("SELECT mrn FROM mcms_emr.patient WHERE patient_id=%s", [acts["patient_id"]])
        assert cur.fetchone()[0] == mrn


def test_ingest_adt_idempotent_on_control_id(admin_client):
    mrn, cid = f"MRN{uuid.uuid4().hex[:8].upper()}", _cid()
    msg = _adt(mrn, cid)
    r1 = admin_client.post("/api/hl7v2/ingest/", data={"message": msg}, format="json")
    r2 = admin_client.post("/api/hl7v2/ingest/", data={"message": msg}, format="json")
    assert r1.data["ack"] == "AA"
    assert r2.data.get("duplicate") is True
    # only one patient created for this MRN
    from django.db import connection
    with connection.cursor() as cur:
        cur.execute("SELECT count(*) FROM mcms_emr.patient WHERE mrn=%s", [mrn])
        assert cur.fetchone()[0] == 1


# --------------------------------------------------------------------- SIU
def test_ingest_siu_books_appointment(admin_client):
    mrn = f"MRN{uuid.uuid4().hex[:8].upper()}"
    admin_client.post("/api/hl7v2/ingest/", data={"message": _adt(mrn, _cid())}, format="json")
    r = admin_client.post("/api/hl7v2/ingest/", data={"message": _siu(mrn, _cid())}, format="json")
    assert r.status_code == 200, r.data
    assert r.data["ack"] == "AA"
    assert "appointment_id" in r.data["actions"]


def test_ingest_siu_unknown_patient_is_error(admin_client):
    r = admin_client.post("/api/hl7v2/ingest/",
                          data={"message": _siu("NOSUCHMRN999", _cid())}, format="json")
    assert r.data["ack"] == "AE"
    assert "unknown patient" in r.data["error"].lower()


# --------------------------------------------------------------------- ORU
def test_ingest_oru_lands_lab_result_note(admin_client):
    mrn = f"MRN{uuid.uuid4().hex[:8].upper()}"
    admin_client.post("/api/hl7v2/ingest/", data={"message": _adt(mrn, _cid())}, format="json")
    r = admin_client.post("/api/hl7v2/ingest/", data={"message": _oru(mrn, _cid())}, format="json")
    assert r.status_code == 200, r.data
    assert r.data["ack"] == "AA"
    assert r.data["actions"]["obx_count"] == 2
    from django.db import connection
    with connection.cursor() as cur:
        cur.execute("SELECT body, note_type FROM mcms_emr.clinical_note WHERE note_id=%s",
                    [r.data["actions"]["clinical_note_id"]])
        body, ntype = cur.fetchone()
    assert ntype == "lab_result"
    assert "Hemoglobin" in body and "[L]" in body


# --------------------------------------------------------------------- routing / acks
def test_ingest_unsupported_type_is_rejected(admin_client):
    bad = f"MSH|^~\\&|X|FAC1|MCMS|MCMS|20260715120000||MDM^T02|{_cid()}|P|2.5\rPID|1||MRNZ"
    r = admin_client.post("/api/hl7v2/ingest/", data={"message": bad}, format="json")
    assert r.data["ack"] == "AR"


def test_ingest_malformed_is_400(admin_client):
    r = admin_client.post("/api/hl7v2/ingest/", data={"message": "not an hl7 message"},
                          format="json")
    assert r.status_code == 400


def test_messages_audit_log_lists_ingested(admin_client):
    mrn = f"MRN{uuid.uuid4().hex[:8].upper()}"
    admin_client.post("/api/hl7v2/ingest/", data={"message": _adt(mrn, _cid())}, format="json")
    r = admin_client.get("/api/hl7v2/messages/")
    assert r.status_code == 200
    assert r.data["count"] >= 1
    assert any(row["message_type"].startswith("ADT") for row in r.data["results"])
