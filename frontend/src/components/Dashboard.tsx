import { useAuth } from "../useAuth";
import { mcmsApi } from "../api";
import { useEffect, useState } from "react";
import { LiveFeed } from "./LiveFeed";
import { SystemHealth } from "./SystemHealth";
import { useTranslation } from "react-i18next";
import { MODEL_LABELS } from "../schemas";

// schema (app label) -> READ permission, mirroring the backend router's
// DOMAIN_PERMS (apps/core/routers.py). Used so quick-access chips only show
// tables the user can actually open. (Group-level perms in SCHEMA_GROUPS are
// coarser; per-schema read perms must match the API exactly.)
const SCHEMA_READ_PERM: Record<string, string> = {
  core: "admin.all",
  emr: "emr.read",
  clinic: "appointment.manage",
  hr: "hr.read",
  surgical: "emr.read",
  emergency: "emr.read",
  rx: "pharmacy.dispense",
  lab: "lab_rad.result",
  rad: "lab_rad.result",
  icu: "emr.read",
  physio: "emr.read",
  dialysis: "emr.read",
  nursery: "emr.read",
  billing: "billing.read",
  erp: "inventory.manage",
};

// Dashboard: KPI tiles (live counts from the API) + the live event feed.
export function Dashboard({ onOpen }: { onOpen: (schema: string, model: string) => void }) {
  const { roles, hasPerm } = useAuth();
  const { t } = useTranslation();
  const [kpis, setKpis] = useState<any>(null);

  useEffect(() => {
    (async () => {
      try {
        const [depts, patients, invoices] = await Promise.all([
          mcmsApi.list("hr", "department", { page: 1 }),
          mcmsApi.list("emr", "patient", { page: 1 }),
          mcmsApi.list("billing", "invoice", { page: 1 }),
        ]);
        setKpis({
          departments: depts.data.count,
          patients: patients.data.count,
          invoices: invoices.data.count,
        });
      } catch { /* RBAC may deny */ }
    })();
  }, []);

  const tiles = [
    { label: "Departments", value: kpis?.departments ?? "—", target: ["hr", "department"] },
    { label: "Patients", value: kpis?.patients ?? "—", target: ["emr", "patient"] },
    { label: "Invoices", value: kpis?.invoices ?? "—", target: ["billing", "invoice"] },
  ];

  // quick-access chips: only tables whose schema the user can read
  const chips = Object.entries(MODEL_LABELS).filter(([k]) => {
    const s = k.split("/")[0];
    const perm = SCHEMA_READ_PERM[s];
    return !perm || hasPerm(perm);
  });

  return (
    <div style={styles.grid}>
      <div style={styles.main}>
        <h2 style={styles.h2}>{t("dashboard")}</h2>
        <div style={styles.roles}>Roles: {roles.join(", ") || "—"}</div>
        {hasPerm("admin.all") && <SystemHealth />}
        <div style={styles.tiles}>
          {tiles.map((x) => (
            <button key={x.label} style={styles.tile} onClick={() => onOpen(x.target[0], x.target[1])}>
              <div style={styles.tileVal}>{x.value}</div>
              <div style={styles.tileLabel}>{x.label}</div>
            </button>
          ))}
        </div>
        <h3 style={styles.h3}>Quick access</h3>
        <div style={{ display: "flex", flexWrap: "wrap", gap: 8 }}>
          {chips.map(([k, v]) => {
            const [s, m] = k.split("/");
            return (
              <button key={k} style={styles.chip} onClick={() => onOpen(s, m)}>{v.en}</button>
            );
          })}
        </div>
      </div>
      <div style={styles.feed}>
        <LiveFeed />
      </div>
    </div>
  );
}

const styles: any = {
  grid: { display: "grid", gridTemplateColumns: "1fr 360px", gap: 20, padding: 24, height: "100vh", boxSizing: "border-box" },
  main: { overflowY: "auto" },
  h2: { margin: "0 0 8px", color: "#e6edf3" },
  h3: { margin: "24px 0 8px", color: "#e6edf3" },
  roles: { color: "#8b949e", fontSize: 13, marginBottom: 16 },
  tiles: { display: "flex", gap: 16 },
  tile: { flex: 1, background: "#161b22", border: "1px solid #30363d", borderRadius: 10, padding: 20, cursor: "pointer", textAlign: "start" },
  tileVal: { fontSize: 32, fontWeight: 800, color: "#58a6ff" },
  tileLabel: { color: "#9aa4ad", fontSize: 13, marginTop: 4 },
  chip: { background: "#21262d", color: "#e6edf3", border: "1px solid #30363d", borderRadius: 999, padding: "6px 12px", cursor: "pointer", fontSize: 13 },
  feed: {},
};
