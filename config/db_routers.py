"""Phase 12 - Database read-replica router.

Routes read queries to the `replica` database when it is configured
(via MCMS_DB_REPLICA_* env); otherwise everything stays on `default`.
This makes the read/write split opt-in: with no replica configured the
application behaves exactly as before (single-node), so there is zero
regression risk and tests stay deterministic.

Django 5 router API.
"""

from django.conf import settings


class ReplicaRouter:
    """Send reads to `replica`, writes to `default`.

    Reads = any query that is not a write (SELECT). Writes (INSERT/UPDATE/
    DELETE/ALTER/...) always go to the primary so replicas are never written.
    """

    def _has_replica(self):
        return "replica" in settings.DATABASES

    def db_for_read(self, model=None, **hints):
        return "replica" if self._has_replica() else "default"

    def db_for_write(self, model=None, **hints):
        return "default"

    def allow_relation(self, obj1, obj2, **hints):
        # allow relations across default+replica (both are the same data)
        return obj1._state.db in ("default", "replica") and \
            obj2._state.db in ("default", "replica")

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        # migrations are managed=False (inspectdb) — never auto-migrate;
        # keep the default behaviour of allowing the primary only.
        return db == "default"
