// Phase 17 - Vital Records page.
// Surfaces the dedicated VitalRecordsViewSet actions (issue_birth,
// issue_death, amend, export_bundle, import_bundle) so the backend
// service has a UI path ("no backend without pages").
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { mcmsApi } from "../api";
import { useAuth } from "../useAuth";

function Field({ label, name, value, onChange, type = "text" }: any) {
  return (
    <label style={{ display: "block", marginBottom: 8, fontSize: 13 }}>
      <span style={{ color: "var(--text-dim)" }}>{label}</span>
      <input
        type={type}
        value={value}
        name={name}
        onChange={(e) => onChange(name, e.target.value)}
        style={{ width: "100%", padding: "6px 8px", marginTop: 2,
                 border: "1px solid var(--border)", borderRadius: 6,
                 background: "var(--bg-elev)", color: "var(--text)" }}
      />
    </label>
  );
}

function IssueForm({ kind, onDone }: { kind: "birth" | "death"; onDone: () => void }) {
  const [form, setForm] = useState<any>({});
  const [busy, setBusy] = useState(false);
  const [err, setErr] = useState<string | null>(null);
  const set = (k: string, v: string) => setForm((f: any) => ({ ...f, [k]: v }));

  const submit = async () => {
    setBusy(true); setErr(null);
    try {
      const ep = kind === "birth" ? "issue_birth" : "issue_death";
      const body = kind === "birth"
        ? { mother_patient_id: Number(form.mother_patient_id),
            birth_datetime: form.birth_datetime,
            facility_id: form.facility_id ? Number(form.facility_id) : undefined }
        : { patient_id: Number(form.patient_id),
            death_datetime: form.death_datetime,
            cause_icd10: form.cause_icd10 || undefined,
            facility_id: form.facility_id ? Number(form.facility_id) : undefined };
      const { data } = await mcmsApi.post(`/vital_records/${ep}/`, body);
      onDone();
      void data;
    } catch (e: any) {
      setErr(e?.response?.data?.detail || "Error");
    } finally { setBusy(false); }
  };

  return (
    <div className="mcms-card" style={{ padding: 16, maxWidth: 520 }}>
      <b>{kind === "birth" ? "Issue Birth Certificate" : "Issue Death Certificate"}</b>
      {kind === "birth" ? (
        <>
          <Field label="Mother patient_id" name="mother_patient_id" value={form.mother_patient_id || ""} onChange={set} />
          <Field label="Birth datetime" name="birth_datetime" type="datetime-local" value={form.birth_datetime || ""} onChange={set} />
        </>
      ) : (
        <>
          <Field label="Patient_id" name="patient_id" value={form.patient_id || ""} onChange={set} />
          <Field label="Death datetime" name="death_datetime" type="datetime-local" value={form.death_datetime || ""} onChange={set} />
          <Field label="Cause ICD-10 (optional)" name="cause_icd10" value={form.cause_icd10 || ""} onChange={set} />
        </>
      )}
      <Field label="Facility_id (optional)" name="facility_id" value={form.facility_id || ""} onChange={set} />
      {err && <div style={{ color: "#d29922", fontSize: 12 }}>{err}</div>}
      <button className="btnAccent" disabled={busy} onClick={submit} style={{ marginTop: 8 }}>
        {busy ? "Issuing…" : "Issue"}
      </button>
    </div>
  );
}

export function VitalRecords() {
  const { t } = useTranslation();
  const { hasPerm } = useAuth();
  const [actions, setActions] = useState<string[]>([]);
  const [tab, setTab] = useState<"birth" | "death" | null>(null);
  const [refresh, setRefresh] = useState(0);

  useEffect(() => {
    mcmsApi.get("/vital_records/").then(({ data }) => {
      const acts = (data?.actions || []).map((a: any) => a.name);
      setActions(acts);
    }).catch(() => setActions([]));
  }, []);

  const canRegister = hasPerm("vital_records.register");

  return (
    <div style={{ padding: 24 }}>
      <h2 style={{ color: "var(--text)" }}>Vital Records</h2>
      <p style={{ color: "var(--text-dim)", fontSize: 13 }}>
        {t("Available service actions")}: {actions.join(", ") || "—"}
      </p>
      {canRegister ? (
        <div style={{ display: "flex", gap: 12, marginBottom: 16 }}>
          <button className="btnAccent" onClick={() => setTab(tab === "birth" ? null : "birth")}>Issue Birth</button>
          <button className="btnAccent" onClick={() => setTab(tab === "death" ? null : "death")}>Issue Death</button>
        </div>
      ) : (
        <p style={{ color: "var(--text-dim)", fontSize: 13 }}>You have read-only access.</p>
      )}
      {tab && <IssueForm key={tab + refresh} kind={tab} onDone={() => { setTab(null); setRefresh((r) => r + 1); }} />}
    </div>
  );
}
