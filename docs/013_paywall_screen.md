# Paywall 画面の最終仕上げ

## 概要
Paywall 画面を RevenueCat と接続し、「7日間無料で試す」ボタンで実際のサブスクリプション購入フローを起動する。App Store 審査要件の「購入を復元する」ボタンも追加する。

## 背景
REQUIREMENTS.md §5-2（Screen 4）と §10 にPaywall の仕様が詳細定義されている。現在 `handleSubscribe()` には `// TODO: RevenueCat で実装` コメントがあり、直接 `userState.isPro = true` しているだけ。RevenueCat 連携（#009）完了後に本チケットで接続する。

## TODO
- [ ] `PurchaseService.purchase()` を `handleSubscribe()` から呼び出す
- [ ] 購入中はローディングインジケーターを「7日間無料で試す」ボタン上に表示し、ボタンを非活性にする
- [ ] 購入エラー時にユーザーフレンドリーなエラーメッセージをアラートで表示する
  - キャンセル時: 何もしない（エラーとして扱わない）
  - 通信エラー時: 「購入を完了できませんでした。もう一度お試しください」
- [ ] 「購入を復元する」テキストボタンを `PaywallView` 最下部に追加する（App Store 審査必須）
- [ ] Paywall 表示中に背景のチャット画面がインタラクティブにならないよう `interactionDisabled` を設定する
- [ ] Paywall を閉じたとき（「あとで」タップ）に Free 制限のカウントが変わっていないことを確認する
- [ ] A/Bテスト用にメインコピーを差し替えやすい定数化を行う（将来の `Paywallコピー.A` / `Paywallコピー.B`）

## 完了条件
- Sandbox テストユーザーで購入フローが完走する
- 購入中はボタンが非活性になる
- 「購入を復元する」ボタンが表示されている

## 依存関係
- 前提: #009（RevenueCat連携）、#007（Free/Pro制限）
- ブロック: なし

## 関連ファイル
- `honne/Views/Paywall/PaywallView.swift`
- `honne/Services/PurchaseService.swift`
- `honne/Models/UserState.swift`
