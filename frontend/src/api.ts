// API client: JWT-aware axios wrapper around the MCMS DRF backend.
import axios from "axios";
import cfg from "./config.json";

// Allow build-time override via Vite env (docker/nginx use relative "/api").
// Falls back to config.json so local dev keeps working unchanged.
const apiBase =
  (import.meta.env.VITE_API_BASE as string | undefined) || cfg.apiBase;

const api = axios.create({ baseURL: apiBase });

api.interceptors.request.use((config) => {
  const t = localStorage.getItem("access");
  if (t) config.headers.Authorization = `Bearer ${t}`;
  return config;
});

// auto-refresh on 401
api.interceptors.response.use(
  (r) => r,
  async (err) => {
    const original = err.config;
    if (err.response?.status === 401 && !original._retry) {
      original._retry = true;
      const refresh = localStorage.getItem("refresh");
      if (refresh) {
        try {
          const { data } = await axios.post(`${cfg.apiBase}/auth/token/refresh/`, { refresh });
          localStorage.setItem("access", data.access);
          original.headers.Authorization = `Bearer ${data.access}`;
          return api(original);
        } catch {
          localStorage.clear();
          window.location.href = "/login";
        }
      }
    }
    return Promise.reject(err);
  }
);

export interface TokenPayload {
  access: string;
  refresh: string;
  roles: string[];
  perms: string[];
}

export const authApi = {
  login: (u: string, p: string) => api.post<TokenPayload>("/auth/token/", { username: u, password: p }),
  refresh: (r: string) => api.post("/auth/token/refresh/", { refresh: r }),
};

// The DB uses physical `mcms_*` schemas, but the DRF routers register each
// domain app under its bare app label (e.g. `mcms_core` -> `core`). Schema-group
// navigation passes the physical `mcms_*` name, so strip the prefix when
// building API URLs — otherwise every TableBrowser/ModelBrowser call 404s and
// the "every UI page hits a real endpoint" contract is broken.
export const apiSlug = (schema: string) => schema.replace(/^mcms_/, "");

export const mcmsApi = {
  get: (url: string, params?: any) => api.get(url, { params }),
  post: (url: string, body: any) => api.post(url, body),
  patch: (url: string, body: any) => api.patch(url, body),
  del: (url: string) => api.delete(url),
  options: (url: string) => api.options(url),
  list: (schema: string, model: string, params?: any) =>
    api.get(`/${apiSlug(schema)}/${model}/`, { params }),
};

export default api;
