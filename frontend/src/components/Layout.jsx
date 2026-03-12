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
