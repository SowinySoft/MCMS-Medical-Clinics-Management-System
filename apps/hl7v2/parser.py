"""Phase 7 - HL7 v2.x ingestion (dependency-free, deterministic).

A minimal pipe-delimited HL7 v2 parser + message router. No external
libraries (keeps it offline/CI-testable, per project convention). Handles the
three feeds a national network needs from existing HIS/LIS/PACS:

  * ADT (A01 admit / A04 register / A08 update) -> upsert emr.patient (by MRN
    or hl7_mpi) + create emr.encounter.
  * SIU (S12 new appt / S13 reschedule)         -> create clinic.appointment.
  * ORU^R01 (lab/obs results)                    -> land OBX rows as
    emr.clinical_note (matches the FHIR observation-import convention; avoids
    the lab_order/sample/test_id FK chain).

Idempotency: every message is keyed on MSH-10 (Message Control ID). A repeat
delivery is a no-op that returns the original ACK. All created rows are stamped
with the ingesting user's facility_id (Phase 6).
"""

from __future__ import annotations

import json

from django.db import connection


class HL7Error(Exception):
    """Raised for malformed or unsupported messages -> AE/AR ack."""


# --------------------------------------------------------------------------- parse
class Segment:
    """One HL7 segment, addressable as seg(field, component=1, repeat=0)."""

    def __init__(self, raw, field_sep="|", comp_sep="^", rep_sep="~"):
        self._raw = raw
        self._field_sep = field_sep
        self._comp_sep = comp_sep
        self._rep_sep = rep_sep
        self.fields = raw.split(field_sep)
        self.name = self.fields[0] if self.fields else ""

    def raw_field(self, idx):
        # MSH is special: MSH-1 is the field separator itself.
        if self.name == "MSH":
            if idx == 1:
                return self._field_sep
            # MSH field numbering: fields[0]='MSH', fields[1]=encoding chars => MSH-2
            return self.fields[idx - 1] if idx - 1 < len(self.fields) else ""
        return self.fields[idx] if idx < len(self.fields) else ""

    def get(self, idx, comp=1, rep=0):
        val = self.raw_field(idx)
        if val == "":
            return ""
        reps = val.split(self._rep_sep)
        chosen = reps[rep] if rep < len(reps) else reps[0]
        comps = chosen.split(self._comp_sep)
        return comps[comp - 1] if comp - 1 < len(comps) else ""


class Message:
    def __init__(self, text):
        # strip MLLP framing (VT ... FS CR) and normalise line endings
        text = text.replace("\x0b", "").replace("\x1c", "")
        text = text.replace("\r\n", "\r").replace("\n", "\r")
        lines = [ln for ln in text.split("\r") if ln.strip()]
        if not lines or not lines[0].startswith("MSH"):
            raise HL7Error("message must start with an MSH segment")
        msh = lines[0]
        # MSH-1 = char after 'MSH'; MSH-2 = next 4 encoding chars
        field_sep = msh[3]
        enc = msh[4:8] if len(msh) >= 8 else "^~\\&"
        comp_sep, rep_sep = enc[0], enc[1]
        self.segments = [
            Segment(ln, field_sep, comp_sep, rep_sep) for ln in lines
        ]

    def seg(self, name):
        for s in self.segments:
            if s.name == name:
                return s
        return None

    def all(self, name):
        return [s for s in self.segments if s.name == name]

    @property
    def msh(self):
        return self.seg("MSH")


def _dt(v):
    """HL7 timestamp YYYYMMDDHHMMSS -> ISO for Django/Postgres, or None."""
    if not v:
        return None
    v = v.strip()
    y, mo, d = v[0:4], v[4:6], v[6:8]
    hh, mm, ss = v[8:10] or "00", v[10:12] or "00", v[12:14] or "00"
    if len(v) < 8:
        return None
    return f"{y}-{mo}-{d} {hh}:{mm}:{ss}"


# --------------------------------------------------------------------------- helpers
def _mrn(msg):
    pid = msg.seg("PID")
    if not pid:
        return ""
    # PID-3 (patient identifier list) preferred, fall back to PID-2
    return pid.get(3) or pid.get(2) or ""


def _find_patient(mrn, mpi):
    from apps.emr.models import Patient
    p = None
    if mrn:
        p = Patient.objects.filter(mrn=mrn).first()
    if p is None and mpi:
        p = Patient.objects.filter(hl7_mpi=mpi).first()
    return p


def _department_default():
    with connection.cursor() as cur:
        cur.execute("SELECT department_id FROM mcms_hr.department ORDER BY department_id LIMIT 1")
        row = cur.fetchone()
    return row[0] if row else None


def _min_user():
    with connection.cursor() as cur:
        cur.execute("SELECT MIN(user_id) FROM mcms_core.app_user")
        return cur.fetchone()[0]


def _stamp(table, pk_col, pk, facility_id):
    """Stamp facility_id on a freshly created row via raw SQL, so we don't
    have to declare facility_id on the inspectdb reflection models."""
    if facility_id is None:
        return
    with connection.cursor() as cur:
        cur.execute(f'UPDATE {table} SET facility_id = %s WHERE "{pk_col}" = %s',
                    [facility_id, pk])


# --------------------------------------------------------------------------- ADT
def handle_adt(msg, facility_id):
    from apps.core.models import Party
    from apps.emr.models import Encounter, Patient

    pid = msg.seg("PID")
    if not pid:
        raise HL7Error("ADT requires a PID segment")
    mrn = _mrn(msg)
    mpi = pid.get(3, comp=1) if pid.get(3, comp=4) == "MPI" else ""
    family = pid.get(5, comp=1)
    given = pid.get(5, comp=2)
    display = f"{given} {family}".strip() or "Unknown"
    gender_map = {"M": "male", "F": "female", "O": "other", "U": "unknown"}
    gender = gender_map.get(pid.get(8).upper(), "unknown")
    dob = _dt(pid.get(7))
    dob = dob.split(" ")[0] if dob else None

    patient = _find_patient(mrn, mpi)
    created = False
    if patient is None:
        party = Party.objects.create(
            party_type="person", display_name=display, gender=gender,
            date_of_birth=dob, is_active=True, preferred_language="en",
        )
        patient = Patient.objects.create(
            party_id=party.party_id, mrn=mrn or f"HL7-{party.party_id}",
        )
        _stamp("mcms_emr.patient", "patient_id", patient.patient_id, facility_id)
        if mpi and not patient.hl7_mpi:
            patient.hl7_mpi = mpi
            patient.save(update_fields=["hl7_mpi"])
        created = True

    actions = {"patient_id": patient.patient_id, "patient_created": created}

    # PV1 -> encounter (A01 admit / A04 register). A08 update may omit PV1.
    pv1 = msg.seg("PV1")
    trigger = msg.msh.get(9, comp=2)
    if pv1 and trigger in ("A01", "A04", "A05"):
        # map HL7 PV1-2 patient class -> encounter_class enum
        pc = (pv1.get(2) or "O").upper()
        class_map = {"I": "inpatient", "O": "ambulatory", "E": "emergency",
                     "P": "ambulatory", "R": "ambulatory", "B": "ambulatory"}
        enc = Encounter.objects.create(
            mrn=patient, patient_id=patient.patient_id,
            status="in_progress" if trigger == "A01" else "planned",
            class_field=class_map.get(pc, "ambulatory"),
            reason_for_visit=(pv1.get(4) or "")[:200] or None,
            started_at=_dt(pv1.get(44)) or _dt(msg.msh.get(7)),
        )
        _stamp("mcms_emr.encounter", "encounter_id", enc.encounter_id, facility_id)
        actions["encounter_id"] = enc.encounter_id
    return actions


# --------------------------------------------------------------------------- SIU
def handle_siu(msg, facility_id):
    from apps.clinic.models import Appointment

    pid = msg.seg("PID")
    sch = msg.seg("SCH")
    if not pid or not sch:
        raise HL7Error("SIU requires PID and SCH segments")
    mrn = _mrn(msg)
    patient = _find_patient(mrn, "")
    if patient is None:
        raise HL7Error(f"SIU: unknown patient MRN {mrn!r} (send ADT first)")

    # SCH-11 = appointment timing quantity; components 4/5 carry start/end
    # datetimes (^^^<start>^<end>). Fall back to MSH time + 30 min.
    start = _dt(sch.get(11, comp=4)) or _dt(msg.msh.get(7))
    end = _dt(sch.get(11, comp=5))
    if not end or (start and end <= start):
        from datetime import datetime, timedelta
        try:
            s = datetime.strptime(start, "%Y-%m-%d %H:%M:%S")
            end = (s + timedelta(minutes=30)).strftime("%Y-%m-%d %H:%M:%S")
        except (TypeError, ValueError):
            end = start
    clinician = _min_user()
    dept = _department_default()
    appt = Appointment.objects.create(
        mrn=patient.mrn, patient_id=patient.patient_id,
        clinician_user_id=clinician, department_id=dept,
        starts_at=start, ends_at=end,
        status="booked", patient_confirmed=False,
        reason=(sch.get(7) or "")[:200] or None,
    )
    _stamp("mcms_clinic.appointment", "appointment_id", appt.appointment_id, facility_id)
    return {"appointment_id": appt.appointment_id, "patient_id": patient.patient_id}


# --------------------------------------------------------------------------- ORU
def handle_oru(msg, facility_id):
    from apps.emr.models import Encounter

    pid = msg.seg("PID")
    if not pid:
        raise HL7Error("ORU requires a PID segment")
    mrn = _mrn(msg)
    patient = _find_patient(mrn, "")
    if patient is None:
        raise HL7Error(f"ORU: unknown patient MRN {mrn!r} (send ADT first)")

    obx_rows = msg.all("OBX")
    if not obx_rows:
        raise HL7Error("ORU has no OBX result segments")
    lines = []
    for obx in obx_rows:
        label = obx.get(3, comp=2) or obx.get(3, comp=1) or "Result"
        value = obx.get(5)
        unit = obx.get(6)
        flag = obx.get(8)
        piece = f"{label}: {value}{(' ' + unit) if unit else ''}"
        if flag:
            piece += f" [{flag}]"
        lines.append(piece)
    enc = Encounter.objects.filter(patient_id=patient.patient_id).order_by("-started_at").first()
    obr = msg.seg("OBR")
    header = (obr.get(4, comp=2) if obr else "") or "Lab/Observation results"
    body = header + "\n" + "\n".join(lines)
    # Raw INSERT: the inspectdb ClinicalNote model mis-types coauthor_ids
    # (bigint[]) as TextField, so the ORM sends '' and Postgres errors. Insert
    # directly and stamp facility_id in the same statement.
    enc_id = enc.encounter_id if enc else None
    if enc_id is None:
        raise HL7Error(f"ORU: no encounter for patient {patient.patient_id} (send ADT first)")
    with connection.cursor() as cur:
        cur.execute(
            "INSERT INTO mcms_emr.clinical_note "
            "(encounter_id, patient_id, note_type, body, author_user_id, signed, facility_id) "
            "VALUES (%s,%s,%s,%s,%s,false,%s) RETURNING note_id",
            [enc_id, patient.patient_id, "lab_result", body[:4000], _min_user(),
             facility_id or 1])
        note_id = cur.fetchone()[0]
    return {"clinical_note_id": note_id,
            "patient_id": patient.patient_id, "obx_count": len(obx_rows)}


# --------------------------------------------------------------------------- router
_ROUTES = {"ADT": handle_adt, "SIU": handle_siu, "ORU": handle_oru}


def ingest(text, facility_id=1, received_by=None):
    """Parse + route one HL7 v2 message. Idempotent on MSH-10.

    Returns a dict: {ack, message_control_id, message_type, actions[, error]}.
    """
    msg = Message(text)
    msh = msg.msh
    mtype_full = f"{msh.get(9, comp=1)}^{msh.get(9, comp=2)}"
    mtype = msh.get(9, comp=1)
    control_id = msh.get(10)
    sending_app = msh.get(3)
    sending_fac = msh.get(4)
    if not control_id:
        raise HL7Error("MSH-10 (Message Control ID) is required for idempotency")

    # idempotency: already ingested -> return original ack, no side effects
    with connection.cursor() as cur:
        cur.execute(
            "SELECT ack_code, actions FROM mcms_core.hl7_message WHERE message_control_id = %s",
            [control_id])
        prior = cur.fetchone()
    if prior:
        return {"ack": prior[0], "message_control_id": control_id,
                "message_type": mtype_full, "actions": prior[1],
                "duplicate": True}

    handler = _ROUTES.get(mtype)
    if handler is None:
        _log(control_id, mtype_full, sending_app, sending_fac, text,
             "AR", f"unsupported message type {mtype_full}", {}, facility_id, received_by)
        return {"ack": "AR", "message_control_id": control_id,
                "message_type": mtype_full, "error": f"unsupported: {mtype_full}",
                "actions": {}}

    try:
        actions = handler(msg, facility_id)
    except HL7Error as e:
        _log(control_id, mtype_full, sending_app, sending_fac, text,
             "AE", str(e), {}, facility_id, received_by)
        return {"ack": "AE", "message_control_id": control_id,
                "message_type": mtype_full, "error": str(e), "actions": {}}

    _log(control_id, mtype_full, sending_app, sending_fac, text,
         "AA", None, actions, facility_id, received_by)
    return {"ack": "AA", "message_control_id": control_id,
            "message_type": mtype_full, "actions": actions}


def _log(control_id, mtype, app, fac, raw, ack, err, actions, facility_id, received_by):
    with connection.cursor() as cur:
        cur.execute(
            "INSERT INTO mcms_core.hl7_message "
            "(message_control_id, message_type, sending_app, sending_facility, raw, "
            " ack_code, error_detail, actions, facility_id, received_by) "
            "VALUES (%s,%s,%s,%s,%s,%s,%s,%s::jsonb,%s,%s) "
            "ON CONFLICT (message_control_id) DO NOTHING",
            [control_id, mtype, app, fac, raw, ack, err,
             json.dumps(actions, default=str), facility_id, received_by])
