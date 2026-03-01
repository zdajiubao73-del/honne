# OpenAI APIキーのセキュア管理

## 概要
現在 `Constants.swift` にハードコードされている OpenAI APIキーを、セキュリティ要件に準拠した管理方法に移行する。本番では Supabase Edge Functions 経由で API を呼び出し、クライアントに APIキーを露出させない。

## 背景
REQUIREMENTS.md §9（セキュリティ要件）に「APIキーはクライアントコードに直接記述しない（Keychain / Edge Functions経由）」と定義されている。現状 `Constants.openAIAPIKey = "YOUR_OPENAI_API_KEY"` と直書きされており、TestFlight 配布前に必ず解消が必要。

## TODO
- [ ] Supabase プロジェクトを作成し、接続情報（URL / anon key）を取得する
- [ ] Supabase Edge Function `chat-completion` を作成する
  - リクエスト: `{ messages: [...] }`
  - 内部で `OPENAI_API_KEY` 環境変数を参照して OpenAI API を呼び出す
  - レスポンス: `{ content: string }`
- [ ] Supabase Dashboard で `OPENAI_API_KEY` を Secrets に登録する
- [ ] `OpenAIService.swift` のエンドポイントを Supabase Edge Function の URL に変更する
- [ ] Supabase の anon key を `Keychain` に保存し、`Constants.swift` から削除する
- [ ] `KeychainService.swift` を新規作成し `save / load / delete` メソッドを実装する
- [ ] 開発環境用に `.env.local`（gitignore対象）でキー管理する手順をREADMEに記載する

## 完了条件
- `Constants.swift` にAPIキーの文字列が一切残っていない
- Supabase Edge Function 経由で OpenAI と正常に通信できる
- `git log` に APIキーが含まれていない（既存コミットも確認）

## 依存関係
- 前提: #001（Xcode プロジェクト設定）
- ブロック: #003（AI会話フェーズ管理）、#008（Supabase匿名認証）

## 関連ファイル
- `honne/Services/OpenAIService.swift`
- `honne/Utils/Constants.swift`
- `honne/Services/KeychainService.swift`（新規作成）
- `supabase/functions/chat-completion/index.ts`（新規作成）
