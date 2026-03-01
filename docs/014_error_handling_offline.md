# エラーハンドリング・オフライン対応

## 概要
ネットワークエラー・APIタイムアウト・オフライン状態を適切に処理し、ユーザーが混乱しないエラー体験を実装する。

## 背景
REQUIREMENTS.md §4-2 に「OpenAI API タイムアウト時のユーザーへのわかりやすいエラーメッセージ」「オフライン時の表示」が定義されている。現在 `ChatViewModel` の `errorMessage` は表示されるが、リトライ手段がない。

## TODO
- [ ] `Network.framework` を使ってオンライン/オフライン状態をリアルタイム監視する `NetworkMonitor.swift` を作成する
- [ ] オフライン時はチャット入力欄の上部に「インターネット接続が必要です」バナーをスライドインで表示する
- [ ] OpenAI APIの5秒タイムアウトを設定する（`URLRequest.timeoutInterval = 5`）
- [ ] タイムアウト時: 「少し時間がかかっています。もう一度試しますか？」とリトライボタンを表示する
- [ ] 連続エラー3回でセッションを安全に終了するフォールバックを実装する
- [ ] Supabase への保存失敗時はローカル保存のみで継続し、次回起動時にリトライする
- [ ] Firebase Crashlytics を初期化し、クラッシュレポートを収集する（ユーザー識別情報は送らない）
- [ ] `APIError` / `NetworkError` の種類を分けてユーザー向けメッセージを日本語で定義する

## 完了条件
- 機内モードで起動するとオフラインバナーが表示される
- AIが5秒以内に返答しない場合、リトライを促すメッセージが出る
- クラッシュが Firebase Crashlytics に記録される

## 依存関係
- 前提: #003（AI会話フェーズ管理）
- ブロック: なし

## 関連ファイル
- `honne/Utils/NetworkMonitor.swift`（新規作成）
- `honne/Services/OpenAIService.swift`
- `honne/ViewModels/ChatViewModel.swift`
- `honne/honneApp.swift`（Firebase 初期化）
