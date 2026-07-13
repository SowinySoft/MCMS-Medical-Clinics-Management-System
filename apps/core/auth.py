"""
JWT authentication layer.

Pattern: token enrichment + DB-backed authorization bridge.
Authentication uses Django's auth_user (secure password hashing, admin, etc.).
Authorization uses the mcms_core RBAC matrix, bridged by username. The access
token carries the effective permission set + roles so the frontend can render
menus without an extra round-trip (the server still re-checks on every call).
"""
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.views import TokenObtainPairView
from apps.core.permissions import _perms_for_username
from django.db import connection


def _roles_for_username(username):
    sql = """
        SELECT DISTINCT r.code
        FROM mcms_core.app_user u
        JOIN mcms_core.user_role_map ur ON ur.user_id = u.user_id
        JOIN mcms_core.role r ON r.role_id = ur.role_id
        WHERE u.username = %s AND u.is_active
    """
    with connection.cursor() as cur:
        cur.execute(sql, [username])
        return [r[0] for r in cur.fetchall()]


class MCMSTokenObtainPairSerializer(TokenObtainPairSerializer):
    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)
        uname = user.get_username()
        token["roles"] = _roles_for_username(uname)
        token["perms"] = sorted(_perms_for_username(uname))
        token["is_superuser"] = user.is_superuser
        return token

    def validate(self, attrs):
        data = super().validate(attrs)
        uname = self.user.get_username()
        data["roles"] = _roles_for_username(uname)
        data["perms"] = sorted(_perms_for_username(uname))
        return data


class MCMSTokenObtainPairView(TokenObtainPairView):
    serializer_class = MCMSTokenObtainPairSerializer
