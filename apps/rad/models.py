"""
rad domain models — reflected from PostgreSQL schema mcms_rad.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_rad"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models


class ExamCatalog(models.Model):
    exam_id = models.BigAutoField(primary_key=True)
    snomed_code = models.TextField(blank=True, null=True)
    name = models.TextField()
    body_part = models.TextField(blank=True, null=True)
    default_modality = models.TextField()  # This field type is a guess.
    contrast_used = models.BooleanField()
    duration_minutes = models.IntegerField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_rad"."exam_catalog'

class ImageInstance(models.Model):
    image_id = models.BigAutoField(primary_key=True)
    study = models.ForeignKey('StudyRequest', models.DO_NOTHING)
    series_number = models.IntegerField()
    instance_number = models.IntegerField()
    sop_instance_uid = models.TextField(blank=True, null=True)
    image_type = models.TextField()  # This field type is a guess.
    storage_uri = models.TextField()
    rows = models.IntegerField(blank=True, null=True)
    columns = models.IntegerField(blank=True, null=True)
    bits_allocated = models.IntegerField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )

    class Meta:
        managed = False
        db_table = 'mcms_rad"."image_instance'
        unique_together = (('study', 'series_number', 'instance_number'),)

class ModalitySuite(models.Model):
    suite_id = models.BigAutoField(primary_key=True)
    department_id = models.BigIntegerField()
    code = models.TextField(unique=True)
    name = models.TextField()
    modality = models.TextField()  # This field type is a guess.
    is_active = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_rad"."modality_suite'

class StudyRequest(models.Model):
    study_id = models.BigAutoField(primary_key=True)
    accession_no = models.TextField(unique=True)
    encounter_id = models.BigIntegerField()
    patient_id = models.BigIntegerField()
    mrn = models.TextField()
    exam = models.ForeignKey(ExamCatalog, models.DO_NOTHING)
    suite = models.ForeignKey(ModalitySuite, models.DO_NOTHING, blank=True, null=True)
    requested_by = models.BigIntegerField()
    priority = models.TextField()  # This field type is a guess.
    clinical_indication = models.TextField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    scheduled_at = models.DateTimeField(blank=True, null=True)
    started_at = models.DateTimeField(blank=True, null=True)
    completed_at = models.DateTimeField(blank=True, null=True)
    image_count = models.IntegerField(blank=True, null=True)
    radiation_dose_msv = models.DecimalField(max_digits=7, decimal_places=3, blank=True, null=True)
    contrast_data = models.JSONField(blank=True, null=True)
    findings = models.TextField(blank=True, null=True)
    impression = models.TextField(blank=True, null=True)
    reported_by = models.BigIntegerField(blank=True, null=True)
    reported_at = models.DateTimeField(blank=True, null=True)
    verified_by = models.BigIntegerField(blank=True, null=True)
    verified_at = models.DateTimeField(blank=True, null=True)
    cancelled_reason = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    def __str__(self):
        return str(self.mrn)

    class Meta:
        managed = False
        db_table = 'mcms_rad"."study_request'
