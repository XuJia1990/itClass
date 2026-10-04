import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:it_class/main.dart';

void main() {
  test('AI history keeps the original answer before the teacher follow-up', () {
    final messages = chatMessagesFromAiQuestionJson({
      'questionContent': 'Javaの配列とは？',
      'aiAnswer': 'AIの説明',
      'teacherAnswer': '先生の補足',
      'effectiveAnswer': '先生の補足',
    });

    expect(messages.map((message) => message.author), [
      MessageAuthor.student,
      MessageAuthor.ai,
      MessageAuthor.teacher,
    ]);
    expect(messages.map((message) => message.text), [
      'Javaの配列とは？',
      'AIの説明',
      '先生の補足',
    ]);
  });

  test('AI history handles unanswered and teacher-only questions', () {
    final waiting = chatMessagesFromAiQuestionJson({
      'questionContent': '質問',
      'aiAnswer': null,
      'teacherAnswer': null,
      'effectiveAnswer': null,
    });
    final teacherOnly = chatMessagesFromAiQuestionJson({
      'questionContent': '質問',
      'teacherAnswer': '先生の回答',
      'effectiveAnswer': '先生の回答',
    });
    final aiOnly = chatMessagesFromAiQuestionJson({
      'questionContent': '質問',
      'aiAnswer': 'AIの回答',
      'effectiveAnswer': 'AIの回答',
    });

    expect(waiting.length, 1);
    expect(aiOnly.map((message) => message.author), [
      MessageAuthor.student,
      MessageAuthor.ai,
    ]);
    expect(teacherOnly.map((message) => message.author), [
      MessageAuthor.student,
      MessageAuthor.teacher,
    ]);
  });

  test('chat websocket URL uses the server root without a fragment', () {
    final uri = SchoolChatRealtime.webSocketUri('secret-token');

    expect(uri.scheme, anyOf('ws', 'wss'));
    expect(uri.path, '/infra/ws');
    expect(uri.queryParameters['token'], 'secret-token');
    expect(uri.toString(), isNot(contains('#')));
    expect(uri.path, isNot(contains('/app-api/')));
  });

  AuthSession fakeSession(int accountType) {
    return AuthSession(
      userId: accountType,
      accessToken: 'test-token',
      refreshToken: 'test-refresh-token',
      schoolAccountId: accountType,
      schoolAccountType: accountType,
      realName: accountType == schoolAccountTypeTeacher ? 'Admin' : '佐藤',
      nickname: accountType == schoolAccountTypeTeacher ? '先生A' : '学生A',
      avatar: '',
      email: accountType == schoolAccountTypeTeacher
          ? 'teacher@example.com'
          : 'student@example.com',
      mobile: '080-0000-0000',
      programmingLanguage: 'Java',
    );
  }

  test('profile updates replace session display fields', () {
    ItClassSession.current = fakeSession(schoolAccountTypeStudent);
    ItClassSession.updateProfile(
      const MemberProfile(
        realName: '佐藤',
        nickname: 'joke',
        avatar: 'https://example.com/avatar.png',
        mobile: '09012345678',
        email: 'joke@example.com',
        programmingLanguage: 'Python',
      ),
    );

    expect(ItClassSession.current?.displayName, 'joke');
    expect(ItClassSession.current?.email, 'joke@example.com');
    expect(ItClassSession.current?.programmingLanguage, 'Python');
  });

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

    expect(find.text('学生のAI質問対応'), findsWidgets);
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
