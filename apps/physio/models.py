"""
physio domain models — reflected from PostgreSQL schema mcms_physio.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_physio"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models

class Session(models.Model):
    session_id = models.BigAutoField(primary_key=True)
    plan = models.ForeignKey('TreatmentPlan', models.DO_NOTHING)
    patient_id = models.BigIntegerField()
    therapist_user_id = models.BigIntegerField()
    therapy = models.ForeignKey('TherapyCatalog', models.DO_NOTHING, blank=True, null=True)
    room_id = models.BigIntegerField(blank=True, null=True)
    sessions_in_seq = models.IntegerField(blank=True, null=True)
    scheduled_at = models.DateTimeField()
    duration_minutes = models.IntegerField()
    pain_before_score = models.IntegerField(blank=True, null=True)
    pain_after_score = models.IntegerField(blank=True, null=True)
    rom_before = models.TextField(blank=True, null=True)
    rom_after = models.TextField(blank=True, null=True)
    subjective = models.TextField(blank=True, null=True)
    interventions = models.TextField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    started_at = models.DateTimeField(blank=True, null=True)
    completed_at = models.DateTimeField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    class Meta:
        managed = False
        db_table = 'mcms_physio"."session'

class TherapyCatalog(models.Model):
    therapy_id = models.BigAutoField(primary_key=True)
    code = models.TextField(unique=True)
    name = models.TextField()
    type = models.TextField()  # This field type is a guess.
    body_region = models.TextField(blank=True, null=True)
    duration_minutes = models.IntegerField()
    equipment = models.TextField(blank=True, null=True)  # This field type is a guess.
    is_active = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True, )

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_physio"."therapy_catalog'

class TreatmentPlan(models.Model):
    plan_id = models.BigAutoField(primary_key=True)
    patient_id = models.BigIntegerField()
    encounter_id = models.BigIntegerField(blank=True, null=True)
    therapist_user_id = models.BigIntegerField()
    diagnosis = models.TextField(blank=True, null=True)
    treatment_goals = models.TextField(blank=True, null=True)
    sessions_planned = models.IntegerField()
    sessions_completed = models.IntegerField()
    frequency = models.TextField(blank=True, null=True)
    starts_on = models.DateField(blank=True, null=True)
    ends_on = models.DateField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    class Meta:
        managed = False
        db_table = 'mcms_physio"."treatment_plan'
