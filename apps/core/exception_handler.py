"""Global DRF exception handler — defense-in-depth for the reflection layer.

The 89 domain models are inspectdb-generated and mirror some (but not all)
DB CHECK constraints as Django `choices`. If an unmapped constraint is
violated on write, Django raises IntegrityError deep in the ORM. Rather than
leak a 500, we surface a clean 400 so the client gets a actionable error and
the system never returns an unhandled 500 from a constraint violation.
"""
from django.db import IntegrityError, DataError
from rest_framework.views import exception_handler
from rest_framework.response import Response


def mcms_exception_handler(exc, context):
    if isinstance(exc, (IntegrityError, DataError)):
        # Pull a readable message; psycopg wraps the raw driver error.
        msg = str(exc)
        if "DETAIL" in msg:
            msg = msg.split("DETAIL:")[-1].strip()
        return Response(
            {"detail": "Validation failed against database constraints.", "db_error": msg[:300]},
            status=400,
        )
    return exception_handler(exc, context)
