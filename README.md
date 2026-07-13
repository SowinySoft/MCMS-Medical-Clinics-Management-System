# MCMS — Medical Clinics Management System

A comprehensive, ERP-architected, **event-driven** medical clinics management system built on **PostgreSQL 18** with a **schema-grouped design**. Web front-end will use **Python Django**. This repository ships the **PostgreSQL backend** (DDL + seed + reporting views + smoke tests) and the **schema diagram**.

## Architecture Overview

| Layer | Implementation |
|---|---|
| **Persistence** | PostgreSQL 18.4 — 13 namespaces (`mcms_*` schemas) — 78 base tables — 187 FKs |
| **Domain events** | Single append-only `mcms_core.event_log` with monotonic sequence + `pg_notify()` fan-out per channel (`mcms`, `mcms_inventory`, `mcms_critical`) |
| **Audit** | `mcms_core.audit_trail` + 50 triggers that emit events on state transitions |
| **Reporting** | 16 cross-cutting views (`v_patient_360`, `v_ed_board`, `v_surgery_board`, `v_bed_board`, `v_low_stock`, `v_tat`, `v_event_feed`, `v_invoice_aging`…) |
| **Front-end** | Django 5+ (to be wired next) |

## Departments Covered (clinical & ERP)

- **EMR** (`mcms_emr`) — patients, encounters, diagnoses (ICD-10), vitals, allergies, immunizations, clinical notes, family/social history, medication orders
- **Clinic / Outpatient** (`mcms_clinic`) — appointments, walk-in queue, consultations (SOAP), clinic rooms
- **Surgical / Operating Rooms** (`mcms_surgical`) — OR allocation, surgery scheduling, surgical teams, pre-op checklist, intra-op vitals, post-op notes
- **Emergency Department** (`mcms_emergency`) — ESI triage, trauma alerts, resuscitation events, ED beds
- **Pharmacy** (`mcms_rx`) — drug catalog (28-class ATC), lots with auto-decrement on dispense, dispensations, administrations, stock movements, low-stock alerts, expired-lot quarantine
- **Laboratory** (`mcms_lab`) — test catalog (LOINC), panels, lab orders (panel-based), sample collection, results with critical flag routing to `mcms_critical` channel
- **Radiology** (`mcms_rad`) — modality suites (10 modalities), exam catalog, study request → report workflow, DICOM image instances
- **ICU** (`mcms_icu`) — bed registry, admissions with auto bed-status, vitals stream, support sessions (mechanical ventilation / ECMO / RRT), ICU scores (APACHE II, GCS, SOFA, RASS), deterioration auto-alert
- **Physiotherapy** (`mcms_physio`) — therapy catalog, treatment plans with auto-completion, sessions, pain/ROM before/after
- **Human Resources** (`mcms_hr`) — departments, employees, multi-department assignment, shifts, attendance, leave requests, payroll periods/items with auto-computed net
- **Billing & Insurance** (`mcms_billing`) — service price list, invoices with auto-compute totals & auto-paid status, payments (6 methods), insurance claims workflow
- **ERP** (`mcms_erp`) — General Ledger accounts, non-drug inventory (consumables, instruments, capital), purchase orders + GRN receipt with auto-stock-up, suppliers (party role), inter-department stock movements

## File Layout

```
D:\MCMS\
├─ install.sql                 # master install (loads all module files in dep order)
├─ sql\
│  ├─ 00_schemas.sql           # 13 namespace declarations
│  ├─ 01_core.sql              # party, address, contact, app_user, lookup, event_log, audit_trail
│  ├─ 02_emr.sql               # patient, encounter, diagnosis, vitals, allergies, notes, med orders
│  ├─ 03_hr.sql                # department, employee, shift, attendance, leave, payroll
│  ├─ 04_clinic.sql            # room, appointment, queue, consultation (SOAP)
│  ├─ 05_surgical.sql          # operating_room, surgery, team, pre/post-op notes, intra-op vitals
│  ├─ 06_emergency.sql         # triage, resuscitation, ed_bed
│  ├─ 07_rx.sql                # drug_item, drug_lot, dispensation, administration, stock_movement
│  ├─ 08_lab.sql               # test_catalog, panel, lab_order, sample, result
│  ├─ 09_rad.sql               # modality_suite, exam_catalog, study_request, image_instance
│  ├─ 10_icu.sql               # bed, admission, bed_stay, vitals_stream, support_session, score
│  ├─ 11_physio.sql            # therapy_catalog, treatment_plan, session
│  ├─ 12_billing.sql           # service_price, invoice, invoice_line, payment, insurance_claim
│  ├─ 13_erp.sql               # gl_account, inventory_item, inventory_stock, supplier,
│  │                           #   purchase_order, goods_receipt, stock_movement
│  ├─ 14_views.sql             # 16 reporting views
│  ├─ 90_seed.sql              # reference data (24 departments, 20 ICD-10, 19 CPT, 15 drugs,
│  │                           #   15 services, 10 physio therapies, 15 lab tests, 15 panels,
│  │                           #   4 ORs, 5 modality suites, 6 imaging exams, 20 GL accounts)
│  ├─ 99_links.sql             # cross-schema FK patches (encounter→dept, dispensation→patient.mrn ...)
│  └─ tests\
│     └─ smoke_e2e.sql         # end-to-end test covering the entire patient journey
└─ docs\
   ├─ erd_schema_diagram.html  # interactive Mermaid ERD (open in any browser)
   └─ erd_schema_diagram.mmd   # raw Mermaid source
```

## Install

```bash
# 1) Prereq: PostgreSQL 16+ running on 127.0.0.1:5432, role `postgres` w/ known password.
# 2) Create database and load everything:
PGPASSWORD=postgres psql -U postgres -h 127.0.0.1 -p 5432 \
  -c "CREATE DATABASE mcms ENCODING 'UTF8' LC_COLLATE 'C' LC_CTYPE 'C' TEMPLATE template0;"
PGPASSWORD=postgres psql -U postgres -h 127.0.0.1 -p 5432 -d mcms \
  -v ON_ERROR_STOP=1 -f install.sql

# 3) (Optional) add an ICU bed then run the end-to-end smoke test:
PGPASSWORD=postgres psql -U postgres -h 127.0.0.1 -p 5432 -d mcms \
  -c "INSERT INTO mcms_icu.bed (room_code, bed_label, department_id, level, status, has_ventilator) \
      VALUES ('ICU-A','ICU-A1', \
      (SELECT department_id FROM mcms_hr.department WHERE code='ICU-GEN'), 3, 'available', true);"
PGPASSWORD=postgres psql -U postgres -h 127.0.0.1 -p 5432 -d mcms \
  -v ON_ERROR_STOP=1 -f sql/tests/smoke_e2e.sql
```

Verified working against **PostgreSQL 18.4** on Windows 11.

## Event-Driven Model Proof

After running the smoke test, `mcms_core.event_log` contains:

| # | event kind              | severity | channel          | source_table    |
|---|-------------------------|----------|------------------|-----------------|
| 1 | employee_hired          | info     | mcms             | employee        |
| 2 | encounter_opened       | info     | mcms             | encounter       |
| 3 | diagnosis_recorded     | info     | mcms             | diagnosis       |
| 4 | triage_recorded        | info     | mcms             | triage          |
| 5 | prescription_issued    | info     | mcms             | medication_order|
| 6 | medication_dispensed  | info     | mcms             | dispensation    |
| 7 | low_stock_alert       | warning  | mcms_inventory   | drug_item       |
| 8 | lab_order_placed      | info     | mcms             | lab_order       |
| 9-11 | surgery_scheduled / started / completed| info | mcms | surgery |
| 12| icu_admit             | warning  | mcms             | admission       |
| 13| deterioration_alert   | critical | **mcms_critical**| vitals_stream   |
| 14| icu_discharge         | info     | mcms             | admission       |

State machine side-effects verified:
- Pharmacy lot decremented from 200 → 170 (lot_id match).
- OR status: `available` → `busy` (on `patient_in_or`) → `cleaning` (on completed).
- ICU bed: `available` → `occupied` (auto bed_stay insert) → `cleaning` (on discharge).
- Critical channel listening: any `severity='critical'` event routes to `mcms_critical` NOTIFY channel.

## Reporting Views

| View | Purpose |
|---|---|
| `mcms_emr.v_patient_360` | One row per patient with comorbidity / allergy / latest encounter |
| `mcms_emr.v_encounter_timeline` | All encounters, attending clinician, dept duration |
| `mcms_emr.v_daily_census` | Per-day per-department census |
| `mcms_emergency.v_ed_board` | Live ED board with minutes-in-ED, ESI, GCS |
| `mcms_surgical.v_surgery_board` | Pending/in-progress OR pipeline |
| `mcms_icu.v_bed_board` | Live ICU bed board |
| `mcms_rx.v_low_stock` | Drugs at/below reorder with expiring lots |
| `mcms_lab.v_tat` | Lab turnaround time (avg, p50, p95) by test |
| `mcms_rad.v_study_pipeline` | Radiology study queue |
| `mcms_billing.v_revenue_by_dept` | Revenue by department + service type |
| `mcms_billing.v_invoice_aging` | Outstanding invoices aging buckets |
| `mcms_billing.v_patient_ledger` | Consolidated charge-per-item |
| `mcms_core.v_event_feed` | System-wide event log join |
| `mcms_hr.v_payroll_summary` | Payroll summary by period and department |
| `mcms_physio.v_session_throughput` | Physio session throughput |
| `mcms_erp.v_department_stock` | ERP stock per department |

## Integrity

After install: 13 schemas + 78 tables + 16 views + 260 indexes + 50 triggers + 187 FK + 56 enums + 28 PL/pgSQL functions. Zero FK violations; zero orphan patient/encounter/diagnosis records after smoke test.

## Next Phase

1. Django project scaffold + `manage.py inspectdb` to materialize models.
2. GraphQL/DRF API layer exposing the reporting views + event subscription (LISTEN/NOTIFY via WebSockets/async).
3. Schema-grouped admin & resource tree (sidebar `mcms_*` groups with tables nested — like the SFAS_TUI design philosophy).
