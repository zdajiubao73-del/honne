fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios create_app

```sh
[bundle exec] fastlane ios create_app
```

App Store Connect にアプリを新規登録

### ios beta

```sh
[bundle exec] fastlane ios beta
```

ビルドして TestFlight にアップロード

### ios release

```sh
[bundle exec] fastlane ios release
```

App Store に審査提出

### ios ship

```sh
[bundle exec] fastlane ios ship
```

アプリ登録 → TestFlight → 審査提出 を一括実行

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
