import { useEventFeed, type FeedEvent } from "../useEventFeed";
import { useTranslation } from "react-i18next";

// Live event feed panel — consumes the WebSocket stream from mcms_core.event_log.
export function LiveFeed() {
  const { t } = useTranslation();
  const { events, connected } = useEventFeed([]);

  return (
    <div style={styles.panel}>
      <div style={styles.header}>
        <span>🔔 {t("liveFeed")}</span>
        <span style={{ color: connected ? "#3fb950" : "#8b949e", fontSize: 12 }}>
          {connected ? "● live" : "○ offline"}
        </span>
      </div>
      <div style={styles.list}>
        {events.length === 0 && <div style={styles.empty}>{t("noEvents")}</div>}
        {events.map((e: FeedEvent) => (
          <div key={e.seq} style={styles.item}>
            <span style={{ ...styles.badge, background: sevColor(e.severity) }}>{e.kind}</span>
            <span style={styles.meta}>{e.source_schema}.{e.source_table}</span>
            <span style={styles.time}>{new Date(e.occurred_at).toLocaleTimeString()}</span>
          </div>
        ))}
      </div>
    </div>
  );
}

const sevColor = (s: string) =>
  ({ critical: "#f85149", warning: "#d29922", info: "#1f6feb", error: "#f85149" }[s] || "#30363d");

const styles: any = {
  panel: { background: "#161b22", border: "1px solid #30363d", borderRadius: 10, padding: 12, height: "100%" },
  header: { display: "flex", justifyContent: "space-between", fontWeight: 700, marginBottom: 10 },
  list: { overflowY: "auto", maxHeight: "calc(100vh - 160px)" },
  item: { display: "flex", gap: 8, alignItems: "center", padding: "6px 4px", borderBottom: "1px solid #21262d", fontSize: 12 },
  badge: { color: "#fff", borderRadius: 4, padding: "2px 6px", fontSize: 11, fontWeight: 600 },
  meta: { color: "#9aa4ad" },
  time: { marginInlineStart: "auto", color: "#6e7681" },
  empty: { color: "#6e7681", fontStyle: "italic", padding: 12 },
};
