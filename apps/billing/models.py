"""
billing domain models — reflected from PostgreSQL schema mcms_billing.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_billing"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models

class InsuranceClaim(models.Model):
    claim_id = models.BigAutoField(primary_key=True)
    invoice = models.ForeignKey('Invoice', models.DO_NOTHING)
    policy_no = models.TextField()
    insurance_provider = models.TextField()
    patient_id = models.BigIntegerField()
    billed_amount = models.DecimalField(max_digits=14, decimal_places=2)
    approved_amount = models.DecimalField(max_digits=14, decimal_places=2, blank=True, null=True)
    rejected_amount = models.DecimalField(max_digits=14, decimal_places=2)
    status = models.TextField()  # This field type is a guess.
    submitted_at = models.DateTimeField(blank=True, null=True)
    adjudicated_at = models.DateTimeField(blank=True, null=True)
    paid_at = models.DateTimeField(blank=True, null=True)
    claim_no_external = models.TextField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    class Meta:
        managed = False
        db_table = 'mcms_billing"."insurance_claim'

class Invoice(models.Model):
    invoice_id = models.BigAutoField(primary_key=True)
    invoice_no = models.TextField(unique=True)
    patient_id = models.BigIntegerField()
    mrn = models.TextField()
    encounter_id = models.BigIntegerField(blank=True, null=True)
    issued_by = models.BigIntegerField()
    status = models.TextField()  # This field type is a guess.
    subtotal = models.DecimalField(max_digits=14, decimal_places=2)
    tax_amount = models.DecimalField(max_digits=14, decimal_places=2)
    discount_amount = models.DecimalField(max_digits=14, decimal_places=2)
    insurance_covers = models.DecimalField(max_digits=14, decimal_places=2)
    patient_pays = models.DecimalField(max_digits=14, decimal_places=2)
    total = models.GeneratedField(
        expression="subtotal + tax_amount - discount_amount",
        output_field=models.DecimalField(max_digits=14, decimal_places=2),
        db_persist=True,
    )  # DB-generated column (GENERATED ALWAYS AS ...)
    currency = models.TextField()
    issued_at = models.DateTimeField()
    due_date = models.DateField(blank=True, null=True)
    paid_at = models.DateTimeField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    def __str__(self):
        return str(self.mrn)

    class Meta:
        managed = False
        db_table = 'mcms_billing"."invoice'

class InvoiceLine(models.Model):
    line_id = models.BigAutoField(primary_key=True)
    invoice = models.ForeignKey(Invoice, models.DO_NOTHING)
    service = models.ForeignKey('ServicePrice', models.DO_NOTHING, blank=True, null=True)
    source_schema = models.TextField(blank=True, null=True)
    source_table = models.TextField(blank=True, null=True)
    source_id = models.BigIntegerField(blank=True, null=True)
    description = models.TextField()
    qty = models.DecimalField(max_digits=8, decimal_places=2)
    unit_price = models.DecimalField(max_digits=12, decimal_places=2)
    line_total = models.DecimalField(max_digits=14, decimal_places=2, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )

    class Meta:
        managed = False
        db_table = 'mcms_billing"."invoice_line'

class Payment(models.Model):
    payment_id = models.BigAutoField(primary_key=True)
    invoice = models.ForeignKey(Invoice, models.DO_NOTHING)
    method = models.TextField()  # This field type is a guess.
    amount = models.DecimalField(max_digits=14, decimal_places=2)
    currency = models.TextField()
    paid_at = models.DateTimeField()
    received_by = models.BigIntegerField(blank=True, null=True)
    txn_ref = models.TextField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_billing"."payment'

class ServicePrice(models.Model):
    service_id = models.BigAutoField(primary_key=True)
    code = models.TextField(unique=True)
    name = models.TextField()
    service_type = models.TextField()  # This field type is a guess.
    department_id = models.BigIntegerField(blank=True, null=True)
    unit_price = models.DecimalField(max_digits=12, decimal_places=2)
    currency = models.TextField()
    is_taxable = models.BooleanField()
    is_active = models.BooleanField()
    effective_from = models.DateField()
    effective_to = models.DateField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_billing"."service_price'
