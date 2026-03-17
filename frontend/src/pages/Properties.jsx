import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import Sidebar from "../components/Sidebar";
import PropBot from "../components/PropBot";
import { MapPin } from "lucide-react";

const API = "http://localhost:8080";

export default function Properties() {
  const { token } = useAuth();
  const [properties, setProperties] = useState([]);
  const [showForm, setShowForm] = useState(false);
  const [loading, setLoading] = useState(false);
  const [mapProperty, setMapProperty] = useState(null);
  const [form, setForm] = useState({ name: "", address: "", city: "", state: "", monthlyRent: "", securityDeposit: "", bedrooms: "", bathrooms: "", type: "APARTMENT" });

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
      const body = { name: form.name, address: form.address, city: form.city, state: form.state, type: form.type, monthlyRent: Number(form.monthlyRent), securityDeposit: Number(form.securityDeposit) || 0, bedrooms: Number(form.bedrooms) || 0, bathrooms: Number(form.bathrooms) || 0 };
      const res = await fetch(`${API}/api/properties`, { method: "POST", headers, body: JSON.stringify(body) });
      if (res.ok) { setShowForm(false); setForm({ name: "", address: "", city: "", state: "", monthlyRent: "", securityDeposit: "", bedrooms: "", bathrooms: "", type: "APARTMENT" }); fetchProperties(); }
      else { const d = await res.json(); alert(d.message || "Failed"); }
    } catch (e) { alert("Error: " + e.message); }
    setLoading(false);
  };

  const handleDelete = async (id) => {
    if (!confirm("Delete this property?")) return;
    await fetch(`${API}/api/properties/${id}`, { method: "DELETE", headers });
    fetchProperties();
  };

  const inp = { width: "100%", background: "#1a1a1a", border: "1px solid #333", borderRadius: 8, padding: "10px 14px", color: "white", fontSize: 14, boxSizing: "border-box" };

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
            <div style={{ background: "#111", border: "1px solid #222", borderRadius: 16, padding: 32, width: 480, maxHeight: "85vh", overflowY: "auto" }}>
              <h2 style={{ color: "white", margin: "0 0 24px" }}>Add New Property</h2>
              <div style={{ marginBottom: 16 }}>
                <label style={{ color: "#9ca3af", fontSize: 13, display: "block", marginBottom: 6 }}>Property Type</label>
                <select value={form.type} onChange={e => setForm({...form, type: e.target.value})} style={inp}>
                  <option value="APARTMENT">Apartment</option>
                  <option value="HOUSE">House</option>
                  <option value="VILLA">Villa</option>
                  <option value="COMMERCIAL">Commercial</option>
                  <option value="PG">PG</option>
                </select>
              </div>
              {[["name","Property Name"],["address","Address"],["city","City"],["state","State"],["monthlyRent","Monthly Rent (Rs)"],["securityDeposit","Security Deposit (Rs)"],["bedrooms","Bedrooms"],["bathrooms","Bathrooms"]].map(([field, label]) => (
                <div key={field} style={{ marginBottom: 16 }}>
                  <label style={{ color: "#9ca3af", fontSize: 13, display: "block", marginBottom: 6 }}>{label}</label>
                  <input value={form[field]} onChange={e => setForm({...form, [field]: e.target.value})} style={inp} />
                </div>
              ))}
              <div style={{ display: "flex", gap: 12, marginTop: 8 }}>
                <button onClick={() => setShowForm(false)} style={{ flex: 1, padding: "10px", background: "#1a1a1a", border: "1px solid #333", borderRadius: 8, color: "white", cursor: "pointer" }}>Cancel</button>
                <button onClick={handleSubmit} disabled={loading} style={{ flex: 1, padding: "10px", background: "linear-gradient(135deg, #6366f1, #8b5cf6)", border: "none", borderRadius: 8, color: "white", cursor: "pointer", fontWeight: 600 }}>{loading ? "Saving..." : "Save Property"}</button>
              </div>
            </div>
          </div>
        )}

        {mapProperty && (
          <div style={{ position: "fixed", inset: 0, background: "rgba(0,0,0,0.8)", display: "flex", alignItems: "center", justifyContent: "center", zIndex: 1000 }}>
            <div style={{ background: "#111", border: "1px solid #222", borderRadius: 16, padding: 24, width: 640, maxWidth: "90vw" }}>
              <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: 16 }}>
                <div>
                  <h3 style={{ color: "white", margin: 0 }}>{mapProperty.name}</h3>
                  <p style={{ color: "#6b7280", margin: "4px 0 0", fontSize: 13 }}>{mapProperty.address}, {mapProperty.city}</p>
                </div>
                <button onClick={() => setMapProperty(null)} style={{ background: "#1a1a1a", border: "1px solid #333", color: "white", borderRadius: 8, padding: "6px 14px", cursor: "pointer" }}>Close</button>
              </div>
              <iframe width="100%" height="350" style={{ border: 0, borderRadius: 12 }} src={`https://maps.google.com/maps?q=${encodeURIComponent(mapProperty.address + ", " + mapProperty.city + ", India")}&output=embed`} allowFullScreen title="map" />
              <a href={`https://www.google.com/maps/search/${encodeURIComponent(mapProperty.address + ", " + mapProperty.city + ", India")}`} target="_blank" rel="noreferrer" style={{ display: "block", textAlign: "center", marginTop: 12, color: "#6366f1", fontSize: 13 }}>Open in Google Maps</a>
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
                {p.type && <span style={{ marginLeft: 12, color: "#6b7280", fontSize: 12 }}>{p.type}</span>}
              </div>
              <div style={{ display: "flex", alignItems: "center", gap: 12 }}>
                <span style={{ background: p.status === "OCCUPIED" ? "#064e3b" : "#1e3a5f", color: p.status === "OCCUPIED" ? "#10b981" : "#60a5fa", padding: "4px 12px", borderRadius: 20, fontSize: 12, fontWeight: 600 }}>{p.status || "VACANT"}</span>
                <button onClick={() => setMapProperty(p)} style={{ background: "#1a1a2e", border: "1px solid #2a2a4e", color: "#6366f1", borderRadius: 8, padding: "6px 14px", cursor: "pointer", fontSize: 13, display: "flex", alignItems: "center", gap: 4 }}><MapPin size={14} /> Map</button>
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
