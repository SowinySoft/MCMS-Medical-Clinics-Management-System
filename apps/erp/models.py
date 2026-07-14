"""
erp domain models — reflected from PostgreSQL schema mcms_erp.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_erp"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models


class GlAccount(models.Model):
    account_id = models.BigAutoField(primary_key=True)
    code = models.TextField(unique=True)
    name = models.TextField()
    account_type = models.TextField()  # This field type is a guess.
    parent_account = models.ForeignKey('self', models.DO_NOTHING, blank=True, null=True)
    is_postable = models.BooleanField()
    is_active = models.BooleanField()

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_erp"."gl_account'

class GoodsReceipt(models.Model):
    grn_id = models.BigAutoField(primary_key=True)
    grn_no = models.TextField(unique=True)
    po = models.ForeignKey('PurchaseOrder', models.DO_NOTHING, blank=True, null=True)
    supplier = models.ForeignKey('Supplier', models.DO_NOTHING)
    received_by = models.BigIntegerField()
    received_at = models.DateTimeField()
    status = models.TextField()  # This field type is a guess.
    notes = models.TextField(blank=True, null=True)

    def __str__(self):
        return str(self.grn_no)

    class Meta:
        managed = False
        db_table = 'mcms_erp"."goods_receipt'

class GoodsReceiptLine(models.Model):
    line_id = models.BigAutoField(primary_key=True)
    grn = models.ForeignKey(GoodsReceipt, models.DO_NOTHING)
    po_line = models.ForeignKey('PurchaseOrderLine', models.DO_NOTHING, blank=True, null=True)
    item = models.ForeignKey('InventoryItem', models.DO_NOTHING, blank=True, null=True)
    drug_item_id = models.BigIntegerField(blank=True, null=True)
    qty_received = models.IntegerField()
    lot_number = models.TextField(blank=True, null=True)
    expiration_date = models.DateField(blank=True, null=True)
    unit_cost = models.DecimalField(max_digits=12, decimal_places=2, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_erp"."goods_receipt_line'

class InventoryItem(models.Model):
    item_id = models.BigAutoField(primary_key=True)
    code = models.TextField(unique=True)
    name = models.TextField()
    type = models.TextField()  # This field type is a guess.
    unit = models.TextField(blank=True, null=True)
    reorder_level = models.IntegerField()
    reorder_qty = models.IntegerField()
    cost_per_unit = models.DecimalField(max_digits=12, decimal_places=2)
    is_active = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_erp"."inventory_item'

class InventoryStock(models.Model):
    stock_id = models.BigAutoField(primary_key=True)
    item = models.ForeignKey(InventoryItem, models.DO_NOTHING)
    department_id = models.BigIntegerField()
    qty_on_hand = models.IntegerField()
    qty_reserved = models.IntegerField()
    last_count_at = models.DateTimeField(blank=True, null=True)
    updated_at = models.DateTimeField(auto_now=True, )

    class Meta:
        managed = False
        db_table = 'mcms_erp"."inventory_stock'
        unique_together = (('item', 'department_id'),)

class PurchaseOrder(models.Model):
    po_id = models.BigAutoField(primary_key=True)
    po_no = models.TextField(unique=True)
    supplier = models.ForeignKey('Supplier', models.DO_NOTHING)
    requested_by = models.BigIntegerField()
    approved_by = models.BigIntegerField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    expected_at = models.DateField(blank=True, null=True)
    ordered_at = models.DateTimeField()
    received_at = models.DateTimeField(blank=True, null=True)
    closed_at = models.DateTimeField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    def __str__(self):
        return str(self.po_no)

    class Meta:
        managed = False
        db_table = 'mcms_erp"."purchase_order'

class PurchaseOrderLine(models.Model):
    line_id = models.BigAutoField(primary_key=True)
    po = models.ForeignKey(PurchaseOrder, models.DO_NOTHING)
    item = models.ForeignKey(InventoryItem, models.DO_NOTHING, blank=True, null=True)
    drug_item_id = models.BigIntegerField(blank=True, null=True)
    item_description = models.TextField()
    qty = models.IntegerField()
    unit_price = models.DecimalField(max_digits=12, decimal_places=2)
    qty_received = models.IntegerField()
    line_total = models.DecimalField(max_digits=14, decimal_places=2, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_erp"."purchase_order_line'

class StockMovement(models.Model):
    movement_id = models.BigAutoField(primary_key=True)
    item = models.ForeignKey(InventoryItem, models.DO_NOTHING)
    from_department_id = models.BigIntegerField(blank=True, null=True)
    to_department_id = models.BigIntegerField(blank=True, null=True)
    qty_delta = models.IntegerField()
    movement_type = models.TextField()  # This field type is a guess.
    reference_table = models.TextField(blank=True, null=True)
    reference_id = models.BigIntegerField(blank=True, null=True)
    performed_by = models.BigIntegerField()
    performed_at = models.DateTimeField()
    reason = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_erp"."stock_movement'

class Supplier(models.Model):
    supplier_id = models.BigAutoField(primary_key=True)
    party_id = models.BigIntegerField(unique=True)
    supplier_code = models.TextField(unique=True)
    contact_user_id = models.BigIntegerField(blank=True, null=True)
    payment_terms_days = models.IntegerField()
    is_active = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True, )

    class Meta:
        managed = False
        db_table = 'mcms_erp"."supplier'
