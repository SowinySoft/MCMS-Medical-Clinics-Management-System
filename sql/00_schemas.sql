-- ============================================================
-- MCMS — Medical Clinics Management System
-- 00 · Schemas
-- PostgreSQL 18 · schema-grouped ERP/event-driven design
--
-- Schemas:
--   mcms_core    shared foundation + event engine (persons, orgs, users, audit)
--   mcms_emr     electronic medical records
--   mcms_clinic  outpatient clinic ops (appointments, queue, consults)
--   mcms_surgical operating rooms & surgical episodes
--   mcms_emergency ED triage & admissions
--   mcms_rx      pharmacy store & dispensary
--   mcms_lab     laboratory orders / results
--   mcms_rad     radiology studies
--   mcms_icu     ICU beds / vitals streams / scores
--   mcms_physio  physical therapy
--   mcms_hr      human resources
--   mcms_billing services price list / invoices / claims
--   mcms_erp     ERP inventory / procurement / GL
-- ============================================================

BEGIN;

CREATE SCHEMA IF NOT EXISTS mcms_core    AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS mcms_emr     AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS mcms_clinic  AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS mcms_surgical AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS mcms_emergency AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS mcms_rx      AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS mcms_lab     AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS mcms_rad     AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS mcms_icu     AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS mcms_physio  AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS mcms_hr      AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS mcms_billing AUTHORIZATION postgres;
CREATE SCHEMA IF NOT EXISTS mcms_erp     AUTHORIZATION postgres;

-- comment schema metadata for discovery
COMMENT ON SCHEMA mcms_core    IS 'MCMS core: parties, users, addresses, reference data, event/audit engine';
COMMENT ON SCHEMA mcms_emr     IS 'MCMS EMR: patients, encounters, diagnoses, vitals, prescriptions, notes';
COMMENT ON SCHEMA mcms_clinic  IS 'MCMS outpatient clinic: appointments, schedule, queue, consultations';
COMMENT ON SCHEMA mcms_surgical IS 'MCMS surgical: operating rooms, surgery scheduling, intra-op notes';
COMMENT ON SCHEMA mcms_emergency IS 'MCMS emergency: triage, ED admissions, trauma levels';
COMMENT ON SCHEMA mcms_rx     IS 'MCMS pharmacy: drug catalog, inventory, dispensations, purchase orders';
COMMENT ON SCHEMA mcms_lab    IS 'MCMS laboratory: test catalog, samples, results, panels';
COMMENT ON SCHEMA mcms_rad    IS 'MCMS radiology: imaging catalog, studies, modality scheduling, reports';
COMMENT ON SCHEMA mcms_icu    IS 'MCMS ICU: bed boards, vitals streams, ventilator sessions, APACHE/GCS';
COMMENT ON SCHEMA mcms_physio IS 'MCMS physical therapy: catalog, sessions, treatment plans';
COMMENT ON SCHEMA mcms_hr     IS 'MCMS human resources: employees, departments, shifts, attendance';
COMMENT ON SCHEMA mcms_billing IS 'MCMS billing & insurance: price list, invoices, claims, co-payments';
COMMENT ON SCHEMA mcms_erp    IS 'MCMS ERP: inventory, purchase orders, suppliers, stock movements, GL accounts';

COMMIT;
