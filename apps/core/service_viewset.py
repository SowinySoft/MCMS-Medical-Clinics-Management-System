"""Base for action-only service viewsets.

The dedicated service viewsets (terminology, telemed, payer, identity,
fhir, hl7v2, ai, referral) expose only @action sub-routes. DRF's API root
(and therefore the frontend SchemaBrowser, which enumerates routes from
GET /api/) only lists viewsets that have a `list` route. Without one,
these schemas are invisible in the UI -> "backend without a page".

ServiceViewSet adds a `list` action that returns the inventory of available
sub-routes, so the viewset appears in the API root and the SchemaBrowser can
navigate it. Subclasses keep their existing @action methods unchanged.
"""
from rest_framework.response import Response
from rest_framework.viewsets import ViewSet


class ServiceViewSet(ViewSet):
    def list(self, request, *args, **kwargs):
        actions = []
        for a in self.get_extra_actions():
            actions.append({
                "name": a.url_path or a.__name__,
                "methods": sorted(m.upper() for m in a.mapping.values()),
                "detail": a.detail,
            })
        return Response({
            "service": self.__class__.__name__,
            "actions": actions,
        })
