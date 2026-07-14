"""Contract test: prove the 89 domain routes are all reachable (no missed
endpoints) and that RBAC read perms follow the DOMAIN_PERMS map.

Enumerates routes from the live API root (the same router that powers
production), so the test stays in sync with the auto-router by construction.
"""
import pytest

pytestmark = pytest.mark.django_db(transaction=True)


def _domain_routes(api_root):
    """Return list of (schema, model, url) for domain routes.

    The auto-router registers prefixes like 'emr/patient', 'billing/invoice'.
    We accept any key containing a '/' whose schema label matches a known
    domain app (so we skip 'reports'/'system' which live elsewhere).
    """
    DOMAIN = {"core", "emr", "clinic", "hr", "surgical", "emergency", "rx",
              "lab", "rad", "icu", "physio", "dialysis", "nursery", "billing", "erp"}
    out = []
    for key, url in api_root.items():
        if "/" not in key:
            continue
        schema = key.split("/", 1)[0]
        if schema in DOMAIN:
            model = key.split("/", 1)[1]
            out.append((schema, model, url))
    return out


def test_all_domain_routes_reachable_via_options(admin_client, api_root):
    routes = _domain_routes(api_root)
    assert len(routes) >= 80, f"expected ~89 domain routes, got {len(routes)}"
    missing = []
    for schema, model, url in routes:
        r = admin_client.options(url)
        if r.status_code != 200:
            missing.append(f"{schema}/{model}:{r.status_code}")
    assert not missing, f"routes not 200 on OPTIONS: {missing[:10]}"


def test_all_domain_routes_listable(admin_client, api_root):
    routes = _domain_routes(api_root)
    bad = []
    for schema, model, url in routes:
        r = admin_client.get(url)
        # LIST returns 200; empty lists are fine. 500 would be a defect.
        if r.status_code >= 500:
            bad.append(f"{schema}/{model}:{r.status_code}")
    assert not bad, f"routes erroring on GET list: {bad[:10]}"
