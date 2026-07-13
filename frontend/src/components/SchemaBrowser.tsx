import { useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { mcmsApi } from "../api";
import { MODEL_LABELS } from "../schemas";
import { useTranslation } from "react-i18next";

// Per-schema table picker. Lists every model under a schema (derived from the
// live API root, so it always matches the backend) and links to its browser.
// This closes the gap where only the 10 Dashboard quick-access tables were
// reachable — now all 89 backend routes are navigable.
export function SchemaBrowser() {
  const { schema } = useParams<{ schema: string }>();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const [models, setModels] = useState<{ slug: string; label: string }[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let active = true;
    setLoading(true);
    mcmsApi.get("/").then(({ data }) => {
      if (!active) return;
      const prefix = `${schema}/`;
      const list = Object.keys(data)
        .filter((k) => k.startsWith(prefix))
        .map((k) => {
          const slug = k.slice(prefix.length);
          return { slug, label: MODEL_LABELS[k]?.en || slug };
        })
        .sort((a, b) => a.label.localeCompare(b.label));
      setModels(list);
      setLoading(false);
    }).catch(() => setLoading(false));
    return () => { active = false; };
  }, [schema]);

  if (loading) return <div className="mcms-spinner" />;

  return (
    <div style={{ padding: 24 }}>
      <div style={{ fontSize: 18, fontWeight: 700, color: "var(--text)", marginBottom: 16 }}>
        {schema?.replace("mcms_", "")} <span style={{ color: "var(--text-dim)", fontWeight: 400, fontSize: 14 }}>— {models.length} {t("tables") || "tables"}</span>
      </div>
      <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))", gap: 12 }}>
        {models.map((m) => (
          <button
            key={m.slug}
            className="mcms-card"
            style={{ textAlign: "start", cursor: "pointer", color: "var(--text)", border: "1px solid var(--border)" }}
            onClick={() => navigate(`/browse/${schema}/${m.slug}`)}
          >
            {m.label}
            <div style={{ fontSize: 11, color: "var(--text-dim)", marginTop: 4 }}>{m.slug}</div>
          </button>
        ))}
      </div>
      {models.length === 0 && <div className="mcms-empty">{t("noData")}</div>}
    </div>
  );
}
