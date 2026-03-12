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
