"""
hr domain models — reflected from PostgreSQL schema mcms_hr.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_hr"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models

class Attendance(models.Model):
    attendance_id = models.BigAutoField(primary_key=True)
    employee = models.ForeignKey('Employee', models.DO_NOTHING)
    shift = models.ForeignKey('Shift', models.DO_NOTHING, blank=True, null=True)
    clock_in_at = models.DateTimeField(blank=True, null=True)
    clock_out_at = models.DateTimeField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    note = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'mcms_hr"."attendance'

class Department(models.Model):
    department_id = models.BigAutoField(primary_key=True)
    code = models.TextField(unique=True)
    name = models.TextField()
    parent_department = models.ForeignKey('self', models.DO_NOTHING, blank=True, null=True)
    kind = models.TextField()
    head_user_id = models.BigIntegerField(blank=True, null=True)
    location_building = models.TextField(blank=True, null=True)
    location_floor = models.IntegerField(blank=True, null=True)
    is_active = models.BooleanField()
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    def __str__(self):
        return str(self.name)

    class Meta:
        managed = False
        db_table = 'mcms_hr"."department'

class Employee(models.Model):
    employee_id = models.BigAutoField(primary_key=True)
    party_id = models.BigIntegerField(unique=True)
    user_id = models.BigIntegerField(blank=True, null=True)
    employee_no = models.TextField(unique=True)
    primary_department = models.ForeignKey(Department, models.DO_NOTHING)
    role = models.TextField()
    job_title = models.TextField(blank=True, null=True)
    specialisation = models.TextField(blank=True, null=True)
    license_number = models.TextField(blank=True, null=True)
    contract_type = models.TextField()  # This field type is a guess.
    status = models.TextField()  # This field type is a guess.
    hired_at = models.DateField()
    terminated_at = models.DateField(blank=True, null=True)
    base_salary_monthly = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    bank_account = models.TextField(blank=True, null=True)
    tax_number = models.TextField(blank=True, null=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'mcms_hr"."employee'

class EmployeeDepartment(models.Model):
    emp_dept_id = models.BigAutoField(primary_key=True)
    employee = models.ForeignKey(Employee, models.DO_NOTHING)
    department = models.ForeignKey(Department, models.DO_NOTHING)
    role = models.TextField()
    start_date = models.DateField()
    end_date = models.DateField(blank=True, null=True)
    is_primary = models.BooleanField()

    class Meta:
        managed = False
        db_table = 'mcms_hr"."employee_department'
        unique_together = (('employee', 'department', 'start_date'),)

class LeaveRequest(models.Model):
    leave_id = models.BigAutoField(primary_key=True)
    employee = models.ForeignKey(Employee, models.DO_NOTHING)
    leave_type = models.TextField()  # This field type is a guess.
    start_date = models.DateField()
    end_date = models.DateField()
    days_off = models.IntegerField()
    reason = models.TextField(blank=True, null=True)
    status = models.TextField()  # This field type is a guess.
    approved_by = models.BigIntegerField(blank=True, null=True)
    approved_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField()
    updated_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'mcms_hr"."leave_request'

class PayrollItem(models.Model):
    item_id = models.BigAutoField(primary_key=True)
    period = models.ForeignKey('PayrollPeriod', models.DO_NOTHING)
    employee = models.ForeignKey(Employee, models.DO_NOTHING)
    base_amount = models.DecimalField(max_digits=10, decimal_places=2)
    overtime_amount = models.DecimalField(max_digits=10, decimal_places=2)
    deduction_amount = models.DecimalField(max_digits=10, decimal_places=2)
    bonus_amount = models.DecimalField(max_digits=10, decimal_places=2)
    net_amount = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    is_paid = models.BooleanField()
    paid_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'mcms_hr"."payroll_item'
        unique_together = (('period', 'employee'),)

class PayrollPeriod(models.Model):
    period_id = models.BigAutoField(primary_key=True)
    code = models.TextField(unique=True)
    start_date = models.DateField()
    end_date = models.DateField()
    status = models.TextField()  # This field type is a guess.
    closed_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField()

    def __str__(self):
        return str(self.code)

    class Meta:
        managed = False
        db_table = 'mcms_hr"."payroll_period'

class Shift(models.Model):
    shift_id = models.BigAutoField(primary_key=True)
    department = models.ForeignKey(Department, models.DO_NOTHING)
    employee = models.ForeignKey(Employee, models.DO_NOTHING)
    shift_type = models.TextField()  # This field type is a guess.
    start_at = models.DateTimeField()
    end_at = models.DateTimeField()
    created_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'mcms_hr"."shift'
