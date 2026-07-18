--
-- PostgreSQL database dump
--

\restrict n9Z0Egihg3Hxj5e5bjVZNA9B3bvKlxGGZoW8qKIlg04khwbhVZ0UvKVEluJbDXQ

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
	(1, 'HQ', 'National HQ', 'المقر الوطني', NULL, true, '2026-07-18 21:16:07.554236+03', 1);


ALTER TABLE mcms_core.organization ENABLE TRIGGER ALL;

--
-- Data for Name: facility; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.facility DISABLE TRIGGER ALL;

INSERT INTO mcms_core.facility VALUES
	(1, 1, 'DEFAULT', 'Default Facility', 'المنشأة الافتراضية', NULL, true, '2026-07-18 21:16:07.554236+03'),
	(2, 1, 'TERT', 'National Tertiary Centre', 'المركز الوطني التخصصي', NULL, true, '2026-07-18 21:16:07.723494+03'),
	(3, 1, 'DIST', 'District General Hospital', 'مستشفى المنطقة العام', NULL, true, '2026-07-18 21:16:07.723494+03'),
	(4, 1, 'CANC', 'Regional Cancer Centre', 'المركز الإقليمي للأورام', NULL, true, '2026-07-18 21:16:07.723494+03');


ALTER TABLE mcms_core.facility ENABLE TRIGGER ALL;

--
-- Data for Name: party; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.party DISABLE TRIGGER ALL;

INSERT INTO mcms_core.party VALUES
	(99003, 'person', NULL, 'Demo Portal Patient', NULL, 'female', NULL, 'unknown', NULL, NULL, true, '2026-07-18 21:16:07.504378+03', '2026-07-18 21:16:07.504378+03', 'en', 1),
	(1, 'person', NULL, 'Test Admin', NULL, NULL, NULL, 'unknown', NULL, NULL, true, '2026-07-18 21:16:08.776368+03', '2026-07-18 21:16:08.776368+03', 'en', 1),
	(2, 'person', NULL, 'Test Acc1', NULL, NULL, NULL, 'unknown', NULL, NULL, true, '2026-07-18 21:16:08.776368+03', '2026-07-18 21:16:08.776368+03', 'en', 1);


ALTER TABLE mcms_core.party ENABLE TRIGGER ALL;

--
-- Data for Name: app_user; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.app_user DISABLE TRIGGER ALL;

INSERT INTO mcms_core.app_user VALUES
	(99, 99003, 'patient1', '$2b$12$KIXQ9zY8x7w6v5u4t3s2rOq0p1n2m3l4k5j6h7g8f9d0c1b2a3y4z5', 'patient', NULL, true, NULL, 0, NULL, '2026-07-18 21:16:07.504378+03', '2026-07-18 21:16:07.504378+03', NULL),
	(1, 1, 'admin', '!', 'admin', NULL, true, NULL, 0, NULL, '2026-07-18 21:16:08.776368+03', '2026-07-18 21:16:08.776368+03', NULL),
	(2, 2, 'acc1', '!', 'billing_clerk', NULL, true, NULL, 0, NULL, '2026-07-18 21:16:08.776368+03', '2026-07-18 21:16:08.776368+03', NULL);


ALTER TABLE mcms_core.app_user ENABLE TRIGGER ALL;

--
-- Data for Name: patient; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.patient DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.patient VALUES
	(99001, 99003, 'MRN-DEMO-PORTAL', NULL, NULL, NULL, NULL, NULL, NULL, false, NULL, NULL, false, false, '2026-07-18 21:16:07.504378+03', '2026-07-18 21:16:07.504378+03', NULL, NULL, 1, false);


ALTER TABLE mcms_emr.patient ENABLE TRIGGER ALL;

--
-- Data for Name: department; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.department DISABLE TRIGGER ALL;

INSERT INTO mcms_hr.department VALUES
	(1, 'ONC-UNIT', 'Oncology Department Unit', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(2, 'MED-GIM', 'Department of General Internal Medicine', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(3, 'NEU-PSY', 'Department of Neurology and Psychiatry', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(4, 'CARD-DIS', 'Department of Cardiology and Cardiovascular Diseases', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(5, 'CHEST', 'Department of Chest Diseases', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(6, 'TROP-MED', 'Department of Tropical Medicine', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(7, 'DERM-VEN', 'Department of Dermatology, Venereology and Andrology', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(8, 'GERI', 'Department of Geriatrics and Gerontology', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(9, 'FMED', 'Department of Family Medicine', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(10, 'GENET', 'Department of Medical Genetics', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(11, 'CLIN-PATH', 'Department of Clinical Pathology', NULL, 'lab', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(12, 'ONC-NM', 'Department of Clinical Oncology and Nuclear Medicine', NULL, 'radiology', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(13, 'RAD-DX', 'Department of Diagnostic Radiology', NULL, 'radiology', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(14, 'SURG-GEN', 'Department of General Surgery', NULL, 'surgical', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(15, 'SURG-CT', 'Department of Cardio-Thoracic Surgery', NULL, 'surgical', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(16, 'SURG-URO', 'Department of Urology', NULL, 'surgical', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(17, 'SURG-PLAS', 'Department of Plastic Burn and Maxillofacial Surgery', NULL, 'surgical', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(18, 'SURG-PED', 'Department of Pediatric Surgery', NULL, 'surgical', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(19, 'SURG-VASC', 'Department of Vascular Surgery', NULL, 'surgical', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(20, 'OPHTH', 'Department of Ophthalmology and Ophthalmic Surgery', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(21, 'OBS-GYN', 'Department of Obstetrics and Gynecology', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(22, 'ANES-ICU', 'Department of Anesthesiology, Intensive Care and Pain Management', NULL, 'icu', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(23, 'EMED', 'Department of Emergency Medicine', NULL, 'emergency', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(24, 'PHY-REHAB', 'Department of Rheumatology, Rehabilitation and Physical Medicine', NULL, 'physio', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(25, 'PROSTH', 'Department of Prosthetics', NULL, 'physio', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(26, 'IND-INST', 'Department of Industrial Installations', NULL, 'administration', NULL, NULL, NULL, true, '2026-07-18 21:16:07.698565+03', '2026-07-18 21:16:07.698565+03', 1),
	(27, 'CLIN-GEN', 'General Outpatient Clinic', NULL, 'clinic', NULL, 'Main', 1, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(28, 'CLIN-CARD', 'Cardiology Clinic', NULL, 'clinic', NULL, 'Main', 2, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(29, 'CLIN-ORTH', 'Orthopaedics Clinic', NULL, 'clinic', NULL, 'Main', 2, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(30, 'CLIN-OBS', 'Obstetrics & Gynaecology', NULL, 'clinic', NULL, 'Women', 3, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(31, 'CLIN-PAED', 'Paediatrics Clinic', NULL, 'clinic', NULL, 'Children', 2, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(32, 'CLIN-ENT', 'Otolaryngology (ENT)', NULL, 'clinic', NULL, 'Specialty', 1, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(33, 'OR-GEN', 'General Operating Theatre', NULL, 'surgical', NULL, 'Surgical Suite', 1, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(34, 'OR-CARD', 'Cardiac Surgery Theatre', NULL, 'surgical', NULL, 'Surgical Suite', 2, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(35, 'OR-ORTHO', 'Orthopaedic Surgery Theatre', NULL, 'surgical', NULL, 'Surgical Suite', 1, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(36, 'OR-NEURO', 'Neurosurgery Theatre', NULL, 'surgical', NULL, 'Surgical Suite', 2, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(37, 'ED-MAIN', 'Emergency Department', NULL, 'emergency', NULL, 'Main', 1, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(38, 'ED-TRIAGE', 'Triage Area', NULL, 'emergency', NULL, 'Main', 1, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(39, 'ICU-GEN', 'General ICU', NULL, 'icu', NULL, 'Critical Care', 3, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(40, 'ICU-CCU', 'Coronary Care Unit', NULL, 'icu', NULL, 'Critical Care', 3, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(41, 'ICU-NICU', 'Neonatal ICU', NULL, 'icu', NULL, 'Paediatrics', 2, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(42, 'LAB-CLIN', 'Clinical Laboratory', NULL, 'lab', NULL, 'Service Block', -1, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(43, 'LAB-PATH', 'Pathology Lab', NULL, 'lab', NULL, 'Service Block', -1, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(44, 'RAD-MAIN', 'Radiology / Imaging', NULL, 'radiology', NULL, 'Service Block', -1, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(45, 'RX-MAIN', 'Inpatient Pharmacy', NULL, 'pharmacy', NULL, 'Service Block', 0, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(46, 'RX-OUT', 'Outpatient Pharmacy', NULL, 'pharmacy', NULL, 'Main', 1, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(47, 'PHY-MAIN', 'Physiotherapy Unit', NULL, 'physio', NULL, 'Rehab', 1, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(48, 'BILL-M', 'Billing Office', NULL, 'billing', NULL, 'Administration', 0, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(49, 'HR-M', 'Human Resources', NULL, 'hr', NULL, 'Administration', 0, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(50, 'ADMIN', 'Administration', NULL, 'administration', NULL, 'Administration', 0, true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(51, 'DIAL-GEN', 'Dialysis Unit', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:08.705882+03', '2026-07-18 21:16:08.705882+03', 1),
	(52, 'NURS-GEN', 'Nursery / Neonatal Unit', NULL, 'clinic', NULL, NULL, NULL, true, '2026-07-18 21:16:08.705882+03', '2026-07-18 21:16:08.705882+03', 1);


ALTER TABLE mcms_hr.department ENABLE TRIGGER ALL;

--
-- Data for Name: encounter; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.encounter DISABLE TRIGGER ALL;



ALTER TABLE mcms_emr.encounter ENABLE TRIGGER ALL;

--
-- Data for Name: invoice; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.invoice DISABLE TRIGGER ALL;



ALTER TABLE mcms_billing.invoice ENABLE TRIGGER ALL;

--
-- Data for Name: insurance_claim; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.insurance_claim DISABLE TRIGGER ALL;



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
	(2, 'SVC-DOC-EMR', 'EMR Document Fee', 'emr_document', 27, 10.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(3, 'SVC-CONSULT-GEN', 'General Consultation', 'consultation', 27, 150.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(4, 'SVC-CONSULT-CARD', 'Cardiology Consultation', 'consultation', 28, 250.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(5, 'SVC-ANAESTHESIA', 'Anaesthesia Fee', 'anaesthesia', 33, 500.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(6, 'SVC-OR-MIN', 'OR Charge per Minute', 'surgery_or', 33, 45.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(7, 'SVC-AMBULATE', 'Ambulance Service', 'ambulance', 37, 350.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(8, 'SVC-ED-VISIT', 'Emergency Visit Fee', 'emergency_triage', 37, 450.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(9, 'SVC-ED-TRIAGE', 'Emergency Triage Fee', 'emergency_triage', 38, 300.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(10, 'SVC-ICU-BED-DAY', 'ICU Bed Day Charge', 'icu_bed', 39, 2200.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(11, 'SVC-LAB-CMP', 'Comprehensive Metabolic Panel', 'lab_test', 42, 180.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(12, 'SVC-LAB-CBC', 'CBC Test', 'lab_test', 42, 60.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(13, 'SVC-RAD-MRI-BRN', 'MRI Brain with Contrast', 'imaging', 44, 1500.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(14, 'SVC-RAD-CT-THX', 'CT Thorax', 'imaging', 44, 650.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(15, 'SVC-RAD-XR-CHST', 'Chest X-ray', 'imaging', 44, 120.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(16, 'SVC-PHYSIO-SESS', 'Physiotherapy Session', 'physio_session', 47, 200.00, 'SAR', true, true, '2026-07-18', NULL, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1);


ALTER TABLE mcms_billing.service_price ENABLE TRIGGER ALL;

--
-- Data for Name: invoice_line; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.invoice_line DISABLE TRIGGER ALL;



ALTER TABLE mcms_billing.invoice_line ENABLE TRIGGER ALL;

--
-- Data for Name: payer; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.payer DISABLE TRIGGER ALL;

INSERT INTO mcms_billing.payer VALUES
	(1, 'MOH', 'Ministry of Health', true, true, true, true, '2026-07-18 21:16:07.68109+03', 1),
	(2, 'NHIF', 'National Health Insurance', true, true, true, true, '2026-07-18 21:16:07.68109+03', 1),
	(3, 'AXA', 'AXA Gulf Insurance', true, true, true, true, '2026-07-18 21:16:07.68109+03', 1);


ALTER TABLE mcms_billing.payer ENABLE TRIGGER ALL;

--
-- Data for Name: payment; Type: TABLE DATA; Schema: mcms_billing; Owner: -
--

ALTER TABLE mcms_billing.payment DISABLE TRIGGER ALL;



ALTER TABLE mcms_billing.payment ENABLE TRIGGER ALL;

--
-- Data for Name: room; Type: TABLE DATA; Schema: mcms_clinic; Owner: -
--

ALTER TABLE mcms_clinic.room DISABLE TRIGGER ALL;



ALTER TABLE mcms_clinic.room ENABLE TRIGGER ALL;

--
-- Data for Name: appointment; Type: TABLE DATA; Schema: mcms_clinic; Owner: -
--

ALTER TABLE mcms_clinic.appointment DISABLE TRIGGER ALL;



ALTER TABLE mcms_clinic.appointment ENABLE TRIGGER ALL;

--
-- Data for Name: patient_queue; Type: TABLE DATA; Schema: mcms_clinic; Owner: -
--

ALTER TABLE mcms_clinic.patient_queue DISABLE TRIGGER ALL;



ALTER TABLE mcms_clinic.patient_queue ENABLE TRIGGER ALL;

--
-- Data for Name: consultation; Type: TABLE DATA; Schema: mcms_clinic; Owner: -
--

ALTER TABLE mcms_clinic.consultation DISABLE TRIGGER ALL;



ALTER TABLE mcms_clinic.consultation ENABLE TRIGGER ALL;

--
-- Data for Name: access_log; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.access_log DISABLE TRIGGER ALL;



ALTER TABLE mcms_core.access_log ENABLE TRIGGER ALL;

--
-- Data for Name: address; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.address DISABLE TRIGGER ALL;



ALTER TABLE mcms_core.address ENABLE TRIGGER ALL;

--
-- Data for Name: event_log; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.event_log DISABLE TRIGGER ALL;

INSERT INTO mcms_core.event_log VALUES
	(1, 2, '2026-07-18 21:16:07.504378+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 1, '{"code": "patient.portal", "description": "Access own patient portal (appointments, results, bills, consents)", "permission_id": 1}', 'db-trigger', NULL, '6c17baf5db287691cc0e61a53be0dd3fac3a6816b52b6f3cab51072c35d5f0c9', 1),
	(2, 4, '2026-07-18 21:16:07.504378+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 1, '{"code": "patient", "name_ar": "مريض", "name_en": "Patient", "role_id": 1, "is_active": true, "created_at": "2026-07-18T21:16:07.504378+03:00", "description": "Self-service portal access scoped to own record"}', 'db-trigger', '6c17baf5db287691cc0e61a53be0dd3fac3a6816b52b6f3cab51072c35d5f0c9', '7cc7bef0a8b29b89a7e7d6b35fa64462685f28ed18e104da0d4786c14d70891f', 1),
	(3, 6, '2026-07-18 21:16:07.504378+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 1, '{"role_id": 1, "permission_id": 1}', 'db-trigger', '7cc7bef0a8b29b89a7e7d6b35fa64462685f28ed18e104da0d4786c14d70891f', 'd6c033e1fef429f1493de8c05376308509941b7b0c33810931a884acfa0d0617', 1),
	(4, 8, '2026-07-18 21:16:07.504378+03', 'create', 'info', NULL, NULL, 'mcms_core', 'party', 99003, '{"code": null, "gender": "female", "tax_id": null, "party_id": 99003, "is_active": true, "blood_type": "unknown", "created_at": "2026-07-18T21:16:07.504378+03:00", "legal_name": null, "party_type": "person", "updated_at": "2026-07-18T21:16:07.504378+03:00", "national_id": null, "display_name": "Demo Portal Patient", "date_of_birth": null, "preferred_language": "en"}', 'db-trigger', 'd6c033e1fef429f1493de8c05376308509941b7b0c33810931a884acfa0d0617', '1435f5520fb55975e8090e280e44fe3db664e2cbc2838fecdee72fa032b06043', 1),
	(5, 10, '2026-07-18 21:16:07.504378+03', 'create', 'info', NULL, NULL, 'mcms_emr', 'patient', 99001, '{"mrn": "MRN-DEMO-PORTAL", "fhir_id": null, "hl7_mpi": null, "party_id": 99003, "created_at": "2026-07-18T21:16:07.504378+03:00", "patient_id": 99001, "updated_at": "2026-07-18T21:16:07.504378+03:00", "facility_id": 1, "is_deceased": false, "living_will": false, "organ_donor": false, "coverage_verified": false, "insurance_group_no": null, "insurance_provider": null, "preferred_language": null, "insurance_policy_no": null, "coverage_verified_at": null, "next_of_kin_party_id": null, "emergency_contact_name": null, "emergency_contact_phone": null}', 'db-trigger', '1435f5520fb55975e8090e280e44fe3db664e2cbc2838fecdee72fa032b06043', 'db6521013d249410593e4ae9e7541f0d71082eef5c576e168ab97c501b69cb35', 1),
	(76, 152, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 13, '{"code": "J45.909", "label": "Unspecified asthma, uncomplicated", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 13, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '5d90de9612561ba79dc2f044e1431d36355cd5ebb50fbc0b3d1bc43258d89942', 'af1a72cc819502c6ac902e9177512823c318acf3cb69b86da7f467fdee567e64', 1),
	(6, 12, '2026-07-18 21:16:07.504378+03', 'create', 'info', NULL, NULL, 'mcms_core', 'app_user', 99, '{"role": "patient", "user_id": 99, "party_id": 99003, "username": "patient1", "is_active": true, "created_at": "2026-07-18T21:16:07.504378+03:00", "updated_at": "2026-07-18T21:16:07.504378+03:00", "facility_id": null, "locked_until": null, "failed_logins": 0, "last_login_at": null, "password_hash": "$2b$12$KIXQ9zY8x7w6v5u4t3s2rOq0p1n2m3l4k5j6h7g8f9d0c1b2a3y4z5", "specialization": null}', 'db-trigger', 'db6521013d249410593e4ae9e7541f0d71082eef5c576e168ab97c501b69cb35', '6efc26c1c6a9fd846164b3c66c0c2a96eeeda988ad6c9f93091a088e9186af41', 1),
	(7, 14, '2026-07-18 21:16:07.504378+03', 'create', 'info', NULL, NULL, 'mcms_core', 'user_role_map', 1, '{"role_id": 1, "user_id": 99, "department_id": null}', 'db-trigger', '6efc26c1c6a9fd846164b3c66c0c2a96eeeda988ad6c9f93091a088e9186af41', '01a25a177d81f03a43fda819723a78a3c4d7769bd8a401361f428ebf6d8d606f', 1),
	(8, 16, '2026-07-18 21:16:07.685139+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 2, '{"code": "rx.prescribe", "description": "Create / sign electronic prescriptions", "facility_id": 1, "permission_id": 2}', 'db-trigger', '01a25a177d81f03a43fda819723a78a3c4d7769bd8a401361f428ebf6d8d606f', '35b3b43717b2fee6ba5070ed3c63a9c15ce5a62d1681c310bff221963604933b', 1),
	(9, 18, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 1, '{"code": "ONC-UNIT", "kind": "clinic", "name": "Oncology Department Unit", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 1, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '35b3b43717b2fee6ba5070ed3c63a9c15ce5a62d1681c310bff221963604933b', '8a9d0b9af1d6bc0cc80c0bac3471c94cf881970f74800503b4e59f74613b2a83', 1),
	(10, 20, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 2, '{"code": "MED-GIM", "kind": "clinic", "name": "Department of General Internal Medicine", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 2, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '8a9d0b9af1d6bc0cc80c0bac3471c94cf881970f74800503b4e59f74613b2a83', 'd152257e452f8381b804b8da0a8a3526c09e91ffb3391909dd033bc1e1adc2a6', 1),
	(11, 22, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 3, '{"code": "NEU-PSY", "kind": "clinic", "name": "Department of Neurology and Psychiatry", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 3, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'd152257e452f8381b804b8da0a8a3526c09e91ffb3391909dd033bc1e1adc2a6', '2cd2febbdce797983c7c417d6a22eae6bc3be39badc7c522947b556023a24258', 1),
	(12, 24, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 4, '{"code": "CARD-DIS", "kind": "clinic", "name": "Department of Cardiology and Cardiovascular Diseases", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 4, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '2cd2febbdce797983c7c417d6a22eae6bc3be39badc7c522947b556023a24258', '96f3ed2abc61ef71c508af5b2b7561df5fbaf1d994d6ab027ba7df025dc81b3f', 1),
	(13, 26, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 5, '{"code": "CHEST", "kind": "clinic", "name": "Department of Chest Diseases", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 5, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '96f3ed2abc61ef71c508af5b2b7561df5fbaf1d994d6ab027ba7df025dc81b3f', '6a8832a6314b35baf8fa3958170a5361c35c242864c6966bc55aabd747e25e1a', 1),
	(14, 28, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 6, '{"code": "TROP-MED", "kind": "clinic", "name": "Department of Tropical Medicine", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 6, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '6a8832a6314b35baf8fa3958170a5361c35c242864c6966bc55aabd747e25e1a', '75a64b6d8c254e84208613094ae4738d3f3d228321bf7f16e5f5f87965f70cc5', 1),
	(15, 30, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 7, '{"code": "DERM-VEN", "kind": "clinic", "name": "Department of Dermatology, Venereology and Andrology", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 7, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '75a64b6d8c254e84208613094ae4738d3f3d228321bf7f16e5f5f87965f70cc5', '2332fe0d2ca8a6be313da50f0bbf29a3f2e63d9907ce5861a2ca0cb0cf69baaf', 1),
	(16, 32, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 8, '{"code": "GERI", "kind": "clinic", "name": "Department of Geriatrics and Gerontology", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 8, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '2332fe0d2ca8a6be313da50f0bbf29a3f2e63d9907ce5861a2ca0cb0cf69baaf', '1b28877a116e692e2588ae09ea0a2d279d616d9982e9d564b3801192ce45effe', 1),
	(17, 34, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 9, '{"code": "FMED", "kind": "clinic", "name": "Department of Family Medicine", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 9, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '1b28877a116e692e2588ae09ea0a2d279d616d9982e9d564b3801192ce45effe', '0182392acce376b4306a618fb1e8d991b2ffe049c02f271eac1a1cd91a6d99d4', 1),
	(18, 36, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 10, '{"code": "GENET", "kind": "clinic", "name": "Department of Medical Genetics", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 10, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '0182392acce376b4306a618fb1e8d991b2ffe049c02f271eac1a1cd91a6d99d4', 'a1084b25cb75d4e0a0dc780de3fd61595b99863440817651a5d6df173ddce795', 1),
	(19, 38, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 11, '{"code": "CLIN-PATH", "kind": "lab", "name": "Department of Clinical Pathology", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 11, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'a1084b25cb75d4e0a0dc780de3fd61595b99863440817651a5d6df173ddce795', 'ad575a153e552824900489bc62167463f1969a3207477e13f13b81c8d0d37795', 1),
	(20, 40, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 12, '{"code": "ONC-NM", "kind": "radiology", "name": "Department of Clinical Oncology and Nuclear Medicine", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 12, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'ad575a153e552824900489bc62167463f1969a3207477e13f13b81c8d0d37795', '37955e3d0cd5f4de1365a297ef04f3ba0c461ddfb4c084fabc8f41c6bf9474d7', 1),
	(21, 42, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 13, '{"code": "RAD-DX", "kind": "radiology", "name": "Department of Diagnostic Radiology", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 13, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '37955e3d0cd5f4de1365a297ef04f3ba0c461ddfb4c084fabc8f41c6bf9474d7', 'c11a23c667bac03c66c7e9e8e0d952e4b8433602005d5476b864c1a08771ccab', 1),
	(22, 44, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 14, '{"code": "SURG-GEN", "kind": "surgical", "name": "Department of General Surgery", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 14, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'c11a23c667bac03c66c7e9e8e0d952e4b8433602005d5476b864c1a08771ccab', '13a5c3950a4d62ad7be13f5ca4d1807c5d1291d585f9510625eff872e4581e2f', 1),
	(23, 46, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 15, '{"code": "SURG-CT", "kind": "surgical", "name": "Department of Cardio-Thoracic Surgery", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 15, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '13a5c3950a4d62ad7be13f5ca4d1807c5d1291d585f9510625eff872e4581e2f', '98e712bcd2ce9a4372820e9dfa39dfcbd6ef648e1a9fcf6d1a56601ffe73ce24', 1),
	(24, 48, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 16, '{"code": "SURG-URO", "kind": "surgical", "name": "Department of Urology", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 16, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '98e712bcd2ce9a4372820e9dfa39dfcbd6ef648e1a9fcf6d1a56601ffe73ce24', 'fb1dd987d9672b9e9945087d9f6a7876f30e800b7ded5bffc12b07979c8928d7', 1),
	(25, 50, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 17, '{"code": "SURG-PLAS", "kind": "surgical", "name": "Department of Plastic Burn and Maxillofacial Surgery", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 17, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'fb1dd987d9672b9e9945087d9f6a7876f30e800b7ded5bffc12b07979c8928d7', 'b88defbd1c6670df1a07391531020c99632eb064590c78fa0821416162f4e726', 1),
	(26, 52, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 18, '{"code": "SURG-PED", "kind": "surgical", "name": "Department of Pediatric Surgery", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 18, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'b88defbd1c6670df1a07391531020c99632eb064590c78fa0821416162f4e726', '3c235036902a4a71eeaaade3ced0df248d2a3b1c7a14251fcaf2f66405ed79e9', 1),
	(27, 54, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 19, '{"code": "SURG-VASC", "kind": "surgical", "name": "Department of Vascular Surgery", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 19, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '3c235036902a4a71eeaaade3ced0df248d2a3b1c7a14251fcaf2f66405ed79e9', '515757e4f5fb36dea8f564bffb575a33b1bef5510ce6841b93482ccdbef88c53', 1),
	(28, 56, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 20, '{"code": "OPHTH", "kind": "clinic", "name": "Department of Ophthalmology and Ophthalmic Surgery", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 20, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '515757e4f5fb36dea8f564bffb575a33b1bef5510ce6841b93482ccdbef88c53', 'a91fe1bd82a06ab40224bb83ab0309f43b584fc7e8a57a7744a3e0b5046a6d1d', 1),
	(29, 58, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 21, '{"code": "OBS-GYN", "kind": "clinic", "name": "Department of Obstetrics and Gynecology", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 21, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'a91fe1bd82a06ab40224bb83ab0309f43b584fc7e8a57a7744a3e0b5046a6d1d', 'a9bfd7ca22a98dacd4f9c967c92c62826ee3a4219dfe3eef16cd293f060d78f4', 1),
	(30, 60, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 22, '{"code": "ANES-ICU", "kind": "icu", "name": "Department of Anesthesiology, Intensive Care and Pain Management", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 22, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'a9bfd7ca22a98dacd4f9c967c92c62826ee3a4219dfe3eef16cd293f060d78f4', 'f181c8984696664d6b4f15c1198e3a49d5e5dea3a0d6b555ee790e32bb80b497', 1),
	(31, 62, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 23, '{"code": "EMED", "kind": "emergency", "name": "Department of Emergency Medicine", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 23, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'f181c8984696664d6b4f15c1198e3a49d5e5dea3a0d6b555ee790e32bb80b497', '4961ce2d346355d88233d2ad6e0cca7bde4a47df3c42c2ecdfe81fdf2dd6d324', 1),
	(32, 64, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 24, '{"code": "PHY-REHAB", "kind": "physio", "name": "Department of Rheumatology, Rehabilitation and Physical Medicine", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 24, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '4961ce2d346355d88233d2ad6e0cca7bde4a47df3c42c2ecdfe81fdf2dd6d324', 'c474cbd0969edf815a371500cfa4fefd5a40a98efc755e0fdd6f6f77371fa397', 1),
	(33, 66, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 25, '{"code": "PROSTH", "kind": "physio", "name": "Department of Prosthetics", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 25, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'c474cbd0969edf815a371500cfa4fefd5a40a98efc755e0fdd6f6f77371fa397', 'fa3f7e87c116c3e6b9c2c3d94783445f50032416b654ec7765ed937159e22252', 1),
	(34, 68, '2026-07-18 21:16:07.698565+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 26, '{"code": "IND-INST", "kind": "administration", "name": "Department of Industrial Installations", "is_active": true, "created_at": "2026-07-18T21:16:07.698565+03:00", "updated_at": "2026-07-18T21:16:07.698565+03:00", "facility_id": 1, "head_user_id": null, "department_id": 26, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', 'fa3f7e87c116c3e6b9c2c3d94783445f50032416b654ec7765ed937159e22252', '336d1465e84af2a7b5ba5de565c09895e605cba7b4e91cbf6a6a7acd345be57f', 1),
	(35, 70, '2026-07-18 21:16:08.48566+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 3, '{"code": "vital_records.read", "description": "View birth/death certificates", "facility_id": 1, "permission_id": 3}', 'db-trigger', '336d1465e84af2a7b5ba5de565c09895e605cba7b4e91cbf6a6a7acd345be57f', 'd7589c3dc0b433506fc75fe41de1b5f2a4e4f69c16628c36e65dd3e3ac01d9a9', 1),
	(36, 72, '2026-07-18 21:16:08.48566+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 4, '{"code": "vital_records.register", "description": "Register (issue) birth/death certificates", "facility_id": 1, "permission_id": 4}', 'db-trigger', 'd7589c3dc0b433506fc75fe41de1b5f2a4e4f69c16628c36e65dd3e3ac01d9a9', 'aa28ef4dfa677d246070a18027f6565fd8e598697879bbb102c3adefc0dfa45d', 1),
	(37, 74, '2026-07-18 21:16:08.48566+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 5, '{"code": "vital_records.certify", "description": "Certify cause of death / clinical attestation", "facility_id": 1, "permission_id": 5}', 'db-trigger', 'aa28ef4dfa677d246070a18027f6565fd8e598697879bbb102c3adefc0dfa45d', '5387cb5e7f9b1bfe13348e66bd12b3e2ebd9101a1587a8dc8dfa9f753feba0d5', 1),
	(38, 76, '2026-07-18 21:16:08.48566+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 1, '{"role_id": 1, "facility_id": 1, "permission_id": 3}', 'db-trigger', '5387cb5e7f9b1bfe13348e66bd12b3e2ebd9101a1587a8dc8dfa9f753feba0d5', 'df1405dd1059b4e1929ef821cb93e0755618a265fc24f6cfbe5216c953206e12', 1),
	(39, 78, '2026-07-18 21:16:08.500873+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 6, '{"code": "waste.read", "description": "View medical waste records, quantities and costs", "facility_id": 1, "permission_id": 6}', 'db-trigger', 'df1405dd1059b4e1929ef821cb93e0755618a265fc24f6cfbe5216c953206e12', '25b8e4f69eb60ef2d3c0da4bbde4fe348171c1744e5a9ed4519ac0caee07fd25', 1),
	(40, 80, '2026-07-18 21:16:08.500873+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 7, '{"code": "waste.manage", "description": "Create/edit medical waste records and disposal manifests", "facility_id": 1, "permission_id": 7}', 'db-trigger', '25b8e4f69eb60ef2d3c0da4bbde4fe348171c1744e5a9ed4519ac0caee07fd25', 'bddeaacc0cc4a6290cc26358f2b028d518b9e9e499e6ccaf249a7d7be09521fd', 1),
	(41, 82, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 27, '{"code": "CLIN-GEN", "kind": "clinic", "name": "General Outpatient Clinic", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 27, "location_floor": 1, "location_building": "Main", "parent_department_id": null}', 'db-trigger', 'bddeaacc0cc4a6290cc26358f2b028d518b9e9e499e6ccaf249a7d7be09521fd', '09b6950879902af158febd65374af15f3806b980b69075e636a1fb563a7d30a2', 1),
	(42, 84, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 28, '{"code": "CLIN-CARD", "kind": "clinic", "name": "Cardiology Clinic", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 28, "location_floor": 2, "location_building": "Main", "parent_department_id": null}', 'db-trigger', '09b6950879902af158febd65374af15f3806b980b69075e636a1fb563a7d30a2', '9ab004f141f7ce3792be8a294412201efe97e3625231d149c66b78aeb0688943', 1),
	(43, 86, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 29, '{"code": "CLIN-ORTH", "kind": "clinic", "name": "Orthopaedics Clinic", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 29, "location_floor": 2, "location_building": "Main", "parent_department_id": null}', 'db-trigger', '9ab004f141f7ce3792be8a294412201efe97e3625231d149c66b78aeb0688943', '830779426bae8bf052af58da40e0a64578723fd267d527a8972993e96c922408', 1),
	(44, 88, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 30, '{"code": "CLIN-OBS", "kind": "clinic", "name": "Obstetrics & Gynaecology", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 30, "location_floor": 3, "location_building": "Women", "parent_department_id": null}', 'db-trigger', '830779426bae8bf052af58da40e0a64578723fd267d527a8972993e96c922408', '637c645a9f791721177f5caf05f391aae60bd7b59fd30639c66602f68dd69fa1', 1),
	(45, 90, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 31, '{"code": "CLIN-PAED", "kind": "clinic", "name": "Paediatrics Clinic", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 31, "location_floor": 2, "location_building": "Children", "parent_department_id": null}', 'db-trigger', '637c645a9f791721177f5caf05f391aae60bd7b59fd30639c66602f68dd69fa1', '5b854f8c2d9efc83e6234d1839cba68a38905ea6258ecb565ee080850edf15df', 1),
	(46, 92, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 32, '{"code": "CLIN-ENT", "kind": "clinic", "name": "Otolaryngology (ENT)", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 32, "location_floor": 1, "location_building": "Specialty", "parent_department_id": null}', 'db-trigger', '5b854f8c2d9efc83e6234d1839cba68a38905ea6258ecb565ee080850edf15df', 'af590c8d5fee7b37e1896115cdfddf1a448f6719fde64e645162e4de86ffde90', 1),
	(47, 94, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 33, '{"code": "OR-GEN", "kind": "surgical", "name": "General Operating Theatre", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 33, "location_floor": 1, "location_building": "Surgical Suite", "parent_department_id": null}', 'db-trigger', 'af590c8d5fee7b37e1896115cdfddf1a448f6719fde64e645162e4de86ffde90', 'a501913d7302b38e3da82a696a0189a7694ffa89c8cbe26067d239dc22d450ae', 1),
	(48, 96, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 34, '{"code": "OR-CARD", "kind": "surgical", "name": "Cardiac Surgery Theatre", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 34, "location_floor": 2, "location_building": "Surgical Suite", "parent_department_id": null}', 'db-trigger', 'a501913d7302b38e3da82a696a0189a7694ffa89c8cbe26067d239dc22d450ae', '5d7b8fb9bd8df50cc3323405ebc7e5850c76f93400350aff926e905826be389d', 1),
	(49, 98, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 35, '{"code": "OR-ORTHO", "kind": "surgical", "name": "Orthopaedic Surgery Theatre", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 35, "location_floor": 1, "location_building": "Surgical Suite", "parent_department_id": null}', 'db-trigger', '5d7b8fb9bd8df50cc3323405ebc7e5850c76f93400350aff926e905826be389d', '38fd3f2eeb008c5593b5a64f7ed43b8d83597b9bada4797244ddca96183b0641', 1),
	(50, 100, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 36, '{"code": "OR-NEURO", "kind": "surgical", "name": "Neurosurgery Theatre", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 36, "location_floor": 2, "location_building": "Surgical Suite", "parent_department_id": null}', 'db-trigger', '38fd3f2eeb008c5593b5a64f7ed43b8d83597b9bada4797244ddca96183b0641', '155d2b6b6ac75537b1df17c60553c4e4887ca16e2a0b2ccd6d1e4474281a3fcb', 1),
	(51, 102, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 37, '{"code": "ED-MAIN", "kind": "emergency", "name": "Emergency Department", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 37, "location_floor": 1, "location_building": "Main", "parent_department_id": null}', 'db-trigger', '155d2b6b6ac75537b1df17c60553c4e4887ca16e2a0b2ccd6d1e4474281a3fcb', 'aabe63111a0022605d4de8cb2395eb7b96c331d4aa477f18fdbdfbc2f098d719', 1),
	(52, 104, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 38, '{"code": "ED-TRIAGE", "kind": "emergency", "name": "Triage Area", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 38, "location_floor": 1, "location_building": "Main", "parent_department_id": null}', 'db-trigger', 'aabe63111a0022605d4de8cb2395eb7b96c331d4aa477f18fdbdfbc2f098d719', '0f8a3b10e66e48a2b624314f011fc6cd5eb9d5b490ec104287a126d8ee9d420e', 1),
	(53, 106, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 39, '{"code": "ICU-GEN", "kind": "icu", "name": "General ICU", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 39, "location_floor": 3, "location_building": "Critical Care", "parent_department_id": null}', 'db-trigger', '0f8a3b10e66e48a2b624314f011fc6cd5eb9d5b490ec104287a126d8ee9d420e', '2d13c5c8418ca327b59759b2f513324cc01f18423a69492ddbac1e5daccc2582', 1),
	(54, 108, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 40, '{"code": "ICU-CCU", "kind": "icu", "name": "Coronary Care Unit", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 40, "location_floor": 3, "location_building": "Critical Care", "parent_department_id": null}', 'db-trigger', '2d13c5c8418ca327b59759b2f513324cc01f18423a69492ddbac1e5daccc2582', '0f1decbf621b1565e53783cd0ea5f3c3f5c580df58e326d4b9363a482797ad46', 1),
	(55, 110, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 41, '{"code": "ICU-NICU", "kind": "icu", "name": "Neonatal ICU", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 41, "location_floor": 2, "location_building": "Paediatrics", "parent_department_id": null}', 'db-trigger', '0f1decbf621b1565e53783cd0ea5f3c3f5c580df58e326d4b9363a482797ad46', '6e92f60c8268d72f32087beee73d1add76fc9552eb0a535e6feccbc26944a89f', 1),
	(56, 112, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 42, '{"code": "LAB-CLIN", "kind": "lab", "name": "Clinical Laboratory", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 42, "location_floor": -1, "location_building": "Service Block", "parent_department_id": null}', 'db-trigger', '6e92f60c8268d72f32087beee73d1add76fc9552eb0a535e6feccbc26944a89f', 'a9d951627d497a046af030b48c89c40244c04af85ae07ac2c3e605262d3d8cab', 1),
	(57, 114, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 43, '{"code": "LAB-PATH", "kind": "lab", "name": "Pathology Lab", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 43, "location_floor": -1, "location_building": "Service Block", "parent_department_id": null}', 'db-trigger', 'a9d951627d497a046af030b48c89c40244c04af85ae07ac2c3e605262d3d8cab', '873e0daa54e4576b3b3d6c5679460cc0d51623e3d566eb637f91c103aac95bb3', 1),
	(58, 116, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 44, '{"code": "RAD-MAIN", "kind": "radiology", "name": "Radiology / Imaging", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 44, "location_floor": -1, "location_building": "Service Block", "parent_department_id": null}', 'db-trigger', '873e0daa54e4576b3b3d6c5679460cc0d51623e3d566eb637f91c103aac95bb3', '7e2457b63e56c7961829eef9864195e6f8293a0ac07e86ad3386bec0e039abba', 1),
	(59, 118, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 45, '{"code": "RX-MAIN", "kind": "pharmacy", "name": "Inpatient Pharmacy", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 45, "location_floor": 0, "location_building": "Service Block", "parent_department_id": null}', 'db-trigger', '7e2457b63e56c7961829eef9864195e6f8293a0ac07e86ad3386bec0e039abba', '45e9fac99cda69812f909003ec84be5140025500081a0e0b90ebb2f5c91a67ca', 1),
	(60, 120, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 46, '{"code": "RX-OUT", "kind": "pharmacy", "name": "Outpatient Pharmacy", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 46, "location_floor": 1, "location_building": "Main", "parent_department_id": null}', 'db-trigger', '45e9fac99cda69812f909003ec84be5140025500081a0e0b90ebb2f5c91a67ca', '03a98ba71bc83cd8c8dfc3f7fab345811e874c721cdd4821771f9ec09526451a', 1),
	(61, 122, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 47, '{"code": "PHY-MAIN", "kind": "physio", "name": "Physiotherapy Unit", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 47, "location_floor": 1, "location_building": "Rehab", "parent_department_id": null}', 'db-trigger', '03a98ba71bc83cd8c8dfc3f7fab345811e874c721cdd4821771f9ec09526451a', '18e480729f8a7d3bb47591f8c1ad5eae4dca4e1a080f9e431ee89b2c24ae90f3', 1),
	(62, 124, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 48, '{"code": "BILL-M", "kind": "billing", "name": "Billing Office", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 48, "location_floor": 0, "location_building": "Administration", "parent_department_id": null}', 'db-trigger', '18e480729f8a7d3bb47591f8c1ad5eae4dca4e1a080f9e431ee89b2c24ae90f3', '8545d662ecdaf23691d8861bb700e8f516f451e3425d63c702e5f0dbd5bc4f14', 1),
	(63, 126, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 49, '{"code": "HR-M", "kind": "hr", "name": "Human Resources", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 49, "location_floor": 0, "location_building": "Administration", "parent_department_id": null}', 'db-trigger', '8545d662ecdaf23691d8861bb700e8f516f451e3425d63c702e5f0dbd5bc4f14', 'aa42e4d673422b24a5f3440d320d2fd08d1d7cff7a4fb1952d92c55ef91dcb90', 1),
	(64, 128, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 50, '{"code": "ADMIN", "kind": "administration", "name": "Administration", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "head_user_id": null, "department_id": 50, "location_floor": 0, "location_building": "Administration", "parent_department_id": null}', 'db-trigger', 'aa42e4d673422b24a5f3440d320d2fd08d1d7cff7a4fb1952d92c55ef91dcb90', '0509dd43ceb519aaef6f298967ede1b7a6bcf5a3f44f992c1534e0edaef8ec2e', 1),
	(65, 130, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 2, '{"code": "J00", "label": "Acute nasopharyngitis [common cold]", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 2, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '0509dd43ceb519aaef6f298967ede1b7a6bcf5a3f44f992c1534e0edaef8ec2e', 'd811c0cda2904557cf0a40f780063973aa170ea5c2674eb68ae509fd63d10883', 1),
	(66, 132, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 3, '{"code": "J20.9", "label": "Acute bronchitis, unspecified", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 3, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'd811c0cda2904557cf0a40f780063973aa170ea5c2674eb68ae509fd63d10883', '2d77c20d23e7b1ed14d161c63f1a08837079764c6fb6508be88dca9fe2d64533', 1),
	(67, 134, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 4, '{"code": "E11.9", "label": "Type 2 diabetes mellitus without complications", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 4, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '2d77c20d23e7b1ed14d161c63f1a08837079764c6fb6508be88dca9fe2d64533', '46d495a98e78b049c29d2cb33b5216aec179b83ff3b953112cad64f51c489ec5', 1),
	(68, 136, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 5, '{"code": "I10", "label": "Essential (primary) hypertension", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 5, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '46d495a98e78b049c29d2cb33b5216aec179b83ff3b953112cad64f51c489ec5', '5b7c249f52c97a54736187c5206a16b080d92bf337c4fd13edbe14b27bbf7a46', 1),
	(69, 138, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 6, '{"code": "E78.5", "label": "Hypercholesterolaemia, unspecified", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 6, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '5b7c249f52c97a54736187c5206a16b080d92bf337c4fd13edbe14b27bbf7a46', '8df7e532e58b4d3f34e0647a28b66d8d9d8fa382bc95600bb0fd6f552fdfb13f', 1),
	(70, 140, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 7, '{"code": "M54.5", "label": "Low back pain", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 7, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '8df7e532e58b4d3f34e0647a28b66d8d9d8fa382bc95600bb0fd6f552fdfb13f', 'adccc4ab91e3e975d78cec1077cdcdc7d560f172d1f850e0eef290082437609e', 1),
	(71, 142, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 8, '{"code": "K21.9", "label": "Gastro-oesophageal reflux disease without oesophagitis", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 8, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'adccc4ab91e3e975d78cec1077cdcdc7d560f172d1f850e0eef290082437609e', '795dced99c7e99067425ec2c8b26230414d9274f98ae12189f7dca1992177648', 1),
	(72, 144, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 9, '{"code": "N39.0", "label": "Urinary tract infection, site not specified", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 9, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '795dced99c7e99067425ec2c8b26230414d9274f98ae12189f7dca1992177648', '78bd212fa35a246d3f9a90d0d61b4964ceb5bedbb6612d9a629c6ef7c6505d7b', 1),
	(73, 146, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 10, '{"code": "R51", "label": "Headache", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 10, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '78bd212fa35a246d3f9a90d0d61b4964ceb5bedbb6612d9a629c6ef7c6505d7b', '4e156ed7fa1a8a597de35c4d12c05f2d0b3a9ee5a9d2397acf11635ec29206a4', 1),
	(74, 148, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 11, '{"code": "S82.8", "label": "Fracture of other specified parts of lower leg", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 11, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '4e156ed7fa1a8a597de35c4d12c05f2d0b3a9ee5a9d2397acf11635ec29206a4', '3d120534b6f221cdd9130bb2ded4bf937805fcc3aad9307bbe17460c618b1df6', 1),
	(75, 150, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 12, '{"code": "I21.9", "label": "Acute myocardial infarction, unspecified", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 12, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '3d120534b6f221cdd9130bb2ded4bf937805fcc3aad9307bbe17460c618b1df6', '5d90de9612561ba79dc2f044e1431d36355cd5ebb50fbc0b3d1bc43258d89942', 1),
	(77, 154, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 14, '{"code": "C50.9", "label": "Malignant neoplasm of breast of unspecified site, female", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 14, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'af1a72cc819502c6ac902e9177512823c318acf3cb69b86da7f467fdee567e64', 'a09744e979681252365750cd13435a0d4b7f72749db42adc4d3a34e08d9ea176', 1),
	(78, 156, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 15, '{"code": "K80.20", "label": "Calculus of gallbladder without cholecystitis", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 15, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'a09744e979681252365750cd13435a0d4b7f72749db42adc4d3a34e08d9ea176', 'e16e5e94d54f4b5499105a4f113f825af4d046f4cff959c4eefd9fc0efd9d5c8', 1),
	(79, 158, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 16, '{"code": "A09", "label": "Diarrhoea and gastroenteritis of infectious origin", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 16, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'e16e5e94d54f4b5499105a4f113f825af4d046f4cff959c4eefd9fc0efd9d5c8', '7fb2745e9e55777ef2dcf8515f8a7227d853075132edaf48d7bc4bb4308344e4', 1),
	(80, 160, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 17, '{"code": "O80", "label": "Encounter for full-term uncomplicated delivery", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 17, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '7fb2745e9e55777ef2dcf8515f8a7227d853075132edaf48d7bc4bb4308344e4', 'f82bc09d40501d8744d94491acc8ae2a74b811dfc43367f9a90f0f65afd9ccf1', 1),
	(81, 162, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 18, '{"code": "O34.21", "label": "Maternal care for congenital uterine malformation", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 18, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'f82bc09d40501d8744d94491acc8ae2a74b811dfc43367f9a90f0f65afd9ccf1', 'c1ff9dcda0fdf4eca230e9aec88ff45d15f1b320d51d95ef3f5c959a66ba3e4a', 1),
	(82, 164, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 19, '{"code": "S06.0", "label": "Intracranial injury (concussion of brain)", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 19, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'c1ff9dcda0fdf4eca230e9aec88ff45d15f1b320d51d95ef3f5c959a66ba3e4a', 'f9b129fc7ae4299fccd945a91ffc4d36bb6e510624f9e220bc3ed54db4448426', 1),
	(83, 166, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 20, '{"code": "S72.0", "label": "Fracture of neck of femur", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 20, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'f9b129fc7ae4299fccd945a91ffc4d36bb6e510624f9e220bc3ed54db4448426', '254c2258f19aa5df51d42e18e552d031ce65ab2aa6473f5f38a2f19df3ea90fe', 1),
	(84, 168, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 21, '{"code": "S02.5", "label": "Fracture of tooth (traumatic)", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 21, "namespace": "icd10", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '254c2258f19aa5df51d42e18e552d031ce65ab2aa6473f5f38a2f19df3ea90fe', 'ec4b355ff8a70b890484f6d12ccac014bf39b2b0546469843479e0d6c989e656', 1),
	(85, 170, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 22, '{"code": "99213", "label": "Office Visit, Established Patient, Low Complexity", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 22, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'ec4b355ff8a70b890484f6d12ccac014bf39b2b0546469843479e0d6c989e656', '67925100cf703a1f14d0083cdd459c3159fd00ee9a963402a4278097136dc80b', 1),
	(86, 172, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 23, '{"code": "99214", "label": "Office Visit, Established Patient, Moderate", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 23, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '67925100cf703a1f14d0083cdd459c3159fd00ee9a963402a4278097136dc80b', 'b8062bbd7e8c32cecbf6ab77f3792b4e136db045c2179ebe76b4bff9a68621ac', 1),
	(87, 174, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 24, '{"code": "99204", "label": "Office Visit, New Patient, Moderate", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 24, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'b8062bbd7e8c32cecbf6ab77f3792b4e136db045c2179ebe76b4bff9a68621ac', '7415e7628819f59630c60499ad01e3cf5d0891dbbf5400f80a70a674a9e2e833', 1),
	(88, 176, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 25, '{"code": "58150", "label": "Total abdominal hysterectomy", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 25, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '7415e7628819f59630c60499ad01e3cf5d0891dbbf5400f80a70a674a9e2e833', '295c6b82c6b33e75ece581672f52795b52742a7376a530d9db48c2dcc785a8ea', 1),
	(89, 178, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 26, '{"code": "23470", "label": "Arthroplasty, glenohumeral joint", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 26, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '295c6b82c6b33e75ece581672f52795b52742a7376a530d9db48c2dcc785a8ea', '9643eb6117c8b7faa275c8de1b057446ef11d0bfcd40bb05e02a8b3f15b3502d', 1),
	(90, 180, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 27, '{"code": "27130", "label": "Total hip arthroplasty", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 27, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '9643eb6117c8b7faa275c8de1b057446ef11d0bfcd40bb05e02a8b3f15b3502d', '64e3059bbe802e882778dabc93c4afe6c0d58349b78b9001cac65e51a07a37f6', 1),
	(91, 182, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 28, '{"code": "27447", "label": "Total knee arthroplasty", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 28, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '64e3059bbe802e882778dabc93c4afe6c0d58349b78b9001cac65e51a07a37f6', 'f7d5628a006bc640a6be6e9f4a3b31b07df2c9ec3dbb01ad984e80db0fa182ee', 1),
	(92, 184, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 29, '{"code": "49505", "label": "Repair of femoral hernia", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 29, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'f7d5628a006bc640a6be6e9f4a3b31b07df2c9ec3dbb01ad984e80db0fa182ee', '1964e239f32f136798f513547e9f60664ffdfeb9e2c988f89e1a5699616c6775', 1),
	(93, 186, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 30, '{"code": "47579", "label": "Open cholecystectomy", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 30, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '1964e239f32f136798f513547e9f60664ffdfeb9e2c988f89e1a5699616c6775', 'e3f8902a016070bcf0ce750bdef8daf5f9ce0fbd6c81f5d4bc59bcc3f00a09ab', 1),
	(94, 188, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 31, '{"code": "33533", "label": "Coronary artery bypass, single", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 31, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'e3f8902a016070bcf0ce750bdef8daf5f9ce0fbd6c81f5d4bc59bcc3f00a09ab', '7e02675401b77037654576638b5de307233f57d02cca5423574016cfbb29fdec', 1),
	(95, 190, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 32, '{"code": "80053", "label": "Comprehensive Metabolic Panel", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 32, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '7e02675401b77037654576638b5de307233f57d02cca5423574016cfbb29fdec', '772408d48874097b8da27bf23e6251e4399d62db7e4f437e2ea1be263a5db35d', 1),
	(96, 192, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 33, '{"code": "80048", "label": "Basic Metabolic Panel", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 33, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '772408d48874097b8da27bf23e6251e4399d62db7e4f437e2ea1be263a5db35d', '22ee8fd86a1890371b8efcfd3917a0202bbcbcc723fe1e4e7da9218d3ecb68c0', 1),
	(97, 194, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 34, '{"code": "85025", "label": "CBC w/ differential", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 34, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '22ee8fd86a1890371b8efcfd3917a0202bbcbcc723fe1e4e7da9218d3ecb68c0', '279e1372c09432d45d1e49157162c9b2d10193617334a2ae301c800645e991ba', 1),
	(98, 196, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 35, '{"code": "81002", "label": "Urinalysis, non-automated", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 35, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '279e1372c09432d45d1e49157162c9b2d10193617334a2ae301c800645e991ba', '00995ff693da78a30a77c169341926805f9086da9a804612681146c5e064324b', 1),
	(99, 198, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 36, '{"code": "71045", "label": "X-ray chest, complete view", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 36, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '00995ff693da78a30a77c169341926805f9086da9a804612681146c5e064324b', '17f984849f93fb8eb049b1a79c33d8939be51a44ab4c69daaebc3a6fa4fd0e7b', 1),
	(100, 200, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 37, '{"code": "71250", "label": "CT thorax without contrast", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 37, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', '17f984849f93fb8eb049b1a79c33d8939be51a44ab4c69daaebc3a6fa4fd0e7b', 'f98e2f8951037990699aec0882634e48b425dd470d4ebb405fce6a84b99ee7ae', 1),
	(101, 202, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 38, '{"code": "70553", "label": "MRI brain with contrast", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 38, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'f98e2f8951037990699aec0882634e48b425dd470d4ebb405fce6a84b99ee7ae', 'e0bb0e6aef1cacbac1edbd24d0f01be33f4c5d4c22d46a02abf8a45daeb2407b', 1),
	(102, 204, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 39, '{"code": "76700", "label": "Ultrasound abdomen", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 39, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'e0bb0e6aef1cacbac1edbd24d0f01be33f4c5d4c22d46a02abf8a45daeb2407b', 'd395de3a38e40214866f324d9c34fa4e24f7f86d46321b21e1b4a9a076542f9a', 1),
	(103, 206, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_core', 'lookup', 40, '{"code": "93000", "label": "ECG, 12-lead", "label_ar": null, "label_en": null, "is_active": true, "lookup_id": 40, "namespace": "cpt", "sort_order": 0, "facility_id": 1, "parent_code": null}', 'db-trigger', 'd395de3a38e40214866f324d9c34fa4e24f7f86d46321b21e1b4a9a076542f9a', 'babcd1acdd6d085f9da4e8b6ce425c6d494a9ad5802a27be6d8b95e847d22f4e', 1),
	(104, 208, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 2, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "500 mg", "is_active": true, "brand_name": "Panadol", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "analgesic", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 5000, "rxnorm_code": null, "drug_item_id": 2, "generic_name": "Paracetamol", "manufacturer": null, "cost_per_unit": 0.05, "reorder_level": 1000, "requires_cold_chain": false, "sale_price_per_unit": 0.15, "controlled_substance": false}', 'db-trigger', 'babcd1acdd6d085f9da4e8b6ce425c6d494a9ad5802a27be6d8b95e847d22f4e', '919184c3bbde4e2affe2de00f846ddc310034cc78dc0b2498756a1aa0f7f648a', 1),
	(105, 210, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 3, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "400 mg", "is_active": true, "brand_name": "Brufen", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "nsaid", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 3000, "rxnorm_code": null, "drug_item_id": 3, "generic_name": "Ibuprofen", "manufacturer": null, "cost_per_unit": 0.08, "reorder_level": 500, "requires_cold_chain": false, "sale_price_per_unit": 0.20, "controlled_substance": false}', 'db-trigger', '919184c3bbde4e2affe2de00f846ddc310034cc78dc0b2498756a1aa0f7f648a', '4d81f0ca6e6058004179fa5e909e3defa8f198c8ba65930fd53d748857998385', 1),
	(106, 212, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 4, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "75 mg", "is_active": true, "brand_name": "Aspec", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "cardiac", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 1000, "rxnorm_code": null, "drug_item_id": 4, "generic_name": "Acetylsalicylic acid", "manufacturer": null, "cost_per_unit": 0.03, "reorder_level": 200, "requires_cold_chain": false, "sale_price_per_unit": 0.10, "controlled_substance": false}', 'db-trigger', '4d81f0ca6e6058004179fa5e909e3defa8f198c8ba65930fd53d748857998385', 'a515f63f8f0726ad641412987a69af95f8a5852df285baaa355561db4f8e1155', 1),
	(185, 370, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 2, '{"ppi_id": 2, "test_id": 2, "panel_id": 2, "sort_order": 1, "facility_id": 1}', 'db-trigger', 'f612c3a788a7a658d2e7654ad2f546ae1a62e427d94955b5016cdc7e028af250', '2efdeaa58a2676d599d0dadebf343686b6bd38e8c3fd94840423acc55dabe865', 1),
	(107, 214, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 5, '{"form": "capsule", "unit": "capsule", "atc_code": null, "strength": "500 mg", "is_active": true, "brand_name": "Amoxil", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "antibiotic", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 2000, "rxnorm_code": null, "drug_item_id": 5, "generic_name": "Amoxicillin", "manufacturer": null, "cost_per_unit": 0.10, "reorder_level": 300, "requires_cold_chain": false, "sale_price_per_unit": 0.30, "controlled_substance": false}', 'db-trigger', 'a515f63f8f0726ad641412987a69af95f8a5852df285baaa355561db4f8e1155', 'c1f83cac0c24f06b13fb6dfcec3bf37ea450b9c30efad3e387902803901c7696', 1),
	(108, 216, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 6, '{"form": "capsule", "unit": "capsule", "atc_code": null, "strength": "500 mg", "is_active": true, "brand_name": "Keflex", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "antibiotic", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 2000, "rxnorm_code": null, "drug_item_id": 6, "generic_name": "Cephalexin", "manufacturer": null, "cost_per_unit": 0.15, "reorder_level": 300, "requires_cold_chain": false, "sale_price_per_unit": 0.40, "controlled_substance": false}', 'db-trigger', 'c1f83cac0c24f06b13fb6dfcec3bf37ea450b9c30efad3e387902803901c7696', 'ae361d2d71c5e2a45ccc3cc99bf72cd9d9fb74eae4958704e2e43e04058ac070', 1),
	(109, 218, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 7, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "850 mg", "is_active": true, "brand_name": "Glucophage", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "antidiabetic", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 2500, "rxnorm_code": null, "drug_item_id": 7, "generic_name": "Metformin", "manufacturer": null, "cost_per_unit": 0.06, "reorder_level": 400, "requires_cold_chain": false, "sale_price_per_unit": 0.20, "controlled_substance": false}', 'db-trigger', 'ae361d2d71c5e2a45ccc3cc99bf72cd9d9fb74eae4958704e2e43e04058ac070', '6cd414fc9be007a4504c0a39ffdb4bb44615ee1877d3082f3eebe2396c6f66fb', 1),
	(110, 220, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 8, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "20 mg", "is_active": true, "brand_name": "Lipitor", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "cardiac", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 2500, "rxnorm_code": null, "drug_item_id": 8, "generic_name": "Atorvastatin", "manufacturer": null, "cost_per_unit": 0.20, "reorder_level": 400, "requires_cold_chain": false, "sale_price_per_unit": 0.55, "controlled_substance": false}', 'db-trigger', '6cd414fc9be007a4504c0a39ffdb4bb44615ee1877d3082f3eebe2396c6f66fb', '4daedae6dbddc47ae3fd53ca45d37e151b91211dce2fea47970349a0e5d3360d', 1),
	(111, 222, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 9, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "10 mg", "is_active": true, "brand_name": "Norvasc", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "antihypertensive", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 2500, "rxnorm_code": null, "drug_item_id": 9, "generic_name": "Amlodipine", "manufacturer": null, "cost_per_unit": 0.10, "reorder_level": 400, "requires_cold_chain": false, "sale_price_per_unit": 0.30, "controlled_substance": false}', 'db-trigger', '4daedae6dbddc47ae3fd53ca45d37e151b91211dce2fea47970349a0e5d3360d', '1f66a1df67a806737494377d255502692ca309baa7a6b0a386ddb318b7a975dc', 1),
	(112, 224, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 10, '{"form": "capsule", "unit": "capsule", "atc_code": null, "strength": "20 mg", "is_active": true, "brand_name": "Prilosec", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "gi", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 3000, "rxnorm_code": null, "drug_item_id": 10, "generic_name": "Omeprazole", "manufacturer": null, "cost_per_unit": 0.10, "reorder_level": 500, "requires_cold_chain": false, "sale_price_per_unit": 0.35, "controlled_substance": false}', 'db-trigger', '1f66a1df67a806737494377d255502692ca309baa7a6b0a386ddb318b7a975dc', '13d1c71258a494fc41ceb9e107dfe3603820de2f981c7a746c81d86b0cc83acb', 1),
	(113, 226, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 11, '{"form": "inhaler", "unit": "inhaler", "atc_code": null, "strength": "100 mcg", "is_active": true, "brand_name": "Ventolin", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "respiratory", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 500, "rxnorm_code": null, "drug_item_id": 11, "generic_name": "Salbutamol", "manufacturer": null, "cost_per_unit": 1.20, "reorder_level": 100, "requires_cold_chain": false, "sale_price_per_unit": 4.50, "controlled_substance": false}', 'db-trigger', '13d1c71258a494fc41ceb9e107dfe3603820de2f981c7a746c81d86b0cc83acb', '5463180c6aaa9979f011d5a54c555378319b8a4cca26ac89771de2105828c62b', 1),
	(114, 228, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 12, '{"form": "vial", "unit": "vial", "atc_code": null, "strength": "100 u/mL", "is_active": true, "brand_name": "Humalog", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "antidiabetic", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 400, "rxnorm_code": null, "drug_item_id": 12, "generic_name": "Insulin Lispro", "manufacturer": null, "cost_per_unit": 6.50, "reorder_level": 80, "requires_cold_chain": false, "sale_price_per_unit": 15.00, "controlled_substance": false}', 'db-trigger', '5463180c6aaa9979f011d5a54c555378319b8a4cca26ac89771de2105828c62b', 'dfc267ee59c17b97d5a8198cdc635f60ab744d714cddb5672dac2f303bac9c79', 1),
	(115, 230, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 13, '{"form": "ampule", "unit": "ampule", "atc_code": null, "strength": "10 mg/mL", "is_active": true, "brand_name": "Morphsul", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "analgesic", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 300, "rxnorm_code": null, "drug_item_id": 13, "generic_name": "Morphine", "manufacturer": null, "cost_per_unit": 1.50, "reorder_level": 80, "requires_cold_chain": false, "sale_price_per_unit": 5.00, "controlled_substance": false}', 'db-trigger', 'dfc267ee59c17b97d5a8198cdc635f60ab744d714cddb5672dac2f303bac9c79', 'a181391c42bcabd5b8a81128b45519eb429b178498fea3904d8a7216d0a19875', 1),
	(116, 232, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 14, '{"form": "tablet", "unit": "tablet", "atc_code": null, "strength": "10 mg", "is_active": true, "brand_name": "Zyrtec", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "antihistamine", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 2500, "rxnorm_code": null, "drug_item_id": 14, "generic_name": "Cetirizine", "manufacturer": null, "cost_per_unit": 0.05, "reorder_level": 400, "requires_cold_chain": false, "sale_price_per_unit": 0.20, "controlled_substance": false}', 'db-trigger', 'a181391c42bcabd5b8a81128b45519eb429b178498fea3904d8a7216d0a19875', '1ec393448814f794057c9c2cf5933dc5d1672c3f8c2ab95f6e1e3fe03877c508', 1),
	(117, 234, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 15, '{"form": "bag", "unit": "bag", "atc_code": null, "strength": "500 mL", "is_active": true, "brand_name": "D5W", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "iv_fluid", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 600, "rxnorm_code": null, "drug_item_id": 15, "generic_name": "Dextrose 5%", "manufacturer": null, "cost_per_unit": 1.00, "reorder_level": 100, "requires_cold_chain": false, "sale_price_per_unit": 3.50, "controlled_substance": false}', 'db-trigger', '1ec393448814f794057c9c2cf5933dc5d1672c3f8c2ab95f6e1e3fe03877c508', 'be79d060e2f7ff4b8396b2d99461b3d8f266b4d744929bf682ec4702dad4d886', 1),
	(118, 236, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_item', 16, '{"form": "bag", "unit": "bag", "atc_code": null, "strength": "1000 mL", "is_active": true, "brand_name": "NS", "created_at": "2026-07-18T21:16:08.615001+03:00", "drug_class": "iv_fluid", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "reorder_qty": 600, "rxnorm_code": null, "drug_item_id": 16, "generic_name": "Sodium Chloride 0.9%", "manufacturer": null, "cost_per_unit": 1.00, "reorder_level": 100, "requires_cold_chain": false, "sale_price_per_unit": 4.00, "controlled_substance": false}', 'db-trigger', 'be79d060e2f7ff4b8396b2d99461b3d8f266b4d744929bf682ec4702dad4d886', 'b36015d314c00f3dd467dc0f24f3b041ca9531fbb853ad1a2890d4c3be246781', 1),
	(119, 238, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 2, '{"code": "SVC-DOC-EMR", "name": "EMR Document Fee", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 2, "unit_price": 10.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "emr_document", "department_id": 27, "effective_from": "2026-07-18"}', 'db-trigger', 'b36015d314c00f3dd467dc0f24f3b041ca9531fbb853ad1a2890d4c3be246781', '322c53e4701b5214b5dd07023f83d2ade6e854f00d75b10919553450be57e8ca', 1),
	(120, 240, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 3, '{"code": "SVC-CONSULT-GEN", "name": "General Consultation", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 3, "unit_price": 150.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "consultation", "department_id": 27, "effective_from": "2026-07-18"}', 'db-trigger', '322c53e4701b5214b5dd07023f83d2ade6e854f00d75b10919553450be57e8ca', 'eac247b8ec53071b680a0b3ec45407593230764c9e18870ae8637a0e91f2f312', 1),
	(121, 242, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 4, '{"code": "SVC-CONSULT-CARD", "name": "Cardiology Consultation", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 4, "unit_price": 250.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "consultation", "department_id": 28, "effective_from": "2026-07-18"}', 'db-trigger', 'eac247b8ec53071b680a0b3ec45407593230764c9e18870ae8637a0e91f2f312', '98980a572e62c03f2837aad90ff36a72deefb31969631060d157b370717a126d', 1),
	(122, 244, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 5, '{"code": "SVC-ANAESTHESIA", "name": "Anaesthesia Fee", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 5, "unit_price": 500.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "anaesthesia", "department_id": 33, "effective_from": "2026-07-18"}', 'db-trigger', '98980a572e62c03f2837aad90ff36a72deefb31969631060d157b370717a126d', '0924787aea3bdf57ecf9df6ec8133abfeeced99672ac368e0a8fd9e76233f6a4', 1),
	(123, 246, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 6, '{"code": "SVC-OR-MIN", "name": "OR Charge per Minute", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 6, "unit_price": 45.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "surgery_or", "department_id": 33, "effective_from": "2026-07-18"}', 'db-trigger', '0924787aea3bdf57ecf9df6ec8133abfeeced99672ac368e0a8fd9e76233f6a4', '335c630f5b60cac07d3bc95cff6c7b325e734f2a416dc72a533c3d6408f5c7bb', 1),
	(124, 248, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 7, '{"code": "SVC-AMBULATE", "name": "Ambulance Service", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 7, "unit_price": 350.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "ambulance", "department_id": 37, "effective_from": "2026-07-18"}', 'db-trigger', '335c630f5b60cac07d3bc95cff6c7b325e734f2a416dc72a533c3d6408f5c7bb', '6952528163dee57b776d8d0258d3720a967680ebdf0ce0a246ac682fdd048d54', 1),
	(125, 250, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 8, '{"code": "SVC-ED-VISIT", "name": "Emergency Visit Fee", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 8, "unit_price": 450.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "emergency_triage", "department_id": 37, "effective_from": "2026-07-18"}', 'db-trigger', '6952528163dee57b776d8d0258d3720a967680ebdf0ce0a246ac682fdd048d54', '4d4115372fb259199f80f2e39fbd7b0dc606750b5b54d51c035722e3f57f8cca', 1),
	(126, 252, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 9, '{"code": "SVC-ED-TRIAGE", "name": "Emergency Triage Fee", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 9, "unit_price": 300.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "emergency_triage", "department_id": 38, "effective_from": "2026-07-18"}', 'db-trigger', '4d4115372fb259199f80f2e39fbd7b0dc606750b5b54d51c035722e3f57f8cca', '50a95eb6790b2a3353200043ef4c5f2b08b2371e0d570f2f28fb11551f622feb', 1),
	(127, 254, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 10, '{"code": "SVC-ICU-BED-DAY", "name": "ICU Bed Day Charge", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 10, "unit_price": 2200.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "icu_bed", "department_id": 39, "effective_from": "2026-07-18"}', 'db-trigger', '50a95eb6790b2a3353200043ef4c5f2b08b2371e0d570f2f28fb11551f622feb', '6adc0345c1f17b9377cb017cb9aee3352d659feda9fce14111222aa944dbb492', 1),
	(156, 312, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'modality_suite', 3, '{"code": "RAD-CT", "name": "CT Suite A", "modality": "ct", "suite_id": 3, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "department_id": 44}', 'db-trigger', '6cc4a9a695d2c17936ed1ab53087ee6af1d973451808e9254843df309bd2c100', '3d1f97144195ba4bd562973bbe466a35220d70ba319e077f8595fdbe9ecad012', 1),
	(128, 256, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 11, '{"code": "SVC-LAB-CMP", "name": "Comprehensive Metabolic Panel", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 11, "unit_price": 180.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "lab_test", "department_id": 42, "effective_from": "2026-07-18"}', 'db-trigger', '6adc0345c1f17b9377cb017cb9aee3352d659feda9fce14111222aa944dbb492', 'e2d696d915a2cd69f51190b20a4553c4fe4d7c0e8a5a39dc79901a7c5c3939d0', 1),
	(129, 258, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 12, '{"code": "SVC-LAB-CBC", "name": "CBC Test", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 12, "unit_price": 60.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "lab_test", "department_id": 42, "effective_from": "2026-07-18"}', 'db-trigger', 'e2d696d915a2cd69f51190b20a4553c4fe4d7c0e8a5a39dc79901a7c5c3939d0', 'f6f576994896c589ae5ae0fe342c1db09dc858f38108a32586ecfb57ab9724a0', 1),
	(130, 260, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 13, '{"code": "SVC-RAD-MRI-BRN", "name": "MRI Brain with Contrast", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 13, "unit_price": 1500.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "imaging", "department_id": 44, "effective_from": "2026-07-18"}', 'db-trigger', 'f6f576994896c589ae5ae0fe342c1db09dc858f38108a32586ecfb57ab9724a0', 'c02691b95ac4024fe3b95f38dacc87573cd9bd3a31333dfa61912511c714c48c', 1),
	(131, 262, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 14, '{"code": "SVC-RAD-CT-THX", "name": "CT Thorax", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 14, "unit_price": 650.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "imaging", "department_id": 44, "effective_from": "2026-07-18"}', 'db-trigger', 'c02691b95ac4024fe3b95f38dacc87573cd9bd3a31333dfa61912511c714c48c', '9583374edd8b4fe41bc1cac7c8f2d57c7c8c69e5010230219121db8dff95bf57', 1),
	(132, 264, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 15, '{"code": "SVC-RAD-XR-CHST", "name": "Chest X-ray", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 15, "unit_price": 120.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "imaging", "department_id": 44, "effective_from": "2026-07-18"}', 'db-trigger', '9583374edd8b4fe41bc1cac7c8f2d57c7c8c69e5010230219121db8dff95bf57', '6099b8cd2be1d333470559edc4b331817d8ebe2d7da4398542c763167238f436', 1),
	(133, 266, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_billing', 'service_price', 16, '{"code": "SVC-PHYSIO-SESS", "name": "Physiotherapy Session", "currency": "SAR", "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "is_taxable": true, "service_id": 16, "unit_price": 200.00, "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "effective_to": null, "service_type": "physio_session", "department_id": 47, "effective_from": "2026-07-18"}', 'db-trigger', '6099b8cd2be1d333470559edc4b331817d8ebe2d7da4398542c763167238f436', '188b03048c427de937861eb78783115e1710eac9af7c9664aae851742e6587c2', 1),
	(134, 268, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 2, '{"code": "PHY-MAN1", "name": "Manual Therapy 30", "type": "manual_therapy", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "therapy_id": 2, "body_region": "spine", "facility_id": 1, "duration_minutes": 30}', 'db-trigger', '188b03048c427de937861eb78783115e1710eac9af7c9664aae851742e6587c2', 'c6a2800b8e2bb044fed992fea69bea60efa6017c5971be4ce75395791aa46bdc', 1),
	(135, 270, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 3, '{"code": "PHY-ELEC1", "name": "Electrotherapy TENS", "type": "electrotherapy", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "therapy_id": 3, "body_region": "any", "facility_id": 1, "duration_minutes": 20}', 'db-trigger', 'c6a2800b8e2bb044fed992fea69bea60efa6017c5971be4ce75395791aa46bdc', 'b0f6d9e94e496d8b9531d43080c906c00ed4bf579f7e675710cc40bf52a5b219', 1),
	(136, 272, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 4, '{"code": "PHY-EX1", "name": "Therapeutic Exercise Set A", "type": "therapeutic_exercise", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "therapy_id": 4, "body_region": "any", "facility_id": 1, "duration_minutes": 45}', 'db-trigger', 'b0f6d9e94e496d8b9531d43080c906c00ed4bf579f7e675710cc40bf52a5b219', '2aab4b1c5902bddcefc0f92c75011419bf79bb00ce8314a358d45e2ddeea081c', 1),
	(137, 274, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 5, '{"code": "PHY-HYDRO", "name": "Hydrotherapy Session", "type": "hydrotherapy", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "therapy_id": 5, "body_region": "lower_limb", "facility_id": 1, "duration_minutes": 30}', 'db-trigger', '2aab4b1c5902bddcefc0f92c75011419bf79bb00ce8314a358d45e2ddeea081c', '3e17a227d57e0aa58371ff63033a7e57f4af57dc552d87b4c363194423c5b706', 1),
	(138, 276, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 6, '{"code": "PHY-CRY", "name": "Cryotherapy 10", "type": "cryotherapy", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "therapy_id": 6, "body_region": "joint", "facility_id": 1, "duration_minutes": 10}', 'db-trigger', '3e17a227d57e0aa58371ff63033a7e57f4af57dc552d87b4c363194423c5b706', '398485b2b9780b70e3124642485d5506d4b812cd444e84773cfc67107b19ff34', 1),
	(139, 278, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 7, '{"code": "PHY-HEAT", "name": "Heat Therapy 15", "type": "heat_therapy", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "therapy_id": 7, "body_region": "soft_tissue", "facility_id": 1, "duration_minutes": 15}', 'db-trigger', '398485b2b9780b70e3124642485d5506d4b812cd444e84773cfc67107b19ff34', '61e707ad4b19fd69caa5077dc1e4e560a8820f09e9cb0ca273a1fe9f35238000', 1),
	(140, 280, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 8, '{"code": "PHY-US", "name": "Therapeutic Ultrasound", "type": "ultrasound", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "therapy_id": 8, "body_region": "soft_tissue", "facility_id": 1, "duration_minutes": 15}', 'db-trigger', '61e707ad4b19fd69caa5077dc1e4e560a8820f09e9cb0ca273a1fe9f35238000', '99b0f003d2f8f2996836ed02743c801d6f0ec48601da0c210b400346a5a0522e', 1),
	(241, 482, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 4, '{"role_id": 4, "facility_id": 1, "permission_id": 11}', 'db-trigger', '56d090fc57482f52a822b95e269db9bec53550ab2b9cd8c7d14378b5162d9d88', '75150e92650f5e184993e15c419eccbee0211a3bb246cdfdfaef8f9b6c1157bb', 1),
	(141, 282, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 9, '{"code": "PHY-LASER", "name": "Laser Therapy", "type": "laser", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "therapy_id": 9, "body_region": "wound", "facility_id": 1, "duration_minutes": 10}', 'db-trigger', '99b0f003d2f8f2996836ed02743c801d6f0ec48601da0c210b400346a5a0522e', '7397fd1262f8b556eb0fdab62c9ec425c07d3a272684109aaefd68e13ec5a72d', 1),
	(142, 284, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 10, '{"code": "PHY-TAPING", "name": "Kinesio Taping", "type": "taping", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "therapy_id": 10, "body_region": "any", "facility_id": 1, "duration_minutes": 15}', 'db-trigger', '7397fd1262f8b556eb0fdab62c9ec425c07d3a272684109aaefd68e13ec5a72d', '11d4476e62c12ac25355d35174cba866c06040b32d43cf39d569f35b865d162f', 1),
	(143, 286, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_physio', 'therapy_catalog', 11, '{"code": "PHY-NEURO", "name": "Neuro Rehab Session", "type": "neuro_rehab", "equipment": null, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "therapy_id": 11, "body_region": "cns", "facility_id": 1, "duration_minutes": 60}', 'db-trigger', '11d4476e62c12ac25355d35174cba866c06040b32d43cf39d569f35b865d162f', '9565443442c9a1c58648d4b0630e5d21b81510e73734481d517f8997bcedd6bd', 1),
	(144, 288, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Arthroplasty, glenohumeral joint", "notes": null, "cpt_code": "23470", "body_site": null, "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "proc_cat_id": 2, "default_duration_min": 90}', 'db-trigger', '9565443442c9a1c58648d4b0630e5d21b81510e73734481d517f8997bcedd6bd', 'a17d5da1d8b9c507861a73433068ba8bb3cb0cfb98d24ab4e5b967c81cf6bf03', 1),
	(145, 290, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Total hip arthroplasty", "notes": null, "cpt_code": "27130", "body_site": null, "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "proc_cat_id": 3, "default_duration_min": 90}', 'db-trigger', 'a17d5da1d8b9c507861a73433068ba8bb3cb0cfb98d24ab4e5b967c81cf6bf03', 'b78823cc41bde6e15457971d4e6e35bbfd5d59f901751e92a6cc0e9bdfc94dc5', 1),
	(146, 292, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Total knee arthroplasty", "notes": null, "cpt_code": "27447", "body_site": null, "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "proc_cat_id": 4, "default_duration_min": 90}', 'db-trigger', 'b78823cc41bde6e15457971d4e6e35bbfd5d59f901751e92a6cc0e9bdfc94dc5', '017ebd1541bc90b918d7ef0744157981d879531c70cebaf9e8227f3ee90b747a', 1),
	(147, 294, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Coronary artery bypass, single", "notes": null, "cpt_code": "33533", "body_site": null, "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "proc_cat_id": 5, "default_duration_min": 90}', 'db-trigger', '017ebd1541bc90b918d7ef0744157981d879531c70cebaf9e8227f3ee90b747a', 'e3c83071fb6c0b3e58c96f0e98a5edfbab74eeacbca825fe4992d4ff4c7cc9bd', 1),
	(148, 296, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Open cholecystectomy", "notes": null, "cpt_code": "47579", "body_site": null, "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "proc_cat_id": 6, "default_duration_min": 90}', 'db-trigger', 'e3c83071fb6c0b3e58c96f0e98a5edfbab74eeacbca825fe4992d4ff4c7cc9bd', 'e97613ef8d148fda3b86ee737766688e537c8cee1f70932c2dcae48c3b67c77d', 1),
	(149, 298, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Repair of femoral hernia", "notes": null, "cpt_code": "49505", "body_site": null, "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "proc_cat_id": 7, "default_duration_min": 90}', 'db-trigger', 'e97613ef8d148fda3b86ee737766688e537c8cee1f70932c2dcae48c3b67c77d', '982745b5e4a87fa99f03b0c34e380a1c770d2db254e1c12d1b7c0bb26e475168', 1),
	(150, 300, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'procedure_catalog', 1, '{"name": "Total abdominal hysterectomy", "notes": null, "cpt_code": "58150", "body_site": null, "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "proc_cat_id": 8, "default_duration_min": 90}', 'db-trigger', '982745b5e4a87fa99f03b0c34e380a1c770d2db254e1c12d1b7c0bb26e475168', 'faa2e58eda57562c0f00428c646a0ccbeeb8788baa057d8ec0bb89c17c0cf96c', 1),
	(151, 302, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'operating_room', 2, '{"code": "OR-GEN", "name": "General Operating Theatre", "or_id": 2, "status": "available", "is_active": true, "room_type": "general", "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "department_id": 33}', 'db-trigger', 'faa2e58eda57562c0f00428c646a0ccbeeb8788baa057d8ec0bb89c17c0cf96c', '79de1bec91620d53acfeae989c1fe1c7f806de07910e5569d6d73390ac34fada', 1),
	(152, 304, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'operating_room', 3, '{"code": "OR-CARD", "name": "Cardiac Surgery Theatre", "or_id": 3, "status": "available", "is_active": true, "room_type": "cardiac", "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "department_id": 34}', 'db-trigger', '79de1bec91620d53acfeae989c1fe1c7f806de07910e5569d6d73390ac34fada', '3090d76d75161aefc9baa1d633101e7c958c9036be17e67de4786224630219de', 1),
	(153, 306, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'operating_room', 4, '{"code": "OR-ORTHO", "name": "Orthopaedic Surgery Theatre", "or_id": 4, "status": "available", "is_active": true, "room_type": "ortho", "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "department_id": 35}', 'db-trigger', '3090d76d75161aefc9baa1d633101e7c958c9036be17e67de4786224630219de', '13057c211549a66aab97dd87c5b4073f48e337cb6084e4372236c64a64e5b2c8', 1),
	(154, 308, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_surgical', 'operating_room', 5, '{"code": "OR-NEURO", "name": "Neurosurgery Theatre", "or_id": 5, "status": "available", "is_active": true, "room_type": "neuro", "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "department_id": 36}', 'db-trigger', '13057c211549a66aab97dd87c5b4073f48e337cb6084e4372236c64a64e5b2c8', '92506733d288d6de09d4d32d07833f169a83c332b04a05b0d4068bdb7d968442', 1),
	(155, 310, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'modality_suite', 2, '{"code": "RAD-XR", "name": "X-ray Room 1", "modality": "xray", "suite_id": 2, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "department_id": 44}', 'db-trigger', '92506733d288d6de09d4d32d07833f169a83c332b04a05b0d4068bdb7d968442', '6cc4a9a695d2c17936ed1ab53087ee6af1d973451808e9254843df309bd2c100', 1),
	(157, 314, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'modality_suite', 4, '{"code": "RAD-MRI", "name": "MRI Unit 1", "modality": "mri", "suite_id": 4, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "department_id": 44}', 'db-trigger', '3d1f97144195ba4bd562973bbe466a35220d70ba319e077f8595fdbe9ecad012', 'a9d383f48ef828c99290d5f631174c84de0441bee903af87a1dc6797b3b43e97', 1),
	(158, 316, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'modality_suite', 5, '{"code": "RAD-US", "name": "Ultrasound 1", "modality": "us", "suite_id": 5, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "department_id": 44}', 'db-trigger', 'a9d383f48ef828c99290d5f631174c84de0441bee903af87a1dc6797b3b43e97', '2fde876ba3576fa28d53e4896f7895a8c7b8136ab4ab96ce46a93c85a77b9314', 1),
	(159, 318, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'modality_suite', 6, '{"code": "RAD-FL", "name": "Fluoroscopy Room", "modality": "fluoroscopy", "suite_id": 6, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "updated_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "department_id": 44}', 'db-trigger', '2fde876ba3576fa28d53e4896f7895a8c7b8136ab4ab96ce46a93c85a77b9314', 'b5f909994604587eca669283e5c5fbe5f301bc8f22491a6ff5e3640d03ac8afa', 1),
	(160, 320, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'exam_catalog', 2, '{"name": "Chest X-ray", "exam_id": 2, "body_part": "Chest", "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "snomed_code": null, "contrast_used": false, "default_modality": "xray", "duration_minutes": 5}', 'db-trigger', 'b5f909994604587eca669283e5c5fbe5f301bc8f22491a6ff5e3640d03ac8afa', '887c16cfb428cd842e8a3a53cb4d6ef7e35b4b15d0f6523a2f7e641b5466f5d8', 1),
	(161, 322, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'exam_catalog', 3, '{"name": "CT Thorax without contrast", "exam_id": 3, "body_part": "Chest", "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "snomed_code": null, "contrast_used": false, "default_modality": "ct", "duration_minutes": 15}', 'db-trigger', '887c16cfb428cd842e8a3a53cb4d6ef7e35b4b15d0f6523a2f7e641b5466f5d8', '02c355df914c45ad146f7f0b0f61943c356613e6b2aaa0293d40665b12567503', 1),
	(162, 324, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'exam_catalog', 4, '{"name": "CT Brain with contrast", "exam_id": 4, "body_part": "Brain", "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "snomed_code": null, "contrast_used": true, "default_modality": "ct", "duration_minutes": 20}', 'db-trigger', '02c355df914c45ad146f7f0b0f61943c356613e6b2aaa0293d40665b12567503', '48b248d0ee96f05ba2aa7fbf3ada103c8c2d9293b620971240d3c4c4306ad20c', 1),
	(163, 326, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'exam_catalog', 5, '{"name": "MRI Brain with contrast", "exam_id": 5, "body_part": "Brain", "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "snomed_code": null, "contrast_used": true, "default_modality": "mri", "duration_minutes": 45}', 'db-trigger', '48b248d0ee96f05ba2aa7fbf3ada103c8c2d9293b620971240d3c4c4306ad20c', '50a423bd90a26e93de88c5a42bfae8f85b1d42c1d261a2a653accdd9d5b09d94', 1),
	(164, 328, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'exam_catalog', 6, '{"name": "Ultrasound Abdomen", "exam_id": 6, "body_part": "Abdomen", "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "snomed_code": null, "contrast_used": false, "default_modality": "us", "duration_minutes": 15}', 'db-trigger', '50a423bd90a26e93de88c5a42bfae8f85b1d42c1d261a2a653accdd9d5b09d94', '23dcf5ce77005918d9565154019252879a1306bce3869f7635b0a4cd52e5cec5', 1),
	(165, 330, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_rad', 'exam_catalog', 7, '{"name": "DEXA Bone Density", "exam_id": 7, "body_part": "Spine", "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1, "snomed_code": null, "contrast_used": false, "default_modality": "dexa", "duration_minutes": 10}', 'db-trigger', '23dcf5ce77005918d9565154019252879a1306bce3869f7635b0a4cd52e5cec5', '17c998465c9b70d15d8eedb9d0afc833da5eddacc0062818e8d24561336e64e2', 1),
	(166, 332, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 2, '{"name": "WBC Count", "unit": "10^3/uL", "ref_low": 4.0, "test_id": 2, "category": "Hematology", "ref_high": 11.0, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "6690-2", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 60}', 'db-trigger', '17c998465c9b70d15d8eedb9d0afc833da5eddacc0062818e8d24561336e64e2', '28fda7c14d25fde84cf7f659b2a93848c7c23f098a84ec4fccc6cb45c05325f7', 1),
	(167, 334, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 3, '{"name": "Hemoglobin", "unit": "g/dL", "ref_low": 12.0, "test_id": 3, "category": "Hematology", "ref_high": 17.5, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "718-7", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 60}', 'db-trigger', '28fda7c14d25fde84cf7f659b2a93848c7c23f098a84ec4fccc6cb45c05325f7', '452861840b753c28a40aae5a8a1b14620b2bc1edc41600d082d07e1f0f99215e', 1),
	(168, 336, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 4, '{"name": "RBC Count", "unit": "10^6/uL", "ref_low": 4.0, "test_id": 4, "category": "Hematology", "ref_high": 5.9, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "789-8", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 60}', 'db-trigger', '452861840b753c28a40aae5a8a1b14620b2bc1edc41600d082d07e1f0f99215e', '3c11d3df93ba1010ed78e7d6e77ce8e0d471ab6c8690527f8c5609777fab0b4f', 1),
	(169, 338, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 5, '{"name": "Sodium", "unit": "mmol/L", "ref_low": 135, "test_id": 5, "category": "Chemistry", "ref_high": 145, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "2951-2", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 60}', 'db-trigger', '3c11d3df93ba1010ed78e7d6e77ce8e0d471ab6c8690527f8c5609777fab0b4f', '29283fb628859797a4d81ffdd45fc79eb06a74afe929827c224962a0d92803df', 1),
	(170, 340, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 6, '{"name": "Chloride", "unit": "mmol/L", "ref_low": 98, "test_id": 6, "category": "Chemistry", "ref_high": 107, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "2069-3", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 60}', 'db-trigger', '29283fb628859797a4d81ffdd45fc79eb06a74afe929827c224962a0d92803df', 'b5ec338017366b43b744e23528b83b3c48ebf4467a2dfefe4a8796cfa595bfe5', 1),
	(242, 484, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 5, '{"role_id": 5, "facility_id": 1, "permission_id": 12}', 'db-trigger', '75150e92650f5e184993e15c419eccbee0211a3bb246cdfdfaef8f9b6c1157bb', '94d25152f67af85d4367ec28aa2c9c19ad56f1c4d710335e537a816dec49d3b6', 1),
	(171, 342, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 7, '{"name": "Potassium", "unit": "mmol/L", "ref_low": 3.5, "test_id": 7, "category": "Chemistry", "ref_high": 5.0, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "2885-2", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 60}', 'db-trigger', 'b5ec338017366b43b744e23528b83b3c48ebf4467a2dfefe4a8796cfa595bfe5', 'c252469b8c156fe132b9b63477d9f0d1019213fe4678050643ff6544e660da17', 1),
	(172, 344, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 8, '{"name": "Glucose, Random", "unit": "mg/dL", "ref_low": 70, "test_id": 8, "category": "Chemistry", "ref_high": 100, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "2345-7", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 30}', 'db-trigger', 'c252469b8c156fe132b9b63477d9f0d1019213fe4678050643ff6544e660da17', '698bdc843c6f85fe29d06be5104a81d8c2e418f2718263e390c51c1ac93ef146', 1),
	(173, 346, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 9, '{"name": "Urea Nitrogen", "unit": "mg/dL", "ref_low": 7, "test_id": 9, "category": "Chemistry", "ref_high": 20, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "3094-0", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 90}', 'db-trigger', '698bdc843c6f85fe29d06be5104a81d8c2e418f2718263e390c51c1ac93ef146', 'a87ceb91a23a981e09db052acaf4cc00348a580bd383b4f98164885ee181b0ca', 1),
	(174, 348, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 10, '{"name": "Creatinine", "unit": "mg/dL", "ref_low": 0.7, "test_id": 10, "category": "Chemistry", "ref_high": 1.3, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "38483-4", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 90}', 'db-trigger', 'a87ceb91a23a981e09db052acaf4cc00348a580bd383b4f98164885ee181b0ca', '069cf4a5823ba3302baeffcaf105adbadb07f9cec12249c6bcff49e992b088ad', 1),
	(175, 350, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 11, '{"name": "Troponin I, Cardiac", "unit": "ng/mL", "ref_low": 0.0, "test_id": 11, "category": "Chemistry", "ref_high": 0.04, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "33914-3", "facility_id": 1, "specimen_type": "blood", "volume_required": 3.00, "turnaround_minutes": 45}', 'db-trigger', '069cf4a5823ba3302baeffcaf105adbadb07f9cec12249c6bcff49e992b088ad', 'c00eabfe9669f4431969bce3626b165d6fda8f4a01372cbedf25a04f7c964fc0', 1),
	(176, 352, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 12, '{"name": "PT/INR", "unit": "INR", "ref_low": 0.8, "test_id": 12, "category": "Coagulation", "ref_high": 1.2, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "25428-4", "facility_id": 1, "specimen_type": "blood", "volume_required": 2.50, "turnaround_minutes": 60}', 'db-trigger', 'c00eabfe9669f4431969bce3626b165d6fda8f4a01372cbedf25a04f7c964fc0', 'e0fc219f237bbcda377e8dc4905c9f1b5d06c5057fcc7d89cea94625adbc9ef5', 1),
	(177, 354, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 13, '{"name": "Potassium, Urine", "unit": "mmol/d", "ref_low": 25, "test_id": 13, "category": "Urinalysis", "ref_high": 125, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "6298-4", "facility_id": 1, "specimen_type": "urine", "volume_required": 10.00, "turnaround_minutes": 120}', 'db-trigger', 'e0fc219f237bbcda377e8dc4905c9f1b5d06c5057fcc7d89cea94625adbc9ef5', '685c117f59147ec8d5608c6a34df5390cfd37a43e650f2225907a60fdb0165b6', 1),
	(178, 356, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 14, '{"name": "Glucose, Urine", "unit": "mg/dL", "ref_low": 0, "test_id": 14, "category": "Urinalysis", "ref_high": 0, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "5792-7", "facility_id": 1, "specimen_type": "urine", "volume_required": 10.00, "turnaround_minutes": 30}', 'db-trigger', '685c117f59147ec8d5608c6a34df5390cfd37a43e650f2225907a60fdb0165b6', 'aee84195d5765b5011afd50f913e708951861faa63e579a40a18fd7e47b89640', 1),
	(179, 358, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 15, '{"name": "Stool Routine", "unit": " qualitative", "ref_low": null, "test_id": 15, "category": "Microbiology", "ref_high": null, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "11277-5", "facility_id": 1, "specimen_type": "stool", "volume_required": 5.00, "turnaround_minutes": 240}', 'db-trigger', 'aee84195d5765b5011afd50f913e708951861faa63e579a40a18fd7e47b89640', 'c099b23f6e1cc9c6ef0c1cc71f843c169faf42e0aef8e58b17244284aa3f231f', 1),
	(180, 360, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_catalog', 16, '{"name": "Wound Culture & Sensitivity", "unit": "qualitative", "ref_low": null, "test_id": 16, "category": "Microbiology", "ref_high": null, "is_active": true, "created_at": "2026-07-18T21:16:08.615001+03:00", "loinc_code": "14461-8", "facility_id": 1, "specimen_type": "swab", "volume_required": 1.00, "turnaround_minutes": 1440}', 'db-trigger', 'c099b23f6e1cc9c6ef0c1cc71f843c169faf42e0aef8e58b17244284aa3f231f', 'f6052edd3f51abc8cd4bf41b4d655f9c3e77a802344f89787c28c579b0725d9d', 1),
	(181, 362, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel', 2, '{"code": "P-CBC", "name": "Complete Blood Count", "panel_id": 2, "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1}', 'db-trigger', 'f6052edd3f51abc8cd4bf41b4d655f9c3e77a802344f89787c28c579b0725d9d', 'ac2f54e0c95bc56d9a5a14517227e6461c788a3543a273e8c5293a2c0565e3df', 1),
	(182, 364, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel', 3, '{"code": "P-CMP", "name": "Comprehensive Metabolic Panel", "panel_id": 3, "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1}', 'db-trigger', 'ac2f54e0c95bc56d9a5a14517227e6461c788a3543a273e8c5293a2c0565e3df', 'd0d114d68b5e2642b161c731e790dd41772b9da72f3fca9ec16dcdbd238d2fef', 1),
	(183, 366, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel', 4, '{"code": "P-CARD", "name": "Cardiac Panel", "panel_id": 4, "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1}', 'db-trigger', 'd0d114d68b5e2642b161c731e790dd41772b9da72f3fca9ec16dcdbd238d2fef', 'cb815d7c9abccd2de811e34071ec05848697a02e9ddea0d37c22df92ccb86688', 1),
	(184, 368, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel', 5, '{"code": "P-UA", "name": "Urinalysis Panel", "panel_id": 5, "created_at": "2026-07-18T21:16:08.615001+03:00", "facility_id": 1}', 'db-trigger', 'cb815d7c9abccd2de811e34071ec05848697a02e9ddea0d37c22df92ccb86688', 'f612c3a788a7a658d2e7654ad2f546ae1a62e427d94955b5016cdc7e028af250', 1),
	(186, 372, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 3, '{"ppi_id": 3, "test_id": 3, "panel_id": 2, "sort_order": 2, "facility_id": 1}', 'db-trigger', '2efdeaa58a2676d599d0dadebf343686b6bd38e8c3fd94840423acc55dabe865', '0c5ebfb041c07851d07dc72010198f7cf5a0767eae2b84dd55212765482daafd', 1),
	(187, 374, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 4, '{"ppi_id": 4, "test_id": 4, "panel_id": 2, "sort_order": 3, "facility_id": 1}', 'db-trigger', '0c5ebfb041c07851d07dc72010198f7cf5a0767eae2b84dd55212765482daafd', '1f72bd311b1a73552d6ea4c7ce1c4ee6d0f31ddbdd413cfd7c521a20cfb83773', 1),
	(188, 376, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 5, '{"ppi_id": 5, "test_id": 5, "panel_id": 3, "sort_order": 1, "facility_id": 1}', 'db-trigger', '1f72bd311b1a73552d6ea4c7ce1c4ee6d0f31ddbdd413cfd7c521a20cfb83773', '3b05e5425dd2b391401088c084b312b1a60746ea40b4b072d91a0b69ba324b96', 1),
	(189, 378, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 6, '{"ppi_id": 6, "test_id": 6, "panel_id": 3, "sort_order": 2, "facility_id": 1}', 'db-trigger', '3b05e5425dd2b391401088c084b312b1a60746ea40b4b072d91a0b69ba324b96', '3b01daa9e283f8611a4ad6a37f157d6882f2baf0891808eb7273dafd70927832', 1),
	(190, 380, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 7, '{"ppi_id": 7, "test_id": 7, "panel_id": 3, "sort_order": 3, "facility_id": 1}', 'db-trigger', '3b01daa9e283f8611a4ad6a37f157d6882f2baf0891808eb7273dafd70927832', '217a9828ce42aabb9c2c208d0f564074498796a3d6cf8a36e04e44d5b0ad3dec', 1),
	(191, 382, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 8, '{"ppi_id": 8, "test_id": 9, "panel_id": 3, "sort_order": 4, "facility_id": 1}', 'db-trigger', '217a9828ce42aabb9c2c208d0f564074498796a3d6cf8a36e04e44d5b0ad3dec', 'a7e46922945883eb265586a6c03e66e247ee6e7c40ee0774deeb4248b13e78ac', 1),
	(192, 384, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 9, '{"ppi_id": 9, "test_id": 10, "panel_id": 3, "sort_order": 5, "facility_id": 1}', 'db-trigger', 'a7e46922945883eb265586a6c03e66e247ee6e7c40ee0774deeb4248b13e78ac', '515c10db483048a7c785e069b2eb77059102a8481dd34d1d7c15b19968c6819b', 1),
	(193, 386, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 10, '{"ppi_id": 10, "test_id": 8, "panel_id": 3, "sort_order": 6, "facility_id": 1}', 'db-trigger', '515c10db483048a7c785e069b2eb77059102a8481dd34d1d7c15b19968c6819b', 'd4ae7cddb3d0da540b7fb1565e0a9e4a4abd356230ec5d7f48a9b90d7e9939f2', 1),
	(194, 388, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_lab', 'test_panel_item', 11, '{"ppi_id": 11, "test_id": 11, "panel_id": 4, "sort_order": 1, "facility_id": 1}', 'db-trigger', 'd4ae7cddb3d0da540b7fb1565e0a9e4a4abd356230ec5d7f48a9b90d7e9939f2', 'f0374d968a8acbab4bbbc9636a5e64ab69d46ad8bc3c702362bf791792ad6691', 1),
	(195, 390, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 2, '{"code": "1000", "name": "Assets", "is_active": true, "account_id": 2, "facility_id": 1, "is_postable": true, "account_type": "asset", "parent_account_id": null}', 'db-trigger', 'f0374d968a8acbab4bbbc9636a5e64ab69d46ad8bc3c702362bf791792ad6691', '787ba2345a02a39497155c96c4ecb6dae20471d2dbf84fb2190d6d9f3bdf9858', 1),
	(196, 392, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 3, '{"code": "1001", "name": "Cash on Hand", "is_active": true, "account_id": 3, "facility_id": 1, "is_postable": true, "account_type": "cash", "parent_account_id": null}', 'db-trigger', '787ba2345a02a39497155c96c4ecb6dae20471d2dbf84fb2190d6d9f3bdf9858', '7b4c03a9b24139f625c2461ff8088161cebbb4469312bdf756c896c7f3c0e418', 1),
	(197, 394, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 4, '{"code": "1002", "name": "Bank Account", "is_active": true, "account_id": 4, "facility_id": 1, "is_postable": true, "account_type": "bank", "parent_account_id": null}', 'db-trigger', '7b4c03a9b24139f625c2461ff8088161cebbb4469312bdf756c896c7f3c0e418', 'a5b48c5f8ddecee24e807c669cfe1fd0b0b433010a3330129b8399566cc83cc3', 1),
	(198, 396, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 5, '{"code": "1200", "name": "Accounts Receivable", "is_active": true, "account_id": 5, "facility_id": 1, "is_postable": true, "account_type": "asset", "parent_account_id": null}', 'db-trigger', 'a5b48c5f8ddecee24e807c669cfe1fd0b0b433010a3330129b8399566cc83cc3', '9462de1f21e5a2d7f9b8805b02e1a94a5d7afe242b31e5300a385e8e972463eb', 1);
INSERT INTO mcms_core.event_log VALUES
	(199, 398, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 6, '{"code": "1400", "name": "Inventory", "is_active": true, "account_id": 6, "facility_id": 1, "is_postable": true, "account_type": "asset", "parent_account_id": null}', 'db-trigger', '9462de1f21e5a2d7f9b8805b02e1a94a5d7afe242b31e5300a385e8e972463eb', '0d860a8dc3f734583b793c1683eee2575e4ac401d8053ffeffa9ae1b21212d31', 1),
	(200, 400, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 7, '{"code": "2000", "name": "Liabilities", "is_active": true, "account_id": 7, "facility_id": 1, "is_postable": true, "account_type": "liability", "parent_account_id": null}', 'db-trigger', '0d860a8dc3f734583b793c1683eee2575e4ac401d8053ffeffa9ae1b21212d31', '110f3df8be6a4b6ab95ce5132372a83d9cbf0f2da261d7f92d89ba87f5b8d0c8', 1),
	(201, 402, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 8, '{"code": "2100", "name": "Accounts Payable", "is_active": true, "account_id": 8, "facility_id": 1, "is_postable": true, "account_type": "liability", "parent_account_id": null}', 'db-trigger', '110f3df8be6a4b6ab95ce5132372a83d9cbf0f2da261d7f92d89ba87f5b8d0c8', '95893fcb3b605cebb9be2d309feade2c6501b7c24e5a8fc62278c4c777c34cb8', 1),
	(202, 404, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 9, '{"code": "3000", "name": "Equity", "is_active": true, "account_id": 9, "facility_id": 1, "is_postable": true, "account_type": "equity", "parent_account_id": null}', 'db-trigger', '95893fcb3b605cebb9be2d309feade2c6501b7c24e5a8fc62278c4c777c34cb8', '241369b490d18680463fb10af7ee628763159bf52186417138fa1c6520b333a0', 1),
	(203, 406, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 10, '{"code": "4000", "name": "Outpatient Revenue", "is_active": true, "account_id": 10, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', '241369b490d18680463fb10af7ee628763159bf52186417138fa1c6520b333a0', 'd62af910cbbac0558a6dc2a66d4c2b8d3f7961ac1333afca33f77549d14b2a39', 1),
	(204, 408, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 11, '{"code": "4100", "name": "Surgical Revenue", "is_active": true, "account_id": 11, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', 'd62af910cbbac0558a6dc2a66d4c2b8d3f7961ac1333afca33f77549d14b2a39', '392bd2258ef8f4c37f09cd92babd866151e6ba74f3b12172d3d5de42e9d63265', 1),
	(205, 410, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 12, '{"code": "4200", "name": "Lab Revenue", "is_active": true, "account_id": 12, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', '392bd2258ef8f4c37f09cd92babd866151e6ba74f3b12172d3d5de42e9d63265', '0673274c8cc3852ab6cffe471790ad2f2e7f991a1260ee19a9faf15bcc3b379e', 1),
	(206, 412, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 13, '{"code": "4300", "name": "Pharmacy Revenue", "is_active": true, "account_id": 13, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', '0673274c8cc3852ab6cffe471790ad2f2e7f991a1260ee19a9faf15bcc3b379e', 'd9af2be9b2d84e5c68c18097dc715fe730d6b30acb4bed47cc20a2014b4cfb9e', 1),
	(207, 414, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 14, '{"code": "4400", "name": "Imaging Revenue", "is_active": true, "account_id": 14, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', 'd9af2be9b2d84e5c68c18097dc715fe730d6b30acb4bed47cc20a2014b4cfb9e', '633df6d05ea491522109a6d6d234ebb0b868253f5d53b8c3377e68a946a0664d', 1),
	(208, 416, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 15, '{"code": "4500", "name": "ICU Revenue", "is_active": true, "account_id": 15, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', '633df6d05ea491522109a6d6d234ebb0b868253f5d53b8c3377e68a946a0664d', '6ae3ddc112bcca95d03b2499329b0029fdc66fa2040f3db80d3a52cc832a9b12', 1),
	(209, 418, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 16, '{"code": "4600", "name": "ER Revenue", "is_active": true, "account_id": 16, "facility_id": 1, "is_postable": true, "account_type": "revenue", "parent_account_id": null}', 'db-trigger', '6ae3ddc112bcca95d03b2499329b0029fdc66fa2040f3db80d3a52cc832a9b12', '99ed2e6d57eb3cd2d84ecbdd962c5c1c78ac17266e718de098fdbaa1c47f3286', 1),
	(210, 420, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 17, '{"code": "5000", "name": "Cost of Consumables", "is_active": true, "account_id": 17, "facility_id": 1, "is_postable": true, "account_type": "expense", "parent_account_id": null}', 'db-trigger', '99ed2e6d57eb3cd2d84ecbdd962c5c1c78ac17266e718de098fdbaa1c47f3286', '69d2b4ed14575c5f8182d9a5b7700541935e74eabb042e86976aa5a35985fd1a', 1),
	(211, 422, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 18, '{"code": "5100", "name": "Cost of Drugs Sold", "is_active": true, "account_id": 18, "facility_id": 1, "is_postable": true, "account_type": "expense", "parent_account_id": null}', 'db-trigger', '69d2b4ed14575c5f8182d9a5b7700541935e74eabb042e86976aa5a35985fd1a', '84d8c456f256d60ff77bc8dd480db0aa3ae1e3b354530fe2478e8c3aac331205', 1),
	(212, 424, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 19, '{"code": "5200", "name": "Salaries & Wages", "is_active": true, "account_id": 19, "facility_id": 1, "is_postable": true, "account_type": "expense", "parent_account_id": null}', 'db-trigger', '84d8c456f256d60ff77bc8dd480db0aa3ae1e3b354530fe2478e8c3aac331205', '9d95bb6eca16809abf56d5f44ff1a329c19796da3b1a4d9610b632bb8900b4c7', 1),
	(213, 426, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 20, '{"code": "5300", "name": "Utilities Expense", "is_active": true, "account_id": 20, "facility_id": 1, "is_postable": true, "account_type": "expense", "parent_account_id": null}', 'db-trigger', '9d95bb6eca16809abf56d5f44ff1a329c19796da3b1a4d9610b632bb8900b4c7', 'b11d6ebf4aa2ec5b5df09b946fc73b8702fe0317972ab2920c4b2c9c943b41bb', 1),
	(214, 428, '2026-07-18 21:16:08.615001+03', 'create', 'info', NULL, NULL, 'mcms_erp', 'gl_account', 21, '{"code": "5400", "name": "Depreciation", "is_active": true, "account_id": 21, "facility_id": 1, "is_postable": true, "account_type": "expense", "parent_account_id": null}', 'db-trigger', 'b11d6ebf4aa2ec5b5df09b946fc73b8702fe0317972ab2920c4b2c9c943b41bb', '0f1d0eb1685320cb8cefc7b8a95c557b2be2b8294adde9d26d66f41e49df5769', 1),
	(215, 430, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 51, '{"code": "DIAL-GEN", "kind": "clinic", "name": "Dialysis Unit", "is_active": true, "created_at": "2026-07-18T21:16:08.705882+03:00", "updated_at": "2026-07-18T21:16:08.705882+03:00", "facility_id": 1, "head_user_id": null, "department_id": 51, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '0f1d0eb1685320cb8cefc7b8a95c557b2be2b8294adde9d26d66f41e49df5769', '20d3590c13935eb1dc250ef72f64928784ef60a136bbea4d7ca207fe1a3e0764', 1),
	(216, 432, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_hr', 'department', 52, '{"code": "NURS-GEN", "kind": "clinic", "name": "Nursery / Neonatal Unit", "is_active": true, "created_at": "2026-07-18T21:16:08.705882+03:00", "updated_at": "2026-07-18T21:16:08.705882+03:00", "facility_id": 1, "head_user_id": null, "department_id": 52, "location_floor": null, "location_building": null, "parent_department_id": null}', 'db-trigger', '20d3590c13935eb1dc250ef72f64928784ef60a136bbea4d7ca207fe1a3e0764', 'fafb71132b6124c8a07561c8df062a273e7b3825cffff670389119a7a9b24048', 1),
	(217, 434, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 2, '{"code": "lab_rad", "name_ar": "مختبر/أشعة", "name_en": "Laboratory/Radiology", "role_id": 2, "is_active": true, "created_at": "2026-07-18T21:16:08.705882+03:00", "description": "Results & reports entry, DICOM", "facility_id": 1}', 'db-trigger', 'fafb71132b6124c8a07561c8df062a273e7b3825cffff670389119a7a9b24048', '44ffa678439553a1a675fd5ca2b1e04297d95c2f013aa7f6a2541d98097ce7dc', 1),
	(218, 436, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 3, '{"code": "reception", "name_ar": "موظف استقبال", "name_en": "Receptionist", "role_id": 3, "is_active": true, "created_at": "2026-07-18T21:16:08.705882+03:00", "description": "Patient & appointment management, no clinical records", "facility_id": 1}', 'db-trigger', '44ffa678439553a1a675fd5ca2b1e04297d95c2f013aa7f6a2541d98097ce7dc', 'bbe04a2cf106397d50a8febd2d03f30a6791ac11f71b5f7d02863d98835a3b20', 1),
	(219, 438, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 4, '{"code": "pharmacist", "name_ar": "صيدلي", "name_en": "Pharmacist", "role_id": 4, "is_active": true, "created_at": "2026-07-18T21:16:08.705882+03:00", "description": "Medication management, dispensing, interactions", "facility_id": 1}', 'db-trigger', 'bbe04a2cf106397d50a8febd2d03f30a6791ac11f71b5f7d02863d98835a3b20', '8a15aeecaaf031f65e7235fc7860e2775426438dec6b9cd2a65c84aee8206342', 1),
	(220, 440, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 5, '{"code": "nurse", "name_ar": "ممرض/فني", "name_en": "Nurse/Technician", "role_id": 5, "is_active": true, "created_at": "2026-07-18T21:16:08.705882+03:00", "description": "Execute orders, vitals, preliminary results", "facility_id": 1}', 'db-trigger', '8a15aeecaaf031f65e7235fc7860e2775426438dec6b9cd2a65c84aee8206342', 'd21dde1038ea150341ea7376cac343be011e784cf410d615fa3835930906a499', 1),
	(243, 486, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 8, '{"role_id": 8, "facility_id": 1, "permission_id": 13}', 'db-trigger', '94d25152f67af85d4367ec28aa2c9c19ad56f1c4d710335e537a816dec49d3b6', '6c282d0421fdccb23ffdaa223fdba2c32b1c34e72482558c8ca7a57fa169084e', 1),
	(221, 442, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 6, '{"code": "accountant", "name_ar": "محاسب", "name_en": "Accountant", "role_id": 6, "is_active": true, "created_at": "2026-07-18T21:16:08.705882+03:00", "description": "Billing, payments, financial reports", "facility_id": 1}', 'db-trigger', 'd21dde1038ea150341ea7376cac343be011e784cf410d615fa3835930906a499', 'c24a316904f7fff939c6602322ca6c9eb1a21c1a89fbd6e4518b07c53e5cdddb', 1),
	(222, 444, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 7, '{"code": "sysadmin", "name_ar": "مدير النظام", "name_en": "System Administrator", "role_id": 7, "is_active": true, "created_at": "2026-07-18T21:16:08.705882+03:00", "description": "User management, roles, settings, full access", "facility_id": 1}', 'db-trigger', 'c24a316904f7fff939c6602322ca6c9eb1a21c1a89fbd6e4518b07c53e5cdddb', 'f841d86c931656af61513c20fc742209d55b0112660fbb85912d5d06c33639cb', 1),
	(223, 446, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 8, '{"code": "doctor", "name_ar": "طبيب", "name_en": "Doctor", "role_id": 8, "is_active": true, "created_at": "2026-07-18T21:16:08.705882+03:00", "description": "Read/write records, order tests, prescribe", "facility_id": 1}', 'db-trigger', 'f841d86c931656af61513c20fc742209d55b0112660fbb85912d5d06c33639cb', '9a85e5ae7eb4050237bba45047f0776bea433dbb49fe55e0e16491461acd031c', 1),
	(224, 448, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role', 9, '{"code": "store_mgr", "name_ar": "مدير المخزن", "name_en": "Warehouse Manager", "role_id": 9, "is_active": true, "created_at": "2026-07-18T21:16:08.705882+03:00", "description": "Inventory & batch management", "facility_id": 1}', 'db-trigger', '9a85e5ae7eb4050237bba45047f0776bea433dbb49fe55e0e16491461acd031c', '29ac20fe59ee86247c6982ca23aed450a49badcc5cf6173786ed189ed1744a04', 1),
	(225, 450, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 8, '{"code": "appointment.manage", "description": "Book/modify appointments", "facility_id": 1, "permission_id": 8}', 'db-trigger', '29ac20fe59ee86247c6982ca23aed450a49badcc5cf6173786ed189ed1744a04', '6a000850f2b959d1ccaf319634eb87d04a0b3cd13667d3e011778a5fbc143fa7', 1),
	(226, 452, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 9, '{"code": "inventory.manage", "description": "Manage inventory & batches", "facility_id": 1, "permission_id": 9}', 'db-trigger', '6a000850f2b959d1ccaf319634eb87d04a0b3cd13667d3e011778a5fbc143fa7', '475affa1a5ad82a79b0d57d0351a0c96e5b53289e8cc2354b2a6f26d37a23646', 1),
	(227, 454, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 10, '{"code": "emr.write", "description": "Write clinical records / orders / prescriptions", "facility_id": 1, "permission_id": 10}', 'db-trigger', '475affa1a5ad82a79b0d57d0351a0c96e5b53289e8cc2354b2a6f26d37a23646', '16df56e00de30c616f4e07d8bd599e9818608c4183dbd2e6fb1064d01d9aaa9e', 1),
	(228, 456, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 11, '{"code": "pharmacy.dispense", "description": "Dispense medications", "facility_id": 1, "permission_id": 11}', 'db-trigger', '16df56e00de30c616f4e07d8bd599e9818608c4183dbd2e6fb1064d01d9aaa9e', 'bef5e78dcf833ea897ab2058aa676e244c74791352bd78f1fe8fa82bc1f9d143', 1),
	(229, 458, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 12, '{"code": "order.execute", "description": "Execute orders / enter preliminary results", "facility_id": 1, "permission_id": 12}', 'db-trigger', 'bef5e78dcf833ea897ab2058aa676e244c74791352bd78f1fe8fa82bc1f9d143', '0c6fd136ea2ca516f18085c7b7feb57c38d3d53248eaf43f62326ea530ca7174', 1),
	(230, 460, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 13, '{"code": "emr.read", "description": "Read clinical records", "facility_id": 1, "permission_id": 13}', 'db-trigger', '0c6fd136ea2ca516f18085c7b7feb57c38d3d53248eaf43f62326ea530ca7174', '6589250530a9465cf87304eb4312c9624479238efb6c9d2d5f433108ca1a382f', 1),
	(231, 462, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 14, '{"code": "billing.manage", "description": "Create/modify invoices & payments", "facility_id": 1, "permission_id": 14}', 'db-trigger', '6589250530a9465cf87304eb4312c9624479238efb6c9d2d5f433108ca1a382f', '92c353104fa016b37172f982554bce0789f1d2d614830af1a4fa6c1e6e000f5d', 1),
	(232, 464, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 15, '{"code": "patient.read", "description": "View patient demographics", "facility_id": 1, "permission_id": 15}', 'db-trigger', '92c353104fa016b37172f982554bce0789f1d2d614830af1a4fa6c1e6e000f5d', '5805da79bfca4b2b6558072997ccd4208d195ce05c4d1b25598a45639ae0385e', 1),
	(233, 466, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 16, '{"code": "lab_rad.result", "description": "Enter lab/radiology results & reports", "facility_id": 1, "permission_id": 16}', 'db-trigger', '5805da79bfca4b2b6558072997ccd4208d195ce05c4d1b25598a45639ae0385e', '85cd0867be5e4230ec253a88763fde431397fc88980d31baf1c999d91bbbebfc', 1),
	(234, 468, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 17, '{"code": "patient.write", "description": "Create/edit patients", "facility_id": 1, "permission_id": 17}', 'db-trigger', '85cd0867be5e4230ec253a88763fde431397fc88980d31baf1c999d91bbbebfc', 'ba2fb246e841c11971d436114d92e00c7f24968574e72a9a93e6d9e337377dee', 1),
	(235, 470, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 18, '{"code": "admin.all", "description": "Full administrative access", "facility_id": 1, "permission_id": 18}', 'db-trigger', 'ba2fb246e841c11971d436114d92e00c7f24968574e72a9a93e6d9e337377dee', '07a87ba27b50a2499b816dd6b4cc663541c45e0127e6c7f66b1b34ce260ecfb9', 1),
	(236, 472, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 19, '{"code": "billing.read", "description": "View financial reports", "facility_id": 1, "permission_id": 19}', 'db-trigger', '07a87ba27b50a2499b816dd6b4cc663541c45e0127e6c7f66b1b34ce260ecfb9', '1625f8418a9f4cb0e060696b9ebc07ecabcef4be04ae28a33ab19f731e3cea63', 1),
	(237, 474, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 8, '{"role_id": 8, "facility_id": 1, "permission_id": 8}', 'db-trigger', '1625f8418a9f4cb0e060696b9ebc07ecabcef4be04ae28a33ab19f731e3cea63', 'f2d650e63389539672aef07fcfde654b46f82fc8692c42260927fd791cf2c3ef', 1),
	(238, 476, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 3, '{"role_id": 3, "facility_id": 1, "permission_id": 8}', 'db-trigger', 'f2d650e63389539672aef07fcfde654b46f82fc8692c42260927fd791cf2c3ef', '038bf47b574ffe21754efb3a2bd1ff129acf8d4209038a3aca03ff5c78f4df14', 1),
	(239, 478, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 9, '{"role_id": 9, "facility_id": 1, "permission_id": 9}', 'db-trigger', '038bf47b574ffe21754efb3a2bd1ff129acf8d4209038a3aca03ff5c78f4df14', '92843339aaf75402115cb45b79d51245a4b74be3d90b8e702ebad3ff818fd9ba', 1),
	(240, 480, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 8, '{"role_id": 8, "facility_id": 1, "permission_id": 10}', 'db-trigger', '92843339aaf75402115cb45b79d51245a4b74be3d90b8e702ebad3ff818fd9ba', '56d090fc57482f52a822b95e269db9bec53550ab2b9cd8c7d14378b5162d9d88', 1),
	(244, 488, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 7, '{"role_id": 7, "facility_id": 1, "permission_id": 13}', 'db-trigger', '6c282d0421fdccb23ffdaa223fdba2c32b1c34e72482558c8ca7a57fa169084e', '13e089572dbf437a51603ec5fe880399836179c0783b0431355a1ccbc2a59776', 1),
	(245, 490, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 5, '{"role_id": 5, "facility_id": 1, "permission_id": 13}', 'db-trigger', '13e089572dbf437a51603ec5fe880399836179c0783b0431355a1ccbc2a59776', 'b30c1e55b39bf6f809d4247ae19ce1a60e6ea37f23c18b691f355a6d70f6a9f7', 1),
	(246, 492, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 4, '{"role_id": 4, "facility_id": 1, "permission_id": 13}', 'db-trigger', 'b30c1e55b39bf6f809d4247ae19ce1a60e6ea37f23c18b691f355a6d70f6a9f7', 'db09dcd04c10ffcbe97c204303a8c2f70a4b4f9ac27e44152b7f834c8f419d9d', 1),
	(247, 494, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 2, '{"role_id": 2, "facility_id": 1, "permission_id": 13}', 'db-trigger', 'db09dcd04c10ffcbe97c204303a8c2f70a4b4f9ac27e44152b7f834c8f419d9d', '6486647213f4865f179d04f6e1307609d18e75187d03869698b7e1ea74c4dcb0', 1),
	(248, 496, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 6, '{"role_id": 6, "facility_id": 1, "permission_id": 14}', 'db-trigger', '6486647213f4865f179d04f6e1307609d18e75187d03869698b7e1ea74c4dcb0', 'a833b04a9befea224e319009e9c696a280170d6cd1d355fd1d709fdd5cf6fcad', 1),
	(249, 498, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 8, '{"role_id": 8, "facility_id": 1, "permission_id": 15}', 'db-trigger', 'a833b04a9befea224e319009e9c696a280170d6cd1d355fd1d709fdd5cf6fcad', '104c00c12258cbf25c98e60e8a1562b18652f13679c345ff1489bbb039bc2446', 1),
	(250, 500, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 7, '{"role_id": 7, "facility_id": 1, "permission_id": 15}', 'db-trigger', '104c00c12258cbf25c98e60e8a1562b18652f13679c345ff1489bbb039bc2446', 'faff52cd8704c037103431dada1f096c4ddd166a989bb0e3e374fe1ba9f7cdb3', 1),
	(251, 502, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 5, '{"role_id": 5, "facility_id": 1, "permission_id": 15}', 'db-trigger', 'faff52cd8704c037103431dada1f096c4ddd166a989bb0e3e374fe1ba9f7cdb3', 'bf9a9f47547329df6b002866325d353b4a01a1afa955cb1088bcca343492a240', 1),
	(252, 504, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 3, '{"role_id": 3, "facility_id": 1, "permission_id": 15}', 'db-trigger', 'bf9a9f47547329df6b002866325d353b4a01a1afa955cb1088bcca343492a240', '380f2217c8e4ba09f4353e387a05864794e7e9b71e39221b1ef04acde7358ea5', 1),
	(253, 506, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 2, '{"role_id": 2, "facility_id": 1, "permission_id": 16}', 'db-trigger', '380f2217c8e4ba09f4353e387a05864794e7e9b71e39221b1ef04acde7358ea5', '84371593ee95f5ca36a38427b987de67027d0c08848dc6a7022d4e73aa3f2c5d', 1),
	(254, 508, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 3, '{"role_id": 3, "facility_id": 1, "permission_id": 17}', 'db-trigger', '84371593ee95f5ca36a38427b987de67027d0c08848dc6a7022d4e73aa3f2c5d', '150fe544bfe1693c91d045afe2919e156e92d6963bb5f96b125c2f7d7f03c6b4', 1),
	(255, 510, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 7, '{"role_id": 7, "facility_id": 1, "permission_id": 18}', 'db-trigger', '150fe544bfe1693c91d045afe2919e156e92d6963bb5f96b125c2f7d7f03c6b4', '554336c4292d01fc54c18ff09eaf9890aff8412703eb6a0444d4e679fed3e3df', 1),
	(256, 512, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 7, '{"role_id": 7, "facility_id": 1, "permission_id": 19}', 'db-trigger', '554336c4292d01fc54c18ff09eaf9890aff8412703eb6a0444d4e679fed3e3df', '0dead4c59fdb8b08e1e35ab2e199917f804e38676e452f912adf0f42fa0cf8ef', 1),
	(257, 514, '2026-07-18 21:16:08.705882+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 6, '{"role_id": 6, "facility_id": 1, "permission_id": 19}', 'db-trigger', '0dead4c59fdb8b08e1e35ab2e199917f804e38676e452f912adf0f42fa0cf8ef', 'f9904d461a830ad10dfe94cfcc2f370ffa25c2fca03320c8028450f367be58c2', 1),
	(258, 516, '2026-07-18 21:16:08.723487+03', 'create', 'info', NULL, NULL, 'mcms_core', 'permission', 20, '{"code": "hr.read", "description": "Read HR / workforce data", "facility_id": 1, "permission_id": 20}', 'db-trigger', 'f9904d461a830ad10dfe94cfcc2f370ffa25c2fca03320c8028450f367be58c2', '888ebfd8c60dd8e06bbf526fc2710b03c721d60bcbd780312c07e083c4bf1284', 1),
	(259, 518, '2026-07-18 21:16:08.723487+03', 'create', 'info', NULL, NULL, 'mcms_core', 'role_permission', 7, '{"role_id": 7, "facility_id": 1, "permission_id": 20}', 'db-trigger', '888ebfd8c60dd8e06bbf526fc2710b03c721d60bcbd780312c07e083c4bf1284', '9b60059aae9f67b96a787b9af2243bf43a2e03f2aa021397ec627130d2b04265', 1),
	(260, 520, '2026-07-18 21:16:08.772136+03', 'create', 'info', NULL, NULL, 'mcms_core', 'system_flag', 1, '{"flag": "maintenance_mode", "value": "false", "updated_at": "2026-07-18T21:16:08.772136+03:00", "facility_id": 1}', 'db-trigger', '9b60059aae9f67b96a787b9af2243bf43a2e03f2aa021397ec627130d2b04265', '2ff87c0c95022d8a21d8663377fe799248450c6ebe6274547693d0aa72ca6ec6', 1),
	(261, 522, '2026-07-18 21:16:08.772136+03', 'create', 'info', NULL, NULL, 'mcms_core', 'system_flag', 1, '{"flag": "last_schema_sync", "value": "never", "updated_at": "2026-07-18T21:16:08.772136+03:00", "facility_id": 1}', 'db-trigger', '2ff87c0c95022d8a21d8663377fe799248450c6ebe6274547693d0aa72ca6ec6', '210a43e042d7c3abcd1b4f09c980d96c349e259919f0b85dd6ab0052d2f0b0d5', 1),
	(262, 524, '2026-07-18 21:16:08.776368+03', 'create', 'info', NULL, NULL, 'mcms_core', 'party', 1, '{"code": null, "gender": null, "tax_id": null, "party_id": 1, "is_active": true, "blood_type": "unknown", "created_at": "2026-07-18T21:16:08.776368+03:00", "legal_name": null, "party_type": "person", "updated_at": "2026-07-18T21:16:08.776368+03:00", "facility_id": 1, "national_id": null, "display_name": "Test Admin", "date_of_birth": null, "preferred_language": "en"}', 'db-trigger', '210a43e042d7c3abcd1b4f09c980d96c349e259919f0b85dd6ab0052d2f0b0d5', 'b2865ff0511a01c0435fcbe08787a6bf3064ffc9de67a958e490493074230b25', 1),
	(263, 526, '2026-07-18 21:16:08.776368+03', 'create', 'info', NULL, NULL, 'mcms_core', 'party', 2, '{"code": null, "gender": null, "tax_id": null, "party_id": 2, "is_active": true, "blood_type": "unknown", "created_at": "2026-07-18T21:16:08.776368+03:00", "legal_name": null, "party_type": "person", "updated_at": "2026-07-18T21:16:08.776368+03:00", "facility_id": 1, "national_id": null, "display_name": "Test Acc1", "date_of_birth": null, "preferred_language": "en"}', 'db-trigger', 'b2865ff0511a01c0435fcbe08787a6bf3064ffc9de67a958e490493074230b25', 'c056282815fa952c109c683a8b6b8ae6c33764b42821cf18978f7c7dfdfa2dc2', 1),
	(264, 528, '2026-07-18 21:16:08.776368+03', 'create', 'info', NULL, NULL, 'mcms_core', 'app_user', 1, '{"role": "admin", "user_id": 1, "party_id": 1, "username": "admin", "is_active": true, "created_at": "2026-07-18T21:16:08.776368+03:00", "updated_at": "2026-07-18T21:16:08.776368+03:00", "facility_id": null, "locked_until": null, "failed_logins": 0, "last_login_at": null, "password_hash": "!", "specialization": null}', 'db-trigger', 'c056282815fa952c109c683a8b6b8ae6c33764b42821cf18978f7c7dfdfa2dc2', '974a4a84703e7b15b0ce89d722dee721ce4d6c37a1befff621ff6af0da3d3c6b', 1),
	(265, 530, '2026-07-18 21:16:08.776368+03', 'create', 'info', NULL, NULL, 'mcms_core', 'app_user', 2, '{"role": "billing_clerk", "user_id": 2, "party_id": 2, "username": "acc1", "is_active": true, "created_at": "2026-07-18T21:16:08.776368+03:00", "updated_at": "2026-07-18T21:16:08.776368+03:00", "facility_id": null, "locked_until": null, "failed_logins": 0, "last_login_at": null, "password_hash": "!", "specialization": null}', 'db-trigger', '974a4a84703e7b15b0ce89d722dee721ce4d6c37a1befff621ff6af0da3d3c6b', '4b2807d5fb34070a5a932a890bd812d68a934898d274e9a00f34f81c0db5416c', 1),
	(266, 532, '2026-07-18 21:16:08.776368+03', 'create', 'info', NULL, NULL, 'mcms_core', 'user_role_map', 7, '{"role_id": 7, "user_id": 1, "facility_id": 1, "department_id": null}', 'db-trigger', '4b2807d5fb34070a5a932a890bd812d68a934898d274e9a00f34f81c0db5416c', '408b5d7520caa81891a7a57dba3e2532e416e1837c8851c2575affcc5e760866', 1),
	(267, 534, '2026-07-18 21:16:08.776368+03', 'create', 'info', NULL, NULL, 'mcms_core', 'user_role_map', 6, '{"role_id": 6, "user_id": 2, "facility_id": 1, "department_id": null}', 'db-trigger', '408b5d7520caa81891a7a57dba3e2532e416e1837c8851c2575affcc5e760866', 'd26182e13a93637aae7b19db7545d28fb5a031d8a0a0a39855adc162d49176e4', 1),
	(268, 536, '2026-07-18 21:16:08.852335+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_interaction', 1, '{"severity": "moderate", "mechanism": "NSAID + paracetamol", "created_at": "2026-07-18T21:16:08.852335+03:00", "management": "Prefer single agent; monitor for GI bleed if combined", "source_ref": null, "facility_id": 1, "drug_item_id_a": 2, "drug_item_id_b": 3, "interaction_id": 2, "clinical_effect": "Increased risk of GI bleeding and renal impairment with combined frequent use"}', 'db-trigger', 'd26182e13a93637aae7b19db7545d28fb5a031d8a0a0a39855adc162d49176e4', '348c80626b037cd7b617fe98ec50e31ab10b315db24eda44c948406595a77525', 1),
	(269, 538, '2026-07-18 21:16:08.852335+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_interaction', 1, '{"severity": "major", "mechanism": "NSAID + antiplatelet (ASA)", "created_at": "2026-07-18T21:16:08.852335+03:00", "management": "Avoid combination unless specifically indicated; GI prophylaxis if unavoidable", "source_ref": null, "facility_id": 1, "drug_item_id_a": 3, "drug_item_id_b": 4, "interaction_id": 3, "clinical_effect": "Additive inhibition of platelet aggregation -> major bleeding risk"}', 'db-trigger', '348c80626b037cd7b617fe98ec50e31ab10b315db24eda44c948406595a77525', 'df9fdd9eb5db55ebf3b496dfa12c4519b0566e18c6c172bc244c07d1a72d8fa2', 1),
	(270, 540, '2026-07-18 21:16:08.852335+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_interaction', 1, '{"severity": "moderate", "mechanism": "Paracetamol + ASA", "created_at": "2026-07-18T21:16:08.852335+03:00", "management": "Use lowest effective doses; monitor renal function", "source_ref": null, "facility_id": 1, "drug_item_id_a": 2, "drug_item_id_b": 4, "interaction_id": 4, "clinical_effect": "Additive analgesic but increased GI/renal risk at high doses"}', 'db-trigger', 'df9fdd9eb5db55ebf3b496dfa12c4519b0566e18c6c172bc244c07d1a72d8fa2', '90e8efc0632e8afc25087d644100b94c41d0095c6d6f960d52453a3aeb65680b', 1),
	(271, 542, '2026-07-18 21:16:08.852335+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_interaction', 1, '{"severity": "major", "mechanism": "ASA + omeprazole", "created_at": "2026-07-18T21:16:08.852335+03:00", "management": "Co-prescribe PPI (e.g. omeprazole) with long-term ASA", "source_ref": null, "facility_id": 1, "drug_item_id_a": 4, "drug_item_id_b": 10, "interaction_id": 5, "clinical_effect": "ASA irritates gastric mucosa; PPI reduces ulcer risk"}', 'db-trigger', '90e8efc0632e8afc25087d644100b94c41d0095c6d6f960d52453a3aeb65680b', '4395d717b9db04e7ac18815e92eb5d87764f588e3883910260f412602495e23c', 1),
	(272, 544, '2026-07-18 21:16:08.852335+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_interaction', 1, '{"severity": "minor", "mechanism": "Metformin + omeprazole", "created_at": "2026-07-18T21:16:08.852335+03:00", "management": "Generally safe; routine monitoring sufficient", "source_ref": null, "facility_id": 1, "drug_item_id_a": 7, "drug_item_id_b": 10, "interaction_id": 6, "clinical_effect": "Omeprazole may marginally raise metformin levels"}', 'db-trigger', '4395d717b9db04e7ac18815e92eb5d87764f588e3883910260f412602495e23c', 'a5c26fc644814b79a85cd1c189c6b7a6b729fb59de07fde37840f52f60aaccf1', 1),
	(273, 546, '2026-07-18 21:16:08.852335+03', 'create', 'info', NULL, NULL, 'mcms_rx', 'drug_interaction', 1, '{"severity": "minor", "mechanism": "Ibuprofen + omeprazole", "created_at": "2026-07-18T21:16:08.852335+03:00", "management": "Co-prescribe PPI for patients on chronic NSAIDs", "source_ref": null, "facility_id": 1, "drug_item_id_a": 3, "drug_item_id_b": 10, "interaction_id": 7, "clinical_effect": "NSAID ulcers mitigated by PPI"}', 'db-trigger', 'a5c26fc644814b79a85cd1c189c6b7a6b729fb59de07fde37840f52f60aaccf1', '0797b91bb14284127c3ed4de4ba3d424a4930819ce38b3253f6ca0591f4d879e', 1);


ALTER TABLE mcms_core.event_log ENABLE TRIGGER ALL;

--
-- Data for Name: audit_trail; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.audit_trail DISABLE TRIGGER ALL;



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
	(1, 99003, 'data_sharing', true, '2026-07-18 21:16:07.504378+03', NULL, 99, 'Demo consent', 1);


ALTER TABLE mcms_core.consent ENABLE TRIGGER ALL;

--
-- Data for Name: contact; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.contact DISABLE TRIGGER ALL;



ALTER TABLE mcms_core.contact ENABLE TRIGGER ALL;

--
-- Data for Name: identity_provider; Type: TABLE DATA; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.identity_provider DISABLE TRIGGER ALL;

INSERT INTO mcms_core.identity_provider VALUES
	('moh_oidc', 'Ministry of Health OIDC', 'oidc', 'mcms-sp', '{"issuer": "https://id.moh.gov.example", "jwks_uri": "https://id.moh.gov.example/.well-known/jwks.json"}', false, '2026-07-18 21:16:07.69005+03', '2026-07-18 21:16:07.69005+03', 1),
	('nhif_saml', 'NHIF SAML IdP', 'saml', 'mcms-sp', '{"sso_url": "https://id.nhif.gov.example/sso", "entity_id": "https://id.nhif.gov.example"}', false, '2026-07-18 21:16:07.69005+03', '2026-07-18 21:16:07.69005+03', 1);


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
	(1, 'patient', 'Patient', 'مريض', 'Self-service portal access scoped to own record', true, '2026-07-18 21:16:07.504378+03', 1),
	(2, 'lab_rad', 'Laboratory/Radiology', 'مختبر/أشعة', 'Results & reports entry, DICOM', true, '2026-07-18 21:16:08.705882+03', 1),
	(3, 'reception', 'Receptionist', 'موظف استقبال', 'Patient & appointment management, no clinical records', true, '2026-07-18 21:16:08.705882+03', 1),
	(4, 'pharmacist', 'Pharmacist', 'صيدلي', 'Medication management, dispensing, interactions', true, '2026-07-18 21:16:08.705882+03', 1),
	(5, 'nurse', 'Nurse/Technician', 'ممرض/فني', 'Execute orders, vitals, preliminary results', true, '2026-07-18 21:16:08.705882+03', 1),
	(6, 'accountant', 'Accountant', 'محاسب', 'Billing, payments, financial reports', true, '2026-07-18 21:16:08.705882+03', 1),
	(7, 'sysadmin', 'System Administrator', 'مدير النظام', 'User management, roles, settings, full access', true, '2026-07-18 21:16:08.705882+03', 1),
	(8, 'doctor', 'Doctor', 'طبيب', 'Read/write records, order tests, prescribe', true, '2026-07-18 21:16:08.705882+03', 1),
	(9, 'store_mgr', 'Warehouse Manager', 'مدير المخزن', 'Inventory & batch management', true, '2026-07-18 21:16:08.705882+03', 1);


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
	('maintenance_mode', 'false', '2026-07-18 21:16:08.772136+03', 1),
	('last_schema_sync', 'never', '2026-07-18 21:16:08.772136+03', 1);


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



ALTER TABLE mcms_dialysis.station ENABLE TRIGGER ALL;

--
-- Data for Name: session; Type: TABLE DATA; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE mcms_dialysis.session DISABLE TRIGGER ALL;



ALTER TABLE mcms_dialysis.session ENABLE TRIGGER ALL;

--
-- Data for Name: triage; Type: TABLE DATA; Schema: mcms_emergency; Owner: -
--

ALTER TABLE mcms_emergency.triage DISABLE TRIGGER ALL;



ALTER TABLE mcms_emergency.triage ENABLE TRIGGER ALL;

--
-- Data for Name: ed_bed; Type: TABLE DATA; Schema: mcms_emergency; Owner: -
--

ALTER TABLE mcms_emergency.ed_bed DISABLE TRIGGER ALL;



ALTER TABLE mcms_emergency.ed_bed ENABLE TRIGGER ALL;

--
-- Data for Name: resuscitation; Type: TABLE DATA; Schema: mcms_emergency; Owner: -
--

ALTER TABLE mcms_emergency.resuscitation DISABLE TRIGGER ALL;



ALTER TABLE mcms_emergency.resuscitation ENABLE TRIGGER ALL;

--
-- Data for Name: allergy; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.allergy DISABLE TRIGGER ALL;



ALTER TABLE mcms_emr.allergy ENABLE TRIGGER ALL;

--
-- Data for Name: clinical_note; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.clinical_note DISABLE TRIGGER ALL;



ALTER TABLE mcms_emr.clinical_note ENABLE TRIGGER ALL;

--
-- Data for Name: diagnosis; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.diagnosis DISABLE TRIGGER ALL;



ALTER TABLE mcms_emr.diagnosis ENABLE TRIGGER ALL;

--
-- Data for Name: family_history; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.family_history DISABLE TRIGGER ALL;



ALTER TABLE mcms_emr.family_history ENABLE TRIGGER ALL;

--
-- Data for Name: immunization; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.immunization DISABLE TRIGGER ALL;



ALTER TABLE mcms_emr.immunization ENABLE TRIGGER ALL;

--
-- Data for Name: medication_order; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.medication_order DISABLE TRIGGER ALL;



ALTER TABLE mcms_emr.medication_order ENABLE TRIGGER ALL;

--
-- Data for Name: referral; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.referral DISABLE TRIGGER ALL;



ALTER TABLE mcms_emr.referral ENABLE TRIGGER ALL;

--
-- Data for Name: referral_linkage_rule; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.referral_linkage_rule DISABLE TRIGGER ALL;

INSERT INTO mcms_emr.referral_linkage_rule VALUES
	(1, NULL, 'I21.9', 'icd10', 4, 10, 'Acute myocardial infarction requires cardiology review', true, '2026-07-18 21:16:07.715827+03', 2, 1),
	(2, NULL, 'I10', 'icd10', 4, 20, 'Essential hypertension -> cardiology / cardiovascular', true, '2026-07-18 21:16:07.715827+03', 2, 1),
	(3, NULL, 'E78.5', 'icd10', 4, 30, 'Hypercholesterolaemia -> cardiovascular risk clinic', true, '2026-07-18 21:16:07.715827+03', 2, 1),
	(4, NULL, 'C50.9', 'icd10', 12, 10, 'Breast malignancy -> clinical oncology & nuclear medicine', true, '2026-07-18 21:16:07.715827+03', 4, 1),
	(5, NULL, 'C50.9', 'icd10', 1, 20, 'Breast malignancy -> oncology unit', true, '2026-07-18 21:16:07.715827+03', 4, 1),
	(6, NULL, 'E11.9', 'icd10', 2, 10, 'Type 2 diabetes -> general internal medicine', true, '2026-07-18 21:16:07.715827+03', 2, 1),
	(7, NULL, 'J20.9', 'icd10', 5, 10, 'Acute bronchitis -> chest diseases', true, '2026-07-18 21:16:07.715827+03', 2, 1),
	(8, NULL, 'J00', 'icd10', 5, 20, 'Acute nasopharyngitis / URTI -> chest diseases', true, '2026-07-18 21:16:07.715827+03', 2, 1),
	(9, NULL, 'A09', 'icd10', 2, 10, 'Infectious gastroenteritis -> general internal medicine', true, '2026-07-18 21:16:07.715827+03', 2, 1),
	(10, NULL, 'I63.9', 'icd10', 3, 10, 'Cerebral infarction -> neurology & psychiatry', true, '2026-07-18 21:16:07.715827+03', 2, 1),
	(11, NULL, 'I60.9', 'icd10', 3, 10, 'Subarachnoid haemorrhage -> neurology & psychiatry', true, '2026-07-18 21:16:07.715827+03', 2, 1),
	(12, 7, NULL, NULL, 1, 30, 'Suspicious skin lesion -> oncology review', true, '2026-07-18 21:16:07.715827+03', 4, 1),
	(13, 2, NULL, NULL, 4, 5, 'Cross-facility: district internal medicine -> tertiary cardiology', true, '2026-07-18 21:16:07.723494+03', 2, 1);


ALTER TABLE mcms_emr.referral_linkage_rule ENABLE TRIGGER ALL;

--
-- Data for Name: social_history; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.social_history DISABLE TRIGGER ALL;



ALTER TABLE mcms_emr.social_history ENABLE TRIGGER ALL;

--
-- Data for Name: vitals; Type: TABLE DATA; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.vitals DISABLE TRIGGER ALL;



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



ALTER TABLE mcms_erp.supplier ENABLE TRIGGER ALL;

--
-- Data for Name: purchase_order; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.purchase_order DISABLE TRIGGER ALL;



ALTER TABLE mcms_erp.purchase_order ENABLE TRIGGER ALL;

--
-- Data for Name: goods_receipt; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.goods_receipt DISABLE TRIGGER ALL;



ALTER TABLE mcms_erp.goods_receipt ENABLE TRIGGER ALL;

--
-- Data for Name: inventory_item; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.inventory_item DISABLE TRIGGER ALL;



ALTER TABLE mcms_erp.inventory_item ENABLE TRIGGER ALL;

--
-- Data for Name: drug_item; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.drug_item DISABLE TRIGGER ALL;

INSERT INTO mcms_rx.drug_item VALUES
	(2, 'Paracetamol', 'Panadol', 'analgesic', 'tablet', '500 mg', 'tablet', NULL, false, false, NULL, 1000, 5000, true, 0.05, 0.15, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(3, 'Ibuprofen', 'Brufen', 'nsaid', 'tablet', '400 mg', 'tablet', NULL, false, false, NULL, 500, 3000, true, 0.08, 0.20, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(4, 'Acetylsalicylic acid', 'Aspec', 'cardiac', 'tablet', '75 mg', 'tablet', NULL, false, false, NULL, 200, 1000, true, 0.03, 0.10, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(5, 'Amoxicillin', 'Amoxil', 'antibiotic', 'capsule', '500 mg', 'capsule', NULL, false, false, NULL, 300, 2000, true, 0.10, 0.30, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(6, 'Cephalexin', 'Keflex', 'antibiotic', 'capsule', '500 mg', 'capsule', NULL, false, false, NULL, 300, 2000, true, 0.15, 0.40, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(7, 'Metformin', 'Glucophage', 'antidiabetic', 'tablet', '850 mg', 'tablet', NULL, false, false, NULL, 400, 2500, true, 0.06, 0.20, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(8, 'Atorvastatin', 'Lipitor', 'cardiac', 'tablet', '20 mg', 'tablet', NULL, false, false, NULL, 400, 2500, true, 0.20, 0.55, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(9, 'Amlodipine', 'Norvasc', 'antihypertensive', 'tablet', '10 mg', 'tablet', NULL, false, false, NULL, 400, 2500, true, 0.10, 0.30, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(10, 'Omeprazole', 'Prilosec', 'gi', 'capsule', '20 mg', 'capsule', NULL, false, false, NULL, 500, 3000, true, 0.10, 0.35, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(11, 'Salbutamol', 'Ventolin', 'respiratory', 'inhaler', '100 mcg', 'inhaler', NULL, false, false, NULL, 100, 500, true, 1.20, 4.50, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(12, 'Insulin Lispro', 'Humalog', 'antidiabetic', 'vial', '100 u/mL', 'vial', NULL, false, false, NULL, 80, 400, true, 6.50, 15.00, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(13, 'Morphine', 'Morphsul', 'analgesic', 'ampule', '10 mg/mL', 'ampule', NULL, false, false, NULL, 80, 300, true, 1.50, 5.00, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(14, 'Cetirizine', 'Zyrtec', 'antihistamine', 'tablet', '10 mg', 'tablet', NULL, false, false, NULL, 400, 2500, true, 0.05, 0.20, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(15, 'Dextrose 5%', 'D5W', 'iv_fluid', 'bag', '500 mL', 'bag', NULL, false, false, NULL, 100, 600, true, 1.00, 3.50, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1),
	(16, 'Sodium Chloride 0.9%', 'NS', 'iv_fluid', 'bag', '1000 mL', 'bag', NULL, false, false, NULL, 100, 600, true, 1.00, 4.00, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', NULL, 1);


ALTER TABLE mcms_rx.drug_item ENABLE TRIGGER ALL;

--
-- Data for Name: purchase_order_line; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.purchase_order_line DISABLE TRIGGER ALL;



ALTER TABLE mcms_erp.purchase_order_line ENABLE TRIGGER ALL;

--
-- Data for Name: goods_receipt_line; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.goods_receipt_line DISABLE TRIGGER ALL;



ALTER TABLE mcms_erp.goods_receipt_line ENABLE TRIGGER ALL;

--
-- Data for Name: inventory_stock; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.inventory_stock DISABLE TRIGGER ALL;



ALTER TABLE mcms_erp.inventory_stock ENABLE TRIGGER ALL;

--
-- Data for Name: stock_movement; Type: TABLE DATA; Schema: mcms_erp; Owner: -
--

ALTER TABLE mcms_erp.stock_movement DISABLE TRIGGER ALL;



ALTER TABLE mcms_erp.stock_movement ENABLE TRIGGER ALL;

--
-- Data for Name: employee; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.employee DISABLE TRIGGER ALL;



ALTER TABLE mcms_hr.employee ENABLE TRIGGER ALL;

--
-- Data for Name: shift; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.shift DISABLE TRIGGER ALL;



ALTER TABLE mcms_hr.shift ENABLE TRIGGER ALL;

--
-- Data for Name: attendance; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.attendance DISABLE TRIGGER ALL;



ALTER TABLE mcms_hr.attendance ENABLE TRIGGER ALL;

--
-- Data for Name: employee_department; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.employee_department DISABLE TRIGGER ALL;



ALTER TABLE mcms_hr.employee_department ENABLE TRIGGER ALL;

--
-- Data for Name: leave_request; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.leave_request DISABLE TRIGGER ALL;



ALTER TABLE mcms_hr.leave_request ENABLE TRIGGER ALL;

--
-- Data for Name: payroll_period; Type: TABLE DATA; Schema: mcms_hr; Owner: -
--

ALTER TABLE mcms_hr.payroll_period DISABLE TRIGGER ALL;



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



ALTER TABLE mcms_icu.bed ENABLE TRIGGER ALL;

--
-- Data for Name: admission; Type: TABLE DATA; Schema: mcms_icu; Owner: -
--

ALTER TABLE mcms_icu.admission DISABLE TRIGGER ALL;



ALTER TABLE mcms_icu.admission ENABLE TRIGGER ALL;

--
-- Data for Name: bed_stay; Type: TABLE DATA; Schema: mcms_icu; Owner: -
--

ALTER TABLE mcms_icu.bed_stay DISABLE TRIGGER ALL;



ALTER TABLE mcms_icu.bed_stay ENABLE TRIGGER ALL;

--
-- Data for Name: score; Type: TABLE DATA; Schema: mcms_icu; Owner: -
--

ALTER TABLE mcms_icu.score DISABLE TRIGGER ALL;



ALTER TABLE mcms_icu.score ENABLE TRIGGER ALL;

--
-- Data for Name: support_session; Type: TABLE DATA; Schema: mcms_icu; Owner: -
--

ALTER TABLE mcms_icu.support_session DISABLE TRIGGER ALL;



ALTER TABLE mcms_icu.support_session ENABLE TRIGGER ALL;

--
-- Data for Name: vitals_stream; Type: TABLE DATA; Schema: mcms_icu; Owner: -
--

ALTER TABLE mcms_icu.vitals_stream DISABLE TRIGGER ALL;



ALTER TABLE mcms_icu.vitals_stream ENABLE TRIGGER ALL;

--
-- Data for Name: test_panel; Type: TABLE DATA; Schema: mcms_lab; Owner: -
--

ALTER TABLE mcms_lab.test_panel DISABLE TRIGGER ALL;

INSERT INTO mcms_lab.test_panel VALUES
	(2, 'P-CBC', 'Complete Blood Count', '2026-07-18 21:16:08.615001+03', 1),
	(3, 'P-CMP', 'Comprehensive Metabolic Panel', '2026-07-18 21:16:08.615001+03', 1),
	(4, 'P-CARD', 'Cardiac Panel', '2026-07-18 21:16:08.615001+03', 1),
	(5, 'P-UA', 'Urinalysis Panel', '2026-07-18 21:16:08.615001+03', 1);


ALTER TABLE mcms_lab.test_panel ENABLE TRIGGER ALL;

--
-- Data for Name: lab_order; Type: TABLE DATA; Schema: mcms_lab; Owner: -
--

ALTER TABLE mcms_lab.lab_order DISABLE TRIGGER ALL;



ALTER TABLE mcms_lab.lab_order ENABLE TRIGGER ALL;

--
-- Data for Name: sample; Type: TABLE DATA; Schema: mcms_lab; Owner: -
--

ALTER TABLE mcms_lab.sample DISABLE TRIGGER ALL;



ALTER TABLE mcms_lab.sample ENABLE TRIGGER ALL;

--
-- Data for Name: test_catalog; Type: TABLE DATA; Schema: mcms_lab; Owner: -
--

ALTER TABLE mcms_lab.test_catalog DISABLE TRIGGER ALL;

INSERT INTO mcms_lab.test_catalog VALUES
	(2, '6690-2', 'WBC Count', 'Hematology', 'blood', 3.00, '10^3/uL', 4.0, 11.0, 60, true, '2026-07-18 21:16:08.615001+03', 1),
	(3, '718-7', 'Hemoglobin', 'Hematology', 'blood', 3.00, 'g/dL', 12.0, 17.5, 60, true, '2026-07-18 21:16:08.615001+03', 1),
	(4, '789-8', 'RBC Count', 'Hematology', 'blood', 3.00, '10^6/uL', 4.0, 5.9, 60, true, '2026-07-18 21:16:08.615001+03', 1),
	(5, '2951-2', 'Sodium', 'Chemistry', 'blood', 3.00, 'mmol/L', 135, 145, 60, true, '2026-07-18 21:16:08.615001+03', 1),
	(6, '2069-3', 'Chloride', 'Chemistry', 'blood', 3.00, 'mmol/L', 98, 107, 60, true, '2026-07-18 21:16:08.615001+03', 1),
	(7, '2885-2', 'Potassium', 'Chemistry', 'blood', 3.00, 'mmol/L', 3.5, 5.0, 60, true, '2026-07-18 21:16:08.615001+03', 1),
	(8, '2345-7', 'Glucose, Random', 'Chemistry', 'blood', 3.00, 'mg/dL', 70, 100, 30, true, '2026-07-18 21:16:08.615001+03', 1),
	(9, '3094-0', 'Urea Nitrogen', 'Chemistry', 'blood', 3.00, 'mg/dL', 7, 20, 90, true, '2026-07-18 21:16:08.615001+03', 1),
	(10, '38483-4', 'Creatinine', 'Chemistry', 'blood', 3.00, 'mg/dL', 0.7, 1.3, 90, true, '2026-07-18 21:16:08.615001+03', 1),
	(11, '33914-3', 'Troponin I, Cardiac', 'Chemistry', 'blood', 3.00, 'ng/mL', 0.0, 0.04, 45, true, '2026-07-18 21:16:08.615001+03', 1),
	(12, '25428-4', 'PT/INR', 'Coagulation', 'blood', 2.50, 'INR', 0.8, 1.2, 60, true, '2026-07-18 21:16:08.615001+03', 1),
	(13, '6298-4', 'Potassium, Urine', 'Urinalysis', 'urine', 10.00, 'mmol/d', 25, 125, 120, true, '2026-07-18 21:16:08.615001+03', 1),
	(14, '5792-7', 'Glucose, Urine', 'Urinalysis', 'urine', 10.00, 'mg/dL', 0, 0, 30, true, '2026-07-18 21:16:08.615001+03', 1),
	(15, '11277-5', 'Stool Routine', 'Microbiology', 'stool', 5.00, ' qualitative', NULL, NULL, 240, true, '2026-07-18 21:16:08.615001+03', 1),
	(16, '14461-8', 'Wound Culture & Sensitivity', 'Microbiology', 'swab', 1.00, 'qualitative', NULL, NULL, 1440, true, '2026-07-18 21:16:08.615001+03', 1);


ALTER TABLE mcms_lab.test_catalog ENABLE TRIGGER ALL;

--
-- Data for Name: result; Type: TABLE DATA; Schema: mcms_lab; Owner: -
--

ALTER TABLE mcms_lab.result DISABLE TRIGGER ALL;



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



ALTER TABLE mcms_nursery.cot ENABLE TRIGGER ALL;

--
-- Data for Name: neonate_record; Type: TABLE DATA; Schema: mcms_nursery; Owner: -
--

ALTER TABLE mcms_nursery.neonate_record DISABLE TRIGGER ALL;



ALTER TABLE mcms_nursery.neonate_record ENABLE TRIGGER ALL;

--
-- Data for Name: growth_entry; Type: TABLE DATA; Schema: mcms_nursery; Owner: -
--

ALTER TABLE mcms_nursery.growth_entry DISABLE TRIGGER ALL;



ALTER TABLE mcms_nursery.growth_entry ENABLE TRIGGER ALL;

--
-- Data for Name: therapy_catalog; Type: TABLE DATA; Schema: mcms_physio; Owner: -
--

ALTER TABLE mcms_physio.therapy_catalog DISABLE TRIGGER ALL;

INSERT INTO mcms_physio.therapy_catalog VALUES
	(2, 'PHY-MAN1', 'Manual Therapy 30', 'manual_therapy', 'spine', 30, NULL, true, '2026-07-18 21:16:08.615001+03', 1),
	(3, 'PHY-ELEC1', 'Electrotherapy TENS', 'electrotherapy', 'any', 20, NULL, true, '2026-07-18 21:16:08.615001+03', 1),
	(4, 'PHY-EX1', 'Therapeutic Exercise Set A', 'therapeutic_exercise', 'any', 45, NULL, true, '2026-07-18 21:16:08.615001+03', 1),
	(5, 'PHY-HYDRO', 'Hydrotherapy Session', 'hydrotherapy', 'lower_limb', 30, NULL, true, '2026-07-18 21:16:08.615001+03', 1),
	(6, 'PHY-CRY', 'Cryotherapy 10', 'cryotherapy', 'joint', 10, NULL, true, '2026-07-18 21:16:08.615001+03', 1),
	(7, 'PHY-HEAT', 'Heat Therapy 15', 'heat_therapy', 'soft_tissue', 15, NULL, true, '2026-07-18 21:16:08.615001+03', 1),
	(8, 'PHY-US', 'Therapeutic Ultrasound', 'ultrasound', 'soft_tissue', 15, NULL, true, '2026-07-18 21:16:08.615001+03', 1),
	(9, 'PHY-LASER', 'Laser Therapy', 'laser', 'wound', 10, NULL, true, '2026-07-18 21:16:08.615001+03', 1),
	(10, 'PHY-TAPING', 'Kinesio Taping', 'taping', 'any', 15, NULL, true, '2026-07-18 21:16:08.615001+03', 1),
	(11, 'PHY-NEURO', 'Neuro Rehab Session', 'neuro_rehab', 'cns', 60, NULL, true, '2026-07-18 21:16:08.615001+03', 1);


ALTER TABLE mcms_physio.therapy_catalog ENABLE TRIGGER ALL;

--
-- Data for Name: treatment_plan; Type: TABLE DATA; Schema: mcms_physio; Owner: -
--

ALTER TABLE mcms_physio.treatment_plan DISABLE TRIGGER ALL;



ALTER TABLE mcms_physio.treatment_plan ENABLE TRIGGER ALL;

--
-- Data for Name: session; Type: TABLE DATA; Schema: mcms_physio; Owner: -
--

ALTER TABLE mcms_physio.session DISABLE TRIGGER ALL;



ALTER TABLE mcms_physio.session ENABLE TRIGGER ALL;

--
-- Data for Name: exam_catalog; Type: TABLE DATA; Schema: mcms_rad; Owner: -
--

ALTER TABLE mcms_rad.exam_catalog DISABLE TRIGGER ALL;

INSERT INTO mcms_rad.exam_catalog VALUES
	(2, NULL, 'Chest X-ray', 'Chest', 'xray', false, 5, '2026-07-18 21:16:08.615001+03', 1),
	(3, NULL, 'CT Thorax without contrast', 'Chest', 'ct', false, 15, '2026-07-18 21:16:08.615001+03', 1),
	(4, NULL, 'CT Brain with contrast', 'Brain', 'ct', true, 20, '2026-07-18 21:16:08.615001+03', 1),
	(5, NULL, 'MRI Brain with contrast', 'Brain', 'mri', true, 45, '2026-07-18 21:16:08.615001+03', 1),
	(6, NULL, 'Ultrasound Abdomen', 'Abdomen', 'us', false, 15, '2026-07-18 21:16:08.615001+03', 1),
	(7, NULL, 'DEXA Bone Density', 'Spine', 'dexa', false, 10, '2026-07-18 21:16:08.615001+03', 1);


ALTER TABLE mcms_rad.exam_catalog ENABLE TRIGGER ALL;

--
-- Data for Name: modality_suite; Type: TABLE DATA; Schema: mcms_rad; Owner: -
--

ALTER TABLE mcms_rad.modality_suite DISABLE TRIGGER ALL;

INSERT INTO mcms_rad.modality_suite VALUES
	(2, 44, 'RAD-XR', 'X-ray Room 1', 'xray', true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(3, 44, 'RAD-CT', 'CT Suite A', 'ct', true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(4, 44, 'RAD-MRI', 'MRI Unit 1', 'mri', true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(5, 44, 'RAD-US', 'Ultrasound 1', 'us', true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(6, 44, 'RAD-FL', 'Fluoroscopy Room', 'fluoroscopy', true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1);


ALTER TABLE mcms_rad.modality_suite ENABLE TRIGGER ALL;

--
-- Data for Name: study_request; Type: TABLE DATA; Schema: mcms_rad; Owner: -
--

ALTER TABLE mcms_rad.study_request DISABLE TRIGGER ALL;



ALTER TABLE mcms_rad.study_request ENABLE TRIGGER ALL;

--
-- Data for Name: image_instance; Type: TABLE DATA; Schema: mcms_rad; Owner: -
--

ALTER TABLE mcms_rad.image_instance DISABLE TRIGGER ALL;



ALTER TABLE mcms_rad.image_instance ENABLE TRIGGER ALL;

--
-- Data for Name: administration; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.administration DISABLE TRIGGER ALL;



ALTER TABLE mcms_rx.administration ENABLE TRIGGER ALL;

--
-- Data for Name: drug_lot; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.drug_lot DISABLE TRIGGER ALL;



ALTER TABLE mcms_rx.drug_lot ENABLE TRIGGER ALL;

--
-- Data for Name: dispensation; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.dispensation DISABLE TRIGGER ALL;



ALTER TABLE mcms_rx.dispensation ENABLE TRIGGER ALL;

--
-- Data for Name: drug_alternative; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.drug_alternative DISABLE TRIGGER ALL;



ALTER TABLE mcms_rx.drug_alternative ENABLE TRIGGER ALL;

--
-- Data for Name: drug_interaction; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.drug_interaction DISABLE TRIGGER ALL;

INSERT INTO mcms_rx.drug_interaction VALUES
	(2, 2, 3, 'moderate', 'NSAID + paracetamol', 'Increased risk of GI bleeding and renal impairment with combined frequent use', 'Prefer single agent; monitor for GI bleed if combined', NULL, '2026-07-18 21:16:08.852335+03', 1),
	(3, 3, 4, 'major', 'NSAID + antiplatelet (ASA)', 'Additive inhibition of platelet aggregation -> major bleeding risk', 'Avoid combination unless specifically indicated; GI prophylaxis if unavoidable', NULL, '2026-07-18 21:16:08.852335+03', 1),
	(4, 2, 4, 'moderate', 'Paracetamol + ASA', 'Additive analgesic but increased GI/renal risk at high doses', 'Use lowest effective doses; monitor renal function', NULL, '2026-07-18 21:16:08.852335+03', 1),
	(5, 4, 10, 'major', 'ASA + omeprazole', 'ASA irritates gastric mucosa; PPI reduces ulcer risk', 'Co-prescribe PPI (e.g. omeprazole) with long-term ASA', NULL, '2026-07-18 21:16:08.852335+03', 1),
	(6, 7, 10, 'minor', 'Metformin + omeprazole', 'Omeprazole may marginally raise metformin levels', 'Generally safe; routine monitoring sufficient', NULL, '2026-07-18 21:16:08.852335+03', 1),
	(7, 3, 10, 'minor', 'Ibuprofen + omeprazole', 'NSAID ulcers mitigated by PPI', 'Co-prescribe PPI for patients on chronic NSAIDs', NULL, '2026-07-18 21:16:08.852335+03', 1);


ALTER TABLE mcms_rx.drug_interaction ENABLE TRIGGER ALL;

--
-- Data for Name: prescription; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.prescription DISABLE TRIGGER ALL;



ALTER TABLE mcms_rx.prescription ENABLE TRIGGER ALL;

--
-- Data for Name: stock_movement; Type: TABLE DATA; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.stock_movement DISABLE TRIGGER ALL;



ALTER TABLE mcms_rx.stock_movement ENABLE TRIGGER ALL;

--
-- Data for Name: operating_room; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.operating_room DISABLE TRIGGER ALL;

INSERT INTO mcms_surgical.operating_room VALUES
	(2, 33, 'OR-GEN', 'General Operating Theatre', 'general', 'available', true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(3, 34, 'OR-CARD', 'Cardiac Surgery Theatre', 'cardiac', 'available', true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(4, 35, 'OR-ORTHO', 'Orthopaedic Surgery Theatre', 'ortho', 'available', true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1),
	(5, 36, 'OR-NEURO', 'Neurosurgery Theatre', 'neuro', 'available', true, '2026-07-18 21:16:08.615001+03', '2026-07-18 21:16:08.615001+03', 1);


ALTER TABLE mcms_surgical.operating_room ENABLE TRIGGER ALL;

--
-- Data for Name: procedure_catalog; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.procedure_catalog DISABLE TRIGGER ALL;

INSERT INTO mcms_surgical.procedure_catalog VALUES
	(2, '23470', 'Arthroplasty, glenohumeral joint', NULL, 90, NULL, '2026-07-18 21:16:08.615001+03', 1),
	(3, '27130', 'Total hip arthroplasty', NULL, 90, NULL, '2026-07-18 21:16:08.615001+03', 1),
	(4, '27447', 'Total knee arthroplasty', NULL, 90, NULL, '2026-07-18 21:16:08.615001+03', 1),
	(5, '33533', 'Coronary artery bypass, single', NULL, 90, NULL, '2026-07-18 21:16:08.615001+03', 1),
	(6, '47579', 'Open cholecystectomy', NULL, 90, NULL, '2026-07-18 21:16:08.615001+03', 1),
	(7, '49505', 'Repair of femoral hernia', NULL, 90, NULL, '2026-07-18 21:16:08.615001+03', 1),
	(8, '58150', 'Total abdominal hysterectomy', NULL, 90, NULL, '2026-07-18 21:16:08.615001+03', 1);


ALTER TABLE mcms_surgical.procedure_catalog ENABLE TRIGGER ALL;

--
-- Data for Name: surgery; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.surgery DISABLE TRIGGER ALL;



ALTER TABLE mcms_surgical.surgery ENABLE TRIGGER ALL;

--
-- Data for Name: intra_op_vitals; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.intra_op_vitals DISABLE TRIGGER ALL;



ALTER TABLE mcms_surgical.intra_op_vitals ENABLE TRIGGER ALL;

--
-- Data for Name: post_op_note; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.post_op_note DISABLE TRIGGER ALL;



ALTER TABLE mcms_surgical.post_op_note ENABLE TRIGGER ALL;

--
-- Data for Name: pre_op_checklist; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.pre_op_checklist DISABLE TRIGGER ALL;



ALTER TABLE mcms_surgical.pre_op_checklist ENABLE TRIGGER ALL;

--
-- Data for Name: surgical_team; Type: TABLE DATA; Schema: mcms_surgical; Owner: -
--

ALTER TABLE mcms_surgical.surgical_team DISABLE TRIGGER ALL;



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



ALTER TABLE mcms_vital_records.birth_certificate ENABLE TRIGGER ALL;

--
-- Data for Name: death_certificate; Type: TABLE DATA; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE mcms_vital_records.death_certificate DISABLE TRIGGER ALL;



ALTER TABLE mcms_vital_records.death_certificate ENABLE TRIGGER ALL;

--
-- Data for Name: waste_stream; Type: TABLE DATA; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_stream DISABLE TRIGGER ALL;

INSERT INTO mcms_waste.waste_stream OVERRIDING SYSTEM VALUE VALUES
	(1, 'SHARPS', 'Sharps', 'sharps', 'yellow', 'UN3291', 'incineration', 3.5000, 'SAR', true, '2026-07-18 21:16:08.500873+03', '2026-07-18 21:16:08.500873+03'),
	(2, 'INFECT', 'Infectious', 'infectious', 'red', 'UN3291', 'autoclave', 2.2500, 'SAR', true, '2026-07-18 21:16:08.500873+03', '2026-07-18 21:16:08.500873+03'),
	(3, 'PHARMA', 'Pharmaceutical', 'pharmaceutical', 'white', 'UN3249', 'incineration', 4.0000, 'SAR', true, '2026-07-18 21:16:08.500873+03', '2026-07-18 21:16:08.500873+03'),
	(4, 'CYTO', 'Cytotoxic', 'cytotoxic', 'purple', 'UN3249', 'incineration', 6.5000, 'SAR', true, '2026-07-18 21:16:08.500873+03', '2026-07-18 21:16:08.500873+03'),
	(5, 'GEN', 'General (non-hazard)', 'general', 'black', NULL, 'landfill', 0.4000, 'SAR', true, '2026-07-18 21:16:08.500873+03', '2026-07-18 21:16:08.500873+03');


ALTER TABLE mcms_waste.waste_stream ENABLE TRIGGER ALL;

--
-- Data for Name: waste_container; Type: TABLE DATA; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_container DISABLE TRIGGER ALL;

INSERT INTO mcms_waste.waste_container OVERRIDING SYSTEM VALUE VALUES
	(1, 'WC-DEMO-0001', 1, 1, 10.000, 'collected', '2026-07-18 21:16:08.500873+03', '2026-07-18 21:16:08.500873+03');


ALTER TABLE mcms_waste.waste_container ENABLE TRIGGER ALL;

--
-- Data for Name: waste_collection; Type: TABLE DATA; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_collection DISABLE TRIGGER ALL;

INSERT INTO mcms_waste.waste_collection OVERRIDING SYSTEM VALUE VALUES
	(1, 1, 7.500, NULL, '2026-07-18 21:16:08.500873+03', 'Central Waste Store', '2026-07-18 21:16:08.500873+03');


ALTER TABLE mcms_waste.waste_collection ENABLE TRIGGER ALL;

--
-- Data for Name: waste_disposal_manifest; Type: TABLE DATA; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_disposal_manifest DISABLE TRIGGER ALL;

INSERT INTO mcms_waste.waste_disposal_manifest OVERRIDING SYSTEM VALUE VALUES
	(1, 'M202607-000001', 'EnviroClean Ltd', 'incineration', '2026-07-18 21:16:08.500873+03', 7.500, 3.5000, DEFAULT, 'SAR', 'CERT-DEMO-0001', NULL, 'certified', '2026-07-18 21:16:08.500873+03', '2026-07-18 21:16:08.500873+03');


ALTER TABLE mcms_waste.waste_disposal_manifest ENABLE TRIGGER ALL;

--
-- Data for Name: waste_cost_allocation; Type: TABLE DATA; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_cost_allocation DISABLE TRIGGER ALL;

INSERT INTO mcms_waste.waste_cost_allocation OVERRIDING SYSTEM VALUE VALUES
	(1, 1, 1, '2026-07-01', 7.500, 26.2500, 'CC-WASTE', '2026-07-18 21:16:08.500873+03');


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

SELECT pg_catalog.setval('mcms_billing.insurance_claim_claim_id_seq', 1, true);


--
-- Name: invoice_invoice_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.invoice_invoice_id_seq', 1, true);


--
-- Name: invoice_line_line_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.invoice_line_line_id_seq', 1, true);


--
-- Name: payer_payer_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.payer_payer_id_seq', 3, true);


--
-- Name: payment_payment_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.payment_payment_id_seq', 1, true);


--
-- Name: service_price_service_id_seq; Type: SEQUENCE SET; Schema: mcms_billing; Owner: -
--

SELECT pg_catalog.setval('mcms_billing.service_price_service_id_seq', 16, true);


--
-- Name: appointment_appointment_id_seq; Type: SEQUENCE SET; Schema: mcms_clinic; Owner: -
--

SELECT pg_catalog.setval('mcms_clinic.appointment_appointment_id_seq', 1, true);


--
-- Name: consultation_consultation_id_seq; Type: SEQUENCE SET; Schema: mcms_clinic; Owner: -
--

SELECT pg_catalog.setval('mcms_clinic.consultation_consultation_id_seq', 1, true);


--
-- Name: patient_queue_queue_id_seq; Type: SEQUENCE SET; Schema: mcms_clinic; Owner: -
--

SELECT pg_catalog.setval('mcms_clinic.patient_queue_queue_id_seq', 1, true);


--
-- Name: room_room_id_seq; Type: SEQUENCE SET; Schema: mcms_clinic; Owner: -
--

SELECT pg_catalog.setval('mcms_clinic.room_room_id_seq', 1, true);


--
-- Name: access_log_access_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.access_log_access_id_seq', 1, true);


--
-- Name: address_address_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.address_address_id_seq', 1, true);


--
-- Name: app_user_user_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.app_user_user_id_seq', 99, true);


--
-- Name: audit_trail_audit_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.audit_trail_audit_id_seq', 1, true);


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

SELECT pg_catalog.setval('mcms_core.contact_contact_id_seq', 1, true);


--
-- Name: event_log_event_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.event_log_event_id_seq', 273, true);


--
-- Name: event_log_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.event_log_seq', 546, true);


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

SELECT pg_catalog.setval('mcms_core.notification_notification_id_seq', 1, true);


--
-- Name: organization_organization_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.organization_organization_id_seq', 1, true);


--
-- Name: party_party_id_seq; Type: SEQUENCE SET; Schema: mcms_core; Owner: -
--

SELECT pg_catalog.setval('mcms_core.party_party_id_seq', 99003, true);


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

SELECT pg_catalog.setval('mcms_dialysis.session_session_id_seq', 1, true);


--
-- Name: station_station_id_seq; Type: SEQUENCE SET; Schema: mcms_dialysis; Owner: -
--

SELECT pg_catalog.setval('mcms_dialysis.station_station_id_seq', 1, true);


--
-- Name: ed_bed_ed_bed_id_seq; Type: SEQUENCE SET; Schema: mcms_emergency; Owner: -
--

SELECT pg_catalog.setval('mcms_emergency.ed_bed_ed_bed_id_seq', 1, true);


--
-- Name: resuscitation_resus_id_seq; Type: SEQUENCE SET; Schema: mcms_emergency; Owner: -
--

SELECT pg_catalog.setval('mcms_emergency.resuscitation_resus_id_seq', 1, true);


--
-- Name: triage_triage_id_seq; Type: SEQUENCE SET; Schema: mcms_emergency; Owner: -
--

SELECT pg_catalog.setval('mcms_emergency.triage_triage_id_seq', 1, true);


--
-- Name: allergy_allergy_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.allergy_allergy_id_seq', 1, true);


--
-- Name: clinical_note_note_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.clinical_note_note_id_seq', 1, true);


--
-- Name: diagnosis_diagnosis_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.diagnosis_diagnosis_id_seq', 1, true);


--
-- Name: encounter_encounter_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.encounter_encounter_id_seq', 1, true);


--
-- Name: family_history_fh_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.family_history_fh_id_seq', 1, true);


--
-- Name: immunization_immunization_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.immunization_immunization_id_seq', 1, true);


--
-- Name: medication_order_order_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.medication_order_order_id_seq', 1, true);


--
-- Name: patient_patient_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.patient_patient_id_seq', 99001, true);


--
-- Name: referral_linkage_rule_rule_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.referral_linkage_rule_rule_id_seq', 13, true);


--
-- Name: referral_referral_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.referral_referral_id_seq', 1, true);


--
-- Name: social_history_sh_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.social_history_sh_id_seq', 1, true);


--
-- Name: vitals_vital_id_seq; Type: SEQUENCE SET; Schema: mcms_emr; Owner: -
--

SELECT pg_catalog.setval('mcms_emr.vitals_vital_id_seq', 1, true);


--
-- Name: gl_account_account_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.gl_account_account_id_seq', 21, true);


--
-- Name: goods_receipt_grn_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.goods_receipt_grn_id_seq', 1, true);


--
-- Name: goods_receipt_line_line_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.goods_receipt_line_line_id_seq', 1, true);


--
-- Name: inventory_item_item_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.inventory_item_item_id_seq', 1, true);


--
-- Name: inventory_stock_stock_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.inventory_stock_stock_id_seq', 1, true);


--
-- Name: purchase_order_line_line_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.purchase_order_line_line_id_seq', 1, true);


--
-- Name: purchase_order_po_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.purchase_order_po_id_seq', 1, true);


--
-- Name: stock_movement_movement_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.stock_movement_movement_id_seq', 1, true);


--
-- Name: supplier_supplier_id_seq; Type: SEQUENCE SET; Schema: mcms_erp; Owner: -
--

SELECT pg_catalog.setval('mcms_erp.supplier_supplier_id_seq', 1, true);


--
-- Name: attendance_attendance_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.attendance_attendance_id_seq', 1, true);


--
-- Name: department_department_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.department_department_id_seq', 52, true);


--
-- Name: employee_department_emp_dept_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.employee_department_emp_dept_id_seq', 1, true);


--
-- Name: employee_employee_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.employee_employee_id_seq', 1, true);


--
-- Name: leave_request_leave_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.leave_request_leave_id_seq', 1, true);


--
-- Name: payroll_item_item_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.payroll_item_item_id_seq', 1, true);


--
-- Name: payroll_period_period_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.payroll_period_period_id_seq', 1, true);


--
-- Name: shift_shift_id_seq; Type: SEQUENCE SET; Schema: mcms_hr; Owner: -
--

SELECT pg_catalog.setval('mcms_hr.shift_shift_id_seq', 1, true);


--
-- Name: admission_admission_id_seq; Type: SEQUENCE SET; Schema: mcms_icu; Owner: -
--

SELECT pg_catalog.setval('mcms_icu.admission_admission_id_seq', 1, true);


--
-- Name: bed_bed_id_seq; Type: SEQUENCE SET; Schema: mcms_icu; Owner: -
--

SELECT pg_catalog.setval('mcms_icu.bed_bed_id_seq', 1, true);


--
-- Name: bed_stay_stay_id_seq; Type: SEQUENCE SET; Schema: mcms_icu; Owner: -
--

SELECT pg_catalog.setval('mcms_icu.bed_stay_stay_id_seq', 1, true);


--
-- Name: score_score_id_seq; Type: SEQUENCE SET; Schema: mcms_icu; Owner: -
--

SELECT pg_catalog.setval('mcms_icu.score_score_id_seq', 1, true);


--
-- Name: support_session_session_id_seq; Type: SEQUENCE SET; Schema: mcms_icu; Owner: -
--

SELECT pg_catalog.setval('mcms_icu.support_session_session_id_seq', 1, true);


--
-- Name: vitals_stream_stream_id_seq; Type: SEQUENCE SET; Schema: mcms_icu; Owner: -
--

SELECT pg_catalog.setval('mcms_icu.vitals_stream_stream_id_seq', 1, true);


--
-- Name: lab_order_order_id_seq; Type: SEQUENCE SET; Schema: mcms_lab; Owner: -
--

SELECT pg_catalog.setval('mcms_lab.lab_order_order_id_seq', 1, true);


--
-- Name: result_result_id_seq; Type: SEQUENCE SET; Schema: mcms_lab; Owner: -
--

SELECT pg_catalog.setval('mcms_lab.result_result_id_seq', 1, true);


--
-- Name: sample_sample_id_seq; Type: SEQUENCE SET; Schema: mcms_lab; Owner: -
--

SELECT pg_catalog.setval('mcms_lab.sample_sample_id_seq', 1, true);


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

SELECT pg_catalog.setval('mcms_nursery.cot_cot_id_seq', 1, true);


--
-- Name: growth_entry_entry_id_seq; Type: SEQUENCE SET; Schema: mcms_nursery; Owner: -
--

SELECT pg_catalog.setval('mcms_nursery.growth_entry_entry_id_seq', 1, true);


--
-- Name: neonate_record_neonate_id_seq; Type: SEQUENCE SET; Schema: mcms_nursery; Owner: -
--

SELECT pg_catalog.setval('mcms_nursery.neonate_record_neonate_id_seq', 1, true);


--
-- Name: session_session_id_seq; Type: SEQUENCE SET; Schema: mcms_physio; Owner: -
--

SELECT pg_catalog.setval('mcms_physio.session_session_id_seq', 1, true);


--
-- Name: therapy_catalog_therapy_id_seq; Type: SEQUENCE SET; Schema: mcms_physio; Owner: -
--

SELECT pg_catalog.setval('mcms_physio.therapy_catalog_therapy_id_seq', 11, true);


--
-- Name: treatment_plan_plan_id_seq; Type: SEQUENCE SET; Schema: mcms_physio; Owner: -
--

SELECT pg_catalog.setval('mcms_physio.treatment_plan_plan_id_seq', 1, true);


--
-- Name: exam_catalog_exam_id_seq; Type: SEQUENCE SET; Schema: mcms_rad; Owner: -
--

SELECT pg_catalog.setval('mcms_rad.exam_catalog_exam_id_seq', 7, true);


--
-- Name: image_instance_image_id_seq; Type: SEQUENCE SET; Schema: mcms_rad; Owner: -
--

SELECT pg_catalog.setval('mcms_rad.image_instance_image_id_seq', 1, true);


--
-- Name: modality_suite_suite_id_seq; Type: SEQUENCE SET; Schema: mcms_rad; Owner: -
--

SELECT pg_catalog.setval('mcms_rad.modality_suite_suite_id_seq', 6, true);


--
-- Name: study_request_study_id_seq; Type: SEQUENCE SET; Schema: mcms_rad; Owner: -
--

SELECT pg_catalog.setval('mcms_rad.study_request_study_id_seq', 1, true);


--
-- Name: administration_administer_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.administration_administer_id_seq', 1, true);


--
-- Name: dispensation_dispensation_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.dispensation_dispensation_id_seq', 1, true);


--
-- Name: drug_alternative_alternative_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.drug_alternative_alternative_id_seq', 1, true);


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

SELECT pg_catalog.setval('mcms_rx.drug_lot_lot_id_seq', 1, true);


--
-- Name: prescription_prescription_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.prescription_prescription_id_seq', 1, true);


--
-- Name: stock_movement_movement_id_seq; Type: SEQUENCE SET; Schema: mcms_rx; Owner: -
--

SELECT pg_catalog.setval('mcms_rx.stock_movement_movement_id_seq', 1, true);


--
-- Name: intra_op_vitals_iov_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.intra_op_vitals_iov_id_seq', 1, true);


--
-- Name: operating_room_or_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.operating_room_or_id_seq', 5, true);


--
-- Name: post_op_note_pon_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.post_op_note_pon_id_seq', 1, true);


--
-- Name: pre_op_checklist_poc_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.pre_op_checklist_poc_id_seq', 1, true);


--
-- Name: procedure_catalog_proc_cat_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.procedure_catalog_proc_cat_id_seq', 8, true);


--
-- Name: surgery_surgery_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.surgery_surgery_id_seq', 1, true);


--
-- Name: surgical_team_surg_team_id_seq; Type: SEQUENCE SET; Schema: mcms_surgical; Owner: -
--

SELECT pg_catalog.setval('mcms_surgical.surgical_team_surg_team_id_seq', 1, true);


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

SELECT pg_catalog.setval('mcms_vital_records.birth_certificate_birth_cert_id_seq', 1, true);


--
-- Name: birth_reg_no_seq; Type: SEQUENCE SET; Schema: mcms_vital_records; Owner: -
--

SELECT pg_catalog.setval('mcms_vital_records.birth_reg_no_seq', 1, false);


--
-- Name: death_certificate_death_cert_id_seq; Type: SEQUENCE SET; Schema: mcms_vital_records; Owner: -
--

SELECT pg_catalog.setval('mcms_vital_records.death_certificate_death_cert_id_seq', 1, true);


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

SELECT pg_catalog.setval('mcms_waste.waste_collection_collection_id_seq', 1, true);


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

\unrestrict n9Z0Egihg3Hxj5e5bjVZNA9B3bvKlxGGZoW8qKIlg04khwbhVZ0UvKVEluJbDXQ

