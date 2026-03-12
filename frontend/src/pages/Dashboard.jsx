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
            <div className="stat-value">{loading ? "â€”" : s.value}</div>
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
                  <td>â‚¹{l.monthlyRent?.toLocaleString("en-IN")}</td>
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
