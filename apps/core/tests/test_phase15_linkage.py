"""Phase 15 - Systematic referral / linkage recommendation tests.

Deterministic, offline: rules seed into mcms_emr.referral_linkage_rule; the
recommend endpoint ranks target departments by priority for a given clinical
context (diagnosis code and/or source department). RBAC emr.read required.
"""

import pytest
from django.db import connection

pytestmark = pytest.mark.django_db(transaction=True)

_CODE2DEPT = {
    "I21.9": "CARD-DIS",   # AMI -> cardiology
    "C50.9": "ONC-NM",     # breast ca -> oncology & nuclear med
    "E11.9": "MED-GIM",    # T2DM -> general internal medicine
    "A09":   "MED-GIM",    # gastroenteritis -> general internal medicine
    "J20.9": "CHEST",      # bronchitis -> chest diseases
    "I63.9": "NEU-PSY",    # cerebral infarct -> neuro & psych
}


def _dept_id(code):
    with connection.cursor() as cur:
        cur.execute("SELECT department_id FROM mcms_hr.department WHERE code=%s", [code])
        return cur.fetchone()[0]


def test_linkage_rules_listed(admin_client):
    r = admin_client.get("/api/referral/linkage_rules/")
    assert r.status_code == 200
    assert r.json()["count"] >= 15
    # every rule has a resolved to_department name
    for rule in r.json()["rules"]:
        assert rule["to_department"]
        assert rule["to_department_id"]


def test_recommend_by_diagnosis(admin_client):
    r = admin_client.get("/api/referral/recommend/?diagnosis_code=I21.9&code_system=icd10")
    assert r.status_code == 200
    body = r.json()
    assert body["count"] >= 1
    top = body["recommendations"][0]
    # highest priority (lowest number) -> cardiology & cardiovascular
    assert top["department_id"] == _dept_id("CARD-DIS")
    assert top["priority"] <= 20


def test_recommend_diagnosis_ordering_by_priority(admin_client):
    # breast ca maps to ONC-NM (prio 10) before ONC-UNIT (prio 20)
    r = admin_client.get("/api/referral/recommend/?diagnosis_code=C50.9")
    assert r.status_code == 200
    recs = r.json()["recommendations"]
    assert recs[0]["department_id"] == _dept_id("ONC-NM")
    prios = [x["priority"] for x in recs]
    assert prios == sorted(prios)


def test_recommend_by_department(admin_client):
    # ED-MAIN -> CARD-DIS (emergency acute cardiac)
    ed = _dept_id("ED-MAIN")
    r = admin_client.get(f"/api/referral/recommend/?from_department_id={ed}")
    assert r.status_code == 200
    recs = r.json()["recommendations"]
    assert any(x["department_id"] == _dept_id("CARD-DIS") for x in recs)


def test_recommend_diagnosis_or_department(admin_client):
    # supplying both -> union of matches; should still return >=1
    ed = _dept_id("LAB-PATH")
    r = admin_client.get(
        f"/api/referral/recommend/?from_department_id={ed}&diagnosis_code=C50.9")
    assert r.status_code == 200
    assert r.json()["count"] >= 1


def test_recommend_requires_context(admin_client):
    r = admin_client.get("/api/referral/recommend/")
    assert r.status_code == 400


def test_recommend_unknown_code_empty(admin_client):
    r = admin_client.get("/api/referral/recommend/?diagnosis_code=Z99.9")
    assert r.status_code == 200
    assert r.json()["count"] == 0


def test_rbac_required(client):
    # unauthenticated -> 401/403 (not 200)
    r = client.get("/api/referral/linkage_rules/")
    assert r.status_code in (401, 403)
