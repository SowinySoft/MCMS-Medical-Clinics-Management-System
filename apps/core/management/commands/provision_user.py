"""
provision_user — create a Django auth user, bridge it into mcms_core.app_user,
and assign an RBAC role.

Usage:
    python manage.py provision_user --username drmona --password pass123 \
        --role doctor --party-name "Dr Mona Kassem"
"""
from django.contrib.auth.models import User
from django.core.management.base import BaseCommand
from django.db import connection


class Command(BaseCommand):
    help = "Provision a Django user bridged to mcms_core.app_user with a role."

    def add_arguments(self, parser):
        parser.add_argument("--username", required=True)
        parser.add_argument("--password", required=True)
        parser.add_argument("--role", required=True, help="mcms_core.role.code")
        parser.add_argument("--party-name", default=None)
        parser.add_argument("--superuser", action="store_true")

    def handle(self, *args, **o):
        u, created = User.objects.get_or_create(username=o["username"])
        u.set_password(o["password"])
        if o["superuser"]:
            u.is_staff = u.is_superuser = True
        u.save()

        pname = o["party_name"] or o["username"]
        # legacy app_user.role enum is informational; real authz is user_role_map.
        LEGACY = {
            "sysadmin": "admin", "doctor": "physician", "nurse": "nurse",
            "pharmacist": "pharmacist", "lab_rad": "lab_tech",
            "accountant": "billing_clerk", "store_mgr": "inventory_clerk",
            "reception": "receptionist",
        }
        legacy_role = LEGACY.get(o["role"], "readonly")
        with connection.cursor() as cur:
            # party
            cur.execute("""
                INSERT INTO mcms_core.party (party_type, display_name)
                VALUES ('person', %s) RETURNING party_id
            """, [pname])
            party_id = cur.fetchone()[0]
            # app_user (bridge by username)
            cur.execute("""
                INSERT INTO mcms_core.app_user (party_id, username, password_hash, role, is_active)
                VALUES (%s, %s, %s, %s::mcms_core.user_role, TRUE)
                ON CONFLICT (username) DO UPDATE SET is_active = TRUE
                RETURNING user_id
            """, [party_id, o["username"], "django-managed", legacy_role])
            user_id = cur.fetchone()[0]
            # role assignment
            cur.execute("SELECT role_id FROM mcms_core.role WHERE code = %s", [o["role"]])
            row = cur.fetchone()
            if not row:
                self.stderr.write(f"Role '{o['role']}' not found in mcms_core.role")
                return
            role_id = row[0]
            cur.execute("""
                INSERT INTO mcms_core.user_role_map (user_id, role_id)
                VALUES (%s, %s) ON CONFLICT DO NOTHING
            """, [user_id, role_id])

        self.stdout.write(self.style.SUCCESS(
            f"Provisioned '{o['username']}' (app_user={user_id}) with role '{o['role']}'."
        ))
