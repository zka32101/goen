# Windows ローカルビルド 引き継ぎ情報

最終更新: 2026-09-23 / commit `e86aab8`（`main`ブランチ）

このクラウドセッション（Linuxサンドボックス）で確認済みの状態を、Windowsローカル環境で
再現するための引き継ぎ。Dart/Flutterコード自体はクロスプラットフォームなので、
ここに書いてあるのは主に「Windows特有のセットアップ手順」と「このリポジトリ固有の注意点」。

## 現在の状態（引き継ぎ時点）

- `main`ブランチ、最新コミット `e86aab8`
- `dart analyze lib test` → エラー0（infoレベルの style lint のみ）
- `flutter test` → 888件全通過
- Android専用アプリ（`ios/`ディレクトリ自体が存在しない。web/macOS/iOS向けビルドは未整備）

## 必要な環境

| 項目 | バージョン | 備考 |
|---|---|---|
| Flutter SDK | 3.47.x (stable channel) | このセッションでは3.47.5で動作確認。`flutter --version`で確認 |
| Dart SDK | 3.13.x（Flutterに同梱） | pubspec.yamlの制約は`>=3.10.0 <4.0.0` |
| JDK | 17 (Temurin推奨) | Android Gradle Plugin 9.1.0がJVM 17を要求 |
| Android SDK | Platform 36 + Build-Tools | compileSdk/targetSdk = 36。Android Studio経由でインストールするのが簡単 |
| NDK | **不要** | ネイティブ`.so`をビルドする設定は無い。`ffi`パッケージはFuegoエンジン連携用に残っているが、現在は呼び出し元が無いdead code（純Dart実装のGoエンジンに置き換わっている） |

このクラウドサンドボックスではネットワークポリシーで`dl.google.com`がブロックされており
Android SDKのダウンロード自体ができなかったため、実機ビルド（`flutter build apk`）は
**このセッションでは一度も実行できていない**。Windows側で初めて検証されることになる。

## セットアップ手順

```powershell
git clone https://github.com/zka32101/goen.git
cd goen
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter build apk --debug
```

- `*.freezed.dart` / `*.g.dart` は`.gitignore`対象なのでcloneした直後は存在しない。
  `build_runner`を実行するまでは`dart analyze`が大量のエラーを出すが、これは想定通り
  （生成後にエラー0になることを確認済み）。
- 実機/エミュレータで動かす場合は`flutter run`。

## Firebase設定の現状（重要）

- `lib/firebase_options.dart`のAndroid設定は実際のFirebaseプロジェクト
  （`goen-29686`）を指す本物の値になっている。iOS/web/macOSはまだプレースホルダーの
  ままだが、このアプリはAndroid専用なので実害はない。
- `android/app/google-services.json`は**リポジトリに含まれていない**（機密情報のため
  意図的に`.gitignore`対象）。
  - Firestore/Authなど大半の機能は`Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
    経由でDart側の値を使うため、このファイルが無くてもビルド・動作する。
    `android/app/build.gradle.kts`もファイルが存在する場合のみGoogle Servicesの
    Gradleプラグインを適用する設計になっている（無くてもビルド自体は失敗しない）。
  - FCM（プッシュ通知）やCrashlyticsのネイティブ側を完全に動かしたい場合は、
    Firebase Console（プロジェクト`goen-29686`）からAndroidアプリの
    `google-services.json`をダウンロードし、`android/app/google-services.json`に配置する。

## リリース（署名済み）ビルドについて

`flutter build apk --release` / AAB版をビルドする場合、`android/app/build.gradle.kts`が
以下の環境変数（またはgradle.properties）を読む:

- `ANDROID_KEYSTORE_PATH`（デフォルト`android/app/goen-release.keystore` — リポジトリ未収録）
- `ANDROID_KEYSTORE_PASSWORD`
- `ANDROID_KEY_ALIAS`（デフォルト`goen-key`）
- `ANDROID_KEY_PASSWORD`

未設定だとデフォルト値`"changeme"`にフォールバックするが、keystoreファイル自体が
存在しないとビルドが失敗する。**デバッグビルド（`--debug`または`flutter run`）は
これらを一切必要としない** — ローカルでの動作確認はデバッグビルドで十分。

## CI（参考）

`.github/workflows/android-build.yml`がGitHub Actions上でのビルド手順の実例
（Ubuntu + Flutter 3.47.2 + JDK17、`pub get` → `build_runner build` →
`flutter analyze` → `flutter test` → `flutter build apk --debug`）。
ローカルでの再現手順もこれに準ずる。CIはデバッグAPKのみビルドしており、
署名済みリリースビルドの検証はしていない。

## その他の注意点

- `flutter test`のうち`fuego_engine_test.dart`の一部（ネイティブlibが無い環境向け）は
  `late FuegoEngineService`がnullのまま3テストがスキップされる設計（意図的、失敗ではない）。
  Windowsでも同様にスキップされるはず。
- `CLAUDE.md`にこれまでの開発履歴（機能実装・バグ修正の経緯）が詳細に記録されている。
  ただし一部の記述（テスト件数・「未実装」の記載など）は後続の変更で古くなっている箇所が
  あるため、実際のコード（`lib/`）を都度確認するのが確実。
- Twitch/YouTube連携は実際のOAuth/APIバックエンドが無く、Firestore上の帳簿処理のみ
  （意図的に誠実な「未対応」表示にしてある — 偽の成功を返さない設計）。
- トーナメントのラウンド生成など一部の機能はクライアント側の自己申告になっており、
  サーバー側（Cloud Functions）での検証が無い（`firestore.rules`のコメントに詳細あり）。
