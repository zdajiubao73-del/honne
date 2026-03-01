# チャット画面の最終仕上げ

## 概要
チャット画面の UX 完成度を高める。話題セレクターの初回表示・キーボード表示時のスクロール追従・セッション終了アラートダイアログを実装する。

## 背景
REQUIREMENTS.md §5-2（Screen 2）でチャット画面が「アプリの95%の価値」と定義されている。現在の実装は基本動作するが、FIGMA_SPEC の画面仕様（話題セレクターの初回表示・非対称バブル角丸・タイピングインジケーター）の一部が未統合。

## TODO
- [x] チャット開始時（AIの最初のメッセージ直下）に `TopicSelectorView` を横スクロールで表示する
  - `ChatViewModel` に `showTopicSelector: Bool` プロパティを追加する
  - トピック選択後は `showTopicSelector = false` にしてフェードアウトアニメーションで非表示にする
  - 2回目以降のセッションでは表示しない（`UserDefaults` "honne_hasSeenTopicSelector" で管理）
- [x] 「終わる」タップ時に iOS 標準アラート風のダイアログを表示する
  - 「今日はここまでにしますか？」「続きはいつでも話せます」
  - 「終わる（destructive）」/ 「続ける（cancel）」
- [ ] キーボード表示時にメッセージリストが最下部に追従することを実機で確認する（`ScrollViewReader` の動作確認）
- [ ] 入力欄が4行以上になったときの高さ自動拡張を実機で確認する
- [x] AIのメッセージが来た瞬間の Haptic Feedback（`UIImpactFeedbackGenerator(.light)`）を実装する
- [x] ネットワークエラー時のリトライボタンを表示する（`retry(userState:)` 関数 + `canRetry` フラグ）
- [x] `vm.sessionEnded` になった後、1.5秒待って dismiss するロジックを確認済み
- [x] セーフガード（#004）の UI 統合: 専門機関電話番号がタップ可能な `Link` として表示される（`MessageBubble` で `tel://` リンクを表示）

## 完了条件
- 初回セッションで話題セレクターが表示され、選択後に消える
- 「終わる」でアラートが出て「終わる」を選ぶと感情タグ確認画面に遷移する
- キーボードが開いても最新メッセージが見える位置にスクロールされる

## 依存関係
- 前提: #003（AI会話フェーズ管理）、#004（セーフガード）、#005（感情タグ）
- ブロック: なし

## 関連ファイル
- `honne/Views/Chat/ChatView.swift`
- `honne/Views/Chat/MessageBubble.swift`
- `honne/Views/Chat/TypingIndicatorView.swift`
- `honne/Views/Onboarding/TopicSelectorView.swift`
- `honne/ViewModels/ChatViewModel.swift`
