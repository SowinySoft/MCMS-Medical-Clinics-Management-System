"""Phase 13 - Identity federation (OIDC / SAML SSO bridge).

Deterministic, offline federation machinery:
  * list configured identity providers
  * exchange a (provider_code, external_subject) assertion for a local
    session: resolve/create the app_user, link via federated_identity,
    REQUIRE data-residency consent (else 422), then issue a standard MCMS
    JWT (reusing the existing token serializer so RBAC enrichment is identical
    to password login).

No live IdP handshake here (discovery / SAML ACS / signature verification are
a separate, deploy-time transport step). The mapping + issuance + consent
gating are fully testable offline.
"""

from django.contrib.auth.models import User
from django.db import connection
from django.utils import timezone
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.core.auth import MCMSTokenObtainPairSerializer
from apps.core.permissions import HasRolePermission
from apps.core.service_viewset import ServiceViewSet


def _rows(sql, params=None):
    with connection.cursor() as cur:
        cur.execute(sql, params or [])
        cols = [d[0] for d in cur.description]
        return [dict(zip(cols, row, strict=False)) for row in cur.fetchall()]


def _require_consent(party_id):
    """Data-residency consent must be granted before federation login."""
    rows = _rows(
        "SELECT 1 FROM mcms_core.consent "
        "WHERE party_id=%s AND consent_type='data_residency' AND granted=true "
        "AND revoked_at IS NULL", [party_id])
    return bool(rows)


class IdentityViewSet(ServiceViewSet):
    permission_classes = [IsAuthenticated, HasRolePermission]
    required_perms = {
        "providers": "admin.all",
        "fed_status": "admin.all",
        "federate": "admin.all",   # federation bridge is an administrative flow
    }

    @action(detail=False, methods=["get"])
    def providers(self, request):
        """List configured external identity providers."""
        rows = _rows(
            "SELECT provider_code, name, protocol, enabled, config "
            "FROM mcms_core.identity_provider ORDER BY provider_code")
        return Response(rows)

    @action(detail=False, methods=["get"])
    def fed_status(self, request):
        """Federation introspection — deterministic, no side effects."""
        provs = _rows(
            "SELECT provider_code, protocol, enabled "
            "FROM mcms_core.identity_provider")
        linked = _rows(
            "SELECT count(*) AS n FROM mcms_core.federated_identity")[0]["n"]
        consent_type_ok = _rows(
            "SELECT 1 FROM pg_type t JOIN pg_enum e ON e.enumtypid=t.oid "
            "WHERE t.typname='consent_type' AND e.enumlabel='data_residency'")
        return Response({
            "federation_supported": True,
            "providers": provs,
            "enabled_providers": [p["provider_code"] for p in provs if p["enabled"]],
            "linked_identities": linked,
            "data_residency_consent_type": bool(consent_type_ok),
            "at": timezone.now().isoformat(),
        })

    @action(detail=False, methods=["post"])
    def federate(self, request):
        """Exchange a federated assertion for a local MCMS session.

        Body: {provider_code, external_subject, display_name?, email?}
        Resolves/creates the local app_user, links the federated identity,
        requires data-residency consent, then issues a JWT.
        """
        provider_code = request.data.get("provider_code")
        ext_sub = request.data.get("external_subject")
        if not provider_code or not ext_sub:
            return Response({"detail": "provider_code and external_subject required"},
                            status=status.HTTP_400_BAD_REQUEST)

        # 1) provider must exist + be enabled
        prov = _rows(
            "SELECT provider_code, protocol, enabled FROM mcms_core.identity_provider "
            "WHERE provider_code=%s", [provider_code])
        if not prov:
            return Response({"detail": "unknown identity provider"},
                            status=status.HTTP_404_NOT_FOUND)
        if not prov[0]["enabled"]:
            return Response({"detail": "identity provider is not enabled"},
                            status=status.HTTP_422_UNPROCESSABLE_ENTITY)

        # 2) resolve existing link
        link = _rows(
            "SELECT user_id FROM mcms_core.federated_identity "
            "WHERE provider_code=%s AND external_subject=%s",
            [provider_code, ext_sub])
        if link:
            user_id = link[0]["user_id"]
            with connection.cursor() as cur:
                cur.execute(
                    "UPDATE mcms_core.federated_identity SET last_seen_at=now() "
                    "WHERE provider_code=%s AND external_subject=%s",
                    [provider_code, ext_sub])
        else:
            # 3) create local user + party + link
            username = f"fed_{provider_code}_{ext_sub}"[:64]
            party_id = _create_party(request.data.get("display_name", username))
            user_id = _create_app_user(username, party_id)
            with connection.cursor() as cur:
                cur.execute(
                    "INSERT INTO mcms_core.federated_identity "
                    "(provider_code, external_subject, user_id) VALUES (%s,%s,%s)",
                    [provider_code, ext_sub, user_id])

        # 4) data-residency consent gate
        if not _require_consent(_party_for_user(user_id)):
            return Response(
                {"detail": "data-residency consent required before federation login"},
                status=status.HTTP_422_UNPROCESSABLE_ENTITY)

        # 5) issue a standard MCMS JWT (identical RBAC enrichment to password login)
        auth_user, _ = User.objects.get_or_create(
            username=username_for_user(user_id),
            defaults={"is_active": True})
        token = MCMSTokenObtainPairSerializer.get_token(auth_user)
        access = str(token.access_token)
        return Response({
            "provider_code": provider_code,
            "protocol": prov[0]["protocol"],
            "user_id": user_id,
            "access": access,
            "token_type": "Bearer",
        }, status=status.HTTP_200_OK)


# --------------------------------------------------------------------- helpers
def _party_for_user(user_id):
    with connection.cursor() as cur:
        cur.execute("SELECT party_id FROM mcms_core.app_user WHERE user_id=%s", [user_id])
        row = cur.fetchone()
    return row[0] if row else None


def username_for_user(user_id):
    with connection.cursor() as cur:
        cur.execute("SELECT username FROM mcms_core.app_user WHERE user_id=%s", [user_id])
        row = cur.fetchone()
    return row[0] if row else None


def _create_party(display_name):
    with connection.cursor() as cur:
        cur.execute(
            "INSERT INTO mcms_core.party (party_type, display_name, is_active, "
            "preferred_language) VALUES ('person',%s,true,'en') RETURNING party_id",
            [display_name])
        return cur.fetchone()[0]


def _create_app_user(username, party_id):
    with connection.cursor() as cur:
        # Federated users have no local password: store a sentinel hash that
        # can never validate, so password login stays impossible for them.
        cur.execute(
            "INSERT INTO mcms_core.app_user (username, party_id, role, "
            "password_hash, is_active, facility_id) "
            "VALUES (%s,%s,'readonly','!federated-no-local-password!',true,1) "
            "RETURNING user_id",
            [username, party_id])
        return cur.fetchone()[0]
