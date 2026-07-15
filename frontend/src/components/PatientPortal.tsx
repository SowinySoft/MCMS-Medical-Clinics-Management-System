// Patient self-service portal (Phase 5: Reach).
// Scoped to the logged-in patient's own record; results/bills respect the
// data_sharing consent. Only renders for holders of `patient.portal`.
import { useEffect, useState } from "react";
import api from "../api";
import { useAuth } from "../auth";
import { useTranslation } from "react-i18next";

interface Row { [k: string]: any }

export function PatientPortal() {
  const { hasPerm } = useAuth();
  const { t } = useTranslation();
  const [tab, setTab] = useState<"appointments" | "results" | "bills" | "consents">("appointments");
  const [rows, setRows] = useState<Row[]>([]);
  const [consents, setConsents] = useState<Row[]>([]);
  const [err, setErr] = useState<string>("");
  const [loading, setLoading] = useState(false);

  // patients only
  useEffect(() => {
    if (!hasPerm("patient.portal")) return;
    load(tab);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [tab, hasPerm]);

  const load = async (which: typeof tab) => {
    setLoading(true); setErr("");
    try {
      if (which === "consents") {
        const { data } = await api.get("/patient/consents/");
        setConsents(data.consents || []);
      } else {
        const { data } = await api.get(`/patient/${which}/`);
        setRows(data[which] || []);
      }
    } catch (e: any) {
      setErr(e?.response?.data?.detail || t("noData"));
    } finally {
      setLoading(false);
    }
  };

  const toggleConsent = async (consent_type: string, granted: boolean) => {
    try {
      await api.post("/patient/toggle_consent/", { consent_type, granted });
      load("consents");
    } catch (e: any) {
      setErr(e?.response?.data?.detail || "error");
    }
  };

  if (!hasPerm("patient.portal")) {
    return <div style={{ padding: 24 }}>{t("forbidden")}</div>;
  }

  return (
    <div style={{ padding: 16, maxWidth: 920, margin: "0 auto" }}>
      <h2 style={{ marginBottom: 4 }}>🩺 {t("patientPortal")}</h2>
      <p style={{ opacity: 0.7, marginTop: 0 }}>{t("patientPortalSub")}</p>

      <div style={{ display: "flex", gap: 8, marginBottom: 16 }}>
        {(["appointments", "results", "bills", "consents"] as const).map((k) => (
          <button key={k} onClick={() => setTab(k)}
            style={{ ...tabBtn, ...(tab === k ? tabBtnActive : {}) }}>
            {t(`portal_${k}`)}
          </button>
        ))}
      </div>

      {err && <div style={{ color: "var(--danger)", marginBottom: 12 }}>{err}</div>}
      {loading && <div style={{ opacity: 0.6 }}>{t("loading")}</div>}

      {tab === "consents" ? (
        <table style={tbl}>
          <thead><tr><th>{t("consentType")}</th><th>{t("status")}</th><th></th></tr></thead>
          <tbody>
            {consents.map((c) => (
              <tr key={c.consent_type}>
                <td>{c.consent_type}</td>
                <td>{c.granted ? `✅ ${t("granted")}` : `⬜ ${t("notGranted")}`}</td>
                <td>
                  <button style={tabBtn} onClick={() => toggleConsent(c.consent_type, !c.granted)}>
                    {c.granted ? t("revoke") : t("grant")}
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      ) : rows.length === 0 && !loading ? (
        <div style={{ opacity: 0.6 }}>{t("noData")}</div>
      ) : (
        <table style={tbl}>
          <thead>
            <tr>{Object.keys(rows[0] || {}).map((k) => <th key={k}>{k}</th>)}</tr>
          </thead>
          <tbody>
            {rows.map((r, i) => (
              <tr key={i}>
                {Object.values(r).map((v, j) => <td key={j}>{String(v ?? "")}</td>)}
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

const tabBtn: any = {
  background: "var(--panel-2)", color: "var(--text)", border: "1px solid var(--border)",
  borderRadius: 6, padding: "6px 12px", cursor: "pointer", fontSize: 13,
};
const tabBtnActive: any = { background: "var(--accent)", color: "#fff", border: "none" };
const tbl: any = {
  width: "100%", borderCollapse: "collapse", fontSize: 13,
  "& th, & td": { borderBottom: "1px solid var(--border)", padding: "8px 10px", textAlign: "left" },
};
