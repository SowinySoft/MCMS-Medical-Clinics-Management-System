"""
rx domain models — reflected from PostgreSQL schema mcms_rx.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_rx"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models

class Administration(models.Model):
    administer_id = models.BigAutoField(primary_key=True)
    patient_id = models.BigIntegerField()
    med_order_id = models.BigIntegerField(blank=True, null=True)
    drug_item = models.ForeignKey('DrugItem', models.DO_NOTHING)
    dose_given = models.TextField()
    dose_at = models.DateTimeField()
    administered_by = models.BigIntegerField()
    witnessed_by = models.BigIntegerField(blank=True, null=True)
    site = models.TextField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_rx"."administration'

class Dispensation(models.Model):
    dispensation_id = models.BigAutoField(primary_key=True)
    patient_id = models.BigIntegerField()
    mrn = models.TextField()
    encounter_id = models.BigIntegerField(blank=True, null=True)
    med_order_id = models.BigIntegerField(blank=True, null=True)
    drug_item = models.ForeignKey('DrugItem', models.DO_NOTHING)
    lot = models.ForeignKey('DrugLot', models.DO_NOTHING, blank=True, null=True)
    quantity = models.IntegerField()
    dispensed_at = models.DateTimeField()
    dispensed_by = models.BigIntegerField()
    instructions = models.TextField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    def __str__(self):
        return str(self.mrn)

    class Meta:
        managed = False
        db_table = 'mcms_rx"."dispensation'

class DrugAlternative(models.Model):
    alternative_id = models.BigAutoField(primary_key=True)
    drug_item = models.ForeignKey('DrugItem', models.DO_NOTHING)
    alt_drug_item = models.ForeignKey('DrugItem', models.DO_NOTHING, related_name='drugalternative_alt_drug_item_set')
    reason = models.TextField(blank=True, null=True)
    is_generic_equiv = models.BooleanField()
    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'mcms_rx"."drug_alternative'
        unique_together = (('drug_item', 'alt_drug_item'),)

class DrugInteraction(models.Model):
    interaction_id = models.BigAutoField(primary_key=True)
    drug_item_id_a = models.ForeignKey('DrugItem', models.DO_NOTHING, db_column='drug_item_id_a')
    drug_item_id_b = models.ForeignKey('DrugItem', models.DO_NOTHING, db_column='drug_item_id_b', related_name='druginteraction_drug_item_id_b_set')
    severity = models.TextField()  # This field type is a guess.
    mechanism = models.TextField(blank=True, null=True)
    clinical_effect = models.TextField(blank=True, null=True)
    management = models.TextField(blank=True, null=True)
    source_ref = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'mcms_rx"."drug_interaction'
        unique_together = (('drug_item_id_a', 'drug_item_id_b'),)

class DrugItem(models.Model):
    drug_item_id = models.BigAutoField(primary_key=True)
    generic_name = models.TextField()
    brand_name = models.TextField(blank=True, null=True)
    drug_class = models.TextField()  # This field type is a guess.
    form = models.TextField(blank=True, null=True)
    strength = models.TextField(blank=True, null=True)
    unit = models.TextField(blank=True, null=True)
    atc_code = models.TextField(blank=True, null=True)
    controlled_substance = models.BooleanField()
    requires_cold_chain = models.BooleanField()
    manufacturer = models.TextField(blank=True, null=True)
    reorder_level = models.IntegerField()
    reorder_qty = models.IntegerField()
    is_active = models.BooleanField()
    cost_per_unit = models.DecimalField(max_digits=10, decimal_places=2)
    sale_price_per_unit = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()
    rxnorm_code = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_rx"."drug_item'

class DrugLot(models.Model):
    lot_id = models.BigAutoField(primary_key=True)
    drug_item = models.ForeignKey(DrugItem, models.DO_NOTHING)
    lot_number = models.TextField()
    received_qty = models.IntegerField()
    on_hand_qty = models.IntegerField()
    manufactured_on = models.DateField(blank=True, null=True)
    expires_on = models.DateField()
    received_at = models.DateTimeField()
    supplier_party_id = models.BigIntegerField(blank=True, null=True)
    purchase_order_id = models.BigIntegerField(blank=True, null=True)
    unit_cost = models.DecimalField(max_digits=10, decimal_places=2)
    status = models.TextField()  # This field type is a guess.

    class Meta:
        managed = False
        db_table = 'mcms_rx"."drug_lot'
        unique_together = (('drug_item', 'lot_number'),)

class StockMovement(models.Model):
    movement_id = models.BigAutoField(primary_key=True)
    drug_item = models.ForeignKey(DrugItem, models.DO_NOTHING)
    lot = models.ForeignKey(DrugLot, models.DO_NOTHING, blank=True, null=True)
    movement_type = models.TextField()  # This field type is a guess.
    qty_delta = models.IntegerField()
    balance_after = models.IntegerField()
    related_movement = models.ForeignKey('self', models.DO_NOTHING, blank=True, null=True)
    reason = models.TextField(blank=True, null=True)
    performed_by = models.BigIntegerField(blank=True, null=True)
    performed_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'mcms_rx"."stock_movement'
