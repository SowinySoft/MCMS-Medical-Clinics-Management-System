import { useEffect, useState } from "react";
import { mcmsApi } from "../api";
import { useTranslation } from "react-i18next";

// Reports hub — calls each RBAC-gated /api/reports/ endpoint and renders the
// result as cards/tables. Sections fail gracefully (403 → hidden) per RBAC.
const SECTIONS = [
  { key: "financial_summary", type: "kv", title: "Financial Summary" },
  { key: "patient_census", type: "kv", title: "Patient Census" },
  { key: "pharmacy_dispense", type: "table", title: "Pharmacy Dispense Log" },
  { key: "emergency_acuity", type: "table", title: "ER Acuity (ESI)" },
  { key: "diagnosis_volume", type: "table", title: "Diagnosis Volume" },
  { key: "event_activity", type: "table", title: "Event-Store Activity" },
] as const;

export function Reports() {
  const { t } = useTranslation();
  const [data, setData] = useState<Record<string, any>>({});
  const [denied, setDenied] = useState<Record<string, boolean>>({});

  useEffect(() => {
    (async () => {
      const out: Record<string, any> = {};
      const dny: Record<string, boolean> = {};
      await Promise.all(
        SECTIONS.map(async (s) => {
          try {
            const { data } = await mcmsApi.get(`/reports/${s.key}/`);
            out[s.key] = data;
          } catch (e: any) {
            if (e.response?.status === 403) dny[s.key] = true;
          }
        })
      );
      setData(out);
      setDenied(dny);
    })();
    // eslint-disable-next-line
  }, []);

  return (
    <div style={styles.wrap}>
      <h2 style={styles.h2}>{t("Reports")}</h2>
      <div style={styles.grid}>
        {SECTIONS.map((s) => (
          <div key={s.key} style={styles.card}>
            <div style={styles.cardTitle}>{s.title}</div>
            {denied[s.key] ? (
              <div style={{ color: "#f85149", fontSize: 13 }}>{t("forbidden")}</div>
            ) : !data[s.key] ? (
              <div style={{ color: "#6e7681" }}>…</div>
            ) : s.type === "kv" ? (
              <div style={styles.kv}>
                {Object.entries(data[s.key]).map(([k, v]) => (
                  <div key={k} style={styles.kvRow}>
                    <span style={styles.kvKey}>{k}</span>
                    <span style={styles.kvVal}>{String(v)}</span>
                  </div>
                ))}
              </div>
            ) : (
              <table style={styles.table}>
                <thead>
                  <tr>{Object.keys(data[s.key][0] || {}).map((c) => <th key={c} style={styles.th}>{c}</th>)}</tr>
                </thead>
                <tbody>
                  {data[s.key].map((r: any, i: number) => (
                    <tr key={i}>{Object.values(r).map((v: any, j: number) => <td key={j} style={styles.td}>{String(v)}</td>)}</tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

const styles: any = {
  wrap: { padding: 24 },
  h2: { color: "#e6edf3", marginBottom: 16 },
  grid: { display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(360px, 1fr))", gap: 16 },
  card: { background: "#161b22", border: "1px solid #30363d", borderRadius: 10, padding: 16 },
  cardTitle: { fontWeight: 700, color: "#58a6ff", marginBottom: 12 },
  kv: {},
  kvRow: { display: "flex", justifyContent: "space-between", padding: "4px 0", borderBottom: "1px solid #21262d", fontSize: 13 },
  kvKey: { color: "#8b949e" },
  kvVal: { color: "#e6edf3", fontWeight: 600 },
  table: { width: "100%", borderCollapse: "collapse", fontSize: 12 },
  th: { textAlign: "start", color: "#8b949e", padding: "4px 6px", borderBottom: "1px solid #30363d" },
  td: { padding: "4px 6px", borderBottom: "1px solid #21262d", color: "#c9d1d9" },
};
