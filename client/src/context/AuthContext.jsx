import { createContext, useContext, useState } from "react";
import api from "../services/api";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    try { return JSON.parse(localStorage.getItem("brightloop_user")); }
    catch { return null; }
  });

  const login = async credentials => {
    const { data } = await api.post("/auth/login", credentials);
    localStorage.setItem("brightloop_token", data.token);
    localStorage.setItem("brightloop_refresh", data.refreshToken);
    localStorage.setItem("brightloop_user", JSON.stringify(data.user));
    setUser(data.user);
    return data.user;
  };

  const register = async payload => {
    const { data } = await api.post("/auth/register", payload);
    return data;
  };

  const logout = () => {
    api.post("/auth/logout").catch(() => {});
    ["brightloop_token", "brightloop_refresh", "brightloop_user"].forEach(key => localStorage.removeItem(key));
    setUser(null);
  };

  return <AuthContext.Provider value={{ user, login, register, logout }}>{children}</AuthContext.Provider>;
}

export const useAuth = () => useContext(AuthContext);
