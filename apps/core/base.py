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
    `created_at`/`updated_at` are DB-managed audit columns (DEFAULT now()) and
    are exposed read-only so create/edit forms never have to supply them.
    Generated columns (e.g. billing.invoice.total) are also read-only so POST
    does not try to write a DB-computed value (which would 500/400). They are
    detected deterministically via Django's GeneratedField, and as a fallback
    via information_schema (inspectdb may model them as plain fields).
    """
    from django.db import connection
    from django.db.models import GeneratedField
    app = model._meta.app_label
    base = model.__name__
    cls_name = f"{app.capitalize()}{base}Serializer"
    meta = type("Meta", (), {"model": model, "fields": fields})
    ro = set(read_only or []) | {"created_at", "updated_at"}
    # deterministic detection: Django GeneratedField
    for f in model._meta.fields:
        if isinstance(f, GeneratedField):
            ro.add(f.name)
    # fallback: live introspection of DB-generated columns
    db_table = model._meta.db_table.replace('"', '')
    schema, tbl = (db_table.split(".", 1) + [""])[:2] if "." in db_table else ("public", db_table)
    try:
        with connection.cursor() as cur:
            cur.execute(
                "SELECT column_name FROM information_schema.columns "
                "WHERE table_schema=%s AND table_name=%s AND is_generated='ALWAYS'",
                [schema, tbl],
            )
            for (col,) in cur.fetchall():
                ro.add(col)
    except Exception:
        pass
    attrs = {"Meta": meta}
    for f in ro:
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
    """Generate a fully wired ViewSet class for `model`.

    The serializer is built lazily on first request (via get_serializer_class)
    rather than at import time: the serializer introspects DB-generated columns
    from information_schema, and that query must run when a live, correct
    database connection is available -- not at Django startup when the dev
    Postgres instance can still be flapping between data directories.
    """
    _ser_cache = {}

    def get_serializer_class(self):
        if model not in _ser_cache:
            _ser_cache[model] = serializer_factory(model)
        return _ser_cache[model]

    attrs = {
        "queryset": model.objects.all(),
        "get_serializer_class": get_serializer_class,
        "required_perms": perms or {},
        "search_fields": search or [],
        "filterset_fields": filterset or [],
        "__module__": model.__module__,
    }
    return type(f"{model.__name__}ViewSet", (BaseModelViewSet,), attrs)
