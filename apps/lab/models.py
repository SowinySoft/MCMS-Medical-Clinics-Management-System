"""
lab domain models — reflected from PostgreSQL schema mcms_lab.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_lab"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models


class LabOrder(models.Model):
    order_id = models.BigAutoField(primary_key=True)
    order_no = models.TextField(unique=True)
    encounter_id = models.BigIntegerField()
    patient_id = models.BigIntegerField()
    mrn = models.TextField()
    requested_by = models.BigIntegerField()
    order_priority = models.TextField()  # This field type is a guess.
    panel = models.ForeignKey('TestPanel', models.DO_NOTHING, blank=True, null=True)
    clinical_indication = models.TextField(blank=True, null=True)
    requested_at = models.DateTimeField()

    def __str__(self):
        return str(self.mrn)

    class Meta:
        managed = False
        db_table = 'mcms_lab"."lab_order'

class Result(models.Model):
    result_id = models.BigAutoField(primary_key=True)
    sample = models.ForeignKey('Sample', models.DO_NOTHING)
    test = models.ForeignKey('TestCatalog', models.DO_NOTHING)
    value_text = models.TextField(blank=True, null=True)
    value_numeric = models.DecimalField(max_digits=14, decimal_places=4, blank=True, null=True)
    unit = models.TextField(blank=True, null=True)
    ref_range = models.TextField(blank=True, null=True)
    flag = models.TextField()  # This field type is a guess.
    analysed_by = models.BigIntegerField(blank=True, null=True)
    analysed_at = models.DateTimeField(blank=True, null=True)
    verified_by = models.BigIntegerField(blank=True, null=True)
    verified_at = models.DateTimeField(blank=True, null=True)
    rejected_at = models.DateTimeField(blank=True, null=True)
    rejected_reason = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )

    class Meta:
        managed = False
        db_table = 'mcms_lab"."result'
        unique_together = (('sample', 'test'),)

class Sample(models.Model):
    sample_id = models.BigAutoField(primary_key=True)
    sample_no = models.TextField(unique=True)
    lab_order = models.ForeignKey(LabOrder, models.DO_NOTHING)
    test_ids = models.TextField(blank=True, null=True)  # This field type is a guess.
    specimen_type = models.TextField()  # This field type is a guess.
    volume_collected = models.DecimalField(max_digits=6, decimal_places=2, blank=True, null=True)
    collected_at = models.DateTimeField()
    collected_by = models.BigIntegerField(blank=True, null=True)
    received_at = models.DateTimeField(blank=True, null=True)
    received_by = models.BigIntegerField(blank=True, null=True)
    status = models.TextField(default="collected")  # native enum sample_status (default 'collected')
    rejected_reason = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_lab"."sample'

class TestCatalog(models.Model):
    test_id = models.BigAutoField(primary_key=True)
    loinc_code = models.TextField(blank=True, null=True)
    name = models.TextField()
    category = models.TextField(blank=True, null=True)
    specimen_type = models.TextField()  # This field type is a guess.
    volume_required = models.DecimalField(max_digits=6, decimal_places=2, blank=True, null=True)
    unit = models.TextField(blank=True, null=True)
    ref_low = models.DecimalField(max_digits=10, decimal_places=5, blank=True, null=True)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    ref_high = models.DecimalField(max_digits=10, decimal_places=5, blank=True, null=True)  # max_digits and decimal_places have been guessed, as this database handles decimal fields as float
    turnaround_minutes = models.IntegerField(blank=True, null=True)
    is_active = models.BooleanField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_lab"."test_catalog'

class TestPanel(models.Model):
    panel_id = models.BigAutoField(primary_key=True)
    code = models.TextField(unique=True)
    name = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True, )

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_lab"."test_panel'

class TestPanelItem(models.Model):
    ppi_id = models.BigAutoField(primary_key=True)
    panel = models.ForeignKey(TestPanel, models.DO_NOTHING)
    test = models.ForeignKey(TestCatalog, models.DO_NOTHING)
    sort_order = models.IntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_lab"."test_panel_item'
