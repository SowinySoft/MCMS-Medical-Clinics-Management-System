// Dedicated Monitors page (Phase 5 follow-up): expands the compact
// Dashboard health strip into a full operational-monitoring view.
// Pulls /system/monitors/ (admin.all only) and shows every signal.
import { useEffect, useState } from "react";
import { mcmsApi } from "../api";
import { useAuth } from "../useAuth";
import { useTranslation } from "react-i18next";

function fmtUptime(s: number) {
  const d = Math.floor(s / 86400);
  const h = Math.floor((s % 86400) / 3600);
  const m = Math.floor((s % 3600) / 60);
  return `${d}d ${h}h ${m}m`;
}

export function Monitors() {
  const { hasPerm } = useAuth();
  const { t } = useTranslation();
  const [h, setH] = useState<any>(null);
  const [err, setErr] = useState<string>("");

  const load = () => {
    mcmsApi.get("/system/monitors/")
      .then(({ data }) => { setH(data); setErr(""); })
      .catch((e) => setErr(e?.response?.data?.detail || t("noData")));
  };

  useEffect(() => {
    let alive = true;
    const tick = () => { if (alive) load(); };
    tick();
    const id = setInterval(tick, 15000);
    return () => { alive = false; clearInterval(id); };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  if (!hasPerm("admin.all")) return <div style={{ padding: 24 }}>{t("forbidden")}</div>;
  if (err) return <div style={{ padding: 24, color: "var(--danger)" }}>{err}</div>;
  if (!h) return <div style={{ padding: 24, opacity: 0.6 }}>{t("loading")}</div>;

  const ok = (b: boolean) => (b ? "#3fb950" : "#d29922");
  const Card = ({ title, value, good }: { title: string; value: any; good?: boolean }) => (
    <div style={card}>
      <div style={{ fontSize: 12, opacity: 0.7 }}>{title}</div>
      <div style={{ fontSize: 26, fontWeight: 800, color: good === undefined ? "var(--text)" : ok(good), marginTop: 6 }}>
        {value}
      </div>
    </div>
  );

  return (
    <div style={{ padding: 24, maxWidth: 1000, margin: "0 auto" }}>
      <div style={{ display: "flex", alignItems: "center", justifyContent: "space-between" }}>
        <h2 style={{ margin: 0 }}>📡 {t("monitors")}</h2>
        <button style={btn} onClick={load}>↻ {t("refresh")}</button>
      </div>
      <div style={{ fontSize: 12, opacity: 0.6, margin: "4px 0 18px" }}>
        {t("lastUpdated")}: {new Date(h.at).toLocaleTimeString()}
      </div>

      <div style={grid}>
        <Card title={t("systemStatus")} value={h.status === "ok" ? `✅ ${t("ok")}` : `⚠ ${t("warn")}`} good={h.status === "ok"} />
        <Card title={t("dbSize")} value={`${h.db_size_mb} MB`} />
        <Card title={t("activeConnections")} value={h.active_connections} />
        <Card title={t("totalTables")} value={h.total_tables} />
        <Card title={t("replication")} value={h.replication} good={h.replication === "active" || h.replication === "standalone"} />
        <Card title={t("longRunningQueries")} value={h.long_running_queries} good={h.long_running_queries === 0} />
        <Card title={t("unusedIndexes")} value={h.unused_indexes} />
        <Card title={t("eventRateHour")} value={`${h.event_rate_per_hour}/h`} />
        <Card title={t("eventRate24h")} value={`${h.event_rate_24h_avg}/h`} />
        <Card title={t("uptime")} value={fmtUptime(h.uptime_seconds)} />
      </div>

      {h.maintenance_mode && (
        <div style={{ marginTop: 16, color: "#d29922", border: "1px solid #d29922", borderRadius: 8, padding: 10 }}>
          ⚠ {t("maintenanceMode")}
        </div>
      )}
    </div>
  );
}

const card: any = {
  background: "var(--panel)", border: "1px solid var(--border)", borderRadius: 10, padding: 16,
};
const grid: any = {
  display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(180px, 1fr))", gap: 14,
};
const btn: any = {
  background: "var(--panel-2)", color: "var(--text)", border: "1px solid var(--border)",
  borderRadius: 6, padding: "6px 12px", cursor: "pointer", fontSize: 13,
};
