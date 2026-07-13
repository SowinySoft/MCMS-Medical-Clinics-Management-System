# MCMS — Django REST API

Medical Clinics Management System web backend. Django 5 + DRF over the merged
15-schema PostgreSQL database (`mcms_core` … `mcms_erp`, 89 tables).

## Architecture (design patterns applied)

| Pattern | Where | What it buys us |
|---|---|---|
| **Schema-per-domain** | `config/settings.py` `DATABASES.OPTIONS.search_path` | 15 schemas, one connection; no cross-DB joins |
| **Reflection layer** | `apps/<schema>/models.py` (`inspectdb`, `managed=False`) | 89 tables mapped to Django without duplicating DDL (SQL owns schema) |
| **Schema-qualified `db_table`** | model `Meta` | Disambiguates colliding table names across schemas (`physio.session` vs `dialysis.session`) |
| **Policy-as-data RBAC** | `apps/core/permissions.py` + `mcms_core.role/permission/role_permission` | Roles & perms edited in SQL, never in code; `HasRolePermission` reads them live |
| **Bridge auth** | `apps/core/auth.py` | Django `auth_user` for secure password hashing; `mcms_core.app_user` bridged by username for authz |
| **Factory + auto-router** | `apps/core/base.py`, `apps/core/routers.py` | One `build_viewset()` + `build_router()` generates **89 CRUD endpoints** with zero per-table code |
| **Serializer namespacing** | `serializer_factory` | App-prefixed class names eliminate OpenAPI component collisions |
| **Ordered pagination** | `AuditContextMixin.get_queryset` | Falls back to PK desc so paginated lists are stable |

## Run

```bash
.venv\Scripts\activate
python manage.py migrate            # creates Django auth tables in public
python manage.py provision_user --username admin --password admin123 \
        --role sysadmin --superuser --party-name "System Admin"
python manage.py runserver 127.0.0.1:8009
```

## Endpoints

| Path | Purpose |
|---|---|
| `POST /api/auth/token/` | JWT obtain — token carries `roles` + `perms` |
| `POST /api/auth/token/refresh/` | JWT refresh |
| `/api/<schema>/<model>/` | Auto CRUD for every table (list/create/detail/update/delete) |
| `/api/docs/` | Swagger UI |
| `/api/redoc/` | ReDoc |
| `/api/schema/` | OpenAPI 3.0 JSON (180 paths, 269 components) |

Example: `/api/emr/patient/`, `/api/billing/invoice/`, `/api/erp/goods-receipt/`,
`/api/dialysis/session/`, `/api/hr/department/`.

## RBAC model

Permission codes (from `mcms_core.permission`):

```
patient.read   emr.read  emr.write  appointment.manage
pharmacy.dispense  lab_rad.result  billing.read  billing.manage
inventory.manage  admin.all
```

A viewset declares required perms via `required_perms` (default in `routers.py`):
read (SAFE) → `<domain>.read`, write (`*`) → `<domain>.manage`. Superusers and
holders of `admin.all` bypass all checks. Tokens are re-validated on every call.

### Seeded test users
| username | password | role | can read EMR | can manage billing |
|---|---|---|---|---|
| `admin` | `admin123` | sysadmin (superuser) | ✔ | ✔ |
| `drmona` | `doc123` | doctor | ✔ | ✘ (403) |
| `acc1` | `acc123` | accountant | ✘ (403) | ✔ |

## Notes
- The DB schema itself is owned by the SQL files in `/sql` — Django never
  DDLs these tables (`managed=False`). Re-run `inspectdb` after schema changes.
- JWT access tokens live 60 min, refresh 7 days, rotation on.
- CORS is open in dev (`CORS_ALLOW_ALL_ORIGINS`) — lock down for production.
