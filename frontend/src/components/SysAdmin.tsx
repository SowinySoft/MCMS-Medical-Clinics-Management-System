import { useEffect, useState } from "react";
import { mcmsApi } from "../api";
import { BarChart } from "./BarChart";
import { useToast } from "../toast";

type Tab = "metrics" | "maintenance" | "backups" | "replication" | "sync";
const TABS: { key: Tab; en: string }[] = [
  { key: "metrics", en: "Metrics" },
  { key: "maintenance", en: "Maintenance" },
  { key: "backups", en: "Backups" },
  { key: "replication", en: "Replication" },
  { key: "sync", en: "Sync" },
];

export function SysAdmin() {
  const toast = useToast();
  const [tab, setTab] = useState<Tab>("metrics");
  const [metrics, setMetrics] = useState<any>(null);
  const [busy, setBusy] = useState(false);

  const loadMetrics = async () => {
    try { const { data } = await mcmsApi.get("/system/metrics/"); setMetrics(data); } catch {}
  };
  useEffect(() => { if (tab === "metrics") loadMetrics(); }, [tab]);

  const act = async (body: any, ok: string) => {
    setBusy(true);
    try {
      await mcmsApi.post("/system/maintenance/", body);
      toast.show(ok);
    } catch (e: any) {
      toast.show(e?.response?.data?.detail || "Error", "err");
    } finally { setBusy(false); }
  };

  const triggerBackup = async () => {
    setBusy(true);
    try {
      const { data } = await mcmsApi.post("/system/backups/", {});
      toast.show(`Backup ${data.status} (${(data.size_bytes / 1024).toFixed(0)} KB)`);
    } catch (e: any) {
      toast.show(e?.response?.data?.detail || "Backup failed", "err");
    } finally { setBusy(false); }
  };

  const runSync = async () => {
    setBusy(true);
    try { const { data } = await mcmsApi.post("/system/sync/", {}); toast.show(data.detail || "Synced"); }
    catch (e: any) { toast.show(e?.response?.data?.detail || "Sync failed", "err"); }
    finally { setBusy(false); }
  };

  return (
    <div style={{ padding: 24 }}>
      <h2 style={{ marginTop: 0, color: "var(--text)" }}>System Administration</h2>
      <div style={{ display: "flex", gap: 8, marginBottom: 20, flexWrap: "wrap" }}>
        {TABS.map((x) => (
          <button key={x.key} onClick={() => setTab(x.key)}
            style={{ background: tab === x.key ? "var(--accent)" : "var(--panel-2)",
              color: tab === x.key ? "#fff" : "var(--text)", border: "1px solid var(--border)",
              borderRadius: 6, padding: "6px 14px", cursor: "pointer", fontSize: 13 }}>
            {x.en}
          </button>
        ))}
      </div>

      {tab === "metrics" && (
        <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill,minmax(200px,1fr))", gap: 14 }}>
          {metrics && Object.entries(metrics).filter(([k]) => !["at", "database", "maintenance_mode", "last_schema_sync"].includes(k)).map(([k, v]) => (
            <div key={k} className="mcms-card" style={{ padding: 14, border: "1px solid var(--border)" }}>
              <div style={{ fontSize: 12, color: "var(--text-dim)" }}>{k.replace(/_/g, " ")}</div>
              <div style={{ fontSize: 22, fontWeight: 700, color: "var(--accent)", marginTop: 4 }}>
                {typeof v === "number" ? (Math.round((v as number) * 100) / 100) : String(v)}
              </div>
            </div>
          ))}
          {metrics && (
            <div className="mcms-card" style={{ padding: 14, border: "1px solid var(--border)" }}>
              <div style={{ fontSize: 12, color: "var(--text-dim)" }}>cache hit ratio</div>
              <BarChart data={[
                { label: "hit %", value: metrics.cache_hit_ratio || 0 },
                { label: "miss %", value: 100 - (metrics.cache_hit_ratio || 0) },
              ]} />
            </div>
          )}
        </div>
      )}

      {tab === "maintenance" && (
        <div style={{ display: "flex", flexDirection: "column", gap: 12, maxWidth: 520 }}>
          <Btn label="Run VACUUM ANALYZE (compaction)" disabled={busy} onClick={() => act({ action: "vacuum" }, "Compaction done")} />
          <Btn label="Toggle Maintenance Mode" disabled={busy} onClick={() => act({ action: "toggle_maintenance" }, "Toggled")} />
          <Btn label="Clear Login Lockouts" disabled={busy} onClick={() => act({ action: "clear_lockouts" }, "Lockouts cleared")} />
          <p style={{ color: "var(--text-dim)", fontSize: 12 }}>Maintenance mode, when on, is recorded in mcms_core.system_flag and can gate client access.</p>
        </div>
      )}

      {tab === "backups" && (
        <div style={{ maxWidth: 720 }}>
          <button className="mcms-btn-accent" disabled={busy} onClick={triggerBackup}
            style={{ marginBottom: 14, background: "var(--accent)", color: "#fff", border: "none", borderRadius: 6, padding: "8px 16px", cursor: "pointer" }}>
            {busy ? "Running…" : "Trigger pg_dump Backup"}
          </button>
          <BackupsList />
        </div>
      )}

      {tab === "replication" && <ReplicationPanel />}

      {tab === "sync" && (
        <div style={{ maxWidth: 520 }}>
          <button className="mcms-btn-accent" disabled={busy} onClick={runSync}
            style={{ background: "var(--accent)", color: "#fff", border: "none", borderRadius: 6, padding: "8px 16px", cursor: "pointer", marginBottom: 12 }}>
            {busy ? "Running…" : "Re-apply Migrations (Sync)"}
          </button>
          <p style={{ color: "var(--text-dim)", fontSize: 12 }}>Re-applies Django migrations to keep the reflection layer consistent with models. Last sync is recorded in mcms_core.system_flag.</p>
        </div>
      )}
    </div>
  );
}

function Btn({ label, onClick, disabled }: { label: string; onClick: () => void; disabled?: boolean }) {
  return <button disabled={disabled} onClick={onClick}
    style={{ background: "var(--panel-2)", color: "var(--text)", border: "1px solid var(--border)",
      borderRadius: 6, padding: "10px 14px", cursor: disabled ? "default" : "pointer", fontSize: 13, textAlign: "start" }}>
    {label}
  </button>;
}

function BackupsList() {
  const [rows, setRows] = useState<any[]>([]);
  useEffect(() => {
    mcmsApi.get("/system/backups/").then(({ data }) => setRows(data.backups || [])).catch(() => setRows([]));
  }, []);
  if (!rows.length) return <p style={{ color: "var(--text-dim)" }}>No backups yet.</p>;
  return (
    <table className="mcms-table" style={{ width: "100%", borderCollapse: "collapse", fontSize: 12 }}>
      <thead><tr style={{ color: "var(--text-dim)", textAlign: "start" }}>
        <th>Started</th><th>File</th><th>Size</th><th>Status</th></tr></thead>
      <tbody>
        {rows.map((r) => (
          <tr key={r.backup_id} style={{ borderTop: "1px solid var(--border)" }}>
            <td>{String(r.started_at).slice(0, 19)}</td>
            <td>{r.filename?.split(/[\\/]/).pop()}</td>
            <td>{r.size_bytes ? `${(r.size_bytes / 1024).toFixed(0)} KB` : "—"}</td>
            <td style={{ color: r.status === "ok" ? "#3fb950" : "#f85149" }}>{r.status}</td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}

function ReplicationPanel() {
  const [data, setData] = useState<any>(null);
  useEffect(() => { mcmsApi.get("/system/replication/").then(({ data }) => setData(data)).catch(() => setData(null)); }, []);
  if (!data) return <p style={{ color: "var(--text-dim)" }}>Loading…</p>;
  return (
    <div style={{ maxWidth: 600 }}>
      <div className="mcms-card" style={{ padding: 16, border: "1px solid var(--border)", marginBottom: 12 }}>
        <b>Status:</b> {data.configured ? <span style={{ color: "#3fb950" }}>Replication active</span> : <span style={{ color: "#d29922" }}>Standalone (no replica configured)</span>}
      </div>
      {data.note && <p style={{ color: "var(--text-dim)", fontSize: 12 }}>{data.note}</p>}
      {data.standbys?.length > 0 && (
        <ul style={{ fontSize: 13 }}>{data.standbys.map((s: any, i: number) => <li key={i}>{s.application_name} — {s.state} ({s.sync_state})</li>)}</ul>
      )}
    </div>
  );
}
