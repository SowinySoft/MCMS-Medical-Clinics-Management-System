"""Phase 9 - Payer integration (deterministic offline simulator).

Wraps the existing mcms_billing.insurance_claim lifecycle with:
  * eligibility verification  (verify active coverage before billing)
  * claim submission + simulated payer round-trip (EOB / claim_response)

No live clearinghouse. The payer round-trip is a STABLE, explainable
mock (mcms_billing.payer.mock_mode=true) so the flow is reproducible
and CI-testable against real schema rows.

Mock adjudication rules (deterministic, no randomness):
  * payer must exist, be active, and support_claims.
  * billed_amount == 0           -> rejected (nothing to pay)
  * rejected_amount > 0           -> partial (approved = billed - rejected)
  * otherwise                      -> approved (approved = billed)
Eligibility:
  * payer active + supports_eligibility + patient has a policy_no -> verified
  * otherwise                                                       -> denied
"""

from django.db import connection
from django.utils import timezone
from rest_framework import status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.viewsets import ViewSet

from apps.core.models import AppUser
from apps.core.permissions import HasRolePermission


def _caller_facility(request):
    au = AppUser.objects.filter(username=request.user.get_username()).first()
    return au.facility_id if au else None


def _payer_row(payer_code):
    with connection.cursor() as cur:
        cur.execute(
            "SELECT payer_code, name, supports_eligibility, supports_claims, "
            "       mock_mode, is_active FROM mcms_billing.payer WHERE payer_code=%s",
            [payer_code])
        return cur.fetchone()


class PayerViewSet(ViewSet):
    permission_classes = [HasRolePermission]
    required_perms = {
        "eligibility_check": "billing.manage",
        "submit_claim": "billing.manage",
    }

    # --------------------------------------------------- eligibility
    @action(detail=False, methods=["post"], url_path=r"eligibility/check")
    def eligibility_check(self, request):
        patient_id = request.data.get("patient_id")
        payer_code = (request.data.get("payer_code") or "").strip().upper()
        if not patient_id or not payer_code:
            return Response({"detail": "patient_id and payer_code are required"},
                            status=status.HTTP_400_BAD_REQUEST)
        payer = _payer_row(payer_code)
        if not payer or not payer[5]:           # is_active
            return Response(
                {"detail": f"unknown or inactive payer {payer_code!r}",
                 "payer_code": payer_code, "status": "denied"},
                status=status.HTTP_404_NOT_FOUND)
        # patient policy from mcms_emr.patient
        with connection.cursor() as cur:
            cur.execute("SELECT insurance_policy_no, insurance_provider "
                        "FROM mcms_emr.patient WHERE patient_id=%s", [patient_id])
            prow = cur.fetchone()
        policy = (prow[0] if prow else None)
        verified = bool(payer[1] and policy)        # supports_eligibility + has policy
        reason = None if verified else "no active policy for this payer"
        if verified:
            st = "verified"
        else:
            st = "denied"
            if not payer[1]:
                reason = "payer does not support eligibility"
        # persist + stamp patient.coverage_verified
        facility = _caller_facility(request)
        with connection.cursor() as cur:
            cur.execute(
                "INSERT INTO mcms_billing.eligibility_check "
                "(patient_id, payer_code, policy_no, status, reason, facility_id) "
                "VALUES (%s,%s,%s,%s,%s,%s) RETURNING eligibility_id",
                [patient_id, payer_code, policy, st, reason, facility or 1])
            elig_id = cur.fetchone()[0]
            cur.execute("UPDATE mcms_emr.patient SET coverage_verified=%s, "
                        "coverage_verified_at=now() WHERE patient_id=%s",
                        [verified, patient_id])
        return Response({
            "eligibility_id": elig_id, "patient_id": patient_id,
            "payer_code": payer_code, "status": st,
            "policy_no": policy, "reason": reason,
        })

    # --------------------------------------------------- claim submit + EOB
    @action(detail=True, methods=["post"], url_path=r"submit")
    def submit_claim(self, request, pk=None):
        facility = _caller_facility(request)
        # load claim
        with connection.cursor() as cur:
            cur.execute(
                "SELECT claim_id, invoice_id, policy_no, insurance_provider, "
                "patient_id, billed_amount, rejected_amount, status "
                "FROM mcms_billing.insurance_claim WHERE claim_id=%s", [pk])
            row = cur.fetchone()
        if not row:
            return Response({"detail": "claim not found"},
                            status=status.HTTP_404_NOT_FOUND)
        (claim_id, invoice_id, policy_no, provider, patient_id,
         billed, rejected, cstatus) = row
        if cstatus != "draft":
            # idempotent: return current state, do not re-submit
            return Response({
                "detail": f"claim already {cstatus} (no re-submit)",
                "status": cstatus, "claim_no_external": _ext_claim_no(claim_id),
            })
        payer_code = (provider or "").strip().upper()
        payer = _payer_row(payer_code)
        if not payer or not payer[5] or not payer[3]:   # active + supports_claims
            return Response(
                {"detail": f"payer {payer_code!r} cannot accept claims "
                 f"(unknown / inactive / unsupported)"},
                status=status.HTTP_422_UNPROCESSABLE_ENTITY)

        # deterministic mock adjudication
        if billed == 0:
            eob_status, approved, rej = "rejected", 0, 0
        elif rejected and rejected > 0:
            eob_status, approved, rej = "partial", billed - rejected, rejected
        else:
            eob_status, approved, rej = "approved", billed, 0

        # map EOB status -> claim_status enum value
        # (fully approved -> paid, partial -> partial_paid)
        status_enum = {
            "approved": "paid",
            "partial": "partial_paid",
            "rejected": "rejected",
        }[eob_status]

        ext_no = _ext_claim_no(claim_id)
        with connection.cursor() as cur:
            # advance claim: submitted -> adjudicated -> paid/partial/rejected
            cur.execute(
                "UPDATE mcms_billing.insurance_claim SET "
                "status=%s, submitted_at=now(), adjudicated_at=now(), "
                "approved_amount=%s, rejected_amount=%s, "
                "claim_no_external=%s, paid_at=%s "
                "WHERE claim_id=%s",
                [status_enum,
                 f"{approved:.2f}", f"{rej:.2f}", ext_no,
                 (timezone.now() if eob_status in ("approved", "partial") else None),
                 claim_id])
            remit = (f"835 remittance: claim {ext_no} -> {eob_status.upper()} "
                      f"paid={approved:.2f} rejected={rej:.2f}")
            cur.execute(
                "INSERT INTO mcms_billing.claim_response "
                "(claim_id, payer_code, status, approved_amount, rejected_amount, "
                "remittance, facility_id) VALUES (%s,%s,%s,%s,%s,%s,%s) "
                "RETURNING response_id",
                [claim_id, payer_code, eob_status, approved, rej, remit, facility or 1])
            resp_id = cur.fetchone()[0]
        return Response({
            "claim_id": claim_id, "claim_no_external": ext_no,
            "status": eob_status, "approved_amount": f"{approved:.2f}",
            "rejected_amount": f"{rej:.2f}", "response_id": resp_id,
            "remittance": remit,
        })


def _ext_claim_no(claim_id):
    return f"EXT{claim_id:08d}"
