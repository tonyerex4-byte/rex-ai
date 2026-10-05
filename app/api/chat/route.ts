import { NextResponse } from "next/server";

export const runtime = "nodejs";

type ChatMessage = {
  role: "user" | "assistant";
  content: string;
};

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const messages = Array.isArray(body.messages) ? body.messages as ChatMessage[] : [];

    if (!messages.length) {
      return NextResponse.json({ error: "No messages were provided." }, { status: 400 });
    }

    const baseUrl = process.env.OLLAMA_BASE_URL || "http://localhost:11434";
    const model = process.env.OLLAMA_MODEL || "llama3.2";

    const response = await fetch(`${baseUrl.replace(/\/$/, "")}/api/chat`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        model,
        messages,
        stream: false
      }),
      cache: "no-store"
    });

    if (!response.ok) {
      const detail = await response.text();
      return NextResponse.json(
        { error: `Ollama returned ${response.status}. ${detail || "Check that Ollama is running and the model is installed."}` },
        { status: 502 }
      );
    }

    const data = await response.json();
    const message = data?.message?.content;

    if (!message) {
      return NextResponse.json({ error: "Ollama returned an empty response." }, { status: 502 });
    }

    return NextResponse.json({ message });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown server error.";
    return NextResponse.json(
      { error: `Could not connect to Ollama. Make sure Ollama is running at the configured OLLAMA_BASE_URL. (${message})` },
      { status: 503 }
    );
  }
}
