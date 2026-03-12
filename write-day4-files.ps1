# PropIQ Day 4 - Write source files only (Vite app already created)
Write-Host "Writing Day 4 source files..." -ForegroundColor Cyan

$src = "C:\Users\User\propiq\frontend\src"

New-Item -ItemType Directory -Force -Path "$src\pages" | Out-Null
New-Item -ItemType Directory -Force -Path "$src\components" | Out-Null
New-Item -ItemType Directory -Force -Path "$src\services" | Out-Null
New-Item -ItemType Directory -Force -Path "$src\context" | Out-Null

Write-Host "Created folders" -ForegroundColor Green

# ── api.js ──
Set-Content -Path "$src\services\api.js" -Encoding utf8 -Value @'
import axios from "axios";

const API = axios.create({ baseURL: "http://localhost:8080" });

API.interceptors.request.use((config) => {
  const token = localStorage.getItem("token");
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

API.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem("token");
      window.location.href = "/login";
    }
    return Promise.reject(err);
  }
);

export const authAPI = {
  login: (data) => API.post("/api/auth/login", data),
  register: (data) => API.post("/api/auth/register", data),
  me: () => API.get("/api/auth/me"),
};

export const propertyAPI = {
  getAll: () => API.get("/api/properties"),
  create: (data) => API.post("/api/properties", data),
  update: (id, data) => API.put(`/api/properties/${id}`, data),
  delete: (id) => API.delete(`/api/properties/${id}`),
};

export const tenantAPI = {
  getAll: () => API.get("/api/tenants"),
  create: (data) => API.post("/api/tenants", data),
  delete: (id) => API.delete(`/api/tenants/${id}`),
};

export const leaseAPI = {
  getAll: () => API.get("/api/leases"),
  create: (data) => API.post("/api/leases", data),
};

export const rentAPI = {
  getByLease: (leaseId) => API.get(`/api/rent/lease/${leaseId}`),
  pay: (data) => API.post("/api/rent/pay", data),
};

export const propbotAPI = {
  chat: (message) =>
    axios.post("http://localhost:8000/chat", { message }),
};
'@
Write-Host "Created api.js" -ForegroundColor Green

# ── AuthContext.jsx ──
Set-Content -Path "$src\context\AuthContext.jsx" -Encoding utf8 -Value @'
import { createContext, useContext, useState, useEffect } from "react";
import { authAPI } from "../services/api";

const AuthContext = createContext(null);

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const token = localStorage.getItem("token");
    if (token) {
      authAPI.me()
        .then((res) => setUser(res.data.data))
        .catch(() => localStorage.removeItem("token"))
        .finally(() => setLoading(false));
    } else {
      setLoading(false);
    }
  }, []);

  const login = async (email, password) => {
    const res = await authAPI.login({ email, password });
    const { accessToken, ...userData } = res.data.data;
    localStorage.setItem("token", accessToken);
    setUser(userData);
    return userData;
  };

  const logout = () => {
    localStorage.removeItem("token");
    setUser(null);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, loading }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => useContext(AuthContext);
'@
Write-Host "Created AuthContext.jsx" -ForegroundColor Green

# ── main.jsx ──
Set-Content -Path "$src\main.jsx" -Encoding utf8 -Value @'
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import { BrowserRouter } from "react-router-dom";
import { Toaster } from "react-hot-toast";
import { AuthProvider } from "./context/AuthContext";
import App from "./App.jsx";
import "./index.css";

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <BrowserRouter>
      <AuthProvider>
        <App />
        <Toaster position="top-right" />
      </AuthProvider>
    </BrowserRouter>
  </StrictMode>
);
'@
Write-Host "Created main.jsx" -ForegroundColor Green

# ── App.jsx ──
Set-Content -Path "$src\App.jsx" -Encoding utf8 -Value @'
import { Routes, Route, Navigate } from "react-router-dom";
import { useAuth } from "./context/AuthContext";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import Properties from "./pages/Properties";
import Tenants from "./pages/Tenants";
import Layout from "./components/Layout";

function PrivateRoute({ children }) {
  const { user, loading } = useAuth();
  if (loading) return <div className="loading-screen"><div className="spinner" /></div>;
  return user ? children : <Navigate to="/login" />;
}

export default function App() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/" element={<PrivateRoute><Layout /></PrivateRoute>}>
        <Route index element={<Dashboard />} />
        <Route path="properties" element={<Properties />} />
        <Route path="tenants" element={<Tenants />} />
      </Route>
    </Routes>
  );
}
'@
Write-Host "Created App.jsx" -ForegroundColor Green

# ── index.css ──
Set-Content -Path "$src\index.css" -Encoding utf8 -Value @'
@import url("https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600;700&family=DM+Mono:wght@400;500&display=swap");

*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

:root {
  --bg: #0f0f13;
  --bg2: #16161d;
  --bg3: #1e1e28;
  --border: #2a2a38;
  --text: #e8e8f0;
  --text2: #8888a8;
  --accent: #7c6af7;
  --accent2: #56cfb2;
  --danger: #f76c6c;
  --warn: #f7c26c;
  --success: #6cf7a8;
  --radius: 12px;
}

body {
  font-family: "DM Sans", sans-serif;
  background: var(--bg);
  color: var(--text);
  min-height: 100vh;
  -webkit-font-smoothing: antialiased;
}

.loading-screen {
  display: flex; align-items: center; justify-content: center;
  height: 100vh; background: var(--bg);
}

.spinner {
  width: 36px; height: 36px;
  border: 3px solid var(--border);
  border-top-color: var(--accent);
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin { to { transform: rotate(360deg); } }

button { cursor: pointer; font-family: inherit; transition: all 0.15s ease; }

input, select, textarea {
  font-family: inherit;
  background: var(--bg3);
  border: 1px solid var(--border);
  color: var(--text);
  border-radius: 8px;
  padding: 10px 14px;
  font-size: 14px;
  outline: none;
  width: 100%;
  transition: border-color 0.15s;
}

input:focus, select:focus, textarea:focus { border-color: var(--accent); }

.btn {
  display: inline-flex; align-items: center; gap: 8px;
  padding: 10px 20px; border-radius: 8px; font-size: 14px;
  font-weight: 500; border: none;
}

.btn-primary { background: var(--accent); color: #fff; }
.btn-primary:hover { background: #6a58e8; transform: translateY(-1px); }
.btn-ghost { background: transparent; color: var(--text2); border: 1px solid var(--border); }
.btn-ghost:hover { background: var(--bg3); color: var(--text); }
.btn-danger { background: transparent; color: var(--danger); border: 1px solid var(--danger); }
.btn-danger:hover { background: var(--danger); color: #fff; }

.card {
  background: var(--bg2);
  border: 1px solid var(--border);
  border-radius: var(--radius);
  padding: 24px;
}

.badge {
  display: inline-flex; align-items: center;
  padding: 3px 10px; border-radius: 20px;
  font-size: 12px; font-weight: 500;
}

.badge-success { background: #6cf7a820; color: var(--success); }
.badge-warn { background: #f7c26c20; color: var(--warn); }
.badge-danger { background: #f76c6c20; color: var(--danger); }
.badge-info { background: #7c6af720; color: var(--accent); }

.modal-overlay {
  position: fixed; inset: 0;
  background: rgba(0,0,0,0.7);
  display: flex; align-items: center; justify-content: center;
  z-index: 1000; padding: 20px;
  animation: fadeIn 0.15s ease;
}

.modal {
  background: var(--bg2);
  border: 1px solid var(--border);
  border-radius: 16px;
  padding: 32px;
  width: 100%; max-width: 480px;
  animation: slideUp 0.2s ease;
}

.modal h2 { font-size: 20px; margin-bottom: 24px; }
.form-group { margin-bottom: 16px; }
.form-group label { display: block; font-size: 13px; color: var(--text2); margin-bottom: 6px; }
.form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }

@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
@keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
'@
Write-Host "Created index.css" -ForegroundColor Green

# ── Layout.jsx ──
Set-Content -Path "$src\components\Layout.jsx" -Encoding utf8 -Value @'
import { Outlet, NavLink, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { Building2, Users, LayoutDashboard, LogOut, Bot } from "lucide-react";
import { useState } from "react";
import PropBot from "./PropBot";
import "./Layout.css";

export default function Layout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const [botOpen, setBotOpen] = useState(false);

  const handleLogout = () => { logout(); navigate("/login"); };

  return (
    <div className="layout">
      <aside className="sidebar">
        <div className="sidebar-logo">
          <Building2 size={22} color="#7c6af7" />
          <span>PropIQ</span>
        </div>
        <nav className="sidebar-nav">
          <NavLink to="/" end className={({isActive}) => isActive ? "nav-item active" : "nav-item"}>
            <LayoutDashboard size={18} /> Dashboard
          </NavLink>
          <NavLink to="/properties" className={({isActive}) => isActive ? "nav-item active" : "nav-item"}>
            <Building2 size={18} /> Properties
          </NavLink>
          <NavLink to="/tenants" className={({isActive}) => isActive ? "nav-item active" : "nav-item"}>
            <Users size={18} /> Tenants
          </NavLink>
        </nav>
        <div className="sidebar-footer">
          <div className="user-info">
            <div className="user-avatar">{user?.name?.[0]?.toUpperCase()}</div>
            <div>
              <div className="user-name">{user?.name}</div>
              <div className="user-role">{user?.role}</div>
            </div>
          </div>
          <button className="logout-btn" onClick={handleLogout}><LogOut size={16} /></button>
        </div>
      </aside>
      <main className="main-content">
        <Outlet />
      </main>
      <button className="bot-fab" onClick={() => setBotOpen(true)}>
        <Bot size={22} />
        <span>PropBot</span>
      </button>
      {botOpen && <PropBot onClose={() => setBotOpen(false)} />}
    </div>
  );
}
'@
Write-Host "Created Layout.jsx" -ForegroundColor Green

# ── Layout.css ──
Set-Content -Path "$src\components\Layout.css" -Encoding utf8 -Value @'
.layout { display: flex; min-height: 100vh; }

.sidebar {
  width: 220px; min-height: 100vh;
  background: var(--bg2);
  border-right: 1px solid var(--border);
  display: flex; flex-direction: column;
  padding: 24px 16px;
  position: fixed; left: 0; top: 0; bottom: 0;
}

.sidebar-logo {
  display: flex; align-items: center; gap: 10px;
  font-size: 18px; font-weight: 700; color: var(--text);
  padding: 0 8px 32px; letter-spacing: -0.5px;
}

.sidebar-nav { flex: 1; display: flex; flex-direction: column; gap: 4px; }

.nav-item {
  display: flex; align-items: center; gap: 10px;
  padding: 10px 12px; border-radius: 8px;
  color: var(--text2); text-decoration: none;
  font-size: 14px; font-weight: 500; transition: all 0.15s;
}

.nav-item:hover { background: var(--bg3); color: var(--text); }
.nav-item.active { background: #7c6af715; color: var(--accent); }

.sidebar-footer {
  display: flex; align-items: center;
  gap: 8px; padding-top: 16px;
  border-top: 1px solid var(--border);
}

.user-info { display: flex; align-items: center; gap: 10px; flex: 1; min-width: 0; }

.user-avatar {
  width: 32px; height: 32px; border-radius: 50%;
  background: var(--accent); color: #fff;
  display: flex; align-items: center; justify-content: center;
  font-size: 13px; font-weight: 600; flex-shrink: 0;
}

.user-name { font-size: 13px; font-weight: 500; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.user-role { font-size: 11px; color: var(--text2); }

.logout-btn { background: none; border: none; color: var(--text2); padding: 6px; border-radius: 6px; }
.logout-btn:hover { color: var(--danger); background: var(--bg3); }

.main-content { margin-left: 220px; flex: 1; padding: 32px; min-height: 100vh; }

.bot-fab {
  position: fixed; bottom: 28px; right: 28px;
  display: flex; align-items: center; gap: 8px;
  background: var(--accent); color: #fff;
  border: none; border-radius: 50px;
  padding: 12px 20px; font-size: 14px; font-weight: 600;
  box-shadow: 0 4px 24px #7c6af740; z-index: 100;
  transition: transform 0.2s, box-shadow 0.2s;
}
.bot-fab:hover { transform: translateY(-2px); box-shadow: 0 8px 32px #7c6af760; }
'@
Write-Host "Created Layout.css" -ForegroundColor Green

# ── PropBot.jsx ──
Set-Content -Path "$src\components\PropBot.jsx" -Encoding utf8 -Value @'
import { useState, useRef, useEffect } from "react";
import { X, Send, Bot, Loader } from "lucide-react";
import { propbotAPI } from "../services/api";
import "./PropBot.css";

export default function PropBot({ onClose }) {
  const [messages, setMessages] = useState([
    { role: "bot", text: "Hi! I am PropBot. Ask me anything about Indian rental law — TDS, security deposits, eviction rules, lease agreements." }
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const bottomRef = useRef(null);

  useEffect(() => { bottomRef.current?.scrollIntoView({ behavior: "smooth" }); }, [messages]);

  const send = async () => {
    if (!input.trim() || loading) return;
    const userMsg = input.trim();
    setInput("");
    setMessages((m) => [...m, { role: "user", text: userMsg }]);
    setLoading(true);
    try {
      const res = await propbotAPI.chat(userMsg);
      setMessages((m) => [...m, { role: "bot", text: res.data.reply }]);
    } catch {
      setMessages((m) => [...m, { role: "bot", text: "PropBot unavailable. Make sure it is running on port 8000." }]);
    } finally {
      setLoading(false);
    }
  };

  const handleKey = (e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); send(); } };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="bot-window" onClick={(e) => e.stopPropagation()}>
        <div className="bot-header">
          <div className="bot-title"><Bot size={18} /> PropBot AI</div>
          <button className="bot-close" onClick={onClose}><X size={18} /></button>
        </div>
        <div className="bot-messages">
          {messages.map((m, i) => (
            <div key={i} className={`msg ${m.role}`}>
              <div className="msg-bubble">{m.text}</div>
            </div>
          ))}
          {loading && (
            <div className="msg bot">
              <div className="msg-bubble typing"><Loader size={14} className="spin" /> Thinking...</div>
            </div>
          )}
          <div ref={bottomRef} />
        </div>
        <div className="bot-input">
          <input value={input} onChange={(e) => setInput(e.target.value)} onKeyDown={handleKey} placeholder="Ask about TDS, deposits, eviction..." autoFocus />
          <button className="send-btn" onClick={send} disabled={loading}><Send size={16} /></button>
        </div>
      </div>
    </div>
  );
}
'@
Write-Host "Created PropBot.jsx" -ForegroundColor Green

# ── PropBot.css ──
Set-Content -Path "$src\components\PropBot.css" -Encoding utf8 -Value @'
.bot-window {
  background: var(--bg2); border: 1px solid var(--border);
  border-radius: 16px; width: 420px; height: 560px;
  display: flex; flex-direction: column; overflow: hidden;
  animation: slideUp 0.2s ease;
}

.bot-header {
  display: flex; align-items: center; justify-content: space-between;
  padding: 16px 20px; border-bottom: 1px solid var(--border);
  background: var(--bg3);
}

.bot-title { display: flex; align-items: center; gap: 8px; font-weight: 600; font-size: 15px; color: var(--accent); }
.bot-close { background: none; border: none; color: var(--text2); padding: 4px; border-radius: 6px; }
.bot-close:hover { background: var(--bg); color: var(--text); }

.bot-messages { flex: 1; overflow-y: auto; padding: 16px; display: flex; flex-direction: column; gap: 12px; }
.bot-messages::-webkit-scrollbar { width: 4px; }
.bot-messages::-webkit-scrollbar-thumb { background: var(--border); border-radius: 4px; }

.msg { display: flex; }
.msg.user { justify-content: flex-end; }
.msg.bot { justify-content: flex-start; }

.msg-bubble { max-width: 80%; padding: 10px 14px; border-radius: 12px; font-size: 14px; line-height: 1.5; }
.msg.user .msg-bubble { background: var(--accent); color: #fff; border-bottom-right-radius: 4px; }
.msg.bot .msg-bubble { background: var(--bg3); color: var(--text); border-bottom-left-radius: 4px; }
.typing { display: flex; align-items: center; gap: 8px; color: var(--text2); }
.spin { animation: spin 1s linear infinite; }

.bot-input { display: flex; gap: 8px; padding: 12px 16px; border-top: 1px solid var(--border); background: var(--bg3); }
.bot-input input { flex: 1; background: var(--bg2); border-radius: 8px; font-size: 14px; }

.send-btn {
  background: var(--accent); color: #fff; border: none; border-radius: 8px;
  width: 38px; height: 38px; display: flex; align-items: center; justify-content: center; flex-shrink: 0;
}
.send-btn:hover:not(:disabled) { background: #6a58e8; }
.send-btn:disabled { opacity: 0.5; }
'@
Write-Host "Created PropBot.css" -ForegroundColor Green

# ── Login.jsx ──
Set-Content -Path "$src\pages\Login.jsx" -Encoding utf8 -Value @'
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { Building2 } from "lucide-react";
import toast from "react-hot-toast";
import "./Login.css";

export default function Login() {
  const [email, setEmail] = useState("owner2@test.com");
  const [password, setPassword] = useState("password123");
  const [loading, setLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    try {
      await login(email, password);
      toast.success("Welcome back!");
      navigate("/");
    } catch {
      toast.error("Invalid credentials");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-page">
      <div className="login-card">
        <div className="login-logo">
          <Building2 size={28} color="#7c6af7" />
          <h1>PropIQ</h1>
        </div>
        <p className="login-sub">Property Management for Indian Landlords</p>
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Email</label>
            <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
          </div>
          <div className="form-group">
            <label>Password</label>
            <input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required />
          </div>
          <button type="submit" className="btn btn-primary" style={{width:"100%",justifyContent:"center",marginTop:8}} disabled={loading}>
            {loading ? "Signing in..." : "Sign In"}
          </button>
        </form>
      </div>
    </div>
  );
}
'@
Write-Host "Created Login.jsx" -ForegroundColor Green

# ── Login.css ──
Set-Content -Path "$src\pages\Login.css" -Encoding utf8 -Value @'
.login-page {
  min-height: 100vh; display: flex; align-items: center; justify-content: center;
  background: var(--bg);
  background-image: radial-gradient(ellipse at 20% 50%, #7c6af710 0%, transparent 60%),
                    radial-gradient(ellipse at 80% 20%, #56cfb210 0%, transparent 60%);
}

.login-card {
  background: var(--bg2); border: 1px solid var(--border);
  border-radius: 20px; padding: 40px; width: 100%; max-width: 400px;
}

.login-logo { display: flex; align-items: center; gap: 12px; margin-bottom: 8px; }
.login-logo h1 { font-size: 26px; font-weight: 700; letter-spacing: -1px; }
.login-sub { color: var(--text2); font-size: 14px; margin-bottom: 32px; }
'@
Write-Host "Created Login.css" -ForegroundColor Green

# ── Dashboard.jsx ──
Set-Content -Path "$src\pages\Dashboard.jsx" -Encoding utf8 -Value @'
import { useEffect, useState } from "react";
import { propertyAPI, tenantAPI, leaseAPI } from "../services/api";
import { Building2, Users, FileText, TrendingUp } from "lucide-react";
import "./Dashboard.css";

export default function Dashboard() {
  const [stats, setStats] = useState({ properties: 0, tenants: 0, leases: 0, occupied: 0 });
  const [leases, setLeases] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([propertyAPI.getAll(), tenantAPI.getAll(), leaseAPI.getAll()])
      .then(([p, t, l]) => {
        const props = p.data.data || [];
        const tens = t.data.data || [];
        const leas = l.data.data || [];
        setStats({ properties: props.length, tenants: tens.length, leases: leas.length, occupied: props.filter((x) => x.isOccupied).length });
        setLeases(leas.slice(0, 5));
      })
      .finally(() => setLoading(false));
  }, []);

  const statCards = [
    { label: "Properties", value: stats.properties, icon: Building2, color: "#7c6af7" },
    { label: "Tenants", value: stats.tenants, icon: Users, color: "#56cfb2" },
    { label: "Active Leases", value: stats.leases, icon: FileText, color: "#f7c26c" },
    { label: "Occupied", value: stats.occupied, icon: TrendingUp, color: "#6cf7a8" },
  ];

  return (
    <div className="page">
      <div className="page-header">
        <h1>Dashboard</h1>
        <p className="page-sub">Overview of your properties</p>
      </div>
      <div className="stats-grid">
        {statCards.map((s) => (
          <div className="stat-card card" key={s.label}>
            <div className="stat-icon" style={{ background: s.color + "20", color: s.color }}><s.icon size={20} /></div>
            <div className="stat-value">{loading ? "—" : s.value}</div>
            <div className="stat-label">{s.label}</div>
          </div>
        ))}
      </div>
      <div className="card" style={{ marginTop: 24 }}>
        <h2 style={{ fontSize: 16, marginBottom: 16 }}>Recent Leases</h2>
        {loading ? <div style={{ color: "var(--text2)" }}>Loading...</div> : leases.length === 0 ? (
          <div style={{ color: "var(--text2)", fontSize: 14 }}>No leases yet.</div>
        ) : (
          <table className="data-table">
            <thead><tr><th>Property</th><th>Tenant</th><th>Monthly Rent</th><th>End Date</th><th>Status</th></tr></thead>
            <tbody>
              {leases.map((l) => (
                <tr key={l.id}>
                  <td>{l.property?.name}</td>
                  <td>{l.tenant?.name}</td>
                  <td>₹{l.monthlyRent?.toLocaleString("en-IN")}</td>
                  <td>{l.endDate}</td>
                  <td><span className={`badge badge-${l.status === "ACTIVE" ? "success" : "warn"}`}>{l.status}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
}
'@
Write-Host "Created Dashboard.jsx" -ForegroundColor Green

# ── Dashboard.css ──
Set-Content -Path "$src\pages\Dashboard.css" -Encoding utf8 -Value @'
.page { max-width: 1100px; }
.page-header { margin-bottom: 28px; }
.page-header h1 { font-size: 26px; font-weight: 700; letter-spacing: -0.5px; }
.page-sub { color: var(--text2); font-size: 14px; margin-top: 4px; }
.stats-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }
.stat-card { display: flex; flex-direction: column; gap: 12px; }
.stat-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; }
.stat-value { font-size: 32px; font-weight: 700; letter-spacing: -1px; }
.stat-label { font-size: 13px; color: var(--text2); }
.data-table { width: 100%; border-collapse: collapse; font-size: 14px; }
.data-table th { text-align: left; padding: 10px 12px; color: var(--text2); font-weight: 500; font-size: 12px; border-bottom: 1px solid var(--border); text-transform: uppercase; letter-spacing: 0.5px; }
.data-table td { padding: 12px; border-bottom: 1px solid var(--border); }
.data-table tr:last-child td { border-bottom: none; }
.data-table tr:hover td { background: var(--bg3); }
'@
Write-Host "Created Dashboard.css" -ForegroundColor Green

# ── Properties.jsx ──
Set-Content -Path "$src\pages\Properties.jsx" -Encoding utf8 -Value @'
import { useEffect, useState } from "react";
import { propertyAPI } from "../services/api";
import { Plus, Building2, MapPin, Trash2 } from "lucide-react";
import toast from "react-hot-toast";
import "./Dashboard.css";
import "./Properties.css";

export default function Properties() {
  const [properties, setProperties] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({ name: "", address: "", city: "", state: "", type: "APARTMENT", monthlyRent: "" });

  const load = () => propertyAPI.getAll().then((r) => setProperties(r.data.data || [])).finally(() => setLoading(false));
  useEffect(() => { load(); }, []);

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await propertyAPI.create({ ...form, monthlyRent: Number(form.monthlyRent) });
      toast.success("Property added!");
      setShowModal(false);
      setForm({ name: "", address: "", city: "", state: "", type: "APARTMENT", monthlyRent: "" });
      load();
    } catch { toast.error("Failed to add property"); }
  };

  const handleDelete = async (id) => {
    if (!confirm("Delete this property?")) return;
    try { await propertyAPI.delete(id); toast.success("Deleted"); load(); }
    catch { toast.error("Cannot delete — has active lease"); }
  };

  return (
    <div className="page">
      <div className="page-header" style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <div><h1>Properties</h1><p className="page-sub">Manage your rental properties</p></div>
        <button className="btn btn-primary" onClick={() => setShowModal(true)}><Plus size={16} /> Add Property</button>
      </div>
      {loading ? <div style={{ color: "var(--text2)" }}>Loading...</div> : (
        <div className="prop-grid">
          {properties.map((p) => (
            <div className="prop-card card" key={p.id}>
              <div className="prop-card-header">
                <div className="prop-icon"><Building2 size={18} /></div>
                <span className={`badge ${p.isOccupied ? "badge-success" : "badge-info"}`}>{p.isOccupied ? "Occupied" : "Vacant"}</span>
              </div>
              <h3 className="prop-name">{p.name}</h3>
              <div className="prop-address"><MapPin size={13} /> {p.address}, {p.city}</div>
              <div className="prop-footer">
                <div className="prop-rent">₹{p.monthlyRent?.toLocaleString("en-IN")}<span>/mo</span></div>
                <button className="btn btn-danger" style={{ padding: "6px 10px" }} onClick={() => handleDelete(p.id)}><Trash2 size={14} /></button>
              </div>
            </div>
          ))}
          {properties.length === 0 && <div style={{ color: "var(--text2)", fontSize: 14 }}>No properties yet.</div>}
        </div>
      )}
      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2>Add Property</h2>
            <form onSubmit={handleCreate}>
              <div className="form-group"><label>Property Name</label><input value={form.name} onChange={(e) => setForm({...form, name: e.target.value})} required /></div>
              <div className="form-group"><label>Address</label><input value={form.address} onChange={(e) => setForm({...form, address: e.target.value})} required /></div>
              <div className="form-row">
                <div className="form-group"><label>City</label><input value={form.city} onChange={(e) => setForm({...form, city: e.target.value})} /></div>
                <div className="form-group"><label>State</label><input value={form.state} onChange={(e) => setForm({...form, state: e.target.value})} /></div>
              </div>
              <div className="form-row">
                <div className="form-group">
                  <label>Type</label>
                  <select value={form.type} onChange={(e) => setForm({...form, type: e.target.value})}>
                    {["APARTMENT","HOUSE","VILLA","COMMERCIAL","PG"].map((t) => <option key={t}>{t}</option>)}
                  </select>
                </div>
                <div className="form-group"><label>Monthly Rent (₹)</label><input type="number" value={form.monthlyRent} onChange={(e) => setForm({...form, monthlyRent: e.target.value})} required /></div>
              </div>
              <div style={{ display: "flex", gap: 12, marginTop: 8 }}>
                <button type="button" className="btn btn-ghost" style={{ flex: 1, justifyContent: "center" }} onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary" style={{ flex: 1, justifyContent: "center" }}>Add Property</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
'@
Write-Host "Created Properties.jsx" -ForegroundColor Green

# ── Properties.css ──
Set-Content -Path "$src\pages\Properties.css" -Encoding utf8 -Value @'
.prop-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px; }
.prop-card { display: flex; flex-direction: column; gap: 10px; }
.prop-card-header { display: flex; justify-content: space-between; align-items: center; }
.prop-icon { width: 36px; height: 36px; border-radius: 8px; background: #7c6af720; color: var(--accent); display: flex; align-items: center; justify-content: center; }
.prop-name { font-size: 16px; font-weight: 600; }
.prop-address { display: flex; align-items: center; gap: 4px; font-size: 13px; color: var(--text2); }
.prop-footer { display: flex; align-items: center; justify-content: space-between; margin-top: 4px; }
.prop-rent { font-size: 20px; font-weight: 700; color: var(--accent2); letter-spacing: -0.5px; }
.prop-rent span { font-size: 13px; color: var(--text2); font-weight: 400; }
'@
Write-Host "Created Properties.css" -ForegroundColor Green

# ── Tenants.jsx ──
Set-Content -Path "$src\pages\Tenants.jsx" -Encoding utf8 -Value @'
import { useEffect, useState } from "react";
import { tenantAPI } from "../services/api";
import { Plus, Trash2, Shield } from "lucide-react";
import toast from "react-hot-toast";
import "./Dashboard.css";

export default function Tenants() {
  const [tenants, setTenants] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({ name: "", email: "", phone: "", aadhaarNumber: "", panNumber: "" });

  const load = () => tenantAPI.getAll().then((r) => setTenants(r.data.data || [])).finally(() => setLoading(false));
  useEffect(() => { load(); }, []);

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await tenantAPI.create(form);
      toast.success("Tenant added!");
      setShowModal(false);
      setForm({ name: "", email: "", phone: "", aadhaarNumber: "", panNumber: "" });
      load();
    } catch (err) { toast.error(err.response?.data?.message || "Failed to add tenant"); }
  };

  const handleDelete = async (id) => {
    if (!confirm("Delete this tenant?")) return;
    try { await tenantAPI.delete(id); toast.success("Deleted"); load(); }
    catch { toast.error("Cannot delete — has active lease"); }
  };

  return (
    <div className="page">
      <div className="page-header" style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <div><h1>Tenants</h1><p className="page-sub">Aadhaar is always masked for PII protection</p></div>
        <button className="btn btn-primary" onClick={() => setShowModal(true)}><Plus size={16} /> Add Tenant</button>
      </div>
      {loading ? <div style={{ color: "var(--text2)" }}>Loading...</div> : (
        <div className="card" style={{ padding: 0, overflow: "hidden" }}>
          <table className="data-table">
            <thead>
              <tr><th>Name</th><th>Email</th><th>Phone</th><th><Shield size={12} style={{verticalAlign:"middle"}} /> Aadhaar</th><th>PAN</th><th></th></tr>
            </thead>
            <tbody>
              {tenants.map((t) => (
                <tr key={t.id}>
                  <td>
                    <div style={{ display:"flex", alignItems:"center", gap:10 }}>
                      <div style={{ width:32, height:32, borderRadius:"50%", background:"#7c6af720", color:"var(--accent)", display:"flex", alignItems:"center", justifyContent:"center", fontSize:13, fontWeight:600 }}>{t.name?.[0]}</div>
                      {t.name}
                    </div>
                  </td>
                  <td style={{ color:"var(--text2)" }}>{t.email}</td>
                  <td>{t.phone}</td>
                  <td><span style={{ fontFamily:"DM Mono,monospace", fontSize:13 }}>{t.aadhaarNumber || "—"}</span></td>
                  <td><span style={{ fontFamily:"DM Mono,monospace", fontSize:13 }}>{t.panNumber || "—"}</span></td>
                  <td><button className="btn btn-danger" style={{ padding:"6px 10px" }} onClick={() => handleDelete(t.id)}><Trash2 size={14} /></button></td>
                </tr>
              ))}
              {tenants.length === 0 && <tr><td colSpan={6} style={{ color:"var(--text2)", textAlign:"center", padding:32 }}>No tenants yet.</td></tr>}
            </tbody>
          </table>
        </div>
      )}
      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2>Add Tenant</h2>
            <form onSubmit={handleCreate}>
              <div className="form-group"><label>Full Name</label><input value={form.name} onChange={(e) => setForm({...form, name: e.target.value})} required /></div>
              <div className="form-row">
                <div className="form-group"><label>Email</label><input type="email" value={form.email} onChange={(e) => setForm({...form, email: e.target.value})} required /></div>
                <div className="form-group"><label>Phone</label><input value={form.phone} onChange={(e) => setForm({...form, phone: e.target.value})} /></div>
              </div>
              <div className="form-row">
                <div className="form-group"><label>Aadhaar Number</label><input value={form.aadhaarNumber} onChange={(e) => setForm({...form, aadhaarNumber: e.target.value})} placeholder="12 digits" /></div>
                <div className="form-group"><label>PAN Number</label><input value={form.panNumber} onChange={(e) => setForm({...form, panNumber: e.target.value})} placeholder="ABCDE1234F" /></div>
              </div>
              <div style={{ display:"flex", gap:12, marginTop:8 }}>
                <button type="button" className="btn btn-ghost" style={{ flex:1, justifyContent:"center" }} onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary" style={{ flex:1, justifyContent:"center" }}>Add Tenant</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
'@
Write-Host "Created Tenants.jsx" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  All source files written!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Now run:" -ForegroundColor Yellow
Write-Host "  cd C:\Users\User\propiq\frontend" -ForegroundColor White
Write-Host "  npm run dev" -ForegroundColor White
Write-Host ""
Write-Host "Open http://localhost:5173 in your browser" -ForegroundColor Green
