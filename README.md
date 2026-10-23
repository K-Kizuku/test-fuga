# test-fuga / HackathonApp

## 概要

SwiftUI で独立した機能を追加し、一覧から個別に試せるハッカソン用の iOS アプリです。起動すると `Capability Playground` が表示されます。

## 主な機能

- `CapabilityRegistry` に登録された機能の一覧と各画面への遷移。
- `Template check`：文字を入力すると画面に反映され、空欄では `Ready` を表示する動作確認用画面。
- XCTest による登録内容の重複・ID 形式・画面生成の確認。

現在登録されている機能は `Template check` です。ハードウェアは使用しません。

## 必要な環境

- macOS と Swift 6 に対応する Xcode（コマンドラインツールだけでは不足）。
- iOS 17.0 以上の iPhone Simulator ランタイムと利用可能な Simulator。
- XcodeGen：`project.yml` から Xcode プロジェクトを生成します。
- Node.js：`scripts/hack-ios.mjs` を実行します。スクリプトは Node.js の標準モジュールを使用します。

`project.yml` は Swift 6.0、iOS 17.0 以上、iPhone / iPad を対象に設定されています。外部 Swift パッケージや npm パッケージの依存定義はありません。

## セットアップ

リポジトリを取得し、`project.yml` があるルートディレクトリで作業します。Xcode、XcodeGen、Node.js を用意し、`xcodegen` と `node` を PATH から実行できる状態にしてください。Xcode には iPhone Simulator ランタイムを用意します。

通常のローカル開発では、次のコマンドでプロジェクトを生成して開きます。

```sh
xcodegen generate --spec project.yml
open HackathonApp.xcodeproj
```

生成される `HackathonApp.xcodeproj/` は Git 管理対象外です。ビルド設定の元ファイルは `project.yml` です。

## ビルド・実行方法

### Simulator で画面を確認する

1. Xcode で `HackathonApp` スキームを選択します。
2. 実行先に iOS 17.0 以上の iPhone Simulator を選択し、Run を実行します。
3. `Capability Playground` から `Template check` を開きます。
4. 入力欄が空なら `Ready`、入力後はその文字列が表示されることを確認します。

### ビルドと XCTest をまとめて実行する

通常のローカル開発では、リポジトリのルートで次を実行します。

```sh
node scripts/hack-ios.mjs
```

このスクリプトは XcodeGen による生成、Simulator 向け Debug ビルド、`HackathonAppTests` の実行を順に行います。テスト先は利用可能な iPhone Simulator から自動選択されます。指定する場合は、次のように設定できます。

```sh
HACK_IOS_DESTINATION='platform=iOS Simulator,name=iPhone 16' node scripts/hack-ios.mjs
```

`iPhone 16` は指定例です。実際にインストールされている Simulator の名前に置き換えてください。

標準の出力先は `DerivedData/` と `.build-logs/` です。`.build-logs/` に各工程のログ、テスト結果の `.xcresult`、成否を示す `latest-result.json` が保存されます。これらも Git 管理対象外です。Xcode や Simulator が不足している場合は検証失敗として扱います。

TAKT のエージェントステップでは、上記の生成・ビルド・テストコマンドを手動実行せず、ステップ後に同じクローンで実行される品質ゲートに委ねます。

### 実機で確認する

Xcode で接続した iPhone を実行先に選び、アプリターゲットの署名用 Team を設定して Run を実行します。`project.yml` の `DEVELOPMENT_TEAM` は空欄です。生成プロジェクト内だけの設定変更は、再生成時に上書きされるため注意してください。

Simulator のテスト成功と実機確認は別に記録します。カメラ、マイク、モーション、位置情報、触覚を使う機能を追加した場合は、実機での動作・権限確認を記録してください。

## ディレクトリ構成

```text
MyApp/
  App/HackathonApp.swift             アプリのエントリーポイント
  Capabilities/Welcome/              現在の Template check 画面
  Playground/CapabilityRegistry.swift 機能の登録と画面生成
  Playground/CapabilityListView.swift 機能一覧
  Shared/CapabilityID.swift           機能 ID の検証
Tests/CapabilityTests.swift           登録内容と ID の XCTest
scripts/hack-ios.mjs                  プロジェクト生成・ビルド・テスト
project.yml                          XcodeGen のプロジェクト設定
AGENTS.md                            作業範囲・品質ゲートのルール
```

## 開発の流れ

1. 担当 Issue の変更範囲を確認し、TAKT の分離クローン・作業ブランチ内で実装します。Coordinator の状態や無関係なファイルは変更しません。
2. 機能は `MyApp/Capabilities/<Name>/` に置き、`MyApp/Playground/CapabilityRegistry.swift` に独立した画面として登録します。登録ファイルや `project.yml` を変更する場合は、Issue の範囲に含めます。ハードウェアが使えない Simulator 向けにはモックや代替動作を用意します。
3. 品質ゲートの実際の結果・ログと実機での確認状況を記録します。未実施の検証を成功として扱いません。
4. PR に対象 Issue を閉じる記述（この Issue なら `Closes #1`）、実装内容、実際のテスト結果・ログ、実機確認の結果または未確認項目を含めます。TAKT ではステージング・コミット・プッシュ・PR 作成をエージェントステップから行わず、連携処理に委ねます。マージは人が行います。

デモ凍結中は新機能、大規模なリファクタリング、依存関係の更新、無関係な改善を行いません。
