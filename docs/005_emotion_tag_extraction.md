# 感情タグ自動付与の完成

## 概要
セッション終了時に OpenAI が感情タグと一言サマリーをJSON形式で返す処理を完成させる。パースエラー時のフォールバックと、結果確認UIへの連携を実装する。

## 背景
`OpenAIService.extractTagsAndSummary()` は実装済みだが、JSONパース失敗時に `([], "")` を返すだけでエラーが握りつぶされている。要件 §6-6 では「最大3つのタグ + サマリー」を保存することが定義されている。セッション終了 → 感情タグ確認画面（Screen 6）への遷移に必要。

## TODO
- [ ] `extractTagsAndSummary()` のエラーハンドリングを改善する（再試行ロジックを1回追加）
- [ ] OpenAI の返答が純粋な JSON でない場合（前後に文章が付く場合）に JSON 部分を抽出する正規表現を実装する
- [ ] タグが1つも取得できなかった場合のデフォルトタグ（「混乱」）を設定する
- [ ] `ChatViewModel.endSession()` で `extractTagsAndSummary()` を呼び出し、`Session` に保存する
- [ ] `StorageService.addSession()` でタグ・サマリー付きセッションを永続化する
- [ ] 感情タグ確認画面（`EmotionTagConfirmationView`）を新規作成する
  - 「今日話してくれてありがとうございました」テキスト
  - 感情タグチップを最大3つ表示
  - 「保存してホームへ」CTAボタン
  - 「このセッションを削除」ボタン（white/30 で目立たせない）
- [ ] 「保存してホームへ」タップ後に HomeView へ遷移し、ストリーク+1 する

## 完了条件
- セッション終了後に感情タグ確認画面が表示される
- タグが正しく表示され、「保存してホームへ」でホームに戻る
- ホームの「今週よく感じたこと」セクションにタグが反映される

## 依存関係
- 前提: #003（AI会話フェーズ管理）
- ブロック: #006（ストリーク管理）、#012（ホーム画面最終仕上げ）

## 関連ファイル
- `honne/Services/OpenAIService.swift`
- `honne/ViewModels/ChatViewModel.swift`
- `honne/Services/StorageService.swift`
- `honne/Views/Session/EmotionTagConfirmationView.swift`（新規作成）
- `honne/Models/Session.swift`
