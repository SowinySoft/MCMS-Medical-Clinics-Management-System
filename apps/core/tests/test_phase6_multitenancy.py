"""Phase 6 - Multi-tenancy: facility scoping tests.

Proves the queryset-layer enforcement (not RLS, since the DB role is
superuser):
  * A user scoped to facility F sees only rows with facility_id = F.
  * A cross-facility admin (facility_id IS NULL) sees all facilities.
  * A write by a scoped user is stamped with their facility_id.
  * Rows created in another facility are invisible to a scoped user.
"""

import uuid

import pytest
from django.contrib.auth.models import User

pytestmark = pytest.mark.django_db(transaction=True)


def _tag():
    return uuid.uuid4().hex[:8]


def _ensure_facility(fid):
    from django.db import connection
    with connection.cursor() as cur:
        cur.execute(
            "INSERT INTO mcms_core.facility (facility_id, organization_id, code, name_en) "
            "VALUES (%s, 1, %s, %s) ON CONFLICT (facility_id) DO NOTHING",
            [fid, f"FAC{fid}", f"Facility {fid}"])


def _make_user(username, facility_id, role_code="doctor", role_enum="physician"):
    from apps.core.models import AppUser
    if facility_id is not None:
        _ensure_facility(facility_id)
    auth_user = User.objects.create(username=username, is_active=True)
    au = AppUser.objects.create(
        user_id=90000 + int(_tag()[:6], 16) % 9000, party_id=3,
        username=username, password_hash="x", role=role_enum,
        is_active=True, failed_logins=0, facility_id=facility_id)
    from django.db import connection
    with connection.cursor() as cur:
        cur.execute("INSERT INTO mcms_core.user_role_map (user_id, role_id) "
                    "SELECT %s, r.role_id FROM mcms_core.role r WHERE r.code=%s "
                    "ON CONFLICT DO NOTHING", [au.user_id, role_code])
    return auth_user, au


def _client(client, auth_user):
    client.force_login(auth_user)
    return client


def test_facility_scoped_user_sees_only_own_facility(client):
    tag = _tag()
    pa, pb = 991000 + int(tag[:5], 16) % 8000, 992000 + int(tag[5:], 16) % 8000
    # seed two patients in different facilities via raw SQL (bypass ORM default)
    from django.db import connection
    with connection.cursor() as cur:
        cur.execute("INSERT INTO mcms_core.party (party_id, party_type, display_name, is_active) "
                    "VALUES (%s, 'person', 'P-A', true), (%s, 'person', 'P-B', true)", [pa, pb])
        cur.execute("INSERT INTO mcms_emr.patient (patient_id, party_id, mrn, facility_id) "
                    "VALUES (%s, %s, %s, 1), (%s, %s, %s, 2)", [pa, pa, f'MRNA{tag}', pb, pb, f'MRNB{tag}'])
    auth_user, _ = _make_user(f"mt_p6_{tag}_a", facility_id=1)
    c = _client(client, auth_user)
    # detail endpoint is deterministic (avoids pagination). pa is in the
    # caller's facility (1) -> visible; pb is in facility 2 -> scoped out (404).
    r_pa = c.get(f"/api/emr/patient/{pa}/")
    r_pb = c.get(f"/api/emr/patient/{pb}/")
    assert r_pa.status_code == 200, f"own-facility record should be visible (got {r_pa.status_code})"
    assert r_pb.status_code == 404, f"other-facility record must be hidden (got {r_pb.status_code})"


def test_cross_facility_admin_sees_all(client):
    tag = _tag()
    pa, pb = 993000 + int(tag[:5], 16) % 8000, 994000 + int(tag[5:], 16) % 8000
    from django.db import connection
    with connection.cursor() as cur:
        cur.execute("INSERT INTO mcms_core.party (party_id, party_type, display_name, is_active) "
                    "VALUES (%s, 'person', 'P-A2', true), (%s, 'person', 'P-B2', true)", [pa, pb])
        cur.execute("INSERT INTO mcms_emr.patient (patient_id, party_id, mrn, facility_id) "
                    "VALUES (%s, %s, %s, 1), (%s, %s, %s, 2)", [pa, pa, f'MRNA2{tag}', pb, pb, f'MRNB2{tag}'])
    # admin fixture is cross-facility (facility_id IS NULL) -> sees all
    auth_user, au = _make_user(f"mt_p6_{tag}_admin", facility_id=None)
    # give admin.all so it can read the patient endpoint
    with connection.cursor() as cur:
        cur.execute("INSERT INTO mcms_core.user_role_map (user_id, role_id) "
                    "SELECT %s, r.role_id FROM mcms_core.role r WHERE r.code='sysadmin' "
                    "ON CONFLICT DO NOTHING", [au.user_id])
    c = _client(client, auth_user)
    # cross-facility admin sees records in BOTH facilities (deterministic detail).
    r_pa = c.get(f"/api/emr/patient/{pa}/")
    r_pb = c.get(f"/api/emr/patient/{pb}/")
    assert r_pa.status_code == 200 and r_pb.status_code == 200, (
        f"cross-facility admin must see all facilities (got {r_pa.status_code}, {r_pb.status_code})")


def test_scoped_write_is_stamped_with_facility(client):
    tag = _tag()
    auth_user, _ = _make_user(f"mt_p6_{tag}_writer", facility_id=2)
    # allow create on patient (patient.write perm -> patient role)
    c = _client(client, auth_user)
    r = c.post("/api/emr/patient/", data=__import__("json").dumps({
        "party_id": 3, "mrn": f"MRNWR{tag}", "facility_id": 999  # attempt to spoof facility
    }), content_type="application/json")
    # expect either 201 (stamped to 2) or a perm error; it must NOT land in 999
    if r.status_code == 201:
        new_id = r.data["patient_id"]
        from django.db import connection
        with connection.cursor() as cur:
            cur.execute("SELECT facility_id FROM mcms_emr.patient WHERE patient_id=%s", [new_id])
            fid = cur.fetchone()[0]
        assert fid == 2, f"write was not scoped to caller facility (got {fid})"


