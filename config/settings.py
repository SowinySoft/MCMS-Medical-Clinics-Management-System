"""
MCMS · Django settings
Multi-schema PostgreSQL (15 mcms_* schemas) exposed through DRF + JWT + RBAC.
Design patterns applied:
  * search_path spanning every mcms_* schema (schema-per-domain, one connection)
  * thin settings, fat app packages under apps/
  * declarative RBAC driven by DB tables (mcms_core.role/permission)
"""
from datetime import timedelta
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

import os as _os

SECRET_KEY = _os.environ.get("MCMS_SECRET_KEY", "mcms-dev-insecure-change-me")
DEBUG = _os.environ.get("MCMS_DEBUG", "false").lower() in ("1", "true", "yes")
ALLOWED_HOSTS = _os.environ.get("MCMS_ALLOWED_HOSTS", "127.0.0.1,localhost").split(",")

# ---------------------------------------------------------------- apps
DJANGO_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]
THIRD_PARTY_APPS = [
    "rest_framework",
    "rest_framework_simplejwt",
    "django_filters",
    "drf_spectacular",
    "corsheaders",
    "axes",
]
# domain apps — one per DB schema
DOMAIN_APPS = [
    "apps.core",
    "apps.emr",
    "apps.clinic",
    "apps.hr",
    "apps.surgical",
    "apps.emergency",
    "apps.rx",
    "apps.lab",
    "apps.rad",
    "apps.icu",
    "apps.physio",
    "apps.dialysis",
    "apps.nursery",
    "apps.billing",
    "apps.erp",
    "apps.fhir",
    "apps.ai",
    "apps.patient",
    "apps.hl7v2",
    "apps.terminology",
    "apps.payer",
    "apps.telemed",
    "apps.identity",
]
INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + DOMAIN_APPS + ["channels"]

MIDDLEWARE = [
    "corsheaders.middleware.CorsMiddleware",
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    "axes.middleware.AxesMiddleware",
]

ROOT_URLCONF = "config.urls"
TEMPLATES = [{
    "BACKEND": "django.template.backends.django.DjangoTemplates",
    "DIRS": [],
    "APP_DIRS": True,
    "OPTIONS": {"context_processors": [
        "django.template.context_processors.debug",
        "django.template.context_processors.request",
        "django.contrib.auth.context_processors.auth",
        "django.contrib.messages.context_processors.messages",
    ]},
}]
WSGI_APPLICATION = "config.wsgi.application"

# ---------------------------------------------------------------- database
# One connection; search_path puts `public` FIRST (Django framework tables:
# auth_*, django_*) then every domain schema. Framework infra no longer lives
# in mcms_core (see sql/94_move_django_to_public.sql).
_SCHEMAS = ",".join([
    "public",
    "mcms_core", "mcms_emr", "mcms_clinic", "mcms_hr", "mcms_surgical",
    "mcms_emergency", "mcms_rx", "mcms_lab", "mcms_rad", "mcms_icu",
    "mcms_physio", "mcms_dialysis", "mcms_nursery", "mcms_billing",
    "mcms_erp",
])
import os as _os

_SP_OVERRIDE = _os.environ.get("MCMS_SEARCH_PATH")
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": _os.environ.get("MCMS_DB_NAME", "mcms"),
        "USER": _os.environ.get("MCMS_DB_USER", "postgres"),
        "PASSWORD": _os.environ.get("MCMS_DB_PASSWORD", "postgres"),
        "HOST": _os.environ.get("MCMS_DB_HOST", "127.0.0.1"),
        "PORT": _os.environ.get("MCMS_DB_PORT", "5432"),
        "CONN_MAX_AGE": int(_os.environ.get("MCMS_CONN_MAX_AGE", "60")),
        "OPTIONS": {"options": f"-c search_path={_SP_OVERRIDE or _SCHEMAS}"},
    }
}
# Phase 12: optional read replica. When MCMS_DB_REPLICA_HOST is set we register a
# `replica` connection + a ReplicaRouter that routes reads to it (writes still go
# to the primary). With no replica configured the app is single-node as before.
if _os.environ.get("MCMS_DB_REPLICA_HOST"):
    DATABASES["replica"] = {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": _os.environ.get("MCMS_DB_REPLICA_NAME", DATABASES["default"]["NAME"]),
        "USER": _os.environ.get("MCMS_DB_REPLICA_USER", DATABASES["default"]["USER"]),
        "PASSWORD": _os.environ.get("MCMS_DB_REPLICA_PASSWORD", DATABASES["default"]["PASSWORD"]),
        "HOST": _os.environ.get("MCMS_DB_REPLICA_HOST"),
        "PORT": _os.environ.get("MCMS_DB_REPLICA_PORT", "5432"),
        "CONN_MAX_AGE": int(_os.environ.get("MCMS_CONN_MAX_AGE", "60")),
        "OPTIONS": {"options": f"-c search_path={_SP_OVERRIDE or _SCHEMAS}"},
    }
    DATABASE_ROUTERS = ["config.db_routers.ReplicaRouter"]  # type: ignore[assignment]

# ---------------------------------------------------------------- auth
AUTHENTICATION_BACKENDS = [
    "axes.backends.AxesStandaloneBackend",  # brute-force aware; records + resets on success
    "django.contrib.auth.backends.ModelBackend",
]

# ---------------------------------------------------------------- DRF / JWT
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
        "rest_framework.authentication.SessionAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": (
        "rest_framework.permissions.IsAuthenticated",
        "apps.core.permissions.HasRolePermission",
    ),
    "EXCEPTION_HANDLER": "apps.core.exception_handler.mcms_exception_handler",
    "DEFAULT_FILTER_BACKENDS": (
        "django_filters.rest_framework.DjangoFilterBackend",
        "rest_framework.filters.SearchFilter",
        "rest_framework.filters.OrderingFilter",
    ),
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 25,
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
}

SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=60),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=7),
    "ROTATE_REFRESH_TOKENS": True,
}

SPECTACULAR_SETTINGS = {
    "TITLE": "MCMS API",
    "DESCRIPTION": "Medical Clinics Management System — DRF over 15-schema PostgreSQL",
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
}

# CORS: restrict to configured origins in production. Set MCMS_CORS_ORIGINS
# (comma-separated) to your frontend host; defaults to open for local dev only.
_CORS = _os.environ.get("MCMS_CORS_ORIGINS", "")
if _CORS:
    CORS_ALLOWED_ORIGINS = [o.strip() for o in _CORS.split(",")]
    CORS_ALLOW_ALL_ORIGINS = False
else:
    CORS_ALLOW_ALL_ORIGINS = True

# ---------------------------------------------------------------- ASGI / Channels
ASGI_APPLICATION = "config.asgi.application"
# Use Redis in production (MCMS_REDIS_URL); fall back to InMemory for local dev.
# InMemory does NOT persist events across workers/restarts — not for prod.
_REDIS = _os.environ.get("MCMS_REDIS_URL")
CHANNEL_LAYERS = {
    "default": (
        {"BACKEND": "channels.layers.InMemoryChannelLayer"}
        if not _REDIS else
        {"BACKEND": "channels_redis.core.RedisChannelLayer", "CONFIG": {"hosts": [_REDIS]}}
    )
}

LANGUAGE_CODE = "en-us"
TIME_ZONE = "UTC"
USE_I18N = True
USE_TZ = True
STATIC_URL = "static/"
STATIC_ROOT = _os.environ.get("MCMS_STATIC_ROOT", str(BASE_DIR / "staticfiles"))

# ---------------------------------------------------------------- Brute-force protection (django-axes)
# Locks an IP+username after N failed logins within COOLOFF. Tunable via env.
AXES_ENABLED = _os.environ.get("MCMS_AXES_ENABLED", "true").lower() in ("1", "true", "yes")
AXES_FAILURE_LIMIT = int(_os.environ.get("MCMS_AXES_FAILURE_LIMIT", "5"))
AXES_COOLOFF_TIME = int(_os.environ.get("MCMS_AXES_COOLOFF_TIME", "10"))  # minutes
AXES_LOCKOUT_TIME = int(_os.environ.get("MCMS_AXES_LOCKOUT_TIME", "30"))   # minutes
AXES_COORDINATOR = "axes.handlers.database.AxesDatabaseHandler"
AXES_USERNAME_FIELD = "username"
AXES_RESET_ON_SUCCESS = True


def _axes_username(request, credentials=None):
    """Pull the attempted username from the JSON login body (DRF-parsed)."""
    try:
        return (request.data or {}).get("username") or ""
    except Exception:
        return ""


AXES_USERNAME_CALLABLE = _axes_username
