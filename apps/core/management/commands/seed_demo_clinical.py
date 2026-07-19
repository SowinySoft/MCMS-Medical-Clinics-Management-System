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

    def _generated_columns(self, schema, table):
        """Return DB columns that are GENERATED ALWAYS (Django may mark them
        editable, causing 'cannot insert a non-DEFAULT value' errors)."""
        from django.db import connection
        try:
            with connection.cursor() as cur:
                cur.execute(
                    """SELECT column_name FROM information_schema.columns
                       WHERE table_schema=%s AND table_name=%s
                         AND is_generated='ALWAYS'""",
                    [schema, table],
                )
                return {r[0] for r in cur.fetchall()}
        except Exception:
            return set()

    def _fk_real_id(self, schema, table, column):
        """If a plain integer column is actually a DB foreign key, return a real
        existing PK value from the referenced table (or None). Uses pg_constraint
        (information_schema.constraint_column_usage misses some FKs)."""
        from django.db import connection
        try:
            with connection.cursor() as cur:
                cur.execute(
                    """SELECT ns2.nspname, cl2.relname, att2.attname
                       FROM pg_constraint con
                       JOIN pg_class cl1 ON cl1.oid = con.conrelid
                       JOIN pg_namespace ns1 ON ns1.oid = cl1.relnamespace
                       JOIN pg_attribute att1
                         ON att1.attrelid = con.conrelid AND att1.attnum = con.conkey[1]
                       JOIN pg_class cl2 ON cl2.oid = con.confrelid
                       JOIN pg_namespace ns2 ON ns2.oid = cl2.relnamespace
                       JOIN pg_attribute att2
                         ON att2.attrelid = con.confrelid AND att2.attnum = con.confkey[1]
                       WHERE con.contype = 'f'
                         AND ns1.nspname = %s AND cl1.relname = %s
                         AND att1.attname = %s
                         AND array_length(con.conkey, 1) = 1
                       LIMIT 1""",
                    [schema, table, column],
                )
                ref = cur.fetchone()
                if not ref:
                    return None
                rs, rt, rc = ref
                cur.execute(f'SELECT "{rc}" FROM "{rs}"."{rt}" LIMIT 1')
                row = cur.fetchone()
                return row[0] if row else None
        except Exception:
            return None

    def _enum_values(self, schema, table, column):
        """Return the valid labels of a Postgres enum column (Django may model
        it as a plain TextField/CharField, so f.choices is empty)."""
        from django.db import connection
        try:
            with connection.cursor() as cur:
                cur.execute(
                    """SELECT e.enumlabel
                       FROM pg_attribute a
                       JOIN pg_class cl ON cl.oid = a.attrelid
                       JOIN pg_namespace n ON n.oid = cl.relnamespace
                       JOIN pg_type t ON t.oid = a.atttypid
                       JOIN pg_enum e ON e.enumtypid = t.oid
                       WHERE n.nspname = %s AND cl.relname = %s AND a.attname = %s
                       ORDER BY e.enumsortorder""",
                    [schema, table, column],
                )
                rows = [r[0] for r in cur.fetchall()]
            return rows
        except Exception:
            return []

    def _seed_generic(self, model, marker_field=None, marker_value=None, extra=None, _seen=None):
        """Resiliently create ONE demo row in `model` by introspecting fields.

        - Skips PK / auto / GENERATED / editable=False columns.
        - For required scalars with no default: fills type-appropriate dummies
          (arrays use their base type; enums use the first choice).
        - For FK fields: resolves to an existing related row, OR recursively
          seeds that (empty) parent table first, so FK chains resolve.
        - Returns (created_bool, note). Never raises — reports and skips.
        """
        if _seen is None:
            _seen = set()
        # idempotency guard (optional marker, or rely on caller's table-empty check)
        if marker_field:
            try:
                if model.objects.filter(**{marker_field: marker_value}).exists():
                    return False, "exists"
            except Exception:
                pass

        opts = model._meta
        vals = dict(extra or {})
        _dbt = opts.db_table.replace('"', "")
        _schema, _table = (_dbt.split(".") + ["", ""])[:2] if "." in _dbt else ("public", _dbt)
        _db_generated = self._generated_columns(_schema, _table)
        for f in opts.fields:
            if f.primary_key or f.auto_created:
                continue
            if getattr(f, "generated", False):  # GENERATED ALWAYS column
                continue
            if f.column in _db_generated:  # DB-side GENERATED (Django unaware)
                continue
            if not f.editable:
                continue
            if f.name in vals:
                continue
            if f.has_default() and f.default is not None:
                continue
            if f.null and not f.blank:
                # nullable but no default — leave as NULL (DB allows)
                continue
            if f.is_relation:
                rel = f.related_model
                try:
                    obj = rel.objects.first()
                except Exception:
                    obj = None
                if obj is None:
                    # recursively seed the (empty) parent table once
                    rlabel = f"{rel._meta.app_label}.{rel.__name__}"
                    if rlabel not in _seen and rel._meta.db_table.startswith("mcms_"):
                        _seen.add(rlabel)
                        self._seed_generic(rel, _seen=_seen)
                        try:
                            obj = rel.objects.first()
                        except Exception:
                            obj = None
                    if obj is None:
                        return False, f"no-ref:{f.name}"
                # assign the related instance (works for both true FKs and
                # BigInteger-typed cross-schema refs)
                vals[f.name] = obj
                continue
            # scalar, required, no default -> dummy by type
            # If the underlying DB column is a Postgres enum (Django may model
            # it as a plain TextField), use the first valid enum label.
            dbt = opts.db_table.replace('"', "")
            schema, table = (dbt.split(".") + ["", ""])[:2] if "." in dbt else ("public", dbt)
            enum_labels = self._enum_values(schema, table, f.column)
            if enum_labels:
                vals[f.name] = enum_labels[0]
                continue
            ft = f.get_internal_type()
            if ft == "ArrayField":
                base = getattr(f, "base_field", None)
                bft = base.get_internal_type() if base else "TextField"
                if bft in ("IntegerField", "BigIntegerField", "DecimalField", "FloatField"):
                    vals[f.name] = [1]
                elif bft in ("BooleanField",):
                    vals[f.name] = [True]
                else:
                    vals[f.name] = ["demo"]
            elif ft in ("CharField", "TextField", "SlugField", "EmailField", "URLField"):
                vals[f.name] = f"demo-{marker_value}" if marker_value else "demo"
            elif ft in ("IntegerField", "BigIntegerField", "SmallIntegerField", "PositiveIntegerField", "PositiveSmallIntegerField"):
                # a plain integer column may actually be a DB foreign key
                fk_val = self._fk_real_id(schema, table, f.column)
                vals[f.name] = fk_val if fk_val is not None else 1
            elif ft in ("DecimalField", "FloatField"):
                vals[f.name] = 1.0
            elif ft == "BooleanField":
                vals[f.name] = True
            elif ft == "DateField":
                vals[f.name] = datetime.date(2025, 1, 1)
            elif ft in ("DateTimeField",):
                vals[f.name] = _now()
            elif ft in ("TimeField",):
                vals[f.name] = datetime.time(9, 0)
            elif ft == "UUIDField":
                import uuid
                vals[f.name] = str(uuid.uuid4())
            elif ft == "JSONField":
                vals[f.name] = {}
            else:
                vals[f.name] = "demo"
        # choose a valid enum value if the field uses choices
        for f in opts.fields:
            if f.name in vals and getattr(f, "choices", None):
                try:
                    vals[f.name] = f.choices[0][0]
                except Exception:
                    pass
        try:
            with transaction.atomic():  # savepoint: a failure here won't
                model.objects.create(**vals)  # poison the outer transaction
            return True, "ok"
        except Exception as e:  # never break the deploy
            return False, f"err:{type(e).__name__}:{str(e)[:80]}"

    @transaction.atomic
    def handle(self, *args, **opts):
        from apps.emr.models import Patient, Encounter, ClinicalNote, Vitals, MedicationOrder  # type: ignore
        from apps.clinic.models import Appointment, Room  # type: ignore
        from apps.lab.models import LabOrder, Sample, Result, TestPanel, TestCatalog  # type: ignore
        from apps.billing.models import Invoice, InvoiceLine, ServicePrice  # type: ignore
        from apps.hr.models import Department, Employee  # type: ignore
        from apps.waste.models import WasteCollection, WasteContainer  # type: ignore
        from apps.clinic.models import Appointment, Room, PatientQueue, Consultation  # type: ignore
        from apps.emr.models import (  # type: ignore
            Encounter, ClinicalNote, Vitals, MedicationOrder,
            Allergy, FamilyHistory, Immunization, SocialHistory,
        )
        from apps.core.models import EventLog, AuditTrail  # type: ignore
        from apps.surgical.models import Surgery, OperatingRoom, ProcedureCatalog, IntraOpVitals  # type: ignore
        from apps.emergency.models import Triage  # type: ignore

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

        # --- Targeted specialty coverage (chicken-and-egg FK tables) ---
        # These need specific FK resolution the generic seeder can't do.
        spec_created = 0

        # emr allergy / family history / immunization / social history
        for p in patients:
            if not Allergy.objects.filter(patient=p).exists():
                Allergy.objects.create(patient=p, substance="Penicillin",
                    reaction="Rash", severity="moderate", onset_age="childhood",
                    noted_on=now, noted_by=clinician_id, is_active=True)
                spec_created += 1
            if not FamilyHistory.objects.filter(patient=p).exists():
                FamilyHistory.objects.create(patient=p, relative="Father",
                    relationship="father", condition_code="I10",
                    condition_desc="Hypertension", age_at_onset=50,
                    is_deceased=False, recorded_at=now)
                spec_created += 1
            if not Immunization.objects.filter(patient=p).exists():
                Immunization.objects.create(patient=p, vaccine_code="COVID-19",
                    vaccine_name="COVID-19 vaccine", dose_number=2, given_at=now,
                    given_by=clinician_id, lot_number="LOT-DEMO", site="LA",
                    reaction="none")
                spec_created += 1
            if not SocialHistory.objects.filter(patient=p).exists():
                from django.db import connection as _conn
                with _conn.cursor() as cur:
                    # illicit_drugs is a real text[] column (model drift: TextField)
                    cur.execute(
                        """INSERT INTO mcms_emr.social_history
                           (patient_id, tobacco_status, packs_per_day, years_smoked,
                            alcohol_status, drinks_per_week, illicit_drugs, occupation,
                            relationship_status, recorded_at)
                           SELECT %s,%s,%s,%s,%s,%s,%s,%s,%s,%s
                           WHERE NOT EXISTS (
                             SELECT 1 FROM mcms_emr.social_history WHERE patient_id=%s)""",
                        [p.patient_id, "never", 0, 0, "none", 0,
                         ["none"], "Demo", "married", now, p.patient_id],
                    )
                spec_created += 1

        # clinic room (needed by patient-queue + consultation)
        room = Room.objects.first()
        if not room:
            from django.db import connection as _conn
            with _conn.cursor() as cur:
                # equipment is a real text[] column (model drift: TextField)
                cur.execute(
                    """INSERT INTO mcms_clinic.room
                       (department_id, code, name, capacity, equipment, is_active)
                       VALUES (%s,%s,%s,%s,%s,%s) RETURNING room_id""",
                    [dept.department_id if dept else 1, "R-DEMO-01",
                     "Demo Room", 2, ["bed", "monitor"], True],
                )
                _row = cur.fetchone()
                rid = _row[0] if _row else None
            if rid is None:
                room = Room.objects.first()
            else:
                room = Room.objects.get(room_id=rid)
            spec_created += 1

        # clinic patient-queue (FK room + patient)
        first_appt = Appointment.objects.first()
        if not PatientQueue.objects.exists() and first_appt:
            pq = PatientQueue.objects.create(
                patient_id=patients[0].patient_id, mrn=patients[0].mrn,
                department_id=dept.department_id if dept else 1,
                assigned_clinician=clinician_id, room=room, priority=1,
                status="waiting", checked_in_at=now, started_at=now,
                finished_at=now, encounter_id=first_enc_id)
            spec_created += 1
        else:
            pq = PatientQueue.objects.first()

        # clinic consultation (FK appointment + queue + room)
        if not Consultation.objects.exists() and first_appt and pq:
            Consultation.objects.create(
                appointment=first_appt, queue=pq, encounter_id=first_enc_id,
                room=room, clinician_user_id=clinician_id, duration_minutes=15,
                subjective="Demo subjective", objective="Demo objective",
                assessment="Demo assessment", plan="Demo plan",
                follow_up_days=7, status="completed", started_at=now, completed_at=now)
            spec_created += 1

        # core audit trail (needs EventLog row)
        if not EventLog.objects.exists():
            ev = EventLog.objects.create(event_type="demo",
                occurred_at=now, payload={})
            spec_created += 1
        else:
            ev = EventLog.objects.first()
        if not AuditTrail.objects.exists():
            AuditTrail.objects.create(table_schema="mcms_core",
                table_name="party", row_id=1, action="update",
                changed_by=clinician, changed_at=now, before={}, after={},
                event=ev)
            spec_created += 1

        # surgical surgery (needs real patient/encounter ids for the
        # BigInteger cross-schema FK columns the generic filler can't resolve)
        if not Surgery.objects.exists():
            or_room = OperatingRoom.objects.first()
            proc = ProcedureCatalog.objects.first()
            Surgery.objects.create(
                operation_no="OP-DEMO-001",
                encounter_id=first_enc_id,
                patient_id=patients[0].patient_id,
                or_field=or_room,
                surgeon_user_id=clinician_id,
                anaesthetist_user_id=clinician_id,
                primary_dept_id=dept.department_id if dept else 1,
                procedure=proc,
                laterality="left",
                status="completed",
                scheduled_at=now, incision_at=now, closure_at=now,
                patient_in_or_at=now, patient_out_or_at=now,
                anaesthesia_type="general", blood_loss_ml=50,
                tourniquet_time_minutes=0, complications="none",
                notes="Demo surgery")
            spec_created += 1

        # intra-op vitals (hr_bpm has a CHECK (>=10 AND <=280) the generic
        # filler's dummy of 1 violates — seed explicit valid vitals)
        if not IntraOpVitals.objects.exists():
            surg = Surgery.objects.first()
            IntraOpVitals.objects.create(
                surgery=surg, recorded_at=now, recorded_by=clinician_id,
                hr_bpm=80, sbp_mmhg=120, dbp_mmhg=80, spo2_pct=98,
                etco2_mmhg=35, anaesthesia_depth=40, temp_c=36.5,
                urine_ml=200, notes="Demo intra-op vitals")
            spec_created += 1

        # emergency triage (meds_on_arrival is a text[] drift col; insert only
        # the truly-required columns via raw SQL to sidestep it)
        if not Triage.objects.exists():
            from django.db import connection as _conn
            with _conn.cursor() as cur:
                cur.execute(
                    """INSERT INTO mcms_emergency.triage
                       (ed_visit_no, patient_id, mrn, encounter_id,
                        chief_complaint, esi_level, triaged_at, status)
                       VALUES (%s,%s,%s,%s,%s,%s,now(),'in_treatment')""",
                    ["EV-DEMO-001", patients[0].patient_id, patients[0].mrn,
                     first_enc_id, "Chest pain", 2],
                )
            spec_created += 1

        # emergency resuscitation (has a text[] drift col + triage FK; raw SQL,
        # required cols only)
        from django.db import connection as _rc
        with _rc.cursor() as cur:
            cur.execute("SELECT triage_id FROM mcms_emergency.triage LIMIT 1")
            _trow = cur.fetchone()
            cur.execute("SELECT COUNT(*) FROM mcms_emergency.resuscitation")
            _rrow = cur.fetchone()
            _rcount = _rrow[0] if _rrow else 0
            if _rcount == 0 and _trow:
                cur.execute(
                    """INSERT INTO mcms_emergency.resuscitation
                       (triage_id, encounter_id, patient_id)
                       VALUES (%s,%s,%s)""",
                    [_trow[0], first_enc_id, patients[0].patient_id],
                )
                spec_created += 1

        # --- raw-SQL block for tables the ORM + generic filler can't satisfy
        # (GENERATED cols / CHECK constraints / self-FKs). Every parent lookup
        # is guarded AND missing parents are seeded explicitly, because on a
        # FRESH prod DB (proven by the live deploy log) these parent tables are
        # EMPTY — an unguarded fetchone()[0] previously crashed and rolled back
        # the entire atomic seed. Each insert is wrapped in its own savepoint. ---
        def _scalar(sql, params=None):
            with _rc.cursor() as c:
                c.execute(sql, params or [])
                row = c.fetchone()
            return row[0] if row else None

        def _count(tbl):
            v = _scalar("SELECT COUNT(*) FROM " + tbl)
            return v or 0

        def _ins(sql, params):
            with _rc.cursor() as c:
                c.execute(sql, params)

        def _try(fn, label):
            nonlocal spec_created
            try:
                with transaction.atomic():  # savepoint isolates failures
                    if fn():
                        spec_created += 1
            except Exception as e:
                self.stdout.write(f"  raw-seed skip {label}: {type(e).__name__}: {str(e)[:80]}")

        # Seed empty parents (FRESH prod DB has none of these).
        def _ensure_admission():
            if _count("mcms_icu.admission"):
                return
            _ins("INSERT INTO mcms_icu.admission (encounter_id, patient_id, mrn) VALUES (%s,%s,'ADM-DEMO-001')",
                 [first_enc_id, patients[0].patient_id])
        _try(_ensure_admission, "icu.admission")

        def _party_id():
            return _scalar("SELECT MIN(party_id) FROM mcms_core.party")
        # erp.supplier: reference data is NOT shipped in the SQL dump, so create
        # a demo supplier (from an existing party) if the table is empty. PO and
        # GRN handlers below depend on at least one supplier existing.
        def _ensure_supplier():
            if _count("mcms_erp.supplier"):
                return
            pid = _scalar("SELECT MIN(party_id) FROM mcms_core.party")
            if pid is None:
                return
            _ins("INSERT INTO mcms_erp.supplier (party_id, supplier_code, facility_id) VALUES (%s,'SUP-DEMO-001',1)",
                 [pid])
        _try(_ensure_supplier, "erp.supplier")

        # erp.purchase_order: supplier_id -> supplier(supplier_id) (NOT party)
        def _ensure_po():
            if _count("mcms_erp.purchase_order"):
                return
            sid = _scalar("SELECT supplier_id FROM mcms_erp.supplier LIMIT 1")
            if sid is None:
                return
            st = (self._enum_values("mcms_erp", "purchase_order", "status") or ["draft"])[0]
            _ins("INSERT INTO mcms_erp.purchase_order (po_no, supplier_id, requested_by, facility_id, status, ordered_at) VALUES ('PO-DEMO-001',%s,%s,1,%s,now())",
                 [sid, clinician_id, st])
        _try(_ensure_po, "erp.purchase_order")

        # erp.goods_receipt: supplier_id -> supplier(supplier_id) (NOT party)
        def _ensure_grn():
            if _count("mcms_erp.goods_receipt"):
                return
            sid = _scalar("SELECT supplier_id FROM mcms_erp.supplier LIMIT 1")
            if sid is None:
                return
            st = (self._enum_values("mcms_erp", "goods_receipt", "status") or ["received"])[0]
            _ins("INSERT INTO mcms_erp.goods_receipt (grn_no, supplier_id, received_by, facility_id, status) VALUES ('GRN-DEMO-001',%s,%s,1,%s)",
                 [sid, clinician_id, st])
        _try(_ensure_grn, "erp.goods_receipt")

        # rx.drug_lot: depends on purchase_order + drug_item + supplier party
        def _ensure_lot():
            if _count("mcms_rx.drug_lot"):
                return
            poid = _scalar("SELECT po_id FROM mcms_erp.purchase_order LIMIT 1")
            di = _scalar("SELECT drug_item_id FROM mcms_rx.drug_item LIMIT 1")
            pid = _party_id()
            if poid is None or di is None or pid is None:
                return
            st = (self._enum_values("mcms_rx", "drug_lot", "status") or ["on_hand"])[0]
            _ins("""INSERT INTO mcms_rx.drug_lot
                   (drug_item_id, lot_number, received_qty, on_hand_qty, expires_on,
                    unit_cost, purchase_order_id, supplier_party_id, status, received_at)
                   VALUES (%s,'LOT-DEMO-001',100,100,now()+'1 year',10.0,%s,%s,%s,now())""",
                 [di, poid, pid, st])
        _try(_ensure_lot, "rx.drug_lot")

        # rx.prescription: status enum + facility_id NOT NULL
        def _ensure_rx():
            if _count("mcms_rx.prescription"):
                return
            di = _scalar("SELECT drug_item_id FROM mcms_rx.drug_item LIMIT 1")
            enc = _scalar("SELECT encounter_id FROM mcms_emr.encounter LIMIT 1")
            if di is None or enc is None:
                return
            st = (self._enum_values("mcms_rx", "prescription", "status") or ["draft"])[0]
            _ins("""INSERT INTO mcms_rx.prescription
                   (patient_id, mrn, prescriber_user_id, drug_item_id, facility_id, status)
                   SELECT p.patient_id, p.mrn, %s, %s, 1, %s
                   FROM mcms_emr.encounter e JOIN mcms_emr.patient p ON p.patient_id=e.patient_id
                   WHERE e.encounter_id=%s LIMIT 1""",
                 [clinician_id, di, st, enc])
        _try(_ensure_rx, "rx.prescription")

        # rx.dispensation: lot_id FK -> drug_lot (seeded above)
        def _ensure_disp():
            if _count("mcms_rx.dispensation"):
                return
            lot = _scalar("SELECT lot_id FROM mcms_rx.drug_lot LIMIT 1")
            enc = _scalar("SELECT encounter_id FROM mcms_emr.encounter LIMIT 1")
            di = _scalar("SELECT drug_item_id FROM mcms_rx.drug_lot LIMIT 1")
            mo = _scalar("SELECT order_id FROM mcms_emr.medication_order LIMIT 1")
            pt = _scalar("SELECT patient_id FROM mcms_emr.patient LIMIT 1")
            mrn = _scalar("SELECT mrn FROM mcms_emr.patient LIMIT 1")
            if lot is None or enc is None or di is None or pt is None or mrn is None:
                return
            _ins("""INSERT INTO mcms_rx.dispensation
                   (patient_id, mrn, drug_item_id, quantity, dispensed_by, lot_id, encounter_id, med_order_id)
                   VALUES (%s,%s,%s,5,%s,%s,%s,%s)""",
                 [pt, mrn, di, clinician_id, lot, enc, mo])
        _try(_ensure_disp, "rx.dispensation")

        # hr.payroll_period: CHECK(end_date > start_date) + status
        def _ensure_pp():
            if _count("mcms_hr.payroll_period"):
                return
            st = (self._enum_values("mcms_hr", "payroll_period", "status") or ["closed"])[0]
            _ins("INSERT INTO mcms_hr.payroll_period (code, start_date, end_date, status) VALUES ('PP-DEMO-2026-01','2026-01-01','2026-01-31',%s)",
                 [st])
        _try(_ensure_pp, "hr.payroll_period")

        # hr.payroll_item: FK period -> payroll_period (seeded above)
        def _ensure_pi():
            if _count("mcms_hr.payroll_item"):
                return
            pid = _scalar("SELECT period_id FROM mcms_hr.payroll_period LIMIT 1")
            eid = _scalar("SELECT employee_id FROM mcms_hr.employee LIMIT 1")
            if pid is None or eid is None:
                return
            _ins("INSERT INTO mcms_hr.payroll_item (period_id, employee_id, base_amount) VALUES (%s,%s,5000.00)",
                 [pid, eid])
        _try(_ensure_pi, "hr.payrollitem")

        # vital_records.birth_certificate: status enum + many FK (patient/facility/encounter)
        def _ensure_bc():
            if _count("mcms_vital_records.birth_certificate"):
                return
            nb = _scalar("SELECT patient_id FROM mcms_emr.patient LIMIT 1")
            mom = nb
            fac = _scalar("SELECT facility_id FROM mcms_core.facility LIMIT 1")
            enc = _scalar("SELECT encounter_id FROM mcms_emr.encounter LIMIT 1")
            fpid = _party_id()
            if nb is None or fac is None or enc is None or fpid is None:
                return
            st = (self._enum_values("mcms_vital_records", "birth_certificate", "status") or ["issued"])[0]
            if st not in ("issued", "amended"):
                st = "issued"
            _ins("""INSERT INTO mcms_vital_records.birth_certificate
                   (registration_no, newborn_patient_id, mother_patient_id, father_party_id,
                    facility_id, delivery_encounter_id, birth_datetime, status)
                   VALUES ('BC-DEMO-001',%s,%s,%s,%s,%s,now(),%s)""",
                 [nb, mom, fpid, fac, enc, st])
        _try(_ensure_bc, "vital_records.birth_certificate")

        # vital_records.death_certificate: status enum + FK patient/facility + coroner_case bool
        def _ensure_dc():
            if _count("mcms_vital_records.death_certificate"):
                return
            pt = _scalar("SELECT patient_id FROM mcms_emr.patient ORDER BY patient_id DESC LIMIT 1")
            fac = _scalar("SELECT facility_id FROM mcms_core.facility LIMIT 1")
            if pt is None or fac is None:
                return
            st = (self._enum_values("mcms_vital_records", "death_certificate", "status") or ["issued"])[0]
            if st not in ("issued", "amended"):
                st = "issued"
            _ins("""INSERT INTO mcms_vital_records.death_certificate
                   (registration_no, patient_id, facility_id, death_datetime, coroner_case, status)
                   VALUES ('DC-DEMO-001',%s,%s,now(),false,%s)""",
                 [pt, fac, st])
        _try(_ensure_dc, "vital_records.death_certificate")


        def _da():
            if _count("mcms_rx.drug_alternative"):
                return False
            d = _scalar("SELECT array_agg(drug_item_id ORDER BY drug_item_id) FROM (SELECT drug_item_id FROM mcms_rx.drug_item LIMIT 2) t")
            if not d or len(d) < 2:
                return False
            _ins("INSERT INTO mcms_rx.drug_alternative (drug_item_id, alt_drug_item_id) VALUES (%s,%s)", [d[0], d[1]])
            return True
        _try(_da, "rx.drug_alternative")

        # rx.stock_movement: enum move_type + FK drug_item
        def _sm():
            if _count("mcms_rx.stock_movement"):
                return False
            di = _scalar("SELECT drug_item_id FROM mcms_rx.drug_item LIMIT 1")
            if di is None:
                return False
            mt = (self._enum_values("mcms_rx", "stock_movement", "movement_type") or ["issue"])[0]
            _ins("INSERT INTO mcms_rx.stock_movement (drug_item_id, movement_type, qty_delta, balance_after) VALUES (%s,%s,10,10)", [di, mt])
            return True
        _try(_sm, "rx.stock_movement")

        # icu.vitals_stream: CHECK(gcs 3..15) + FK admission/patient
        def _vs():
            if _count("mcms_icu.vitals_stream"):
                return False
            aid = _scalar("SELECT admission_id FROM mcms_icu.admission LIMIT 1")
            if aid is None:
                return False
            _ins("INSERT INTO mcms_icu.vitals_stream (admission_id, patient_id) VALUES (%s,%s)", [aid, patients[0].patient_id])
            return True
        _try(_vs, "icu.vitals_stream")

        # erp.purchase_order_line: line_total is GENERATED (omit it)
        def _pol():
            if _count("mcms_erp.purchase_order_line"):
                return False
            poid = _scalar("SELECT po_id FROM mcms_erp.purchase_order LIMIT 1")
            di = _scalar("SELECT drug_item_id FROM mcms_rx.drug_item LIMIT 1")
            if poid is None or di is None:
                return False
            _ins("INSERT INTO mcms_erp.purchase_order_line (po_id, drug_item_id, item_description, qty, unit_price) VALUES (%s,%s,%s,%s,%s)", [poid, di, "Demo PO line", 5, 10.0])
            return True
        _try(_pol, "erp.purchase_order_line")

        # erp.goods_receipt_line: FK grn + po_line
        def _grl():
            if _count("mcms_erp.goods_receipt_line"):
                return False
            grn = _scalar("SELECT grn_id FROM mcms_erp.goods_receipt LIMIT 1")
            pol = _scalar("SELECT line_id FROM mcms_erp.purchase_order_line LIMIT 1")
            if grn is None or pol is None:
                return False
            _ins("INSERT INTO mcms_erp.goods_receipt_line (grn_id, po_line_id, qty_received) VALUES (%s,%s,%s)", [grn, pol, 5])
            return True
        _try(_grl, "erp.goods_receipt_line")

        # --- Demo coverage for operational / integration tables that would
        # otherwise stay empty (claims, eligibility, telemed, terminology,
        # federated identity, HL7, backup log). Each inserts a single realistic
        # demo row so the UI is not blank in a fresh demo deploy. Wrapped in
        # their own savepoints like every other raw insert above. ---

        def _ensure_telemed_visit():
            if _count("mcms_telemed.visit"):
                return False
            p = patients[0]
            _ins("""INSERT INTO mcms_telemed.visit
                   (patient_id, mrn, clinician_user_id, encounter_id, mode, status,
                    subjective, objective, assessment, plan)
                   VALUES (%s,%s,%s,%s,'video','completed',
                           'Routine tele-consult', 'Stable', 'Follow-up', 'Continue meds')""",
                 [p.patient_id, p.mrn, clinician_id, first_enc_id])
            return True
        _try(_ensure_telemed_visit, "telemed.visit")

        def _ensure_eligibility_check():
            if _count("mcms_billing.eligibility_check"):
                return False
            p = patients[0]
            _ins("""INSERT INTO mcms_billing.eligibility_check
                   (patient_id, payer_code, policy_no, status, reason, checked_at)
                   VALUES (%s,'TML','POL-DEMO-001','eligible','Demo eligibility OK',now())""",
                 [p.patient_id])
            return True
        _try(_ensure_eligibility_check, "billing.eligibility_check")

        def _ensure_claim_response():
            if _count("mcms_billing.claim_response"):
                return False
            inv_id = _scalar("SELECT invoice_id FROM mcms_billing.invoice LIMIT 1")
            if inv_id is None:
                return False
            # Create a matching insurance_claim if none exists, then its response.
            claim_id = _scalar("SELECT claim_id FROM mcms_billing.insurance_claim LIMIT 1")
            if claim_id is None:
                p = patients[0]
                _ins("""INSERT INTO mcms_billing.insurance_claim
                       (invoice_id, policy_no, insurance_provider, patient_id,
                        billed_amount, status)
                       VALUES (%s,'POL-DEMO-001','TML',%s,100.00,'adjudicated')""",
                     [inv_id, p.patient_id])
                claim_id = _scalar("SELECT claim_id FROM mcms_billing.insurance_claim LIMIT 1")
            if claim_id is None:
                return False
            _ins("""INSERT INTO mcms_billing.claim_response
                   (claim_id, payer_code, status, approved_amount, rejected_amount,
                    remittance, received_at)
                   VALUES (%s,'TML','paid',100.00,0.00,'Demo remittance advice',now())""",
                 [claim_id])
            return True
        _try(_ensure_claim_response, "billing.claim_response")

        def _ensure_terminology_concept():
            if _count("mcms_terminology.concept"):
                return False
            fac = _scalar("SELECT facility_id FROM mcms_core.facility LIMIT 1") or 1
            _ins("""INSERT INTO mcms_terminology.concept
                   (code_system, code, display, display_ar, synonyms, source, facility_id)
                   VALUES ('SNOMED-CT','123456','Acute myocardial infarction',
                           'احتشاء عضلة القلب', 'AMI; MI','demo-seed',%s)""",
                 [fac])
            return True
        _try(_ensure_terminology_concept, "terminology.concept")

        def _ensure_federated_identity():
            if _count("mcms_core.federated_identity"):
                return False
            uid = _scalar("SELECT user_id FROM mcms_core.app_user LIMIT 1")
            if uid is None:
                return False
            _ins("""INSERT INTO mcms_core.federated_identity
                   (provider_code, external_subject, user_id, linked_at, last_seen_at)
                   VALUES ('moh_oidc','demo-subject-001',%s,now(),now())""",
                 [uid])
            return True
        _try(_ensure_federated_identity, "core.federated_identity")

        def _ensure_hl7_message():
            if _count("mcms_core.hl7_message"):
                return False
            _ins("""INSERT INTO mcms_core.hl7_message
                   (message_control_id, message_type, sending_app, sending_facility,
                    raw, ack_code)
                   VALUES ('MCM-DEMO-001','ADT^A01','MCMS','DEMO-FAC',
                           'MSH|^~\\&|MCMS|DEMO|FAC|DEMO|20240101000000||ADT^A01|MCM-DEMO-001|P|2.5','AA')""",
                 [])
            return True
        _try(_ensure_hl7_message, "core.hl7_message")

        def _ensure_backup_log():
            if _count("mcms_core.backup_log"):
                return False
            _ins("""INSERT INTO mcms_core.backup_log
                   (started_at, finished_at, filename, size_bytes, status, detail,
                    triggered_by)
                   VALUES (now(), now(), 'mcms_demo_backup.dump', 1048576, 'success',
                           'Demo backup', 'seed_demo_clinical')""",
                 [])
            return True
        _try(_ensure_backup_log, "core.backup_log")

        self.stdout.write(f"specialty coverage: +{spec_created}")

        # --- Generic coverage for the remaining specialty tables ---
        # Every clinical model gets at least one demo row so its page shows
        # data. Tables already seeded above (core clinical loop) are skipped.
        # Read-only / bridge / log tables are excluded.
        from django.apps import apps as django_apps

        SKIP_MODELS = {
            # already seeded or non-table
            "core.party", "core.appuser", "core.authuser",
            "emr.patient", "emr.encounter", "emr.clinicalnote", "emr.vitals",
            "emr.medicationorder",
            "clinic.appointment",
            "lab.laborder", "lab.sample", "lab.result",
            "billing.invoice", "billing.invoiceline",
            "waste.wastecollection", "waste.wastecontainer",
            # read-only / bridge / log / pivot tables (no direct demo row)
            "core.auditlog", "core.eventlog", "core.audit", "core.notification",
            "core.lookup", "core.permission", "core.role", "core.userrolemap",
            "hr.employee", "hr.department",
            "lab.testpanel", "lab.testcatalog",
            "billing.serviceprice",
            # targeted (specialty) handlers above create these explicitly
            "emr.allergy", "emr.familyhistory", "emr.immunization", "emr.socialhistory",
            "clinic.room", "clinic.patientqueue", "clinic.consultation",
            "surgical.surgery", "surgical.intraopvitals",
            "emergency.triage",
            "emergency.resuscitation",
            "rx.drugalternative", "rx.stockmovement",
            "rx.druglot", "rx.prescription", "rx.dispensation",
            "icu.vitalsstream",
            "hr.payrollperiod", "hr.payrollitem",
            "vital_records.birthcertificate", "vital_records.deathcertificate",
            "erp.purchaseorder", "erp.goodsreceipt",
            "erp.purchaseorderline", "erp.goodsreceiptline",
            "core.audittrail",
            "auth.user", "auth.group", "auth.permission",
            "sessions.session", "contenttypes.contenttype",
            "admin.logentry",
        }
        EXCLUDE_APPS = {"auth", "contenttypes", "sessions", "admin", "guardian"}

        generic_created = 0
        generic_skipped = 0
        generic_failed = []
        for model in django_apps.get_models():
            label = f"{model._meta.app_label}.{model.__name__}".lower()
            if model._meta.app_label in EXCLUDE_APPS:
                continue
            if label in SKIP_MODELS:
                continue
            # only seed tables under clinical schemas (mcms_* apps)
            if not model._meta.db_table.startswith("mcms_"):
                continue
            # idempotent: only seed if the table is currently empty
            try:
                if model.objects.exists():
                    continue
            except Exception:
                continue
            ok, note = self._seed_generic(model)
            if ok:
                generic_created += 1
            elif note == "exists":
                pass
            elif note.startswith("no-ref:") or note.startswith("err:"):
                generic_failed.append(f"{label}:{note}")
                generic_skipped += 1
            else:
                generic_skipped += 1
        self.stdout.write(
            f"generic coverage: +{generic_created} rows, {generic_skipped} skipped"
        )
        if generic_failed:
            self.stdout.write(
                self.style.WARNING("generic skipped: " + "; ".join(generic_failed))
            )

        self.stdout.write(self.style.SUCCESS("seed_demo_clinical complete."))
