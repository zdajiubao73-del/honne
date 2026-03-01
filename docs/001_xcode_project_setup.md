# Xcode プロジェクト設定・ビルド環境整備

## 概要
アプリを実機・TestFlightで動かすための Xcode プロジェクト設定を完了させる。Bundle ID / 署名 / Capabilities を確定し、チーム全体でビルドできる状態にする。

## 背景
現在 Swift ファイルは実装済みだが、Xcode プロジェクトファイル（.xcodeproj）の設定が未確認の状態。TestFlight 配布（M4）に向けて最初に完了すべき基盤タスク。

## TODO
- [ ] Bundle ID を `com.{yourname}.honne` で確定し、App Store Connect に登録する ← **手動: Apple Developer ログイン必要**
- [ ] Apple Developer Program（$99/年）に登録し、Provisioning Profile を作成する ← **手動**
- [ ] Xcode の Signing & Capabilities で自動署名を有効にする ← **手動: Xcode で DEVELOPMENT_TEAM を設定**
- [x] Deployment Target を iOS 17.0 に設定する
- [x] Info.plist に NSMicrophoneUsageDescription（音声入力v1.1用）を追記する
- [x] Info.plist に NSUserTrackingUsageDescription（RevenueCat用）を追記する
- [ ] Swift Package Manager で依存パッケージを追加する（RevenueCat, Firebase） ← **次: #009, #014 で対応**
- [x] `.gitignore` に `*.xcuserdata/` と APIキーファイルを追加する
- [x] `Debug` / `Release` ビルド設定を分離し、Release では最適化を有効にする
- [x] シミュレータービルドが通ることを確認する（BUILD SUCCEEDED）

## 完了条件
- Xcode で `Product > Archive` が成功する
- 実機でアプリが起動し、クラッシュしない
- TestFlight にアップロード可能な IPA が生成できる

## 依存関係
- 前提: なし
- ブロック: #009（RevenueCat連携）、#017（TestFlight配布）

## 関連ファイル
- `honne.xcodeproj/project.pbxproj`
- `honne/Info.plist`
