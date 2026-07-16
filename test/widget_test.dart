import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:it_class/main.dart';

void main() {
  void useDesktopViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('shows role login options', (tester) async {
    useDesktopViewport(tester);
    await tester.pumpWidget(const ItClassApp());

    expect(find.text('IT教師'), findsOneWidget);
    expect(find.text('学生ログイン'), findsOneWidget);
    expect(find.text('先生ログイン'), findsOneWidget);
  });

  testWidgets('opens student workspace', (tester) async {
    useDesktopViewport(tester);
    await tester.pumpWidget(const ItClassApp());

    await tester.tap(find.text('学生ログイン'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ログイン'));
    await tester.pumpAndSettle();

    expect(find.text('AI会話'), findsWidgets);
    expect(find.text('コード採点'), findsWidgets);
    expect(find.text('AI教室'), findsWidgets);
    expect(find.text('テスト'), findsWidgets);
  });

  testWidgets('opens teacher workspace', (tester) async {
    useDesktopViewport(tester);
    await tester.pumpWidget(const ItClassApp());

    await tester.tap(find.text('先生ログイン'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ログイン'));
    await tester.pumpAndSettle();

    expect(find.text('AI回答不能（先生対応）'), findsWidgets);
    expect(find.text('成績確認'), findsWidgets);
    expect(find.text('システム管理'), findsWidgets);
  });
}
