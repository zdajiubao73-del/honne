# TestFlight 配布準備・初期ユーザーテスト

## 概要
TestFlight でエバンジェリストカスタマー10〜30人にアプリを配布し、ショーン・エリス・テストを実施できる状態を作る。PMF 確認まで2週間スプリントで改善を繰り返す。

## 背景
REQUIREMENTS.md §12 に「M4: TestFlight 10人配布（Week 10）」が定義されている。TestFlight 配布 → 計測（AARRR）→ インタビュー → 改善 のサイクルを最低3回回してからApp Store提出する。

## TODO

### TestFlight 配布準備
- [ ] App Store Connect で TestFlight の内部テスト（最大100人）を設定する
- [ ] 招待メールのテンプレートを作成する
  - 「荒削りですが試してください。壊れてもOKです。週1フィードバックをお願いします」
  - インストール手順（TestFlight アプリのDL → 招待メール開封）
- [ ] Phase 0 で確保したエバンジェリストカスタマー3〜5人を最初の配布対象にする
- [ ] 知人・友人を追加し、合計10〜30人に配布する
- [ ] テスト用 Sandbox Apple ID を用意し、課金フロー（RevenueCat）のテストをする

### 計測設定（AARRR）
- [ ] Firebase Analytics（または Mixpanel）でイベント計測を実装する
  - `onboarding_completed`
  - `first_chat_message_sent`
  - `session_completed`
  - `paywall_shown`
  - `purchase_started`
  - `purchase_completed`
- [ ] 7日後リテンション計測のためにセッション完了日時を記録する
- [ ] AHA モーメント計測: 初回セッション完了 → 48時間以内に2回目を開いたか

### ショーン・エリス・テスト（10人配布後）
- [ ] Google フォームでアンケートを作成する
  - 「このアプリがなくなったらどう思いますか？」
  - A: 非常に残念 / B: 少し残念 / C: 残念でない（他の代替がある）
  - フリーコメント欄
- [ ] TestFlight ユーザー全員にアンケートを送付する
- [ ] 「非常に残念」が40%未満の場合: インタビューで理由を深掘りし、最も影響が大きい1点を改善する
- [ ] 2週間スプリントで改善を繰り返す（最大4スプリント = 8週間）

### PMF 達成後の App Store 提出手順
- [ ] ショーン・エリス・テスト 40% 達成を確認する
- [ ] 7日リテンション 40% 以上を確認する
- [ ] #016（App Store審査対応）のチェックリスト全完了を確認する
- [ ] App Store Connect で「審査に提出」をクリックする

## 完了条件
- TestFlight で10人以上がアプリをインストールできる
- ショーン・エリス・テストのアンケートが送付される
- PMF 達成（40%）または4スプリント後に App Store 提出の判断をする

## 依存関係
- 前提: #001（Xcode設定）、#009（RevenueCat）、#010〜013（全画面完成）、#016（審査対応）
- ブロック: App Store リリース（最終マイルストーン）

## 関連ファイル
- App Store Connect（外部サービス）
- `docs/testflight_invitation_template.md`（作成）
- `docs/sean_ellis_test_form.md`（Googleフォーム設計書）
