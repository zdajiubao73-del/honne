# RevenueCat 連携（サブスクリプション購入フロー）

## 概要
RevenueCat SDK を使い、App Store の In-App Purchase を実装する。月額¥980の Pro プラン購入・7日間無料トライアル・サブスク状態の管理を行う。

## 背景
REQUIREMENTS.md §10 に Pro プラン（¥980/月・7日間無料トライアル）が定義されている。現在 `PaywallView.handleSubscribe()` には `// TODO: RevenueCat で実装` のコメントがあり未実装。TestFlight 配布前に RevenueCat 接続のみ完了し、App Store 審査後に課金を有効化する。

## TODO
- [ ] App Store Connect で In-App Purchase（自動更新サブスクリプション）を作成する
  - 製品ID: `honne.pro.monthly`
  - 価格: ¥980/月
  - 無料トライアル: 7日間
- [ ] RevenueCat アカウントを作成し、App の API Key を取得する
- [ ] `RevenueCat`（`purchases-ios`）を Swift Package Manager で追加する
- [ ] `PurchaseService.swift` を新規作成し以下を実装する
  - `configure(userId:)`: RevenueCat の初期化
  - `purchase() async throws`: Pro プランの購入処理
  - `restorePurchases() async throws`: 購入復元
  - `checkProStatus() async -> Bool`: Pro ステータスの確認
- [ ] `honneApp.swift` 起動時に `PurchaseService.configure()` を呼び出す
- [ ] `PaywallView.handleSubscribe()` の TODO を `PurchaseService.purchase()` に置き換える
- [ ] 「購入を復元する」ボタンを `PaywallView` の下部に追加する（App Store 審査要件）
- [ ] 購入成功後に `UserState.isPro = true` を設定し Paywall を閉じる
- [ ] アプリ起動時に `checkProStatus()` を呼び出し、課金状態を最新化する

## 完了条件
- テスト環境（Sandbox）で購入フローが完走する
- 購入後に `userState.isPro` が `true` になりメッセージ制限が解除される
- 「購入を復元する」が機能する

## 依存関係
- 前提: #001（Xcode設定）、#007（Free/Pro制限）
- ブロック: #013（Paywall画面最終仕上げ）、#017（TestFlight配布）

## 関連ファイル
- `honne/Services/PurchaseService.swift`（新規作成）
- `honne/Views/Paywall/PaywallView.swift`
- `honne/Models/UserState.swift`
- `honne/honneApp.swift`
