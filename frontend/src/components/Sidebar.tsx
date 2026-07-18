import { useAuth } from "../useAuth";
import { SCHEMA_GROUPS } from "../schemas";
import { useTranslation } from "react-i18next";
import { useNavigate } from "react-router-dom";
import { useState } from "react";
import { toggleLanguage } from "../i18n";

// RBAC-aware, schema-grouped sidebar with a Windows-Explorer-style collapsible
// tree (each group expands/collapses via its header) and a bottom "Tools"
// section (Reports + Language) separated by a divider, so Reporting/Localization
// live INSIDE the sidebar as one cohesive component instead of feeling detached.
export function Sidebar({ onNavigate }: { onNavigate: (schema: string, model: string) => void }) {
  const { hasPerm, logout } = useAuth();
  const { t } = useTranslation();
  const navigate = useNavigate();
  // All groups expanded by default (familiar); user can collapse any.
  const [open, setOpen] = useState<Record<string, boolean>>(
    Object.fromEntries(SCHEMA_GROUPS.map((g) => [g.key, true])),
  );
  const groups = SCHEMA_GROUPS.filter((g) => hasPerm(g.perm));

  return (
    <aside style={styles.aside}>
      <div style={styles.brand}>{t("appName")}</div>

      <div style={styles.groupTitle}>{t("schemaGroups")}</div>
      <nav style={{ flex: 1, overflowY: "auto" }}>
        {groups.map((g) => (
          <div key={g.key} style={styles.group}>
            <div
              style={styles.groupHeader}
              className="mcms-navitem"
              onClick={() => setOpen((s) => ({ ...s, [g.key]: !s[g.key] }))}
            >
              <span style={styles.chevron}>{open[g.key] ? "▾" : "▸"}</span>
              <span>{g.icon}</span>
              <span style={{ flex: 1 }}>{g.label.en}</span>
            </div>
            {open[g.key] &&
              g.schemas.map((s) => (
                <button key={s} className="mcms-navitem schemaBtn" style={styles.schemaBtn} onClick={() => onNavigate(s, "")}>
                  {s.replace("mcms_", "")}
                </button>
              ))}
          </div>
        ))}

        {/* Tools section — Reporting & Localization, part of the same sidebar */}
        <div style={styles.divider} />
        <div style={styles.groupTitle}>{t("tools")}</div>
        <button className="mcms-navitem toolBtn" style={styles.toolBtn} onClick={() => navigate("/reports")}>
          📊 {t("Reports")}
        </button>
        <button className="mcms-navitem toolBtn" style={styles.toolBtn} onClick={toggleLanguage}>
          🌐 {t("language")}: EN / ع
        </button>
        {hasPerm("admin.all") && (
          <>
            <button className="mcms-navitem toolBtn" style={styles.toolBtn} onClick={() => navigate("/sysadmin")}>⚙️ System</button>
            <button className="mcms-navitem toolBtn" style={styles.toolBtn} onClick={() => navigate("/monitors")}>📡 Monitors</button>
            <button className="mcms-navitem toolBtn" style={styles.toolBtn} onClick={() => navigate("/vital")}>📜 Vital Records</button>
          </>
        )}
        {hasPerm("patient.portal") && (
          <button className="mcms-navitem toolBtn" style={styles.toolBtn} onClick={() => navigate("/portal")}>🧑 {t("patientPortal")}</button>
        )}
      </nav>

      <button style={styles.logout} className="mcms-no-print" onClick={logout}>
        {t("logout")}
      </button>
    </aside>
  );
}

const styles: any = {
  aside: {
    width: 260,
    background: "var(--bg-elev)",
    color: "var(--text)",
    height: "100vh",
    display: "flex",
    flexDirection: "column",
    padding: 16,
    borderInlineEnd: "1px solid var(--border)",
  },
  brand: { fontWeight: 700, fontSize: 15, marginBottom: 18, color: "var(--accent)" },
  groupTitle: {
    fontSize: 11,
    textTransform: "uppercase",
    color: "var(--text-dim)",
    marginBottom: 8,
  },
  group: { marginBottom: 6 },
  groupHeader: {
    display: "flex",
    gap: 6,
    alignItems: "center",
    padding: "7px 8px",
    background: "var(--panel)",
    borderRadius: 6,
    fontWeight: 600,
    cursor: "pointer",
    userSelect: "none",
    borderInlineStart: "3px solid transparent",
  },
  chevron: { width: 12, fontSize: 10, color: "var(--text-dim)" },
  schemaBtn: {
    display: "block",
    width: "100%",
    textAlign: "start",
    background: "transparent",
    border: "none",
    borderInlineStart: "3px solid transparent",
    color: "var(--text-dim)",
    padding: "5px 8px 5px 28px",
    cursor: "pointer",
    fontSize: 13,
  },
  divider: { height: 1, background: "var(--border)", margin: "14px 0 10px" },
  toolBtn: {
    display: "block",
    width: "100%",
    textAlign: "start",
    background: "var(--panel-2)",
    border: "1px solid var(--border)",
    borderInlineStart: "3px solid transparent",
    color: "var(--text)",
    borderRadius: 6,
    padding: "8px 10px",
    marginBottom: 6,
    cursor: "pointer",
    fontSize: 13,
  },
  logout: {
    marginTop: 12,
    background: "var(--panel-2)",
    color: "var(--text)",
    border: "1px solid var(--border)",
    borderRadius: 6,
    padding: 8,
    cursor: "pointer",
  },
};
