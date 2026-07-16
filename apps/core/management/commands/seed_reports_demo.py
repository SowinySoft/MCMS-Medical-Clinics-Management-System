"""seed_reports_demo — populate demo data for the Phase 17.1 Reports layer.

This is the ORM/write-path equivalent of the old raw-SQL seed (sql/39_report_seed.sql).
Routing the seed through the Django models means the data goes through the same
write path the application uses, so it can never drift from the real schema
(validators, GENERATED columns, FKs) the way direct INSERTs could. It is
idempotent (get_or_create / exists-check) so it is safe to run on every build.

Groups seeded:
  1) RBAC: payroll.read permission + role maps (admin, hr_clerk, billing_clerk)
  2) HR:   a July-2026 payroll period with employees + payroll items
  3) Billing: a few insurance_claims across statuses

Usage (after the schema + main seed exist):
    python manage.py seed_reports_demo
"""
from datetime import timedelta

from django.core.management.base import BaseCommand
from django.db import connection, transaction
from django.db.models import Min
from django.utils import timezone

from apps.billing.models import InsuranceClaim, Invoice
from apps.core.models import Facility, Party, Permission, Role, RolePermission
from apps.emr.models import Patient
from apps.hr.models import Department, Employee, PayrollItem, PayrollPeriod


# Fixed party ids keep demo employees from colliding with real data and let us
# keep the party sequence in sync (needed by the deep-integrity audit). Same
# values the old sql/39 used.
EMP_PARTY_IDS = [990001, 990002, 990003, 990004, 990005, 990006]
EMP_ROSTER = [
    # party_id, employee_no, dept_id, job_title, role, contract_type, salary
    (990001, "EMP-9001", 1, "Nurse", "nurse", "permanent", 4200.00),
    (990002, "EMP-9002", 1, "Clerk", "receptionist", "permanent", 3100.00),
    (990003, "EMP-9003", 2, "Cardiologist", "physician", "permanent", 11500.00),
    (990004, "EMP-9004", 2, "Technician", "lab_tech", "permanent", 5200.00),
    (990005, "EMP-9005", 3, "Surgeon", "surgeon", "permanent", 13200.00),
    (990006, "EMP-9006", 3, "Therapist", "physio_therapist", "contract", 4800.00),
]
PAYROLL_ITEMS = [
    # employee_no, base, overtime, deduction, bonus
    ("EMP-9001", 4200.00, 120.00, 380.00, 0.00),
    ("EMP-9002", 3100.00, 0.00, 290.00, 50.00),
    ("EMP-9003", 11500.00, 0.00, 1500.00, 800.00),
    ("EMP-9004", 5200.00, 300.00, 520.00, 0.00),
    ("EMP-9005", 13200.00, 0.00, 1900.00, 1500.00),
    ("EMP-9006", 4800.00, 240.00, 430.00, 0.00),
]
CLAIMS = [
    # claim_no, status, billed, approved, rejected, submitted_days_ago,
    # adjudicated_days_ago, paid_days_ago
    ("CLM-9001", "submitted", 1500.00, 0, 0, 5, None, None),
    ("CLM-9002", "processing", 2400.00, 2100.00, 0, 10, 4, None),
    ("CLM-9003", "paid", 3200.00, 3000.00, 0, 20, 12, 6),
    ("CLM-9004", "rejected", 900.00, 0, 900.00, 15, 9, None),
]


class Command(BaseCommand):
    help = "Seed demo data for the Reports layer via the Django ORM."

    def handle(self, *args, **options):
        with transaction.atomic():
            self._seed_rbac()
            period = self._seed_payroll()
            self._seed_claims()
            self._bump_party_sequence()
        self.stdout.write(self.style.SUCCESS(
            "Reports demo seed complete (period=%s, items=%d, claims=%d)."
            % (period.code if period else "-",
               len(PAYROLL_ITEMS), len(CLAIMS))))

    # ---- 1) RBAC -----------------------------------------------------------
    def _seed_rbac(self):
        perm, _ = Permission.objects.get_or_create(
            code="payroll.read",
            defaults={"description": "View payroll / HR accounting reports"})
        roles = ["admin", "hr_clerk", "billing_clerk"]
        for code in roles:
            role = Role.objects.filter(code=code).first()
            if not role:
                self.stderr.write(f"Role '{code}' not found — skipping role map")
                continue
            RolePermission.objects.get_or_create(role=role, permission=perm)

    # ---- 2) Payroll --------------------------------------------------------
    def _seed_payroll(self):
        period, _ = PayrollPeriod.objects.get_or_create(
            code="2026-07",
            defaults={
                "start_date": "2026-07-01",
                "end_date": "2026-07-31",
                "status": "paid",
                "closed_at": timezone.now(),
            })

        # parties for the demo employees (explicit ids, idempotent)
        for pid in EMP_PARTY_IDS:
            Party.objects.get_or_create(
                party_id=pid,
                defaults={
                    "party_type": "person",
                    "display_name": f"Payroll Test {chr(64 + pid - 990000)}",
                    "is_active": True,
                    "preferred_language": "en",
                })

        employees = {}
        for pid, eno, dept_id, title, role, ctype, salary in EMP_ROSTER:
            dept = Department.objects.filter(department_id=dept_id).first()
            if not dept:
                self.stderr.write(f"Department {dept_id} missing — skipping {eno}")
                continue
            emp, _ = Employee.objects.get_or_create(
                employee_no=eno,
                defaults={
                    "party_id": pid,
                    "primary_department": dept,
                    "job_title": title,
                    "role": role,
                    "contract_type": ctype,
                    "status": "active",
                    "base_salary_monthly": salary,
                    "hired_at": "2024-01-15",
                })
            employees[eno] = emp

        for eno, base, ot, ded, bonus in PAYROLL_ITEMS:
            emp = employees.get(eno)
            if not emp:
                continue
            if PayrollItem.objects.filter(period=period, employee=emp).exists():
                continue
            # net_amount is a DB-GENERATED column, so we MUST NOT INSERT it —
            # the database computes it. Django's ORM cannot omit a model field
            # from an INSERT, so we write this one row through a parameterized
            # cursor (the only generated column in the seed). All other rows go
            # through the ORM models above.
            with connection.cursor() as cur:
                cur.execute(
                    """INSERT INTO mcms_hr.payroll_item
                       (period_id, employee_id, base_amount, overtime_amount,
                        deduction_amount, bonus_amount, is_paid)
                       VALUES (%s, %s, %s, %s, %s, %s, FALSE)""",
                    [period.period_id, emp.employee_id, base, ot, ded, bonus])

        return period

    # ---- 3) Insurance claims ---------------------------------------------
    def _seed_claims(self):
        invoice = Invoice.objects.order_by("invoice_id").first()
        if not invoice:
            self.stderr.write("No invoice present — skipping insurance_claim seed")
            return
        patient_min = Patient.objects.aggregate(m=Min("patient_id"))["m"]
        if not patient_min:
            self.stderr.write("No patient present — skipping insurance_claim seed")
            return
        facility = Facility.objects.order_by("facility_id").first()
        if not facility:
            self.stderr.write("No facility present — skipping insurance_claim seed")
            return

        now = timezone.now()
        for (cno, status, billed, approved, rejected,
             sub_ago, adj_ago, paid_ago) in CLAIMS:
            if InsuranceClaim.objects.filter(claim_no_external=cno).exists():
                continue
            InsuranceClaim.objects.create(
                invoice=invoice,
                patient_id=patient_min,
                insurance_provider="MOH",
                policy_no="POL-" + cno.split("-")[-1],
                facility_id=facility.facility_id,
                claim_no_external=cno,
                status=status,
                billed_amount=billed,
                approved_amount=approved,
                rejected_amount=rejected,
                submitted_at=now - timedelta(days=sub_ago),
                adjudicated_at=(now - timedelta(days=adj_ago)) if adj_ago else None,
                paid_at=(now - timedelta(days=paid_ago)) if paid_ago else None)

    # ---- keep party sequence ahead of explicit ids -----------------------
    def _bump_party_sequence(self):
        with connection.cursor() as cur:
            cur.execute(
                "SELECT setval('mcms_core.party_party_id_seq', "
                "GREATEST(990006, (SELECT COALESCE(max(party_id),0) "
                "FROM mcms_core.party)))")
