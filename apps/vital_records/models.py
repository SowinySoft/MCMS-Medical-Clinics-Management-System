"""Vital Records domain models — reflected from PostgreSQL schema
mcms_vital_records. managed=False (schema owned by SQL in /sql)."""
from django.db import models


class BirthCertificate(models.Model):
    birth_cert_id = models.BigAutoField(primary_key=True)
    registration_no = models.TextField()
    newborn_patient = models.ForeignKey(
        'emr.Patient', models.DO_NOTHING, db_column='newborn_patient_id',
        related_name='birth_cert_as_newborn')
    mother_patient = models.ForeignKey(
        'emr.Patient', models.DO_NOTHING, db_column='mother_patient_id',
        blank=True, null=True, related_name='birth_cert_as_mother')
    father_party = models.ForeignKey(
        'core.Party', models.DO_NOTHING, db_column='father_party_id',
        blank=True, null=True)
    delivery_encounter = models.ForeignKey(
        'emr.Encounter', models.DO_NOTHING, db_column='delivery_encounter_id',
        blank=True, null=True)
    facility = models.ForeignKey(
        'core.Facility', models.DO_NOTHING, db_column='facility_id')
    birth_datetime = models.DateTimeField()
    birth_weight_g = models.DecimalField(
        max_digits=7, decimal_places=1, blank=True, null=True)
    gestation_weeks = models.DecimalField(
        max_digits=4, decimal_places=1, blank=True, null=True)
    place_of_birth = models.TextField(blank=True, null=True)
    attendant_user_id = models.BigIntegerField(blank=True, null=True)
    registrar_user_id = models.BigIntegerField(blank=True, null=True)
    certifier_user_id = models.BigIntegerField(blank=True, null=True)
    status = models.TextField()
    signed_at = models.DateTimeField(blank=True, null=True)
    amended_from = models.ForeignKey(
        'self', models.DO_NOTHING, db_column='amended_from',
        blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_vital_records"."birth_certificate'
        unique_together = (('registration_no', 'facility'),)


class DeathCertificate(models.Model):
    death_cert_id = models.BigAutoField(primary_key=True)
    registration_no = models.TextField()
    patient = models.ForeignKey(
        'emr.Patient', models.DO_NOTHING, db_column='patient_id')
    facility = models.ForeignKey(
        'core.Facility', models.DO_NOTHING, db_column='facility_id')
    death_datetime = models.DateTimeField()
    cause_icd10 = models.TextField(blank=True, null=True)
    cause_text = models.TextField(blank=True, null=True)
    certifying_clinician_user_id = models.BigIntegerField(blank=True, null=True)
    coroner_case = models.BooleanField()
    registrar_user_id = models.BigIntegerField(blank=True, null=True)
    status = models.TextField()
    signed_at = models.DateTimeField(blank=True, null=True)
    amended_from = models.ForeignKey(
        'self', models.DO_NOTHING, db_column='amended_from',
        blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_vital_records"."death_certificate'
        unique_together = (('registration_no', 'facility'),)
