import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import Sidebar from "../components/Sidebar";
import PropBot from "../components/PropBot";

const API = "http://15.207.159.218:8080";

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
