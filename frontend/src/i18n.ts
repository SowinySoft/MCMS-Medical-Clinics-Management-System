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
      theme: "Theme",
      invalidCredentials: "Invalid credentials",
      loading: "Loading…",
      delete: "Delete",
      confirmDelete: "Delete this record?",
      export: "Export CSV",
      print: "Print",
      from: "From",
      to: "To",
      noData: "No data available.",
      Search: "Apply",
      "is required": "is required",
      created: "Created",
      updated: "Updated",
      deleted: "Deleted",
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
      theme: "السمة",
      invalidCredentials: "بيانات غير صحيحة",
      loading: "جار التحميل…",
      delete: "حذف",
      confirmDelete: "حذف هذا السجل؟",
      export: "تصدير CSV",
      print: "طباعة",
      from: "من",
      to: "إلى",
      noData: "لا توجد بيانات.",
      Search: "تطبيق",
      "is required": "مطلوب",
      created: "تم الإنشاء",
      updated: "تم التحديث",
      deleted: "تم الحذف",
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
