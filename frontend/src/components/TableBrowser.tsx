import { mcmsApi } from "../api";
import { useEffect, useState } from "react";
import { useTranslation } from "react-i18next";
import { MODEL_LABELS } from "../schemas";
import { useToast } from "../toast";

// Generic data browser with richer CRUD:
//  - dynamic form from DRF OPTIONS metadata
//  - required-field validation, numeric/boolean coercion
//  - delete with confirmation
//  - real pagination (page state -> API ?page=)
//  - loading / empty / error states + toasts
const PAGE = 25;

export function TableBrowser({ schema, model }: { schema: string; model: string }) {
  const { t } = useTranslation();
  const toast = useToast();
  const [rows, setRows] = useState<any[]>([]);
  const [count, setCount] = useState(0);
  const [page, setPage] = useState(1);
  const [cols, setCols] = useState<string[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [meta, setMeta] = useState<Record<string, any> | null>(null);
  const [editing, setEditing] = useState<any | null>(null);
  const [form, setForm] = useState<Record<string, any>>({});
  const [confirmDel, setConfirmDel] = useState<any | null>(null);

  const label = MODEL_LABELS[`${schema}/${model}`]?.en || `${schema}/${model}`;
  const pkField = `${model.replace(/s$/, "")}_id`;

  const load = async (pg = 1) => {
    setLoading(true); setError("");
    try {
      const { data } = await mcmsApi.list(schema, model, { page: pg });
      setCount(data.count); setRows(data.results); setPage(pg);
      if (data.results[0]) setCols(Object.keys(data.results[0]).slice(0, 8));
    } catch (e: any) {
      setError(e.response?.status === 403 ? t("forbidden") : "Error");
    } finally { setLoading(false); }
  };

  const loadMeta = async () => {
    try { const res = await mcmsApi.options(`/${schema}/${model}/`); setMeta(res.data.actions?.POST || {}); }
    catch {}
  };

  useEffect(() => { setMeta(null); setEditing(null); setConfirmDel(null); load(); loadMeta(); /* eslint-disable-next-line */ }, [schema, model]);

  const openCreate = () => {
    const init: Record<string, any> = {};
    if (meta) for (const k of Object.keys(meta)) if (!meta[k].read_only) init[k] = meta[k].type === "boolean" ? false : "";
    setForm(init); setEditing({ _new: true });
  };

  const openEdit = (row: any) => {
    const init: Record<string, any> = {};
    if (meta) for (const k of Object.keys(meta)) if (!meta[k].read_only) init[k] = row[k] ?? (meta[k].type === "boolean" ? false : "");
    setForm(init); setEditing(row);
  };

  const coerce = (f: any, v: any) => {
    if (f.type === "integer" || f.type === "number" || f.type === "decimal")
      return v === "" ? null : Number(v);
    if (f.type === "boolean") return Boolean(v);
    return v;
  };

  const submit = async (e: any) => {
    e.preventDefault();
    // required-field validation
    for (const [k, f] of Object.entries(meta || {})) {
      if ((f as any).required && !(f as any).read_only && (form[k] === "" || form[k] == null)) {
        toast.show(`${k} ${t("is required") || "is required"}`, "err"); return;
      }
    }
    try {
      if (editing._new) { await mcmsApi.post(`/${schema}/${model}/`, form); toast.show(t("created") || "Created"); }
      else { await mcmsApi.patch(`/${schema}/${model}/${editing[pkField]}/`, form); toast.show(t("updated") || "Updated"); }
      setEditing(null); load(page);
    } catch (err: any) {
      const detail = err.response?.data ? JSON.stringify(err.response.data).slice(0, 200) : err.message;
      toast.show("Error: " + detail, "err");
    }
  };

  const doDelete = async () => {
    try { await mcmsApi.del(`/${schema}/${model}/${confirmDel[pkField]}/`); toast.show(t("deleted") || "Deleted"); setConfirmDel(null); load(page); }
    catch (err: any) { toast.show("Error: " + (err.response?.status || err.message), "err"); }
  };

  const fieldType = (f: any) => {
    if (f.type === "integer" || f.type === "number" || f.type === "decimal") return "number";
    if (f.type === "boolean") return "checkbox";
    if (f.type === "datetime" || f.type === "date") return "datetime-local";
    return "text";
  };

  return (
    <div style={{ padding: 24 }}>
      <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
        <div style={{ fontSize: 18, fontWeight: 700, color: "var(--text)" }}>{label} <span style={{ color: "var(--text-dim)", fontWeight: 400, fontSize: 14 }}>({count})</span></div>
        <button className="mcms-btn mcms-no-print" onClick={openCreate} disabled={!meta}>+ {t("New")}</button>
      </div>

      {error && <div className="mcms-error">{error}</div>}
      {loading && <div className="mcms-spinner" />}
      {!loading && !error && rows.length === 0 && <div className="mcms-empty">{t("noData")}</div>}

      {editing && meta && (
        <form style={formGrid} onSubmit={submit}>
          <div style={{ gridColumn: "1 / -1", fontWeight: 700, color: "var(--text)" }}>{editing._new ? t("Create") : t("edit")} {label}</div>
          {Object.entries(meta).filter(([, f]: any) => !f.read_only).map(([k, f]: any) => (
            <label key={k} style={{ display: "flex", flexDirection: "column", gap: 4 }}>
              <span style={{ fontSize: 12, color: "var(--text-dim)" }}>{k}{(f as any).required ? " *" : ""}</span>
              <input
                className="mcms-input"
                type={fieldType(f)}
                checked={fieldType(f) === "checkbox" ? !!form[k] : undefined}
                value={fieldType(f) === "checkbox" ? undefined : form[k]}
                onChange={(e) => setForm({ ...form, [k]: coerce(f, fieldType(f) === "checkbox" ? e.target.checked : e.target.value) })}
              />
            </label>
          ))}
          <div style={{ gridColumn: "1 / -1", display: "flex", gap: 8 }}>
            <button type="submit" className="mcms-btn">{t("Save")}</button>
            <button type="button" className="mcms-btn" style={{ background: "var(--panel-2)", color: "var(--text)" }} onClick={() => setEditing(null)}>{t("Cancel")}</button>
          </div>
        </form>
      )}

      {confirmDel && (
        <div style={overlay}>
          <div className="mcms-card" style={{ maxWidth: 340 }}>
            <div style={{ marginBottom: 12, color: "var(--text)" }}>{t("confirmDelete")}</div>
            <div style={{ display: "flex", gap: 8 }}>
              <button className="mcms-btn" style={{ background: "var(--danger)" }} onClick={doDelete}>{t("delete")}</button>
              <button className="mcms-btn" style={{ background: "var(--panel-2)", color: "var(--text)" }} onClick={() => setConfirmDel(null)}>{t("Cancel")}</button>
            </div>
          </div>
        </div>
      )}

      {!loading && !error && rows.length > 0 && !editing && (
        <>
          <table style={{ width: "100%", borderCollapse: "collapse", fontSize: 13 }}>
            <thead>
              <tr>{cols.map((c) => <th key={c} style={th}>{c}</th>)}<th style={th}></th></tr>
            </thead>
            <tbody>
              {rows.map((r, i) => (
                <tr key={i} style={{ borderBottom: "1px solid var(--border)" }}>
                  {cols.map((c) => <td key={c} style={{ padding: 8, color: "var(--text)" }}>{String(r[c]).slice(0, 60)}</td>)}
                  <td style={{ padding: 8 }}>
                    <button className="mcms-btn" style={{ background: "transparent", color: "var(--accent)", padding: "2px 8px" }} onClick={() => openEdit(r)}>{t("edit")}</button>
                    <button className="mcms-btn" style={{ background: "transparent", color: "var(--danger)", padding: "2px 8px", marginInlineStart: 6 }} onClick={() => setConfirmDel(r)}>{t("delete")}</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
          <div style={{ marginTop: 14, display: "flex", gap: 8, alignItems: "center" }}>
            <button className="mcms-btn" style={{ background: "var(--panel-2)", color: "var(--text)" }} disabled={page <= 1} onClick={() => load(page - 1)}>‹</button>
            <span style={{ color: "var(--text-dim)" }}>p{page} / {Math.max(1, Math.ceil(count / PAGE))}</span>
            <button className="mcms-btn" style={{ background: "var(--panel-2)", color: "var(--text)" }} disabled={page * PAGE >= count} onClick={() => load(page + 1)}>›</button>
          </div>
        </>
      )}
    </div>
  );
}

const formGrid: any = { background: "var(--panel)", border: "1px solid var(--border)", borderRadius: 10, padding: 16, marginBottom: 16, display: "grid", gridTemplateColumns: "1fr 1fr", gap: 12 };
const th: any = { textAlign: "start", background: "var(--panel)", color: "var(--text-dim)", padding: 8, borderBottom: "1px solid var(--border)" };
const overlay: any = { position: "fixed", inset: 0, background: "rgba(0,0,0,0.5)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 500 };
