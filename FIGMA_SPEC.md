# honne - Figma実装仕様書 v1.0

> 対象: Figmaデザイナー / SwiftUI実装者
> 更新日: 2026-02-27
> デバイス基準: iPhone 15 Pro (390 × 844pt / @3x)

---

## デザインシステム

### カラーパレット（全変数）

Figmaの `Local Variables` パネルに以下を登録する。
コレクション名: **honne/colors**

#### Primitives（生の色）

| 変数名 | HEX / RGB | 用途メモ |
|---|---|---|
| `primitive/night-900` | `#0D0D1A` | アプリ背景（最暗） |
| `primitive/night-800` | `#111127` | Paywallシート背景 |
| `primitive/night-700` | `#16162F` | ホバー・選択背景 |
| `primitive/indigo-600` | `#4F46E5` | メインアクション色 |
| `primitive/indigo-500` | `#6366F1` | グラデーション終端 |
| `primitive/indigo-300` | `#A5B4FC` | 価格ラベル・強調 |
| `primitive/white` | `#FFFFFF` | ベースホワイト |
| `primitive/red-400` | `#F87171` | 破壊的アクション（「終わる」） |

#### Semantic（意味付きトークン）

| 変数名 | 参照先 / Alpha | 実RGBA値 | 用途 |
|---|---|---|---|
| `color/bg/app` | `primitive/night-900` | `rgba(13,13,26,1.0)` | 全画面の背景 |
| `color/bg/sheet` | `primitive/night-800` | `rgba(17,17,39,1.0)` | Paywallシート背景 |
| `color/bg/bubble-ai` | `primitive/white` @ 6% | `rgba(255,255,255,0.06)` | AIバブル背景 |
| `color/bg/bubble-user` | `primitive/indigo-600` @ 80% | `rgba(79,70,229,0.80)` | ユーザーバブル背景 |
| `color/bg/input` | `primitive/white` @ 6% | `rgba(255,255,255,0.06)` | テキストフィールド背景 |
| `color/bg/chip` | `primitive/white` @ 6% | `rgba(255,255,255,0.06)` | 感情タグ・チップ背景 |
| `color/border/default` | `primitive/white` @ 8% | `rgba(255,255,255,0.08)` | バブル・カード枠線 |
| `color/border/chip` | `primitive/white` @ 20% | `rgba(255,255,255,0.20)` | 話題セレクター枠線 |
| `color/border/divider` | `primitive/white` @ 8% | `rgba(255,255,255,0.08)` | 区切り線 |
| `color/text/primary` | `primitive/white` @ 90% | `rgba(255,255,255,0.90)` | 大見出し |
| `color/text/body` | `primitive/white` @ 85% | `rgba(255,255,255,0.85)` | 本文・AIバブルテキスト |
| `color/text/secondary` | `primitive/white` @ 60% | `rgba(255,255,255,0.60)` | 補足テキスト |
| `color/text/tertiary` | `primitive/white` @ 50% | `rgba(255,255,255,0.50)` | タイムスタンプ・ラベル |
| `color/text/muted` | `primitive/white` @ 40% | `rgba(255,255,255,0.40)` | 解約テキスト・サブCTA |
| `color/text/disabled` | `primitive/white` @ 30% | `rgba(255,255,255,0.30)` | placeholder・hint |
| `color/text/chip` | `primitive/white` @ 70% | `rgba(255,255,255,0.70)` | 話題セレクターラベル |
| `color/text/price` | `primitive/indigo-300` | `rgba(165,180,252,1.0)` | 価格バッジ |
| `color/text/destructive` | `primitive/red-400` | `rgba(248,113,113,1.0)` | 「終わる」テキスト |
| `color/text/action` | `primitive/indigo-300` | `rgba(165,180,252,1.0)` | 「続ける」テキスト（アラート） |
| `color/cta/gradient-start` | `primitive/indigo-600` | `rgba(79,70,229,1.0)` | CTAボタン左端 |
| `color/cta/gradient-end` | `primitive/indigo-500` | `rgba(99,102,241,1.0)` | CTAボタン右端 |
| `color/send-btn/active` | `primitive/indigo-500` | `rgba(99,102,241,1.0)` | 送信ボタン（入力あり） |
| `color/send-btn/inactive` | `primitive/white` @ 10% | `rgba(255,255,255,0.10)` | 送信ボタン（空） |
| `color/navbar/bg` | `primitive/night-900` @ 95% | `rgba(13,13,26,0.95)` | NavigationBar背景 |
| `color/streak/card-bg` | `primitive/white` @ 4% | `rgba(255,255,255,0.04)` | ストリークカード背景 |

#### グラデーション定義

| 名前 | 方向 | カラーストップ |
|---|---|---|
| `gradient/cta` | 左→右 (90°) | 0%: `#4F46E5`, 100%: `#6366F1` |
| `gradient/cta-vertical` | 上→下 (180°) | 0%: `#4F46E5`, 100%: `#6366F1` |

#### Blur（Figmaの Effects > Background blur）

| 変数名 | 値 | 適用先 |
|---|---|---|
| `blur/glass` | 20px | AIメッセージバブル |
| `blur/navbar` | 12px | NavigationBar |

---

### タイポグラフィスケール

Figmaの `Local Styles > Text Styles` に登録する。
フォントファミリー: **SF Pro** (Figma上では `.SF Pro Display` / `.SF Pro Text` を使用)

| スタイル名 | フォント | サイズ | ウェイト | 行間 (Line Height) | Letter Spacing | 用途 |
|---|---|---|---|---|---|---|
| `type/hero` | SF Pro Display | 34px | Bold (700) | 40px (118%) | -0.5px | ストリーク数値 |
| `type/heading-lg` | SF Pro Display | 28px | Bold (700) | 34px (121%) | -0.3px | 大見出し |
| `type/heading-md` | SF Pro Display | 26px | Semibold (600) | 32px (123%) | -0.3px | Paywallメインコピー |
| `type/heading-sm` | SF Pro Display | 22px | Regular (400) | 37px (168%) | 0px | オンボーディング問いかけ |
| `type/section` | SF Pro Text | 20px | Semibold (600) | 24px (120%) | -0.2px | セクション見出し |
| `type/alert-title` | SF Pro Text | 17px | Semibold (600) | 22px (129%) | -0.2px | アラートタイトル |
| `type/nav` | SF Pro Text | 16px | Semibold (600) | 20px (125%) | -0.2px | NavigationBar |
| `type/body` | SF Pro Text | 16px | Regular (400) | 26px (162%) | 0px | チャット本文・本文 |
| `type/cta` | SF Pro Text | 17px | Semibold (600) | 22px (129%) | -0.2px | CTAボタン |
| `type/price` | SF Pro Text | 20px | Semibold (600) | 24px (120%) | -0.2px | 価格表示 |
| `type/onboarding-security` | SF Pro Text | 16px | Regular (400) | 32px (200%) | 0px | 安心ポイントリスト |
| `type/label` | SF Pro Text | 14px | Regular (400) | 20px (143%) | 0px | チップラベル・補足 |
| `type/caption` | SF Pro Text | 13px | Regular (400) | 18px (138%) | 0px | 補足・タグ |
| `type/caption-sm` | SF Pro Text | 12px | Regular (400) | 16px (133%) | 0px | 最小テキスト（解約等） |
| `type/hint` | SF Pro Text | 13px | Regular (400) | 18px (138%) | 0px | placeholder・ヒント |
| `type/emotion-chip` | SF Pro Text | 13px | Regular (400) | 18px (138%) | 0px | 感情タグ内テキスト |
| `type/topic-chip` | SF Pro Text | 14px | Regular (400) | 20px (143%) | 0px | 話題セレクターチップ |
| `type/continue-hint` | SF Pro Text | 13px | Regular (400) | 18px (138%) | 0px | 「tap anywhere to continue」 |
| `type/session-end` | SF Pro Text | 18px | Regular (400) | 26px (144%) | -0.1px | セッション終了メッセージ |
| `type/alert-body` | SF Pro Text | 14px | Regular (400) | 20px (143%) | 0px | アラート本文 |

---

### スペーシング

Figmaの `Local Variables > Spacing` コレクションに登録する。

| 変数名 | 値 | 用途 |
|---|---|---|
| `spacing/2` | 2px | 最小マージン |
| `spacing/4` | 4px | 極小間隔 |
| `spacing/6` | 6px | アイコン内パディング |
| `spacing/8` | 8px | チップ間・小間隔 |
| `spacing/10` | 10px | バブル縦パディング |
| `spacing/12` | 12px | メッセージ間・リスト行間 |
| `spacing/14` | 14px | 小ボタンパディング |
| `spacing/16` | 16px | 標準水平パディング |
| `spacing/20` | 20px | セクション間 |
| `spacing/24` | 24px | カード内パディング小 |
| `spacing/28` | 28px | --- |
| `spacing/32` | 32px | カード内パディング・大セクション間 |
| `spacing/44` | 44px | NavigationBar高さ・テキストフィールド右パディング |
| `spacing/48` | 48px | 水平マージン（CTAボタン） |
| `spacing/56` | 56px | CTAボタン高さ |
| `spacing/100` | 100px | オンボーディング上部余白（スライド2） |
| `spacing/120` | 120px | オンボーディング上部余白（スライド1） |
| `safearea/top` | 59px | iPhone 15 Pro Dynamic Island上部SafeArea |
| `safearea/bottom` | 34px | iPhone 15 Pro下部SafeArea |

---

### コンポーネント一覧

Figmaの `Assets` パネルに以下のコンポーネントを作成する。
ページ: **Components** に全コンポーネントを集約する。

| コンポーネント名 | バリアント | 説明 |
|---|---|---|
| `CTAButton` | State: Default / Pressed | フルワイドCTAボタン |
| `MessageBubble/AI` | State: Default / Typing | AIメッセージバブル |
| `MessageBubble/User` | State: Default | ユーザーメッセージバブル |
| `TopicChip` | State: Default / Selected | 話題セレクターチップ |
| `EmotionTag` | — | 感情タグ（#疲れ など） |
| `SendButton` | State: Active / Inactive | 送信ボタン |
| `InputField` | State: Empty / Filled | テキスト入力フィールド |
| `InputArea` | State: Empty / Filled | 入力エリア全体（InputField + SendButton） |
| `NavigationBar` | — | チャット画面上部バー |
| `StreakCard` | — | 連続記録カード |
| `TypingIndicator` | — | AIタイピング中ドット |
| `AlertDialog` | — | セッション終了確認アラート |
| `OnboardingSecurityItem` | — | 安心ポイント1行 |
| `PaywallBenefitItem` | — | 特典リスト1行 |
| `PaywallHandle` | — | シートのドラッグハンドル |
| `SectionDivider` | — | 区切り線 |

---

## 画面仕様

> フレームサイズ: 390 × 844px（iPhone 15 Pro）
> 全画面の背景色: `color/bg/app` = `#0D0D1A`

---

### Screen 1: オンボーディング

---

#### 1-1 スライド1

**フレーム名:** `Onboarding/Slide1`
**サイズ:** 390 × 844px

**レイヤー構成（上から順）:**

```
Frame: Onboarding/Slide1 [390×844, fill: color/bg/app]
  ├── Rectangle: StatusBar-spacer [390×59, fill: transparent] ← SafeArea Top
  ├── Text: MainQuestion [幅280px, 中央配置]
  │     コンテンツ: 「夜、誰かに話を聞いてほしくなることはありますか？」
  │     スタイル: type/heading-sm (22px / Regular)
  │     色: color/text/primary (white/90)
  │     揃え: Center
  │     上端Y座標: 120px (StatusBarを含めた絶対値)
  │     X: (390-280)/2 = 55px
  └── Text: ContinueHint [幅: auto, 中央配置]
        コンテンツ: 「tap anywhere to continue」
        スタイル: type/continue-hint (13px / Regular)
        色: color/text/disabled (white/30)
        揃え: Center
        下端Y座標: 844 - 34 (SafeArea) - 40 = 770px
```

**インタラクション:**
- 画面全体: タップ → スライド2へ遷移
- 遷移アニメーション: Smart Animate / Dissolve / 300ms / Ease Out

---

#### 1-2 スライド2

**フレーム名:** `Onboarding/Slide2`
**サイズ:** 390 × 844px

**レイヤー構成:**

```
Frame: Onboarding/Slide2 [390×844, fill: color/bg/app]
  ├── Rectangle: StatusBar-spacer [390×59]
  ├── Group: SecurityList [左パディング32px, 右パディング32px]
  │     上端Y座標: 100px + 59px(SafeArea) = 159px
  │     幅: 390 - 64 = 326px
  │     ├── Component: OnboardingSecurityItem #1
  │     │     アイコン: 🔒 (20px)
  │     │     テキスト: 「名前もメアドも不要」
  │     │     間隔: アイコン〜テキスト 12px
  │     ├── Component: OnboardingSecurityItem #2
  │     │     アイコン: 🔒
  │     │     テキスト: 「会話は端末に暗号化保存」
  │     ├── Component: OnboardingSecurityItem #3
  │     │     アイコン: 🔒
  │     │     テキスト: 「AIはあなたを批判しない」
  │     各アイテム間隔（Auto Layout Gap）: 行間2.0 相当 → 各行高32px
  │     スタイル: type/onboarding-security (16px / Regular)
  │     色: color/text/body (white/85)
  └── Component: CTAButton (固定・画面下部)
        テキスト: 「はじめる」
        位置: x=24, y=844 - 34(SafeArea) - 48(下余白) - 56(ボタン高) = 706px
        幅: 390 - 48 = 342px / 高さ: 56px
```

**コンポーネント: OnboardingSecurityItem**

```
Frame: OnboardingSecurityItem [幅326px, 高さ32px, Auto Layout: Horizontal]
  ├── Text: Icon [20px, color: white]
  │     コンテンツ: 🔒
  ├── Text: Label [style: type/onboarding-security, color: color/text/body]
  Auto Layout: Gap 12px, Alignment: Center
```

**インタラクション:**
- 「はじめる」タップ → スライド3（チャット画面）へ遷移
- 遷移: Smart Animate / 400ms / Ease In Out

---

#### 1-3 スライド3（チャット画面へ直接遷移）

**フレーム名:** `Onboarding/Slide3-Transition`

このスライドは独立したUIを持たない。
スライド2の「はじめる」ボタンを押した直後に Screen 2: チャット（初期状態）へ直接遷移する。

**遷移仕様:**
- アニメーション: Push Left / 400ms / Ease In Out
- ローディング画面: なし
- チャット画面の初期状態: AIの最初のメッセージ + 話題セレクター表示

---

### Screen 2: チャット（メイン）

---

#### 2-1 画面構造

**フレーム名:** `Chat/Main`
**サイズ:** 390 × 844px

```
Frame: Chat/Main [390×844, fill: color/bg/app]
  ├── Component: NavigationBar [390×(44+59)px, 上部固定]
  ├── ScrollView: MessageList [390×(844-103-80)px = 390×661px]
  │     padding: 0 16px
  │     メッセージ間隔: 12px
  │     コンテンツ: MessageBubble/AI, MessageBubble/User の繰り返し
  └── Component: InputArea [390×80px+SafeAreaBottom, 下部固定]
```

**自動スクロール:** 新規メッセージ追加時、最下部へスムーズスクロール（300ms）

---

#### 2-2 AIメッセージバブル

**コンポーネント名:** `MessageBubble/AI`

**バリアント:**
- `State=Default` : テキスト表示状態
- `State=Typing` : タイピングインジケーター状態（→ 2-6参照）

**State=Default 仕様:**

```
Frame: MessageBubble/AI [最大幅293px(390×75%), 高さAuto, Auto Layout: Vertical]
  配置: 左揃え (leading)
  左マージン: 0px (親のpadding 16pxで制御)

  Visual Properties:
    fill:            rgba(255,255,255,0.06) [color/bg/bubble-ai]
    border:          1px solid rgba(255,255,255,0.08) [color/border/default]
    border-radius:   4px (左上) / 18px (右上) / 18px (右下) / 18px (左下)
    backdrop-blur:   20px [blur/glass]
    padding:         12px 16px (上下12px / 左右16px)

  内部レイヤー:
    Text: Content [style: type/body / color: color/text/body]
      コンテンツ: AIの返答テキスト
      幅: Auto（最大 293-32=261px）
      line-height: 26px (1.625倍)
```

**Figma実装メモ:**
- `backdrop-filter: blur(20px)` はFigmaの `Effects > Background blur: 20` で再現
- 角丸の非対称設定: Figmaの `Corner radius` を個別指定（左上のみ4px）

---

#### 2-3 ユーザーメッセージバブル

**コンポーネント名:** `MessageBubble/User`

```
Frame: MessageBubble/User [最大幅293px(390×75%), 高さAuto, Auto Layout: Vertical]
  配置: 右揃え (trailing)
  右マージン: 0px (親のpadding 16pxで制御)

  Visual Properties:
    fill:            rgba(79,70,229,0.80) [color/bg/bubble-user]
    border:          なし
    border-radius:   18px (左上) / 4px (右上) / 18px (右下) / 18px (左下)
    padding:         12px 16px

  内部レイヤー:
    Text: Content [style: type/body / color: white (rgba(255,255,255,1.0))]
      幅: Auto（最大 293-32=261px）
      line-height: 26px
```

---

#### 2-4 入力エリア

**コンポーネント名:** `InputArea`

**バリアント:**
- `State=Empty` : placeholder表示・送信ボタンinactive
- `State=Filled` : テキストあり・送信ボタンactive

```
Frame: InputArea [幅390px, 高さ80px + SafeArea(34px) = 114px]
  配置: 画面下部固定

  Visual Properties:
    fill:            color/bg/app (#0D0D1A)
    border-top:      1px solid rgba(255,255,255,0.08) [color/border/divider]
    padding:         12px 16px (上下12px / 左右16px)
    bottom-padding:  12px + 34px(SafeArea) = 46px

  内部レイヤー:
    Component: InputField [幅358px (390-32), 高さ44px]
    └── Auto Layout: Horizontal, Gap: Fill-Container
          ├── Text: Placeholder or Input [style: type/body / color: color/text/disabled]
          │     placeholder文言: 「話してみてください…」
          │     入力時: color/text/primary (white)
          └── Component: SendButton [28×28px, 右端内包]
```

**コンポーネント: InputField**

```
Frame: InputField [幅358px, 高さ44px]
  Visual Properties:
    fill:            rgba(255,255,255,0.06) [color/bg/input]
    border:          なし
    border-radius:   22px (pill型)
    padding:         10px 44px 10px 16px
    (右パディング44px = SendButton28px + 右内マージン8px + 余白8px)

  内部 Auto Layout: Horizontal, Alignment: Center
    ├── Text: Content [Grow, style: type/body]
    └── Component: SendButton [28×28px, 固定幅]
          右マージン: 8px
```

**コンポーネント: SendButton**

```
Frame: SendButton [28×28px]
  バリアント:
    State=Active:
      fill:   color/send-btn/active (#6366F1)
      border-radius: 14px (完全な円)
      icon:   ↑ (上向き矢印 / SF Symbol: arrow.up / 16px / white)
    State=Inactive:
      fill:   color/send-btn/inactive (rgba(255,255,255,0.10))
      border-radius: 14px
      icon:   ↑ (16px / rgba(255,255,255,0.40))
```

---

#### 2-5 話題セレクター

**コンポーネント名:** `TopicSelector` (チャット開始時のみ表示)

```
Frame: TopicSelector [幅: 画面幅, 高さ: 44px]
  配置: AIの最初のメッセージの直下・16px gap
  ScrollView: Horizontal (横スクロール)
  padding: 0 16px
  チップ間隔: 8px

  内部: 以下チップを横並び
    Component: TopicChip × 4
      テキスト: 「仕事」「人間関係」「将来」「なんとなく」
```

**コンポーネント: TopicChip**

```
Frame: TopicChip [幅: Hug Contents, 高さ: 36px]
  Auto Layout: Horizontal, padding: 8px 16px

  バリアント:
    State=Default:
      fill:         transparent
      border:       1px solid rgba(255,255,255,0.20) [color/border/chip]
      border-radius: 36px (pill型)
      Text: Label [style: type/topic-chip (14px) / color: color/text/chip (white/70)]

    State=Selected: (選択後は非表示になるためアニメーション確認用として存在)
      fill:         rgba(79,70,229,0.30)
      border:       1px solid rgba(79,70,229,0.60)
      Text: Label [color: white]
```

**インタラクション:**
- チップタップ → タップしたトピックがメッセージとして送信される
- TopicSelector全体がフェードアウト（200ms / Ease Out）して非表示になる
- 2度目以降のセッションでは表示しない

---

#### 2-6 タイピングインジケーター

**コンポーネント名:** `TypingIndicator`

```
Frame: TypingIndicator [幅: Hug Contents (最小60px), 高さ: 44px]
  配置: AIバブルと同一スタイル（MessageBubble/AI State=Typing に内包）

  Visual Properties: MessageBubble/AI と同一
    fill:            rgba(255,255,255,0.06)
    border:          1px solid rgba(255,255,255,0.08)
    border-radius:   4px 18px 18px 18px
    padding:         12px 16px

  内部 Auto Layout: Horizontal, Gap: 6px, Alignment: Center
    ├── Ellipse: Dot1 [8×8px, fill: rgba(255,255,255,0.50), border-radius: 4px]
    ├── Ellipse: Dot2 [8×8px, fill: rgba(255,255,255,0.50), border-radius: 4px]
    └── Ellipse: Dot3 [8×8px, fill: rgba(255,255,255,0.50), border-radius: 4px]
```

**アニメーション仕様（Figmaプロトタイプ / After Delay）:**

Figmaでは3フレームを交互に切り替えるプロトタイプで表現する。

| フレーム | Dot1スケール | Dot2スケール | Dot3スケール |
|---|---|---|---|
| Frame A | 1.0 (8px) | 0.75 (6px) | 0.75 (6px) |
| Frame B | 0.75 (6px) | 1.0 (8px) | 0.75 (6px) |
| Frame C | 0.75 (6px) | 0.75 (6px) | 1.0 (8px) |

遷移: A→B→C→A のループ / 各遷移: 300ms / After Delay 0ms / Ease In Out
実装時（SwiftUI）は `withAnimation(.easeInOut(duration: 0.3).repeatForever())` で各Dotに遅延をつけて実装する。

---

#### 2-7 NavigationBar

**コンポーネント名:** `NavigationBar`

```
Frame: NavigationBar [幅390px, 高さ103px (44px bar + 59px StatusBar)]
  配置: 画面上部固定

  Visual Properties:
    fill:            rgba(13,13,26,0.95) [color/navbar/bg]
    backdrop-blur:   12px [blur/navbar]
    border-bottom:   なし（スクロール時に微細な影で区別）

  内部（Y: 59px〜103px の44pxエリア内に配置）:
    ├── Text: Logo [style: type/nav (16px Semibold) / color: rgba(255,255,255,0.80)]
    │     コンテンツ: 「honne」
    │     配置: 水平中央 / 垂直中央 (Y: 59 + 12 = 71px)
    └── Text: EndButton [style: type/label (14px) / color: color/text/tertiary (white/50)]
          コンテンツ: 「終わる」
          配置: 右端 / 右マージン 16px / 垂直中央

インタラクション:
  「終わる」タップ → AlertDialog (Screen 6) を表示
```

---

### Screen 3: ホーム（ストリーク）

**フレーム名:** `Home/Main`
**サイズ:** 390 × 844px

```
Frame: Home/Main [390×844, fill: color/bg/app]
  ├── Rectangle: StatusBar-spacer [390×59]
  ├── Component: StreakCard [幅342px, X:24, Y:~160px]
  ├── Group: EmotionChips [幅: Hug, X:中央揃え, Y: StreakCard下端+24px]
  │     Auto Layout: Horizontal, Gap: 8px
  │     └── Component: EmotionTag × 3 (例: 😔疲れ, 😤イライラ, 😌落ち着き)
  └── Component: CTAButton [画面下部固定]
        テキスト: 「今日も話す」
        位置: x=24, y=844-34-48-56 = 706px
```

**コンポーネント: StreakCard**

```
Frame: StreakCard [幅342px, 高さAuto (最小160px)]
  Auto Layout: Vertical, Gap: 8px, padding: 32px 24px
  Alignment: Center

  Visual Properties:
    fill:            rgba(255,255,255,0.04) [color/streak/card-bg]
    border:          1px solid rgba(255,255,255,0.08) [color/border/default]
    border-radius:   20px

  内部:
    ├── Text: FireEmoji [40px emoji / 配置: 中央]
    │     コンテンツ: 🔥
    ├── Text: StreakNumber [style: type/hero (34px Bold) / color: white]
    │     コンテンツ: 「7日連続」
    │     配置: 中央
    └── Text: StreakLabel [style: type/label (14px) / color: color/text/tertiary (white/50)]
          コンテンツ: 「話し続けています」
          配置: 中央
```

**コンポーネント: EmotionTag（ホーム用）**

```
Frame: EmotionTag [幅: Hug Contents, 高さ: 28px]
  Auto Layout: Horizontal, Gap: 4px, padding: 4px 10px
  Visual Properties:
    fill:         transparent
    border-radius: 14px

  内部:
    ├── Text: Emoji [13px]
    └── Text: Label [style: type/caption (13px) / color: color/text/secondary (white/60)]
```

**コンポーネント: CTAButton**

```
Frame: CTAButton [幅342px(390-48), 高さ56px]
  Auto Layout: Horizontal, Alignment: Center

  Visual Properties:
    fill:            gradient/cta (左→右: #4F46E5 → #6366F1)
    border-radius:   16px

  内部:
    Text: Label [style: type/cta (17px Semibold) / color: white]
      コンテンツ: 引数化（「はじめる」「今日も話す」「7日間無料で試す」）

  バリアント:
    State=Default: 上記スタイル
    State=Pressed: fill opacity 90% / scale 0.97 (Smart Animate 100ms)
```

---

### Screen 4: Paywall

**フレーム名:** `Paywall/Sheet`
**表示形式:** ボトムシート（Sheet）としてチャット画面に重ねる

**表示トリガー:** 5通目のメッセージ送信後

```
Frame: Paywall/Sheet [幅390px, 高さ620px]
  配置: 画面下部から上端揃え (Y: 844-620 = 224px)
  アニメーション: Y: 844 → 224 / 450ms / Spring (damping: 0.82)

  Visual Properties:
    fill:            color/bg/sheet (#111127)
    border-radius:   24px 24px 0 0 (上部のみ角丸)
    shadow: なし（背景の暗さで自然に分離）

  内部 Auto Layout: Vertical, padding: 12px 24px 0 24px

  ├── Component: PaywallHandle [X:中央, Y:12px]
  ├── Text: SubCopy [style: type/label (14px) / color: color/text/tertiary (white/50)]
  │     コンテンツ: 「もっと話を続けますか？」
  │     配置: 中央 / 上マージン: 20px
  ├── Text: MainCopy [style: type/heading-md (26px Semibold) / color: white]
  │     コンテンツ: 「毎晩、話せる場所。」
  │     配置: 中央 / 上マージン: 20px
  ├── Text: Price [style: type/price (20px Semibold) / color: color/text/price (indigo-300)]
  │     コンテンツ: 「¥980 / 月」
  │     配置: 中央 / 上マージン: 12px
  ├── Component: SectionDivider [幅: Fill / 上マージン: 20px / 下マージン: 20px]
  ├── Group: BenefitList [Auto Layout: Vertical, Gap: 12px]
  │     ├── Component: PaywallBenefitItem テキスト:「無制限チャット」
  │     ├── Component: PaywallBenefitItem テキスト:「週次レポート（感情パターン分析）」
  │     └── Component: PaywallBenefitItem テキスト:「感情カレンダー（全期間）」
  ├── Component: CTAButton [上マージン:28px]
  │     テキスト: 「7日間無料で試す」
  ├── Text: CancelNote [style: type/caption-sm (12px) / color: color/text/muted (white/40)]
  │     コンテンツ: 「いつでも解約できます（1タップ）」
  │     配置: 中央 / 上マージン: 12px
  └── Text: SkipButton [style: type/caption (13px) / color: color/text/muted (white/40)]
        コンテンツ: 「あとで（無料のまま続ける）」
        配置: 中央 / padding: 16px (タップエリア確保) / 上マージン: 4px
```

**コンポーネント: PaywallHandle**

```
Frame: PaywallHandle [幅36px, 高さ4px]
  Visual Properties:
    fill:         rgba(255,255,255,0.20)
    border-radius: 2px
```

**コンポーネント: PaywallBenefitItem**

```
Frame: PaywallBenefitItem [幅: 342px (Fill), 高さ: Hug]
  Auto Layout: Horizontal, Gap: 12px, Alignment: Center

  ├── Text: Checkmark [style: type/body (16px) / color: color/text/price (indigo-300)]
  │     コンテンツ: 「✓」
  └── Text: Label [style: type/body (16px) / color: color/text/body (white/85)]
        コンテンツ: 引数化
```

**コンポーネント: SectionDivider**

```
Frame: SectionDivider [幅: Fill, 高さ: 1px]
  Visual Properties:
    fill: rgba(255,255,255,0.08) [color/border/divider]
```

---

### Screen 5: 感情タグ確認

**フレーム名:** `EmotionTag/Confirmation`
**表示形式:** チャット画面の上部からスライドダウンするオーバーレイカード

```
Frame: EmotionTag/Confirmation [幅390px, 高さAuto (最小240px)]
  配置: 画面上部・NavigationBar直下から表示
  アニメーション: Y: -240 → 0 / 400ms / Spring (damping: 0.85)

  Visual Properties:
    fill:            rgba(17,17,39,0.96) [color/bg/sheet に近似]
    border-bottom:   1px solid rgba(255,255,255,0.08)
    backdrop-blur:   20px

  内部 Auto Layout: Vertical, padding: 24px, Gap: 16px

  ├── Text: ThankYou [style: type/session-end (18px) / color: rgba(255,255,255,0.80)]
  │     コンテンツ: 「今日話してくれてありがとうございました」
  │     配置: 中央
  ├── Text: SubMessage [style: type/label (14px) / color: color/text/tertiary (white/50)]
  │     コンテンツ: 「少し楽になりましたか？」
  │     配置: 中央
  ├── Group: EmotionTagList [Auto Layout: Horizontal, Gap: 8px, Wrap: true]
  │     └── Component: EmotionTagChip × 最大3個
  │           例: #疲れ, #仕事, #孤独
  ├── Component: CTAButton [テキスト: 「保存してホームへ」]
  └── Text: DeleteButton [style: type/caption (13px) / color: color/text/disabled (white/30)]
        コンテンツ: 「このセッションを削除」
        配置: 中央
        padding: 12px (タップエリア確保)
```

**コンポーネント: EmotionTagChip**

```
Frame: EmotionTagChip [幅: Hug Contents, 高さ: 28px]
  Auto Layout: Horizontal, padding: 6px 12px

  Visual Properties:
    fill:            rgba(255,255,255,0.06) [color/bg/chip]
    border:          1px solid rgba(255,255,255,0.08) [color/border/default]
    border-radius:   36px (pill型)

  内部:
    Text: Label [style: type/emotion-chip (13px) / color: color/text/chip (white/70)]
      コンテンツ: 例「#疲れ」「#仕事」「#孤独」
```

---

### Screen 6: セッション終了確認

**フレーム名:** `Alert/EndSession`
**表示形式:** iOS標準アラートを模したオーバーレイ

```
Overlay: DimBackground [390×844px, fill: rgba(0,0,0,0.50)]

Frame: Alert/EndSession [幅270px, 高さAuto]
  配置: 画面中央 (X: 60px, Y: 中央揃え)
  アニメーション: scale 0.85→1.0 + opacity 0→1 / 250ms / Spring

  Visual Properties:
    fill:            rgba(30,30,46,0.98)
    border-radius:   14px
    border:          1px solid rgba(255,255,255,0.06)
    backdrop-blur:   30px

  内部 Auto Layout: Vertical

  ├── Group: TextContent [padding: 20px 16px 16px, Gap: 8px]
  │     ├── Text: Title [style: type/alert-title (17px Semibold) / color: white]
  │     │     コンテンツ: 「今日はここまでにしますか？」
  │     │     配置: 中央
  │     └── Text: Body [style: type/alert-body (14px) / color: color/text/secondary (white/60)]
  │           コンテンツ: 「続きはいつでも話せます」
  │           配置: 中央
  ├── Component: SectionDivider [幅: Fill]
  └── Group: Buttons [Auto Layout: Horizontal, 幅: 270px]
        ├── Text: EndButton [幅: 135px, 高さ: 44px]
        │     コンテンツ: 「終わる」
        │     スタイル: type/body (16px) / color: color/text/destructive (red-400)
        │     配置: 中央
        ├── Component: SectionDivider [幅: 1px, 高さ: 44px, 縦区切り]
        └── Text: ContinueButton [幅: 134px, 高さ: 44px]
              コンテンツ: 「続ける」
              スタイル: type/body (16px Semibold) / color: color/text/action (indigo-300)
              配置: 中央 (推奨アクション)
```

**インタラクション:**
- 「終わる」タップ → EmotionTag確認（Screen 5）へ遷移
- 「続ける」タップ → アラートを閉じてチャット画面に戻る
- DimBackground タップ → 「続ける」と同じ動作

---

## インタラクション・アニメーション仕様

### 画面遷移一覧

| From | To | トリガー | アニメーション | 時間 | イージング |
|---|---|---|---|---|---|
| Onboarding/Slide1 | Onboarding/Slide2 | 画面タップ | Dissolve | 300ms | Ease Out |
| Onboarding/Slide2 | Chat/Main | 「はじめる」タップ | Push Left | 400ms | Ease In Out |
| Chat/Main | Paywall/Sheet | 5通目の返信後 | Slide Up (Sheet) | 450ms | Spring (0.82) |
| Chat/Main | Alert/EndSession | 「終わる」タップ | Scale + Fade In | 250ms | Spring |
| Alert/EndSession | EmotionTag/Confirmation | 「終わる」タップ | Slide Down | 400ms | Spring (0.85) |
| EmotionTag/Confirmation | Home/Main | 「保存してホームへ」タップ | Push Left | 400ms | Ease In Out |
| Home/Main | Chat/Main | 「今日も話す」タップ | Push Left | 400ms | Ease In Out |

---

### バブルアニメーション

#### AIメッセージの出現

```
1. TypingIndicator が左下からフェードイン
   - opacity: 0 → 1 / transform: translateY(8px) → 0
   - 時間: 200ms / Ease Out

2. AIのレスポンス生成中は TypingIndicator を継続表示

3. レスポンス受信後:
   - TypingIndicator がフェードアウト (opacity: 1→0 / 150ms)
   - AIバブルが同じ位置にフェードイン (opacity: 0→1 / 200ms / Ease Out)

4. MessageList が新バブル分だけ下スクロール
   - scroll: smooth / 300ms
```

#### ユーザーメッセージの出現

```
1. テキストフィールドのテキストが消える
2. ユーザーバブルが右下からフェードイン
   - opacity: 0 → 1 / transform: translateY(4px) → 0
   - 時間: 150ms / Ease Out
3. 直後に TypingIndicator が表示開始
```

---

### タイピングインジケーター詳細アニメーション

3つのドット（Dot1 / Dot2 / Dot3）が順番に拡大縮小する。

```
Dot1: delay 0ms
Dot2: delay 150ms
Dot3: delay 300ms

各Dotの動作:
  scale: 1.0 → 1.4 → 1.0
  opacity: 0.50 → 1.0 → 0.50
  duration: 600ms / loop forever
  easing: Ease In Out (Sine)
```

---

### Paywall表示アニメーション

```
1. チャット画面はそのまま（インタラクション可）
2. 半透明のDim overlay がフェードイン (opacity: 0→0.4 / 300ms)
3. Paywallシートが下から上スライドイン (Y: 844→224 / 450ms / Spring damping:0.82)
4. Paywallシート表示中もチャット画面の「終わる」ボタンは非活性
```

---

## アセット仕様

### アイコン

アイコンは SF Symbols を使用する（iOSネイティブ）。
Figmaでは [SF Symbols Plugin](https://www.figma.com/community/plugin/1234) または [SF Symbols 5 for Figma](https://www.figma.com/community) を使用する。

| 用途 | SF Symbol名 | サイズ | 色 |
|---|---|---|---|
| 送信ボタン（矢印） | `arrow.up` | 16px | white |
| 送信ボタン（inactive） | `arrow.up` | 16px | rgba(255,255,255,0.40) |
| 安心ポイント（錠前） | `lock.fill` | 20px | white |
| 特典チェック | `checkmark` | 16px | color/text/price (indigo-300) |
| ストリーク（炎） | 絵文字 🔥 | 40px | ネイティブ絵文字 |

**アイコン配置ルール:**
- SF Symbols はすべて `.semibold` ウェイトで統一する
- タップ領域は最小 44×44px を確保する（アイコンが小さい場合は透明レイヤーで拡張）

---

### アプリアイコン仕様

**デザイン方針:** 暗いグラデーション + 余白多めの白い半円（静けさ・安心）

```
サイズ: 1024 × 1024px (App Store用マスター)

背景:
  グラデーション: 上左→下右 (135°)
  0%: #0D0D1A
  100%: #1A1A3A

中央モチーフ:
  形状: 半円（上半分）
  サイズ: 約380px幅
  色: white
  opacity: 0.90
  位置: 画面中央よりやや上 (Y: 340px)
  border-radius: 上部190px / 下部 0px（完全な半円）

余白:
  モチーフ周囲の余白を十分に確保（モチーフサイズは全体の37%以内）

書き出しサイズ:
  1024×1024 (App Store)
  180×180   (iPhone @3x)
  120×120   (iPhone @2x)
  87×87     (iPhone Spotlight @3x)
  80×80     (iPhone Spotlight @2x)
  60×60     (iPhone Notification @3x)
  40×40     (iPhone Notification @2x)

角丸: iOSが自動でマスクするためFigma上は角丸不要（正方形で作成）
```

---

## Figmaファイル構成（推奨）

### ページ構成

| ページ名 | 内容 |
|---|---|
| `🎨 Design System` | カラー変数・テキストスタイル・スペーシング定義・サンプル |
| `🧩 Components` | 全コンポーネント・バリアント一覧 |
| `📱 Screens` | 全画面フレーム（実寸・iPhone 15 Pro） |
| `🔗 Prototype` | インタラクション・遷移フローの確認用 |
| `📦 Assets` | アプリアイコン・書き出しアセット |

---

### フレーム名（Screensページ）

```
Screens/
  ├── Onboarding/
  │     ├── Onboarding/Slide1
  │     ├── Onboarding/Slide2
  │     └── Onboarding/Slide3-Transition (説明用フレーム)
  ├── Chat/
  │     ├── Chat/Initial       (話題セレクター表示状態)
  │     ├── Chat/InProgress    (会話中・複数バブル)
  │     ├── Chat/Typing        (AIタイピング中)
  │     └── Chat/WithPaywall   (Paywallシート重ね表示)
  ├── Home/
  │     └── Home/Main
  ├── Paywall/
  │     └── Paywall/Sheet
  ├── Session/
  │     ├── EmotionTag/Confirmation
  │     └── Alert/EndSession
  └── AppIcon/
        └── AppIcon/1024
```

---

### コンポーネント構成（Componentsページ）

```
Components/
  ├── Buttons/
  │     ├── CTAButton [State: Default, Pressed]
  │     └── SendButton [State: Active, Inactive]
  ├── Inputs/
  │     ├── InputField [State: Empty, Filled]
  │     └── InputArea [State: Empty, Filled]
  ├── Chat/
  │     ├── MessageBubble/AI [State: Default, Typing]
  │     ├── MessageBubble/User [State: Default]
  │     └── TypingIndicator [Frame A, B, C]
  ├── Navigation/
  │     └── NavigationBar
  ├── Chips/
  │     ├── TopicChip [State: Default, Selected]
  │     ├── EmotionTagChip
  │     └── EmotionTag (ホーム用)
  ├── Cards/
  │     └── StreakCard
  ├── Paywall/
  │     ├── PaywallHandle
  │     └── PaywallBenefitItem
  ├── Onboarding/
  │     └── OnboardingSecurityItem
  ├── Overlays/
  │     └── AlertDialog
  └── Utilities/
        └── SectionDivider [Direction: Horizontal, Vertical]
```

---

### バリアント設計

**バリアント命名規則:** `Property=Value` 形式で統一する。

| コンポーネント | Property | Values |
|---|---|---|
| `CTAButton` | `State` | `Default`, `Pressed` |
| `CTAButton` | `Label` | テキストプロパティとして可変 |
| `SendButton` | `State` | `Active`, `Inactive` |
| `InputField` | `State` | `Empty`, `Filled` |
| `InputArea` | `State` | `Empty`, `Filled` |
| `MessageBubble/AI` | `State` | `Default`, `Typing` |
| `TopicChip` | `State` | `Default`, `Selected` |
| `TypingIndicator` | `Frame` | `A`, `B`, `C` (アニメーション用) |
| `SectionDivider` | `Direction` | `Horizontal`, `Vertical` |

**テキストプロパティ（Component Properties）の設定:**

以下のコンポーネントにはFigmaの `Component Properties > Text` を設定し、
インスタンスから直接テキストを変更できるようにする。

- `CTAButton` → Property名: `label` / Default: 「はじめる」
- `MessageBubble/AI` → Property名: `content` / Default: 「こんにちは」
- `MessageBubble/User` → Property名: `content` / Default: 「話したいことがあって」
- `TopicChip` → Property名: `topic` / Default: 「仕事」
- `EmotionTagChip` → Property名: `tag` / Default: 「#疲れ」
- `PaywallBenefitItem` → Property名: `benefit` / Default: 「無制限チャット」
- `OnboardingSecurityItem` → Property名: `text` / Default: 「名前もメアドも不要」

---

### Auto Layout 設定一覧

全コンポーネントはAuto Layoutを使用し、固定幅/高さを最小限にする。

| コンポーネント | 方向 | Gap | Padding | Alignment |
|---|---|---|---|---|
| `CTAButton` | Horizontal | — | 0 56px | Center |
| `InputArea` | Horizontal | 8px | 12px 16px | Center |
| `InputField` | Horizontal | — | 10px 44px 10px 16px | Center |
| `MessageBubble/AI` | Vertical | — | 12px 16px | Leading |
| `MessageBubble/User` | Vertical | — | 12px 16px | Trailing |
| `TypingIndicator` | Horizontal | 6px | 12px 16px | Center |
| `TopicChip` | Horizontal | — | 8px 16px | Center |
| `EmotionTagChip` | Horizontal | — | 6px 12px | Center |
| `StreakCard` | Vertical | 8px | 32px 24px | Center |
| `PaywallBenefitItem` | Horizontal | 12px | 0 | Center |
| `OnboardingSecurityItem` | Horizontal | 12px | 0 | Center |
| `AlertDialog` | Vertical | — | 0 | Center |

---

## 補足: アクセシビリティ基準

| テキスト | 背景 | コントラスト比 | 基準適合 |
|---|---|---|---|
| AIバブル本文 white/85 | rgba(255,255,255,0.06) on #0D0D1A | ≥ 7:1 | AAA |
| ユーザーバブル white | rgba(79,70,229,0.80) | 21:1 | AAA |
| タイムスタンプ white/50 | #0D0D1A | ≥ 4.5:1 | AA |
| CTA「はじめる」white | #4F46E5→#6366F1 | ≥ 4.5:1 | AA |
| placeholder white/30 | rgba(255,255,255,0.06) on #0D0D1A | 装飾的用途 | 対象外 |

最小タップ領域: **44 × 44pt** (HIG準拠)
- 「終わる」テキストボタン: 透明レイヤーで44×44pt確保
- 「あとで」テキストボタン: padding 16px で確保

---

*honne Figma実装仕様書 v1.0 / 2026-02-27*
