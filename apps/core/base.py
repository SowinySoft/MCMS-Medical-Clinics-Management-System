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
from django.utils import timezone
from rest_framework import serializers, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

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

    Phase 1 (Trust) additions:
      * `sensitive=True`  -> GET-detail logs a row to mcms_core.access_log
        (HIPAA/GDPR per-record read tracing for lab/psych/notes/diagnosis).
      * Models with a `signed` column are attestation-locked: PUT/PATCH/DELETE
        on a signed record returns 423 Locked; POST /sign/ attests it.
    """
    permission_classes = [HasRolePermission]
    filterset_fields = []
    search_fields = []
    ordering_fields = "__all__"

    # set per-build by the router
    sensitive = False
    cds = False
    signable = False  # model has a `signed` column (attestation)

    @classmethod
    def get_extra_actions(cls):
        """Only expose /sign/ on signable models and /check-interactions/ on
        CDS models, so the 89 auto-built routes don't all sprout dead actions."""
        acts = super().get_extra_actions()
        out = []
        for a in acts:
            if a.__name__ == "sign" and not cls.signable:
                continue
            if a.__name__ == "check_interactions" and not cls.cds:
                continue
            out.append(a)
        return out

    # ---- Phase 1 helpers -------------------------------------------------
    def _app_user_id(self):
        from apps.core.models import AppUser
        au = AppUser.objects.filter(username=self.request.user.get_username()).first()
        return au.user_id if au else None

    def _is_signed(self, obj):
        return getattr(obj, "signed", None) in (True, "t", "true")

    # ---- read-access logging (sensitive tables) -------------------------
    def retrieve(self, request, *args, **kwargs):
        resp = super().retrieve(request, *args, **kwargs)
        if self.sensitive:
            self._log_access(resp.data)
        return resp

    def _log_access(self, data):
        from apps.core.models import AccessLog
        from apps.emr.models import Patient
        try:
            pk_name = self.get_queryset().model._meta.pk.name
            row_id = data.get(pk_name) or data.get("id")
            subject_party = None
            pid = data.get("patient_id") or data.get("patient")
            if pid:
                p = Patient.objects.filter(patient_id=pid).first()
                subject_party = p.party_id if p else None
            AccessLog.objects.create(
                reader_user_id=self._app_user_id(),
                subject_party_id=subject_party,
                table_schema=self.get_queryset().model._meta.app_label,
                table_name=self.get_queryset().model.__name__,
                row_id=row_id,
                reason="record view",
            )
        except Exception:
            pass  # access logging must never break a read

    # ---- attestation lock -------------------------------------------------
    def update(self, request, *args, **kwargs):
        obj = self.get_object()
        if self._is_signed(obj):
            return Response({"detail": "Record is signed/attested and locked."},
                            status=status.HTTP_423_LOCKED)
        return super().update(request, *args, **kwargs)

    def partial_update(self, request, *args, **kwargs):
        obj = self.get_object()
        if self._is_signed(obj):
            return Response({"detail": "Record is signed/attested and locked."},
                            status=status.HTTP_423_LOCKED)
        return super().partial_update(request, *args, **kwargs)

    def destroy(self, request, *args, **kwargs):
        obj = self.get_object()
        if self._is_signed(obj):
            return Response({"detail": "Record is signed/attested and locked."},
                            status=status.HTTP_423_LOCKED)
        return super().destroy(request, *args, **kwargs)

    @action(detail=True, methods=["post"])
    def sign(self, request, pk=None):
        """Attest/sign this record (medico-legal e-sign). Idempotent."""
        obj = self.get_object()
        if self._is_signed(obj):
            return Response({"detail": "Already signed.", "signed_at": obj.signed_at},
                            status=status.HTTP_200_OK)
        obj.signed = True
        obj.signed_at = timezone.now()
        obj.signed_by = self._app_user_id()
        obj.save(update_fields=["signed", "signed_at", "signed_by"])
        return Response({"detail": "Signed.", "signed_at": obj.signed_at,
                         "signed_by": obj.signed_by}, status=status.HTTP_200_OK)

    @action(detail=False, methods=["post"])
    def check_interactions(self, request):
        """Phase 1 CDS: drug-drug interaction check for a candidate order.

        Body: {patient_id, drug_item_id} (or drug_name). Returns active
        interactions between the patient's current active meds and the
        candidate drug, drawn from mcms_rx.drug_interaction.
        """
        from django.db import connection

        from apps.emr.models import MedicationOrder
        patient_id = request.data.get("patient_id")
        drug_item_id = request.data.get("drug_item_id")
        if not patient_id or not drug_item_id:
            return Response({"detail": "patient_id and drug_item_id required."},
                            status=status.HTTP_400_BAD_REQUEST)
        active = list(MedicationOrder.objects.filter(
            patient_id=patient_id, status="active"
        ).exclude(drug_item_id__isnull=True).values_list("drug_item_id", flat=True))
        if not active:
            return Response({"interactions": []})
        with connection.cursor() as cur:
            cur.execute(
                """SELECT a.drug_item_id_a, a.drug_item_id_b, a.severity, a.clinical_effect,
                          a.management, di_a.generic_name, di_b.generic_name
                   FROM mcms_rx.drug_interaction a
                   JOIN mcms_rx.drug_item di_a ON di_a.drug_item_id = a.drug_item_id_a
                   JOIN mcms_rx.drug_item di_b ON di_b.drug_item_id = a.drug_item_id_b
                   WHERE (a.drug_item_id_a = ANY(%(ids)s) AND a.drug_item_id_b = %(cand)s)
                      OR (a.drug_item_id_b = ANY(%(ids)s) AND a.drug_item_id_a = %(cand)s)""",
                {"ids": active, "cand": drug_item_id},
            )
            rows = [
                {"drug_item_id_a": r[0], "drug_item_id_b": r[1], "severity": r[2],
                 "clinical_effect": r[3], "management": r[4],
                 "drug_a": r[5], "drug_b": r[6]}
                for r in cur.fetchall()
            ]
        return Response({"interactions": rows})


def build_viewset(model, perms=None, search=None, filterset=None, sensitive=False, cds=False, signable=False):
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
        "sensitive": sensitive,
        "cds": cds,
        "signable": signable,
        "__module__": model.__module__,
    }
    return type(f"{model.__name__}ViewSet", (BaseModelViewSet,), attrs)

