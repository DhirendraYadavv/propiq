import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import Sidebar from "../components/Sidebar";
import PropBot from "../components/PropBot";
import { Building2, Users, FileText, Home } from "lucide-react";

const API = "http://15.207.159.218:8080";

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
