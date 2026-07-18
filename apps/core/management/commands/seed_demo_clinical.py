"""Seed a small but coherent set of clinical demo data so the SPA's medical
workflow pages render real rows (patients, appointments, encounters, labs,
prescriptions, invoices, waste) instead of empty states.

Idempotent: guarded so re-running on every container start never duplicates.
We tag demo rows with a stable marker (MRN prefix / invoice_no prefix /
order_no prefix / note title) and skip if already present.

Run automatically from start.sh after provision_user, so both the live app
and the e2e DB show demo clinical data. Safe to run repeatedly.
"""
from django.core.management.base import BaseCommand
from django.db import transaction
from django.utils import timezone
import datetime

# Local imports kept inside the command to avoid import cost at startup.
from apps.core.models import Party  # type: ignore
from apps.core.models import AppUser  # type: ignore


def _now():
    return timezone.now()


class Command(BaseCommand):
    help = "Seed demo clinical data (idempotent) for the medical workflow pages."

    def _first(self, model, **kw):
        return model.objects.filter(**kw).first()

    def _patient(self, Party, Patient, mrn, first, last, gender):
        # update_or_create always applies defaults to the INSERT (unlike
        # get_or_create, which can omit a field whose value matches the
        # implied default and trip the preferred_language CHECK).
        party, _ = Party.objects.update_or_create(
            national_id=mrn,
            defaults={
                "party_type": "person",
                "code": mrn,
                "display_name": f"{first} {last}",
                "legal_name": f"{first} {last}",
                "gender": gender,
                "date_of_birth": datetime.date(1985, 1, 1),
                "is_active": True,
                "preferred_language": "en",
            },
        )
        patient, created = Patient.objects.get_or_create(
            mrn=mrn,
            defaults={
                "party_id": party.party_id,
                "emergency_contact_name": "Demo Contact",
                "emergency_contact_phone": "+10000000000",
                "next_of_kin_party_id": party.party_id,
                "insurance_provider": "Demo Insurer",
                "insurance_policy_no": f"POL-{mrn}",
                "insurance_group_no": "GRP-1",
                "preferred_language": "en",
            },
        )
        return patient, created

    @transaction.atomic
    def handle(self, *args, **opts):
        from apps.emr.models import Patient, Encounter, ClinicalNote, Vitals, MedicationOrder  # type: ignore
        from apps.clinic.models import Appointment, Room  # type: ignore
        from apps.lab.models import LabOrder, Sample, Result, TestPanel, TestCatalog  # type: ignore
        from apps.billing.models import Invoice, InvoiceLine, ServicePrice  # type: ignore
        from apps.hr.models import Department, Employee  # type: ignore
        from apps.waste.models import WasteCollection, WasteContainer  # type: ignore

        created = 0
        now = _now()

        # --- Demo patients (idempotent by MRN) ---
        patients = []
        for mrn, fn, ln, g in [
            ("MRN-DEMO-001", "Ahmad", "Mansour", "male"),
            ("MRN-DEMO-002", "Layla", "Haddad", "female"),
            ("MRN-DEMO-003", "Karim", "Nasser", "male"),
            ("MRN-DEMO-004", "Sara", "Khoury", "female"),
            ("MRN-DEMO-005", "Omar", "Saleh", "male"),
        ]:
            p, was_created = self._patient(Party, Patient, mrn, fn, ln, g)
            patients.append(p)
            created += 1 if was_created else 0
        self.stdout.write(f"patients: {len(patients)} (new {created})")

        # --- Department + clinician (use already-seeded rows) ---
        dept = Department.objects.first()
        clinician = AppUser.objects.filter(role="admin").first() or AppUser.objects.first()
        clinician_id = clinician.user_id if clinician else 1

        # --- Appointments (idempotent by MRN+starts_at) ---
        appt_created = 0
        for i, p in enumerate(patients[:4]):
            starts = now + datetime.timedelta(days=i, hours=9)
            if not Appointment.objects.filter(mrn=p.mrn, starts_at=starts).exists():
                Appointment.objects.create(
                    mrn=p.mrn,
                    patient_id=p.patient_id,
                    clinician_user_id=clinician_id,
                    department_id=dept.department_id if dept else 1,
                    starts_at=starts,
                    ends_at=starts + datetime.timedelta(minutes=30),
                    status="booked",
                    reason="Routine check-up",
                    booked_by=clinician_id,
                    patient_confirmed=False,
                )
                appt_created += 1
        self.stdout.write(f"appointments: +{appt_created}")

        # --- Encounters + notes + vitals (idempotent by patient+started_at) ---
        enc_created = 0
        for i, p in enumerate(patients):
            start = now - datetime.timedelta(days=i)
            enc = Encounter.objects.filter(patient_id=p.patient_id, started_at=start).first()
            if not enc:
                enc = Encounter.objects.create(
                    mrn=p,
                    patient=p,
                    status="finished",
                    class_field="ambulatory",
                    attending_user_id=clinician_id,
                    department_id=dept.department_id if dept else 1,
                    reason_for_visit="Demo visit",
                    chief_complaint="Routine",
                    started_at=start,
                    ended_at=start + datetime.timedelta(hours=1),
                )
                enc_created += 1
            if not ClinicalNote.objects.filter(encounter=enc, title="Demo Note").exists():
                ClinicalNote.objects.create(
                    encounter=enc, patient=p, note_type="progress",
                    title="Demo Note", body="Demonstration clinical note.",
                    author_user_id=clinician_id, signed=True,
                    signed_at=now, signed_by=clinician_id,
                )
            if not Vitals.objects.filter(encounter=enc).exists():
                Vitals.objects.create(
                    encounter=enc, patient=p, taken_at=start, taken_by=clinician_id,
                    temp_c=37.0, hr_bpm=80, rr_pm=16, sbp_mmhg=120, dbp_mmhg=80,
                    spo2_pct=98, weight_kg=70, height_cm=170, pain_score=0,
                )
        self.stdout.write(f"encounters: +{enc_created}")

        # --- Medication orders (idempotent by patient+ordered_at) ---
        med_created = 0
        drug = self._first(  # type: ignore
            __import__("apps.rx.models", fromlist=["DrugItem"]).DrugItem, generic_name="Paracetamol"
        ) if False else None
        from apps.rx.models import DrugItem  # type: ignore
        drug = DrugItem.objects.first()
        for i, p in enumerate(patients[:3]):
            ordered = now - datetime.timedelta(days=i)
            if not MedicationOrder.objects.filter(patient_id=p.patient_id, ordered_at=ordered).exists():
                MedicationOrder.objects.create(
                    encounter=None, patient=p,
                    prescriber_user_id=clinician_id,
                    drug_item_id=drug.drug_item_id if drug else 1,
                    drug_name=drug.generic_name if drug else "Paracetamol",
                    dose="500 mg", route="po", frequency="tid",
                    duration_days=5, prn=False, refill_count=0,
                    instructions="After meals", status="active",
                    signed=True, signed_at=now, signed_by=clinician_id, ordered_at=ordered,
                )
                med_created += 1
        self.stdout.write(f"medication_orders: +{med_created}")

        # Real encounter PK (encounters use auto IDs, not 1).
        first_enc = Encounter.objects.first()
        first_enc_id = first_enc.encounter_id if first_enc else 1

        # --- Lab orders + samples + results (idempotent by order_no) ---
        panel = TestPanel.objects.first()
        test = TestCatalog.objects.first()
        lab_created = 0
        for i, p in enumerate(patients[:3]):
            order_no = f"LAB-DEMO-{i+1:03d}"
            lo = LabOrder.objects.filter(order_no=order_no).first()
            if not lo:
                lo = LabOrder.objects.create(
                    order_no=order_no,
                    encounter_id=first_enc_id, patient_id=p.patient_id, mrn=p.mrn,
                    requested_by=clinician_id, order_priority="routine",
                    panel=panel, clinical_indication="Demo",
                    requested_at=now - datetime.timedelta(days=i),
                )
                sample = Sample.objects.create(
                    sample_no=f"SMP-DEMO-{i+1:03d}", lab_order=lo,
                    specimen_type="blood", volume_collected=5,
                    collected_at=now - datetime.timedelta(days=i),
                    collected_by=clinician_id, received_at=now,
                    received_by=clinician_id, status="received",
                )
                if test:
                    Result.objects.create(
                        sample=sample, test=test, value_text="Normal",
                        value_numeric=5.0, unit="g/dL", ref_range="4-6",
                        flag="normal", analysed_by=clinician_id, analysed_at=now,
                        verified_by=clinician_id, verified_at=now,
                    )
                lab_created += 1
        self.stdout.write(f"lab_orders: +{lab_created}")

        # --- Invoices + lines (idempotent by invoice_no) ---
        svc = ServicePrice.objects.first()
        inv_created = 0
        for i, p in enumerate(patients[:3]):
            inv_no = f"INV-DEMO-{i+1:03d}"
            inv = Invoice.objects.filter(invoice_no=inv_no).first()
            if not inv:
                total = 150.00
                inv = Invoice.objects.create(
                    invoice_no=inv_no, patient_id=p.patient_id, mrn=p.mrn,
                    encounter_id=first_enc_id, issued_by=clinician_id, status="issued",
                    subtotal=total, tax_amount=0, discount_amount=0,
                    insurance_covers=0, patient_pays=total, total=total,
                    currency="USD", issued_at=now,
                    due_date=now.date() + datetime.timedelta(days=30),
                )
                if svc:
                    from django.db import connection as _conn
                    with _conn.cursor() as cur:
                        # line_total is a GENERATED column (model drift) — omit it.
                        cur.execute(
                            """INSERT INTO mcms_billing.invoice_line
                               (invoice_id, service_id, source_schema, source_table,
                                source_id, description, qty, unit_price)
                               VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
                               ON CONFLICT DO NOTHING""",
                            [inv.invoice_id, svc.service_id, "billing",
                             "service_price", svc.service_id,
                             svc.name or "Service", 1, total],
                        )
                inv_created += 1
        self.stdout.write(f"invoices: +{inv_created}")

        # --- Waste collections (idempotent by collection_datetime+weight) ---
        container = WasteContainer.objects.first()
        waste_created = 0
        for i, p in enumerate(patients[:2]):
            cwhen = now - datetime.timedelta(days=i)
            if not WasteCollection.objects.filter(
                collection_datetime=cwhen, weight_kg=2.5
            ).exists():
                WasteCollection.objects.create(
                    container=container,
                    weight_kg=2.5,
                    collected_by_user_id=clinician_id,
                    collection_datetime=cwhen,
                    storage_location="Demo Storage",
                )
                waste_created += 1
        self.stdout.write(f"waste_collections: +{waste_created}")

        self.stdout.write(self.style.SUCCESS("seed_demo_clinical complete."))
