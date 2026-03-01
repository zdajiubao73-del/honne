# Free/Pro メッセージ制限（日次リセット）

## 概要
Free プランで1日5メッセージまでの制限を実装し、5通目のAI返答直後に Paywall を表示する。0時を過ぎたら制限をリセットする日次ロジックを実装する。

## 背景
REQUIREMENTS.md §3-1（F08）に「Free プラン: 1日5メッセージまで / 5通目のAI返答直後にPaywallを表示」と定義されている。現在 `UserState.remainingFreeMessages` は存在するが日次リセットが実装されているか不明。

## TODO
- [ ] `UserDefaults` に `lastMessageCountResetDate: Date` を保存する
- [ ] アプリ起動時・フォアグラウンド復帰時に `checkDailyReset()` を呼び出す
  - 今日の日付 ≠ `lastMessageCountResetDate` の場合: `remainingFreeMessages = 5` にリセット
  - `lastMessageCountResetDate` を今日の日付に更新する
- [ ] `ChatViewModel.send()` でメッセージ送信前に Free 制限を確認する
  - `!userState.isPro && userState.remainingFreeMessages <= 0` の場合は送信をブロックし Paywall を表示する
- [ ] AI返答受信後に `remainingFreeMessages -= 1` する（ユーザー側のカウントではなくAI返答ベース）
- [ ] `HomeView` の FREE バッジに残り回数を表示する（例: 「FREE 3回」）
- [ ] 残り1回になったらバッジをより目立つ色にする（white/70 → indigo-300 など）
- [ ] `HomeView` の `checkDailyReset()` も忘れず呼ぶ

## 完了条件
- Free ユーザーが6通目を送ろうとしたら Paywall が表示される
- 日付が変わると制限が5回にリセットされる
- Pro ユーザーは制限なく送信できる

## 依存関係
- 前提: #001（Xcode設定）
- ブロック: #009（RevenueCat連携）、#013（Paywall画面最終仕上げ）

## 関連ファイル
- `honne/Models/UserState.swift`
- `honne/ViewModels/ChatViewModel.swift`
- `honne/ViewModels/HomeViewModel.swift`
- `honne/Views/Home/HomeView.swift`
