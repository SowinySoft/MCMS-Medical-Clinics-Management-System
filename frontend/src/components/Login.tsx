import { useState } from "react";
import { useAuth } from "../auth";
import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { toggleLanguage } from "../i18n";
import { ThemeSwitcher } from "./ThemeSwitcher";

export function Login() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const [u, setU] = useState("admin");
  const [p, setP] = useState("admin123");
  const [err, setErr] = useState("");

  const submit = async (e: any) => {
    e.preventDefault();
    try { await login(u, p); navigate("/"); }
    catch { setErr(t("invalidCredentials") || "Invalid credentials"); }
  };

  return (
    <div style={styles.wrap}>
      <div style={styles.card}>
        <div style={styles.brand}>{t("appName")}</div>
        <div style={{ position: "absolute", top: 20, insetInlineEnd: 20, display: "flex", gap: 8 }}>
          <ThemeSwitcher />
          <button style={styles.lang} onClick={toggleLanguage}>{t("language")}: EN / ع</button>
        </div>
        <form onSubmit={submit} style={styles.form}>
          <label>{t("username")}</label>
          <input className="mcms-input" value={u} onChange={(e) => setU(e.target.value)} />
          <label>{t("password")}</label>
          <input className="mcms-input" type="password" value={p} onChange={(e) => setP(e.target.value)} />
          {err && <div style={{ color: "var(--danger)" }}>{err}</div>}
          <button type="submit" className="mcms-btn" style={{ marginTop: 12 }}>{t("login")}</button>
        </form>
      </div>
    </div>
  );
}

const styles: any = {
  wrap: { minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", background: "linear-gradient(135deg, var(--bg), color-mix(in srgb, var(--accent) 12%, var(--bg)))" },
  card: { background: "var(--panel)", padding: 32, borderRadius: 12, width: 360, border: "1px solid var(--border)", position: "relative" },
  brand: { fontSize: 16, fontWeight: 700, color: "var(--accent)", marginBottom: 18 },
  lang: { background: "var(--panel-2)", color: "var(--text)", border: "1px solid var(--border)", borderRadius: 6, padding: "4px 8px", cursor: "pointer", fontSize: 12 },
  form: { display: "flex", flexDirection: "column", gap: 8 },
};
