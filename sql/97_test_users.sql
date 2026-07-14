-- 97_test_users.sql : minimal test identity for the pytest backend suite.
--
-- The backend tests (apps/core/tests/) authenticate via force_authenticate
-- against real auth_user rows, and exercise RBAC via the DB matrix
-- (mcms_core.app_user -> user_role_map -> role -> role_permission -> permission).
-- This script provisions just enough identity for the suite:
--   * admin  -> role 'admin' (user_role enum) + user_role_map -> sysadmin
--   * acc1   -> role 'billing_clerk'          + user_role_map -> accountant
--
-- Passwords are placeholders ('!'); the test harness never checks them
-- (force_authenticate bypasses the password). Safe to commit: no real creds.
--
-- Idempotent: re-running on an existing DB is a no-op (ON CONFLICT DO NOTHING
-- / WHERE NOT EXISTS), so CI can apply it repeatedly.

BEGIN;

-- 1) Parties (app_user.party_id is NOT NULL FK -> mcms_core.party)
INSERT INTO mcms_core.party (party_id, party_type, display_name, is_active, preferred_language)
VALUES (1, 'person', 'Test Admin',  true, 'en'),
       (2, 'person', 'Test Acc1',   true, 'en')
ON CONFLICT (party_id) DO NOTHING;

-- 2) Django auth users (public.auth_user) -- force_authenticate target
INSERT INTO public.auth_user (username, password, first_name, last_name, is_active, is_superuser, is_staff, email, date_joined)
VALUES ('admin', '!', 'Test', 'Admin', true, true,  true,  'admin@mcms.local', now()),
       ('acc1',  '!', 'Test', 'Acc1',  true, false, false, 'acc1@mcms.local',  now())
ON CONFLICT (username) DO NOTHING;

-- 3) mcms_core.app_user (user_id explicit for deterministic user_role_map links)
INSERT INTO mcms_core.app_user (user_id, party_id, username, password_hash, role, is_active)
VALUES (1, 1, 'admin', '!', 'admin',        true),
       (2, 2, 'acc1',  '!', 'billing_clerk', true)
ON CONFLICT (user_id) DO NOTHING;

-- 4) user_role_map: admin -> sysadmin, acc1 -> accountant
INSERT INTO mcms_core.user_role_map (user_id, role_id)
SELECT 1, r.role_id FROM mcms_core.role r WHERE r.code = 'sysadmin'
  AND NOT EXISTS (SELECT 1 FROM mcms_core.user_role_map WHERE user_id = 1 AND role_id = r.role_id);

INSERT INTO mcms_core.user_role_map (user_id, role_id)
SELECT 2, r.role_id FROM mcms_core.role r WHERE r.code = 'accountant'
  AND NOT EXISTS (SELECT 1 FROM mcms_core.user_role_map WHERE user_id = 2 AND role_id = r.role_id);

-- 5) Advance sequences past the explicit IDs so later auto-inserts (e.g. the
--    e2e test creating new parties/users) don't collide on party_id/user_id.
SELECT setval(pg_get_serial_sequence('mcms_core.party', 'party_id'),
              GREATEST((SELECT max(party_id) FROM mcms_core.party), 1));
SELECT setval(pg_get_serial_sequence('mcms_core.app_user', 'user_id'),
              GREATEST((SELECT max(user_id) FROM mcms_core.app_user), 1));
SELECT setval(pg_get_serial_sequence('public.auth_user', 'id'),
              GREATEST((SELECT max(id) FROM public.auth_user), 1));

COMMIT;
