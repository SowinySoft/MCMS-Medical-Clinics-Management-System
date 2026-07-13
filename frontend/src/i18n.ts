// i18n: English + Arabic with automatic RTL layout switching.
import i18n from "i18next";
import { initReactI18next } from "react-i18next";

const resources = {
  en: {
    translation: {
      appName: "MCMS — Medical Clinics Management System",
      login: "Login",
      username: "Username",
      password: "Password",
      dashboard: "Dashboard",
      logout: "Logout",
      language: "Language",
      search: "Search",
      liveFeed: "Live Event Feed",
      noEvents: "Waiting for events…",
      schemaGroups: "Departments & Modules",
      notifications: "Notifications",
      poweredBy: "Powered by MCMS event-driven core",
      forbidden: "You do not have permission to view this.",
      Reports: "Reports",
      New: "New",
      Save: "Save",
      Cancel: "Cancel",
      edit: "Edit",
      Create: "Create",
    },
  },
  ar: {
    translation: {
      appName: "نظام إدارة العيادات الطبية",
      login: "تسجيل الدخول",
      username: "اسم المستخدم",
      password: "كلمة المرور",
      dashboard: "لوحة التحكم",
      logout: "تسجيل الخروج",
      language: "اللغة",
      search: "بحث",
      liveFeed: "بث الأحداث المباشر",
      noEvents: "في انتظار الأحداث…",
      schemaGroups: "الأقسام والوحدات",
      notifications: "الإشعارات",
      poweredBy: "مدعوم بنواة النظام الموجه بالأحداث",
      forbidden: "ليس لديك صلاحية لعرض هذا.",
      Reports: "التقارير",
      New: "جديد",
      Save: "حفظ",
      Cancel: "إلغاء",
      edit: "تعديل",
      Create: "إنشاء",
    },
  },
};

const RTL_LANGS = ["ar"];

i18n.use(initReactI18next).init({
  resources,
  lng: localStorage.getItem("lang") || "en",
  fallbackLng: "en",
  interpolation: { escapeValue: false },
});

// toggle document direction on language change
function applyDir(lng: string) {
  document.documentElement.dir = RTL_LANGS.includes(lng) ? "rtl" : "ltr";
  document.documentElement.lang = lng;
}
applyDir(i18n.language);
i18n.on("languageChanged", applyDir);

export const toggleLanguage = () => {
  const next = i18n.language === "en" ? "ar" : "en";
  localStorage.setItem("lang", next);
  i18n.changeLanguage(next);
};

export default i18n;
