"""
RBAC / ABAC engine — driven by the DB permission matrix in mcms_core.

Pattern: policy-as-data. Roles→permissions live in
mcms_core.role / permission / role_permission / user_role_map, so access
rules are edited in SQL, never in code. Django users map to mcms_core.app_user
by username; their effective permission set is cached per-request.

A ViewSet declares required permission codes via `required_perms`:
    class InvoiceViewSet(BaseModelViewSet):
        required_perms = {"GET": "billing.read", "*": "billing.manage"}
"""
from functools import lru_cache
from django.db import connection
from rest_framework.permissions import BasePermission

SAFE = {"GET", "HEAD", "OPTIONS"}


def _perms_for_username(username: str) -> set[str]:
    """Effective permission codes for a username via the DB matrix."""
    sql = """
        SELECT DISTINCT p.code
        FROM mcms_core.app_user u
        JOIN mcms_core.user_role_map ur ON ur.user_id = u.user_id
        JOIN mcms_core.role_permission rp ON rp.role_id = ur.role_id
        JOIN mcms_core.permission p ON p.permission_id = rp.permission_id
        WHERE u.username = %s AND u.is_active
    """
    with connection.cursor() as cur:
        cur.execute(sql, [username])
        codes = {r[0] for r in cur.fetchall()}
    # admin.all is a superset wildcard
    return codes


def effective_perms(request) -> set[str]:
    if not request.user or not request.user.is_authenticated:
        return set()
    if getattr(request, "_mcms_perms", None) is None:
        request._mcms_perms = _perms_for_username(request.user.get_username())
    return request._mcms_perms


class HasRolePermission(BasePermission):
    """
    Global permission check. A view may expose `required_perms`, a dict keyed
    by HTTP method (or "*"), each value a permission code or iterable of codes.
    Django superusers and holders of 'admin.all' bypass all checks.
    """
    message = "You lack the role permission required for this action."

    def has_permission(self, request, view):
        if not (request.user and request.user.is_authenticated):
            return False
        if request.user.is_superuser:
            return True

        required = getattr(view, "required_perms", None)
        if not required:
            return True  # authenticated is enough when nothing declared

        perms = effective_perms(request)
        if "admin.all" in perms:
            return True

        needed = required.get(request.method) or required.get(
            "SAFE" if request.method in SAFE else "*"
        ) or required.get("*")
        if not needed:
            return True
        if isinstance(needed, str):
            needed = {needed}
        return bool(set(needed) & perms)
