"""End-to-end happy path: party -> patient -> encounter -> diagnosis ->
medication order -> pharmacy dispensation -> billing invoice.

Uses OPTIONS metadata to learn required fields AND valid choices, so the test
is resilient to the real schema (enums, FKs). Runs in a transaction (rolled
back) leaving no residue. All steps use the admin (sysadmin) client.
"""
import uuid

import pytest

pytestmark = pytest.mark.django_db(transaction=True)

_SUFFIX = uuid.uuid4().hex[:8]


def _uniq(prefix):
    return f"{prefix}-{_SUFFIX}"


def _meta(client, url):
    return client.options(url).data.get("actions", {}).get("POST", {})


def _enum_first_value(model_name, field_name):
    """Resolve the first allowed label of a PostgreSQL enum column when OPTIONS
    does not expose choices. Finds the model by (lowercased) name, gets the DB
    column + its udt_name, then reads pg_enum labels."""
    from django.apps import apps as django_apps
    from django.db import connection
    target = model_name.lower()
    model = None
    for app in django_apps.get_app_configs():
        m = app.models.get(target)
        if m:
            model = m
            break
    if not model:
        return "x"
    field = model._meta.get_field(field_name)
    col = field.column
    db_table = model._meta.db_table  # e.g. mcms_emr"."encounter (inspectdb quoting)
    db_table = db_table.replace('"', '')
    schema, tbl = (db_table.split(".", 1) + [""])[:2] if "." in db_table else ("public", db_table)
    with connection.cursor() as cur:
        cur.execute(
            "SELECT e.enumlabel FROM pg_type t "
            "JOIN pg_enum e ON e.enumtypid=t.oid "
            "WHERE t.typname = (SELECT udt_name FROM information_schema.columns "
            "WHERE table_schema=%s AND table_name=%s AND column_name=%s LIMIT 1)",
            [schema, tbl, col],
        )
        row = cur.fetchone()
        if row:
            return row[0]
    return "x"


def _build(client, url):
    """Build a valid payload for the required fields using OPTIONS metadata."""
    meta = _meta(client, url)
    payload = {}
    model_name = url.rstrip("/").split("/")[-1].replace("-", "")
    for k, v in meta.items():
        if not v.get("required"):
            continue
        if k in ("id", "created_at", "updated_at"):
            continue
        ftype = v.get("type")
        choices = v.get("choices")
        if choices:
            first = choices[0]
            if isinstance(first, dict):
                payload[k] = first.get("value", list(first.values())[0])
            elif isinstance(first, (list, tuple)):
                payload[k] = first[0]
            else:
                payload[k] = first
        elif ftype in ("integer", "number", "float", "decimal"):
            payload[k] = 1
        elif ftype == "boolean":
            payload[k] = True
        elif ftype == "datetime":
            payload[k] = "2026-07-14T10:00:00"
        elif k == "party_id":
            payload[k] = "__PARTY__"
        elif model_name == "party" and k == "party_id":
            # avoid colliding with the test-identity parties (1,2) created by
            # sql/97_test_users.sql; use a high random id (no rollback in tests)
            import random
            payload[k] = random.randint(900000, 999999)
        elif k == "patient" or k == "patient_id":
            payload[k] = "__PATIENT__"
        elif k == "encounter":
            payload[k] = "__ENCOUNTER__"
        elif k == "mrn":
            payload[k] = _uniq("MRN")
        elif k == "invoice_no":
            payload[k] = _uniq("INV")
        elif k == "party_type":
            payload[k] = "person"
        elif k == "display_name":
            payload[k] = "Test Patient"
        elif k == "preferred_language":
            payload[k] = "en"
        elif k == "currency":
            payload[k] = "USD"
        elif k in ("subtotal", "tax_amount", "discount_amount", "insurance_covers", "patient_pays"):
            payload[k] = 100.0
        elif k in ("dispensed_by", "issued_by", "prescriber_user_id", "drug_item"):
            payload[k] = 1
        elif k in ("status", "class_field", "role", "condition_code", "route", "frequency", "dose"):
            # enum fields without OPTIONS choices -> resolve from pg_enum
            payload[k] = _enum_first_value(model_name, k)
        else:
            # last resort: try to resolve a PostgreSQL enum label from the DB
            payload[k] = _enum_first_value(model_name, k)
    return payload


def _post(client, url, payload):
    r = client.post(url, payload, format="json")
    assert r.status_code in (200, 201), f"{url} -> {r.status_code} {r.data}"
    return r


def test_patient_encounter_rx_invoice(admin_client, api_root):
    party_url = api_root["core/party"]
    party = _post(admin_client, party_url, _build(admin_client, party_url))
    party_id = party.data.get("party_id") or party.data.get("id")

    patient_url = api_root["emr/patient"]
    pld = _build(admin_client, patient_url)
    pld["party_id"] = party_id
    patient = _post(admin_client, patient_url, pld)
    patient_id = patient.data.get("patient_id") or patient.data.get("id")

    enc_url = api_root["emr/encounter"]
    eld = _build(admin_client, enc_url)
    eld["patient"] = patient_id
    enc = _post(admin_client, enc_url, eld)
    enc_id = enc.data.get("encounter_id") or enc.data.get("id")

    dx_url = api_root["emr/diagnosis"]
    dxd = _build(admin_client, dx_url)
    dxd["encounter"] = enc_id
    dxd["patient"] = patient_id
    _post(admin_client, dx_url, dxd)

    mo_url = api_root["emr/medication-order"]
    mod = _build(admin_client, mo_url)
    mod["patient"] = patient_id
    _post(admin_client, mo_url, mod)

    rx_url = api_root["rx/dispensation"]
    rxd = _build(admin_client, rx_url)
    rxd["patient_id"] = patient_id
    _post(admin_client, rx_url, rxd)

    inv_url = api_root["billing/invoice"]
    invd = _build(admin_client, inv_url)
    invd["patient_id"] = patient_id
    inv = _post(admin_client, inv_url, invd)
    admin_client.delete(inv_url + str(inv.data.get("invoice_id") or inv.data.get("id")))
