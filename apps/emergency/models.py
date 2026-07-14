"""
emergency domain models — reflected from PostgreSQL schema mcms_emergency.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_emergency"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models


class EdBed(models.Model):
    ed_bed_id = models.BigAutoField(primary_key=True)
    triage = models.ForeignKey('Triage', models.DO_NOTHING)
    bed_label = models.TextField()
    assigned_at = models.DateTimeField()
    released_at = models.DateTimeField(blank=True, null=True)
    observation_minutes = models.IntegerField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_emergency"."ed_bed'

class Resuscitation(models.Model):
    resus_id = models.BigAutoField(primary_key=True)
    triage = models.ForeignKey('Triage', models.DO_NOTHING, blank=True, null=True)
    encounter_id = models.BigIntegerField()
    patient_id = models.BigIntegerField()
    code_initiated_at = models.DateTimeField()
    code_type = models.TextField(blank=True, null=True, choices=[('medical','medical'),('trauma','trauma'),('cardiac','cardiac'),('respiratory','respiratory'),('paediatric','paediatric'),('obstetric','obstetric')])
    team_leader_id = models.BigIntegerField(blank=True, null=True)
    airway = models.TextField(blank=True, null=True)
    interventions = models.TextField(blank=True, null=True)  # This field type is a guess.
    iv_access = models.TextField(blank=True, null=True)
    meds_administered = models.TextField(blank=True, null=True)  # This field type is a guess.
    rosc = models.BooleanField(blank=True, null=True)
    rosc_at = models.DateTimeField(blank=True, null=True)
    duration_minutes = models.IntegerField(blank=True, null=True)
    outcome = models.TextField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )

    class Meta:
        managed = False
        db_table = 'mcms_emergency"."resuscitation'

class Triage(models.Model):
    triage_id = models.BigAutoField(primary_key=True)
    ed_visit_no = models.TextField(unique=True)
    patient_id = models.BigIntegerField()
    mrn = models.TextField()
    encounter_id = models.BigIntegerField()
    presentation_time = models.DateTimeField()
    chief_complaint = models.TextField()
    esi_level = models.IntegerField()
    arrival_mode = models.TextField(blank=True, null=True, choices=[('walk_in','walk_in'),('ambulance','ambulance'),('helicopter','helicopter'),('transfer','transfer'),('police','police')])
    trauma_alert = models.BooleanField()
    vital_temp_c = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    vital_hr_bpm = models.IntegerField(blank=True, null=True)
    vital_sbp_mmhg = models.IntegerField(blank=True, null=True)
    vital_dbp_mmhg = models.IntegerField(blank=True, null=True)
    vital_rr_pm = models.IntegerField(blank=True, null=True)
    vital_spo2_pct = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    vital_pain_score = models.IntegerField(blank=True, null=True)
    vital_gcs = models.IntegerField(blank=True, null=True)
    allergies_known = models.TextField(blank=True, null=True)
    meds_on_arrival = models.TextField(blank=True, null=True)  # This field type is a guess.
    triage_nurse_user_id = models.BigIntegerField(blank=True, null=True)
    triaged_at = models.DateTimeField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    disposition = models.TextField(blank=True, null=True)
    disposition_destination = models.TextField(blank=True, null=True)
    disposition_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    def __str__(self):
        return str(self.mrn)

    class Meta:
        managed = False
        db_table = 'mcms_emergency"."triage'
