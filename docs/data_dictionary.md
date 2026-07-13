# MCMS Data Dictionary

_15 schemas · 89 tables · generated from live DB_


## mcms_billing — Billing


### mcms_billing.insurance_claim

| Column | Type | PK |
|---|---|---|
| claim_id | int8 | ✔ |
| invoice_id | int8 |  |
| policy_no | text |  |
| insurance_provider | text |  |
| patient_id | int8 |  |
| billed_amount | numeric |  |
| approved_amount | numeric |  |
| rejected_amount | numeric |  |
| status | claim_status |  |
| submitted_at | timestamptz |  |
| adjudicated_at | timestamptz |  |
| paid_at | timestamptz |  |
| claim_no_external | text |  |
| notes | text |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_billing.invoice

| Column | Type | PK |
|---|---|---|
| invoice_id | int8 | ✔ |
| invoice_no | text |  |
| patient_id | int8 |  |
| mrn | text |  |
| encounter_id | int8 |  |
| issued_by | int8 |  |
| status | inv_status |  |
| subtotal | numeric |  |
| tax_amount | numeric |  |
| discount_amount | numeric |  |
| insurance_covers | numeric |  |
| patient_pays | numeric |  |
| total | numeric |  |
| currency | text |  |
| issued_at | timestamptz |  |
| due_date | date |  |
| paid_at | timestamptz |  |
| notes | text |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_billing.invoice_line

| Column | Type | PK |
|---|---|---|
| line_id | int8 | ✔ |
| invoice_id | int8 |  |
| service_id | int8 |  |
| source_schema | text |  |
| source_table | text |  |
| source_id | int8 |  |
| description | text |  |
| qty | numeric |  |
| unit_price | numeric |  |
| line_total | numeric |  |
| created_at | timestamptz |  |

### mcms_billing.payment

| Column | Type | PK |
|---|---|---|
| payment_id | int8 | ✔ |
| invoice_id | int8 |  |
| method | pay_method |  |
| amount | numeric |  |
| currency | text |  |
| paid_at | timestamptz |  |
| received_by | int8 |  |
| txn_ref | text |  |
| notes | text |  |

### mcms_billing.service_price

| Column | Type | PK |
|---|---|---|
| service_id | int8 | ✔ |
| code | text |  |
| name | text |  |
| service_type | service_type |  |
| department_id | int8 |  |
| unit_price | numeric |  |
| currency | text |  |
| is_taxable | bool |  |
| is_active | bool |  |
| effective_from | date |  |
| effective_to | date |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

## mcms_clinic — Clinics & Appointments


### mcms_clinic.appointment

| Column | Type | PK |
|---|---|---|
| appointment_id | int8 | ✔ |
| mrn | text |  |
| patient_id | int8 |  |
| clinician_user_id | int8 |  |
| room_id | int8 |  |
| department_id | int8 |  |
| starts_at | timestamptz |  |
| ends_at | timestamptz |  |
| status | slot_status |  |
| reason | text |  |
| booked_by | int8 |  |
| encounter_id | int8 |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |
| confirmation_token | uuid |  |
| confirmation_deadline | timestamptz |  |
| confirmed_at | timestamptz |  |
| patient_confirmed | bool |  |

### mcms_clinic.consultation

| Column | Type | PK |
|---|---|---|
| consultation_id | int8 | ✔ |
| appointment_id | int8 |  |
| queue_id | int8 |  |
| encounter_id | int8 |  |
| room_id | int8 |  |
| clinician_user_id | int8 |  |
| duration_minutes | int4 |  |
| subjective | text |  |
| objective | text |  |
| assessment | text |  |
| plan | text |  |
| follow_up_days | int4 |  |
| status | consult_status |  |
| started_at | timestamptz |  |
| completed_at | timestamptz |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_clinic.patient_queue

| Column | Type | PK |
|---|---|---|
| queue_id | int8 | ✔ |
| patient_id | int8 |  |
| mrn | text |  |
| department_id | int8 |  |
| assigned_clinician | int8 |  |
| room_id | int8 |  |
| priority | int4 |  |
| status | queue_status |  |
| checked_in_at | timestamptz |  |
| called_at | timestamptz |  |
| started_at | timestamptz |  |
| finished_at | timestamptz |  |
| encounter_id | int8 |  |

### mcms_clinic.room

| Column | Type | PK |
|---|---|---|
| room_id | int8 | ✔ |
| department_id | int8 |  |
| code | text |  |
| name | text |  |
| capacity | int4 |  |
| equipment | _text |  |
| is_active | bool |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

## mcms_core — Core / Event-Store / RBAC


### mcms_core.address

| Column | Type | PK |
|---|---|---|
| address_id | int8 | ✔ |
| party_id | int8 |  |
| label | text |  |
| line1 | text |  |
| line2 | text |  |
| city | text |  |
| region | text |  |
| postal_code | text |  |
| country | text |  |
| latitude | float8 |  |
| longitude | float8 |  |
| is_primary | bool |  |
| created_at | timestamptz |  |

### mcms_core.app_user

| Column | Type | PK |
|---|---|---|
| user_id | int8 | ✔ |
| party_id | int8 |  |
| username | text |  |
| password_hash | text |  |
| role | user_role |  |
| specialization | text |  |
| is_active | bool |  |
| last_login_at | timestamptz |  |
| failed_logins | int4 |  |
| locked_until | timestamptz |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_core.audit_trail

| Column | Type | PK |
|---|---|---|
| audit_id | int8 | ✔ |
| table_schema | text |  |
| table_name | text |  |
| row_id | int8 |  |
| action | text |  |
| changed_by | int8 |  |
| changed_at | timestamptz |  |
| before | jsonb |  |
| after | jsonb |  |
| event_id | int8 |  |

### mcms_core.contact

| Column | Type | PK |
|---|---|---|
| contact_id | int8 | ✔ |
| party_id | int8 |  |
| kind | text |  |
| value | text |  |
| is_primary | bool |  |
| verified_at | timestamptz |  |
| created_at | timestamptz |  |

### mcms_core.event_log

| Column | Type | PK |
|---|---|---|
| event_id | int8 | ✔ |
| seq | int8 |  |
| occurred_at | timestamptz |  |
| kind | event_kind |  |
| severity | event_severity |  |
| actor_user_id | int8 |  |
| subject_party_id | int8 |  |
| source_schema | text |  |
| source_table | text |  |
| source_id | int8 |  |
| payload | jsonb |  |
| channel | text |  |

### mcms_core.lookup

| Column | Type | PK |
|---|---|---|
| lookup_id | int8 | ✔ |
| namespace | text |  |
| code | text |  |
| label | text |  |
| parent_code | text |  |
| sort_order | int4 |  |
| is_active | bool |  |
| label_en | text |  |
| label_ar | text |  |

### mcms_core.notification

| Column | Type | PK |
|---|---|---|
| notification_id | int8 | ✔ |
| recipient_user_id | int8 |  |
| recipient_party_id | int8 |  |
| category | text |  |
| channel | notification_channel |  |
| subject | text |  |
| body | text |  |
| status | notification_status |  |
| source_schema | text |  |
| source_table | text |  |
| source_id | int8 |  |
| sent_at | timestamptz |  |
| read_at | timestamptz |  |
| created_at | timestamptz |  |

### mcms_core.party

| Column | Type | PK |
|---|---|---|
| party_id | int8 | ✔ |
| party_type | party_type |  |
| code | text |  |
| display_name | text |  |
| legal_name | text |  |
| gender | gender_type |  |
| date_of_birth | date |  |
| blood_type | blood_type |  |
| tax_id | text |  |
| national_id | text |  |
| is_active | bool |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |
| preferred_language | text |  |

### mcms_core.permission

| Column | Type | PK |
|---|---|---|
| permission_id | int8 | ✔ |
| code | text |  |
| description | text |  |

### mcms_core.role

| Column | Type | PK |
|---|---|---|
| role_id | int8 | ✔ |
| code | text |  |
| name_en | text |  |
| name_ar | text |  |
| description | text |  |
| is_active | bool |  |
| created_at | timestamptz |  |

### mcms_core.role_permission

| Column | Type | PK |
|---|---|---|
| role_id | int8 | ✔ |
| permission_id | int8 | ✔ |

### mcms_core.user_role_map

| Column | Type | PK |
|---|---|---|
| user_id | int8 | ✔ |
| role_id | int8 | ✔ |
| department_id | int8 |  |

## mcms_dialysis — Dialysis


### mcms_dialysis.session

| Column | Type | PK |
|---|---|---|
| session_id | int8 | ✔ |
| patient_id | int8 |  |
| encounter_id | int8 |  |
| station_id | int8 |  |
| nurse_user_id | int8 |  |
| nephrologist_user_id | int8 |  |
| modality | modality |  |
| scheduled_at | timestamptz |  |
| started_at | timestamptz |  |
| ended_at | timestamptz |  |
| duration_minutes | int4 |  |
| pre_weight_kg | numeric |  |
| pre_bp | text |  |
| dry_weight_kg | numeric |  |
| post_weight_kg | numeric |  |
| post_bp | text |  |
| fluid_removed_ml | int4 |  |
| blood_flow_rate | int4 |  |
| dialysate_flow | int4 |  |
| heparin_units | int4 |  |
| kt_v | numeric |  |
| complications | text |  |
| status | dialysis_status |  |
| notes | text |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_dialysis.station

| Column | Type | PK |
|---|---|---|
| station_id | int8 | ✔ |
| code | text |  |
| name | text |  |
| department_id | int8 |  |
| has_ro_water | bool |  |
| status | bed_status |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

## mcms_emergency — Emergency


### mcms_emergency.ed_bed

| Column | Type | PK |
|---|---|---|
| ed_bed_id | int8 | ✔ |
| triage_id | int8 |  |
| bed_label | text |  |
| assigned_at | timestamptz |  |
| released_at | timestamptz |  |
| observation_minutes | int4 |  |
| notes | text |  |

### mcms_emergency.resuscitation

| Column | Type | PK |
|---|---|---|
| resus_id | int8 | ✔ |
| triage_id | int8 |  |
| encounter_id | int8 |  |
| patient_id | int8 |  |
| code_initiated_at | timestamptz |  |
| code_type | text |  |
| team_leader_id | int8 |  |
| airway | text |  |
| interventions | _text |  |
| iv_access | text |  |
| meds_administered | _text |  |
| rosc | bool |  |
| rosc_at | timestamptz |  |
| duration_minutes | int4 |  |
| outcome | text |  |
| notes | text |  |
| created_at | timestamptz |  |

### mcms_emergency.triage

| Column | Type | PK |
|---|---|---|
| triage_id | int8 | ✔ |
| ed_visit_no | text |  |
| patient_id | int8 |  |
| mrn | text |  |
| encounter_id | int8 |  |
| presentation_time | timestamptz |  |
| chief_complaint | text |  |
| esi_level | int4 |  |
| arrival_mode | text |  |
| trauma_alert | bool |  |
| vital_temp_c | numeric |  |
| vital_hr_bpm | int4 |  |
| vital_sbp_mmhg | int4 |  |
| vital_dbp_mmhg | int4 |  |
| vital_rr_pm | int4 |  |
| vital_spo2_pct | numeric |  |
| vital_pain_score | int4 |  |
| vital_gcs | int4 |  |
| allergies_known | text |  |
| meds_on_arrival | _text |  |
| triage_nurse_user_id | int8 |  |
| triaged_at | timestamptz |  |
| status | triage_status |  |
| disposition | text |  |
| disposition_destination | text |  |
| disposition_at | timestamptz |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

## mcms_emr — EMR


### mcms_emr.allergy

| Column | Type | PK |
|---|---|---|
| allergy_id | int8 | ✔ |
| patient_id | int8 |  |
| substance | text |  |
| reaction | text |  |
| severity | allergy_severity |  |
| onset_age | text |  |
| noted_on | timestamptz |  |
| noted_by | int8 |  |
| is_active | bool |  |

### mcms_emr.clinical_note

| Column | Type | PK |
|---|---|---|
| note_id | int8 | ✔ |
| encounter_id | int8 |  |
| patient_id | int8 |  |
| note_type | note_type |  |
| title | text |  |
| body | text |  |
| author_user_id | int8 |  |
| coauthor_ids | _int8 |  |
| signed | bool |  |
| signed_at | timestamptz |  |
| amended_at | timestamptz |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_emr.diagnosis

| Column | Type | PK |
|---|---|---|
| diagnosis_id | int8 | ✔ |
| encounter_id | int8 |  |
| patient_id | int8 |  |
| condition_code | text |  |
| condition_desc | text |  |
| role | diagnosis_role |  |
| status | diagnosis_status |  |
| onset_date | date |  |
| resolved_at | timestamptz |  |
| recorded_by | int8 |  |
| is_chronic | bool |  |
| created_at | timestamptz |  |

### mcms_emr.encounter

| Column | Type | PK |
|---|---|---|
| encounter_id | int8 | ✔ |
| mrn | text |  |
| patient_id | int8 |  |
| status | encounter_status |  |
| class | encounter_class |  |
| attending_user_id | int8 |  |
| referring_user_id | int8 |  |
| department_id | int8 |  |
| reason_for_visit | text |  |
| chief_complaint | text |  |
| started_at | timestamptz |  |
| ended_at | timestamptz |  |
| bed_assign_id | int8 |  |
| originating_encounter_id | int8 |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |
| fhir_id | text |  |

### mcms_emr.family_history

| Column | Type | PK |
|---|---|---|
| fh_id | int8 | ✔ |
| patient_id | int8 |  |
| relative | text |  |
| relationship | text |  |
| condition_code | text |  |
| condition_desc | text |  |
| age_at_onset | int4 |  |
| is_deceased | bool |  |
| recorded_at | timestamptz |  |

### mcms_emr.immunization

| Column | Type | PK |
|---|---|---|
| immunization_id | int8 | ✔ |
| patient_id | int8 |  |
| vaccine_code | text |  |
| vaccine_name | text |  |
| dose_number | int4 |  |
| given_at | timestamptz |  |
| given_by | int8 |  |
| lot_number | text |  |
| site | text |  |
| reaction | text |  |

### mcms_emr.medication_order

| Column | Type | PK |
|---|---|---|
| order_id | int8 | ✔ |
| encounter_id | int8 |  |
| patient_id | int8 |  |
| prescriber_user_id | int8 |  |
| drug_item_id | int8 |  |
| drug_name | text |  |
| dose | text |  |
| route | med_route |  |
| frequency | text |  |
| duration_days | int4 |  |
| prn | bool |  |
| refill_count | int4 |  |
| instructions | text |  |
| status | med_order_status |  |
| ordered_at | timestamptz |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_emr.patient

| Column | Type | PK |
|---|---|---|
| patient_id | int8 | ✔ |
| party_id | int8 |  |
| mrn | text |  |
| emergency_contact_name | text |  |
| emergency_contact_phone | text |  |
| next_of_kin_party_id | int8 |  |
| insurance_provider | text |  |
| insurance_policy_no | text |  |
| insurance_group_no | text |  |
| coverage_verified | bool |  |
| coverage_verified_at | timestamptz |  |
| preferred_language | text |  |
| organ_donor | bool |  |
| living_will | bool |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |
| fhir_id | text |  |
| hl7_mpi | text |  |

### mcms_emr.social_history

| Column | Type | PK |
|---|---|---|
| sh_id | int8 | ✔ |
| patient_id | int8 |  |
| tobacco_status | text |  |
| packs_per_day | numeric |  |
| years_smoked | int4 |  |
| alcohol_status | text |  |
| drinks_per_week | int4 |  |
| illicit_drugs | _text |  |
| occupation | text |  |
| relationship_status | text |  |
| recorded_at | timestamptz |  |

### mcms_emr.vitals

| Column | Type | PK |
|---|---|---|
| vital_id | int8 | ✔ |
| encounter_id | int8 |  |
| patient_id | int8 |  |
| taken_at | timestamptz |  |
| taken_by | int8 |  |
| temp_c | numeric |  |
| hr_bpm | int4 |  |
| rr_pm | int4 |  |
| sbp_mmhg | int4 |  |
| dbp_mmhg | int4 |  |
| spo2_pct | numeric |  |
| weight_kg | numeric |  |
| height_cm | numeric |  |
| bmi | numeric |  |
| pain_score | int4 |  |
| glucose_mgdl | int4 |  |

## mcms_erp — ERP / Supply Chain


### mcms_erp.gl_account

| Column | Type | PK |
|---|---|---|
| account_id | int8 | ✔ |
| code | text |  |
| name | text |  |
| account_type | account_type |  |
| parent_account_id | int8 |  |
| is_postable | bool |  |
| is_active | bool |  |

### mcms_erp.goods_receipt

| Column | Type | PK |
|---|---|---|
| grn_id | int8 | ✔ |
| grn_no | text |  |
| po_id | int8 |  |
| supplier_id | int8 |  |
| received_by | int8 |  |
| received_at | timestamptz |  |
| status | grn_status |  |
| notes | text |  |

### mcms_erp.goods_receipt_line

| Column | Type | PK |
|---|---|---|
| line_id | int8 | ✔ |
| grn_id | int8 |  |
| po_line_id | int8 |  |
| item_id | int8 |  |
| drug_item_id | int8 |  |
| qty_received | int4 |  |
| lot_number | text |  |
| expiration_date | date |  |
| unit_cost | numeric |  |

### mcms_erp.inventory_item

| Column | Type | PK |
|---|---|---|
| item_id | int8 | ✔ |
| code | text |  |
| name | text |  |
| type | item_type |  |
| unit | text |  |
| reorder_level | int4 |  |
| reorder_qty | int4 |  |
| cost_per_unit | numeric |  |
| is_active | bool |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_erp.inventory_stock

| Column | Type | PK |
|---|---|---|
| stock_id | int8 | ✔ |
| item_id | int8 |  |
| department_id | int8 |  |
| qty_on_hand | int4 |  |
| qty_reserved | int4 |  |
| last_count_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_erp.purchase_order

| Column | Type | PK |
|---|---|---|
| po_id | int8 | ✔ |
| po_no | text |  |
| supplier_id | int8 |  |
| requested_by | int8 |  |
| approved_by | int8 |  |
| status | po_status |  |
| expected_at | date |  |
| ordered_at | timestamptz |  |
| received_at | timestamptz |  |
| closed_at | timestamptz |  |
| notes | text |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_erp.purchase_order_line

| Column | Type | PK |
|---|---|---|
| line_id | int8 | ✔ |
| po_id | int8 |  |
| item_id | int8 |  |
| drug_item_id | int8 |  |
| item_description | text |  |
| qty | int4 |  |
| unit_price | numeric |  |
| qty_received | int4 |  |
| line_total | numeric |  |

### mcms_erp.stock_movement

| Column | Type | PK |
|---|---|---|
| movement_id | int8 | ✔ |
| item_id | int8 |  |
| from_department_id | int8 |  |
| to_department_id | int8 |  |
| qty_delta | int4 |  |
| movement_type | move_type |  |
| reference_table | text |  |
| reference_id | int8 |  |
| performed_by | int8 |  |
| performed_at | timestamptz |  |
| reason | text |  |

### mcms_erp.supplier

| Column | Type | PK |
|---|---|---|
| supplier_id | int8 | ✔ |
| party_id | int8 |  |
| supplier_code | text |  |
| contact_user_id | int8 |  |
| payment_terms_days | int4 |  |
| is_active | bool |  |
| created_at | timestamptz |  |

## mcms_hr — HR & Payroll


### mcms_hr.attendance

| Column | Type | PK |
|---|---|---|
| attendance_id | int8 | ✔ |
| employee_id | int8 |  |
| shift_id | int8 |  |
| clock_in_at | timestamptz |  |
| clock_out_at | timestamptz |  |
| status | attendance_status |  |
| note | text |  |
| created_at | timestamptz |  |

### mcms_hr.department

| Column | Type | PK |
|---|---|---|
| department_id | int8 | ✔ |
| code | text |  |
| name | text |  |
| parent_department_id | int8 |  |
| kind | text |  |
| head_user_id | int8 |  |
| location_building | text |  |
| location_floor | int4 |  |
| is_active | bool |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_hr.employee

| Column | Type | PK |
|---|---|---|
| employee_id | int8 | ✔ |
| party_id | int8 |  |
| user_id | int8 |  |
| employee_no | text |  |
| primary_department_id | int8 |  |
| role | text |  |
| job_title | text |  |
| specialisation | text |  |
| license_number | text |  |
| contract_type | contract_type |  |
| status | employment_status |  |
| hired_at | date |  |
| terminated_at | date |  |
| base_salary_monthly | numeric |  |
| bank_account | text |  |
| tax_number | text |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_hr.employee_department

| Column | Type | PK |
|---|---|---|
| emp_dept_id | int8 | ✔ |
| employee_id | int8 |  |
| department_id | int8 |  |
| role | text |  |
| start_date | date |  |
| end_date | date |  |
| is_primary | bool |  |

### mcms_hr.leave_request

| Column | Type | PK |
|---|---|---|
| leave_id | int8 | ✔ |
| employee_id | int8 |  |
| leave_type | leave_type |  |
| start_date | date |  |
| end_date | date |  |
| days_off | int4 |  |
| reason | text |  |
| status | leave_status |  |
| approved_by | int8 |  |
| approved_at | timestamptz |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_hr.payroll_item

| Column | Type | PK |
|---|---|---|
| item_id | int8 | ✔ |
| period_id | int8 |  |
| employee_id | int8 |  |
| base_amount | numeric |  |
| overtime_amount | numeric |  |
| deduction_amount | numeric |  |
| bonus_amount | numeric |  |
| net_amount | numeric |  |
| is_paid | bool |  |
| paid_at | timestamptz |  |
| created_at | timestamptz |  |

### mcms_hr.payroll_period

| Column | Type | PK |
|---|---|---|
| period_id | int8 | ✔ |
| code | text |  |
| start_date | date |  |
| end_date | date |  |
| status | pay_status |  |
| closed_at | timestamptz |  |
| created_at | timestamptz |  |

### mcms_hr.shift

| Column | Type | PK |
|---|---|---|
| shift_id | int8 | ✔ |
| department_id | int8 |  |
| employee_id | int8 |  |
| shift_type | shift_type |  |
| start_at | timestamptz |  |
| end_at | timestamptz |  |
| created_at | timestamptz |  |

## mcms_icu — ICU


### mcms_icu.admission

| Column | Type | PK |
|---|---|---|
| admission_id | int8 | ✔ |
| encounter_id | int8 |  |
| patient_id | int8 |  |
| mrn | text |  |
| bed_id | int8 |  |
| primary_physician_id | int8 |  |
| attending_nurse_id | int8 |  |
| status | icu_status |  |
| admit_diagnosis | text |  |
| admit_reason | text |  |
| admitted_at | timestamptz |  |
| discharged_at | timestamptz |  |
| discharge_destination | text |  |
| expired_at | timestamptz |  |
| notes | text |  |

### mcms_icu.bed

| Column | Type | PK |
|---|---|---|
| bed_id | int8 | ✔ |
| room_code | text |  |
| bed_label | text |  |
| department_id | int8 |  |
| level | int4 |  |
| status | bed_status |  |
| has_ventilator | bool |  |
| has_dialysis | bool |  |
| is_isolation | bool |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_icu.bed_stay

| Column | Type | PK |
|---|---|---|
| stay_id | int8 | ✔ |
| admission_id | int8 |  |
| bed_id | int8 |  |
| assigned_at | timestamptz |  |
| released_at | timestamptz |  |

### mcms_icu.score

| Column | Type | PK |
|---|---|---|
| score_id | int8 | ✔ |
| admission_id | int8 |  |
| type | text |  |
| raw | int4 |  |
| computed_value | numeric |  |
| interpretation | text |  |
| assessed_at | timestamptz |  |
| assessed_by | int8 |  |

### mcms_icu.support_session

| Column | Type | PK |
|---|---|---|
| session_id | int8 | ✔ |
| admission_id | int8 |  |
| support_kind | support_kind |  |
| started_at | timestamptz |  |
| stopped_at | timestamptz |  |
| parameters | jsonb |  |
| stopped_reason | text |  |

### mcms_icu.vitals_stream

| Column | Type | PK |
|---|---|---|
| stream_id | int8 | ✔ |
| admission_id | int8 |  |
| patient_id | int8 |  |
| recorded_at | timestamptz |  |
| charted_by | int8 |  |
| temp_c | numeric |  |
| hr_bpm | int4 |  |
| rr_pm | int4 |  |
| sbp_mmhg | int4 |  |
| dbp_mmhg | int4 |  |
| mbp_mmhg | int4 |  |
| spo2_pct | numeric |  |
| etco2_mmhg | int4 |  |
| cvp_cmh2o | int4 |  |
| urine_ml_hour | int4 |  |
| gcs | int4 |  |
| pupils | text |  |
| notes | text |  |

## mcms_lab — Laboratory


### mcms_lab.lab_order

| Column | Type | PK |
|---|---|---|
| order_id | int8 | ✔ |
| order_no | text |  |
| encounter_id | int8 |  |
| patient_id | int8 |  |
| mrn | text |  |
| requested_by | int8 |  |
| order_priority | order_priority |  |
| panel_id | int8 |  |
| clinical_indication | text |  |
| requested_at | timestamptz |  |

### mcms_lab.result

| Column | Type | PK |
|---|---|---|
| result_id | int8 | ✔ |
| sample_id | int8 |  |
| test_id | int8 |  |
| value_text | text |  |
| value_numeric | numeric |  |
| unit | text |  |
| ref_range | text |  |
| flag | result_flag |  |
| analysed_by | int8 |  |
| analysed_at | timestamptz |  |
| verified_by | int8 |  |
| verified_at | timestamptz |  |
| rejected_at | timestamptz |  |
| rejected_reason | text |  |
| created_at | timestamptz |  |

### mcms_lab.sample

| Column | Type | PK |
|---|---|---|
| sample_id | int8 | ✔ |
| sample_no | text |  |
| lab_order_id | int8 |  |
| test_ids | _int8 |  |
| specimen_type | specimen_type |  |
| volume_collected | numeric |  |
| collected_at | timestamptz |  |
| collected_by | int8 |  |
| received_at | timestamptz |  |
| received_by | int8 |  |
| status | sample_status |  |
| rejected_reason | text |  |

### mcms_lab.test_catalog

| Column | Type | PK |
|---|---|---|
| test_id | int8 | ✔ |
| loinc_code | text |  |
| name | text |  |
| category | text |  |
| specimen_type | specimen_type |  |
| volume_required | numeric |  |
| unit | text |  |
| ref_low | numeric |  |
| ref_high | numeric |  |
| turnaround_minutes | int4 |  |
| is_active | bool |  |
| created_at | timestamptz |  |

### mcms_lab.test_panel

| Column | Type | PK |
|---|---|---|
| panel_id | int8 | ✔ |
| code | text |  |
| name | text |  |
| created_at | timestamptz |  |

### mcms_lab.test_panel_item

| Column | Type | PK |
|---|---|---|
| ppi_id | int8 | ✔ |
| panel_id | int8 |  |
| test_id | int8 |  |
| sort_order | int4 |  |

## mcms_nursery — Nursery/Neonatal


### mcms_nursery.cot

| Column | Type | PK |
|---|---|---|
| cot_id | int8 | ✔ |
| code | text |  |
| name | text |  |
| department_id | int8 |  |
| is_incubator | bool |  |
| has_phototherapy | bool |  |
| status | cot_status |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_nursery.growth_entry

| Column | Type | PK |
|---|---|---|
| entry_id | int8 | ✔ |
| neonate_id | int8 |  |
| recorded_at | timestamptz |  |
| weight_g | int4 |  |
| length_cm | numeric |  |
| head_circ_cm | numeric |  |
| temperature_c | numeric |  |
| feeding_type | text |  |
| feed_volume_ml | int4 |  |
| nurse_user_id | int8 |  |
| notes | text |  |

### mcms_nursery.neonate_record

| Column | Type | PK |
|---|---|---|
| neonate_id | int8 | ✔ |
| patient_id | int8 |  |
| mother_party_id | int8 |  |
| cot_id | int8 |  |
| gestational_age_weeks | numeric |  |
| birth_weight_g | int4 |  |
| apgar_1min | int4 |  |
| apgar_5min | int4 |  |
| admitted_at | timestamptz |  |
| discharged_at | timestamptz |  |
| notes | text |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

## mcms_physio — Physiotherapy


### mcms_physio.session

| Column | Type | PK |
|---|---|---|
| session_id | int8 | ✔ |
| plan_id | int8 |  |
| patient_id | int8 |  |
| therapist_user_id | int8 |  |
| therapy_id | int8 |  |
| room_id | int8 |  |
| sessions_in_seq | int4 |  |
| scheduled_at | timestamptz |  |
| duration_minutes | int4 |  |
| pain_before_score | int4 |  |
| pain_after_score | int4 |  |
| rom_before | text |  |
| rom_after | text |  |
| subjective | text |  |
| interventions | text |  |
| status | session_status |  |
| started_at | timestamptz |  |
| completed_at | timestamptz |  |
| notes | text |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_physio.therapy_catalog

| Column | Type | PK |
|---|---|---|
| therapy_id | int8 | ✔ |
| code | text |  |
| name | text |  |
| type | therapy_type |  |
| body_region | text |  |
| duration_minutes | int4 |  |
| equipment | _text |  |
| is_active | bool |  |
| created_at | timestamptz |  |

### mcms_physio.treatment_plan

| Column | Type | PK |
|---|---|---|
| plan_id | int8 | ✔ |
| patient_id | int8 |  |
| encounter_id | int8 |  |
| therapist_user_id | int8 |  |
| diagnosis | text |  |
| treatment_goals | text |  |
| sessions_planned | int4 |  |
| sessions_completed | int4 |  |
| frequency | text |  |
| starts_on | date |  |
| ends_on | date |  |
| status | plan_status |  |
| notes | text |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

## mcms_rad — Radiology


### mcms_rad.exam_catalog

| Column | Type | PK |
|---|---|---|
| exam_id | int8 | ✔ |
| snomed_code | text |  |
| name | text |  |
| body_part | text |  |
| default_modality | modality_type |  |
| contrast_used | bool |  |
| duration_minutes | int4 |  |
| created_at | timestamptz |  |

### mcms_rad.image_instance

| Column | Type | PK |
|---|---|---|
| image_id | int8 | ✔ |
| study_id | int8 |  |
| series_number | int4 |  |
| instance_number | int4 |  |
| sop_instance_uid | text |  |
| image_type | image_type |  |
| storage_uri | text |  |
| rows | int4 |  |
| columns | int4 |  |
| bits_allocated | int4 |  |
| created_at | timestamptz |  |

### mcms_rad.modality_suite

| Column | Type | PK |
|---|---|---|
| suite_id | int8 | ✔ |
| department_id | int8 |  |
| code | text |  |
| name | text |  |
| modality | modality_type |  |
| is_active | bool |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_rad.study_request

| Column | Type | PK |
|---|---|---|
| study_id | int8 | ✔ |
| accession_no | text |  |
| encounter_id | int8 |  |
| patient_id | int8 |  |
| mrn | text |  |
| exam_id | int8 |  |
| suite_id | int8 |  |
| requested_by | int8 |  |
| priority | order_priority |  |
| clinical_indication | text |  |
| status | study_status |  |
| scheduled_at | timestamptz |  |
| started_at | timestamptz |  |
| completed_at | timestamptz |  |
| image_count | int4 |  |
| radiation_dose_msv | numeric |  |
| contrast_data | jsonb |  |
| findings | text |  |
| impression | text |  |
| reported_by | int8 |  |
| reported_at | timestamptz |  |
| verified_by | int8 |  |
| verified_at | timestamptz |  |
| cancelled_reason | text |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

## mcms_rx — Pharmacy


### mcms_rx.administration

| Column | Type | PK |
|---|---|---|
| administer_id | int8 | ✔ |
| patient_id | int8 |  |
| med_order_id | int8 |  |
| drug_item_id | int8 |  |
| dose_given | text |  |
| dose_at | timestamptz |  |
| administered_by | int8 |  |
| witnessed_by | int8 |  |
| site | text |  |
| notes | text |  |

### mcms_rx.dispensation

| Column | Type | PK |
|---|---|---|
| dispensation_id | int8 | ✔ |
| patient_id | int8 |  |
| mrn | text |  |
| encounter_id | int8 |  |
| med_order_id | int8 |  |
| drug_item_id | int8 |  |
| lot_id | int8 |  |
| quantity | int4 |  |
| dispensed_at | timestamptz |  |
| dispensed_by | int8 |  |
| instructions | text |  |
| notes | text |  |

### mcms_rx.drug_alternative

| Column | Type | PK |
|---|---|---|
| alternative_id | int8 | ✔ |
| drug_item_id | int8 |  |
| alt_drug_item_id | int8 |  |
| reason | text |  |
| is_generic_equiv | bool |  |
| created_at | timestamptz |  |

### mcms_rx.drug_interaction

| Column | Type | PK |
|---|---|---|
| interaction_id | int8 | ✔ |
| drug_item_id_a | int8 |  |
| drug_item_id_b | int8 |  |
| severity | interaction_severity |  |
| mechanism | text |  |
| clinical_effect | text |  |
| management | text |  |
| source_ref | text |  |
| created_at | timestamptz |  |

### mcms_rx.drug_item

| Column | Type | PK |
|---|---|---|
| drug_item_id | int8 | ✔ |
| generic_name | text |  |
| brand_name | text |  |
| drug_class | drug_class |  |
| form | text |  |
| strength | text |  |
| unit | text |  |
| atc_code | text |  |
| controlled_substance | bool |  |
| requires_cold_chain | bool |  |
| manufacturer | text |  |
| reorder_level | int4 |  |
| reorder_qty | int4 |  |
| is_active | bool |  |
| cost_per_unit | numeric |  |
| sale_price_per_unit | numeric |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |
| rxnorm_code | text |  |

### mcms_rx.drug_lot

| Column | Type | PK |
|---|---|---|
| lot_id | int8 | ✔ |
| drug_item_id | int8 |  |
| lot_number | text |  |
| received_qty | int4 |  |
| on_hand_qty | int4 |  |
| manufactured_on | date |  |
| expires_on | date |  |
| received_at | timestamptz |  |
| supplier_party_id | int8 |  |
| purchase_order_id | int8 |  |
| unit_cost | numeric |  |
| status | lot_status |  |

### mcms_rx.stock_movement

| Column | Type | PK |
|---|---|---|
| movement_id | int8 | ✔ |
| drug_item_id | int8 |  |
| lot_id | int8 |  |
| movement_type | move_type |  |
| qty_delta | int4 |  |
| balance_after | int4 |  |
| related_movement_id | int8 |  |
| reason | text |  |
| performed_by | int8 |  |
| performed_at | timestamptz |  |

## mcms_surgical — Surgical


### mcms_surgical.intra_op_vitals

| Column | Type | PK |
|---|---|---|
| iov_id | int8 | ✔ |
| surgery_id | int8 |  |
| recorded_at | timestamptz |  |
| recorded_by | int8 |  |
| hr_bpm | int4 |  |
| sbp_mmhg | int4 |  |
| dbp_mmhg | int4 |  |
| spo2_pct | numeric |  |
| etco2_mmhg | int4 |  |
| anaesthesia_depth | int4 |  |
| temp_c | numeric |  |
| urine_ml | int4 |  |
| notes | text |  |

### mcms_surgical.operating_room

| Column | Type | PK |
|---|---|---|
| or_id | int8 | ✔ |
| department_id | int8 |  |
| code | text |  |
| name | text |  |
| room_type | text |  |
| status | or_status |  |
| is_active | bool |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_surgical.post_op_note

| Column | Type | PK |
|---|---|---|
| pon_id | int8 | ✔ |
| surgery_id | int8 |  |
| written_at | timestamptz |  |
| written_by | int8 |  |
| recovery_room | text |  |
| pain_score | int4 |  |
| findings | text |  |
| instructions | text |  |
| follow_up_days | int4 |  |
| is_signed | bool |  |
| signed_at | timestamptz |  |

### mcms_surgical.pre_op_checklist

| Column | Type | PK |
|---|---|---|
| poc_id | int8 | ✔ |
| surgery_id | int8 |  |
| fasting_confirmed | bool |  |
| consent_signed | bool |  |
| site_marked | bool |  |
| antibiotics_given | bool |  |
| iv_secured | bool |  |
| labs_checked | bool |  |
| imaging_checked | bool |  |
| risk_score | text |  |
| checklist_by | int8 |  |
| completed_at | timestamptz |  |
| created_at | timestamptz |  |

### mcms_surgical.procedure_catalog

| Column | Type | PK |
|---|---|---|
| proc_cat_id | int8 | ✔ |
| cpt_code | text |  |
| name | text |  |
| body_site | text |  |
| default_duration_min | int4 |  |
| notes | text |  |
| created_at | timestamptz |  |

### mcms_surgical.surgery

| Column | Type | PK |
|---|---|---|
| surgery_id | int8 | ✔ |
| operation_no | text |  |
| encounter_id | int8 |  |
| patient_id | int8 |  |
| or_id | int8 |  |
| surgeon_user_id | int8 |  |
| anaesthetist_user_id | int8 |  |
| primary_dept_id | int8 |  |
| procedure_id | int8 |  |
| laterality | text |  |
| status | surg_status |  |
| scheduled_at | timestamptz |  |
| incision_at | timestamptz |  |
| closure_at | timestamptz |  |
| patient_in_or_at | timestamptz |  |
| patient_out_or_at | timestamptz |  |
| anaesthesia_type | text |  |
| blood_loss_ml | int4 |  |
| tourniquet_time_minutes | int4 |  |
| complications | text |  |
| notes | text |  |
| created_at | timestamptz |  |
| updated_at | timestamptz |  |

### mcms_surgical.surgical_team

| Column | Type | PK |
|---|---|---|
| surg_team_id | int8 | ✔ |
| surgery_id | int8 |  |
| user_id | int8 |  |
| role | team_role |  |
| joined_at | timestamptz |  |
| left_at | timestamptz |  |