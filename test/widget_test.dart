import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:it_class/main.dart';

void main() {
  AuthSession fakeSession(int accountType) {
    return AuthSession(
      userId: accountType,
      accessToken: 'test-token',
      refreshToken: 'test-refresh-token',
      schoolAccountId: accountType,
      schoolAccountType: accountType,
      realName: accountType == schoolAccountTypeTeacher ? 'Admin' : '佐藤',
      email: accountType == schoolAccountTypeTeacher
          ? 'teacher@example.com'
          : 'student@example.com',
      mobile: '080-0000-0000',
      programmingLanguage: 'Java',
    );
  }

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
    ItClassSession.current = fakeSession(schoolAccountTypeStudent);
    await tester.pumpWidget(const MaterialApp(home: StudentHomePage()));
    await tester.pump();

    expect(find.text('AI会話'), findsWidgets);
    expect(find.text('コード採点'), findsWidgets);
    expect(find.text('AI教室'), findsWidgets);
    expect(find.text('テスト'), findsWidgets);
  });

  testWidgets('opens teacher workspace', (tester) async {
    useDesktopViewport(tester);
    ItClassSession.current = fakeSession(schoolAccountTypeTeacher);
    await tester.pumpWidget(const MaterialApp(home: TeacherHomePage()));
    await tester.pump();

    expect(find.text('AI回答不能（先生対応）'), findsWidgets);
    expect(find.text('成績確認'), findsWidgets);
    expect(find.text('システム管理'), findsWidgets);
  });

  testWidgets('desktop side menu does not return to login page', (
    tester,
  ) async {
    useDesktopViewport(tester);
    ItClassSession.current = fakeSession(schoolAccountTypeStudent);
    await tester.pumpWidget(const MaterialApp(home: StudentHomePage()));
    await tester.pump();

    await tester.tap(find.text('AI教室'));
    await tester.pumpAndSettle();

    expect(find.text('学生ログイン'), findsNothing);
    expect(find.text('AI教室：動画学習'), findsOneWidget);

    expect(find.text('先生ログイン'), findsNothing);
  });
}
