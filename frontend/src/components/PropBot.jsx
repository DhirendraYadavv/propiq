import { useState, useRef, useEffect } from "react";
import { X, Send, Bot, Loader } from "lucide-react";
import { propbotAPI } from "../services/api";
import "./PropBot.css";

export default function PropBot({ onClose }) {
  const [messages, setMessages] = useState([
    { role: "bot", text: "Hi! I am PropBot. Ask me anything about Indian rental law â€” TDS, security deposits, eviction rules, lease agreements." }
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
      const res = await propbotAPI.chat(userMsg);
      setMessages((m) => [...m, { role: "bot", text: res.data.reply }]);
    } catch {
      setMessages((m) => [...m, { role: "bot", text: "PropBot unavailable. Make sure it is running on port 8000." }]);
    } finally {
      setLoading(false);
    }
  };

  const handleKey = (e) => { if (e.key === "Enter" && !e.shiftKey) { e.preventDefault(); send(); } };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="bot-window" onClick={(e) => e.stopPropagation()}>
        <div className="bot-header">
          <div className="bot-title"><Bot size={18} /> PropBot AI</div>
          <button className="bot-close" onClick={onClose}><X size={18} /></button>
        </div>
        <div className="bot-messages">
          {messages.map((m, i) => (
            <div key={i} className={`msg ${m.role}`}>
              <div className="msg-bubble">{m.text}</div>
            </div>
          ))}
          {loading && (
            <div className="msg bot">
              <div className="msg-bubble typing"><Loader size={14} className="spin" /> Thinking...</div>
            </div>
          )}
          <div ref={bottomRef} />
        </div>
        <div className="bot-input">
          <input value={input} onChange={(e) => setInput(e.target.value)} onKeyDown={handleKey} placeholder="Ask about TDS, deposits, eviction..." autoFocus />
          <button className="send-btn" onClick={send} disabled={loading}><Send size={16} /></button>
        </div>
      </div>
    </div>
  );
}
