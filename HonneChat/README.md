# Honne（本音）- 没入型AIチャットアプリ

シチュエーションを選んで、その場にワープ。没入感のある空間でAIと本音で語り合うiOSアプリ。

## セットアップ手順

### 1. Xcodeプロジェクト作成

1. Xcode → File → New → Project → iOS → App
2. Product Name: `HonneChat`
3. Interface: **SwiftUI**
4. Language: **Swift**
5. Minimum Deployments: **iOS 16.0**

### 2. ファイルを追加

`HonneChat/HonneChat/` フォルダの中身をXcodeプロジェクトの対応するフォルダにドラッグ＆ドロップ。

```
HonneChat/
├── HonneChatApp.swift        ← エントリポイント
├── Models/
│   ├── Situation.swift        ← シチュエーション定義（17種類）
│   └── ChatMessage.swift      ← メッセージモデル
├── Views/
│   ├── ContentView.swift      ← ルートビュー＋設定画面
│   ├── SituationSelectionView.swift ← ホーム画面（カテゴリ別グリッド）
│   ├── WarpTransitionView.swift     ← ワープアニメーション
│   ├── ChatView.swift         ← チャット画面UI
│   ├── ChatViewModel.swift    ← チャットロジック
│   └── Backgrounds/
│       └── ParticleBackgroundView.swift ← 15種類の背景アニメ
└── Services/
    ├── OpenAIService.swift    ← OpenAI API連携
    └── AudioManager.swift     ← BGM管理
```

### 3. BGM音源を追加（任意）

各シチュエーションに対応するBGMファイルをプロジェクトに追加：

| ファイル名 | シチュエーション | 推奨BGM |
|-----------|--------------|---------|
| starry_night.mp3 | 星空の下 | ピアノ＋バイオリン |
| campfire.mp3 | キャンプファイアー | アコースティックギター |
| sunset_beach.mp3 | 海辺の夕暮れ | アンビエント |
| forest_path.mp3 | 森の中の小道 | 自然音＋フルート |
| fireflies_river.mp3 | 蛍の舞う川辺 | 虫の音＋ピアノ |
| cherry_blossom.mp3 | 桜並木の下 | 箏＋ピアノ |
| aurora.mp3 | オーロラの下 | シンセ＋アンビエント |
| rainy_cafe.mp3 | 雨の日のカフェ | ジャズピアノ |
| night_bar.mp3 | 深夜のバー | ジャズ |
| snowy_window.mp3 | 雪の降る窓辺 | オルゴール |
| library.mp3 | 図書館の片隅 | クラシック（小さめ） |
| hot_spring.mp3 | 温泉の露天風呂 | 三味線＋自然音 |
| rooftop_night.mp3 | 屋上からの夜景 | Lo-fi |
| night_train.mp3 | 深夜の電車 | 電車の音＋アンビエント |
| lantern_festival.mp3 | ランタン祭り | アジアンアンビエント |
| spaceship.mp3 | 宇宙船の窓辺 | スペースアンビエント |
| moonlit_waves.mp3 | 波打ち際の月夜 | 波の音＋ピアノ |

BGMがなくても動作します（チャット機能は使えます）。

### 4. OpenAI APIキーを設定

アプリ内の設定画面（⚙️アイコン）からAPIキーを入力。
APIキーなしでもフォールバックの定型メッセージで動作します。

## 機能一覧

### 17のシチュエーション（4カテゴリ）

**自然**: 星空、キャンプファイアー、海辺の夕暮れ、森の小道、蛍の川辺、桜並木、オーロラ、月夜の波打ち際

**室内**: 雨の日のカフェ、深夜のバー、雪の窓辺、図書館、温泉

**都会**: 屋上の夜景、深夜の電車

**特別**: ランタン祭り、宇宙船

### 各シチュエーションの要素
- SwiftUI Canvasによるリアルタイムパーティクルアニメーション
- シチュエーションごとの専用グラデーション背景
- シチュエーション固有のAIプロンプト（情景描写込み）
- 専用BGM対応

### UX
- ワープアニメーションによるシチュエーション遷移
- 触覚フィードバック
- メッセージのスプリングアニメーション
- タイピングインジケーター
- BGMフェードイン/アウト

## 技術構成

- **SwiftUI** + **Canvas API** (パーティクルシステム)
- **AVFoundation** (BGM)
- **OpenAI Chat Completions API** (gpt-4o-mini)
- **Combine** (リアクティブUI)
- iOS 16+ 対応
