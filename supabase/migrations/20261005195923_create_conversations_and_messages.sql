/*
# Create conversations and messages tables

## Purpose
R3X AI Companion is a chat app that talks to a local Ollama model.
Previously, conversations lived only in browser memory and were lost on
reload. This migration gives R3X a persistent database so chat history
survives across sessions.

## 1. New Tables

### conversations
- `id` (uuid, primary key) — unique identifier for a chat session
- `title` (text, not null) — a short label shown in the conversation list,
  defaulting to "New conversation" until the user renames it
- `created_at` (timestamptz) — when the conversation was started
- `updated_at` (timestamptz) — when the conversation was last touched,
  updated automatically on every message write

### messages
- `id` (uuid, primary key) — unique identifier for a single message
- `conversation_id` (uuid, foreign key → conversations.id, on delete cascade)
  — the conversation this message belongs to. Deleting a conversation removes
  all of its messages automatically.
- `role` (text, not null, check constraint) — either "user" or "assistant",
  matching the Ollama chat format
- `content` (text, not null) — the message text
- `created_at` (timestamptz) — when the message was stored

## 2. Indexes
- `messages_conversation_id_idx` on messages.conversation_id for fast
  retrieval of all messages in a conversation
- `conversations_updated_at_idx` on conversations.updated_at (desc) so the
  conversation list can be sorted by most-recent efficiently

## 3. Security (Row Level Security)
This app has no sign-in screen, so the frontend always talks to the database
as the `anon` role. All policies use `TO anon, authenticated` with
`USING (true)` / `WITH CHECK (true)` because the data is intentionally
shared/public (single-tenant app). RLS is enabled on both tables as required.

## 4. Notes
- `updated_at` auto-refreshes via a trigger so the conversation list always
  reflects the latest activity without application code.
- No user_id columns or auth references — this is a single-tenant app.
*/

CREATE TABLE IF NOT EXISTS conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL DEFAULT 'New conversation',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id uuid NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('user', 'assistant')),
  content text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS messages_conversation_id_idx ON messages(conversation_id);
CREATE INDEX IF NOT EXISTS conversations_updated_at_idx ON conversations(updated_at DESC);

-- Auto-update conversations.updated_at when a new message is inserted
CREATE OR REPLACE FUNCTION touch_conversation_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  UPDATE conversations SET updated_at = now() WHERE id = NEW.conversation_id;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS messages_touch_conversation ON messages;
CREATE TRIGGER messages_touch_conversation
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION touch_conversation_updated_at();

-- RLS: conversations (single-tenant, no auth)
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_conversations" ON conversations;
CREATE POLICY "anon_select_conversations" ON conversations FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_conversations" ON conversations;
CREATE POLICY "anon_insert_conversations" ON conversations FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_conversations" ON conversations;
CREATE POLICY "anon_update_conversations" ON conversations FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_conversations" ON conversations;
CREATE POLICY "anon_delete_conversations" ON conversations FOR DELETE
  TO anon, authenticated USING (true);

-- RLS: messages (single-tenant, no auth)
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_messages" ON messages;
CREATE POLICY "anon_select_messages" ON messages FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_messages" ON messages;
CREATE POLICY "anon_insert_messages" ON messages FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_messages" ON messages;
CREATE POLICY "anon_update_messages" ON messages FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_messages" ON messages;
CREATE POLICY "anon_delete_messages" ON messages FOR DELETE
  TO anon, authenticated USING (true);
