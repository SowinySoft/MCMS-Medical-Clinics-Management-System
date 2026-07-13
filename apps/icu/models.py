"""
icu domain models — reflected from PostgreSQL schema mcms_icu.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_icu"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models

class Admission(models.Model):
    admission_id = models.BigAutoField(primary_key=True)
    encounter_id = models.BigIntegerField()
    patient_id = models.BigIntegerField()
    mrn = models.TextField()
    bed = models.ForeignKey('Bed', models.DO_NOTHING, blank=True, null=True)
    primary_physician_id = models.BigIntegerField(blank=True, null=True)
    attending_nurse_id = models.BigIntegerField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    admit_diagnosis = models.TextField(blank=True, null=True)
    admit_reason = models.TextField(blank=True, null=True)
    admitted_at = models.DateTimeField()
    discharged_at = models.DateTimeField(blank=True, null=True)
    discharge_destination = models.TextField(blank=True, null=True)
    expired_at = models.DateTimeField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    def __str__(self):
        return str(self.mrn)

    class Meta:
        managed = False
        db_table = 'mcms_icu"."admission'

class Bed(models.Model):
    bed_id = models.BigAutoField(primary_key=True)
    room_code = models.TextField()
    bed_label = models.TextField()
    department_id = models.BigIntegerField()
    level = models.IntegerField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    has_ventilator = models.BooleanField()
    has_dialysis = models.BooleanField()
    is_isolation = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    class Meta:
        managed = False
        db_table = 'mcms_icu"."bed'
        unique_together = (('room_code', 'bed_label'),)

class BedStay(models.Model):
    stay_id = models.BigAutoField(primary_key=True)
    admission = models.ForeignKey(Admission, models.DO_NOTHING)
    bed = models.ForeignKey(Bed, models.DO_NOTHING)
    assigned_at = models.DateTimeField()
    released_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_icu"."bed_stay'

class Score(models.Model):
    score_id = models.BigAutoField(primary_key=True)
    admission = models.ForeignKey(Admission, models.DO_NOTHING)
    type = models.TextField()
    raw = models.IntegerField(blank=True, null=True)
    computed_value = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    interpretation = models.TextField(blank=True, null=True)
    assessed_at = models.DateTimeField()
    assessed_by = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_icu"."score'

class SupportSession(models.Model):
    session_id = models.BigAutoField(primary_key=True)
    admission = models.ForeignKey(Admission, models.DO_NOTHING)
    support_kind = models.TextField()  # This field type is a guess.
    started_at = models.DateTimeField()
    stopped_at = models.DateTimeField(blank=True, null=True)
    parameters = models.JSONField(blank=True, null=True)
    stopped_reason = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_icu"."support_session'

class VitalsStream(models.Model):
    stream_id = models.BigAutoField(primary_key=True)
    admission = models.ForeignKey(Admission, models.DO_NOTHING)
    patient_id = models.BigIntegerField()
    recorded_at = models.DateTimeField()
    charted_by = models.BigIntegerField(blank=True, null=True)
    temp_c = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    hr_bpm = models.IntegerField(blank=True, null=True)
    rr_pm = models.IntegerField(blank=True, null=True)
    sbp_mmhg = models.IntegerField(blank=True, null=True)
    dbp_mmhg = models.IntegerField(blank=True, null=True)
    mbp_mmhg = models.IntegerField(blank=True, null=True)
    spo2_pct = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    etco2_mmhg = models.IntegerField(blank=True, null=True)
    cvp_cmh2o = models.IntegerField(blank=True, null=True)
    urine_ml_hour = models.IntegerField(blank=True, null=True)
    gcs = models.IntegerField(blank=True, null=True)
    pupils = models.TextField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_icu"."vitals_stream'
