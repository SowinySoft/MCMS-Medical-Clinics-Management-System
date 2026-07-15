"""
core domain models — reflected from PostgreSQL schema mcms_core.
Auto-generated via inspectdb, then normalized:
  * db_table schema-qualified ("mcms_core"."table") to disambiguate
    colliding table names across the 15 schemas.
  * managed = False (schema owned by SQL migrations in /sql, not Django).
  * __str__ added for admin/serializer readability.
Pattern: reflection layer — Django never DDLs these tables.
"""
from django.db import models


class Address(models.Model):
    address_id = models.BigAutoField(primary_key=True)
    party = models.ForeignKey('Party', models.DO_NOTHING)
    label = models.TextField()
    line1 = models.TextField(blank=True, null=True)
    line2 = models.TextField(blank=True, null=True)
    city = models.TextField(blank=True, null=True)
    region = models.TextField(blank=True, null=True)
    postal_code = models.TextField(blank=True, null=True)
    country = models.TextField()
    latitude = models.FloatField(blank=True, null=True)
    longitude = models.FloatField(blank=True, null=True)
    is_primary = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True, )

    def __str__(self):
        return str(self.label)

    class Meta:
        managed = False
        db_table = 'mcms_core"."address'

class AppUser(models.Model):
    user_id = models.BigAutoField(primary_key=True)
    party = models.ForeignKey('Party', models.DO_NOTHING)
    username = models.TextField(unique=True)
    password_hash = models.TextField()
    role = models.TextField()  # This field type is a guess.
    specialization = models.TextField(blank=True, null=True)
    is_active = models.BooleanField()
    last_login_at = models.DateTimeField(blank=True, null=True)
    failed_logins = models.IntegerField()
    locked_until = models.DateTimeField(blank=True, null=True)
    facility_id = models.BigIntegerField(blank=True, null=True)  # NULL = cross-facility (sysadmin)
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )

    def __str__(self):
        return str(self.username)

    class Meta:
        managed = False
        db_table = 'mcms_core"."app_user'

class AuditTrail(models.Model):
    audit_id = models.BigAutoField(primary_key=True)
    table_schema = models.TextField()
    table_name = models.TextField()
    row_id = models.BigIntegerField()
    action = models.TextField(choices=[('insert','insert'),('update','update'),('delete','delete')])
    changed_by = models.ForeignKey(AppUser, models.DO_NOTHING, db_column='changed_by', blank=True, null=True)
    changed_at = models.DateTimeField()
    before = models.JSONField(blank=True, null=True)
    after = models.JSONField(blank=True, null=True)
    event = models.ForeignKey('EventLog', models.DO_NOTHING, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_core"."audit_trail'

class Contact(models.Model):
    contact_id = models.BigAutoField(primary_key=True)
    party = models.ForeignKey('Party', models.DO_NOTHING)
    kind = models.TextField(choices=[('phone','phone'),('mobile','mobile'),('email','email'),('fax','fax'),('web','web')])
    value = models.TextField()
    is_primary = models.BooleanField()
    verified_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )

    class Meta:
        managed = False
        db_table = 'mcms_core"."contact'

class EventLog(models.Model):
    event_id = models.BigAutoField(primary_key=True)
    seq = models.BigIntegerField(unique=True)
    occurred_at = models.DateTimeField()
    kind = models.TextField()  # This field type is a guess.
    severity = models.TextField()  # This field type is a guess.
    actor_user = models.ForeignKey(AppUser, models.DO_NOTHING, blank=True, null=True)
    subject_party = models.ForeignKey('Party', models.DO_NOTHING, blank=True, null=True)
    source_schema = models.TextField(blank=True, null=True)
    source_table = models.TextField(blank=True, null=True)
    source_id = models.BigIntegerField(blank=True, null=True)
    payload = models.JSONField()
    channel = models.TextField()

    class Meta:
        managed = False
        db_table = 'mcms_core"."event_log'

class Lookup(models.Model):
    lookup_id = models.BigAutoField(primary_key=True)
    namespace = models.TextField()
    code = models.TextField()
    label = models.TextField()
    parent_code = models.TextField(blank=True, null=True)
    sort_order = models.IntegerField(blank=True, null=True)
    is_active = models.BooleanField()
    label_en = models.TextField(blank=True, null=True)
    label_ar = models.TextField(blank=True, null=True)

    def __str__(self):
        return str(self.label)

    class Meta:
        managed = False
        db_table = 'mcms_core"."lookup'
        unique_together = (('namespace', 'code'),)

class Notification(models.Model):
    notification_id = models.BigAutoField(primary_key=True)
    recipient_user = models.ForeignKey(AppUser, models.DO_NOTHING, blank=True, null=True)
    recipient_party = models.ForeignKey('Party', models.DO_NOTHING, blank=True, null=True)
    category = models.TextField()
    channel = models.TextField()  # This field type is a guess.
    subject = models.TextField(blank=True, null=True)
    body = models.TextField()
    status = models.TextField()  # This field type is a guess.
    source_schema = models.TextField(blank=True, null=True)
    source_table = models.TextField(blank=True, null=True)
    source_id = models.BigIntegerField(blank=True, null=True)
    sent_at = models.DateTimeField(blank=True, null=True)
    read_at = models.DateTimeField(blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True, )

    class Meta:
        managed = False
        db_table = 'mcms_core"."notification'

class Party(models.Model):
    party_id = models.BigAutoField(primary_key=True)
    party_type = models.TextField()  # This field type is a guess.
    code = models.TextField(unique=True, blank=True, null=True)
    display_name = models.TextField()
    legal_name = models.TextField(blank=True, null=True)
    gender = models.TextField(blank=True, null=True)  # This field type is a guess.
    date_of_birth = models.DateField(blank=True, null=True)
    blood_type = models.TextField(blank=True, null=True)  # This field type is a guess.
    tax_id = models.TextField(blank=True, null=True)
    national_id = models.TextField(blank=True, null=True)
    is_active = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True, )
    updated_at = models.DateTimeField(auto_now=True, )
    preferred_language = models.TextField(choices=[('ar','ar'),('en','en')])

    def __str__(self):
        return str(self.display_name)

    class Meta:
        managed = False
        db_table = 'mcms_core"."party'

class Permission(models.Model):
    permission_id = models.BigAutoField(primary_key=True)
    code = models.TextField(unique=True)
    description = models.TextField(blank=True, null=True)

    def __str__(self):
        return str(self.code)

    class Meta:
        managed = False
        db_table = 'mcms_core"."permission'

class Role(models.Model):
    role_id = models.BigAutoField(primary_key=True)
    code = models.TextField(unique=True)
    name_en = models.TextField()
    name_ar = models.TextField(blank=True, null=True)
    description = models.TextField(blank=True, null=True)
    is_active = models.BooleanField()
    created_at = models.DateTimeField(auto_now_add=True, )

    def __str__(self):
        return str(self.code)

    class Meta:
        managed = False
        db_table = 'mcms_core"."role'

class RolePermission(models.Model):
    role = models.OneToOneField(Role, models.DO_NOTHING, primary_key=True)  # The composite primary key (role_id, permission_id) found, that is not supported. The first column is selected.
    permission = models.ForeignKey(Permission, models.DO_NOTHING)

    class Meta:
        managed = False
        db_table = 'mcms_core"."role_permission'
        unique_together = (('role', 'permission'),)

class UserRoleMap(models.Model):
    user = models.OneToOneField(AppUser, models.DO_NOTHING, primary_key=True)  # The composite primary key (user_id, role_id) found, that is not supported. The first column is selected.
    role = models.ForeignKey(Role, models.DO_NOTHING)
    department_id = models.BigIntegerField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_core"."user_role_map'
        unique_together = (('user', 'role'),)



class Consent(models.Model):
    """Per-party consent flags (GDPR/HIPAA-style). Drives what UI/API exposes."""
    consent_id = models.BigAutoField(primary_key=True)
    party = models.ForeignKey('Party', models.DO_NOTHING)
    consent_type = models.TextField()  # consent_type enum
    granted = models.BooleanField(default=False)
    granted_at = models.DateTimeField(blank=True, null=True)
    revoked_at = models.DateTimeField(blank=True, null=True)
    granted_by = models.BigIntegerField(blank=True, null=True)  # app_user
    note = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_core"."consent'
        unique_together = (('party', 'consent_type'),)


class AccessLog(models.Model):
    """Per-record read-access log for sensitive tables (HIPAA/GDPR access tracing)."""
    access_id = models.BigAutoField(primary_key=True)
    reader_user = models.ForeignKey(AppUser, models.DO_NOTHING, null=True, blank=True, db_column='reader_user_id')
    subject_party = models.ForeignKey('Party', models.DO_NOTHING, null=True, blank=True, db_column='subject_party_id')
    table_schema = models.TextField()
    table_name = models.TextField()
    row_id = models.BigIntegerField()
    read_at = models.DateTimeField(auto_now_add=True, )
    reason = models.TextField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'mcms_core"."access_log'
