-- Migrate Django framework tables from mcms_core -> public.
-- Why: Django connected with search_path starting at mcms_core, so its
-- auth_*/django_* tables were created inside the domain core schema. Framework
-- infra must live in `public`, keeping mcms_core purely for domain data.
--
-- Safe: no domain (mcms_*) table references these framework tables (verified),
-- so moving them preserves all FKs, data, and sequences via SET SCHEMA.

-- 1) move sequences (must precede tables so defaults stay valid)
ALTER SEQUENCE IF EXISTS mcms_core.django_migrations_id_seq      SET SCHEMA public;
ALTER SEQUENCE IF EXISTS mcms_core.django_content_type_id_seq    SET SCHEMA public;
ALTER SEQUENCE IF EXISTS mcms_core.auth_permission_id_seq        SET SCHEMA public;
ALTER SEQUENCE IF EXISTS mcms_core.auth_group_id_seq             SET SCHEMA public;
ALTER SEQUENCE IF EXISTS mcms_core.auth_group_permissions_id_seq SET SCHEMA public;
ALTER SEQUENCE IF EXISTS mcms_core.auth_user_id_seq              SET SCHEMA public;
ALTER SEQUENCE IF EXISTS mcms_core.auth_user_groups_id_seq       SET SCHEMA public;
ALTER SEQUENCE IF EXISTS mcms_core.auth_user_user_permissions_id_seq SET SCHEMA public;
ALTER SEQUENCE IF EXISTS mcms_core.django_admin_log_id_seq       SET SCHEMA public;

-- 2) move tables (data + constraints move with them)
ALTER TABLE IF EXISTS mcms_core.django_migrations            SET SCHEMA public;
ALTER TABLE IF EXISTS mcms_core.django_content_type          SET SCHEMA public;
ALTER TABLE IF EXISTS mcms_core.auth_permission              SET SCHEMA public;
ALTER TABLE IF EXISTS mcms_core.auth_group                   SET SCHEMA public;
ALTER TABLE IF EXISTS mcms_core.auth_group_permissions       SET SCHEMA public;
ALTER TABLE IF EXISTS mcms_core.auth_user                    SET SCHEMA public;
ALTER TABLE IF EXISTS mcms_core.auth_user_groups             SET SCHEMA public;
ALTER TABLE IF EXISTS mcms_core.auth_user_user_permissions   SET SCHEMA public;
ALTER TABLE IF EXISTS mcms_core.django_session               SET SCHEMA public;
ALTER TABLE IF EXISTS mcms_core.django_admin_log             SET SCHEMA public;

-- 3) re-point Django's connection search_path so `public` is FIRST.
--    Framework tables resolve to public; domain tables still resolve via mcms_core.
--    (Applied in config/settings.py DATABASES OPTIONS; this note documents intent.)
