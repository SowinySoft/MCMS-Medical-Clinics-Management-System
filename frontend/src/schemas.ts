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
    schemas: ["emr", "clinic", "emergency", "icu", "physio", "dialysis", "nursery", "telemed", "referral"], perm: "emr.read" },
  { key: "diagnosis", label: { en: "Diagnosis", ar: "التشخيص" }, icon: "🔬",
    schemas: ["lab", "rad", "surgical", "terminology", "ai"], perm: "lab_rad.result" },
  { key: "pharma", label: { en: "Pharmaceuticals & Pharmacy", ar: "الصيدلية والأدوية" }, icon: "💊",
    schemas: ["rx"], perm: "pharmacy.dispense" },
  { key: "mgmt", label: { en: "Management & Support", ar: "الإدارة والدعم" }, icon: "⚙️",
    schemas: ["billing", "erp", "hr", "payer"], perm: "billing.read" },
  { key: "reporting", label: { en: "Reporting & Localization", ar: "التقارير والتعريب" }, icon: "📊",
    schemas: ["core", "identity", "fhir", "hl7v2", "vital_records"], perm: "admin.all" },
];

// Friendly labels for every domain table (used by the table browser title).
// Generated from the live schema — see model_labels.ts.
export { MODEL_LABELS } from "./model_labels";
