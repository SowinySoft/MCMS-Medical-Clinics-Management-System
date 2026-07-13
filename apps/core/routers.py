"""
Auto-router — convention-driven API surface.

Walks every domain app, builds a ViewSet per model via the factory, and
registers it at /api/<schema>/<model-slug>/. Permission codes are derived
from a schema→domain map so RBAC is applied uniformly without per-model code.

Pattern: convention over configuration. Adding a table to the DB + rerunning
inspectdb yields a fully secured REST endpoint with zero extra wiring.
"""
import re
from django.apps import apps as django_apps
from rest_framework.routers import DefaultRouter
from apps.core.base import build_viewset

# schema (app label) -> (read_perm, write_perm)
DOMAIN_PERMS = {
    "core":      ("patient.read", "admin.all"),
    "emr":       ("emr.read", "emr.write"),
    "clinic":    ("patient.read", "appointment.manage"),
    "hr":        ("patient.read", "admin.all"),
    "surgical":  ("emr.read", "emr.write"),
    "emergency": ("emr.read", "emr.write"),
    "rx":        ("emr.read", "pharmacy.dispense"),
    "lab":       ("emr.read", "lab_rad.result"),
    "rad":       ("emr.read", "lab_rad.result"),
    "icu":       ("emr.read", "emr.write"),
    "physio":    ("emr.read", "emr.write"),
    "dialysis":  ("emr.read", "emr.write"),
    "nursery":   ("emr.read", "emr.write"),
    "billing":   ("billing.read", "billing.manage"),
    "erp":       ("patient.read", "inventory.manage"),
}

# heuristic search fields by column name presence
SEARCH_CANDIDATES = ["display_name", "name", "code", "mrn", "invoice_no",
                     "po_no", "grn_no", "username", "label", "name_en"]


def _slug(name: str) -> str:
    s = re.sub(r"(?<!^)(?=[A-Z])", "-", name).lower()
    return s


def build_router() -> DefaultRouter:
    router = DefaultRouter()
    for label, (read_p, write_p) in DOMAIN_PERMS.items():
        try:
            app_config = django_apps.get_app_config(label)
        except LookupError:
            continue
        perms = {"SAFE": read_p, "*": write_p}
        for model in app_config.get_models():
            fieldnames = {f.name for f in model._meta.fields}
            search = [c for c in SEARCH_CANDIDATES if c in fieldnames]
            vs = build_viewset(model, perms=perms, search=search)
            prefix = f"{label}/{_slug(model.__name__)}"
            router.register(prefix, vs, basename=f"{label}-{model.__name__.lower()}")
    return router
