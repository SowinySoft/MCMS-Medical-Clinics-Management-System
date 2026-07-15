"""AI coding-assist viewset.

Exposes a deterministic, offline ICD-10 / SNOMED code suggester driven by the
curated `mcms_core.lookup` table. No LLM, no API key, CI-testable.
"""

from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.ai.engine import suggest_codes
from apps.core.permissions import HasRolePermission


class AiViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated, HasRolePermission]
    required_perms = {"suggest_codes": "emr.write"}

    @action(detail=False, methods=["post"])
    def suggest_codes(self, request):
        if (d := self._guard(request)):  # noqa
            return d
        text = (request.data.get("text") or "").strip()
        if not text:
            return Response({"detail": "text is required"}, status=status.HTTP_400_BAD_REQUEST)
        # namespaces default to icd10; allow snomed via query/body
        ns_param = request.data.get("namespaces") or request.query_params.get("namespaces")
        if ns_param:
            namespaces = [n.strip() for n in str(ns_param).replace(",", " ").split() if n.strip()]
        else:
            namespaces = ["icd10"]
        try:
            limit = int(request.query_params.get("limit", 8))
        except (TypeError, ValueError):
            limit = 8
        candidates = suggest_codes(text, namespaces=tuple(namespaces), limit=limit)
        return Response({"text": text, "candidates": candidates})

    def _guard(self, request):
        perms = __import__("apps.core.permissions", fromlist=["effective_perms"]).effective_perms(request)
        if "admin.all" in perms or "emr.write" in perms:
            return None
        return Response({"detail": "Forbidden"}, status=status.HTTP_403_FORBIDDEN)
