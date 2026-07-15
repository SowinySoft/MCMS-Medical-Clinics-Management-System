"""FHIR R4 exporters.

Pure transform functions that turn the reflection-layer domain models
(Party/Patient, Encounter, vitals/result -> Observation, medication_order
-> MedicationRequest) into FHIR R4 resource dicts. No new tables, no
DB writes -- export only. Importers live in imports.py.

Resource `id` rules (round-trip stable):
  * Patient      -> patient.fhir_id if set else "party-<party_id>"
  * Encounter    -> encounter.fhir_id if set else "enc-<encounter_id>"
  * Observation   -> "obs-vital-<vital_id>" / "obs-result-<result_id>"
  * MedicationRequest -> "med-<order_id>"
The importer (imports.py) maps these back by stripping the prefix, or by
matching fhir_id / national_id / hl7_mpi on upsert.
"""
from datetime import date, datetime


def _dt(v):
    if isinstance(v, (datetime, date)):
        return v.isoformat()
    return v


def _ref(resource_type, rid):
    return {"reference": f"{resource_type}/{rid}"}


# ---------------------------------------------------------------- Patient
def patient_to_fhir(party, patient=None):
    """party: mcms_core.Party; patient: mcms_emr.Patient (optional)."""
    rid = (patient.fhir_id if (patient and patient.fhir_id)
            else f"party-{party.party_id}")
    identifiers = [{"system": "urn:mcms:mrn",
                    "value": patient.mrn}] if patient and patient.mrn else []
    if party.national_id:
        identifiers.append({"system": "urn:mcms:national-id",
                           "value": party.national_id})
    if patient and patient.hl7_mpi:
        identifiers.append({"system": "urn:hl7:mpi",
                           "value": patient.hl7_mpi})
    name = []
    if party.display_name:
        name.append({"text": party.display_name,
                     "family": party.legal_name or party.display_name.split()[-1],
                     "given": party.display_name.split()[:-1] or [party.display_name]})
    res = {
        "resourceType": "Patient",
        "id": rid,
        "identifier": identifiers,
        "name": name,
        "gender": (party.gender or "unknown") if party.gender in ("male", "female", "other", "unknown") else "unknown",
        "communication": [{"language": {"coding": [{"system": "urn:mcms:lang",
                                                       "code": party.preferred_language or "en"}]}}],
        "meta": {"sourcePk": party.party_id, "partyType": party.party_type},
    }
    if party.date_of_birth:
        res["birthDate"] = _dt(party.date_of_birth)
    if patient and patient.fhir_id:
        res["meta"]["fhirId"] = patient.fhir_id
    return res


# ---------------------------------------------------------------- Encounter
_ENC_CLASS = {  # mcms encounter.class_field -> FHIR class coding
    "ambulatory": ("http://terminology.hl7.org/CodeSystem/v3-ActCode", "AMB"),
    "emergency": ("http://terminology.hl7.org/CodeSystem/v3-ActCode", "EMER"),
    "inpatient": ("http://terminology.hl7.org/CodeSystem/v3-ActCode", "IMP"),
    "observation": ("http://terminology.hl7.org/CodeSystem/v3-ActCode", "OBS"),
    "day": ("http://terminology.hl7.org/CodeSystem/v3-ActCode", "DAY"),
    "virtual": ("http://terminology.hl7.org/CodeSystem/v3-ActCode", "VR"),
}


def encounter_to_fhir(enc):
    rid = enc.fhir_id if enc.fhir_id else f"enc-{enc.encounter_id}"
    cls = _ENC_CLASS.get(enc.class_field, ("http://terminology.hl7.org/CodeSystem/v3-ActCode", "AMB"))
    period = {}
    if enc.started_at:
        period["start"] = _dt(enc.started_at)
    if enc.ended_at:
        period["end"] = _dt(enc.ended_at)
    res = {
        "resourceType": "Encounter",
        "id": rid,
        "status": enc.status or "unknown",
        "class": {"system": cls[0], "code": cls[1]},
        "subject": _ref("Patient", f"party-{enc.patient_id}"),
        "period": period,
        "meta": {"sourcePk": enc.encounter_id, "mrn": enc.mrn_id},
    }
    if enc.reason_for_visit:
        res["reasonCode"] = [{"text": enc.reason_for_visit}]
    if enc.chief_complaint:
        res["diagnosis"] = [{"condition": {"display": enc.chief_complaint}}]
    return res


# ---------------------------------------------------------------- Observation
_VITAL_DEFS = [  # (field, loinc-ish code, display, unit)
    ("temp_c", "8310-5", "Body temperature", "Cel"),
    ("hr_bpm", "8867-4", "Heart rate", "/min"),
    ("rr_pm", "9279-1", "Respiratory rate", "/min"),
    ("sbp_mmhg", "8480-6", "Systolic blood pressure", "mm[Hg]"),
    ("dbp_mmhg", "8462-4", "Diastolic blood pressure", "mm[Hg]"),
    ("spo2_pct", "59408-5", "Oxygen saturation", "%"),
    ("weight_kg", "29463-7", "Body weight", "kg"),
    ("height_cm", "8302-2", "Body height", "cm"),
    ("pain_score", "72514-3", "Pain severity", "{score}"),
    ("glucose_mgdl", "2339-0", "Glucose", "mg/dL"),
]


def vitals_to_fhir(v):
    """One Observation per vital sign on a vitals row."""
    out = []
    for field, code, display, unit in _VITAL_DEFS:
        val = getattr(v, field, None)
        if val is None:
            continue
        out.append({
            "resourceType": "Observation",
            "id": f"obs-vital-{v.vital_id}-{field}",
            "status": "final",
            "category": [{"coding": [{"system": "http://terminology.hl7.org/CodeSystem/observation-category",
                                     "code": "vital-signs"}]}],
            "code": {"coding": [{"system": "http://loinc.org", "code": code, "display": display}],
                     "text": display},
            "subject": _ref("Patient", f"party-{v.patient_id}"),
            "encounter": _ref("Encounter", f"enc-{v.encounter_id}") if v.encounter_id else None,
            "effectiveDateTime": _dt(v.taken_at),
            "valueQuantity": {"value": float(val), "unit": unit,
                              "system": "http://unitsofmeasure.org", "code": unit},
            "meta": {"sourcePk": v.vital_id, "field": field},
        })
    return out


_FLAG_SEV = {  # mcms_lab.result.flag -> FHIR interpretation
    "normal": "normal", "low": "L", "high": "H", "critical": "CR",
    "abnormal": "A", "panic": "CR", "equivocal": "A",
}


def result_to_fhir(r):
    val = r.value_numeric if r.value_numeric is not None else r.value_text
    comp = {
        "resourceType": "Observation",
        "id": f"obs-result-{r.result_id}",
        "status": "final" if r.verified_at else ("registered" if r.rejected_at else "preliminary"),
        "category": [{"coding": [{"system": "http://terminology.hl7.org/CodeSystem/observation-category",
                                 "code": "laboratory"}]}],
        "code": {"text": f"test#{r.test_id}"},
        "subject": _ref("Patient", _patient_ref_for_sample(r.sample_id)),
        "effectiveDateTime": _dt(r.analysed_at or r.verified_at),
        "meta": {"sourcePk": r.result_id},
    }
    if isinstance(val, (int, float)):
        comp["valueQuantity"] = {"value": float(val),
                                 "unit": r.unit or "?",
                                 "system": "http://unitsofmeasure.org",
                                 "code": r.unit or "?"}
    else:
        comp["valueString"] = str(val) if val is not None else None
    if r.ref_range:
        comp["referenceRange"] = [{"text": r.ref_range}]
    if r.flag and r.flag in _FLAG_SEV:
        comp["interpretation"] = [{"coding": [{"system": "http://terminology.hl7.org/CodeSystem/v3-ObservationInterpretation",
                                                  "code": _FLAG_SEV[r.flag]}]}]
    return comp


# resolved lazily to avoid an import cycle at module load
_PATIENT_CACHE = {}


def _patient_ref_for_sample(sample_id):
    from apps.lab.models import LabOrder, Sample
    try:
        s = Sample.objects.get(pk=sample_id)
        o = LabOrder.objects.get(pk=s.lab_order_id)
        return f"party-{o.patient_id}"
    except Exception:  # noqa
        return "unknown"


# ---------------------------------------------------------------- MedicationRequest
_ROUTE = {  # mcms_emr.medication_order.route -> display
    "po": "Oral", "iv": "Intravenous", "im": "Intramuscular",
    "sc": "Subcutaneous", "top": "Topical", "inh": "Inhalation",
    "pr": "Rectal", "sl": "Sublingual",
}


def medication_order_to_fhir(mo):
    dosage = []
    if mo.dose:
        di = {"doseAndRate": [{"doseQuantity": {"value": float(mo.dose) if isinstance(mo.dose, (int, float)) else mo.dose}}]}
        if mo.route:
            di["route"] = {"text": _ROUTE.get(mo.route, mo.route)}
        if mo.frequency:
            di["timing"] = {"code": {"text": mo.frequency}}
        dosage.append(di)
    res = {
        "resourceType": "MedicationRequest",
        "id": f"med-{mo.order_id}",
        "status": (mo.status or "unknown").lower(),
        "intent": "order",
        "medicationCodeableConcept": {"text": mo.drug_name or f"drug#{mo.drug_item_id}"},
        "subject": _ref("Patient", f"party-{mo.patient_id}"),
        "authoredOn": _dt(mo.ordered_at),
        "dosageInstruction": dosage,
        "meta": {"sourcePk": mo.order_id, "encounterId": mo.encounter_id},
    }
    if mo.encounter_id:
        res["encounter"] = _ref("Encounter", f"enc-{mo.encounter_id}")
    if mo.signed:
        res["meta"]["signed"] = True
    return res


def to_bundle(resources, base_url=""):
    return {
        "resourceType": "Bundle",
        "type": "collection",
        "timestamp": datetime.now().isoformat(),
        "entry": [{"fullUrl": f"{base_url}/{r['resourceType']}/{r['id']}",
                    "resource": r} for r in resources],
    }
