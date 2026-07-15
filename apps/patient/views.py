"""Patient portal API (Phase 5: Reach).

Self-service, strictly scoped to the authenticated patient's OWN record. The
boundary is enforced in SQL: every query is filtered by the caller's
patient_id, resolved from app_user.party_id -> patient. No other patient's
data is reachable. Results/bills are additionally gated by a granted
`data_sharing` consent (mcms_core.consent), satisfying the 'own role +
consent' requirement.

RBAC: requires the `patient.portal` permission (held by the `patient` role).
A patient can never reach the clinical CRUD endpoints -- those need clinical
permissions they don't have.
"""

from django.db import connection
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.core.permissions import HasRolePermission, effective_perms


def _patient_id_for_request(request):
    """Resolve the caller's patient_id from app_user.party_id -> patient."""
    uname = request.user.get_username()
    with connection.cursor() as cur:
        cur.execute(
            "SELECT p.patient_id FROM mcms_core.app_user u "
            "JOIN mcms_emr.patient p ON p.party_id = u.party_id "
            "WHERE u.username = %s AND u.is_active",
            [uname])
        row = cur.fetchone()
    return row[0] if row else None


def _has_consent(patient_id, consent_type="data_sharing"):
    with connection.cursor() as cur:
        cur.execute(
            "SELECT 1 FROM mcms_core.consent c "
            "JOIN mcms_emr.patient p ON p.party_id = c.party_id "
            "WHERE p.patient_id = %s AND c.consent_type = %s AND c.granted",
            [patient_id, consent_type])
        return cur.fetchone() is not None


class PatientPortalViewSet(viewsets.ViewSet):
    permission_classes = [IsAuthenticated, HasRolePermission]
    required_perms = {
        "appointments": "patient.portal",
        "results": "patient.portal",
        "bills": "patient.portal",
        "consents": "patient.portal",
        "toggle_consent": "patient.portal",
    }

    def _guard(self, request):
        perms = effective_perms(request)
        if "admin.all" in perms or "patient.portal" in perms:
            return None
        return Response({"detail": "Forbidden"}, status=status.HTTP_403_FORBIDDEN)

    @action(detail=False, methods=["get"])
    def appointments(self, request):
        if (d := self._guard(request)):
            return d
        pid = _patient_id_for_request(request)
        if pid is None:
            return Response({"detail": "No linked patient record"}, status=status.HTTP_404_NOT_FOUND)
        with connection.cursor() as cur:
            cur.execute(
                "SELECT appointment_id, patient_id, starts_at, ends_at, status, reason, "
                       "patient_confirmed, clinician_user_id, department_id "
                "FROM mcms_clinic.appointment WHERE patient_id = %s "
                "ORDER BY starts_at DESC LIMIT 50", [pid])
            cols = [d[0] for d in cur.description]
            rows = [dict(zip(cols, r, strict=False)) for r in cur.fetchall()]
        return Response({"patient_id": pid, "appointments": rows})

    @action(detail=False, methods=["get"])
    def results(self, request):
        if (d := self._guard(request)):
            return d
        pid = _patient_id_for_request(request)
        if pid is None:
            return Response({"detail": "No linked patient record"}, status=status.HTTP_404_NOT_FOUND)
        if not _has_consent(pid, "data_sharing"):
            return Response(
                {"detail": "Results hidden: data-sharing consent not granted.",
                 "consent_required": "data_sharing"},
                status=status.HTTP_403_FORBIDDEN)
        with connection.cursor() as cur:
            cur.execute(
                "SELECT r.result_id, r.test_id, tc.name AS test, r.flag, "
                       "r.value_numeric, r.value_text, r.unit, r.verified_at "
                "FROM mcms_lab.result r "
                "JOIN mcms_lab.sample s ON s.sample_id = r.sample_id "
                "JOIN mcms_lab.lab_order lo ON lo.order_id = s.lab_order_id "
                "LEFT JOIN mcms_lab.test_catalog tc ON tc.test_id = r.test_id "
                "WHERE lo.patient_id = %s ORDER BY r.verified_at DESC NULLS LAST LIMIT 50",
                [pid])
            cols = [d[0] for d in cur.description]
            rows = [dict(zip(cols, r, strict=False)) for r in cur.fetchall()]
        return Response({"patient_id": pid, "results": rows})

    @action(detail=False, methods=["get"])
    def bills(self, request):
        if (d := self._guard(request)):
            return d
        pid = _patient_id_for_request(request)
        if pid is None:
            return Response({"detail": "No linked patient record"}, status=status.HTTP_404_NOT_FOUND)
        if not _has_consent(pid, "data_sharing"):
            return Response(
                {"detail": "Bills hidden: data-sharing consent not granted.",
                 "consent_required": "data_sharing"},
                status=status.HTTP_403_FORBIDDEN)
        with connection.cursor() as cur:
            cur.execute(
                "SELECT invoice_id, patient_id, mrn, status, subtotal, tax_amount, "
                       "discount_amount, total, patient_pays, issued_at "
                "FROM mcms_billing.invoice WHERE patient_id = %s "
                "ORDER BY issued_at DESC LIMIT 50", [pid])
            cols = [d[0] for d in cur.description]
            rows = [dict(zip(cols, r, strict=False)) for r in cur.fetchall()]
        return Response({"patient_id": pid, "bills": rows})

    @action(detail=False, methods=["get"])
    def consents(self, request):
        if (d := self._guard(request)):
            return d
        pid = _patient_id_for_request(request)
        if pid is None:
            return Response({"detail": "No linked patient record"}, status=status.HTTP_404_NOT_FOUND)
        # Full matrix: every consent_type with its current granted state for
        # this patient (absent => not granted). Patient-friendly portal view.
        with connection.cursor() as cur:
            cur.execute(
                "SELECT unnest(enum_range(NULL::mcms_core.consent_type))")
            types = [r[0] for r in cur.fetchall()]
            cur.execute(
                "SELECT c.consent_type, c.granted, c.granted_at, c.revoked_at, c.note "
                "FROM mcms_core.consent c "
                "JOIN mcms_emr.patient p ON p.party_id = c.party_id "
                "WHERE p.patient_id = %s", [pid])
            existing = {r[0]: {"granted": r[1], "granted_at": r[2],
                               "revoked_at": r[3], "note": r[4]}
                        for r in cur.fetchall()}
        rows = [{"consent_type": t,
                 "granted": bool(existing[t]["granted"]) if t in existing else False,
                 "granted_at": existing[t]["granted_at"] if t in existing else None,
                 "revoked_at": existing[t]["revoked_at"] if t in existing else None,
                 "note": existing[t]["note"] if t in existing else None}
                for t in types]
        return Response({"patient_id": pid, "consents": rows})

    @action(detail=False, methods=["post"])
    def toggle_consent(self, request):
        if (d := self._guard(request)):
            return d
        pid = _patient_id_for_request(request)
        if pid is None:
            return Response({"detail": "No linked patient record"}, status=status.HTTP_404_NOT_FOUND)
        ctype = request.data.get("consent_type")
        granted = bool(request.data.get("granted", False))
        if not ctype:
            return Response({"detail": "consent_type required"}, status=status.HTTP_400_BAD_REQUEST)
        with connection.cursor() as cur:
            cur.execute(
                "SELECT party_id FROM mcms_emr.patient WHERE patient_id = %s", [pid])
            party_row = cur.fetchone()
            if not party_row:
                return Response({"detail": "No linked party"}, status=status.HTTP_404_NOT_FOUND)
            party_id = party_row[0]
            cur.execute(
                "SELECT consent_id FROM mcms_core.consent "
                "WHERE party_id = %s AND consent_type = %s", [party_id, ctype])
            existing = cur.fetchone()
            if existing:
                cur.execute(
                    "UPDATE mcms_core.consent SET granted = %s, "
                    "granted_at = CASE WHEN %s THEN now() ELSE NULL END, "
                    "revoked_at = CASE WHEN %s THEN NULL ELSE now() END, "
                    "granted_by = (SELECT user_id FROM mcms_core.app_user WHERE username = %s), "
                    "note = 'Patient self-service' "
                    "WHERE consent_id = %s",
                    [granted, granted, granted, request.user.get_username(), existing[0]])
            else:
                cur.execute(
                    "INSERT INTO mcms_core.consent "
                    "(party_id, consent_type, granted, granted_at, granted_by, note) "
                    "VALUES (%s, %s, %s, CASE WHEN %s THEN now() ELSE NULL END, "
                    "(SELECT user_id FROM mcms_core.app_user WHERE username = %s), "
                    "'Patient self-service')",
                    [party_id, ctype, granted, granted, request.user.get_username()])
        return Response({"detail": "consent updated", "consent_type": ctype, "granted": granted})
