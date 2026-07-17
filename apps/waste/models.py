"""Medical Waste domain models — reflected from PostgreSQL schema mcms_waste.

managed=False (schema owned by SQL in /sql/43_medical_waste.sql). Django never
DDLs these tables. The auto-router (apps/core/routers.py) turns each model into
a secured CRUD endpoint at /api/waste/<model-slug>/.

Note: waste_disposal_manifest.total_cost is a GENERATED ALWAYS column
(total_weight_kg * unit_cost_per_kg) — the serializer must treat it read-only
and never insert/update it (see WASTE_GENERATED_FIELDS in apps/core/base.py).
"""
from django.db import models


class WasteStream(models.Model):
    stream_id = models.BigAutoField(primary_key=True)
    code = models.TextField(unique=True)
    name = models.TextField()
    kind = models.TextField(choices=[
        ('sharps', 'sharps'), ('infectious', 'infectious'),
        ('pathological', 'pathological'), ('pharmaceutical', 'pharmaceutical'),
        ('chemical', 'chemical'), ('cytotoxic', 'cytotoxic'),
        ('radioactive', 'radioactive'), ('general', 'general')])
    color_code = models.TextField(blank=True, null=True)
    hazard_class = models.TextField(blank=True, null=True)
    default_disposal_method = models.TextField(blank=True, null=True)
    unit_cost_per_kg = models.DecimalField(max_digits=12, decimal_places=4, default=0)
    currency = models.TextField(default='SAR')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_waste"."waste_stream'


class WasteContainer(models.Model):
    container_id = models.BigAutoField(primary_key=True)
    barcode = models.TextField(unique=True)
    stream = models.ForeignKey(WasteStream, models.DO_NOTHING, db_column='stream_id')
    department = models.ForeignKey('hr.Department', models.DO_NOTHING, db_column='department_id')
    capacity_kg = models.DecimalField(max_digits=10, decimal_places=3, blank=True, null=True)
    status = models.TextField(choices=[
        ('open', 'open'), ('sealed', 'sealed'),
        ('collected', 'collected'), ('disposed', 'disposed')], default='open')
    opened_at = models.DateTimeField(auto_now_add=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return str(self.barcode)

    class Meta:
        managed = False
        db_table = 'mcms_waste"."waste_container'


class WasteCollection(models.Model):
    collection_id = models.BigAutoField(primary_key=True)
    container = models.ForeignKey(WasteContainer, models.DO_NOTHING, db_column='container_id')
    weight_kg = models.DecimalField(max_digits=10, decimal_places=3)
    collected_by_user_id = models.BigIntegerField(blank=True, null=True)
    collection_datetime = models.DateTimeField()
    storage_location = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"collection {self.collection_id}"

    class Meta:
        managed = False
        db_table = 'mcms_waste"."waste_collection'


class WasteDisposalManifest(models.Model):
    manifest_id = models.BigAutoField(primary_key=True)
    manifest_no = models.TextField(unique=True)
    carrier_vendor = models.TextField(blank=True, null=True)
    treatment_method = models.TextField(blank=True, null=True, choices=[
        ('autoclave', 'autoclave'), ('incineration', 'incineration'),
        ('chemical', 'chemical'), ('microwave', 'microwave'),
        ('landfill', 'landfill'), ('encapsulation', 'encapsulation'),
        ('other', 'other')])
    disposal_datetime = models.DateTimeField()
    total_weight_kg = models.DecimalField(max_digits=12, decimal_places=3, default=0)
    unit_cost_per_kg = models.DecimalField(max_digits=12, decimal_places=4, default=0)
    # GENERATED ALWAYS in the DB (total_weight_kg * unit_cost_per_kg) — read-only,
    # never written by the app (same pattern as billing.invoice.total).
    total_cost = models.GeneratedField(
        expression="total_weight_kg * unit_cost_per_kg",
        output_field=models.DecimalField(max_digits=16, decimal_places=4),
        db_persist=True,
    )
    currency = models.TextField(default='SAR')
    certificate_ref = models.TextField(blank=True, null=True)
    certified_by_user_id = models.BigIntegerField(blank=True, null=True)
    status = models.TextField(choices=[
        ('open', 'open'), ('certified', 'certified'),
        ('cancelled', 'cancelled')], default='open')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return str(self.manifest_no)

    class Meta:
        managed = False
        db_table = 'mcms_waste"."waste_disposal_manifest'


class WasteCostAllocation(models.Model):
    allocation_id = models.BigAutoField(primary_key=True)
    manifest = models.ForeignKey(WasteDisposalManifest, models.DO_NOTHING, db_column='manifest_id')
    department = models.ForeignKey('hr.Department', models.DO_NOTHING, db_column='department_id')
    period_month = models.DateField()
    allocated_weight_kg = models.DecimalField(max_digits=12, decimal_places=3, default=0)
    allocated_cost = models.DecimalField(max_digits=16, decimal_places=4, default=0)
    cost_center_code = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"alloc {self.allocation_id}"

    class Meta:
        managed = False
        db_table = 'mcms_waste"."waste_cost_allocation'
        unique_together = (('manifest', 'department', 'period_month'),)
