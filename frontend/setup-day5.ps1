Write-Host "Creating PropIQ Day 5 files..." -ForegroundColor Cyan

$src = "C:\Users\User\propiq\frontend\src"

# Fix App.jsx - update routes to include Rent page
$appJsx = @'
import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import { AuthProvider } from "./context/AuthContext";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import Properties from "./pages/Properties";
import Tenants from "./pages/Tenants";
import Rent from "./pages/Rent";
import PrivateRoute from "./components/PrivateRoute";

export default function App() {
  return (
    <BrowserRouter>
      <AuthProvider>
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route path="/" element={<PrivateRoute><Dashboard /></PrivateRoute>} />
          <Route path="/properties" element={<PrivateRoute><Properties /></PrivateRoute>} />
          <Route path="/tenants" element={<PrivateRoute><Tenants /></PrivateRoute>} />
          <Route path="/rent" element={<PrivateRoute><Rent /></PrivateRoute>} />
          <Route path="*" element={<Navigate to="/" />} />
        </Routes>
      </AuthProvider>
    </BrowserRouter>
  );
}
'@
Set-Content -Path "$src\App.jsx" -Value $appJsx -Encoding UTF8
Write-Host "  [OK] App.jsx" -ForegroundColor Green

# Sidebar with Rent link
$sidebar = @'
import { NavLink, useNavigate } from "react-router-dom";
import { useAuth } from "../context/AuthContext";
import { LayoutDashboard, Building2, Users, CreditCard, LogOut } from "lucide-react";

export default function Sidebar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate("/login");
  };

  const links = [
    { to: "/", icon: <LayoutDashboard size={18} />, label: "Dashboard" },
    { to: "/properties", icon: <Building2 size={18} />, label: "Properties" },
    { to: "/tenants", icon: <Users size={18} />, label: "Tenants" },
    { to: "/rent", icon: <CreditCard size={18} />, label: "Rent" },
  ];

  return (
    <div style={{ width: 220, background: "#0f0f0f", borderRight: "1px solid #1e1e1e", display: "flex", flexDirection: "column", height: "100vh", position: "fixed" }}>
      <div style={{ padding: "24px 20px 16px", borderBottom: "1px solid #1e1e1e" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10 }}>
          <div style={{ width: 32, height: 32, background: "linear-gradient(135deg, #6366f1, #8b5cf6)", borderRadius: 8, display: "flex", alignItems: "center", justifyContent: "center", fontSize: 14, fontWeight: 700, color: "white" }}>P</div>
          <span style={{ color: "white", fontWeight: 700, fontSize: 18 }}>PropIQ</span>
        </div>
      </div>
      <nav style={{ flex: 1, padding: "12px 12px" }}>
        {links.map(link => (
          <NavLink key={link.to} to={link.to} end={link.to === "/"} style={({ isActive }) => ({
            display: "flex", alignItems: "center", gap: 10, padding: "10px 12px", borderRadius: 8,
            marginBottom: 4, textDecoration: "none", fontSize: 14, fontWeight: 500,
            color: isActive ? "white" : "#9ca3af",
            background: isActive ? "#1e1e2e" : "transparent"
          })}>
            {link.icon}{link.label}
          </NavLink>
        ))}
      </nav>
      <div style={{ padding: "16px 20px", borderTop: "1px solid #1e1e1e" }}>
        <div style={{ display: "flex", alignItems: "center", gap: 10, marginBottom: 12 }}>
          <div style={{ width: 32, height: 32, borderRadius: "50%", background: "#6366f1", display: "flex", alignItems: "center", justifyContent: "center", color: "white", fontSize: 13, fontWeight: 600 }}>
            {user?.name?.charAt(0) || "U"}
          </div>
          <div>
            <div style={{ color: "white", fontSize: 13, fontWeight: 600 }}>{user?.name}</div>
            <div style={{ color: "#6b7280", fontSize: 11 }}>{user?.role}</div>
          </div>
          <button onClick={handleLogout} style={{ marginLeft: "auto", background: "none", border: "none", cursor: "pointer", color: "#6b7280" }}>
            <LogOut size={16} />
          </button>
        </div>
      </div>
    </div>
  );
}
'@
Set-Content -Path "$src\components\Sidebar.jsx" -Value $sidebar -Encoding UTF8
Write-Host "  [OK] Sidebar.jsx (with Rent link)" -ForegroundColor Green

# Properties page with working Add form
$properties = @'
import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import Sidebar from "../components/Sidebar";
import PropBot from "../components/PropBot";

const API = "http://localhost:8080";

export default function Properties() {
  const { token } = useAuth();
  const [properties, setProperties] = useState([]);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState({ name: "", address: "", city: "", state: "", pincode: "", monthlyRent: "", securityDeposit: "", bedrooms: "", bathrooms: "" });

  const headers = { "Content-Type": "application/json", Authorization: `Bearer ${token}` };

  useEffect(() => { fetchProperties(); }, []);

  const fetchProperties = async () => {
    try {
      const res = await fetch(`${API}/api/properties`, { headers });
      const data = await res.json();
      setProperties(data.data || []);
    } catch (e) { console.error(e); }
  };

  const handleSubmit = async () => {
    if (!form.name || !form.address || !form.monthlyRent) { alert("Name, address and rent are required"); return; }
    setLoading(true);
    try {
      const res = await fetch(`${API}/api/properties`, { method: "POST", headers, body: JSON.stringify({ ...form, monthlyRent: Number(form.monthlyRent), securityDeposit: Number(form.securityDeposit), bedrooms: Number(form.bedrooms), bathrooms: Number(form.bathrooms) }) });
      if (res.ok) { setShowForm(false); setForm({ name: "", address: "", city: "", state: "", pincode: "", monthlyRent: "", securityDeposit: "", bedrooms: "", bathrooms: "" }); fetchProperties(); }
      else { const d = await res.json(); alert(d.message || "Failed"); }
    } catch (e) { alert("Error: " + e.message); }
    setLoading(false);
  };

  const handleDelete = async (id) => {
    if (!confirm("Delete this property?")) return;
    await fetch(`${API}/api/properties/${id}`, { method: "DELETE", headers });
    fetchProperties();
  };

  return (
    <div style={{ display: "flex", background: "#0a0a0a", minHeight: "100vh" }}>
      <Sidebar />
      <main style={{ marginLeft: 220, flex: 1, padding: 32 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 24 }}>
          <div>
            <h1 style={{ color: "white", fontSize: 28, fontWeight: 700, margin: 0 }}>Properties</h1>
            <p style={{ color: "#6b7280", margin: "4px 0 0" }}>Manage your rental properties</p>
          </div>
          <button onClick={() => setShowForm(true)} style={{ background: "linear-gradient(135deg, #6366f1, #8b5cf6)", color: "white", border: "none", borderRadius: 10, padding: "10px 20px", cursor: "pointer", fontWeight: 600 }}>+ Add Property</button>
        </div>

        {showForm && (
          <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.7)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 1000 }}>
            <div style={{ background: "#111", border: "1px solid #222", borderRadius: 16, padding: 32, width: 480, maxHeight: "80vh", overflowY: "auto" }}>
              <h2 style={{ color: "white", margin: "0 0 24px" }}>Add New Property</h2>
              {[["name","Property Name"],["address","Address"],["city","City"],["state","State"],["pincode","Pincode"],["monthlyRent","Monthly Rent (Rs)"],["securityDeposit","Security Deposit (Rs)"],["bedrooms","Bedrooms"],["bathrooms","Bathrooms"]].map(([field, label]) => (
                <div key={field} style={{ marginBottom: 16 }}>
                  <label style={{ color: "#9ca3af", fontSize: 13, display: "block", marginBottom: 6 }}>{label}</label>
                  <input value={form[field]} onChange={e => setForm({...form, [field]: e.target.value})} style={{ width: "100%", background: "#1a1a1a", border: "1px solid #333", borderRadius: 8, padding: "10px 14px", color: "white", fontSize: 14, boxSizing: "border-box" }} />
                </div>
              ))}
              <div style={{ display: "flex", gap: 12, marginTop: 8 }}>
                <button onClick={() => setShowForm(false)} style={{ flex: 1, padding: "10px", background: "#1a1a1a", border: "1px solid #333", borderRadius: 8, color: "white", cursor: "pointer" }}>Cancel</button>
                <button onClick={handleSubmit} disabled={loading} style={{ flex: 1, padding: "10px", background: "linear-gradient(135deg, #6366f1, #8b5cf6)", border: "none", borderRadius: 8, color: "white", cursor: "pointer", fontWeight: 600 }}>{loading ? "Saving..." : "Save Property"}</button>
              </div>
            </div>
          </div>
        )}

        <div style={{ display: "grid", gap: 16 }}>
          {properties.length === 0 ? (
            <div style={{ color: "#6b7280", textAlign: "center", padding: 48 }}>No properties yet. Click "+ Add Property" to get started.</div>
          ) : properties.map(p => (
            <div key={p.id} style={{ background: "#111", border: "1px solid #1e1e1e", borderRadius: 12, padding: 24, display: "flex", justifyContent: "space-between", alignItems: "center" }}>
              <div>
                <h3 style={{ color: "white", margin: "0 0 4px", fontSize: 18 }}>{p.name}</h3>
                <p style={{ color: "#6b7280", margin: "0 0 8px", fontSize: 14 }}>{p.address}, {p.city}</p>
                <span style={{ color: "#10b981", fontSize: 15, fontWeight: 600 }}>Rs {p.monthlyRent?.toLocaleString()}/mo</span>
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                <span style={{ background: p.status === "OCCUPIED" ? "#064e3b" : "#1e3a5f", color: p.status === "OCCUPIED" ? "#10b981" : "#60a5fa", padding: "4px 12px", borderRadius: 20, fontSize: 12, fontWeight: 600 }}>{p.status || "VACANT"}</span>
                <button onClick={() => handleDelete(p.id)} style={{ background: "#2a1a1a", border: "1px solid #3a2a2a", color: "#ef4444", borderRadius: 8, padding: "6px 14px", cursor: "pointer", fontSize: 13 }}>Delete</button>
              </div>
            </div>
          ))}
        </div>
      </main>
      <PropBot />
    </div>
  );
}
'@
Set-Content -Path "$src\pages\Properties.jsx" -Value $properties -Encoding UTF8
Write-Host "  [OK] Properties.jsx (with working Add form)" -ForegroundColor Green

# Tenants page with working Add form
$tenants = @'
import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import Sidebar from "../components/Sidebar";
import PropBot from "../components/PropBot";

const API = "http://localhost:8080";

export default function Tenants() {
  const { token } = useAuth();
  const [tenants, setTenants] = useState([]);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState({ name: "", email: "", phone: "", aadhaarNumber: "", panNumber: "", emergencyContact: "" });

  const headers = { "Content-Type": "application/json", Authorization: `Bearer ${token}` };

  useEffect(() => { fetchTenants(); }, []);

  const fetchTenants = async () => {
    try {
      const res = await fetch(`${API}/api/tenants`, { headers });
      const data = await res.json();
      setTenants(data.data || []);
    } catch (e) { console.error(e); }
  };

  const handleSubmit = async () => {
    if (!form.name || !form.email) { alert("Name and email are required"); return; }
    setLoading(true);
    try {
      const res = await fetch(`${API}/api/tenants`, { method: "POST", headers, body: JSON.stringify(form) });
      if (res.ok) { setShowForm(false); setForm({ name: "", email: "", phone: "", aadhaarNumber: "", panNumber: "", emergencyContact: "" }); fetchTenants(); }
      else { const d = await res.json(); alert(d.message || "Failed"); }
    } catch (e) { alert("Error: " + e.message); }
    setLoading(false);
  };

  const handleDelete = async (id) => {
    if (!confirm("Delete this tenant?")) return;
    await fetch(`${API}/api/tenants/${id}`, { method: "DELETE", headers });
    fetchTenants();
  };

  return (
    <div style={{ display: "flex", background: "#0a0a0a", minHeight: "100vh" }}>
      <Sidebar />
      <main style={{ marginLeft: 220, flex: 1, padding: 32 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 24 }}>
          <div>
            <h1 style={{ color: "white", fontSize: 28, fontWeight: 700, margin: 0 }}>Tenants</h1>
            <p style={{ color: "#6b7280", margin: "4px 0 0" }}>Aadhaar is always masked for PII protection</p>
          </div>
          <button onClick={() => setShowForm(true)} style={{ background: "linear-gradient(135deg, #6366f1, #8b5cf6)", color: "white", border: "none", borderRadius: 10, padding: "10px 20px", cursor: "pointer", fontWeight: 600 }}>+ Add Tenant</button>
        </div>

        {showForm && (
          <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.7)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 1000 }}>
            <div style={{ background: "#111", border: "1px solid #222", borderRadius: 16, padding: 32, width: 480 }}>
              <h2 style={{ color: "white", margin: "0 0 24px" }}>Add New Tenant</h2>
              {[["name","Full Name"],["email","Email"],["phone","Phone"],["aadhaarNumber","Aadhaar Number (12 digits)"],["panNumber","PAN Number"],["emergencyContact","Emergency Contact"]].map(([field, label]) => (
                <div key={field} style={{ marginBottom: 16 }}>
                  <label style={{ color: "#9ca3af", fontSize: 13, display: "block", marginBottom: 6 }}>{label}</label>
                  <input value={form[field]} onChange={e => setForm({...form, [field]: e.target.value})} style={{ width: "100%", background: "#1a1a1a", border: "1px solid #333", borderRadius: 8, padding: "10px 14px", color: "white", fontSize: 14, boxSizing: "border-box" }} />
                </div>
              ))}
              <div style={{ display: "flex", gap: 12, marginTop: 8 }}>
                <button onClick={() => setShowForm(false)} style={{ flex: 1, padding: "10px", background: "#1a1a1a", border: "1px solid #333", borderRadius: 8, color: "white", cursor: "pointer" }}>Cancel</button>
                <button onClick={handleSubmit} disabled={loading} style={{ flex: 1, padding: "10px", background: "linear-gradient(135deg, #6366f1, #8b5cf6)", border: "none", borderRadius: 8, color: "white", cursor: "pointer", fontWeight: 600 }}>{loading ? "Saving..." : "Save Tenant"}</button>
              </div>
            </div>
          </div>
        )}

        <div style={{ background: "#111", border: "1px solid #1e1e1e", borderRadius: 12, overflow: "hidden" }}>
          <table style={{ width: "100%", borderCollapse: "collapse" }}>
            <thead>
              <tr style={{ borderBottom: "1px solid #1e1e1e" }}>
                {["NAME","EMAIL","PHONE","AADHAAR","PAN"].map(h => (
                  <th key={h} style={{ padding: "14px 20px", textAlign: "left", color: "#6b7280", fontSize: 12, fontWeight: 600 }}>{h}</th>
                ))}
                <th style={{ padding: "14px 20px" }}></th>
              </tr>
            </thead>
            <tbody>
              {tenants.length === 0 ? (
                <tr><td colSpan={6} style={{ color: "#6b7280", textAlign: "center", padding: 48 }}>No tenants yet.</td></tr>
              ) : tenants.map(t => (
                <tr key={t.id} style={{ borderBottom: "1px solid #1a1a1a" }}>
                  <td style={{ padding: "16px 20px", color: "white", fontWeight: 500 }}>{t.name}</td>
                  <td style={{ padding: "16px 20px", color: "#9ca3af" }}>{t.email}</td>
                  <td style={{ padding: "16px 20px", color: "#9ca3af" }}>{t.phone || "-"}</td>
                  <td style={{ padding: "16px 20px", color: "#9ca3af", fontFamily: "monospace" }}>{t.aadhaarNumber || "-"}</td>
                  <td style={{ padding: "16px 20px", color: "#9ca3af", fontFamily: "monospace" }}>{t.panNumber || "-"}</td>
                  <td style={{ padding: "16px 20px" }}>
                    <button onClick={() => handleDelete(t.id)} style={{ background: "#2a1a1a", border: "1px solid #3a2a2a", color: "#ef4444", borderRadius: 6, padding: "5px 12px", cursor: "pointer", fontSize: 12 }}>Delete</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </main>
      <PropBot />
    </div>
  );
}
'@
Set-Content -Path "$src\pages\Tenants.jsx" -Value $tenants -Encoding UTF8
Write-Host "  [OK] Tenants.jsx (with working Add form)" -ForegroundColor Green

# Rent page
$rent = @'
import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import Sidebar from "../components/Sidebar";
import PropBot from "../components/PropBot";

const API = "http://localhost:8080";

export default function Rent() {
  const { token } = useAuth();
  const [payments, setPayments] = useState([]);
  const [properties, setProperties] = useState([]);
  const [tenants, setTenants] = useState([]);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(false);
  const [form, setForm] = useState({ propertyId: "", tenantId: "", amount: "", monthYear: "", paymentMethod: "BANK_TRANSFER", notes: "" });

  const headers = { "Content-Type": "application/json", Authorization: `Bearer ${token}` };

  useEffect(() => {
    fetchPayments();
    fetchProperties();
    fetchTenants();
  }, []);

  const fetchPayments = async () => {
    try {
      const res = await fetch(`${API}/api/rent`, { headers });
      const data = await res.json();
      setPayments(data.data || []);
    } catch (e) { console.error(e); }
  };

  const fetchProperties = async () => {
    try {
      const res = await fetch(`${API}/api/properties`, { headers });
      const data = await res.json();
      setProperties(data.data || []);
    } catch (e) {}
  };

  const fetchTenants = async () => {
    try {
      const res = await fetch(`${API}/api/tenants`, { headers });
      const data = await res.json();
      setTenants(data.data || []);
    } catch (e) {}
  };

  const handleSubmit = async () => {
    if (!form.propertyId || !form.tenantId || !form.amount || !form.monthYear) { alert("All fields required"); return; }
    setLoading(true);
    try {
      const res = await fetch(`${API}/api/rent/pay`, { method: "POST", headers, body: JSON.stringify({ ...form, amount: Number(form.amount), propertyId: Number(form.propertyId), tenantId: Number(form.tenantId) }) });
      if (res.ok) { setShowForm(false); setForm({ propertyId: "", tenantId: "", amount: "", monthYear: "", paymentMethod: "BANK_TRANSFER", notes: "" }); fetchPayments(); }
      else { const d = await res.json(); alert(d.message || "Failed"); }
    } catch (e) { alert("Error: " + e.message); }
    setLoading(false);
  };

  const statusColor = (s) => s === "PAID" ? { bg: "#064e3b", color: "#10b981" } : s === "PENDING" ? { bg: "#1e3a5f", color: "#60a5fa" } : { bg: "#4a1a1a", color: "#ef4444" };

  return (
    <div style={{ display: "flex", background: "#0a0a0a", minHeight: "100vh" }}>
      <Sidebar />
      <main style={{ marginLeft: 220, flex: 1, padding: 32 }}>
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 24 }}>
          <div>
            <h1 style={{ color: "white", fontSize: 28, fontWeight: 700, margin: 0 }}>Rent Tracking</h1>
            <p style={{ color: "#6b7280", margin: "4px 0 0" }}>Track payments, TDS alerts, late fees</p>
          </div>
          <button onClick={() => setShowForm(true)} style={{ background: "linear-gradient(135deg, #6366f1, #8b5cf6)", color: "white", border: "none", borderRadius: 10, padding: "10px 20px", cursor: "pointer", fontWeight: 600 }}>+ Record Payment</button>
        </div>

        {showForm && (
          <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.7)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 1000 }}>
            <div style={{ background: "#111", border: "1px solid #222", borderRadius: 16, padding: 32, width: 480 }}>
              <h2 style={{ color: "white", margin: "0 0 24px" }}>Record Rent Payment</h2>
              <div style={{ marginBottom: 16 }}>
                <label style={{ color: "#9ca3af", fontSize: 13, display: "block", marginBottom: 6 }}>Property</label>
                <select value={form.propertyId} onChange={e => setForm({...form, propertyId: e.target.value})} style={{ width: "100%", background: "#1a1a1a", border: "1px solid #333", borderRadius: 8, padding: "10px 14px", color: "white", fontSize: 14 }}>
                  <option value="">Select property</option>
                  {properties.map(p => <option key={p.id} value={p.id}>{p.name}</option>)}
                </select>
              </div>
              <div style={{ marginBottom: 16 }}>
                <label style={{ color: "#9ca3af", fontSize: 13, display: "block", marginBottom: 6 }}>Tenant</label>
                <select value={form.tenantId} onChange={e => setForm({...form, tenantId: e.target.value})} style={{ width: "100%", background: "#1a1a1a", border: "1px solid #333", borderRadius: 8, padding: "10px 14px", color: "white", fontSize: 14 }}>
                  <option value="">Select tenant</option>
                  {tenants.map(t => <option key={t.id} value={t.id}>{t.name}</option>)}
                </select>
              </div>
              {[["amount","Amount (Rs)"],["monthYear","Month-Year (e.g. 2024-03)"],["notes","Notes (optional)"]].map(([field, label]) => (
                <div key={field} style={{ marginBottom: 16 }}>
                  <label style={{ color: "#9ca3af", fontSize: 13, display: "block", marginBottom: 6 }}>{label}</label>
                  <input value={form[field]} onChange={e => setForm({...form, [field]: e.target.value})} style={{ width: "100%", background: "#1a1a1a", border: "1px solid #333", borderRadius: 8, padding: "10px 14px", color: "white", fontSize: 14, boxSizing: "border-box" }} />
                </div>
              ))}
              <div style={{ display: "flex", gap: 12, marginTop: 8 }}>
                <button onClick={() => setShowForm(false)} style={{ flex: 1, padding: "10px", background: "#1a1a1a", border: "1px solid #333", borderRadius: 8, color: "white", cursor: "pointer" }}>Cancel</button>
                <button onClick={handleSubmit} disabled={loading} style={{ flex: 1, padding: "10px", background: "linear-gradient(135deg, #6366f1, #8b5cf6)", border: "none", borderRadius: 8, color: "white", cursor: "pointer", fontWeight: 600 }}>{loading ? "Saving..." : "Record Payment"}</button>
              </div>
            </div>
          </div>
        )}

        <div style={{ background: "#111", border: "1px solid #1e1e1e", borderRadius: 12, overflow: "hidden" }}>
          <table style={{ width: "100%", borderCollapse: "collapse" }}>
            <thead>
              <tr style={{ borderBottom: "1px solid #1e1e1e" }}>
                {["PROPERTY","TENANT","AMOUNT","MONTH","METHOD","STATUS","TDS"].map(h => (
                  <th key={h} style={{ padding: "14px 20px", textAlign: "left", color: "#6b7280", fontSize: 12, fontWeight: 600 }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {payments.length === 0 ? (
                <tr><td colSpan={7} style={{ color: "#6b7280", textAlign: "center", padding: 48 }}>No payments recorded yet.</td></tr>
              ) : payments.map(p => {
                const sc = statusColor(p.status);
                return (
                  <tr key={p.id} style={{ borderBottom: "1px solid #1a1a1a" }}>
                    <td style={{ padding: "16px 20px", color: "white" }}>{p.propertyName || "-"}</td>
                    <td style={{ padding: "16px 20px", color: "#9ca3af" }}>{p.tenantName || "-"}</td>
                    <td style={{ padding: "16px 20px", color: "#10b981", fontWeight: 600 }}>Rs {p.amount?.toLocaleString()}</td>
                    <td style={{ padding: "16px 20px", color: "#9ca3af" }}>{p.monthYear}</td>
                    <td style={{ padding: "16px 20px", color: "#9ca3af" }}>{p.paymentMethod}</td>
                    <td style={{ padding: "16px 20px" }}>
                      <span style={{ background: sc.bg, color: sc.color, padding: "3px 10px", borderRadius: 20, fontSize: 12, fontWeight: 600 }}>{p.status}</span>
                    </td>
                    <td style={{ padding: "16px 20px" }}>
                      {p.tdsApplicable ? <span style={{ background: "#4a2a00", color: "#f59e0b", padding: "3px 10px", borderRadius: 20, fontSize: 11, fontWeight: 600 }}>TDS ALERT</span> : <span style={{ color: "#4b5563", fontSize: 12 }}>-</span>}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </main>
      <PropBot />
    </div>
  );
}
'@
Set-Content -Path "$src\pages\Rent.jsx" -Value $rent -Encoding UTF8
Write-Host "  [OK] Rent.jsx (new page)" -ForegroundColor Green

# Fix Dashboard - replace rupee symbol with Rs
$dashboard = @'
import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import Sidebar from "../components/Sidebar";
import PropBot from "../components/PropBot";
import { Building2, Users, FileText, Home } from "lucide-react";

const API = "http://localhost:8080";

export default function Dashboard() {
  const { token } = useAuth();
  const [stats, setStats] = useState({ properties: 0, tenants: 0, activeLeases: 0, occupied: 0 });
  const [leases, setLeases] = useState([]);

  useEffect(() => {
    const headers = { Authorization: `Bearer ${token}` };
    fetch(`${API}/api/properties`, { headers }).then(r => r.json()).then(d => {
      const props = d.data || [];
      setStats(s => ({ ...s, properties: props.length, occupied: props.filter(p => p.status === "OCCUPIED").length }));
    }).catch(() => {});
    fetch(`${API}/api/tenants`, { headers }).then(r => r.json()).then(d => {
      setStats(s => ({ ...s, tenants: (d.data || []).length }));
    }).catch(() => {});
    fetch(`${API}/api/leases`, { headers }).then(r => r.json()).then(d => {
      const ls = d.data || [];
      const unique = ls.filter((l, i, a) => a.findIndex(x => x.propertyId === l.propertyId && x.tenantId === l.tenantId) === i);
      setStats(s => ({ ...s, activeLeases: unique.filter(l => l.status === "ACTIVE").length }));
      setLeases(unique.slice(0, 5));
    }).catch(() => {});
  }, []);

  const cards = [
    { label: "Properties", value: stats.properties, icon: <Building2 size={22} />, color: "#6366f1" },
    { label: "Tenants", value: stats.tenants, icon: <Users size={22} />, color: "#8b5cf6" },
    { label: "Active Leases", value: stats.activeLeases, icon: <FileText size={22} />, color: "#06b6d4" },
    { label: "Occupied", value: stats.occupied, icon: <Home size={22} />, color: "#10b981" },
  ];

  return (
    <div style={{ display: "flex", background: "#0a0a0a", minHeight: "100vh" }}>
      <Sidebar />
      <main style={{ marginLeft: 220, flex: 1, padding: 32 }}>
        <div style={{ marginBottom: 32 }}>
          <h1 style={{ color: "white", fontSize: 28, fontWeight: 700, margin: 0 }}>Dashboard</h1>
          <p style={{ color: "#6b7280", margin: "4px 0 0" }}>Overview of your properties</p>
        </div>
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 20, marginBottom: 32 }}>
          {cards.map(c => (
            <div key={c.label} style={{ background: "#111", border: "1px solid #1e1e1e", borderRadius: 16, padding: 24 }}>
              <div style={{ width: 44, height: 44, borderRadius: 12, background: c.color + "22", display: "flex", alignItems: "center", justifyContent: "center", color: c.color, marginBottom: 16 }}>{c.icon}</div>
              <div style={{ color: "white", fontSize: 32, fontWeight: 700 }}>{c.value}</div>
              <div style={{ color: "#6b7280", fontSize: 14, marginTop: 4 }}>{c.label}</div>
            </div>
          ))}
        </div>
        <div style={{ background: "#111", border: "1px solid #1e1e1e", borderRadius: 16, padding: 24 }}>
          <h2 style={{ color: "white", fontSize: 18, fontWeight: 600, margin: "0 0 20px" }}>Recent Leases</h2>
          <table style={{ width: "100%", borderCollapse: "collapse" }}>
            <thead>
              <tr style={{ borderBottom: "1px solid #1e1e1e" }}>
                {["PROPERTY","TENANT","MONTHLY RENT","END DATE","STATUS"].map(h => (
                  <th key={h} style={{ padding: "10px 16px", textAlign: "left", color: "#6b7280", fontSize: 12, fontWeight: 600 }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {leases.length === 0 ? (
                <tr><td colSpan={5} style={{ color: "#6b7280", textAlign: "center", padding: 32 }}>No leases yet.</td></tr>
              ) : leases.map(l => (
                <tr key={l.id} style={{ borderBottom: "1px solid #1a1a1a" }}>
                  <td style={{ padding: "14px 16px", color: "white" }}>{l.propertyName || "-"}</td>
                  <td style={{ padding: "14px 16px", color: "#9ca3af" }}>{l.tenantName || "-"}</td>
                  <td style={{ padding: "14px 16px", color: "#10b981", fontWeight: 600 }}>Rs {l.monthlyRent?.toLocaleString()}</td>
                  <td style={{ padding: "14px 16px", color: "#9ca3af" }}>{l.endDate}</td>
                  <td style={{ padding: "14px 16px" }}>
                    <span style={{ background: l.status === "ACTIVE" ? "#064e3b" : "#1a1a1a", color: l.status === "ACTIVE" ? "#10b981" : "#6b7280", padding: "3px 10px", borderRadius: 20, fontSize: 12, fontWeight: 600 }}>{l.status}</span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </main>
      <PropBot />
    </div>
  );
}
'@
Set-Content -Path "$src\pages\Dashboard.jsx" -Value $dashboard -Encoding UTF8
Write-Host "  [OK] Dashboard.jsx (fixed Rs symbol, deduped leases)" -ForegroundColor Green

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Day 5 complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "React will auto-reload. Check:" -ForegroundColor Yellow
Write-Host "  - Dashboard: Rs symbol fixed, no duplicate leases" -ForegroundColor Yellow
Write-Host "  - Properties: + Add Property form works" -ForegroundColor Yellow
Write-Host "  - Tenants: + Add Tenant form works" -ForegroundColor Yellow
Write-Host "  - Rent: new page at /rent" -ForegroundColor Yellow
