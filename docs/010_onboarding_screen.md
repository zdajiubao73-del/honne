# オンボーディング画面の最終仕上げ

## 概要
初回起動時のオンボーディング3画面を完成させる。「tap anywhere」でのスライド遷移・話題セレクターとの接続・「初回のみ表示」ロジックを実装する。

## 背景
REQUIREMENTS.md §5-2（Screen 1）に3スライド構成が定義されている。現在 `OnboardingView.swift` は基本実装済みだが、Slide 1 の「画面タップで進む」インタラクションと `OnboardingViewModel.canAdvance` の正確な制御が必要。デザイン改善（中央揃え・SafetyItem バッジ）は完了済み。

## TODO
- [ ] Slide 1（`OnboardingPage1View`）で画面全体をタップすると Slide 2 へ進む `onTapGesture` を実装する
- [ ] Slide 3（`TopicSelectorView`）でトピックを選択すると `canAdvance = true` になることを確認する
- [ ] `OnboardingViewModel.canAdvance` の条件を整理する
  - Slide 0・1: 常に `true`（CTAボタン常に有効）
  - Slide 2: トピック選択後のみ `true`
- [ ] `UserState.onboardingCompleted` が `false` の時のみオンボーディングを表示するロジックを `ContentView.swift` に実装する
- [ ] `ContentView.swift` を確認し、`onboardingCompleted` に応じて `OnboardingView` / `HomeView` を切り替える条件分岐を実装する
- [ ] `userState.completeOnboarding()` で `onboardingCompleted = true` を `UserDefaults` に永続化する
- [ ] ページインジケーターが3ドット正確に表示されることを実機で確認する
- [ ] 縦向き（Portrait）固定であることを確認する

## 完了条件
- 初回起動でオンボーディングが表示される
- Slide 1 を画面タップで進める
- 話題を選択して「はじめる」でチャット画面に遷移する
- 2回目の起動ではオンボーディングをスキップしてホームを表示する

## 依存関係
- 前提: #001（Xcode設定）
- ブロック: なし

## 関連ファイル
- `honne/Views/Onboarding/OnboardingView.swift`
- `honne/Views/Onboarding/TopicSelectorView.swift`
- `honne/ViewModels/OnboardingViewModel.swift`
- `honne/ContentView.swift`
- `honne/Models/UserState.swift`
