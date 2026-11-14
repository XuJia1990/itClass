import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_class/main.dart';

http.Response ok(Object? data) => http.Response(
  jsonEncode({'code': 0, 'data': data, 'msg': ''}),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
Map<String, Object?> page(List<Object?> rows) => {
  'list': rows,
  'total': rows.length,
};

void main() {
  late ItClassApi originalApi;
  late AuthSession? originalSession;
  late MockClient client;
  final writes = <Map<String, dynamic>>[];
  final requests = <http.Request>[];
  var graded = false;
  setUp(() {
    originalApi = ItClassApi.instance;
    originalSession = ItClassSession.current;
    writes.clear();
    requests.clear();
    graded = false;
    ItClassSession.current = AuthSession.fromJson({
      'userId': 5,
      'schoolAccountId': 5,
      'schoolAccountType': 1,
      'accessToken': 'fixture',
    });
    client = MockClient((request) async {
      requests.add(request);
      switch (request.url.path) {
        case '/app-api/school/classroom/my-list':
        case '/app-api/school/classroom/available-list':
          return ok([
            {'id': 1, 'name': 'Java', 'programmingLanguage': 'Java'},
            {'id': 2, 'name': 'Python', 'programmingLanguage': 'Python'},
          ]);
        case '/app-api/school/account/student/list-simple':
        case '/app-api/school/course-video/page':
        case '/app-api/school/course-document/page':
        case '/app-api/school/practice-question/list':
        case '/app-api/school/code-scoring/assignment/list':
          if (request.url.path.endsWith('/page')) return ok(page([]));
          return ok([]);
        case '/app-api/school/ai-teacher/question/page':
        case '/app-api/school/ai-tutor/conversation/page':
        case '/app-api/school/chat/conversation/page':
          return ok(page([]));
        case '/app-api/school/ai-tutor/config/get':
          return ok({
            'programmingLanguage': 'ALL',
            'welcomeMessage': 'プログラミングの質問',
            'autoAnswerEnabled': true,
          });
        case '/app-api/school/teacher/list':
          return ok([
            {
              'accountId': 11,
              'realName': '田中先生',
              'status': 0,
              'programmingLanguages': ['Java'],
            },
            {
              'accountId': 12,
              'realName': '山田先生',
              'status': 0,
              'programmingLanguages': ['Python'],
            },
          ]);
        case '/app-api/school/exam/page':
          return ok(
            page([
              for (final entry in [
                (1, 'Java', '田中先生', 11),
                (2, 'Python', '山田先生', 12),
              ])
                {
                  'id': entry.$1,
                  'title': '${entry.$2}検定',
                  'programmingLanguage': entry.$2,
                  'status': 10,
                  'alwaysAvailable': true,
                  'durationMinutes': 0,
                  'maxAttempts': 0,
                  'teachers': [
                    {'accountId': entry.$4, 'realName': entry.$3, 'status': 0},
                  ],
                },
            ]),
          );
        case '/app-api/school/exam-teacher/attempt/page':
          return ok(
            page(
              graded
                  ? []
                  : [
                      {
                        'id': 8,
                        'examId': 1,
                        'studentRealName': '学生A',
                        'examTitle': 'Java検定',
                        'programmingLanguage': 'Java',
                        'status': 20,
                        'attemptNo': 1,
                        'paperTotalScore': 10,
                      },
                    ],
            ),
          );
        case '/app-api/school/exam-teacher/attempt/answers':
          return ok([
            {
              'id': 11,
              'paperQuestionId': 22,
              'questionType': 5,
              'questionTitle': '変数の説明',
              'questionContent': '変数とは？',
              'answerContent': '値の保存先',
              'referenceAnswer': '値を保持する名前付き領域',
              'maxScore': 10,
              'gradingStatus': 0,
            },
          ]);
        case '/app-api/school/exam-teacher/attempt/grade':
          expect(request.method, 'PUT');
          writes.add(jsonDecode(request.body) as Map<String, dynamic>);
          graded = true;
          return ok(true);
        case '/app-api/school/exam/attempt/page':
          return ok(
            page([
              {
                'id': 8,
                'examId': 1,
                'examTitle': '過去のJava試験',
                'programmingLanguage': 'Java',
                'status': 30,
                'attemptNo': 2,
                'totalScore': 7.5,
                'paperTotalScore': 10,
                'passed': true,
              },
            ]),
          );
        case '/app-api/school/exam/result':
          return ok({
            'attemptId': 8,
            'examTitle': '過去のJava試験',
            'status': 30,
            'totalScore': 7.5,
            'paperTotalScore': 10,
            'passed': true,
            'answersVisible': true,
            'answers': [
              {
                'paperQuestionId': 22,
                'questionTitle': '変数の説明',
                'answerContent': '値の保存先',
                'referenceAnswer': '値を保持する名前付き領域',
                'score': 7.5,
                'maxScore': 10,
                'graderComment': '具体例を追加しましょう',
              },
            ],
          });
        default:
          fail('Unexpected mocked endpoint ${request.url.path}');
      }
    });
    ItClassApi.instance = ItClassApi.forTesting(client);
  });
  tearDown(() {
    ItClassApi.instance = originalApi;
    ItClassSession.current = originalSession;
    client.close();
  });

  for (final width in [1280.0, 390.0]) {
    testWidgets(
      'teacher can grade subjective answers at ${width.toInt()}px without exceeding max score',
      (tester) async {
        tester.view.physicalSize = Size(width, 1000);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const MaterialApp(home: TeacherHomePage()));
        await tester.pumpAndSettle();
        if (width < 980) {
          tester.state<ScaffoldState>(find.byType(Scaffold).first).openDrawer();
          await tester.pumpAndSettle();
        }
        final menu = find.text('成績確認').first;
        await tester.ensureVisible(menu);
        await tester.tap(menu);
        await tester.pumpAndSettle();
        final edit = find.byTooltip('採点する');
        await tester.ensureVisible(edit);
        await tester.tap(edit);
        await tester.pumpAndSettle();
        final score = find.byWidgetPredicate(
          (widget) =>
              widget is TextField &&
              widget.decoration?.labelText?.startsWith('得点（') == true,
        );
        await tester.enterText(score, '11');
        final save = find.widgetWithText(FilledButton, '採点を保存');
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(find.text('0〜10.0 の範囲で入力してください。'), findsOneWidget);
        expect(writes, isEmpty);
        await tester.enterText(score, '7.5');
        final comment = find.byWidgetPredicate(
          (widget) =>
              widget is TextField && widget.decoration?.labelText == '先生コメント',
        );
        await tester.enterText(comment, '具体例を追加しましょう');
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(writes, [
          {
            'attemptId': 8,
            'answers': [
              {'answerId': 11, 'score': 7.5, 'comment': '具体例を追加しましょう'},
            ],
          },
        ]);
        expect(find.text('該当する答案はありません。'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'student exam and teacher directory have language filters and historical scores',
    (tester) async {
      ItClassSession.current = AuthSession.fromJson({
        'userId': 8,
        'schoolAccountId': 8,
        'schoolAccountType': 2,
        'accessToken': 'fixture',
      });
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: StudentHomePage()));
      await tester.pumpAndSettle();
      await tester.tap(find.text('テスト').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('すべて').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Python').last);
      await tester.pumpAndSettle();
      expect(find.text('Java検定'), findsNothing);
      expect(find.text('Python検定'), findsOneWidget);
      await tester.tap(find.text('先生に質問').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('すべて').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Python').last);
      await tester.pumpAndSettle();
      expect(find.text('田中先生'), findsNothing);
      expect(find.text('山田先生'), findsOneWidget);
      await tester.tap(find.text('テスト').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Python').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('すべて').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('成績履歴').first);
      await tester.pumpAndSettle();
      expect(find.text('過去のJava試験'), findsOneWidget);
      final detail = find.byTooltip('採点結果を表示');
      await tester.tap(detail);
      await tester.pumpAndSettle();
      expect(find.text('先生コメント：具体例を追加しましょう'), findsOneWidget);
      final historyRequest = requests.lastWhere(
        (request) => request.url.path.endsWith('/school/exam/attempt/page'),
      );
      expect(
        historyRequest.url.queryParameters.containsKey('studentAccountId'),
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );

  test('exam API forwards language and classroom filters', () async {
    await ItClassApi.instance.examPage(
      programmingLanguage: 'JAVA',
      classroomId: 1,
    );
    final request = requests.single;
    expect(request.url.queryParameters['programmingLanguage'], 'JAVA');
    expect(request.url.queryParameters['classroomId'], '1');
  });
}
