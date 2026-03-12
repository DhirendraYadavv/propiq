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
