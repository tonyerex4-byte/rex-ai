# R3X AI Companion — Ollama Edition

A clean R3X frontend with a custom Next.js backend connected directly to Ollama.

## Requirements

- Node.js 18.18+ (20+ recommended)
- Ollama installed and running
- At least one Ollama model

## 1. Install dependencies

```bash
npm install
```

## 2. Install an Ollama model

For example:

```bash
ollama pull llama3.2
```

You can use another model by changing `OLLAMA_MODEL`.

## 3. Configure environment

Copy `.env.example` to `.env.local`.

Default configuration:

```env
OLLAMA_BASE_URL=http://localhost:11434
OLLAMA_MODEL=llama3.2
NEXT_PUBLIC_APP_NAME=R3X AI Companion
```

If Ollama is running on the same computer as Next.js, the default URL is correct.

## 4. Start R3X

```bash
npm run dev
```

Open:

http://localhost:3000

## Important deployment note

A normal public website cannot directly reach `localhost` on your computer. If you deploy this Next.js app to a cloud host, the backend must be able to reach an Ollama server over a reachable network URL. Do not put an Ollama API key in browser-side code.

## API

POST `/api/chat`

Body:

```json
{
  "messages": [
    { "role": "user", "content": "Hello R3X" }
  ]
}
```

The server forwards the conversation to:

`OLLAMA_BASE_URL/api/chat`

GET `/api/health` checks the Ollama connection.

## Troubleshooting

If the app says it cannot connect to Ollama:

1. Start Ollama.
2. Confirm the Ollama service is listening on port `11434`.
3. Confirm the model exists:
   `ollama list`
4. Pull it if needed:
   `ollama pull llama3.2`
5. Restart `npm run dev`.

No OpenAI, Gemini, or OpenRouter key is required.
