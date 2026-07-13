import { mcmsApi } from "../api";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { MODEL_LABELS } from "../schemas";

// Generic data browser — lists any /api/<schema>/<model>/ endpoint with
// pagination. RBAC is enforced server-side; a 403 surfaces a friendly message.
export function TableBrowser({ schema, model }: { schema: string; model: string }) {
  const { t } = useTranslation();
  const [rows, setRows] = useState<any[]>([]);
  const [count, setCount] = useState(0);
  const [page, setPage] = useState(1);
  const [cols, setCols] = useState<string[]>([]);
  const [error, setError] = useState("");

  useEffect(() => {
    setError(""); setRows([]); setPage(1);
    (async () => {
      try {
        const { data } = await mcmsApi.list(schema, model, { page: 1 });
        setCount(data.count);
        setRows(data.results);
        if (data.results[0]) setCols(Object.keys(data.results[0]).slice(0, 8));
      } catch (e: any) {
        setError(e.response?.status === 403 ? t("forbidden") : "Error");
      }
    })();
  }, [schema, model]);

  const label = MODEL_LABELS[`${schema}/${model}`]?.en || `${schema}/${model}`;

  return (
    <div style={styles.wrap}>
      <div style={styles.title}>{label} <span style={styles.count}>({count})</span></div>
      {error && <div style={{ color: "#f85149" }}>{error}</div>}
      {!error && rows.length === 0 && <div style={{ color: "#6e7681" }}>No rows.</div>}
      {!error && rows.length > 0 && (
        <table style={styles.table}>
          <thead>
            <tr>{cols.map((c) => <th key={c} style={styles.th}>{c}</th>)}</tr>
          </thead>
          <tbody>
            {rows.map((r, i) => (
              <tr key={i}>
                {cols.map((c) => <td key={c} style={styles.td}>{String(r[c]).slice(0, 60)}</td>)}
              </tr>
            ))}
          </tbody>
        </table>
      )}
      <div style={styles.pager}>
        <button disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>‹</button>
        <span style={{ margin: "0 8px" }}>p{page}</span>
        <button disabled={page * 25 >= count} onClick={() => setPage((p) => p + 1)}>›</button>
      </div>
    </div>
  );
}

const styles: any = {
  wrap: { padding: 24 },
  title: { fontSize: 18, fontWeight: 700, color: "#e6edf3", marginBottom: 16 },
  count: { color: "#8b949e", fontWeight: 400, fontSize: 14 },
  table: { width: "100%", borderCollapse: "collapse", fontSize: 13 },
  th: { textAlign: "start", background: "#161b22", color: "#8b949e", padding: 8, borderBottom: "1px solid #30363d" },
  td: { padding: 8, borderBottom: "1px solid #21262d", color: "#c9d1d9" },
  pager: { marginTop: 14 },
};
