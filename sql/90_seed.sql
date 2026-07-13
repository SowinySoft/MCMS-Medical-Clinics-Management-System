-- ============================================================
-- MCMS · 90 · Seed reference data
-- Departments spanning every clinical area, ICD-10 cherry-picks,
-- CPT codes for procedures, drug seed list, service price list,
-- GL chart of accounts.
-- Designed to be re-runnable (ON CONFLICT DO NOTHING).
-- ============================================================

BEGIN;

-- ---------- Departments (catalog) ----------
INSERT INTO mcms_hr.department (code, name, kind, location_building, location_floor) VALUES
   ('CLIN-GEN',  'General Outpatient Clinic',    'clinic', 'Main', 1),
   ('CLIN-CARD', 'Cardiology Clinic',            'clinic', 'Main', 2),
   ('CLIN-ORTH', 'Orthopaedics Clinic',          'clinic', 'Main', 2),
   ('CLIN-OBS',  'Obstetrics & Gynaecology',     'clinic', 'Women', 3),
   ('CLIN-PAED', 'Paediatrics Clinic',           'clinic', 'Children', 2),
   ('CLIN-ENT',  'Otolaryngology (ENT)',         'clinic', 'Specialty', 1),
   ('OR-GEN',    'General Operating Theatre',    'surgical', 'Surgical Suite', 1),
   ('OR-CARD',   'Cardiac Surgery Theatre',      'surgical', 'Surgical Suite', 2),
   ('OR-ORTHO',  'Orthopaedic Surgery Theatre',  'surgical', 'Surgical Suite', 1),
   ('OR-NEURO',  'Neurosurgery Theatre',         'surgical', 'Surgical Suite', 2),
   ('ED-MAIN',   'Emergency Department',         'emergency', 'Main', 1),
   ('ED-TRIAGE', 'Triage Area',                  'emergency', 'Main', 1),
   ('ICU-GEN',   'General ICU',                   'icu', 'Critical Care', 3),
   ('ICU-CCU',   'Coronary Care Unit',            'icu', 'Critical Care', 3),
   ('ICU-NICU',  'Neonatal ICU',                  'icu', 'Paediatrics', 2),
   ('LAB-CLIN',  'Clinical Laboratory',           'lab', 'Service Block', -1),
   ('LAB-PATH',  'Pathology Lab',                 'lab', 'Service Block', -1),
   ('RAD-MAIN',  'Radiology / Imaging',           'radiology', 'Service Block', -1),
   ('RX-MAIN',   'Inpatient Pharmacy',           'pharmacy', 'Service Block', 0),
   ('RX-OUT',    'Outpatient Pharmacy',         'pharmacy', 'Main', 1),
   ('PHY-MAIN',  'Physiotherapy Unit',           'physio', 'Rehab', 1),
   ('BILL-M',    'Billing Office',                'billing', 'Administration', 0),
   ('HR-M',      'Human Resources',                'hr', 'Administration', 0),
   ('ADMIN',     'Administration',                'administration', 'Administration', 0)
ON CONFLICT (code) DO NOTHING;

-- ---------- ICD-10 cherry-pick (lookup namespace = 'icd10') ----------
INSERT INTO mcms_core.lookup (namespace, code, label) VALUES
   ('icd10','J00',    'Acute nasopharyngitis [common cold]'),
   ('icd10','J20.9',  'Acute bronchitis, unspecified'),
   ('icd10','E11.9',  'Type 2 diabetes mellitus without complications'),
   ('icd10','I10',    'Essential (primary) hypertension'),
   ('icd10','E78.5',  'Hypercholesterolaemia, unspecified'),
   ('icd10','M54.5',  'Low back pain'),
   ('icd10','K21.9',  'Gastro-oesophageal reflux disease without oesophagitis'),
   ('icd10','N39.0',  'Urinary tract infection, site not specified'),
   ('icd10','R51',    'Headache'),
   ('icd10','S82.8',  'Fracture of other specified parts of lower leg'),
   ('icd10','I21.9',  'Acute myocardial infarction, unspecified'),
   ('icd10','J45.909','Unspecified asthma, uncomplicated'),
   ('icd10','C50.9',  'Malignant neoplasm of breast of unspecified site, female'),
   ('icd10','K80.20', 'Calculus of gallbladder without cholecystitis'),
   ('icd10','A09',    'Diarrhoea and gastroenteritis of infectious origin'),
   ('icd10','O80',    'Encounter for full-term uncomplicated delivery'),
   ('icd10','O34.21', 'Maternal care for congenital uterine malformation'),
   ('icd10','S06.0',  'Intracranial injury (concussion of brain)'),
   ('icd10','S72.0',  'Fracture of neck of femur'),
   ('icd10','S02.5',  'Fracture of tooth (traumatic)')
ON CONFLICT (namespace, code) DO NOTHING;

-- ---------- CPT/procedure codes (lookup namespace = 'cpt') ----------
INSERT INTO mcms_core.lookup (namespace, code, label) VALUES
   ('cpt','99213','Office Visit, Established Patient, Low Complexity'),
   ('cpt','99214','Office Visit, Established Patient, Moderate'),
   ('cpt','99204','Office Visit, New Patient, Moderate'),
   ('cpt','58150','Total abdominal hysterectomy'),
   ('cpt','23470','Arthroplasty, glenohumeral joint'),
   ('cpt','27130','Total hip arthroplasty'),
   ('cpt','27447','Total knee arthroplasty'),
   ('cpt','49505','Repair of femoral hernia'),
   ('cpt','47579','Open cholecystectomy'),
   ('cpt','33533','Coronary artery bypass, single'),
   ('cpt','80053','Comprehensive Metabolic Panel'),
   ('cpt','80048','Basic Metabolic Panel'),
   ('cpt','85025','CBC w/ differential'),
   ('cpt','81002','Urinalysis, non-automated'),
   ('cpt','71045','X-ray chest, complete view'),
   ('cpt','71250','CT thorax without contrast'),
   ('cpt','70553','MRI brain with contrast'),
   ('cpt','76700','Ultrasound abdomen'),
   ('cpt','93000','ECG, 12-lead')
ON CONFLICT (namespace, code) DO NOTHING;

-- ---------- Drug seed (pharmacy catalog) ----------
INSERT INTO mcms_rx.drug_item (generic_name, brand_name, drug_class, form, strength, unit, reorder_level, reorder_qty, cost_per_unit, sale_price_per_unit) VALUES
   ('Paracetamol', 'Panadol',       'analgesic',    'tablet',  '500 mg', 'tablet', 1000, 5000, 0.05, 0.15),
   ('Ibuprofen',   'Brufen',        'nsaid',        'tablet',  '400 mg', 'tablet',  500, 3000, 0.08, 0.20),
   ('Acetylsalicylic acid', 'Aspec', 'cardiac',     'tablet',  '75 mg',  'tablet', 200, 1000, 0.03, 0.10),
   ('Amoxicillin', 'Amoxil',        'antibiotic',   'capsule', '500 mg', 'capsule', 300, 2000, 0.10, 0.30),
   ('Cephalexin',  'Keflex',        'antibiotic',   'capsule', '500 mg', 'capsule', 300, 2000, 0.15, 0.40),
   ('Metformin',   'Glucophage',    'antidiabetic', 'tablet',  '850 mg', 'tablet', 400, 2500, 0.06, 0.20),
   ('Atorvastatin','Lipitor',       'cardiac',      'tablet',  '20 mg',  'tablet', 400, 2500, 0.20, 0.55),
   ('Amlodipine',  'Norvasc',        'antihypertensive','tablet','10 mg','tablet', 400, 2500, 0.10, 0.30),
   ('Omeprazole',  'Prilosec',       'gi',           'capsule', '20 mg', 'capsule', 500, 3000, 0.10, 0.35),
   ('Salbutamol',  'Ventolin',       'respiratory',  'inhaler', '100 mcg','inhaler', 100, 500, 1.20, 4.50),
   ('Insulin Lispro','Humalog',      'antidiabetic', 'vial',  '100 u/mL','vial',   80,  400, 6.50, 15.00),
   ('Morphine',    'Morphsul',       'analgesic',    'ampule', '10 mg/mL','ampule', 80,  300, 1.50, 5.00),
   ('Cetirizine',  'Zyrtec',         'antihistamine','tablet', '10 mg',  'tablet', 400, 2500, 0.05, 0.20),
   ('Dextrose 5%', 'D5W',            'iv_fluid',     'bag',    '500 mL', 'bag',    100, 600, 1.00, 3.50),
   ('Sodium Chloride 0.9%', 'NS',    'iv_fluid',     'bag',    '1000 mL','bag',    100, 600, 1.00, 4.00)
ON CONFLICT DO NOTHING;

-- ---------- Service Price List (billing) ----------
WITH svc AS (
   SELECT *
   FROM (VALUES
     ('SVC-CONSULT-GEN',  'General Consultation',         'consultation'::mcms_billing.service_type,    'CLIN-GEN',  150.00),
     ('SVC-CONSULT-CARD', 'Cardiology Consultation',      'consultation'::mcms_billing.service_type,    'CLIN-CARD', 250.00),
     ('SVC-ED-TRIAGE',    'Emergency Triage Fee',         'emergency_triage'::mcms_billing.service_type, 'ED-TRIAGE', 300.00),
     ('SVC-ED-VISIT',     'Emergency Visit Fee',          'emergency_triage'::mcms_billing.service_type, 'ED-MAIN',   450.00),
     ('SVC-ICU-BED-DAY',  'ICU Bed Day Charge',           'icu_bed'::mcms_billing.service_type,          'ICU-GEN',  2200.00),
     ('SVC-OR-MIN',       'OR Charge per Minute',         'surgery_or'::mcms_billing.service_type,      'OR-GEN',     45.00),
     ('SVC-ANAESTHESIA',  'Anaesthesia Fee',              'anaesthesia'::mcms_billing.service_type,     'OR-GEN',    500.00),
     ('SVC-LAB-CBC',      'CBC Test',                     'lab_test'::mcms_billing.service_type,         'LAB-CLIN',   60.00),
     ('SVC-LAB-CMP',      'Comprehensive Metabolic Panel','lab_test'::mcms_billing.service_type,         'LAB-CLIN',  180.00),
     ('SVC-RAD-XR-CHST',  'Chest X-ray',                  'imaging'::mcms_billing.service_type,          'RAD-MAIN',  120.00),
     ('SVC-RAD-CT-THX',   'CT Thorax',                    'imaging'::mcms_billing.service_type,          'RAD-MAIN',  650.00),
     ('SVC-RAD-MRI-BRN',  'MRI Brain with Contrast',      'imaging'::mcms_billing.service_type,          'RAD-MAIN', 1500.00),
     ('SVC-PHYSIO-SESS',  'Physiotherapy Session',        'physio_session'::mcms_billing.service_type,  'PHY-MAIN',  200.00),
     ('SVC-AMBULATE',     'Ambulance Service',            'ambulance'::mcms_billing.service_type,        'ED-MAIN',   350.00),
     ('SVC-DOC-EMR',      'EMR Document Fee',              'emr_document'::mcms_billing.service_type,     'CLIN-GEN',   10.00)
   ) AS t(billing_code, name, service_type, dept_code, price)
)
INSERT INTO mcms_billing.service_price (code, name, service_type, department_id, unit_price, currency)
SELECT s.billing_code, s.name, s.service_type, d.department_id, s.price, 'SAR'
FROM svc s
JOIN mcms_hr.department d ON d.code = s.dept_code
ON CONFLICT (code) DO NOTHING;

-- ---------- Therapy catalog (physio) ----------
INSERT INTO mcms_physio.therapy_catalog (code, name, type, body_region, duration_minutes) VALUES
   ('PHY-MAN1', 'Manual Therapy 30',         'manual_therapy',     'spine',          30),
   ('PHY-ELEC1','Electrotherapy TENS',       'electrotherapy',     'any',            20),
   ('PHY-EX1',  'Therapeutic Exercise Set A','therapeutic_exercise','any',           45),
   ('PHY-HYDRO','Hydrotherapy Session',       'hydrotherapy',      'lower_limb',     30),
   ('PHY-CRY',  'Cryotherapy 10',             'cryotherapy',         'joint',           10),
   ('PHY-HEAT','Heat Therapy 15',            'heat_therapy',        'soft_tissue',    15),
   ('PHY-US',   'Therapeutic Ultrasound',    'ultrasound',         'soft_tissue',    15),
   ('PHY-LASER','Laser Therapy',              'laser',              'wound',          10),
   ('PHY-TAPING','Kinesio Taping',           'taping',             'any',            15),
   ('PHY-NEURO','Neuro Rehab Session',       'neuro_rehab',        'cns',            60)
ON CONFLICT (code) DO NOTHING;

-- ---------- Surgery procedure catalog ----------
INSERT INTO mcms_surgical.procedure_catalog (cpt_code, name, body_site, default_duration_min)
SELECT code, label, NULL, 90
FROM mcms_core.lookup
WHERE namespace = 'cpt'
  AND code IN ('58150','23470','27130','27447','49505','47579','33533')
ON CONFLICT (cpt_code) DO NOTHING;

-- ---------- Operating Rooms ----------
INSERT INTO mcms_surgical.operating_room (department_id, code, name, room_type, status)
SELECT d.department_id, t.code, t.name, t.room_type, 'available'::mcms_surgical.or_status
FROM (VALUES
   ('OR-GEN',  'General Operating Theatre', 'general'),
   ('OR-CARD', 'Cardiac Surgery Theatre',  'cardiac'),
   ('OR-ORTHO','Orthopaedic Surgery Theatre','ortho'),
   ('OR-NEURO','Neurosurgery Theatre',     'neuro')
) AS t(code, name, room_type)
JOIN mcms_hr.department d ON d.code = t.code
ON CONFLICT (code) DO NOTHING;

-- ---------- Radiology modalities ----------
INSERT INTO mcms_rad.modality_suite (department_id, code, name, modality)
SELECT d.department_id, t.code, t.name, t.modality::mcms_rad.modality_type
FROM (VALUES
   ('RAD-XR',    'X-ray Room 1'::text,  'xray'::mcms_rad.modality_type),
   ('RAD-CT',    'CT Suite A',         'ct'),
   ('RAD-MRI',   'MRI Unit 1',         'mri'),
   ('RAD-US',    'Ultrasound 1',       'us'),
   ('RAD-FL',    'Fluoroscopy Room',   'fluoroscopy')
) AS t(code, name, modality)
JOIN mcms_hr.department d ON d.code = 'RAD-MAIN'
ON CONFLICT (code) DO NOTHING;

-- ---------- Imaging exam catalog ----------
INSERT INTO mcms_rad.exam_catalog (name, body_part, default_modality, contrast_used, duration_minutes)
VALUES
   ('Chest X-ray',                    'Chest',  'xray',  false, 5),
   ('CT Thorax without contrast',     'Chest',  'ct',    false, 15),
   ('CT Brain with contrast',         'Brain',  'ct',    true,  20),
   ('MRI Brain with contrast',        'Brain',  'mri',   true,  45),
   ('Ultrasound Abdomen',             'Abdomen','us',    false, 15),
   ('DEXA Bone Density',              'Spine',  'dexa',  false, 10)
ON CONFLICT DO NOTHING;

-- ---------- Lab test catalog ----------
INSERT INTO mcms_lab.test_catalog (loinc_code, name, category, specimen_type, volume_required, unit, ref_low, ref_high, turnaround_minutes)
VALUES
   ('6690-2',  'WBC Count',                'Hematology',   'blood',    3.00, '10^3/uL',  4.0, 11.0, 60),
   ('718-7',   'Hemoglobin',                'Hematology',  'blood',    3.00, 'g/dL',     12.0, 17.5, 60),
   ('789-8',   'RBC Count',                'Hematology',   'blood',    3.00, '10^6/uL',  4.0,  5.9, 60),
   ('2951-2',  'Sodium',                   'Chemistry',   'blood',    3.00, 'mmol/L',   135,  145,  60),
   ('2069-3',  'Chloride',                 'Chemistry',   'blood',    3.00, 'mmol/L',   98,   107,  60),
   ('2885-2',  'Potassium',                'Chemistry',   'blood',    3.00, 'mmol/L',   3.5,  5.0,  60),
   ('2345-7',  'Glucose, Random',          'Chemistry',   'blood',    3.00, 'mg/dL',    70,   100,  30),
   ('3094-0',  'Urea Nitrogen',           'Chemistry',   'blood',    3.00, 'mg/dL',    7,    20,  90),
   ('38483-4', 'Creatinine',                'Chemistry',   'blood',    3.00, 'mg/dL',    0.7,  1.3, 90),
   ('33914-3', 'Troponin I, Cardiac',      'Chemistry',   'blood',    3.00, 'ng/mL',    0.0,  0.04, 45),
   ('25428-4', 'PT/INR',                   'Coagulation', 'blood',    2.50, 'INR',      0.8,  1.2, 60),
   ('6298-4',  'Potassium, Urine',         'Urinalysis',  'urine',    10.0, 'mmol/d',   25,   125, 120),
   ('5792-7',  'Glucose, Urine',           'Urinalysis',  'urine',    10.0, 'mg/dL',    0,    0,   30),
   ('11277-5', 'Stool Routine',            'Microbiology','stool',    5.00, ' qualitative', NULL, NULL, 240),
   ('14461-8', 'Wound Culture & Sensitivity','Microbiology','swab',   1.00, 'qualitative', NULL, NULL, 1440)
ON CONFLICT DO NOTHING;

-- ---------- Lab panels ----------
INSERT INTO mcms_lab.test_panel (code, name) VALUES ('P-CBC','Complete Blood Count') ON CONFLICT (code) DO NOTHING;
INSERT INTO mcms_lab.test_panel (code, name) VALUES ('P-CMP','Comprehensive Metabolic Panel') ON CONFLICT (code) DO NOTHING;
INSERT INTO mcms_lab.test_panel (code, name) VALUES ('P-CARD','Cardiac Panel') ON CONFLICT (code) DO NOTHING;
INSERT INTO mcms_lab.test_panel (code, name) VALUES ('P-UA','Urinalysis Panel') ON CONFLICT (code) DO NOTHING;
INSERT INTO mcms_lab.test_panel_item (panel_id, test_id, sort_order)
SELECT p.panel_id, t.test_id, 1 FROM mcms_lab.test_panel p, mcms_lab.test_catalog t
WHERE p.code='P-CBC' AND t.loinc_code='6690-2';
INSERT INTO mcms_lab.test_panel_item (panel_id, test_id, sort_order)
SELECT p.panel_id, t.test_id, 2 FROM mcms_lab.test_panel p, mcms_lab.test_catalog t
WHERE p.code='P-CBC' AND t.loinc_code='718-7';
INSERT INTO mcms_lab.test_panel_item (panel_id, test_id, sort_order)
SELECT p.panel_id, t.test_id, 3 FROM mcms_lab.test_panel p, mcms_lab.test_catalog t
WHERE p.code='P-CBC' AND t.loinc_code='789-8';
INSERT INTO mcms_lab.test_panel_item (panel_id, test_id, sort_order)
SELECT p.panel_id, t.test_id, n FROM mcms_lab.test_panel p, mcms_lab.test_catalog t,
   (VALUES (1),(2),(3),(4),(5),(6),(7)) AS v(n)
WHERE p.code='P-CMP'
  AND ((v.n=1 AND t.loinc_code='2951-2')
    OR (v.n=2 AND t.loinc_code='2069-3')
    OR (v.n=3 AND t.loinc_code='2885-2')
    OR (v.n=4 AND t.loinc_code='3094-0')
    OR (v.n=5 AND t.loinc_code='38483-4')
    OR (v.n=6 AND t.loinc_code='2345-7'));
INSERT INTO mcms_lab.test_panel_item (panel_id, test_id, sort_order)
SELECT p.panel_id, t.test_id, 1 FROM mcms_lab.test_panel p, mcms_lab.test_catalog t
WHERE p.code='P-CARD' AND t.loinc_code='33914-3';

-- ---------- GL Accounts ----------
INSERT INTO mcms_erp.gl_account (code, name, account_type) VALUES
   ('1000',        'Assets',                     'asset'),
   ('1001',        'Cash on Hand',                'cash'),
   ('1002',        'Bank Account',                'bank'),
   ('1200',        'Accounts Receivable',        'asset'),
   ('1400',        'Inventory',                   'asset'),
   ('2000',        'Liabilities',                 'liability'),
   ('2100',        'Accounts Payable',            'liability'),
   ('3000',        'Equity',                      'equity'),
   ('4000',        'Outpatient Revenue',           'revenue'),
   ('4100',        'Surgical Revenue',            'revenue'),
   ('4200',        'Lab Revenue',                 'revenue'),
   ('4300',        'Pharmacy Revenue',             'revenue'),
   ('4400',        'Imaging Revenue',              'revenue'),
   ('4500',        'ICU Revenue',                  'revenue'),
   ('4600',        'ER Revenue',                   'revenue'),
   ('5000',        'Cost of Consumables',          'expense'),
   ('5100',        'Cost of Drugs Sold',           'expense'),
   ('5200',        'Salaries & Wages',              'expense'),
   ('5300',        'Utilities Expense',             'expense'),
   ('5400',        'Depreciation',                  'expense')
ON CONFLICT (code) DO NOTHING;

COMMIT;
