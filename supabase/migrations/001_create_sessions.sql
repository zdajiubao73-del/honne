-- honne: sessions テーブル
-- 匿名ユーザーのセッション（会話単位）を保存する

CREATE TABLE IF NOT EXISTS sessions (
    id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id      UUID NOT NULL,
    started_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ended_at     TIMESTAMPTZ,
    emotion_tags TEXT[]    DEFAULT '{}',
    summary      TEXT,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Row Level Security: 自分のデータのみ参照・操作可能
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert own sessions"
    ON sessions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can select own sessions"
    ON sessions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions"
    ON sessions FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own sessions"
    ON sessions FOR DELETE
    USING (auth.uid() = user_id);

-- インデックス（ユーザー別セッション一覧の高速化）
CREATE INDEX IF NOT EXISTS idx_sessions_user_id ON sessions (user_id);
CREATE INDEX IF NOT EXISTS idx_sessions_started_at ON sessions (started_at DESC);
