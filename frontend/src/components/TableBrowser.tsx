import { mcmsApi } from "../api";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { MODEL_LABELS } from "../schemas";

// Generic data browser with dynamic CRUD.
// - list: GET /api/<schema>/<model>/
// - create/edit: builds a form from DRF OPTIONS metadata (actions.POST),
//   sending writable fields and letting the backend apply DB defaults.
export function TableBrowser({ schema, model }: { schema: string; model: string }) {
  const { t } = useTranslation();
  const [rows, setRows] = useState<any[]>([]);
  const [count, setCount] = useState(0);
  const [cols, setCols] = useState<string[]>([]);
  const [error, setError] = useState("");
  const [meta, setMeta] = useState<Record<string, any> | null>(null);
  const [editing, setEditing] = useState<any | null>(null);
  const [form, setForm] = useState<Record<string, any>>({});
  const [msg, setMsg] = useState("");

  const label = MODEL_LABELS[`${schema}/${model}`]?.en || `${schema}/${model}`;

  const load = async () => {
    setError("");
    try {
      const { data } = await mcmsApi.list(schema, model, { page: 1 });
      setCount(data.count);
      setRows(data.results);
      if (data.results[0]) setCols(Object.keys(data.results[0]).slice(0, 8));
    } catch (e: any) {
      setError(e.response?.status === 403 ? t("forbidden") : "Error");
    }
  };

  // fetch OPTIONS metadata for the create/edit form
  const loadMeta = async () => {
    try {
      const res = await mcmsApi.options(`/${schema}/${model}/`);
      setMeta(res.data.actions?.POST || {});
    } catch {}
  };

  useEffect(() => {
    setError(""); setRows([]); setMeta(null); setEditing(null);
    load();
    loadMeta();
    // eslint-disable-next-line
  }, [schema, model]);

  const openCreate = () => {
    const init: Record<string, any> = {};
    if (meta) for (const k of Object.keys(meta)) if (!meta[k].read_only) init[k] = "";
    setForm(init);
    setEditing({ _new: true });
    setMsg("");
  };

  const openEdit = (row: any) => {
    const init: Record<string, any> = {};
    if (meta) for (const k of Object.keys(meta)) if (!meta[k].read_only) init[k] = row[k] ?? "";
    setForm(init);
    setEditing(row);
    setMsg("");
  };

  const submit = async (e: any) => {
    e.preventDefault();
    setMsg("");
    try {
      if (editing._new) {
        await mcmsApi.post(`/${schema}/${model}/`, form);
        setMsg("Created ✓");
      } else {
        const id = editing[Object.keys(editing).find((k) => k.endsWith("_id")) || "id"];
        await mcmsApi.patch(`/${schema}/${model}/${id}/`, form);
        setMsg("Updated ✓");
      }
      setEditing(null);
      load();
    } catch (err: any) {
      setMsg("Error: " + JSON.stringify(err.response?.data || err.message).slice(0, 200));
    }
  };

  const fieldType = (f: any) => {
    if (f.type === "integer" || f.type === "number" || f.type === "decimal") return "number";
    if (f.type === "boolean" || f.type === "checkbox") return "checkbox";
    if (f.type === "datetime" || f.type === "date") return "datetime-local";
    return "text";
  };

  return (
    <div style={styles.wrap}>
      <div style={styles.titleBar}>
        <div style={styles.title}>{label} <span style={styles.count}>({count})</span></div>
        <button style={styles.createBtn} onClick={openCreate} disabled={!meta}>+ New</button>
      </div>

      {msg && <div style={{ color: "#3fb950", marginBottom: 8 }}>{msg}</div>}
      {error && <div style={{ color: "#f85149" }}>{error}</div>}

      {editing && meta && (
        <form style={styles.form} onSubmit={submit}>
          <div style={styles.formTitle}>{editing._new ? "Create" : "Edit"} {label}</div>
          {Object.entries(meta).filter(([, f]: any) => !f.read_only).map(([k, f]: any) => (
            <label key={k} style={styles.field}>
              <span style={styles.flabel}>{k}</span>
              <input
                style={styles.input}
                type={fieldType(f)}
                checked={fieldType(f) === "checkbox" ? !!form[k] : undefined}
                value={fieldType(f) === "checkbox" ? undefined : form[k]}
                onChange={(e) => setForm({ ...form, [k]: fieldType(f) === "checkbox" ? e.target.checked : e.target.value })}
              />
            </label>
          ))}
          <div style={{ display: "flex", gap: 8 }}>
            <button type="submit" style={styles.submit}>Save</button>
            <button type="button" style={styles.cancel} onClick={() => setEditing(null)}>Cancel</button>
          </div>
        </form>
      )}

      {!error && rows.length === 0 && !editing && <div style={{ color: "#6e7681" }}>No rows.</div>}
      {!error && rows.length > 0 && !editing && (
        <>
          <table style={styles.table}>
            <thead>
              <tr>{cols.map((c) => <th key={c} style={styles.th}>{c}</th>)}
                <th style={styles.th}></th>
              </tr>
            </thead>
            <tbody>
              {rows.map((r, i) => (
                <tr key={i}>
                  {cols.map((c) => <td key={c} style={styles.td}>{String(r[c]).slice(0, 60)}</td>)}
                  <td style={styles.td}><button style={styles.editBtn} onClick={() => openEdit(r)}>edit</button></td>
                </tr>
              ))}
            </tbody>
          </table>
          <div style={styles.pager}>
            <button disabled={1 <= 1} onClick={() => {}}>‹</button>
            <span style={{ margin: "0 8px" }}>p1</span>
            <button disabled={25 >= count} onClick={() => {}}>›</button>
          </div>
        </>
      )}
    </div>
  );
}

const styles: any = {
  wrap: { padding: 24 },
  titleBar: { display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 },
  title: { fontSize: 18, fontWeight: 700, color: "#e6edf3" },
  count: { color: "#8b949e", fontWeight: 400, fontSize: 14 },
  createBtn: { background: "#1f6feb", color: "#fff", border: "none", borderRadius: 6, padding: "6px 12px", cursor: "pointer" },
  form: { background: "#161b22", border: "1px solid #30363d", borderRadius: 10, padding: 16, marginBottom: 16, display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 },
  formTitle: { gridColumn: "1 / -1", fontWeight: 700, color: "#e6edf3" },
  field: { display: "flex", flexDirection: "column", gap: 4 },
  flabel: { fontSize: 12, color: "#8b949e" },
  input: { padding: 8, borderRadius: 6, border: "1px solid #30363d", background: "#0d1117", color: "#e6edf3" },
  submit: { gridColumn: "1 / -1", background: "#3fb950", color: "#fff", border: "none", borderRadius: 6, padding: 10, cursor: "pointer", fontWeight: 600 },
  cancel: { gridColumn: "1 / -1", background: "#21262d", color: "#e6edf3", border: "1px solid #30363d", borderRadius: 6, padding: 10, cursor: "pointer" },
  table: { width: "100%", borderCollapse: "collapse", fontSize: 13 },
  th: { textAlign: "start", background: "#161b22", color: "#8b949e", padding: 8, borderBottom: "1px solid #30363d" },
  td: { padding: 8, borderBottom: "1px solid #21262d", color: "#c9d1d9" },
  editBtn: { background: "transparent", color: "#58a6ff", border: "none", cursor: "pointer", fontSize: 12 },
  pager: { marginTop: 14 },
};
