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

    expect(find.text('it教师'), findsOneWidget);
    expect(find.text('学生端登录'), findsOneWidget);
    expect(find.text('老师端登录'), findsOneWidget);
  });

  testWidgets('opens student workspace', (tester) async {
    useDesktopViewport(tester);
    await tester.pumpWidget(const ItClassApp());

    await tester.tap(find.text('学生端登录'));
    await tester.pumpAndSettle();

    expect(find.text('AI会話'), findsWidgets);
    expect(find.text('コード採点'), findsWidgets);
    expect(find.text('考试'), findsWidgets);
  });

  testWidgets('opens teacher workspace', (tester) async {
    useDesktopViewport(tester);
    await tester.pumpWidget(const ItClassApp());

    await tester.tap(find.text('老师端登录'));
    await tester.pumpAndSettle();

    expect(find.text('AI回答不能（先生対応）'), findsWidgets);
    expect(find.text('テスト解答分析'), findsWidgets);
    expect(find.text('システム管理'), findsWidgets);
  });
}
