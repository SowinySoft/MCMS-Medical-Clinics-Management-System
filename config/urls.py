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
from django.urls import path, include
from rest_framework_simplejwt.views import TokenRefreshView
from drf_spectacular.views import (
    SpectacularAPIView, SpectacularSwaggerView, SpectacularRedocView,
)
from apps.core.auth import MCMSTokenObtainPairView
from apps.core.routers import build_router

router = build_router()

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/", include(router.urls)),
    path("api/auth/token/", MCMSTokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/auth/token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="swagger-ui"),
    path("api/redoc/", SpectacularRedocView.as_view(url_name="schema"), name="redoc"),
]
