"""
surgical domain models — reflected from PostgreSQL schema mcms_surgical.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_surgical"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models

class IntraOpVitals(models.Model):
    iov_id = models.BigAutoField(primary_key=True)
    surgery = models.ForeignKey('Surgery', models.DO_NOTHING)
    recorded_at = models.DateTimeField()
    recorded_by = models.BigIntegerField(blank=True, null=True)
    hr_bpm = models.IntegerField(blank=True, null=True)
    sbp_mmhg = models.IntegerField(blank=True, null=True)
    dbp_mmhg = models.IntegerField(blank=True, null=True)
    spo2_pct = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    etco2_mmhg = models.IntegerField(blank=True, null=True)
    anaesthesia_depth = models.IntegerField(blank=True, null=True)
    temp_c = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    urine_ml = models.IntegerField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_surgical"."intra_op_vitals'

class OperatingRoom(models.Model):
    or_id = models.BigAutoField(primary_key=True)
    department_id = models.BigIntegerField()
    code = models.TextField(unique=True)
    name = models.TextField()
    room_type = models.TextField()
    status = models.TextField()  # This field type is a guess.
    is_active = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_surgical"."operating_room'

class PostOpNote(models.Model):
    pon_id = models.BigAutoField(primary_key=True)
    surgery = models.ForeignKey('Surgery', models.DO_NOTHING)
    written_at = models.DateTimeField()
    written_by = models.BigIntegerField()
    recovery_room = models.TextField(blank=True, null=True)
    pain_score = models.IntegerField(blank=True, null=True)
    findings = models.TextField()
    instructions = models.TextField(blank=True, null=True)
    follow_up_days = models.IntegerField(blank=True, null=True)
    is_signed = models.BooleanField(blank=True, null=True)
    signed_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_surgical"."post_op_note'

class PreOpChecklist(models.Model):
    poc_id = models.BigAutoField(primary_key=True)
    surgery = models.OneToOneField('Surgery', models.DO_NOTHING)
    fasting_confirmed = models.BooleanField(blank=True, null=True)
    consent_signed = models.BooleanField(blank=True, null=True)
    site_marked = models.BooleanField(blank=True, null=True)
    antibiotics_given = models.BooleanField(blank=True, null=True)
    iv_secured = models.BooleanField(blank=True, null=True)
    labs_checked = models.BooleanField(blank=True, null=True)
    imaging_checked = models.BooleanField(blank=True, null=True)
    risk_score = models.TextField(blank=True, null=True)
    checklist_by = models.BigIntegerField(blank=True, null=True)
    completed_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )

    class Meta:
        managed = False
        db_table = 'mcms_surgical"."pre_op_checklist'

class ProcedureCatalog(models.Model):
    proc_cat_id = models.BigAutoField(primary_key=True)
    cpt_code = models.TextField(unique=True)
    name = models.TextField()
    body_site = models.TextField(blank=True, null=True)
    default_duration_min = models.IntegerField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_surgical"."procedure_catalog'

class Surgery(models.Model):
    surgery_id = models.BigAutoField(primary_key=True)
    operation_no = models.TextField(unique=True)
    encounter_id = models.BigIntegerField()
    patient_id = models.BigIntegerField()
    or_field = models.ForeignKey(OperatingRoom, models.DO_NOTHING, db_column='or_id')  # Field renamed because it was a Python reserved word.
    surgeon_user_id = models.BigIntegerField()
    anaesthetist_user_id = models.BigIntegerField(blank=True, null=True)
    primary_dept_id = models.BigIntegerField()
    procedure = models.ForeignKey(ProcedureCatalog, models.DO_NOTHING)
    laterality = models.TextField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    scheduled_at = models.DateTimeField(blank=True, null=True)
    incision_at = models.DateTimeField(blank=True, null=True)
    closure_at = models.DateTimeField(blank=True, null=True)
    patient_in_or_at = models.DateTimeField(blank=True, null=True)
    patient_out_or_at = models.DateTimeField(blank=True, null=True)
    anaesthesia_type = models.TextField(blank=True, null=True)
    blood_loss_ml = models.IntegerField(blank=True, null=True)
    tourniquet_time_minutes = models.IntegerField(blank=True, null=True)
    complications = models.TextField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    class Meta:
        managed = False
        db_table = 'mcms_surgical"."surgery'

class SurgicalTeam(models.Model):
    surg_team_id = models.BigAutoField(primary_key=True)
    surgery = models.ForeignKey(Surgery, models.DO_NOTHING)
    user_id = models.BigIntegerField()
    role = models.TextField()  # This field type is a guess.
    joined_at = models.DateTimeField(blank=True, null=True)
    left_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_surgical"."surgical_team'
        unique_together = (('surgery', 'user_id', 'role'),)
