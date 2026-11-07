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
flutter run -d chrome --web-port=65141
flutter run -d android
flutter run -d ios
```

Web は同じブラウザーと同じ URL で開くとログイン状態を復元します。Android Studio の
`itClass Web` 実行設定は固定ポートを使用します。アカウントのパスワードは保存せず、
保存したログイントークンを必要に応じて更新します。ログアウトすると保存情報を削除します。
サーバーがログインを失効させた場合やブラウザーのデータを消去した場合は再ログインが必要です。

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
