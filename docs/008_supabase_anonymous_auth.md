# Supabase 匿名認証の実装

## 概要
Supabase の Anonymous Sign-in を使い、名前・メールアドレスなしでデバイス固有のUUIDを発行する。会話履歴をサーバー側に暗号化保存し、機種変更時のデータ引き継ぎを可能にする基盤を作る。

## 背景
REQUIREMENTS.md §7-3 に「Supabase 匿名認証でUUIDを発行」「会話履歴をPostgreSQLに暗号化保存」と定義されている。現在は `UserDefaults` のみのローカル管理で、端末を替えると履歴が消える。v1.0 の匿名性担保・データ保護要件に必須。

## TODO
- [ ] Supabase Swift SDK（`supabase-swift`）を Swift Package Manager で追加する
- [ ] `AuthService.swift` を新規作成し以下を実装する
  - `signInAnonymously()`: 匿名サインイン（初回のみ実行、以降はセッション継続）
  - `currentUserId: UUID?`: 現在のユーザーID
  - `signOut()`: セッション破棄
- [ ] アプリ起動時（`honneApp.swift`）に `AuthService.signInAnonymously()` を呼び出す
- [ ] Supabase に `sessions` テーブルを作成する
  ```sql
  CREATE TABLE sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    started_at TIMESTAMPTZ,
    ended_at TIMESTAMPTZ,
    emotion_tags TEXT[],
    summary TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
  );
  ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
  CREATE POLICY "Users can only see own sessions"
    ON sessions FOR ALL USING (auth.uid() = user_id);
  ```
- [ ] `StorageService` を拡張し、セッション完了時に Supabase にも保存する（ローカルと二重保存）
- [ ] `messages` テーブルも作成し、Pro ユーザーの会話履歴をサーバーに保存する（Free は端末のみ）

## 完了条件
- 初回起動時に Supabase に匿名ユーザーが作成される
- セッション完了後に Supabase の `sessions` テーブルにレコードが追加される
- Row Level Security が有効で、他ユーザーのデータにアクセスできない

## 依存関係
- 前提: #002（OpenAI セキュア管理 / Supabase プロジェクト作成済み）
- ブロック: なし

## 関連ファイル
- `honne/Services/AuthService.swift`（新規作成）
- `honne/Services/StorageService.swift`
- `honne/honneApp.swift`
- `supabase/migrations/001_create_sessions.sql`（新規作成）
