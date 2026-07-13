"""
emr domain models — reflected from PostgreSQL schema mcms_emr.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_emr"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models

class Allergy(models.Model):
    allergy_id = models.BigAutoField(primary_key=True)
    patient = models.ForeignKey('Patient', models.DO_NOTHING)
    substance = models.TextField()
    reaction = models.TextField(blank=True, null=True)
    severity = models.TextField()  # This field type is a guess.
    onset_age = models.TextField(blank=True, null=True)
    noted_on = models.DateTimeField()
    noted_by = models.BigIntegerField(blank=True, null=True)
    is_active = models.BooleanField()

    class Meta:
        managed = False
        db_table = 'mcms_emr"."allergy'

class ClinicalNote(models.Model):
    note_id = models.BigAutoField(primary_key=True)
    encounter = models.ForeignKey('Encounter', models.DO_NOTHING)
    patient = models.ForeignKey('Patient', models.DO_NOTHING)
    note_type = models.TextField()  # This field type is a guess.
    title = models.TextField(blank=True, null=True)
    body = models.TextField()
    author_user_id = models.BigIntegerField()
    coauthor_ids = models.TextField(blank=True, null=True)  # This field type is a guess.
    signed = models.BooleanField()
    signed_at = models.DateTimeField(blank=True, null=True)
    amended_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    def __str__(self):
        return str(self.title)

    class Meta:
        managed = False
        db_table = 'mcms_emr"."clinical_note'

class Diagnosis(models.Model):
    diagnosis_id = models.BigAutoField(primary_key=True)
    encounter = models.ForeignKey('Encounter', models.DO_NOTHING)
    patient = models.ForeignKey('Patient', models.DO_NOTHING)
    condition_code = models.TextField()
    condition_desc = models.TextField()
    role = models.TextField()  # This field type is a guess.
    status = models.TextField()  # This field type is a guess.
    onset_date = models.DateField(blank=True, null=True)
    resolved_at = models.DateTimeField(blank=True, null=True)
    recorded_by = models.BigIntegerField(blank=True, null=True)
    is_chronic = models.BooleanField(blank=True, null=True)
    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'mcms_emr"."diagnosis'

class Encounter(models.Model):
    encounter_id = models.BigAutoField(primary_key=True)
    mrn = models.ForeignKey('Patient', models.DO_NOTHING, db_column='mrn', to_field='mrn')
    patient = models.ForeignKey('Patient', models.DO_NOTHING, related_name='encounter_patient_set')
    status = models.TextField()  # This field type is a guess.
    class_field = models.TextField(db_column='class')  # Field renamed because it was a Python reserved word. This field type is a guess.
    attending_user_id = models.BigIntegerField(blank=True, null=True)
    referring_user_id = models.BigIntegerField(blank=True, null=True)
    department_id = models.BigIntegerField(blank=True, null=True)
    reason_for_visit = models.TextField(blank=True, null=True)
    chief_complaint = models.TextField(blank=True, null=True)
    started_at = models.DateTimeField(blank=True, null=True)
    ended_at = models.DateTimeField(blank=True, null=True)
    bed_assign_id = models.BigIntegerField(blank=True, null=True)
    originating_encounter = models.ForeignKey('self', models.DO_NOTHING, blank=True, null=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    fhir_id = models.TextField(unique=True, blank=True, null=True)

    def __str__(self):
        return str(self.mrn)

    class Meta:
        managed = False
        db_table = 'mcms_emr"."encounter'

class FamilyHistory(models.Model):
    fh_id = models.BigAutoField(primary_key=True)
    patient = models.ForeignKey('Patient', models.DO_NOTHING)
    relative = models.TextField()
    relationship = models.TextField(blank=True, null=True)
    condition_code = models.TextField(blank=True, null=True)
    condition_desc = models.TextField()
    age_at_onset = models.IntegerField(blank=True, null=True)
    is_deceased = models.BooleanField(blank=True, null=True)
    recorded_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'mcms_emr"."family_history'

class Immunization(models.Model):
    immunization_id = models.BigAutoField(primary_key=True)
    patient = models.ForeignKey('Patient', models.DO_NOTHING)
    vaccine_code = models.TextField()
    vaccine_name = models.TextField()
    dose_number = models.IntegerField(blank=True, null=True)
    given_at = models.DateTimeField()
    given_by = models.BigIntegerField(blank=True, null=True)
    lot_number = models.TextField(blank=True, null=True)
    site = models.TextField(blank=True, null=True)
    reaction = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_emr"."immunization'

class MedicationOrder(models.Model):
    order_id = models.BigAutoField(primary_key=True)
    encounter = models.ForeignKey(Encounter, models.DO_NOTHING, blank=True, null=True)
    patient = models.ForeignKey('Patient', models.DO_NOTHING)
    prescriber_user_id = models.BigIntegerField()
    drug_item_id = models.BigIntegerField(blank=True, null=True)
    drug_name = models.TextField()
    dose = models.TextField()
    route = models.TextField()  # This field type is a guess.
    frequency = models.TextField()
    duration_days = models.IntegerField(blank=True, null=True)
    prn = models.BooleanField(blank=True, null=True)
    refill_count = models.IntegerField()
    instructions = models.TextField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    ordered_at = models.DateTimeField()
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'mcms_emr"."medication_order'

class Patient(models.Model):
    patient_id = models.BigAutoField(primary_key=True)
    party_id = models.BigIntegerField(unique=True)
    mrn = models.TextField(unique=True)
    emergency_contact_name = models.TextField(blank=True, null=True)
    emergency_contact_phone = models.TextField(blank=True, null=True)
    next_of_kin_party_id = models.BigIntegerField(blank=True, null=True)
    insurance_provider = models.TextField(blank=True, null=True)
    insurance_policy_no = models.TextField(blank=True, null=True)
    insurance_group_no = models.TextField(blank=True, null=True)
    coverage_verified = models.BooleanField(blank=True, null=True)
    coverage_verified_at = models.DateTimeField(blank=True, null=True)
    preferred_language = models.TextField(blank=True, null=True)
    organ_donor = models.BooleanField(blank=True, null=True)
    living_will = models.BooleanField(blank=True, null=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    fhir_id = models.TextField(unique=True, blank=True, null=True)
    hl7_mpi = models.TextField(blank=True, null=True)

    def __str__(self):
        return str(self.mrn)

    class Meta:
        managed = False
        db_table = 'mcms_emr"."patient'

class SocialHistory(models.Model):
    sh_id = models.BigAutoField(primary_key=True)
    patient = models.ForeignKey(Patient, models.DO_NOTHING)
    tobacco_status = models.TextField(blank=True, null=True)
    packs_per_day = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    years_smoked = models.IntegerField(blank=True, null=True)
    alcohol_status = models.TextField(blank=True, null=True)
    drinks_per_week = models.IntegerField(blank=True, null=True)
    illicit_drugs = models.TextField(blank=True, null=True)  # This field type is a guess.
    occupation = models.TextField(blank=True, null=True)
    relationship_status = models.TextField(blank=True, null=True)
    recorded_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'mcms_emr"."social_history'

class Vitals(models.Model):
    vital_id = models.BigAutoField(primary_key=True)
    encounter = models.ForeignKey(Encounter, models.DO_NOTHING)
    patient = models.ForeignKey(Patient, models.DO_NOTHING)
    taken_at = models.DateTimeField()
    taken_by = models.BigIntegerField(blank=True, null=True)
    temp_c = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    hr_bpm = models.IntegerField(blank=True, null=True)
    rr_pm = models.IntegerField(blank=True, null=True)
    sbp_mmhg = models.IntegerField(blank=True, null=True)
    dbp_mmhg = models.IntegerField(blank=True, null=True)
    spo2_pct = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    weight_kg = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    height_cm = models.DecimalField(max_digits=5, decimal_places=1, blank=True, null=True)
    bmi = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    pain_score = models.IntegerField(blank=True, null=True)
    glucose_mgdl = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_emr"."vitals'
