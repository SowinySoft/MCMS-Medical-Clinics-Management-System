-- ============================================================
-- MCMS · 03 · HR
-- Human resources — departments, employees (party_role), shifts,
-- attendance, payroll refs, leave.  Other schemas FK to department_id.
-- ============================================================

BEGIN;

-- ---------- Clinical & Admin Departments ----------
-- One row per organizational unit (surgery theatre, ER, ICU bay group,
-- pharmacy, lab, radiology, physio hall, front-desk, billing office...).
CREATE TABLE mcms_hr.department (
   department_id        BIGSERIAL PRIMARY KEY,
   code                 TEXT NOT NULL UNIQUE,
   name                 TEXT NOT NULL,
   parent_department_id BIGINT REFERENCES mcms_hr.department(department_id),
   kind                 TEXT NOT NULL CHECK (kind IN (
      'clinic','surgical','emergency','icu','lab','radiology','pharmacy',
      'physio','billing','hr','administration','maintenance','housekeeping','other'
   )),
   head_user_id         BIGINT REFERENCES mcms_core.app_user(user_id),
   location_building    TEXT,
   location_floor       INT,
   is_active            BOOLEAN NOT NULL DEFAULT TRUE,
   created_at           timestamptz NOT NULL DEFAULT now(),
   updated_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_hr.department (parent_department_id);
CREATE INDEX ON mcms_hr.department (kind);

-- ---------- Employees ----------
-- Every employee is also a party in mcms_core (single source of truth for identity).
CREATE TYPE mcms_hr.employment_status AS ENUM ('active','suspended','terminated','retired','on_leave');
CREATE TYPE mcms_hr.contract_type AS ENUM ('permanent','temporary','contract','consultant','locum');

CREATE TABLE mcms_hr.employee (
   employee_id          BIGSERIAL PRIMARY KEY,
   party_id             BIGINT NOT NULL UNIQUE REFERENCES mcms_core.party(party_id) ON DELETE CASCADE,
   user_id              BIGINT REFERENCES mcms_core.app_user(user_id),
   employee_no          TEXT NOT NULL UNIQUE,
   primary_department_id BIGINT NOT NULL REFERENCES mcms_hr.department(department_id),
   role                 TEXT NOT NULL,                       -- 'Surgeon', 'Nurse Manager' ...
   job_title            TEXT,
   specialisation       TEXT,
   license_number        TEXT,                               -- medical/board licence
   contract_type        mcms_hr.contract_type NOT NULL DEFAULT 'permanent',
   status               mcms_hr.employment_status NOT NULL DEFAULT 'active',
   hired_at             DATE NOT NULL,
   terminated_at        DATE,
   base_salary_monthly  NUMERIC(10,2) CHECK (base_salary_monthly >= 0),
   bank_account         TEXT,
   tax_number           TEXT,
   created_at           timestamptz NOT NULL DEFAULT now(),
   updated_at           timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_hr.employee (primary_department_id);
CREATE INDEX ON mcms_hr.employee (status);

-- ---------- Employee ↔ Department (multi-department assignment) ----------
CREATE TABLE mcms_hr.employee_department (
   emp_dept_id           BIGSERIAL PRIMARY KEY,
   employee_id           BIGINT NOT NULL REFERENCES mcms_hr.employee(employee_id) ON DELETE CASCADE,
   department_id         BIGINT NOT NULL REFERENCES mcms_hr.department(department_id) ON DELETE CASCADE,
   role                  TEXT NOT NULL,
   start_date            DATE NOT NULL,
   end_date              DATE,
   is_primary           BOOLEAN NOT NULL DEFAULT FALSE,
   UNIQUE (employee_id, department_id, start_date),
   CHECK ((end_date IS NULL) OR (end_date >= start_date))
);
CREATE INDEX ON mcms_hr.employee_department (department_id);
CREATE INDEX ON mcms_hr.employee_department (employee_id);

-- ---------- Shifts ----------
CREATE TYPE mcms_hr.shift_type AS ENUM ('morning','evening','night','on_call','split');

CREATE TABLE mcms_hr.shift (
   shift_id           BIGSERIAL PRIMARY KEY,
   department_id      BIGINT NOT NULL REFERENCES mcms_hr.department(department_id) ON DELETE CASCADE,
   employee_id        BIGINT NOT NULL REFERENCES mcms_hr.employee(employee_id) ON DELETE CASCADE,
   shift_type         mcms_hr.shift_type NOT NULL,
   start_at           timestamptz NOT NULL,
   end_at             timestamptz NOT NULL CHECK (end_at > start_at),
   created_at         timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON mcms_hr.shift (department_id, start_at);
CREATE INDEX ON mcms_hr.shift (employee_id);

-- ---------- Attendance ----------
CREATE TYPE mcms_hr.attendance_status AS ENUM ('present','absent','late','leave','overtime');

CREATE TABLE mcms_hr.attendance (
   attendance_id     BIGSERIAL PRIMARY KEY,
   employee_id        BIGINT NOT NULL REFERENCES mcms_hr.employee(employee_id) ON DELETE CASCADE,
   shift_id           BIGINT REFERENCES mcms_hr.shift(shift_id),
   clock_in_at        timestamptz,
   clock_out_at      timestamptz,
   status             mcms_hr.attendance_status NOT NULL DEFAULT 'present',
   note               TEXT,
   created_at         timestamptz NOT NULL DEFAULT now(),
   CHECK (clock_out_at IS NULL OR clock_in_at IS NULL OR clock_out_at > clock_in_at)
);
CREATE INDEX ON mcms_hr.attendance (employee_id, clock_in_at DESC);

-- ---------- Leave requests ----------
CREATE TYPE mcms_hr.leave_status AS ENUM ('pending','approved','rejected','cancelled');
CREATE TYPE mcms_hr.leave_type AS ENUM ('annual','sick','maternity','paternity','compassion','unpaid','sabbatical');

CREATE TABLE mcms_hr.leave_request (
   leave_id            BIGSERIAL PRIMARY KEY,
   employee_id         BIGINT NOT NULL REFERENCES mcms_hr.employee(employee_id) ON DELETE CASCADE,
   leave_type          mcms_hr.leave_type NOT NULL,
   start_date          DATE NOT NULL,
   end_date            DATE NOT NULL,
   days_off            INT NOT NULL,
   reason              TEXT,
   status              mcms_hr.leave_status NOT NULL DEFAULT 'pending',
   approved_by         BIGINT REFERENCES mcms_core.app_user(user_id),
   approved_at         timestamptz,
   created_at          timestamptz NOT NULL DEFAULT now(),
   updated_at          timestamptz NOT NULL DEFAULT now(),
   CHECK (end_date >= start_date)
);
CREATE INDEX ON mcms_hr.leave_request (employee_id);
CREATE INDEX ON mcms_hr.leave_request (status);

-- ---------- Payroll ----------
CREATE TYPE mcms_hr.pay_status AS ENUM ('draft','approved','paid','cancelled');

CREATE TABLE mcms_hr.payroll_period (
   period_id         BIGSERIAL PRIMARY KEY,
   code              TEXT NOT NULL UNIQUE,           -- '2026-07'
   start_date        DATE NOT NULL,
   end_date          DATE NOT NULL CHECK (end_date > start_date),
   status            mcms_hr.pay_status NOT NULL DEFAULT 'draft',
   closed_at         timestamptz,
   created_at        timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE mcms_hr.payroll_item (
   item_id            BIGSERIAL PRIMARY KEY,
   period_id          BIGINT NOT NULL REFERENCES mcms_hr.payroll_period(period_id) ON DELETE CASCADE,
   employee_id        BIGINT NOT NULL REFERENCES mcms_hr.employee(employee_id) ON DELETE CASCADE,
   base_amount        NUMERIC(10,2) NOT NULL CHECK (base_amount >= 0),
   overtime_amount   NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (overtime_amount >= 0),
   deduction_amount  NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (deduction_amount >= 0),
   bonus_amount      NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (bonus_amount >= 0),
   net_amount        NUMERIC(10,2) GENERATED ALWAYS AS (base_amount + overtime_amount + bonus_amount - deduction_amount) STORED,
   is_paid           BOOLEAN NOT NULL DEFAULT FALSE,
   paid_at           timestamptz,
   created_at        timestamptz NOT NULL DEFAULT now(),
   UNIQUE (period_id, employee_id)
);
CREATE INDEX ON mcms_hr.payroll_item (period_id);
CREATE INDEX ON mcms_hr.payroll_item (employee_id);

-- ---------- Hire event ----------
CREATE OR REPLACE FUNCTION mcms_hr.fn_employee_hire_event()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
   PERFORM mcms_core.emit_event('employee_hired','info', NULL, NEW.party_id,
       'mcms_hr','employee', NEW.employee_id,
       jsonb_build_object('employee_no', NEW.employee_no,
                          'role', NEW.role, 'department_id', NEW.primary_department_id));
   RETURN NEW;
END$$;
-- safer: emit on first INSERT
CREATE TRIGGER trg_employee_hire AFTER INSERT ON mcms_hr.employee
FOR EACH ROW EXECUTE FUNCTION mcms_hr.fn_employee_hire_event();

CREATE TRIGGER trg_dept_touch BEFORE UPDATE ON mcms_hr.department
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER trg_emp_touch BEFORE UPDATE ON mcms_hr.employee
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();
CREATE TRIGGER trg_leave_touch BEFORE UPDATE ON mcms_hr.leave_request
FOR EACH ROW EXECUTE FUNCTION mcms_core.fn_touch();

COMMIT;
