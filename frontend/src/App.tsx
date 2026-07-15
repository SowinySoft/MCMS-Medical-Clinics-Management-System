import { useState } from "react";
import { BrowserRouter, Routes, Route, Navigate, useNavigate } from "react-router-dom";
import { AuthProvider, useAuth } from "./auth";
import { ToastProvider } from "./toast";
import { Sidebar } from "./components/Sidebar";
import { Login } from "./components/Login";
import { Dashboard } from "./components/Dashboard";
import { TableBrowser } from "./components/TableBrowser";
import { SchemaBrowser } from "./components/SchemaBrowser";
import { SysAdmin } from "./components/SysAdmin";
import { Reports } from "./components/Reports";
import { PatientPortal } from "./components/PatientPortal";
import { ThemeSwitcher } from "./components/ThemeSwitcher";
import { toggleLanguage } from "./i18n";
import { useTranslation } from "react-i18next";

function Shell() {
  const { access, hasPerm } = useAuth();
  const navigate = useNavigate();
  const { t } = useTranslation();
  const [view, setView] = useState<{ schema: string; model: string }>({ schema: "", model: "" });

  if (!access) return <Navigate to="/login" />;

  const open = (schema: string, model: string) => {
    if (schema && model) { setView({ schema, model }); navigate(`/browse/${schema}/${model}`); }
    else if (schema) { setView({ schema, model: "" }); navigate(`/browse/${schema}`); }
    else navigate("/");
  };

  return (
    <div style={{ display: "flex", height: "100vh" }}>
      <Sidebar onNavigate={open} />
      <main style={{ flex: 1, minHeight: "100vh", overflow: "auto" }}>
        <div className="mcms-no-print" style={topbar}>
          <button style={btn} onClick={toggleLanguage}>{t("language")}: EN / ع</button>
          <ThemeSwitcher />
          <button style={btnAccent} onClick={() => navigate("/reports")}>{t("Reports")}</button>
          {hasPerm("admin.all") && (
            <button style={btnAccent} onClick={() => navigate("/sysadmin")}>System</button>
          )}
          {hasPerm("patient.portal") && (
            <button style={btnAccent} onClick={() => navigate("/portal")}>{t("patientPortal")}</button>
          )}
        </div>
        <Routes>
          <Route path="/" element={<Dashboard onOpen={open} />} />
          <Route path="/reports" element={<Reports />} />
          <Route path="/sysadmin" element={<SysAdmin />} />
          <Route path="/portal" element={<PatientPortal />} />
          <Route path="/browse/:schema" element={<SchemaBrowser />} />
          <Route path="/browse/:schema/:model" element={<TableBrowser schema={view.schema} model={view.model} />} />
        </Routes>
      </main>
    </div>
  );
}

const topbar: any = { height: 44, display: "flex", alignItems: "center", justifyContent: "flex-end", gap: 8, padding: "0 16px", borderBottom: "1px solid var(--border)", background: "var(--bg-elev)" };
const btn: any = { background: "var(--panel-2)", color: "var(--text)", border: "1px solid var(--border)", borderRadius: 6, padding: "4px 10px", cursor: "pointer", fontSize: 12 };
const btnAccent: any = { background: "var(--accent)", color: "#fff", border: "none", borderRadius: 6, padding: "4px 12px", cursor: "pointer", fontSize: 12 };

function Root() {
  const { access } = useAuth();
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={access ? <Navigate to="/" /> : <Login />} />
        <Route path="/*" element={<Shell />} />
      </Routes>
    </BrowserRouter>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <ToastProvider>
        <Root />
      </ToastProvider>
    </AuthProvider>
  );
}
