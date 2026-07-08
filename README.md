# itClass

Flutter で構築したクロスプラットフォーム学習アプリです。Web、Android、iOS に対応しています。

## 必要環境

- Flutter 3.x
- Dart SDK
- Android Studio または Android SDK
- Xcode（iOS ビルドには macOS が必要です）

## よく使うコマンド

```bash
flutter pub get
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

## ビルドコマンド

```bash
flutter build web
flutter build apk
flutter build ios
```

## ディレクトリ構成

- `lib/`: Flutter アプリコード
- `lib/pages/`: ログイン、学生画面、先生画面
- `lib/shared/`: 共通ウィジェット、モデル、Mock データ
- `web/`: Web エントリとアイコン
- `android/`: Android ネイティブプロジェクト
- `ios/`: iOS ネイティブプロジェクト
- `test/`: 自動テスト
