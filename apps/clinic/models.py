"""
clinic domain models — reflected from PostgreSQL schema mcms_clinic.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_clinic"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models

class Appointment(models.Model):
    appointment_id = models.BigAutoField(primary_key=True)
    mrn = models.TextField()
    patient_id = models.BigIntegerField()
    clinician_user_id = models.BigIntegerField()
    room = models.ForeignKey('Room', models.DO_NOTHING, blank=True, null=True)
    department_id = models.BigIntegerField()
    starts_at = models.DateTimeField()
    ends_at = models.DateTimeField()
    status = models.TextField()  # This field type is a guess.
    reason = models.TextField(blank=True, null=True)
    booked_by = models.BigIntegerField(blank=True, null=True)
    encounter_id = models.BigIntegerField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )
    confirmation_token = models.UUIDField(blank=True, null=True)
    confirmation_deadline = models.DateTimeField(blank=True, null=True)
    confirmed_at = models.DateTimeField(blank=True, null=True)
    patient_confirmed = models.BooleanField()

    def __str__(self):
        return str(self.mrn)

    class Meta:
        managed = False
        db_table = 'mcms_clinic"."appointment'

class Consultation(models.Model):
    consultation_id = models.BigAutoField(primary_key=True)
    appointment = models.ForeignKey(Appointment, models.DO_NOTHING, blank=True, null=True)
    queue = models.ForeignKey('PatientQueue', models.DO_NOTHING, blank=True, null=True)
    encounter_id = models.BigIntegerField()
    room = models.ForeignKey('Room', models.DO_NOTHING, blank=True, null=True)
    clinician_user_id = models.BigIntegerField()
    duration_minutes = models.IntegerField(blank=True, null=True)
    subjective = models.TextField(blank=True, null=True)
    objective = models.TextField(blank=True, null=True)
    assessment = models.TextField(blank=True, null=True)
    plan = models.TextField(blank=True, null=True)
    follow_up_days = models.IntegerField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    started_at = models.DateTimeField()
    completed_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    class Meta:
        managed = False
        db_table = 'mcms_clinic"."consultation'

class PatientQueue(models.Model):
    queue_id = models.BigAutoField(primary_key=True)
    patient_id = models.BigIntegerField()
    mrn = models.TextField()
    department_id = models.BigIntegerField()
    assigned_clinician = models.BigIntegerField(blank=True, null=True)
    room = models.ForeignKey('Room', models.DO_NOTHING, blank=True, null=True)
    priority = models.IntegerField()
    status = models.TextField()  # This field type is a guess.
    checked_in_at = models.DateTimeField()
    called_at = models.DateTimeField(blank=True, null=True)
    started_at = models.DateTimeField(blank=True, null=True)
    finished_at = models.DateTimeField(blank=True, null=True)
    encounter_id = models.BigIntegerField(blank=True, null=True)

    def __str__(self):
        return str(self.mrn)

    class Meta:
        managed = False
        db_table = 'mcms_clinic"."patient_queue'

class Room(models.Model):
    room_id = models.BigAutoField(primary_key=True)
    department_id = models.BigIntegerField()
    code = models.TextField(unique=True)
    name = models.TextField()
    capacity = models.IntegerField(blank=True, null=True)
    equipment = models.TextField(blank=True, null=True)  # This field type is a guess.
    is_active = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_clinic"."room'
