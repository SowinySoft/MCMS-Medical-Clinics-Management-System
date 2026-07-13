import { useState } from "react";
import { useAuth } from "../auth";
import { useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import { toggleLanguage } from "../i18n";

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
    catch { setErr("Invalid credentials"); }
  };

  return (
    <div style={styles.wrap}>
      <div style={styles.card}>
        <div style={styles.brand}>{t("appName")}</div>
        <button style={styles.lang} onClick={toggleLanguage}>{t("language")}: EN / ع</button>
        <form onSubmit={submit} style={styles.form}>
          <label>{t("username")}</label>
          <input value={u} onChange={(e) => setU(e.target.value)} style={styles.input} />
          <label>{t("password")}</label>
          <input type="password" value={p} onChange={(e) => setP(e.target.value)} style={styles.input} />
          {err && <div style={{ color: "#f85149" }}>{err}</div>}
          <button type="submit" style={styles.btn}>{t("login")}</button>
        </form>
      </div>
    </div>
  );
}

const styles: any = {
  wrap: { minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center", background: "linear-gradient(135deg,#0d1117,#1f6feb22)" },
  card: { background: "#161b22", padding: 32, borderRadius: 12, width: 360, border: "1px solid #30363d", position: "relative" },
  brand: { fontSize: 16, fontWeight: 700, color: "#58a6ff", marginBottom: 18 },
  lang: { position: "absolute", top: 24, insetInlineEnd: 24, background: "#21262d", color: "#e6edf3", border: "1px solid #30363d", borderRadius: 6, padding: "4px 8px", cursor: "pointer", fontSize: 12 },
  form: { display: "flex", flexDirection: "column", gap: 8 },
  input: { padding: 8, borderRadius: 6, border: "1px solid #30363d", background: "#0d1117", color: "#e6edf3" },
  btn: { marginTop: 12, padding: 10, background: "#1f6feb", color: "#fff", border: "none", borderRadius: 6, cursor: "pointer", fontWeight: 600 },
};
