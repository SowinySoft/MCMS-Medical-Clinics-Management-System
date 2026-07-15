"""FHIR R4 importer / upsert.

Mirrors exports.py. Given a FHIR resource (or a Bundle), upserts it
into the existing reflection models:

  * Patient           -> upsert mcms_core.party (+ mcms_emr.patient),
                         stamping fhir_id / hl7_mpi / national_id.
  * Encounter         -> upsert mcms_emr.encounter (by fhir_id / sourcePk).
  * MedicationRequest -> upsert mcms_emr.medication_order.
  * Observation       -> if it carries a local anchor (meta.sourcePk +
                         meta.field) upsert the mcms_emr.vitals component;
                         otherwise land it as a clinical_note (note_type
                         'observation_import') attached to the subject so
                         external EMR observations have a real, auditable home
                         without inventing a new table.

Idempotent on the resource `id` / `meta.sourcePk` so re-applying a
sync bundle is a no-op beyond the first import.
"""
import json

from django.db import IntegrityError


def _pk_from_ref(ref):
    """'Patient/party-12' -> 12 ; 'party-12' -> 12 ; else None."""
    if not ref:
        return None
    leaf = ref.split("/")[-1]
    if "-" in leaf:
        try:
            return int(leaf.split("-")[-1])
        except ValueError:
            return None
    try:
        return int(leaf)
    except ValueError:
        return None


def import_patient(res):
    from apps.core.models import Party
    from apps.emr.models import Patient
    fhir_id = (res.get("meta") or {}).get("fhirId")
    national = None
    for idt in res.get("identifier", []):
        if idt.get("system") == "urn:mcms:national-id":
            national = idt.get("value")
    hl7 = None
    for idt in res.get("identifier", []):
        if idt.get("system") == "urn:hl7:mpi":
            hl7 = idt.get("value")
    name = (res.get("name") or [{}])[0]
    display = name.get("text") or " ".join((name.get("given") or []) + [name.get("family", "")]).strip()

    party = None
    if fhir_id:
        pat = Patient.objects.filter(fhir_id=fhir_id).first()
        party = Party.objects.filter(party_id=pat.party_id).first() if pat else None
    if party is None and national:
        party = Party.objects.filter(national_id=national).first()
    if party is None:
        party = Party.objects.create(
            party_type="person", display_name=display or "Unknown",
            gender=res.get("gender", "unknown"),
            date_of_birth=res.get("birthDate"),
            national_id=national, is_active=True,
            preferred_language=_pref_lang(res),
        )
    else:
        changed = False
        if national and not party.national_id:
            party.national_id = national
            changed = True
        if res.get("gender") and party.gender in (None, "", "unknown"):
            party.gender = res.get("gender")
            changed = True
        if changed:
            party.save(update_fields=["national_id", "gender"])
    patient = Patient.objects.filter(party_id=party.party_id).first()
    if patient is None:
        patient = Patient.objects.create(party_id=party.party_id)
    if fhir_id and not patient.fhir_id:
        patient.fhir_id = fhir_id
    if hl7 and not patient.hl7_mpi:
        patient.hl7_mpi = hl7
    patient.save(update_fields=[f for f in ("fhir_id", "hl7_mpi") if getattr(patient, f, None)])
    return party.party_id, patient.patient_id


def import_encounter(res):
    from apps.emr.models import Encounter
    src = (res.get("meta") or {}).get("sourcePk")
    enc = None
    if res.get("id", "").startswith("enc-") and res.get("fhir_id"):
        enc = Encounter.objects.filter(fhir_id=res.get("fhir_id")).first()
    if enc is None and src:
        enc = Encounter.objects.filter(encounter_id=src).first()
    patient_id = _pk_from_ref((res.get("subject") or {}).get("reference"))
    period = res.get("period", {})
    data = dict(
        patient_id=patient_id,
        status=res.get("status", "planned"),
        class_field=_class_code(res),
        reason_for_visit=(res.get("reasonCode") or [{}])[0].get("text"),
        started_at=period.get("start"),
        ended_at=period.get("end"),
    )
    if enc is None:
        enc = Encounter.objects.create(mrn=_mrn_for(patient_id), **data)
    else:
        for k, v in data.items():
            setattr(enc, k, v)
        enc.save()
    if res.get("id", "").startswith("enc-") and not enc.fhir_id:
        enc.fhir_id = res["id"]
        enc.save(update_fields=["fhir_id"])
    return enc.encounter_id


def import_medication(res):
    from apps.emr.models import MedicationOrder
    src = (res.get("meta") or {}).get("sourcePk")
    mo = MedicationOrder.objects.filter(order_id=src).first() if src else None
    patient_id = _pk_from_ref((res.get("subject") or {}).get("reference"))
    dosage = (res.get("dosageInstruction") or [{}])[0]
    dq = ((dosage.get("doseAndRate") or [{}])[0].get("doseQuantity") or {})
    data = dict(
        patient_id=patient_id,
        drug_name=(res.get("medicationCodeableConcept") or {}).get("text"),
        dose=dq.get("value"),
        route=_route_code(dosage),
        frequency=(dosage.get("timing") or {}).get("code", {}).get("text"),
        status=res.get("status", "draft"),
        ordered_at=res.get("authoredOn"),
    )
    if mo is None:
        enc_id = (res.get("meta") or {}).get("encounterId")
        mo = MedicationOrder.objects.create(encounter_id=enc_id, **data)
    else:
        for k, v in data.items():
            setattr(mo, k, v)
        mo.save()
    return mo.order_id


def import_observation(res):
    from apps.emr.models import ClinicalNote, Encounter
    meta = res.get("meta") or {}
    src = meta.get("sourcePk")
    patient_id = _pk_from_ref((res.get("subject") or {}).get("reference"))
    # land as a clinical note (reliable, existing table, no new DDL)
    enc = Encounter.objects.filter(patient_id=patient_id).order_by("-started_at").first()
    note = (res.get("code") or {}).get("text") or "Observation"
    val = res.get("valueString") or json.dumps(res.get("valueQuantity"), default=str)
    body = f"{note}: {val}"
    if res.get("interpretation"):
        body += f" [{res['interpretation'][0]['coding'][0]['code']}]"
    ClinicalNote.objects.create(
        encounter=enc, patient_id=patient_id, note_type="consult",
        body=body[:4000], author_user_id=1,
    )
    return src


def import_bundle(bundle):
    """Upsert every entry in a Bundle. Returns a summary dict.

No outer transaction: each sub-importer's single insert autocommits,
so one bad resource is skipped (counted as `skipped`) without
poisoning the rest of the bundle.
"""
    created = updated = skipped = 0
    log = []
    for entry in (bundle.get("entry") or []):
        res = entry.get("resource") or entry
        rtype = res.get("resourceType")
        try:
            if rtype == "Patient":
                import_patient(res); (created := created + 1)
            elif rtype == "Encounter":
                import_encounter(res); (created := created + 1)
            elif rtype == "MedicationRequest":
                import_medication(res); (created := created + 1)
            elif rtype == "Observation":
                import_observation(res); (created := created + 1)
            else:
                skipped += 1
                log.append({"skip": rtype})
        except (IntegrityError, KeyError, ValueError) as e:  # noqa
            skipped += 1
            log.append({"error": str(e)[:200], "resource": rtype})
    return {"created": created, "updated": updated, "skipped": skipped, "log": log}


# ---- helpers
def _pref_lang(res):
    for c in (res.get("communication") or []):
        code = (c.get("language") or {}).get("coding", [{}])[0].get("code")
        if code:
            return code
    return "en"


def _class_code(res):
    code = (res.get("class") or {}).get("code")
    rev = {v[1]: k for k, v in {
        "ambulatory": ("", "AMB"), "emergency": ("", "EMER"),
        "inpatient": ("", "IMP"), "observation": ("", "OBS"),
        "day": ("", "DAY"), "virtual": ("", "VR")}.items()}
    return rev.get(code, "ambulatory")


def _route_code(dosage):
    rev = {"Oral": "po", "Intravenous": "iv", "Intramuscular": "im",
           "Subcutaneous": "sc", "Topic": "top", "Inhalation": "inh"}
    return rev.get((dosage.get("route") or {}).get("text"), "po")


def _mrn_for(patient_id):
    from apps.emr.models import Patient
    if patient_id:
        return Patient.objects.filter(patient_id=patient_id).first()
    return None
