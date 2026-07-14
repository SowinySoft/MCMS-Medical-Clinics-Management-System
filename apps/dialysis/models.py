"""
dialysis domain models — reflected from PostgreSQL schema mcms_dialysis.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_dialysis"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models


class Session(models.Model):
    session_id = models.BigAutoField(primary_key=True)
    patient_id = models.BigIntegerField()
    encounter_id = models.BigIntegerField(blank=True, null=True)
    station = models.ForeignKey('Station', models.DO_NOTHING, blank=True, null=True)
    nurse_user_id = models.BigIntegerField(blank=True, null=True)
    nephrologist_user_id = models.BigIntegerField(blank=True, null=True)
    modality = models.TextField()  # This field type is a guess.
    scheduled_at = models.DateTimeField()
    started_at = models.DateTimeField(blank=True, null=True)
    ended_at = models.DateTimeField(blank=True, null=True)
    duration_minutes = models.IntegerField(blank=True, null=True)
    pre_weight_kg = models.DecimalField(max_digits=6, decimal_places=2, blank=True, null=True)
    pre_bp = models.TextField(blank=True, null=True)
    dry_weight_kg = models.DecimalField(max_digits=6, decimal_places=2, blank=True, null=True)
    post_weight_kg = models.DecimalField(max_digits=6, decimal_places=2, blank=True, null=True)
    post_bp = models.TextField(blank=True, null=True)
    fluid_removed_ml = models.IntegerField(blank=True, null=True)
    blood_flow_rate = models.IntegerField(blank=True, null=True)
    dialysate_flow = models.IntegerField(blank=True, null=True)
    heparin_units = models.IntegerField(blank=True, null=True)
    kt_v = models.DecimalField(max_digits=4, decimal_places=2, blank=True, null=True)
    complications = models.TextField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    class Meta:
        managed = False
        db_table = 'mcms_dialysis"."session'

class Station(models.Model):
    station_id = models.BigAutoField(primary_key=True)
    code = models.TextField(unique=True)
    name = models.TextField()
    department_id = models.BigIntegerField(blank=True, null=True)
    has_ro_water = models.BooleanField()
    status = models.TextField()  # This field type is a guess.
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_dialysis"."station'
