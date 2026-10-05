import { NextResponse } from "next/server";

export async function GET() {
  const baseUrl = process.env.OLLAMA_BASE_URL || "http://localhost:11434";
  const model = process.env.OLLAMA_MODEL || "llama3.2";

  try {
    const response = await fetch(`${baseUrl.replace(/\/$/, "")}/api/tags`, {
      cache: "no-store"
    });
    return NextResponse.json({ ok: response.ok, model, ollama: baseUrl });
  } catch {
    return NextResponse.json({ ok: false, model, ollama: baseUrl }, { status: 503 });
  }
}
