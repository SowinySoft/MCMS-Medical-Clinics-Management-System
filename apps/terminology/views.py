"""Phase 8 - Terminology service API.

  GET  /api/terminology/resolve/?system=loinc&code=718-7   -> concept or 404
  GET  /api/terminology/search/?system=loinc&q=hemoglobin  -> list
  POST /api/terminology/validate/                          -> {codes:[...], system}
       body {"system":"loinc","codes":["718-7","000-0"]}   -> {code: bool}

Deterministic / offline: resolves against mcms_terminology.concept, seeded
from the domain catalogs. Read-only; no external distribution files.
"""

from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.viewsets import ViewSet

from apps.core.permissions import HasRolePermission
from apps.terminology import resolver


class TerminologyViewSet(ViewSet):
    permission_classes = [HasRolePermission]
    required_perms = {
        "resolve": "emr.read",
        "search": "emr.read",
        "validate": "emr.read",
    }

    @action(detail=False, methods=["get"], url_path=r"resolve")
    def resolve(self, request):
        system = request.query_params.get("system")
        code = request.query_params.get("code")
        if not system or not code:
            return Response({"detail": "system and code are required"},
                            status=status.HTTP_400_BAD_REQUEST)
        concept = resolver.resolve(system, code)
        if concept is None:
            return Response(
                {"detail": "unknown code", "system": system, "code": code},
                status=status.HTTP_404_NOT_FOUND)
        return Response(concept)

    @action(detail=False, methods=["get"], url_path=r"search")
    def search(self, request):
        system = request.query_params.get("system")
        q = request.query_params.get("q") or request.query_params.get("query")
        try:
            limit = int(request.query_params.get("limit", 20))
        except (TypeError, ValueError):
            limit = 20
        results = resolver.search(system=system, q=q, limit=min(limit, 200))
        return Response({"count": len(results), "results": results})

    @action(detail=False, methods=["post"], url_path=r"validate")
    def validate(self, request):
        system = request.data.get("system")
        codes = request.data.get("codes") or []
        if not system or not isinstance(codes, list):
            return Response({"detail": "system and codes[] are required"},
                            status=status.HTTP_400_BAD_REQUEST)
        if resolver._norm_system(system) is None:
            return Response({"detail": f"unknown code system {system!r}", "known": resolver.KNOWN_SYSTEMS},
                            status=status.HTTP_400_BAD_REQUEST)
        verdicts = resolver.validate(system, codes)
        return Response({
            "system": system,
            "valid_count": sum(1 for v in verdicts.values() if v),
            "total": len(verdicts),
            "results": verdicts,
        })
