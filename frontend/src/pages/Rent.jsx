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
