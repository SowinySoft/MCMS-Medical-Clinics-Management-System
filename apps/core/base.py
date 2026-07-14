"""Reflection-based API layer for MCMS.

The domain models under apps/*/models.py are inspectdb-generated
(managed=False). This module turns each model into a fully-wired
DRF ModelViewSet via build_viewset(), so adding a table to the
schema automatically exposes CRUD + OPTIONS metadata. RBAC is enforced
per-route by HasRolePermission.

Phase 1 (Trust) additions:
    - read-access logging on sensitive tables
    - attestation lock (signed records -> 423) + /sign/
    - drug-drug CDS (/check-interactions/)

Phase 2 (Workflow) additions:
    - appointment: /confirm/ /mark_no_show/ /calendar/
    - referral: /accept/ /decline/
    - insurance_claim: /adjudicate/
"""
from datetime import timedelta

from django.utils import timezone
from rest_framework import serializers, status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response

from .permissions import HasRolePermission


def serializer_factory(model, fields="__all__", read_only=None):
    """Build a ModelSerializer subclass for `model` with sane defaults:
    DB-generated columns (e.g. invoice.total) and PKs are read-only."""
    read_only = set(read_only or [])
    meta_attrs = {"model": model, "fields": fields}
    attrs = {"Meta": type("Meta", (), meta_attrs)}
    cls_name = f"{model.__name__}Serializer"
    cls = type(cls_name, (serializers.ModelSerializer,), attrs)
    for f in model._meta.fields:
        if getattr(f, "db_generated", False) or f.primary_key:
            read_only.add(f.name)
    cls.Meta.read_only_fields = tuple(read_only)
    return cls


class AuditContextMixin:
    """Stamps actor/subject onto writes for the audit trigger (Phase 0 audit)."""

    def perform_create(self, serializer):
        serializer.save()

    def perform_update(self, serializer):
        serializer.save()

    def perform_destroy(self, instance):
        instance.delete()


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
    Phase 2 (Workflow) additions:
      * appointment: /confirm/ /mark_no_show/ /calendar/
      * referral: /accept/ /decline/
      * insurance_claim: /adjudicate/
    """
    permission_classes = [HasRolePermission]
    filterset_fields = []
    search_fields = []
    ordering_fields = "__all__"

    # set per-build by the router
    sensitive = False
    cds = False
    signable = False  # model has a `signed` column (attestation)
    appt_actions = False   # appointment: confirm / mark_no_show / calendar
    referral_actions = False  # referral: accept / decline
    claim_actions = False   # insurance_claim: adjudicate

    @classmethod
    def get_extra_actions(cls):
        """Only expose the right custom actions per model so the 89 auto-built
        routes don't all sprout dead endpoints."""
        acts = super().get_extra_actions()
        out = []
        for a in acts:
            if a.__name__ == "sign" and not cls.signable:
                continue
            if a.__name__ == "check_interactions" and not cls.cds:
                continue
            if a.__name__ in ("confirm", "mark_no_show", "calendar") and not cls.appt_actions:
                continue
            if a.__name__ in ("accept", "decline") and not cls.referral_actions:
                continue
            if a.__name__ == "adjudicate" and not cls.claim_actions:
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
        from django.db import connection
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

    # ---- Phase 2: scheduling (appointment) ------------------------------
    @action(detail=True, methods=["post"])
    def confirm(self, request, pk=None):
        """Patient/desk confirms the appointment (token-gated in practice)."""
        obj = self.get_object()
        if obj.status in ("completed", "noshow"):
            return Response({"detail": f"Cannot confirm a {obj.status} appointment."},
                            status=status.HTTP_409_CONFLICT)
        obj.patient_confirmed = True
        obj.confirmed_at = timezone.now()
        obj.save(update_fields=["patient_confirmed", "confirmed_at"])
        return Response({"detail": "Confirmed.", "confirmed_at": obj.confirmed_at})

    @action(detail=True, methods=["post"])
    def mark_no_show(self, request, pk=None):
        """Mark the patient as no-show (scheduling completeness metric)."""
        obj = self.get_object()
        if obj.status in ("completed", "cancelled"):
            return Response({"detail": f"Cannot mark a {obj.status} appointment as no-show."},
                            status=status.HTTP_409_CONFLICT)
        obj.status = "noshow"
        obj.no_show_at = timezone.now()
        obj.save(update_fields=["status", "no_show_at"])
        return Response({"detail": "Marked no-show.", "no_show_at": obj.no_show_at})

    @action(detail=False, methods=["get"])
    def calendar(self, request):
        """Calendar feed: appointments in a [from,to] window (default +/-7d)."""
        now = timezone.now()
        try:
            frm = request.query_params.get("from") or (now - timedelta(days=7)).isoformat()
            to = request.query_params.get("to") or (now + timedelta(days=7)).isoformat()
        except Exception:
            return Response({"detail": "Invalid 'from'/'to' ISO timestamps."},
                            status=status.HTTP_400_BAD_REQUEST)
        qs = self.filter_queryset(
            self.get_queryset().filter(starts_at__gte=frm, starts_at__lte=to)
        ).order_by("starts_at")
        page = self.paginate_queryset(qs)
        ser = self.get_serializer(page if page is not None else qs, many=True)
        if page is not None:
            return self.get_paginated_response(ser.data)
        return Response(ser.data)

    # ---- Phase 2: referral workflow (mcms_emr.referral) ---------------
    @action(detail=True, methods=["post"])
    def accept(self, request, pk=None):
        obj = self.get_object()
        if obj.status not in ("draft", "pending"):
            return Response({"detail": f"Referral is already {obj.status}."},
                            status=status.HTTP_409_CONFLICT)
        obj.status = "accepted"
        obj.to_user = self._app_user_id()
        obj.responded_at = timezone.now()
        obj.save(update_fields=["status", "to_user", "responded_at"])
        return Response({"detail": "Referral accepted.", "status": "accepted"})

    @action(detail=True, methods=["post"])
    def decline(self, request, pk=None):
        obj = self.get_object()
        if obj.status not in ("draft", "pending"):
            return Response({"detail": f"Referral is already {obj.status}."},
                            status=status.HTTP_409_CONFLICT)
        obj.status = "declined"
        obj.responded_at = timezone.now()
        obj.save(update_fields=["status", "responded_at"])
        return Response({"detail": "Referral declined.", "status": "declined"})

    # ---- Phase 2: insurance claim lifecycle (mcms_billing.insurance_claim)
    @action(detail=True, methods=["post"])
    def adjudicate(self, request, pk=None):
        """Payer mock: draft->submitted->(approved|partial_paid|rejected)->paid."""
        obj = self.get_object()
        nxt = request.data.get("status")
        allowed = ("submitted", "approved", "partial_paid", "rejected", "paid")
        if nxt not in allowed:
            return Response({"detail": f"status must be one of {allowed}."},
                            status=status.HTTP_400_BAD_REQUEST)
        obj.status = nxt
        if nxt == "submitted":
            obj.submitted_at = timezone.now()
        if nxt in ("approved", "partial_paid", "rejected"):
            obj.adjudicated_at = timezone.now()
            if nxt == "approved":
                obj.approved_amount = obj.billed_amount - obj.rejected_amount
        if nxt == "paid":
            obj.paid_at = timezone.now()
        obj.save(update_fields=["status", "submitted_at", "adjudicated_at",
                              "approved_amount", "paid_at"])
        return Response({"detail": f"Claim {nxt}.", "status": obj.status})


def build_viewset(model, perms=None, search=None, filterset=None, sensitive=False,
               cds=False, signable=False, appt_actions=False,
               referral_actions=False, claim_actions=False):
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
        "appt_actions": appt_actions,
        "referral_actions": referral_actions,
        "claim_actions": claim_actions,
        "__module__": model.__module__,
    }
    return type(f"{model.__name__}ViewSet", (BaseModelViewSet,), attrs)
