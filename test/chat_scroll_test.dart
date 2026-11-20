import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_class/main.dart';

void main() {
  late ItClassApi previous;
  late AuthSession? session;
  setUp(() {
    previous = ItClassApi.instance;
    session = ItClassSession.current;
  });
  tearDown(() {
    ItClassApi.instance = previous;
    ItClassSession.current = session;
  });
  http.Response ok(Object? data) => http.Response(
    jsonEncode({'code': 0, 'data': data}),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
  Object page(List<Object> rows) => {'list': rows, 'total': rows.length};
  void api(bool teacher) {
    ItClassSession.current = AuthSession.fromJson({
      'schoolAccountId': teacher ? 7 : 5,
      'schoolAccountType': teacher ? 1 : 2,
      'accessToken': 'fixture',
    });
    final client = MockClient((r) async {
      final path = r.url.path.replaceFirst('/app-api/school/', '');
      switch (path) {
        case 'classroom/my-list':
          return ok([
            {'id': 1, 'name': 'JAVA', 'programmingLanguage': 'JAVA'},
          ]);
        case 'teacher/list':
          return ok([
            {
              'accountId': 7,
              'realName': '担当先生',
              'status': 0,
              'programmingLanguages': ['JAVA'],
            },
          ]);
        case 'course-video/page':
          return ok(
            page([
              {
                'id': 1,
                'title': 'JAVA動画',
                'programmingLanguage': 'JAVA',
                'status': 0,
              },
            ]),
          );
        case 'ai-tutor/config/get':
          return ok({'autoAnswerEnabled': true});
        case 'ai-tutor/conversation/page':
          return ok(
            page([
              {'id': 1, 'title': '長い会話'},
            ]),
          );
        case 'ai-tutor/conversation/questions':
          return ok([
            for (var i = 1; i <= 30; i++)
              {
                'id': i,
                'questionContent': '長い質問$i',
                'aiAnswer': 'AIからの説明$i\n詳細な説明です。\n改行を含む回答です。',
                'status': 10,
              },
          ]);
        case 'chat/conversation/page':
          return ok(
            page([
              {
                'id': 1,
                'peerAccountId': teacher ? 5 : 7,
                'peerRealName': teacher ? '生徒A' : '担当先生',
                'lastMessageId': 30,
                'lastMessageContent': '最後のメッセージ30',
              },
            ]),
          );
        case 'chat/message/page':
          return ok(
            page([
              for (var i = 30; i > 0; i--)
                {
                  'id': i,
                  'conversationId': 1,
                  'content': '最後のメッセージ$i\n長い会話の本文です。\n複数行のメッセージです。',
                  'senderAccountId': i.isEven ? 7 : 5,
                  'senderAccountType': i.isEven ? 1 : 2,
                },
            ]),
          );
        case 'chat/message/read':
          return ok(true);
        case 'account/profile':
          return ok({'nickname': '検証'});
        case 'practice-question/list':
        case 'code-scoring/assignment/list':
        case 'account/student/list-simple':
          return ok([]);
        case 'course-document/page':
        case 'exam/page':
        case 'ai-teacher/question/page':
        case 'exam-teacher/attempt/page':
          return ok(page([]));
        default:
          throw StateError('Unexpected endpoint $path');
      }
    });
    ItClassApi.instance = ItClassApi.forTesting(client);
    addTearDown(client.close);
  }

  Future<void> tap(WidgetTester t, String label) async {
    await t.tap(find.text(label).first);
    await t.pumpAndSettle();
  }

  ScrollPosition position(WidgetTester t) => t
      .state<ScrollableState>(
        find
            .descendant(
              of: find.byKey(const ValueKey('chat-history-scroll')),
              matching: find.byType(Scrollable),
            )
            .first,
      )
      .position;
  void atBottom(WidgetTester t) {
    final p = position(t);
    expect(p.maxScrollExtent, greaterThan(500));
    expect(p.extentAfter, lessThan(1));
  }

  for (final mode in ['ai', 'student', 'teacher']) {
    testWidgets(
      '$mode chat opens and reopens at newest message without jumping while reading history',
      (t) async {
        api(mode == 'teacher');
        t.view.physicalSize = const Size(1600, 900);
        t.view.devicePixelRatio = 1;
        addTearDown(t.view.resetPhysicalSize);
        addTearDown(t.view.resetDevicePixelRatio);
        await t.pumpWidget(
          MaterialApp(
            home: mode == 'teacher'
                ? const TeacherHomePage()
                : const StudentHomePage(),
          ),
        );
        await t.pumpAndSettle();
        Future<void> open() async {
          if (mode == 'ai') {
            await tap(t, '質問・AI回答');
            await tap(t, '長い会話');
          } else if (mode == 'teacher') {
            await tap(t, '学生チャット');
          } else {
            await tap(t, '先生に質問');
            await tap(t, '担当先生');
          }
        }

        await open();
        atBottom(t);
        position(t).jumpTo(200);
        await t.pump();
        final previousOffset = position(t).pixels;
        if (mode != 'teacher') {
          await t.enterText(find.byType(TextField).last, 'まだ送信しない下書き');
        }
        await t.pumpAndSettle();
        expect(
          position(t).pixels,
          previousOffset,
          reason: 'Typing is not a new incoming message',
        );
        await tap(t, '設定');
        await open();
        atBottom(t);
        expect(t.takeException(), isNull);
      },
    );
  }
}
