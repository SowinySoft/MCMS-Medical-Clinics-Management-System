-- =====================================================================
-- MCMS MERGE SEED : RBAC roles + permission matrix, dialysis & nursery depts
-- Reflects the design-doc RBAC/ABAC matrix.
-- =====================================================================
BEGIN;

-- ---- Departments for the two new units (G3, G4) ----
INSERT INTO mcms_hr.department (code, name, kind, is_active)
SELECT v.code, v.name, 'clinic', TRUE
FROM (VALUES
   ('DIAL-GEN','Dialysis Unit'),
   ('NURS-GEN','Nursery / Neonatal Unit')
) AS v(code,name)
WHERE NOT EXISTS (SELECT 1 FROM mcms_hr.department d WHERE d.code = v.code);

-- ---- Roles (design-doc role list, bilingual) ----
INSERT INTO mcms_core.role (code, name_en, name_ar, description)
SELECT v.code, v.en, v.ar, v.descr
FROM (VALUES
  ('reception','Receptionist','موظف استقبال','Patient & appointment management, no clinical records'),
  ('doctor','Doctor','طبيب','Read/write records, order tests, prescribe'),
  ('nurse','Nurse/Technician','ممرض/فني','Execute orders, vitals, preliminary results'),
  ('pharmacist','Pharmacist','صيدلي','Medication management, dispensing, interactions'),
  ('lab_rad','Laboratory/Radiology','مختبر/أشعة','Results & reports entry, DICOM'),
  ('accountant','Accountant','محاسب','Billing, payments, financial reports'),
  ('store_mgr','Warehouse Manager','مدير المخزن','Inventory & batch management'),
  ('sysadmin','System Administrator','مدير النظام','User management, roles, settings, full access')
) AS v(code,en,ar,descr)
WHERE NOT EXISTS (SELECT 1 FROM mcms_core.role r WHERE r.code = v.code);

-- ---- Permissions (domain.action) ----
INSERT INTO mcms_core.permission (code, description)
SELECT v.code, v.descr
FROM (VALUES
  ('patient.read','View patient demographics'),
  ('patient.write','Create/edit patients'),
  ('appointment.manage','Book/modify appointments'),
  ('emr.read','Read clinical records'),
  ('emr.write','Write clinical records / orders / prescriptions'),
  ('order.execute','Execute orders / enter preliminary results'),
  ('pharmacy.dispense','Dispense medications'),
  ('lab_rad.result','Enter lab/radiology results & reports'),
  ('billing.manage','Create/modify invoices & payments'),
  ('billing.read','View financial reports'),
  ('inventory.manage','Manage inventory & batches'),
  ('admin.all','Full administrative access')
) AS v(code,descr)
WHERE NOT EXISTS (SELECT 1 FROM mcms_core.permission p WHERE p.code = v.code);

-- ---- Permission matrix (role_permission) ----
-- helper: insert (role_code, perm_code) pairs
INSERT INTO mcms_core.role_permission (role_id, permission_id)
SELECT r.role_id, p.permission_id
FROM (VALUES
  -- Reception
  ('reception','patient.read'),('reception','patient.write'),('reception','appointment.manage'),
  -- Doctor
  ('doctor','patient.read'),('doctor','emr.read'),('doctor','emr.write'),('doctor','appointment.manage'),
  -- Nurse/Technician
  ('nurse','patient.read'),('nurse','emr.read'),('nurse','order.execute'),
  -- Pharmacist
  ('pharmacist','emr.read'),('pharmacist','pharmacy.dispense'),
  -- Lab/Radiology
  ('lab_rad','emr.read'),('lab_rad','lab_rad.result'),
  -- Accountant
  ('accountant','billing.manage'),('accountant','billing.read'),
  -- Warehouse Manager
  ('store_mgr','inventory.manage'),
  -- System Administrator (all)
  ('sysadmin','admin.all'),('sysadmin','billing.read'),('sysadmin','patient.read'),('sysadmin','emr.read')
) AS m(role_code, perm_code)
JOIN mcms_core.role r ON r.code = m.role_code
JOIN mcms_core.permission p ON p.code = m.perm_code
WHERE NOT EXISTS (
   SELECT 1 FROM mcms_core.role_permission rp
   WHERE rp.role_id = r.role_id AND rp.permission_id = p.permission_id
);

COMMIT;
