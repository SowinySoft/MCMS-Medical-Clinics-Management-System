"""
nursery domain models — reflected from PostgreSQL schema mcms_nursery.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_nursery"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models


class Cot(models.Model):
    cot_id = models.BigAutoField(primary_key=True)
    code = models.TextField(unique=True)
    name = models.TextField()
    department_id = models.BigIntegerField(blank=True, null=True)
    is_incubator = models.BooleanField()
    has_phototherapy = models.BooleanField()
    status = models.TextField()  # This field type is a guess.
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_nursery"."cot'

class GrowthEntry(models.Model):
    entry_id = models.BigAutoField(primary_key=True)
    neonate = models.ForeignKey('NeonateRecord', models.DO_NOTHING)
    recorded_at = models.DateTimeField()
    weight_g = models.IntegerField(blank=True, null=True)
    length_cm = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    head_circ_cm = models.DecimalField(max_digits=5, decimal_places=2, blank=True, null=True)
    temperature_c = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    feeding_type = models.TextField(blank=True, null=True)
    feed_volume_ml = models.IntegerField(blank=True, null=True)
    nurse_user_id = models.BigIntegerField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_nursery"."growth_entry'

class NeonateRecord(models.Model):
    neonate_id = models.BigAutoField(primary_key=True)
    patient_id = models.BigIntegerField()
    mother_party_id = models.BigIntegerField(blank=True, null=True)
    cot = models.ForeignKey(Cot, models.DO_NOTHING, blank=True, null=True)
    gestational_age_weeks = models.DecimalField(max_digits=4, decimal_places=1, blank=True, null=True)
    birth_weight_g = models.IntegerField(blank=True, null=True)
    apgar_1min = models.IntegerField(blank=True, null=True)
    apgar_5min = models.IntegerField(blank=True, null=True)
    admitted_at = models.DateTimeField()
    discharged_at = models.DateTimeField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    class Meta:
        managed = False
        db_table = 'mcms_nursery"."neonate_record'
