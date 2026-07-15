"""Phase 12 - Scale / infra tests.

Covers scale-readiness that is deterministic + CI-testable WITHOUT live
infra: read-replica router fallback (single-node == default), the
health/readiness probe endpoints, and the scale_status introspection.
Replica routing is exercised by asserting the router always returns a
configured DB alias (default when no replica env is set).
"""

import pytest
from django.conf import settings
from django.test import override_settings

pytestmark = pytest.mark.django_db(transaction=True)


def test_replica_router_falls_back_to_default():
    """With no replica configured, reads route to `default` (no regression)."""
    from config.db_routers import ReplicaRouter
    router = ReplicaRouter()
    assert "replica" not in settings.DATABASES  # single-node in CI
    assert router.db_for_read() == "default"
    assert router.db_for_write() == "default"
    assert router.db_for_read(model=None) == "default"


def test_replica_router_routes_reads_when_configured():
    """When a replica connection exists, reads go to `replica`, writes to primary."""
    from config.db_routers import ReplicaRouter
    router = ReplicaRouter()
    replica_cfg = {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": "mcms", "USER": "postgres", "PASSWORD": "postgres",
        "HOST": "127.0.0.1", "PORT": "5432",
    }
    with override_settings(
        DATABASES={**settings.DATABASES, "replica": replica_cfg},
        DATABASE_ROUTERS=["config.db_routers.ReplicaRouter"],
    ):
        assert router.db_for_read() == "replica"
        assert router.db_for_write() == "default"


def test_health_probe_ok(admin_client):
    r = admin_client.get("/api/system/health/")
    assert r.status_code == 200, r.data
    assert r.data["status"] == "ok"
    assert r.data["db"] == "up"


def test_readiness_probe_ok(admin_client):
    r = admin_client.get("/api/system/readiness/")
    assert r.status_code == 200, r.data
    assert r.data["ready"] is True
    assert r.data["checks"]["db_primary"] == "up"
    # standalone is a valid state; replica not required for readiness
    assert "replica_configured" in r.data["checks"]


def test_scale_status_standalone(admin_client):
    r = admin_client.get("/api/system/scale_status/")
    assert r.status_code == 200, r.data
    assert r.data["replication_role"] in ("standalone", "active")
    assert r.data["replica_configured"] is False
    assert "default" in r.data["databases"]
    assert isinstance(r.data["conn_max_age"], int)
    assert r.data["channel_layer"] in ("InMemoryChannelLayer", "RedisChannelLayer")


def test_conn_max_age_is_set():
    # MCMS_CONN_MAX_AGE defaults to 60; must be an int on the default connection
    cma = settings.DATABASES["default"].get("CONN_MAX_AGE")
    assert isinstance(cma, int)
    assert cma >= 0


def test_docker_compose_present():
    """Scale topology is declared (deterministic, no build in CI)."""
    from pathlib import Path
    assert Path("Dockerfile").exists()
    assert Path("docker-compose.yml").exists()
    compose = Path("docker-compose.yml").read_text()
    assert "daphne" in compose  # single ASGI entry for HTTP + WS
    assert "redis" in compose  # channel layer backend
    assert "postgres" in compose
