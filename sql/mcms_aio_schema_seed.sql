--
-- PostgreSQL database dump
--

\restrict lPfARl8gMsTvkLtDtB6cWBqFXIHtKKD46AJsP4PO7YwuOCz4cBwb4S5prtUkbda

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: organization; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

SET SESSION AUTHORIZATION DEFAULT;

ALTER TABLE mcms_core.organization DISABLE TRIGGER ALL;

INSERT INTO mcms_core.organization VALUES
	(1, 'HQ', 'National HQ', 'المقر الوطني', NULL, true, '2026-07-18 21:59:07.492461+03', 1);


ALTER TABLE mcms_core.organization ENABLE TRIGGER ALL;

--
-- Data for Name: facility; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.facility DISABLE TRIGGER ALL;

INSERT INTO mcms_core.facility VALUES
	(1, 1, 'DEFAULT', 'Default Facility', 'المنشأة الافتراضية', NULL, true, '2026-07-18 21:59:07.492461+03'),
	(2, 1, 'TERT', 'National Tertiary Centre', 'المركز الوطني التخصصي', NULL, true, '2026-07-18 21:59:07.674999+03'),
	(3, 1, 'DIST', 'District General Hospital', 'مستشفى المنطقة العام', NULL, true, '2026-07-18 21:59:07.674999+03'),
	(4, 1, 'CANC', 'Regional Cancer Centre', 'المركز الإقليمي للأورام', NULL, true, '2026-07-18 21:59:07.674999+03');


ALTER TABLE mcms_core.facility ENABLE TRIGGER ALL;

--
-- Data for Name: party; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.party DISABLE TRIGGER ALL;

INSERT INTO mcms_core.party VALUES
	(99003, 'person', NULL, 'Demo Portal Patient', NULL, 'female', NULL, 'unknown', NULL, NULL, true, '2026-07-18 21:59:07.423037+03', '2026-07-18 21:59:07.423037+03', 'en', 1),
	(1, 'person', NULL, 'Test Admin', NULL, NULL, NULL, 'unknown', NULL, NULL, true, '2026-07-18 21:59:08.656874+03', '2026-07-18 21:59:08.656874+03', 'en', 1),
	(2, 'person', NULL, 'Test Acc1', NULL, NULL, NULL, 'unknown', NULL, NULL, true, '2026-07-18 21:59:08.656874+03', '2026-07-18 21:59:08.656874+03', 'en', 1),
	(99004, 'person', NULL, 'System Administrator', NULL, NULL, NULL, 'unknown', NULL, NULL, true, '2026-07-18 21:59:14.437289+03', '2026-07-18 21:59:14.437289+03', 'ar', 1),
	(99005, 'person', 'MRN-DEMO-001', 'Ahmad Mansour', 'Ahmad Mansour', 'male', '1985-01-01', NULL, NULL, 'MRN-DEMO-001', true, '2026-07-18 21:59:17.929136+03', '2026-07-18 21:59:17.929136+03', 'en', 1),
	(99006, 'person', 'MRN-DEMO-002', 'Layla Haddad', 'Layla Haddad', 'female', '1985-01-01', NULL, NULL, 'MRN-DEMO-002', true, '2026-07-18 21:59:17.966972+03', '2026-07-18 21:59:17.966972+03', 'en', 1),
	(99007, 'person', 'MRN-DEMO-003', 'Karim Nasser', 'Karim Nasser', 'male', '1985-01-01', NULL, NULL, 'MRN-DEMO-003', true, '2026-07-18 21:59:17.979058+03', '2026-07-18 21:59:17.979058+03', 'en', 1),
	(99008, 'person', 'MRN-DEMO-004', 'Sara Khoury', 'Sara Khoury', 'female', '1985-01-01', NULL, NULL, 'MRN-DEMO-004', true, '2026-07-18 21:59:17.991907+03', '2026-07-18 21:59:17.991907+03', 'en', 1),
	(99009, 'person', 'MRN-DEMO-005', 'Omar Saleh', 'Omar Saleh', 'male', '1985-01-01', NULL, NULL, 'MRN-DEMO-005', true, '2026-07-18 21:59:17.998016+03', '2026-07-18 21:59:17.998016+03', 'en', 1);


ALTER TABLE mcms_core.party ENABLE TRIGGER ALL;

--
-- Data for Name: app_user; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.app_user DISABLE TRIGGER ALL;

INSERT INTO mcms_core.app_user VALUES
	(99, 99003, 'patient1', '$2b$12$KIXQ9zY8x7w6v5u4t3s2rOq0p1n2m3l4k5j6h7g8f9d0c1b2a3y4z5', 'patient', NULL, true, NULL, 0, NULL, '2026-07-18 21:59:07.423037+03', '2026-07-18 21:59:07.423037+03', NULL),
	(2, 2, 'acc1', '!', 'billing_clerk', NULL, true, NULL, 0, NULL, '2026-07-18 21:59:08.656874+03', '2026-07-18 21:59:08.656874+03', NULL),
	(1, 1, 'admin', '!', 'admin', NULL, true, NULL, 0, NULL, '2026-07-18 21:59:08.656874+03', '2026-07-18 21:59:08.656874+03', NULL);


ALTER TABLE mcms_core.app_user ENABLE TRIGGER ALL;

--
-- Data for Name: patient; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.patient DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.patient VALUES
	(99001, 99003, 'MRN-DEMO-PORTAL', NULL, NULL, NULL, NULL, NULL, NULL, false, NULL, NULL, false, false, '2026-07-18 21:59:07.423037+03', '2026-07-18 21:59:07.423037+03', NULL, NULL, 1, false),
	(99002, 99005, 'MRN-DEMO-001', 'Demo Contact', '+10000000000', 99005, 'Demo Insurer', 'POL-MRN-DEMO-001', 'GRP-1', NULL, NULL, 'en', NULL, NULL, '2026-07-18 21:59:17.960864+03', '2026-07-18 21:59:17.960864+03', NULL, NULL, 1, false),
	(99003, 99006, 'MRN-DEMO-002', 'Demo Contact', '+10000000000', 99006, 'Demo Insurer', 'POL-MRN-DEMO-002', 'GRP-1', NULL, NULL, 'en', NULL, NULL, '2026-07-18 21:59:17.974834+03', '2026-07-18 21:59:17.974834+03', NULL, NULL, 1, false),
	(99004, 99007, 'MRN-DEMO-003', 'Demo Contact', '+10000000000', 99007, 'Demo Insurer', 'POL-MRN-DEMO-003', 'GRP-1', NULL, NULL, 'en', NULL, NULL, '2026-07-18 21:59:17.982059+03', '2026-07-18 21:59:17.982059+03', NULL, NULL, 1, false),
	(99005, 99008, 'MRN-DEMO-004', 'Demo Contact', '+10000000000', 99008, 'Demo Insurer', 'POL-MRN-DEMO-004', 'GRP-1', NULL, NULL, 'en', NULL, NULL, '2026-07-18 21:59:17.994906+03', '2026-07-18 21:59:17.994906+03', NULL, NULL, 1, false),
	(99006, 99009, 'MRN-DEMO-005', 'Demo Contact', '+10000000000', 99009, 'Demo Insurer', 'POL-MRN-DEMO-005', 'GRP-1', NULL, NULL, 'en', NULL, NULL, '2026-07-18 21:59:18.003106+03', '2026-07-18 21:59:18.003106+03', NULL, NULL, 1, false);


ALTER TABLE mcms_emr.patient ENABLE TRIGGER ALL;

--
-- Data for Name: department; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.department DISABLE TRIGGER ALL;

INSERT INTO mcms_hr.department VALUES
	(1, 'ONC-UNIT', 'Oncology Department Unit', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(2, 'MED-GIM', 'Department of General Internal Medicine', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(3, 'NEU-PSY', 'Department of Neurology and Psychiatry', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(4, 'CARD-DIS', 'Department of Cardiology and Cardiovascular Diseases', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(5, 'CHEST', 'Department of Chest Diseases', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(6, 'TROP-MED', 'Department of Tropical Medicine', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(7, 'DERM-VEN', 'Department of Dermatology, Venereology and Andrology', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(8, 'GERI', 'Department of Geriatrics and Gerontology', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(9, 'FMED', 'Department of Family Medicine', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(10, 'GENET', 'Department of Medical Genetics', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(11, 'CLIN-PATH', 'Department of Clinical Pathology', NULL, 'lab', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(12, 'ONC-NM', 'Department of Clinical Oncology and Nuclear Medicine', NULL, 'radiology', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(13, 'RAD-DX', 'Department of Diagnostic Radiology', NULL, 'radiology', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(14, 'SURG-GEN', 'Department of General Surgery', NULL, 'surgical', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(15, 'SURG-CT', 'Department of Cardio-Thoracic Surgery', NULL, 'surgical', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(16, 'SURG-URO', 'Department of Urology', NULL, 'surgical', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(17, 'SURG-PLAS', 'Department of Plastic Burn and Maxillofacial Surgery', NULL, 'surgical', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(18, 'SURG-PED', 'Department of Pediatric Surgery', NULL, 'surgical', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(19, 'SURG-VASC', 'Department of Vascular Surgery', NULL, 'surgical', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(20, 'OPHTH', 'Department of Ophthalmology and Ophthalmic Surgery', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(21, 'OBS-GYN', 'Department of Obstetrics and Gynecology', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(22, 'ANES-ICU', 'Department of Anesthesiology, Intensive Care and Pain Management', NULL, 'icu', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(23, 'EMED', 'Department of Emergency Medicine', NULL, 'emergency', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(24, 'PHY-REHAB', 'Department of Rheumatology, Rehabilitation and Physical Medicine', NULL, 'physio', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(25, 'PROSTH', 'Department of Prosthetics', NULL, 'physio', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(26, 'IND-INST', 'Department of Industrial Installations', NULL, 'administration', NULL, NULL, NULL, true, '2026-07-18 21:59:07.643886+03', '2026-07-18 21:59:07.643886+03', 1),
	(27, 'CLIN-GEN', 'General Outpatient Clinic', NULL, 'clinic', NULL, 'Main', 1, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(28, 'CLIN-CARD', 'Cardiology Clinic', NULL, 'clinic', NULL, 'Main', 2, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(29, 'CLIN-ORTH', 'Orthopaedics Clinic', NULL, 'clinic', NULL, 'Main', 2, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(30, 'CLIN-OBS', 'Obstetrics & Gynaecology', NULL, 'clinic', NULL, 'Women', 3, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(31, 'CLIN-PAED', 'Paediatrics Clinic', NULL, 'clinic', NULL, 'Children', 2, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(32, 'CLIN-ENT', 'Otolaryngology (ENT)', NULL, 'clinic', NULL, 'Specialty', 1, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(33, 'OR-GEN', 'General Operating Theatre', NULL, 'surgical', NULL, 'Surgical Suite', 1, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(34, 'OR-CARD', 'Cardiac Surgery Theatre', NULL, 'surgical', NULL, 'Surgical Suite', 2, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(35, 'OR-ORTHO', 'Orthopaedic Surgery Theatre', NULL, 'surgical', NULL, 'Surgical Suite', 1, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(36, 'OR-NEURO', 'Neurosurgery Theatre', NULL, 'surgical', NULL, 'Surgical Suite', 2, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(37, 'ED-MAIN', 'Emergency Department', NULL, 'emergency', NULL, 'Main', 1, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(38, 'ED-TRIAGE', 'Triage Area', NULL, 'emergency', NULL, 'Main', 1, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(39, 'ICU-GEN', 'General ICU', NULL, 'icu', NULL, 'Critical Care', 3, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(40, 'ICU-CCU', 'Coronary Care Unit', NULL, 'icu', NULL, 'Critical Care', 3, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(41, 'ICU-NICU', 'Neonatal ICU', NULL, 'icu', NULL, 'Paediatrics', 2, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(42, 'LAB-CLIN', 'Clinical Laboratory', NULL, 'lab', NULL, 'Service Block', -1, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(43, 'LAB-PATH', 'Pathology Lab', NULL, 'lab', NULL, 'Service Block', -1, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(44, 'RAD-MAIN', 'Radiology / Imaging', NULL, 'radiology', NULL, 'Service Block', -1, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(45, 'RX-MAIN', 'Inpatient Pharmacy', NULL, 'pharmacy', NULL, 'Service Block', 0, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(46, 'RX-OUT', 'Outpatient Pharmacy', NULL, 'pharmacy', NULL, 'Main', 1, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(47, 'PHY-MAIN', 'Physiotherapy Unit', NULL, 'physio', NULL, 'Rehab', 1, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(48, 'BILL-M', 'Billing Office', NULL, 'billing', NULL, 'Administration', 0, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(49, 'HR-M', 'Human Resources', NULL, 'hr', NULL, 'Administration', 0, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(50, 'ADMIN', 'Administration', NULL, 'administration', NULL, 'Administration', 0, true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(51, 'DIAL-GEN', 'Dialysis Unit', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:08.579833+03', '2026-07-18 21:59:08.579833+03', 1),
	(52, 'NURS-GEN', 'Nursery / Neonatal Unit', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:59:08.579833+03', '2026-07-18 21:59:08.579833+03', 1);


ALTER TABLE mcms_hr.department ENABLE TRIGGER ALL;

--
-- Data for Name: encounter; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.encounter DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.encounter VALUES
	(2, 'MRN-DEMO-001', 99002, 'finished', 'ambulatory', 1, NULL, 1, 'Demo visit', 'Routine', '2026-07-18 21:59:17.913956+03', '2026-07-18 22:59:17.913956+03', NULL, NULL, '2026-07-18 21:59:18.094959+03', '2026-07-18 21:59:18.094959+03', NULL, 1),
	(3, 'MRN-DEMO-002', 99003, 'finished', 'ambulatory', 1, NULL, 1, 'Demo visit', 'Routine', '2026-07-17 21:59:17.913956+03', '2026-07-17 22:59:17.913956+03', NULL, NULL, '2026-07-18 21:59:18.144845+03', '2026-07-18 21:59:18.144845+03', NULL, 1),
	(4, 'MRN-DEMO-003', 99004, 'finished', 'ambulatory', 1, NULL, 1, 'Demo visit', 'Routine', '2026-07-16 21:59:17.913956+03', '2026-07-16 22:59:17.913956+03', NULL, NULL, '2026-07-18 21:59:18.159546+03', '2026-07-18 21:59:18.159546+03', NULL, 1),
	(5, 'MRN-DEMO-004', 99005, 'finished', 'ambulatory', 1, NULL, 1, 'Demo visit', 'Routine', '2026-07-15 21:59:17.913956+03', '2026-07-15 22:59:17.913956+03', NULL, NULL, '2026-07-18 21:59:18.170656+03', '2026-07-18 21:59:18.170656+03', NULL, 1),
	(6, 'MRN-DEMO-005', 99006, 'finished', 'ambulatory', 1, NULL, 1, 'Demo visit', 'Routine', '2026-07-14 21:59:17.913956+03', '2026-07-14 22:59:17.913956+03', NULL, NULL, '2026-07-18 21:59:18.181888+03', '2026-07-18 21:59:18.181888+03', NULL, 1);


ALTER TABLE mcms_emr.encounter ENABLE TRIGGER ALL;

--
-- Data for Name: invoice; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.invoice DISABLE TRIGGER ALL;

INSERT INTO mcms_billing.invoice VALUES
	(2, 'INV-DEMO-001', 99002, 'MRN-DEMO-001', 2, 1, 'issued', 150.00, 0.00, 0.00, 0.00, 150.00, DEFAULT, 'USD', '2026-07-18 21:59:17.913956+03', '2026-08-17', NULL, NULL, '2026-07-18 21:59:18.320051+03', '2026-07-18 21:59:18.320051+03', 1),
	(3, 'INV-DEMO-002', 99003, 'MRN-DEMO-002', 2, 1, 'issued', 150.00, 0.00, 0.00, 0.00, 150.00, DEFAULT, 'USD', '2026-07-18 21:59:17.913956+03', '2026-08-17', NULL, NULL, '2026-07-18 21:59:18.334312+03', '2026-07-18 21:59:18.334312+03', 1),
	(4, 'INV-DEMO-003', 99004, 'MRN-DEMO-003', 2, 1, 'issued', 150.00, 0.00, 0.00, 0.00, 150.00, DEFAULT, 'USD', '2026-07-18 21:59:17.913956+03', '2026-08-17', NULL, NULL, '2026-07-18 21:59:18.344583+03', '2026-07-18 21:59:18.344583+03', 1);


ALTER TABLE mcms_billing.invoice ENABLE TRIGGER ALL;

--
-- Data for Name: insurance_claim; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.insurance_claim DISABLE TRIGGER ALL;

INSERT INTO mcms_billing.insurance_claim VALUES
	(2, 2, 'demo', 'demo', 99001, 1.00, 1.00, 1.00, 'draft', '2026-07-18 21:59:20.125775+03', '2026-07-18 21:59:20.130238+03', '2026-07-18 21:59:20.131286+03', 'demo', 'demo', '2026-07-18 21:59:20.133285+03', '2026-07-18 21:59:20.133285+03', 1);


ALTER TABLE mcms_billing.insurance_claim ENABLE TRIGGER ALL;

--
-- Data for Name: claim_response; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.claim_response DISABLE TRIGGER ALL;



ALTER TABLE mcms_billing.claim_response ENABLE TRIGGER ALL;

--
-- Data for Name: eligibility_check; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.eligibility_check DISABLE TRIGGER ALL;



ALTER TABLE mcms_billing.eligibility_check ENABLE TRIGGER ALL;

--
-- Data for Name: service_price; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.service_price DISABLE TRIGGER ALL;

INSERT INTO mcms_billing.service_price VALUES
	(2, 'SVC-DOC-EMR', 'EMR Document Fee', 'emr_document', 27, 10.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(3, 'SVC-CONSULT-GEN', 'General Consultation', 'consultation', 27, 150.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(4, 'SVC-CONSULT-CARD', 'Cardiology Consultation', 'consultation', 28, 250.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(5, 'SVC-ANAESTHESIA', 'Anaesthesia Fee', 'anaesthesia', 33, 500.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(6, 'SVC-OR-MIN', 'OR Charge per Minute', 'surgery_or', 33, 45.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(7, 'SVC-AMBULATE', 'Ambulance Service', 'ambulance', 37, 350.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(8, 'SVC-ED-VISIT', 'Emergency Visit Fee', 'emergency_triage', 37, 450.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(9, 'SVC-ED-TRIAGE', 'Emergency Triage Fee', 'emergency_triage', 38, 300.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(10, 'SVC-ICU-BED-DAY', 'ICU Bed Day Charge', 'icu_bed', 39, 2200.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(11, 'SVC-LAB-CMP', 'Comprehensive Metabolic Panel', 'lab_test', 42, 180.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(12, 'SVC-LAB-CBC', 'CBC Test', 'lab_test', 42, 60.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(13, 'SVC-RAD-MRI-BRN', 'MRI Brain with Contrast', 'imaging', 44, 1500.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(14, 'SVC-RAD-CT-THX', 'CT Thorax', 'imaging', 44, 650.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(15, 'SVC-RAD-XR-CHST', 'Chest X-ray', 'imaging', 44, 120.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(16, 'SVC-PHYSIO-SESS', 'Physiotherapy Session', 'physio_session', 47, 200.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1);


ALTER TABLE mcms_billing.service_price ENABLE TRIGGER ALL;

--
-- Data for Name: invoice_line; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.invoice_line DISABLE TRIGGER ALL;

INSERT INTO mcms_billing.invoice_line VALUES
	(2, 2, 2, 'billing', 'service_price', 2, 'EMR Document Fee', 1.00, 150.00, DEFAULT, '2026-07-18 21:59:17.914572+03', 1),
	(3, 3, 2, 'billing', 'service_price', 2, 'EMR Document Fee', 1.00, 150.00, DEFAULT, '2026-07-18 21:59:17.914572+03', 1),
	(4, 4, 2, 'billing', 'service_price', 2, 'EMR Document Fee', 1.00, 150.00, DEFAULT, '2026-07-18 21:59:17.914572+03', 1);


ALTER TABLE mcms_billing.invoice_line ENABLE TRIGGER ALL;

--
-- Data for Name: payer; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.payer DISABLE TRIGGER ALL;

INSERT INTO mcms_billing.payer VALUES
	(1, 'MOH', 'Ministry of Health', true, true, true, true, '2026-07-18 21:59:07.625463+03', 1),
	(2, 'NHIF', 'National Health Insurance', true, true, true, true, '2026-07-18 21:59:07.625463+03', 1),
	(3, 'AXA', 'AXA Gulf Insurance', true, true, true, true, '2026-07-18 21:59:07.625463+03', 1);


ALTER TABLE mcms_billing.payer ENABLE TRIGGER ALL;

--
-- Data for Name: payment; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.payment DISABLE TRIGGER ALL;

INSERT INTO mcms_billing.payment VALUES
	(2, 2, 'cash', 1.00, 'demo', '2026-07-18 21:59:20.154814+03', 99, 'demo', 'demo', 1);


ALTER TABLE mcms_billing.payment ENABLE TRIGGER ALL;

--
-- Data for Name: room; Type: TABLE DATA; Schema: mcms_clinic; Owner: -
--

ALTER TABLE mcms_clinic.room DISABLE TRIGGER ALL;

INSERT INTO mcms_clinic.room VALUES
	(2, 1, 'R-DEMO-01', 'Demo Room', 2, '{bed,monitor}', true, '2026-07-18 21:59:17.914572+03', '2026-07-18 21:59:17.914572+03', 1);


ALTER TABLE mcms_clinic.room ENABLE TRIGGER ALL;

--
-- Data for Name: appointment; Type: TABLE DATA; Schema: mcms_clinic; Owner: -
--

ALTER TABLE mcms_clinic.appointment DISABLE TRIGGER ALL;

INSERT INTO mcms_clinic.appointment VALUES
	(2, 'MRN-DEMO-001', 99002, 1, NULL, 1, '2026-07-19 06:59:17.913956+03', '2026-07-19 07:29:17.913956+03', 'booked', 'Routine check-up', 1, NULL, '2026-07-18 21:59:18.036264+03', '2026-07-18 21:59:18.036264+03', NULL, NULL, NULL, false, NULL, NULL, 1),
	(3, 'MRN-DEMO-002', 99003, 1, NULL, 1, '2026-07-20 06:59:17.913956+03', '2026-07-20 07:29:17.913956+03', 'booked', 'Routine check-up', 1, NULL, '2026-07-18 21:59:18.060275+03', '2026-07-18 21:59:18.060275+03', NULL, NULL, NULL, false, NULL, NULL, 1),
	(4, 'MRN-DEMO-003', 99004, 1, NULL, 1, '2026-07-21 06:59:17.913956+03', '2026-07-21 07:29:17.913956+03', 'booked', 'Routine check-up', 1, NULL, '2026-07-18 21:59:18.064274+03', '2026-07-18 21:59:18.064274+03', NULL, NULL, NULL, false, NULL, NULL, 1),
	(5, 'MRN-DEMO-004', 99005, 1, NULL, 1, '2026-07-22 06:59:17.913956+03', '2026-07-22 07:29:17.913956+03', 'booked', 'Routine check-up', 1, NULL, '2026-07-18 21:59:18.075632+03', '2026-07-18 21:59:18.075632+03', NULL, NULL, NULL, false, NULL, NULL, 1);


ALTER TABLE mcms_clinic.appointment ENABLE TRIGGER ALL;

--
-- Data for Name: patient_queue; Type: TABLE DATA; Schema: mcms_clinic; Owner: -
--

ALTER TABLE mcms_clinic.patient_queue DISABLE TRIGGER ALL;

INSERT INTO mcms_clinic.patient_queue VALUES
	(2, 99002, 'MRN-DEMO-001', 1, 1, 2, 1, 'waiting', '2026-07-18 21:59:17.913956+03', NULL, '2026-07-18 21:59:17.913956+03', '2026-07-18 21:59:17.913956+03', 2, 1);


ALTER TABLE mcms_clinic.patient_queue ENABLE TRIGGER ALL;

--
-- Data for Name: consultation; Type: TABLE DATA; Schema: mcms_clinic; Owner: -
--

ALTER TABLE mcms_clinic.consultation DISABLE TRIGGER ALL;

INSERT INTO mcms_clinic.consultation VALUES
	(2, 2, 2, 2, 2, 1, 15, 'Demo subjective', 'Demo objective', 'Demo assessment', 'Demo plan', 7, 'completed', '2026-07-18 21:59:17.913956+03', '2026-07-18 21:59:17.913956+03', '2026-07-18 21:59:18.491655+03', '2026-07-18 21:59:18.491655+03', 1);


ALTER TABLE mcms_clinic.consultation ENABLE TRIGGER ALL;

--
-- Data for Name: access_log; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.access_log DISABLE TRIGGER ALL;

INSERT INTO mcms_core.access_log VALUES
	(2, 1, 1, 'demo', 'demo', 1, '2026-07-18 21:59:18.912075+03', 'demo', 1);


ALTER TABLE mcms_core.access_log ENABLE TRIGGER ALL;

--
-- Data for Name: address; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.address DISABLE TRIGGER ALL;

INSERT INTO mcms_core.address VALUES
	(2, 1, 'demo', 'demo', 'demo', 'demo', 'demo', 'demo', 'demo', 1, 1, true, '2026-07-18 21:59:18.846827+03', 1);


ALTER TABLE mcms_core.address ENABLE TRIGGER ALL;

--
-- Data for Name: event_log; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.event_log DISABLE TRIGGER ALL;

INSERT INTO mcms_core.event_log VALUES
	(1, 2, '2026-07-18 21:59:07.423037+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 1, '{"code": "patient.portal", "description": "Access own patient portal (appointments, results, bills, consents)", "permission_id": 1}', 'db-trigger', NULL, '6c17baf5db287691cc0e61a53be0dd3fac3a6816b52b6f3cab51072c35d5f0c9', 1),
	(2, 4, '2026-07-18 21:59:07.423037+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 1, '{"code": "patient", "name_ar": "مريض", "name_en": "Patient", "role_id": 1, "is_active": true, "created_at": "2026-07-18T21:59:07.423037+03:00", "description": "Self-service portal access scoped to own record"}', 'db-trigger', '6c17baf5db287691cc0e61a53be0dd3fac3a6816b52b6f3cab51072c35d5f0c9', 'bbb07ef979a7330bec7108dfea312093507cb214b74dc59aa13edd0307cbceb9', 1),
	(3, 6, '2026-07-18 21:59:07.423037+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 1, '{"role_id": 1, "permission_id": 1}', 'db-trigger', 'bbb07ef979a7330bec7108dfea312093507cb214b74dc59aa13edd0307cbceb9', '6be54fc7f63cf5c26df336fb0948d408666c8461d274306ef38bd6587d8f3be9', 1),
	(4, 8, '2026-07-18 21:59:07.423037+03', 'create', 'info', NULL, NULL, 'mcms_core', 'party', 99003, '{"code": null, "gender": "female", "tax_id": null, "party_id": 99003, "is_active": true, "blood_type": "unknown", "created_at": "2026-07-18T21:59:07.423037+03:00", "legal_name": null, "party_type": "person", "updated_at": "2026-07-18T21:59:07.423037+03:00", "national_id": null, "display_name": "Demo Portal Patient", "date_of_birth": null, "preferred_language": "en"}', 'db-trigger', '6be54fc7f63cf5c26df336fb0948d408666c8461d274306ef38bd6587d8f3be9', 'a16fecbc4ba127842327b45213b3b2bd214f6f8c570e6baa267b61b15215a7bc', 1),
	(5, 10, '2026-07-18 21:59:07.423037+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'patient', 99001, '{"mrn": "MRN-DEMO-PORTAL", "fhir_id": null, "hl7_mpi": null, "party_id": 99003, "created_at": "2026-07-18T21:59:07.423037+03:00", "patient_id": 99001, "updated_at": "2026-07-18T21:59:07.423037+03:00", "facility_id": 1, "is_deceased": false, "living_will": false, "organ_donor": false, "coverage_verified": false, "insurance_group_no": null, "insurance_provider": null, "preferred_language": null, "insurance_policy_no": null, "coverage_verified_at": null, "next_of_kin_party_id": null, "emergency_contact_name": null, "emergency_contact_phone": null}', 'db-trigger', 'a16fecbc4ba127842327b45213b3b2bd214f6f8c570e6baa267b61b15215a7bc', 'f043a792778de1f717196d4b134e3946190bcd092c371ea7e5ca966f3e1b8c9f', 1),
	(76, 152, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 13, '{"code": "J45.909", "label": "Unspecified asthma, uncomplicated", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 13, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'ad9ee8fed4b4b97706d33d3c8ddf119be38567ff017dd7902396267ad6b21322', '00a27da2d6e30d8fcf94406ca488f36c4697f1fa384351573b741580a85fdc28', 1),
	(6, 12, '2026-07-18 21:59:07.423037+03', 'create', 'info', NULL, NULL, 'mcms_core', 'app_user', 99, '{"role": "patient", "user_id": 99, "party_id": 99003, "username": "patient1", "is_active": true, "created_at": "2026-07-18T21:59:07.423037+03:00", "updated_at": "2026-07-18T21:59:07.423037+03:00", "facility_id": null, "locked_until": null, "failed_logins": 0, "last_login_at": null, "password_hash": "$2b$12$KIXQ9zY8x7w6v5u4t3s2rOq0p1n2m3l4k5j6h7g8f9d0c1b2a3y4z5", "specialization": null}', 'db-trigger', 'f043a792778de1f717196d4b134e3946190bcd092c371ea7e5ca966f3e1b8c9f', 'e4ebff8a03381fc40b165b2ff423529245f905fda347679c8492354fc7937c8b', 1),
	(7, 14, '2026-07-18 21:59:07.423037+03', 'create', 'info', NULL, NULL, 'mcms_core', 'user_role_map', 1, '{"role_id": 1, "user_id": 99, "department_id": null}', 'db-trigger', 'e4ebff8a03381fc40b165b2ff423529245f905fda347679c8492354fc7937c8b', '93e98c03c652993660fc63d36f0b0ec48d07285dba7270c47a5978c7158a6f80', 1),
	(8, 16, '2026-07-18 21:59:07.63425+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 2, '{"code": "rx.prescribe", "description": "Create / sign electronic prescriptions", "facility_id": 1, "permission_id": 2}', 'db-trigger', '93e98c03c652993660fc63d36f0b0ec48d07285dba7270c47a5978c7158a6f80', '5a734452518240a8758ef0226a5e982c546a02fe4789e3f10ea1b5304bf8b62e', 1),
	(9, 18, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 1, '{"code": "ONC-UNIT", "kind": "clinic", "name": "Oncology Department Unit", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 1, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '5a734452518240a8758ef0226a5e982c546a02fe4789e3f10ea1b5304bf8b62e', 'f1b4c6f1987502eee6767d37733b4ed8a0f7235740e2d217732b2ad9efb011b0', 1),
	(10, 20, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 2, '{"code": "MED-GIM", "kind": "clinic", "name": "Department of General Internal Medicine", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 2, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'f1b4c6f1987502eee6767d37733b4ed8a0f7235740e2d217732b2ad9efb011b0', '6515cb7a867f84e4a27db4e5147a99c4d22fac9d147bd427309dce9484692d97', 1),
	(11, 22, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 3, '{"code": "NEU-PSY", "kind": "clinic", "name": "Department of Neurology and Psychiatry", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 3, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '6515cb7a867f84e4a27db4e5147a99c4d22fac9d147bd427309dce9484692d97', 'cdb883e16dc2bc215df346358e777d9daf0dd4ea6676ac4a9d19530984a27465', 1),
	(12, 24, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 4, '{"code": "CARD-DIS", "kind": "clinic", "name": "Department of Cardiology and Cardiovascular Diseases", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 4, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'cdb883e16dc2bc215df346358e777d9daf0dd4ea6676ac4a9d19530984a27465', 'f455e22210a3a6f7ba0dbaa5ff95130722ffba95bda6eaacb384f2078c0ee06c', 1),
	(13, 26, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 5, '{"code": "CHEST", "kind": "clinic", "name": "Department of Chest Diseases", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 5, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'f455e22210a3a6f7ba0dbaa5ff95130722ffba95bda6eaacb384f2078c0ee06c', '85310685af4aa8729406fb41a0a727a0ee1ce5dea15eae9d27f6fee3ec729c1b', 1),
	(14, 28, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 6, '{"code": "TROP-MED", "kind": "clinic", "name": "Department of Tropical Medicine", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 6, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '85310685af4aa8729406fb41a0a727a0ee1ce5dea15eae9d27f6fee3ec729c1b', 'da2e250a602cfd5a0326eb4f183b386b6e062ec7f1f5d75ecd49061e99d78a5a', 1),
	(15, 30, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 7, '{"code": "DERM-VEN", "kind": "clinic", "name": "Department of Dermatology, Venereology and Andrology", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 7, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'da2e250a602cfd5a0326eb4f183b386b6e062ec7f1f5d75ecd49061e99d78a5a', '2fc3cb01af94db9f97f7de0561b411bd26cd5a3c5123d25ff3685bdc86922e8d', 1),
	(16, 32, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 8, '{"code": "GERI", "kind": "clinic", "name": "Department of Geriatrics and Gerontology", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 8, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '2fc3cb01af94db9f97f7de0561b411bd26cd5a3c5123d25ff3685bdc86922e8d', '12fad31ad71b648c31b2b21ccd3a49a9ea80c479ffa688f86c03e8537eee6302', 1),
	(17, 34, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 9, '{"code": "FMED", "kind": "clinic", "name": "Department of Family Medicine", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 9, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '12fad31ad71b648c31b2b21ccd3a49a9ea80c479ffa688f86c03e8537eee6302', '4397a96fc8675cdb0c17b6962eaae9196db6905ab7174ab3ca30c9cc6341ea9c', 1),
	(18, 36, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 10, '{"code": "GENET", "kind": "clinic", "name": "Department of Medical Genetics", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 10, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '4397a96fc8675cdb0c17b6962eaae9196db6905ab7174ab3ca30c9cc6341ea9c', '2a2bb4a70ae69e745725964d2db6cce213656d67e7476772cde8ffb8d53c3f72', 1),
	(19, 38, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 11, '{"code": "CLIN-PATH", "kind": "lab", "name": "Department of Clinical Pathology", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 11, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '2a2bb4a70ae69e745725964d2db6cce213656d67e7476772cde8ffb8d53c3f72', '354f579d1ca642be0adaf1e95a726f9a8e2d297c6784b8585719699661c1e729', 1),
	(20, 40, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 12, '{"code": "ONC-NM", "kind": "radiology", "name": "Department of Clinical Oncology and Nuclear Medicine", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 12, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '354f579d1ca642be0adaf1e95a726f9a8e2d297c6784b8585719699661c1e729', 'eca0d9965e0fbb63528f941aab6c80705ff40e2c4148684f2fdb76bb63f1370d', 1),
	(21, 42, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 13, '{"code": "RAD-DX", "kind": "radiology", "name": "Department of Diagnostic Radiology", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 13, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'eca0d9965e0fbb63528f941aab6c80705ff40e2c4148684f2fdb76bb63f1370d', 'ae070c3136aaa310a94344ea4aefd271cb4f6d79c26fad8d2fddbd581a12cdd3', 1),
	(22, 44, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 14, '{"code": "SURG-GEN", "kind": "surgical", "name": "Department of General Surgery", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 14, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'ae070c3136aaa310a94344ea4aefd271cb4f6d79c26fad8d2fddbd581a12cdd3', '981178f47a265c5be69242006289cf851c3fb770e9fa05e172e96ee4b2843e37', 1),
	(23, 46, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 15, '{"code": "SURG-CT", "kind": "surgical", "name": "Department of Cardio-Thoracic Surgery", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 15, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '981178f47a265c5be69242006289cf851c3fb770e9fa05e172e96ee4b2843e37', '160f5209113a60754fb861246a64dc77ecbe945e6c5c152973ad3cb2ad35f0e1', 1),
	(24, 48, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 16, '{"code": "SURG-URO", "kind": "surgical", "name": "Department of Urology", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 16, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '160f5209113a60754fb861246a64dc77ecbe945e6c5c152973ad3cb2ad35f0e1', 'cf4bb395af88ee7bc50779323a46a00f1a6008643f86c929264027c145cd87d8', 1),
	(25, 50, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 17, '{"code": "SURG-PLAS", "kind": "surgical", "name": "Department of Plastic Burn and Maxillofacial Surgery", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 17, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'cf4bb395af88ee7bc50779323a46a00f1a6008643f86c929264027c145cd87d8', '6b17fb0f4d2d554604a2393afcd33e7a24cc5a4c6649f82382cebb19741ba87e', 1),
	(26, 52, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 18, '{"code": "SURG-PED", "kind": "surgical", "name": "Department of Pediatric Surgery", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 18, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '6b17fb0f4d2d554604a2393afcd33e7a24cc5a4c6649f82382cebb19741ba87e', '076a4838858bdcf8bb2bd94f18a5bb0e46b368829e5e99e61c7fe3e0bfde639a', 1),
	(27, 54, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 19, '{"code": "SURG-VASC", "kind": "surgical", "name": "Department of Vascular Surgery", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 19, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '076a4838858bdcf8bb2bd94f18a5bb0e46b368829e5e99e61c7fe3e0bfde639a', 'bce1ebb61d25aced3ccc4a9f9ac13f0e1923e25ff1e53e4314ca23253d78073a', 1),
	(28, 56, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 20, '{"code": "OPHTH", "kind": "clinic", "name": "Department of Ophthalmology and Ophthalmic Surgery", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 20, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'bce1ebb61d25aced3ccc4a9f9ac13f0e1923e25ff1e53e4314ca23253d78073a', '3cf20387f955b8c0a3799e31a852e192a73db58347fda8d9155d34d327e28921', 1),
	(29, 58, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 21, '{"code": "OBS-GYN", "kind": "clinic", "name": "Department of Obstetrics and Gynecology", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 21, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '3cf20387f955b8c0a3799e31a852e192a73db58347fda8d9155d34d327e28921', '479ef75e63bebb6529764ea90ba59d7609bdd3efff6c0429223afad1ca020200', 1),
	(30, 60, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 22, '{"code": "ANES-ICU", "kind": "icu", "name": "Department of Anesthesiology, Intensive Care and Pain Management", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 22, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '479ef75e63bebb6529764ea90ba59d7609bdd3efff6c0429223afad1ca020200', '6fee729fa31d24856fe7bd0fc99cc81602383711a4d4d98cdf9dbe4952d641f9', 1),
	(31, 62, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 23, '{"code": "EMED", "kind": "emergency", "name": "Department of Emergency Medicine", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 23, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '6fee729fa31d24856fe7bd0fc99cc81602383711a4d4d98cdf9dbe4952d641f9', '6fd03e686020cd42e12389ae8f06fa9bdc3970f4f03a2d4ebd8eca4ad350d201', 1),
	(32, 64, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 24, '{"code": "PHY-REHAB", "kind": "physio", "name": "Department of Rheumatology, Rehabilitation and Physical Medicine", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 24, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '6fd03e686020cd42e12389ae8f06fa9bdc3970f4f03a2d4ebd8eca4ad350d201', 'bcc987307bab42c165cd221b7bd1ba7d1b4be12ee96f548af0bed387dbb82da4', 1),
	(33, 66, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 25, '{"code": "PROSTH", "kind": "physio", "name": "Department of Prosthetics", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 25, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'bcc987307bab42c165cd221b7bd1ba7d1b4be12ee96f548af0bed387dbb82da4', '2a6085fedbbe22ce56377c488f612a154c1b24f0f81f093d916931b3839fc1d8', 1),
	(34, 68, '2026-07-18 21:59:07.643886+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 26, '{"code": "IND-INST", "kind": "administration", "name": "Department of Industrial Installations", "is_active": true, "created_at": "2026-07-18T21:59:07.643886+03:00", "updated_at": "2026-07-18T21:59:07.643886+03:00", "facility_id": 1, "head_user_id": null, "department_id": 26, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '2a6085fedbbe22ce56377c488f612a154c1b24f0f81f093d916931b3839fc1d8', '40b5d54b83cbbb6014da1e428e966a13649936662429eab5702249555635fab4', 1),
	(35, 70, '2026-07-18 21:59:08.344403+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 3, '{"code": "vital_records.read", "description": "View birth/death certificates", "facility_id": 1, "permission_id": 3}', 'db-trigger', '40b5d54b83cbbb6014da1e428e966a13649936662429eab5702249555635fab4', 'ba987212c7c7aceaa8184100fe3d882167cb6d7d063d9979f1190b6ad74b52c6', 1),
	(36, 72, '2026-07-18 21:59:08.344403+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 4, '{"code": "vital_records.register", "description": "Register (issue) birth/death certificates", "facility_id": 1, "permission_id": 4}', 'db-trigger', 'ba987212c7c7aceaa8184100fe3d882167cb6d7d063d9979f1190b6ad74b52c6', 'af0f96994e316a33e369d4a4886b6b1a5dc375611851f068cf502ae295421e0c', 1),
	(37, 74, '2026-07-18 21:59:08.344403+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 5, '{"code": "vital_records.certify", "description": "Certify cause of death / clinical attestation", "facility_id": 1, "permission_id": 5}', 'db-trigger', 'af0f96994e316a33e369d4a4886b6b1a5dc375611851f068cf502ae295421e0c', 'b4c4a60dbf04632b74195aa08df0cd02a7144266dbae1faa3262af1be97469e0', 1),
	(38, 76, '2026-07-18 21:59:08.344403+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 1, '{"role_id": 1, "facility_id": 1, "permission_id": 3}', 'db-trigger', 'b4c4a60dbf04632b74195aa08df0cd02a7144266dbae1faa3262af1be97469e0', '3b69a8bb5fc095fde2e3dd27c67d60e2359518a083704790625ed761db38a98c', 1),
	(39, 78, '2026-07-18 21:59:08.361814+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 6, '{"code": "waste.read", "description": "View medical waste records, quantities and costs", "facility_id": 1, "permission_id": 6}', 'db-trigger', '3b69a8bb5fc095fde2e3dd27c67d60e2359518a083704790625ed761db38a98c', 'bc9fd91d9330726346053165c6b3fece2ae79a0dea4eeafcb3933d8a3f34e819', 1),
	(40, 80, '2026-07-18 21:59:08.361814+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 7, '{"code": "waste.manage", "description": "Create/edit medical waste records and disposal manifests", "facility_id": 1, "permission_id": 7}', 'db-trigger', 'bc9fd91d9330726346053165c6b3fece2ae79a0dea4eeafcb3933d8a3f34e819', '1cf1c85b842bce53df921099c1e077b8c127431a2c9a673a32613cb1b41b76ac', 1),
	(41, 82, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 27, '{"code": "CLIN-GEN", "kind": "clinic", "name": "General Outpatient Clinic", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 27, "location_floor": 1, "location_building": "Main", "parent_department_id": null}', 'db-trigger', '1cf1c85b842bce53df921099c1e077b8c127431a2c9a673a32613cb1b41b76ac', '6b7047910479a8ab5bbc0d9838f3af5aa43345c562e02a795356ff528826cca3', 1),
	(42, 84, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 28, '{"code": "CLIN-CARD", "kind": "clinic", "name": "Cardiology Clinic", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 28, "location_floor": 2, "location_building": "Main", "parent_department_id": null}', 'db-trigger', '6b7047910479a8ab5bbc0d9838f3af5aa43345c562e02a795356ff528826cca3', 'e3a446d4f0b1327da897640f63c6b9f30fd331f125f15f84f69c3639614b1b8a', 1),
	(43, 86, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 29, '{"code": "CLIN-ORTH", "kind": "clinic", "name": "Orthopaedics Clinic", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 29, "location_floor": 2, "location_building": "Main", "parent_department_id": null}', 'db-trigger', 'e3a446d4f0b1327da897640f63c6b9f30fd331f125f15f84f69c3639614b1b8a', 'c96252fe6e4ad4e19465dc4642d1c07cf9917fe565ae845e986be893e3e944b8', 1),
	(44, 88, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 30, '{"code": "CLIN-OBS", "kind": "clinic", "name": "Obstetrics & Gynaecology", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 30, "location_floor": 3, "location_building": "Women", "parent_department_id": null}', 'db-trigger', 'c96252fe6e4ad4e19465dc4642d1c07cf9917fe565ae845e986be893e3e944b8', '69556e86aa054eb1a91b514c5e21ee9a9cfe16c1740e3d3a9a130bcd59f026e7', 1),
	(45, 90, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 31, '{"code": "CLIN-PAED", "kind": "clinic", "name": "Paediatrics Clinic", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 31, "location_floor": 2, "location_building": "Children", "parent_department_id": null}', 'db-trigger', '69556e86aa054eb1a91b514c5e21ee9a9cfe16c1740e3d3a9a130bcd59f026e7', '17c55bf00290eeddb2aec69572d9597dfda6d1b3f2c39923d0e1c5083c534fa3', 1),
	(46, 92, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 32, '{"code": "CLIN-ENT", "kind": "clinic", "name": "Otolaryngology (ENT)", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 32, "location_floor": 1, "location_building": "Specialty", "parent_department_id": null}', 'db-trigger', '17c55bf00290eeddb2aec69572d9597dfda6d1b3f2c39923d0e1c5083c534fa3', 'abea4ead4084ffb7f95159b33600ca26484d78a0df1ab762392cfc8a4f8e58d5', 1),
	(47, 94, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 33, '{"code": "OR-GEN", "kind": "surgical", "name": "General Operating Theatre", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 33, "location_floor": 1, "location_building": "Surgical Suite", "parent_department_id": null}', 'db-trigger', 'abea4ead4084ffb7f95159b33600ca26484d78a0df1ab762392cfc8a4f8e58d5', '37847f2a2bf2a6b6e68135f0ca54ea347bf80725d54b72a613c6809dd55d8153', 1),
	(48, 96, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 34, '{"code": "OR-CARD", "kind": "surgical", "name": "Cardiac Surgery Theatre", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 34, "location_floor": 2, "location_building": "Surgical Suite", "parent_department_id": null}', 'db-trigger', '37847f2a2bf2a6b6e68135f0ca54ea347bf80725d54b72a613c6809dd55d8153', 'c47f465497ddc665cda15015bd408e8bf2b6e8e4fc63ccff138977b28f4bfe38', 1),
	(49, 98, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 35, '{"code": "OR-ORTHO", "kind": "surgical", "name": "Orthopaedic Surgery Theatre", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 35, "location_floor": 1, "location_building": "Surgical Suite", "parent_department_id": null}', 'db-trigger', 'c47f465497ddc665cda15015bd408e8bf2b6e8e4fc63ccff138977b28f4bfe38', 'a952a305b4847db4c7218fa7579c324f492494486571f32d88fe2b7b10ff2c25', 1),
	(50, 100, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 36, '{"code": "OR-NEURO", "kind": "surgical", "name": "Neurosurgery Theatre", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 36, "location_floor": 2, "location_building": "Surgical Suite", "parent_department_id": null}', 'db-trigger', 'a952a305b4847db4c7218fa7579c324f492494486571f32d88fe2b7b10ff2c25', '307bd55ec99b5c1fd9f395d6fbfc7a957bd5143ff4f5b3350b09a3668b274c63', 1),
	(51, 102, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 37, '{"code": "ED-MAIN", "kind": "emergency", "name": "Emergency Department", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 37, "location_floor": 1, "location_building": "Main", "parent_department_id": null}', 'db-trigger', '307bd55ec99b5c1fd9f395d6fbfc7a957bd5143ff4f5b3350b09a3668b274c63', '38470c1e49e1d6c170720a6bf8186c03dc212e5b89be29c4b288d53b267429fd', 1),
	(52, 104, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 38, '{"code": "ED-TRIAGE", "kind": "emergency", "name": "Triage Area", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 38, "location_floor": 1, "location_building": "Main", "parent_department_id": null}', 'db-trigger', '38470c1e49e1d6c170720a6bf8186c03dc212e5b89be29c4b288d53b267429fd', 'ee9ddb4794ab8937ee084592c913944e103d432f77ecca58bc44eb64bed65d1a', 1),
	(53, 106, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 39, '{"code": "ICU-GEN", "kind": "icu", "name": "General ICU", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 39, "location_floor": 3, "location_building": "Critical Care", "parent_department_id": null}', 'db-trigger', 'ee9ddb4794ab8937ee084592c913944e103d432f77ecca58bc44eb64bed65d1a', 'b2832e356ecf88fe3e42d4e8a77cfcf1997794eb9ce7a933888a1a490c134f5d', 1),
	(54, 108, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 40, '{"code": "ICU-CCU", "kind": "icu", "name": "Coronary Care Unit", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 40, "location_floor": 3, "location_building": "Critical Care", "parent_department_id": null}', 'db-trigger', 'b2832e356ecf88fe3e42d4e8a77cfcf1997794eb9ce7a933888a1a490c134f5d', '8d5c87bc4133996b83d43d27770293b3c0a4aab81c36f942bb686187a83408c7', 1),
	(55, 110, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 41, '{"code": "ICU-NICU", "kind": "icu", "name": "Neonatal ICU", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 41, "location_floor": 2, "location_building": "Paediatrics", "parent_department_id": null}', 'db-trigger', '8d5c87bc4133996b83d43d27770293b3c0a4aab81c36f942bb686187a83408c7', '541887e8ded4d85102c41eed5a2b0eb2057f250ae72616e14ed231f68b1b0234', 1),
	(56, 112, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 42, '{"code": "LAB-CLIN", "kind": "lab", "name": "Clinical Laboratory", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 42, "location_floor": -1, "location_building": "Service Block", "parent_department_id": null}', 'db-trigger', '541887e8ded4d85102c41eed5a2b0eb2057f250ae72616e14ed231f68b1b0234', '6775d2e37a1b172b125363450e857060df5634cdd12f7b26702aa47cd578eabc', 1),
	(57, 114, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 43, '{"code": "LAB-PATH", "kind": "lab", "name": "Pathology Lab", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 43, "location_floor": -1, "location_building": "Service Block", "parent_department_id": null}', 'db-trigger', '6775d2e37a1b172b125363450e857060df5634cdd12f7b26702aa47cd578eabc', '0e41ff8b841a75701ce7dffc6c98ebefe1ceac4b4213998eb52cb461877cbbea', 1),
	(58, 116, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 44, '{"code": "RAD-MAIN", "kind": "radiology", "name": "Radiology / Imaging", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 44, "location_floor": -1, "location_building": "Service Block", "parent_department_id": null}', 'db-trigger', '0e41ff8b841a75701ce7dffc6c98ebefe1ceac4b4213998eb52cb461877cbbea', '2266ceb816e3a552627c4b86b89eef5dae703462801b5af149b61b8149de5ad5', 1),
	(59, 118, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 45, '{"code": "RX-MAIN", "kind": "pharmacy", "name": "Inpatient Pharmacy", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 45, "location_floor": 0, "location_building": "Service Block", "parent_department_id": null}', 'db-trigger', '2266ceb816e3a552627c4b86b89eef5dae703462801b5af149b61b8149de5ad5', 'cb332b5d8630fa571c67e09e85c5a840b4b79793cd5699f8cd39a027fe4be9ab', 1),
	(60, 120, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 46, '{"code": "RX-OUT", "kind": "pharmacy", "name": "Outpatient Pharmacy", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 46, "location_floor": 1, "location_building": "Main", "parent_department_id": null}', 'db-trigger', 'cb332b5d8630fa571c67e09e85c5a840b4b79793cd5699f8cd39a027fe4be9ab', '3ad7efce67032b31e941bca8ed77b865ef66c4b4d11905e18bf0cc68ccbfd751', 1),
	(61, 122, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 47, '{"code": "PHY-MAIN", "kind": "physio", "name": "Physiotherapy Unit", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 47, "location_floor": 1, "location_building": "Rehab", "parent_department_id": null}', 'db-trigger', '3ad7efce67032b31e941bca8ed77b865ef66c4b4d11905e18bf0cc68ccbfd751', '696a5745564b437bb6ff260938512ce5228a814b8cce287293b044a6b7e327eb', 1),
	(62, 124, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 48, '{"code": "BILL-M", "kind": "billing", "name": "Billing Office", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 48, "location_floor": 0, "location_building": "Administration", "parent_department_id": null}', 'db-trigger', '696a5745564b437bb6ff260938512ce5228a814b8cce287293b044a6b7e327eb', '56e2b2fcc1e6741fe8431c22f77053e287512b0f2ff9535c06cf02e0aa7790dd', 1),
	(63, 126, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 49, '{"code": "HR-M", "kind": "hr", "name": "Human Resources", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 49, "location_floor": 0, "location_building": "Administration", "parent_department_id": null}', 'db-trigger', '56e2b2fcc1e6741fe8431c22f77053e287512b0f2ff9535c06cf02e0aa7790dd', '031a535a788238998af6da872221963daef8e779ec8fde60e03381c0e8681711', 1),
	(64, 128, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 50, '{"code": "ADMIN", "kind": "administration", "name": "Administration", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "head_user_id": null, "department_id": 50, "location_floor": 0, "location_building": "Administration", "parent_department_id": null}', 'db-trigger', '031a535a788238998af6da872221963daef8e779ec8fde60e03381c0e8681711', '1306d7b9f1e0426d348ab0c4045d750466e5fb884c18f164cce77e4fa3dbad1e', 1),
	(65, 130, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 2, '{"code": "J00", "label": "Acute nasopharyngitis [common cold]", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 2, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '1306d7b9f1e0426d348ab0c4045d750466e5fb884c18f164cce77e4fa3dbad1e', '4793611f2a748e95afccd08c2db14af238c88146e4172f0882ce3bda0b984b82', 1),
	(66, 132, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 3, '{"code": "J20.9", "label": "Acute bronchitis, unspecified", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 3, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '4793611f2a748e95afccd08c2db14af238c88146e4172f0882ce3bda0b984b82', '9910b16d3f780118bf9825744d1e9af6eab23318bd09e4ebfec511a18a8bed3a', 1),
	(67, 134, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 4, '{"code": "E11.9", "label": "Type 2 diabetes mellitus without complications", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 4, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '9910b16d3f780118bf9825744d1e9af6eab23318bd09e4ebfec511a18a8bed3a', '4dc694867b91c3b24bba1d17e1ef0d1af4700181eafa6076d7ba1d7eeb1c2865', 1),
	(68, 136, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 5, '{"code": "I10", "label": "Essential (primary) hypertension", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 5, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '4dc694867b91c3b24bba1d17e1ef0d1af4700181eafa6076d7ba1d7eeb1c2865', 'b946338d7a69ab2893a74c184102658aacdbc509344a1772e2705f10fd0f5736', 1),
	(69, 138, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 6, '{"code": "E78.5", "label": "Hypercholesterolaemia, unspecified", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 6, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'b946338d7a69ab2893a74c184102658aacdbc509344a1772e2705f10fd0f5736', 'be9dfc5bbe76939354fec7c7f9a9ec82de8bcf8c668bbf3df5586b7c7105a431', 1),
	(70, 140, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 7, '{"code": "M54.5", "label": "Low back pain", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 7, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'be9dfc5bbe76939354fec7c7f9a9ec82de8bcf8c668bbf3df5586b7c7105a431', '7ad1ab8639291c7cbf378973a3294068becc4d045b400d0c94dba0aba68493ab', 1),
	(71, 142, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 8, '{"code": "K21.9", "label": "Gastro-oesophageal reflux disease without oesophagitis", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 8, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '7ad1ab8639291c7cbf378973a3294068becc4d045b400d0c94dba0aba68493ab', 'c159af6f8e01fb396fa837338ae3796d4661cbaa0e645f64db70a0a9fb567220', 1),
	(72, 144, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 9, '{"code": "N39.0", "label": "Urinary tract infection, site not specified", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 9, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'c159af6f8e01fb396fa837338ae3796d4661cbaa0e645f64db70a0a9fb567220', '6e3388ec7020a4a093f66d18c4230befe02371538e1ae07c19859d103e05b0d1', 1),
	(73, 146, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 10, '{"code": "R51", "label": "Headache", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 10, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '6e3388ec7020a4a093f66d18c4230befe02371538e1ae07c19859d103e05b0d1', '504e1e4cfef1f50f934775ce229cac442ab5500c270995ab4e802419cafb702d', 1),
	(74, 148, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 11, '{"code": "S82.8", "label": "Fracture of other specified parts of lower leg", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 11, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '504e1e4cfef1f50f934775ce229cac442ab5500c270995ab4e802419cafb702d', 'a25d5f9990eda257971cf3543eed31b023eeb5a9ee696b0b7ca2503ab75b983e', 1),
	(75, 150, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 12, '{"code": "I21.9", "label": "Acute myocardial infarction, unspecified", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 12, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'a25d5f9990eda257971cf3543eed31b023eeb5a9ee696b0b7ca2503ab75b983e', 'ad9ee8fed4b4b97706d33d3c8ddf119be38567ff017dd7902396267ad6b21322', 1),
	(77, 154, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 14, '{"code": "C50.9", "label": "Malignant neoplasm of breast of unspecified site, female", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 14, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '00a27da2d6e30d8fcf94406ca488f36c4697f1fa384351573b741580a85fdc28', 'fc19459acca97847158d1a3ea1098f566532c61e73cad1cb53a1c1522a6149e4', 1),
	(78, 156, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 15, '{"code": "K80.20", "label": "Calculus of gallbladder without cholecystitis", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 15, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'fc19459acca97847158d1a3ea1098f566532c61e73cad1cb53a1c1522a6149e4', 'a8cd4b6eca3ee7b03e4898dd4dd456198719d5628484c1afc463bf5fe9fcf6c1', 1),
	(79, 158, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 16, '{"code": "A09", "label": "Diarrhoea and gastroenteritis of infectious origin", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 16, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'a8cd4b6eca3ee7b03e4898dd4dd456198719d5628484c1afc463bf5fe9fcf6c1', 'f5d0a94c2991d8c760c619bbb82f7c8b0bed7ca16cb803003696da51f36797a2', 1),
	(80, 160, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 17, '{"code": "O80", "label": "Encounter for full-term uncomplicated delivery", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 17, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'f5d0a94c2991d8c760c619bbb82f7c8b0bed7ca16cb803003696da51f36797a2', '64be42d7f3c23c366101c9a82ccdf2ea7cd03270c3bb597b5beabc9c060b7c91', 1),
	(81, 162, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 18, '{"code": "O34.21", "label": "Maternal care for congenital uterine malformation", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 18, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '64be42d7f3c23c366101c9a82ccdf2ea7cd03270c3bb597b5beabc9c060b7c91', '99f8ad6500fa12e2dc3360b3880927b28a1c51fefbcce047a45c9cd713356df7', 1),
	(82, 164, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 19, '{"code": "S06.0", "label": "Intracranial injury (concussion of brain)", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 19, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '99f8ad6500fa12e2dc3360b3880927b28a1c51fefbcce047a45c9cd713356df7', '4f03afe73fc3c987e13048376f6f9460e76e471f011179b879be1e796ea298f7', 1),
	(83, 166, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 20, '{"code": "S72.0", "label": "Fracture of neck of femur", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 20, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '4f03afe73fc3c987e13048376f6f9460e76e471f011179b879be1e796ea298f7', '352625232e77156571b85740b52340dcf7a5d55d75155c07fbb2141e414b444b', 1),
	(84, 168, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 21, '{"code": "S02.5", "label": "Fracture of tooth (traumatic)", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 21, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '352625232e77156571b85740b52340dcf7a5d55d75155c07fbb2141e414b444b', '6c66b6e76a579f43075091edd11e9bbbde6b7f628a4981ba5491745aa00c36f9', 1),
	(85, 170, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 22, '{"code": "99213", "label": "Office Visit, Established Patient, Low Complexity", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 22, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '6c66b6e76a579f43075091edd11e9bbbde6b7f628a4981ba5491745aa00c36f9', '7480267de7020c70e3fdf3af8838d507032167eda955b370addfc2c5b44aae2e', 1),
	(86, 172, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 23, '{"code": "99214", "label": "Office Visit, Established Patient, Moderate", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 23, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '7480267de7020c70e3fdf3af8838d507032167eda955b370addfc2c5b44aae2e', 'f589b099909ff2dcda16beb4fcc293e3a72432cbd619e8d68198042a7245d198', 1),
	(87, 174, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 24, '{"code": "99204", "label": "Office Visit, New Patient, Moderate", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 24, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'f589b099909ff2dcda16beb4fcc293e3a72432cbd619e8d68198042a7245d198', 'f23f85716a4101c18a5b15dc5fb68b52b20eb5f2cebfa637e316a711b9a459e1', 1),
	(88, 176, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 25, '{"code": "58150", "label": "Total abdominal hysterectomy", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 25, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'f23f85716a4101c18a5b15dc5fb68b52b20eb5f2cebfa637e316a711b9a459e1', '175034fee18c0d9036b261755e5cdb8cd26d141d15942e7a92c61353eb5de420', 1),
	(89, 178, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 26, '{"code": "23470", "label": "Arthroplasty, glenohumeral joint", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 26, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '175034fee18c0d9036b261755e5cdb8cd26d141d15942e7a92c61353eb5de420', 'e0839e20d34713d86ad0a227e08379820f7684c1572d3b9f99bc5bef10e798d8', 1),
	(90, 180, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 27, '{"code": "27130", "label": "Total hip arthroplasty", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 27, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'e0839e20d34713d86ad0a227e08379820f7684c1572d3b9f99bc5bef10e798d8', '293f1b79951875fcb9c883b253630e27fd52a87210766785190ebf6f2c40c76d', 1),
	(91, 182, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 28, '{"code": "27447", "label": "Total knee arthroplasty", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 28, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '293f1b79951875fcb9c883b253630e27fd52a87210766785190ebf6f2c40c76d', 'cb384bd48cd23109a4280d3f0ab88e4c2738df651157f9b00d7a567565864c2f', 1),
	(92, 184, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 29, '{"code": "49505", "label": "Repair of femoral hernia", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 29, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'cb384bd48cd23109a4280d3f0ab88e4c2738df651157f9b00d7a567565864c2f', 'c75694a8f71e3aa0e1ea5078fcdc513f17f41f5b53ec992032de99ae1e7c6bcc', 1),
	(93, 186, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 30, '{"code": "47579", "label": "Open cholecystectomy", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 30, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'c75694a8f71e3aa0e1ea5078fcdc513f17f41f5b53ec992032de99ae1e7c6bcc', '9a476e9b9005b6a1055f0d6de587e98c776ea25abe1f8b2c71c54e2e282a2252', 1),
	(94, 188, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 31, '{"code": "33533", "label": "Coronary artery bypass, single", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 31, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '9a476e9b9005b6a1055f0d6de587e98c776ea25abe1f8b2c71c54e2e282a2252', '2ade13291f38ab5cb1e45a729c686b3c0187df54ed151b06d3e8461019ea0a3d', 1),
	(95, 190, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 32, '{"code": "80053", "label": "Comprehensive Metabolic Panel", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 32, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '2ade13291f38ab5cb1e45a729c686b3c0187df54ed151b06d3e8461019ea0a3d', 'c5a223122e3a69183eb8886814435d95e3be2e8d7e69faab4889c5c2bc19f884', 1),
	(96, 192, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 33, '{"code": "80048", "label": "Basic Metabolic Panel", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 33, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'c5a223122e3a69183eb8886814435d95e3be2e8d7e69faab4889c5c2bc19f884', '759a1be087dd0d5b64c2a51652eb58302d1e9bc2ec3060263a50786c0beb6d21', 1),
	(97, 194, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 34, '{"code": "85025", "label": "CBC w/ differential", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 34, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '759a1be087dd0d5b64c2a51652eb58302d1e9bc2ec3060263a50786c0beb6d21', '87949b8759ac9f217e9a903b442586285fdd74955a377d435d08b9bd97cdd217', 1),
	(98, 196, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 35, '{"code": "81002", "label": "Urinalysis, non-automated", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 35, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '87949b8759ac9f217e9a903b442586285fdd74955a377d435d08b9bd97cdd217', '5281eff3026d34c318280efb9e4fb1dd465034c89c54bf90a5c80587fa4be28c', 1),
	(99, 198, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 36, '{"code": "71045", "label": "X-ray chest, complete view", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 36, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '5281eff3026d34c318280efb9e4fb1dd465034c89c54bf90a5c80587fa4be28c', '62d2dbc50d2e3e063e8fbf459831a0b268b7d8a6eda07e369e8d0ab1c4479209', 1),
	(100, 200, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 37, '{"code": "71250", "label": "CT thorax without contrast", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 37, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '62d2dbc50d2e3e063e8fbf459831a0b268b7d8a6eda07e369e8d0ab1c4479209', 'd73450a7ae7d4f7a40bbe79b8990ccd1ad568b6f58a9c269445fbc9e3a957431', 1),
	(101, 202, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 38, '{"code": "70553", "label": "MRI brain with contrast", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 38, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'd73450a7ae7d4f7a40bbe79b8990ccd1ad568b6f58a9c269445fbc9e3a957431', 'f08b75966949635a10d086835866420162642b624596508ea9cdfe1d24735a9e', 1),
	(102, 204, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 39, '{"code": "76700", "label": "Ultrasound abdomen", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 39, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'f08b75966949635a10d086835866420162642b624596508ea9cdfe1d24735a9e', 'bc7cc49422fc25254863a2dffba4d845a0cb40b54f17f72b8c2618108c82c6ce', 1),
	(103, 206, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 40, '{"code": "93000", "label": "ECG, 12-lead", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 40, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'bc7cc49422fc25254863a2dffba4d845a0cb40b54f17f72b8c2618108c82c6ce', 'a37bd2a239fca87343b5b73de29fec8bd606663a21bc51cf5c26ac1fb5921975', 1),
	(104, 208, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 2, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "500 mg", "is_active": true, "brand_name": "Panadol", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "analgesic", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 5000, "rxnorm_code": null, "drug_item_id": 2, "generic_name": "Paracetamol", "manufacturer": null, "cost_per_unit": 0.05, "reorder_level": 1000, "requires_cold_chain": false, "sale_price_per_unit": 0.15, "controlled_substance": false}', 'db-trigger', 'a37bd2a239fca87343b5b73de29fec8bd606663a21bc51cf5c26ac1fb5921975', 'b67f43432619b94dca1dc50f254360d7080ff799cb9cacfa44a685b3c51b9dad', 1),
	(105, 210, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 3, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "400 mg", "is_active": true, "brand_name": "Brufen", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "nsaid", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 3000, "rxnorm_code": null, "drug_item_id": 3, "generic_name": "Ibuprofen", "manufacturer": null, "cost_per_unit": 0.08, "reorder_level": 500, "requires_cold_chain": false, "sale_price_per_unit": 0.20, "controlled_substance": false}', 'db-trigger', 'b67f43432619b94dca1dc50f254360d7080ff799cb9cacfa44a685b3c51b9dad', '95986d17d2c9be7e733bbc7e51e1790f37c4f4df5d02c4ade7def0290a881db0', 1),
	(106, 212, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 4, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "75 mg", "is_active": true, "brand_name": "Aspec", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "cardiac", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 1000, "rxnorm_code": null, "drug_item_id": 4, "generic_name": "Acetylsalicylic acid", "manufacturer": null, "cost_per_unit": 0.03, "reorder_level": 200, "requires_cold_chain": false, "sale_price_per_unit": 0.10, "controlled_substance": false}', 'db-trigger', '95986d17d2c9be7e733bbc7e51e1790f37c4f4df5d02c4ade7def0290a881db0', '71681d505d3bbeb5e9cbfc017fa707c040e738a12144dc09551bdda9f39ab3b1', 1),
	(185, 370, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 2, '{"ppi_id": 2, "test_id": 2, "panel_id": 2, "sort_order": 1, "facility_id": 1}', 'db-trigger', '047cd8bc0f2b2ffc12abad5c9952be0bfab1baae3122a762ac7cdee223a72292', 'aebc5c1ca6cdf5d4fd82f394ef75b4d3785d862e4aa62b2ea843220bd37fda10', 1),
	(107, 214, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 5, '{"form": "capsule", "unit": "capsule", "atc_code": null, "strength": "500 mg", "is_active": true, "brand_name": "Amoxil", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "antibiotic", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 2000, "rxnorm_code": null, "drug_item_id": 5, "generic_name": "Amoxicillin", "manufacturer": null, "cost_per_unit": 0.10, "reorder_level": 300, "requires_cold_chain": false, "sale_price_per_unit": 0.30, "controlled_substance": false}', 'db-trigger', '71681d505d3bbeb5e9cbfc017fa707c040e738a12144dc09551bdda9f39ab3b1', '380ec1f264192165c81c4b2cfd19687699eb8a2c6717c293e5246603646ddde8', 1),
	(108, 216, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 6, '{"form": "capsule", "unit": "capsule", "atc_code": null, "strength": "500 mg", "is_active": true, "brand_name": "Keflex", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "antibiotic", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 2000, "rxnorm_code": null, "drug_item_id": 6, "generic_name": "Cephalexin", "manufacturer": null, "cost_per_unit": 0.15, "reorder_level": 300, "requires_cold_chain": false, "sale_price_per_unit": 0.40, "controlled_substance": false}', 'db-trigger', '380ec1f264192165c81c4b2cfd19687699eb8a2c6717c293e5246603646ddde8', 'd77e64a4775cefb54061f7afa7e23945c502ec0d675c10bd7940ad2dbba7ba18', 1),
	(109, 218, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 7, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "850 mg", "is_active": true, "brand_name": "Glucophage", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "antidiabetic", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 2500, "rxnorm_code": null, "drug_item_id": 7, "generic_name": "Metformin", "manufacturer": null, "cost_per_unit": 0.06, "reorder_level": 400, "requires_cold_chain": false, "sale_price_per_unit": 0.20, "controlled_substance": false}', 'db-trigger', 'd77e64a4775cefb54061f7afa7e23945c502ec0d675c10bd7940ad2dbba7ba18', 'e9396b1bf359579dff561488817b5da3f4599e8ae57a6633f9e62ff7ae753b7e', 1),
	(110, 220, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 8, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "20 mg", "is_active": true, "brand_name": "Lipitor", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "cardiac", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 2500, "rxnorm_code": null, "drug_item_id": 8, "generic_name": "Atorvastatin", "manufacturer": null, "cost_per_unit": 0.20, "reorder_level": 400, "requires_cold_chain": false, "sale_price_per_unit": 0.55, "controlled_substance": false}', 'db-trigger', 'e9396b1bf359579dff561488817b5da3f4599e8ae57a6633f9e62ff7ae753b7e', 'e6af5ea94fbc0a639c3e4213259cac0ba1daa4a317c3438ae8277fa3c9d6f8d2', 1),
	(111, 222, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 9, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "10 mg", "is_active": true, "brand_name": "Norvasc", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "antihypertensive", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 2500, "rxnorm_code": null, "drug_item_id": 9, "generic_name": "Amlodipine", "manufacturer": null, "cost_per_unit": 0.10, "reorder_level": 400, "requires_cold_chain": false, "sale_price_per_unit": 0.30, "controlled_substance": false}', 'db-trigger', 'e6af5ea94fbc0a639c3e4213259cac0ba1daa4a317c3438ae8277fa3c9d6f8d2', '4b78df43bbe408dea33d1272e68bd9bb02957317957c9719a447bbcc54400aaa', 1),
	(112, 224, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 10, '{"form": "capsule", "unit": "capsule", "atc_code": null, "strength": "20 mg", "is_active": true, "brand_name": "Prilosec", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "gi", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 3000, "rxnorm_code": null, "drug_item_id": 10, "generic_name": "Omeprazole", "manufacturer": null, "cost_per_unit": 0.10, "reorder_level": 500, "requires_cold_chain": false, "sale_price_per_unit": 0.35, "controlled_substance": false}', 'db-trigger', '4b78df43bbe408dea33d1272e68bd9bb02957317957c9719a447bbcc54400aaa', '9feb3f47de956a421e1c00357f6e8c0ea7879eb0a12beedacf81324cddaffc20', 1),
	(113, 226, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 11, '{"form": "inhaler", "unit": "inhaler", "atc_code": null, "strength": "100 mcg", "is_active": true, "brand_name": "Ventolin", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "respiratory", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 500, "rxnorm_code": null, "drug_item_id": 11, "generic_name": "Salbutamol", "manufacturer": null, "cost_per_unit": 1.20, "reorder_level": 100, "requires_cold_chain": false, "sale_price_per_unit": 4.50, "controlled_substance": false}', 'db-trigger', '9feb3f47de956a421e1c00357f6e8c0ea7879eb0a12beedacf81324cddaffc20', 'ac9c32433f55b057fd16c3e1e6a97b89e63dc3b9d147d98ed1771d187dc47f24', 1),
	(114, 228, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 12, '{"form": "vial", "unit": "vial", "atc_code": null, "strength": "100 u/mL", "is_active": true, "brand_name": "Humalog", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "antidiabetic", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 400, "rxnorm_code": null, "drug_item_id": 12, "generic_name": "Insulin Lispro", "manufacturer": null, "cost_per_unit": 6.50, "reorder_level": 80, "requires_cold_chain": false, "sale_price_per_unit": 15.00, "controlled_substance": false}', 'db-trigger', 'ac9c32433f55b057fd16c3e1e6a97b89e63dc3b9d147d98ed1771d187dc47f24', 'c27908abc85f27b9191465f4dc461c5fc5654c8e3557a7f904a6c34b548a04ab', 1),
	(115, 230, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 13, '{"form": "ampule", "unit": "ampule", "atc_code": null, "strength": "10 mg/mL", "is_active": true, "brand_name": "Morphsul", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "analgesic", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 300, "rxnorm_code": null, "drug_item_id": 13, "generic_name": "Morphine", "manufacturer": null, "cost_per_unit": 1.50, "reorder_level": 80, "requires_cold_chain": false, "sale_price_per_unit": 5.00, "controlled_substance": false}', 'db-trigger', 'c27908abc85f27b9191465f4dc461c5fc5654c8e3557a7f904a6c34b548a04ab', '02e15d5e81b8ac763b431dd08bff4316307fd89cefa05a40f36ea9f0b9a87e48', 1),
	(116, 232, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 14, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "10 mg", "is_active": true, "brand_name": "Zyrtec", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "antihistamine", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 2500, "rxnorm_code": null, "drug_item_id": 14, "generic_name": "Cetirizine", "manufacturer": null, "cost_per_unit": 0.05, "reorder_level": 400, "requires_cold_chain": false, "sale_price_per_unit": 0.20, "controlled_substance": false}', 'db-trigger', '02e15d5e81b8ac763b431dd08bff4316307fd89cefa05a40f36ea9f0b9a87e48', 'c8552912d26f3f40f00a86343ea12aea7b7c3aca04564ee07413d433d9ca575f', 1),
	(117, 234, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 15, '{"form": "bag", "unit": "bag", "atc_code": null, "strength": "500 mL", "is_active": true, "brand_name": "D5W", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "iv_fluid", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 600, "rxnorm_code": null, "drug_item_id": 15, "generic_name": "Dextrose 5%", "manufacturer": null, "cost_per_unit": 1.00, "reorder_level": 100, "requires_cold_chain": false, "sale_price_per_unit": 3.50, "controlled_substance": false}', 'db-trigger', 'c8552912d26f3f40f00a86343ea12aea7b7c3aca04564ee07413d433d9ca575f', '452f3265e7cf2dedd88fc2fa7309160ce4a0e479ae0293592af8ccbe6b05125a', 1),
	(118, 236, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 16, '{"form": "bag", "unit": "bag", "atc_code": null, "strength": "1000 mL", "is_active": true, "brand_name": "NS", "created_at": "2026-07-18T21:59:08.489232+03:00", "drug_class": "iv_fluid", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "reorder_qty": 600, "rxnorm_code": null, "drug_item_id": 16, "generic_name": "Sodium Chloride 0.9%", "manufacturer": null, "cost_per_unit": 1.00, "reorder_level": 100, "requires_cold_chain": false, "sale_price_per_unit": 4.00, "controlled_substance": false}', 'db-trigger', '452f3265e7cf2dedd88fc2fa7309160ce4a0e479ae0293592af8ccbe6b05125a', '812e362c1c4c13128a6e46feba120063cad24ee339b8bb370792418e48fe1e60', 1),
	(119, 238, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 2, '{"code": "SVC-DOC-EMR", "name": "EMR Document Fee", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 2, "unit_price": 10.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "emr_document", "department_id": 27, "effective_from": "2026-07-18"}', 'db-trigger', '812e362c1c4c13128a6e46feba120063cad24ee339b8bb370792418e48fe1e60', 'ea5125e05d3fc43bb039ba243c79968c7d14058dd38e6719b58747e9b48fef10', 1),
	(120, 240, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 3, '{"code": "SVC-CONSULT-GEN", "name": "General Consultation", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 3, "unit_price": 150.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "consultation", "department_id": 27, "effective_from": "2026-07-18"}', 'db-trigger', 'ea5125e05d3fc43bb039ba243c79968c7d14058dd38e6719b58747e9b48fef10', '38a8b41824dcb6f7f2c87c75c0386a855b2349fed613d2c7ddd5947e2f87728a', 1),
	(121, 242, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 4, '{"code": "SVC-CONSULT-CARD", "name": "Cardiology Consultation", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 4, "unit_price": 250.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "consultation", "department_id": 28, "effective_from": "2026-07-18"}', 'db-trigger', '38a8b41824dcb6f7f2c87c75c0386a855b2349fed613d2c7ddd5947e2f87728a', '202bd2a13322eeb7049c0864a2cacc0605aa20c0b2a243483ce6dbb0196d162d', 1),
	(122, 244, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 5, '{"code": "SVC-ANAESTHESIA", "name": "Anaesthesia Fee", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 5, "unit_price": 500.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "anaesthesia", "department_id": 33, "effective_from": "2026-07-18"}', 'db-trigger', '202bd2a13322eeb7049c0864a2cacc0605aa20c0b2a243483ce6dbb0196d162d', '3705360719d87b17c2ace32a1067fe1be505d548f84167dad2d787496920e3c8', 1),
	(123, 246, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 6, '{"code": "SVC-OR-MIN", "name": "OR Charge per Minute", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 6, "unit_price": 45.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "surgery_or", "department_id": 33, "effective_from": "2026-07-18"}', 'db-trigger', '3705360719d87b17c2ace32a1067fe1be505d548f84167dad2d787496920e3c8', 'e6f54ad5872f6f94f8605d06afe595f5cdd2fcbfeb6f9884e1e36c4d027fc3fe', 1),
	(124, 248, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 7, '{"code": "SVC-AMBULATE", "name": "Ambulance Service", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 7, "unit_price": 350.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "ambulance", "department_id": 37, "effective_from": "2026-07-18"}', 'db-trigger', 'e6f54ad5872f6f94f8605d06afe595f5cdd2fcbfeb6f9884e1e36c4d027fc3fe', '48e1e269bfacc5cf010b00c6d19a715df4dd2ce48fd4b81f6b1dfbb2ce3992f8', 1),
	(125, 250, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 8, '{"code": "SVC-ED-VISIT", "name": "Emergency Visit Fee", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 8, "unit_price": 450.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "emergency_triage", "department_id": 37, "effective_from": "2026-07-18"}', 'db-trigger', '48e1e269bfacc5cf010b00c6d19a715df4dd2ce48fd4b81f6b1dfbb2ce3992f8', '37f0f647ec1357c0f26aeb03f922bae76aefda366528f7362e3faf196f3611f9', 1),
	(126, 252, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 9, '{"code": "SVC-ED-TRIAGE", "name": "Emergency Triage Fee", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 9, "unit_price": 300.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "emergency_triage", "department_id": 38, "effective_from": "2026-07-18"}', 'db-trigger', '37f0f647ec1357c0f26aeb03f922bae76aefda366528f7362e3faf196f3611f9', 'c03ce71d539e1a76e28eaff64a3f79f15630d9a207873d09435876418ca2e808', 1),
	(127, 254, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 10, '{"code": "SVC-ICU-BED-DAY", "name": "ICU Bed Day Charge", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 10, "unit_price": 2200.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "icu_bed", "department_id": 39, "effective_from": "2026-07-18"}', 'db-trigger', 'c03ce71d539e1a76e28eaff64a3f79f15630d9a207873d09435876418ca2e808', 'ecae73df91315232dde1cc2a3ad906efb48850e47e11d675f3c3a1c2740d7328', 1),
	(156, 312, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'modality_suite', 3, '{"code": "RAD-CT", "name": "CT Suite A", "modality": "ct", "suite_id": 3, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "department_id": 44}', 'db-trigger', '0e6a0291dc95d351cced39446641effdfff847136ecf05a41af86b7237997c11', '77c9aa20552a10ec14f1ed09cef3fdf7a962775484ab83aba89529c5333f2dfa', 1),
	(128, 256, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 11, '{"code": "SVC-LAB-CMP", "name": "Comprehensive Metabolic Panel", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 11, "unit_price": 180.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "lab_test", "department_id": 42, "effective_from": "2026-07-18"}', 'db-trigger', 'ecae73df91315232dde1cc2a3ad906efb48850e47e11d675f3c3a1c2740d7328', '8590e2d5c7a31b13bd0e879c1f9b2aa76c1d7c83d15f93a2baae22f5ea445fcf', 1),
	(129, 258, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 12, '{"code": "SVC-LAB-CBC", "name": "CBC Test", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 12, "unit_price": 60.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "lab_test", "department_id": 42, "effective_from": "2026-07-18"}', 'db-trigger', '8590e2d5c7a31b13bd0e879c1f9b2aa76c1d7c83d15f93a2baae22f5ea445fcf', '07b241207df17e16f143685ab7fc7a2f17fe1cfacefab872540daf3ab3212a94', 1),
	(130, 260, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 13, '{"code": "SVC-RAD-MRI-BRN", "name": "MRI Brain with Contrast", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 13, "unit_price": 1500.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "imaging", "department_id": 44, "effective_from": "2026-07-18"}', 'db-trigger', '07b241207df17e16f143685ab7fc7a2f17fe1cfacefab872540daf3ab3212a94', '14d36ab5c365442e3c13b62983071836a02316d5d468e0a9b4682f5a7bd7269a', 1),
	(131, 262, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 14, '{"code": "SVC-RAD-CT-THX", "name": "CT Thorax", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 14, "unit_price": 650.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "imaging", "department_id": 44, "effective_from": "2026-07-18"}', 'db-trigger', '14d36ab5c365442e3c13b62983071836a02316d5d468e0a9b4682f5a7bd7269a', 'b060e28d3191bce37c483b808db19b9570cd4e19b512e224e6c8ee22ff19d414', 1),
	(132, 264, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 15, '{"code": "SVC-RAD-XR-CHST", "name": "Chest X-ray", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 15, "unit_price": 120.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "imaging", "department_id": 44, "effective_from": "2026-07-18"}', 'db-trigger', 'b060e28d3191bce37c483b808db19b9570cd4e19b512e224e6c8ee22ff19d414', '49359a41595dc950e159e0da00c38d1bb0b8cdb77bb983d7a22fa8d6077167ea', 1),
	(133, 266, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 16, '{"code": "SVC-PHYSIO-SESS", "name": "Physiotherapy Session", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "is_taxable": true, "service_id": 16, "unit_price": 200.00, "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "effective_to": null, "service_type": "physio_session", "department_id": 47, "effective_from": "2026-07-18"}', 'db-trigger', '49359a41595dc950e159e0da00c38d1bb0b8cdb77bb983d7a22fa8d6077167ea', '74916dedc61742d4aad833b38550ffb934b1424a3a9699f3135892ed48b56409', 1),
	(134, 268, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 2, '{"code": "PHY-MAN1", "name": "Manual Therapy 30", "type": "manual_therapy", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "therapy_id": 2, "body_region": "spine", "facility_id": 1, "duration_minutes": 30}', 'db-trigger', '74916dedc61742d4aad833b38550ffb934b1424a3a9699f3135892ed48b56409', 'b92430cb1f6da794b4a92c938ad23085337448ff9e1ffa987fda2f741e93d9cb', 1),
	(135, 270, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 3, '{"code": "PHY-ELEC1", "name": "Electrotherapy TENS", "type": "electrotherapy", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "therapy_id": 3, "body_region": "any", "facility_id": 1, "duration_minutes": 20}', 'db-trigger', 'b92430cb1f6da794b4a92c938ad23085337448ff9e1ffa987fda2f741e93d9cb', '8a14cb4d0f6c6a695c3d95e5e77aa0e2233332ccf7e9d2a85df821f6d8241892', 1),
	(136, 272, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 4, '{"code": "PHY-EX1", "name": "Therapeutic Exercise Set A", "type": "therapeutic_exercise", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "therapy_id": 4, "body_region": "any", "facility_id": 1, "duration_minutes": 45}', 'db-trigger', '8a14cb4d0f6c6a695c3d95e5e77aa0e2233332ccf7e9d2a85df821f6d8241892', '4d73edf791154c994613ee2be4385a7a2b0d0167532e5aa697376e9921a0cd99', 1),
	(137, 274, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 5, '{"code": "PHY-HYDRO", "name": "Hydrotherapy Session", "type": "hydrotherapy", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "therapy_id": 5, "body_region": "lower_limb", "facility_id": 1, "duration_minutes": 30}', 'db-trigger', '4d73edf791154c994613ee2be4385a7a2b0d0167532e5aa697376e9921a0cd99', 'c54822a3adff71d67f42b3ffa4ae72ba34336c667d9543ae88b103a5298386c8', 1),
	(138, 276, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 6, '{"code": "PHY-CRY", "name": "Cryotherapy 10", "type": "cryotherapy", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "therapy_id": 6, "body_region": "joint", "facility_id": 1, "duration_minutes": 10}', 'db-trigger', 'c54822a3adff71d67f42b3ffa4ae72ba34336c667d9543ae88b103a5298386c8', '65ee1005a358afe1f26ce9b3ecf1a222ae5183e73ffbf19ee1605f99de65ab8a', 1),
	(139, 278, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 7, '{"code": "PHY-HEAT", "name": "Heat Therapy 15", "type": "heat_therapy", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "therapy_id": 7, "body_region": "soft_tissue", "facility_id": 1, "duration_minutes": 15}', 'db-trigger', '65ee1005a358afe1f26ce9b3ecf1a222ae5183e73ffbf19ee1605f99de65ab8a', '23cf71e496681e3a356a311556448741d88aa4e6308906d7b4df1b729a519e9b', 1),
	(140, 280, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 8, '{"code": "PHY-US", "name": "Therapeutic Ultrasound", "type": "ultrasound", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "therapy_id": 8, "body_region": "soft_tissue", "facility_id": 1, "duration_minutes": 15}', 'db-trigger', '23cf71e496681e3a356a311556448741d88aa4e6308906d7b4df1b729a519e9b', 'cb7f2dc5761daf3219a56bcb6b3116673db744f36c0e46270452fd5dd8085586', 1),
	(241, 482, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 4, '{"role_id": 4, "facility_id": 1, "permission_id": 11}', 'db-trigger', '39191d01d22db05bc7403cff4fa95123d57ac11b3ad1bf82553052f08a71e2ad', '0bce78d8bc35ceb2c47acf802d7cf0941c01ad2d0ec1e802ead4437bca0507e0', 1),
	(141, 282, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 9, '{"code": "PHY-LASER", "name": "Laser Therapy", "type": "laser", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "therapy_id": 9, "body_region": "wound", "facility_id": 1, "duration_minutes": 10}', 'db-trigger', 'cb7f2dc5761daf3219a56bcb6b3116673db744f36c0e46270452fd5dd8085586', 'b8675d7909d2b2ddcf8c8c1e6895627c0a8f1845f3cd6f385b2db6f13718a945', 1),
	(142, 284, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 10, '{"code": "PHY-TAPING", "name": "Kinesio Taping", "type": "taping", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "therapy_id": 10, "body_region": "any", "facility_id": 1, "duration_minutes": 15}', 'db-trigger', 'b8675d7909d2b2ddcf8c8c1e6895627c0a8f1845f3cd6f385b2db6f13718a945', 'f7d70fc324f828659bb95f74232e4291b2a364b06ccb6a767fed4e3c6b8eef26', 1),
	(143, 286, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 11, '{"code": "PHY-NEURO", "name": "Neuro Rehab Session", "type": "neuro_rehab", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "therapy_id": 11, "body_region": "cns", "facility_id": 1, "duration_minutes": 60}', 'db-trigger', 'f7d70fc324f828659bb95f74232e4291b2a364b06ccb6a767fed4e3c6b8eef26', '49d004aa3f76728759b6687e35be7a6b391a0c1a4b62a765c647b95a5fcda4b7', 1),
	(144, 288, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Arthroplasty, glenohumeral joint", "notes": null, "cpt_code": "23470", "body_site": null, "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "proc_cat_id": 2, "default_duration_min": 90}', 'db-trigger', '49d004aa3f76728759b6687e35be7a6b391a0c1a4b62a765c647b95a5fcda4b7', '0fe4e86a915d91910dd6c311b6045327247c3529aa18a5937af425b85666f1fe', 1),
	(145, 290, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Total hip arthroplasty", "notes": null, "cpt_code": "27130", "body_site": null, "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "proc_cat_id": 3, "default_duration_min": 90}', 'db-trigger', '0fe4e86a915d91910dd6c311b6045327247c3529aa18a5937af425b85666f1fe', 'e0cdb50161f30f5a89f6f8ad1283f0ef3fef306a80740e87e9207d4a6bc326ea', 1),
	(146, 292, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Total knee arthroplasty", "notes": null, "cpt_code": "27447", "body_site": null, "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "proc_cat_id": 4, "default_duration_min": 90}', 'db-trigger', 'e0cdb50161f30f5a89f6f8ad1283f0ef3fef306a80740e87e9207d4a6bc326ea', '018726760cc0e2223282404688dccdc5e42e2b5bb7e6e9a564d6c394d4e6dccf', 1),
	(147, 294, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Coronary artery bypass, single", "notes": null, "cpt_code": "33533", "body_site": null, "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "proc_cat_id": 5, "default_duration_min": 90}', 'db-trigger', '018726760cc0e2223282404688dccdc5e42e2b5bb7e6e9a564d6c394d4e6dccf', 'affd32cc864c60be826b1e5736dd2c93f640cb79ca2ed38e3bd4fcba86c2cfc0', 1),
	(148, 296, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Open cholecystectomy", "notes": null, "cpt_code": "47579", "body_site": null, "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "proc_cat_id": 6, "default_duration_min": 90}', 'db-trigger', 'affd32cc864c60be826b1e5736dd2c93f640cb79ca2ed38e3bd4fcba86c2cfc0', '95a7e680b669aea1a0793ee54d8a8a781d6f1c48e61df56f7ff4b8bb8b8ae422', 1),
	(149, 298, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Repair of femoral hernia", "notes": null, "cpt_code": "49505", "body_site": null, "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "proc_cat_id": 7, "default_duration_min": 90}', 'db-trigger', '95a7e680b669aea1a0793ee54d8a8a781d6f1c48e61df56f7ff4b8bb8b8ae422', '54d1e3f05d186d070faeeaed2a1b13fc3091a080e7b31826a3cbe293521e237a', 1),
	(150, 300, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Total abdominal hysterectomy", "notes": null, "cpt_code": "58150", "body_site": null, "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "proc_cat_id": 8, "default_duration_min": 90}', 'db-trigger', '54d1e3f05d186d070faeeaed2a1b13fc3091a080e7b31826a3cbe293521e237a', '9c0fa2d61c526b81455e6c5a87805ed168a1dce1b92aea215253029bd6305fda', 1),
	(151, 302, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'operating_room', 2, '{"code": "OR-GEN", "name": "General Operating Theatre", "or_id": 2, "status": "available", "is_active": true, "room_type": "general", "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "department_id": 33}', 'db-trigger', '9c0fa2d61c526b81455e6c5a87805ed168a1dce1b92aea215253029bd6305fda', '4f3186edeee12f5a971de71294d1c510595c76fe60b609ea3690e892280913e7', 1),
	(152, 304, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'operating_room', 3, '{"code": "OR-CARD", "name": "Cardiac Surgery Theatre", "or_id": 3, "status": "available", "is_active": true, "room_type": "cardiac", "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "department_id": 34}', 'db-trigger', '4f3186edeee12f5a971de71294d1c510595c76fe60b609ea3690e892280913e7', 'b9914ed3079a77d74ce02da13655d7957328f38186e5f25be71e2a9c2d4ddfa6', 1),
	(153, 306, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'operating_room', 4, '{"code": "OR-ORTHO", "name": "Orthopaedic Surgery Theatre", "or_id": 4, "status": "available", "is_active": true, "room_type": "ortho", "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "department_id": 35}', 'db-trigger', 'b9914ed3079a77d74ce02da13655d7957328f38186e5f25be71e2a9c2d4ddfa6', '47c53751b2655d3b74fb8db7400e46ecc895c639cadf1e533a02d5345372b3cb', 1),
	(154, 308, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'operating_room', 5, '{"code": "OR-NEURO", "name": "Neurosurgery Theatre", "or_id": 5, "status": "available", "is_active": true, "room_type": "neuro", "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "department_id": 36}', 'db-trigger', '47c53751b2655d3b74fb8db7400e46ecc895c639cadf1e533a02d5345372b3cb', '7860f2896d149b2aafa262a5407b370f2134f59f1b98d1450826daae0b63c703', 1),
	(155, 310, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'modality_suite', 2, '{"code": "RAD-XR", "name": "X-ray Room 1", "modality": "xray", "suite_id": 2, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "department_id": 44}', 'db-trigger', '7860f2896d149b2aafa262a5407b370f2134f59f1b98d1450826daae0b63c703', '0e6a0291dc95d351cced39446641effdfff847136ecf05a41af86b7237997c11', 1),
	(157, 314, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'modality_suite', 4, '{"code": "RAD-MRI", "name": "MRI Unit 1", "modality": "mri", "suite_id": 4, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "department_id": 44}', 'db-trigger', '77c9aa20552a10ec14f1ed09cef3fdf7a962775484ab83aba89529c5333f2dfa', '240141fc5714dc624ce36b683eb67f409c1d0f121835f762522f5106e759abc9', 1),
	(158, 316, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'modality_suite', 5, '{"code": "RAD-US", "name": "Ultrasound 1", "modality": "us", "suite_id": 5, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "department_id": 44}', 'db-trigger', '240141fc5714dc624ce36b683eb67f409c1d0f121835f762522f5106e759abc9', '39ec9eb1d07d4b04236c9435aa51e4e575f419544f54a0c8cba991717d2fa87e', 1),
	(159, 318, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'modality_suite', 6, '{"code": "RAD-FL", "name": "Fluoroscopy Room", "modality": "fluoroscopy", "suite_id": 6, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "updated_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "department_id": 44}', 'db-trigger', '39ec9eb1d07d4b04236c9435aa51e4e575f419544f54a0c8cba991717d2fa87e', '53904cdaf9d66dbcae8c10f3e8113f6ed7947db18ea34b7eea8e3e2826651094', 1),
	(160, 320, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'exam_catalog', 2, '{"name": "Chest X-ray", "exam_id": 2, "body_part": "Chest", "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "snomed_code": null, "contrast_used": false, "default_modality": "xray", "duration_minutes": 5}', 'db-trigger', '53904cdaf9d66dbcae8c10f3e8113f6ed7947db18ea34b7eea8e3e2826651094', '0099eef76f8b59894b7146d95bc1c541e04fdb420921e56f61da33c7bd60922f', 1),
	(161, 322, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'exam_catalog', 3, '{"name": "CT Thorax without contrast", "exam_id": 3, "body_part": "Chest", "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "snomed_code": null, "contrast_used": false, "default_modality": "ct", "duration_minutes": 15}', 'db-trigger', '0099eef76f8b59894b7146d95bc1c541e04fdb420921e56f61da33c7bd60922f', '2b51908f37ed9ac1411460c07115f0f61ece5e3bad4e8352576d4192d53ab6d1', 1),
	(162, 324, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'exam_catalog', 4, '{"name": "CT Brain with contrast", "exam_id": 4, "body_part": "Brain", "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "snomed_code": null, "contrast_used": true, "default_modality": "ct", "duration_minutes": 20}', 'db-trigger', '2b51908f37ed9ac1411460c07115f0f61ece5e3bad4e8352576d4192d53ab6d1', '7b1e3e85c06260ffb4f9401333edc6bc5e07f9efc56c9f96acfb5f432dbbf21f', 1),
	(163, 326, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'exam_catalog', 5, '{"name": "MRI Brain with contrast", "exam_id": 5, "body_part": "Brain", "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "snomed_code": null, "contrast_used": true, "default_modality": "mri", "duration_minutes": 45}', 'db-trigger', '7b1e3e85c06260ffb4f9401333edc6bc5e07f9efc56c9f96acfb5f432dbbf21f', 'af990c63f558be6d40dc479d180eca41bed5c4b58a450011e6e4fe6ac05810e5', 1),
	(164, 328, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'exam_catalog', 6, '{"name": "Ultrasound Abdomen", "exam_id": 6, "body_part": "Abdomen", "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "snomed_code": null, "contrast_used": false, "default_modality": "us", "duration_minutes": 15}', 'db-trigger', 'af990c63f558be6d40dc479d180eca41bed5c4b58a450011e6e4fe6ac05810e5', 'f84c9d51e7dd75d4acbb2d0bd8e339520145be9a5759d4b8af20433946a36b07', 1),
	(165, 330, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'exam_catalog', 7, '{"name": "DEXA Bone Density", "exam_id": 7, "body_part": "Spine", "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1, "snomed_code": null, "contrast_used": false, "default_modality": "dexa", "duration_minutes": 10}', 'db-trigger', 'f84c9d51e7dd75d4acbb2d0bd8e339520145be9a5759d4b8af20433946a36b07', 'c7261ea682cc9c9446ab0c129c7ce17751c7ea856a5a8f2605ce90b9101fd324', 1),
	(166, 332, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 2, '{"name": "WBC Count", "unit": "10^3/uL", "ref_low": 4.0, "test_id": 2, "category": "Hematology", "ref_high": 11.0, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "6690-2", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 60}', 'db-trigger', 'c7261ea682cc9c9446ab0c129c7ce17751c7ea856a5a8f2605ce90b9101fd324', 'bb5923d9f013fdad1336bdff0e88208221940f3bbcdeb8d8788f491288010d45', 1),
	(167, 334, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 3, '{"name": "Hemoglobin", "unit": "g/dL", "ref_low": 12.0, "test_id": 3, "category": "Hematology", "ref_high": 17.5, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "718-7", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 60}', 'db-trigger', 'bb5923d9f013fdad1336bdff0e88208221940f3bbcdeb8d8788f491288010d45', '5cb8a4b8f10ff7e3373f9107a948419d01928e109f88df11dd28bb76ce8a5a0a', 1),
	(168, 336, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 4, '{"name": "RBC Count", "unit": "10^6/uL", "ref_low": 4.0, "test_id": 4, "category": "Hematology", "ref_high": 5.9, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "789-8", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 60}', 'db-trigger', '5cb8a4b8f10ff7e3373f9107a948419d01928e109f88df11dd28bb76ce8a5a0a', '740b2ceae4669133e20b7832223839e9403f70e93617812492a2ce33a14d3c96', 1),
	(169, 338, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 5, '{"name": "Sodium", "unit": "mmol/L", "ref_low": 135, "test_id": 5, "category": "Chemistry", "ref_high": 145, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "2951-2", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 60}', 'db-trigger', '740b2ceae4669133e20b7832223839e9403f70e93617812492a2ce33a14d3c96', '86c8126cd43d934d1a9b635662a77f9f387a5f36fa0e7fb8e7a52293db82a87c', 1),
	(170, 340, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 6, '{"name": "Chloride", "unit": "mmol/L", "ref_low": 98, "test_id": 6, "category": "Chemistry", "ref_high": 107, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "2069-3", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 60}', 'db-trigger', '86c8126cd43d934d1a9b635662a77f9f387a5f36fa0e7fb8e7a52293db82a87c', '13d429234d89081cb5906af43ca58a475442b906135e3a97c36ff10e456c7a58', 1),
	(242, 484, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 5, '{"role_id": 5, "facility_id": 1, "permission_id": 12}', 'db-trigger', '0bce78d8bc35ceb2c47acf802d7cf0941c01ad2d0ec1e802ead4437bca0507e0', 'd687c381211f153a9b0e3076fb2706c5ea4efbdeeb4ac0b70541ea29c45e1da7', 1),
	(171, 342, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 7, '{"name": "Potassium", "unit": "mmol/L", "ref_low": 3.5, "test_id": 7, "category": "Chemistry", "ref_high": 5.0, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "2885-2", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 60}', 'db-trigger', '13d429234d89081cb5906af43ca58a475442b906135e3a97c36ff10e456c7a58', 'eaf0ae722bc224ceda86bb0722e90f7daad7cf33b49c048224ff8f249f158034', 1),
	(172, 344, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 8, '{"name": "Glucose, Random", "unit": "mg/dL", "ref_low": 70, "test_id": 8, "category": "Chemistry", "ref_high": 100, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "2345-7", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 30}', 'db-trigger', 'eaf0ae722bc224ceda86bb0722e90f7daad7cf33b49c048224ff8f249f158034', 'b7c1a2a4ba569aa16b12334add52b908fd0c35b618c65c2bc520aca55888875b', 1),
	(173, 346, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 9, '{"name": "Urea Nitrogen", "unit": "mg/dL", "ref_low": 7, "test_id": 9, "category": "Chemistry", "ref_high": 20, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "3094-0", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 90}', 'db-trigger', 'b7c1a2a4ba569aa16b12334add52b908fd0c35b618c65c2bc520aca55888875b', '4558f815f038b05de33dd3fb7e7362d9c9a7fbef406892fee932a589ce7cfc2c', 1),
	(174, 348, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 10, '{"name": "Creatinine", "unit": "mg/dL", "ref_low": 0.7, "test_id": 10, "category": "Chemistry", "ref_high": 1.3, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "38483-4", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 90}', 'db-trigger', '4558f815f038b05de33dd3fb7e7362d9c9a7fbef406892fee932a589ce7cfc2c', 'c0d97c7e440cf325d0b8205d9d30ddd9ec1c59c60a4daaa7054174f0bd49a493', 1),
	(175, 350, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 11, '{"name": "Troponin I, Cardiac", "unit": "ng/mL", "ref_low": 0.0, "test_id": 11, "category": "Chemistry", "ref_high": 0.04, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "33914-3", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 45}', 'db-trigger', 'c0d97c7e440cf325d0b8205d9d30ddd9ec1c59c60a4daaa7054174f0bd49a493', '7354f0a974ab67a4673b81dd3e85484ba59214f83884e2bdf8af11c5810ecab7', 1),
	(176, 352, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 12, '{"name": "PT/INR", "unit": "INR", "ref_low": 0.8, "test_id": 12, "category": "Coagulation", "ref_high": 1.2, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "25428-4", "facility_id": 1, "specimen_type": "blood", "volume_required": 2.50, "turnaround_minutes": 60}', 'db-trigger', '7354f0a974ab67a4673b81dd3e85484ba59214f83884e2bdf8af11c5810ecab7', '40881cd4c436cf3688520ffe062f64e1f7316f6dcfff5529fcc543288fa1aaa5', 1),
	(177, 354, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 13, '{"name": "Potassium, Urine", "unit": "mmol/d", "ref_low": 25, "test_id": 13, "category": "Urinalysis", "ref_high": 125, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "6298-4", "facility_id": 1, "specimen_type": "urine", "volume_required": 10.00, "turnaround_minutes": 120}', 'db-trigger', '40881cd4c436cf3688520ffe062f64e1f7316f6dcfff5529fcc543288fa1aaa5', 'e84c3e98d550a90d6ea030e2e1ab366196dcdfc119d5ccc5091133a70d321d94', 1),
	(178, 356, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 14, '{"name": "Glucose, Urine", "unit": "mg/dL", "ref_low": 0, "test_id": 14, "category": "Urinalysis", "ref_high": 0, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "5792-7", "facility_id": 1, "specimen_type": "urine", "volume_required": 10.00, "turnaround_minutes": 30}', 'db-trigger', 'e84c3e98d550a90d6ea030e2e1ab366196dcdfc119d5ccc5091133a70d321d94', 'b16246270cf783b3d0b78411b67973067673df8777f215c786787aed4d45c46d', 1),
	(179, 358, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 15, '{"name": "Stool Routine", "unit": " qualitative", "ref_low": null, "test_id": 15, "category": "Microbiology", "ref_high": null, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "11277-5", "facility_id": 1, "specimen_type": "stool", "volume_required": 5.00, "turnaround_minutes": 240}', 'db-trigger', 'b16246270cf783b3d0b78411b67973067673df8777f215c786787aed4d45c46d', '5ad09ea0ebc9a9575010b8d83ac678d087274594af3a82c03cb6cee3067c12ed', 1),
	(180, 360, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 16, '{"name": "Wound Culture & Sensitivity", "unit": "qualitative", "ref_low": null, "test_id": 16, "category": "Microbiology", "ref_high": null, "is_active": true, "created_at": "2026-07-18T21:59:08.489232+03:00", "loinc_code": "14461-8", "facility_id": 1, "specimen_type": "swab", "volume_required": 1.00, "turnaround_minutes": 1440}', 'db-trigger', '5ad09ea0ebc9a9575010b8d83ac678d087274594af3a82c03cb6cee3067c12ed', '04c431b722c89bf979416c80e2cd77ccad407518f2700adbfbb417e0f334b807', 1),
	(181, 362, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel', 2, '{"code": "P-CBC", "name": "Complete Blood Count", "panel_id": 2, "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1}', 'db-trigger', '04c431b722c89bf979416c80e2cd77ccad407518f2700adbfbb417e0f334b807', '9e9ca701b2c646b5c43d78a8b0a281062da51012c5bac9ef6f42ac1651bd506c', 1),
	(182, 364, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel', 3, '{"code": "P-CMP", "name": "Comprehensive Metabolic Panel", "panel_id": 3, "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1}', 'db-trigger', '9e9ca701b2c646b5c43d78a8b0a281062da51012c5bac9ef6f42ac1651bd506c', '3e978c0caa82bed72f81c8a13b7df195984ca7dd45e5b2a1ebdf11f4fa7e0ac6', 1),
	(183, 366, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel', 4, '{"code": "P-CARD", "name": "Cardiac Panel", "panel_id": 4, "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1}', 'db-trigger', '3e978c0caa82bed72f81c8a13b7df195984ca7dd45e5b2a1ebdf11f4fa7e0ac6', 'd142a47b4b35dc84c630e2eb31c711a1c599d50b006a5adba5372f1837488f6b', 1),
	(184, 368, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel', 5, '{"code": "P-UA", "name": "Urinalysis Panel", "panel_id": 5, "created_at": "2026-07-18T21:59:08.489232+03:00", "facility_id": 1}', 'db-trigger', 'd142a47b4b35dc84c630e2eb31c711a1c599d50b006a5adba5372f1837488f6b', '047cd8bc0f2b2ffc12abad5c9952be0bfab1baae3122a762ac7cdee223a72292', 1),
	(186, 372, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 3, '{"ppi_id": 3, "test_id": 3, "panel_id": 2, "sort_order": 2, "facility_id": 1}', 'db-trigger', 'aebc5c1ca6cdf5d4fd82f394ef75b4d3785d862e4aa62b2ea843220bd37fda10', '54998f4357247c0add678ef4f77e62aa38a9b3ca8762819bd4bba556d7d44277', 1),
	(187, 374, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 4, '{"ppi_id": 4, "test_id": 4, "panel_id": 2, "sort_order": 3, "facility_id": 1}', 'db-trigger', '54998f4357247c0add678ef4f77e62aa38a9b3ca8762819bd4bba556d7d44277', 'bdd6558567fa99e8bd8fd2e72b653d4f10c30850d07b432e5adea6dc46a730dc', 1),
	(188, 376, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 5, '{"ppi_id": 5, "test_id": 5, "panel_id": 3, "sort_order": 1, "facility_id": 1}', 'db-trigger', 'bdd6558567fa99e8bd8fd2e72b653d4f10c30850d07b432e5adea6dc46a730dc', 'f6d55700a4e6f17f157f527397c5301417d6901a7520c0fd5e3490db13a30a5c', 1),
	(189, 378, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 6, '{"ppi_id": 6, "test_id": 6, "panel_id": 3, "sort_order": 2, "facility_id": 1}', 'db-trigger', 'f6d55700a4e6f17f157f527397c5301417d6901a7520c0fd5e3490db13a30a5c', '941b738093f879c4de38399866fe8bc35b55d25d4773a72083ef3852ac305d6d', 1),
	(190, 380, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 7, '{"ppi_id": 7, "test_id": 7, "panel_id": 3, "sort_order": 3, "facility_id": 1}', 'db-trigger', '941b738093f879c4de38399866fe8bc35b55d25d4773a72083ef3852ac305d6d', '2b22221a7f19ba9e5900bdc458c76c717deb5cf5e872fbb71862c2e0ce767db9', 1),
	(191, 382, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 8, '{"ppi_id": 8, "test_id": 9, "panel_id": 3, "sort_order": 4, "facility_id": 1}', 'db-trigger', '2b22221a7f19ba9e5900bdc458c76c717deb5cf5e872fbb71862c2e0ce767db9', '0313973d8b507ed84d57443a248291ce1129b1fb10fa40bdf9f512a60cde91f0', 1),
	(192, 384, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 9, '{"ppi_id": 9, "test_id": 10, "panel_id": 3, "sort_order": 5, "facility_id": 1}', 'db-trigger', '0313973d8b507ed84d57443a248291ce1129b1fb10fa40bdf9f512a60cde91f0', 'b67c51ad13762a1fa16a8e47e02af1048f207faf590f5c7c5c24d99df0fffce0', 1),
	(193, 386, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 10, '{"ppi_id": 10, "test_id": 8, "panel_id": 3, "sort_order": 6, "facility_id": 1}', 'db-trigger', 'b67c51ad13762a1fa16a8e47e02af1048f207faf590f5c7c5c24d99df0fffce0', 'faab020fe974202d0d5fa371c68884e6195717d376ce09eb0d598fefe47784cb', 1),
	(194, 388, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 11, '{"ppi_id": 11, "test_id": 11, "panel_id": 4, "sort_order": 1, "facility_id": 1}', 'db-trigger', 'faab020fe974202d0d5fa371c68884e6195717d376ce09eb0d598fefe47784cb', '47bbae794bd7a3ce80d12c030db38cd7c13783629b7663e48fa5946ebcf1258c', 1),
	(195, 390, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 2, '{"code": "1000", "name": "Assets", "is_active": true, "account_id": 2, "facility_id": 1, "is_postable": true, "account_type": "asset", "parent_account_id": null}', 'db-trigger', '47bbae794bd7a3ce80d12c030db38cd7c13783629b7663e48fa5946ebcf1258c', 'df5a248b3d28a80fdd9e42002215d7d6ae56e7b2ebc2fff1ee3eff62482ce98d', 1),
	(196, 392, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 3, '{"code": "1001", "name": "Cash on Hand", "is_active": true, "account_id": 3, "facility_id": 1, "is_postable": true, "account_type": "cash", "parent_account_id": null}', 'db-trigger', 'df5a248b3d28a80fdd9e42002215d7d6ae56e7b2ebc2fff1ee3eff62482ce98d', '10268f429854cff8ac04afc61a606654bfb5b869491607f0a5206ed1adf60ce4', 1),
	(197, 394, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 4, '{"code": "1002", "name": "Bank Account", "is_active": true, "account_id": 4, "facility_id": 1, "is_postable": true, "account_type": "bank", "parent_account_id": null}', 'db-trigger', '10268f429854cff8ac04afc61a606654bfb5b869491607f0a5206ed1adf60ce4', '13eb8c5a1c618b1e7069a86b62e48c51c338c1f5a1541e87abccff6b107d24aa', 1),
	(198, 396, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 5, '{"code": "1200", "name": "Accounts Receivable", "is_active": true, "account_id": 5, "facility_id": 1, "is_postable": true, "account_type": "asset", "parent_account_id": null}', 'db-trigger', '13eb8c5a1c618b1e7069a86b62e48c51c338c1f5a1541e87abccff6b107d24aa', '0716796d4d7d4f434e7596898f5cbf8dc490908d31dee219f396f5579fea70ec', 1);
INSERT INTO mcms_core.event_log VALUES
	(199, 398, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 6, '{"code": "1400", "name": "Inventory", "is_active": true, "account_id": 6, "facility_id": 1, "is_postable": true, "account_type": "asset", "parent_account_id": null}', 'db-trigger', '0716796d4d7d4f434e7596898f5cbf8dc490908d31dee219f396f5579fea70ec', 'ae0b87303d9338987f9c99e5785b65c8985ddfa9deb92272e8d4efa0ffa4f4ea', 1),
	(200, 400, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 7, '{"code": "2000", "name": "Liabilities", "is_active": true, "account_id": 7, "facility_id": 1, "is_postable": true, "account_type": "liability", "parent_account_id": null}', 'db-trigger', 'ae0b87303d9338987f9c99e5785b65c8985ddfa9deb92272e8d4efa0ffa4f4ea', 'cbc852479107b6c67bcd21c51b1a55fe9d9c5676dfb890e06a83cb9f567e7907', 1),
	(201, 402, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 8, '{"code": "2100", "name": "Accounts Payable", "is_active": true, "account_id": 8, "facility_id": 1, "is_postable": true, "account_type": "liability", "parent_account_id": null}', 'db-trigger', 'cbc852479107b6c67bcd21c51b1a55fe9d9c5676dfb890e06a83cb9f567e7907', '52f441351f38a575fd6d6ff44e99c904292a4d29b636c29dc994ee124acac3fe', 1),
	(202, 404, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 9, '{"code": "3000", "name": "Equity", "is_active": true, "account_id": 9, "facility_id": 1, "is_postable": true, "account_type": "equity", "parent_account_id": null}', 'db-trigger', '52f441351f38a575fd6d6ff44e99c904292a4d29b636c29dc994ee124acac3fe', '61ec4413b651e9f1d3ea9f5a834aee46825d24c221a0ac2ff25ec8d77084db6b', 1),
	(203, 406, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 10, '{"code": "4000", "name": "Outpatient Revenue", "is_active": true, "account_id": 10, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', '61ec4413b651e9f1d3ea9f5a834aee46825d24c221a0ac2ff25ec8d77084db6b', '872f47d973aaec92139f9a33af8fcdc21c824a0a493cb6f47583fff3ede7fe30', 1),
	(204, 408, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 11, '{"code": "4100", "name": "Surgical Revenue", "is_active": true, "account_id": 11, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', '872f47d973aaec92139f9a33af8fcdc21c824a0a493cb6f47583fff3ede7fe30', '7a408b6eb3ec4f455f36c28c4c295eee959b271432b11d6238b6baa4da6f5c4f', 1),
	(205, 410, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 12, '{"code": "4200", "name": "Lab Revenue", "is_active": true, "account_id": 12, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', '7a408b6eb3ec4f455f36c28c4c295eee959b271432b11d6238b6baa4da6f5c4f', '421eb8df1a94f22437192703c08df1f5aed60324b063fd232b5249dc26b2eadc', 1),
	(206, 412, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 13, '{"code": "4300", "name": "Pharmacy Revenue", "is_active": true, "account_id": 13, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', '421eb8df1a94f22437192703c08df1f5aed60324b063fd232b5249dc26b2eadc', 'e9220782141a4ec78533d6ed1786c4a4ecb416cdae7118f481791d66053b0bfb', 1),
	(207, 414, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 14, '{"code": "4400", "name": "Imaging Revenue", "is_active": true, "account_id": 14, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', 'e9220782141a4ec78533d6ed1786c4a4ecb416cdae7118f481791d66053b0bfb', '113cdc9a87aaa11a368951f60cce4808d5041eeac05daed3f63a9ffe608df526', 1),
	(208, 416, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 15, '{"code": "4500", "name": "ICU Revenue", "is_active": true, "account_id": 15, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', '113cdc9a87aaa11a368951f60cce4808d5041eeac05daed3f63a9ffe608df526', '97c94fc08c5010814b32b9fa3f6e5ea7f9989585aacda145559149998e47d4fc', 1),
	(209, 418, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 16, '{"code": "4600", "name": "ER Revenue", "is_active": true, "account_id": 16, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', '97c94fc08c5010814b32b9fa3f6e5ea7f9989585aacda145559149998e47d4fc', 'a3ae010b11634e91f4b7f78a49ef00271eddd1e939f20711150be584b8ee6a31', 1),
	(210, 420, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 17, '{"code": "5000", "name": "Cost of Consumables", "is_active": true, "account_id": 17, "facility_id": 1, "is_postable": true, "account_type": "expense", "parent_account_id": null}', 'db-trigger', 'a3ae010b11634e91f4b7f78a49ef00271eddd1e939f20711150be584b8ee6a31', '0c27497ae264ce5159e3dbddaaa014a9a279ba3baebb438aaaab56848e646c3c', 1),
	(211, 422, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 18, '{"code": "5100", "name": "Cost of Drugs Sold", "is_active": true, "account_id": 18, "facility_id": 1, "is_postable": true, "account_type": "expense", "parent_account_id": null}', 'db-trigger', '0c27497ae264ce5159e3dbddaaa014a9a279ba3baebb438aaaab56848e646c3c', 'a67328cb065e7ce05be5f1a6f9fcd77735d1fcd54adf5754c2ffb27ecb4431fe', 1),
	(212, 424, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 19, '{"code": "5200", "name": "Salaries & Wages", "is_active": true, "account_id": 19, "facility_id": 1, "is_postable": true, "account_type": "expense", "parent_account_id": null}', 'db-trigger', 'a67328cb065e7ce05be5f1a6f9fcd77735d1fcd54adf5754c2ffb27ecb4431fe', '302ace3f45a5d619b9096feb14c680369bc090722bbf0f2f93f9a741ee57a895', 1),
	(213, 426, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 20, '{"code": "5300", "name": "Utilities Expense", "is_active": true, "account_id": 20, "facility_id": 1, "is_postable": true, "account_type": "expense", "parent_account_id": null}', 'db-trigger', '302ace3f45a5d619b9096feb14c680369bc090722bbf0f2f93f9a741ee57a895', '677e6fcd365afaf79c58bb987361ab9b4f6329d645c4bf3d875c258c3414ab00', 1),
	(214, 428, '2026-07-18 21:59:08.489232+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 21, '{"code": "5400", "name": "Depreciation", "is_active": true, "account_id": 21, "facility_id": 1, "is_postable": true, "account_type": "expense", "parent_account_id": null}', 'db-trigger', '677e6fcd365afaf79c58bb987361ab9b4f6329d645c4bf3d875c258c3414ab00', 'b1994ae0cfd811ee4781ed5f77c09e359b23e4803bb05ac66d067891e40abf67', 1),
	(215, 430, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 51, '{"code": "DIAL-GEN", "kind": "clinic", "name": "Dialysis Unit", "is_active": true, "created_at": "2026-07-18T21:59:08.579833+03:00", "updated_at": "2026-07-18T21:59:08.579833+03:00", "facility_id": 1, "head_user_id": null, "department_id": 51, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'b1994ae0cfd811ee4781ed5f77c09e359b23e4803bb05ac66d067891e40abf67', '10269e66fa4f71d5ced87ba0e8704f8badfc5bb64ff13f400de61ebc43a188b6', 1),
	(216, 432, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 52, '{"code": "NURS-GEN", "kind": "clinic", "name": "Nursery / Neonatal Unit", "is_active": true, "created_at": "2026-07-18T21:59:08.579833+03:00", "updated_at": "2026-07-18T21:59:08.579833+03:00", "facility_id": 1, "head_user_id": null, "department_id": 52, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '10269e66fa4f71d5ced87ba0e8704f8badfc5bb64ff13f400de61ebc43a188b6', '582cc60b88e732f9ca12a0a643a3b188a484005b4e9c40b50f69716e493ba665', 1),
	(217, 434, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 2, '{"code": "lab_rad", "name_ar": "مختبر/أشعة", "name_en": "Laboratory/Radiology", "role_id": 2, "is_active": true, "created_at": "2026-07-18T21:59:08.579833+03:00", "description": "Results & reports entry, DICOM", "facility_id": 1}', 'db-trigger', '582cc60b88e732f9ca12a0a643a3b188a484005b4e9c40b50f69716e493ba665', 'a730fab5a12d3147972ea00a638a871f25cb93130ad9e8e1272bbc6c6e2117db', 1),
	(218, 436, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 3, '{"code": "reception", "name_ar": "موظف استقبال", "name_en": "Receptionist", "role_id": 3, "is_active": true, "created_at": "2026-07-18T21:59:08.579833+03:00", "description": "Patient & appointment management, no clinical records", "facility_id": 1}', 'db-trigger', 'a730fab5a12d3147972ea00a638a871f25cb93130ad9e8e1272bbc6c6e2117db', '059649ddf4c5d022237428a1d4c334022f5aed576974af6ae21c062d038543f4', 1),
	(219, 438, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 4, '{"code": "pharmacist", "name_ar": "صيدلي", "name_en": "Pharmacist", "role_id": 4, "is_active": true, "created_at": "2026-07-18T21:59:08.579833+03:00", "description": "Medication management, dispensing, interactions", "facility_id": 1}', 'db-trigger', '059649ddf4c5d022237428a1d4c334022f5aed576974af6ae21c062d038543f4', '3b9bd6f4322a8e63e0daffea7cf02d0ea887b055982b275450663873c3eb5ecd', 1),
	(220, 440, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 5, '{"code": "nurse", "name_ar": "ممرض/فني", "name_en": "Nurse/Technician", "role_id": 5, "is_active": true, "created_at": "2026-07-18T21:59:08.579833+03:00", "description": "Execute orders, vitals, preliminary results", "facility_id": 1}', 'db-trigger', '3b9bd6f4322a8e63e0daffea7cf02d0ea887b055982b275450663873c3eb5ecd', '89f46dad9c232f4cfc19e08333b14ebc762332ca462782f346eb0448004dceb5', 1),
	(243, 486, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 8, '{"role_id": 8, "facility_id": 1, "permission_id": 13}', 'db-trigger', 'd687c381211f153a9b0e3076fb2706c5ea4efbdeeb4ac0b70541ea29c45e1da7', 'c7ff2425d78101d11a8a8f4d6ebe3bf5c488ad232bc7eb6da86f4bcf6decc338', 1),
	(221, 442, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 6, '{"code": "accountant", "name_ar": "محاسب", "name_en": "Accountant", "role_id": 6, "is_active": true, "created_at": "2026-07-18T21:59:08.579833+03:00", "description": "Billing, payments, financial reports", "facility_id": 1}', 'db-trigger', '89f46dad9c232f4cfc19e08333b14ebc762332ca462782f346eb0448004dceb5', '6d252fc581abfe30d46d46a62190d52911ee9de9872e315a5fa902456cfa29fc', 1),
	(222, 444, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 7, '{"code": "sysadmin", "name_ar": "مدير النظام", "name_en": "System Administrator", "role_id": 7, "is_active": true, "created_at": "2026-07-18T21:59:08.579833+03:00", "description": "User management, roles, settings, full access", "facility_id": 1}', 'db-trigger', '6d252fc581abfe30d46d46a62190d52911ee9de9872e315a5fa902456cfa29fc', '3a90b4003c49d5e89291fa0d205e0a9003eca2835fe8d9d875ba011176856164', 1),
	(223, 446, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 8, '{"code": "doctor", "name_ar": "طبيب", "name_en": "Doctor", "role_id": 8, "is_active": true, "created_at": "2026-07-18T21:59:08.579833+03:00", "description": "Read/write records, order tests, prescribe", "facility_id": 1}', 'db-trigger', '3a90b4003c49d5e89291fa0d205e0a9003eca2835fe8d9d875ba011176856164', 'e16786b88a3f9136f813b6956c643797c88eb40442a37c3b8e2f15d11b177209', 1),
	(224, 448, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 9, '{"code": "store_mgr", "name_ar": "مدير المخزن", "name_en": "Warehouse Manager", "role_id": 9, "is_active": true, "created_at": "2026-07-18T21:59:08.579833+03:00", "description": "Inventory & batch management", "facility_id": 1}', 'db-trigger', 'e16786b88a3f9136f813b6956c643797c88eb40442a37c3b8e2f15d11b177209', 'aa3a3b4c1f82866d76b13c3247eb5325f42c1080ad4053000c9ea95de264d7f1', 1),
	(225, 450, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 8, '{"code": "appointment.manage", "description": "Book/modify appointments", "facility_id": 1, "permission_id": 8}', 'db-trigger', 'aa3a3b4c1f82866d76b13c3247eb5325f42c1080ad4053000c9ea95de264d7f1', '4936c3d99d8390cd44a689c82eb3a2608947acc9231eba4e6bca4fffc8b62186', 1),
	(226, 452, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 9, '{"code": "inventory.manage", "description": "Manage inventory & batches", "facility_id": 1, "permission_id": 9}', 'db-trigger', '4936c3d99d8390cd44a689c82eb3a2608947acc9231eba4e6bca4fffc8b62186', '6d004ba038e72a97656c807df9fbdc4c55d54cab4750f6c948d0558cf2f786f9', 1),
	(227, 454, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 10, '{"code": "emr.write", "description": "Write clinical records / orders / prescriptions", "facility_id": 1, "permission_id": 10}', 'db-trigger', '6d004ba038e72a97656c807df9fbdc4c55d54cab4750f6c948d0558cf2f786f9', 'f9ab0d4a8cbffc6d4e70b1142e58ff94342127028a506d57c914552ab13c14d0', 1),
	(228, 456, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 11, '{"code": "pharmacy.dispense", "description": "Dispense medications", "facility_id": 1, "permission_id": 11}', 'db-trigger', 'f9ab0d4a8cbffc6d4e70b1142e58ff94342127028a506d57c914552ab13c14d0', '64adad3f375ad38a3063a8ec9f1daf7cfe9f66fe7eb9985cf1109a8a0af3132d', 1),
	(229, 458, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 12, '{"code": "order.execute", "description": "Execute orders / enter preliminary results", "facility_id": 1, "permission_id": 12}', 'db-trigger', '64adad3f375ad38a3063a8ec9f1daf7cfe9f66fe7eb9985cf1109a8a0af3132d', '234b5da2bea0eab42628affe220778a2f24d45a8c51ff1352f74d39629b522e6', 1),
	(230, 460, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 13, '{"code": "emr.read", "description": "Read clinical records", "facility_id": 1, "permission_id": 13}', 'db-trigger', '234b5da2bea0eab42628affe220778a2f24d45a8c51ff1352f74d39629b522e6', 'abff6b72d9285e79abe25f99777ea88f30155d2ce25cc28a4bf6c5a89a262e85', 1),
	(231, 462, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 14, '{"code": "billing.manage", "description": "Create/modify invoices & payments", "facility_id": 1, "permission_id": 14}', 'db-trigger', 'abff6b72d9285e79abe25f99777ea88f30155d2ce25cc28a4bf6c5a89a262e85', 'd55073ac83eef32393502365bcbe470b9491d8bea0d673654a70dadc89b469fa', 1),
	(232, 464, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 15, '{"code": "patient.read", "description": "View patient demographics", "facility_id": 1, "permission_id": 15}', 'db-trigger', 'd55073ac83eef32393502365bcbe470b9491d8bea0d673654a70dadc89b469fa', 'e1130109ff58e554462d617343329d3fb7e0a0aff795ec937c74cdea652a64f4', 1),
	(233, 466, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 16, '{"code": "lab_rad.result", "description": "Enter lab/radiology results & reports", "facility_id": 1, "permission_id": 16}', 'db-trigger', 'e1130109ff58e554462d617343329d3fb7e0a0aff795ec937c74cdea652a64f4', 'f73eefce259c0bd86f29f28a7400a349e363d7ea5d09b0945da5dfe9b573b1a5', 1),
	(234, 468, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 17, '{"code": "patient.write", "description": "Create/edit patients", "facility_id": 1, "permission_id": 17}', 'db-trigger', 'f73eefce259c0bd86f29f28a7400a349e363d7ea5d09b0945da5dfe9b573b1a5', '873fb727bf68eb1fa6c3ebcdade5d91c45d53489b7d7fad681cf6f6024e97fb5', 1),
	(235, 470, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 18, '{"code": "admin.all", "description": "Full administrative access", "facility_id": 1, "permission_id": 18}', 'db-trigger', '873fb727bf68eb1fa6c3ebcdade5d91c45d53489b7d7fad681cf6f6024e97fb5', 'e58156ea4009f7a679ab1bc75a1f35a3123d0a260b9a6e147a12ad929e42b14d', 1),
	(236, 472, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 19, '{"code": "billing.read", "description": "View financial reports", "facility_id": 1, "permission_id": 19}', 'db-trigger', 'e58156ea4009f7a679ab1bc75a1f35a3123d0a260b9a6e147a12ad929e42b14d', '11f2d8080f742070349d5809de6e5e9710528adfb117a33a8272c26a877141a4', 1),
	(237, 474, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 8, '{"role_id": 8, "facility_id": 1, "permission_id": 8}', 'db-trigger', '11f2d8080f742070349d5809de6e5e9710528adfb117a33a8272c26a877141a4', '6df8cb49c2f064ad9d0f1b2dbfb014cb79a5fbfb5f15a4d5740d3c4c8636d30c', 1),
	(238, 476, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 3, '{"role_id": 3, "facility_id": 1, "permission_id": 8}', 'db-trigger', '6df8cb49c2f064ad9d0f1b2dbfb014cb79a5fbfb5f15a4d5740d3c4c8636d30c', 'fb933029cc5ed848b076dc84956f9feaf893c2f09ca8e34c2cb97a11851ed0af', 1),
	(239, 478, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 9, '{"role_id": 9, "facility_id": 1, "permission_id": 9}', 'db-trigger', 'fb933029cc5ed848b076dc84956f9feaf893c2f09ca8e34c2cb97a11851ed0af', '9a717c9a93520618b8f97bbdeb5c78f059fad145592d4ad6a1d29939b13eacb6', 1),
	(240, 480, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 8, '{"role_id": 8, "facility_id": 1, "permission_id": 10}', 'db-trigger', '9a717c9a93520618b8f97bbdeb5c78f059fad145592d4ad6a1d29939b13eacb6', '39191d01d22db05bc7403cff4fa95123d57ac11b3ad1bf82553052f08a71e2ad', 1),
	(244, 488, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 7, '{"role_id": 7, "facility_id": 1, "permission_id": 13}', 'db-trigger', 'c7ff2425d78101d11a8a8f4d6ebe3bf5c488ad232bc7eb6da86f4bcf6decc338', '5c7e2031d9b8fdfabbae1cf1e1613dd1e87fc159251d247147c1360f3fbfe701', 1),
	(245, 490, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 5, '{"role_id": 5, "facility_id": 1, "permission_id": 13}', 'db-trigger', '5c7e2031d9b8fdfabbae1cf1e1613dd1e87fc159251d247147c1360f3fbfe701', 'f96cf6523de08b49131309606821d67c5c48310492f99c8b4899a1c554ca2990', 1),
	(246, 492, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 4, '{"role_id": 4, "facility_id": 1, "permission_id": 13}', 'db-trigger', 'f96cf6523de08b49131309606821d67c5c48310492f99c8b4899a1c554ca2990', '45df9bcda2c8cc49d8f301640607d23bb70e22dee8a0afd96437452cdbf3146c', 1),
	(247, 494, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 2, '{"role_id": 2, "facility_id": 1, "permission_id": 13}', 'db-trigger', '45df9bcda2c8cc49d8f301640607d23bb70e22dee8a0afd96437452cdbf3146c', '8a048a129108228e46e1cde2847c97d651debc948dcbdff7752e0532e859200d', 1),
	(248, 496, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 6, '{"role_id": 6, "facility_id": 1, "permission_id": 14}', 'db-trigger', '8a048a129108228e46e1cde2847c97d651debc948dcbdff7752e0532e859200d', 'd4896c206bd8a8eb94befa3326c61948d5889e520fcc1ceca767baf23cbf01ac', 1),
	(249, 498, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 8, '{"role_id": 8, "facility_id": 1, "permission_id": 15}', 'db-trigger', 'd4896c206bd8a8eb94befa3326c61948d5889e520fcc1ceca767baf23cbf01ac', '38e618c11e0f87231cb0e4474567c6b5a862278232c226ef9c1b5ee2b4dc95bb', 1),
	(250, 500, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 7, '{"role_id": 7, "facility_id": 1, "permission_id": 15}', 'db-trigger', '38e618c11e0f87231cb0e4474567c6b5a862278232c226ef9c1b5ee2b4dc95bb', '7b1054684d604e0a059cbe5630ac70cc8145867d62eb673e066575237f24cf47', 1),
	(251, 502, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 5, '{"role_id": 5, "facility_id": 1, "permission_id": 15}', 'db-trigger', '7b1054684d604e0a059cbe5630ac70cc8145867d62eb673e066575237f24cf47', 'e2346bbf8a937a2c653f5c11aa6ea3792a8f11662cd94f2b7a31910c0fa62ec3', 1),
	(252, 504, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 3, '{"role_id": 3, "facility_id": 1, "permission_id": 15}', 'db-trigger', 'e2346bbf8a937a2c653f5c11aa6ea3792a8f11662cd94f2b7a31910c0fa62ec3', '181a3b308493e1ac62c9d25a390a2b86cd8326ce9576abb8e240975acfc10d5a', 1),
	(253, 506, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 2, '{"role_id": 2, "facility_id": 1, "permission_id": 16}', 'db-trigger', '181a3b308493e1ac62c9d25a390a2b86cd8326ce9576abb8e240975acfc10d5a', 'a80c5c88fb888309829da73410b152f6d8c7f98a6e381df569dc2c494d24153b', 1),
	(254, 508, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 3, '{"role_id": 3, "facility_id": 1, "permission_id": 17}', 'db-trigger', 'a80c5c88fb888309829da73410b152f6d8c7f98a6e381df569dc2c494d24153b', 'a3300c0c8be711a3d39f9d98a0f11b2486dd38b3552f8b141a941a721c242cfd', 1),
	(255, 510, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 7, '{"role_id": 7, "facility_id": 1, "permission_id": 18}', 'db-trigger', 'a3300c0c8be711a3d39f9d98a0f11b2486dd38b3552f8b141a941a721c242cfd', '68dde63dbf50693204fd544884a4e4dbd9313404b9b34406b7062ae4b8cac924', 1),
	(256, 512, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 7, '{"role_id": 7, "facility_id": 1, "permission_id": 19}', 'db-trigger', '68dde63dbf50693204fd544884a4e4dbd9313404b9b34406b7062ae4b8cac924', 'd4e4abd5cb309a71f8e176c83f6ad2ef71b1ee30094aa8ca7317dca98cb21028', 1),
	(257, 514, '2026-07-18 21:59:08.579833+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 6, '{"role_id": 6, "facility_id": 1, "permission_id": 19}', 'db-trigger', 'd4e4abd5cb309a71f8e176c83f6ad2ef71b1ee30094aa8ca7317dca98cb21028', '9c2b2371cdb688c1f591850a5e8ae68d44d16ed64e4c8835994d77d734fa7a66', 1),
	(258, 516, '2026-07-18 21:59:08.595405+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 20, '{"code": "hr.read", "description": "Read HR / workforce data", "facility_id": 1, "permission_id": 20}', 'db-trigger', '9c2b2371cdb688c1f591850a5e8ae68d44d16ed64e4c8835994d77d734fa7a66', '87a4ca4eeccc9abad6f24165e07e931f142dde2eb8dd06d217dd6fb0372f26c0', 1),
	(259, 518, '2026-07-18 21:59:08.595405+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 7, '{"role_id": 7, "facility_id": 1, "permission_id": 20}', 'db-trigger', '87a4ca4eeccc9abad6f24165e07e931f142dde2eb8dd06d217dd6fb0372f26c0', '3cbb29ee84d54347f8a61bf9affc62541bf98dd74076e13f4ab279217e59a25f', 1),
	(260, 520, '2026-07-18 21:59:08.646446+03', 'create', 'info', NULL, NULL, 'mcms_core', 'system_flag', 1, '{"flag": "maintenance_mode", "value": "false", "updated_at": "2026-07-18T21:59:08.646446+03:00", "facility_id": 1}', 'db-trigger', '3cbb29ee84d54347f8a61bf9affc62541bf98dd74076e13f4ab279217e59a25f', 'ac91c82382ec7fdaf21d5e29910b2d47a7bc8a58cfbc0e447ef2fad0447bc226', 1),
	(261, 522, '2026-07-18 21:59:08.646446+03', 'create', 'info', NULL, NULL, 'mcms_core', 'system_flag', 1, '{"flag": "last_schema_sync", "value": "never", "updated_at": "2026-07-18T21:59:08.646446+03:00", "facility_id": 1}', 'db-trigger', 'ac91c82382ec7fdaf21d5e29910b2d47a7bc8a58cfbc0e447ef2fad0447bc226', 'e043a9a1ea8aeb937cdef09f78bacb4e38629f06fd54276c3b661725c5fc7b24', 1),
	(262, 524, '2026-07-18 21:59:08.656874+03', 'create', 'info', NULL, NULL, 'mcms_core', 'party', 1, '{"code": null, "gender": null, "tax_id": null, "party_id": 1, "is_active": true, "blood_type": "unknown", "created_at": "2026-07-18T21:59:08.656874+03:00", "legal_name": null, "party_type": "person", "updated_at": "2026-07-18T21:59:08.656874+03:00", "facility_id": 1, "national_id": null, "display_name": "Test Admin", "date_of_birth": null, "preferred_language": "en"}', 'db-trigger', 'e043a9a1ea8aeb937cdef09f78bacb4e38629f06fd54276c3b661725c5fc7b24', '2f688db08545aae2f15df2544a14525bd50e83d265a4c2b7da65ec84233c01fa', 1),
	(263, 526, '2026-07-18 21:59:08.656874+03', 'create', 'info', NULL, NULL, 'mcms_core', 'party', 2, '{"code": null, "gender": null, "tax_id": null, "party_id": 2, "is_active": true, "blood_type": "unknown", "created_at": "2026-07-18T21:59:08.656874+03:00", "legal_name": null, "party_type": "person", "updated_at": "2026-07-18T21:59:08.656874+03:00", "facility_id": 1, "national_id": null, "display_name": "Test Acc1", "date_of_birth": null, "preferred_language": "en"}', 'db-trigger', '2f688db08545aae2f15df2544a14525bd50e83d265a4c2b7da65ec84233c01fa', '5a5a4a4a193b0588763c81cb9312522e46f57a6e3cefa0e1a159e04869f424e9', 1),
	(391, 752, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emergency', 'ed_bed', 2, '{"notes": "demo", "bed_label": "demo", "ed_bed_id": 2, "triage_id": 2, "assigned_at": "2026-07-18T18:59:19.298741+00:00", "facility_id": 1, "released_at": "2026-07-18T18:59:19.299741+00:00", "observation_minutes": 1}', 'db-trigger', 'aba87fc5ad597423175de327dc87ad81a03cd08a14c989e82c098bb4e5c6d6c0', 'db6bafaa7e5eaa9d1bf1565608558bf1875d048858382900e594b0e29b9e8afd', 1),
	(264, 528, '2026-07-18 21:59:08.656874+03', 'create', 'info', NULL, NULL, 'mcms_core', 'app_user', 1, '{"role": "admin", "user_id": 1, "party_id": 1, "username": "admin", "is_active": true, "created_at": "2026-07-18T21:59:08.656874+03:00", "updated_at": "2026-07-18T21:59:08.656874+03:00", "facility_id": null, "locked_until": null, "failed_logins": 0, "last_login_at": null, "password_hash": "!", "specialization": null}', 'db-trigger', '5a5a4a4a193b0588763c81cb9312522e46f57a6e3cefa0e1a159e04869f424e9', '442f3464bf970eb7acf82d216db91e4e19799657c72f4f8ef0776137116687ad', 1),
	(265, 530, '2026-07-18 21:59:08.656874+03', 'create', 'info', NULL, NULL, 'mcms_core', 'app_user', 2, '{"role": "billing_clerk", "user_id": 2, "party_id": 2, "username": "acc1", "is_active": true, "created_at": "2026-07-18T21:59:08.656874+03:00", "updated_at": "2026-07-18T21:59:08.656874+03:00", "facility_id": null, "locked_until": null, "failed_logins": 0, "last_login_at": null, "password_hash": "!", "specialization": null}', 'db-trigger', '442f3464bf970eb7acf82d216db91e4e19799657c72f4f8ef0776137116687ad', '2ca0986c936e506d7c55613fbf30a2054d271f6221ea7f68ea79e9b471b0a3c6', 1),
	(266, 532, '2026-07-18 21:59:08.656874+03', 'create', 'info', NULL, NULL, 'mcms_core', 'user_role_map', 7, '{"role_id": 7, "user_id": 1, "facility_id": 1, "department_id": null}', 'db-trigger', '2ca0986c936e506d7c55613fbf30a2054d271f6221ea7f68ea79e9b471b0a3c6', '74f1f987b4bf1c1b4615544f7212a50ab1834cbbcee1137de03e40f7797c530f', 1),
	(267, 534, '2026-07-18 21:59:08.656874+03', 'create', 'info', NULL, NULL, 'mcms_core', 'user_role_map', 6, '{"role_id": 6, "user_id": 2, "facility_id": 1, "department_id": null}', 'db-trigger', '74f1f987b4bf1c1b4615544f7212a50ab1834cbbcee1137de03e40f7797c530f', 'f9babcd592448613cc75d1713508a94c042e39e28e44978c0ad51b01f5f6674f', 1),
	(268, 536, '2026-07-18 21:59:08.726945+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_interaction', 1, '{"severity": "moderate", "mechanism": "NSAID + paracetamol", "created_at": "2026-07-18T21:59:08.726945+03:00", "management": "Prefer single agent; monitor for GI bleed if combined", "source_ref": null, "facility_id": 1, "drug_item_id_a": 2, "drug_item_id_b": 3, "interaction_id": 2, "clinical_effect": "Increased risk of GI bleeding and renal impairment with combined frequent use"}', 'db-trigger', 'f9babcd592448613cc75d1713508a94c042e39e28e44978c0ad51b01f5f6674f', 'f20246e6cb170696b51ed3af6f4a9fa91b074afc5d7d7dea07c4cac175b1ac35', 1),
	(269, 538, '2026-07-18 21:59:08.726945+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_interaction', 1, '{"severity": "major", "mechanism": "NSAID + antiplatelet (ASA)", "created_at": "2026-07-18T21:59:08.726945+03:00", "management": "Avoid combination unless specifically indicated; GI prophylaxis if unavoidable", "source_ref": null, "facility_id": 1, "drug_item_id_a": 3, "drug_item_id_b": 4, "interaction_id": 3, "clinical_effect": "Additive inhibition of platelet aggregation -> major bleeding risk"}', 'db-trigger', 'f20246e6cb170696b51ed3af6f4a9fa91b074afc5d7d7dea07c4cac175b1ac35', '5f7b30c4138da54487e20d617eb2f0eaf73b79732379df566957b1d716b718eb', 1),
	(270, 540, '2026-07-18 21:59:08.726945+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_interaction', 1, '{"severity": "moderate", "mechanism": "Paracetamol + ASA", "created_at": "2026-07-18T21:59:08.726945+03:00", "management": "Use lowest effective doses; monitor renal function", "source_ref": null, "facility_id": 1, "drug_item_id_a": 2, "drug_item_id_b": 4, "interaction_id": 4, "clinical_effect": "Additive analgesic but increased GI/renal risk at high doses"}', 'db-trigger', '5f7b30c4138da54487e20d617eb2f0eaf73b79732379df566957b1d716b718eb', '1a96755583883f06eb14eac735b08672279c22e81ce39ea77942ecf48d4d7604', 1),
	(271, 542, '2026-07-18 21:59:08.726945+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_interaction', 1, '{"severity": "major", "mechanism": "ASA + omeprazole", "created_at": "2026-07-18T21:59:08.726945+03:00", "management": "Co-prescribe PPI (e.g. omeprazole) with long-term ASA", "source_ref": null, "facility_id": 1, "drug_item_id_a": 4, "drug_item_id_b": 10, "interaction_id": 5, "clinical_effect": "ASA irritates gastric mucosa; PPI reduces ulcer risk"}', 'db-trigger', '1a96755583883f06eb14eac735b08672279c22e81ce39ea77942ecf48d4d7604', '2d1910ab92655d774c49fbf920fcef12d99802c4c3ba8213d84ad67e1aeb0318', 1),
	(272, 544, '2026-07-18 21:59:08.726945+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_interaction', 1, '{"severity": "minor", "mechanism": "Metformin + omeprazole", "created_at": "2026-07-18T21:59:08.726945+03:00", "management": "Generally safe; routine monitoring sufficient", "source_ref": null, "facility_id": 1, "drug_item_id_a": 7, "drug_item_id_b": 10, "interaction_id": 6, "clinical_effect": "Omeprazole may marginally raise metformin levels"}', 'db-trigger', '2d1910ab92655d774c49fbf920fcef12d99802c4c3ba8213d84ad67e1aeb0318', '508c691de1114fe943d3f5ba150679565d29bfabfb1e55d3f45dd10e64337095', 1),
	(273, 546, '2026-07-18 21:59:08.726945+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_interaction', 1, '{"severity": "minor", "mechanism": "Ibuprofen + omeprazole", "created_at": "2026-07-18T21:59:08.726945+03:00", "management": "Co-prescribe PPI for patients on chronic NSAIDs", "source_ref": null, "facility_id": 1, "drug_item_id_a": 3, "drug_item_id_b": 10, "interaction_id": 7, "clinical_effect": "NSAID ulcers mitigated by PPI"}', 'db-trigger', '508c691de1114fe943d3f5ba150679565d29bfabfb1e55d3f45dd10e64337095', '3e6721304424d0affd29e11a351e3d79595a59a58eb94bd7ca85249b7cb38147', 1),
	(274, 548, '2026-07-18 21:59:14.437289+03', 'create', 'info', NULL, NULL, 'mcms_core', 'party', 99004, '{"code": null, "gender": null, "tax_id": null, "party_id": 99004, "is_active": true, "blood_type": "unknown", "created_at": "2026-07-18T18:59:14.437289+00:00", "legal_name": null, "party_type": "person", "updated_at": "2026-07-18T18:59:14.437289+00:00", "facility_id": 1, "national_id": null, "display_name": "System Administrator", "date_of_birth": null, "preferred_language": "ar"}', 'db-trigger', '3e6721304424d0affd29e11a351e3d79595a59a58eb94bd7ca85249b7cb38147', 'bfcb9cebfbfd7cdb1551c2832237cf13af3cf2f940ff4504852952678cb03d3f', 1),
	(275, 550, '2026-07-18 21:59:14.460855+03', 'update', 'info', NULL, NULL, 'mcms_core', 'app_user', 1, '{"role": "admin", "user_id": 1, "party_id": 1, "username": "admin", "is_active": true, "created_at": "2026-07-18T18:59:08.656874+00:00", "updated_at": "2026-07-18T18:59:08.656874+00:00", "facility_id": null, "locked_until": null, "failed_logins": 0, "last_login_at": null, "password_hash": "!", "specialization": null}', 'db-trigger', 'bfcb9cebfbfd7cdb1551c2832237cf13af3cf2f940ff4504852952678cb03d3f', '7e47a35db2d186cf895292227096b1640299fde25922e5c6fae08c10ba73f8a9', 1),
	(276, 552, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'party', 99005, '{"code": "MRN-DEMO-001", "gender": "male", "tax_id": null, "party_id": 99005, "is_active": true, "blood_type": null, "created_at": "2026-07-18T18:59:17.929136+00:00", "legal_name": "Ahmad Mansour", "party_type": "person", "updated_at": "2026-07-18T18:59:17.929136+00:00", "facility_id": 1, "national_id": "MRN-DEMO-001", "display_name": "Ahmad Mansour", "date_of_birth": "1985-01-01", "preferred_language": "en"}', 'db-trigger', '7e47a35db2d186cf895292227096b1640299fde25922e5c6fae08c10ba73f8a9', 'c2fffe7845a2e1ced0ff38f6c9f8f139bf061ec640e48bb604a230da10317c39', 1),
	(392, 753, '2026-07-18 21:59:17.914572+03', 'medication_administered', 'info', 99, 99003, 'mcms_rx', 'administration', 2, '{"dose": "demo", "drug_item_id": 2}', 'mcms', 'db6bafaa7e5eaa9d1bf1565608558bf1875d048858382900e594b0e29b9e8afd', '8b2cc7b993fc6ae8ead310238463767817eaca3185892a148ab19852d7bbbd9f', 1),
	(277, 554, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'patient', 99002, '{"mrn": "MRN-DEMO-001", "fhir_id": null, "hl7_mpi": null, "party_id": 99005, "created_at": "2026-07-18T18:59:17.960864+00:00", "patient_id": 99002, "updated_at": "2026-07-18T18:59:17.960864+00:00", "facility_id": 1, "is_deceased": false, "living_will": null, "organ_donor": null, "coverage_verified": null, "insurance_group_no": "GRP-1", "insurance_provider": "Demo Insurer", "preferred_language": "en", "insurance_policy_no": "POL-MRN-DEMO-001", "coverage_verified_at": null, "next_of_kin_party_id": 99005, "emergency_contact_name": "Demo Contact", "emergency_contact_phone": "+10000000000"}', 'db-trigger', 'c2fffe7845a2e1ced0ff38f6c9f8f139bf061ec640e48bb604a230da10317c39', 'a1d809a355eb1f2481e8059774cca6e8bcf2da091201e3e9fd4a44f6c5cd3716', 1),
	(278, 556, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'party', 99006, '{"code": "MRN-DEMO-002", "gender": "female", "tax_id": null, "party_id": 99006, "is_active": true, "blood_type": null, "created_at": "2026-07-18T18:59:17.966972+00:00", "legal_name": "Layla Haddad", "party_type": "person", "updated_at": "2026-07-18T18:59:17.966972+00:00", "facility_id": 1, "national_id": "MRN-DEMO-002", "display_name": "Layla Haddad", "date_of_birth": "1985-01-01", "preferred_language": "en"}', 'db-trigger', 'a1d809a355eb1f2481e8059774cca6e8bcf2da091201e3e9fd4a44f6c5cd3716', '4755e26188e4fa5480fa4ce9a8ddf1db996083870142fbb50adf000addad700b', 1),
	(279, 558, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'patient', 99003, '{"mrn": "MRN-DEMO-002", "fhir_id": null, "hl7_mpi": null, "party_id": 99006, "created_at": "2026-07-18T18:59:17.974834+00:00", "patient_id": 99003, "updated_at": "2026-07-18T18:59:17.974834+00:00", "facility_id": 1, "is_deceased": false, "living_will": null, "organ_donor": null, "coverage_verified": null, "insurance_group_no": "GRP-1", "insurance_provider": "Demo Insurer", "preferred_language": "en", "insurance_policy_no": "POL-MRN-DEMO-002", "coverage_verified_at": null, "next_of_kin_party_id": 99006, "emergency_contact_name": "Demo Contact", "emergency_contact_phone": "+10000000000"}', 'db-trigger', '4755e26188e4fa5480fa4ce9a8ddf1db996083870142fbb50adf000addad700b', 'f596d82edc62d2490cc79ed4b3b9c42c5826c7370fb3a919575817c8a1df8220', 1),
	(280, 560, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'party', 99007, '{"code": "MRN-DEMO-003", "gender": "male", "tax_id": null, "party_id": 99007, "is_active": true, "blood_type": null, "created_at": "2026-07-18T18:59:17.979058+00:00", "legal_name": "Karim Nasser", "party_type": "person", "updated_at": "2026-07-18T18:59:17.979058+00:00", "facility_id": 1, "national_id": "MRN-DEMO-003", "display_name": "Karim Nasser", "date_of_birth": "1985-01-01", "preferred_language": "en"}', 'db-trigger', 'f596d82edc62d2490cc79ed4b3b9c42c5826c7370fb3a919575817c8a1df8220', 'd3883db911779842e083d207d39e1e4c1b0dc82b393c7cff6f76b2dc6342b680', 1),
	(281, 562, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'patient', 99004, '{"mrn": "MRN-DEMO-003", "fhir_id": null, "hl7_mpi": null, "party_id": 99007, "created_at": "2026-07-18T18:59:17.982059+00:00", "patient_id": 99004, "updated_at": "2026-07-18T18:59:17.982059+00:00", "facility_id": 1, "is_deceased": false, "living_will": null, "organ_donor": null, "coverage_verified": null, "insurance_group_no": "GRP-1", "insurance_provider": "Demo Insurer", "preferred_language": "en", "insurance_policy_no": "POL-MRN-DEMO-003", "coverage_verified_at": null, "next_of_kin_party_id": 99007, "emergency_contact_name": "Demo Contact", "emergency_contact_phone": "+10000000000"}', 'db-trigger', 'd3883db911779842e083d207d39e1e4c1b0dc82b393c7cff6f76b2dc6342b680', '4084a700f7877bcf20006ec9c2ce031312c7582ed99714b5e755d0616f79769f', 1),
	(282, 564, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'party', 99008, '{"code": "MRN-DEMO-004", "gender": "female", "tax_id": null, "party_id": 99008, "is_active": true, "blood_type": null, "created_at": "2026-07-18T18:59:17.991907+00:00", "legal_name": "Sara Khoury", "party_type": "person", "updated_at": "2026-07-18T18:59:17.991907+00:00", "facility_id": 1, "national_id": "MRN-DEMO-004", "display_name": "Sara Khoury", "date_of_birth": "1985-01-01", "preferred_language": "en"}', 'db-trigger', '4084a700f7877bcf20006ec9c2ce031312c7582ed99714b5e755d0616f79769f', '15ec22cb89c418b82fe0cc75a8cc3d54af42a270e7f839affb01fbd39207798e', 1),
	(283, 566, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'patient', 99005, '{"mrn": "MRN-DEMO-004", "fhir_id": null, "hl7_mpi": null, "party_id": 99008, "created_at": "2026-07-18T18:59:17.994906+00:00", "patient_id": 99005, "updated_at": "2026-07-18T18:59:17.994906+00:00", "facility_id": 1, "is_deceased": false, "living_will": null, "organ_donor": null, "coverage_verified": null, "insurance_group_no": "GRP-1", "insurance_provider": "Demo Insurer", "preferred_language": "en", "insurance_policy_no": "POL-MRN-DEMO-004", "coverage_verified_at": null, "next_of_kin_party_id": 99008, "emergency_contact_name": "Demo Contact", "emergency_contact_phone": "+10000000000"}', 'db-trigger', '15ec22cb89c418b82fe0cc75a8cc3d54af42a270e7f839affb01fbd39207798e', 'd06ed39bc404fcc2e4aeda4be93924a3c2f5b7c27fd3bfcaba1f8de412dec5cb', 1),
	(284, 568, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'party', 99009, '{"code": "MRN-DEMO-005", "gender": "male", "tax_id": null, "party_id": 99009, "is_active": true, "blood_type": null, "created_at": "2026-07-18T18:59:17.998016+00:00", "legal_name": "Omar Saleh", "party_type": "person", "updated_at": "2026-07-18T18:59:17.998016+00:00", "facility_id": 1, "national_id": "MRN-DEMO-005", "display_name": "Omar Saleh", "date_of_birth": "1985-01-01", "preferred_language": "en"}', 'db-trigger', 'd06ed39bc404fcc2e4aeda4be93924a3c2f5b7c27fd3bfcaba1f8de412dec5cb', 'b6d21b3b0e3b13fd3db667d44f7ae611b7ef6a49e397e0be4833ce0a3c72053a', 1),
	(285, 570, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'patient', 99006, '{"mrn": "MRN-DEMO-005", "fhir_id": null, "hl7_mpi": null, "party_id": 99009, "created_at": "2026-07-18T18:59:18.003106+00:00", "patient_id": 99006, "updated_at": "2026-07-18T18:59:18.003106+00:00", "facility_id": 1, "is_deceased": false, "living_will": null, "organ_donor": null, "coverage_verified": null, "insurance_group_no": "GRP-1", "insurance_provider": "Demo Insurer", "preferred_language": "en", "insurance_policy_no": "POL-MRN-DEMO-005", "coverage_verified_at": null, "next_of_kin_party_id": 99009, "emergency_contact_name": "Demo Contact", "emergency_contact_phone": "+10000000000"}', 'db-trigger', 'b6d21b3b0e3b13fd3db667d44f7ae611b7ef6a49e397e0be4833ce0a3c72053a', '6c3d28138e8147ac735311203b1186bf6ebe69a1374544a59ce3b666941a8959', 1),
	(286, 572, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'notification', 2, '{"body": "Appointment on 2026-07-19 03:59 (booked).", "status": "pending", "channel": "in_app", "read_at": null, "sent_at": null, "subject": "Appointment booked", "category": "appointment_reminder", "source_id": 2, "created_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "source_table": "appointment", "source_schema": "mcms_clinic", "notification_id": 2, "recipient_user_id": 1, "recipient_party_id": 99005}', 'db-trigger', '6c3d28138e8147ac735311203b1186bf6ebe69a1374544a59ce3b666941a8959', '1d13d8ae2694d8694c477a220bca6d6d7467f490b6ec402216cf5bb0267bd0ef', 1),
	(287, 573, '2026-07-18 21:59:17.914572+03', 'appointment_booked', 'info', 1, 99005, 'mcms_clinic', 'appointment', 2, '{"status": "booked", "starts_at": "2026-07-19T03:59:17.913956+00:00", "department_id": 1}', 'mcms', '1d13d8ae2694d8694c477a220bca6d6d7467f490b6ec402216cf5bb0267bd0ef', 'd6df0b19f234f2ffe256840667e64a8e2fe549ade938d188e01b60c89d7cebc6', 1),
	(288, 575, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'notification', 3, '{"body": "Appointment on 2026-07-20 03:59 (booked).", "status": "pending", "channel": "in_app", "read_at": null, "sent_at": null, "subject": "Appointment booked", "category": "appointment_reminder", "source_id": 3, "created_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "source_table": "appointment", "source_schema": "mcms_clinic", "notification_id": 3, "recipient_user_id": 1, "recipient_party_id": 99006}', 'db-trigger', 'd6df0b19f234f2ffe256840667e64a8e2fe549ade938d188e01b60c89d7cebc6', '51c36b2187390baf45c5d75144082b117fcfd471e2cdb4163eda0d476616ac0b', 1),
	(289, 576, '2026-07-18 21:59:17.914572+03', 'appointment_booked', 'info', 1, 99006, 'mcms_clinic', 'appointment', 3, '{"status": "booked", "starts_at": "2026-07-20T03:59:17.913956+00:00", "department_id": 1}', 'mcms', '51c36b2187390baf45c5d75144082b117fcfd471e2cdb4163eda0d476616ac0b', 'f5033866db9500a71486aae170c8de7090e3ff77131981a350fa6a557eccec3d', 1),
	(290, 578, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'notification', 4, '{"body": "Appointment on 2026-07-21 03:59 (booked).", "status": "pending", "channel": "in_app", "read_at": null, "sent_at": null, "subject": "Appointment booked", "category": "appointment_reminder", "source_id": 4, "created_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "source_table": "appointment", "source_schema": "mcms_clinic", "notification_id": 4, "recipient_user_id": 1, "recipient_party_id": 99007}', 'db-trigger', 'f5033866db9500a71486aae170c8de7090e3ff77131981a350fa6a557eccec3d', '8cdbff613ba2229ab518ede32a3744b1d7bd4c1b323ed990589690685c2d7dd8', 1),
	(291, 579, '2026-07-18 21:59:17.914572+03', 'appointment_booked', 'info', 1, 99007, 'mcms_clinic', 'appointment', 4, '{"status": "booked", "starts_at": "2026-07-21T03:59:17.913956+00:00", "department_id": 1}', 'mcms', '8cdbff613ba2229ab518ede32a3744b1d7bd4c1b323ed990589690685c2d7dd8', '4336dbfbbcb5a7813b4a9536d3a02d079116a1bf1c28939a1280453b7b219a96', 1),
	(292, 581, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'notification', 5, '{"body": "Appointment on 2026-07-22 03:59 (booked).", "status": "pending", "channel": "in_app", "read_at": null, "sent_at": null, "subject": "Appointment booked", "category": "appointment_reminder", "source_id": 5, "created_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "source_table": "appointment", "source_schema": "mcms_clinic", "notification_id": 5, "recipient_user_id": 1, "recipient_party_id": 99008}', 'db-trigger', '4336dbfbbcb5a7813b4a9536d3a02d079116a1bf1c28939a1280453b7b219a96', 'aa16167f63133f941bf4a422a97bd86789a48c857f145c68ab1e97d8d020bd11', 1),
	(293, 582, '2026-07-18 21:59:17.914572+03', 'appointment_booked', 'info', 1, 99008, 'mcms_clinic', 'appointment', 5, '{"status": "booked", "starts_at": "2026-07-22T03:59:17.913956+00:00", "department_id": 1}', 'mcms', 'aa16167f63133f941bf4a422a97bd86789a48c857f145c68ab1e97d8d020bd11', 'bd54622594da505064c5d7e3ab615368172396a959445cdf1e43bba875f4b987', 1),
	(294, 583, '2026-07-18 21:59:17.914572+03', 'encounter_opened', 'info', 1, 99005, 'mcms_emr', 'encounter', 2, '{"mrn": "MRN-DEMO-001", "class": "ambulatory", "reason": "Demo visit"}', 'mcms', 'bd54622594da505064c5d7e3ab615368172396a959445cdf1e43bba875f4b987', '0140411f5d5756869d9b6cf830eb581b74dc852bc1ec2a70fc173f2c76b4912d', 1),
	(295, 585, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'clinical_note', 2, '{"body": "Demonstration clinical note.", "title": "Demo Note", "signed": true, "note_id": 2, "note_type": "progress", "signed_at": "2026-07-18T18:59:17.913956+00:00", "signed_by": 1, "amended_at": null, "created_at": "2026-07-18T18:59:18.113661+00:00", "patient_id": 99002, "updated_at": "2026-07-18T18:59:18.113661+00:00", "facility_id": 1, "coauthor_ids": null, "encounter_id": 2, "author_user_id": 1}', 'db-trigger', '0140411f5d5756869d9b6cf830eb581b74dc852bc1ec2a70fc173f2c76b4912d', '93a1e1176f4900815b2ae611b6ed77997d27bdb1eec3543117f33f7cb4531c30', 1),
	(296, 587, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'vitals', 2, '{"bmi": 24.2, "rr_pm": 16, "hr_bpm": 80, "temp_c": 37.0, "dbp_mmhg": 80, "sbp_mmhg": 120, "spo2_pct": 98.0, "taken_at": "2026-07-18T18:59:17.913956+00:00", "taken_by": 1, "vital_id": 2, "height_cm": 170.0, "weight_kg": 70.00, "pain_score": 0, "patient_id": 99002, "facility_id": 1, "encounter_id": 2, "glucose_mgdl": null}', 'db-trigger', '93a1e1176f4900815b2ae611b6ed77997d27bdb1eec3543117f33f7cb4531c30', 'e943e6f39db0e8b26f9c79e6f092a9aef26e487b172a71f5ff254fc61a829f05', 1),
	(297, 588, '2026-07-18 21:59:17.914572+03', 'encounter_opened', 'info', 1, 99006, 'mcms_emr', 'encounter', 3, '{"mrn": "MRN-DEMO-002", "class": "ambulatory", "reason": "Demo visit"}', 'mcms', 'e943e6f39db0e8b26f9c79e6f092a9aef26e487b172a71f5ff254fc61a829f05', '2b22c26ce5b8e4152b47631f8489e6fc4c99b359af33a46518820a394237fcf6', 1),
	(298, 590, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'clinical_note', 3, '{"body": "Demonstration clinical note.", "title": "Demo Note", "signed": true, "note_id": 3, "note_type": "progress", "signed_at": "2026-07-18T18:59:17.913956+00:00", "signed_by": 1, "amended_at": null, "created_at": "2026-07-18T18:59:18.147965+00:00", "patient_id": 99003, "updated_at": "2026-07-18T18:59:18.147965+00:00", "facility_id": 1, "coauthor_ids": null, "encounter_id": 3, "author_user_id": 1}', 'db-trigger', '2b22c26ce5b8e4152b47631f8489e6fc4c99b359af33a46518820a394237fcf6', '4c8477f81f6c6b3deb8cd7281afa0bdb5c532c09c2fc69a1310ad271c27f8f0b', 1),
	(299, 592, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'vitals', 3, '{"bmi": 24.2, "rr_pm": 16, "hr_bpm": 80, "temp_c": 37.0, "dbp_mmhg": 80, "sbp_mmhg": 120, "spo2_pct": 98.0, "taken_at": "2026-07-17T18:59:17.913956+00:00", "taken_by": 1, "vital_id": 3, "height_cm": 170.0, "weight_kg": 70.00, "pain_score": 0, "patient_id": 99003, "facility_id": 1, "encounter_id": 3, "glucose_mgdl": null}', 'db-trigger', '4c8477f81f6c6b3deb8cd7281afa0bdb5c532c09c2fc69a1310ad271c27f8f0b', 'ec74cea2ab5b65f02290d91f596a1897ff6d0d7c6b2a608e0e984572f088ad16', 1),
	(300, 593, '2026-07-18 21:59:17.914572+03', 'encounter_opened', 'info', 1, 99007, 'mcms_emr', 'encounter', 4, '{"mrn": "MRN-DEMO-003", "class": "ambulatory", "reason": "Demo visit"}', 'mcms', 'ec74cea2ab5b65f02290d91f596a1897ff6d0d7c6b2a608e0e984572f088ad16', '5e9abf8f3ebf8ba3d439ae435e575079d2aa2499ec71849319c9f6966c793923', 1),
	(301, 595, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'clinical_note', 4, '{"body": "Demonstration clinical note.", "title": "Demo Note", "signed": true, "note_id": 4, "note_type": "progress", "signed_at": "2026-07-18T18:59:17.913956+00:00", "signed_by": 1, "amended_at": null, "created_at": "2026-07-18T18:59:18.162554+00:00", "patient_id": 99004, "updated_at": "2026-07-18T18:59:18.162554+00:00", "facility_id": 1, "coauthor_ids": null, "encounter_id": 4, "author_user_id": 1}', 'db-trigger', '5e9abf8f3ebf8ba3d439ae435e575079d2aa2499ec71849319c9f6966c793923', '3356c00b653f0e84c9da3f1f2fa4c9b2b4f8e427041aa6d7506988a8e0b005d9', 1),
	(393, 754, '2026-07-18 21:59:17.914572+03', 'study_requested', 'info', 99, 99003, 'mcms_rad', 'study_request', 2, '{"status": "requested", "priority": "routine", "accession_no": "demo"}', 'mcms', '8b2cc7b993fc6ae8ead310238463767817eaca3185892a148ab19852d7bbbd9f', 'ed21f0eaaeb076220d1869f858091c71bbd23a57ad74f81f24c8f5de0926dcfd', 1),
	(302, 597, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'vitals', 4, '{"bmi": 24.2, "rr_pm": 16, "hr_bpm": 80, "temp_c": 37.0, "dbp_mmhg": 80, "sbp_mmhg": 120, "spo2_pct": 98.0, "taken_at": "2026-07-16T18:59:17.913956+00:00", "taken_by": 1, "vital_id": 4, "height_cm": 170.0, "weight_kg": 70.00, "pain_score": 0, "patient_id": 99004, "facility_id": 1, "encounter_id": 4, "glucose_mgdl": null}', 'db-trigger', '3356c00b653f0e84c9da3f1f2fa4c9b2b4f8e427041aa6d7506988a8e0b005d9', 'e6d1f3589f60e88437024f6a24eb01232c784b3db40a513d349311224ed31777', 1),
	(303, 598, '2026-07-18 21:59:17.914572+03', 'encounter_opened', 'info', 1, 99008, 'mcms_emr', 'encounter', 5, '{"mrn": "MRN-DEMO-004", "class": "ambulatory", "reason": "Demo visit"}', 'mcms', 'e6d1f3589f60e88437024f6a24eb01232c784b3db40a513d349311224ed31777', '30113523bc6ea26dca81ffd14486c7ab5931cff9954f2fb5079a3c0ba6cc20f9', 1),
	(304, 600, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'clinical_note', 5, '{"body": "Demonstration clinical note.", "title": "Demo Note", "signed": true, "note_id": 5, "note_type": "progress", "signed_at": "2026-07-18T18:59:17.913956+00:00", "signed_by": 1, "amended_at": null, "created_at": "2026-07-18T18:59:18.176745+00:00", "patient_id": 99005, "updated_at": "2026-07-18T18:59:18.176745+00:00", "facility_id": 1, "coauthor_ids": null, "encounter_id": 5, "author_user_id": 1}', 'db-trigger', '30113523bc6ea26dca81ffd14486c7ab5931cff9954f2fb5079a3c0ba6cc20f9', '2b237e76cd2cebbe1beebc87a368e1f7a917d8781724cce1326ae1bb81a6a0a1', 1),
	(305, 602, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'vitals', 5, '{"bmi": 24.2, "rr_pm": 16, "hr_bpm": 80, "temp_c": 37.0, "dbp_mmhg": 80, "sbp_mmhg": 120, "spo2_pct": 98.0, "taken_at": "2026-07-15T18:59:17.913956+00:00", "taken_by": 1, "vital_id": 5, "height_cm": 170.0, "weight_kg": 70.00, "pain_score": 0, "patient_id": 99005, "facility_id": 1, "encounter_id": 5, "glucose_mgdl": null}', 'db-trigger', '2b237e76cd2cebbe1beebc87a368e1f7a917d8781724cce1326ae1bb81a6a0a1', 'f68009b839786d49b67735c03072cb71923097853aea42120e6e46f7ff6559e9', 1),
	(306, 603, '2026-07-18 21:59:17.914572+03', 'encounter_opened', 'info', 1, 99009, 'mcms_emr', 'encounter', 6, '{"mrn": "MRN-DEMO-005", "class": "ambulatory", "reason": "Demo visit"}', 'mcms', 'f68009b839786d49b67735c03072cb71923097853aea42120e6e46f7ff6559e9', '4d40d377e90f5bec069b7f534f0b3a9cbca021ea7513e077c806990ed96511fe', 1),
	(307, 605, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'clinical_note', 6, '{"body": "Demonstration clinical note.", "title": "Demo Note", "signed": true, "note_id": 6, "note_type": "progress", "signed_at": "2026-07-18T18:59:17.913956+00:00", "signed_by": 1, "amended_at": null, "created_at": "2026-07-18T18:59:18.18689+00:00", "patient_id": 99006, "updated_at": "2026-07-18T18:59:18.18689+00:00", "facility_id": 1, "coauthor_ids": null, "encounter_id": 6, "author_user_id": 1}', 'db-trigger', '4d40d377e90f5bec069b7f534f0b3a9cbca021ea7513e077c806990ed96511fe', '9c504a868dfab4c442ff9e417acbaeb33062d82af50ebf1f8ee5dca22440a174', 1),
	(308, 607, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'vitals', 6, '{"bmi": 24.2, "rr_pm": 16, "hr_bpm": 80, "temp_c": 37.0, "dbp_mmhg": 80, "sbp_mmhg": 120, "spo2_pct": 98.0, "taken_at": "2026-07-14T18:59:17.913956+00:00", "taken_by": 1, "vital_id": 6, "height_cm": 170.0, "weight_kg": 70.00, "pain_score": 0, "patient_id": 99006, "facility_id": 1, "encounter_id": 6, "glucose_mgdl": null}', 'db-trigger', '9c504a868dfab4c442ff9e417acbaeb33062d82af50ebf1f8ee5dca22440a174', '8d69bf23b47aa044aa4957cec3fe53047dad169091b7b9d5825decf1e741d6dd', 1),
	(309, 608, '2026-07-18 21:59:17.914572+03', 'prescription_issued', 'info', 1, 99005, 'mcms_emr', 'medication_order', 2, '{"dose": "500 mg", "route": "po", "drug_name": "Paracetamol", "frequency": "tid"}', 'mcms', '8d69bf23b47aa044aa4957cec3fe53047dad169091b7b9d5825decf1e741d6dd', '9b432f917e271ff37afd5ac5aec7c0ae89a6e94330bb4e19f034826c25852a26', 1),
	(310, 609, '2026-07-18 21:59:17.914572+03', 'prescription_issued', 'info', 1, 99006, 'mcms_emr', 'medication_order', 3, '{"dose": "500 mg", "route": "po", "drug_name": "Paracetamol", "frequency": "tid"}', 'mcms', '9b432f917e271ff37afd5ac5aec7c0ae89a6e94330bb4e19f034826c25852a26', '89ec50873629034c71c854ab6e92f120d2310df1020840a5f67a3573d0681b2b', 1),
	(311, 610, '2026-07-18 21:59:17.914572+03', 'prescription_issued', 'info', 1, 99007, 'mcms_emr', 'medication_order', 4, '{"dose": "500 mg", "route": "po", "drug_name": "Paracetamol", "frequency": "tid"}', 'mcms', '89ec50873629034c71c854ab6e92f120d2310df1020840a5f67a3573d0681b2b', 'f72922110fc532a9270fceda821330efacebe1c4e2858a8a25ffa160a1d060d7', 1),
	(312, 611, '2026-07-18 21:59:17.914572+03', 'lab_order_placed', 'info', 1, 99005, 'mcms_lab', 'lab_order', 2, '{"order_no": "LAB-DEMO-001", "panel_id": 2, "priority": "routine"}', 'mcms', 'f72922110fc532a9270fceda821330efacebe1c4e2858a8a25ffa160a1d060d7', 'd98324fe66eb8d925c5493509c29aa1b2d8d2b459aa42a006207eae6c3fd0d87', 1),
	(313, 613, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'notification', 6, '{"body": "Result for WBC Count flagged normal.", "status": "pending", "channel": "in_app", "read_at": null, "sent_at": null, "subject": "abnormal_result: WBC Count", "category": "abnormal_result", "source_id": 2, "created_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "source_table": "result", "source_schema": "mcms_lab", "notification_id": 6, "recipient_user_id": null, "recipient_party_id": 99005}', 'db-trigger', 'd98324fe66eb8d925c5493509c29aa1b2d8d2b459aa42a006207eae6c3fd0d87', '3d46557809ce13118219cebc1159690fe197667b241483296d350368d5c4cad1', 1),
	(314, 614, '2026-07-18 21:59:17.914572+03', 'abnormal_result_alert', 'warning', NULL, 99005, 'mcms_lab', 'result', 2, '{"flag": "normal", "test": "WBC Count", "value": "Normal"}', 'mcms', '3d46557809ce13118219cebc1159690fe197667b241483296d350368d5c4cad1', '8a8ff2b426ca285e6f3f505ecba54280704a108212508e401c47cd91d5ec46e3', 1),
	(315, 616, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'clinical_note', 7, '{"body": "Auto-routed from mcms_lab.result #2 | flag=normal | value=Normal", "title": "Lab result: WBC Count", "signed": false, "note_id": 7, "note_type": "lab_result", "signed_at": null, "signed_by": null, "amended_at": null, "created_at": "2026-07-18T18:59:17.914572+00:00", "patient_id": 99002, "updated_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "coauthor_ids": null, "encounter_id": 2, "author_user_id": 1}', 'db-trigger', '8a8ff2b426ca285e6f3f505ecba54280704a108212508e401c47cd91d5ec46e3', 'c638588b5da4dfc7ab00384213ca69e2e4baf69c86b04d48d77b9e8332abad51', 1),
	(316, 617, '2026-07-18 21:59:17.914572+03', 'lab_order_placed', 'info', 1, 99006, 'mcms_lab', 'lab_order', 3, '{"order_no": "LAB-DEMO-002", "panel_id": 2, "priority": "routine"}', 'mcms', 'c638588b5da4dfc7ab00384213ca69e2e4baf69c86b04d48d77b9e8332abad51', 'a039a8cfa749497323cf13d359efb46078065855f005c14c26980fa86d799425', 1),
	(332, 643, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'allergy', 2, '{"noted_by": 1, "noted_on": "2026-07-18T18:59:17.913956+00:00", "reaction": "Rash", "severity": "moderate", "is_active": true, "onset_age": "childhood", "substance": "Penicillin", "allergy_id": 2, "patient_id": 99002, "facility_id": 1}', 'db-trigger', '3a67577e81ceb6615bc9e4d73bf3a04441ed349a45c5273f6156252ddf82339d', 'e371a0f6068c9881d8fb22a505644f9c65a701f434abee4dbb79e16e0ebc8a0a', 1),
	(317, 619, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'notification', 7, '{"body": "Result for WBC Count flagged normal.", "status": "pending", "channel": "in_app", "read_at": null, "sent_at": null, "subject": "abnormal_result: WBC Count", "category": "abnormal_result", "source_id": 3, "created_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "source_table": "result", "source_schema": "mcms_lab", "notification_id": 7, "recipient_user_id": null, "recipient_party_id": 99006}', 'db-trigger', 'a039a8cfa749497323cf13d359efb46078065855f005c14c26980fa86d799425', '27035e9a2f96196aa3c7955ce7ad7e4107d418bf8a37e308677aef86501dc9d0', 1),
	(318, 620, '2026-07-18 21:59:17.914572+03', 'abnormal_result_alert', 'warning', NULL, 99006, 'mcms_lab', 'result', 3, '{"flag": "normal", "test": "WBC Count", "value": "Normal"}', 'mcms', '27035e9a2f96196aa3c7955ce7ad7e4107d418bf8a37e308677aef86501dc9d0', '4d88c01bb8eb330b9f41b45d680d1a004e8a9bedfe2fb6b8f9d8a577e8d6dcaf', 1),
	(319, 622, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'clinical_note', 8, '{"body": "Auto-routed from mcms_lab.result #3 | flag=normal | value=Normal", "title": "Lab result: WBC Count", "signed": false, "note_id": 8, "note_type": "lab_result", "signed_at": null, "signed_by": null, "amended_at": null, "created_at": "2026-07-18T18:59:17.914572+00:00", "patient_id": 99003, "updated_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "coauthor_ids": null, "encounter_id": 2, "author_user_id": 1}', 'db-trigger', '4d88c01bb8eb330b9f41b45d680d1a004e8a9bedfe2fb6b8f9d8a577e8d6dcaf', '75339b7a40220f8aabf63aa7515e2f5207779589df4c630b32c8bbde1d76d753', 1),
	(320, 623, '2026-07-18 21:59:17.914572+03', 'lab_order_placed', 'info', 1, 99007, 'mcms_lab', 'lab_order', 4, '{"order_no": "LAB-DEMO-003", "panel_id": 2, "priority": "routine"}', 'mcms', '75339b7a40220f8aabf63aa7515e2f5207779589df4c630b32c8bbde1d76d753', 'b063f216935bc4c40b27c66ef13557fbac0149f93fd91ba5a3ef2032a6d630ae', 1),
	(321, 625, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'notification', 8, '{"body": "Result for WBC Count flagged normal.", "status": "pending", "channel": "in_app", "read_at": null, "sent_at": null, "subject": "abnormal_result: WBC Count", "category": "abnormal_result", "source_id": 4, "created_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "source_table": "result", "source_schema": "mcms_lab", "notification_id": 8, "recipient_user_id": null, "recipient_party_id": 99007}', 'db-trigger', 'b063f216935bc4c40b27c66ef13557fbac0149f93fd91ba5a3ef2032a6d630ae', '010f6a3d21ab63eda29b2a53ca359791661d2f07037fa6e3148a019eebbfecc8', 1),
	(322, 626, '2026-07-18 21:59:17.914572+03', 'abnormal_result_alert', 'warning', NULL, 99007, 'mcms_lab', 'result', 4, '{"flag": "normal", "test": "WBC Count", "value": "Normal"}', 'mcms', '010f6a3d21ab63eda29b2a53ca359791661d2f07037fa6e3148a019eebbfecc8', '0667bc7f104a076ff2684af7b8502db1a6847125a5845aced2017554a2e6cc8d', 1),
	(323, 628, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'clinical_note', 9, '{"body": "Auto-routed from mcms_lab.result #4 | flag=normal | value=Normal", "title": "Lab result: WBC Count", "signed": false, "note_id": 9, "note_type": "lab_result", "signed_at": null, "signed_by": null, "amended_at": null, "created_at": "2026-07-18T18:59:17.914572+00:00", "patient_id": 99004, "updated_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "coauthor_ids": null, "encounter_id": 2, "author_user_id": 1}', 'db-trigger', '0667bc7f104a076ff2684af7b8502db1a6847125a5845aced2017554a2e6cc8d', '2e2e788e0dcf648e957032678cb0bc30cf1f54d5f2df321756cef65ab2c88e47', 1),
	(324, 629, '2026-07-18 21:59:17.914572+03', 'invoice_issued', 'info', 1, 99005, 'mcms_billing', 'invoice', 2, '{"total": 150.00, "invoice_no": "INV-DEMO-001"}', 'mcms', '2e2e788e0dcf648e957032678cb0bc30cf1f54d5f2df321756cef65ab2c88e47', 'ea3791f0e84b8bb4717b579264fba72b9171fdcb9c2942f01d11c040e5103306', 1),
	(325, 631, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'invoice_line', 2, '{"qty": 1.00, "line_id": 2, "source_id": 2, "created_at": "2026-07-18T18:59:17.914572+00:00", "invoice_id": 2, "line_total": 150.00, "service_id": 2, "unit_price": 150.00, "description": "EMR Document Fee", "facility_id": 1, "source_table": "service_price", "source_schema": "billing"}', 'db-trigger', 'ea3791f0e84b8bb4717b579264fba72b9171fdcb9c2942f01d11c040e5103306', '2a6d8f082b3b097bbde46efbd562907e669ced49c0310748d9cca6c51a8e4363', 1),
	(326, 632, '2026-07-18 21:59:17.914572+03', 'invoice_issued', 'info', 1, 99006, 'mcms_billing', 'invoice', 3, '{"total": 150.00, "invoice_no": "INV-DEMO-002"}', 'mcms', '2a6d8f082b3b097bbde46efbd562907e669ced49c0310748d9cca6c51a8e4363', '4df10e0f2159ecde3e356ce0829a84919940ae325cb5bdd3c3fc365cb9ed5bd5', 1),
	(327, 634, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'invoice_line', 3, '{"qty": 1.00, "line_id": 3, "source_id": 2, "created_at": "2026-07-18T18:59:17.914572+00:00", "invoice_id": 3, "line_total": 150.00, "service_id": 2, "unit_price": 150.00, "description": "EMR Document Fee", "facility_id": 1, "source_table": "service_price", "source_schema": "billing"}', 'db-trigger', '4df10e0f2159ecde3e356ce0829a84919940ae325cb5bdd3c3fc365cb9ed5bd5', 'f8d2bb019bcfb2e44dc6827b8abc6888afc3224182d2f0f48071dd8508ffcee8', 1),
	(328, 635, '2026-07-18 21:59:17.914572+03', 'invoice_issued', 'info', 1, 99007, 'mcms_billing', 'invoice', 4, '{"total": 150.00, "invoice_no": "INV-DEMO-003"}', 'mcms', 'f8d2bb019bcfb2e44dc6827b8abc6888afc3224182d2f0f48071dd8508ffcee8', '6542e259d4716535b61e31de1cd5347909f0264074f6c00952cd662198d03e30', 1),
	(329, 637, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'invoice_line', 4, '{"qty": 1.00, "line_id": 4, "source_id": 2, "created_at": "2026-07-18T18:59:17.914572+00:00", "invoice_id": 4, "line_total": 150.00, "service_id": 2, "unit_price": 150.00, "description": "EMR Document Fee", "facility_id": 1, "source_table": "service_price", "source_schema": "billing"}', 'db-trigger', '6542e259d4716535b61e31de1cd5347909f0264074f6c00952cd662198d03e30', '2bc697abead4ab65238244ea729ae8b20f93c17c0b0ad79eb4a9df10a9d7c5b5', 1),
	(330, 639, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_waste', 'waste_collection', 1, '{"weight_kg": 2.500, "created_at": "2026-07-18T18:59:18.361006+00:00", "container_id": 1, "collection_id": 2, "storage_location": "Demo Storage", "collection_datetime": "2026-07-18T18:59:17.913956+00:00", "collected_by_user_id": 1}', 'db-trigger', '2bc697abead4ab65238244ea729ae8b20f93c17c0b0ad79eb4a9df10a9d7c5b5', 'e4abf31b6fbe06fbab7a1c35b88c45320f98fd39cd3009eab6e2ab3e00743f1c', 1),
	(331, 641, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_waste', 'waste_collection', 1, '{"weight_kg": 2.500, "created_at": "2026-07-18T18:59:18.365017+00:00", "container_id": 1, "collection_id": 3, "storage_location": "Demo Storage", "collection_datetime": "2026-07-17T18:59:17.913956+00:00", "collected_by_user_id": 1}', 'db-trigger', 'e4abf31b6fbe06fbab7a1c35b88c45320f98fd39cd3009eab6e2ab3e00743f1c', '3a67577e81ceb6615bc9e4d73bf3a04441ed349a45c5273f6156252ddf82339d', 1),
	(362, 699, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'goods_receipt', 2, '{"notes": null, "po_id": null, "grn_id": 2, "grn_no": "GRN-DEMO-001", "status": "pending", "facility_id": 1, "received_at": "2026-07-18T18:59:17.914572+00:00", "received_by": 1, "supplier_id": 2}', 'db-trigger', '86ed96300ba356a87c50959203ec3935eaae8163d19e63d00ac4284902df399b', 'b90cf9ccd2f4341c905b4763c0d3b64ec9ba6da0ca44e551df12de513aa83368', 1),
	(333, 645, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'family_history', 2, '{"fh_id": 2, "relative": "Father", "patient_id": 99002, "facility_id": 1, "is_deceased": false, "recorded_at": "2026-07-18T18:59:17.913956+00:00", "age_at_onset": 50, "relationship": "father", "condition_code": "I10", "condition_desc": "Hypertension"}', 'db-trigger', 'e371a0f6068c9881d8fb22a505644f9c65a701f434abee4dbb79e16e0ebc8a0a', '2eb330fb6906be81b9f595d5b626f3d2247f750008782c759497494540ec0ebc', 1),
	(334, 647, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'immunization', 2, '{"site": "LA", "given_at": "2026-07-18T18:59:17.913956+00:00", "given_by": 1, "reaction": "none", "lot_number": "LOT-DEMO", "patient_id": 99002, "dose_number": 2, "facility_id": 1, "vaccine_code": "COVID-19", "vaccine_name": "COVID-19 vaccine", "immunization_id": 2}', 'db-trigger', '2eb330fb6906be81b9f595d5b626f3d2247f750008782c759497494540ec0ebc', '50ed0ebf60da01a335f376f55ec16664e7f632afa4dd732096b61414f4f065ae', 1),
	(335, 649, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'social_history', 2, '{"sh_id": 2, "occupation": "Demo", "patient_id": 99002, "facility_id": 1, "recorded_at": "2026-07-18T18:59:17.913956+00:00", "years_smoked": 0, "illicit_drugs": ["none"], "packs_per_day": 0.0, "alcohol_status": "none", "tobacco_status": "never", "drinks_per_week": 0, "relationship_status": "married"}', 'db-trigger', '50ed0ebf60da01a335f376f55ec16664e7f632afa4dd732096b61414f4f065ae', '08980f4129ab1fdb9c9bcbfc9e35b94ec1961fc834cc1b5068bb5bed374a57e3', 1),
	(336, 651, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'allergy', 3, '{"noted_by": 1, "noted_on": "2026-07-18T18:59:17.913956+00:00", "reaction": "Rash", "severity": "moderate", "is_active": true, "onset_age": "childhood", "substance": "Penicillin", "allergy_id": 3, "patient_id": 99003, "facility_id": 1}', 'db-trigger', '08980f4129ab1fdb9c9bcbfc9e35b94ec1961fc834cc1b5068bb5bed374a57e3', '318ee688c07ddd9c6519c294572da6b94fedf47a2494411b08505f9fb06d27cb', 1),
	(337, 653, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'family_history', 3, '{"fh_id": 3, "relative": "Father", "patient_id": 99003, "facility_id": 1, "is_deceased": false, "recorded_at": "2026-07-18T18:59:17.913956+00:00", "age_at_onset": 50, "relationship": "father", "condition_code": "I10", "condition_desc": "Hypertension"}', 'db-trigger', '318ee688c07ddd9c6519c294572da6b94fedf47a2494411b08505f9fb06d27cb', 'c586ee98c062e5ad437d5989f28077d5c0099d5e45b4ff2e54a52bd9ecc00458', 1),
	(338, 655, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'immunization', 3, '{"site": "LA", "given_at": "2026-07-18T18:59:17.913956+00:00", "given_by": 1, "reaction": "none", "lot_number": "LOT-DEMO", "patient_id": 99003, "dose_number": 2, "facility_id": 1, "vaccine_code": "COVID-19", "vaccine_name": "COVID-19 vaccine", "immunization_id": 3}', 'db-trigger', 'c586ee98c062e5ad437d5989f28077d5c0099d5e45b4ff2e54a52bd9ecc00458', 'f9d4566568d0692117e7a90d648f6364ea1396e7ecbaf7bfdcf2a8b709bc360d', 1),
	(339, 657, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'social_history', 3, '{"sh_id": 3, "occupation": "Demo", "patient_id": 99003, "facility_id": 1, "recorded_at": "2026-07-18T18:59:17.913956+00:00", "years_smoked": 0, "illicit_drugs": ["none"], "packs_per_day": 0.0, "alcohol_status": "none", "tobacco_status": "never", "drinks_per_week": 0, "relationship_status": "married"}', 'db-trigger', 'f9d4566568d0692117e7a90d648f6364ea1396e7ecbaf7bfdcf2a8b709bc360d', '73e2009eb761175ce1807d2cc5c863e6634944e324432fafb2d3a1e1ee744059', 1),
	(340, 659, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'allergy', 4, '{"noted_by": 1, "noted_on": "2026-07-18T18:59:17.913956+00:00", "reaction": "Rash", "severity": "moderate", "is_active": true, "onset_age": "childhood", "substance": "Penicillin", "allergy_id": 4, "patient_id": 99004, "facility_id": 1}', 'db-trigger', '73e2009eb761175ce1807d2cc5c863e6634944e324432fafb2d3a1e1ee744059', '35dca3396a5cd36af565a511efc264d6c8d01ca3636b8480b5a73f541c513a0c', 1),
	(341, 661, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'family_history', 4, '{"fh_id": 4, "relative": "Father", "patient_id": 99004, "facility_id": 1, "is_deceased": false, "recorded_at": "2026-07-18T18:59:17.913956+00:00", "age_at_onset": 50, "relationship": "father", "condition_code": "I10", "condition_desc": "Hypertension"}', 'db-trigger', '35dca3396a5cd36af565a511efc264d6c8d01ca3636b8480b5a73f541c513a0c', '73202134eb0c737c7f526a7a3f77c614b748a219dc6745b5a552fcdb5f3b2f47', 1),
	(342, 663, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'immunization', 4, '{"site": "LA", "given_at": "2026-07-18T18:59:17.913956+00:00", "given_by": 1, "reaction": "none", "lot_number": "LOT-DEMO", "patient_id": 99004, "dose_number": 2, "facility_id": 1, "vaccine_code": "COVID-19", "vaccine_name": "COVID-19 vaccine", "immunization_id": 4}', 'db-trigger', '73202134eb0c737c7f526a7a3f77c614b748a219dc6745b5a552fcdb5f3b2f47', 'a5adb8914a69f0dbcb490332b4691876546e7f319df0de42e90b1568b24d1566', 1),
	(343, 665, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'social_history', 4, '{"sh_id": 4, "occupation": "Demo", "patient_id": 99004, "facility_id": 1, "recorded_at": "2026-07-18T18:59:17.913956+00:00", "years_smoked": 0, "illicit_drugs": ["none"], "packs_per_day": 0.0, "alcohol_status": "none", "tobacco_status": "never", "drinks_per_week": 0, "relationship_status": "married"}', 'db-trigger', 'a5adb8914a69f0dbcb490332b4691876546e7f319df0de42e90b1568b24d1566', '01f6180e07e0212f4ebe487791d8940df6e385072ae442d5f6719371eb6eb65b', 1),
	(344, 667, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'allergy', 5, '{"noted_by": 1, "noted_on": "2026-07-18T18:59:17.913956+00:00", "reaction": "Rash", "severity": "moderate", "is_active": true, "onset_age": "childhood", "substance": "Penicillin", "allergy_id": 5, "patient_id": 99005, "facility_id": 1}', 'db-trigger', '01f6180e07e0212f4ebe487791d8940df6e385072ae442d5f6719371eb6eb65b', 'be595f74a86bf06ea6a2d9801c490ec0cafefce71b59d41acd35fd7a3cd44ed5', 1),
	(345, 669, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'family_history', 5, '{"fh_id": 5, "relative": "Father", "patient_id": 99005, "facility_id": 1, "is_deceased": false, "recorded_at": "2026-07-18T18:59:17.913956+00:00", "age_at_onset": 50, "relationship": "father", "condition_code": "I10", "condition_desc": "Hypertension"}', 'db-trigger', 'be595f74a86bf06ea6a2d9801c490ec0cafefce71b59d41acd35fd7a3cd44ed5', 'c9b62b3b1cd2f184f85f4922b5e0c0a499422eee637e2d0a0eccbe39798acb30', 1),
	(346, 671, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'immunization', 5, '{"site": "LA", "given_at": "2026-07-18T18:59:17.913956+00:00", "given_by": 1, "reaction": "none", "lot_number": "LOT-DEMO", "patient_id": 99005, "dose_number": 2, "facility_id": 1, "vaccine_code": "COVID-19", "vaccine_name": "COVID-19 vaccine", "immunization_id": 5}', 'db-trigger', 'c9b62b3b1cd2f184f85f4922b5e0c0a499422eee637e2d0a0eccbe39798acb30', 'bb7c2155c2b440dda7207a0c37ecced0d4b3c4e1dfb995a3b725fc978b1d606b', 1),
	(347, 673, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'social_history', 5, '{"sh_id": 5, "occupation": "Demo", "patient_id": 99005, "facility_id": 1, "recorded_at": "2026-07-18T18:59:17.913956+00:00", "years_smoked": 0, "illicit_drugs": ["none"], "packs_per_day": 0.0, "alcohol_status": "none", "tobacco_status": "never", "drinks_per_week": 0, "relationship_status": "married"}', 'db-trigger', 'bb7c2155c2b440dda7207a0c37ecced0d4b3c4e1dfb995a3b725fc978b1d606b', 'fb1b0bd5e6b51532a90c2df905dd774ae2a7de50c5f27a7ebc52ca7bac1e52dd', 1),
	(348, 675, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'allergy', 6, '{"noted_by": 1, "noted_on": "2026-07-18T18:59:17.913956+00:00", "reaction": "Rash", "severity": "moderate", "is_active": true, "onset_age": "childhood", "substance": "Penicillin", "allergy_id": 6, "patient_id": 99006, "facility_id": 1}', 'db-trigger', 'fb1b0bd5e6b51532a90c2df905dd774ae2a7de50c5f27a7ebc52ca7bac1e52dd', 'eb1b3bdfbd03c5f9a96e4e1317c9e8f014382441e1acfcadc3a1ac80303a5f9b', 1),
	(349, 677, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'family_history', 6, '{"fh_id": 6, "relative": "Father", "patient_id": 99006, "facility_id": 1, "is_deceased": false, "recorded_at": "2026-07-18T18:59:17.913956+00:00", "age_at_onset": 50, "relationship": "father", "condition_code": "I10", "condition_desc": "Hypertension"}', 'db-trigger', 'eb1b3bdfbd03c5f9a96e4e1317c9e8f014382441e1acfcadc3a1ac80303a5f9b', '88e37dcf429563e0aa38f286801906ef078de9423e827a08837a7e2dd9ee7261', 1),
	(350, 679, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'immunization', 6, '{"site": "LA", "given_at": "2026-07-18T18:59:17.913956+00:00", "given_by": 1, "reaction": "none", "lot_number": "LOT-DEMO", "patient_id": 99006, "dose_number": 2, "facility_id": 1, "vaccine_code": "COVID-19", "vaccine_name": "COVID-19 vaccine", "immunization_id": 6}', 'db-trigger', '88e37dcf429563e0aa38f286801906ef078de9423e827a08837a7e2dd9ee7261', '48dd538be13471dee2fdf7511eff8e0d1574fc96696dbe3813369ba390723f82', 1),
	(351, 681, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'social_history', 6, '{"sh_id": 6, "occupation": "Demo", "patient_id": 99006, "facility_id": 1, "recorded_at": "2026-07-18T18:59:17.913956+00:00", "years_smoked": 0, "illicit_drugs": ["none"], "packs_per_day": 0.0, "alcohol_status": "none", "tobacco_status": "never", "drinks_per_week": 0, "relationship_status": "married"}', 'db-trigger', '48dd538be13471dee2fdf7511eff8e0d1574fc96696dbe3813369ba390723f82', '859b9170f303e15d862928cde5e279502cabbe6e3ec76ab163ae33bf096f635e', 1),
	(352, 683, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_clinic', 'room', 2, '{"code": "R-DEMO-01", "name": "Demo Room", "room_id": 2, "capacity": 2, "equipment": ["bed", "monitor"], "is_active": true, "created_at": "2026-07-18T18:59:17.914572+00:00", "updated_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "department_id": 1}', 'db-trigger', '859b9170f303e15d862928cde5e279502cabbe6e3ec76ab163ae33bf096f635e', 'dee9cdf6f6c0497a6653216cb6935370373014df852b3572d32933c7a4d50de2', 1),
	(353, 685, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_clinic', 'patient_queue', 2, '{"mrn": "MRN-DEMO-001", "status": "waiting", "room_id": 2, "priority": 1, "queue_id": 2, "called_at": null, "patient_id": 99002, "started_at": "2026-07-18T18:59:17.913956+00:00", "facility_id": 1, "finished_at": "2026-07-18T18:59:17.913956+00:00", "encounter_id": 2, "checked_in_at": "2026-07-18T18:59:17.913956+00:00", "department_id": 1, "assigned_clinician": 1}', 'db-trigger', 'dee9cdf6f6c0497a6653216cb6935370373014df852b3572d32933c7a4d50de2', '956cfab010c59a890af1129915ae8c31827468e0cd91191142399a1da2dac0e8', 1),
	(354, 687, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'audit_trail', 1, '{"after": {}, "action": "update", "before": {}, "row_id": 1, "audit_id": 2, "event_id": 1, "changed_at": "2026-07-18T18:59:17.913956+00:00", "changed_by": 1, "table_name": "party", "facility_id": 1, "table_schema": "mcms_core"}', 'db-trigger', '956cfab010c59a890af1129915ae8c31827468e0cd91191142399a1da2dac0e8', 'f1c98c438551455d5f167e60dd0821683de2b59ce9a230e020dfe1778e29b066', 1),
	(355, 688, '2026-07-18 21:59:17.914572+03', 'surgery_scheduled', 'info', 1, 99005, 'mcms_surgical', 'surgery', 2, '{"or_id": 2, "status": "completed", "operation_no": "OP-DEMO-001", "procedure_id": 2}', 'mcms', 'f1c98c438551455d5f167e60dd0821683de2b59ce9a230e020dfe1778e29b066', '61902547e670cdb3964f3303d083e6fa9df99889c4f31d4490a510f2d1225185', 1),
	(356, 690, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'intra_op_vitals', 2, '{"notes": "Demo intra-op vitals", "hr_bpm": 80, "iov_id": 2, "temp_c": 36.5, "dbp_mmhg": 80, "sbp_mmhg": 120, "spo2_pct": 98.0, "urine_ml": 200, "etco2_mmhg": 35, "surgery_id": 2, "facility_id": 1, "recorded_at": "2026-07-18T18:59:17.913956+00:00", "recorded_by": 1, "anaesthesia_depth": 40}', 'db-trigger', '61902547e670cdb3964f3303d083e6fa9df99889c4f31d4490a510f2d1225185', 'eb3fa96986acf8e6b82ac1143350b3b5bd57d8d8c9b3b5b7344c85e92ccfa76d', 1),
	(357, 691, '2026-07-18 21:59:17.914572+03', 'triage_recorded', 'info', NULL, 99005, 'mcms_emergency', 'triage', 2, '{"esi_level": 2, "ed_visit_no": "EV-DEMO-001", "trauma_alert": false}', 'mcms', 'eb3fa96986acf8e6b82ac1143350b3b5bd57d8d8c9b3b5b7344c85e92ccfa76d', '4a65645bb5df80f27b076753c8b25e182011cb70ecea89411d655f919e4b8c88', 1),
	(358, 692, '2026-07-18 21:59:17.914572+03', 'resuscitation_initiated', 'critical', NULL, 99005, 'mcms_emergency', 'resuscitation', 2, '{"code_type": null, "code_initiated_at": "2026-07-18T18:59:17.914572+00:00"}', 'mcms', '4a65645bb5df80f27b076753c8b25e182011cb70ecea89411d655f919e4b8c88', '80421bca06c86ecf56ae7913dd8ce92a075cdeeb7c98a2caa6227680e56b1ed6', 1),
	(359, 693, '2026-07-18 21:59:17.914572+03', 'icu_admit', 'warning', NULL, 99005, 'mcms_icu', 'admission', 2, '{"bed_id": null, "reason": null}', 'mcms', '80421bca06c86ecf56ae7913dd8ce92a075cdeeb7c98a2caa6227680e56b1ed6', '5e00ce7ac6b36c6fd8b314df9b1b4c95e93380a44cb969582d3174d096dad091', 1),
	(360, 695, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'supplier', 2, '{"party_id": 1, "is_active": true, "created_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "supplier_id": 2, "supplier_code": "SUP-DEMO-001", "contact_user_id": null, "payment_terms_days": 30}', 'db-trigger', '5e00ce7ac6b36c6fd8b314df9b1b4c95e93380a44cb969582d3174d096dad091', 'a58a70c0588e8f83831dda5d2c6b6ff5ba779c692079d6cce2054f179507eb76', 1),
	(361, 697, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'purchase_order', 2, '{"notes": null, "po_id": 2, "po_no": "PO-DEMO-001", "status": "draft", "closed_at": null, "created_at": "2026-07-18T18:59:17.914572+00:00", "ordered_at": "2026-07-18T18:59:17.914572+00:00", "updated_at": "2026-07-18T18:59:17.914572+00:00", "approved_by": null, "expected_at": null, "facility_id": 1, "received_at": null, "supplier_id": 2, "requested_by": 1}', 'db-trigger', 'a58a70c0588e8f83831dda5d2c6b6ff5ba779c692079d6cce2054f179507eb76', '86ed96300ba356a87c50959203ec3935eaae8163d19e63d00ac4284902df399b', 1),
	(363, 701, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_lot', 2, '{"lot_id": 2, "status": "on_hand", "unit_cost": 10.00, "expires_on": "2027-07-18", "lot_number": "LOT-DEMO-001", "facility_id": 1, "on_hand_qty": 100, "received_at": "2026-07-18T18:59:17.914572+00:00", "drug_item_id": 2, "received_qty": 100, "manufactured_on": null, "purchase_order_id": 2, "supplier_party_id": 1}', 'db-trigger', 'b90cf9ccd2f4341c905b4763c0d3b64ec9ba6da0ca44e551df12de513aa83368', '72af1ba22271d3fcbb150df364c113d97af74fb2dd965f48629e98dc392f8498', 1),
	(364, 703, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'prescription', 2, '{"mrn": "MRN-DEMO-001", "dose": null, "notes": null, "route": null, "status": "draft", "quantity": null, "visit_id": null, "frequency": null, "signed_at": null, "controlled": false, "created_at": "2026-07-18T18:59:17.914572+00:00", "patient_id": 99002, "updated_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "dispensed_at": null, "drug_item_id": 2, "encounter_id": null, "duration_days": null, "prescription_id": 2, "prescriber_user_id": 1, "interaction_severity": null}', 'db-trigger', '72af1ba22271d3fcbb150df364c113d97af74fb2dd965f48629e98dc392f8498', '69ce1439e5adca2cf95eeab97379d7b0389b0fe7d45575ce8ba8116b8e3161bb', 1),
	(365, 705, '2026-07-18 21:59:17.914572+03', 'update', 'info', NULL, NULL, 'mcms_rx', 'drug_lot', 2, '{"lot_id": 2, "status": "on_hand", "unit_cost": 10.00, "expires_on": "2027-07-18", "lot_number": "LOT-DEMO-001", "facility_id": 1, "on_hand_qty": 95, "received_at": "2026-07-18T18:59:17.914572+00:00", "drug_item_id": 2, "received_qty": 100, "manufactured_on": null, "purchase_order_id": 2, "supplier_party_id": 1}', 'db-trigger', '69ce1439e5adca2cf95eeab97379d7b0389b0fe7d45575ce8ba8116b8e3161bb', '10df7efc351d44b74fca34c7d6291649b423fbd2a1549699c45c6875a0d7b87d', 1),
	(366, 707, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'stock_movement', 2, '{"lot_id": 2, "reason": "dispense to patient MRN-DEMO-PORTAL", "qty_delta": -5, "facility_id": 1, "movement_id": 2, "drug_item_id": 2, "performed_at": "2026-07-18T18:59:17.914572+00:00", "performed_by": 1, "balance_after": 95, "movement_type": "dispense", "related_movement_id": null}', 'db-trigger', '10df7efc351d44b74fca34c7d6291649b423fbd2a1549699c45c6875a0d7b87d', '6cdeaa99d9396aca9af84b03dbc052ca98e26359b7cfd7e72200202bf17f5958', 1),
	(367, 708, '2026-07-18 21:59:17.914572+03', 'medication_dispensed', 'info', 1, 99003, 'mcms_rx', 'dispensation', 2, '{"mrn": "MRN-DEMO-PORTAL", "qty": 5, "drug_item_id": 2}', 'mcms', '6cdeaa99d9396aca9af84b03dbc052ca98e26359b7cfd7e72200202bf17f5958', '83e118fa724d49be7956db8f57106af636c41ca5a5c6d6973d3f87041a3e5ff1', 1),
	(368, 709, '2026-07-18 21:59:17.914572+03', 'low_stock_alert', 'warning', NULL, NULL, 'mcms_rx', 'drug_item', 2, '{"drug": "Paracetamol", "on_hand": 95, "reorder_level": 1000}', 'mcms_inventory', '83e118fa724d49be7956db8f57106af636c41ca5a5c6d6973d3f87041a3e5ff1', 'b9ff28fc86203aac305b7f189350d80f9f277c7846779754cd9c1579ad15494b', 1),
	(369, 711, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'payroll_period', 2, '{"code": "PP-DEMO-2026-01", "status": "draft", "end_date": "2026-01-31", "closed_at": null, "period_id": 2, "created_at": "2026-07-18T18:59:17.914572+00:00", "start_date": "2026-01-01", "facility_id": 1}', 'db-trigger', 'b9ff28fc86203aac305b7f189350d80f9f277c7846779754cd9c1579ad15494b', 'ec19d4c2c86ab36ce9d45106918b815b086d95bb0ef164e8d794b45041b3f75d', 1),
	(370, 713, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_vital_records', 'birth_certificate', 1, '{"status": "draft", "signed_at": null, "created_at": "2026-07-18T18:59:17.914572+00:00", "updated_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "amended_from": null, "birth_cert_id": 2, "birth_datetime": "2026-07-18T18:59:17.914572+00:00", "birth_weight_g": null, "place_of_birth": null, "father_party_id": 1, "gestation_weeks": null, "registration_no": "BC-DEMO-001", "attendant_user_id": null, "certifier_user_id": null, "mother_patient_id": 99001, "registrar_user_id": null, "newborn_patient_id": 99001, "delivery_encounter_id": 2}', 'db-trigger', 'ec19d4c2c86ab36ce9d45106918b815b086d95bb0ef164e8d794b45041b3f75d', '0701b32b53f4b02a9c8442b58bcde6f7dbcc6f2a40483baf87af87fa066465d9', 1),
	(371, 715, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_vital_records', 'death_certificate', 99006, '{"status": "draft", "signed_at": null, "cause_text": null, "created_at": "2026-07-18T18:59:17.914572+00:00", "patient_id": 99006, "updated_at": "2026-07-18T18:59:17.914572+00:00", "cause_icd10": null, "facility_id": 1, "amended_from": null, "coroner_case": false, "death_cert_id": 2, "death_datetime": "2026-07-18T18:59:17.914572+00:00", "registration_no": "DC-DEMO-001", "registrar_user_id": null, "certifying_clinician_user_id": null}', 'db-trigger', '0701b32b53f4b02a9c8442b58bcde6f7dbcc6f2a40483baf87af87fa066465d9', '831a8b2c57c6ed2a1db6865cdd50e475614dc1c8be2e2b4acc28b587f65c2cdb', 1),
	(372, 717, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_alternative', 1, '{"reason": null, "created_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "drug_item_id": 2, "alternative_id": 2, "alt_drug_item_id": 3, "is_generic_equiv": false}', 'db-trigger', '831a8b2c57c6ed2a1db6865cdd50e475614dc1c8be2e2b4acc28b587f65c2cdb', 'f3c97c4c9b05756cb5fae36b67b795c5564d623b2705e12c946df2fc6088d4e8', 1),
	(373, 719, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'purchase_order_line', 2, '{"qty": 5, "po_id": 2, "item_id": null, "line_id": 2, "line_total": 50.00, "unit_price": 10.00, "facility_id": 1, "drug_item_id": 2, "qty_received": 0, "item_description": "Demo PO line"}', 'db-trigger', 'f3c97c4c9b05756cb5fae36b67b795c5564d623b2705e12c946df2fc6088d4e8', '3176d99c0377746270ed74e735e7db3ac613e75d50ac919f3e7f2ecc6bfece89', 1),
	(374, 721, '2026-07-18 21:59:17.914572+03', 'update', 'info', NULL, NULL, 'mcms_erp', 'purchase_order_line', 2, '{"qty": 5, "po_id": 2, "item_id": null, "line_id": 2, "line_total": 50.00, "unit_price": 10.00, "facility_id": 1, "drug_item_id": 2, "qty_received": 5, "item_description": "Demo PO line"}', 'db-trigger', '3176d99c0377746270ed74e735e7db3ac613e75d50ac919f3e7f2ecc6bfece89', '1024251c0053dd29abc9ecd436d5e829d4e3dec41b90217f956f15f1b25bea3e', 1),
	(375, 722, '2026-07-18 21:59:17.914572+03', 'purchase_order_raised', 'info', NULL, NULL, 'mcms_erp', 'goods_receipt_line', 2, '{"grn_id": 2, "item_id": null, "drug_item_id": null, "qty_received": 5}', 'mcms_inventory', '1024251c0053dd29abc9ecd436d5e829d4e3dec41b90217f956f15f1b25bea3e', 'eaf8ad39d4c50b191d7279407180b7dff8a5efb8e89b54e533be3653cd744817', 1),
	(376, 724, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'goods_receipt_line', 2, '{"grn_id": 2, "item_id": null, "line_id": 2, "unit_cost": null, "lot_number": null, "po_line_id": 2, "facility_id": 1, "drug_item_id": null, "qty_received": 5, "expiration_date": null}', 'db-trigger', 'eaf8ad39d4c50b191d7279407180b7dff8a5efb8e89b54e533be3653cd744817', '122273094730077c98668f6caa9a494b90cebf4df0df8e857edde0a59bf08f7b', 1),
	(377, 726, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'address', 2, '{"city": "demo", "label": "demo", "line1": "demo", "line2": "demo", "region": "demo", "country": "demo", "latitude": 1, "party_id": 1, "longitude": 1, "address_id": 2, "created_at": "2026-07-18T18:59:18.846827+00:00", "is_primary": true, "facility_id": 1, "postal_code": "demo"}', 'db-trigger', '122273094730077c98668f6caa9a494b90cebf4df0df8e857edde0a59bf08f7b', 'cc64404410468facabbf9b23ac9ea1657dba7c5d514971709b9020fd263b7c57', 1),
	(378, 728, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'contact', 2, '{"kind": "phone", "value": "demo", "party_id": 1, "contact_id": 2, "created_at": "2026-07-18T18:59:18.86587+00:00", "is_primary": true, "facility_id": 1, "verified_at": "2026-07-18T18:59:18.864874+00:00"}', 'db-trigger', 'cc64404410468facabbf9b23ac9ea1657dba7c5d514971709b9020fd263b7c57', '647f87517aed13d4f3760ee2ca90a737d9a3d1cff1b22558b78f663971561c59', 1),
	(379, 730, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'access_log', 1, '{"reason": "demo", "row_id": 1, "read_at": "2026-07-18T18:59:18.912075+00:00", "access_id": 2, "table_name": "demo", "facility_id": 1, "table_schema": "demo", "reader_user_id": 1, "subject_party_id": 1}', 'db-trigger', '647f87517aed13d4f3760ee2ca90a737d9a3d1cff1b22558b78f663971561c59', 'aa1917d039fbf217c0f0239770c359a36873e201c0568b50a8c8ded069a0a821', 1),
	(380, 731, '2026-07-18 21:59:17.914572+03', 'diagnosis_recorded', 'info', 99, 99003, 'mcms_emr', 'diagnosis', 2, '{"code": "demo", "desc": "demo", "role": "admitting", "status": "active"}', 'mcms', 'aa1917d039fbf217c0f0239770c359a36873e201c0568b50a8c8ded069a0a821', 'b149dc991453a8105efd041cc8d91014030cb89adcea99c4b0dc1412adcc62c9', 1),
	(381, 733, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'referral', 2, '{"reason": "demo", "status": "draft", "urgency": "demo", "created_at": "2026-07-18T18:59:18.999677+00:00", "to_user_id": 99, "updated_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "referral_id": 2, "diagnosis_id": 2, "from_user_id": 1, "responded_at": "2026-07-18T18:59:18.998635+00:00", "to_encounter_id": 2, "clinical_summary": "demo", "to_department_id": 1, "from_encounter_id": 2}', 'db-trigger', 'b149dc991453a8105efd041cc8d91014030cb89adcea99c4b0dc1412adcc62c9', '89ba77e6499e75cd20b1f6c001039c6f0bf0d41d80ca6df8c99c1739b7fbfd0e', 1),
	(382, 735, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'referral', 2, '{"reason": "demo", "status": "draft", "urgency": "demo", "created_at": "2026-07-18T18:59:18.999677+00:00", "to_user_id": 99, "updated_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "referral_id": 2, "diagnosis_id": 2, "from_user_id": 1, "responded_at": "2026-07-18T18:59:18.998635+00:00", "to_encounter_id": 2, "clinical_summary": "demo", "to_department_id": 1, "from_encounter_id": 2}', 'db-trigger', '89ba77e6499e75cd20b1f6c001039c6f0bf0d41d80ca6df8c99c1739b7fbfd0e', '0ec11069d7a0e735b7bb7860c6d617f1631beb799c4479385b8a6f7edf17215a', 1),
	(383, 736, '2026-07-18 21:59:17.914572+03', 'employee_hired', 'info', NULL, 99003, 'mcms_hr', 'employee', 2, '{"role": "demo", "employee_no": "demo", "department_id": 1}', 'mcms', '0ec11069d7a0e735b7bb7860c6d617f1631beb799c4479385b8a6f7edf17215a', '694488f5b50a89944cf2b50d8873159067298f1229a739626fefc09f6cb49225', 1),
	(384, 738, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'shift', 2, '{"end_at": "2026-07-18T18:59:19.0783+00:00", "shift_id": 2, "start_at": "2026-07-18T18:59:19.077295+00:00", "created_at": "2026-07-18T18:59:19.079293+00:00", "shift_type": "morning", "employee_id": 2, "facility_id": 1, "department_id": 1}', 'db-trigger', '694488f5b50a89944cf2b50d8873159067298f1229a739626fefc09f6cb49225', '5cee89230e7de03b95141fbb8464768191b7d60f6297518a9530d2ddc2de76c8', 1),
	(385, 740, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'attendance', 2, '{"note": "demo", "status": "present", "shift_id": 2, "created_at": "2026-07-18T18:59:19.094763+00:00", "clock_in_at": "2026-07-18T18:59:19.084375+00:00", "employee_id": 2, "facility_id": 1, "clock_out_at": "2026-07-18T18:59:19.085374+00:00", "attendance_id": 2}', 'db-trigger', '5cee89230e7de03b95141fbb8464768191b7d60f6297518a9530d2ddc2de76c8', '290eda0b2f6cf1bbc6e57b61818de01cb7d57bf277f08a2cfd26f8ffb42a6fdb', 1),
	(386, 742, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'employee_department', 2, '{"role": "demo", "end_date": "2025-01-01", "is_primary": true, "start_date": "2025-01-01", "emp_dept_id": 2, "employee_id": 2, "facility_id": 1, "department_id": 1}', 'db-trigger', '290eda0b2f6cf1bbc6e57b61818de01cb7d57bf277f08a2cfd26f8ffb42a6fdb', '239a6e3079bbaa8e37a528c98bce02e77699087ac0093d5cbffcd9818b4bfb94', 1),
	(387, 744, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'leave_request', 2, '{"reason": "demo", "status": "pending", "days_off": 1, "end_date": "2025-01-01", "leave_id": 2, "created_at": "2026-07-18T18:59:19.164673+00:00", "leave_type": "annual", "start_date": "2025-01-01", "updated_at": "2026-07-18T18:59:19.164673+00:00", "approved_at": "2026-07-18T18:59:19.163673+00:00", "approved_by": 99, "employee_id": 2, "facility_id": 1}', 'db-trigger', '239a6e3079bbaa8e37a528c98bce02e77699087ac0093d5cbffcd9818b4bfb94', '2151c4cdc960a56f449ce98a444117ac7d7e1fe81e377e707c48ff15c6b8958d', 1),
	(388, 746, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'post_op_note', 2, '{"pon_id": 2, "findings": "demo", "is_signed": true, "signed_at": "2026-07-18T18:59:19.214372+00:00", "pain_score": 1, "surgery_id": 2, "written_at": "2026-07-18T18:59:19.182171+00:00", "written_by": 99, "facility_id": 1, "instructions": "demo", "recovery_room": "demo", "follow_up_days": 1}', 'db-trigger', '2151c4cdc960a56f449ce98a444117ac7d7e1fe81e377e707c48ff15c6b8958d', 'd29a288c48cd6d008f2aab09c961aac5dc932034954ba8706e474561868e8f79', 1),
	(389, 748, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'pre_op_checklist', 2, '{"poc_id": 2, "created_at": "2026-07-18T18:59:19.250058+00:00", "iv_secured": true, "risk_score": "demo", "surgery_id": 2, "facility_id": 1, "site_marked": true, "checklist_by": 99, "completed_at": "2026-07-18T18:59:19.249056+00:00", "labs_checked": true, "consent_signed": true, "imaging_checked": true, "antibiotics_given": true, "fasting_confirmed": true}', 'db-trigger', 'd29a288c48cd6d008f2aab09c961aac5dc932034954ba8706e474561868e8f79', 'c53441e7f074e65fcb2b8356a488c8d6931d22c0145f5bc19b82e69cae8df622', 1),
	(390, 750, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'surgical_team', 99, '{"role": "surgeon", "left_at": "2026-07-18T18:59:19.280392+00:00", "user_id": 99, "joined_at": "2026-07-18T18:59:19.279298+00:00", "surgery_id": 2, "facility_id": 1, "surg_team_id": 2}', 'db-trigger', 'c53441e7f074e65fcb2b8356a488c8d6931d22c0145f5bc19b82e69cae8df622', 'aba87fc5ad597423175de327dc87ad81a03cd08a14c989e82c098bb4e5c6d6c0', 1),
	(394, 756, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'image_instance', 2, '{"rows": 1, "columns": 1, "image_id": 2, "study_id": 2, "created_at": "2026-07-18T18:59:19.532316+00:00", "image_type": "dicom", "facility_id": 1, "storage_uri": "demo", "series_number": 1, "bits_allocated": 1, "instance_number": 1, "sop_instance_uid": "demo"}', 'db-trigger', 'ed21f0eaaeb076220d1869f858091c71bbd23a57ad74f81f24c8f5de0926dcfd', '059c493be213ae29277d4ef24bef3dc849b4ceff9577d2c25b93a64719980b67', 1),
	(395, 758, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_icu', 'bed', 2, '{"level": 1, "bed_id": 2, "status": "available", "bed_label": "demo", "room_code": "demo", "created_at": "2026-07-18T18:59:19.579314+00:00", "updated_at": "2026-07-18T18:59:19.579314+00:00", "facility_id": 1, "has_dialysis": true, "is_isolation": true, "department_id": 1, "has_ventilator": true}', 'db-trigger', '059c493be213ae29277d4ef24bef3dc849b4ceff9577d2c25b93a64719980b67', '075653f071fe285f00a4548ab52f16f5c0fc371ffc1deba0e0b1d333b2687201', 1),
	(396, 760, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_icu', 'bed_stay', 2, '{"bed_id": 2, "stay_id": 2, "assigned_at": "2026-07-18T18:59:19.598529+00:00", "facility_id": 1, "released_at": "2026-07-18T18:59:19.599532+00:00", "admission_id": 2}', 'db-trigger', '075653f071fe285f00a4548ab52f16f5c0fc371ffc1deba0e0b1d333b2687201', 'd06980523a99c4d3eb26cdd63b1dd005b22903012c743dcc72f36b69a71abe2a', 1),
	(397, 762, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_icu', 'score', 2, '{"raw": 1, "type": "demo", "score_id": 2, "assessed_at": "2026-07-18T18:59:19.631091+00:00", "assessed_by": 99, "facility_id": 1, "admission_id": 2, "computed_value": 1.00, "interpretation": "demo"}', 'db-trigger', 'd06980523a99c4d3eb26cdd63b1dd005b22903012c743dcc72f36b69a71abe2a', '74f758aa7d2a4616227f1ad3a8c192818ad623e08bce13c5ec8c6586da65e742', 1),
	(398, 764, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'treatment_plan', 2, '{"notes": "demo", "status": "active", "ends_on": "2025-01-01", "plan_id": 2, "diagnosis": "demo", "frequency": "demo", "starts_on": "2025-01-01", "created_at": "2026-07-18T18:59:19.734154+00:00", "patient_id": 99001, "updated_at": "2026-07-18T18:59:19.734154+00:00", "facility_id": 1, "encounter_id": 2, "treatment_goals": "demo", "sessions_planned": 1, "therapist_user_id": 99, "sessions_completed": 1}', 'db-trigger', '74f758aa7d2a4616227f1ad3a8c192818ad623e08bce13c5ec8c6586da65e742', '46f76025c0c065ca685817162d4ec5f74f682aeb7ccf3b150c9fc3c041f7fe25', 1),
	(399, 766, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_dialysis', 'station', 2, '{"code": "demo", "name": "demo", "status": "available", "created_at": "2026-07-18T18:59:19.866335+00:00", "station_id": 2, "updated_at": "2026-07-18T18:59:19.866335+00:00", "facility_id": 1, "has_ro_water": true, "department_id": 1}', 'db-trigger', '46f76025c0c065ca685817162d4ec5f74f682aeb7ccf3b150c9fc3c041f7fe25', '944f3132c4a0126618cbe4239feacabd393202fb7d011fdad64b8f335c5d7221', 1),
	(400, 768, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_dialysis', 'session', 2, '{"kt_v": 1.00, "notes": "demo", "pre_bp": "demo", "status": "scheduled", "post_bp": "demo", "ended_at": "2026-07-18T18:59:19.890252+00:00", "modality": "hemodialysis", "created_at": "2026-07-18T18:59:19.943097+00:00", "patient_id": 99001, "session_id": 2, "started_at": "2026-07-18T18:59:19.887202+00:00", "station_id": 2, "updated_at": "2026-07-18T18:59:19.943097+00:00", "facility_id": 1, "encounter_id": 2, "scheduled_at": "2026-07-18T18:59:19.886151+00:00", "complications": "demo", "dry_weight_kg": 1.00, "heparin_units": 1, "nurse_user_id": 99, "pre_weight_kg": 1.00, "dialysate_flow": 1, "post_weight_kg": 1.00, "blood_flow_rate": 1, "duration_minutes": 1, "fluid_removed_ml": 1, "nephrologist_user_id": 99}', 'db-trigger', '944f3132c4a0126618cbe4239feacabd393202fb7d011fdad64b8f335c5d7221', 'd5d4f1d74e1dc364ce7de860218deb6b5f339f28b59f029d4cf9761be72506fb', 1);
INSERT INTO mcms_core.event_log VALUES
	(401, 770, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_nursery', 'cot', 2, '{"code": "demo", "name": "demo", "cot_id": 2, "status": "available", "created_at": "2026-07-18T18:59:19.973685+00:00", "updated_at": "2026-07-18T18:59:19.973685+00:00", "facility_id": 1, "is_incubator": true, "department_id": 1, "has_phototherapy": true}', 'db-trigger', 'd5d4f1d74e1dc364ce7de860218deb6b5f339f28b59f029d4cf9761be72506fb', '63a90ca0902ddb3562f589335978e5059e647722339c1e70e14c15794dfb4470', 1),
	(402, 772, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_nursery', 'neonate_record', 2, '{"notes": "demo", "cot_id": 2, "apgar_1min": 1, "apgar_5min": 1, "created_at": "2026-07-18T18:59:20.051556+00:00", "neonate_id": 2, "patient_id": 99001, "updated_at": "2026-07-18T18:59:20.051556+00:00", "admitted_at": "2026-07-18T18:59:20.04855+00:00", "facility_id": 1, "discharged_at": "2026-07-18T18:59:20.050552+00:00", "birth_weight_g": 1, "mother_party_id": 99003, "gestational_age_weeks": 1.0}', 'db-trigger', '63a90ca0902ddb3562f589335978e5059e647722339c1e70e14c15794dfb4470', '6ab0df4bc8500682606ff57fe66ea11bf305c233039039d0673d7bbc0dfdeb49', 1),
	(403, 774, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_nursery', 'growth_entry', 2, '{"notes": "demo", "entry_id": 2, "weight_g": 1, "length_cm": 1.00, "neonate_id": 2, "facility_id": 1, "recorded_at": "2026-07-18T18:59:20.064708+00:00", "feeding_type": "demo", "head_circ_cm": 1.00, "nurse_user_id": 99, "temperature_c": 1.0, "feed_volume_ml": 1}', 'db-trigger', '6ab0df4bc8500682606ff57fe66ea11bf305c233039039d0673d7bbc0dfdeb49', 'acaf1c790d8d4b8ed5ab2d5ecb06d293cb52ac01561a690aa25ff5437c86afa0', 1),
	(404, 776, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_core', 'notification', 9, '{"body": "Claim #2 for invoice #2 is now draft.", "status": "pending", "channel": "in_app", "read_at": null, "sent_at": null, "subject": "Insurance claim draft", "category": "claim_update", "source_id": 2, "created_at": "2026-07-18T18:59:17.914572+00:00", "facility_id": 1, "source_table": "insurance_claim", "source_schema": "mcms_billing", "notification_id": 9, "recipient_user_id": null, "recipient_party_id": 99003}', 'db-trigger', 'acaf1c790d8d4b8ed5ab2d5ecb06d293cb52ac01561a690aa25ff5437c86afa0', 'f37397e3a8c70a21428ee0930cade029cd0ec2b68a92b3f9e50b78fc1be2ed65', 1),
	(405, 777, '2026-07-18 21:59:17.914572+03', 'payment_received', 'info', 99, NULL, 'mcms_billing', 'payment', 2, '{"amount": 1.00, "method": "cash", "invoice_id": 2}', 'mcms', 'f37397e3a8c70a21428ee0930cade029cd0ec2b68a92b3f9e50b78fc1be2ed65', '861b69c5ccd42f6e3c4a6444e23d9b47bc0c8e23dd99b70ec1ec150754795993', 1),
	(406, 779, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'inventory_item', 2, '{"code": "demo", "name": "demo", "type": "consumable", "unit": "demo", "item_id": 2, "is_active": true, "created_at": "2026-07-18T18:59:20.213871+00:00", "updated_at": "2026-07-18T18:59:20.213871+00:00", "facility_id": 1, "reorder_qty": 1, "cost_per_unit": 1.00, "reorder_level": 1}', 'db-trigger', '861b69c5ccd42f6e3c4a6444e23d9b47bc0c8e23dd99b70ec1ec150754795993', 'e073934f8e49ec81f6a2045e57dea11e73c612f1657645d61e6cf7ce6f4a0027', 1),
	(407, 781, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'inventory_stock', 2, '{"item_id": 2, "stock_id": 2, "updated_at": "2026-07-18T18:59:20.247547+00:00", "facility_id": 1, "qty_on_hand": 1, "qty_reserved": 1, "department_id": 1, "last_count_at": "2026-07-18T18:59:20.246545+00:00"}', 'db-trigger', 'e073934f8e49ec81f6a2045e57dea11e73c612f1657645d61e6cf7ce6f4a0027', '4cb3692929005ad75bf27c3f7fe9fdb356c9e7b09c145b64fdf68c6f3e35a147', 1),
	(408, 783, '2026-07-18 21:59:17.914572+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'stock_movement', 2, '{"reason": "demo", "item_id": 2, "qty_delta": 1, "facility_id": 1, "movement_id": 2, "performed_at": "2026-07-18T18:59:20.297076+00:00", "performed_by": 99, "reference_id": 1, "movement_type": "issue", "reference_table": "demo", "to_department_id": 1, "from_department_id": 1}', 'db-trigger', '4cb3692929005ad75bf27c3f7fe9fdb356c9e7b09c145b64fdf68c6f3e35a147', '219c902bde87bfabe9fa3967e59d65b72a9c62c716ae8b5b4620a3bfdd81922e', 1);


ALTER TABLE mcms_core.event_log ENABLE TRIGGER ALL;

--
-- Data for Name: audit_trail; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.audit_trail DISABLE TRIGGER ALL;

INSERT INTO mcms_core.audit_trail VALUES
	(2, 'mcms_core', 'party', 1, 'update', 1, '2026-07-18 21:59:17.913956+03', '{}', '{}', 1, 1);


ALTER TABLE mcms_core.audit_trail ENABLE TRIGGER ALL;

--
-- Data for Name: backup_log; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.backup_log DISABLE TRIGGER ALL;



ALTER TABLE mcms_core.backup_log ENABLE TRIGGER ALL;

--
-- Data for Name: consent; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.consent DISABLE TRIGGER ALL;

INSERT INTO mcms_core.consent VALUES
	(1, 99003, 'data_sharing', true, '2026-07-18 21:59:07.423037+03', NULL, 99, 'Demo consent', 1);


ALTER TABLE mcms_core.consent ENABLE TRIGGER ALL;

--
-- Data for Name: contact; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.contact DISABLE TRIGGER ALL;

INSERT INTO mcms_core.contact VALUES
	(2, 1, 'phone', 'demo', true, '2026-07-18 21:59:18.864874+03', '2026-07-18 21:59:18.86587+03', 1);


ALTER TABLE mcms_core.contact ENABLE TRIGGER ALL;

--
-- Data for Name: identity_provider; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.identity_provider DISABLE TRIGGER ALL;

INSERT INTO mcms_core.identity_provider VALUES
	('moh_oidc', 'Ministry of Health OIDC', 'oidc', 'mcms-sp', '{"issuer": "https://id.moh.gov.example", "jwks_uri": "https://id.moh.gov.example/.well-known/jwks.json"}', false, '2026-07-18 21:59:07.641213+03', '2026-07-18 21:59:07.641213+03', 1),
	('nhif_saml', 'NHIF SAML IdP', 'saml', 'mcms-sp', '{"sso_url": "https://id.nhif.gov.example/sso", "entity_id": "https://id.nhif.gov.example"}', false, '2026-07-18 21:59:07.641213+03', '2026-07-18 21:59:07.641213+03', 1);


ALTER TABLE mcms_core.identity_provider ENABLE TRIGGER ALL;

--
-- Data for Name: federated_identity; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.federated_identity DISABLE TRIGGER ALL;



ALTER TABLE mcms_core.federated_identity ENABLE TRIGGER ALL;

--
-- Data for Name: hl7_message; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.hl7_message DISABLE TRIGGER ALL;



ALTER TABLE mcms_core.hl7_message ENABLE TRIGGER ALL;

--
-- Data for Name: lookup; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.lookup DISABLE TRIGGER ALL;

INSERT INTO mcms_core.lookup VALUES
	(2, 'icd10', 'J00', 'Acute nasopharyngitis [common cold]', NULL, 0, true, NULL, NULL, 1),
	(3, 'icd10', 'J20.9', 'Acute bronchitis, unspecified', NULL, 0, true, NULL, NULL, 1),
	(4, 'icd10', 'E11.9', 'Type 2 diabetes mellitus without complications', NULL, 0, true, NULL, NULL, 1),
	(5, 'icd10', 'I10', 'Essential (primary) hypertension', NULL, 0, true, NULL, NULL, 1),
	(6, 'icd10', 'E78.5', 'Hypercholesterolaemia, unspecified', NULL, 0, true, NULL, NULL, 1),
	(7, 'icd10', 'M54.5', 'Low back pain', NULL, 0, true, NULL, NULL, 1),
	(8, 'icd10', 'K21.9', 'Gastro-oesophageal reflux disease without oesophagitis', NULL, 0, true, NULL, NULL, 1),
	(9, 'icd10', 'N39.0', 'Urinary tract infection, site not specified', NULL, 0, true, NULL, NULL, 1),
	(10, 'icd10', 'R51', 'Headache', NULL, 0, true, NULL, NULL, 1),
	(11, 'icd10', 'S82.8', 'Fracture of other specified parts of lower leg', NULL, 0, true, NULL, NULL, 1),
	(12, 'icd10', 'I21.9', 'Acute myocardial infarction, unspecified', NULL, 0, true, NULL, NULL, 1),
	(13, 'icd10', 'J45.909', 'Unspecified asthma, uncomplicated', NULL, 0, true, NULL, NULL, 1),
	(14, 'icd10', 'C50.9', 'Malignant neoplasm of breast of unspecified site, female', NULL, 0, true, NULL, NULL, 1),
	(15, 'icd10', 'K80.20', 'Calculus of gallbladder without cholecystitis', NULL, 0, true, NULL, NULL, 1),
	(16, 'icd10', 'A09', 'Diarrhoea and gastroenteritis of infectious origin', NULL, 0, true, NULL, NULL, 1),
	(17, 'icd10', 'O80', 'Encounter for full-term uncomplicated delivery', NULL, 0, true, NULL, NULL, 1),
	(18, 'icd10', 'O34.21', 'Maternal care for congenital uterine malformation', NULL, 0, true, NULL, NULL, 1),
	(19, 'icd10', 'S06.0', 'Intracranial injury (concussion of brain)', NULL, 0, true, NULL, NULL, 1),
	(20, 'icd10', 'S72.0', 'Fracture of neck of femur', NULL, 0, true, NULL, NULL, 1),
	(21, 'icd10', 'S02.5', 'Fracture of tooth (traumatic)', NULL, 0, true, NULL, NULL, 1),
	(22, 'cpt', '99213', 'Office Visit, Established Patient, Low Complexity', NULL, 0, true, NULL, NULL, 1),
	(23, 'cpt', '99214', 'Office Visit, Established Patient, Moderate', NULL, 0, true, NULL, NULL, 1),
	(24, 'cpt', '99204', 'Office Visit, New Patient, Moderate', NULL, 0, true, NULL, NULL, 1),
	(25, 'cpt', '58150', 'Total abdominal hysterectomy', NULL, 0, true, NULL, NULL, 1),
	(26, 'cpt', '23470', 'Arthroplasty, glenohumeral joint', NULL, 0, true, NULL, NULL, 1),
	(27, 'cpt', '27130', 'Total hip arthroplasty', NULL, 0, true, NULL, NULL, 1),
	(28, 'cpt', '27447', 'Total knee arthroplasty', NULL, 0, true, NULL, NULL, 1),
	(29, 'cpt', '49505', 'Repair of femoral hernia', NULL, 0, true, NULL, NULL, 1),
	(30, 'cpt', '47579', 'Open cholecystectomy', NULL, 0, true, NULL, NULL, 1),
	(31, 'cpt', '33533', 'Coronary artery bypass, single', NULL, 0, true, NULL, NULL, 1),
	(32, 'cpt', '80053', 'Comprehensive Metabolic Panel', NULL, 0, true, NULL, NULL, 1),
	(33, 'cpt', '80048', 'Basic Metabolic Panel', NULL, 0, true, NULL, NULL, 1),
	(34, 'cpt', '85025', 'CBC w/ differential', NULL, 0, true, NULL, NULL, 1),
	(35, 'cpt', '81002', 'Urinalysis, non-automated', NULL, 0, true, NULL, NULL, 1),
	(36, 'cpt', '71045', 'X-ray chest, complete view', NULL, 0, true, NULL, NULL, 1),
	(37, 'cpt', '71250', 'CT thorax without contrast', NULL, 0, true, NULL, NULL, 1),
	(38, 'cpt', '70553', 'MRI brain with contrast', NULL, 0, true, NULL, NULL, 1),
	(39, 'cpt', '76700', 'Ultrasound abdomen', NULL, 0, true, NULL, NULL, 1),
	(40, 'cpt', '93000', 'ECG, 12-lead', NULL, 0, true, NULL, NULL, 1);


ALTER TABLE mcms_core.lookup ENABLE TRIGGER ALL;

--
-- Data for Name: notification; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.notification DISABLE TRIGGER ALL;

INSERT INTO mcms_core.notification VALUES
	(2, 1, 99005, 'appointment_reminder', 'in_app', 'Appointment booked', 'Appointment on 2026-07-19 03:59 (booked).', 'pending', 'mcms_clinic', 'appointment', 2, NULL, NULL, '2026-07-18 21:59:17.914572+03', 1),
	(3, 1, 99006, 'appointment_reminder', 'in_app', 'Appointment booked', 'Appointment on 2026-07-20 03:59 (booked).', 'pending', 'mcms_clinic', 'appointment', 3, NULL, NULL, '2026-07-18 21:59:17.914572+03', 1),
	(4, 1, 99007, 'appointment_reminder', 'in_app', 'Appointment booked', 'Appointment on 2026-07-21 03:59 (booked).', 'pending', 'mcms_clinic', 'appointment', 4, NULL, NULL, '2026-07-18 21:59:17.914572+03', 1),
	(5, 1, 99008, 'appointment_reminder', 'in_app', 'Appointment booked', 'Appointment on 2026-07-22 03:59 (booked).', 'pending', 'mcms_clinic', 'appointment', 5, NULL, NULL, '2026-07-18 21:59:17.914572+03', 1),
	(6, NULL, 99005, 'abnormal_result', 'in_app', 'abnormal_result: WBC Count', 'Result for WBC Count flagged normal.', 'pending', 'mcms_lab', 'result', 2, NULL, NULL, '2026-07-18 21:59:17.914572+03', 1),
	(7, NULL, 99006, 'abnormal_result', 'in_app', 'abnormal_result: WBC Count', 'Result for WBC Count flagged normal.', 'pending', 'mcms_lab', 'result', 3, NULL, NULL, '2026-07-18 21:59:17.914572+03', 1),
	(8, NULL, 99007, 'abnormal_result', 'in_app', 'abnormal_result: WBC Count', 'Result for WBC Count flagged normal.', 'pending', 'mcms_lab', 'result', 4, NULL, NULL, '2026-07-18 21:59:17.914572+03', 1),
	(9, NULL, 99003, 'claim_update', 'in_app', 'Insurance claim draft', 'Claim #2 for invoice #2 is now draft.', 'pending', 'mcms_billing', 'insurance_claim', 2, NULL, NULL, '2026-07-18 21:59:17.914572+03', 1);


ALTER TABLE mcms_core.notification ENABLE TRIGGER ALL;

--
-- Data for Name: permission; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.permission DISABLE TRIGGER ALL;

INSERT INTO mcms_core.permission VALUES
	(1, 'patient.portal', 'Access own patient portal (appointments, results, bills, consents)', 1),
	(2, 'rx.prescribe', 'Create / sign electronic prescriptions', 1),
	(3, 'vital_records.read', 'View birth/death certificates', 1),
	(4, 'vital_records.register', 'Register (issue) birth/death certificates', 1),
	(5, 'vital_records.certify', 'Certify cause of death / clinical attestation', 1),
	(6, 'waste.read', 'View medical waste records, quantities and costs', 1),
	(7, 'waste.manage', 'Create/edit medical waste records and disposal manifests', 1),
	(8, 'appointment.manage', 'Book/modify appointments', 1),
	(9, 'inventory.manage', 'Manage inventory & batches', 1),
	(10, 'emr.write', 'Write clinical records / orders / prescriptions', 1),
	(11, 'pharmacy.dispense', 'Dispense medications', 1),
	(12, 'order.execute', 'Execute orders / enter preliminary results', 1),
	(13, 'emr.read', 'Read clinical records', 1),
	(14, 'billing.manage', 'Create/modify invoices & payments', 1),
	(15, 'patient.read', 'View patient demographics', 1),
	(16, 'lab_rad.result', 'Enter lab/radiology results & reports', 1),
	(17, 'patient.write', 'Create/edit patients', 1),
	(18, 'admin.all', 'Full administrative access', 1),
	(19, 'billing.read', 'View financial reports', 1),
	(20, 'hr.read', 'Read HR / workforce data', 1);


ALTER TABLE mcms_core.permission ENABLE TRIGGER ALL;

--
-- Data for Name: role; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.role DISABLE TRIGGER ALL;

INSERT INTO mcms_core.role VALUES
	(1, 'patient', 'Patient', 'مريض', 'Self-service portal access scoped to own record', true, '2026-07-18 21:59:07.423037+03', 1),
	(2, 'lab_rad', 'Laboratory/Radiology', 'مختبر/أشعة', 'Results & reports entry, DICOM', true, '2026-07-18 21:59:08.579833+03', 1),
	(3, 'reception', 'Receptionist', 'موظف استقبال', 'Patient & appointment management, no clinical records', true, '2026-07-18 21:59:08.579833+03', 1),
	(4, 'pharmacist', 'Pharmacist', 'صيدلي', 'Medication management, dispensing, interactions', true, '2026-07-18 21:59:08.579833+03', 1),
	(5, 'nurse', 'Nurse/Technician', 'ممرض/فني', 'Execute orders, vitals, preliminary results', true, '2026-07-18 21:59:08.579833+03', 1),
	(6, 'accountant', 'Accountant', 'محاسب', 'Billing, payments, financial reports', true, '2026-07-18 21:59:08.579833+03', 1),
	(7, 'sysadmin', 'System Administrator', 'مدير النظام', 'User management, roles, settings, full access', true, '2026-07-18 21:59:08.579833+03', 1),
	(8, 'doctor', 'Doctor', 'طبيب', 'Read/write records, order tests, prescribe', true, '2026-07-18 21:59:08.579833+03', 1),
	(9, 'store_mgr', 'Warehouse Manager', 'مدير المخزن', 'Inventory & batch management', true, '2026-07-18 21:59:08.579833+03', 1);


ALTER TABLE mcms_core.role ENABLE TRIGGER ALL;

--
-- Data for Name: role_permission; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.role_permission DISABLE TRIGGER ALL;

INSERT INTO mcms_core.role_permission VALUES
	(1, 1, 1),
	(1, 3, 1),
	(8, 8, 1),
	(3, 8, 1),
	(9, 9, 1),
	(8, 10, 1),
	(4, 11, 1),
	(5, 12, 1),
	(8, 13, 1),
	(7, 13, 1),
	(5, 13, 1),
	(4, 13, 1),
	(2, 13, 1),
	(6, 14, 1),
	(8, 15, 1),
	(7, 15, 1),
	(5, 15, 1),
	(3, 15, 1),
	(2, 16, 1),
	(3, 17, 1),
	(7, 18, 1),
	(7, 19, 1),
	(6, 19, 1),
	(7, 20, 1);


ALTER TABLE mcms_core.role_permission ENABLE TRIGGER ALL;

--
-- Data for Name: system_flag; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.system_flag DISABLE TRIGGER ALL;

INSERT INTO mcms_core.system_flag VALUES
	('maintenance_mode', 'false', '2026-07-18 21:59:08.646446+03', 1),
	('last_schema_sync', 'never', '2026-07-18 21:59:08.646446+03', 1);


ALTER TABLE mcms_core.system_flag ENABLE TRIGGER ALL;

--
-- Data for Name: user_role_map; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.user_role_map DISABLE TRIGGER ALL;

INSERT INTO mcms_core.user_role_map VALUES
	(99, 1, NULL, 1),
	(1, 7, NULL, 1),
	(2, 6, NULL, 1);


ALTER TABLE mcms_core.user_role_map ENABLE TRIGGER ALL;

--
-- Data for Name: station; Type: TABLE DATA; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE mcms_dialysis.station DISABLE TRIGGER ALL;

INSERT INTO mcms_dialysis.station VALUES
	(2, 'demo', 'demo', 1, true, 'available', '2026-07-18 21:59:19.866335+03', '2026-07-18 21:59:19.866335+03', 1);


ALTER TABLE mcms_dialysis.station ENABLE TRIGGER ALL;

--
-- Data for Name: session; Type: TABLE DATA; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE mcms_dialysis.session DISABLE TRIGGER ALL;

INSERT INTO mcms_dialysis.session VALUES
	(2, 99001, 2, 2, 99, 99, 'hemodialysis', '2026-07-18 21:59:19.886151+03', '2026-07-18 21:59:19.887202+03', '2026-07-18 21:59:19.890252+03', 1, 1.00, 'demo', 1.00, 1.00, 'demo', 1, 1, 1, 1, 1.00, 'demo', 'scheduled', 'demo', '2026-07-18 21:59:19.943097+03', '2026-07-18 21:59:19.943097+03', 1);


ALTER TABLE mcms_dialysis.session ENABLE TRIGGER ALL;

--
-- Data for Name: triage; Type: TABLE DATA; Schema: mcms_emergency; Owner: -
--

ALTER TABLE mcms_emergency.triage DISABLE TRIGGER ALL;

INSERT INTO mcms_emergency.triage VALUES
	(2, 'EV-DEMO-001', 99002, 'MRN-DEMO-001', 2, '2026-07-18 21:59:17.914572+03', 'Chest pain', 2, NULL, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'awaiting', NULL, NULL, NULL, '2026-07-18 21:59:17.914572+03', '2026-07-18 21:59:17.914572+03', 1);


ALTER TABLE mcms_emergency.triage ENABLE TRIGGER ALL;

--
-- Data for Name: ed_bed; Type: TABLE DATA; Schema: mcms_emergency; Owner: -
--

ALTER TABLE mcms_emergency.ed_bed DISABLE TRIGGER ALL;

INSERT INTO mcms_emergency.ed_bed VALUES
	(2, 2, 'demo', '2026-07-18 21:59:19.298741+03', '2026-07-18 21:59:19.299741+03', 1, 'demo', 1);


ALTER TABLE mcms_emergency.ed_bed ENABLE TRIGGER ALL;

--
-- Data for Name: resuscitation; Type: TABLE DATA; Schema: mcms_emergency; Owner: -
--

ALTER TABLE mcms_emergency.resuscitation DISABLE TRIGGER ALL;

INSERT INTO mcms_emergency.resuscitation VALUES
	(2, 2, 2, 99002, '2026-07-18 21:59:17.914572+03', NULL, NULL, NULL, NULL, NULL, NULL, false, NULL, NULL, NULL, NULL, '2026-07-18 21:59:17.914572+03', 1);


ALTER TABLE mcms_emergency.resuscitation ENABLE TRIGGER ALL;

--
-- Data for Name: allergy; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.allergy DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.allergy VALUES
	(2, 99002, 'Penicillin', 'Rash', 'moderate', 'childhood', '2026-07-18 21:59:17.913956+03', 1, true, 1),
	(3, 99003, 'Penicillin', 'Rash', 'moderate', 'childhood', '2026-07-18 21:59:17.913956+03', 1, true, 1),
	(4, 99004, 'Penicillin', 'Rash', 'moderate', 'childhood', '2026-07-18 21:59:17.913956+03', 1, true, 1),
	(5, 99005, 'Penicillin', 'Rash', 'moderate', 'childhood', '2026-07-18 21:59:17.913956+03', 1, true, 1),
	(6, 99006, 'Penicillin', 'Rash', 'moderate', 'childhood', '2026-07-18 21:59:17.913956+03', 1, true, 1);


ALTER TABLE mcms_emr.allergy ENABLE TRIGGER ALL;

--
-- Data for Name: clinical_note; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.clinical_note DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.clinical_note VALUES
	(2, 2, 99002, 'progress', 'Demo Note', 'Demonstration clinical note.', 1, NULL, true, '2026-07-18 21:59:17.913956+03', NULL, '2026-07-18 21:59:18.113661+03', '2026-07-18 21:59:18.113661+03', 1, 1),
	(3, 3, 99003, 'progress', 'Demo Note', 'Demonstration clinical note.', 1, NULL, true, '2026-07-18 21:59:17.913956+03', NULL, '2026-07-18 21:59:18.147965+03', '2026-07-18 21:59:18.147965+03', 1, 1),
	(4, 4, 99004, 'progress', 'Demo Note', 'Demonstration clinical note.', 1, NULL, true, '2026-07-18 21:59:17.913956+03', NULL, '2026-07-18 21:59:18.162554+03', '2026-07-18 21:59:18.162554+03', 1, 1),
	(5, 5, 99005, 'progress', 'Demo Note', 'Demonstration clinical note.', 1, NULL, true, '2026-07-18 21:59:17.913956+03', NULL, '2026-07-18 21:59:18.176745+03', '2026-07-18 21:59:18.176745+03', 1, 1),
	(6, 6, 99006, 'progress', 'Demo Note', 'Demonstration clinical note.', 1, NULL, true, '2026-07-18 21:59:17.913956+03', NULL, '2026-07-18 21:59:18.18689+03', '2026-07-18 21:59:18.18689+03', 1, 1),
	(7, 2, 99002, 'lab_result', 'Lab result: WBC Count', 'Auto-routed from mcms_lab.result #2 | flag=normal | value=Normal', 1, NULL, false, NULL, NULL, '2026-07-18 21:59:17.914572+03', '2026-07-18 21:59:17.914572+03', NULL, 1),
	(8, 2, 99003, 'lab_result', 'Lab result: WBC Count', 'Auto-routed from mcms_lab.result #3 | flag=normal | value=Normal', 1, NULL, false, NULL, NULL, '2026-07-18 21:59:17.914572+03', '2026-07-18 21:59:17.914572+03', NULL, 1),
	(9, 2, 99004, 'lab_result', 'Lab result: WBC Count', 'Auto-routed from mcms_lab.result #4 | flag=normal | value=Normal', 1, NULL, false, NULL, NULL, '2026-07-18 21:59:17.914572+03', '2026-07-18 21:59:17.914572+03', NULL, 1);


ALTER TABLE mcms_emr.clinical_note ENABLE TRIGGER ALL;

--
-- Data for Name: diagnosis; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.diagnosis DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.diagnosis VALUES
	(2, 2, 99001, 'demo', 'demo', 'admitting', 'active', '2025-01-01', '2026-07-18 21:59:18.9345+03', 99, true, '2026-07-18 21:59:18.951505+03', false, '2026-07-18 21:59:18.946409+03', 99, 1);


ALTER TABLE mcms_emr.diagnosis ENABLE TRIGGER ALL;

--
-- Data for Name: family_history; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.family_history DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.family_history VALUES
	(2, 99002, 'Father', 'father', 'I10', 'Hypertension', 50, false, '2026-07-18 21:59:17.913956+03', 1),
	(3, 99003, 'Father', 'father', 'I10', 'Hypertension', 50, false, '2026-07-18 21:59:17.913956+03', 1),
	(4, 99004, 'Father', 'father', 'I10', 'Hypertension', 50, false, '2026-07-18 21:59:17.913956+03', 1),
	(5, 99005, 'Father', 'father', 'I10', 'Hypertension', 50, false, '2026-07-18 21:59:17.913956+03', 1),
	(6, 99006, 'Father', 'father', 'I10', 'Hypertension', 50, false, '2026-07-18 21:59:17.913956+03', 1);


ALTER TABLE mcms_emr.family_history ENABLE TRIGGER ALL;

--
-- Data for Name: immunization; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.immunization DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.immunization VALUES
	(2, 99002, 'COVID-19', 'COVID-19 vaccine', 2, '2026-07-18 21:59:17.913956+03', 1, 'LOT-DEMO', 'LA', 'none', 1),
	(3, 99003, 'COVID-19', 'COVID-19 vaccine', 2, '2026-07-18 21:59:17.913956+03', 1, 'LOT-DEMO', 'LA', 'none', 1),
	(4, 99004, 'COVID-19', 'COVID-19 vaccine', 2, '2026-07-18 21:59:17.913956+03', 1, 'LOT-DEMO', 'LA', 'none', 1),
	(5, 99005, 'COVID-19', 'COVID-19 vaccine', 2, '2026-07-18 21:59:17.913956+03', 1, 'LOT-DEMO', 'LA', 'none', 1),
	(6, 99006, 'COVID-19', 'COVID-19 vaccine', 2, '2026-07-18 21:59:17.913956+03', 1, 'LOT-DEMO', 'LA', 'none', 1);


ALTER TABLE mcms_emr.immunization ENABLE TRIGGER ALL;

--
-- Data for Name: medication_order; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.medication_order DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.medication_order VALUES
	(2, NULL, 99002, 1, 2, 'Paracetamol', '500 mg', 'po', 'tid', 5, false, 0, 'After meals', 'active', '2026-07-18 21:59:17.913956+03', '2026-07-18 21:59:18.212629+03', '2026-07-18 21:59:18.212629+03', true, '2026-07-18 21:59:17.913956+03', 1, 1),
	(3, NULL, 99003, 1, 2, 'Paracetamol', '500 mg', 'po', 'tid', 5, false, 0, 'After meals', 'active', '2026-07-17 21:59:17.913956+03', '2026-07-18 21:59:18.217215+03', '2026-07-18 21:59:18.217215+03', true, '2026-07-18 21:59:17.913956+03', 1, 1),
	(4, NULL, 99004, 1, 2, 'Paracetamol', '500 mg', 'po', 'tid', 5, false, 0, 'After meals', 'active', '2026-07-16 21:59:17.913956+03', '2026-07-18 21:59:18.22549+03', '2026-07-18 21:59:18.22549+03', true, '2026-07-18 21:59:17.913956+03', 1, 1);


ALTER TABLE mcms_emr.medication_order ENABLE TRIGGER ALL;

--
-- Data for Name: referral; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.referral DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.referral OVERRIDING SYSTEM VALUE VALUES
	(2, 2, 2, 1, 99, 1, 2, 'demo', 'demo', 'demo', 'draft', '2026-07-18 21:59:18.998635+03', '2026-07-18 21:59:18.999677+03', '2026-07-18 21:59:17.914572+03', 1);


ALTER TABLE mcms_emr.referral ENABLE TRIGGER ALL;

--
-- Data for Name: referral_linkage_rule; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.referral_linkage_rule DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.referral_linkage_rule VALUES
	(1, NULL, 'I21.9', 'icd10', 4, 10, 'Acute myocardial infarction requires cardiology review', true, '2026-07-18 21:59:07.66045+03', 2, 1),
	(2, NULL, 'I10', 'icd10', 4, 20, 'Essential hypertension -> cardiology / cardiovascular', true, '2026-07-18 21:59:07.66045+03', 2, 1),
	(3, NULL, 'E78.5', 'icd10', 4, 30, 'Hypercholesterolaemia -> cardiovascular risk clinic', true, '2026-07-18 21:59:07.66045+03', 2, 1),
	(4, NULL, 'C50.9', 'icd10', 12, 10, 'Breast malignancy -> clinical oncology & nuclear medicine', true, '2026-07-18 21:59:07.66045+03', 4, 1),
	(5, NULL, 'C50.9', 'icd10', 1, 20, 'Breast malignancy -> oncology unit', true, '2026-07-18 21:59:07.66045+03', 4, 1),
	(6, NULL, 'E11.9', 'icd10', 2, 10, 'Type 2 diabetes -> general internal medicine', true, '2026-07-18 21:59:07.66045+03', 2, 1),
	(7, NULL, 'J20.9', 'icd10', 5, 10, 'Acute bronchitis -> chest diseases', true, '2026-07-18 21:59:07.66045+03', 2, 1),
	(8, NULL, 'J00', 'icd10', 5, 20, 'Acute nasopharyngitis / URTI -> chest diseases', true, '2026-07-18 21:59:07.66045+03', 2, 1),
	(9, NULL, 'A09', 'icd10', 2, 10, 'Infectious gastroenteritis -> general internal medicine', true, '2026-07-18 21:59:07.66045+03', 2, 1),
	(10, NULL, 'I63.9', 'icd10', 3, 10, 'Cerebral infarction -> neurology & psychiatry', true, '2026-07-18 21:59:07.66045+03', 2, 1),
	(11, NULL, 'I60.9', 'icd10', 3, 10, 'Subarachnoid haemorrhage -> neurology & psychiatry', true, '2026-07-18 21:59:07.66045+03', 2, 1),
	(12, 7, NULL, NULL, 1, 30, 'Suspicious skin lesion -> oncology review', true, '2026-07-18 21:59:07.66045+03', 4, 1),
	(13, 2, NULL, NULL, 4, 5, 'Cross-facility: district internal medicine -> tertiary cardiology', true, '2026-07-18 21:59:07.674999+03', 2, 1);


ALTER TABLE mcms_emr.referral_linkage_rule ENABLE TRIGGER ALL;

--
-- Data for Name: social_history; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.social_history DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.social_history VALUES
	(2, 99002, 'never', 0.0, 0, 'none', 0, '{none}', 'Demo', 'married', '2026-07-18 21:59:17.913956+03', 1),
	(3, 99003, 'never', 0.0, 0, 'none', 0, '{none}', 'Demo', 'married', '2026-07-18 21:59:17.913956+03', 1),
	(4, 99004, 'never', 0.0, 0, 'none', 0, '{none}', 'Demo', 'married', '2026-07-18 21:59:17.913956+03', 1),
	(5, 99005, 'never', 0.0, 0, 'none', 0, '{none}', 'Demo', 'married', '2026-07-18 21:59:17.913956+03', 1),
	(6, 99006, 'never', 0.0, 0, 'none', 0, '{none}', 'Demo', 'married', '2026-07-18 21:59:17.913956+03', 1);


ALTER TABLE mcms_emr.social_history ENABLE TRIGGER ALL;

--
-- Data for Name: vitals; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.vitals DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.vitals VALUES
	(2, 2, 99002, '2026-07-18 21:59:17.913956+03', 1, 37.0, 80, 16, 120, 80, 98.0, 70.00, 170.0, DEFAULT, 0, NULL, 1),
	(3, 3, 99003, '2026-07-17 21:59:17.913956+03', 1, 37.0, 80, 16, 120, 80, 98.0, 70.00, 170.0, DEFAULT, 0, NULL, 1),
	(4, 4, 99004, '2026-07-16 21:59:17.913956+03', 1, 37.0, 80, 16, 120, 80, 98.0, 70.00, 170.0, DEFAULT, 0, NULL, 1),
	(5, 5, 99005, '2026-07-15 21:59:17.913956+03', 1, 37.0, 80, 16, 120, 80, 98.0, 70.00, 170.0, DEFAULT, 0, NULL, 1),
	(6, 6, 99006, '2026-07-14 21:59:17.913956+03', 1, 37.0, 80, 16, 120, 80, 98.0, 70.00, 170.0, DEFAULT, 0, NULL, 1);


ALTER TABLE mcms_emr.vitals ENABLE TRIGGER ALL;

--
-- Data for Name: gl_account; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.gl_account DISABLE TRIGGER ALL;

INSERT INTO mcms_erp.gl_account VALUES
	(2, '1000', 'Assets', 'asset', NULL, true, true, 1),
	(3, '1001', 'Cash on Hand', 'cash', NULL, true, true, 1),
	(4, '1002', 'Bank Account', 'bank', NULL, true, true, 1),
	(5, '1200', 'Accounts Receivable', 'asset', NULL, true, true, 1),
	(6, '1400', 'Inventory', 'asset', NULL, true, true, 1),
	(7, '2000', 'Liabilities', 'liability', NULL, true, true, 1),
	(8, '2100', 'Accounts Payable', 'liability', NULL, true, true, 1),
	(9, '3000', 'Equity', 'equity', NULL, true, true, 1),
	(10, '4000', 'Outpatient Revenue', 'revenue', NULL, true, true, 1),
	(11, '4100', 'Surgical Revenue', 'revenue', NULL, true, true, 1),
	(12, '4200', 'Lab Revenue', 'revenue', NULL, true, true, 1),
	(13, '4300', 'Pharmacy Revenue', 'revenue', NULL, true, true, 1),
	(14, '4400', 'Imaging Revenue', 'revenue', NULL, true, true, 1),
	(15, '4500', 'ICU Revenue', 'revenue', NULL, true, true, 1),
	(16, '4600', 'ER Revenue', 'revenue', NULL, true, true, 1),
	(17, '5000', 'Cost of Consumables', 'expense', NULL, true, true, 1),
	(18, '5100', 'Cost of Drugs Sold', 'expense', NULL, true, true, 1),
	(19, '5200', 'Salaries & Wages', 'expense', NULL, true, true, 1),
	(20, '5300', 'Utilities Expense', 'expense', NULL, true, true, 1),
	(21, '5400', 'Depreciation', 'expense', NULL, true, true, 1);


ALTER TABLE mcms_erp.gl_account ENABLE TRIGGER ALL;

--
-- Data for Name: supplier; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.supplier DISABLE TRIGGER ALL;

INSERT INTO mcms_erp.supplier VALUES
	(2, 1, 'SUP-DEMO-001', NULL, 30, true, '2026-07-18 21:59:17.914572+03', 1);


ALTER TABLE mcms_erp.supplier ENABLE TRIGGER ALL;

--
-- Data for Name: purchase_order; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.purchase_order DISABLE TRIGGER ALL;

INSERT INTO mcms_erp.purchase_order VALUES
	(2, 'PO-DEMO-001', 2, 1, NULL, 'draft', NULL, '2026-07-18 21:59:17.914572+03', NULL, NULL, NULL, '2026-07-18 21:59:17.914572+03', '2026-07-18 21:59:17.914572+03', 1);


ALTER TABLE mcms_erp.purchase_order ENABLE TRIGGER ALL;

--
-- Data for Name: goods_receipt; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.goods_receipt DISABLE TRIGGER ALL;

INSERT INTO mcms_erp.goods_receipt VALUES
	(2, 'GRN-DEMO-001', NULL, 2, 1, '2026-07-18 21:59:17.914572+03', 'pending', NULL, 1);


ALTER TABLE mcms_erp.goods_receipt ENABLE TRIGGER ALL;

--
-- Data for Name: inventory_item; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.inventory_item DISABLE TRIGGER ALL;

INSERT INTO mcms_erp.inventory_item VALUES
	(2, 'demo', 'demo', 'consumable', 'demo', 1, 1, 1.00, true, '2026-07-18 21:59:20.213871+03', '2026-07-18 21:59:20.213871+03', 1);


ALTER TABLE mcms_erp.inventory_item ENABLE TRIGGER ALL;

--
-- Data for Name: drug_item; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.drug_item DISABLE TRIGGER ALL;

INSERT INTO mcms_rx.drug_item VALUES
	(2, 'Paracetamol', 'Panadol', 'analgesic', 'tablet', '500 mg', 'tablet', NULL, false, false, NULL, 1000, 5000, true, 0.05, 0.15, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(3, 'Ibuprofen', 'Brufen', 'nsaid', 'tablet', '400 mg', 'tablet', NULL, false, false, NULL, 500, 3000, true, 0.08, 0.20, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(4, 'Acetylsalicylic acid', 'Aspec', 'cardiac', 'tablet', '75 mg', 'tablet', NULL, false, false, NULL, 200, 1000, true, 0.03, 0.10, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(5, 'Amoxicillin', 'Amoxil', 'antibiotic', 'capsule', '500 mg', 'capsule', NULL, false, false, NULL, 300, 2000, true, 0.10, 0.30, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(6, 'Cephalexin', 'Keflex', 'antibiotic', 'capsule', '500 mg', 'capsule', NULL, false, false, NULL, 300, 2000, true, 0.15, 0.40, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(7, 'Metformin', 'Glucophage', 'antidiabetic', 'tablet', '850 mg', 'tablet', NULL, false, false, NULL, 400, 2500, true, 0.06, 0.20, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(8, 'Atorvastatin', 'Lipitor', 'cardiac', 'tablet', '20 mg', 'tablet', NULL, false, false, NULL, 400, 2500, true, 0.20, 0.55, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(9, 'Amlodipine', 'Norvasc', 'antihypertensive', 'tablet', '10 mg', 'tablet', NULL, false, false, NULL, 400, 2500, true, 0.10, 0.30, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(10, 'Omeprazole', 'Prilosec', 'gi', 'capsule', '20 mg', 'capsule', NULL, false, false, NULL, 500, 3000, true, 0.10, 0.35, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(11, 'Salbutamol', 'Ventolin', 'respiratory', 'inhaler', '100 mcg', 'inhaler', NULL, false, false, NULL, 100, 500, true, 1.20, 4.50, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(12, 'Insulin Lispro', 'Humalog', 'antidiabetic', 'vial', '100 u/mL', 'vial', NULL, false, false, NULL, 80, 400, true, 6.50, 15.00, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(13, 'Morphine', 'Morphsul', 'analgesic', 'ampule', '10 mg/mL', 'ampule', NULL, false, false, NULL, 80, 300, true, 1.50, 5.00, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(14, 'Cetirizine', 'Zyrtec', 'antihistamine', 'tablet', '10 mg', 'tablet', NULL, false, false, NULL, 400, 2500, true, 0.05, 0.20, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(15, 'Dextrose 5%', 'D5W', 'iv_fluid', 'bag', '500 mL', 'bag', NULL, false, false, NULL, 100, 600, true, 1.00, 3.50, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1),
	(16, 'Sodium Chloride 0.9%', 'NS', 'iv_fluid', 'bag', '1000 mL', 'bag', NULL, false, false, NULL, 100, 600, true, 1.00, 4.00, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', NULL, 1);


ALTER TABLE mcms_rx.drug_item ENABLE TRIGGER ALL;

--
-- Data for Name: purchase_order_line; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.purchase_order_line DISABLE TRIGGER ALL;

INSERT INTO mcms_erp.purchase_order_line VALUES
	(2, 2, NULL, 2, 'Demo PO line', 5, 10.00, 5, DEFAULT, 1);


ALTER TABLE mcms_erp.purchase_order_line ENABLE TRIGGER ALL;

--
-- Data for Name: goods_receipt_line; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.goods_receipt_line DISABLE TRIGGER ALL;

INSERT INTO mcms_erp.goods_receipt_line VALUES
	(2, 2, 2, NULL, NULL, 5, NULL, NULL, NULL, 1);


ALTER TABLE mcms_erp.goods_receipt_line ENABLE TRIGGER ALL;

--
-- Data for Name: inventory_stock; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.inventory_stock DISABLE TRIGGER ALL;

INSERT INTO mcms_erp.inventory_stock VALUES
	(2, 2, 1, 1, 1, '2026-07-18 21:59:20.246545+03', '2026-07-18 21:59:20.247547+03', 1);


ALTER TABLE mcms_erp.inventory_stock ENABLE TRIGGER ALL;

--
-- Data for Name: stock_movement; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.stock_movement DISABLE TRIGGER ALL;

INSERT INTO mcms_erp.stock_movement VALUES
	(2, 2, 1, 1, 1, 'issue', 'demo', 1, 99, '2026-07-18 21:59:20.297076+03', 'demo', 1);


ALTER TABLE mcms_erp.stock_movement ENABLE TRIGGER ALL;

--
-- Data for Name: employee; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.employee DISABLE TRIGGER ALL;

INSERT INTO mcms_hr.employee VALUES
	(2, 99003, 99, 'demo', 1, 'demo', 'demo', 'demo', 'demo', 'permanent', 'active', '2025-01-01', '2025-01-01', 1.00, 'demo', 'demo', '2026-07-18 21:59:19.051288+03', '2026-07-18 21:59:19.051288+03', 1);


ALTER TABLE mcms_hr.employee ENABLE TRIGGER ALL;

--
-- Data for Name: shift; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.shift DISABLE TRIGGER ALL;

INSERT INTO mcms_hr.shift VALUES
	(2, 1, 2, 'morning', '2026-07-18 21:59:19.077295+03', '2026-07-18 21:59:19.0783+03', '2026-07-18 21:59:19.079293+03', 1);


ALTER TABLE mcms_hr.shift ENABLE TRIGGER ALL;

--
-- Data for Name: attendance; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.attendance DISABLE TRIGGER ALL;

INSERT INTO mcms_hr.attendance VALUES
	(2, 2, 2, '2026-07-18 21:59:19.084375+03', '2026-07-18 21:59:19.085374+03', 'present', 'demo', '2026-07-18 21:59:19.094763+03', 1);


ALTER TABLE mcms_hr.attendance ENABLE TRIGGER ALL;

--
-- Data for Name: employee_department; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.employee_department DISABLE TRIGGER ALL;

INSERT INTO mcms_hr.employee_department VALUES
	(2, 2, 1, 'demo', '2025-01-01', '2025-01-01', true, 1);


ALTER TABLE mcms_hr.employee_department ENABLE TRIGGER ALL;

--
-- Data for Name: leave_request; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.leave_request DISABLE TRIGGER ALL;

INSERT INTO mcms_hr.leave_request VALUES
	(2, 2, 'annual', '2025-01-01', '2025-01-01', 1, 'demo', 'pending', 99, '2026-07-18 21:59:19.163673+03', '2026-07-18 21:59:19.164673+03', '2026-07-18 21:59:19.164673+03', 1);


ALTER TABLE mcms_hr.leave_request ENABLE TRIGGER ALL;

--
-- Data for Name: payroll_period; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.payroll_period DISABLE TRIGGER ALL;

INSERT INTO mcms_hr.payroll_period VALUES
	(2, 'PP-DEMO-2026-01', '2026-01-01', '2026-01-31', 'draft', NULL, '2026-07-18 21:59:17.914572+03', 1);


ALTER TABLE mcms_hr.payroll_period ENABLE TRIGGER ALL;

--
-- Data for Name: payroll_item; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.payroll_item DISABLE TRIGGER ALL;



ALTER TABLE mcms_hr.payroll_item ENABLE TRIGGER ALL;

--
-- Data for Name: bed; Type: TABLE DATA; Schema: mcms_icu; Owner: -
--

ALTER TABLE mcms_icu.bed DISABLE TRIGGER ALL;

INSERT INTO mcms_icu.bed VALUES
	(2, 'demo', 'demo', 1, 1, 'available', true, true, true, '2026-07-18 21:59:19.579314+03', '2026-07-18 21:59:19.579314+03', 1);


ALTER TABLE mcms_icu.bed ENABLE TRIGGER ALL;

--
-- Data for Name: admission; Type: TABLE DATA; Schema: mcms_icu; Owner: -
--

ALTER TABLE mcms_icu.admission DISABLE TRIGGER ALL;

INSERT INTO mcms_icu.admission VALUES
	(2, 2, 99002, 'ADM-DEMO-001', NULL, NULL, NULL, 'admitted', NULL, NULL, '2026-07-18 21:59:17.914572+03', NULL, NULL, NULL, NULL, 1);


ALTER TABLE mcms_icu.admission ENABLE TRIGGER ALL;

--
-- Data for Name: bed_stay; Type: TABLE DATA; Schema: mcms_icu; Owner: -
--

ALTER TABLE mcms_icu.bed_stay DISABLE TRIGGER ALL;

INSERT INTO mcms_icu.bed_stay VALUES
	(2, 2, 2, '2026-07-18 21:59:19.598529+03', '2026-07-18 21:59:19.599532+03', 1);


ALTER TABLE mcms_icu.bed_stay ENABLE TRIGGER ALL;

--
-- Data for Name: score; Type: TABLE DATA; Schema: mcms_icu; Owner: -
--

ALTER TABLE mcms_icu.score DISABLE TRIGGER ALL;

INSERT INTO mcms_icu.score VALUES
	(2, 2, 'demo', 1, 1.00, 'demo', '2026-07-18 21:59:19.631091+03', 99, 1);


ALTER TABLE mcms_icu.score ENABLE TRIGGER ALL;

--
-- Data for Name: support_session; Type: TABLE DATA; Schema: mcms_icu; Owner: -
--

ALTER TABLE mcms_icu.support_session DISABLE TRIGGER ALL;

INSERT INTO mcms_icu.support_session VALUES
	(2, 2, 'mechanical_ventilation', '2026-07-18 21:59:19.6533+03', '2026-07-18 21:59:19.655302+03', '{}', 'demo', 1);


ALTER TABLE mcms_icu.support_session ENABLE TRIGGER ALL;

--
-- Data for Name: vitals_stream; Type: TABLE DATA; Schema: mcms_icu; Owner: -
--

ALTER TABLE mcms_icu.vitals_stream DISABLE TRIGGER ALL;

INSERT INTO mcms_icu.vitals_stream VALUES
	(2, 2, 99002, '2026-07-18 21:59:17.914572+03', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1);


ALTER TABLE mcms_icu.vitals_stream ENABLE TRIGGER ALL;

--
-- Data for Name: test_panel; Type: TABLE DATA; Schema: mcms_lab; Owner: -
--

ALTER TABLE mcms_lab.test_panel DISABLE TRIGGER ALL;

INSERT INTO mcms_lab.test_panel VALUES
	(2, 'P-CBC', 'Complete Blood Count', '2026-07-18 21:59:08.489232+03', 1),
	(3, 'P-CMP', 'Comprehensive Metabolic Panel', '2026-07-18 21:59:08.489232+03', 1),
	(4, 'P-CARD', 'Cardiac Panel', '2026-07-18 21:59:08.489232+03', 1),
	(5, 'P-UA', 'Urinalysis Panel', '2026-07-18 21:59:08.489232+03', 1);


ALTER TABLE mcms_lab.test_panel ENABLE TRIGGER ALL;

--
-- Data for Name: lab_order; Type: TABLE DATA; Schema: mcms_lab; Owner: -
--

ALTER TABLE mcms_lab.lab_order DISABLE TRIGGER ALL;

INSERT INTO mcms_lab.lab_order VALUES
	(2, 'LAB-DEMO-001', 2, 99002, 'MRN-DEMO-001', 1, 'routine', 2, 'Demo', '2026-07-18 21:59:17.913956+03', 1),
	(3, 'LAB-DEMO-002', 2, 99003, 'MRN-DEMO-002', 1, 'routine', 2, 'Demo', '2026-07-17 21:59:17.913956+03', 1),
	(4, 'LAB-DEMO-003', 2, 99004, 'MRN-DEMO-003', 1, 'routine', 2, 'Demo', '2026-07-16 21:59:17.913956+03', 1);


ALTER TABLE mcms_lab.lab_order ENABLE TRIGGER ALL;

--
-- Data for Name: sample; Type: TABLE DATA; Schema: mcms_lab; Owner: -
--

ALTER TABLE mcms_lab.sample DISABLE TRIGGER ALL;

INSERT INTO mcms_lab.sample VALUES
	(2, 'SMP-DEMO-001', 2, NULL, 'blood', 5.00, '2026-07-18 21:59:17.913956+03', 1, '2026-07-18 21:59:17.913956+03', 1, 'received', NULL, 1),
	(3, 'SMP-DEMO-002', 3, NULL, 'blood', 5.00, '2026-07-17 21:59:17.913956+03', 1, '2026-07-18 21:59:17.913956+03', 1, 'received', NULL, 1),
	(4, 'SMP-DEMO-003', 4, NULL, 'blood', 5.00, '2026-07-16 21:59:17.913956+03', 1, '2026-07-18 21:59:17.913956+03', 1, 'received', NULL, 1);


ALTER TABLE mcms_lab.sample ENABLE TRIGGER ALL;

--
-- Data for Name: test_catalog; Type: TABLE DATA; Schema: mcms_lab; Owner: -
--

ALTER TABLE mcms_lab.test_catalog DISABLE TRIGGER ALL;

INSERT INTO mcms_lab.test_catalog VALUES
	(2, '6690-2', 'WBC Count', 'Hematology', 'blood', 3.00, '10^3/uL', 4.0, 11.0, 60, true, '2026-07-18 21:59:08.489232+03', 1),
	(3, '718-7', 'Hemoglobin', 'Hematology', 'blood', 3.00, 'g/dL', 12.0, 17.5, 60, true, '2026-07-18 21:59:08.489232+03', 1),
	(4, '789-8', 'RBC Count', 'Hematology', 'blood', 3.00, '10^6/uL', 4.0, 5.9, 60, true, '2026-07-18 21:59:08.489232+03', 1),
	(5, '2951-2', 'Sodium', 'Chemistry', 'blood', 3.00, 'mmol/L', 135, 145, 60, true, '2026-07-18 21:59:08.489232+03', 1),
	(6, '2069-3', 'Chloride', 'Chemistry', 'blood', 3.00, 'mmol/L', 98, 107, 60, true, '2026-07-18 21:59:08.489232+03', 1),
	(7, '2885-2', 'Potassium', 'Chemistry', 'blood', 3.00, 'mmol/L', 3.5, 5.0, 60, true, '2026-07-18 21:59:08.489232+03', 1),
	(8, '2345-7', 'Glucose, Random', 'Chemistry', 'blood', 3.00, 'mg/dL', 70, 100, 30, true, '2026-07-18 21:59:08.489232+03', 1),
	(9, '3094-0', 'Urea Nitrogen', 'Chemistry', 'blood', 3.00, 'mg/dL', 7, 20, 90, true, '2026-07-18 21:59:08.489232+03', 1),
	(10, '38483-4', 'Creatinine', 'Chemistry', 'blood', 3.00, 'mg/dL', 0.7, 1.3, 90, true, '2026-07-18 21:59:08.489232+03', 1),
	(11, '33914-3', 'Troponin I, Cardiac', 'Chemistry', 'blood', 3.00, 'ng/mL', 0.0, 0.04, 45, true, '2026-07-18 21:59:08.489232+03', 1),
	(12, '25428-4', 'PT/INR', 'Coagulation', 'blood', 2.50, 'INR', 0.8, 1.2, 60, true, '2026-07-18 21:59:08.489232+03', 1),
	(13, '6298-4', 'Potassium, Urine', 'Urinalysis', 'urine', 10.00, 'mmol/d', 25, 125, 120, true, '2026-07-18 21:59:08.489232+03', 1),
	(14, '5792-7', 'Glucose, Urine', 'Urinalysis', 'urine', 10.00, 'mg/dL', 0, 0, 30, true, '2026-07-18 21:59:08.489232+03', 1),
	(15, '11277-5', 'Stool Routine', 'Microbiology', 'stool', 5.00, ' qualitative', NULL, NULL, 240, true, '2026-07-18 21:59:08.489232+03', 1),
	(16, '14461-8', 'Wound Culture & Sensitivity', 'Microbiology', 'swab', 1.00, 'qualitative', NULL, NULL, 1440, true, '2026-07-18 21:59:08.489232+03', 1);


ALTER TABLE mcms_lab.test_catalog ENABLE TRIGGER ALL;

--
-- Data for Name: result; Type: TABLE DATA; Schema: mcms_lab; Owner: -
--

ALTER TABLE mcms_lab.result DISABLE TRIGGER ALL;

INSERT INTO mcms_lab.result VALUES
	(2, 2, 2, 'Normal', 5.0000, 'g/dL', '4-6', 'normal', 1, '2026-07-18 21:59:17.913956+03', 1, '2026-07-18 21:59:17.913956+03', NULL, NULL, '2026-07-18 21:59:18.265401+03', 1),
	(3, 3, 2, 'Normal', 5.0000, 'g/dL', '4-6', 'normal', 1, '2026-07-18 21:59:17.913956+03', 1, '2026-07-18 21:59:17.913956+03', NULL, NULL, '2026-07-18 21:59:18.289112+03', 1),
	(4, 4, 2, 'Normal', 5.0000, 'g/dL', '4-6', 'normal', 1, '2026-07-18 21:59:17.913956+03', 1, '2026-07-18 21:59:17.913956+03', NULL, NULL, '2026-07-18 21:59:18.29846+03', 1);


ALTER TABLE mcms_lab.result ENABLE TRIGGER ALL;

--
-- Data for Name: test_panel_item; Type: TABLE DATA; Schema: mcms_lab; Owner: -
--

ALTER TABLE mcms_lab.test_panel_item DISABLE TRIGGER ALL;

INSERT INTO mcms_lab.test_panel_item VALUES
	(2, 2, 2, 1, 1),
	(3, 2, 3, 2, 1),
	(4, 2, 4, 3, 1),
	(5, 3, 5, 1, 1),
	(6, 3, 6, 2, 1),
	(7, 3, 7, 3, 1),
	(8, 3, 9, 4, 1),
	(9, 3, 10, 5, 1),
	(10, 3, 8, 6, 1),
	(11, 4, 11, 1, 1);


ALTER TABLE mcms_lab.test_panel_item ENABLE TRIGGER ALL;

--
-- Data for Name: cot; Type: TABLE DATA; Schema: mcms_nursery; Owner: -
--

ALTER TABLE mcms_nursery.cot DISABLE TRIGGER ALL;

INSERT INTO mcms_nursery.cot VALUES
	(2, 'demo', 'demo', 1, true, true, 'available', '2026-07-18 21:59:19.973685+03', '2026-07-18 21:59:19.973685+03', 1);


ALTER TABLE mcms_nursery.cot ENABLE TRIGGER ALL;

--
-- Data for Name: neonate_record; Type: TABLE DATA; Schema: mcms_nursery; Owner: -
--

ALTER TABLE mcms_nursery.neonate_record DISABLE TRIGGER ALL;

INSERT INTO mcms_nursery.neonate_record VALUES
	(2, 99001, 99003, 2, 1.0, 1, 1, 1, '2026-07-18 21:59:20.04855+03', '2026-07-18 21:59:20.050552+03', 'demo', '2026-07-18 21:59:20.051556+03', '2026-07-18 21:59:20.051556+03', 1);


ALTER TABLE mcms_nursery.neonate_record ENABLE TRIGGER ALL;

--
-- Data for Name: growth_entry; Type: TABLE DATA; Schema: mcms_nursery; Owner: -
--

ALTER TABLE mcms_nursery.growth_entry DISABLE TRIGGER ALL;

INSERT INTO mcms_nursery.growth_entry VALUES
	(2, 2, '2026-07-18 21:59:20.064708+03', 1, 1.00, 1.00, 1.0, 'demo', 1, 99, 'demo', 1);


ALTER TABLE mcms_nursery.growth_entry ENABLE TRIGGER ALL;

--
-- Data for Name: therapy_catalog; Type: TABLE DATA; Schema: mcms_physio; Owner: -
--

ALTER TABLE mcms_physio.therapy_catalog DISABLE TRIGGER ALL;

INSERT INTO mcms_physio.therapy_catalog VALUES
	(2, 'PHY-MAN1', 'Manual Therapy 30', 'manual_therapy', 'spine', 30, NULL, true, '2026-07-18 21:59:08.489232+03', 1),
	(3, 'PHY-ELEC1', 'Electrotherapy TENS', 'electrotherapy', 'any', 20, NULL, true, '2026-07-18 21:59:08.489232+03', 1),
	(4, 'PHY-EX1', 'Therapeutic Exercise Set A', 'therapeutic_exercise', 'any', 45, NULL, true, '2026-07-18 21:59:08.489232+03', 1),
	(5, 'PHY-HYDRO', 'Hydrotherapy Session', 'hydrotherapy', 'lower_limb', 30, NULL, true, '2026-07-18 21:59:08.489232+03', 1),
	(6, 'PHY-CRY', 'Cryotherapy 10', 'cryotherapy', 'joint', 10, NULL, true, '2026-07-18 21:59:08.489232+03', 1),
	(7, 'PHY-HEAT', 'Heat Therapy 15', 'heat_therapy', 'soft_tissue', 15, NULL, true, '2026-07-18 21:59:08.489232+03', 1),
	(8, 'PHY-US', 'Therapeutic Ultrasound', 'ultrasound', 'soft_tissue', 15, NULL, true, '2026-07-18 21:59:08.489232+03', 1),
	(9, 'PHY-LASER', 'Laser Therapy', 'laser', 'wound', 10, NULL, true, '2026-07-18 21:59:08.489232+03', 1),
	(10, 'PHY-TAPING', 'Kinesio Taping', 'taping', 'any', 15, NULL, true, '2026-07-18 21:59:08.489232+03', 1),
	(11, 'PHY-NEURO', 'Neuro Rehab Session', 'neuro_rehab', 'cns', 60, NULL, true, '2026-07-18 21:59:08.489232+03', 1);


ALTER TABLE mcms_physio.therapy_catalog ENABLE TRIGGER ALL;

--
-- Data for Name: treatment_plan; Type: TABLE DATA; Schema: mcms_physio; Owner: -
--

ALTER TABLE mcms_physio.treatment_plan DISABLE TRIGGER ALL;

INSERT INTO mcms_physio.treatment_plan VALUES
	(2, 99001, 2, 99, 'demo', 'demo', 1, 1, 'demo', '2025-01-01', '2025-01-01', 'active', 'demo', '2026-07-18 21:59:19.734154+03', '2026-07-18 21:59:19.734154+03', 1);


ALTER TABLE mcms_physio.treatment_plan ENABLE TRIGGER ALL;

--
-- Data for Name: session; Type: TABLE DATA; Schema: mcms_physio; Owner: -
--

ALTER TABLE mcms_physio.session DISABLE TRIGGER ALL;

INSERT INTO mcms_physio.session VALUES
	(2, 2, 99001, 99, 2, 2, 1, '2026-07-18 21:59:19.779622+03', 1, 1, 1, 'demo', 'demo', 'demo', 'demo', 'scheduled', '2026-07-18 21:59:19.807166+03', '2026-07-18 21:59:19.811081+03', 'demo', '2026-07-18 21:59:19.814079+03', '2026-07-18 21:59:19.814079+03', 1);


ALTER TABLE mcms_physio.session ENABLE TRIGGER ALL;

--
-- Data for Name: exam_catalog; Type: TABLE DATA; Schema: mcms_rad; Owner: -
--

ALTER TABLE mcms_rad.exam_catalog DISABLE TRIGGER ALL;

INSERT INTO mcms_rad.exam_catalog VALUES
	(2, NULL, 'Chest X-ray', 'Chest', 'xray', false, 5, '2026-07-18 21:59:08.489232+03', 1),
	(3, NULL, 'CT Thorax without contrast', 'Chest', 'ct', false, 15, '2026-07-18 21:59:08.489232+03', 1),
	(4, NULL, 'CT Brain with contrast', 'Brain', 'ct', true, 20, '2026-07-18 21:59:08.489232+03', 1),
	(5, NULL, 'MRI Brain with contrast', 'Brain', 'mri', true, 45, '2026-07-18 21:59:08.489232+03', 1),
	(6, NULL, 'Ultrasound Abdomen', 'Abdomen', 'us', false, 15, '2026-07-18 21:59:08.489232+03', 1),
	(7, NULL, 'DEXA Bone Density', 'Spine', 'dexa', false, 10, '2026-07-18 21:59:08.489232+03', 1);


ALTER TABLE mcms_rad.exam_catalog ENABLE TRIGGER ALL;

--
-- Data for Name: modality_suite; Type: TABLE DATA; Schema: mcms_rad; Owner: -
--

ALTER TABLE mcms_rad.modality_suite DISABLE TRIGGER ALL;

INSERT INTO mcms_rad.modality_suite VALUES
	(2, 44, 'RAD-XR', 'X-ray Room 1', 'xray', true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(3, 44, 'RAD-CT', 'CT Suite A', 'ct', true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(4, 44, 'RAD-MRI', 'MRI Unit 1', 'mri', true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(5, 44, 'RAD-US', 'Ultrasound 1', 'us', true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(6, 44, 'RAD-FL', 'Fluoroscopy Room', 'fluoroscopy', true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1);


ALTER TABLE mcms_rad.modality_suite ENABLE TRIGGER ALL;

--
-- Data for Name: study_request; Type: TABLE DATA; Schema: mcms_rad; Owner: -
--

ALTER TABLE mcms_rad.study_request DISABLE TRIGGER ALL;

INSERT INTO mcms_rad.study_request VALUES
	(2, 'demo', 2, 99001, 'demo', 2, 2, 99, 'routine', 'demo', 'requested', '2026-07-18 21:59:19.447411+03', '2026-07-18 21:59:19.448463+03', '2026-07-18 21:59:19.448463+03', 1, 1.000, '{}', 'demo', 'demo', 99, '2026-07-18 21:59:19.469123+03', 99, '2026-07-18 21:59:19.480676+03', 'demo', '2026-07-18 21:59:19.482675+03', '2026-07-18 21:59:19.482675+03', 1);


ALTER TABLE mcms_rad.study_request ENABLE TRIGGER ALL;

--
-- Data for Name: image_instance; Type: TABLE DATA; Schema: mcms_rad; Owner: -
--

ALTER TABLE mcms_rad.image_instance DISABLE TRIGGER ALL;

INSERT INTO mcms_rad.image_instance VALUES
	(2, 2, 1, 1, 'demo', 'dicom', 'demo', 1, 1, 1, '2026-07-18 21:59:19.532316+03', 1);


ALTER TABLE mcms_rad.image_instance ENABLE TRIGGER ALL;

--
-- Data for Name: administration; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.administration DISABLE TRIGGER ALL;

INSERT INTO mcms_rx.administration VALUES
	(2, 99001, 2, 2, 'demo', '2026-07-18 21:59:19.346266+03', 99, 99, 'demo', 'demo', 1);


ALTER TABLE mcms_rx.administration ENABLE TRIGGER ALL;

--
-- Data for Name: drug_lot; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.drug_lot DISABLE TRIGGER ALL;

INSERT INTO mcms_rx.drug_lot VALUES
	(2, 2, 'LOT-DEMO-001', 100, 95, NULL, '2027-07-18', '2026-07-18 21:59:17.914572+03', 1, 2, 10.00, 'on_hand', 1);


ALTER TABLE mcms_rx.drug_lot ENABLE TRIGGER ALL;

--
-- Data for Name: dispensation; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.dispensation DISABLE TRIGGER ALL;

INSERT INTO mcms_rx.dispensation VALUES
	(2, 99001, 'MRN-DEMO-PORTAL', 2, 2, 2, 2, 5, '2026-07-18 21:59:17.914572+03', 1, NULL, NULL, 1);


ALTER TABLE mcms_rx.dispensation ENABLE TRIGGER ALL;

--
-- Data for Name: drug_alternative; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.drug_alternative DISABLE TRIGGER ALL;

INSERT INTO mcms_rx.drug_alternative VALUES
	(2, 2, 3, NULL, false, '2026-07-18 21:59:17.914572+03', 1);


ALTER TABLE mcms_rx.drug_alternative ENABLE TRIGGER ALL;

--
-- Data for Name: drug_interaction; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.drug_interaction DISABLE TRIGGER ALL;

INSERT INTO mcms_rx.drug_interaction VALUES
	(2, 2, 3, 'moderate', 'NSAID + paracetamol', 'Increased risk of GI bleeding and renal impairment with combined frequent use', 'Prefer single agent; monitor for GI bleed if combined', NULL, '2026-07-18 21:59:08.726945+03', 1),
	(3, 3, 4, 'major', 'NSAID + antiplatelet (ASA)', 'Additive inhibition of platelet aggregation -> major bleeding risk', 'Avoid combination unless specifically indicated; GI prophylaxis if unavoidable', NULL, '2026-07-18 21:59:08.726945+03', 1),
	(4, 2, 4, 'moderate', 'Paracetamol + ASA', 'Additive analgesic but increased GI/renal risk at high doses', 'Use lowest effective doses; monitor renal function', NULL, '2026-07-18 21:59:08.726945+03', 1),
	(5, 4, 10, 'major', 'ASA + omeprazole', 'ASA irritates gastric mucosa; PPI reduces ulcer risk', 'Co-prescribe PPI (e.g. omeprazole) with long-term ASA', NULL, '2026-07-18 21:59:08.726945+03', 1),
	(6, 7, 10, 'minor', 'Metformin + omeprazole', 'Omeprazole may marginally raise metformin levels', 'Generally safe; routine monitoring sufficient', NULL, '2026-07-18 21:59:08.726945+03', 1),
	(7, 3, 10, 'minor', 'Ibuprofen + omeprazole', 'NSAID ulcers mitigated by PPI', 'Co-prescribe PPI for patients on chronic NSAIDs', NULL, '2026-07-18 21:59:08.726945+03', 1);


ALTER TABLE mcms_rx.drug_interaction ENABLE TRIGGER ALL;

--
-- Data for Name: prescription; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.prescription DISABLE TRIGGER ALL;

INSERT INTO mcms_rx.prescription OVERRIDING SYSTEM VALUE VALUES
	(2, NULL, NULL, 99002, 'MRN-DEMO-001', 1, 2, NULL, NULL, NULL, NULL, NULL, NULL, 'draft', NULL, false, NULL, NULL, 1, '2026-07-18 21:59:17.914572+03', '2026-07-18 21:59:17.914572+03');


ALTER TABLE mcms_rx.prescription ENABLE TRIGGER ALL;

--
-- Data for Name: stock_movement; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.stock_movement DISABLE TRIGGER ALL;

INSERT INTO mcms_rx.stock_movement VALUES
	(2, 2, 2, 'dispense', -5, 95, NULL, 'dispense to patient MRN-DEMO-PORTAL', 1, '2026-07-18 21:59:17.914572+03', 1);


ALTER TABLE mcms_rx.stock_movement ENABLE TRIGGER ALL;

--
-- Data for Name: operating_room; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.operating_room DISABLE TRIGGER ALL;

INSERT INTO mcms_surgical.operating_room VALUES
	(2, 33, 'OR-GEN', 'General Operating Theatre', 'general', 'available', true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(3, 34, 'OR-CARD', 'Cardiac Surgery Theatre', 'cardiac', 'available', true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(4, 35, 'OR-ORTHO', 'Orthopaedic Surgery Theatre', 'ortho', 'available', true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1),
	(5, 36, 'OR-NEURO', 'Neurosurgery Theatre', 'neuro', 'available', true, '2026-07-18 21:59:08.489232+03', '2026-07-18 21:59:08.489232+03', 1);


ALTER TABLE mcms_surgical.operating_room ENABLE TRIGGER ALL;

--
-- Data for Name: procedure_catalog; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.procedure_catalog DISABLE TRIGGER ALL;

INSERT INTO mcms_surgical.procedure_catalog VALUES
	(2, '23470', 'Arthroplasty, glenohumeral joint', NULL, 90, NULL, '2026-07-18 21:59:08.489232+03', 1),
	(3, '27130', 'Total hip arthroplasty', NULL, 90, NULL, '2026-07-18 21:59:08.489232+03', 1),
	(4, '27447', 'Total knee arthroplasty', NULL, 90, NULL, '2026-07-18 21:59:08.489232+03', 1),
	(5, '33533', 'Coronary artery bypass, single', NULL, 90, NULL, '2026-07-18 21:59:08.489232+03', 1),
	(6, '47579', 'Open cholecystectomy', NULL, 90, NULL, '2026-07-18 21:59:08.489232+03', 1),
	(7, '49505', 'Repair of femoral hernia', NULL, 90, NULL, '2026-07-18 21:59:08.489232+03', 1),
	(8, '58150', 'Total abdominal hysterectomy', NULL, 90, NULL, '2026-07-18 21:59:08.489232+03', 1);


ALTER TABLE mcms_surgical.procedure_catalog ENABLE TRIGGER ALL;

--
-- Data for Name: surgery; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.surgery DISABLE TRIGGER ALL;

INSERT INTO mcms_surgical.surgery VALUES
	(2, 'OP-DEMO-001', 2, 99002, 2, 1, 1, 1, 2, 'left', 'completed', '2026-07-18 21:59:17.913956+03', '2026-07-18 21:59:17.913956+03', '2026-07-18 21:59:17.913956+03', '2026-07-18 21:59:17.913956+03', '2026-07-18 21:59:17.913956+03', 'general', 50, 0, 'none', 'Demo surgery', '2026-07-18 21:59:18.529815+03', '2026-07-18 21:59:18.529815+03', 1);


ALTER TABLE mcms_surgical.surgery ENABLE TRIGGER ALL;

--
-- Data for Name: intra_op_vitals; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.intra_op_vitals DISABLE TRIGGER ALL;

INSERT INTO mcms_surgical.intra_op_vitals VALUES
	(2, 2, '2026-07-18 21:59:17.913956+03', 1, 80, 120, 80, 98.0, 35, 40, 36.5, 200, 'Demo intra-op vitals', 1);


ALTER TABLE mcms_surgical.intra_op_vitals ENABLE TRIGGER ALL;

--
-- Data for Name: post_op_note; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.post_op_note DISABLE TRIGGER ALL;

INSERT INTO mcms_surgical.post_op_note VALUES
	(2, 2, '2026-07-18 21:59:19.182171+03', 99, 'demo', 1, 'demo', 'demo', 1, true, '2026-07-18 21:59:19.214372+03', 1);


ALTER TABLE mcms_surgical.post_op_note ENABLE TRIGGER ALL;

--
-- Data for Name: pre_op_checklist; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.pre_op_checklist DISABLE TRIGGER ALL;

INSERT INTO mcms_surgical.pre_op_checklist VALUES
	(2, 2, true, true, true, true, true, true, true, 'demo', 99, '2026-07-18 21:59:19.249056+03', '2026-07-18 21:59:19.250058+03', 1);


ALTER TABLE mcms_surgical.pre_op_checklist ENABLE TRIGGER ALL;

--
-- Data for Name: surgical_team; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.surgical_team DISABLE TRIGGER ALL;

INSERT INTO mcms_surgical.surgical_team VALUES
	(2, 2, 99, 'surgeon', '2026-07-18 21:59:19.279298+03', '2026-07-18 21:59:19.280392+03', 1);


ALTER TABLE mcms_surgical.surgical_team ENABLE TRIGGER ALL;

--
-- Data for Name: visit; Type: TABLE DATA; Schema: mcms_telemed; Owner: -
--

ALTER TABLE mcms_telemed.visit DISABLE TRIGGER ALL;



ALTER TABLE mcms_telemed.visit ENABLE TRIGGER ALL;

--
-- Data for Name: concept; Type: TABLE DATA; Schema: mcms_terminology; Owner: -
--

ALTER TABLE mcms_terminology.concept DISABLE TRIGGER ALL;



ALTER TABLE mcms_terminology.concept ENABLE TRIGGER ALL;

--
-- Data for Name: birth_certificate; Type: TABLE DATA; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE mcms_vital_records.birth_certificate DISABLE TRIGGER ALL;

INSERT INTO mcms_vital_records.birth_certificate OVERRIDING SYSTEM VALUE VALUES
	(2, 'BC-DEMO-001', 99001, 99001, 1, 2, 1, '2026-07-18 21:59:17.914572+03', NULL, NULL, NULL, NULL, NULL, NULL, 'draft', NULL, NULL, '2026-07-18 21:59:17.914572+03', '2026-07-18 21:59:17.914572+03');


ALTER TABLE mcms_vital_records.birth_certificate ENABLE TRIGGER ALL;

--
-- Data for Name: death_certificate; Type: TABLE DATA; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE mcms_vital_records.death_certificate DISABLE TRIGGER ALL;

INSERT INTO mcms_vital_records.death_certificate OVERRIDING SYSTEM VALUE VALUES
	(2, 'DC-DEMO-001', 99006, 1, '2026-07-18 21:59:17.914572+03', NULL, NULL, NULL, false, NULL, 'draft', NULL, NULL, '2026-07-18 21:59:17.914572+03', '2026-07-18 21:59:17.914572+03');


ALTER TABLE mcms_vital_records.death_certificate ENABLE TRIGGER ALL;

--
-- Data for Name: waste_stream; Type: TABLE DATA; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_stream DISABLE TRIGGER ALL;

INSERT INTO mcms_waste.waste_stream OVERRIDING SYSTEM VALUE VALUES
	(1, 'SHARPS', 'Sharps', 'sharps', 'yellow', 'UN3291', 'incineration', 3.5000, 'SAR', true, '2026-07-18 21:59:08.361814+03', '2026-07-18 21:59:08.361814+03'),
	(2, 'INFECT', 'Infectious', 'infectious', 'red', 'UN3291', 'autoclave', 2.2500, 'SAR', true, '2026-07-18 21:59:08.361814+03', '2026-07-18 21:59:08.361814+03'),
	(3, 'PHARMA', 'Pharmaceutical', 'pharmaceutical', 'white', 'UN3249', 'incineration', 4.0000, 'SAR', true, '2026-07-18 21:59:08.361814+03', '2026-07-18 21:59:08.361814+03'),
	(4, 'CYTO', 'Cytotoxic', 'cytotoxic', 'purple', 'UN3249', 'incineration', 6.5000, 'SAR', true, '2026-07-18 21:59:08.361814+03', '2026-07-18 21:59:08.361814+03'),
	(5, 'GEN', 'General (non-hazard)', 'general', 'black', NULL, 'landfill', 0.4000, 'SAR', true, '2026-07-18 21:59:08.361814+03', '2026-07-18 21:59:08.361814+03');


ALTER TABLE mcms_waste.waste_stream ENABLE TRIGGER ALL;

--
-- Data for Name: waste_container; Type: TABLE DATA; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_container DISABLE TRIGGER ALL;

INSERT INTO mcms_waste.waste_container OVERRIDING SYSTEM VALUE VALUES
	(1, 'WC-DEMO-0001', 1, 1, 10.000, 'collected', '2026-07-18 21:59:08.361814+03', '2026-07-18 21:59:08.361814+03');


ALTER TABLE mcms_waste.waste_container ENABLE TRIGGER ALL;

--
-- Data for Name: waste_collection; Type: TABLE DATA; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_collection DISABLE TRIGGER ALL;

INSERT INTO mcms_waste.waste_collection OVERRIDING SYSTEM VALUE VALUES
	(1, 1, 7.500, NULL, '2026-07-18 21:59:08.361814+03', 'Central Waste Store', '2026-07-18 21:59:08.361814+03'),
	(2, 1, 2.500, 1, '2026-07-18 21:59:17.913956+03', 'Demo Storage', '2026-07-18 21:59:18.361006+03'),
	(3, 1, 2.500, 1, '2026-07-17 21:59:17.913956+03', 'Demo Storage', '2026-07-18 21:59:18.365017+03');


ALTER TABLE mcms_waste.waste_collection ENABLE TRIGGER ALL;

--
-- Data for Name: waste_disposal_manifest; Type: TABLE DATA; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_disposal_manifest DISABLE TRIGGER ALL;

INSERT INTO mcms_waste.waste_disposal_manifest OVERRIDING SYSTEM VALUE VALUES
	(1, 'M202607-000001', 'EnviroClean Ltd', 'incineration', '2026-07-18 21:59:08.361814+03', 7.500, 3.5000, DEFAULT, 'SAR', 'CERT-DEMO-0001', NULL, 'certified', '2026-07-18 21:59:08.361814+03', '2026-07-18 21:59:08.361814+03');


ALTER TABLE mcms_waste.waste_disposal_manifest ENABLE TRIGGER ALL;

--
-- Data for Name: waste_cost_allocation; Type: TABLE DATA; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_cost_allocation DISABLE TRIGGER ALL;

INSERT INTO mcms_waste.waste_cost_allocation OVERRIDING SYSTEM VALUE VALUES
	(1, 1, 1, '2026-07-01', 7.500, 26.2500, 'CC-WASTE', '2026-07-18 21:59:08.361814+03');


ALTER TABLE mcms_waste.waste_cost_allocation ENABLE TRIGGER ALL;

--
-- Name: claim_response_response_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.claim_response_response_id_seq', 1, true);


--
-- Name: eligibility_check_eligibility_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.eligibility_check_eligibility_id_seq', 1, true);


--
-- Name: insurance_claim_claim_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.insurance_claim_claim_id_seq', 2, true);


--
-- Name: invoice_invoice_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.invoice_invoice_id_seq', 4, true);


--
-- Name: invoice_line_line_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.invoice_line_line_id_seq', 4, true);


--
-- Name: payer_payer_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.payer_payer_id_seq', 3, true);


--
-- Name: payment_payment_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.payment_payment_id_seq', 2, true);


--
-- Name: service_price_service_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.service_price_service_id_seq', 16, true);


--
-- Name: appointment_appointment_id_seq; Type: SEQUENCE SET; Schema: mcms_clinic; Owner: -
--

SELECT pg_catalog.setval('mcms_clinic.appointment_appointment_id_seq', 5, true);


--
-- Name: consultation_consultation_id_seq; Type: SEQUENCE SET; Schema: mcms_clinic; Owner: -
--

SELECT pg_catalog.setval('mcms_clinic.consultation_consultation_id_seq', 2, true);


--
-- Name: patient_queue_queue_id_seq; Type: SEQUENCE SET; Schema: mcms_clinic; Owner: -
--

SELECT pg_catalog.setval('mcms_clinic.patient_queue_queue_id_seq', 2, true);


--
-- Name: room_room_id_seq; Type: SEQUENCE SET; Schema: mcms_clinic; Owner: -
--

SELECT pg_catalog.setval('mcms_clinic.room_room_id_seq', 2, true);


--
-- Name: access_log_access_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.access_log_access_id_seq', 2, true);


--
-- Name: address_address_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.address_address_id_seq', 2, true);


--
-- Name: app_user_user_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.app_user_user_id_seq', 100, true);


--
-- Name: audit_trail_audit_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.audit_trail_audit_id_seq', 2, true);


--
-- Name: backup_log_backup_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.backup_log_backup_id_seq', 1, true);


--
-- Name: consent_consent_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.consent_consent_id_seq', 1, true);


--
-- Name: contact_contact_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.contact_contact_id_seq', 2, true);


--
-- Name: event_log_event_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.event_log_event_id_seq', 408, true);


--
-- Name: event_log_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.event_log_seq', 783, true);


--
-- Name: facility_facility_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.facility_facility_id_seq', 4, true);


--
-- Name: federated_identity_fed_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.federated_identity_fed_id_seq', 1, true);


--
-- Name: hl7_message_hl7_message_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.hl7_message_hl7_message_id_seq', 1, true);


--
-- Name: lookup_lookup_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.lookup_lookup_id_seq', 40, true);


--
-- Name: notification_notification_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.notification_notification_id_seq', 9, true);


--
-- Name: organization_organization_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.organization_organization_id_seq', 1, true);


--
-- Name: party_party_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.party_party_id_seq', 99009, true);


--
-- Name: permission_permission_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.permission_permission_id_seq', 20, true);


--
-- Name: role_role_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.role_role_id_seq', 9, true);


--
-- Name: session_session_id_seq; Type: SEQUENCE SET; Schema: mcms_dialysis; Owner: -
--

SELECT pg_catalog.setval('mcms_dialysis.session_session_id_seq', 2, true);


--
-- Name: station_station_id_seq; Type: SEQUENCE SET; Schema: mcms_dialysis; Owner: -
--

SELECT pg_catalog.setval('mcms_dialysis.station_station_id_seq', 2, true);


--
-- Name: ed_bed_ed_bed_id_seq; Type: SEQUENCE SET; Schema: mcms_emergency; Owner: -
--

SELECT pg_catalog.setval('mcms_emergency.ed_bed_ed_bed_id_seq', 2, true);


--
-- Name: resuscitation_resus_id_seq; Type: SEQUENCE SET; Schema: mcms_emergency; Owner: -
--

SELECT pg_catalog.setval('mcms_emergency.resuscitation_resus_id_seq', 2, true);


--
-- Name: triage_triage_id_seq; Type: SEQUENCE SET; Schema: mcms_emergency; Owner: -
--

SELECT pg_catalog.setval('mcms_emergency.triage_triage_id_seq', 2, true);


--
-- Name: allergy_allergy_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.allergy_allergy_id_seq', 6, true);


--
-- Name: clinical_note_note_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.clinical_note_note_id_seq', 9, true);


--
-- Name: diagnosis_diagnosis_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.diagnosis_diagnosis_id_seq', 2, true);


--
-- Name: encounter_encounter_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.encounter_encounter_id_seq', 6, true);


--
-- Name: family_history_fh_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.family_history_fh_id_seq', 6, true);


--
-- Name: immunization_immunization_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.immunization_immunization_id_seq', 6, true);


--
-- Name: medication_order_order_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.medication_order_order_id_seq', 4, true);


--
-- Name: patient_patient_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.patient_patient_id_seq', 99006, true);


--
-- Name: referral_linkage_rule_rule_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.referral_linkage_rule_rule_id_seq', 13, true);


--
-- Name: referral_referral_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.referral_referral_id_seq', 2, true);


--
-- Name: social_history_sh_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.social_history_sh_id_seq', 6, true);


--
-- Name: vitals_vital_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.vitals_vital_id_seq', 6, true);


--
-- Name: gl_account_account_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.gl_account_account_id_seq', 21, true);


--
-- Name: goods_receipt_grn_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.goods_receipt_grn_id_seq', 2, true);


--
-- Name: goods_receipt_line_line_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.goods_receipt_line_line_id_seq', 2, true);


--
-- Name: inventory_item_item_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.inventory_item_item_id_seq', 2, true);


--
-- Name: inventory_stock_stock_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.inventory_stock_stock_id_seq', 2, true);


--
-- Name: purchase_order_line_line_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.purchase_order_line_line_id_seq', 2, true);


--
-- Name: purchase_order_po_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.purchase_order_po_id_seq', 2, true);


--
-- Name: stock_movement_movement_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.stock_movement_movement_id_seq', 2, true);


--
-- Name: supplier_supplier_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.supplier_supplier_id_seq', 2, true);


--
-- Name: attendance_attendance_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.attendance_attendance_id_seq', 2, true);


--
-- Name: department_department_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.department_department_id_seq', 52, true);


--
-- Name: employee_department_emp_dept_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.employee_department_emp_dept_id_seq', 2, true);


--
-- Name: employee_employee_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.employee_employee_id_seq', 2, true);


--
-- Name: leave_request_leave_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.leave_request_leave_id_seq', 2, true);


--
-- Name: payroll_item_item_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.payroll_item_item_id_seq', 1, true);


--
-- Name: payroll_period_period_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.payroll_period_period_id_seq', 2, true);


--
-- Name: shift_shift_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.shift_shift_id_seq', 2, true);


--
-- Name: admission_admission_id_seq; Type: SEQUENCE SET; Schema: mcms_icu; Owner: -
--

SELECT pg_catalog.setval('mcms_icu.admission_admission_id_seq', 2, true);


--
-- Name: bed_bed_id_seq; Type: SEQUENCE SET; Schema: mcms_icu; Owner: -
--

SELECT pg_catalog.setval('mcms_icu.bed_bed_id_seq', 2, true);


--
-- Name: bed_stay_stay_id_seq; Type: SEQUENCE SET; Schema: mcms_icu; Owner: -
--

SELECT pg_catalog.setval('mcms_icu.bed_stay_stay_id_seq', 2, true);


--
-- Name: score_score_id_seq; Type: SEQUENCE SET; Schema: mcms_icu; Owner: -
--

SELECT pg_catalog.setval('mcms_icu.score_score_id_seq', 2, true);


--
-- Name: support_session_session_id_seq; Type: SEQUENCE SET; Schema: mcms_icu; Owner: -
--

SELECT pg_catalog.setval('mcms_icu.support_session_session_id_seq', 2, true);


--
-- Name: vitals_stream_stream_id_seq; Type: SEQUENCE SET; Schema: mcms_icu; Owner: -
--

SELECT pg_catalog.setval('mcms_icu.vitals_stream_stream_id_seq', 2, true);


--
-- Name: lab_order_order_id_seq; Type: SEQUENCE SET; Schema: mcms_lab; Owner: -
--

SELECT pg_catalog.setval('mcms_lab.lab_order_order_id_seq', 4, true);


--
-- Name: result_result_id_seq; Type: SEQUENCE SET; Schema: mcms_lab; Owner: -
--

SELECT pg_catalog.setval('mcms_lab.result_result_id_seq', 4, true);


--
-- Name: sample_sample_id_seq; Type: SEQUENCE SET; Schema: mcms_lab; Owner: -
--

SELECT pg_catalog.setval('mcms_lab.sample_sample_id_seq', 4, true);


--
-- Name: test_catalog_test_id_seq; Type: SEQUENCE SET; Schema: mcms_lab; Owner: -
--

SELECT pg_catalog.setval('mcms_lab.test_catalog_test_id_seq', 16, true);


--
-- Name: test_panel_item_ppi_id_seq; Type: SEQUENCE SET; Schema: mcms_lab; Owner: -
--

SELECT pg_catalog.setval('mcms_lab.test_panel_item_ppi_id_seq', 11, true);


--
-- Name: test_panel_panel_id_seq; Type: SEQUENCE SET; Schema: mcms_lab; Owner: -
--

SELECT pg_catalog.setval('mcms_lab.test_panel_panel_id_seq', 5, true);


--
-- Name: cot_cot_id_seq; Type: SEQUENCE SET; Schema: mcms_nursery; Owner: -
--

SELECT pg_catalog.setval('mcms_nursery.cot_cot_id_seq', 2, true);


--
-- Name: growth_entry_entry_id_seq; Type: SEQUENCE SET; Schema: mcms_nursery; Owner: -
--

SELECT pg_catalog.setval('mcms_nursery.growth_entry_entry_id_seq', 2, true);


--
-- Name: neonate_record_neonate_id_seq; Type: SEQUENCE SET; Schema: mcms_nursery; Owner: -
--

SELECT pg_catalog.setval('mcms_nursery.neonate_record_neonate_id_seq', 2, true);


--
-- Name: session_session_id_seq; Type: SEQUENCE SET; Schema: mcms_physio; Owner: -
--

SELECT pg_catalog.setval('mcms_physio.session_session_id_seq', 2, true);


--
-- Name: therapy_catalog_therapy_id_seq; Type: SEQUENCE SET; Schema: mcms_physio; Owner: -
--

SELECT pg_catalog.setval('mcms_physio.therapy_catalog_therapy_id_seq', 11, true);


--
-- Name: treatment_plan_plan_id_seq; Type: SEQUENCE SET; Schema: mcms_physio; Owner: -
--

SELECT pg_catalog.setval('mcms_physio.treatment_plan_plan_id_seq', 2, true);


--
-- Name: exam_catalog_exam_id_seq; Type: SEQUENCE SET; Schema: mcms_rad; Owner: -
--

SELECT pg_catalog.setval('mcms_rad.exam_catalog_exam_id_seq', 7, true);


--
-- Name: image_instance_image_id_seq; Type: SEQUENCE SET; Schema: mcms_rad; Owner: -
--

SELECT pg_catalog.setval('mcms_rad.image_instance_image_id_seq', 2, true);


--
-- Name: modality_suite_suite_id_seq; Type: SEQUENCE SET; Schema: mcms_rad; Owner: -
--

SELECT pg_catalog.setval('mcms_rad.modality_suite_suite_id_seq', 6, true);


--
-- Name: study_request_study_id_seq; Type: SEQUENCE SET; Schema: mcms_rad; Owner: -
--

SELECT pg_catalog.setval('mcms_rad.study_request_study_id_seq', 2, true);


--
-- Name: administration_administer_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.administration_administer_id_seq', 2, true);


--
-- Name: dispensation_dispensation_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.dispensation_dispensation_id_seq', 2, true);


--
-- Name: drug_alternative_alternative_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.drug_alternative_alternative_id_seq', 2, true);


--
-- Name: drug_interaction_interaction_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.drug_interaction_interaction_id_seq', 7, true);


--
-- Name: drug_item_drug_item_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.drug_item_drug_item_id_seq', 16, true);


--
-- Name: drug_lot_lot_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.drug_lot_lot_id_seq', 2, true);


--
-- Name: prescription_prescription_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.prescription_prescription_id_seq', 2, true);


--
-- Name: stock_movement_movement_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.stock_movement_movement_id_seq', 2, true);


--
-- Name: intra_op_vitals_iov_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.intra_op_vitals_iov_id_seq', 2, true);


--
-- Name: operating_room_or_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.operating_room_or_id_seq', 5, true);


--
-- Name: post_op_note_pon_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.post_op_note_pon_id_seq', 2, true);


--
-- Name: pre_op_checklist_poc_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.pre_op_checklist_poc_id_seq', 2, true);


--
-- Name: procedure_catalog_proc_cat_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.procedure_catalog_proc_cat_id_seq', 8, true);


--
-- Name: surgery_surgery_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.surgery_surgery_id_seq', 2, true);


--
-- Name: surgical_team_surg_team_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.surgical_team_surg_team_id_seq', 2, true);


--
-- Name: visit_visit_id_seq; Type: SEQUENCE SET; Schema: mcms_telemed; Owner: -
--

SELECT pg_catalog.setval('mcms_telemed.visit_visit_id_seq', 1, true);


--
-- Name: concept_concept_id_seq; Type: SEQUENCE SET; Schema: mcms_terminology; Owner: -
--

SELECT pg_catalog.setval('mcms_terminology.concept_concept_id_seq', 1, true);


--
-- Name: birth_certificate_birth_cert_id_seq; Type: SEQUENCE SET; Schema: mcms_vital_records; Owner: -
--

SELECT pg_catalog.setval('mcms_vital_records.birth_certificate_birth_cert_id_seq', 2, true);


--
-- Name: birth_reg_no_seq; Type: SEQUENCE SET; Schema: mcms_vital_records; Owner: -
--

SELECT pg_catalog.setval('mcms_vital_records.birth_reg_no_seq', 1, false);


--
-- Name: death_certificate_death_cert_id_seq; Type: SEQUENCE SET; Schema: mcms_vital_records; Owner: -
--

SELECT pg_catalog.setval('mcms_vital_records.death_certificate_death_cert_id_seq', 2, true);


--
-- Name: death_reg_no_seq; Type: SEQUENCE SET; Schema: mcms_vital_records; Owner: -
--

SELECT pg_catalog.setval('mcms_vital_records.death_reg_no_seq', 1, false);


--
-- Name: manifest_no_seq; Type: SEQUENCE SET; Schema: mcms_waste; Owner: -
--

SELECT pg_catalog.setval('mcms_waste.manifest_no_seq', 1, true);


--
-- Name: waste_collection_collection_id_seq; Type: SEQUENCE SET; Schema: mcms_waste; Owner: -
--

SELECT pg_catalog.setval('mcms_waste.waste_collection_collection_id_seq', 3, true);


--
-- Name: waste_container_container_id_seq; Type: SEQUENCE SET; Schema: mcms_waste; Owner: -
--

SELECT pg_catalog.setval('mcms_waste.waste_container_container_id_seq', 1, true);


--
-- Name: waste_cost_allocation_allocation_id_seq; Type: SEQUENCE SET; Schema: mcms_waste; Owner: -
--

SELECT pg_catalog.setval('mcms_waste.waste_cost_allocation_allocation_id_seq', 1, true);


--
-- Name: waste_disposal_manifest_manifest_id_seq; Type: SEQUENCE SET; Schema: mcms_waste; Owner: -
--

SELECT pg_catalog.setval('mcms_waste.waste_disposal_manifest_manifest_id_seq', 1, true);


--
-- Name: waste_stream_stream_id_seq; Type: SEQUENCE SET; Schema: mcms_waste; Owner: -
--

SELECT pg_catalog.setval('mcms_waste.waste_stream_stream_id_seq', 5, true);


--
-- PostgreSQL database dump complete
--

\unrestrict lPfARl8gMsTvkLtDtB6cWBqFXIHtKKD46AJsP4PO7YwuOCz4cBwb4S5prtUkbda

