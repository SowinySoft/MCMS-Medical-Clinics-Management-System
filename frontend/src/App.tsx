import { useState } from "react";
import { BrowserRouter, Routes, Route, Navigate, useNavigate } from "react-router-dom";
import { AuthProvider, useAuth } from "./auth";
import { Sidebar } from "./components/Sidebar";
import { Login } from "./components/Login";
import { Dashboard } from "./components/Dashboard";
import { TableBrowser } from "./components/TableBrowser";
import { toggleLanguage } from "./i18n";
import { useTranslation } from "react-i18next";

function Shell() {
  const { access } = useAuth();
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
    <div style={{ display: "flex" }}>
      <Sidebar onNavigate={open} />
      <main style={{ flex: 1, minHeight: "100vh", background: "#010409", color: "#e6edf3" }}>
        <div style={topbar}>
          <button style={langBtn} onClick={toggleLanguage}>{t("language")}: EN / ع</button>
        </div>
        <Routes>
          <Route path="/" element={<Dashboard onOpen={open} />} />
          <Route path="/browse/:schema" element={<Dashboard onOpen={open} />} />
          <Route path="/browse/:schema/:model" element={<TableBrowser schema={view.schema} model={view.model} />} />
        </Routes>
      </main>
    </div>
  );
}

const topbar: any = { height: 44, display: "flex", alignItems: "center", justifyContent: "flex-end", padding: "0 16px", borderBottom: "1px solid #30363d", background: "#0d1117" };
const langBtn: any = { background: "#21262d", color: "#e6edf3", border: "1px solid #30363d", borderRadius: 6, padding: "4px 10px", cursor: "pointer", fontSize: 12 };

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
      <Root />
    </AuthProvider>
  );
}
