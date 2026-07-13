import { useEffect, useState } from "react";
import { mcmsApi } from "../api";
import { useTranslation } from "react-i18next";
import { BarChart } from "./BarChart";
import { useToast } from "../toast";

// Reports hub — RBAC-gated sections with shared date-range filter,
// SVG charts for aggregations, CSV export and print.
const SECTIONS = [
  { key: "financial_summary", title: "Financial Summary", type: "kv" },
  { key: "revenue_by_department", title: "Revenue by Department", type: "bar", labelKey: "department", valueKey: "revenue" },
  { key: "patient_census", title: "Patient Census", type: "kv" },
  { key: "pharmacy_dispense", title: "Pharmacy Dispense Log", type: "table", limit: 50 },
  { key: "emergency_acuity", title: "ER Acuity (ESI)", type: "bar", labelKey: "esi_level", valueKey: "triages" },
  { key: "er_wait_times", title: "ER Wait Times", type: "table" },
  { key: "diagnosis_volume", title: "Diagnosis Volume", type: "bar", labelKey: "domain", valueKey: "orders" },
  { key: "top_diagnoses", title: "Top Diagnoses", type: "bar", labelKey: "condition_desc", valueKey: "count" },
  { key: "inventory_valuation", title: "Inventory Valuation", type: "table" },
  { key: "event_activity", title: "Event-Store Activity", type: "bar", labelKey: "kind", valueKey: "events" },
] as const;

export function Reports() {
  const { t } = useTranslation();
  const toast = useToast();
  const [since, setSince] = useState("");
  const [until, setUntil] = useState("");
  const [data, setData] = useState<Record<string, any>>({});
  const [denied, setDenied] = useState<Record<string, boolean>>({});
  const [loading, setLoading] = useState(true);

  const fetchAll = async () => {
    setLoading(true);
    const params = new URLSearchParams();
    if (since) params.set("since", since);
    if (until) params.set("until", until);
    const qs = params.toString() ? `?${params}` : "";
    const out: Record<string, any> = {}; const dny: Record<string, boolean> = {};
    await Promise.all(SECTIONS.map(async (s) => {
      try { const { data } = await mcmsApi.get(`/reports/${s.key}/${qs}`); out[s.key] = data; }
      catch (e: any) { if (e.response?.status === 403) dny[s.key] = true; }
    }));
    setData(out); setDenied(dny); setLoading(false);
  };

  useEffect(() => { fetchAll(); /* eslint-disable-next-line */ }, []);

  const exportCsv = (key: string, rows: any[]) => {
    if (!rows.length) return;
    const cols = Object.keys(rows[0]);
    const csv = [cols.join(",")].concat(rows.map((r) => cols.map((c) => `"${String(r[c]).replace(/"/g, '""')}"`).join(","))).join("\n");
    const blob = new Blob([csv], { type: "text/csv" });
    const a = document.createElement("a"); a.href = URL.createObjectURL(blob);
    a.download = `${key}.csv`; a.click(); toast.show(t("export") || "Export");
  };

  return (
    <div style={{ padding: 24 }}>
      <div className="mcms-no-print" style={{ display: "flex", alignItems: "center", gap: 12, marginBottom: 16, flexWrap: "wrap" }}>
        <h2 style={{ color: "var(--text)", margin: 0, marginInlineEnd: "auto" }}>{t("Reports")}</h2>
        <label style={{ color: "var(--text-dim)", fontSize: 12 }}>{t("from")}<input className="mcms-input" type="date" value={since} onChange={(e) => setSince(e.target.value)} style={{ width: "auto", marginInlineStart: 6 }} /></label>
        <label style={{ color: "var(--text-dim)", fontSize: 12 }}>{t("to")}<input className="mcms-input" type="date" value={until} onChange={(e) => setUntil(e.target.value)} style={{ width: "auto", marginInlineStart: 6 }} /></label>
        <button className="mcms-btn" onClick={fetchAll}>{t("Search") || "Apply"}</button>
        <button className="mcms-btn" style={{ background: "var(--panel-2)", color: "var(--text)" }} onClick={() => window.print()}>{t("print")}</button>
      </div>

      {loading && <div className="mcms-spinner" />}

      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(380px, 1fr))", gap: 16 }}>
        {SECTIONS.map((s) => (
          <div key={s.key} className="mcms-card">
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div style={{ fontWeight: 700, color: "var(--accent)", marginBottom: 8 }}>{s.title}</div>
              {Array.isArray(data[s.key]) && data[s.key].length > 0 &&
                <button className="mcms-btn mcms-no-print" style={{ background: "var(--panel-2)", color: "var(--text)", fontSize: 11, padding: "2px 8px" }} onClick={() => exportCsv(s.key, data[s.key])}>{t("export")}</button>}
            </div>
            {denied[s.key] ? <div style={{ color: "var(--danger)", fontSize: 13 }}>{t("forbidden")}</div>
              : !data[s.key] ? <div className="mcms-empty">{t("loading")}</div>
              : s.type === "kv" ? (
                <div>
                  {Object.entries(data[s.key]).map(([k, v]) => (
                    <div key={k} style={{ display: "flex", justifyContent: "space-between", padding: "4px 0", borderBottom: "1px solid var(--border)", fontSize: 13 }}>
                      <span style={{ color: "var(--text-dim)" }}>{k}</span><span style={{ color: "var(--text)", fontWeight: 600 }}>{String(v)}</span>
                    </div>))}
                </div>)
              : s.type === "bar" ? (
                <BarChart data={(data[s.key] as any[]).map((r: any) => ({ label: String(r[(s as any).labelKey]), value: r[(s as any).valueKey] }))} />)
              : (
                <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
                  <thead><tr>{Object.keys((data[s.key][0] || {})).map((c) => <th key={c} style={th}>{c}</th>)}</tr></thead>
                  <tbody>{(data[s.key] as any[]).map((r: any, i: number) => (
                    <tr key={i}>{Object.values(r).map((v: any, j: number) => <td key={j} style={{ padding: "4px 6px", borderBottom: "1px solid var(--border)", color: "var(--text)" }}>{String(v)}</td>)}</tr>))}</tbody>
                </table>)
            }
          </div>
        ))}
      </div>
    </div>
  );
}

const th: any = { textAlign: "start", color: "var(--text-dim)", padding: "4px 6px", borderBottom: "1px solid var(--border)" };
