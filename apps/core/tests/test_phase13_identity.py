"""Phase 13 - Identity federation tests.

Covers the deterministic, offline federation machinery: provider registry,
federated-login (subject -> local user + JWT issuance) with the data-residency
consent gate, idempotent re-link, and unknown-provider rejection.
"""

import uuid

import pytest
from django.db import connection

pytestmark = pytest.mark.django_db(transaction=True)


def _enable_provider(code):
    with connection.cursor() as cur:
        cur.execute(
            "UPDATE mcms_core.identity_provider SET enabled=true WHERE provider_code=%s",
            [code])


def _grant_consent(party_id, granted_by, ctype="data_residency"):
    with connection.cursor() as cur:
        cur.execute(
            "INSERT INTO mcms_core.consent (party_id, consent_type, granted, granted_by) "
            "VALUES (%s,%s,true,%s) ON CONFLICT DO NOTHING", [party_id, ctype, granted_by])


def _user_for_link(provider_code, ext_sub):
    with connection.cursor() as cur:
        cur.execute(
            "SELECT user_id FROM mcms_core.federated_identity "
            "WHERE provider_code=%s AND external_subject=%s",
            [provider_code, ext_sub])
        row = cur.fetchone()
    return row[0] if row else None


def _party_for_user(user_id):
    with connection.cursor() as cur:
        cur.execute("SELECT party_id FROM mcms_core.app_user WHERE user_id=%s", [user_id])
        row = cur.fetchone()
    return row[0] if row else None


# --------------------------------------------------------------------- registry
def test_providers_listed(admin_client):
    r = admin_client.get("/api/identity/providers/")
    assert r.status_code == 200, r.data
    codes = {p["provider_code"] for p in r.data}
    assert {"moh_oidc", "nhif_saml"} <= codes
    assert all(p["protocol"] in ("oidc", "saml") for p in r.data)


def test_fed_status(admin_client):
    r = admin_client.get("/api/identity/fed_status/")
    assert r.status_code == 200, r.data
    assert r.data["federation_supported"] is True
    assert r.data["data_residency_consent_type"] is True
    assert isinstance(r.data["linked_identities"], int)


def test_unknown_provider_404(admin_client):
    r = admin_client.post("/api/identity/federate/",
                          data={"provider_code": "nope", "external_subject": "x"},
                          format="json")
    assert r.status_code == 404


def test_federate_requires_consent_then_succeeds(admin_client):
    _enable_provider("moh_oidc")
    prov, sub = "moh_oidc", f"sub-{uuid.uuid4().hex}"
    # first attempt: no data-residency consent yet -> 422 (but the local
    # user + link are created so the party exists for consent grant)
    r1 = admin_client.post("/api/identity/federate/",
                           data={"provider_code": prov, "external_subject": sub,
                                 "display_name": "Dr Federated"},
                           format="json")
    assert r1.status_code == 422, r1.data
    # grant the consent to the party that was just created
    uid = _user_for_link(prov, sub)
    assert uid is not None
    _grant_consent(_party_for_user(uid), uid)
    # second attempt: consent present -> 200 + JWT
    r2 = admin_client.post("/api/identity/federate/",
                           data={"provider_code": prov, "external_subject": sub},
                           format="json")
    assert r2.status_code == 200, r2.data
    assert r2.data["protocol"] == "oidc"
    assert r2.data["user_id"] == uid           # idempotent: same local user
    assert r2.data["access"]
    assert r2.data["token_type"] == "Bearer"


def test_disabled_provider_rejected(admin_client):
    # ensure the provider is disabled at the start (self-contained)
    with connection.cursor() as cur:
        cur.execute(
            "UPDATE mcms_core.identity_provider SET enabled=false WHERE provider_code='moh_oidc'")
    r = admin_client.post("/api/identity/federate/",
                          data={"provider_code": "moh_oidc", "external_subject": "x"},
                          format="json")
    assert r.status_code == 422
    assert "not enabled" in r.data["detail"]
