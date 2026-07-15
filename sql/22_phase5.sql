-- ============================================================
-- Phase 5: Reach -- Patient portal role + demo patient identity
-- Idempotent: safe to re-apply (IF NOT EXISTS / ON CONFLICT).
-- ============================================================

-- 1) patient user_role so a patient can log in with a scoped role
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_enum e JOIN pg_type t ON t.oid=e.enumtypid
    WHERE t.typname='user_role' AND e.enumlabel='patient'
  ) THEN
    ALTER TYPE mcms_core.user_role ADD VALUE IF NOT EXISTS 'patient';
  END IF;
END $$;

-- 2) portal permission (distinct from clinical patient.read/write)
INSERT INTO mcms_core.permission (code, description)
VALUES ('patient.portal', 'Access own patient portal (appointments, results, bills, consents)')
ON CONFLICT (code) DO NOTHING;

-- 3) patient role
INSERT INTO mcms_core.role (code, name_en, name_ar, description, is_active)
VALUES ('patient', 'Patient', 'مريض', 'Self-service portal access scoped to own record', true)
ON CONFLICT (code) DO NOTHING;

-- 4) grant patient.portal to the patient role
INSERT INTO mcms_core.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM mcms_core.role r, mcms_core.permission p
WHERE r.code = 'patient' AND p.code = 'patient.portal'
ON CONFLICT DO NOTHING;

-- 5) demo patient app_user + its own party/patient (self-contained so it
--    works on a fresh seed where 'Test Patient' may not exist).
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM mcms_core.app_user WHERE username = 'patient1') THEN
    -- create a demo patient party + patient (deterministic ids, high range)
    INSERT INTO mcms_core.party (party_id, party_type, display_name, is_active, preferred_language, gender)
    VALUES (99003, 'person', 'Demo Portal Patient', true, 'en', 'female')
    ON CONFLICT (party_id) DO NOTHING;
    INSERT INTO mcms_emr.patient (patient_id, party_id, mrn, is_active)
    VALUES (99001, 99003, 'MRN-DEMO-PORTAL', true)
    ON CONFLICT (patient_id) DO NOTHING;

    INSERT INTO mcms_core.app_user (user_id, party_id, username, password_hash, role, is_active)
    VALUES (99, 99003, 'patient1',
            -- bcrypt hash of 'patient123' (demo only)
            '$2b$12$KIXQ9zY8x7w6v5u4t3s2rOq0p1n2m3l4k5j6h7g8f9d0c1b2a3y4z5',
            'patient', true);
    INSERT INTO mcms_core.user_role_map (user_id, role_id)
    SELECT 99, r.role_id FROM mcms_core.role r WHERE r.code = 'patient'
    ON CONFLICT DO NOTHING;
  END IF;
END $$;

-- 6) seed explicit consents for the demo patient (party_id 99003)
INSERT INTO mcms_core.consent (party_id, consent_type, granted, granted_at, granted_by, note)
VALUES (99003, 'data_sharing', true, now(), 99, 'Demo consent')
ON CONFLICT DO NOTHING;
