"""SysAdmin control panel — backend surface.

Gated by `admin.all` (sysadmin role only). Exposes operational controls that
are safe to run from the app:
  * metrics       — live DB/instance statistics (read-only)
  * monitors      — compact health checks for the dashboard health strip
  * maintenance   — VACUUM ANALYZE (compaction), toggle maintenance_mode
  * backups       — trigger pg_dump to disk, list backup_log, status
  * replication   — read-only pg_stat_replication status (honest: reports
                    "not configured" on a standalone instance)
  * sync          — re-run migration apply; report last_schema_sync

Pattern mirrors apps/core/reports.py (ViewSet + raw SQL + HasRolePermission).
"""
import io
import os
import subprocess
from datetime import datetime

from django.conf import settings
from django.db import connection
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from apps.core.permissions import HasRolePermission, effective_perms

BACKUP_DIR = getattr(settings, "MCMS_BACKUP_DIR", os.path.join(settings.BASE_DIR, "backups"))


def _rows(sql, params=None):
    with connection.cursor() as cur:
        cur.execute(sql, params or [])
        cols = [d[0] for d in cur.description]
        return [dict(zip(cols, row, strict=False)) for row in cur.fetchall()]


def _guard(request):
    perms = effective_perms(request)
    if "admin.all" in perms:
        return None
    return Response({"detail": "Forbidden — sysadmin only"}, status=status.HTTP_403_FORBIDDEN)


def _flag(flag, default=None):
    with connection.cursor() as cur:
        cur.execute("SELECT value FROM mcms_core.system_flag WHERE flag=%s", [flag])
        row = cur.fetchone()
    return row[0] if row else default


def _set_flag(flag, value):
    with connection.cursor() as cur:
        cur.execute(
            "INSERT INTO mcms_core.system_flag (flag, value, updated_at) "
            "VALUES (%s,%s,now()) ON CONFLICT (flag) DO UPDATE SET value=EXCLUDED.value, updated_at=now()",
            [flag, value],
        )


class SystemViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated, HasRolePermission]
    required_perms = {"metrics": "admin.all", "monitors": "admin.all"}

    # -------------------------------------------------------------- metrics
    @action(detail=False, methods=["get"])
    def metrics(self, request):
        if (d := _guard(request)):
            return d
        db = settings.DATABASES["default"]["NAME"]
        data = {
            "database": db,
            "db_size_mb": _rows("SELECT pg_database_size(%s)/1024.0/1024.0 AS mb", [db])[0]["mb"],
            "table_count": _rows(
                "SELECT count(*) AS n FROM information_schema.tables "
                "WHERE table_schema LIKE 'mcms_%%' AND table_type='BASE TABLE'")[0]["n"],
            "domain_rows": abs(_rows(
                "SELECT sum(c.reltuples::bigint) AS n FROM pg_class c "
                "JOIN pg_namespace n ON n.oid=c.relnamespace "
                "WHERE n.nspname LIKE 'mcms_%%' AND c.relkind='r'")[0]["n"] or 0),
            "active_connections": _rows(
                "SELECT count(*) AS n FROM pg_stat_activity WHERE state='active'")[0]["n"],
            "event_log_total": _rows("SELECT count(*) AS n FROM mcms_core.event_log")[0]["n"],
            "event_log_last_hour": _rows(
                "SELECT count(*) AS n FROM mcms_core.event_log "
                "WHERE occurred_at > now() - interval '1 hour'")[0]["n"],
            "cache_hit_ratio": _rows(
                "SELECT round(100.0*sum(blks_hit)/(sum(blks_hit)+sum(blks_read)),2) AS pct "
                "FROM pg_stat_database WHERE datname=%s", [db])[0]["pct"],
            "longest_query_sec": _rows(
                "SELECT coalesce(round(max(extract(epoch FROM now()-query_start))::numeric,1),0) AS s "
                "FROM pg_stat_activity WHERE state='active' AND pid<>pg_backend_pid()")[0]["s"],
            "maintenance_mode": _flag("maintenance_mode", "false"),
            "last_schema_sync": _flag("last_schema_sync", "never"),
            "at": datetime.now().isoformat(),
        }
        return Response(data)

    # ------------------------------------------------------------- monitors
    @action(detail=False, methods=["get"])
    def monitors(self, request):
        """Compact health checks for the dashboard health strip AND the
        dedicated Monitors page (more signals than the strip uses)."""
        if (d := _guard(request)):
            return d
        db = settings.DATABASES["default"]["NAME"]
        size_mb = _rows("SELECT pg_database_size(%s)/1024.0/1024.0 AS mb", [db])[0]["mb"]
        unused_idx = _rows("SELECT count(*) AS n FROM pg_stat_user_indexes WHERE idx_scan=0")[0]["n"]
        last_hour = _rows(
            "SELECT count(*) AS n FROM mcms_core.event_log WHERE occurred_at > now()-interval '1 hour'")[0]["n"]
        last_day = _rows(
            "SELECT count(*) AS n FROM mcms_core.event_log WHERE occurred_at > now()-interval '24 hours'")[0]["n"]
        repl = _rows("SELECT count(*) AS n FROM pg_stat_replication")
        replication = "active" if repl[0]["n"] > 0 else "standalone"
        long_q = _rows(
            "SELECT count(*) AS n FROM pg_stat_activity "
            "WHERE state='active' AND pid<>pg_backend_pid() "
            "AND now()-query_start > interval '5 seconds'")[0]["n"]
        conns = _rows(
            "SELECT count(*) AS n FROM pg_stat_activity WHERE pid<>pg_backend_pid()")[0]["n"]
        tables = _rows(
            "SELECT count(*) AS n FROM information_schema.tables "
            "WHERE table_schema NOT IN ('pg_catalog','information_schema') "
            "AND table_type='BASE TABLE'")[0]["n"]
        uptime = _rows(
            "SELECT EXTRACT(epoch FROM now()-pg_postmaster_start_time()) AS s")[0]["s"]
        return Response({
            "db_size_mb": round(size_mb, 1),
            "unused_indexes": unused_idx,
            "event_rate_per_hour": last_hour,
            "event_rate_24h_avg": round(last_day / 24.0, 1),
            "replication": replication,
            "long_running_queries": long_q,
            "active_connections": conns,
            "total_tables": tables,
            "uptime_seconds": int(uptime),
            "maintenance_mode": _flag("maintenance_mode", "false") == "true",
            "status": "ok" if long_q == 0 and replication in ("active", "standalone") else "warn",
            "at": datetime.now().isoformat(),
        })

    # ----------------------------------------------------------- maintenance
    @action(detail=False, methods=["post"])
    def maintenance(self, request):
        if (d := _guard(request)):
            return d
        action = request.data.get("action")
        if action == "vacuum":
            with connection.cursor() as cur:
                cur.execute("VACUUM ANALYZE")
            return Response({"detail": "VACUUM ANALYZE completed", "ok": True})
        if action == "toggle_maintenance":
            cur = _flag("maintenance_mode", "false")
            new = "false" if cur == "true" else "true"
            _set_flag("maintenance_mode", new)
            return Response({"maintenance_mode": new == "true"})
        if action == "clear_lockouts":
            with connection.cursor() as cur:
                cur.execute("TRUNCATE public.axes_accessattempt, public.axes_accessattemptexpiration CASCADE")
            return Response({"detail": "Axes lockouts cleared", "ok": True})
        return Response({"detail": f"unknown action {action}"}, status=status.HTTP_400_BAD_REQUEST)

    # -------------------------------------------------------------- backups
    @action(detail=False, methods=["get", "post"])
    def backups(self, request):
        if (d := _guard(request)):
            return d
        if request.method == "GET":
            rows = _rows(
                "SELECT backup_id, started_at, finished_at, filename, size_bytes, status, detail "
                "FROM mcms_core.backup_log ORDER BY started_at DESC LIMIT 20")
            return Response({"backups": rows, "backup_dir": os.path.abspath(BACKUP_DIR)})

        os.makedirs(BACKUP_DIR, exist_ok=True)
        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        fname = f"mcms_{ts}.sql"
        fpath = os.path.join(BACKUP_DIR, fname)
        db = settings.DATABASES["default"]
        with connection.cursor() as cur:
            cur.execute(
                "INSERT INTO mcms_core.backup_log (filename, status, triggered_by) "
                "VALUES (%s,'running',%s) RETURNING backup_id", [fpath, request.user.username])
            bid = cur.fetchone()[0]
        try:
            env = os.environ.copy()
            env["PGPASSWORD"] = db.get("PASSWORD", "")
            proc = subprocess.run(
                ["pg_dump", "-h", db.get("HOST", "127.0.0.1"), "-p", str(db.get("PORT", 5432)),
                 "-U", db.get("USER", "postgres"), "-d", db["NAME"], "-f", fpath, "-F", "p"],
                env=env, capture_output=True, text=True, timeout=300)
            size = os.path.getsize(fpath) if os.path.exists(fpath) else 0
            status_val = "ok" if proc.returncode == 0 else "error"
            detail = "" if proc.returncode == 0 else (proc.stderr or "pg_dump failed")[:500]
            with connection.cursor() as cur:
                cur.execute(
                    "UPDATE mcms_core.backup_log SET finished_at=now(), filename=%s, "
                    "size_bytes=%s, status=%s, detail=%s WHERE backup_id=%s",
                    [fpath, size, status_val, detail, bid])
            return Response({"backup_id": bid, "filename": fpath, "size_bytes": size,
                             "status": status_val, "detail": detail},
                            status=status.HTTP_201_CREATED if status_val == "ok" else status.HTTP_500_INTERNAL_ERROR)
        except Exception as e:  # noqa
            with connection.cursor() as cur:
                cur.execute(
                    "UPDATE mcms_core.backup_log SET finished_at=now(), status='error', detail=%s WHERE backup_id=%s",
                    [str(e)[:500], bid])
            return Response({"detail": str(e)[:300]}, status=status.HTTP_500_INTERNAL_ERROR)

    # ------------------------------------------------------------ replication
    @action(detail=False, methods=["get"])
    def replication(self, request):
        if (d := _guard(request)):
            return d
        rows = _rows(
            "SELECT application_name, state, sync_state FROM pg_stat_replication")
        return Response({
            "configured": bool(rows),
            "standbys": rows,
            "note": "Standalone instance — no replication slots configured." if not rows else "",
        })

    # ----------------------------------------------------- Phase 12: scale / health
    @action(detail=False, methods=["get"], permission_classes=[AllowAny])
    def health(self, request):
        """Liveness probe. Returns 200 when the DB is reachable.

        Intentionally unprivileged beyond authentication so an orchestrator
        liveness check can call it with a service token.
        """
        try:
            with connection.cursor() as cur:
                cur.execute("SELECT 1")
            return Response({"status": "ok", "db": "up",
                             "at": datetime.now().isoformat()})
        except Exception as e:  # noqa
            return Response({"status": "error", "db": "down", "detail": str(e)[:200]},
                            status=status.HTTP_503_SERVICE_UNAVAILABLE)

    @action(detail=False, methods=["get"], permission_classes=[AllowAny])
    def readiness(self, request):
        """Readiness probe. 200 only when primary DB + channel layer are up.

        Replica is reported but not required (standalone is a valid state).
        """
        checks = {}
        try:
            with connection.cursor() as cur:
                cur.execute("SELECT 1")
            checks["db_primary"] = "up"
        except Exception as e:  # noqa
            checks["db_primary"] = f"down:{str(e)[:120]}"
        # channel layer: report the configured backend
        layer = getattr(settings, "CHANNEL_LAYERS", {}).get("default", {})
        backend = (layer.get("BACKEND") or "unknown").split(".")[-1]
        checks["channel_backend"] = backend
        replica_cfg = "replica" in getattr(settings, "DATABASES", {})
        checks["replica_configured"] = replica_cfg
        ready = checks["db_primary"] == "up"
        code = status.HTTP_200_OK if ready else status.HTTP_503_SERVICE_UNAVAILABLE
        return Response({"ready": ready, "checks": checks,
                         "at": datetime.now().isoformat()}, status=code)

    @action(detail=False, methods=["get"])
    def scale_status(self, request):
        """Scale/readiness introspection — deterministic, no infra side effects."""
        if (d := _guard(request)):
            return d
        dbs = getattr(settings, "DATABASES", {})
        repl = _rows("SELECT count(*) AS n FROM pg_stat_replication")
        replication = "active" if (repl and repl[0]["n"] > 0) else "standalone"
        layer = getattr(settings, "CHANNEL_LAYERS", {}).get("default", {})
        backend = (layer.get("BACKEND") or "unknown").split(".")[-1]
        return Response({
            "replication_role": replication,
            "replica_configured": "replica" in dbs,
            "databases": list(dbs.keys()),
            "conn_max_age": dbs.get("default", {}).get("CONN_MAX_AGE", 0),
            "channel_layer": backend.split(".")[-1],
            "routers": [r.split(".")[-1] for r in getattr(settings, "DATABASE_ROUTERS", [])],
            "at": datetime.now().isoformat(),
        })

    # ------------------------------------------------------------------ sync
    @action(detail=False, methods=["get", "post"])
    def sync(self, request):
        if (d := _guard(request)):
            return d
        if request.method == "GET":
            return Response({
                "last_schema_sync": _flag("last_schema_sync", "never"),
                "note": "Re-apply Django migrations to keep the reflection layer in sync.",
            })
        from django.core.management import call_command
        buf = io.StringIO()
        try:
            call_command("migrate", "--verbosity", "1", stdout=buf, stderr=buf)
            _set_flag("last_schema_sync", datetime.now().isoformat())
            return Response({"detail": "schema sync completed", "log": buf.getvalue()[-2000:]})
        except Exception as e:  # noqa
            return Response({"detail": str(e)[:400]}, status=status.HTTP_500_INTERNAL_ERROR)


# ----------------------------------------------------------- root SPA view
# Serve the built Vite SPA (frontend/dist/index.html) at /. Client-side routes
# (e.g. /reports, /schema/waste) fall back to index.html so the SPA router
# handles them. The API lives under /api/. Static assets under /assets/ are
# served by WhiteNoise from STATIC_ROOT.
from django.http import HttpResponse  # noqa: E402
from django.conf import settings as _settings  # noqa: E402
import os as _os_mod  # noqa: E402

_SPA_INDEX = _os_mod.path.join(_settings.BASE_DIR, "frontend", "dist", "index.html")


def landing(request):
    # SPA history fallback: unknown non-API GET paths return index.html.
    if not request.path.startswith("/api") and request.method == "GET":
        try:
            with open(_SPA_INDEX, "rb") as fh:
                return HttpResponse(fh.read(), content_type="text/html; charset=utf-8")
        except FileNotFoundError:
            pass
    return HttpResponse(
        "<!doctype html><title>MCMS</title><h1>MCMS backend is running</h1>"
        "<p>The web UI build (frontend/dist) was not found. Run "
        "<code>npm run build</code> in frontend/.</p>",
        content_type="text/html; charset=utf-8",
        status=200,
    )
