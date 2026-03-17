import { useState, useEffect } from "react";
import { useAuth } from "../context/AuthContext";
import Sidebar from "../components/Sidebar";
import PropBot from "../components/PropBot";
import { Building2, Users, FileText, Home, TrendingUp } from "lucide-react";

const API = "http://localhost:8080";

function calcScore(property, leases, payments) {
  let score = 100;
  const reasons = [];

  if (property.status !== "OCCUPIED") {
    score -= 30;
    reasons.push("❌ Property is vacant (-30)");
  } else {
    reasons.push("✅ Property is occupied");
  }

  const propLeases = leases.filter(l => l.propertyId === property.id && l.status === "ACTIVE");
  if (propLeases.length === 0) {
    score -= 20;
    reasons.push("❌ No active lease (-20)");
  } else {
    reasons.push("✅ Active lease exists");
  }

  const today = new Date();
  propLeases.forEach(l => {
    const end = new Date(l.endDate);
    const daysLeft = Math.floor((end - today) / (1000 * 60 * 60 * 24));
    if (daysLeft < 30) {
      score -= 15;
      reasons.push(`⚠️ Lease expiring in ${daysLeft} days (-15)`);
    } else {
      reasons.push(`✅ Lease valid for ${daysLeft} more days`);
    }
  });

  return { score: Math.max(0, score), reasons };
}

function HealthScore({ score }) {
  const color = score >= 75 ? "#10b981" : score >= 50 ? "#f59e0b" : "#ef4444";
  const label = score >= 75 ? "Healthy" : score >= 50 ? "Average" : "At Risk";
  const circumference = 2 * Math.PI * 36;
  const offset = circumference - (score / 100) * circumference;
  return (
    <div style={{ display: "flex", flexDirection: "column", alignItems: "center", gap: 6 }}>
      <svg width="90" height="90" viewBox="0 0 90 90">
        <circle cx="45" cy="45" r="36" fill="none" stroke="#1e1e1e" strokeWidth="8" />
        <circle cx="45" cy="45" r="36" fill="none" stroke={color} strokeWidth="8"
          strokeDasharray={circumference} strokeDashoffset={offset}
          strokeLinecap="round" transform="rotate(-90 45 45)" />
        <text x="45" y="50" textAnchor="middle" fill="white" fontSize="16" fontWeight="700">{score}</text>
      </svg>
      <span style={{ color, fontSize: 12, fontWeight: 600 }}>{label}</span>
    </div>
  );
}

export default function Dashboard() {
  const { token } = useAuth();
  const [stats, setStats] = useState({ properties: 0, tenants: 0, activeLeases: 0, occupied: 0 });
  const [leases, setLeases] = useState([]);
  const [properties, setProperties] = useState([]);
  const [payments, setPayments] = useState([]);

  useEffect(() => {
    const headers = { Authorization: `Bearer ${token}` };
    fetch(`${API}/api/properties`, { headers }).then(r => r.json()).then(d => {
      const props = d.data || [];
      setProperties(props);
      setStats(s => ({ ...s, properties: props.length, occupied: props.filter(p => p.status === "OCCUPIED").length }));
    }).catch(() => {});
    fetch(`${API}/api/tenants`, { headers }).then(r => r.json()).then(d => {
      setStats(s => ({ ...s, tenants: (d.data || []).length }));
    }).catch(() => {});
    fetch(`${API}/api/leases`, { headers }).then(r => r.json()).then(d => {
      const ls = d.data || [];
      const unique = ls.filter((l, i, a) => a.findIndex(x => x.propertyId === l.propertyId && x.tenantId === l.tenantId) === i);
      setStats(s => ({ ...s, activeLeases: unique.filter(l => l.status === "ACTIVE").length }));
      setLeases(unique);
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

        {/* Stat Cards */}
        <div style={{ display: "grid", gridTemplateColumns: "repeat(4, 1fr)", gap: 20, marginBottom: 32 }}>
          {cards.map(c => (
            <div key={c.label} style={{ background: "#111", border: "1px solid #1e1e1e", borderRadius: 16, padding: 24 }}>
              <div style={{ width: 44, height: 44, borderRadius: 12, background: c.color + "22", display: "flex", alignItems: "center", justifyContent: "center", color: c.color, marginBottom: 16 }}>{c.icon}</div>
              <div style={{ color: "white", fontSize: 32, fontWeight: 700 }}>{c.value}</div>
              <div style={{ color: "#6b7280", fontSize: 14, marginTop: 4 }}>{c.label}</div>
            </div>
          ))}
        </div>

        {/* Property Health Scores */}
        {properties.length > 0 && (
          <div style={{ background: "#111", border: "1px solid #1e1e1e", borderRadius: 16, padding: 24, marginBottom: 32 }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8, marginBottom: 20 }}>
              <TrendingUp size={18} color="#6366f1" />
              <h2 style={{ color: "white", fontSize: 18, fontWeight: 600, margin: 0 }}>Property Health Score</h2>
              <span style={{ color: "#6b7280", fontSize: 13, marginLeft: 4 }}>AI-powered performance rating · hover to see breakdown</span>
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(200px, 1fr))", gap: 20 }}>
              {properties.map(p => {
                const { score, reasons } = calcScore(p, leases, payments);
                return (
                  <div key={p.id}
                    title={reasons.join("\n")}
                    style={{
                      background: "#0a0a0a", border: "1px solid #1e1e1e", borderRadius: 12,
                      padding: 20, display: "flex", flexDirection: "column", alignItems: "center",
                      gap: 12, cursor: "help"
                    }}>
                    <HealthScore score={score} />
                    <div style={{ textAlign: "center" }}>
                      <div style={{ color: "white", fontWeight: 600, fontSize: 14 }}>{p.name}</div>
                      <div style={{ color: "#6b7280", fontSize: 12, marginTop: 2 }}>{p.address}</div>
                      <div style={{ color: "#9ca3af", fontSize: 12, marginTop: 4 }}>Rs {p.monthlyRent?.toLocaleString()}/mo</div>
                    </div>
                    {/* Score breakdown shown below card */}
                    <div style={{ width: "100%", borderTop: "1px solid #1e1e1e", paddingTop: 10 }}>
                      {reasons.map((r, i) => (
                        <div key={i} style={{ color: "#9ca3af", fontSize: 11, marginBottom: 4, lineHeight: 1.4 }}>{r}</div>
                      ))}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}

        {/* Recent Leases */}
        <div style={{ background: "#111", border: "1px solid #1e1e1e", borderRadius: 16, padding: 24 }}>
          <h2 style={{ color: "white", fontSize: 18, fontWeight: 600, margin: "0 0 20px" }}>Recent Leases</h2>
          <table style={{ width: "100%", borderCollapse: "collapse" }}>
            <thead>
              <tr style={{ borderBottom: "1px solid #1e1e1e" }}>
                {["PROPERTY", "TENANT", "MONTHLY RENT", "END DATE", "STATUS"].map(h => (
                  <th key={h} style={{ padding: "10px 16px", textAlign: "left", color: "#6b7280", fontSize: 12, fontWeight: 600 }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {leases.length === 0 ? (
                <tr><td colSpan={5} style={{ color: "#6b7280", textAlign: "center", padding: 32 }}>No leases yet.</td></tr>
              ) : leases.slice(0, 5).map(l => (
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