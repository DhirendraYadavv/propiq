import { useEffect, useState } from "react";
import { tenantAPI } from "../services/api";
import { Plus, Trash2, Shield } from "lucide-react";
import toast from "react-hot-toast";
import "./Dashboard.css";

export default function Tenants() {
  const [tenants, setTenants] = useState([]);
  const [loading, setLoading] = useState(true);
  const [showModal, setShowModal] = useState(false);
  const [form, setForm] = useState({ name: "", email: "", phone: "", aadhaarNumber: "", panNumber: "" });

  const load = () => tenantAPI.getAll().then((r) => setTenants(r.data.data || [])).finally(() => setLoading(false));
  useEffect(() => { load(); }, []);

  const handleCreate = async (e) => {
    e.preventDefault();
    try {
      await tenantAPI.create(form);
      toast.success("Tenant added!");
      setShowModal(false);
      setForm({ name: "", email: "", phone: "", aadhaarNumber: "", panNumber: "" });
      load();
    } catch (err) { toast.error(err.response?.data?.message || "Failed to add tenant"); }
  };

  const handleDelete = async (id) => {
    if (!confirm("Delete this tenant?")) return;
    try { await tenantAPI.delete(id); toast.success("Deleted"); load(); }
    catch { toast.error("Cannot delete â€” has active lease"); }
  };

  return (
    <div className="page">
      <div className="page-header" style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-start" }}>
        <div><h1>Tenants</h1><p className="page-sub">Aadhaar is always masked for PII protection</p></div>
        <button className="btn btn-primary" onClick={() => setShowModal(true)}><Plus size={16} /> Add Tenant</button>
      </div>
      {loading ? <div style={{ color: "var(--text2)" }}>Loading...</div> : (
        <div className="card" style={{ padding: 0, overflow: "hidden" }}>
          <table className="data-table">
            <thead>
              <tr><th>Name</th><th>Email</th><th>Phone</th><th><Shield size={12} style={{verticalAlign:"middle"}} /> Aadhaar</th><th>PAN</th><th></th></tr>
            </thead>
            <tbody>
              {tenants.map((t) => (
                <tr key={t.id}>
                  <td>
                    <div style={{ display:"flex", alignItems:"center", gap:10 }}>
                      <div style={{ width:32, height:32, borderRadius:"50%", background:"#7c6af720", color:"var(--accent)", display:"flex", alignItems:"center", justifyContent:"center", fontSize:13, fontWeight:600 }}>{t.name?.[0]}</div>
                      {t.name}
                    </div>
                  </td>
                  <td style={{ color:"var(--text2)" }}>{t.email}</td>
                  <td>{t.phone}</td>
                  <td><span style={{ fontFamily:"DM Mono,monospace", fontSize:13 }}>{t.aadhaarNumber || "â€”"}</span></td>
                  <td><span style={{ fontFamily:"DM Mono,monospace", fontSize:13 }}>{t.panNumber || "â€”"}</span></td>
                  <td><button className="btn btn-danger" style={{ padding:"6px 10px" }} onClick={() => handleDelete(t.id)}><Trash2 size={14} /></button></td>
                </tr>
              ))}
              {tenants.length === 0 && <tr><td colSpan={6} style={{ color:"var(--text2)", textAlign:"center", padding:32 }}>No tenants yet.</td></tr>}
            </tbody>
          </table>
        </div>
      )}
      {showModal && (
        <div className="modal-overlay" onClick={() => setShowModal(false)}>
          <div className="modal" onClick={(e) => e.stopPropagation()}>
            <h2>Add Tenant</h2>
            <form onSubmit={handleCreate}>
              <div className="form-group"><label>Full Name</label><input value={form.name} onChange={(e) => setForm({...form, name: e.target.value})} required /></div>
              <div className="form-row">
                <div className="form-group"><label>Email</label><input type="email" value={form.email} onChange={(e) => setForm({...form, email: e.target.value})} required /></div>
                <div className="form-group"><label>Phone</label><input value={form.phone} onChange={(e) => setForm({...form, phone: e.target.value})} /></div>
              </div>
              <div className="form-row">
                <div className="form-group"><label>Aadhaar Number</label><input value={form.aadhaarNumber} onChange={(e) => setForm({...form, aadhaarNumber: e.target.value})} placeholder="12 digits" /></div>
                <div className="form-group"><label>PAN Number</label><input value={form.panNumber} onChange={(e) => setForm({...form, panNumber: e.target.value})} placeholder="ABCDE1234F" /></div>
              </div>
              <div style={{ display:"flex", gap:12, marginTop:8 }}>
                <button type="button" className="btn btn-ghost" style={{ flex:1, justifyContent:"center" }} onClick={() => setShowModal(false)}>Cancel</button>
                <button type="submit" className="btn btn-primary" style={{ flex:1, justifyContent:"center" }}>Add Tenant</button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
