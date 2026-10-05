"use client";

import { FormEvent, useState } from "react";

type Message = {
  role: "user" | "assistant";
  content: string;
};

export default function Home() {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState("");
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState("");

  async function sendMessage(e: FormEvent) {
    e.preventDefault();
    const text = input.trim();
    if (!text || busy) return;

    const next = [...messages, { role: "user" as const, content: text }];
    setMessages(next);
    setInput("");
    setError("");
    setBusy(true);

    try {
      const res = await fetch("/api/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ messages: next })
      });

      const data = await res.json();

      if (!res.ok) {
        throw new Error(data.error || "The AI request failed.");
      }

      setMessages([...next, { role: "assistant", content: data.message }]);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Something went wrong.");
    } finally {
      setBusy(false);
    }
  }

  return (
    <main className="shell">
      <section className="welcome">
        <div className="glow" />
        <div className="brand">
          <div className="logo">R3X</div>
          <div>
            <h1>R3X</h1>
            <p>AI COMPANION</p>
          </div>
        </div>
        <h2>Hey, I&apos;m R3X.</h2>
        <p className="tagline">Your AI companion, powered privately by Ollama.</p>
      </section>

      <section className="chatCard">
        <header className="chatHeader">
          <div className="statusDot" />
          <div>
            <strong>R3X Chat</strong>
            <span>Ollama connection</span>
          </div>
          <button onClick={() => setMessages([])} className="clear">Clear</button>
        </header>

        <div className="messages">
          {messages.length === 0 ? (
            <div className="empty">
              <div className="emptyLogo">R3X</div>
              <h3>Ask me anything</h3>
              <p>Start a conversation with your local AI.</p>
            </div>
          ) : messages.map((m, i) => (
            <div key={i} className={`bubbleRow ${m.role}`}>
              <div className="bubble">{m.content}</div>
            </div>
          ))}
          {busy && <div className="bubbleRow assistant"><div className="bubble typing">R3X is thinking…</div></div>}
        </div>

        <form className="composer" onSubmit={sendMessage}>
          <textarea
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="Message R3X..."
            rows={1}
            onKeyDown={(e) => {
              if (e.key === "Enter" && !e.shiftKey) {
                e.preventDefault();
                e.currentTarget.form?.requestSubmit();
              }
            }}
          />
          <button className="send" disabled={busy || !input.trim()} aria-label="Send">
            ↑
          </button>
        </form>
        {error && <div className="error">{error}</div>}
        <p className="privacy">Local AI • Ollama • No OpenAI key required</p>
      </section>
    </main>
  );
}
