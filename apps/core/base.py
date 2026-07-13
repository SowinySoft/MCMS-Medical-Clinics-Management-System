"""
Reusable DRF base classes — the 'soft' factory layer.

Pattern: generic factory + mixins. Instead of hand-writing a serializer and
viewset per table (89 tables!), we auto-build them:
  * serializer_factory(model)  -> ModelSerializer subclass (fields="__all__")
  * BaseModelViewSet           -> read/write viewset with RBAC + filtering
  * build_viewset(model, ...)  -> a ready ViewSet class for any model

Domain apps only override when they need custom behaviour (validation,
computed fields, extra actions). Everything else is generated.
"""
from rest_framework import serializers, viewsets
from .permissions import HasRolePermission


def serializer_factory(model, fields="__all__", read_only=None):
    """
    Create a ModelSerializer subclass for `model` on the fly.
    Class is namespaced by app label (e.g. PhysioSessionSerializer) so the
    OpenAPI schema never collides on tables that share a name across schemas.
    """
    app = model._meta.app_label
    base = model.__name__
    cls_name = f"{app.capitalize()}{base}Serializer"
    meta = type("Meta", (), {"model": model, "fields": fields})
    attrs = {"Meta": meta}
    if read_only:
        for f in read_only:
            attrs[f] = serializers.ReadOnlyField()
    return type(cls_name, (serializers.ModelSerializer,), attrs)


class AuditContextMixin:
    """Injects the request into serializer context (for user-stamping)."""
    def get_serializer_context(self):
        ctx = super().get_serializer_context()
        ctx["request"] = self.request
        return ctx

    def get_queryset(self):
        qs = super().get_queryset()
        if not qs.ordered:
            pk = qs.model._meta.pk.name if qs.model._meta.pk else None
            if pk:
                qs = qs.order_by(f"-{pk}")
        return qs


class BaseModelViewSet(AuditContextMixin, viewsets.ModelViewSet):
    """
    Standard CRUD viewset with RBAC baked in.
    Subclasses set `queryset`, `serializer_class`, and optionally
    `required_perms`, `filterset_fields`, `search_fields`, `ordering_fields`.
    """
    permission_classes = [HasRolePermission]
    filterset_fields = []
    search_fields = []
    ordering_fields = "__all__"


def build_viewset(model, perms=None, search=None, filterset=None):
    """Generate a fully wired ViewSet class for `model`."""
    ser = serializer_factory(model)
    attrs = {
        "queryset": model.objects.all(),
        "serializer_class": ser,
        "required_perms": perms or {},
        "search_fields": search or [],
        "filterset_fields": filterset or [],
        "__module__": model.__module__,
    }
    return type(f"{model.__name__}ViewSet", (BaseModelViewSet,), attrs)
