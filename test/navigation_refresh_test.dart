import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_class/main.dart';

http.Response response(Object? data, {int code = 0}) => http.Response(
  jsonEncode({'code': code, 'data': data, 'msg': code == 0 ? '' : '更新失敗'}),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
Object page(List<Object> rows) => {'list': rows, 'total': rows.length};

void main() {
  late ItClassApi previousApi;
  late AuthSession? previousSession;
  final requests = <http.Request>[];
  var revision = 1;
  Completer<http.Response>? delayedTopics;
  var failTopics = false;
  Completer<http.Response>? delayedMessages;

  setUp(() {
    previousApi = ItClassApi.instance;
    previousSession = ItClassSession.current;
    requests.clear();
    revision = 1;
    delayedTopics = null;
    failTopics = false;
    delayedMessages = null;
    ItClassSession.current = AuthSession.fromJson({
      'userId': 7,
      'schoolAccountId': 7,
      'schoolAccountType': 1,
      'accessToken': 'fixture',
      'nickname': 'テスト',
    });
    final client = MockClient((r) async {
      requests.add(r);
      final path = r.url.path.replaceFirst('/app-api/school/', '');
      switch (path) {
        case 'classroom/my-list':
          return response([
            {'id': 1, 'name': 'JAVA', 'programmingLanguage': 'JAVA'},
          ]);
        case 'account/profile':
          return response({
            'nickname': '名前$revision',
            'email': 'user$revision@example.test',
          });
        case 'ai-tutor/conversation/page':
          if (delayedTopics != null) return delayedTopics!.future;
          if (failTopics) return response(null, code: 500);
          return response(
            page([
              {'id': 1, 'title': '会話$revision'},
            ]),
          );
        case 'ai-tutor/ask':
          return response({'status': 10, 'aiAnswer': '送信後の回答'});
        case 'ai-tutor/conversation/questions':
          if (delayedMessages != null) return delayedMessages!.future;
          return response([
            {
              'id': 1,
              'questionContent': '質問です',
              'status': 30,
              'teacherReplies': [
                {'id': 1, 'answer': '最新の回答$revision', 'teacherName': '先生名'},
              ],
            },
          ]);
        case 'ai-tutor/config/get':
          return response({
            'welcomeMessage': 'こんにちは',
            'autoAnswerEnabled': true,
          });
        case 'ai-teacher/question/page':
          return response(
            page([
              {
                'id': 1,
                'conversationId': 1,
                'studentName': '生徒',
                'questionContent': '先生への質問$revision',
                'status': 20,
              },
            ]),
          );
        case 'teacher/list':
        case 'account/student/list-simple':
        case 'practice-question/list':
        case 'code-scoring/assignment/list':
          return response([]);
        case 'chat/conversation/page':
          return response(
            page([
              {
                'id': 1,
                'peerAccountId': 8,
                'peerRealName': '相手',
                'lastMessageId': 1,
              },
            ]),
          );
        case 'chat/message/page':
          return response(
            page([
              {
                'id': revision,
                'conversationId': 1,
                'content': 'メッセージ$revision',
                'senderAccountType': 2,
                'senderAccountId': 8,
              },
            ]),
          );
        case 'chat/message/read':
          return response(true);
        case 'course-video/page':
        case 'course-document/page':
        case 'course-video/teacher-page':
        case 'course-document/teacher-page':
        case 'exam/page':
        case 'exam-teacher/attempt/page':
          return response(page([]));
        default:
          throw StateError('Unexpected request: ${r.method} ${r.url}');
      }
    });
    ItClassApi.instance = ItClassApi.forTesting(client);
    addTearDown(client.close);
  });
  tearDown(() {
    ItClassApi.instance = previousApi;
    ItClassSession.current = previousSession;
  });
  int count(String endpoint) =>
      requests.where((r) => r.url.path.endsWith(endpoint)).length;
  Future<void> mount(WidgetTester t, {bool teacher = false}) async {
    t.view.physicalSize = const Size(1600, 1100);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      MaterialApp(
        home: teacher ? const TeacherHomePage() : const StudentHomePage(),
      ),
    );
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, String text) async {
    await t.tap(find.text(text).first);
    await t.pumpAndSettle();
  }

  for (final teacher in [false, true]) {
    testWidgets(
      '${teacher ? 'teacher' : 'student'} every left tab refreshes on re-click without polling',
      (t) async {
        await mount(t, teacher: teacher);
        final tabs = teacher
            ? {
                '学生のAI質問対応': ['ai-teacher/question/page'],
                '成績確認': ['classroom/my-list', 'exam-teacher/attempt/page'],
                '学生チャット': ['chat/conversation/page', 'chat/message/page'],
                '教材・テストアップロード': [
                  'classroom/my-list',
                  'course-video/teacher-page',
                ],
                'システム管理': ['account/student/list-simple'],
                '設定': ['account/profile'],
              }
            : {
                '質問・AI回答': [
                  'ai-tutor/conversation/page',
                  'ai-tutor/config/get',
                ],
                'コード採点': ['code-scoring/assignment/list'],
                'AI教室': [
                  'course-video/page',
                  'course-document/page',
                  'practice-question/list',
                ],
                'テスト': ['exam/page'],
                '先生に質問': ['teacher/list', 'chat/conversation/page'],
                '設定': ['account/profile'],
              };
        for (final entry in tabs.entries) {
          await tap(t, entry.key);
          final before = {
            for (final endpoint in entry.value) endpoint: count(endpoint),
          };
          await tap(t, entry.key);
          for (final endpoint in entry.value) {
            expect(
              count(endpoint),
              before[endpoint]! + 1,
              reason: '${entry.key}: $endpoint',
            );
          }
          final settled = requests.length;
          await t.pump(const Duration(minutes: 1));
          expect(
            requests.length,
            settled,
            reason: 'No idle polling in ${entry.key}',
          );
          expect(t.takeException(), isNull);
        }
        expect(count('/exam/start'), 0);
        expect(count('/ai-tutor/ask'), 0);
        expect(count('/chat/message/send'), 0);
      },
    );
  }

  testWidgets(
    'student re-click fetches teacher replies without clearing the unsent AI draft',
    (t) async {
      await mount(t);
      await tap(t, '会話1');
      await t.enterText(find.byType(TextField), '未送信の質問');
      revision = 2;
      await tap(t, '質問・AI回答');
      expect(find.text('最新の回答2'), findsOneWidget);
      expect(find.text('未送信の質問'), findsOneWidget);
      expect(count('/ai-tutor/ask'), 0);
    },
  );

  testWidgets('rapid menu clicks coalesce and a failed read can be retried', (
    t,
  ) async {
    await mount(t);
    final before = count('ai-tutor/conversation/page');
    final pending = delayedTopics = Completer<http.Response>();
    for (var i = 0; i < 4; i++) {
      await t.tap(find.text('質問・AI回答'));
      await t.pump(const Duration(milliseconds: 20));
    }
    expect(count('ai-tutor/conversation/page'), before + 1);
    delayedTopics = null;
    revision = 2;
    pending.complete(
      response(
        page([
          {'id': 1, 'title': '古い会話'},
        ]),
      ),
    );
    await t.pumpAndSettle();
    expect(count('ai-tutor/conversation/page'), before + 2);
    expect(find.text('会話2'), findsWidgets);
    failTopics = true;
    await tap(t, '質問・AI回答');
    expect(find.textContaining('一部のデータを読み込めませんでした'), findsOneWidget);
    failTopics = false;
    revision = 3;
    await tap(t, '質問・AI回答');
    expect(find.text('会話3'), findsWidgets);
    expect(find.textContaining('一部のデータを読み込めませんでした'), findsNothing);
  });

  testWidgets(
    'teacher refresh preserves reply and profile drafts while fetching saved data',
    (t) async {
      await mount(t, teacher: true);
      await t.enterText(find.byType(TextField), '下書き返信');
      revision = 2;
      await tap(t, '学生のAI質問対応');
      expect(find.text('先生への質問2'), findsWidgets);
      expect(find.text('下書き返信'), findsOneWidget);
      await tap(t, '設定');
      final name = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'ニックネーム',
      );
      await t.enterText(name, '未保存の名前');
      revision = 3;
      await tap(t, '設定');
      expect(find.text('未保存の名前'), findsOneWidget);
      expect(find.text('user3@example.test'), findsWidgets);
      expect(ItClassSession.current?.nickname, '名前3');
      expect(t.takeException(), isNull);
    },
  );
  testWidgets(
    'a slow history refresh never overwrites a newer sent AI message',
    (t) async {
      await mount(t);
      await tap(t, '会話1');
      final pending = delayedMessages = Completer<http.Response>();
      await t.tap(find.text('質問・AI回答'));
      await t.pump(const Duration(milliseconds: 20));
      await t.enterText(find.byType(TextField), '新しい質問');
      await t.tap(find.text('送信'));
      await t.pump(const Duration(milliseconds: 50));
      delayedMessages = null;
      pending.complete(
        response([
          {
            'id': 1,
            'questionContent': '古い質問',
            'status': 10,
            'aiAnswer': '古い回答',
          },
        ]),
      );
      await t.pumpAndSettle();
      expect(find.text('新しい質問'), findsOneWidget);
      expect(find.text('送信後の回答'), findsOneWidget);
      expect(find.text('古い回答'), findsNothing);
    },
  );
}
