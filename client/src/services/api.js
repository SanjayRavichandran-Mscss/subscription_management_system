import axios from "axios";

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || "http://localhost:5000/api",
  timeout: 15000
});

api.interceptors.request.use(config => {
  const token = localStorage.getItem("brightloop_token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

api.interceptors.response.use(
  response => response,
  async error => {
    const original = error.config;
    const refreshToken = localStorage.getItem("brightloop_refresh");
    if (error.response?.status === 401 && refreshToken && !original?._retry && !original?.url?.includes("/auth/")) {
      original._retry = true;
      try {
        const { data } = await api.post("/auth/refresh", { refreshToken });
        localStorage.setItem("brightloop_token", data.token);
        localStorage.setItem("brightloop_refresh", data.refreshToken);
        original.headers.Authorization = `Bearer ${data.token}`;
        return api(original);
      } catch {
        localStorage.removeItem("brightloop_refresh");
      }
    }
    if (error.response?.status === 401) {
      ["brightloop_token", "brightloop_refresh", "brightloop_user"].forEach(key => localStorage.removeItem(key));
      if (!window.location.pathname.startsWith("/login")) window.location.assign("/login");
    }
    return Promise.reject(error);
  }
);

export default api;
