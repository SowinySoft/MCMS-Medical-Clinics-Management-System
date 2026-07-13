import { useAuth } from "../auth";
import { SCHEMA_GROUPS } from "../schemas";
import { useTranslation } from "react-i18next";

// RBAC-aware, schema-grouped sidebar. Groups the user can't see are filtered
// out; each visible group expands to its physical schemas.
export function Sidebar({ onNavigate }: { onNavigate: (schema: string, model: string) => void }) {
  const { hasPerm, logout } = useAuth();
  const { t } = useTranslation();

  return (
    <aside style={styles.aside}>
      <div style={styles.brand}>{t("appName")}</div>
      <div style={styles.groupTitle}>{t("schemaGroups")}</div>
      <nav>
        {SCHEMA_GROUPS.filter((g) => hasPerm(g.perm)).map((g) => (
          <div key={g.key} style={styles.group}>
            <div style={styles.groupHeader}>
              <span>{g.icon}</span>
              <span>{g.label.en}</span>
            </div>
            {g.schemas.map((s) => (
              <button key={s} style={styles.schemaBtn} onClick={() => onNavigate(s, "")}>
                {s.replace("mcms_", "")}
              </button>
            ))}
          </div>
        ))}
      </nav>
      <button style={styles.logout} className="mcms-no-print" onClick={logout}>{t("logout")}</button>
    </aside>
  );
}

const styles: any = {
  aside: { width: 260, background: "var(--bg-elev)", color: "var(--text)", height: "100vh", display: "flex", flexDirection: "column", padding: 16, borderInlineEnd: "1px solid var(--border)" },
  brand: { fontWeight: 700, fontSize: 15, marginBottom: 18, color: "var(--accent)" },
  groupTitle: { fontSize: 11, textTransform: "uppercase", color: "var(--text-dim)", marginBottom: 8 },
  group: { marginBottom: 14 },
  groupHeader: { display: "flex", gap: 8, alignItems: "center", padding: "6px 8px", background: "var(--panel)", borderRadius: 6, fontWeight: 600 },
  schemaBtn: { display: "block", width: "100%", textAlign: "start", background: "transparent", border: "none", color: "var(--text-dim)", padding: "4px 8px 4px 28px", cursor: "pointer", fontSize: 13 },
  logout: { marginTop: "auto", background: "var(--panel-2)", color: "var(--text)", border: "1px solid var(--border)", borderRadius: 6, padding: 8, cursor: "pointer" },
};
