--
-- PostgreSQL database dump
--

\restrict uDwcM2be06Prp64mKyrnNppyCHTZ5pf8nJY8Ct3yZpvyStE5vNTR4AGNwsbJEyA

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
-- Name: mcms_billing; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_billing;


--
-- Name: SCHEMA mcms_billing; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_billing IS 'MCMS billing & insurance: price list, invoices, claims, co-payments';


--
-- Name: mcms_clinic; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_clinic;


--
-- Name: SCHEMA mcms_clinic; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_clinic IS 'MCMS outpatient clinic: appointments, schedule, queue, consultations';


--
-- Name: mcms_core; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_core;


--
-- Name: SCHEMA mcms_core; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_core IS 'MCMS core: parties, users, addresses, reference data, event/audit engine';


--
-- Name: mcms_dialysis; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_dialysis;


--
-- Name: mcms_emergency; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_emergency;


--
-- Name: SCHEMA mcms_emergency; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_emergency IS 'MCMS emergency: triage, ED admissions, trauma levels';


--
-- Name: mcms_emr; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_emr;


--
-- Name: SCHEMA mcms_emr; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_emr IS 'MCMS EMR: patients, encounters, diagnoses, vitals, prescriptions, notes';


--
-- Name: mcms_erp; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_erp;


--
-- Name: SCHEMA mcms_erp; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_erp IS 'MCMS ERP: inventory, purchase orders, suppliers, stock movements, GL accounts';


--
-- Name: mcms_hr; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_hr;


--
-- Name: SCHEMA mcms_hr; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_hr IS 'MCMS human resources: employees, departments, shifts, attendance';


--
-- Name: mcms_icu; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_icu;


--
-- Name: SCHEMA mcms_icu; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_icu IS 'MCMS ICU: bed boards, vitals streams, ventilator sessions, APACHE/GCS';


--
-- Name: mcms_lab; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_lab;


--
-- Name: SCHEMA mcms_lab; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_lab IS 'MCMS laboratory: test catalog, samples, results, panels';


--
-- Name: mcms_nursery; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_nursery;


--
-- Name: mcms_physio; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_physio;


--
-- Name: SCHEMA mcms_physio; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_physio IS 'MCMS physical therapy: catalog, sessions, treatment plans';


--
-- Name: mcms_rad; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_rad;


--
-- Name: SCHEMA mcms_rad; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_rad IS 'MCMS radiology: imaging catalog, studies, modality scheduling, reports';


--
-- Name: mcms_rx; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_rx;


--
-- Name: SCHEMA mcms_rx; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_rx IS 'MCMS pharmacy: drug catalog, inventory, dispensations, purchase orders';


--
-- Name: mcms_surgical; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_surgical;


--
-- Name: SCHEMA mcms_surgical; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA mcms_surgical IS 'MCMS surgical: operating rooms, surgery scheduling, intra-op notes';


--
-- Name: mcms_telemed; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_telemed;


--
-- Name: mcms_terminology; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_terminology;


--
-- Name: mcms_vital_records; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_vital_records;


--
-- Name: mcms_waste; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA mcms_waste;


--
-- Name: claim_status; Type: TYPE; Schema: mcms_billing; Owner: -
--

CREATE TYPE mcms_billing.claim_status AS ENUM (
    'draft',
    'submitted',
    'processing',
    'approved',
    'partial_paid',
    'rejected',
    'paid'
);


--
-- Name: inv_status; Type: TYPE; Schema: mcms_billing; Owner: -
--

CREATE TYPE mcms_billing.inv_status AS ENUM (
    'draft',
    'issued',
    'partial',
    'paid',
    'disputed',
    'cancelled',
    'refunded'
);


--
-- Name: pay_method; Type: TYPE; Schema: mcms_billing; Owner: -
--

CREATE TYPE mcms_billing.pay_method AS ENUM (
    'cash',
    'card',
    'cheque',
    'bank_transfer',
    'insurance',
    'wallet'
);


--
-- Name: service_type; Type: TYPE; Schema: mcms_billing; Owner: -
--

CREATE TYPE mcms_billing.service_type AS ENUM (
    'consultation',
    'procedure',
    'surgery_or',
    'surgery_surgeon_fee',
    'anaesthesia',
    'lab_test',
    'imaging',
    'pharmacy',
    'icu_bed',
    'emr_document',
    'physio_session',
    'emergency_triage',
    'ambulance',
    'diagnostic_fee',
    'room_charge',
    'maternity',
    'consumable',
    'other'
);


--
-- Name: consult_status; Type: TYPE; Schema: mcms_clinic; Owner: -
--

CREATE TYPE mcms_clinic.consult_status AS ENUM (
    'in_progress',
    'completed',
    'no_show',
    'rescheduled',
    'cancelled'
);


--
-- Name: queue_status; Type: TYPE; Schema: mcms_clinic; Owner: -
--

CREATE TYPE mcms_clinic.queue_status AS ENUM (
    'waiting',
    'called',
    'in_consult',
    'done',
    'diverted'
);


--
-- Name: slot_status; Type: TYPE; Schema: mcms_clinic; Owner: -
--

CREATE TYPE mcms_clinic.slot_status AS ENUM (
    'open',
    'held',
    'booked',
    'blocked',
    'noshow',
    'completed'
);


--
-- Name: blood_type; Type: TYPE; Schema: mcms_core; Owner: -
--

CREATE TYPE mcms_core.blood_type AS ENUM (
    'a+',
    'a-',
    'b+',
    'b-',
    'ab+',
    'ab-',
    'o+',
    'o-',
    'unknown'
);


--
-- Name: consent_type; Type: TYPE; Schema: mcms_core; Owner: -
--

CREATE TYPE mcms_core.consent_type AS ENUM (
    'data_sharing',
    'contact_sms',
    'contact_email',
    'research',
    'psycho_disclosure',
    'identity_federation',
    'data_residency'
);


--
-- Name: event_kind; Type: TYPE; Schema: mcms_core; Owner: -
--

CREATE TYPE mcms_core.event_kind AS ENUM (
    'encounter_opened',
    'encounter_closed',
    'diagnosis_recorded',
    'vitals_taken',
    'prescription_issued',
    'appointment_booked',
    'appointment_cancelled',
    'appointment_completed',
    'consultation_completed',
    'note_added',
    'allergy_added',
    'immunization_given',
    'surgery_scheduled',
    'surgery_started',
    'surgery_completed',
    'surgery_cancelled',
    'triage_recorded',
    'ed_admitted',
    'ed_discharged',
    'resuscitation_initiated',
    'medication_dispensed',
    'medication_administered',
    'low_stock_alert',
    'purchase_order_raised',
    'lab_order_placed',
    'sample_collected',
    'result_verified',
    'result_rejected',
    'study_requested',
    'study_completed',
    'report_finalised',
    'icu_admit',
    'icu_discharge',
    'ventilator_started',
    'ventilator_stopped',
    'deterioration_alert',
    'physio_session_completed',
    'invoice_issued',
    'payment_received',
    'insurance_claim_submitted',
    'employee_hired',
    'employee_offboarded',
    'login',
    'logout',
    'audit_note',
    'appointment_confirmed',
    'appointment_confirmation_sent',
    'notification_sent',
    'create',
    'update',
    'delete',
    'appointment_noshow',
    'abnormal_result_alert',
    'patient_deceased'
);


--
-- Name: event_severity; Type: TYPE; Schema: mcms_core; Owner: -
--

CREATE TYPE mcms_core.event_severity AS ENUM (
    'info',
    'warning',
    'critical'
);


--
-- Name: gender_type; Type: TYPE; Schema: mcms_core; Owner: -
--

CREATE TYPE mcms_core.gender_type AS ENUM (
    'male',
    'female',
    'other',
    'unknown'
);


--
-- Name: notification_channel; Type: TYPE; Schema: mcms_core; Owner: -
--

CREATE TYPE mcms_core.notification_channel AS ENUM (
    'in_app',
    'email',
    'sms',
    'push'
);


--
-- Name: notification_status; Type: TYPE; Schema: mcms_core; Owner: -
--

CREATE TYPE mcms_core.notification_status AS ENUM (
    'pending',
    'sent',
    'delivered',
    'read',
    'failed'
);


--
-- Name: party_type; Type: TYPE; Schema: mcms_core; Owner: -
--

CREATE TYPE mcms_core.party_type AS ENUM (
    'person',
    'organization'
);


--
-- Name: user_role; Type: TYPE; Schema: mcms_core; Owner: -
--

CREATE TYPE mcms_core.user_role AS ENUM (
    'admin',
    'physician',
    'surgeon',
    'nurse',
    'pharmacist',
    'lab_tech',
    'radiologist',
    'physio_therapist',
    'receptionist',
    'billing_clerk',
    'hr_clerk',
    'inventory_clerk',
    'icu_specialist',
    'er_physician',
    'readonly',
    'patient'
);


--
-- Name: dialysis_status; Type: TYPE; Schema: mcms_dialysis; Owner: -
--

CREATE TYPE mcms_dialysis.dialysis_status AS ENUM (
    'scheduled',
    'in_progress',
    'completed',
    'aborted',
    'no_show',
    'cancelled'
);


--
-- Name: modality; Type: TYPE; Schema: mcms_dialysis; Owner: -
--

CREATE TYPE mcms_dialysis.modality AS ENUM (
    'hemodialysis',
    'peritoneal',
    'hemofiltration',
    'hemodiafiltration',
    'crrt'
);


--
-- Name: triage_status; Type: TYPE; Schema: mcms_emergency; Owner: -
--

CREATE TYPE mcms_emergency.triage_status AS ENUM (
    'awaiting',
    'triaged',
    'in_treatment',
    'admitted',
    'transferred',
    'discharged',
    'ama',
    'died'
);


--
-- Name: allergy_severity; Type: TYPE; Schema: mcms_emr; Owner: -
--

CREATE TYPE mcms_emr.allergy_severity AS ENUM (
    'mild',
    'moderate',
    'severe',
    'fatal',
    'unknown'
);


--
-- Name: diagnosis_role; Type: TYPE; Schema: mcms_emr; Owner: -
--

CREATE TYPE mcms_emr.diagnosis_role AS ENUM (
    'admitting',
    'working',
    'differential',
    'primary',
    'secondary'
);


--
-- Name: diagnosis_status; Type: TYPE; Schema: mcms_emr; Owner: -
--

CREATE TYPE mcms_emr.diagnosis_status AS ENUM (
    'active',
    'resolved',
    'recurrent',
    'ruled_out',
    'chronic'
);


--
-- Name: encounter_class; Type: TYPE; Schema: mcms_emr; Owner: -
--

CREATE TYPE mcms_emr.encounter_class AS ENUM (
    'ambulatory',
    'emergency',
    'inpatient',
    'home',
    'virtual',
    'surgical',
    'icu'
);


--
-- Name: encounter_status; Type: TYPE; Schema: mcms_emr; Owner: -
--

CREATE TYPE mcms_emr.encounter_status AS ENUM (
    'planned',
    'arrived',
    'in_progress',
    'on_leave',
    'finished',
    'cancelled',
    'no_show'
);


--
-- Name: med_order_status; Type: TYPE; Schema: mcms_emr; Owner: -
--

CREATE TYPE mcms_emr.med_order_status AS ENUM (
    'active',
    'on_hold',
    'cancelled',
    'completed',
    'expired'
);


--
-- Name: med_route; Type: TYPE; Schema: mcms_emr; Owner: -
--

CREATE TYPE mcms_emr.med_route AS ENUM (
    'po',
    'iv',
    'im',
    'sc',
    'inh',
    'top',
    'pr',
    'sl',
    'gt',
    'ng'
);


--
-- Name: note_type; Type: TYPE; Schema: mcms_emr; Owner: -
--

CREATE TYPE mcms_emr.note_type AS ENUM (
    'progress',
    'history',
    'exam',
    'assessment',
    'plan',
    'nursing',
    'discharge',
    'consult',
    'op_note',
    'ed_note',
    'lab_result'
);


--
-- Name: referral_status; Type: TYPE; Schema: mcms_emr; Owner: -
--

CREATE TYPE mcms_emr.referral_status AS ENUM (
    'draft',
    'pending',
    'accepted',
    'declined',
    'completed',
    'cancelled'
);


--
-- Name: account_type; Type: TYPE; Schema: mcms_erp; Owner: -
--

CREATE TYPE mcms_erp.account_type AS ENUM (
    'asset',
    'liability',
    'equity',
    'revenue',
    'expense',
    'cash',
    'bank',
    'control'
);


--
-- Name: grn_status; Type: TYPE; Schema: mcms_erp; Owner: -
--

CREATE TYPE mcms_erp.grn_status AS ENUM (
    'pending',
    'received',
    'partial',
    'rejected',
    'cancelled'
);


--
-- Name: item_type; Type: TYPE; Schema: mcms_erp; Owner: -
--

CREATE TYPE mcms_erp.item_type AS ENUM (
    'consumable',
    'instrument',
    'capital',
    'medical_supply',
    'office',
    'ppe',
    'utility',
    'other'
);


--
-- Name: move_type; Type: TYPE; Schema: mcms_erp; Owner: -
--

CREATE TYPE mcms_erp.move_type AS ENUM (
    'issue',
    'return',
    'transfer_in',
    'transfer_out',
    'adjust_in',
    'adjust_out',
    'write_off',
    'initial',
    'count_variance'
);


--
-- Name: po_status; Type: TYPE; Schema: mcms_erp; Owner: -
--

CREATE TYPE mcms_erp.po_status AS ENUM (
    'draft',
    'pending_approval',
    'approved',
    'sent',
    'partial_received',
    'received',
    'closed',
    'cancelled'
);


--
-- Name: attendance_status; Type: TYPE; Schema: mcms_hr; Owner: -
--

CREATE TYPE mcms_hr.attendance_status AS ENUM (
    'present',
    'absent',
    'late',
    'leave',
    'overtime'
);


--
-- Name: contract_type; Type: TYPE; Schema: mcms_hr; Owner: -
--

CREATE TYPE mcms_hr.contract_type AS ENUM (
    'permanent',
    'temporary',
    'contract',
    'consultant',
    'locum'
);


--
-- Name: employment_status; Type: TYPE; Schema: mcms_hr; Owner: -
--

CREATE TYPE mcms_hr.employment_status AS ENUM (
    'active',
    'suspended',
    'terminated',
    'retired',
    'on_leave'
);


--
-- Name: leave_status; Type: TYPE; Schema: mcms_hr; Owner: -
--

CREATE TYPE mcms_hr.leave_status AS ENUM (
    'pending',
    'approved',
    'rejected',
    'cancelled'
);


--
-- Name: leave_type; Type: TYPE; Schema: mcms_hr; Owner: -
--

CREATE TYPE mcms_hr.leave_type AS ENUM (
    'annual',
    'sick',
    'maternity',
    'paternity',
    'compassion',
    'unpaid',
    'sabbatical'
);


--
-- Name: pay_status; Type: TYPE; Schema: mcms_hr; Owner: -
--

CREATE TYPE mcms_hr.pay_status AS ENUM (
    'draft',
    'approved',
    'paid',
    'cancelled'
);


--
-- Name: shift_type; Type: TYPE; Schema: mcms_hr; Owner: -
--

CREATE TYPE mcms_hr.shift_type AS ENUM (
    'morning',
    'evening',
    'night',
    'on_call',
    'split'
);


--
-- Name: bed_status; Type: TYPE; Schema: mcms_icu; Owner: -
--

CREATE TYPE mcms_icu.bed_status AS ENUM (
    'available',
    'occupied',
    'cleaning',
    'maintenance',
    'reserved'
);


--
-- Name: icu_status; Type: TYPE; Schema: mcms_icu; Owner: -
--

CREATE TYPE mcms_icu.icu_status AS ENUM (
    'admitted',
    'active',
    'discharged',
    'transferred',
    'expired'
);


--
-- Name: support_kind; Type: TYPE; Schema: mcms_icu; Owner: -
--

CREATE TYPE mcms_icu.support_kind AS ENUM (
    'mechanical_ventilation',
    'non_invasive_ventilation',
    'vasopressor',
    'sedation',
    'rrt',
    'ecmo',
    'hypothermia',
    'prone_position'
);


--
-- Name: order_priority; Type: TYPE; Schema: mcms_lab; Owner: -
--

CREATE TYPE mcms_lab.order_priority AS ENUM (
    'routine',
    'urgent',
    'stat',
    'asap'
);


--
-- Name: result_flag; Type: TYPE; Schema: mcms_lab; Owner: -
--

CREATE TYPE mcms_lab.result_flag AS ENUM (
    'normal',
    'low',
    'high',
    'critical',
    'abnormal',
    'pending'
);


--
-- Name: sample_status; Type: TYPE; Schema: mcms_lab; Owner: -
--

CREATE TYPE mcms_lab.sample_status AS ENUM (
    'collected',
    'in_transit',
    'received',
    'in_progress',
    'resulted',
    'rejected',
    'cancelled'
);


--
-- Name: specimen_type; Type: TYPE; Schema: mcms_lab; Owner: -
--

CREATE TYPE mcms_lab.specimen_type AS ENUM (
    'blood',
    'urine',
    'stool',
    'sputum',
    'tissue',
    'csf',
    'swab',
    'fluid',
    'other'
);


--
-- Name: workup_phase; Type: TYPE; Schema: mcms_lab; Owner: -
--

CREATE TYPE mcms_lab.workup_phase AS ENUM (
    'pending',
    'running',
    'paused',
    'completed',
    'invalid'
);


--
-- Name: cot_status; Type: TYPE; Schema: mcms_nursery; Owner: -
--

CREATE TYPE mcms_nursery.cot_status AS ENUM (
    'available',
    'occupied',
    'cleaning',
    'maintenance'
);


--
-- Name: plan_status; Type: TYPE; Schema: mcms_physio; Owner: -
--

CREATE TYPE mcms_physio.plan_status AS ENUM (
    'active',
    'completed',
    'discontinued',
    'on_hold'
);


--
-- Name: session_status; Type: TYPE; Schema: mcms_physio; Owner: -
--

CREATE TYPE mcms_physio.session_status AS ENUM (
    'scheduled',
    'in_progress',
    'completed',
    'no_show',
    'cancelled'
);


--
-- Name: therapy_type; Type: TYPE; Schema: mcms_physio; Owner: -
--

CREATE TYPE mcms_physio.therapy_type AS ENUM (
    'manual_therapy',
    'electrotherapy',
    'therapeutic_exercise',
    'hydrotherapy',
    'cryotherapy',
    'heat_therapy',
    'ultrasound',
    'traction',
    'laser',
    'taping',
    'rehabilitation',
    'sports_injury',
    'neuro_rehab',
    'post_surgical',
    'ergonomic'
);


--
-- Name: image_type; Type: TYPE; Schema: mcms_rad; Owner: -
--

CREATE TYPE mcms_rad.image_type AS ENUM (
    'dicom',
    'png',
    'jpg',
    'webp'
);


--
-- Name: modality_type; Type: TYPE; Schema: mcms_rad; Owner: -
--

CREATE TYPE mcms_rad.modality_type AS ENUM (
    'xray',
    'fluoroscopy',
    'ct',
    'mri',
    'us',
    'mammography',
    'pet',
    'nm',
    'dexa',
    'angio',
    'other'
);


--
-- Name: order_priority; Type: TYPE; Schema: mcms_rad; Owner: -
--

CREATE TYPE mcms_rad.order_priority AS ENUM (
    'routine',
    'urgent',
    'stat',
    'asap'
);


--
-- Name: study_status; Type: TYPE; Schema: mcms_rad; Owner: -
--

CREATE TYPE mcms_rad.study_status AS ENUM (
    'requested',
    'scheduled',
    'patient_arrived',
    'in_progress',
    'completed',
    'reported',
    'verified',
    'cancelled'
);


--
-- Name: drug_class; Type: TYPE; Schema: mcms_rx; Owner: -
--

CREATE TYPE mcms_rx.drug_class AS ENUM (
    'antibiotic',
    'analgesic',
    'antihypertensive',
    'antidiabetic',
    'anticoagulant',
    'antihistamine',
    'antidepressant',
    'antipsychotic',
    'corticosteroid',
    'nsaid',
    'antacid',
    'diuretic',
    'cardiac',
    'respiratory',
    'gi',
    'cns',
    'hormone',
    'vitamin',
    'vaccine',
    'iv_fluid',
    'controlled',
    'anaesthesia',
    'other'
);


--
-- Name: interaction_severity; Type: TYPE; Schema: mcms_rx; Owner: -
--

CREATE TYPE mcms_rx.interaction_severity AS ENUM (
    'minor',
    'moderate',
    'major',
    'contraindicated'
);


--
-- Name: lot_status; Type: TYPE; Schema: mcms_rx; Owner: -
--

CREATE TYPE mcms_rx.lot_status AS ENUM (
    'on_hand',
    'dispensed',
    'expired',
    'quarantined',
    'returned'
);


--
-- Name: move_type; Type: TYPE; Schema: mcms_rx; Owner: -
--

CREATE TYPE mcms_rx.move_type AS ENUM (
    'reception',
    'dispense',
    'adjust_in',
    'adjust_out',
    'return',
    'expiry',
    'waste',
    'transfer'
);


--
-- Name: route_type; Type: TYPE; Schema: mcms_rx; Owner: -
--

CREATE TYPE mcms_rx.route_type AS ENUM (
    'po',
    'iv',
    'im',
    'sc',
    'inh',
    'top',
    'pr',
    'sl',
    'gt'
);


--
-- Name: or_status; Type: TYPE; Schema: mcms_surgical; Owner: -
--

CREATE TYPE mcms_surgical.or_status AS ENUM (
    'available',
    'busy',
    'cleaning',
    'maintenance',
    'disabled'
);


--
-- Name: surg_status; Type: TYPE; Schema: mcms_surgical; Owner: -
--

CREATE TYPE mcms_surgical.surg_status AS ENUM (
    'scheduled',
    'pre_op',
    'patient_in_or',
    'incision_start',
    'in_progress',
    'closure_start',
    'patient_out_or',
    'recovery',
    'completed',
    'cancelled',
    'on_hold'
);


--
-- Name: team_role; Type: TYPE; Schema: mcms_surgical; Owner: -
--

CREATE TYPE mcms_surgical.team_role AS ENUM (
    'surgeon',
    'first_assist',
    'second_assist',
    'scrub_nurse',
    'circulating_nurse',
    'anaesthetist',
    'anaesthesia_tech',
    'perfussionist',
    'runner'
);


--
-- Name: fn_claim_event(); Type: FUNCTION; Schema: mcms_billing; Owner: -
--

CREATE FUNCTION mcms_billing.fn_claim_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   IF (TG_OP='UPDATE' AND OLD.status <> NEW.status AND NEW.status='submitted') THEN
      PERFORM mcms_core.emit_event('insurance_claim_submitted','info', NULL, NULL,
         'mcms_billing','insurance_claim', NEW.claim_id,
         jsonb_build_object('provider', NEW.insurance_provider,'amount', NEW.billed_amount));
   END IF;
   RETURN NEW;
END$$;


--
-- Name: fn_claim_notify(); Type: FUNCTION; Schema: mcms_billing; Owner: -
--

CREATE FUNCTION mcms_billing.fn_claim_notify() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_party bigint;
BEGIN
  SELECT p.party_id INTO v_party FROM mcms_emr.patient p WHERE p.patient_id = NEW.patient_id;
  PERFORM mcms_core.fn_make_notification(
    'claim_update',
    'Insurance claim ' || NEW.status,
    'Claim #' || NEW.claim_id || ' for invoice #' || NEW.invoice_id || ' is now ' || NEW.status || '.',
    NULL, v_party,
    'mcms_billing', 'insurance_claim', NEW.claim_id);
  RETURN NEW;
END;
$$;


--
-- Name: fn_invoice_event(); Type: FUNCTION; Schema: mcms_billing; Owner: -
--

CREATE FUNCTION mcms_billing.fn_invoice_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   IF (TG_OP='INSERT' AND NEW.status IN ('issued','partial','paid')) THEN
      PERFORM mcms_core.emit_event('invoice_issued','info', NEW.issued_by, v_party,
         'mcms_billing','invoice', NEW.invoice_id,
         jsonb_build_object('invoice_no', NEW.invoice_no, 'total', NEW.total));
   END IF;
   RETURN NEW;
END$$;


--
-- Name: fn_payment_event(); Type: FUNCTION; Schema: mcms_billing; Owner: -
--

CREATE FUNCTION mcms_billing.fn_payment_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   inv mcms_billing.invoice%ROWTYPE;
   paid NUMERIC(14,2);
BEGIN
   SELECT * INTO inv FROM mcms_billing.invoice WHERE invoice_id = NEW.invoice_id;
   SELECT COALESCE(SUM(amount),0) INTO paid FROM mcms_billing.payment WHERE invoice_id = NEW.invoice_id;
   IF inv.total > 0 AND paid >= inv.total AND inv.status <> 'paid' THEN
     UPDATE mcms_billing.invoice SET status='paid', paid_at = now() WHERE invoice_id = NEW.invoice_id;
   END IF;
   PERFORM mcms_core.emit_event('payment_received','info', NEW.received_by, NULL,
      'mcms_billing','payment', NEW.payment_id,
      jsonb_build_object('invoice_id', NEW.invoice_id, 'amount', NEW.amount, 'method', NEW.method::text));
   RETURN NEW;
END$$;


--
-- Name: fn_appointment_reminder(); Type: FUNCTION; Schema: mcms_clinic; Owner: -
--

CREATE FUNCTION mcms_clinic.fn_appointment_reminder() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_party bigint;
BEGIN
  SELECT p.party_id INTO v_party FROM mcms_emr.patient p WHERE p.patient_id = NEW.patient_id;
  PERFORM mcms_core.fn_make_notification(
    'appointment_reminder',
    'Appointment booked',
    'Appointment on ' || to_char(NEW.starts_at, 'YYYY-MM-DD HH24:MI') || ' (' || NEW.status || ').',
    NEW.clinician_user_id, v_party,
    'mcms_clinic', 'appointment', NEW.appointment_id);
  RETURN NEW;
END;
$$;


--
-- Name: fn_appt_event(); Type: FUNCTION; Schema: mcms_clinic; Owner: -
--

CREATE FUNCTION mcms_clinic.fn_appt_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE pid BIGINT;
BEGIN
   SELECT party_id INTO pid FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event(
      CASE WHEN (TG_OP='INSERT') THEN 'appointment_booked'::mcms_core.event_kind
           WHEN (TG_OP='UPDATE' AND NEW.status::text='cancelled') THEN 'appointment_cancelled'::mcms_core.event_kind
           WHEN (TG_OP='UPDATE' AND NEW.status::text='completed') THEN 'appointment_completed'::mcms_core.event_kind
           WHEN (TG_OP='UPDATE' AND NEW.status::text='noshow') THEN 'appointment_noshow'::mcms_core.event_kind
           ELSE NULL END,
      'info', NEW.clinician_user_id, pid,
      'mcms_clinic','appointment', NEW.appointment_id,
      jsonb_build_object('starts_at', NEW.starts_at, 'department_id', NEW.department_id,
                         'status', NEW.status::text)
   );
   RETURN NEW;
END;
$$;


--
-- Name: fn_consult_event(); Type: FUNCTION; Schema: mcms_clinic; Owner: -
--

CREATE FUNCTION mcms_clinic.fn_consult_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   IF (TG_OP='UPDATE' AND OLD.status <> NEW.status AND NEW.status='completed') THEN
      PERFORM mcms_core.emit_event('consultation_completed','info', NEW.clinician_user_id, NULL,
         'mcms_clinic','consultation', NEW.consultation_id,
         jsonb_build_object('duration_minutes', NEW.duration_minutes, 'encounter_id', NEW.encounter_id));
   END IF;
   RETURN NEW;
END$$;


--
-- Name: emit_event(mcms_core.event_kind, mcms_core.event_severity, bigint, bigint, text, text, bigint, jsonb, text); Type: FUNCTION; Schema: mcms_core; Owner: -
--

CREATE FUNCTION mcms_core.emit_event(p_kind mcms_core.event_kind, p_severity mcms_core.event_severity DEFAULT 'info'::mcms_core.event_severity, p_actor_user_id bigint DEFAULT NULL::bigint, p_subject_party_id bigint DEFAULT NULL::bigint, p_source_schema text DEFAULT NULL::text, p_source_table text DEFAULT NULL::text, p_source_id bigint DEFAULT NULL::bigint, p_payload jsonb DEFAULT '{}'::jsonb, p_channel text DEFAULT 'mcms'::text) RETURNS bigint
    LANGUAGE sql
    AS $$
   INSERT INTO mcms_core.event_log
     (kind, severity, actor_user_id, subject_party_id, source_schema, source_table, source_id, payload, channel)
   VALUES (p_kind, p_severity, p_actor_user_id, p_subject_party_id, p_source_schema, p_source_table, p_source_id, p_payload, p_channel)
   RETURNING event_id;
$$;


--
-- Name: fn_event_insert(); Type: FUNCTION; Schema: mcms_core; Owner: -
--

CREATE FUNCTION mcms_core.fn_event_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  ch  TEXT;
  ph  TEXT;
  calc TEXT;
BEGIN
  NEW.seq := nextval('mcms_core.event_log_seq');
  -- previous chain head (highest seq so far)
  SELECT e.hash INTO ph
    FROM mcms_core.event_log e
   ORDER BY e.seq DESC LIMIT 1;
  NEW.prev_hash := ph;
  calc := encode(sha256(convert_to(concat(
      COALESCE(ph, ''), '|',
      NEW.seq, '|',
      NEW.kind::text, '|',
      COALESCE(NEW.source_schema, ''), '|',
      COALESCE(NEW.source_table, ''), '|',
      COALESCE(NEW.source_id::text, ''), '|',
      NEW.payload::text, '|',
      COALESCE(NEW.actor_user_id::text, ''), '|',
      COALESCE(NEW.subject_party_id::text, '')
    ), 'UTF8')), 'hex');
  NEW.hash := calc;
  ch := COALESCE(NEW.channel, 'mcms');
  PERFORM pg_notify(ch, json_build_object(
      'event_id', NEW.event_id, 'seq', NEW.seq, 'kind', NEW.kind::text,
      'subject_party_id', NEW.subject_party_id,
      'source_table', NEW.source_table, 'source_id', NEW.source_id,
      'hash', NEW.hash
   )::text);
  RETURN NEW;
END;
$$;


--
-- Name: fn_generic_audit(); Type: FUNCTION; Schema: mcms_core; Owner: -
--

CREATE FUNCTION mcms_core.fn_generic_audit() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  v_kind   mcms_core.event_kind;
  v_schema text := TG_TABLE_SCHEMA;
  v_table  text := TG_TABLE_NAME;
  v_row    jsonb;
  v_id     bigint := NULL;
  k        text;
BEGIN
  v_kind := CASE TG_OP
    WHEN 'INSERT' THEN 'create'::mcms_core.event_kind
    WHEN 'UPDATE' THEN 'update'::mcms_core.event_kind
    WHEN 'DELETE' THEN 'delete'::mcms_core.event_kind
    ELSE 'audit_note'::mcms_core.event_kind
  END;

  v_row := CASE TG_OP WHEN 'DELETE' THEN to_jsonb(OLD) ELSE to_jsonb(NEW) END;

  -- derive the PK value generically, preferring the real primary key.
  -- Guard every cast: only treat a key as an id when its JSON value is an
  -- integer string, so boolean/text columns (e.g. is_paid) never break the
  -- bigint cast. (A bare to_jsonb(NEW)->>'is_paid' is "false", which is not
  -- a valid bigint and used to abort the whole trigger on tables like
  -- mcms_hr.payroll_item.)
  IF v_row ? 'id' AND v_row->>'id' ~ '^[0-9]+$' THEN
    v_id := (v_row->>'id')::bigint;
  ELSIF v_row ? (v_table || '_id') AND v_row->>(v_table || '_id') ~ '^[0-9]+$' THEN
    v_id := (v_row->>(v_table || '_id'))::bigint;
  ELSE
    FOR k IN SELECT jsonb_object_keys(v_row) LOOP
      IF k LIKE '%_id' AND v_row->>k ~ '^[0-9]+$' THEN
        v_id := (v_row->>k)::bigint;
        EXIT;
      END IF;
    END LOOP;
  END IF;

  -- event_log enforces event_source_pair_chk: (source_schema, source_table,
  -- source_id) must all be NULL or all be non-NULL. For tables whose PK is NOT
  -- a bigint (e.g. identity_provider.provider_code, system_flag.flag are text
  -- keys), v_id stays NULL — so null the schema/table too. The event is still
  -- logged (channel='db-trigger') and streamed; it just isn't tied to a row PK.
  IF v_id IS NULL THEN
    v_schema := NULL;
    v_table  := NULL;
  END IF;

  INSERT INTO mcms_core.event_log
    (seq, occurred_at, kind, severity, source_schema, source_table, source_id, payload, channel)
  VALUES (
    nextval('mcms_core.event_log_seq'),
    now(),
    v_kind,
    'info'::mcms_core.event_severity,
    v_schema,
    v_table,
    v_id,
    v_row,
    'db-trigger'
  );
  RETURN COALESCE(NEW, OLD);
END;
$_$;


--
-- Name: fn_make_notification(text, text, text, bigint, bigint, text, text, bigint); Type: FUNCTION; Schema: mcms_core; Owner: -
--

CREATE FUNCTION mcms_core.fn_make_notification(p_category text, p_subject text, p_body text, p_recipient_user_id bigint, p_recipient_party_id bigint, p_source_schema text, p_source_table text, p_source_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO mcms_core.notification
    (recipient_user_id, recipient_party_id, category, channel, subject, body,
     status, source_schema, source_table, source_id)
  VALUES (p_recipient_user_id, p_recipient_party_id, p_category, 'in_app',
          p_subject, p_body, 'pending', p_source_schema, p_source_table, p_source_id);
  -- WS broadcast is done by trg_notify_after_insert -> fn_notify_broadcast,
  -- so we don't notify here (avoids double delivery).
END;
$$;


--
-- Name: fn_notify_broadcast(); Type: FUNCTION; Schema: mcms_core; Owner: -
--

CREATE FUNCTION mcms_core.fn_notify_broadcast() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM pg_notify('notifications', json_build_object(
    'notification_id', NEW.notification_id, 'category', NEW.category,
    'subject', NEW.subject, 'recipient_user_id', NEW.recipient_user_id,
    'recipient_party_id', NEW.recipient_party_id,
    'source_table', NEW.source_table, 'source_id', NEW.source_id)::text);
  RETURN NEW;
END;
$$;


--
-- Name: fn_touch(); Type: FUNCTION; Schema: mcms_core; Owner: -
--

CREATE FUNCTION mcms_core.fn_touch() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN NEW.updated_at := now(); RETURN NEW; END$$;


--
-- Name: fn_user_facility(text); Type: FUNCTION; Schema: mcms_core; Owner: -
--

CREATE FUNCTION mcms_core.fn_user_facility(p_username text) RETURNS bigint
    LANGUAGE sql STABLE
    AS $$
  SELECT facility_id FROM mcms_core.app_user WHERE username = p_username;
$$;


--
-- Name: verify_event_chain(); Type: FUNCTION; Schema: mcms_core; Owner: -
--

CREATE FUNCTION mcms_core.verify_event_chain() RETURNS TABLE(broken_at bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
  r RECORD;
  prev TEXT := NULL;
  calc TEXT;
BEGIN
  FOR r IN SELECT event_id, seq, kind, source_schema, source_table, source_id,
                  payload, actor_user_id, subject_party_id, prev_hash, hash
             FROM mcms_core.event_log ORDER BY seq LOOP
    calc := encode(sha256(convert_to(concat(
        COALESCE(prev, ''), '|',
        r.seq, '|', r.kind::text, '|',
        COALESCE(r.source_schema, ''), '|',
        COALESCE(r.source_table, ''), '|',
        COALESCE(r.source_id::text, ''), '|',
        r.payload::text, '|',
        COALESCE(r.actor_user_id::text, ''), '|',
        COALESCE(r.subject_party_id::text, '')
      ), 'UTF8')), 'hex');
    IF calc <> r.hash OR prev IS DISTINCT FROM r.prev_hash THEN
      broken_at := r.seq; RETURN NEXT;
    END IF;
    prev := r.hash;
  END LOOP;
END;
$$;


--
-- Name: fn_resus_event(); Type: FUNCTION; Schema: mcms_emergency; Owner: -
--

CREATE FUNCTION mcms_emergency.fn_resus_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event('resuscitation_initiated','critical', NEW.team_leader_id, v_party,
      'mcms_emergency','resuscitation', NEW.resus_id,
      jsonb_build_object('code_type', NEW.code_type, 'code_initiated_at', NEW.code_initiated_at));
   RETURN NEW;
END$$;


--
-- Name: fn_triage_event(); Type: FUNCTION; Schema: mcms_emergency; Owner: -
--

CREATE FUNCTION mcms_emergency.fn_triage_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   IF (TG_OP='INSERT') THEN
      PERFORM mcms_core.emit_event('triage_recorded','info', NEW.triage_nurse_user_id, v_party,
         'mcms_emergency','triage', NEW.triage_id,
         jsonb_build_object('ed_visit_no', NEW.ed_visit_no,'esi_level', NEW.esi_level,
                            'trauma_alert', NEW.trauma_alert));
      IF NEW.trauma_alert THEN
         PERFORM mcms_core.emit_event('ed_admitted','warning', NULL, v_party,
            'mcms_emergency','triage', NEW.triage_id,
            jsonb_build_object('esi_level', NEW.esi_level,'trauma', true));
      END IF;
   ELSIF (TG_OP='UPDATE' AND OLD.status <> NEW.status AND NEW.status='discharged') THEN
      PERFORM mcms_core.emit_event('ed_discharged','info', NULL, v_party,
         'mcms_emergency','triage', NEW.triage_id,
         jsonb_build_object('disposition', NEW.disposition));
   END IF;
   RETURN NEW;
END$$;


--
-- Name: fn_diag_event(); Type: FUNCTION; Schema: mcms_emr; Owner: -
--

CREATE FUNCTION mcms_emr.fn_diag_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE v_pid BIGINT;
BEGIN
   SELECT p.party_id INTO v_pid
     FROM mcms_emr.patient p WHERE p.patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event(
      'diagnosis_recorded','info', NEW.recorded_by, v_pid,
      'mcms_emr','diagnosis', NEW.diagnosis_id,
      jsonb_build_object('code', NEW.condition_code,'desc', NEW.condition_desc,
                         'role', NEW.role::text,'status', NEW.status::text));
   RETURN NEW;
END$$;


--
-- Name: fn_encounter_event(); Type: FUNCTION; Schema: mcms_emr; Owner: -
--

CREATE FUNCTION mcms_emr.fn_encounter_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   v_party BIGINT;
   v_mrn TEXT;
   v_uid BIGINT;
BEGIN
   SELECT p.party_id, p.mrn INTO v_party, v_mrn
     FROM mcms_emr.patient p WHERE p.patient_id = NEW.patient_id;
   SELECT a.party_id INTO v_uid FROM mcms_core.app_user a WHERE a.user_id = NEW.attending_user_id;
   IF (TG_OP = 'INSERT') THEN
      PERFORM mcms_core.emit_event(
         'encounter_opened','info', NEW.attending_user_id, v_party,
         'mcms_emr','encounter', NEW.encounter_id,
         jsonb_build_object('mrn', v_mrn, 'class', NEW.class::text, 'reason', NEW.reason_for_visit)
      );
   ELSIF (TG_OP = 'UPDATE' AND OLD.status <> NEW.status) THEN
      IF NEW.status = 'finished' THEN
        PERFORM mcms_core.emit_event('encounter_closed','info', NEW.attending_user_id, v_party,
            'mcms_emr','encounter', NEW.encounter_id,
            jsonb_build_object('mrn', v_mrn, 'class', NEW.class::text));
      END IF;
   END IF;
   RETURN NEW;
END$$;


--
-- Name: fn_med_order_event(); Type: FUNCTION; Schema: mcms_emr; Owner: -
--

CREATE FUNCTION mcms_emr.fn_med_order_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event(
      'prescription_issued','info', NEW.prescriber_user_id, v_party,
      'mcms_emr','medication_order', NEW.order_id,
      jsonb_build_object('drug_name', NEW.drug_name, 'dose', NEW.dose,
                         'route', NEW.route::text, 'frequency', NEW.frequency));
   RETURN NEW;
END$$;


--
-- Name: fn_grn_line_insert(); Type: FUNCTION; Schema: mcms_erp; Owner: -
--

CREATE FUNCTION mcms_erp.fn_grn_line_insert() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   inv   mcms_erp.inventory_item%ROWTYPE;
   stock mcms_erp.inventory_stock%ROWTYPE;
   po_line mcms_erp.purchase_order_line%ROWTYPE;
   cnt INT;
   newlot BIGINT;
   pid BIGINT;
BEGIN
   IF NEW.item_id IS NOT NULL THEN
      -- Insert into inventory_stock if not exists, or increment qty.
      SELECT * INTO stock FROM mcms_erp.inventory_stock WHERE item_id = NEW.item_id AND department_id = (
         SELECT COALESCE(to_department_id, from_department_id) FROM mcms_erp.goods_receipt g, mcms_erp.purchase_order p
         WHERE g.grn_id = NEW.grn_id AND (g.po_id = p.po_id)
         LIMIT 1);
      -- Determine the receiving department; default: link via PO that requested by user's primary dept
      PERFORM mcms_erp.upsert_stock(NEW.item_id, NEW.qty_received, NULL);
   ELSIF NEW.drug_item_id IS NOT NULL THEN
      INSERT INTO mcms_rx.drug_lot (drug_item_id, lot_number, received_qty, on_hand_qty, expires_on, supplier_party_id, unit_cost)
      VALUES (NEW.drug_item_id, NEW.lot_number, NEW.qty_received, NEW.qty_received, NEW.expiration_date,
              (SELECT s.party_id FROM mcms_erp.supplier s JOIN mcms_erp.goods_receipt g ON g.supplier_id = s.supplier_id WHERE g.grn_id = NEW.grn_id),
              NEW.unit_cost)
      RETURNING lot_id INTO newlot;
   END IF;

   -- Update po_line.qty_received
   IF NEW.po_line_id IS NOT NULL THEN
      UPDATE mcms_erp.purchase_order_line
         SET qty_received = qty_received + NEW.qty_received
       WHERE line_id = NEW.po_line_id
       RETURNING * INTO po_line;
   END IF;

   -- If all lines received, mark PO as 'received'
   IF (SELECT COUNT(*) FROM mcms_erp.purchase_order_line WHERE po_id = po_line.po_id AND qty_received < qty) = 0 THEN
      UPDATE mcms_erp.purchase_order SET status='received', received_at=now()
       WHERE po_id = po_line.po_id AND status IN ('sent','partial_received','approved');
   ELSE
      UPDATE mcms_erp.purchase_order SET status='partial_received' WHERE po_id = po_line.po_id AND status IN ('approved','sent');
   END IF;

   PERFORM mcms_core.emit_event('purchase_order_raised','info', NULL, NULL,
      'mcms_erp','goods_receipt_line', NEW.line_id,
      jsonb_build_object('grn_id', NEW.grn_id, 'item_id', NEW.item_id, 'drug_item_id', NEW.drug_item_id,
                         'qty_received', NEW.qty_received),
      p_channel := 'mcms_inventory');
   RETURN NEW;
END$$;


--
-- Name: upsert_stock(bigint, integer, bigint); Type: FUNCTION; Schema: mcms_erp; Owner: -
--

CREATE FUNCTION mcms_erp.upsert_stock(p_item_id bigint, p_qty integer, p_dept_id bigint) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE sid BIGINT;
BEGIN
   INSERT INTO mcms_erp.inventory_stock (item_id, department_id, qty_on_hand)
   VALUES (p_item_id, COALESCE(p_dept_id, (SELECT MIN(department_id) FROM mcms_hr.department)),
           p_qty)
   ON CONFLICT (item_id, department_id)
   DO UPDATE SET qty_on_hand = inventory_stock.qty_on_hand + p_qty,
                 updated_at = now()
   RETURNING stock_id INTO sid;
END$$;


--
-- Name: fn_employee_hire_event(); Type: FUNCTION; Schema: mcms_hr; Owner: -
--

CREATE FUNCTION mcms_hr.fn_employee_hire_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   PERFORM mcms_core.emit_event('employee_hired','info', NULL, NEW.party_id,
       'mcms_hr','employee', NEW.employee_id,
       jsonb_build_object('employee_no', NEW.employee_no,
                          'role', NEW.role, 'department_id', NEW.primary_department_id));
   RETURN NEW;
END$$;


--
-- Name: fn_admission_event(); Type: FUNCTION; Schema: mcms_icu; Owner: -
--

CREATE FUNCTION mcms_icu.fn_admission_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   IF (TG_OP='INSERT') THEN
      PERFORM mcms_core.emit_event('icu_admit','warning', NULL, v_party,
         'mcms_icu','admission', NEW.admission_id,
         jsonb_build_object('bed_id', NEW.bed_id, 'reason', NEW.admit_reason));
      IF NEW.bed_id IS NOT NULL THEN
         UPDATE mcms_icu.bed SET status='occupied' WHERE bed_id = NEW.bed_id;
         INSERT INTO mcms_icu.bed_stay (admission_id, bed_id, assigned_at)
         VALUES (NEW.admission_id, NEW.bed_id, now())
         ON CONFLICT DO NOTHING;
      END IF;
   ELSIF (TG_OP='UPDATE' AND OLD.status <> NEW.status AND NEW.status IN ('discharged','transferred','expired')) THEN
      PERFORM mcms_core.emit_event('icu_discharge','info', NULL, v_party,
         'mcms_icu','admission', NEW.admission_id,
         jsonb_build_object('destination', NEW.discharge_destination,'status', NEW.status::text));
      UPDATE mcms_icu.bed_stay SET released_at = now() WHERE admission_id = NEW.admission_id AND released_at IS NULL;
      UPDATE mcms_icu.bed
         SET status='cleaning'
       WHERE bed_id IN (SELECT bed_id FROM mcms_icu.bed_stay WHERE admission_id = NEW.admission_id)
          OR bed_id = NEW.bed_id;
   END IF;
   RETURN NEW;
END$$;


--
-- Name: fn_vent_event(); Type: FUNCTION; Schema: mcms_icu; Owner: -
--

CREATE FUNCTION mcms_icu.fn_vent_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party
     FROM mcms_emr.patient p
     JOIN mcms_icu.admission a ON a.patient_id = p.patient_id
    WHERE a.admission_id = NEW.admission_id;
   IF (TG_OP='INSERT' AND NEW.support_kind='mechanical_ventilation' AND NEW.stopped_at IS NULL) THEN
      PERFORM mcms_core.emit_event('ventilator_started','warning', NULL, v_party,
         'mcms_icu','support_session', NEW.session_id,
         jsonb_build_object('started_at', NEW.started_at));
   ELSIF (TG_OP='UPDATE' AND OLD.stopped_at IS NULL AND NEW.stopped_at IS NOT NULL AND NEW.support_kind='mechanical_ventilation') THEN
      PERFORM mcms_core.emit_event('ventilator_stopped','info', NULL, v_party,
         'mcms_icu','support_session', NEW.session_id,
         jsonb_build_object('stopped_at', NEW.stopped_at, 'stopped_reason', NEW.stopped_reason));
   END IF;
   RETURN NEW;
END$$;


--
-- Name: fn_vitals_alert_event(); Type: FUNCTION; Schema: mcms_icu; Owner: -
--

CREATE FUNCTION mcms_icu.fn_vitals_alert_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   crit BOOLEAN := FALSE;
   pid BIGINT;
   v_party BIGINT;
BEGIN
   crit := (NEW.hr_bpm IS NOT NULL AND NEW.hr_bpm > 130)
        OR (NEW.sbp_mmhg IS NOT NULL AND NEW.sbp_mmhg < 90)
        OR (NEW.spo2_pct IS NOT NULL AND NEW.spo2_pct < 88)
        OR (NEW.gcs   IS NOT NULL AND NEW.gcs   < 8);
   IF crit THEN
      SELECT patient_id INTO pid FROM mcms_icu.admission WHERE admission_id = NEW.admission_id;
      SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = pid;
      PERFORM mcms_core.emit_event('deterioration_alert','critical', NULL, v_party,
         'mcms_icu','vitals_stream', NEW.stream_id,
         jsonb_build_object('hr', NEW.hr_bpm, 'sbp', NEW.sbp_mmhg,
                            'spo2', NEW.spo2_pct, 'gcs', NEW.gcs),
         p_channel := 'mcms_critical');
   END IF;
   RETURN NEW;
END$$;


--
-- Name: fn_lab_order_event(); Type: FUNCTION; Schema: mcms_lab; Owner: -
--

CREATE FUNCTION mcms_lab.fn_lab_order_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event('lab_order_placed','info', NEW.requested_by, v_party,
      'mcms_lab','lab_order', NEW.order_id,
      jsonb_build_object('order_no', NEW.order_no, 'priority', NEW.order_priority::text, 'panel_id', NEW.panel_id));
   RETURN NEW;
END$$;


--
-- Name: fn_result_critical(); Type: FUNCTION; Schema: mcms_lab; Owner: -
--

CREATE FUNCTION mcms_lab.fn_result_critical() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_patient bigint; v_party bigint; v_encounter bigint;
  v_test text; v_cat text;
BEGIN
  IF NEW.flag = 'pending' OR NEW.flag IS NULL THEN RETURN NEW; END IF;
  SELECT lo.patient_id, lo.encounter_id, tc.name
    INTO v_patient, v_encounter, v_test
    FROM mcms_lab.sample s
    JOIN mcms_lab.lab_order lo ON lo.order_id = s.lab_order_id
    JOIN mcms_lab.test_catalog tc ON tc.test_id = NEW.test_id
    WHERE s.sample_id = NEW.sample_id;
  SELECT p.party_id INTO v_party FROM mcms_emr.patient p WHERE p.patient_id = v_patient;

  v_cat := CASE WHEN NEW.flag = 'critical' THEN 'critical_result'
                ELSE 'abnormal_result' END;
  PERFORM mcms_core.fn_make_notification(
    v_cat,
    v_cat || ': ' || v_test,
    'Result for ' || v_test || ' flagged ' || NEW.flag || '.',
    NULL, v_party,
    'mcms_lab', 'result', NEW.result_id);

  -- anomaly alert -> event_log (severity critical/warning) so it surfaces
  -- automatically in the LiveFeed WebSocket stream.
  PERFORM mcms_core.emit_event(
    'abnormal_result_alert'::mcms_core.event_kind,
    CASE WHEN NEW.flag = 'critical' THEN 'critical'::mcms_core.event_severity
         ELSE 'warning'::mcms_core.event_severity END,
    NULL, v_party,
    'mcms_lab', 'result', NEW.result_id,
    jsonb_build_object('flag', NEW.flag, 'test', v_test,
                       'value', COALESCE(NEW.value_text, NEW.value_numeric::text)));

  -- auto-route: attach a clinical note to the encounter (if any)
  IF v_encounter IS NOT NULL THEN
    INSERT INTO mcms_emr.clinical_note
      (encounter_id, patient_id, note_type, title, body, author_user_id, signed, created_at, updated_at)
    VALUES (v_encounter, v_patient, 'lab_result',
            'Lab result: ' || v_test,
            'Auto-routed from mcms_lab.result #' || NEW.result_id ||
            ' | flag=' || NEW.flag ||
            ' | value=' || COALESCE(NEW.value_text, NEW.value_numeric::text),
            COALESCE(NEW.verified_by, NEW.analysed_by,
                     (SELECT MIN(user_id) FROM mcms_core.app_user)),
            false, now(), now());
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: fn_result_event(); Type: FUNCTION; Schema: mcms_lab; Owner: -
--

CREATE FUNCTION mcms_lab.fn_result_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   samp mcms_lab.sample%ROWTYPE;
   pid BIGINT;
   v_party BIGINT;
   sev mcms_core.event_severity;
BEGIN
   SELECT * INTO samp FROM mcms_lab.sample WHERE sample_id = NEW.sample_id;
   SELECT patient_id INTO pid FROM mcms_lab.lab_order WHERE order_id = samp.lab_order_id;
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = pid;
   sev := CASE WHEN NEW.flag='critical' THEN 'critical' ELSE 'info' END;
   IF (TG_OP='UPDATE' AND NEW.verified_at IS NOT NULL) THEN
      PERFORM mcms_core.emit_event('result_verified', sev, NEW.verified_by, v_party,
         'mcms_lab','result', NEW.result_id,
         jsonb_build_object('test_id', NEW.test_id, 'flag', NEW.flag::text,
                            'value_text', NEW.value_text, 'value_numeric', NEW.value_numeric,
                            'critical', NEW.flag='critical'),
         p_channel := CASE WHEN NEW.flag='critical' THEN 'mcms_critical' ELSE 'mcms' END);
   END IF;
   RETURN NEW;
END$$;


--
-- Name: fn_sample_event(); Type: FUNCTION; Schema: mcms_lab; Owner: -
--

CREATE FUNCTION mcms_lab.fn_sample_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   IF (NEW.status = 'collected' AND ((TG_OP='INSERT') OR (TG_OP='UPDATE' AND OLD.status <> NEW.status))) THEN
      PERFORM mcms_core.emit_event('sample_collected','info', NEW.collected_by, NULL,
         'mcms_lab','sample', NEW.sample_id,
         jsonb_build_object('sample_no', NEW.sample_no, 'specimen_type', NEW.specimen_type::text));
   ELSIF (TG_OP='UPDATE' AND NEW.status = 'rejected' AND OLD.status <> 'rejected') THEN
      PERFORM mcms_core.emit_event('result_rejected','warning', NEW.received_by, NULL,
         'mcms_lab','sample', NEW.sample_id,
         jsonb_build_object('rejected_reason', COALESCE(NEW.rejected_reason,'')));
   END IF;
   RETURN NEW;
END$$;


--
-- Name: fn_session_event(); Type: FUNCTION; Schema: mcms_physio; Owner: -
--

CREATE FUNCTION mcms_physio.fn_session_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   IF (TG_OP='UPDATE' AND OLD.status <> NEW.status AND NEW.status='completed') THEN
      PERFORM mcms_core.emit_event('physio_session_completed','info', NEW.therapist_user_id, v_party,
         'mcms_physio','session', NEW.session_id,
         jsonb_build_object('plan_id', NEW.plan_id, 'therapy_id', NEW.therapy_id,
                            'session_no', NEW.sessions_in_seq));
      UPDATE mcms_physio.treatment_plan
         SET sessions_completed = sessions_completed + 1,
             status = CASE WHEN sessions_completed + 1 >= sessions_planned THEN 'completed'::mcms_physio.plan_status
                           ELSE status END
       WHERE plan_id = NEW.plan_id;
   END IF;
   RETURN NEW;
END$$;


--
-- Name: fn_study_event(); Type: FUNCTION; Schema: mcms_rad; Owner: -
--

CREATE FUNCTION mcms_rad.fn_study_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE ev mcms_core.event_kind; v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   IF (TG_OP = 'INSERT') THEN ev := 'study_requested';
   ELSIF (TG_OP='UPDATE' AND OLD.status <> NEW.status) THEN
      ev := CASE NEW.status
         WHEN 'completed' THEN 'study_completed'
         WHEN 'verified'  THEN 'report_finalised'
         ELSE NULL END;
   ELSE ev := NULL;
   END IF;
   IF ev IS NOT NULL THEN
      PERFORM mcms_core.emit_event(ev, 'info', NEW.requested_by, v_party,
         'mcms_rad','study_request', NEW.study_id,
         jsonb_build_object('accession_no', NEW.accession_no,
                            'status', NEW.status::text,
                            'priority', NEW.priority::text));
   END IF;
   RETURN NEW;
END$$;


--
-- Name: fn_administer_event(); Type: FUNCTION; Schema: mcms_rx; Owner: -
--

CREATE FUNCTION mcms_rx.fn_administer_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event('medication_administered','info', NEW.administered_by, v_party,
      'mcms_rx','administration', NEW.administer_id,
      jsonb_build_object('drug_item_id', NEW.drug_item_id, 'dose', NEW.dose_given));
   RETURN NEW;
END$$;


--
-- Name: fn_dispense_event_and_stock(); Type: FUNCTION; Schema: mcms_rx; Owner: -
--

CREATE FUNCTION mcms_rx.fn_dispense_event_and_stock() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
   bal INT;
   drugrow mcms_rx.drug_item%ROWTYPE;
   v_party BIGINT;
BEGIN
   IF NEW.lot_id IS NOT NULL THEN
      UPDATE mcms_rx.drug_lot
         SET on_hand_qty = on_hand_qty - NEW.quantity
       WHERE lot_id = NEW.lot_id AND on_hand_qty >= NEW.quantity
       RETURNING on_hand_qty INTO bal;
      IF bal IS NULL THEN
          RAISE EXCEPTION 'Insufficient stock in lot %', NEW.lot_id
            USING ERRCODE = '40001';
      END IF;
      bal := bal;
      INSERT INTO mcms_rx.stock_movement (drug_item_id, lot_id, movement_type, qty_delta, balance_after, performed_by, reason)
      VALUES (NEW.drug_item_id, NEW.lot_id, 'dispense', -NEW.quantity, bal, NEW.dispensed_by,
              'dispense to patient ' || NEW.mrn);
   END IF;

   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   PERFORM mcms_core.emit_event('medication_dispensed','info', NEW.dispensed_by, v_party,
      'mcms_rx','dispensation', NEW.dispensation_id,
      jsonb_build_object('drug_item_id', NEW.drug_item_id, 'qty', NEW.quantity, 'mrn', NEW.mrn));

   SELECT * INTO drugrow FROM mcms_rx.drug_item WHERE drug_item_id = NEW.drug_item_id;
   SELECT COALESCE(SUM(on_hand_qty), 0) INTO bal FROM mcms_rx.drug_lot WHERE drug_item_id = NEW.drug_item_id AND status = 'on_hand';
   IF drugrow.reorder_level > 0 AND bal <= drugrow.reorder_level THEN
       PERFORM mcms_core.emit_event('low_stock_alert','warning', NULL, NULL,
          'mcms_rx','drug_item', NEW.drug_item_id,
          jsonb_build_object('drug', drugrow.generic_name, 'on_hand', bal, 'reorder_level', drugrow.reorder_level),
          p_channel := 'mcms_inventory');
   END IF;
   RETURN NEW;
END$$;


--
-- Name: scan_expired_lots(); Type: FUNCTION; Schema: mcms_rx; Owner: -
--

CREATE FUNCTION mcms_rx.scan_expired_lots() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE n INT;
BEGIN
   UPDATE mcms_rx.drug_lot SET status='expired'
    WHERE expires_on < now()::date AND status='on_hand'
    RETURNING drug_item_id INTO n;
   PERFORM mcms_core.emit_event('low_stock_alert','warning', NULL, NULL,
       'mcms_rx','drug_lot', NULL,
       jsonb_build_object('note', 'expired lot quarantine done'));
   RETURN n;
END$$;


--
-- Name: fn_or_busy_on_surgery(); Type: FUNCTION; Schema: mcms_surgical; Owner: -
--

CREATE FUNCTION mcms_surgical.fn_or_busy_on_surgery() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   IF (TG_OP='UPDATE' AND NEW.status IN ('patient_in_or','incision_start','in_progress','closure_start')) THEN
      UPDATE mcms_surgical.operating_room SET status='busy', updated_at=now()
      WHERE or_id = NEW.or_id;
   ELSIF (TG_OP='UPDATE' AND NEW.status IN ('patient_out_or','recovery','completed','cancelled') OR
          (TG_OP='DELETE')) THEN
      UPDATE mcms_surgical.operating_room SET status='cleaning', updated_at=now()
      WHERE or_id = OLD.or_id;
   END IF;
   RETURN COALESCE(NEW, OLD);
END$$;


--
-- Name: fn_surg_event(); Type: FUNCTION; Schema: mcms_surgical; Owner: -
--

CREATE FUNCTION mcms_surgical.fn_surg_event() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE ev_kind mcms_core.event_kind; v_party BIGINT;
BEGIN
   SELECT party_id INTO v_party FROM mcms_emr.patient WHERE patient_id = NEW.patient_id;
   IF TG_OP='INSERT' THEN
      ev_kind := 'surgery_scheduled';
   ELSIF TG_OP='UPDATE' AND OLD.status <> NEW.status THEN
      ev_kind := CASE NEW.status
         WHEN 'incision_start' THEN 'surgery_started'
         WHEN 'completed'       THEN 'surgery_completed'
         WHEN 'cancelled'       THEN 'surgery_cancelled'
         ELSE NULL END;
   END IF;
   IF ev_kind IS NOT NULL THEN
      PERFORM mcms_core.emit_event(ev_kind, 'info', NEW.surgeon_user_id, v_party,
         'mcms_surgical','surgery', NEW.surgery_id,
         jsonb_build_object('operation_no', NEW.operation_no, 'or_id', NEW.or_id,
                            'procedure_id', NEW.procedure_id, 'status', NEW.status::text));
   END IF;
   RETURN NEW;
END$$;


--
-- Name: fn_patient_deceased_guard(); Type: FUNCTION; Schema: mcms_vital_records; Owner: -
--

CREATE FUNCTION mcms_vital_records.fn_patient_deceased_guard() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.is_deceased IS TRUE AND OLD.is_deceased IS NOT TRUE THEN
    -- immutable: never allow flipping a deceased patient back to alive
    PERFORM mcms_core.emit_event(
      'patient_deceased', 'info', NULL, NEW.party_id,
      'mcms_emr', 'patient', NEW.patient_id, '{}'::jsonb);
  END IF;
  -- reject any attempt to un-decease (defensive; also enforced in app layer)
  IF OLD.is_deceased IS TRUE AND NEW.is_deceased IS NOT TRUE THEN
    RAISE EXCEPTION 'patient % is deceased and cannot be reactivated', OLD.patient_id;
  END IF;
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: claim_response; Type: TABLE; Schema: mcms_billing; Owner: -
--

CREATE TABLE mcms_billing.claim_response (
    response_id bigint NOT NULL,
    claim_id bigint NOT NULL,
    payer_code text NOT NULL,
    status text NOT NULL,
    approved_amount numeric(14,2) DEFAULT 0 NOT NULL,
    rejected_amount numeric(14,2) DEFAULT 0 NOT NULL,
    remittance text,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: claim_response_response_id_seq; Type: SEQUENCE; Schema: mcms_billing; Owner: -
--

CREATE SEQUENCE mcms_billing.claim_response_response_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: claim_response_response_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_billing; Owner: -
--

ALTER SEQUENCE mcms_billing.claim_response_response_id_seq OWNED BY mcms_billing.claim_response.response_id;


--
-- Name: eligibility_check; Type: TABLE; Schema: mcms_billing; Owner: -
--

CREATE TABLE mcms_billing.eligibility_check (
    eligibility_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    payer_code text NOT NULL,
    policy_no text,
    status text NOT NULL,
    reason text,
    raw_response text,
    checked_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: eligibility_check_eligibility_id_seq; Type: SEQUENCE; Schema: mcms_billing; Owner: -
--

CREATE SEQUENCE mcms_billing.eligibility_check_eligibility_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: eligibility_check_eligibility_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_billing; Owner: -
--

ALTER SEQUENCE mcms_billing.eligibility_check_eligibility_id_seq OWNED BY mcms_billing.eligibility_check.eligibility_id;


--
-- Name: insurance_claim; Type: TABLE; Schema: mcms_billing; Owner: -
--

CREATE TABLE mcms_billing.insurance_claim (
    claim_id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    policy_no text NOT NULL,
    insurance_provider text NOT NULL,
    patient_id bigint NOT NULL,
    billed_amount numeric(14,2) NOT NULL,
    approved_amount numeric(14,2),
    rejected_amount numeric(14,2) DEFAULT 0 NOT NULL,
    status mcms_billing.claim_status DEFAULT 'draft'::mcms_billing.claim_status NOT NULL,
    submitted_at timestamp with time zone,
    adjudicated_at timestamp with time zone,
    paid_at timestamp with time zone,
    claim_no_external text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: insurance_claim_claim_id_seq; Type: SEQUENCE; Schema: mcms_billing; Owner: -
--

CREATE SEQUENCE mcms_billing.insurance_claim_claim_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: insurance_claim_claim_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_billing; Owner: -
--

ALTER SEQUENCE mcms_billing.insurance_claim_claim_id_seq OWNED BY mcms_billing.insurance_claim.claim_id;


--
-- Name: invoice; Type: TABLE; Schema: mcms_billing; Owner: -
--

CREATE TABLE mcms_billing.invoice (
    invoice_id bigint NOT NULL,
    invoice_no text NOT NULL,
    patient_id bigint NOT NULL,
    mrn text NOT NULL,
    encounter_id bigint,
    issued_by bigint NOT NULL,
    status mcms_billing.inv_status DEFAULT 'draft'::mcms_billing.inv_status NOT NULL,
    subtotal numeric(14,2) DEFAULT 0 NOT NULL,
    tax_amount numeric(14,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(14,2) DEFAULT 0 NOT NULL,
    insurance_covers numeric(14,2) DEFAULT 0 NOT NULL,
    patient_pays numeric(14,2) DEFAULT 0 NOT NULL,
    total numeric(14,2) GENERATED ALWAYS AS (((subtotal + tax_amount) - discount_amount)) STORED,
    currency text DEFAULT 'SAR'::text NOT NULL,
    issued_at timestamp with time zone DEFAULT now() NOT NULL,
    due_date date,
    paid_at timestamp with time zone,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: invoice_invoice_id_seq; Type: SEQUENCE; Schema: mcms_billing; Owner: -
--

CREATE SEQUENCE mcms_billing.invoice_invoice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_invoice_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_billing; Owner: -
--

ALTER SEQUENCE mcms_billing.invoice_invoice_id_seq OWNED BY mcms_billing.invoice.invoice_id;


--
-- Name: invoice_line; Type: TABLE; Schema: mcms_billing; Owner: -
--

CREATE TABLE mcms_billing.invoice_line (
    line_id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    service_id bigint,
    source_schema text,
    source_table text,
    source_id bigint,
    description text NOT NULL,
    qty numeric(8,2) DEFAULT 1 NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    line_total numeric(14,2) GENERATED ALWAYS AS ((qty * unit_price)) STORED,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT invoice_line_qty_check CHECK ((qty > (0)::numeric)),
    CONSTRAINT invoice_line_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


--
-- Name: invoice_line_line_id_seq; Type: SEQUENCE; Schema: mcms_billing; Owner: -
--

CREATE SEQUENCE mcms_billing.invoice_line_line_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: invoice_line_line_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_billing; Owner: -
--

ALTER SEQUENCE mcms_billing.invoice_line_line_id_seq OWNED BY mcms_billing.invoice_line.line_id;


--
-- Name: payer; Type: TABLE; Schema: mcms_billing; Owner: -
--

CREATE TABLE mcms_billing.payer (
    payer_id bigint NOT NULL,
    payer_code text NOT NULL,
    name text NOT NULL,
    supports_eligibility boolean DEFAULT true NOT NULL,
    supports_claims boolean DEFAULT true NOT NULL,
    mock_mode boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: payer_payer_id_seq; Type: SEQUENCE; Schema: mcms_billing; Owner: -
--

CREATE SEQUENCE mcms_billing.payer_payer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payer_payer_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_billing; Owner: -
--

ALTER SEQUENCE mcms_billing.payer_payer_id_seq OWNED BY mcms_billing.payer.payer_id;


--
-- Name: payment; Type: TABLE; Schema: mcms_billing; Owner: -
--

CREATE TABLE mcms_billing.payment (
    payment_id bigint NOT NULL,
    invoice_id bigint NOT NULL,
    method mcms_billing.pay_method NOT NULL,
    amount numeric(14,2) NOT NULL,
    currency text DEFAULT 'SAR'::text NOT NULL,
    paid_at timestamp with time zone DEFAULT now() NOT NULL,
    received_by bigint,
    txn_ref text,
    notes text,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT payment_amount_check CHECK ((amount > (0)::numeric))
);


--
-- Name: payment_payment_id_seq; Type: SEQUENCE; Schema: mcms_billing; Owner: -
--

CREATE SEQUENCE mcms_billing.payment_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payment_payment_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_billing; Owner: -
--

ALTER SEQUENCE mcms_billing.payment_payment_id_seq OWNED BY mcms_billing.payment.payment_id;


--
-- Name: service_price; Type: TABLE; Schema: mcms_billing; Owner: -
--

CREATE TABLE mcms_billing.service_price (
    service_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    service_type mcms_billing.service_type NOT NULL,
    department_id bigint,
    unit_price numeric(12,2) NOT NULL,
    currency text DEFAULT 'SAR'::text NOT NULL,
    is_taxable boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    effective_from date DEFAULT CURRENT_DATE NOT NULL,
    effective_to date,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT service_price_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


--
-- Name: service_price_service_id_seq; Type: SEQUENCE; Schema: mcms_billing; Owner: -
--

CREATE SEQUENCE mcms_billing.service_price_service_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: service_price_service_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_billing; Owner: -
--

ALTER SEQUENCE mcms_billing.service_price_service_id_seq OWNED BY mcms_billing.service_price.service_id;


--
-- Name: party; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.party (
    party_id bigint NOT NULL,
    party_type mcms_core.party_type NOT NULL,
    code text,
    display_name text NOT NULL,
    legal_name text,
    gender mcms_core.gender_type,
    date_of_birth date,
    blood_type mcms_core.blood_type DEFAULT 'unknown'::mcms_core.blood_type,
    tax_id text,
    national_id text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    preferred_language text DEFAULT 'ar'::text NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT party_display_name_check CHECK ((display_name <> ''::text)),
    CONSTRAINT party_preferred_language_check CHECK ((preferred_language = ANY (ARRAY['ar'::text, 'en'::text])))
);


--
-- Name: patient; Type: TABLE; Schema: mcms_emr; Owner: -
--

CREATE TABLE mcms_emr.patient (
    patient_id bigint NOT NULL,
    party_id bigint NOT NULL,
    mrn text NOT NULL,
    emergency_contact_name text,
    emergency_contact_phone text,
    next_of_kin_party_id bigint,
    insurance_provider text,
    insurance_policy_no text,
    insurance_group_no text,
    coverage_verified boolean DEFAULT false,
    coverage_verified_at timestamp with time zone,
    preferred_language text,
    organ_donor boolean DEFAULT false,
    living_will boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    fhir_id text,
    hl7_mpi text,
    facility_id bigint DEFAULT 1 NOT NULL,
    is_deceased boolean DEFAULT false NOT NULL
);


--
-- Name: COLUMN patient.is_deceased; Type: COMMENT; Schema: mcms_emr; Owner: -
--

COMMENT ON COLUMN mcms_emr.patient.is_deceased IS 'Lifecycle flag set true when a death certificate is issued (immutable once set).';


--
-- Name: v_invoice_aging; Type: VIEW; Schema: mcms_billing; Owner: -
--

CREATE VIEW mcms_billing.v_invoice_aging AS
 SELECT i.invoice_id,
    i.invoice_no,
    pt.mrn,
    p.display_name AS patient_name,
    i.status,
    i.total,
    i.issued_at,
    i.due_date,
    COALESCE(pay.paid, (0)::numeric) AS paid_amount,
    (i.total - COALESCE(pay.paid, (0)::numeric)) AS balance,
        CASE
            WHEN ((now())::date < i.due_date) THEN 'current'::text
            WHEN ((now())::date < (i.due_date + '30 days'::interval)) THEN '1-30'::text
            WHEN ((now())::date < (i.due_date + '60 days'::interval)) THEN '31-60'::text
            WHEN ((now())::date < (i.due_date + '90 days'::interval)) THEN '61-90'::text
            ELSE 'over_90'::text
        END AS aging_bucket
   FROM (((mcms_billing.invoice i
     JOIN mcms_emr.patient pt ON ((pt.patient_id = i.patient_id)))
     JOIN mcms_core.party p ON ((p.party_id = pt.party_id)))
     LEFT JOIN ( SELECT payment.invoice_id,
            sum(payment.amount) AS paid
           FROM mcms_billing.payment
          GROUP BY payment.invoice_id) pay ON ((pay.invoice_id = i.invoice_id)))
  WHERE (i.status <> ALL (ARRAY['paid'::mcms_billing.inv_status, 'draft'::mcms_billing.inv_status, 'cancelled'::mcms_billing.inv_status]));


--
-- Name: department; Type: TABLE; Schema: mcms_hr; Owner: -
--

CREATE TABLE mcms_hr.department (
    department_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    parent_department_id bigint,
    kind text NOT NULL,
    head_user_id bigint,
    location_building text,
    location_floor integer,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT department_kind_check CHECK ((kind = ANY (ARRAY['clinic'::text, 'surgical'::text, 'emergency'::text, 'icu'::text, 'lab'::text, 'radiology'::text, 'pharmacy'::text, 'physio'::text, 'billing'::text, 'hr'::text, 'administration'::text, 'maintenance'::text, 'housekeeping'::text, 'other'::text])))
);


--
-- Name: v_patient_ledger; Type: VIEW; Schema: mcms_billing; Owner: -
--

CREATE VIEW mcms_billing.v_patient_ledger AS
 SELECT i.invoice_id,
    i.invoice_no,
    pt.mrn,
    p.display_name AS patient_name,
    il.line_id,
    il.description AS line_description,
    sp.service_type,
    d.name AS dept_name,
    il.qty,
    il.unit_price,
    il.line_total,
    i.issued_at,
    i.status AS invoice_status
   FROM (((((mcms_billing.invoice_line il
     JOIN mcms_billing.invoice i ON ((i.invoice_id = il.invoice_id)))
     JOIN mcms_emr.patient pt ON ((pt.patient_id = i.patient_id)))
     JOIN mcms_core.party p ON ((p.party_id = pt.party_id)))
     LEFT JOIN mcms_billing.service_price sp ON ((sp.service_id = il.service_id)))
     LEFT JOIN mcms_hr.department d ON ((d.department_id = sp.department_id)));


--
-- Name: v_revenue_by_dept; Type: VIEW; Schema: mcms_billing; Owner: -
--

CREATE VIEW mcms_billing.v_revenue_by_dept AS
 SELECT sp.service_type,
    d.code AS dept_code,
    d.name AS dept_name,
    count(DISTINCT i.invoice_id) AS invoice_count,
    sum(il.line_total) AS gross_revenue,
    avg(il.line_total) AS avg_line_value
   FROM (((mcms_billing.invoice_line il
     JOIN mcms_billing.invoice i ON ((i.invoice_id = il.invoice_id)))
     JOIN mcms_billing.service_price sp ON ((sp.service_id = il.service_id)))
     LEFT JOIN mcms_hr.department d ON ((d.department_id = sp.department_id)))
  GROUP BY sp.service_type, d.code, d.name;


--
-- Name: appointment; Type: TABLE; Schema: mcms_clinic; Owner: -
--

CREATE TABLE mcms_clinic.appointment (
    appointment_id bigint NOT NULL,
    mrn text NOT NULL,
    patient_id bigint NOT NULL,
    clinician_user_id bigint NOT NULL,
    room_id bigint,
    department_id bigint NOT NULL,
    starts_at timestamp with time zone NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    status mcms_clinic.slot_status DEFAULT 'booked'::mcms_clinic.slot_status NOT NULL,
    reason text,
    booked_by bigint,
    encounter_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    confirmation_token uuid DEFAULT gen_random_uuid(),
    confirmation_deadline timestamp with time zone,
    confirmed_at timestamp with time zone,
    patient_confirmed boolean DEFAULT false NOT NULL,
    no_show_at timestamp with time zone,
    reminder_sent_at timestamp with time zone,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT appointment_check CHECK ((ends_at > starts_at))
);


--
-- Name: appointment_appointment_id_seq; Type: SEQUENCE; Schema: mcms_clinic; Owner: -
--

CREATE SEQUENCE mcms_clinic.appointment_appointment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: appointment_appointment_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_clinic; Owner: -
--

ALTER SEQUENCE mcms_clinic.appointment_appointment_id_seq OWNED BY mcms_clinic.appointment.appointment_id;


--
-- Name: consultation; Type: TABLE; Schema: mcms_clinic; Owner: -
--

CREATE TABLE mcms_clinic.consultation (
    consultation_id bigint NOT NULL,
    appointment_id bigint,
    queue_id bigint,
    encounter_id bigint NOT NULL,
    room_id bigint,
    clinician_user_id bigint NOT NULL,
    duration_minutes integer,
    subjective text,
    objective text,
    assessment text,
    plan text,
    follow_up_days integer,
    status mcms_clinic.consult_status DEFAULT 'in_progress'::mcms_clinic.consult_status NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT consultation_duration_minutes_check CHECK ((duration_minutes >= 0))
);


--
-- Name: consultation_consultation_id_seq; Type: SEQUENCE; Schema: mcms_clinic; Owner: -
--

CREATE SEQUENCE mcms_clinic.consultation_consultation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: consultation_consultation_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_clinic; Owner: -
--

ALTER SEQUENCE mcms_clinic.consultation_consultation_id_seq OWNED BY mcms_clinic.consultation.consultation_id;


--
-- Name: patient_queue; Type: TABLE; Schema: mcms_clinic; Owner: -
--

CREATE TABLE mcms_clinic.patient_queue (
    queue_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    mrn text NOT NULL,
    department_id bigint NOT NULL,
    assigned_clinician bigint,
    room_id bigint,
    priority integer DEFAULT 5 NOT NULL,
    status mcms_clinic.queue_status DEFAULT 'waiting'::mcms_clinic.queue_status NOT NULL,
    checked_in_at timestamp with time zone DEFAULT now() NOT NULL,
    called_at timestamp with time zone,
    started_at timestamp with time zone,
    finished_at timestamp with time zone,
    encounter_id bigint,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT patient_queue_priority_check CHECK (((priority >= 0) AND (priority <= 9)))
);


--
-- Name: patient_queue_queue_id_seq; Type: SEQUENCE; Schema: mcms_clinic; Owner: -
--

CREATE SEQUENCE mcms_clinic.patient_queue_queue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: patient_queue_queue_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_clinic; Owner: -
--

ALTER SEQUENCE mcms_clinic.patient_queue_queue_id_seq OWNED BY mcms_clinic.patient_queue.queue_id;


--
-- Name: room; Type: TABLE; Schema: mcms_clinic; Owner: -
--

CREATE TABLE mcms_clinic.room (
    room_id bigint NOT NULL,
    department_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    capacity integer DEFAULT 1,
    equipment text[],
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: room_room_id_seq; Type: SEQUENCE; Schema: mcms_clinic; Owner: -
--

CREATE SEQUENCE mcms_clinic.room_room_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: room_room_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_clinic; Owner: -
--

ALTER SEQUENCE mcms_clinic.room_room_id_seq OWNED BY mcms_clinic.room.room_id;


--
-- Name: access_log; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.access_log (
    access_id bigint NOT NULL,
    reader_user_id bigint,
    subject_party_id bigint,
    table_schema text NOT NULL,
    table_name text NOT NULL,
    row_id bigint NOT NULL,
    read_at timestamp with time zone DEFAULT now() NOT NULL,
    reason text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: access_log_access_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.access_log_access_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: access_log_access_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.access_log_access_id_seq OWNED BY mcms_core.access_log.access_id;


--
-- Name: address; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.address (
    address_id bigint NOT NULL,
    party_id bigint NOT NULL,
    label text NOT NULL,
    line1 text,
    line2 text,
    city text,
    region text,
    postal_code text,
    country text DEFAULT 'Unknown'::text NOT NULL,
    latitude double precision,
    longitude double precision,
    is_primary boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: address_address_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.address_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: address_address_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.address_address_id_seq OWNED BY mcms_core.address.address_id;


--
-- Name: app_user; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.app_user (
    user_id bigint NOT NULL,
    party_id bigint NOT NULL,
    username text NOT NULL,
    password_hash text NOT NULL,
    role mcms_core.user_role DEFAULT 'readonly'::mcms_core.user_role NOT NULL,
    specialization text,
    is_active boolean DEFAULT true NOT NULL,
    last_login_at timestamp with time zone,
    failed_logins integer DEFAULT 0 NOT NULL,
    locked_until timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint
);


--
-- Name: app_user_user_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.app_user_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: app_user_user_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.app_user_user_id_seq OWNED BY mcms_core.app_user.user_id;


--
-- Name: audit_trail; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.audit_trail (
    audit_id bigint NOT NULL,
    table_schema text NOT NULL,
    table_name text NOT NULL,
    row_id bigint NOT NULL,
    action text NOT NULL,
    changed_by bigint,
    changed_at timestamp with time zone DEFAULT now() NOT NULL,
    before jsonb,
    after jsonb,
    event_id bigint,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT audit_trail_action_check CHECK ((action = ANY (ARRAY['insert'::text, 'update'::text, 'delete'::text])))
);


--
-- Name: audit_trail_audit_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.audit_trail_audit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_trail_audit_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.audit_trail_audit_id_seq OWNED BY mcms_core.audit_trail.audit_id;


--
-- Name: backup_log; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.backup_log (
    backup_id bigint NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    finished_at timestamp with time zone,
    filename text,
    size_bytes bigint,
    status text DEFAULT 'running'::text NOT NULL,
    detail text,
    triggered_by text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: backup_log_backup_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.backup_log_backup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: backup_log_backup_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.backup_log_backup_id_seq OWNED BY mcms_core.backup_log.backup_id;


--
-- Name: consent; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.consent (
    consent_id bigint NOT NULL,
    party_id bigint NOT NULL,
    consent_type mcms_core.consent_type NOT NULL,
    granted boolean DEFAULT false NOT NULL,
    granted_at timestamp with time zone,
    revoked_at timestamp with time zone,
    granted_by bigint,
    note text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: consent_consent_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.consent_consent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: consent_consent_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.consent_consent_id_seq OWNED BY mcms_core.consent.consent_id;


--
-- Name: contact; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.contact (
    contact_id bigint NOT NULL,
    party_id bigint NOT NULL,
    kind text NOT NULL,
    value text NOT NULL,
    is_primary boolean DEFAULT false NOT NULL,
    verified_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT contact_kind_check CHECK ((kind = ANY (ARRAY['phone'::text, 'mobile'::text, 'email'::text, 'fax'::text, 'web'::text])))
);


--
-- Name: contact_contact_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.contact_contact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contact_contact_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.contact_contact_id_seq OWNED BY mcms_core.contact.contact_id;


--
-- Name: event_log; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.event_log (
    event_id bigint NOT NULL,
    seq bigint NOT NULL,
    occurred_at timestamp with time zone DEFAULT now() NOT NULL,
    kind mcms_core.event_kind NOT NULL,
    severity mcms_core.event_severity DEFAULT 'info'::mcms_core.event_severity NOT NULL,
    actor_user_id bigint,
    subject_party_id bigint,
    source_schema text,
    source_table text,
    source_id bigint,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    channel text DEFAULT 'mcms'::text NOT NULL,
    prev_hash text,
    hash text,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT event_source_pair_chk CHECK ((((source_schema IS NULL) AND (source_table IS NULL) AND (source_id IS NULL)) OR ((source_schema IS NOT NULL) AND (source_table IS NOT NULL) AND (source_id IS NOT NULL))))
);


--
-- Name: event_log_event_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.event_log_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_log_event_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.event_log_event_id_seq OWNED BY mcms_core.event_log.event_id;


--
-- Name: event_log_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.event_log_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facility; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.facility (
    facility_id bigint NOT NULL,
    organization_id bigint NOT NULL,
    code text NOT NULL,
    name_en text NOT NULL,
    name_ar text,
    parent_facility_id bigint,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: facility_facility_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.facility_facility_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: facility_facility_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.facility_facility_id_seq OWNED BY mcms_core.facility.facility_id;


--
-- Name: federated_identity; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.federated_identity (
    fed_id bigint NOT NULL,
    provider_code text NOT NULL,
    external_subject text NOT NULL,
    user_id bigint NOT NULL,
    linked_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: federated_identity_fed_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

ALTER TABLE mcms_core.federated_identity ALTER COLUMN fed_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME mcms_core.federated_identity_fed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: hl7_message; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.hl7_message (
    hl7_message_id bigint NOT NULL,
    message_control_id text NOT NULL,
    message_type text NOT NULL,
    sending_app text,
    sending_facility text,
    raw text NOT NULL,
    ack_code text DEFAULT 'AA'::text NOT NULL,
    error_detail text,
    actions jsonb DEFAULT '{}'::jsonb NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    received_by bigint,
    received_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: hl7_message_hl7_message_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.hl7_message_hl7_message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hl7_message_hl7_message_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.hl7_message_hl7_message_id_seq OWNED BY mcms_core.hl7_message.hl7_message_id;


--
-- Name: identity_provider; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.identity_provider (
    provider_code text NOT NULL,
    name text NOT NULL,
    protocol text NOT NULL,
    client_id text,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT identity_provider_protocol_check CHECK ((protocol = ANY (ARRAY['oidc'::text, 'saml'::text])))
);


--
-- Name: lookup; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.lookup (
    lookup_id bigint NOT NULL,
    namespace text NOT NULL,
    code text NOT NULL,
    label text NOT NULL,
    parent_code text,
    sort_order integer DEFAULT 0,
    is_active boolean DEFAULT true NOT NULL,
    label_en text,
    label_ar text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: lookup_lookup_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.lookup_lookup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lookup_lookup_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.lookup_lookup_id_seq OWNED BY mcms_core.lookup.lookup_id;


--
-- Name: notification; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.notification (
    notification_id bigint NOT NULL,
    recipient_user_id bigint,
    recipient_party_id bigint,
    category text NOT NULL,
    channel mcms_core.notification_channel DEFAULT 'in_app'::mcms_core.notification_channel NOT NULL,
    subject text,
    body text NOT NULL,
    status mcms_core.notification_status DEFAULT 'pending'::mcms_core.notification_status NOT NULL,
    source_schema text,
    source_table text,
    source_id bigint,
    sent_at timestamp with time zone,
    read_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: notification_notification_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.notification_notification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notification_notification_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.notification_notification_id_seq OWNED BY mcms_core.notification.notification_id;


--
-- Name: organization; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.organization (
    organization_id bigint NOT NULL,
    code text NOT NULL,
    name_en text NOT NULL,
    name_ar text,
    parent_org_id bigint,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: organization_organization_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.organization_organization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: organization_organization_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.organization_organization_id_seq OWNED BY mcms_core.organization.organization_id;


--
-- Name: party_party_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.party_party_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: party_party_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.party_party_id_seq OWNED BY mcms_core.party.party_id;


--
-- Name: permission; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.permission (
    permission_id bigint NOT NULL,
    code text NOT NULL,
    description text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: permission_permission_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.permission_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permission_permission_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.permission_permission_id_seq OWNED BY mcms_core.permission.permission_id;


--
-- Name: role; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.role (
    role_id bigint NOT NULL,
    code text NOT NULL,
    name_en text NOT NULL,
    name_ar text,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: role_permission; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.role_permission (
    role_id bigint NOT NULL,
    permission_id bigint NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: role_role_id_seq; Type: SEQUENCE; Schema: mcms_core; Owner: -
--

CREATE SEQUENCE mcms_core.role_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: role_role_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_core; Owner: -
--

ALTER SEQUENCE mcms_core.role_role_id_seq OWNED BY mcms_core.role.role_id;


--
-- Name: system_flag; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.system_flag (
    flag text NOT NULL,
    value text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: user_role_map; Type: TABLE; Schema: mcms_core; Owner: -
--

CREATE TABLE mcms_core.user_role_map (
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    department_id bigint,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: v_event_feed; Type: VIEW; Schema: mcms_core; Owner: -
--

CREATE VIEW mcms_core.v_event_feed AS
 SELECT e.seq,
    e.occurred_at,
    e.kind,
    e.severity,
    e.channel,
    e.source_schema,
    e.source_table,
    e.source_id,
    e.payload,
    pr.display_name AS actor_name,
    u.role AS actor_role,
    psubj.display_name AS subject_name
   FROM (((mcms_core.event_log e
     LEFT JOIN mcms_core.app_user u ON ((u.user_id = e.actor_user_id)))
     LEFT JOIN mcms_core.party pr ON ((pr.party_id = u.party_id)))
     LEFT JOIN mcms_core.party psubj ON ((psubj.party_id = e.subject_party_id)))
  ORDER BY e.seq DESC;


--
-- Name: session; Type: TABLE; Schema: mcms_dialysis; Owner: -
--

CREATE TABLE mcms_dialysis.session (
    session_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    encounter_id bigint,
    station_id bigint,
    nurse_user_id bigint,
    nephrologist_user_id bigint,
    modality mcms_dialysis.modality DEFAULT 'hemodialysis'::mcms_dialysis.modality NOT NULL,
    scheduled_at timestamp with time zone NOT NULL,
    started_at timestamp with time zone,
    ended_at timestamp with time zone,
    duration_minutes integer,
    pre_weight_kg numeric(6,2),
    pre_bp text,
    dry_weight_kg numeric(6,2),
    post_weight_kg numeric(6,2),
    post_bp text,
    fluid_removed_ml integer,
    blood_flow_rate integer,
    dialysate_flow integer,
    heparin_units integer,
    kt_v numeric(4,2),
    complications text,
    status mcms_dialysis.dialysis_status DEFAULT 'scheduled'::mcms_dialysis.dialysis_status NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: session_session_id_seq; Type: SEQUENCE; Schema: mcms_dialysis; Owner: -
--

CREATE SEQUENCE mcms_dialysis.session_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: session_session_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_dialysis; Owner: -
--

ALTER SEQUENCE mcms_dialysis.session_session_id_seq OWNED BY mcms_dialysis.session.session_id;


--
-- Name: station; Type: TABLE; Schema: mcms_dialysis; Owner: -
--

CREATE TABLE mcms_dialysis.station (
    station_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    department_id bigint,
    has_ro_water boolean DEFAULT true NOT NULL,
    status mcms_icu.bed_status DEFAULT 'available'::mcms_icu.bed_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: station_station_id_seq; Type: SEQUENCE; Schema: mcms_dialysis; Owner: -
--

CREATE SEQUENCE mcms_dialysis.station_station_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: station_station_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_dialysis; Owner: -
--

ALTER SEQUENCE mcms_dialysis.station_station_id_seq OWNED BY mcms_dialysis.station.station_id;


--
-- Name: ed_bed; Type: TABLE; Schema: mcms_emergency; Owner: -
--

CREATE TABLE mcms_emergency.ed_bed (
    ed_bed_id bigint NOT NULL,
    triage_id bigint NOT NULL,
    bed_label text NOT NULL,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    released_at timestamp with time zone,
    observation_minutes integer,
    notes text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: ed_bed_ed_bed_id_seq; Type: SEQUENCE; Schema: mcms_emergency; Owner: -
--

CREATE SEQUENCE mcms_emergency.ed_bed_ed_bed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ed_bed_ed_bed_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emergency; Owner: -
--

ALTER SEQUENCE mcms_emergency.ed_bed_ed_bed_id_seq OWNED BY mcms_emergency.ed_bed.ed_bed_id;


--
-- Name: resuscitation; Type: TABLE; Schema: mcms_emergency; Owner: -
--

CREATE TABLE mcms_emergency.resuscitation (
    resus_id bigint NOT NULL,
    triage_id bigint,
    encounter_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    code_initiated_at timestamp with time zone DEFAULT now() NOT NULL,
    code_type text,
    team_leader_id bigint,
    airway text,
    interventions text[],
    iv_access text,
    meds_administered text[],
    rosc boolean DEFAULT false,
    rosc_at timestamp with time zone,
    duration_minutes integer,
    outcome text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT resuscitation_code_type_check CHECK ((code_type = ANY (ARRAY['medical'::text, 'trauma'::text, 'cardiac'::text, 'respiratory'::text, 'paediatric'::text, 'obstetric'::text]))),
    CONSTRAINT resuscitation_duration_minutes_check CHECK ((duration_minutes >= 0))
);


--
-- Name: resuscitation_resus_id_seq; Type: SEQUENCE; Schema: mcms_emergency; Owner: -
--

CREATE SEQUENCE mcms_emergency.resuscitation_resus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resuscitation_resus_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emergency; Owner: -
--

ALTER SEQUENCE mcms_emergency.resuscitation_resus_id_seq OWNED BY mcms_emergency.resuscitation.resus_id;


--
-- Name: triage; Type: TABLE; Schema: mcms_emergency; Owner: -
--

CREATE TABLE mcms_emergency.triage (
    triage_id bigint NOT NULL,
    ed_visit_no text NOT NULL,
    patient_id bigint NOT NULL,
    mrn text NOT NULL,
    encounter_id bigint NOT NULL,
    presentation_time timestamp with time zone DEFAULT now() NOT NULL,
    chief_complaint text NOT NULL,
    esi_level integer NOT NULL,
    arrival_mode text,
    trauma_alert boolean DEFAULT false NOT NULL,
    vital_temp_c numeric(4,1),
    vital_hr_bpm integer,
    vital_sbp_mmhg integer,
    vital_dbp_mmhg integer,
    vital_rr_pm integer,
    vital_spo2_pct numeric(4,1),
    vital_pain_score integer,
    vital_gcs integer,
    allergies_known text,
    meds_on_arrival text[],
    triage_nurse_user_id bigint,
    triaged_at timestamp with time zone,
    status mcms_emergency.triage_status DEFAULT 'awaiting'::mcms_emergency.triage_status NOT NULL,
    disposition text,
    disposition_destination text,
    disposition_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT triage_arrival_mode_check CHECK ((arrival_mode = ANY (ARRAY['walk_in'::text, 'ambulance'::text, 'helicopter'::text, 'transfer'::text, 'police'::text]))),
    CONSTRAINT triage_esi_level_check CHECK (((esi_level >= 1) AND (esi_level <= 5))),
    CONSTRAINT triage_vital_gcs_check CHECK (((vital_gcs IS NULL) OR ((vital_gcs >= 3) AND (vital_gcs <= 15)))),
    CONSTRAINT triage_vital_hr_bpm_check CHECK (((vital_hr_bpm IS NULL) OR ((vital_hr_bpm >= 10) AND (vital_hr_bpm <= 280)))),
    CONSTRAINT triage_vital_pain_score_check CHECK (((vital_pain_score IS NULL) OR ((vital_pain_score >= 0) AND (vital_pain_score <= 10)))),
    CONSTRAINT triage_vital_temp_c_check CHECK (((vital_temp_c IS NULL) OR ((vital_temp_c >= (28)::numeric) AND (vital_temp_c <= (45)::numeric))))
);


--
-- Name: triage_triage_id_seq; Type: SEQUENCE; Schema: mcms_emergency; Owner: -
--

CREATE SEQUENCE mcms_emergency.triage_triage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: triage_triage_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emergency; Owner: -
--

ALTER SEQUENCE mcms_emergency.triage_triage_id_seq OWNED BY mcms_emergency.triage.triage_id;


--
-- Name: v_ed_board; Type: VIEW; Schema: mcms_emergency; Owner: -
--

CREATE VIEW mcms_emergency.v_ed_board AS
 SELECT t.triage_id,
    t.ed_visit_no,
    p.display_name AS patient_name,
    p.gender,
    age((p.date_of_birth)::timestamp with time zone) AS age,
    t.presentation_time,
    t.chief_complaint,
    t.esi_level,
    t.trauma_alert,
    t.vital_sbp_mmhg,
    t.vital_spo2_pct,
    t.vital_gcs,
    t.status,
    t.disposition,
    (EXTRACT(epoch FROM (now() - t.presentation_time)) / (60)::numeric) AS minutes_in_ed,
    pn.display_name AS triage_nurse
   FROM ((((mcms_emergency.triage t
     JOIN mcms_emr.patient pt ON ((pt.patient_id = t.patient_id)))
     JOIN mcms_core.party p ON ((p.party_id = pt.party_id)))
     LEFT JOIN mcms_core.app_user u ON ((u.user_id = t.triage_nurse_user_id)))
     LEFT JOIN mcms_core.party pn ON ((pn.party_id = u.party_id)))
  WHERE (t.status <> ALL (ARRAY['discharged'::mcms_emergency.triage_status, 'ama'::mcms_emergency.triage_status, 'died'::mcms_emergency.triage_status]));


--
-- Name: allergy; Type: TABLE; Schema: mcms_emr; Owner: -
--

CREATE TABLE mcms_emr.allergy (
    allergy_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    substance text NOT NULL,
    reaction text,
    severity mcms_emr.allergy_severity DEFAULT 'unknown'::mcms_emr.allergy_severity NOT NULL,
    onset_age text,
    noted_on timestamp with time zone DEFAULT now() NOT NULL,
    noted_by bigint,
    is_active boolean DEFAULT true NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: allergy_allergy_id_seq; Type: SEQUENCE; Schema: mcms_emr; Owner: -
--

CREATE SEQUENCE mcms_emr.allergy_allergy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: allergy_allergy_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emr; Owner: -
--

ALTER SEQUENCE mcms_emr.allergy_allergy_id_seq OWNED BY mcms_emr.allergy.allergy_id;


--
-- Name: clinical_note; Type: TABLE; Schema: mcms_emr; Owner: -
--

CREATE TABLE mcms_emr.clinical_note (
    note_id bigint NOT NULL,
    encounter_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    note_type mcms_emr.note_type NOT NULL,
    title text,
    body text NOT NULL,
    author_user_id bigint NOT NULL,
    coauthor_ids bigint[],
    signed boolean DEFAULT false NOT NULL,
    signed_at timestamp with time zone,
    amended_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    signed_by bigint,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: clinical_note_note_id_seq; Type: SEQUENCE; Schema: mcms_emr; Owner: -
--

CREATE SEQUENCE mcms_emr.clinical_note_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: clinical_note_note_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emr; Owner: -
--

ALTER SEQUENCE mcms_emr.clinical_note_note_id_seq OWNED BY mcms_emr.clinical_note.note_id;


--
-- Name: diagnosis; Type: TABLE; Schema: mcms_emr; Owner: -
--

CREATE TABLE mcms_emr.diagnosis (
    diagnosis_id bigint NOT NULL,
    encounter_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    condition_code text NOT NULL,
    condition_desc text NOT NULL,
    role mcms_emr.diagnosis_role DEFAULT 'working'::mcms_emr.diagnosis_role NOT NULL,
    status mcms_emr.diagnosis_status DEFAULT 'active'::mcms_emr.diagnosis_status NOT NULL,
    onset_date date,
    resolved_at timestamp with time zone,
    recorded_by bigint,
    is_chronic boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    signed boolean DEFAULT false NOT NULL,
    signed_at timestamp with time zone,
    signed_by bigint,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: diagnosis_diagnosis_id_seq; Type: SEQUENCE; Schema: mcms_emr; Owner: -
--

CREATE SEQUENCE mcms_emr.diagnosis_diagnosis_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: diagnosis_diagnosis_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emr; Owner: -
--

ALTER SEQUENCE mcms_emr.diagnosis_diagnosis_id_seq OWNED BY mcms_emr.diagnosis.diagnosis_id;


--
-- Name: encounter; Type: TABLE; Schema: mcms_emr; Owner: -
--

CREATE TABLE mcms_emr.encounter (
    encounter_id bigint NOT NULL,
    mrn text NOT NULL,
    patient_id bigint NOT NULL,
    status mcms_emr.encounter_status DEFAULT 'planned'::mcms_emr.encounter_status NOT NULL,
    class mcms_emr.encounter_class DEFAULT 'ambulatory'::mcms_emr.encounter_class NOT NULL,
    attending_user_id bigint,
    referring_user_id bigint,
    department_id bigint,
    reason_for_visit text,
    chief_complaint text,
    started_at timestamp with time zone,
    ended_at timestamp with time zone,
    bed_assign_id bigint,
    originating_encounter_id bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    fhir_id text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: encounter_encounter_id_seq; Type: SEQUENCE; Schema: mcms_emr; Owner: -
--

CREATE SEQUENCE mcms_emr.encounter_encounter_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: encounter_encounter_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emr; Owner: -
--

ALTER SEQUENCE mcms_emr.encounter_encounter_id_seq OWNED BY mcms_emr.encounter.encounter_id;


--
-- Name: family_history; Type: TABLE; Schema: mcms_emr; Owner: -
--

CREATE TABLE mcms_emr.family_history (
    fh_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    relative text NOT NULL,
    relationship text,
    condition_code text,
    condition_desc text NOT NULL,
    age_at_onset integer,
    is_deceased boolean DEFAULT false,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: family_history_fh_id_seq; Type: SEQUENCE; Schema: mcms_emr; Owner: -
--

CREATE SEQUENCE mcms_emr.family_history_fh_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: family_history_fh_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emr; Owner: -
--

ALTER SEQUENCE mcms_emr.family_history_fh_id_seq OWNED BY mcms_emr.family_history.fh_id;


--
-- Name: immunization; Type: TABLE; Schema: mcms_emr; Owner: -
--

CREATE TABLE mcms_emr.immunization (
    immunization_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    vaccine_code text NOT NULL,
    vaccine_name text NOT NULL,
    dose_number integer,
    given_at timestamp with time zone DEFAULT now() NOT NULL,
    given_by bigint,
    lot_number text,
    site text,
    reaction text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: immunization_immunization_id_seq; Type: SEQUENCE; Schema: mcms_emr; Owner: -
--

CREATE SEQUENCE mcms_emr.immunization_immunization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: immunization_immunization_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emr; Owner: -
--

ALTER SEQUENCE mcms_emr.immunization_immunization_id_seq OWNED BY mcms_emr.immunization.immunization_id;


--
-- Name: medication_order; Type: TABLE; Schema: mcms_emr; Owner: -
--

CREATE TABLE mcms_emr.medication_order (
    order_id bigint NOT NULL,
    encounter_id bigint,
    patient_id bigint NOT NULL,
    prescriber_user_id bigint NOT NULL,
    drug_item_id bigint,
    drug_name text NOT NULL,
    dose text NOT NULL,
    route mcms_emr.med_route NOT NULL,
    frequency text NOT NULL,
    duration_days integer,
    prn boolean DEFAULT false,
    refill_count integer DEFAULT 0 NOT NULL,
    instructions text,
    status mcms_emr.med_order_status DEFAULT 'active'::mcms_emr.med_order_status NOT NULL,
    ordered_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    signed boolean DEFAULT false NOT NULL,
    signed_at timestamp with time zone,
    signed_by bigint,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: medication_order_order_id_seq; Type: SEQUENCE; Schema: mcms_emr; Owner: -
--

CREATE SEQUENCE mcms_emr.medication_order_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: medication_order_order_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emr; Owner: -
--

ALTER SEQUENCE mcms_emr.medication_order_order_id_seq OWNED BY mcms_emr.medication_order.order_id;


--
-- Name: patient_patient_id_seq; Type: SEQUENCE; Schema: mcms_emr; Owner: -
--

CREATE SEQUENCE mcms_emr.patient_patient_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: patient_patient_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emr; Owner: -
--

ALTER SEQUENCE mcms_emr.patient_patient_id_seq OWNED BY mcms_emr.patient.patient_id;


--
-- Name: referral; Type: TABLE; Schema: mcms_emr; Owner: -
--

CREATE TABLE mcms_emr.referral (
    referral_id bigint NOT NULL,
    from_encounter_id bigint NOT NULL,
    to_encounter_id bigint,
    from_user_id bigint NOT NULL,
    to_user_id bigint,
    to_department_id bigint,
    diagnosis_id bigint,
    reason text,
    clinical_summary text,
    urgency text DEFAULT 'routine'::text NOT NULL,
    status mcms_emr.referral_status DEFAULT 'draft'::mcms_emr.referral_status NOT NULL,
    responded_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: referral_linkage_rule; Type: TABLE; Schema: mcms_emr; Owner: -
--

CREATE TABLE mcms_emr.referral_linkage_rule (
    rule_id bigint NOT NULL,
    from_department_id bigint,
    diagnosis_code text,
    code_system text,
    to_department_id bigint NOT NULL,
    priority integer DEFAULT 100 NOT NULL,
    rationale text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    to_facility_id bigint,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: referral_linkage_rule_rule_id_seq; Type: SEQUENCE; Schema: mcms_emr; Owner: -
--

CREATE SEQUENCE mcms_emr.referral_linkage_rule_rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: referral_linkage_rule_rule_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emr; Owner: -
--

ALTER SEQUENCE mcms_emr.referral_linkage_rule_rule_id_seq OWNED BY mcms_emr.referral_linkage_rule.rule_id;


--
-- Name: referral_referral_id_seq; Type: SEQUENCE; Schema: mcms_emr; Owner: -
--

ALTER TABLE mcms_emr.referral ALTER COLUMN referral_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME mcms_emr.referral_referral_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: social_history; Type: TABLE; Schema: mcms_emr; Owner: -
--

CREATE TABLE mcms_emr.social_history (
    sh_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    tobacco_status text,
    packs_per_day numeric(4,1),
    years_smoked integer,
    alcohol_status text,
    drinks_per_week integer,
    illicit_drugs text[],
    occupation text,
    relationship_status text,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: social_history_sh_id_seq; Type: SEQUENCE; Schema: mcms_emr; Owner: -
--

CREATE SEQUENCE mcms_emr.social_history_sh_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: social_history_sh_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emr; Owner: -
--

ALTER SEQUENCE mcms_emr.social_history_sh_id_seq OWNED BY mcms_emr.social_history.sh_id;


--
-- Name: v_daily_census; Type: VIEW; Schema: mcms_emr; Owner: -
--

CREATE VIEW mcms_emr.v_daily_census AS
 SELECT d.department_id,
    d.code AS dept_code,
    d.name AS dept_name,
    (e.started_at)::date AS day,
    count(*) FILTER (WHERE (e.status = 'in_progress'::mcms_emr.encounter_status)) AS in_progress,
    count(*) FILTER (WHERE (e.status = 'finished'::mcms_emr.encounter_status)) AS finished_today,
    count(*) AS total_opened
   FROM (mcms_emr.encounter e
     JOIN mcms_hr.department d ON ((d.department_id = e.department_id)))
  WHERE (e.started_at IS NOT NULL)
  GROUP BY d.department_id, d.code, d.name, ((e.started_at)::date);


--
-- Name: v_encounter_timeline; Type: VIEW; Schema: mcms_emr; Owner: -
--

CREATE VIEW mcms_emr.v_encounter_timeline AS
 SELECT e.encounter_id,
    e.mrn,
    p.display_name AS patient_name,
    e.class,
    e.status,
    e.reason_for_visit,
    d.code AS dept_code,
    d.name AS dept_name,
    pr.display_name AS attending,
    u.role AS attending_role,
    e.started_at,
    e.ended_at,
    age(now(), e.started_at) AS duration_running
   FROM (((((mcms_emr.encounter e
     JOIN mcms_emr.patient pt ON ((pt.patient_id = e.patient_id)))
     JOIN mcms_core.party p ON ((p.party_id = pt.party_id)))
     LEFT JOIN mcms_hr.department d ON ((d.department_id = e.department_id)))
     LEFT JOIN mcms_core.app_user u ON ((u.user_id = e.attending_user_id)))
     LEFT JOIN mcms_core.party pr ON ((pr.party_id = u.party_id)));


--
-- Name: v_patient_360; Type: VIEW; Schema: mcms_emr; Owner: -
--

CREATE VIEW mcms_emr.v_patient_360 AS
 SELECT p.patient_id,
    p.mrn,
    pr.display_name,
    pr.gender,
    pr.date_of_birth,
    age((pr.date_of_birth)::timestamp with time zone) AS age,
    pr.blood_type,
    ( SELECT count(*) AS count
           FROM mcms_emr.allergy a
          WHERE ((a.patient_id = p.patient_id) AND a.is_active)) AS active_allergies,
    ( SELECT count(*) AS count
           FROM mcms_emr.diagnosis d
          WHERE ((d.patient_id = p.patient_id) AND (d.status = 'active'::mcms_emr.diagnosis_status))) AS active_dx,
    ( SELECT count(*) AS count
           FROM mcms_emr.encounter e
          WHERE (e.patient_id = p.patient_id)) AS encounter_count,
    ( SELECT e.encounter_id
           FROM mcms_emr.encounter e
          WHERE (e.patient_id = p.patient_id)
          ORDER BY e.started_at DESC NULLS LAST
         LIMIT 1) AS latest_encounter_id,
    ( SELECT e.status
           FROM mcms_emr.encounter e
          WHERE (e.patient_id = p.patient_id)
          ORDER BY e.started_at DESC NULLS LAST
         LIMIT 1) AS latest_encounter_status,
    p.insurance_provider,
    p.insurance_policy_no
   FROM (mcms_emr.patient p
     JOIN mcms_core.party pr ON ((pr.party_id = p.party_id)));


--
-- Name: vitals; Type: TABLE; Schema: mcms_emr; Owner: -
--

CREATE TABLE mcms_emr.vitals (
    vital_id bigint NOT NULL,
    encounter_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    taken_at timestamp with time zone DEFAULT now() NOT NULL,
    taken_by bigint,
    temp_c numeric(4,1),
    hr_bpm integer,
    rr_pm integer,
    sbp_mmhg integer,
    dbp_mmhg integer,
    spo2_pct numeric(4,1),
    weight_kg numeric(5,2),
    height_cm numeric(5,1),
    bmi numeric(4,1) GENERATED ALWAYS AS (
CASE
    WHEN ((height_cm > (0)::numeric) AND (weight_kg IS NOT NULL)) THEN (weight_kg / NULLIF(power((height_cm / 100.0), (2)::numeric), (0)::numeric))
    ELSE NULL::numeric
END) STORED,
    pain_score integer,
    glucose_mgdl integer,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT vitals_bp_chk CHECK (((dbp_mmhg IS NULL) OR (sbp_mmhg IS NULL) OR (dbp_mmhg <= sbp_mmhg))),
    CONSTRAINT vitals_dbp_mmhg_check CHECK (((dbp_mmhg >= 10) AND (dbp_mmhg <= 200))),
    CONSTRAINT vitals_hr_bpm_check CHECK (((hr_bpm >= 10) AND (hr_bpm <= 280))),
    CONSTRAINT vitals_pain_score_check CHECK (((pain_score >= 0) AND (pain_score <= 10))),
    CONSTRAINT vitals_rr_pm_check CHECK (((rr_pm >= 4) AND (rr_pm <= 80))),
    CONSTRAINT vitals_sbp_mmhg_check CHECK (((sbp_mmhg >= 30) AND (sbp_mmhg <= 280))),
    CONSTRAINT vitals_spo2_pct_check CHECK (((spo2_pct >= (0)::numeric) AND (spo2_pct <= (100)::numeric))),
    CONSTRAINT vitals_temp_c_check CHECK (((temp_c > (25)::numeric) AND (temp_c < (50)::numeric)))
);


--
-- Name: vitals_vital_id_seq; Type: SEQUENCE; Schema: mcms_emr; Owner: -
--

CREATE SEQUENCE mcms_emr.vitals_vital_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vitals_vital_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_emr; Owner: -
--

ALTER SEQUENCE mcms_emr.vitals_vital_id_seq OWNED BY mcms_emr.vitals.vital_id;


--
-- Name: gl_account; Type: TABLE; Schema: mcms_erp; Owner: -
--

CREATE TABLE mcms_erp.gl_account (
    account_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    account_type mcms_erp.account_type NOT NULL,
    parent_account_id bigint,
    is_postable boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: gl_account_account_id_seq; Type: SEQUENCE; Schema: mcms_erp; Owner: -
--

CREATE SEQUENCE mcms_erp.gl_account_account_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: gl_account_account_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_erp; Owner: -
--

ALTER SEQUENCE mcms_erp.gl_account_account_id_seq OWNED BY mcms_erp.gl_account.account_id;


--
-- Name: goods_receipt; Type: TABLE; Schema: mcms_erp; Owner: -
--

CREATE TABLE mcms_erp.goods_receipt (
    grn_id bigint NOT NULL,
    grn_no text NOT NULL,
    po_id bigint,
    supplier_id bigint NOT NULL,
    received_by bigint NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    status mcms_erp.grn_status DEFAULT 'received'::mcms_erp.grn_status NOT NULL,
    notes text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: goods_receipt_grn_id_seq; Type: SEQUENCE; Schema: mcms_erp; Owner: -
--

CREATE SEQUENCE mcms_erp.goods_receipt_grn_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: goods_receipt_grn_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_erp; Owner: -
--

ALTER SEQUENCE mcms_erp.goods_receipt_grn_id_seq OWNED BY mcms_erp.goods_receipt.grn_id;


--
-- Name: goods_receipt_line; Type: TABLE; Schema: mcms_erp; Owner: -
--

CREATE TABLE mcms_erp.goods_receipt_line (
    line_id bigint NOT NULL,
    grn_id bigint NOT NULL,
    po_line_id bigint,
    item_id bigint,
    drug_item_id bigint,
    qty_received integer NOT NULL,
    lot_number text,
    expiration_date date,
    unit_cost numeric(12,2),
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT goods_receipt_line_qty_received_check CHECK ((qty_received > 0))
);


--
-- Name: goods_receipt_line_line_id_seq; Type: SEQUENCE; Schema: mcms_erp; Owner: -
--

CREATE SEQUENCE mcms_erp.goods_receipt_line_line_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: goods_receipt_line_line_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_erp; Owner: -
--

ALTER SEQUENCE mcms_erp.goods_receipt_line_line_id_seq OWNED BY mcms_erp.goods_receipt_line.line_id;


--
-- Name: inventory_item; Type: TABLE; Schema: mcms_erp; Owner: -
--

CREATE TABLE mcms_erp.inventory_item (
    item_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    type mcms_erp.item_type DEFAULT 'other'::mcms_erp.item_type NOT NULL,
    unit text,
    reorder_level integer DEFAULT 0 NOT NULL,
    reorder_qty integer DEFAULT 0 NOT NULL,
    cost_per_unit numeric(12,2) DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: inventory_item_item_id_seq; Type: SEQUENCE; Schema: mcms_erp; Owner: -
--

CREATE SEQUENCE mcms_erp.inventory_item_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_item_item_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_erp; Owner: -
--

ALTER SEQUENCE mcms_erp.inventory_item_item_id_seq OWNED BY mcms_erp.inventory_item.item_id;


--
-- Name: inventory_stock; Type: TABLE; Schema: mcms_erp; Owner: -
--

CREATE TABLE mcms_erp.inventory_stock (
    stock_id bigint NOT NULL,
    item_id bigint NOT NULL,
    department_id bigint NOT NULL,
    qty_on_hand integer NOT NULL,
    qty_reserved integer DEFAULT 0 NOT NULL,
    last_count_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT inventory_stock_qty_on_hand_check CHECK ((qty_on_hand >= 0))
);


--
-- Name: inventory_stock_stock_id_seq; Type: SEQUENCE; Schema: mcms_erp; Owner: -
--

CREATE SEQUENCE mcms_erp.inventory_stock_stock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inventory_stock_stock_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_erp; Owner: -
--

ALTER SEQUENCE mcms_erp.inventory_stock_stock_id_seq OWNED BY mcms_erp.inventory_stock.stock_id;


--
-- Name: purchase_order; Type: TABLE; Schema: mcms_erp; Owner: -
--

CREATE TABLE mcms_erp.purchase_order (
    po_id bigint NOT NULL,
    po_no text NOT NULL,
    supplier_id bigint NOT NULL,
    requested_by bigint NOT NULL,
    approved_by bigint,
    status mcms_erp.po_status DEFAULT 'draft'::mcms_erp.po_status NOT NULL,
    expected_at date,
    ordered_at timestamp with time zone DEFAULT now() NOT NULL,
    received_at timestamp with time zone,
    closed_at timestamp with time zone,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: purchase_order_line; Type: TABLE; Schema: mcms_erp; Owner: -
--

CREATE TABLE mcms_erp.purchase_order_line (
    line_id bigint NOT NULL,
    po_id bigint NOT NULL,
    item_id bigint,
    drug_item_id bigint,
    item_description text NOT NULL,
    qty integer NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    qty_received integer DEFAULT 0 NOT NULL,
    line_total numeric(14,2) GENERATED ALWAYS AS (((qty)::numeric * unit_price)) STORED,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT purchase_order_line_check CHECK (((item_id IS NOT NULL) OR (drug_item_id IS NOT NULL))),
    CONSTRAINT purchase_order_line_qty_check CHECK ((qty > 0)),
    CONSTRAINT purchase_order_line_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


--
-- Name: purchase_order_line_line_id_seq; Type: SEQUENCE; Schema: mcms_erp; Owner: -
--

CREATE SEQUENCE mcms_erp.purchase_order_line_line_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_order_line_line_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_erp; Owner: -
--

ALTER SEQUENCE mcms_erp.purchase_order_line_line_id_seq OWNED BY mcms_erp.purchase_order_line.line_id;


--
-- Name: purchase_order_po_id_seq; Type: SEQUENCE; Schema: mcms_erp; Owner: -
--

CREATE SEQUENCE mcms_erp.purchase_order_po_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: purchase_order_po_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_erp; Owner: -
--

ALTER SEQUENCE mcms_erp.purchase_order_po_id_seq OWNED BY mcms_erp.purchase_order.po_id;


--
-- Name: stock_movement; Type: TABLE; Schema: mcms_erp; Owner: -
--

CREATE TABLE mcms_erp.stock_movement (
    movement_id bigint NOT NULL,
    item_id bigint NOT NULL,
    from_department_id bigint,
    to_department_id bigint,
    qty_delta integer NOT NULL,
    movement_type mcms_erp.move_type NOT NULL,
    reference_table text,
    reference_id bigint,
    performed_by bigint NOT NULL,
    performed_at timestamp with time zone DEFAULT now() NOT NULL,
    reason text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: stock_movement_movement_id_seq; Type: SEQUENCE; Schema: mcms_erp; Owner: -
--

CREATE SEQUENCE mcms_erp.stock_movement_movement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_movement_movement_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_erp; Owner: -
--

ALTER SEQUENCE mcms_erp.stock_movement_movement_id_seq OWNED BY mcms_erp.stock_movement.movement_id;


--
-- Name: supplier; Type: TABLE; Schema: mcms_erp; Owner: -
--

CREATE TABLE mcms_erp.supplier (
    supplier_id bigint NOT NULL,
    party_id bigint NOT NULL,
    supplier_code text NOT NULL,
    contact_user_id bigint,
    payment_terms_days integer DEFAULT 30 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: supplier_supplier_id_seq; Type: SEQUENCE; Schema: mcms_erp; Owner: -
--

CREATE SEQUENCE mcms_erp.supplier_supplier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supplier_supplier_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_erp; Owner: -
--

ALTER SEQUENCE mcms_erp.supplier_supplier_id_seq OWNED BY mcms_erp.supplier.supplier_id;


--
-- Name: v_department_stock; Type: VIEW; Schema: mcms_erp; Owner: -
--

CREATE VIEW mcms_erp.v_department_stock AS
 SELECT ii.item_id,
    ii.code,
    ii.name,
    ii.type,
    d.code AS dept_code,
    d.name AS dept_name,
    isk.qty_on_hand,
    isk.qty_reserved,
    (isk.qty_on_hand - isk.qty_reserved) AS qty_available,
    ii.reorder_level,
        CASE
            WHEN (isk.qty_on_hand <= ii.reorder_level) THEN 'REORDER'::text
            ELSE 'OK'::text
        END AS stock_state
   FROM ((mcms_erp.inventory_stock isk
     JOIN mcms_erp.inventory_item ii ON ((ii.item_id = isk.item_id)))
     JOIN mcms_hr.department d ON ((d.department_id = isk.department_id)));


--
-- Name: attendance; Type: TABLE; Schema: mcms_hr; Owner: -
--

CREATE TABLE mcms_hr.attendance (
    attendance_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    shift_id bigint,
    clock_in_at timestamp with time zone,
    clock_out_at timestamp with time zone,
    status mcms_hr.attendance_status DEFAULT 'present'::mcms_hr.attendance_status NOT NULL,
    note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT attendance_check CHECK (((clock_out_at IS NULL) OR (clock_in_at IS NULL) OR (clock_out_at > clock_in_at)))
);


--
-- Name: attendance_attendance_id_seq; Type: SEQUENCE; Schema: mcms_hr; Owner: -
--

CREATE SEQUENCE mcms_hr.attendance_attendance_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attendance_attendance_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_hr; Owner: -
--

ALTER SEQUENCE mcms_hr.attendance_attendance_id_seq OWNED BY mcms_hr.attendance.attendance_id;


--
-- Name: department_department_id_seq; Type: SEQUENCE; Schema: mcms_hr; Owner: -
--

CREATE SEQUENCE mcms_hr.department_department_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: department_department_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_hr; Owner: -
--

ALTER SEQUENCE mcms_hr.department_department_id_seq OWNED BY mcms_hr.department.department_id;


--
-- Name: employee; Type: TABLE; Schema: mcms_hr; Owner: -
--

CREATE TABLE mcms_hr.employee (
    employee_id bigint NOT NULL,
    party_id bigint NOT NULL,
    user_id bigint,
    employee_no text NOT NULL,
    primary_department_id bigint NOT NULL,
    role text NOT NULL,
    job_title text,
    specialisation text,
    license_number text,
    contract_type mcms_hr.contract_type DEFAULT 'permanent'::mcms_hr.contract_type NOT NULL,
    status mcms_hr.employment_status DEFAULT 'active'::mcms_hr.employment_status NOT NULL,
    hired_at date NOT NULL,
    terminated_at date,
    base_salary_monthly numeric(10,2),
    bank_account text,
    tax_number text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT employee_base_salary_monthly_check CHECK ((base_salary_monthly >= (0)::numeric))
);


--
-- Name: employee_department; Type: TABLE; Schema: mcms_hr; Owner: -
--

CREATE TABLE mcms_hr.employee_department (
    emp_dept_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    department_id bigint NOT NULL,
    role text NOT NULL,
    start_date date NOT NULL,
    end_date date,
    is_primary boolean DEFAULT false NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT employee_department_check CHECK (((end_date IS NULL) OR (end_date >= start_date)))
);


--
-- Name: employee_department_emp_dept_id_seq; Type: SEQUENCE; Schema: mcms_hr; Owner: -
--

CREATE SEQUENCE mcms_hr.employee_department_emp_dept_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employee_department_emp_dept_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_hr; Owner: -
--

ALTER SEQUENCE mcms_hr.employee_department_emp_dept_id_seq OWNED BY mcms_hr.employee_department.emp_dept_id;


--
-- Name: employee_employee_id_seq; Type: SEQUENCE; Schema: mcms_hr; Owner: -
--

CREATE SEQUENCE mcms_hr.employee_employee_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: employee_employee_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_hr; Owner: -
--

ALTER SEQUENCE mcms_hr.employee_employee_id_seq OWNED BY mcms_hr.employee.employee_id;


--
-- Name: leave_request; Type: TABLE; Schema: mcms_hr; Owner: -
--

CREATE TABLE mcms_hr.leave_request (
    leave_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    leave_type mcms_hr.leave_type NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    days_off integer NOT NULL,
    reason text,
    status mcms_hr.leave_status DEFAULT 'pending'::mcms_hr.leave_status NOT NULL,
    approved_by bigint,
    approved_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT leave_request_check CHECK ((end_date >= start_date))
);


--
-- Name: leave_request_leave_id_seq; Type: SEQUENCE; Schema: mcms_hr; Owner: -
--

CREATE SEQUENCE mcms_hr.leave_request_leave_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leave_request_leave_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_hr; Owner: -
--

ALTER SEQUENCE mcms_hr.leave_request_leave_id_seq OWNED BY mcms_hr.leave_request.leave_id;


--
-- Name: payroll_item; Type: TABLE; Schema: mcms_hr; Owner: -
--

CREATE TABLE mcms_hr.payroll_item (
    item_id bigint NOT NULL,
    period_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    base_amount numeric(10,2) NOT NULL,
    overtime_amount numeric(10,2) DEFAULT 0 NOT NULL,
    deduction_amount numeric(10,2) DEFAULT 0 NOT NULL,
    bonus_amount numeric(10,2) DEFAULT 0 NOT NULL,
    net_amount numeric(10,2) GENERATED ALWAYS AS ((((base_amount + overtime_amount) + bonus_amount) - deduction_amount)) STORED,
    is_paid boolean DEFAULT false NOT NULL,
    paid_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT payroll_item_base_amount_check CHECK ((base_amount >= (0)::numeric)),
    CONSTRAINT payroll_item_bonus_amount_check CHECK ((bonus_amount >= (0)::numeric)),
    CONSTRAINT payroll_item_deduction_amount_check CHECK ((deduction_amount >= (0)::numeric)),
    CONSTRAINT payroll_item_overtime_amount_check CHECK ((overtime_amount >= (0)::numeric))
);


--
-- Name: payroll_item_item_id_seq; Type: SEQUENCE; Schema: mcms_hr; Owner: -
--

CREATE SEQUENCE mcms_hr.payroll_item_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payroll_item_item_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_hr; Owner: -
--

ALTER SEQUENCE mcms_hr.payroll_item_item_id_seq OWNED BY mcms_hr.payroll_item.item_id;


--
-- Name: payroll_period; Type: TABLE; Schema: mcms_hr; Owner: -
--

CREATE TABLE mcms_hr.payroll_period (
    period_id bigint NOT NULL,
    code text NOT NULL,
    start_date date NOT NULL,
    end_date date NOT NULL,
    status mcms_hr.pay_status DEFAULT 'draft'::mcms_hr.pay_status NOT NULL,
    closed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT payroll_period_check CHECK ((end_date > start_date))
);


--
-- Name: payroll_period_period_id_seq; Type: SEQUENCE; Schema: mcms_hr; Owner: -
--

CREATE SEQUENCE mcms_hr.payroll_period_period_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: payroll_period_period_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_hr; Owner: -
--

ALTER SEQUENCE mcms_hr.payroll_period_period_id_seq OWNED BY mcms_hr.payroll_period.period_id;


--
-- Name: shift; Type: TABLE; Schema: mcms_hr; Owner: -
--

CREATE TABLE mcms_hr.shift (
    shift_id bigint NOT NULL,
    department_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    shift_type mcms_hr.shift_type NOT NULL,
    start_at timestamp with time zone NOT NULL,
    end_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT shift_check CHECK ((end_at > start_at))
);


--
-- Name: shift_shift_id_seq; Type: SEQUENCE; Schema: mcms_hr; Owner: -
--

CREATE SEQUENCE mcms_hr.shift_shift_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: shift_shift_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_hr; Owner: -
--

ALTER SEQUENCE mcms_hr.shift_shift_id_seq OWNED BY mcms_hr.shift.shift_id;


--
-- Name: v_payroll_summary; Type: VIEW; Schema: mcms_hr; Owner: -
--

CREATE VIEW mcms_hr.v_payroll_summary AS
 SELECT pp.code AS period,
    pp.start_date,
    pp.end_date,
    d.code AS dept_code,
    d.name AS dept_name,
    count(DISTINCT pi.employee_id) AS employees_in_period,
    sum(pi.base_amount) AS total_base,
    sum(pi.overtime_amount) AS total_overtime,
    sum(pi.bonus_amount) AS total_bonus,
    sum(pi.deduction_amount) AS total_deductions,
    sum(pi.net_amount) AS total_net,
    count(*) FILTER (WHERE pi.is_paid) AS paid_count
   FROM (((mcms_hr.payroll_period pp
     JOIN mcms_hr.payroll_item pi ON ((pi.period_id = pp.period_id)))
     JOIN mcms_hr.employee e ON ((e.employee_id = pi.employee_id)))
     LEFT JOIN mcms_hr.department d ON ((d.department_id = e.primary_department_id)))
  GROUP BY pp.code, pp.start_date, pp.end_date, d.code, d.name;


--
-- Name: admission; Type: TABLE; Schema: mcms_icu; Owner: -
--

CREATE TABLE mcms_icu.admission (
    admission_id bigint NOT NULL,
    encounter_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    mrn text NOT NULL,
    bed_id bigint,
    primary_physician_id bigint,
    attending_nurse_id bigint,
    status mcms_icu.icu_status DEFAULT 'admitted'::mcms_icu.icu_status NOT NULL,
    admit_diagnosis text,
    admit_reason text,
    admitted_at timestamp with time zone DEFAULT now() NOT NULL,
    discharged_at timestamp with time zone,
    discharge_destination text,
    expired_at timestamp with time zone,
    notes text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: admission_admission_id_seq; Type: SEQUENCE; Schema: mcms_icu; Owner: -
--

CREATE SEQUENCE mcms_icu.admission_admission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admission_admission_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_icu; Owner: -
--

ALTER SEQUENCE mcms_icu.admission_admission_id_seq OWNED BY mcms_icu.admission.admission_id;


--
-- Name: bed; Type: TABLE; Schema: mcms_icu; Owner: -
--

CREATE TABLE mcms_icu.bed (
    bed_id bigint NOT NULL,
    room_code text NOT NULL,
    bed_label text NOT NULL,
    department_id bigint NOT NULL,
    level integer,
    status mcms_icu.bed_status DEFAULT 'available'::mcms_icu.bed_status NOT NULL,
    has_ventilator boolean DEFAULT false NOT NULL,
    has_dialysis boolean DEFAULT false NOT NULL,
    is_isolation boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT bed_level_check CHECK ((level = ANY (ARRAY[1, 2, 3])))
);


--
-- Name: bed_bed_id_seq; Type: SEQUENCE; Schema: mcms_icu; Owner: -
--

CREATE SEQUENCE mcms_icu.bed_bed_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bed_bed_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_icu; Owner: -
--

ALTER SEQUENCE mcms_icu.bed_bed_id_seq OWNED BY mcms_icu.bed.bed_id;


--
-- Name: bed_stay; Type: TABLE; Schema: mcms_icu; Owner: -
--

CREATE TABLE mcms_icu.bed_stay (
    stay_id bigint NOT NULL,
    admission_id bigint NOT NULL,
    bed_id bigint NOT NULL,
    assigned_at timestamp with time zone DEFAULT now() NOT NULL,
    released_at timestamp with time zone,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: bed_stay_stay_id_seq; Type: SEQUENCE; Schema: mcms_icu; Owner: -
--

CREATE SEQUENCE mcms_icu.bed_stay_stay_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bed_stay_stay_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_icu; Owner: -
--

ALTER SEQUENCE mcms_icu.bed_stay_stay_id_seq OWNED BY mcms_icu.bed_stay.stay_id;


--
-- Name: score; Type: TABLE; Schema: mcms_icu; Owner: -
--

CREATE TABLE mcms_icu.score (
    score_id bigint NOT NULL,
    admission_id bigint NOT NULL,
    type text NOT NULL,
    raw integer,
    computed_value numeric(5,2),
    interpretation text,
    assessed_at timestamp with time zone DEFAULT now() NOT NULL,
    assessed_by bigint,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: score_score_id_seq; Type: SEQUENCE; Schema: mcms_icu; Owner: -
--

CREATE SEQUENCE mcms_icu.score_score_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: score_score_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_icu; Owner: -
--

ALTER SEQUENCE mcms_icu.score_score_id_seq OWNED BY mcms_icu.score.score_id;


--
-- Name: support_session; Type: TABLE; Schema: mcms_icu; Owner: -
--

CREATE TABLE mcms_icu.support_session (
    session_id bigint NOT NULL,
    admission_id bigint NOT NULL,
    support_kind mcms_icu.support_kind NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    stopped_at timestamp with time zone,
    parameters jsonb,
    stopped_reason text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: support_session_session_id_seq; Type: SEQUENCE; Schema: mcms_icu; Owner: -
--

CREATE SEQUENCE mcms_icu.support_session_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: support_session_session_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_icu; Owner: -
--

ALTER SEQUENCE mcms_icu.support_session_session_id_seq OWNED BY mcms_icu.support_session.session_id;


--
-- Name: v_bed_board; Type: VIEW; Schema: mcms_icu; Owner: -
--

CREATE VIEW mcms_icu.v_bed_board AS
 SELECT b.bed_id,
    b.room_code,
    b.bed_label,
    b.status,
    b.level,
    b.has_ventilator,
    b.has_dialysis,
    d.code AS dept_code,
    a.patient_id,
    pt.mrn,
    p.display_name AS patient_name,
    a.admitted_at
   FROM ((((mcms_icu.bed b
     JOIN mcms_hr.department d ON ((d.department_id = b.department_id)))
     LEFT JOIN mcms_icu.admission a ON (((a.bed_id = b.bed_id) AND (a.status = ANY (ARRAY['admitted'::mcms_icu.icu_status, 'active'::mcms_icu.icu_status])))))
     LEFT JOIN mcms_emr.patient pt ON ((pt.patient_id = a.patient_id)))
     LEFT JOIN mcms_core.party p ON ((p.party_id = pt.party_id)));


--
-- Name: vitals_stream; Type: TABLE; Schema: mcms_icu; Owner: -
--

CREATE TABLE mcms_icu.vitals_stream (
    stream_id bigint NOT NULL,
    admission_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    charted_by bigint,
    temp_c numeric(4,1),
    hr_bpm integer,
    rr_pm integer,
    sbp_mmhg integer,
    dbp_mmhg integer,
    mbp_mmhg integer,
    spo2_pct numeric(4,1),
    etco2_mmhg integer,
    cvp_cmh2o integer,
    urine_ml_hour integer,
    gcs integer,
    pupils text,
    notes text,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT vitals_stream_gcs_check CHECK (((gcs >= 3) AND (gcs <= 15)))
);


--
-- Name: vitals_stream_stream_id_seq; Type: SEQUENCE; Schema: mcms_icu; Owner: -
--

CREATE SEQUENCE mcms_icu.vitals_stream_stream_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vitals_stream_stream_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_icu; Owner: -
--

ALTER SEQUENCE mcms_icu.vitals_stream_stream_id_seq OWNED BY mcms_icu.vitals_stream.stream_id;


--
-- Name: lab_order; Type: TABLE; Schema: mcms_lab; Owner: -
--

CREATE TABLE mcms_lab.lab_order (
    order_id bigint NOT NULL,
    order_no text NOT NULL,
    encounter_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    mrn text NOT NULL,
    requested_by bigint NOT NULL,
    order_priority mcms_lab.order_priority DEFAULT 'routine'::mcms_lab.order_priority NOT NULL,
    panel_id bigint,
    clinical_indication text,
    requested_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: lab_order_order_id_seq; Type: SEQUENCE; Schema: mcms_lab; Owner: -
--

CREATE SEQUENCE mcms_lab.lab_order_order_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lab_order_order_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_lab; Owner: -
--

ALTER SEQUENCE mcms_lab.lab_order_order_id_seq OWNED BY mcms_lab.lab_order.order_id;


--
-- Name: result; Type: TABLE; Schema: mcms_lab; Owner: -
--

CREATE TABLE mcms_lab.result (
    result_id bigint NOT NULL,
    sample_id bigint NOT NULL,
    test_id bigint NOT NULL,
    value_text text,
    value_numeric numeric(14,4),
    unit text,
    ref_range text,
    flag mcms_lab.result_flag DEFAULT 'pending'::mcms_lab.result_flag NOT NULL,
    analysed_by bigint,
    analysed_at timestamp with time zone,
    verified_by bigint,
    verified_at timestamp with time zone,
    rejected_at timestamp with time zone,
    rejected_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: result_result_id_seq; Type: SEQUENCE; Schema: mcms_lab; Owner: -
--

CREATE SEQUENCE mcms_lab.result_result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: result_result_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_lab; Owner: -
--

ALTER SEQUENCE mcms_lab.result_result_id_seq OWNED BY mcms_lab.result.result_id;


--
-- Name: sample; Type: TABLE; Schema: mcms_lab; Owner: -
--

CREATE TABLE mcms_lab.sample (
    sample_id bigint NOT NULL,
    sample_no text NOT NULL,
    lab_order_id bigint NOT NULL,
    test_ids bigint[],
    specimen_type mcms_lab.specimen_type NOT NULL,
    volume_collected numeric(6,2),
    collected_at timestamp with time zone DEFAULT now() NOT NULL,
    collected_by bigint,
    received_at timestamp with time zone,
    received_by bigint,
    status mcms_lab.sample_status DEFAULT 'collected'::mcms_lab.sample_status NOT NULL,
    rejected_reason text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: sample_sample_id_seq; Type: SEQUENCE; Schema: mcms_lab; Owner: -
--

CREATE SEQUENCE mcms_lab.sample_sample_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sample_sample_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_lab; Owner: -
--

ALTER SEQUENCE mcms_lab.sample_sample_id_seq OWNED BY mcms_lab.sample.sample_id;


--
-- Name: test_catalog; Type: TABLE; Schema: mcms_lab; Owner: -
--

CREATE TABLE mcms_lab.test_catalog (
    test_id bigint NOT NULL,
    loinc_code text,
    name text NOT NULL,
    category text,
    specimen_type mcms_lab.specimen_type NOT NULL,
    volume_required numeric(6,2),
    unit text,
    ref_low numeric,
    ref_high numeric,
    turnaround_minutes integer,
    is_active boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: test_catalog_test_id_seq; Type: SEQUENCE; Schema: mcms_lab; Owner: -
--

CREATE SEQUENCE mcms_lab.test_catalog_test_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_catalog_test_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_lab; Owner: -
--

ALTER SEQUENCE mcms_lab.test_catalog_test_id_seq OWNED BY mcms_lab.test_catalog.test_id;


--
-- Name: test_panel; Type: TABLE; Schema: mcms_lab; Owner: -
--

CREATE TABLE mcms_lab.test_panel (
    panel_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: test_panel_item; Type: TABLE; Schema: mcms_lab; Owner: -
--

CREATE TABLE mcms_lab.test_panel_item (
    ppi_id bigint NOT NULL,
    panel_id bigint NOT NULL,
    test_id bigint NOT NULL,
    sort_order integer DEFAULT 0,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: test_panel_item_ppi_id_seq; Type: SEQUENCE; Schema: mcms_lab; Owner: -
--

CREATE SEQUENCE mcms_lab.test_panel_item_ppi_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_panel_item_ppi_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_lab; Owner: -
--

ALTER SEQUENCE mcms_lab.test_panel_item_ppi_id_seq OWNED BY mcms_lab.test_panel_item.ppi_id;


--
-- Name: test_panel_panel_id_seq; Type: SEQUENCE; Schema: mcms_lab; Owner: -
--

CREATE SEQUENCE mcms_lab.test_panel_panel_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_panel_panel_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_lab; Owner: -
--

ALTER SEQUENCE mcms_lab.test_panel_panel_id_seq OWNED BY mcms_lab.test_panel.panel_id;


--
-- Name: v_tat; Type: VIEW; Schema: mcms_lab; Owner: -
--

CREATE VIEW mcms_lab.v_tat AS
 WITH base AS (
         SELECT tc.test_id,
            tc.name AS test_name,
            tc.category,
            ((EXTRACT(epoch FROM (r.verified_at - s.collected_at)) / (60)::numeric))::numeric(10,1) AS minutes
           FROM ((mcms_lab.result r
             JOIN mcms_lab.sample s ON ((s.sample_id = r.sample_id)))
             JOIN mcms_lab.test_catalog tc ON ((tc.test_id = r.test_id)))
          WHERE (r.verified_at IS NOT NULL)
        )
 SELECT test_id,
    test_name,
    category,
    count(*) AS results_count,
    avg(minutes) AS avg_minutes,
    percentile_cont((0.5)::double precision) WITHIN GROUP (ORDER BY ((minutes)::double precision)) AS p50_minutes,
    percentile_cont((0.95)::double precision) WITHIN GROUP (ORDER BY ((minutes)::double precision)) AS p95_minutes
   FROM base
  GROUP BY test_id, test_name, category;


--
-- Name: cot; Type: TABLE; Schema: mcms_nursery; Owner: -
--

CREATE TABLE mcms_nursery.cot (
    cot_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    department_id bigint,
    is_incubator boolean DEFAULT false NOT NULL,
    has_phototherapy boolean DEFAULT false NOT NULL,
    status mcms_nursery.cot_status DEFAULT 'available'::mcms_nursery.cot_status NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: cot_cot_id_seq; Type: SEQUENCE; Schema: mcms_nursery; Owner: -
--

CREATE SEQUENCE mcms_nursery.cot_cot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cot_cot_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_nursery; Owner: -
--

ALTER SEQUENCE mcms_nursery.cot_cot_id_seq OWNED BY mcms_nursery.cot.cot_id;


--
-- Name: growth_entry; Type: TABLE; Schema: mcms_nursery; Owner: -
--

CREATE TABLE mcms_nursery.growth_entry (
    entry_id bigint NOT NULL,
    neonate_id bigint NOT NULL,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    weight_g integer,
    length_cm numeric(5,2),
    head_circ_cm numeric(5,2),
    temperature_c numeric(4,1),
    feeding_type text,
    feed_volume_ml integer,
    nurse_user_id bigint,
    notes text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: growth_entry_entry_id_seq; Type: SEQUENCE; Schema: mcms_nursery; Owner: -
--

CREATE SEQUENCE mcms_nursery.growth_entry_entry_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: growth_entry_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_nursery; Owner: -
--

ALTER SEQUENCE mcms_nursery.growth_entry_entry_id_seq OWNED BY mcms_nursery.growth_entry.entry_id;


--
-- Name: neonate_record; Type: TABLE; Schema: mcms_nursery; Owner: -
--

CREATE TABLE mcms_nursery.neonate_record (
    neonate_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    mother_party_id bigint,
    cot_id bigint,
    gestational_age_weeks numeric(4,1),
    birth_weight_g integer,
    apgar_1min integer,
    apgar_5min integer,
    admitted_at timestamp with time zone DEFAULT now() NOT NULL,
    discharged_at timestamp with time zone,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT neonate_record_apgar_1min_check CHECK (((apgar_1min >= 0) AND (apgar_1min <= 10))),
    CONSTRAINT neonate_record_apgar_5min_check CHECK (((apgar_5min >= 0) AND (apgar_5min <= 10)))
);


--
-- Name: neonate_record_neonate_id_seq; Type: SEQUENCE; Schema: mcms_nursery; Owner: -
--

CREATE SEQUENCE mcms_nursery.neonate_record_neonate_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: neonate_record_neonate_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_nursery; Owner: -
--

ALTER SEQUENCE mcms_nursery.neonate_record_neonate_id_seq OWNED BY mcms_nursery.neonate_record.neonate_id;


--
-- Name: session; Type: TABLE; Schema: mcms_physio; Owner: -
--

CREATE TABLE mcms_physio.session (
    session_id bigint NOT NULL,
    plan_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    therapist_user_id bigint NOT NULL,
    therapy_id bigint,
    room_id bigint,
    sessions_in_seq integer,
    scheduled_at timestamp with time zone NOT NULL,
    duration_minutes integer DEFAULT 30 NOT NULL,
    pain_before_score integer,
    pain_after_score integer,
    rom_before text,
    rom_after text,
    subjective text,
    interventions text,
    status mcms_physio.session_status DEFAULT 'scheduled'::mcms_physio.session_status NOT NULL,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT session_pain_after_score_check CHECK (((pain_after_score IS NULL) OR ((pain_after_score >= 0) AND (pain_after_score <= 10)))),
    CONSTRAINT session_pain_before_score_check CHECK (((pain_before_score IS NULL) OR ((pain_before_score >= 0) AND (pain_before_score <= 10))))
);


--
-- Name: session_session_id_seq; Type: SEQUENCE; Schema: mcms_physio; Owner: -
--

CREATE SEQUENCE mcms_physio.session_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: session_session_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_physio; Owner: -
--

ALTER SEQUENCE mcms_physio.session_session_id_seq OWNED BY mcms_physio.session.session_id;


--
-- Name: therapy_catalog; Type: TABLE; Schema: mcms_physio; Owner: -
--

CREATE TABLE mcms_physio.therapy_catalog (
    therapy_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    type mcms_physio.therapy_type NOT NULL,
    body_region text,
    duration_minutes integer NOT NULL,
    equipment text[],
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT therapy_catalog_duration_minutes_check CHECK ((duration_minutes > 0))
);


--
-- Name: therapy_catalog_therapy_id_seq; Type: SEQUENCE; Schema: mcms_physio; Owner: -
--

CREATE SEQUENCE mcms_physio.therapy_catalog_therapy_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: therapy_catalog_therapy_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_physio; Owner: -
--

ALTER SEQUENCE mcms_physio.therapy_catalog_therapy_id_seq OWNED BY mcms_physio.therapy_catalog.therapy_id;


--
-- Name: treatment_plan; Type: TABLE; Schema: mcms_physio; Owner: -
--

CREATE TABLE mcms_physio.treatment_plan (
    plan_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    encounter_id bigint,
    therapist_user_id bigint NOT NULL,
    diagnosis text,
    treatment_goals text,
    sessions_planned integer DEFAULT 1 NOT NULL,
    sessions_completed integer DEFAULT 0 NOT NULL,
    frequency text,
    starts_on date,
    ends_on date,
    status mcms_physio.plan_status DEFAULT 'active'::mcms_physio.plan_status NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: treatment_plan_plan_id_seq; Type: SEQUENCE; Schema: mcms_physio; Owner: -
--

CREATE SEQUENCE mcms_physio.treatment_plan_plan_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: treatment_plan_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_physio; Owner: -
--

ALTER SEQUENCE mcms_physio.treatment_plan_plan_id_seq OWNED BY mcms_physio.treatment_plan.plan_id;


--
-- Name: v_session_throughput; Type: VIEW; Schema: mcms_physio; Owner: -
--

CREATE VIEW mcms_physio.v_session_throughput AS
 SELECT tp.plan_id,
    pt.mrn,
    p.display_name AS patient_name,
    u.username AS therapist,
    tp.diagnosis,
    tp.sessions_planned,
    tp.sessions_completed,
    tp.status,
    count(s.session_id) FILTER (WHERE (s.status = 'completed'::mcms_physio.session_status)) AS completed_sessions_count,
    count(s.session_id) FILTER (WHERE (s.status = 'no_show'::mcms_physio.session_status)) AS no_shows
   FROM ((((mcms_physio.treatment_plan tp
     JOIN mcms_emr.patient pt ON ((pt.patient_id = tp.patient_id)))
     JOIN mcms_core.party p ON ((p.party_id = pt.party_id)))
     LEFT JOIN mcms_core.app_user u ON ((u.user_id = tp.therapist_user_id)))
     LEFT JOIN mcms_physio.session s ON ((s.plan_id = tp.plan_id)))
  GROUP BY tp.plan_id, pt.mrn, p.display_name, u.username, tp.diagnosis, tp.sessions_planned, tp.sessions_completed, tp.status;


--
-- Name: exam_catalog; Type: TABLE; Schema: mcms_rad; Owner: -
--

CREATE TABLE mcms_rad.exam_catalog (
    exam_id bigint NOT NULL,
    snomed_code text,
    name text NOT NULL,
    body_part text,
    default_modality mcms_rad.modality_type NOT NULL,
    contrast_used boolean DEFAULT false NOT NULL,
    duration_minutes integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT exam_catalog_duration_minutes_check CHECK ((duration_minutes > 0))
);


--
-- Name: exam_catalog_exam_id_seq; Type: SEQUENCE; Schema: mcms_rad; Owner: -
--

CREATE SEQUENCE mcms_rad.exam_catalog_exam_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exam_catalog_exam_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_rad; Owner: -
--

ALTER SEQUENCE mcms_rad.exam_catalog_exam_id_seq OWNED BY mcms_rad.exam_catalog.exam_id;


--
-- Name: image_instance; Type: TABLE; Schema: mcms_rad; Owner: -
--

CREATE TABLE mcms_rad.image_instance (
    image_id bigint NOT NULL,
    study_id bigint NOT NULL,
    series_number integer NOT NULL,
    instance_number integer NOT NULL,
    sop_instance_uid text,
    image_type mcms_rad.image_type DEFAULT 'dicom'::mcms_rad.image_type NOT NULL,
    storage_uri text NOT NULL,
    rows integer,
    columns integer,
    bits_allocated integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: image_instance_image_id_seq; Type: SEQUENCE; Schema: mcms_rad; Owner: -
--

CREATE SEQUENCE mcms_rad.image_instance_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: image_instance_image_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_rad; Owner: -
--

ALTER SEQUENCE mcms_rad.image_instance_image_id_seq OWNED BY mcms_rad.image_instance.image_id;


--
-- Name: modality_suite; Type: TABLE; Schema: mcms_rad; Owner: -
--

CREATE TABLE mcms_rad.modality_suite (
    suite_id bigint NOT NULL,
    department_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    modality mcms_rad.modality_type NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: modality_suite_suite_id_seq; Type: SEQUENCE; Schema: mcms_rad; Owner: -
--

CREATE SEQUENCE mcms_rad.modality_suite_suite_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: modality_suite_suite_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_rad; Owner: -
--

ALTER SEQUENCE mcms_rad.modality_suite_suite_id_seq OWNED BY mcms_rad.modality_suite.suite_id;


--
-- Name: study_request; Type: TABLE; Schema: mcms_rad; Owner: -
--

CREATE TABLE mcms_rad.study_request (
    study_id bigint NOT NULL,
    accession_no text NOT NULL,
    encounter_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    mrn text NOT NULL,
    exam_id bigint NOT NULL,
    suite_id bigint,
    requested_by bigint NOT NULL,
    priority mcms_rad.order_priority DEFAULT 'routine'::mcms_rad.order_priority NOT NULL,
    clinical_indication text,
    status mcms_rad.study_status DEFAULT 'requested'::mcms_rad.study_status NOT NULL,
    scheduled_at timestamp with time zone,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    image_count integer,
    radiation_dose_msv numeric(7,3),
    contrast_data jsonb,
    findings text,
    impression text,
    reported_by bigint,
    reported_at timestamp with time zone,
    verified_by bigint,
    verified_at timestamp with time zone,
    cancelled_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT study_request_image_count_check CHECK (((image_count IS NULL) OR (image_count >= 0)))
);


--
-- Name: study_request_study_id_seq; Type: SEQUENCE; Schema: mcms_rad; Owner: -
--

CREATE SEQUENCE mcms_rad.study_request_study_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: study_request_study_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_rad; Owner: -
--

ALTER SEQUENCE mcms_rad.study_request_study_id_seq OWNED BY mcms_rad.study_request.study_id;


--
-- Name: v_study_pipeline; Type: VIEW; Schema: mcms_rad; Owner: -
--

CREATE VIEW mcms_rad.v_study_pipeline AS
 SELECT sr.study_id,
    sr.accession_no,
    p.display_name AS patient_name,
    pt.mrn,
    ec.name AS exam,
    ms.code AS suite,
    sr.status,
    sr.priority,
    sr.requested_by,
    sr.scheduled_at,
    sr.started_at,
    sr.completed_at,
    sr.verified_at
   FROM ((((mcms_rad.study_request sr
     JOIN mcms_emr.patient pt ON ((pt.patient_id = sr.patient_id)))
     JOIN mcms_core.party p ON ((p.party_id = pt.party_id)))
     JOIN mcms_rad.exam_catalog ec ON ((ec.exam_id = sr.exam_id)))
     LEFT JOIN mcms_rad.modality_suite ms ON ((ms.suite_id = sr.suite_id)))
  WHERE (sr.status <> ALL (ARRAY['verified'::mcms_rad.study_status, 'cancelled'::mcms_rad.study_status]));


--
-- Name: administration; Type: TABLE; Schema: mcms_rx; Owner: -
--

CREATE TABLE mcms_rx.administration (
    administer_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    med_order_id bigint,
    drug_item_id bigint NOT NULL,
    dose_given text NOT NULL,
    dose_at timestamp with time zone DEFAULT now() NOT NULL,
    administered_by bigint NOT NULL,
    witnessed_by bigint,
    site text,
    notes text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: administration_administer_id_seq; Type: SEQUENCE; Schema: mcms_rx; Owner: -
--

CREATE SEQUENCE mcms_rx.administration_administer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: administration_administer_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_rx; Owner: -
--

ALTER SEQUENCE mcms_rx.administration_administer_id_seq OWNED BY mcms_rx.administration.administer_id;


--
-- Name: dispensation; Type: TABLE; Schema: mcms_rx; Owner: -
--

CREATE TABLE mcms_rx.dispensation (
    dispensation_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    mrn text NOT NULL,
    encounter_id bigint,
    med_order_id bigint,
    drug_item_id bigint NOT NULL,
    lot_id bigint,
    quantity integer NOT NULL,
    dispensed_at timestamp with time zone DEFAULT now() NOT NULL,
    dispensed_by bigint NOT NULL,
    instructions text,
    notes text,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT dispensation_quantity_check CHECK ((quantity > 0))
);


--
-- Name: dispensation_dispensation_id_seq; Type: SEQUENCE; Schema: mcms_rx; Owner: -
--

CREATE SEQUENCE mcms_rx.dispensation_dispensation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dispensation_dispensation_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_rx; Owner: -
--

ALTER SEQUENCE mcms_rx.dispensation_dispensation_id_seq OWNED BY mcms_rx.dispensation.dispensation_id;


--
-- Name: drug_alternative; Type: TABLE; Schema: mcms_rx; Owner: -
--

CREATE TABLE mcms_rx.drug_alternative (
    alternative_id bigint NOT NULL,
    drug_item_id bigint NOT NULL,
    alt_drug_item_id bigint NOT NULL,
    reason text,
    is_generic_equiv boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_alt_distinct CHECK ((drug_item_id <> alt_drug_item_id))
);


--
-- Name: drug_alternative_alternative_id_seq; Type: SEQUENCE; Schema: mcms_rx; Owner: -
--

CREATE SEQUENCE mcms_rx.drug_alternative_alternative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drug_alternative_alternative_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_rx; Owner: -
--

ALTER SEQUENCE mcms_rx.drug_alternative_alternative_id_seq OWNED BY mcms_rx.drug_alternative.alternative_id;


--
-- Name: drug_interaction; Type: TABLE; Schema: mcms_rx; Owner: -
--

CREATE TABLE mcms_rx.drug_interaction (
    interaction_id bigint NOT NULL,
    drug_item_id_a bigint NOT NULL,
    drug_item_id_b bigint NOT NULL,
    severity mcms_rx.interaction_severity DEFAULT 'moderate'::mcms_rx.interaction_severity NOT NULL,
    mechanism text,
    clinical_effect text,
    management text,
    source_ref text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT ck_interaction_distinct CHECK ((drug_item_id_a <> drug_item_id_b))
);


--
-- Name: drug_interaction_interaction_id_seq; Type: SEQUENCE; Schema: mcms_rx; Owner: -
--

CREATE SEQUENCE mcms_rx.drug_interaction_interaction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drug_interaction_interaction_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_rx; Owner: -
--

ALTER SEQUENCE mcms_rx.drug_interaction_interaction_id_seq OWNED BY mcms_rx.drug_interaction.interaction_id;


--
-- Name: drug_item; Type: TABLE; Schema: mcms_rx; Owner: -
--

CREATE TABLE mcms_rx.drug_item (
    drug_item_id bigint NOT NULL,
    generic_name text NOT NULL,
    brand_name text,
    drug_class mcms_rx.drug_class DEFAULT 'other'::mcms_rx.drug_class NOT NULL,
    form text,
    strength text,
    unit text,
    atc_code text,
    controlled_substance boolean DEFAULT false NOT NULL,
    requires_cold_chain boolean DEFAULT false NOT NULL,
    manufacturer text,
    reorder_level integer DEFAULT 10 NOT NULL,
    reorder_qty integer DEFAULT 50 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    cost_per_unit numeric(10,2) DEFAULT 0 NOT NULL,
    sale_price_per_unit numeric(10,2) DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    rxnorm_code text,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: drug_item_drug_item_id_seq; Type: SEQUENCE; Schema: mcms_rx; Owner: -
--

CREATE SEQUENCE mcms_rx.drug_item_drug_item_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drug_item_drug_item_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_rx; Owner: -
--

ALTER SEQUENCE mcms_rx.drug_item_drug_item_id_seq OWNED BY mcms_rx.drug_item.drug_item_id;


--
-- Name: drug_lot; Type: TABLE; Schema: mcms_rx; Owner: -
--

CREATE TABLE mcms_rx.drug_lot (
    lot_id bigint NOT NULL,
    drug_item_id bigint NOT NULL,
    lot_number text NOT NULL,
    received_qty integer NOT NULL,
    on_hand_qty integer NOT NULL,
    manufactured_on date,
    expires_on date NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    supplier_party_id bigint,
    purchase_order_id bigint,
    unit_cost numeric(10,2) NOT NULL,
    status mcms_rx.lot_status DEFAULT 'on_hand'::mcms_rx.lot_status NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT drug_lot_on_hand_qty_check CHECK ((on_hand_qty >= 0)),
    CONSTRAINT drug_lot_received_qty_check CHECK ((received_qty > 0)),
    CONSTRAINT drug_lot_unit_cost_check CHECK ((unit_cost >= (0)::numeric))
);


--
-- Name: drug_lot_lot_id_seq; Type: SEQUENCE; Schema: mcms_rx; Owner: -
--

CREATE SEQUENCE mcms_rx.drug_lot_lot_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: drug_lot_lot_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_rx; Owner: -
--

ALTER SEQUENCE mcms_rx.drug_lot_lot_id_seq OWNED BY mcms_rx.drug_lot.lot_id;


--
-- Name: prescription; Type: TABLE; Schema: mcms_rx; Owner: -
--

CREATE TABLE mcms_rx.prescription (
    prescription_id bigint NOT NULL,
    encounter_id bigint,
    visit_id bigint,
    patient_id bigint NOT NULL,
    mrn text NOT NULL,
    prescriber_user_id bigint NOT NULL,
    drug_item_id bigint NOT NULL,
    dose text,
    route text,
    frequency text,
    duration_days integer,
    quantity numeric(10,2),
    notes text,
    status text DEFAULT 'draft'::text NOT NULL,
    interaction_severity text,
    controlled boolean DEFAULT false,
    signed_at timestamp with time zone,
    dispensed_at timestamp with time zone,
    facility_id bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT prescription_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'signed'::text, 'dispensed'::text, 'cancelled'::text])))
);


--
-- Name: prescription_prescription_id_seq; Type: SEQUENCE; Schema: mcms_rx; Owner: -
--

ALTER TABLE mcms_rx.prescription ALTER COLUMN prescription_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME mcms_rx.prescription_prescription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stock_movement; Type: TABLE; Schema: mcms_rx; Owner: -
--

CREATE TABLE mcms_rx.stock_movement (
    movement_id bigint NOT NULL,
    drug_item_id bigint NOT NULL,
    lot_id bigint,
    movement_type mcms_rx.move_type NOT NULL,
    qty_delta integer NOT NULL,
    balance_after integer NOT NULL,
    related_movement_id bigint,
    reason text,
    performed_by bigint,
    performed_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: stock_movement_movement_id_seq; Type: SEQUENCE; Schema: mcms_rx; Owner: -
--

CREATE SEQUENCE mcms_rx.stock_movement_movement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stock_movement_movement_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_rx; Owner: -
--

ALTER SEQUENCE mcms_rx.stock_movement_movement_id_seq OWNED BY mcms_rx.stock_movement.movement_id;


--
-- Name: v_low_stock; Type: VIEW; Schema: mcms_rx; Owner: -
--

CREATE VIEW mcms_rx.v_low_stock AS
 SELECT di.drug_item_id,
    di.generic_name,
    di.brand_name,
    COALESCE(sum(dl.on_hand_qty) FILTER (WHERE (dl.status = 'on_hand'::mcms_rx.lot_status)), (0)::bigint) AS qty_on_hand,
    di.reorder_level,
    di.reorder_qty,
    count(*) FILTER (WHERE (dl.lot_id IS NOT NULL)) AS lot_count,
    count(*) FILTER (WHERE ((dl.expires_on < (now())::date) AND (dl.status = 'on_hand'::mcms_rx.lot_status))) AS expiring_lots
   FROM (mcms_rx.drug_item di
     LEFT JOIN mcms_rx.drug_lot dl ON ((dl.drug_item_id = di.drug_item_id)))
  GROUP BY di.drug_item_id, di.generic_name, di.brand_name, di.reorder_level, di.reorder_qty
 HAVING (COALESCE(sum(dl.on_hand_qty) FILTER (WHERE (dl.status = 'on_hand'::mcms_rx.lot_status)), (0)::bigint) <= di.reorder_level);


--
-- Name: intra_op_vitals; Type: TABLE; Schema: mcms_surgical; Owner: -
--

CREATE TABLE mcms_surgical.intra_op_vitals (
    iov_id bigint NOT NULL,
    surgery_id bigint NOT NULL,
    recorded_at timestamp with time zone DEFAULT now() NOT NULL,
    recorded_by bigint,
    hr_bpm integer,
    sbp_mmhg integer,
    dbp_mmhg integer,
    spo2_pct numeric(4,1),
    etco2_mmhg integer,
    anaesthesia_depth integer,
    temp_c numeric(4,1),
    urine_ml integer,
    notes text,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT intra_op_vitals_hr_bpm_check CHECK (((hr_bpm >= 10) AND (hr_bpm <= 280)))
);


--
-- Name: intra_op_vitals_iov_id_seq; Type: SEQUENCE; Schema: mcms_surgical; Owner: -
--

CREATE SEQUENCE mcms_surgical.intra_op_vitals_iov_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intra_op_vitals_iov_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_surgical; Owner: -
--

ALTER SEQUENCE mcms_surgical.intra_op_vitals_iov_id_seq OWNED BY mcms_surgical.intra_op_vitals.iov_id;


--
-- Name: operating_room; Type: TABLE; Schema: mcms_surgical; Owner: -
--

CREATE TABLE mcms_surgical.operating_room (
    or_id bigint NOT NULL,
    department_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    room_type text NOT NULL,
    status mcms_surgical.or_status DEFAULT 'available'::mcms_surgical.or_status NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT operating_room_room_type_check CHECK ((room_type = ANY (ARRAY['general'::text, 'cardiac'::text, 'ortho'::text, 'neuro'::text, 'day_case'::text, 'hybrid'::text])))
);


--
-- Name: operating_room_or_id_seq; Type: SEQUENCE; Schema: mcms_surgical; Owner: -
--

CREATE SEQUENCE mcms_surgical.operating_room_or_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: operating_room_or_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_surgical; Owner: -
--

ALTER SEQUENCE mcms_surgical.operating_room_or_id_seq OWNED BY mcms_surgical.operating_room.or_id;


--
-- Name: post_op_note; Type: TABLE; Schema: mcms_surgical; Owner: -
--

CREATE TABLE mcms_surgical.post_op_note (
    pon_id bigint NOT NULL,
    surgery_id bigint NOT NULL,
    written_at timestamp with time zone DEFAULT now() NOT NULL,
    written_by bigint NOT NULL,
    recovery_room text,
    pain_score integer,
    findings text NOT NULL,
    instructions text,
    follow_up_days integer,
    is_signed boolean DEFAULT false,
    signed_at timestamp with time zone,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT post_op_note_pain_score_check CHECK (((pain_score >= 0) AND (pain_score <= 10)))
);


--
-- Name: post_op_note_pon_id_seq; Type: SEQUENCE; Schema: mcms_surgical; Owner: -
--

CREATE SEQUENCE mcms_surgical.post_op_note_pon_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_op_note_pon_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_surgical; Owner: -
--

ALTER SEQUENCE mcms_surgical.post_op_note_pon_id_seq OWNED BY mcms_surgical.post_op_note.pon_id;


--
-- Name: pre_op_checklist; Type: TABLE; Schema: mcms_surgical; Owner: -
--

CREATE TABLE mcms_surgical.pre_op_checklist (
    poc_id bigint NOT NULL,
    surgery_id bigint NOT NULL,
    fasting_confirmed boolean DEFAULT false,
    consent_signed boolean DEFAULT false,
    site_marked boolean DEFAULT false,
    antibiotics_given boolean DEFAULT false,
    iv_secured boolean DEFAULT false,
    labs_checked boolean DEFAULT false,
    imaging_checked boolean DEFAULT false,
    risk_score text,
    checklist_by bigint,
    completed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: pre_op_checklist_poc_id_seq; Type: SEQUENCE; Schema: mcms_surgical; Owner: -
--

CREATE SEQUENCE mcms_surgical.pre_op_checklist_poc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pre_op_checklist_poc_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_surgical; Owner: -
--

ALTER SEQUENCE mcms_surgical.pre_op_checklist_poc_id_seq OWNED BY mcms_surgical.pre_op_checklist.poc_id;


--
-- Name: procedure_catalog; Type: TABLE; Schema: mcms_surgical; Owner: -
--

CREATE TABLE mcms_surgical.procedure_catalog (
    proc_cat_id bigint NOT NULL,
    cpt_code text NOT NULL,
    name text NOT NULL,
    body_site text,
    default_duration_min integer,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: procedure_catalog_proc_cat_id_seq; Type: SEQUENCE; Schema: mcms_surgical; Owner: -
--

CREATE SEQUENCE mcms_surgical.procedure_catalog_proc_cat_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: procedure_catalog_proc_cat_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_surgical; Owner: -
--

ALTER SEQUENCE mcms_surgical.procedure_catalog_proc_cat_id_seq OWNED BY mcms_surgical.procedure_catalog.proc_cat_id;


--
-- Name: surgery; Type: TABLE; Schema: mcms_surgical; Owner: -
--

CREATE TABLE mcms_surgical.surgery (
    surgery_id bigint NOT NULL,
    operation_no text NOT NULL,
    encounter_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    or_id bigint NOT NULL,
    surgeon_user_id bigint NOT NULL,
    anaesthetist_user_id bigint,
    primary_dept_id bigint NOT NULL,
    procedure_id bigint NOT NULL,
    laterality text,
    status mcms_surgical.surg_status DEFAULT 'scheduled'::mcms_surgical.surg_status NOT NULL,
    scheduled_at timestamp with time zone,
    incision_at timestamp with time zone,
    closure_at timestamp with time zone,
    patient_in_or_at timestamp with time zone,
    patient_out_or_at timestamp with time zone,
    anaesthesia_type text,
    blood_loss_ml integer,
    tourniquet_time_minutes integer,
    complications text,
    notes text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    facility_id bigint DEFAULT 1 NOT NULL,
    CONSTRAINT surgery_blood_loss_ml_check CHECK ((blood_loss_ml >= 0)),
    CONSTRAINT surgery_laterality_check CHECK ((laterality = ANY (ARRAY['left'::text, 'right'::text, 'bilateral'::text, 'na'::text]))),
    CONSTRAINT surgery_tourniquet_time_minutes_check CHECK ((tourniquet_time_minutes >= 0))
);


--
-- Name: surgery_surgery_id_seq; Type: SEQUENCE; Schema: mcms_surgical; Owner: -
--

CREATE SEQUENCE mcms_surgical.surgery_surgery_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: surgery_surgery_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_surgical; Owner: -
--

ALTER SEQUENCE mcms_surgical.surgery_surgery_id_seq OWNED BY mcms_surgical.surgery.surgery_id;


--
-- Name: surgical_team; Type: TABLE; Schema: mcms_surgical; Owner: -
--

CREATE TABLE mcms_surgical.surgical_team (
    surg_team_id bigint NOT NULL,
    surgery_id bigint NOT NULL,
    user_id bigint NOT NULL,
    role mcms_surgical.team_role NOT NULL,
    joined_at timestamp with time zone,
    left_at timestamp with time zone,
    facility_id bigint DEFAULT 1 NOT NULL
);


--
-- Name: surgical_team_surg_team_id_seq; Type: SEQUENCE; Schema: mcms_surgical; Owner: -
--

CREATE SEQUENCE mcms_surgical.surgical_team_surg_team_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: surgical_team_surg_team_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_surgical; Owner: -
--

ALTER SEQUENCE mcms_surgical.surgical_team_surg_team_id_seq OWNED BY mcms_surgical.surgical_team.surg_team_id;


--
-- Name: v_surgery_board; Type: VIEW; Schema: mcms_surgical; Owner: -
--

CREATE VIEW mcms_surgical.v_surgery_board AS
 SELECT s.surgery_id,
    s.operation_no,
    pt.mrn,
    p.display_name AS patient_name,
    pc.cpt_code,
    pc.name AS procedure_name,
    or_room.code AS or_code,
    or_room.status AS or_status,
    s.laterality,
    s.status,
    s.scheduled_at,
    s.incision_at,
    s.closure_at,
    surg.display_name AS surgeon,
    an.display_name AS anaesthetist,
    d.code AS primary_dept
   FROM (((((((((mcms_surgical.surgery s
     JOIN mcms_emr.patient pt ON ((pt.patient_id = s.patient_id)))
     JOIN mcms_core.party p ON ((p.party_id = pt.party_id)))
     JOIN mcms_surgical.procedure_catalog pc ON ((pc.proc_cat_id = s.procedure_id)))
     JOIN mcms_surgical.operating_room or_room ON ((or_room.or_id = s.or_id)))
     LEFT JOIN mcms_core.app_user u_surg ON ((u_surg.user_id = s.surgeon_user_id)))
     LEFT JOIN mcms_core.party surg ON ((surg.party_id = u_surg.party_id)))
     LEFT JOIN mcms_core.app_user u_ane ON ((u_ane.user_id = s.anaesthetist_user_id)))
     LEFT JOIN mcms_core.party an ON ((an.party_id = u_ane.party_id)))
     LEFT JOIN mcms_hr.department d ON ((d.department_id = s.primary_dept_id)))
  WHERE (s.status <> ALL (ARRAY['completed'::mcms_surgical.surg_status, 'cancelled'::mcms_surgical.surg_status]))
  ORDER BY s.scheduled_at;


--
-- Name: visit; Type: TABLE; Schema: mcms_telemed; Owner: -
--

CREATE TABLE mcms_telemed.visit (
    visit_id bigint NOT NULL,
    patient_id bigint NOT NULL,
    mrn text NOT NULL,
    clinician_user_id bigint NOT NULL,
    encounter_id bigint,
    appointment_id bigint,
    mode text DEFAULT 'video'::text NOT NULL,
    status text DEFAULT 'in_progress'::text NOT NULL,
    subjective text,
    objective text,
    assessment text,
    plan text,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    ended_at timestamp with time zone,
    facility_id bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT visit_mode_check CHECK ((mode = ANY (ARRAY['video'::text, 'phone'::text, 'chat'::text]))),
    CONSTRAINT visit_status_check CHECK ((status = ANY (ARRAY['in_progress'::text, 'completed'::text, 'cancelled'::text])))
);


--
-- Name: visit_visit_id_seq; Type: SEQUENCE; Schema: mcms_telemed; Owner: -
--

ALTER TABLE mcms_telemed.visit ALTER COLUMN visit_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME mcms_telemed.visit_visit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: concept; Type: TABLE; Schema: mcms_terminology; Owner: -
--

CREATE TABLE mcms_terminology.concept (
    concept_id bigint NOT NULL,
    code_system text NOT NULL,
    code text NOT NULL,
    display text NOT NULL,
    display_ar text,
    synonyms text,
    source text,
    facility_id bigint DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: concept_concept_id_seq; Type: SEQUENCE; Schema: mcms_terminology; Owner: -
--

CREATE SEQUENCE mcms_terminology.concept_concept_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: concept_concept_id_seq; Type: SEQUENCE OWNED BY; Schema: mcms_terminology; Owner: -
--

ALTER SEQUENCE mcms_terminology.concept_concept_id_seq OWNED BY mcms_terminology.concept.concept_id;


--
-- Name: birth_certificate; Type: TABLE; Schema: mcms_vital_records; Owner: -
--

CREATE TABLE mcms_vital_records.birth_certificate (
    birth_cert_id bigint NOT NULL,
    registration_no text NOT NULL,
    newborn_patient_id bigint NOT NULL,
    mother_patient_id bigint,
    father_party_id bigint,
    delivery_encounter_id bigint,
    facility_id bigint NOT NULL,
    birth_datetime timestamp with time zone NOT NULL,
    birth_weight_g numeric(7,1),
    gestation_weeks numeric(4,1),
    place_of_birth text,
    attendant_user_id bigint,
    registrar_user_id bigint,
    certifier_user_id bigint,
    status text DEFAULT 'draft'::text NOT NULL,
    signed_at timestamp with time zone,
    amended_from bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT birth_certificate_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'issued'::text, 'amended'::text])))
);


--
-- Name: birth_certificate_birth_cert_id_seq; Type: SEQUENCE; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE mcms_vital_records.birth_certificate ALTER COLUMN birth_cert_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME mcms_vital_records.birth_certificate_birth_cert_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: birth_reg_no_seq; Type: SEQUENCE; Schema: mcms_vital_records; Owner: -
--

CREATE SEQUENCE mcms_vital_records.birth_reg_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: death_certificate; Type: TABLE; Schema: mcms_vital_records; Owner: -
--

CREATE TABLE mcms_vital_records.death_certificate (
    death_cert_id bigint NOT NULL,
    registration_no text NOT NULL,
    patient_id bigint NOT NULL,
    facility_id bigint NOT NULL,
    death_datetime timestamp with time zone NOT NULL,
    cause_icd10 text,
    cause_text text,
    certifying_clinician_user_id bigint,
    coroner_case boolean DEFAULT false NOT NULL,
    registrar_user_id bigint,
    status text DEFAULT 'draft'::text NOT NULL,
    signed_at timestamp with time zone,
    amended_from bigint,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT death_certificate_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'issued'::text, 'amended'::text])))
);


--
-- Name: death_certificate_death_cert_id_seq; Type: SEQUENCE; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE mcms_vital_records.death_certificate ALTER COLUMN death_cert_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME mcms_vital_records.death_certificate_death_cert_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: death_reg_no_seq; Type: SEQUENCE; Schema: mcms_vital_records; Owner: -
--

CREATE SEQUENCE mcms_vital_records.death_reg_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: manifest_no_seq; Type: SEQUENCE; Schema: mcms_waste; Owner: -
--

CREATE SEQUENCE mcms_waste.manifest_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: waste_collection; Type: TABLE; Schema: mcms_waste; Owner: -
--

CREATE TABLE mcms_waste.waste_collection (
    collection_id bigint NOT NULL,
    container_id bigint NOT NULL,
    weight_kg numeric(10,3) NOT NULL,
    collected_by_user_id bigint,
    collection_datetime timestamp with time zone DEFAULT now() NOT NULL,
    storage_location text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT waste_collection_weight_kg_check CHECK ((weight_kg >= (0)::numeric))
);


--
-- Name: waste_collection_collection_id_seq; Type: SEQUENCE; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_collection ALTER COLUMN collection_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME mcms_waste.waste_collection_collection_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: waste_container; Type: TABLE; Schema: mcms_waste; Owner: -
--

CREATE TABLE mcms_waste.waste_container (
    container_id bigint NOT NULL,
    barcode text NOT NULL,
    stream_id bigint NOT NULL,
    department_id bigint NOT NULL,
    capacity_kg numeric(10,3),
    status text DEFAULT 'open'::text NOT NULL,
    opened_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT waste_container_capacity_kg_check CHECK (((capacity_kg IS NULL) OR (capacity_kg >= (0)::numeric))),
    CONSTRAINT waste_container_status_check CHECK ((status = ANY (ARRAY['open'::text, 'sealed'::text, 'collected'::text, 'disposed'::text])))
);


--
-- Name: waste_container_container_id_seq; Type: SEQUENCE; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_container ALTER COLUMN container_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME mcms_waste.waste_container_container_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: waste_cost_allocation; Type: TABLE; Schema: mcms_waste; Owner: -
--

CREATE TABLE mcms_waste.waste_cost_allocation (
    allocation_id bigint NOT NULL,
    manifest_id bigint NOT NULL,
    department_id bigint NOT NULL,
    period_month date NOT NULL,
    allocated_weight_kg numeric(12,3) DEFAULT 0 NOT NULL,
    allocated_cost numeric(16,4) DEFAULT 0 NOT NULL,
    cost_center_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT waste_cost_allocation_allocated_cost_check CHECK ((allocated_cost >= (0)::numeric)),
    CONSTRAINT waste_cost_allocation_allocated_weight_kg_check CHECK ((allocated_weight_kg >= (0)::numeric))
);


--
-- Name: waste_cost_allocation_allocation_id_seq; Type: SEQUENCE; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_cost_allocation ALTER COLUMN allocation_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME mcms_waste.waste_cost_allocation_allocation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: waste_disposal_manifest; Type: TABLE; Schema: mcms_waste; Owner: -
--

CREATE TABLE mcms_waste.waste_disposal_manifest (
    manifest_id bigint NOT NULL,
    manifest_no text NOT NULL,
    carrier_vendor text,
    treatment_method text,
    disposal_datetime timestamp with time zone DEFAULT now() NOT NULL,
    total_weight_kg numeric(12,3) DEFAULT 0 NOT NULL,
    unit_cost_per_kg numeric(12,4) DEFAULT 0 NOT NULL,
    total_cost numeric(16,4) GENERATED ALWAYS AS ((total_weight_kg * unit_cost_per_kg)) STORED,
    currency text DEFAULT 'SAR'::text NOT NULL,
    certificate_ref text,
    certified_by_user_id bigint,
    status text DEFAULT 'open'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT waste_disposal_manifest_status_check CHECK ((status = ANY (ARRAY['open'::text, 'certified'::text, 'cancelled'::text]))),
    CONSTRAINT waste_disposal_manifest_total_weight_kg_check CHECK ((total_weight_kg >= (0)::numeric)),
    CONSTRAINT waste_disposal_manifest_treatment_method_check CHECK (((treatment_method IS NULL) OR (treatment_method = ANY (ARRAY['autoclave'::text, 'incineration'::text, 'chemical'::text, 'microwave'::text, 'landfill'::text, 'encapsulation'::text, 'other'::text])))),
    CONSTRAINT waste_disposal_manifest_unit_cost_per_kg_check CHECK ((unit_cost_per_kg >= (0)::numeric))
);


--
-- Name: waste_disposal_manifest_manifest_id_seq; Type: SEQUENCE; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_disposal_manifest ALTER COLUMN manifest_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME mcms_waste.waste_disposal_manifest_manifest_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: waste_stream; Type: TABLE; Schema: mcms_waste; Owner: -
--

CREATE TABLE mcms_waste.waste_stream (
    stream_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    kind text NOT NULL,
    color_code text,
    hazard_class text,
    default_disposal_method text,
    unit_cost_per_kg numeric(12,4) DEFAULT 0 NOT NULL,
    currency text DEFAULT 'SAR'::text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT waste_stream_kind_check CHECK ((kind = ANY (ARRAY['sharps'::text, 'infectious'::text, 'pathological'::text, 'pharmaceutical'::text, 'chemical'::text, 'cytotoxic'::text, 'radioactive'::text, 'general'::text]))),
    CONSTRAINT waste_stream_unit_cost_per_kg_check CHECK ((unit_cost_per_kg >= (0)::numeric))
);


--
-- Name: waste_stream_stream_id_seq; Type: SEQUENCE; Schema: mcms_waste; Owner: -
--

ALTER TABLE mcms_waste.waste_stream ALTER COLUMN stream_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME mcms_waste.waste_stream_stream_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: claim_response response_id; Type: DEFAULT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.claim_response ALTER COLUMN response_id SET DEFAULT nextval('mcms_billing.claim_response_response_id_seq'::regclass);


--
-- Name: eligibility_check eligibility_id; Type: DEFAULT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.eligibility_check ALTER COLUMN eligibility_id SET DEFAULT nextval('mcms_billing.eligibility_check_eligibility_id_seq'::regclass);


--
-- Name: insurance_claim claim_id; Type: DEFAULT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.insurance_claim ALTER COLUMN claim_id SET DEFAULT nextval('mcms_billing.insurance_claim_claim_id_seq'::regclass);


--
-- Name: invoice invoice_id; Type: DEFAULT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.invoice ALTER COLUMN invoice_id SET DEFAULT nextval('mcms_billing.invoice_invoice_id_seq'::regclass);


--
-- Name: invoice_line line_id; Type: DEFAULT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.invoice_line ALTER COLUMN line_id SET DEFAULT nextval('mcms_billing.invoice_line_line_id_seq'::regclass);


--
-- Name: payer payer_id; Type: DEFAULT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.payer ALTER COLUMN payer_id SET DEFAULT nextval('mcms_billing.payer_payer_id_seq'::regclass);


--
-- Name: payment payment_id; Type: DEFAULT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.payment ALTER COLUMN payment_id SET DEFAULT nextval('mcms_billing.payment_payment_id_seq'::regclass);


--
-- Name: service_price service_id; Type: DEFAULT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.service_price ALTER COLUMN service_id SET DEFAULT nextval('mcms_billing.service_price_service_id_seq'::regclass);


--
-- Name: appointment appointment_id; Type: DEFAULT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.appointment ALTER COLUMN appointment_id SET DEFAULT nextval('mcms_clinic.appointment_appointment_id_seq'::regclass);


--
-- Name: consultation consultation_id; Type: DEFAULT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.consultation ALTER COLUMN consultation_id SET DEFAULT nextval('mcms_clinic.consultation_consultation_id_seq'::regclass);


--
-- Name: patient_queue queue_id; Type: DEFAULT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.patient_queue ALTER COLUMN queue_id SET DEFAULT nextval('mcms_clinic.patient_queue_queue_id_seq'::regclass);


--
-- Name: room room_id; Type: DEFAULT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.room ALTER COLUMN room_id SET DEFAULT nextval('mcms_clinic.room_room_id_seq'::regclass);


--
-- Name: access_log access_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.access_log ALTER COLUMN access_id SET DEFAULT nextval('mcms_core.access_log_access_id_seq'::regclass);


--
-- Name: address address_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.address ALTER COLUMN address_id SET DEFAULT nextval('mcms_core.address_address_id_seq'::regclass);


--
-- Name: app_user user_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.app_user ALTER COLUMN user_id SET DEFAULT nextval('mcms_core.app_user_user_id_seq'::regclass);


--
-- Name: audit_trail audit_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.audit_trail ALTER COLUMN audit_id SET DEFAULT nextval('mcms_core.audit_trail_audit_id_seq'::regclass);


--
-- Name: backup_log backup_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.backup_log ALTER COLUMN backup_id SET DEFAULT nextval('mcms_core.backup_log_backup_id_seq'::regclass);


--
-- Name: consent consent_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.consent ALTER COLUMN consent_id SET DEFAULT nextval('mcms_core.consent_consent_id_seq'::regclass);


--
-- Name: contact contact_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.contact ALTER COLUMN contact_id SET DEFAULT nextval('mcms_core.contact_contact_id_seq'::regclass);


--
-- Name: event_log event_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.event_log ALTER COLUMN event_id SET DEFAULT nextval('mcms_core.event_log_event_id_seq'::regclass);


--
-- Name: facility facility_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.facility ALTER COLUMN facility_id SET DEFAULT nextval('mcms_core.facility_facility_id_seq'::regclass);


--
-- Name: hl7_message hl7_message_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.hl7_message ALTER COLUMN hl7_message_id SET DEFAULT nextval('mcms_core.hl7_message_hl7_message_id_seq'::regclass);


--
-- Name: lookup lookup_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.lookup ALTER COLUMN lookup_id SET DEFAULT nextval('mcms_core.lookup_lookup_id_seq'::regclass);


--
-- Name: notification notification_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.notification ALTER COLUMN notification_id SET DEFAULT nextval('mcms_core.notification_notification_id_seq'::regclass);


--
-- Name: organization organization_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.organization ALTER COLUMN organization_id SET DEFAULT nextval('mcms_core.organization_organization_id_seq'::regclass);


--
-- Name: party party_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.party ALTER COLUMN party_id SET DEFAULT nextval('mcms_core.party_party_id_seq'::regclass);


--
-- Name: permission permission_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.permission ALTER COLUMN permission_id SET DEFAULT nextval('mcms_core.permission_permission_id_seq'::regclass);


--
-- Name: role role_id; Type: DEFAULT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.role ALTER COLUMN role_id SET DEFAULT nextval('mcms_core.role_role_id_seq'::regclass);


--
-- Name: session session_id; Type: DEFAULT; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE ONLY mcms_dialysis.session ALTER COLUMN session_id SET DEFAULT nextval('mcms_dialysis.session_session_id_seq'::regclass);


--
-- Name: station station_id; Type: DEFAULT; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE ONLY mcms_dialysis.station ALTER COLUMN station_id SET DEFAULT nextval('mcms_dialysis.station_station_id_seq'::regclass);


--
-- Name: ed_bed ed_bed_id; Type: DEFAULT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.ed_bed ALTER COLUMN ed_bed_id SET DEFAULT nextval('mcms_emergency.ed_bed_ed_bed_id_seq'::regclass);


--
-- Name: resuscitation resus_id; Type: DEFAULT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.resuscitation ALTER COLUMN resus_id SET DEFAULT nextval('mcms_emergency.resuscitation_resus_id_seq'::regclass);


--
-- Name: triage triage_id; Type: DEFAULT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.triage ALTER COLUMN triage_id SET DEFAULT nextval('mcms_emergency.triage_triage_id_seq'::regclass);


--
-- Name: allergy allergy_id; Type: DEFAULT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.allergy ALTER COLUMN allergy_id SET DEFAULT nextval('mcms_emr.allergy_allergy_id_seq'::regclass);


--
-- Name: clinical_note note_id; Type: DEFAULT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.clinical_note ALTER COLUMN note_id SET DEFAULT nextval('mcms_emr.clinical_note_note_id_seq'::regclass);


--
-- Name: diagnosis diagnosis_id; Type: DEFAULT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.diagnosis ALTER COLUMN diagnosis_id SET DEFAULT nextval('mcms_emr.diagnosis_diagnosis_id_seq'::regclass);


--
-- Name: encounter encounter_id; Type: DEFAULT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.encounter ALTER COLUMN encounter_id SET DEFAULT nextval('mcms_emr.encounter_encounter_id_seq'::regclass);


--
-- Name: family_history fh_id; Type: DEFAULT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.family_history ALTER COLUMN fh_id SET DEFAULT nextval('mcms_emr.family_history_fh_id_seq'::regclass);


--
-- Name: immunization immunization_id; Type: DEFAULT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.immunization ALTER COLUMN immunization_id SET DEFAULT nextval('mcms_emr.immunization_immunization_id_seq'::regclass);


--
-- Name: medication_order order_id; Type: DEFAULT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.medication_order ALTER COLUMN order_id SET DEFAULT nextval('mcms_emr.medication_order_order_id_seq'::regclass);


--
-- Name: patient patient_id; Type: DEFAULT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.patient ALTER COLUMN patient_id SET DEFAULT nextval('mcms_emr.patient_patient_id_seq'::regclass);


--
-- Name: referral_linkage_rule rule_id; Type: DEFAULT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral_linkage_rule ALTER COLUMN rule_id SET DEFAULT nextval('mcms_emr.referral_linkage_rule_rule_id_seq'::regclass);


--
-- Name: social_history sh_id; Type: DEFAULT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.social_history ALTER COLUMN sh_id SET DEFAULT nextval('mcms_emr.social_history_sh_id_seq'::regclass);


--
-- Name: vitals vital_id; Type: DEFAULT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.vitals ALTER COLUMN vital_id SET DEFAULT nextval('mcms_emr.vitals_vital_id_seq'::regclass);


--
-- Name: gl_account account_id; Type: DEFAULT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.gl_account ALTER COLUMN account_id SET DEFAULT nextval('mcms_erp.gl_account_account_id_seq'::regclass);


--
-- Name: goods_receipt grn_id; Type: DEFAULT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.goods_receipt ALTER COLUMN grn_id SET DEFAULT nextval('mcms_erp.goods_receipt_grn_id_seq'::regclass);


--
-- Name: goods_receipt_line line_id; Type: DEFAULT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.goods_receipt_line ALTER COLUMN line_id SET DEFAULT nextval('mcms_erp.goods_receipt_line_line_id_seq'::regclass);


--
-- Name: inventory_item item_id; Type: DEFAULT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.inventory_item ALTER COLUMN item_id SET DEFAULT nextval('mcms_erp.inventory_item_item_id_seq'::regclass);


--
-- Name: inventory_stock stock_id; Type: DEFAULT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.inventory_stock ALTER COLUMN stock_id SET DEFAULT nextval('mcms_erp.inventory_stock_stock_id_seq'::regclass);


--
-- Name: purchase_order po_id; Type: DEFAULT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.purchase_order ALTER COLUMN po_id SET DEFAULT nextval('mcms_erp.purchase_order_po_id_seq'::regclass);


--
-- Name: purchase_order_line line_id; Type: DEFAULT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.purchase_order_line ALTER COLUMN line_id SET DEFAULT nextval('mcms_erp.purchase_order_line_line_id_seq'::regclass);


--
-- Name: stock_movement movement_id; Type: DEFAULT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.stock_movement ALTER COLUMN movement_id SET DEFAULT nextval('mcms_erp.stock_movement_movement_id_seq'::regclass);


--
-- Name: supplier supplier_id; Type: DEFAULT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.supplier ALTER COLUMN supplier_id SET DEFAULT nextval('mcms_erp.supplier_supplier_id_seq'::regclass);


--
-- Name: attendance attendance_id; Type: DEFAULT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.attendance ALTER COLUMN attendance_id SET DEFAULT nextval('mcms_hr.attendance_attendance_id_seq'::regclass);


--
-- Name: department department_id; Type: DEFAULT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.department ALTER COLUMN department_id SET DEFAULT nextval('mcms_hr.department_department_id_seq'::regclass);


--
-- Name: employee employee_id; Type: DEFAULT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.employee ALTER COLUMN employee_id SET DEFAULT nextval('mcms_hr.employee_employee_id_seq'::regclass);


--
-- Name: employee_department emp_dept_id; Type: DEFAULT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.employee_department ALTER COLUMN emp_dept_id SET DEFAULT nextval('mcms_hr.employee_department_emp_dept_id_seq'::regclass);


--
-- Name: leave_request leave_id; Type: DEFAULT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.leave_request ALTER COLUMN leave_id SET DEFAULT nextval('mcms_hr.leave_request_leave_id_seq'::regclass);


--
-- Name: payroll_item item_id; Type: DEFAULT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.payroll_item ALTER COLUMN item_id SET DEFAULT nextval('mcms_hr.payroll_item_item_id_seq'::regclass);


--
-- Name: payroll_period period_id; Type: DEFAULT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.payroll_period ALTER COLUMN period_id SET DEFAULT nextval('mcms_hr.payroll_period_period_id_seq'::regclass);


--
-- Name: shift shift_id; Type: DEFAULT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.shift ALTER COLUMN shift_id SET DEFAULT nextval('mcms_hr.shift_shift_id_seq'::regclass);


--
-- Name: admission admission_id; Type: DEFAULT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.admission ALTER COLUMN admission_id SET DEFAULT nextval('mcms_icu.admission_admission_id_seq'::regclass);


--
-- Name: bed bed_id; Type: DEFAULT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.bed ALTER COLUMN bed_id SET DEFAULT nextval('mcms_icu.bed_bed_id_seq'::regclass);


--
-- Name: bed_stay stay_id; Type: DEFAULT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.bed_stay ALTER COLUMN stay_id SET DEFAULT nextval('mcms_icu.bed_stay_stay_id_seq'::regclass);


--
-- Name: score score_id; Type: DEFAULT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.score ALTER COLUMN score_id SET DEFAULT nextval('mcms_icu.score_score_id_seq'::regclass);


--
-- Name: support_session session_id; Type: DEFAULT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.support_session ALTER COLUMN session_id SET DEFAULT nextval('mcms_icu.support_session_session_id_seq'::regclass);


--
-- Name: vitals_stream stream_id; Type: DEFAULT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.vitals_stream ALTER COLUMN stream_id SET DEFAULT nextval('mcms_icu.vitals_stream_stream_id_seq'::regclass);


--
-- Name: lab_order order_id; Type: DEFAULT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.lab_order ALTER COLUMN order_id SET DEFAULT nextval('mcms_lab.lab_order_order_id_seq'::regclass);


--
-- Name: result result_id; Type: DEFAULT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.result ALTER COLUMN result_id SET DEFAULT nextval('mcms_lab.result_result_id_seq'::regclass);


--
-- Name: sample sample_id; Type: DEFAULT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.sample ALTER COLUMN sample_id SET DEFAULT nextval('mcms_lab.sample_sample_id_seq'::regclass);


--
-- Name: test_catalog test_id; Type: DEFAULT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.test_catalog ALTER COLUMN test_id SET DEFAULT nextval('mcms_lab.test_catalog_test_id_seq'::regclass);


--
-- Name: test_panel panel_id; Type: DEFAULT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.test_panel ALTER COLUMN panel_id SET DEFAULT nextval('mcms_lab.test_panel_panel_id_seq'::regclass);


--
-- Name: test_panel_item ppi_id; Type: DEFAULT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.test_panel_item ALTER COLUMN ppi_id SET DEFAULT nextval('mcms_lab.test_panel_item_ppi_id_seq'::regclass);


--
-- Name: cot cot_id; Type: DEFAULT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.cot ALTER COLUMN cot_id SET DEFAULT nextval('mcms_nursery.cot_cot_id_seq'::regclass);


--
-- Name: growth_entry entry_id; Type: DEFAULT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.growth_entry ALTER COLUMN entry_id SET DEFAULT nextval('mcms_nursery.growth_entry_entry_id_seq'::regclass);


--
-- Name: neonate_record neonate_id; Type: DEFAULT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.neonate_record ALTER COLUMN neonate_id SET DEFAULT nextval('mcms_nursery.neonate_record_neonate_id_seq'::regclass);


--
-- Name: session session_id; Type: DEFAULT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.session ALTER COLUMN session_id SET DEFAULT nextval('mcms_physio.session_session_id_seq'::regclass);


--
-- Name: therapy_catalog therapy_id; Type: DEFAULT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.therapy_catalog ALTER COLUMN therapy_id SET DEFAULT nextval('mcms_physio.therapy_catalog_therapy_id_seq'::regclass);


--
-- Name: treatment_plan plan_id; Type: DEFAULT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.treatment_plan ALTER COLUMN plan_id SET DEFAULT nextval('mcms_physio.treatment_plan_plan_id_seq'::regclass);


--
-- Name: exam_catalog exam_id; Type: DEFAULT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.exam_catalog ALTER COLUMN exam_id SET DEFAULT nextval('mcms_rad.exam_catalog_exam_id_seq'::regclass);


--
-- Name: image_instance image_id; Type: DEFAULT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.image_instance ALTER COLUMN image_id SET DEFAULT nextval('mcms_rad.image_instance_image_id_seq'::regclass);


--
-- Name: modality_suite suite_id; Type: DEFAULT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.modality_suite ALTER COLUMN suite_id SET DEFAULT nextval('mcms_rad.modality_suite_suite_id_seq'::regclass);


--
-- Name: study_request study_id; Type: DEFAULT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.study_request ALTER COLUMN study_id SET DEFAULT nextval('mcms_rad.study_request_study_id_seq'::regclass);


--
-- Name: administration administer_id; Type: DEFAULT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.administration ALTER COLUMN administer_id SET DEFAULT nextval('mcms_rx.administration_administer_id_seq'::regclass);


--
-- Name: dispensation dispensation_id; Type: DEFAULT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.dispensation ALTER COLUMN dispensation_id SET DEFAULT nextval('mcms_rx.dispensation_dispensation_id_seq'::regclass);


--
-- Name: drug_alternative alternative_id; Type: DEFAULT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_alternative ALTER COLUMN alternative_id SET DEFAULT nextval('mcms_rx.drug_alternative_alternative_id_seq'::regclass);


--
-- Name: drug_interaction interaction_id; Type: DEFAULT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_interaction ALTER COLUMN interaction_id SET DEFAULT nextval('mcms_rx.drug_interaction_interaction_id_seq'::regclass);


--
-- Name: drug_item drug_item_id; Type: DEFAULT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_item ALTER COLUMN drug_item_id SET DEFAULT nextval('mcms_rx.drug_item_drug_item_id_seq'::regclass);


--
-- Name: drug_lot lot_id; Type: DEFAULT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_lot ALTER COLUMN lot_id SET DEFAULT nextval('mcms_rx.drug_lot_lot_id_seq'::regclass);


--
-- Name: stock_movement movement_id; Type: DEFAULT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.stock_movement ALTER COLUMN movement_id SET DEFAULT nextval('mcms_rx.stock_movement_movement_id_seq'::regclass);


--
-- Name: intra_op_vitals iov_id; Type: DEFAULT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.intra_op_vitals ALTER COLUMN iov_id SET DEFAULT nextval('mcms_surgical.intra_op_vitals_iov_id_seq'::regclass);


--
-- Name: operating_room or_id; Type: DEFAULT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.operating_room ALTER COLUMN or_id SET DEFAULT nextval('mcms_surgical.operating_room_or_id_seq'::regclass);


--
-- Name: post_op_note pon_id; Type: DEFAULT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.post_op_note ALTER COLUMN pon_id SET DEFAULT nextval('mcms_surgical.post_op_note_pon_id_seq'::regclass);


--
-- Name: pre_op_checklist poc_id; Type: DEFAULT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.pre_op_checklist ALTER COLUMN poc_id SET DEFAULT nextval('mcms_surgical.pre_op_checklist_poc_id_seq'::regclass);


--
-- Name: procedure_catalog proc_cat_id; Type: DEFAULT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.procedure_catalog ALTER COLUMN proc_cat_id SET DEFAULT nextval('mcms_surgical.procedure_catalog_proc_cat_id_seq'::regclass);


--
-- Name: surgery surgery_id; Type: DEFAULT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgery ALTER COLUMN surgery_id SET DEFAULT nextval('mcms_surgical.surgery_surgery_id_seq'::regclass);


--
-- Name: surgical_team surg_team_id; Type: DEFAULT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgical_team ALTER COLUMN surg_team_id SET DEFAULT nextval('mcms_surgical.surgical_team_surg_team_id_seq'::regclass);


--
-- Name: concept concept_id; Type: DEFAULT; Schema: mcms_terminology; Owner: -
--

ALTER TABLE ONLY mcms_terminology.concept ALTER COLUMN concept_id SET DEFAULT nextval('mcms_terminology.concept_concept_id_seq'::regclass);


--
-- Name: claim_response claim_response_pkey; Type: CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.claim_response
    ADD CONSTRAINT claim_response_pkey PRIMARY KEY (response_id);


--
-- Name: eligibility_check eligibility_check_patient_id_payer_code_checked_at_key; Type: CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.eligibility_check
    ADD CONSTRAINT eligibility_check_patient_id_payer_code_checked_at_key UNIQUE (patient_id, payer_code, checked_at);


--
-- Name: eligibility_check eligibility_check_pkey; Type: CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.eligibility_check
    ADD CONSTRAINT eligibility_check_pkey PRIMARY KEY (eligibility_id);


--
-- Name: insurance_claim insurance_claim_pkey; Type: CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.insurance_claim
    ADD CONSTRAINT insurance_claim_pkey PRIMARY KEY (claim_id);


--
-- Name: invoice invoice_invoice_no_key; Type: CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.invoice
    ADD CONSTRAINT invoice_invoice_no_key UNIQUE (invoice_no);


--
-- Name: invoice_line invoice_line_pkey; Type: CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.invoice_line
    ADD CONSTRAINT invoice_line_pkey PRIMARY KEY (line_id);


--
-- Name: invoice invoice_pkey; Type: CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.invoice
    ADD CONSTRAINT invoice_pkey PRIMARY KEY (invoice_id);


--
-- Name: payer payer_payer_code_key; Type: CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.payer
    ADD CONSTRAINT payer_payer_code_key UNIQUE (payer_code);


--
-- Name: payer payer_pkey; Type: CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.payer
    ADD CONSTRAINT payer_pkey PRIMARY KEY (payer_id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (payment_id);


--
-- Name: service_price service_price_code_key; Type: CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.service_price
    ADD CONSTRAINT service_price_code_key UNIQUE (code);


--
-- Name: service_price service_price_pkey; Type: CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.service_price
    ADD CONSTRAINT service_price_pkey PRIMARY KEY (service_id);


--
-- Name: appointment appointment_pkey; Type: CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.appointment
    ADD CONSTRAINT appointment_pkey PRIMARY KEY (appointment_id);


--
-- Name: consultation consultation_pkey; Type: CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.consultation
    ADD CONSTRAINT consultation_pkey PRIMARY KEY (consultation_id);


--
-- Name: patient_queue patient_queue_pkey; Type: CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.patient_queue
    ADD CONSTRAINT patient_queue_pkey PRIMARY KEY (queue_id);


--
-- Name: room room_code_key; Type: CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.room
    ADD CONSTRAINT room_code_key UNIQUE (code);


--
-- Name: room room_pkey; Type: CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.room
    ADD CONSTRAINT room_pkey PRIMARY KEY (room_id);


--
-- Name: access_log access_log_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.access_log
    ADD CONSTRAINT access_log_pkey PRIMARY KEY (access_id);


--
-- Name: address address_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.address
    ADD CONSTRAINT address_pkey PRIMARY KEY (address_id);


--
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (user_id);


--
-- Name: app_user app_user_username_key; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.app_user
    ADD CONSTRAINT app_user_username_key UNIQUE (username);


--
-- Name: audit_trail audit_trail_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.audit_trail
    ADD CONSTRAINT audit_trail_pkey PRIMARY KEY (audit_id);


--
-- Name: backup_log backup_log_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.backup_log
    ADD CONSTRAINT backup_log_pkey PRIMARY KEY (backup_id);


--
-- Name: consent consent_party_id_consent_type_key; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.consent
    ADD CONSTRAINT consent_party_id_consent_type_key UNIQUE (party_id, consent_type);


--
-- Name: consent consent_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.consent
    ADD CONSTRAINT consent_pkey PRIMARY KEY (consent_id);


--
-- Name: contact contact_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.contact
    ADD CONSTRAINT contact_pkey PRIMARY KEY (contact_id);


--
-- Name: event_log event_log_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.event_log
    ADD CONSTRAINT event_log_pkey PRIMARY KEY (event_id);


--
-- Name: facility facility_code_key; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.facility
    ADD CONSTRAINT facility_code_key UNIQUE (code);


--
-- Name: facility facility_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.facility
    ADD CONSTRAINT facility_pkey PRIMARY KEY (facility_id);


--
-- Name: federated_identity federated_identity_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.federated_identity
    ADD CONSTRAINT federated_identity_pkey PRIMARY KEY (fed_id);


--
-- Name: federated_identity federated_identity_provider_code_external_subject_key; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.federated_identity
    ADD CONSTRAINT federated_identity_provider_code_external_subject_key UNIQUE (provider_code, external_subject);


--
-- Name: hl7_message hl7_message_message_control_id_key; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.hl7_message
    ADD CONSTRAINT hl7_message_message_control_id_key UNIQUE (message_control_id);


--
-- Name: hl7_message hl7_message_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.hl7_message
    ADD CONSTRAINT hl7_message_pkey PRIMARY KEY (hl7_message_id);


--
-- Name: identity_provider identity_provider_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.identity_provider
    ADD CONSTRAINT identity_provider_pkey PRIMARY KEY (provider_code);


--
-- Name: lookup lookup_namespace_code_key; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.lookup
    ADD CONSTRAINT lookup_namespace_code_key UNIQUE (namespace, code);


--
-- Name: lookup lookup_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.lookup
    ADD CONSTRAINT lookup_pkey PRIMARY KEY (lookup_id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (notification_id);


--
-- Name: organization organization_code_key; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.organization
    ADD CONSTRAINT organization_code_key UNIQUE (code);


--
-- Name: organization organization_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.organization
    ADD CONSTRAINT organization_pkey PRIMARY KEY (organization_id);


--
-- Name: party party_code_key; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.party
    ADD CONSTRAINT party_code_key UNIQUE (code);


--
-- Name: party party_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.party
    ADD CONSTRAINT party_pkey PRIMARY KEY (party_id);


--
-- Name: permission permission_code_key; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.permission
    ADD CONSTRAINT permission_code_key UNIQUE (code);


--
-- Name: permission permission_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.permission
    ADD CONSTRAINT permission_pkey PRIMARY KEY (permission_id);


--
-- Name: role role_code_key; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.role
    ADD CONSTRAINT role_code_key UNIQUE (code);


--
-- Name: role_permission role_permission_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.role_permission
    ADD CONSTRAINT role_permission_pkey PRIMARY KEY (role_id, permission_id);


--
-- Name: role role_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (role_id);


--
-- Name: system_flag system_flag_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.system_flag
    ADD CONSTRAINT system_flag_pkey PRIMARY KEY (flag);


--
-- Name: user_role_map user_role_map_pkey; Type: CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.user_role_map
    ADD CONSTRAINT user_role_map_pkey PRIMARY KEY (user_id, role_id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE ONLY mcms_dialysis.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (session_id);


--
-- Name: station station_code_key; Type: CONSTRAINT; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE ONLY mcms_dialysis.station
    ADD CONSTRAINT station_code_key UNIQUE (code);


--
-- Name: station station_pkey; Type: CONSTRAINT; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE ONLY mcms_dialysis.station
    ADD CONSTRAINT station_pkey PRIMARY KEY (station_id);


--
-- Name: ed_bed ed_bed_pkey; Type: CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.ed_bed
    ADD CONSTRAINT ed_bed_pkey PRIMARY KEY (ed_bed_id);


--
-- Name: resuscitation resuscitation_pkey; Type: CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.resuscitation
    ADD CONSTRAINT resuscitation_pkey PRIMARY KEY (resus_id);


--
-- Name: triage triage_ed_visit_no_key; Type: CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.triage
    ADD CONSTRAINT triage_ed_visit_no_key UNIQUE (ed_visit_no);


--
-- Name: triage triage_pkey; Type: CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.triage
    ADD CONSTRAINT triage_pkey PRIMARY KEY (triage_id);


--
-- Name: allergy allergy_pkey; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.allergy
    ADD CONSTRAINT allergy_pkey PRIMARY KEY (allergy_id);


--
-- Name: clinical_note clinical_note_pkey; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.clinical_note
    ADD CONSTRAINT clinical_note_pkey PRIMARY KEY (note_id);


--
-- Name: diagnosis diagnosis_pkey; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.diagnosis
    ADD CONSTRAINT diagnosis_pkey PRIMARY KEY (diagnosis_id);


--
-- Name: encounter encounter_fhir_id_key; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.encounter
    ADD CONSTRAINT encounter_fhir_id_key UNIQUE (fhir_id);


--
-- Name: encounter encounter_pkey; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.encounter
    ADD CONSTRAINT encounter_pkey PRIMARY KEY (encounter_id);


--
-- Name: family_history family_history_pkey; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.family_history
    ADD CONSTRAINT family_history_pkey PRIMARY KEY (fh_id);


--
-- Name: immunization immunization_pkey; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.immunization
    ADD CONSTRAINT immunization_pkey PRIMARY KEY (immunization_id);


--
-- Name: medication_order medication_order_pkey; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.medication_order
    ADD CONSTRAINT medication_order_pkey PRIMARY KEY (order_id);


--
-- Name: patient patient_fhir_id_key; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.patient
    ADD CONSTRAINT patient_fhir_id_key UNIQUE (fhir_id);


--
-- Name: patient patient_mrn_key; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.patient
    ADD CONSTRAINT patient_mrn_key UNIQUE (mrn);


--
-- Name: patient patient_party_id_key; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.patient
    ADD CONSTRAINT patient_party_id_key UNIQUE (party_id);


--
-- Name: patient patient_pkey; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.patient
    ADD CONSTRAINT patient_pkey PRIMARY KEY (patient_id);


--
-- Name: referral_linkage_rule referral_linkage_rule_from_department_id_diagnosis_code_cod_key; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral_linkage_rule
    ADD CONSTRAINT referral_linkage_rule_from_department_id_diagnosis_code_cod_key UNIQUE (from_department_id, diagnosis_code, code_system, to_department_id);


--
-- Name: referral_linkage_rule referral_linkage_rule_pkey; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral_linkage_rule
    ADD CONSTRAINT referral_linkage_rule_pkey PRIMARY KEY (rule_id);


--
-- Name: referral referral_pkey; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral
    ADD CONSTRAINT referral_pkey PRIMARY KEY (referral_id);


--
-- Name: social_history social_history_pkey; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.social_history
    ADD CONSTRAINT social_history_pkey PRIMARY KEY (sh_id);


--
-- Name: vitals vitals_pkey; Type: CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.vitals
    ADD CONSTRAINT vitals_pkey PRIMARY KEY (vital_id);


--
-- Name: gl_account gl_account_code_key; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.gl_account
    ADD CONSTRAINT gl_account_code_key UNIQUE (code);


--
-- Name: gl_account gl_account_pkey; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.gl_account
    ADD CONSTRAINT gl_account_pkey PRIMARY KEY (account_id);


--
-- Name: goods_receipt goods_receipt_grn_no_key; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.goods_receipt
    ADD CONSTRAINT goods_receipt_grn_no_key UNIQUE (grn_no);


--
-- Name: goods_receipt_line goods_receipt_line_pkey; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.goods_receipt_line
    ADD CONSTRAINT goods_receipt_line_pkey PRIMARY KEY (line_id);


--
-- Name: goods_receipt goods_receipt_pkey; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.goods_receipt
    ADD CONSTRAINT goods_receipt_pkey PRIMARY KEY (grn_id);


--
-- Name: inventory_item inventory_item_code_key; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.inventory_item
    ADD CONSTRAINT inventory_item_code_key UNIQUE (code);


--
-- Name: inventory_item inventory_item_pkey; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.inventory_item
    ADD CONSTRAINT inventory_item_pkey PRIMARY KEY (item_id);


--
-- Name: inventory_stock inventory_stock_item_id_department_id_key; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.inventory_stock
    ADD CONSTRAINT inventory_stock_item_id_department_id_key UNIQUE (item_id, department_id);


--
-- Name: inventory_stock inventory_stock_pkey; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.inventory_stock
    ADD CONSTRAINT inventory_stock_pkey PRIMARY KEY (stock_id);


--
-- Name: purchase_order_line purchase_order_line_pkey; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.purchase_order_line
    ADD CONSTRAINT purchase_order_line_pkey PRIMARY KEY (line_id);


--
-- Name: purchase_order purchase_order_pkey; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.purchase_order
    ADD CONSTRAINT purchase_order_pkey PRIMARY KEY (po_id);


--
-- Name: purchase_order purchase_order_po_no_key; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.purchase_order
    ADD CONSTRAINT purchase_order_po_no_key UNIQUE (po_no);


--
-- Name: stock_movement stock_movement_pkey; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.stock_movement
    ADD CONSTRAINT stock_movement_pkey PRIMARY KEY (movement_id);


--
-- Name: supplier supplier_party_id_key; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.supplier
    ADD CONSTRAINT supplier_party_id_key UNIQUE (party_id);


--
-- Name: supplier supplier_pkey; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.supplier
    ADD CONSTRAINT supplier_pkey PRIMARY KEY (supplier_id);


--
-- Name: supplier supplier_supplier_code_key; Type: CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.supplier
    ADD CONSTRAINT supplier_supplier_code_key UNIQUE (supplier_code);


--
-- Name: attendance attendance_pkey; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.attendance
    ADD CONSTRAINT attendance_pkey PRIMARY KEY (attendance_id);


--
-- Name: department department_code_key; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.department
    ADD CONSTRAINT department_code_key UNIQUE (code);


--
-- Name: department department_pkey; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.department
    ADD CONSTRAINT department_pkey PRIMARY KEY (department_id);


--
-- Name: employee_department employee_department_employee_id_department_id_start_date_key; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.employee_department
    ADD CONSTRAINT employee_department_employee_id_department_id_start_date_key UNIQUE (employee_id, department_id, start_date);


--
-- Name: employee_department employee_department_pkey; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.employee_department
    ADD CONSTRAINT employee_department_pkey PRIMARY KEY (emp_dept_id);


--
-- Name: employee employee_employee_no_key; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.employee
    ADD CONSTRAINT employee_employee_no_key UNIQUE (employee_no);


--
-- Name: employee employee_party_id_key; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.employee
    ADD CONSTRAINT employee_party_id_key UNIQUE (party_id);


--
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- Name: leave_request leave_request_pkey; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.leave_request
    ADD CONSTRAINT leave_request_pkey PRIMARY KEY (leave_id);


--
-- Name: payroll_item payroll_item_period_id_employee_id_key; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.payroll_item
    ADD CONSTRAINT payroll_item_period_id_employee_id_key UNIQUE (period_id, employee_id);


--
-- Name: payroll_item payroll_item_pkey; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.payroll_item
    ADD CONSTRAINT payroll_item_pkey PRIMARY KEY (item_id);


--
-- Name: payroll_period payroll_period_code_key; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.payroll_period
    ADD CONSTRAINT payroll_period_code_key UNIQUE (code);


--
-- Name: payroll_period payroll_period_pkey; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.payroll_period
    ADD CONSTRAINT payroll_period_pkey PRIMARY KEY (period_id);


--
-- Name: shift shift_pkey; Type: CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.shift
    ADD CONSTRAINT shift_pkey PRIMARY KEY (shift_id);


--
-- Name: admission admission_pkey; Type: CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.admission
    ADD CONSTRAINT admission_pkey PRIMARY KEY (admission_id);


--
-- Name: bed bed_pkey; Type: CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.bed
    ADD CONSTRAINT bed_pkey PRIMARY KEY (bed_id);


--
-- Name: bed bed_room_code_bed_label_key; Type: CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.bed
    ADD CONSTRAINT bed_room_code_bed_label_key UNIQUE (room_code, bed_label);


--
-- Name: bed_stay bed_stay_pkey; Type: CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.bed_stay
    ADD CONSTRAINT bed_stay_pkey PRIMARY KEY (stay_id);


--
-- Name: score score_pkey; Type: CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.score
    ADD CONSTRAINT score_pkey PRIMARY KEY (score_id);


--
-- Name: support_session support_session_pkey; Type: CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.support_session
    ADD CONSTRAINT support_session_pkey PRIMARY KEY (session_id);


--
-- Name: vitals_stream vitals_stream_pkey; Type: CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.vitals_stream
    ADD CONSTRAINT vitals_stream_pkey PRIMARY KEY (stream_id);


--
-- Name: lab_order lab_order_order_no_key; Type: CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.lab_order
    ADD CONSTRAINT lab_order_order_no_key UNIQUE (order_no);


--
-- Name: lab_order lab_order_pkey; Type: CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.lab_order
    ADD CONSTRAINT lab_order_pkey PRIMARY KEY (order_id);


--
-- Name: result result_pkey; Type: CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.result
    ADD CONSTRAINT result_pkey PRIMARY KEY (result_id);


--
-- Name: result result_sample_id_test_id_key; Type: CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.result
    ADD CONSTRAINT result_sample_id_test_id_key UNIQUE (sample_id, test_id);


--
-- Name: sample sample_pkey; Type: CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.sample
    ADD CONSTRAINT sample_pkey PRIMARY KEY (sample_id);


--
-- Name: sample sample_sample_no_key; Type: CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.sample
    ADD CONSTRAINT sample_sample_no_key UNIQUE (sample_no);


--
-- Name: test_catalog test_catalog_pkey; Type: CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.test_catalog
    ADD CONSTRAINT test_catalog_pkey PRIMARY KEY (test_id);


--
-- Name: test_panel test_panel_code_key; Type: CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.test_panel
    ADD CONSTRAINT test_panel_code_key UNIQUE (code);


--
-- Name: test_panel_item test_panel_item_pkey; Type: CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.test_panel_item
    ADD CONSTRAINT test_panel_item_pkey PRIMARY KEY (ppi_id);


--
-- Name: test_panel test_panel_pkey; Type: CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.test_panel
    ADD CONSTRAINT test_panel_pkey PRIMARY KEY (panel_id);


--
-- Name: cot cot_code_key; Type: CONSTRAINT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.cot
    ADD CONSTRAINT cot_code_key UNIQUE (code);


--
-- Name: cot cot_pkey; Type: CONSTRAINT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.cot
    ADD CONSTRAINT cot_pkey PRIMARY KEY (cot_id);


--
-- Name: growth_entry growth_entry_pkey; Type: CONSTRAINT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.growth_entry
    ADD CONSTRAINT growth_entry_pkey PRIMARY KEY (entry_id);


--
-- Name: neonate_record neonate_record_pkey; Type: CONSTRAINT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.neonate_record
    ADD CONSTRAINT neonate_record_pkey PRIMARY KEY (neonate_id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.session
    ADD CONSTRAINT session_pkey PRIMARY KEY (session_id);


--
-- Name: therapy_catalog therapy_catalog_code_key; Type: CONSTRAINT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.therapy_catalog
    ADD CONSTRAINT therapy_catalog_code_key UNIQUE (code);


--
-- Name: therapy_catalog therapy_catalog_pkey; Type: CONSTRAINT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.therapy_catalog
    ADD CONSTRAINT therapy_catalog_pkey PRIMARY KEY (therapy_id);


--
-- Name: treatment_plan treatment_plan_pkey; Type: CONSTRAINT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.treatment_plan
    ADD CONSTRAINT treatment_plan_pkey PRIMARY KEY (plan_id);


--
-- Name: exam_catalog exam_catalog_pkey; Type: CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.exam_catalog
    ADD CONSTRAINT exam_catalog_pkey PRIMARY KEY (exam_id);


--
-- Name: image_instance image_instance_pkey; Type: CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.image_instance
    ADD CONSTRAINT image_instance_pkey PRIMARY KEY (image_id);


--
-- Name: image_instance image_instance_study_id_series_number_instance_number_key; Type: CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.image_instance
    ADD CONSTRAINT image_instance_study_id_series_number_instance_number_key UNIQUE (study_id, series_number, instance_number);


--
-- Name: modality_suite modality_suite_code_key; Type: CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.modality_suite
    ADD CONSTRAINT modality_suite_code_key UNIQUE (code);


--
-- Name: modality_suite modality_suite_pkey; Type: CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.modality_suite
    ADD CONSTRAINT modality_suite_pkey PRIMARY KEY (suite_id);


--
-- Name: study_request study_request_accession_no_key; Type: CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.study_request
    ADD CONSTRAINT study_request_accession_no_key UNIQUE (accession_no);


--
-- Name: study_request study_request_pkey; Type: CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.study_request
    ADD CONSTRAINT study_request_pkey PRIMARY KEY (study_id);


--
-- Name: administration administration_pkey; Type: CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.administration
    ADD CONSTRAINT administration_pkey PRIMARY KEY (administer_id);


--
-- Name: dispensation dispensation_pkey; Type: CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.dispensation
    ADD CONSTRAINT dispensation_pkey PRIMARY KEY (dispensation_id);


--
-- Name: drug_alternative drug_alternative_pkey; Type: CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_alternative
    ADD CONSTRAINT drug_alternative_pkey PRIMARY KEY (alternative_id);


--
-- Name: drug_interaction drug_interaction_pkey; Type: CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_interaction
    ADD CONSTRAINT drug_interaction_pkey PRIMARY KEY (interaction_id);


--
-- Name: drug_item drug_item_pkey; Type: CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_item
    ADD CONSTRAINT drug_item_pkey PRIMARY KEY (drug_item_id);


--
-- Name: drug_lot drug_lot_drug_item_id_lot_number_key; Type: CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_lot
    ADD CONSTRAINT drug_lot_drug_item_id_lot_number_key UNIQUE (drug_item_id, lot_number);


--
-- Name: drug_lot drug_lot_pkey; Type: CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_lot
    ADD CONSTRAINT drug_lot_pkey PRIMARY KEY (lot_id);


--
-- Name: prescription prescription_pkey; Type: CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.prescription
    ADD CONSTRAINT prescription_pkey PRIMARY KEY (prescription_id);


--
-- Name: stock_movement stock_movement_pkey; Type: CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.stock_movement
    ADD CONSTRAINT stock_movement_pkey PRIMARY KEY (movement_id);


--
-- Name: drug_alternative uq_alt_pair; Type: CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_alternative
    ADD CONSTRAINT uq_alt_pair UNIQUE (drug_item_id, alt_drug_item_id);


--
-- Name: drug_interaction uq_interaction_pair; Type: CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_interaction
    ADD CONSTRAINT uq_interaction_pair UNIQUE (drug_item_id_a, drug_item_id_b);


--
-- Name: intra_op_vitals intra_op_vitals_pkey; Type: CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.intra_op_vitals
    ADD CONSTRAINT intra_op_vitals_pkey PRIMARY KEY (iov_id);


--
-- Name: operating_room operating_room_code_key; Type: CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.operating_room
    ADD CONSTRAINT operating_room_code_key UNIQUE (code);


--
-- Name: operating_room operating_room_pkey; Type: CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.operating_room
    ADD CONSTRAINT operating_room_pkey PRIMARY KEY (or_id);


--
-- Name: post_op_note post_op_note_pkey; Type: CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.post_op_note
    ADD CONSTRAINT post_op_note_pkey PRIMARY KEY (pon_id);


--
-- Name: pre_op_checklist pre_op_checklist_pkey; Type: CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.pre_op_checklist
    ADD CONSTRAINT pre_op_checklist_pkey PRIMARY KEY (poc_id);


--
-- Name: pre_op_checklist pre_op_checklist_surgery_id_key; Type: CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.pre_op_checklist
    ADD CONSTRAINT pre_op_checklist_surgery_id_key UNIQUE (surgery_id);


--
-- Name: procedure_catalog procedure_catalog_cpt_code_key; Type: CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.procedure_catalog
    ADD CONSTRAINT procedure_catalog_cpt_code_key UNIQUE (cpt_code);


--
-- Name: procedure_catalog procedure_catalog_pkey; Type: CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.procedure_catalog
    ADD CONSTRAINT procedure_catalog_pkey PRIMARY KEY (proc_cat_id);


--
-- Name: surgery surgery_operation_no_key; Type: CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgery
    ADD CONSTRAINT surgery_operation_no_key UNIQUE (operation_no);


--
-- Name: surgery surgery_pkey; Type: CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgery
    ADD CONSTRAINT surgery_pkey PRIMARY KEY (surgery_id);


--
-- Name: surgical_team surgical_team_pkey; Type: CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgical_team
    ADD CONSTRAINT surgical_team_pkey PRIMARY KEY (surg_team_id);


--
-- Name: surgical_team surgical_team_surgery_id_user_id_role_key; Type: CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgical_team
    ADD CONSTRAINT surgical_team_surgery_id_user_id_role_key UNIQUE (surgery_id, user_id, role);


--
-- Name: visit visit_pkey; Type: CONSTRAINT; Schema: mcms_telemed; Owner: -
--

ALTER TABLE ONLY mcms_telemed.visit
    ADD CONSTRAINT visit_pkey PRIMARY KEY (visit_id);


--
-- Name: concept concept_code_system_code_key; Type: CONSTRAINT; Schema: mcms_terminology; Owner: -
--

ALTER TABLE ONLY mcms_terminology.concept
    ADD CONSTRAINT concept_code_system_code_key UNIQUE (code_system, code);


--
-- Name: concept concept_pkey; Type: CONSTRAINT; Schema: mcms_terminology; Owner: -
--

ALTER TABLE ONLY mcms_terminology.concept
    ADD CONSTRAINT concept_pkey PRIMARY KEY (concept_id);


--
-- Name: birth_certificate birth_certificate_pkey; Type: CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.birth_certificate
    ADD CONSTRAINT birth_certificate_pkey PRIMARY KEY (birth_cert_id);


--
-- Name: birth_certificate birth_certificate_registration_no_facility_id_key; Type: CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.birth_certificate
    ADD CONSTRAINT birth_certificate_registration_no_facility_id_key UNIQUE (registration_no, facility_id);


--
-- Name: death_certificate death_certificate_pkey; Type: CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.death_certificate
    ADD CONSTRAINT death_certificate_pkey PRIMARY KEY (death_cert_id);


--
-- Name: death_certificate death_certificate_registration_no_facility_id_key; Type: CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.death_certificate
    ADD CONSTRAINT death_certificate_registration_no_facility_id_key UNIQUE (registration_no, facility_id);


--
-- Name: waste_collection waste_collection_pkey; Type: CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_collection
    ADD CONSTRAINT waste_collection_pkey PRIMARY KEY (collection_id);


--
-- Name: waste_container waste_container_barcode_key; Type: CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_container
    ADD CONSTRAINT waste_container_barcode_key UNIQUE (barcode);


--
-- Name: waste_container waste_container_pkey; Type: CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_container
    ADD CONSTRAINT waste_container_pkey PRIMARY KEY (container_id);


--
-- Name: waste_cost_allocation waste_cost_allocation_manifest_id_department_id_period_mont_key; Type: CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_cost_allocation
    ADD CONSTRAINT waste_cost_allocation_manifest_id_department_id_period_mont_key UNIQUE (manifest_id, department_id, period_month);


--
-- Name: waste_cost_allocation waste_cost_allocation_pkey; Type: CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_cost_allocation
    ADD CONSTRAINT waste_cost_allocation_pkey PRIMARY KEY (allocation_id);


--
-- Name: waste_disposal_manifest waste_disposal_manifest_manifest_no_key; Type: CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_disposal_manifest
    ADD CONSTRAINT waste_disposal_manifest_manifest_no_key UNIQUE (manifest_no);


--
-- Name: waste_disposal_manifest waste_disposal_manifest_pkey; Type: CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_disposal_manifest
    ADD CONSTRAINT waste_disposal_manifest_pkey PRIMARY KEY (manifest_id);


--
-- Name: waste_stream waste_stream_code_key; Type: CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_stream
    ADD CONSTRAINT waste_stream_code_key UNIQUE (code);


--
-- Name: waste_stream waste_stream_pkey; Type: CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_stream
    ADD CONSTRAINT waste_stream_pkey PRIMARY KEY (stream_id);


--
-- Name: insurance_claim_invoice_id_idx; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX insurance_claim_invoice_id_idx ON mcms_billing.insurance_claim USING btree (invoice_id);


--
-- Name: insurance_claim_status_idx; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX insurance_claim_status_idx ON mcms_billing.insurance_claim USING btree (status);


--
-- Name: invoice_encounter_id_idx; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX invoice_encounter_id_idx ON mcms_billing.invoice USING btree (encounter_id);


--
-- Name: invoice_line_invoice_id_idx; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX invoice_line_invoice_id_idx ON mcms_billing.invoice_line USING btree (invoice_id);


--
-- Name: invoice_line_service_id_idx; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX invoice_line_service_id_idx ON mcms_billing.invoice_line USING btree (service_id);


--
-- Name: invoice_patient_id_issued_at_idx; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX invoice_patient_id_issued_at_idx ON mcms_billing.invoice USING btree (patient_id, issued_at DESC);


--
-- Name: invoice_status_idx; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX invoice_status_idx ON mcms_billing.invoice USING btree (status);


--
-- Name: ix_claim_resp_claim; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX ix_claim_resp_claim ON mcms_billing.claim_response USING btree (claim_id);


--
-- Name: ix_claim_response_facility; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX ix_claim_response_facility ON mcms_billing.claim_response USING btree (facility_id);


--
-- Name: ix_elig_patient; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX ix_elig_patient ON mcms_billing.eligibility_check USING btree (patient_id, payer_code);


--
-- Name: ix_eligibility_check_facility; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX ix_eligibility_check_facility ON mcms_billing.eligibility_check USING btree (facility_id);


--
-- Name: ix_insurance_claim_facility; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX ix_insurance_claim_facility ON mcms_billing.insurance_claim USING btree (facility_id);


--
-- Name: ix_invoice_facility; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX ix_invoice_facility ON mcms_billing.invoice USING btree (facility_id);


--
-- Name: ix_invoice_line_facility; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX ix_invoice_line_facility ON mcms_billing.invoice_line USING btree (facility_id);


--
-- Name: ix_invoice_mrn; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX ix_invoice_mrn ON mcms_billing.invoice USING btree (mrn);


--
-- Name: ix_mcms_billing_insurance_claim_patient_id; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX ix_mcms_billing_insurance_claim_patient_id ON mcms_billing.insurance_claim USING btree (patient_id);


--
-- Name: ix_mcms_billing_invoice_issued_by; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX ix_mcms_billing_invoice_issued_by ON mcms_billing.invoice USING btree (issued_by);


--
-- Name: ix_mcms_billing_payment_received_by; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX ix_mcms_billing_payment_received_by ON mcms_billing.payment USING btree (received_by);


--
-- Name: payment_invoice_id_idx; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX payment_invoice_id_idx ON mcms_billing.payment USING btree (invoice_id);


--
-- Name: service_price_department_id_idx; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX service_price_department_id_idx ON mcms_billing.service_price USING btree (department_id);


--
-- Name: service_price_service_type_idx; Type: INDEX; Schema: mcms_billing; Owner: -
--

CREATE INDEX service_price_service_type_idx ON mcms_billing.service_price USING btree (service_type);


--
-- Name: appointment_clinician_user_id_starts_at_idx; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX appointment_clinician_user_id_starts_at_idx ON mcms_clinic.appointment USING btree (clinician_user_id, starts_at);


--
-- Name: appointment_department_id_starts_at_idx; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX appointment_department_id_starts_at_idx ON mcms_clinic.appointment USING btree (department_id, starts_at);


--
-- Name: appointment_patient_id_idx; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX appointment_patient_id_idx ON mcms_clinic.appointment USING btree (patient_id);


--
-- Name: appointment_status_idx; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX appointment_status_idx ON mcms_clinic.appointment USING btree (status);


--
-- Name: consultation_clinician_user_id_idx; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX consultation_clinician_user_id_idx ON mcms_clinic.consultation USING btree (clinician_user_id);


--
-- Name: consultation_encounter_id_idx; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX consultation_encounter_id_idx ON mcms_clinic.consultation USING btree (encounter_id);


--
-- Name: ix_appointment_facility; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_appointment_facility ON mcms_clinic.appointment USING btree (facility_id);


--
-- Name: ix_appt_conf_token; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_appt_conf_token ON mcms_clinic.appointment USING btree (confirmation_token);


--
-- Name: ix_mcms_clinic_appointment_booked_by; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_mcms_clinic_appointment_booked_by ON mcms_clinic.appointment USING btree (booked_by);


--
-- Name: ix_mcms_clinic_appointment_encounter_id; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_mcms_clinic_appointment_encounter_id ON mcms_clinic.appointment USING btree (encounter_id);


--
-- Name: ix_mcms_clinic_appointment_mrn; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_mcms_clinic_appointment_mrn ON mcms_clinic.appointment USING btree (mrn);


--
-- Name: ix_mcms_clinic_appointment_room_id; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_mcms_clinic_appointment_room_id ON mcms_clinic.appointment USING btree (room_id);


--
-- Name: ix_mcms_clinic_consultation_appointment_id; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_mcms_clinic_consultation_appointment_id ON mcms_clinic.consultation USING btree (appointment_id);


--
-- Name: ix_mcms_clinic_consultation_queue_id; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_mcms_clinic_consultation_queue_id ON mcms_clinic.consultation USING btree (queue_id);


--
-- Name: ix_mcms_clinic_consultation_room_id; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_mcms_clinic_consultation_room_id ON mcms_clinic.consultation USING btree (room_id);


--
-- Name: ix_mcms_clinic_patient_queue_assigned_clinician; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_mcms_clinic_patient_queue_assigned_clinician ON mcms_clinic.patient_queue USING btree (assigned_clinician);


--
-- Name: ix_mcms_clinic_patient_queue_encounter_id; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_mcms_clinic_patient_queue_encounter_id ON mcms_clinic.patient_queue USING btree (encounter_id);


--
-- Name: ix_mcms_clinic_patient_queue_mrn; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_mcms_clinic_patient_queue_mrn ON mcms_clinic.patient_queue USING btree (mrn);


--
-- Name: ix_mcms_clinic_patient_queue_room_id; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_mcms_clinic_patient_queue_room_id ON mcms_clinic.patient_queue USING btree (room_id);


--
-- Name: ix_patient_queue_facility; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX ix_patient_queue_facility ON mcms_clinic.patient_queue USING btree (facility_id);


--
-- Name: patient_queue_department_id_status_priority_checked_in_at_idx; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX patient_queue_department_id_status_priority_checked_in_at_idx ON mcms_clinic.patient_queue USING btree (department_id, status, priority DESC, checked_in_at);


--
-- Name: patient_queue_patient_id_idx; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX patient_queue_patient_id_idx ON mcms_clinic.patient_queue USING btree (patient_id);


--
-- Name: room_department_id_idx; Type: INDEX; Schema: mcms_clinic; Owner: -
--

CREATE INDEX room_department_id_idx ON mcms_clinic.room USING btree (department_id);


--
-- Name: address_party_id_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX address_party_id_idx ON mcms_core.address USING btree (party_id);


--
-- Name: app_user_role_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX app_user_role_idx ON mcms_core.app_user USING btree (role);


--
-- Name: audit_trail_changed_at_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX audit_trail_changed_at_idx ON mcms_core.audit_trail USING btree (changed_at DESC);


--
-- Name: audit_trail_table_schema_table_name_row_id_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX audit_trail_table_schema_table_name_row_id_idx ON mcms_core.audit_trail USING btree (table_schema, table_name, row_id);


--
-- Name: contact_party_id_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX contact_party_id_idx ON mcms_core.contact USING btree (party_id);


--
-- Name: contact_value_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX contact_value_idx ON mcms_core.contact USING btree (value);


--
-- Name: event_log_actor_user_id_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX event_log_actor_user_id_idx ON mcms_core.event_log USING btree (actor_user_id);


--
-- Name: event_log_kind_occurred_at_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX event_log_kind_occurred_at_idx ON mcms_core.event_log USING btree (kind, occurred_at DESC);


--
-- Name: event_log_payload_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX event_log_payload_idx ON mcms_core.event_log USING gin (payload);


--
-- Name: event_log_source_schema_source_table_source_id_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX event_log_source_schema_source_table_source_id_idx ON mcms_core.event_log USING btree (source_schema, source_table, source_id);


--
-- Name: event_log_subject_party_id_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX event_log_subject_party_id_idx ON mcms_core.event_log USING btree (subject_party_id);


--
-- Name: event_seq_uq; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE UNIQUE INDEX event_seq_uq ON mcms_core.event_log USING btree (seq);


--
-- Name: ix_access_log_party; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_access_log_party ON mcms_core.access_log USING btree (subject_party_id, read_at DESC);


--
-- Name: ix_access_log_table; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_access_log_table ON mcms_core.access_log USING btree (table_schema, table_name, row_id);


--
-- Name: ix_app_user_facility; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_app_user_facility ON mcms_core.app_user USING btree (facility_id);


--
-- Name: ix_consent_party; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_consent_party ON mcms_core.consent USING btree (party_id);


--
-- Name: ix_fed_identity_user; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_fed_identity_user ON mcms_core.federated_identity USING btree (user_id);


--
-- Name: ix_hl7_message_facility; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_hl7_message_facility ON mcms_core.hl7_message USING btree (facility_id);


--
-- Name: ix_hl7_message_received; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_hl7_message_received ON mcms_core.hl7_message USING btree (received_at);


--
-- Name: ix_hl7_message_type; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_hl7_message_type ON mcms_core.hl7_message USING btree (message_type);


--
-- Name: ix_mcms_core_app_user_party_id; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_mcms_core_app_user_party_id ON mcms_core.app_user USING btree (party_id);


--
-- Name: ix_mcms_core_audit_trail_changed_by; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_mcms_core_audit_trail_changed_by ON mcms_core.audit_trail USING btree (changed_by);


--
-- Name: ix_mcms_core_audit_trail_event_id; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_mcms_core_audit_trail_event_id ON mcms_core.audit_trail USING btree (event_id);


--
-- Name: ix_mcms_core_user_role_map_department_id; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_mcms_core_user_role_map_department_id ON mcms_core.user_role_map USING btree (department_id);


--
-- Name: ix_notif_party; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_notif_party ON mcms_core.notification USING btree (recipient_party_id);


--
-- Name: ix_notif_status; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_notif_status ON mcms_core.notification USING btree (status);


--
-- Name: ix_notif_user; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX ix_notif_user ON mcms_core.notification USING btree (recipient_user_id);


--
-- Name: lookup_namespace_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX lookup_namespace_idx ON mcms_core.lookup USING btree (namespace);


--
-- Name: lookup_parent_code_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX lookup_parent_code_idx ON mcms_core.lookup USING btree (parent_code);


--
-- Name: party_gender_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX party_gender_idx ON mcms_core.party USING btree (gender);


--
-- Name: party_party_type_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX party_party_type_idx ON mcms_core.party USING btree (party_type);


--
-- Name: party_to_tsvector_idx; Type: INDEX; Schema: mcms_core; Owner: -
--

CREATE INDEX party_to_tsvector_idx ON mcms_core.party USING gin (to_tsvector('simple'::regconfig, display_name));


--
-- Name: ix_dial_sess_patient; Type: INDEX; Schema: mcms_dialysis; Owner: -
--

CREATE INDEX ix_dial_sess_patient ON mcms_dialysis.session USING btree (patient_id);


--
-- Name: ix_dial_sess_sched; Type: INDEX; Schema: mcms_dialysis; Owner: -
--

CREATE INDEX ix_dial_sess_sched ON mcms_dialysis.session USING btree (scheduled_at);


--
-- Name: ix_mcms_dialysis_session_encounter_id; Type: INDEX; Schema: mcms_dialysis; Owner: -
--

CREATE INDEX ix_mcms_dialysis_session_encounter_id ON mcms_dialysis.session USING btree (encounter_id);


--
-- Name: ix_mcms_dialysis_session_nephrologist_user_id; Type: INDEX; Schema: mcms_dialysis; Owner: -
--

CREATE INDEX ix_mcms_dialysis_session_nephrologist_user_id ON mcms_dialysis.session USING btree (nephrologist_user_id);


--
-- Name: ix_mcms_dialysis_session_nurse_user_id; Type: INDEX; Schema: mcms_dialysis; Owner: -
--

CREATE INDEX ix_mcms_dialysis_session_nurse_user_id ON mcms_dialysis.session USING btree (nurse_user_id);


--
-- Name: ix_mcms_dialysis_session_station_id; Type: INDEX; Schema: mcms_dialysis; Owner: -
--

CREATE INDEX ix_mcms_dialysis_session_station_id ON mcms_dialysis.session USING btree (station_id);


--
-- Name: ix_mcms_dialysis_station_department_id; Type: INDEX; Schema: mcms_dialysis; Owner: -
--

CREATE INDEX ix_mcms_dialysis_station_department_id ON mcms_dialysis.station USING btree (department_id);


--
-- Name: ed_bed_triage_id_idx; Type: INDEX; Schema: mcms_emergency; Owner: -
--

CREATE INDEX ed_bed_triage_id_idx ON mcms_emergency.ed_bed USING btree (triage_id);


--
-- Name: ix_ed_bed_facility; Type: INDEX; Schema: mcms_emergency; Owner: -
--

CREATE INDEX ix_ed_bed_facility ON mcms_emergency.ed_bed USING btree (facility_id);


--
-- Name: ix_mcms_emergency_resuscitation_encounter_id; Type: INDEX; Schema: mcms_emergency; Owner: -
--

CREATE INDEX ix_mcms_emergency_resuscitation_encounter_id ON mcms_emergency.resuscitation USING btree (encounter_id);


--
-- Name: ix_mcms_emergency_resuscitation_team_leader_id; Type: INDEX; Schema: mcms_emergency; Owner: -
--

CREATE INDEX ix_mcms_emergency_resuscitation_team_leader_id ON mcms_emergency.resuscitation USING btree (team_leader_id);


--
-- Name: ix_mcms_emergency_triage_mrn; Type: INDEX; Schema: mcms_emergency; Owner: -
--

CREATE INDEX ix_mcms_emergency_triage_mrn ON mcms_emergency.triage USING btree (mrn);


--
-- Name: ix_mcms_emergency_triage_triage_nurse_user_id; Type: INDEX; Schema: mcms_emergency; Owner: -
--

CREATE INDEX ix_mcms_emergency_triage_triage_nurse_user_id ON mcms_emergency.triage USING btree (triage_nurse_user_id);


--
-- Name: resuscitation_patient_id_idx; Type: INDEX; Schema: mcms_emergency; Owner: -
--

CREATE INDEX resuscitation_patient_id_idx ON mcms_emergency.resuscitation USING btree (patient_id);


--
-- Name: resuscitation_triage_id_idx; Type: INDEX; Schema: mcms_emergency; Owner: -
--

CREATE INDEX resuscitation_triage_id_idx ON mcms_emergency.resuscitation USING btree (triage_id);


--
-- Name: triage_encounter_id_idx; Type: INDEX; Schema: mcms_emergency; Owner: -
--

CREATE INDEX triage_encounter_id_idx ON mcms_emergency.triage USING btree (encounter_id);


--
-- Name: triage_esi_level_status_presentation_time_idx; Type: INDEX; Schema: mcms_emergency; Owner: -
--

CREATE INDEX triage_esi_level_status_presentation_time_idx ON mcms_emergency.triage USING btree (esi_level, status, presentation_time DESC);


--
-- Name: triage_patient_id_idx; Type: INDEX; Schema: mcms_emergency; Owner: -
--

CREATE INDEX triage_patient_id_idx ON mcms_emergency.triage USING btree (patient_id);


--
-- Name: allergy_patient_id_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX allergy_patient_id_idx ON mcms_emr.allergy USING btree (patient_id);


--
-- Name: allergy_substance_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX allergy_substance_idx ON mcms_emr.allergy USING btree (substance);


--
-- Name: clinical_note_encounter_id_created_at_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX clinical_note_encounter_id_created_at_idx ON mcms_emr.clinical_note USING btree (encounter_id, created_at DESC);


--
-- Name: clinical_note_patient_id_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX clinical_note_patient_id_idx ON mcms_emr.clinical_note USING btree (patient_id);


--
-- Name: clinical_note_to_tsvector_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX clinical_note_to_tsvector_idx ON mcms_emr.clinical_note USING gin (to_tsvector('english'::regconfig, body));


--
-- Name: diagnosis_condition_code_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX diagnosis_condition_code_idx ON mcms_emr.diagnosis USING btree (condition_code);


--
-- Name: diagnosis_encounter_id_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX diagnosis_encounter_id_idx ON mcms_emr.diagnosis USING btree (encounter_id);


--
-- Name: diagnosis_patient_id_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX diagnosis_patient_id_idx ON mcms_emr.diagnosis USING btree (patient_id);


--
-- Name: encounter_attending_user_id_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX encounter_attending_user_id_idx ON mcms_emr.encounter USING btree (attending_user_id);


--
-- Name: encounter_class_status_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX encounter_class_status_idx ON mcms_emr.encounter USING btree (class, status);


--
-- Name: encounter_patient_id_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX encounter_patient_id_idx ON mcms_emr.encounter USING btree (patient_id);


--
-- Name: encounter_status_started_at_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX encounter_status_started_at_idx ON mcms_emr.encounter USING btree (status, started_at DESC);


--
-- Name: family_history_patient_id_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX family_history_patient_id_idx ON mcms_emr.family_history USING btree (patient_id);


--
-- Name: immunization_patient_id_given_at_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX immunization_patient_id_given_at_idx ON mcms_emr.immunization USING btree (patient_id, given_at DESC);


--
-- Name: ix_clinical_note_facility; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_clinical_note_facility ON mcms_emr.clinical_note USING btree (facility_id);


--
-- Name: ix_diagnosis_facility; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_diagnosis_facility ON mcms_emr.diagnosis USING btree (facility_id);


--
-- Name: ix_encounter_facility; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_encounter_facility ON mcms_emr.encounter USING btree (facility_id);


--
-- Name: ix_mcms_emr_allergy_noted_by; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_mcms_emr_allergy_noted_by ON mcms_emr.allergy USING btree (noted_by);


--
-- Name: ix_mcms_emr_clinical_note_author_user_id; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_mcms_emr_clinical_note_author_user_id ON mcms_emr.clinical_note USING btree (author_user_id);


--
-- Name: ix_mcms_emr_diagnosis_recorded_by; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_mcms_emr_diagnosis_recorded_by ON mcms_emr.diagnosis USING btree (recorded_by);


--
-- Name: ix_mcms_emr_encounter_department_id; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_mcms_emr_encounter_department_id ON mcms_emr.encounter USING btree (department_id);


--
-- Name: ix_mcms_emr_encounter_mrn; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_mcms_emr_encounter_mrn ON mcms_emr.encounter USING btree (mrn);


--
-- Name: ix_mcms_emr_encounter_originating_encounter_id; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_mcms_emr_encounter_originating_encounter_id ON mcms_emr.encounter USING btree (originating_encounter_id);


--
-- Name: ix_mcms_emr_encounter_referring_user_id; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_mcms_emr_encounter_referring_user_id ON mcms_emr.encounter USING btree (referring_user_id);


--
-- Name: ix_mcms_emr_immunization_given_by; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_mcms_emr_immunization_given_by ON mcms_emr.immunization USING btree (given_by);


--
-- Name: ix_mcms_emr_medication_order_prescriber_user_id; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_mcms_emr_medication_order_prescriber_user_id ON mcms_emr.medication_order USING btree (prescriber_user_id);


--
-- Name: ix_mcms_emr_patient_next_of_kin_party_id; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_mcms_emr_patient_next_of_kin_party_id ON mcms_emr.patient USING btree (next_of_kin_party_id);


--
-- Name: ix_mcms_emr_vitals_taken_by; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_mcms_emr_vitals_taken_by ON mcms_emr.vitals USING btree (taken_by);


--
-- Name: ix_medication_order_drug_item; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_medication_order_drug_item ON mcms_emr.medication_order USING btree (drug_item_id);


--
-- Name: ix_medication_order_facility; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_medication_order_facility ON mcms_emr.medication_order USING btree (facility_id);


--
-- Name: ix_patient_facility; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_patient_facility ON mcms_emr.patient USING btree (facility_id);


--
-- Name: ix_referral_facility; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_referral_facility ON mcms_emr.referral USING btree (facility_id);


--
-- Name: ix_referral_from; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_referral_from ON mcms_emr.referral USING btree (from_encounter_id);


--
-- Name: ix_referral_status; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_referral_status ON mcms_emr.referral USING btree (status);


--
-- Name: ix_referral_to_user; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_referral_to_user ON mcms_emr.referral USING btree (to_user_id);


--
-- Name: ix_vitals_facility; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX ix_vitals_facility ON mcms_emr.vitals USING btree (facility_id);


--
-- Name: medication_order_encounter_id_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX medication_order_encounter_id_idx ON mcms_emr.medication_order USING btree (encounter_id);


--
-- Name: medication_order_patient_id_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX medication_order_patient_id_idx ON mcms_emr.medication_order USING btree (patient_id);


--
-- Name: medication_order_status_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX medication_order_status_idx ON mcms_emr.medication_order USING btree (status);


--
-- Name: patient_insurance_provider_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX patient_insurance_provider_idx ON mcms_emr.patient USING btree (insurance_provider);


--
-- Name: social_history_patient_id_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX social_history_patient_id_idx ON mcms_emr.social_history USING btree (patient_id);


--
-- Name: vitals_encounter_id_taken_at_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX vitals_encounter_id_taken_at_idx ON mcms_emr.vitals USING btree (encounter_id, taken_at);


--
-- Name: vitals_patient_id_taken_at_idx; Type: INDEX; Schema: mcms_emr; Owner: -
--

CREATE INDEX vitals_patient_id_taken_at_idx ON mcms_emr.vitals USING btree (patient_id, taken_at DESC);


--
-- Name: gl_account_account_type_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX gl_account_account_type_idx ON mcms_erp.gl_account USING btree (account_type);


--
-- Name: gl_account_parent_account_id_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX gl_account_parent_account_id_idx ON mcms_erp.gl_account USING btree (parent_account_id);


--
-- Name: goods_receipt_line_grn_id_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX goods_receipt_line_grn_id_idx ON mcms_erp.goods_receipt_line USING btree (grn_id);


--
-- Name: goods_receipt_po_id_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX goods_receipt_po_id_idx ON mcms_erp.goods_receipt USING btree (po_id);


--
-- Name: goods_receipt_supplier_id_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX goods_receipt_supplier_id_idx ON mcms_erp.goods_receipt USING btree (supplier_id);


--
-- Name: inventory_item_type_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX inventory_item_type_idx ON mcms_erp.inventory_item USING btree (type);


--
-- Name: inventory_stock_department_id_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX inventory_stock_department_id_idx ON mcms_erp.inventory_stock USING btree (department_id);


--
-- Name: ix_mcms_erp_goods_receipt_line_drug_item_id; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX ix_mcms_erp_goods_receipt_line_drug_item_id ON mcms_erp.goods_receipt_line USING btree (drug_item_id);


--
-- Name: ix_mcms_erp_goods_receipt_line_item_id; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX ix_mcms_erp_goods_receipt_line_item_id ON mcms_erp.goods_receipt_line USING btree (item_id);


--
-- Name: ix_mcms_erp_goods_receipt_line_po_line_id; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX ix_mcms_erp_goods_receipt_line_po_line_id ON mcms_erp.goods_receipt_line USING btree (po_line_id);


--
-- Name: ix_mcms_erp_goods_receipt_received_by; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX ix_mcms_erp_goods_receipt_received_by ON mcms_erp.goods_receipt USING btree (received_by);


--
-- Name: ix_mcms_erp_purchase_order_approved_by; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX ix_mcms_erp_purchase_order_approved_by ON mcms_erp.purchase_order USING btree (approved_by);


--
-- Name: ix_mcms_erp_purchase_order_line_drug_item_id; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX ix_mcms_erp_purchase_order_line_drug_item_id ON mcms_erp.purchase_order_line USING btree (drug_item_id);


--
-- Name: ix_mcms_erp_purchase_order_line_item_id; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX ix_mcms_erp_purchase_order_line_item_id ON mcms_erp.purchase_order_line USING btree (item_id);


--
-- Name: ix_mcms_erp_purchase_order_requested_by; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX ix_mcms_erp_purchase_order_requested_by ON mcms_erp.purchase_order USING btree (requested_by);


--
-- Name: ix_mcms_erp_stock_movement_performed_by; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX ix_mcms_erp_stock_movement_performed_by ON mcms_erp.stock_movement USING btree (performed_by);


--
-- Name: ix_mcms_erp_supplier_contact_user_id; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX ix_mcms_erp_supplier_contact_user_id ON mcms_erp.supplier USING btree (contact_user_id);


--
-- Name: ix_purchase_order_facility; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX ix_purchase_order_facility ON mcms_erp.purchase_order USING btree (facility_id);


--
-- Name: ix_purchase_order_line_facility; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX ix_purchase_order_line_facility ON mcms_erp.purchase_order_line USING btree (facility_id);


--
-- Name: purchase_order_line_po_id_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX purchase_order_line_po_id_idx ON mcms_erp.purchase_order_line USING btree (po_id);


--
-- Name: purchase_order_status_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX purchase_order_status_idx ON mcms_erp.purchase_order USING btree (status);


--
-- Name: purchase_order_supplier_id_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX purchase_order_supplier_id_idx ON mcms_erp.purchase_order USING btree (supplier_id);


--
-- Name: stock_movement_from_department_id_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX stock_movement_from_department_id_idx ON mcms_erp.stock_movement USING btree (from_department_id);


--
-- Name: stock_movement_item_id_performed_at_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX stock_movement_item_id_performed_at_idx ON mcms_erp.stock_movement USING btree (item_id, performed_at);


--
-- Name: stock_movement_to_department_id_idx; Type: INDEX; Schema: mcms_erp; Owner: -
--

CREATE INDEX stock_movement_to_department_id_idx ON mcms_erp.stock_movement USING btree (to_department_id);


--
-- Name: attendance_employee_id_clock_in_at_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX attendance_employee_id_clock_in_at_idx ON mcms_hr.attendance USING btree (employee_id, clock_in_at DESC);


--
-- Name: department_kind_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX department_kind_idx ON mcms_hr.department USING btree (kind);


--
-- Name: department_parent_department_id_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX department_parent_department_id_idx ON mcms_hr.department USING btree (parent_department_id);


--
-- Name: employee_department_department_id_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX employee_department_department_id_idx ON mcms_hr.employee_department USING btree (department_id);


--
-- Name: employee_department_employee_id_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX employee_department_employee_id_idx ON mcms_hr.employee_department USING btree (employee_id);


--
-- Name: employee_primary_department_id_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX employee_primary_department_id_idx ON mcms_hr.employee USING btree (primary_department_id);


--
-- Name: employee_status_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX employee_status_idx ON mcms_hr.employee USING btree (status);


--
-- Name: ix_mcms_hr_attendance_shift_id; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX ix_mcms_hr_attendance_shift_id ON mcms_hr.attendance USING btree (shift_id);


--
-- Name: ix_mcms_hr_department_head_user_id; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX ix_mcms_hr_department_head_user_id ON mcms_hr.department USING btree (head_user_id);


--
-- Name: ix_mcms_hr_employee_user_id; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX ix_mcms_hr_employee_user_id ON mcms_hr.employee USING btree (user_id);


--
-- Name: ix_mcms_hr_leave_request_approved_by; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX ix_mcms_hr_leave_request_approved_by ON mcms_hr.leave_request USING btree (approved_by);


--
-- Name: leave_request_employee_id_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX leave_request_employee_id_idx ON mcms_hr.leave_request USING btree (employee_id);


--
-- Name: leave_request_status_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX leave_request_status_idx ON mcms_hr.leave_request USING btree (status);


--
-- Name: payroll_item_employee_id_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX payroll_item_employee_id_idx ON mcms_hr.payroll_item USING btree (employee_id);


--
-- Name: payroll_item_period_id_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX payroll_item_period_id_idx ON mcms_hr.payroll_item USING btree (period_id);


--
-- Name: shift_department_id_start_at_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX shift_department_id_start_at_idx ON mcms_hr.shift USING btree (department_id, start_at);


--
-- Name: shift_employee_id_idx; Type: INDEX; Schema: mcms_hr; Owner: -
--

CREATE INDEX shift_employee_id_idx ON mcms_hr.shift USING btree (employee_id);


--
-- Name: admission_encounter_id_idx; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX admission_encounter_id_idx ON mcms_icu.admission USING btree (encounter_id);


--
-- Name: admission_patient_id_idx; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX admission_patient_id_idx ON mcms_icu.admission USING btree (patient_id);


--
-- Name: admission_status_admitted_at_idx; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX admission_status_admitted_at_idx ON mcms_icu.admission USING btree (status, admitted_at DESC);


--
-- Name: bed_department_id_idx; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX bed_department_id_idx ON mcms_icu.bed USING btree (department_id);


--
-- Name: bed_status_idx; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX bed_status_idx ON mcms_icu.bed USING btree (status);


--
-- Name: bed_stay_admission_id_idx; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX bed_stay_admission_id_idx ON mcms_icu.bed_stay USING btree (admission_id);


--
-- Name: bed_stay_bed_id_assigned_at_idx; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX bed_stay_bed_id_assigned_at_idx ON mcms_icu.bed_stay USING btree (bed_id, assigned_at DESC);


--
-- Name: ix_admission_facility; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX ix_admission_facility ON mcms_icu.admission USING btree (facility_id);


--
-- Name: ix_admission_mrn; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX ix_admission_mrn ON mcms_icu.admission USING btree (mrn);


--
-- Name: ix_bed_facility; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX ix_bed_facility ON mcms_icu.bed USING btree (facility_id);


--
-- Name: ix_bed_stay_facility; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX ix_bed_stay_facility ON mcms_icu.bed_stay USING btree (facility_id);


--
-- Name: ix_mcms_icu_admission_attending_nurse_id; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX ix_mcms_icu_admission_attending_nurse_id ON mcms_icu.admission USING btree (attending_nurse_id);


--
-- Name: ix_mcms_icu_admission_bed_id; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX ix_mcms_icu_admission_bed_id ON mcms_icu.admission USING btree (bed_id);


--
-- Name: ix_mcms_icu_admission_primary_physician_id; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX ix_mcms_icu_admission_primary_physician_id ON mcms_icu.admission USING btree (primary_physician_id);


--
-- Name: ix_mcms_icu_score_assessed_by; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX ix_mcms_icu_score_assessed_by ON mcms_icu.score USING btree (assessed_by);


--
-- Name: ix_mcms_icu_vitals_stream_charted_by; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX ix_mcms_icu_vitals_stream_charted_by ON mcms_icu.vitals_stream USING btree (charted_by);


--
-- Name: ix_mcms_icu_vitals_stream_patient_id; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX ix_mcms_icu_vitals_stream_patient_id ON mcms_icu.vitals_stream USING btree (patient_id);


--
-- Name: ix_vitals_stream_facility; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX ix_vitals_stream_facility ON mcms_icu.vitals_stream USING btree (facility_id);


--
-- Name: score_admission_id_type_assessed_at_idx; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX score_admission_id_type_assessed_at_idx ON mcms_icu.score USING btree (admission_id, type, assessed_at DESC);


--
-- Name: support_session_admission_id_idx; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX support_session_admission_id_idx ON mcms_icu.support_session USING btree (admission_id);


--
-- Name: vitals_stream_admission_id_recorded_at_idx; Type: INDEX; Schema: mcms_icu; Owner: -
--

CREATE INDEX vitals_stream_admission_id_recorded_at_idx ON mcms_icu.vitals_stream USING btree (admission_id, recorded_at);


--
-- Name: ix_lab_order_facility; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX ix_lab_order_facility ON mcms_lab.lab_order USING btree (facility_id);


--
-- Name: ix_lab_order_mrn; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX ix_lab_order_mrn ON mcms_lab.lab_order USING btree (mrn);


--
-- Name: ix_mcms_lab_lab_order_panel_id; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX ix_mcms_lab_lab_order_panel_id ON mcms_lab.lab_order USING btree (panel_id);


--
-- Name: ix_mcms_lab_lab_order_requested_by; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX ix_mcms_lab_lab_order_requested_by ON mcms_lab.lab_order USING btree (requested_by);


--
-- Name: ix_mcms_lab_result_analysed_by; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX ix_mcms_lab_result_analysed_by ON mcms_lab.result USING btree (analysed_by);


--
-- Name: ix_mcms_lab_result_verified_by; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX ix_mcms_lab_result_verified_by ON mcms_lab.result USING btree (verified_by);


--
-- Name: ix_mcms_lab_sample_collected_by; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX ix_mcms_lab_sample_collected_by ON mcms_lab.sample USING btree (collected_by);


--
-- Name: ix_mcms_lab_sample_received_by; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX ix_mcms_lab_sample_received_by ON mcms_lab.sample USING btree (received_by);


--
-- Name: ix_mcms_lab_test_panel_item_panel_id; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX ix_mcms_lab_test_panel_item_panel_id ON mcms_lab.test_panel_item USING btree (panel_id);


--
-- Name: ix_mcms_lab_test_panel_item_test_id; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX ix_mcms_lab_test_panel_item_test_id ON mcms_lab.test_panel_item USING btree (test_id);


--
-- Name: ix_result_facility; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX ix_result_facility ON mcms_lab.result USING btree (facility_id);


--
-- Name: ix_sample_facility; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX ix_sample_facility ON mcms_lab.sample USING btree (facility_id);


--
-- Name: lab_order_encounter_id_idx; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX lab_order_encounter_id_idx ON mcms_lab.lab_order USING btree (encounter_id);


--
-- Name: lab_order_order_priority_requested_at_idx; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX lab_order_order_priority_requested_at_idx ON mcms_lab.lab_order USING btree (order_priority, requested_at);


--
-- Name: lab_order_patient_id_idx; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX lab_order_patient_id_idx ON mcms_lab.lab_order USING btree (patient_id);


--
-- Name: result_flag_idx; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX result_flag_idx ON mcms_lab.result USING btree (flag);


--
-- Name: result_sample_id_idx; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX result_sample_id_idx ON mcms_lab.result USING btree (sample_id);


--
-- Name: sample_lab_order_id_idx; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX sample_lab_order_id_idx ON mcms_lab.sample USING btree (lab_order_id);


--
-- Name: sample_status_idx; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX sample_status_idx ON mcms_lab.sample USING btree (status);


--
-- Name: test_catalog_category_idx; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX test_catalog_category_idx ON mcms_lab.test_catalog USING btree (category);


--
-- Name: test_catalog_loinc_code_idx; Type: INDEX; Schema: mcms_lab; Owner: -
--

CREATE INDEX test_catalog_loinc_code_idx ON mcms_lab.test_catalog USING btree (loinc_code);


--
-- Name: ix_growth_neonate; Type: INDEX; Schema: mcms_nursery; Owner: -
--

CREATE INDEX ix_growth_neonate ON mcms_nursery.growth_entry USING btree (neonate_id);


--
-- Name: ix_mcms_nursery_cot_department_id; Type: INDEX; Schema: mcms_nursery; Owner: -
--

CREATE INDEX ix_mcms_nursery_cot_department_id ON mcms_nursery.cot USING btree (department_id);


--
-- Name: ix_mcms_nursery_growth_entry_nurse_user_id; Type: INDEX; Schema: mcms_nursery; Owner: -
--

CREATE INDEX ix_mcms_nursery_growth_entry_nurse_user_id ON mcms_nursery.growth_entry USING btree (nurse_user_id);


--
-- Name: ix_mcms_nursery_neonate_record_cot_id; Type: INDEX; Schema: mcms_nursery; Owner: -
--

CREATE INDEX ix_mcms_nursery_neonate_record_cot_id ON mcms_nursery.neonate_record USING btree (cot_id);


--
-- Name: ix_mcms_nursery_neonate_record_mother_party_id; Type: INDEX; Schema: mcms_nursery; Owner: -
--

CREATE INDEX ix_mcms_nursery_neonate_record_mother_party_id ON mcms_nursery.neonate_record USING btree (mother_party_id);


--
-- Name: ix_neonate_patient; Type: INDEX; Schema: mcms_nursery; Owner: -
--

CREATE INDEX ix_neonate_patient ON mcms_nursery.neonate_record USING btree (patient_id);


--
-- Name: ix_mcms_physio_session_room_id; Type: INDEX; Schema: mcms_physio; Owner: -
--

CREATE INDEX ix_mcms_physio_session_room_id ON mcms_physio.session USING btree (room_id);


--
-- Name: ix_mcms_physio_session_therapy_id; Type: INDEX; Schema: mcms_physio; Owner: -
--

CREATE INDEX ix_mcms_physio_session_therapy_id ON mcms_physio.session USING btree (therapy_id);


--
-- Name: ix_mcms_physio_treatment_plan_encounter_id; Type: INDEX; Schema: mcms_physio; Owner: -
--

CREATE INDEX ix_mcms_physio_treatment_plan_encounter_id ON mcms_physio.treatment_plan USING btree (encounter_id);


--
-- Name: session_patient_id_scheduled_at_idx; Type: INDEX; Schema: mcms_physio; Owner: -
--

CREATE INDEX session_patient_id_scheduled_at_idx ON mcms_physio.session USING btree (patient_id, scheduled_at DESC);


--
-- Name: session_plan_id_idx; Type: INDEX; Schema: mcms_physio; Owner: -
--

CREATE INDEX session_plan_id_idx ON mcms_physio.session USING btree (plan_id);


--
-- Name: session_status_idx; Type: INDEX; Schema: mcms_physio; Owner: -
--

CREATE INDEX session_status_idx ON mcms_physio.session USING btree (status);


--
-- Name: session_therapist_user_id_scheduled_at_idx; Type: INDEX; Schema: mcms_physio; Owner: -
--

CREATE INDEX session_therapist_user_id_scheduled_at_idx ON mcms_physio.session USING btree (therapist_user_id, scheduled_at);


--
-- Name: therapy_catalog_body_region_idx; Type: INDEX; Schema: mcms_physio; Owner: -
--

CREATE INDEX therapy_catalog_body_region_idx ON mcms_physio.therapy_catalog USING btree (body_region);


--
-- Name: therapy_catalog_type_idx; Type: INDEX; Schema: mcms_physio; Owner: -
--

CREATE INDEX therapy_catalog_type_idx ON mcms_physio.therapy_catalog USING btree (type);


--
-- Name: treatment_plan_patient_id_idx; Type: INDEX; Schema: mcms_physio; Owner: -
--

CREATE INDEX treatment_plan_patient_id_idx ON mcms_physio.treatment_plan USING btree (patient_id);


--
-- Name: treatment_plan_therapist_user_id_idx; Type: INDEX; Schema: mcms_physio; Owner: -
--

CREATE INDEX treatment_plan_therapist_user_id_idx ON mcms_physio.treatment_plan USING btree (therapist_user_id);


--
-- Name: exam_catalog_body_part_idx; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX exam_catalog_body_part_idx ON mcms_rad.exam_catalog USING btree (body_part);


--
-- Name: exam_catalog_default_modality_idx; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX exam_catalog_default_modality_idx ON mcms_rad.exam_catalog USING btree (default_modality);


--
-- Name: image_instance_study_id_idx; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX image_instance_study_id_idx ON mcms_rad.image_instance USING btree (study_id);


--
-- Name: ix_mcms_rad_modality_suite_department_id; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX ix_mcms_rad_modality_suite_department_id ON mcms_rad.modality_suite USING btree (department_id);


--
-- Name: ix_mcms_rad_study_request_exam_id; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX ix_mcms_rad_study_request_exam_id ON mcms_rad.study_request USING btree (exam_id);


--
-- Name: ix_mcms_rad_study_request_reported_by; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX ix_mcms_rad_study_request_reported_by ON mcms_rad.study_request USING btree (reported_by);


--
-- Name: ix_mcms_rad_study_request_verified_by; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX ix_mcms_rad_study_request_verified_by ON mcms_rad.study_request USING btree (verified_by);


--
-- Name: ix_study_request_mrn; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX ix_study_request_mrn ON mcms_rad.study_request USING btree (mrn);


--
-- Name: modality_suite_modality_idx; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX modality_suite_modality_idx ON mcms_rad.modality_suite USING btree (modality);


--
-- Name: study_request_encounter_id_idx; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX study_request_encounter_id_idx ON mcms_rad.study_request USING btree (encounter_id);


--
-- Name: study_request_patient_id_idx; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX study_request_patient_id_idx ON mcms_rad.study_request USING btree (patient_id);


--
-- Name: study_request_status_requested_by_idx; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX study_request_status_requested_by_idx ON mcms_rad.study_request USING btree (status, requested_by);


--
-- Name: study_request_suite_id_scheduled_at_idx; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX study_request_suite_id_scheduled_at_idx ON mcms_rad.study_request USING btree (suite_id, scheduled_at);


--
-- Name: study_request_to_tsvector_idx; Type: INDEX; Schema: mcms_rad; Owner: -
--

CREATE INDEX study_request_to_tsvector_idx ON mcms_rad.study_request USING gin (to_tsvector('english'::regconfig, ((COALESCE(findings, ''::text) || ' '::text) || COALESCE(impression, ''::text))));


--
-- Name: administration_patient_id_dose_at_idx; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX administration_patient_id_dose_at_idx ON mcms_rx.administration USING btree (patient_id, dose_at DESC);


--
-- Name: dispensation_med_order_id_idx; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX dispensation_med_order_id_idx ON mcms_rx.dispensation USING btree (med_order_id);


--
-- Name: dispensation_patient_id_dispensed_at_idx; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX dispensation_patient_id_dispensed_at_idx ON mcms_rx.dispensation USING btree (patient_id, dispensed_at DESC);


--
-- Name: drug_item_drug_class_idx; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX drug_item_drug_class_idx ON mcms_rx.drug_item USING btree (drug_class);


--
-- Name: drug_item_to_tsvector_idx; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX drug_item_to_tsvector_idx ON mcms_rx.drug_item USING gin (to_tsvector('english'::regconfig, ((generic_name || ' '::text) || COALESCE(brand_name, ''::text))));


--
-- Name: drug_lot_drug_item_id_idx; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX drug_lot_drug_item_id_idx ON mcms_rx.drug_lot USING btree (drug_item_id);


--
-- Name: drug_lot_expires_on_idx; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX drug_lot_expires_on_idx ON mcms_rx.drug_lot USING btree (expires_on);


--
-- Name: drug_lot_status_idx; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX drug_lot_status_idx ON mcms_rx.drug_lot USING btree (status);


--
-- Name: ix_interaction_a; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_interaction_a ON mcms_rx.drug_interaction USING btree (drug_item_id_a);


--
-- Name: ix_interaction_b; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_interaction_b ON mcms_rx.drug_interaction USING btree (drug_item_id_b);


--
-- Name: ix_mcms_rx_administration_administered_by; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_administration_administered_by ON mcms_rx.administration USING btree (administered_by);


--
-- Name: ix_mcms_rx_administration_drug_item_id; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_administration_drug_item_id ON mcms_rx.administration USING btree (drug_item_id);


--
-- Name: ix_mcms_rx_administration_med_order_id; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_administration_med_order_id ON mcms_rx.administration USING btree (med_order_id);


--
-- Name: ix_mcms_rx_administration_witnessed_by; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_administration_witnessed_by ON mcms_rx.administration USING btree (witnessed_by);


--
-- Name: ix_mcms_rx_dispensation_dispensed_by; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_dispensation_dispensed_by ON mcms_rx.dispensation USING btree (dispensed_by);


--
-- Name: ix_mcms_rx_dispensation_drug_item_id; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_dispensation_drug_item_id ON mcms_rx.dispensation USING btree (drug_item_id);


--
-- Name: ix_mcms_rx_dispensation_encounter_id; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_dispensation_encounter_id ON mcms_rx.dispensation USING btree (encounter_id);


--
-- Name: ix_mcms_rx_dispensation_lot_id; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_dispensation_lot_id ON mcms_rx.dispensation USING btree (lot_id);


--
-- Name: ix_mcms_rx_dispensation_mrn; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_dispensation_mrn ON mcms_rx.dispensation USING btree (mrn);


--
-- Name: ix_mcms_rx_drug_lot_purchase_order_id; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_drug_lot_purchase_order_id ON mcms_rx.drug_lot USING btree (purchase_order_id);


--
-- Name: ix_mcms_rx_drug_lot_supplier_party_id; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_drug_lot_supplier_party_id ON mcms_rx.drug_lot USING btree (supplier_party_id);


--
-- Name: ix_mcms_rx_stock_movement_lot_id; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_stock_movement_lot_id ON mcms_rx.stock_movement USING btree (lot_id);


--
-- Name: ix_mcms_rx_stock_movement_performed_by; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_stock_movement_performed_by ON mcms_rx.stock_movement USING btree (performed_by);


--
-- Name: ix_mcms_rx_stock_movement_related_movement_id; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_mcms_rx_stock_movement_related_movement_id ON mcms_rx.stock_movement USING btree (related_movement_id);


--
-- Name: ix_prescription_facility; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_prescription_facility ON mcms_rx.prescription USING btree (facility_id);


--
-- Name: ix_prescription_mrn; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_prescription_mrn ON mcms_rx.prescription USING btree (mrn);


--
-- Name: ix_prescription_prescriber; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_prescription_prescriber ON mcms_rx.prescription USING btree (prescriber_user_id);


--
-- Name: ix_rx_prescription_drug; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_rx_prescription_drug ON mcms_rx.prescription USING btree (drug_item_id);


--
-- Name: ix_rx_prescription_patient; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX ix_rx_prescription_patient ON mcms_rx.prescription USING btree (patient_id);


--
-- Name: stock_movement_drug_item_id_performed_at_idx; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX stock_movement_drug_item_id_performed_at_idx ON mcms_rx.stock_movement USING btree (drug_item_id, performed_at);


--
-- Name: stock_movement_movement_type_idx; Type: INDEX; Schema: mcms_rx; Owner: -
--

CREATE INDEX stock_movement_movement_type_idx ON mcms_rx.stock_movement USING btree (movement_type);


--
-- Name: intra_op_vitals_surgery_id_recorded_at_idx; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX intra_op_vitals_surgery_id_recorded_at_idx ON mcms_surgical.intra_op_vitals USING btree (surgery_id, recorded_at);


--
-- Name: ix_intra_op_vitals_facility; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX ix_intra_op_vitals_facility ON mcms_surgical.intra_op_vitals USING btree (facility_id);


--
-- Name: ix_mcms_surgical_intra_op_vitals_recorded_by; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX ix_mcms_surgical_intra_op_vitals_recorded_by ON mcms_surgical.intra_op_vitals USING btree (recorded_by);


--
-- Name: ix_mcms_surgical_post_op_note_written_by; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX ix_mcms_surgical_post_op_note_written_by ON mcms_surgical.post_op_note USING btree (written_by);


--
-- Name: ix_mcms_surgical_pre_op_checklist_checklist_by; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX ix_mcms_surgical_pre_op_checklist_checklist_by ON mcms_surgical.pre_op_checklist USING btree (checklist_by);


--
-- Name: ix_mcms_surgical_surgery_anaesthetist_user_id; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX ix_mcms_surgical_surgery_anaesthetist_user_id ON mcms_surgical.surgery USING btree (anaesthetist_user_id);


--
-- Name: ix_mcms_surgical_surgery_encounter_id; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX ix_mcms_surgical_surgery_encounter_id ON mcms_surgical.surgery USING btree (encounter_id);


--
-- Name: ix_mcms_surgical_surgery_primary_dept_id; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX ix_mcms_surgical_surgery_primary_dept_id ON mcms_surgical.surgery USING btree (primary_dept_id);


--
-- Name: ix_mcms_surgical_surgery_procedure_id; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX ix_mcms_surgical_surgery_procedure_id ON mcms_surgical.surgery USING btree (procedure_id);


--
-- Name: ix_post_op_note_facility; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX ix_post_op_note_facility ON mcms_surgical.post_op_note USING btree (facility_id);


--
-- Name: operating_room_department_id_idx; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX operating_room_department_id_idx ON mcms_surgical.operating_room USING btree (department_id);


--
-- Name: post_op_note_surgery_id_idx; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX post_op_note_surgery_id_idx ON mcms_surgical.post_op_note USING btree (surgery_id);


--
-- Name: procedure_catalog_name_idx; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX procedure_catalog_name_idx ON mcms_surgical.procedure_catalog USING btree (name);


--
-- Name: surgery_or_id_scheduled_at_idx; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX surgery_or_id_scheduled_at_idx ON mcms_surgical.surgery USING btree (or_id, scheduled_at);


--
-- Name: surgery_patient_id_idx; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX surgery_patient_id_idx ON mcms_surgical.surgery USING btree (patient_id);


--
-- Name: surgery_status_scheduled_at_idx; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX surgery_status_scheduled_at_idx ON mcms_surgical.surgery USING btree (status, scheduled_at);


--
-- Name: surgery_surgeon_user_id_scheduled_at_idx; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX surgery_surgeon_user_id_scheduled_at_idx ON mcms_surgical.surgery USING btree (surgeon_user_id, scheduled_at);


--
-- Name: surgical_team_surgery_id_idx; Type: INDEX; Schema: mcms_surgical; Owner: -
--

CREATE INDEX surgical_team_surgery_id_idx ON mcms_surgical.surgical_team USING btree (surgery_id);


--
-- Name: ix_telemed_visit_encounter; Type: INDEX; Schema: mcms_telemed; Owner: -
--

CREATE INDEX ix_telemed_visit_encounter ON mcms_telemed.visit USING btree (encounter_id);


--
-- Name: ix_telemed_visit_patient; Type: INDEX; Schema: mcms_telemed; Owner: -
--

CREATE INDEX ix_telemed_visit_patient ON mcms_telemed.visit USING btree (patient_id);


--
-- Name: ix_visit_facility; Type: INDEX; Schema: mcms_telemed; Owner: -
--

CREATE INDEX ix_visit_facility ON mcms_telemed.visit USING btree (facility_id);


--
-- Name: ix_visit_mrn; Type: INDEX; Schema: mcms_telemed; Owner: -
--

CREATE INDEX ix_visit_mrn ON mcms_telemed.visit USING btree (mrn);


--
-- Name: ix_concept_display; Type: INDEX; Schema: mcms_terminology; Owner: -
--

CREATE INDEX ix_concept_display ON mcms_terminology.concept USING btree (code_system, display text_pattern_ops);


--
-- Name: ix_concept_facility; Type: INDEX; Schema: mcms_terminology; Owner: -
--

CREATE INDEX ix_concept_facility ON mcms_terminology.concept USING btree (facility_id);


--
-- Name: ix_birth_facility; Type: INDEX; Schema: mcms_vital_records; Owner: -
--

CREATE INDEX ix_birth_facility ON mcms_vital_records.birth_certificate USING btree (facility_id);


--
-- Name: ix_birth_mother; Type: INDEX; Schema: mcms_vital_records; Owner: -
--

CREATE INDEX ix_birth_mother ON mcms_vital_records.birth_certificate USING btree (mother_patient_id);


--
-- Name: ix_birth_newborn; Type: INDEX; Schema: mcms_vital_records; Owner: -
--

CREATE INDEX ix_birth_newborn ON mcms_vital_records.birth_certificate USING btree (newborn_patient_id);


--
-- Name: ix_birth_status; Type: INDEX; Schema: mcms_vital_records; Owner: -
--

CREATE INDEX ix_birth_status ON mcms_vital_records.birth_certificate USING btree (status);


--
-- Name: ix_death_cause; Type: INDEX; Schema: mcms_vital_records; Owner: -
--

CREATE INDEX ix_death_cause ON mcms_vital_records.death_certificate USING btree (cause_icd10);


--
-- Name: ix_death_facility; Type: INDEX; Schema: mcms_vital_records; Owner: -
--

CREATE INDEX ix_death_facility ON mcms_vital_records.death_certificate USING btree (facility_id);


--
-- Name: ix_death_patient; Type: INDEX; Schema: mcms_vital_records; Owner: -
--

CREATE INDEX ix_death_patient ON mcms_vital_records.death_certificate USING btree (patient_id);


--
-- Name: ix_death_status; Type: INDEX; Schema: mcms_vital_records; Owner: -
--

CREATE INDEX ix_death_status ON mcms_vital_records.death_certificate USING btree (status);


--
-- Name: ix_walloc_dept; Type: INDEX; Schema: mcms_waste; Owner: -
--

CREATE INDEX ix_walloc_dept ON mcms_waste.waste_cost_allocation USING btree (department_id);


--
-- Name: ix_walloc_manifest; Type: INDEX; Schema: mcms_waste; Owner: -
--

CREATE INDEX ix_walloc_manifest ON mcms_waste.waste_cost_allocation USING btree (manifest_id);


--
-- Name: ix_walloc_period; Type: INDEX; Schema: mcms_waste; Owner: -
--

CREATE INDEX ix_walloc_period ON mcms_waste.waste_cost_allocation USING btree (period_month);


--
-- Name: ix_wcollection_cont; Type: INDEX; Schema: mcms_waste; Owner: -
--

CREATE INDEX ix_wcollection_cont ON mcms_waste.waste_collection USING btree (container_id);


--
-- Name: ix_wcollection_dt; Type: INDEX; Schema: mcms_waste; Owner: -
--

CREATE INDEX ix_wcollection_dt ON mcms_waste.waste_collection USING btree (collection_datetime);


--
-- Name: ix_wcontainer_dept; Type: INDEX; Schema: mcms_waste; Owner: -
--

CREATE INDEX ix_wcontainer_dept ON mcms_waste.waste_container USING btree (department_id);


--
-- Name: ix_wcontainer_status; Type: INDEX; Schema: mcms_waste; Owner: -
--

CREATE INDEX ix_wcontainer_status ON mcms_waste.waste_container USING btree (status);


--
-- Name: ix_wcontainer_stream; Type: INDEX; Schema: mcms_waste; Owner: -
--

CREATE INDEX ix_wcontainer_stream ON mcms_waste.waste_container USING btree (stream_id);


--
-- Name: ix_wmanifest_dt; Type: INDEX; Schema: mcms_waste; Owner: -
--

CREATE INDEX ix_wmanifest_dt ON mcms_waste.waste_disposal_manifest USING btree (disposal_datetime);


--
-- Name: ix_wmanifest_status; Type: INDEX; Schema: mcms_waste; Owner: -
--

CREATE INDEX ix_wmanifest_status ON mcms_waste.waste_disposal_manifest USING btree (status);


--
-- Name: insurance_claim trg_claim_event; Type: TRIGGER; Schema: mcms_billing; Owner: -
--

CREATE TRIGGER trg_claim_event AFTER UPDATE OF status ON mcms_billing.insurance_claim FOR EACH ROW EXECUTE FUNCTION mcms_billing.fn_claim_event();


--
-- Name: insurance_claim trg_claim_notify; Type: TRIGGER; Schema: mcms_billing; Owner: -
--

CREATE TRIGGER trg_claim_notify AFTER INSERT OR UPDATE OF status ON mcms_billing.insurance_claim FOR EACH ROW EXECUTE FUNCTION mcms_billing.fn_claim_notify();


--
-- Name: insurance_claim trg_claim_touch; Type: TRIGGER; Schema: mcms_billing; Owner: -
--

CREATE TRIGGER trg_claim_touch BEFORE UPDATE ON mcms_billing.insurance_claim FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: invoice trg_inv_event; Type: TRIGGER; Schema: mcms_billing; Owner: -
--

CREATE TRIGGER trg_inv_event AFTER INSERT ON mcms_billing.invoice FOR EACH ROW EXECUTE FUNCTION mcms_billing.fn_invoice_event();


--
-- Name: invoice trg_invoice_touch; Type: TRIGGER; Schema: mcms_billing; Owner: -
--

CREATE TRIGGER trg_invoice_touch BEFORE UPDATE ON mcms_billing.invoice FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: claim_response trg_mcms_billing_claim_response_audit; Type: TRIGGER; Schema: mcms_billing; Owner: -
--

CREATE TRIGGER trg_mcms_billing_claim_response_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_billing.claim_response FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: eligibility_check trg_mcms_billing_eligibility_check_audit; Type: TRIGGER; Schema: mcms_billing; Owner: -
--

CREATE TRIGGER trg_mcms_billing_eligibility_check_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_billing.eligibility_check FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: invoice_line trg_mcms_billing_invoice_line_audit; Type: TRIGGER; Schema: mcms_billing; Owner: -
--

CREATE TRIGGER trg_mcms_billing_invoice_line_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_billing.invoice_line FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: payer trg_mcms_billing_payer_audit; Type: TRIGGER; Schema: mcms_billing; Owner: -
--

CREATE TRIGGER trg_mcms_billing_payer_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_billing.payer FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: service_price trg_mcms_billing_service_price_audit; Type: TRIGGER; Schema: mcms_billing; Owner: -
--

CREATE TRIGGER trg_mcms_billing_service_price_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_billing.service_price FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: payment trg_payment_event; Type: TRIGGER; Schema: mcms_billing; Owner: -
--

CREATE TRIGGER trg_payment_event AFTER INSERT ON mcms_billing.payment FOR EACH ROW EXECUTE FUNCTION mcms_billing.fn_payment_event();


--
-- Name: service_price trg_svc_price_touch; Type: TRIGGER; Schema: mcms_billing; Owner: -
--

CREATE TRIGGER trg_svc_price_touch BEFORE UPDATE ON mcms_billing.service_price FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: appointment trg_appointment_reminder; Type: TRIGGER; Schema: mcms_clinic; Owner: -
--

CREATE TRIGGER trg_appointment_reminder AFTER INSERT ON mcms_clinic.appointment FOR EACH ROW EXECUTE FUNCTION mcms_clinic.fn_appointment_reminder();


--
-- Name: appointment trg_appt_event; Type: TRIGGER; Schema: mcms_clinic; Owner: -
--

CREATE TRIGGER trg_appt_event AFTER INSERT OR UPDATE OF status ON mcms_clinic.appointment FOR EACH ROW EXECUTE FUNCTION mcms_clinic.fn_appt_event();


--
-- Name: appointment trg_appt_touch; Type: TRIGGER; Schema: mcms_clinic; Owner: -
--

CREATE TRIGGER trg_appt_touch BEFORE UPDATE ON mcms_clinic.appointment FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: consultation trg_consult_event; Type: TRIGGER; Schema: mcms_clinic; Owner: -
--

CREATE TRIGGER trg_consult_event AFTER UPDATE ON mcms_clinic.consultation FOR EACH ROW EXECUTE FUNCTION mcms_clinic.fn_consult_event();


--
-- Name: consultation trg_consult_touch; Type: TRIGGER; Schema: mcms_clinic; Owner: -
--

CREATE TRIGGER trg_consult_touch BEFORE UPDATE ON mcms_clinic.consultation FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: patient_queue trg_mcms_clinic_patient_queue_audit; Type: TRIGGER; Schema: mcms_clinic; Owner: -
--

CREATE TRIGGER trg_mcms_clinic_patient_queue_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_clinic.patient_queue FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: room trg_mcms_clinic_room_audit; Type: TRIGGER; Schema: mcms_clinic; Owner: -
--

CREATE TRIGGER trg_mcms_clinic_room_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_clinic.room FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: room trg_room_touch; Type: TRIGGER; Schema: mcms_clinic; Owner: -
--

CREATE TRIGGER trg_room_touch BEFORE UPDATE ON mcms_clinic.room FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: event_log trg_event_log_insert; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_event_log_insert BEFORE INSERT ON mcms_core.event_log FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_event_insert();


--
-- Name: access_log trg_mcms_core_access_log_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_access_log_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.access_log FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: address trg_mcms_core_address_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_address_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.address FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: app_user trg_mcms_core_app_user_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_app_user_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.app_user FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: audit_trail trg_mcms_core_audit_trail_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_audit_trail_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.audit_trail FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: backup_log trg_mcms_core_backup_log_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_backup_log_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.backup_log FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: consent trg_mcms_core_consent_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_consent_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.consent FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: contact trg_mcms_core_contact_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_contact_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.contact FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: facility trg_mcms_core_facility_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_facility_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.facility FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: federated_identity trg_mcms_core_federated_identity_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_federated_identity_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.federated_identity FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: hl7_message trg_mcms_core_hl7_message_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_hl7_message_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.hl7_message FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: identity_provider trg_mcms_core_identity_provider_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_identity_provider_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.identity_provider FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: lookup trg_mcms_core_lookup_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_lookup_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.lookup FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: notification trg_mcms_core_notification_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_notification_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.notification FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: organization trg_mcms_core_organization_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_organization_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.organization FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: party trg_mcms_core_party_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_party_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.party FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: permission trg_mcms_core_permission_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_permission_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.permission FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: role trg_mcms_core_role_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_role_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.role FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: role_permission trg_mcms_core_role_permission_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_role_permission_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.role_permission FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: system_flag trg_mcms_core_system_flag_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_system_flag_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.system_flag FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: user_role_map trg_mcms_core_user_role_map_audit; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_mcms_core_user_role_map_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_core.user_role_map FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: notification trg_notify_after_insert; Type: TRIGGER; Schema: mcms_core; Owner: -
--

CREATE TRIGGER trg_notify_after_insert AFTER INSERT ON mcms_core.notification FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_notify_broadcast();


--
-- Name: session trg_mcms_dialysis_session_audit; Type: TRIGGER; Schema: mcms_dialysis; Owner: -
--

CREATE TRIGGER trg_mcms_dialysis_session_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_dialysis.session FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: station trg_mcms_dialysis_station_audit; Type: TRIGGER; Schema: mcms_dialysis; Owner: -
--

CREATE TRIGGER trg_mcms_dialysis_station_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_dialysis.station FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: ed_bed trg_mcms_emergency_ed_bed_audit; Type: TRIGGER; Schema: mcms_emergency; Owner: -
--

CREATE TRIGGER trg_mcms_emergency_ed_bed_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_emergency.ed_bed FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: resuscitation trg_resus_event; Type: TRIGGER; Schema: mcms_emergency; Owner: -
--

CREATE TRIGGER trg_resus_event AFTER INSERT ON mcms_emergency.resuscitation FOR EACH ROW EXECUTE FUNCTION mcms_emergency.fn_resus_event();


--
-- Name: triage trg_triage_event; Type: TRIGGER; Schema: mcms_emergency; Owner: -
--

CREATE TRIGGER trg_triage_event AFTER INSERT OR UPDATE OF status ON mcms_emergency.triage FOR EACH ROW EXECUTE FUNCTION mcms_emergency.fn_triage_event();


--
-- Name: triage trg_triage_touch; Type: TRIGGER; Schema: mcms_emergency; Owner: -
--

CREATE TRIGGER trg_triage_touch BEFORE UPDATE ON mcms_emergency.triage FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: diagnosis trg_diag_event; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_diag_event AFTER INSERT ON mcms_emr.diagnosis FOR EACH ROW EXECUTE FUNCTION mcms_emr.fn_diag_event();


--
-- Name: encounter trg_encounter_event; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_encounter_event AFTER INSERT OR UPDATE ON mcms_emr.encounter FOR EACH ROW EXECUTE FUNCTION mcms_emr.fn_encounter_event();


--
-- Name: encounter trg_encounter_touch; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_encounter_touch BEFORE UPDATE ON mcms_emr.encounter FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: allergy trg_mcms_emr_allergy_audit; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_mcms_emr_allergy_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_emr.allergy FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: clinical_note trg_mcms_emr_clinical_note_audit; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_mcms_emr_clinical_note_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_emr.clinical_note FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: family_history trg_mcms_emr_family_history_audit; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_mcms_emr_family_history_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_emr.family_history FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: immunization trg_mcms_emr_immunization_audit; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_mcms_emr_immunization_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_emr.immunization FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: patient trg_mcms_emr_patient_audit; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_mcms_emr_patient_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_emr.patient FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: referral trg_mcms_emr_referral_audit; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_mcms_emr_referral_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_emr.referral FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: referral_linkage_rule trg_mcms_emr_referral_linkage_rule_audit; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_mcms_emr_referral_linkage_rule_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_emr.referral_linkage_rule FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: social_history trg_mcms_emr_social_history_audit; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_mcms_emr_social_history_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_emr.social_history FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: vitals trg_mcms_emr_vitals_audit; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_mcms_emr_vitals_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_emr.vitals FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: medication_order trg_med_order_event; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_med_order_event AFTER INSERT ON mcms_emr.medication_order FOR EACH ROW EXECUTE FUNCTION mcms_emr.fn_med_order_event();


--
-- Name: medication_order trg_med_order_touch; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_med_order_touch BEFORE UPDATE ON mcms_emr.medication_order FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: clinical_note trg_note_touch; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_note_touch BEFORE UPDATE ON mcms_emr.clinical_note FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: patient trg_patient_deceased_guard; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_patient_deceased_guard BEFORE UPDATE ON mcms_emr.patient FOR EACH ROW WHEN ((old.is_deceased IS DISTINCT FROM new.is_deceased)) EXECUTE FUNCTION mcms_vital_records.fn_patient_deceased_guard();


--
-- Name: patient trg_patient_touch; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_patient_touch BEFORE UPDATE ON mcms_emr.patient FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: referral trg_referral_audit; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_referral_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_emr.referral FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: referral trg_referral_touch; Type: TRIGGER; Schema: mcms_emr; Owner: -
--

CREATE TRIGGER trg_referral_touch BEFORE INSERT OR UPDATE ON mcms_emr.referral FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: inventory_item tgt_inv_item_touch; Type: TRIGGER; Schema: mcms_erp; Owner: -
--

CREATE TRIGGER tgt_inv_item_touch BEFORE UPDATE ON mcms_erp.inventory_item FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: goods_receipt_line trg_grn_line; Type: TRIGGER; Schema: mcms_erp; Owner: -
--

CREATE TRIGGER trg_grn_line AFTER INSERT ON mcms_erp.goods_receipt_line FOR EACH ROW EXECUTE FUNCTION mcms_erp.fn_grn_line_insert();


--
-- Name: gl_account trg_mcms_erp_gl_account_audit; Type: TRIGGER; Schema: mcms_erp; Owner: -
--

CREATE TRIGGER trg_mcms_erp_gl_account_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_erp.gl_account FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: goods_receipt trg_mcms_erp_goods_receipt_audit; Type: TRIGGER; Schema: mcms_erp; Owner: -
--

CREATE TRIGGER trg_mcms_erp_goods_receipt_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_erp.goods_receipt FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: goods_receipt_line trg_mcms_erp_goods_receipt_line_audit; Type: TRIGGER; Schema: mcms_erp; Owner: -
--

CREATE TRIGGER trg_mcms_erp_goods_receipt_line_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_erp.goods_receipt_line FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: inventory_item trg_mcms_erp_inventory_item_audit; Type: TRIGGER; Schema: mcms_erp; Owner: -
--

CREATE TRIGGER trg_mcms_erp_inventory_item_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_erp.inventory_item FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: inventory_stock trg_mcms_erp_inventory_stock_audit; Type: TRIGGER; Schema: mcms_erp; Owner: -
--

CREATE TRIGGER trg_mcms_erp_inventory_stock_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_erp.inventory_stock FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: purchase_order trg_mcms_erp_purchase_order_audit; Type: TRIGGER; Schema: mcms_erp; Owner: -
--

CREATE TRIGGER trg_mcms_erp_purchase_order_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_erp.purchase_order FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: purchase_order_line trg_mcms_erp_purchase_order_line_audit; Type: TRIGGER; Schema: mcms_erp; Owner: -
--

CREATE TRIGGER trg_mcms_erp_purchase_order_line_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_erp.purchase_order_line FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: stock_movement trg_mcms_erp_stock_movement_audit; Type: TRIGGER; Schema: mcms_erp; Owner: -
--

CREATE TRIGGER trg_mcms_erp_stock_movement_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_erp.stock_movement FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: supplier trg_mcms_erp_supplier_audit; Type: TRIGGER; Schema: mcms_erp; Owner: -
--

CREATE TRIGGER trg_mcms_erp_supplier_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_erp.supplier FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: purchase_order trg_po_touch; Type: TRIGGER; Schema: mcms_erp; Owner: -
--

CREATE TRIGGER trg_po_touch BEFORE UPDATE ON mcms_erp.purchase_order FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: department trg_dept_touch; Type: TRIGGER; Schema: mcms_hr; Owner: -
--

CREATE TRIGGER trg_dept_touch BEFORE UPDATE ON mcms_hr.department FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: employee trg_emp_touch; Type: TRIGGER; Schema: mcms_hr; Owner: -
--

CREATE TRIGGER trg_emp_touch BEFORE UPDATE ON mcms_hr.employee FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: employee trg_employee_hire; Type: TRIGGER; Schema: mcms_hr; Owner: -
--

CREATE TRIGGER trg_employee_hire AFTER INSERT ON mcms_hr.employee FOR EACH ROW EXECUTE FUNCTION mcms_hr.fn_employee_hire_event();


--
-- Name: leave_request trg_leave_touch; Type: TRIGGER; Schema: mcms_hr; Owner: -
--

CREATE TRIGGER trg_leave_touch BEFORE UPDATE ON mcms_hr.leave_request FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: attendance trg_mcms_hr_attendance_audit; Type: TRIGGER; Schema: mcms_hr; Owner: -
--

CREATE TRIGGER trg_mcms_hr_attendance_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_hr.attendance FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: department trg_mcms_hr_department_audit; Type: TRIGGER; Schema: mcms_hr; Owner: -
--

CREATE TRIGGER trg_mcms_hr_department_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_hr.department FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: employee_department trg_mcms_hr_employee_department_audit; Type: TRIGGER; Schema: mcms_hr; Owner: -
--

CREATE TRIGGER trg_mcms_hr_employee_department_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_hr.employee_department FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: leave_request trg_mcms_hr_leave_request_audit; Type: TRIGGER; Schema: mcms_hr; Owner: -
--

CREATE TRIGGER trg_mcms_hr_leave_request_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_hr.leave_request FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: payroll_item trg_mcms_hr_payroll_item_audit; Type: TRIGGER; Schema: mcms_hr; Owner: -
--

CREATE TRIGGER trg_mcms_hr_payroll_item_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_hr.payroll_item FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: payroll_period trg_mcms_hr_payroll_period_audit; Type: TRIGGER; Schema: mcms_hr; Owner: -
--

CREATE TRIGGER trg_mcms_hr_payroll_period_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_hr.payroll_period FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: shift trg_mcms_hr_shift_audit; Type: TRIGGER; Schema: mcms_hr; Owner: -
--

CREATE TRIGGER trg_mcms_hr_shift_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_hr.shift FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: bed trg_bed_touch; Type: TRIGGER; Schema: mcms_icu; Owner: -
--

CREATE TRIGGER trg_bed_touch BEFORE UPDATE ON mcms_icu.bed FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: admission trg_icu_admission_event; Type: TRIGGER; Schema: mcms_icu; Owner: -
--

CREATE TRIGGER trg_icu_admission_event AFTER INSERT OR UPDATE OF status ON mcms_icu.admission FOR EACH ROW EXECUTE FUNCTION mcms_icu.fn_admission_event();


--
-- Name: vitals_stream trg_icu_vitals_alert; Type: TRIGGER; Schema: mcms_icu; Owner: -
--

CREATE TRIGGER trg_icu_vitals_alert AFTER INSERT ON mcms_icu.vitals_stream FOR EACH ROW EXECUTE FUNCTION mcms_icu.fn_vitals_alert_event();


--
-- Name: bed trg_mcms_icu_bed_audit; Type: TRIGGER; Schema: mcms_icu; Owner: -
--

CREATE TRIGGER trg_mcms_icu_bed_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_icu.bed FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: bed_stay trg_mcms_icu_bed_stay_audit; Type: TRIGGER; Schema: mcms_icu; Owner: -
--

CREATE TRIGGER trg_mcms_icu_bed_stay_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_icu.bed_stay FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: score trg_mcms_icu_score_audit; Type: TRIGGER; Schema: mcms_icu; Owner: -
--

CREATE TRIGGER trg_mcms_icu_score_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_icu.score FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: support_session trg_vent_event; Type: TRIGGER; Schema: mcms_icu; Owner: -
--

CREATE TRIGGER trg_vent_event AFTER INSERT OR UPDATE ON mcms_icu.support_session FOR EACH ROW EXECUTE FUNCTION mcms_icu.fn_vent_event();


--
-- Name: lab_order trg_lab_order_event; Type: TRIGGER; Schema: mcms_lab; Owner: -
--

CREATE TRIGGER trg_lab_order_event AFTER INSERT ON mcms_lab.lab_order FOR EACH ROW EXECUTE FUNCTION mcms_lab.fn_lab_order_event();


--
-- Name: test_catalog trg_mcms_lab_test_catalog_audit; Type: TRIGGER; Schema: mcms_lab; Owner: -
--

CREATE TRIGGER trg_mcms_lab_test_catalog_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_lab.test_catalog FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: test_panel trg_mcms_lab_test_panel_audit; Type: TRIGGER; Schema: mcms_lab; Owner: -
--

CREATE TRIGGER trg_mcms_lab_test_panel_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_lab.test_panel FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: test_panel_item trg_mcms_lab_test_panel_item_audit; Type: TRIGGER; Schema: mcms_lab; Owner: -
--

CREATE TRIGGER trg_mcms_lab_test_panel_item_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_lab.test_panel_item FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: result trg_result_critical; Type: TRIGGER; Schema: mcms_lab; Owner: -
--

CREATE TRIGGER trg_result_critical AFTER INSERT OR UPDATE OF flag ON mcms_lab.result FOR EACH ROW EXECUTE FUNCTION mcms_lab.fn_result_critical();


--
-- Name: result trg_result_event; Type: TRIGGER; Schema: mcms_lab; Owner: -
--

CREATE TRIGGER trg_result_event AFTER INSERT OR UPDATE OF verified_at ON mcms_lab.result FOR EACH ROW EXECUTE FUNCTION mcms_lab.fn_result_event();


--
-- Name: sample trg_sample_event; Type: TRIGGER; Schema: mcms_lab; Owner: -
--

CREATE TRIGGER trg_sample_event AFTER INSERT OR UPDATE OF status ON mcms_lab.sample FOR EACH ROW EXECUTE FUNCTION mcms_lab.fn_sample_event();


--
-- Name: cot trg_mcms_nursery_cot_audit; Type: TRIGGER; Schema: mcms_nursery; Owner: -
--

CREATE TRIGGER trg_mcms_nursery_cot_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_nursery.cot FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: growth_entry trg_mcms_nursery_growth_entry_audit; Type: TRIGGER; Schema: mcms_nursery; Owner: -
--

CREATE TRIGGER trg_mcms_nursery_growth_entry_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_nursery.growth_entry FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: neonate_record trg_mcms_nursery_neonate_record_audit; Type: TRIGGER; Schema: mcms_nursery; Owner: -
--

CREATE TRIGGER trg_mcms_nursery_neonate_record_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_nursery.neonate_record FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: session tgt_session_touch; Type: TRIGGER; Schema: mcms_physio; Owner: -
--

CREATE TRIGGER tgt_session_touch BEFORE UPDATE ON mcms_physio.session FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: therapy_catalog trg_mcms_physio_therapy_catalog_audit; Type: TRIGGER; Schema: mcms_physio; Owner: -
--

CREATE TRIGGER trg_mcms_physio_therapy_catalog_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_physio.therapy_catalog FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: treatment_plan trg_mcms_physio_treatment_plan_audit; Type: TRIGGER; Schema: mcms_physio; Owner: -
--

CREATE TRIGGER trg_mcms_physio_treatment_plan_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_physio.treatment_plan FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: session trg_physio_event; Type: TRIGGER; Schema: mcms_physio; Owner: -
--

CREATE TRIGGER trg_physio_event AFTER UPDATE OF status ON mcms_physio.session FOR EACH ROW EXECUTE FUNCTION mcms_physio.fn_session_event();


--
-- Name: treatment_plan trg_plan_touch; Type: TRIGGER; Schema: mcms_physio; Owner: -
--

CREATE TRIGGER trg_plan_touch BEFORE UPDATE ON mcms_physio.treatment_plan FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: exam_catalog trg_mcms_rad_exam_catalog_audit; Type: TRIGGER; Schema: mcms_rad; Owner: -
--

CREATE TRIGGER trg_mcms_rad_exam_catalog_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_rad.exam_catalog FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: image_instance trg_mcms_rad_image_instance_audit; Type: TRIGGER; Schema: mcms_rad; Owner: -
--

CREATE TRIGGER trg_mcms_rad_image_instance_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_rad.image_instance FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: modality_suite trg_mcms_rad_modality_suite_audit; Type: TRIGGER; Schema: mcms_rad; Owner: -
--

CREATE TRIGGER trg_mcms_rad_modality_suite_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_rad.modality_suite FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: study_request trg_rad_event; Type: TRIGGER; Schema: mcms_rad; Owner: -
--

CREATE TRIGGER trg_rad_event AFTER INSERT OR UPDATE OF status ON mcms_rad.study_request FOR EACH ROW EXECUTE FUNCTION mcms_rad.fn_study_event();


--
-- Name: study_request trg_rad_study_touch; Type: TRIGGER; Schema: mcms_rad; Owner: -
--

CREATE TRIGGER trg_rad_study_touch BEFORE UPDATE ON mcms_rad.study_request FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: modality_suite trg_rad_suite_touch; Type: TRIGGER; Schema: mcms_rad; Owner: -
--

CREATE TRIGGER trg_rad_suite_touch BEFORE UPDATE ON mcms_rad.modality_suite FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: administration trg_admin_event; Type: TRIGGER; Schema: mcms_rx; Owner: -
--

CREATE TRIGGER trg_admin_event AFTER INSERT ON mcms_rx.administration FOR EACH ROW EXECUTE FUNCTION mcms_rx.fn_administer_event();


--
-- Name: dispensation trg_dispense_event; Type: TRIGGER; Schema: mcms_rx; Owner: -
--

CREATE TRIGGER trg_dispense_event AFTER INSERT ON mcms_rx.dispensation FOR EACH ROW EXECUTE FUNCTION mcms_rx.fn_dispense_event_and_stock();


--
-- Name: drug_item trg_drug_touch; Type: TRIGGER; Schema: mcms_rx; Owner: -
--

CREATE TRIGGER trg_drug_touch BEFORE UPDATE ON mcms_rx.drug_item FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: drug_alternative trg_mcms_rx_drug_alternative_audit; Type: TRIGGER; Schema: mcms_rx; Owner: -
--

CREATE TRIGGER trg_mcms_rx_drug_alternative_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_rx.drug_alternative FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: drug_interaction trg_mcms_rx_drug_interaction_audit; Type: TRIGGER; Schema: mcms_rx; Owner: -
--

CREATE TRIGGER trg_mcms_rx_drug_interaction_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_rx.drug_interaction FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: drug_item trg_mcms_rx_drug_item_audit; Type: TRIGGER; Schema: mcms_rx; Owner: -
--

CREATE TRIGGER trg_mcms_rx_drug_item_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_rx.drug_item FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: drug_lot trg_mcms_rx_drug_lot_audit; Type: TRIGGER; Schema: mcms_rx; Owner: -
--

CREATE TRIGGER trg_mcms_rx_drug_lot_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_rx.drug_lot FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: prescription trg_mcms_rx_prescription_audit; Type: TRIGGER; Schema: mcms_rx; Owner: -
--

CREATE TRIGGER trg_mcms_rx_prescription_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_rx.prescription FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: stock_movement trg_mcms_rx_stock_movement_audit; Type: TRIGGER; Schema: mcms_rx; Owner: -
--

CREATE TRIGGER trg_mcms_rx_stock_movement_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_rx.stock_movement FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: intra_op_vitals trg_mcms_surgical_intra_op_vitals_audit; Type: TRIGGER; Schema: mcms_surgical; Owner: -
--

CREATE TRIGGER trg_mcms_surgical_intra_op_vitals_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_surgical.intra_op_vitals FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: operating_room trg_mcms_surgical_operating_room_audit; Type: TRIGGER; Schema: mcms_surgical; Owner: -
--

CREATE TRIGGER trg_mcms_surgical_operating_room_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_surgical.operating_room FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: post_op_note trg_mcms_surgical_post_op_note_audit; Type: TRIGGER; Schema: mcms_surgical; Owner: -
--

CREATE TRIGGER trg_mcms_surgical_post_op_note_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_surgical.post_op_note FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: pre_op_checklist trg_mcms_surgical_pre_op_checklist_audit; Type: TRIGGER; Schema: mcms_surgical; Owner: -
--

CREATE TRIGGER trg_mcms_surgical_pre_op_checklist_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_surgical.pre_op_checklist FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: procedure_catalog trg_mcms_surgical_procedure_catalog_audit; Type: TRIGGER; Schema: mcms_surgical; Owner: -
--

CREATE TRIGGER trg_mcms_surgical_procedure_catalog_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_surgical.procedure_catalog FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: surgical_team trg_mcms_surgical_surgical_team_audit; Type: TRIGGER; Schema: mcms_surgical; Owner: -
--

CREATE TRIGGER trg_mcms_surgical_surgical_team_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_surgical.surgical_team FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: surgery trg_or_busy; Type: TRIGGER; Schema: mcms_surgical; Owner: -
--

CREATE TRIGGER trg_or_busy AFTER INSERT OR DELETE OR UPDATE ON mcms_surgical.surgery FOR EACH ROW EXECUTE FUNCTION mcms_surgical.fn_or_busy_on_surgery();


--
-- Name: operating_room trg_or_touch; Type: TRIGGER; Schema: mcms_surgical; Owner: -
--

CREATE TRIGGER trg_or_touch BEFORE UPDATE ON mcms_surgical.operating_room FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: surgery trg_surg_event; Type: TRIGGER; Schema: mcms_surgical; Owner: -
--

CREATE TRIGGER trg_surg_event AFTER INSERT OR UPDATE OF status ON mcms_surgical.surgery FOR EACH ROW EXECUTE FUNCTION mcms_surgical.fn_surg_event();


--
-- Name: surgery trg_surg_touch; Type: TRIGGER; Schema: mcms_surgical; Owner: -
--

CREATE TRIGGER trg_surg_touch BEFORE UPDATE ON mcms_surgical.surgery FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();


--
-- Name: visit trg_mcms_telemed_visit_audit; Type: TRIGGER; Schema: mcms_telemed; Owner: -
--

CREATE TRIGGER trg_mcms_telemed_visit_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_telemed.visit FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: concept trg_mcms_terminology_concept_audit; Type: TRIGGER; Schema: mcms_terminology; Owner: -
--

CREATE TRIGGER trg_mcms_terminology_concept_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_terminology.concept FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: birth_certificate trg_mcms_vital_records_birth_certificate_audit; Type: TRIGGER; Schema: mcms_vital_records; Owner: -
--

CREATE TRIGGER trg_mcms_vital_records_birth_certificate_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_vital_records.birth_certificate FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: death_certificate trg_mcms_vital_records_death_certificate_audit; Type: TRIGGER; Schema: mcms_vital_records; Owner: -
--

CREATE TRIGGER trg_mcms_vital_records_death_certificate_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_vital_records.death_certificate FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: waste_collection trg_mcms_waste_waste_collection_audit; Type: TRIGGER; Schema: mcms_waste; Owner: -
--

CREATE TRIGGER trg_mcms_waste_waste_collection_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_waste.waste_collection FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: waste_container trg_mcms_waste_waste_container_audit; Type: TRIGGER; Schema: mcms_waste; Owner: -
--

CREATE TRIGGER trg_mcms_waste_waste_container_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_waste.waste_container FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: waste_cost_allocation trg_mcms_waste_waste_cost_allocation_audit; Type: TRIGGER; Schema: mcms_waste; Owner: -
--

CREATE TRIGGER trg_mcms_waste_waste_cost_allocation_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_waste.waste_cost_allocation FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: waste_disposal_manifest trg_mcms_waste_waste_disposal_manifest_audit; Type: TRIGGER; Schema: mcms_waste; Owner: -
--

CREATE TRIGGER trg_mcms_waste_waste_disposal_manifest_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_waste.waste_disposal_manifest FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: waste_stream trg_mcms_waste_waste_stream_audit; Type: TRIGGER; Schema: mcms_waste; Owner: -
--

CREATE TRIGGER trg_mcms_waste_waste_stream_audit AFTER INSERT OR DELETE OR UPDATE ON mcms_waste.waste_stream FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_generic_audit();


--
-- Name: claim_response claim_response_claim_id_fkey; Type: FK CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.claim_response
    ADD CONSTRAINT claim_response_claim_id_fkey FOREIGN KEY (claim_id) REFERENCES mcms_billing.insurance_claim(claim_id) ON DELETE CASCADE;


--
-- Name: insurance_claim insurance_claim_invoice_id_fkey; Type: FK CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.insurance_claim
    ADD CONSTRAINT insurance_claim_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES mcms_billing.invoice(invoice_id) ON DELETE CASCADE;


--
-- Name: insurance_claim insurance_claim_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.insurance_claim
    ADD CONSTRAINT insurance_claim_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: invoice invoice_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.invoice
    ADD CONSTRAINT invoice_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: invoice invoice_issued_by_fkey; Type: FK CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.invoice
    ADD CONSTRAINT invoice_issued_by_fkey FOREIGN KEY (issued_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: invoice_line invoice_line_invoice_id_fkey; Type: FK CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.invoice_line
    ADD CONSTRAINT invoice_line_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES mcms_billing.invoice(invoice_id) ON DELETE CASCADE;


--
-- Name: invoice_line invoice_line_service_id_fkey; Type: FK CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.invoice_line
    ADD CONSTRAINT invoice_line_service_id_fkey FOREIGN KEY (service_id) REFERENCES mcms_billing.service_price(service_id);


--
-- Name: invoice invoice_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.invoice
    ADD CONSTRAINT invoice_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: payment payment_invoice_id_fkey; Type: FK CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.payment
    ADD CONSTRAINT payment_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES mcms_billing.invoice(invoice_id) ON DELETE CASCADE;


--
-- Name: payment payment_received_by_fkey; Type: FK CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.payment
    ADD CONSTRAINT payment_received_by_fkey FOREIGN KEY (received_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: service_price service_price_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_billing; Owner: -
--

ALTER TABLE ONLY mcms_billing.service_price
    ADD CONSTRAINT service_price_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: appointment appointment_booked_by_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.appointment
    ADD CONSTRAINT appointment_booked_by_fkey FOREIGN KEY (booked_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: appointment appointment_clinician_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.appointment
    ADD CONSTRAINT appointment_clinician_user_id_fkey FOREIGN KEY (clinician_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: appointment appointment_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.appointment
    ADD CONSTRAINT appointment_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: appointment appointment_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.appointment
    ADD CONSTRAINT appointment_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: appointment appointment_mrn_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.appointment
    ADD CONSTRAINT appointment_mrn_fkey FOREIGN KEY (mrn) REFERENCES mcms_emr.patient(mrn) ON DELETE CASCADE;


--
-- Name: appointment appointment_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.appointment
    ADD CONSTRAINT appointment_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: appointment appointment_room_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.appointment
    ADD CONSTRAINT appointment_room_id_fkey FOREIGN KEY (room_id) REFERENCES mcms_clinic.room(room_id);


--
-- Name: consultation consultation_appointment_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.consultation
    ADD CONSTRAINT consultation_appointment_id_fkey FOREIGN KEY (appointment_id) REFERENCES mcms_clinic.appointment(appointment_id) ON DELETE SET NULL;


--
-- Name: consultation consultation_clinician_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.consultation
    ADD CONSTRAINT consultation_clinician_user_id_fkey FOREIGN KEY (clinician_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: consultation consultation_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.consultation
    ADD CONSTRAINT consultation_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: consultation consultation_queue_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.consultation
    ADD CONSTRAINT consultation_queue_id_fkey FOREIGN KEY (queue_id) REFERENCES mcms_clinic.patient_queue(queue_id) ON DELETE SET NULL;


--
-- Name: consultation consultation_room_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.consultation
    ADD CONSTRAINT consultation_room_id_fkey FOREIGN KEY (room_id) REFERENCES mcms_clinic.room(room_id);


--
-- Name: patient_queue patient_queue_assigned_clinician_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.patient_queue
    ADD CONSTRAINT patient_queue_assigned_clinician_fkey FOREIGN KEY (assigned_clinician) REFERENCES mcms_core.app_user(user_id);


--
-- Name: patient_queue patient_queue_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.patient_queue
    ADD CONSTRAINT patient_queue_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: patient_queue patient_queue_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.patient_queue
    ADD CONSTRAINT patient_queue_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: patient_queue patient_queue_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.patient_queue
    ADD CONSTRAINT patient_queue_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: patient_queue patient_queue_room_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.patient_queue
    ADD CONSTRAINT patient_queue_room_id_fkey FOREIGN KEY (room_id) REFERENCES mcms_clinic.room(room_id);


--
-- Name: patient_queue pq_mrn_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.patient_queue
    ADD CONSTRAINT pq_mrn_fkey FOREIGN KEY (mrn) REFERENCES mcms_emr.patient(mrn) ON DELETE CASCADE;


--
-- Name: room room_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_clinic; Owner: -
--

ALTER TABLE ONLY mcms_clinic.room
    ADD CONSTRAINT room_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: access_log access_log_reader_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.access_log
    ADD CONSTRAINT access_log_reader_user_id_fkey FOREIGN KEY (reader_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: access_log access_log_subject_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.access_log
    ADD CONSTRAINT access_log_subject_party_id_fkey FOREIGN KEY (subject_party_id) REFERENCES mcms_core.party(party_id);


--
-- Name: address address_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.address
    ADD CONSTRAINT address_party_id_fkey FOREIGN KEY (party_id) REFERENCES mcms_core.party(party_id) ON DELETE CASCADE;


--
-- Name: app_user app_user_facility_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.app_user
    ADD CONSTRAINT app_user_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES mcms_core.facility(facility_id);


--
-- Name: app_user app_user_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.app_user
    ADD CONSTRAINT app_user_party_id_fkey FOREIGN KEY (party_id) REFERENCES mcms_core.party(party_id) ON DELETE CASCADE;


--
-- Name: audit_trail audit_trail_changed_by_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.audit_trail
    ADD CONSTRAINT audit_trail_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: audit_trail audit_trail_event_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.audit_trail
    ADD CONSTRAINT audit_trail_event_id_fkey FOREIGN KEY (event_id) REFERENCES mcms_core.event_log(event_id);


--
-- Name: consent consent_granted_by_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.consent
    ADD CONSTRAINT consent_granted_by_fkey FOREIGN KEY (granted_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: consent consent_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.consent
    ADD CONSTRAINT consent_party_id_fkey FOREIGN KEY (party_id) REFERENCES mcms_core.party(party_id) ON DELETE CASCADE;


--
-- Name: contact contact_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.contact
    ADD CONSTRAINT contact_party_id_fkey FOREIGN KEY (party_id) REFERENCES mcms_core.party(party_id) ON DELETE CASCADE;


--
-- Name: event_log event_log_actor_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.event_log
    ADD CONSTRAINT event_log_actor_user_id_fkey FOREIGN KEY (actor_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: event_log event_log_subject_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.event_log
    ADD CONSTRAINT event_log_subject_party_id_fkey FOREIGN KEY (subject_party_id) REFERENCES mcms_core.party(party_id);


--
-- Name: facility facility_organization_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.facility
    ADD CONSTRAINT facility_organization_id_fkey FOREIGN KEY (organization_id) REFERENCES mcms_core.organization(organization_id);


--
-- Name: facility facility_parent_facility_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.facility
    ADD CONSTRAINT facility_parent_facility_id_fkey FOREIGN KEY (parent_facility_id) REFERENCES mcms_core.facility(facility_id);


--
-- Name: federated_identity federated_identity_provider_code_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.federated_identity
    ADD CONSTRAINT federated_identity_provider_code_fkey FOREIGN KEY (provider_code) REFERENCES mcms_core.identity_provider(provider_code);


--
-- Name: federated_identity federated_identity_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.federated_identity
    ADD CONSTRAINT federated_identity_user_id_fkey FOREIGN KEY (user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: hl7_message hl7_message_facility_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.hl7_message
    ADD CONSTRAINT hl7_message_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES mcms_core.facility(facility_id);


--
-- Name: hl7_message hl7_message_received_by_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.hl7_message
    ADD CONSTRAINT hl7_message_received_by_fkey FOREIGN KEY (received_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: notification notification_recipient_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.notification
    ADD CONSTRAINT notification_recipient_party_id_fkey FOREIGN KEY (recipient_party_id) REFERENCES mcms_core.party(party_id);


--
-- Name: notification notification_recipient_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.notification
    ADD CONSTRAINT notification_recipient_user_id_fkey FOREIGN KEY (recipient_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: organization organization_parent_org_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.organization
    ADD CONSTRAINT organization_parent_org_id_fkey FOREIGN KEY (parent_org_id) REFERENCES mcms_core.organization(organization_id);


--
-- Name: role_permission role_permission_permission_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.role_permission
    ADD CONSTRAINT role_permission_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES mcms_core.permission(permission_id) ON DELETE CASCADE;


--
-- Name: role_permission role_permission_role_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.role_permission
    ADD CONSTRAINT role_permission_role_id_fkey FOREIGN KEY (role_id) REFERENCES mcms_core.role(role_id) ON DELETE CASCADE;


--
-- Name: user_role_map user_role_map_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.user_role_map
    ADD CONSTRAINT user_role_map_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: user_role_map user_role_map_role_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.user_role_map
    ADD CONSTRAINT user_role_map_role_id_fkey FOREIGN KEY (role_id) REFERENCES mcms_core.role(role_id) ON DELETE CASCADE;


--
-- Name: user_role_map user_role_map_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_core; Owner: -
--

ALTER TABLE ONLY mcms_core.user_role_map
    ADD CONSTRAINT user_role_map_user_id_fkey FOREIGN KEY (user_id) REFERENCES mcms_core.app_user(user_id) ON DELETE CASCADE;


--
-- Name: session session_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE ONLY mcms_dialysis.session
    ADD CONSTRAINT session_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: session session_nephrologist_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE ONLY mcms_dialysis.session
    ADD CONSTRAINT session_nephrologist_user_id_fkey FOREIGN KEY (nephrologist_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: session session_nurse_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE ONLY mcms_dialysis.session
    ADD CONSTRAINT session_nurse_user_id_fkey FOREIGN KEY (nurse_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: session session_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE ONLY mcms_dialysis.session
    ADD CONSTRAINT session_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id);


--
-- Name: session session_station_id_fkey; Type: FK CONSTRAINT; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE ONLY mcms_dialysis.session
    ADD CONSTRAINT session_station_id_fkey FOREIGN KEY (station_id) REFERENCES mcms_dialysis.station(station_id);


--
-- Name: station station_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_dialysis; Owner: -
--

ALTER TABLE ONLY mcms_dialysis.station
    ADD CONSTRAINT station_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: ed_bed ed_bed_triage_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.ed_bed
    ADD CONSTRAINT ed_bed_triage_id_fkey FOREIGN KEY (triage_id) REFERENCES mcms_emergency.triage(triage_id) ON DELETE CASCADE;


--
-- Name: resuscitation resuscitation_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.resuscitation
    ADD CONSTRAINT resuscitation_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: resuscitation resuscitation_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.resuscitation
    ADD CONSTRAINT resuscitation_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: resuscitation resuscitation_team_leader_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.resuscitation
    ADD CONSTRAINT resuscitation_team_leader_id_fkey FOREIGN KEY (team_leader_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: resuscitation resuscitation_triage_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.resuscitation
    ADD CONSTRAINT resuscitation_triage_id_fkey FOREIGN KEY (triage_id) REFERENCES mcms_emergency.triage(triage_id) ON DELETE CASCADE;


--
-- Name: triage triage_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.triage
    ADD CONSTRAINT triage_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: triage triage_mrn_fkey; Type: FK CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.triage
    ADD CONSTRAINT triage_mrn_fkey FOREIGN KEY (mrn) REFERENCES mcms_emr.patient(mrn) ON DELETE CASCADE;


--
-- Name: triage triage_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.triage
    ADD CONSTRAINT triage_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: triage triage_triage_nurse_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emergency; Owner: -
--

ALTER TABLE ONLY mcms_emergency.triage
    ADD CONSTRAINT triage_triage_nurse_user_id_fkey FOREIGN KEY (triage_nurse_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: allergy allergy_noted_by_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.allergy
    ADD CONSTRAINT allergy_noted_by_fkey FOREIGN KEY (noted_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: allergy allergy_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.allergy
    ADD CONSTRAINT allergy_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: clinical_note clinical_note_author_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.clinical_note
    ADD CONSTRAINT clinical_note_author_user_id_fkey FOREIGN KEY (author_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: clinical_note clinical_note_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.clinical_note
    ADD CONSTRAINT clinical_note_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id) ON DELETE CASCADE;


--
-- Name: clinical_note clinical_note_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.clinical_note
    ADD CONSTRAINT clinical_note_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: clinical_note clinical_note_signed_by_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.clinical_note
    ADD CONSTRAINT clinical_note_signed_by_fkey FOREIGN KEY (signed_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: diagnosis diagnosis_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.diagnosis
    ADD CONSTRAINT diagnosis_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id) ON DELETE CASCADE;


--
-- Name: diagnosis diagnosis_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.diagnosis
    ADD CONSTRAINT diagnosis_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: diagnosis diagnosis_recorded_by_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.diagnosis
    ADD CONSTRAINT diagnosis_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: diagnosis diagnosis_signed_by_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.diagnosis
    ADD CONSTRAINT diagnosis_signed_by_fkey FOREIGN KEY (signed_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: encounter encounter_attending_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.encounter
    ADD CONSTRAINT encounter_attending_user_id_fkey FOREIGN KEY (attending_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: encounter encounter_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.encounter
    ADD CONSTRAINT encounter_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: encounter encounter_mrn_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.encounter
    ADD CONSTRAINT encounter_mrn_fkey FOREIGN KEY (mrn) REFERENCES mcms_emr.patient(mrn) ON DELETE CASCADE;


--
-- Name: encounter encounter_originating_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.encounter
    ADD CONSTRAINT encounter_originating_encounter_id_fkey FOREIGN KEY (originating_encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: encounter encounter_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.encounter
    ADD CONSTRAINT encounter_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: encounter encounter_referring_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.encounter
    ADD CONSTRAINT encounter_referring_user_id_fkey FOREIGN KEY (referring_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: family_history family_history_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.family_history
    ADD CONSTRAINT family_history_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: immunization immunization_given_by_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.immunization
    ADD CONSTRAINT immunization_given_by_fkey FOREIGN KEY (given_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: immunization immunization_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.immunization
    ADD CONSTRAINT immunization_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: medication_order medication_order_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.medication_order
    ADD CONSTRAINT medication_order_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id) ON DELETE CASCADE;


--
-- Name: medication_order medication_order_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.medication_order
    ADD CONSTRAINT medication_order_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: medication_order medication_order_prescriber_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.medication_order
    ADD CONSTRAINT medication_order_prescriber_user_id_fkey FOREIGN KEY (prescriber_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: medication_order medication_order_signed_by_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.medication_order
    ADD CONSTRAINT medication_order_signed_by_fkey FOREIGN KEY (signed_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: patient patient_next_of_kin_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.patient
    ADD CONSTRAINT patient_next_of_kin_party_id_fkey FOREIGN KEY (next_of_kin_party_id) REFERENCES mcms_core.party(party_id);


--
-- Name: patient patient_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.patient
    ADD CONSTRAINT patient_party_id_fkey FOREIGN KEY (party_id) REFERENCES mcms_core.party(party_id) ON DELETE CASCADE;


--
-- Name: referral referral_diagnosis_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral
    ADD CONSTRAINT referral_diagnosis_id_fkey FOREIGN KEY (diagnosis_id) REFERENCES mcms_emr.diagnosis(diagnosis_id);


--
-- Name: referral referral_from_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral
    ADD CONSTRAINT referral_from_encounter_id_fkey FOREIGN KEY (from_encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: referral referral_from_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral
    ADD CONSTRAINT referral_from_user_id_fkey FOREIGN KEY (from_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: referral_linkage_rule referral_linkage_rule_from_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral_linkage_rule
    ADD CONSTRAINT referral_linkage_rule_from_department_id_fkey FOREIGN KEY (from_department_id) REFERENCES mcms_hr.department(department_id) ON DELETE RESTRICT;


--
-- Name: referral_linkage_rule referral_linkage_rule_to_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral_linkage_rule
    ADD CONSTRAINT referral_linkage_rule_to_department_id_fkey FOREIGN KEY (to_department_id) REFERENCES mcms_hr.department(department_id) ON DELETE RESTRICT;


--
-- Name: referral_linkage_rule referral_linkage_rule_to_facility_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral_linkage_rule
    ADD CONSTRAINT referral_linkage_rule_to_facility_id_fkey FOREIGN KEY (to_facility_id) REFERENCES mcms_core.facility(facility_id) ON DELETE RESTRICT;


--
-- Name: referral referral_to_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral
    ADD CONSTRAINT referral_to_department_id_fkey FOREIGN KEY (to_department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: referral referral_to_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral
    ADD CONSTRAINT referral_to_encounter_id_fkey FOREIGN KEY (to_encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: referral referral_to_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.referral
    ADD CONSTRAINT referral_to_user_id_fkey FOREIGN KEY (to_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: social_history social_history_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.social_history
    ADD CONSTRAINT social_history_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: vitals vitals_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.vitals
    ADD CONSTRAINT vitals_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id) ON DELETE CASCADE;


--
-- Name: vitals vitals_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.vitals
    ADD CONSTRAINT vitals_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: vitals vitals_taken_by_fkey; Type: FK CONSTRAINT; Schema: mcms_emr; Owner: -
--

ALTER TABLE ONLY mcms_emr.vitals
    ADD CONSTRAINT vitals_taken_by_fkey FOREIGN KEY (taken_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: gl_account gl_account_parent_account_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.gl_account
    ADD CONSTRAINT gl_account_parent_account_id_fkey FOREIGN KEY (parent_account_id) REFERENCES mcms_erp.gl_account(account_id);


--
-- Name: goods_receipt_line goods_receipt_line_drug_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.goods_receipt_line
    ADD CONSTRAINT goods_receipt_line_drug_item_id_fkey FOREIGN KEY (drug_item_id) REFERENCES mcms_rx.drug_item(drug_item_id);


--
-- Name: goods_receipt_line goods_receipt_line_grn_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.goods_receipt_line
    ADD CONSTRAINT goods_receipt_line_grn_id_fkey FOREIGN KEY (grn_id) REFERENCES mcms_erp.goods_receipt(grn_id) ON DELETE CASCADE;


--
-- Name: goods_receipt_line goods_receipt_line_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.goods_receipt_line
    ADD CONSTRAINT goods_receipt_line_item_id_fkey FOREIGN KEY (item_id) REFERENCES mcms_erp.inventory_item(item_id);


--
-- Name: goods_receipt_line goods_receipt_line_po_line_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.goods_receipt_line
    ADD CONSTRAINT goods_receipt_line_po_line_id_fkey FOREIGN KEY (po_line_id) REFERENCES mcms_erp.purchase_order_line(line_id);


--
-- Name: goods_receipt goods_receipt_po_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.goods_receipt
    ADD CONSTRAINT goods_receipt_po_id_fkey FOREIGN KEY (po_id) REFERENCES mcms_erp.purchase_order(po_id);


--
-- Name: goods_receipt goods_receipt_received_by_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.goods_receipt
    ADD CONSTRAINT goods_receipt_received_by_fkey FOREIGN KEY (received_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: goods_receipt goods_receipt_supplier_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.goods_receipt
    ADD CONSTRAINT goods_receipt_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES mcms_erp.supplier(supplier_id);


--
-- Name: inventory_stock inventory_stock_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.inventory_stock
    ADD CONSTRAINT inventory_stock_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: inventory_stock inventory_stock_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.inventory_stock
    ADD CONSTRAINT inventory_stock_item_id_fkey FOREIGN KEY (item_id) REFERENCES mcms_erp.inventory_item(item_id) ON DELETE CASCADE;


--
-- Name: purchase_order purchase_order_approved_by_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.purchase_order
    ADD CONSTRAINT purchase_order_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: purchase_order_line purchase_order_line_drug_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.purchase_order_line
    ADD CONSTRAINT purchase_order_line_drug_item_id_fkey FOREIGN KEY (drug_item_id) REFERENCES mcms_rx.drug_item(drug_item_id);


--
-- Name: purchase_order_line purchase_order_line_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.purchase_order_line
    ADD CONSTRAINT purchase_order_line_item_id_fkey FOREIGN KEY (item_id) REFERENCES mcms_erp.inventory_item(item_id);


--
-- Name: purchase_order_line purchase_order_line_po_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.purchase_order_line
    ADD CONSTRAINT purchase_order_line_po_id_fkey FOREIGN KEY (po_id) REFERENCES mcms_erp.purchase_order(po_id) ON DELETE CASCADE;


--
-- Name: purchase_order purchase_order_requested_by_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.purchase_order
    ADD CONSTRAINT purchase_order_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: purchase_order purchase_order_supplier_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.purchase_order
    ADD CONSTRAINT purchase_order_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES mcms_erp.supplier(supplier_id);


--
-- Name: stock_movement stock_movement_from_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.stock_movement
    ADD CONSTRAINT stock_movement_from_department_id_fkey FOREIGN KEY (from_department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: stock_movement stock_movement_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.stock_movement
    ADD CONSTRAINT stock_movement_item_id_fkey FOREIGN KEY (item_id) REFERENCES mcms_erp.inventory_item(item_id);


--
-- Name: stock_movement stock_movement_performed_by_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.stock_movement
    ADD CONSTRAINT stock_movement_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: stock_movement stock_movement_to_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.stock_movement
    ADD CONSTRAINT stock_movement_to_department_id_fkey FOREIGN KEY (to_department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: supplier supplier_contact_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.supplier
    ADD CONSTRAINT supplier_contact_user_id_fkey FOREIGN KEY (contact_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: supplier supplier_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_erp; Owner: -
--

ALTER TABLE ONLY mcms_erp.supplier
    ADD CONSTRAINT supplier_party_id_fkey FOREIGN KEY (party_id) REFERENCES mcms_core.party(party_id) ON DELETE CASCADE;


--
-- Name: attendance attendance_employee_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.attendance
    ADD CONSTRAINT attendance_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES mcms_hr.employee(employee_id) ON DELETE CASCADE;


--
-- Name: attendance attendance_shift_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.attendance
    ADD CONSTRAINT attendance_shift_id_fkey FOREIGN KEY (shift_id) REFERENCES mcms_hr.shift(shift_id);


--
-- Name: department department_head_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.department
    ADD CONSTRAINT department_head_user_id_fkey FOREIGN KEY (head_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: department department_parent_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.department
    ADD CONSTRAINT department_parent_department_id_fkey FOREIGN KEY (parent_department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: employee_department employee_department_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.employee_department
    ADD CONSTRAINT employee_department_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id) ON DELETE CASCADE;


--
-- Name: employee_department employee_department_employee_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.employee_department
    ADD CONSTRAINT employee_department_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES mcms_hr.employee(employee_id) ON DELETE CASCADE;


--
-- Name: employee employee_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.employee
    ADD CONSTRAINT employee_party_id_fkey FOREIGN KEY (party_id) REFERENCES mcms_core.party(party_id) ON DELETE CASCADE;


--
-- Name: employee employee_primary_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.employee
    ADD CONSTRAINT employee_primary_department_id_fkey FOREIGN KEY (primary_department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: employee employee_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.employee
    ADD CONSTRAINT employee_user_id_fkey FOREIGN KEY (user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: leave_request leave_request_approved_by_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.leave_request
    ADD CONSTRAINT leave_request_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: leave_request leave_request_employee_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.leave_request
    ADD CONSTRAINT leave_request_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES mcms_hr.employee(employee_id) ON DELETE CASCADE;


--
-- Name: payroll_item payroll_item_employee_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.payroll_item
    ADD CONSTRAINT payroll_item_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES mcms_hr.employee(employee_id) ON DELETE CASCADE;


--
-- Name: payroll_item payroll_item_period_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.payroll_item
    ADD CONSTRAINT payroll_item_period_id_fkey FOREIGN KEY (period_id) REFERENCES mcms_hr.payroll_period(period_id) ON DELETE CASCADE;


--
-- Name: shift shift_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.shift
    ADD CONSTRAINT shift_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id) ON DELETE CASCADE;


--
-- Name: shift shift_employee_id_fkey; Type: FK CONSTRAINT; Schema: mcms_hr; Owner: -
--

ALTER TABLE ONLY mcms_hr.shift
    ADD CONSTRAINT shift_employee_id_fkey FOREIGN KEY (employee_id) REFERENCES mcms_hr.employee(employee_id) ON DELETE CASCADE;


--
-- Name: admission admission_attending_nurse_id_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.admission
    ADD CONSTRAINT admission_attending_nurse_id_fkey FOREIGN KEY (attending_nurse_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: admission admission_bed_id_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.admission
    ADD CONSTRAINT admission_bed_id_fkey FOREIGN KEY (bed_id) REFERENCES mcms_icu.bed(bed_id);


--
-- Name: admission admission_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.admission
    ADD CONSTRAINT admission_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: admission admission_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.admission
    ADD CONSTRAINT admission_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: admission admission_primary_physician_id_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.admission
    ADD CONSTRAINT admission_primary_physician_id_fkey FOREIGN KEY (primary_physician_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: bed bed_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.bed
    ADD CONSTRAINT bed_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: bed_stay bed_stay_admission_id_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.bed_stay
    ADD CONSTRAINT bed_stay_admission_id_fkey FOREIGN KEY (admission_id) REFERENCES mcms_icu.admission(admission_id) ON DELETE CASCADE;


--
-- Name: bed_stay bed_stay_bed_id_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.bed_stay
    ADD CONSTRAINT bed_stay_bed_id_fkey FOREIGN KEY (bed_id) REFERENCES mcms_icu.bed(bed_id);


--
-- Name: score score_admission_id_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.score
    ADD CONSTRAINT score_admission_id_fkey FOREIGN KEY (admission_id) REFERENCES mcms_icu.admission(admission_id) ON DELETE CASCADE;


--
-- Name: score score_assessed_by_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.score
    ADD CONSTRAINT score_assessed_by_fkey FOREIGN KEY (assessed_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: support_session support_session_admission_id_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.support_session
    ADD CONSTRAINT support_session_admission_id_fkey FOREIGN KEY (admission_id) REFERENCES mcms_icu.admission(admission_id) ON DELETE CASCADE;


--
-- Name: vitals_stream vitals_stream_admission_id_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.vitals_stream
    ADD CONSTRAINT vitals_stream_admission_id_fkey FOREIGN KEY (admission_id) REFERENCES mcms_icu.admission(admission_id) ON DELETE CASCADE;


--
-- Name: vitals_stream vitals_stream_charted_by_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.vitals_stream
    ADD CONSTRAINT vitals_stream_charted_by_fkey FOREIGN KEY (charted_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: vitals_stream vitals_stream_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_icu; Owner: -
--

ALTER TABLE ONLY mcms_icu.vitals_stream
    ADD CONSTRAINT vitals_stream_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: lab_order lab_order_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.lab_order
    ADD CONSTRAINT lab_order_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: lab_order lab_order_panel_id_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.lab_order
    ADD CONSTRAINT lab_order_panel_id_fkey FOREIGN KEY (panel_id) REFERENCES mcms_lab.test_panel(panel_id);


--
-- Name: lab_order lab_order_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.lab_order
    ADD CONSTRAINT lab_order_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: lab_order lab_order_requested_by_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.lab_order
    ADD CONSTRAINT lab_order_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: result result_analysed_by_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.result
    ADD CONSTRAINT result_analysed_by_fkey FOREIGN KEY (analysed_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: result result_sample_id_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.result
    ADD CONSTRAINT result_sample_id_fkey FOREIGN KEY (sample_id) REFERENCES mcms_lab.sample(sample_id) ON DELETE CASCADE;


--
-- Name: result result_test_id_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.result
    ADD CONSTRAINT result_test_id_fkey FOREIGN KEY (test_id) REFERENCES mcms_lab.test_catalog(test_id);


--
-- Name: result result_verified_by_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.result
    ADD CONSTRAINT result_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: sample sample_collected_by_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.sample
    ADD CONSTRAINT sample_collected_by_fkey FOREIGN KEY (collected_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: sample sample_lab_order_id_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.sample
    ADD CONSTRAINT sample_lab_order_id_fkey FOREIGN KEY (lab_order_id) REFERENCES mcms_lab.lab_order(order_id) ON DELETE CASCADE;


--
-- Name: sample sample_received_by_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.sample
    ADD CONSTRAINT sample_received_by_fkey FOREIGN KEY (received_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: test_panel_item test_panel_item_panel_id_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.test_panel_item
    ADD CONSTRAINT test_panel_item_panel_id_fkey FOREIGN KEY (panel_id) REFERENCES mcms_lab.test_panel(panel_id) ON DELETE CASCADE;


--
-- Name: test_panel_item test_panel_item_test_id_fkey; Type: FK CONSTRAINT; Schema: mcms_lab; Owner: -
--

ALTER TABLE ONLY mcms_lab.test_panel_item
    ADD CONSTRAINT test_panel_item_test_id_fkey FOREIGN KEY (test_id) REFERENCES mcms_lab.test_catalog(test_id);


--
-- Name: cot cot_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.cot
    ADD CONSTRAINT cot_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: growth_entry growth_entry_neonate_id_fkey; Type: FK CONSTRAINT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.growth_entry
    ADD CONSTRAINT growth_entry_neonate_id_fkey FOREIGN KEY (neonate_id) REFERENCES mcms_nursery.neonate_record(neonate_id) ON DELETE CASCADE;


--
-- Name: growth_entry growth_entry_nurse_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.growth_entry
    ADD CONSTRAINT growth_entry_nurse_user_id_fkey FOREIGN KEY (nurse_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: neonate_record neonate_record_cot_id_fkey; Type: FK CONSTRAINT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.neonate_record
    ADD CONSTRAINT neonate_record_cot_id_fkey FOREIGN KEY (cot_id) REFERENCES mcms_nursery.cot(cot_id);


--
-- Name: neonate_record neonate_record_mother_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.neonate_record
    ADD CONSTRAINT neonate_record_mother_party_id_fkey FOREIGN KEY (mother_party_id) REFERENCES mcms_core.party(party_id);


--
-- Name: neonate_record neonate_record_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_nursery; Owner: -
--

ALTER TABLE ONLY mcms_nursery.neonate_record
    ADD CONSTRAINT neonate_record_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id);


--
-- Name: session session_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.session
    ADD CONSTRAINT session_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: session session_plan_id_fkey; Type: FK CONSTRAINT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.session
    ADD CONSTRAINT session_plan_id_fkey FOREIGN KEY (plan_id) REFERENCES mcms_physio.treatment_plan(plan_id) ON DELETE CASCADE;


--
-- Name: session session_room_id_fkey; Type: FK CONSTRAINT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.session
    ADD CONSTRAINT session_room_id_fkey FOREIGN KEY (room_id) REFERENCES mcms_clinic.room(room_id);


--
-- Name: session session_therapist_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.session
    ADD CONSTRAINT session_therapist_user_id_fkey FOREIGN KEY (therapist_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: session session_therapy_id_fkey; Type: FK CONSTRAINT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.session
    ADD CONSTRAINT session_therapy_id_fkey FOREIGN KEY (therapy_id) REFERENCES mcms_physio.therapy_catalog(therapy_id);


--
-- Name: treatment_plan treatment_plan_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.treatment_plan
    ADD CONSTRAINT treatment_plan_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: treatment_plan treatment_plan_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.treatment_plan
    ADD CONSTRAINT treatment_plan_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: treatment_plan treatment_plan_therapist_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_physio; Owner: -
--

ALTER TABLE ONLY mcms_physio.treatment_plan
    ADD CONSTRAINT treatment_plan_therapist_user_id_fkey FOREIGN KEY (therapist_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: image_instance image_instance_study_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.image_instance
    ADD CONSTRAINT image_instance_study_id_fkey FOREIGN KEY (study_id) REFERENCES mcms_rad.study_request(study_id) ON DELETE CASCADE;


--
-- Name: modality_suite modality_suite_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.modality_suite
    ADD CONSTRAINT modality_suite_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: study_request study_request_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.study_request
    ADD CONSTRAINT study_request_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: study_request study_request_exam_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.study_request
    ADD CONSTRAINT study_request_exam_id_fkey FOREIGN KEY (exam_id) REFERENCES mcms_rad.exam_catalog(exam_id);


--
-- Name: study_request study_request_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.study_request
    ADD CONSTRAINT study_request_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: study_request study_request_reported_by_fkey; Type: FK CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.study_request
    ADD CONSTRAINT study_request_reported_by_fkey FOREIGN KEY (reported_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: study_request study_request_requested_by_fkey; Type: FK CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.study_request
    ADD CONSTRAINT study_request_requested_by_fkey FOREIGN KEY (requested_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: study_request study_request_suite_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.study_request
    ADD CONSTRAINT study_request_suite_id_fkey FOREIGN KEY (suite_id) REFERENCES mcms_rad.modality_suite(suite_id);


--
-- Name: study_request study_request_verified_by_fkey; Type: FK CONSTRAINT; Schema: mcms_rad; Owner: -
--

ALTER TABLE ONLY mcms_rad.study_request
    ADD CONSTRAINT study_request_verified_by_fkey FOREIGN KEY (verified_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: administration administration_administered_by_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.administration
    ADD CONSTRAINT administration_administered_by_fkey FOREIGN KEY (administered_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: administration administration_drug_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.administration
    ADD CONSTRAINT administration_drug_item_id_fkey FOREIGN KEY (drug_item_id) REFERENCES mcms_rx.drug_item(drug_item_id);


--
-- Name: administration administration_med_order_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.administration
    ADD CONSTRAINT administration_med_order_id_fkey FOREIGN KEY (med_order_id) REFERENCES mcms_emr.medication_order(order_id);


--
-- Name: administration administration_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.administration
    ADD CONSTRAINT administration_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: administration administration_witnessed_by_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.administration
    ADD CONSTRAINT administration_witnessed_by_fkey FOREIGN KEY (witnessed_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: dispensation disp_mrn_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.dispensation
    ADD CONSTRAINT disp_mrn_fkey FOREIGN KEY (mrn) REFERENCES mcms_emr.patient(mrn) ON DELETE CASCADE;


--
-- Name: dispensation dispensation_dispensed_by_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.dispensation
    ADD CONSTRAINT dispensation_dispensed_by_fkey FOREIGN KEY (dispensed_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: dispensation dispensation_drug_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.dispensation
    ADD CONSTRAINT dispensation_drug_item_id_fkey FOREIGN KEY (drug_item_id) REFERENCES mcms_rx.drug_item(drug_item_id);


--
-- Name: dispensation dispensation_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.dispensation
    ADD CONSTRAINT dispensation_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: dispensation dispensation_lot_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.dispensation
    ADD CONSTRAINT dispensation_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES mcms_rx.drug_lot(lot_id);


--
-- Name: dispensation dispensation_med_order_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.dispensation
    ADD CONSTRAINT dispensation_med_order_id_fkey FOREIGN KEY (med_order_id) REFERENCES mcms_emr.medication_order(order_id);


--
-- Name: dispensation dispensation_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.dispensation
    ADD CONSTRAINT dispensation_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: drug_alternative drug_alternative_alt_drug_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_alternative
    ADD CONSTRAINT drug_alternative_alt_drug_item_id_fkey FOREIGN KEY (alt_drug_item_id) REFERENCES mcms_rx.drug_item(drug_item_id);


--
-- Name: drug_alternative drug_alternative_drug_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_alternative
    ADD CONSTRAINT drug_alternative_drug_item_id_fkey FOREIGN KEY (drug_item_id) REFERENCES mcms_rx.drug_item(drug_item_id);


--
-- Name: drug_interaction drug_interaction_drug_item_id_a_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_interaction
    ADD CONSTRAINT drug_interaction_drug_item_id_a_fkey FOREIGN KEY (drug_item_id_a) REFERENCES mcms_rx.drug_item(drug_item_id);


--
-- Name: drug_interaction drug_interaction_drug_item_id_b_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_interaction
    ADD CONSTRAINT drug_interaction_drug_item_id_b_fkey FOREIGN KEY (drug_item_id_b) REFERENCES mcms_rx.drug_item(drug_item_id);


--
-- Name: drug_lot drug_lot_drug_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_lot
    ADD CONSTRAINT drug_lot_drug_item_id_fkey FOREIGN KEY (drug_item_id) REFERENCES mcms_rx.drug_item(drug_item_id) ON DELETE CASCADE;


--
-- Name: drug_lot drug_lot_po_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_lot
    ADD CONSTRAINT drug_lot_po_fkey FOREIGN KEY (purchase_order_id) REFERENCES mcms_erp.purchase_order(po_id);


--
-- Name: drug_lot drug_lot_supplier_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.drug_lot
    ADD CONSTRAINT drug_lot_supplier_party_id_fkey FOREIGN KEY (supplier_party_id) REFERENCES mcms_core.party(party_id);


--
-- Name: prescription prescription_drug_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.prescription
    ADD CONSTRAINT prescription_drug_item_id_fkey FOREIGN KEY (drug_item_id) REFERENCES mcms_rx.drug_item(drug_item_id);


--
-- Name: stock_movement stock_movement_drug_item_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.stock_movement
    ADD CONSTRAINT stock_movement_drug_item_id_fkey FOREIGN KEY (drug_item_id) REFERENCES mcms_rx.drug_item(drug_item_id);


--
-- Name: stock_movement stock_movement_lot_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.stock_movement
    ADD CONSTRAINT stock_movement_lot_id_fkey FOREIGN KEY (lot_id) REFERENCES mcms_rx.drug_lot(lot_id);


--
-- Name: stock_movement stock_movement_performed_by_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.stock_movement
    ADD CONSTRAINT stock_movement_performed_by_fkey FOREIGN KEY (performed_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: stock_movement stock_movement_related_movement_id_fkey; Type: FK CONSTRAINT; Schema: mcms_rx; Owner: -
--

ALTER TABLE ONLY mcms_rx.stock_movement
    ADD CONSTRAINT stock_movement_related_movement_id_fkey FOREIGN KEY (related_movement_id) REFERENCES mcms_rx.stock_movement(movement_id);


--
-- Name: intra_op_vitals intra_op_vitals_recorded_by_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.intra_op_vitals
    ADD CONSTRAINT intra_op_vitals_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: intra_op_vitals intra_op_vitals_surgery_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.intra_op_vitals
    ADD CONSTRAINT intra_op_vitals_surgery_id_fkey FOREIGN KEY (surgery_id) REFERENCES mcms_surgical.surgery(surgery_id) ON DELETE CASCADE;


--
-- Name: operating_room operating_room_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.operating_room
    ADD CONSTRAINT operating_room_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: post_op_note post_op_note_surgery_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.post_op_note
    ADD CONSTRAINT post_op_note_surgery_id_fkey FOREIGN KEY (surgery_id) REFERENCES mcms_surgical.surgery(surgery_id) ON DELETE CASCADE;


--
-- Name: post_op_note post_op_note_written_by_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.post_op_note
    ADD CONSTRAINT post_op_note_written_by_fkey FOREIGN KEY (written_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: pre_op_checklist pre_op_checklist_checklist_by_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.pre_op_checklist
    ADD CONSTRAINT pre_op_checklist_checklist_by_fkey FOREIGN KEY (checklist_by) REFERENCES mcms_core.app_user(user_id);


--
-- Name: pre_op_checklist pre_op_checklist_surgery_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.pre_op_checklist
    ADD CONSTRAINT pre_op_checklist_surgery_id_fkey FOREIGN KEY (surgery_id) REFERENCES mcms_surgical.surgery(surgery_id) ON DELETE CASCADE;


--
-- Name: surgery surgery_anaesthetist_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgery
    ADD CONSTRAINT surgery_anaesthetist_user_id_fkey FOREIGN KEY (anaesthetist_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: surgery surgery_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgery
    ADD CONSTRAINT surgery_encounter_id_fkey FOREIGN KEY (encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: surgery surgery_or_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgery
    ADD CONSTRAINT surgery_or_id_fkey FOREIGN KEY (or_id) REFERENCES mcms_surgical.operating_room(or_id);


--
-- Name: surgery surgery_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgery
    ADD CONSTRAINT surgery_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id) ON DELETE CASCADE;


--
-- Name: surgery surgery_primary_dept_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgery
    ADD CONSTRAINT surgery_primary_dept_id_fkey FOREIGN KEY (primary_dept_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: surgery surgery_procedure_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgery
    ADD CONSTRAINT surgery_procedure_id_fkey FOREIGN KEY (procedure_id) REFERENCES mcms_surgical.procedure_catalog(proc_cat_id);


--
-- Name: surgery surgery_surgeon_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgery
    ADD CONSTRAINT surgery_surgeon_user_id_fkey FOREIGN KEY (surgeon_user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: surgical_team surgical_team_surgery_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgical_team
    ADD CONSTRAINT surgical_team_surgery_id_fkey FOREIGN KEY (surgery_id) REFERENCES mcms_surgical.surgery(surgery_id) ON DELETE CASCADE;


--
-- Name: surgical_team surgical_team_user_id_fkey; Type: FK CONSTRAINT; Schema: mcms_surgical; Owner: -
--

ALTER TABLE ONLY mcms_surgical.surgical_team
    ADD CONSTRAINT surgical_team_user_id_fkey FOREIGN KEY (user_id) REFERENCES mcms_core.app_user(user_id);


--
-- Name: birth_certificate birth_certificate_amended_from_fkey; Type: FK CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.birth_certificate
    ADD CONSTRAINT birth_certificate_amended_from_fkey FOREIGN KEY (amended_from) REFERENCES mcms_vital_records.birth_certificate(birth_cert_id);


--
-- Name: birth_certificate birth_certificate_delivery_encounter_id_fkey; Type: FK CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.birth_certificate
    ADD CONSTRAINT birth_certificate_delivery_encounter_id_fkey FOREIGN KEY (delivery_encounter_id) REFERENCES mcms_emr.encounter(encounter_id);


--
-- Name: birth_certificate birth_certificate_facility_id_fkey; Type: FK CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.birth_certificate
    ADD CONSTRAINT birth_certificate_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES mcms_core.facility(facility_id);


--
-- Name: birth_certificate birth_certificate_father_party_id_fkey; Type: FK CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.birth_certificate
    ADD CONSTRAINT birth_certificate_father_party_id_fkey FOREIGN KEY (father_party_id) REFERENCES mcms_core.party(party_id);


--
-- Name: birth_certificate birth_certificate_mother_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.birth_certificate
    ADD CONSTRAINT birth_certificate_mother_patient_id_fkey FOREIGN KEY (mother_patient_id) REFERENCES mcms_emr.patient(patient_id);


--
-- Name: birth_certificate birth_certificate_newborn_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.birth_certificate
    ADD CONSTRAINT birth_certificate_newborn_patient_id_fkey FOREIGN KEY (newborn_patient_id) REFERENCES mcms_emr.patient(patient_id);


--
-- Name: death_certificate death_certificate_amended_from_fkey; Type: FK CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.death_certificate
    ADD CONSTRAINT death_certificate_amended_from_fkey FOREIGN KEY (amended_from) REFERENCES mcms_vital_records.death_certificate(death_cert_id);


--
-- Name: death_certificate death_certificate_facility_id_fkey; Type: FK CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.death_certificate
    ADD CONSTRAINT death_certificate_facility_id_fkey FOREIGN KEY (facility_id) REFERENCES mcms_core.facility(facility_id);


--
-- Name: death_certificate death_certificate_patient_id_fkey; Type: FK CONSTRAINT; Schema: mcms_vital_records; Owner: -
--

ALTER TABLE ONLY mcms_vital_records.death_certificate
    ADD CONSTRAINT death_certificate_patient_id_fkey FOREIGN KEY (patient_id) REFERENCES mcms_emr.patient(patient_id);


--
-- Name: waste_collection waste_collection_container_id_fkey; Type: FK CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_collection
    ADD CONSTRAINT waste_collection_container_id_fkey FOREIGN KEY (container_id) REFERENCES mcms_waste.waste_container(container_id);


--
-- Name: waste_container waste_container_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_container
    ADD CONSTRAINT waste_container_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: waste_container waste_container_stream_id_fkey; Type: FK CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_container
    ADD CONSTRAINT waste_container_stream_id_fkey FOREIGN KEY (stream_id) REFERENCES mcms_waste.waste_stream(stream_id);


--
-- Name: waste_cost_allocation waste_cost_allocation_department_id_fkey; Type: FK CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_cost_allocation
    ADD CONSTRAINT waste_cost_allocation_department_id_fkey FOREIGN KEY (department_id) REFERENCES mcms_hr.department(department_id);


--
-- Name: waste_cost_allocation waste_cost_allocation_manifest_id_fkey; Type: FK CONSTRAINT; Schema: mcms_waste; Owner: -
--

ALTER TABLE ONLY mcms_waste.waste_cost_allocation
    ADD CONSTRAINT waste_cost_allocation_manifest_id_fkey FOREIGN KEY (manifest_id) REFERENCES mcms_waste.waste_disposal_manifest(manifest_id);


--
-- PostgreSQL database dump complete
--

\unrestrict uDwcM2be06Prp64mKyrnNppyCHTZ5pf8nJY8Ct3yZpvyStE5vNTR4AGNwsbJEyA

