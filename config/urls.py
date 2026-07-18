"""
MCMS URL configuration.
  /api/                        -> auto-registered CRUD endpoints (89 tables)
  /api/auth/token/             -> JWT obtain (enriched with roles+perms)
  /api/auth/token/refresh/     -> JWT refresh
  /api/schema/                 -> OpenAPI schema (drf-spectacular)
  /api/docs/                   -> Swagger UI
  /api/redoc/                  -> ReDoc
"""
from django.contrib import admin
from django.urls import include, path, re_path
from django.views.static import serve as static_serve
import os

from django.conf import settings as _djsettings
BASE_DIR = _djsettings.BASE_DIR

from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularRedocView,
    SpectacularSwaggerView,
)
from rest_framework_simplejwt.views import TokenRefreshView

from apps.ai.views import AiViewSet
from apps.core.admin_panel import SystemViewSet, landing
from apps.core.auth import MCMSTokenObtainPairView
from apps.core.reports import ReportViewSet
from apps.core.routers import build_router
from apps.fhir.views import FhirViewSet, SyncViewSet
from apps.hl7v2.views import HL7V2ViewSet
from apps.identity.views import IdentityViewSet
from apps.patient.views import PatientPortalViewSet
from apps.payer.views import PayerViewSet
from apps.referral.views import ReferralViewSet
from apps.telemed.views import TelemedViewSet
from apps.terminology.views import TerminologyViewSet
from apps.vital_records.views import VitalRecordsViewSet

router = build_router()
router.register("reports", ReportViewSet, basename="reports")
router.register("system", SystemViewSet, basename="system")
router.register("fhir", FhirViewSet, basename="fhir")
router.register("ai", AiViewSet, basename="ai")
router.register("patient", PatientPortalViewSet, basename="patient")
router.register("hl7v2", HL7V2ViewSet, basename="hl7v2")
router.register("terminology", TerminologyViewSet, basename="terminology")
router.register("payer", PayerViewSet, basename="payer")
router.register("telemed", TelemedViewSet, basename="telemed")
router.register("identity", IdentityViewSet, basename="identity")
router.register("referral", ReferralViewSet, basename="referral")
router.register("vital_records", VitalRecordsViewSet, basename="vital_records")

urlpatterns = [
    path("", landing, name="landing"),
    path("admin/", admin.site.urls),
    path("api/sync/", SyncViewSet.as_view({"get": "sync", "post": "sync"})),
    path("api/", include(router.urls)),
    path("api/auth/token/", MCMSTokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/auth/token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="swagger-ui"),
    path("api/redoc/", SpectacularRedocView.as_view(url_name="schema"), name="redoc"),
    # SPA catch-all: any non-/api GET path serves the built SPA (client-side
    # routing). Must stay LAST and must NOT match static asset paths, which
    # are served explicitly below via static.serve (correct MIME under ASGI).
    re_path(r"^(?!api/|assets/|static/|favicon\.svg|manifest\.webmanifest|sw\.js|icons/).*$", landing, name="spa"),
]

# --- SPA static assets (served by Django; correct Content-Type under Daphne/ASGI)
# WhiteNoise was unreliable here, so we serve frontend/dist explicitly.
_SPA_DIST = os.path.join(BASE_DIR, "frontend", "dist")
urlpatterns += [
    re_path(r"^assets/(?P<path>.*)$", static_serve, {"document_root": os.path.join(_SPA_DIST, "assets")}),
    re_path(r"^(?P<path>favicon\.svg|manifest\.webmanifest|sw\.js|icons/.*)$",
            static_serve, {"document_root": _SPA_DIST}),
]
