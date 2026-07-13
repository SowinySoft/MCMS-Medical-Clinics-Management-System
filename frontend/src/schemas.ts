// Schema-group metadata — the 6 macro-units from the design doc, mapping to
// physical schemas. Drives the RBAC-aware, schema-grouped navigation sidebar.
export interface SchemaGroup {
  key: string;
  label: { en: string; ar: string };
  icon: string;
  schemas: string[]; // physical mcms_* app labels
  perm: string;       // required permission code to see this group
}

export const SCHEMA_GROUPS: SchemaGroup[] = [
  { key: "reception", label: { en: "Reception & Appointments", ar: "الاستقبال والمواعيد" }, icon: "📅",
    schemas: ["clinic"], perm: "appointment.manage" },
  { key: "medical", label: { en: "Medical Services", ar: "الخدمات الطبية" }, icon: "🩺",
    schemas: ["emr", "clinic", "emergency", "icu", "physio", "dialysis", "nursery"], perm: "emr.read" },
  { key: "diagnosis", label: { en: "Diagnosis", ar: "التشخيص" }, icon: "🔬",
    schemas: ["lab", "rad", "surgical"], perm: "lab_rad.result" },
  { key: "pharma", label: { en: "Pharmaceuticals & Pharmacy", ar: "الصيدلية والأدوية" }, icon: "💊",
    schemas: ["rx"], perm: "pharmacy.dispense" },
  { key: "mgmt", label: { en: "Management & Support", ar: "الإدارة والدعم" }, icon: "⚙️",
    schemas: ["billing", "erp", "hr"], perm: "billing.read" },
  { key: "reporting", label: { en: "Reporting & Localization", ar: "التقارير والتعريب" }, icon: "📊",
    schemas: ["core"], perm: "patient.read" },
];

// model slug -> friendly label per schema (used by the table browser)
export const MODEL_LABELS: Record<string, { en: string; ar: string }> = {
  "hr/department": { en: "Departments", ar: "الأقسام" },
  "emr/patient": { en: "Patients", ar: "المرضى" },
  "clinic/appointment": { en: "Appointments", ar: "المواعيد" },
  "billing/invoice": { en: "Invoices", ar: "الفواتير" },
  "rx/drug-item": { en: "Drug Items", ar: "الأدوية" },
  "erp/goods-receipt": { en: "Goods Receipts", ar: "إيصالات الاستلام" },
  "lab/lab-order": { en: "Lab Orders", ar: "طلبات المختبر" },
  "rad/exam-catalog": { en: "Radiology Exams", ar: "فحوص الأشعة" },
  "icu/admission": { en: "ICU Admissions", ar: "إدخالات العناية" },
  "surgical/surgery": { en: "Surgeries", ar: "العمليات الجراحية" },
};
