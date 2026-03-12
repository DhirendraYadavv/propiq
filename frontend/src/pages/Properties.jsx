import { useEffect, useState } from "react";
import { propertyAPI } from "../services/api";
import { Plus, Building2, MapPin, Trash2 } from "lucide-react";
import toast from "react-hot-toast";
import "./Dashboard.css";
import "./Properties.css";

export default function Properties() {
  const [properties, setProperties] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({ name: "", address: "", city: "", state: "", type: "APARTMENT", monthlyRent: "" });

  const load = () => propertyAPI.getAll().then((r) => setProperties(r.data.data || [])).finally(() => setLoading(false));
  useEffect(() => { load(); }, []);

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await propertyAPI.create({ ...form, monthlyRent: Number(form.monthlyRent) });
      toast.success("Property added!");
      setShowModal(false);
      setForm({ name: "", address: "", city: "", state: "", type: "APARTMENT", monthlyRent: "" });
      load();
    } catch { toast.error("Failed to add property"); }
  };

  const handleDelete = async (id) => {
    if (!confirm("Delete this property?")) return;
    try { await propertyAPI.delete(id); toast.success("Deleted"); load(); }
    catch { toast.error("Cannot delete â€” has active lease"); }
  };

  return (
    <div className="page">
      <div className="page-header" style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <div><h1>Properties</h1><p className="page-sub">Manage your rental properties</p></div>
        <button className="btn btn-primary" onClick={() => setShowModal(true)}><Plus size={16} /> Add Property</button>
      </div>
      {loading ? <div style={{ color: "var(--text2)" }}>Loading...</div> : (
        <div className="prop-grid">
          {properties.map((p) => (
            <div className="prop-card card" key={p.id}>
              <div className="prop-card-header">
                <div className="prop-icon"><Building2 size={18} /></div>
                <span className={`badge ${p.isOccupied ? "badge-success" : "badge-info"}`}>{p.isOccupied ? "Occupied" : "Vacant"}</span>
              </div>
              <h3 className="prop-name">{p.name}</h3>
              <div className="prop-address"><MapPin size={13} /> {p.address}, {p.city}</div>
              <div className="prop-footer">
                <div className="prop-rent">â‚¹{p.monthlyRent?.toLocaleString("en-IN")}<span>/mo</span></div>
                <button className="btn btn-danger" style={{ padding: "6px 10px" }} onClick={() => handleDelete(p.id)}><Trash2 size={14} /></button>
              </div>
            </div>
          ))}
          {properties.length === 0 && <div style={{ color: "var(--text2)", fontSize: 14 }}>No properties yet.</div>}
        </div>
      )}
      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2>Add Property</h2>
            <form onSubmit={handleCreate}>
              <div className="form-group"><label>Property Name</label><input value={form.name} onChange={(e) => setForm({...form, name: e.target.value})} required /></div>
              <div className="form-group"><label>Address</label><input value={form.address} onChange={(e) => setForm({...form, address: e.target.value})} required /></div>
              <div className="form-row">
                <div className="form-group"><label>City</label><input value={form.city} onChange={(e) => setForm({...form, city: e.target.value})} /></div>
                <div className="form-group"><label>State</label><input value={form.state} onChange={(e) => setForm({...form, state: e.target.value})} /></div>
              </div>
              <div className="form-row">
                <div className="form-group">
                  <label>Type</label>
                  <select value={form.type} onChange={(e) => setForm({...form, type: e.target.value})}>
                    {["APARTMENT","HOUSE","VILLA","COMMERCIAL","PG"].map((t) => <option key={t}>{t}</option>)}
                  </select>
                </div>
                <div className="form-group"><label>Monthly Rent (â‚¹)</label><input type="number" value={form.monthlyRent} onChange={(e) => setForm({...form, monthlyRent: e.target.value})} required /></div>
              </div>
              <div style={{ display: "flex", gap: 12, marginTop: 8 }}>
                <button type="button" className="btn btn-ghost" style={{ flex: 1, justifyContent: "center" }} onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary" style={{ flex: 1, justifyContent: "center" }}>Add Property</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
