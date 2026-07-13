-- Audit fix: add hr.read permission (router now requires it for mcms_hr)
-- and grant it to the System Administrator role so HR data is readable
-- by admins while staying siloed from clinical staff.
INSERT INTO mcms_core.permission (code, description)
VALUES ('hr.read', 'Read HR / workforce data')
ON CONFLICT (code) DO NOTHING;

INSERT INTO mcms_core.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM mcms_core.role r, mcms_core.permission p
WHERE r.code = 'sysadmin' AND p.code = 'hr.read'
ON CONFLICT DO NOTHING;
