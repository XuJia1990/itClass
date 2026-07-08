# itClass

一个基于 Flutter 的跨端项目，当前已开启 Web、Android、iOS 三个平台。

## 环境要求

- Flutter 3.x
- Dart SDK
- Android Studio 或 Android SDK
- Xcode（构建 iOS 需要 macOS）

## 常用命令

```bash
flutter pub get
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

## 构建命令

```bash
flutter build web
flutter build apk
flutter build ios
```

## 目录说明

- `lib/`：Flutter 应用代码
- `web/`：Web 端入口和图标
- `android/`：Android 原生工程
- `ios/`：iOS 原生工程
- `test/`：自动化测试
