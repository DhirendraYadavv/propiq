import { useState, useRef, useEffect } from "react";
import { X, Send, Bot, Loader } from "lucide-react";
import "./PropBot.css";

export default function PropBot() {
  const [open, setOpen] = useState(false);
  const [messages, setMessages] = useState([
    { role: "bot", text: "Hi! I am PropBot. Ask me anything about your properties or Indian rental law - TDS, security deposits, eviction rules, lease agreements." }
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const bottomRef = useRef(null);

  useEffect(() => { bottomRef.current?.scrollIntoView({ behavior: "smooth" }); }, [messages]);

  const send = async () => {
    if (!input.trim() || loading) return;
    const userMsg = input.trim();
    setInput("");
    setMessages((m) => [...m, { role: "user", text: userMsg }]);
    setLoading(true);
    try {
      const token = localStorage.getItem("token") || "";
      const res = await fetch(`http://localhost:8000/chat`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: userMsg, token })
      });
      const data = await res.json();
      setMessages((m) => [...m, { role: "bot", text: data.reply }]);
    } catch {
      setMessages((m) => [...m, { role: "bot", text: "PropBot unavailable. Make sure it is running on port 8000." }]);
    } finally {
      setLoading(false);
    }
  };

  const handleKey = (e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); send(); } };

  return (
    <>
      {!open && (
        <button onClick={() => setOpen(true)} style={{
          position: "fixed", bottom: 24, right: 24, background: "linear-gradient(135deg, #6366f1, #8b5cf6)",
          color: "white", border: "none", borderRadius: 50, padding: "14px 20px", cursor: "pointer",
          fontSize: 14, fontWeight: 600, display: "flex", alignItems: "center", gap: 8,
          boxShadow: "0 4px 20px rgba(99,102,241,0.4)", zIndex: 999
        }}>
          <Bot size={18} /> PropBot
        </button>
      )}

      {open && (
        <div style={{
          position: "fixed", bottom: 24, right: 24, width: 380, height: 500,
          background: "#111", border: "1px solid #222", borderRadius: 16,
          display: "flex", flexDirection: "column", zIndex: 1000,
          boxShadow: "0 8px 32px rgba(0,0,0,0.5)"
        }}>
          <div style={{ padding: "16px 20px", borderBottom: "1px solid #222", display: "flex", alignItems: "center", justifyContent: "space-between" }}>
            <div style={{ display: "flex", alignItems: "center", gap: 8, color: "#6366f1", fontWeight: 600 }}>
              <Bot size={18} /> PropBot AI
            </div>
            <button onClick={() => setOpen(false)} style={{ background: "none", border: "none", color: "#6b7280", cursor: "pointer", padding: 4 }}>
              <X size={18} />
            </button>
          </div>

          <div style={{ flex: 1, overflowY: "auto", padding: 16, display: "flex", flexDirection: "column", gap: 12 }}>
            {messages.map((m, i) => (
              <div key={i} style={{ display: "flex", justifyContent: m.role === "user" ? "flex-end" : "flex-start" }}>
                <div style={{
                  maxWidth: "80%", padding: "10px 14px", borderRadius: 12, fontSize: 14, lineHeight: 1.5,
                  background: m.role === "user" ? "#6366f1" : "#1a1a2e",
                  color: "white"
                }}>{m.text}</div>
              </div>
            ))}
            {loading && (
              <div style={{ display: "flex" }}>
                <div style={{ background: "#1a1a2e", color: "#9ca3af", padding: "10px 14px", borderRadius: 12, fontSize: 14, display: "flex", alignItems: "center", gap: 8 }}>
                  <Loader size={14} /> Thinking...
                </div>
              </div>
            )}
            <div ref={bottomRef} />
          </div>

          <div style={{ padding: "12px 16px", borderTop: "1px solid #222", display: "flex", gap: 8 }}>
            <input
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={handleKey}
              placeholder="Ask about your properties, TDS, deposits..."
              style={{ flex: 1, background: "#1a1a1a", border: "1px solid #333", borderRadius: 8, padding: "10px 14px", color: "white", fontSize: 14, outline: "none" }}
              autoFocus
            />
            <button onClick={send} disabled={loading} style={{ background: "#6366f1", border: "none", borderRadius: 8, padding: "10px 14px", color: "white", cursor: "pointer" }}>
              <Send size={16} />
            </button>
          </div>
        </div>
      )}
    </>
  );
}