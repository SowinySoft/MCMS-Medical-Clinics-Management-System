import { useEffect, useState } from "react";
import { mcmsApi } from "../api";

// Compact live system-health strip for the Dashboard (sysadmin only).
// Pulls /system/monitors/ — db size, event rate, replication, long queries.
export function SystemHealth() {
  const [h, setH] = useState<any>(null);
  useEffect(() => {
    let alive = true;
    const load = () => {
      mcmsApi.get("/system/monitors/").then(({ data }) => alive && setH(data)).catch(() => {});
    };
    load();
    const id = setInterval(load, 15000);
    return () => { alive = false; clearInterval(id); };
  }, []);

  if (!h) return null;
  const dot = (ok: boolean) => ({
    width: 8, height: 8, borderRadius: "50%", background: ok ? "#3fb950" : "#d29922", display: "inline-block", marginInlineEnd: 6,
  });
  return (
    <div style={{ display: "flex", gap: 18, flexWrap: "wrap", margin: "0 0 18px", padding: 12,
      background: "var(--panel)", border: "1px solid var(--border)", borderRadius: 10, fontSize: 12 }}>
      <span><span style={dot(h.status === "ok")} />System {h.status}</span>
      <span>DB <b>{h.db_size_mb} MB</b></span>
      <span>Events <b>{h.event_rate_per_hour}/h</b> (24h avg {h.event_rate_24h_avg})</span>
      <span>Replication <b style={{ color: h.replication === "active" ? "#3fb950" : "#d29922" }}>{h.replication}</b></span>
      <span>Long queries <b style={{ color: h.long_running_queries ? "#d29922" : "#3fb950" }}>{h.long_running_queries}</b></span>
      <span>Unused indexes <b>{h.unused_indexes}</b></span>
      {h.maintenance_mode && <span style={{ color: "#d29922" }}>⚠ Maintenance mode</span>}
    </div>
  );
}
