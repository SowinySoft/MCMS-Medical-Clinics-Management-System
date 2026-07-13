// API client: JWT-aware axios wrapper around the MCMS DRF backend.
import axios from "axios";
import cfg from "./config.json";

const api = axios.create({ baseURL: cfg.apiBase });

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

export const mcmsApi = {
  get: (url: string, params?: any) => api.get(url, { params }),
  post: (url: string, body: any) => api.post(url, body),
  list: (schema: string, model: string, params?: any) =>
    api.get(`/${schema}/${model}/`, { params }),
};

export default api;
