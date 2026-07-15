-- ============================================================
-- Phase 14: Clinical department / section coverage
-- Adds the national-scale department list as NEW rows (ids 27+) alongside
-- the existing 26. No renames (existing IDs stay stable; names are
-- referenced by seed SQL). `code` is unique -> idempotent via
-- ON CONFLICT DO NOTHING. `kind` reuses the existing controlled vocabulary.
-- ============================================================

INSERT INTO mcms_hr.department (code, name, kind, is_active) VALUES
    -- Medicine / specialty clinics
    ('ONC-UNIT',   'Oncology Department Unit',                         'clinic',    true),
    ('MED-GIM',    'Department of General Internal Medicine',          'clinic',    true),
    ('NEU-PSY',    'Department of Neurology and Psychiatry',           'clinic',    true),
    ('CARD-DIS',   'Department of Cardiology and Cardiovascular Diseases','clinic',  true),
    ('CHEST',      'Department of Chest Diseases',                     'clinic',    true),
    ('TROP-MED',   'Department of Tropical Medicine',                  'clinic',    true),
    ('DERM-VEN',   'Department of Dermatology, Venereology and Andrology','clinic',  true),
    ('GERI',       'Department of Geriatrics and Gerontology',         'clinic',    true),
    ('FMED',       'Department of Family Medicine',                    'clinic',    true),
    ('GENET',      'Department of Medical Genetics',                   'clinic',    true),
    -- Labs / pathology / imaging
    ('CLIN-PATH',  'Department of Clinical Pathology',                 'lab',       true),
    ('ONC-NM',     'Department of Clinical Oncology and Nuclear Medicine','radiology', true),
    ('RAD-DX',     'Department of Diagnostic Radiology',               'radiology', true),
    -- Surgical disciplines
    ('SURG-GEN',   'Department of General Surgery',                    'surgical',   true),
    ('SURG-CT',    'Department of Cardio-Thoracic Surgery',            'surgical',   true),
    ('SURG-URO',   'Department of Urology',                            'surgical',   true),
    ('SURG-PLAS',  'Department of Plastic Burn and Maxillofacial Surgery','surgical', true),
    ('SURG-PED',   'Department of Pediatric Surgery',                  'surgical',   true),
    ('SURG-VASC',  'Department of Vascular Surgery',                   'surgical',   true),
    -- Other specialties
    ('OPHTH',      'Department of Ophthalmology and Ophthalmic Surgery','clinic',    true),
    ('OBS-GYN',    'Department of Obstetrics and Gynecology',          'clinic',    true),
    ('ANES-ICU',   'Department of Anesthesiology, Intensive Care and Pain Management','icu', true),
    ('EMED',       'Department of Emergency Medicine',                 'emergency',  true),
    -- Support / allied health
    ('PHY-REHAB',  'Department of Rheumatology, Rehabilitation and Physical Medicine','physio', true),
    ('PROSTH',     'Department of Prosthetics',                        'physio',    true),
    ('IND-INST',   'Department of Industrial Installations',           'administration', true)
ON CONFLICT (code) DO NOTHING;
