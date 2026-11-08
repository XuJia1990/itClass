import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_class/main.dart';

http.Response envelope(Object? data, {int code = 0}) => http.Response(
  jsonEncode({
    'code': code,
    'data': data,
    'msg': code == 0 ? '' : '一時的に読み込めません',
  }),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  late ItClassApi originalApi;
  late AuthSession? originalSession;
  final replies = <Map<String, Object>>[];
  late List<http.Request> requests;
  var failHistory = false;
  var failReplyRefresh = false;
  Completer<http.Response>? pendingReply;
  Completer<http.Response>? pendingHistory;
  Map<String, dynamic> question() => {
    'id': 11,
    'conversationId': 9,
    'studentName': '生徒A',
    'questionContent': '配列とは？',
    'status': replies.isEmpty ? 20 : 30,
    'teacherAnswer': replies.isEmpty ? null : replies.last['answer'],
    'teacherReplies': List.of(replies),
  };
  Map<String, dynamic> message(int id, {int conversation = 1}) => {
    'id': id,
    'conversationId': conversation,
    'content': '履歴メッセージ$id',
    'senderAccountId': id.isEven ? 7 : 5,
    'senderAccountType': id.isEven ? 1 : 2,
    'senderRealName': id.isEven ? '田中' : '佐藤',
    'senderNickname': id.isEven ? '田中先生' : '佐藤さん',
  };

  setUp(() {
    originalApi = ItClassApi.instance;
    originalSession = ItClassSession.current;
    replies.clear();
    requests = [];
    failHistory = false;
    failReplyRefresh = false;
    pendingReply = null;
    pendingHistory = null;
    ItClassSession.current = AuthSession.fromJson({
      'userId': 7,
      'schoolAccountId': 7,
      'schoolAccountType': 1,
      'accessToken': 'fixture',
      'refreshToken': 'fixture-refresh',
      'realName': '先生',
    });
    final client = MockClient((request) async {
      requests.add(request);
      switch (request.url.path) {
        case '/app-api/school/classroom/my-list':
        case '/app-api/school/account/student/list-simple':
          return envelope([]);
        case '/app-api/school/exam-teacher/attempt/page':
          return envelope({'list': [], 'total': 0});
        case '/app-api/school/ai-teacher/question/page':
          return envelope({
            'list': [question()],
            'total': 1,
          });
        case '/app-api/school/ai-teacher/question/get':
          return envelope(
            failReplyRefresh ? null : question(),
            code: failReplyRefresh ? 500 : 0,
          );
        case '/app-api/school/ai-teacher/question/reply':
          replies.add({
            'id': replies.length + 1,
            'answer': jsonDecode(request.body)['answer'],
          });
          return pendingReply == null ? envelope(true) : pendingReply!.future;
        case '/app-api/school/chat/conversation/page':
          return envelope({
            'list': [
              for (final id in [1, 2])
                {
                  'id': id,
                  'peerAccountId': id + 4,
                  'peerRealName': '生徒$id',
                  'resourceName': 'Java',
                  'lastMessageId': 102,
                  'lastMessageContent': '最新の相談$id',
                },
            ],
            'total': 2,
          });
        case '/app-api/school/chat/message/page':
          if (failHistory) return envelope(null, code: 500);
          if (request.url.queryParameters['conversationId'] == '2') {
            return envelope({
              'list': [message(201, conversation: 2)],
              'total': 1,
            });
          }
          if (pendingHistory != null) return pendingHistory!.future;
          final before = request.url.queryParameters['beforeMessageId'];
          return envelope({
            'list': before == null
                ? [message(102), message(101)]
                : [message(100)],
            'total': before == null ? 3 : 1,
          });
        case '/app-api/school/chat/message/read':
          return envelope(true);
        default:
          throw StateError('Unexpected fixture endpoint: ${request.url.path}');
      }
    });
    ItClassApi.instance = ItClassApi.forTesting(client);
    addTearDown(client.close);
  });

  tearDown(() {
    ItClassApi.instance = originalApi;
    ItClassSession.current = originalSession;
  });

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1500, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: TeacherHomePage()));
    await tester.pumpAndSettle();
  }

  test(
    'student history keeps every teacher response without duplicating the legacy answer',
    () {
      final messages = chatMessagesFromAiQuestionJson({
        'questionContent': '質問',
        'status': 30,
        'teacherAnswer': '補足',
        'teacherReplies': [
          {'id': 1, 'answer': '説明', 'teacherAccountId': 7, 'teacherName': '田中'},
          {'id': 2, 'answer': '補足', 'teacherAccountId': 8, 'teacherName': '鈴木'},
          {'id': 3, 'answer': '補足', 'teacherAccountId': 7, 'teacherName': '田中'},
        ],
      });
      expect(messages.map((m) => m.text), ['質問', '説明', '補足', '補足']);
      expect(messages.skip(1).map((m) => m.senderName), ['田中', '鈴木', '田中']);
      expect(messages.skip(1).map((m) => m.senderAccountId), [7, 8, 7]);
      expect(
        messages.skip(1).every((m) => m.author == MessageAuthor.teacher),
        isTrue,
      );
    },
  );

  testWidgets('teacher can send two replies and retains both after reopening', (
    tester,
  ) async {
    await mount(tester);
    for (final answer in ['最初の回答', '追加の説明']) {
      await tester.enterText(find.byType(TextField), answer);
      await tester.tap(find.text('学生へ回答'));
      await tester.pumpAndSettle();
    }
    expect(find.text('最初の回答'), findsOneWidget);
    expect(find.text('追加の説明'), findsOneWidget);
    await tester.tap(find.text('システム管理'));
    await tester.pumpAndSettle();
    expect(find.text('既存学生を追加'), findsNothing);
    expect(find.text('新規学生作成'), findsOneWidget);
    await tester.tap(find.text('学生のAI質問対応'));
    await tester.pumpAndSettle();
    expect(find.text('最初の回答'), findsOneWidget);
    expect(find.text('追加の説明'), findsOneWidget);
    expect(replies, hasLength(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'sending is guarded and a failed read never resends a saved reply',
    (tester) async {
      pendingReply = Completer<http.Response>();
      failReplyRefresh = true;
      await mount(tester);
      await tester.enterText(find.byType(TextField), '保存済みの回答');
      await tester.tap(find.text('学生へ回答'));
      await tester.pump();
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '送信中…'))
            .onPressed,
        isNull,
      );
      pendingReply!.complete(envelope(true));
      await tester.pumpAndSettle();
      expect(replies, hasLength(1));
      expect(find.text('保存済みの回答'), findsOneWidget);
      expect(find.textContaining('回答は保存されました。'), findsOneWidget);
    },
  );

  testWidgets(
    'teacher history loads older messages and survives leaving and returning',
    (tester) async {
      await mount(tester);
      await tester.tap(find.text('学生チャット'));
      await tester.pumpAndSettle();
      expect(find.text('履歴メッセージ101'), findsOneWidget);
      expect(find.text('履歴メッセージ102'), findsOneWidget);
      expect(find.text('佐藤さん'), findsOneWidget);
      expect(find.text('田中先生'), findsNothing);
      expect(
        tester.getTopLeft(find.text('佐藤さん')).dx,
        lessThan(tester.getTopLeft(find.text('履歴メッセージ101')).dx),
      );
      expect(
        tester.getTopLeft(find.text('履歴メッセージ102')).dx,
        greaterThan(tester.getTopLeft(find.text('履歴メッセージ101')).dx),
        reason:
            'The signed-in teacher replies on the right; the student is on the left.',
      );
      await tester.tap(find.text('以前のメッセージを表示'));
      await tester.pumpAndSettle();
      expect(find.text('履歴メッセージ100'), findsOneWidget);
      expect(find.text('以前のメッセージを表示'), findsNothing);
      expect(
        requests.where(
          (r) => r.url.queryParameters['beforeMessageId'] == '101',
        ),
        hasLength(1),
      );
      final reads = requests.length;
      await tester.pump(const Duration(minutes: 2));
      expect(requests.length, reads); // no background polling
      await tester.tap(find.text('システム管理'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('学生チャット'));
      await tester.pumpAndSettle();
      expect(find.text('履歴メッセージ101'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'failed history shows a retry rather than an empty conversation',
    (tester) async {
      failHistory = true;
      await mount(tester);
      await tester.tap(find.text('学生チャット'));
      await tester.pumpAndSettle();
      expect(find.text('会話履歴を読み込めませんでした'), findsOneWidget);
      expect(find.text('メッセージはありません'), findsNothing);
      failHistory = false;
      await tester.tap(find.text('更新'));
      await tester.pumpAndSettle();
      expect(find.text('履歴メッセージ101'), findsOneWidget);
    },
  );

  testWidgets(
    'late history response cannot replace another student conversation',
    (tester) async {
      pendingHistory = Completer<http.Response>();
      await mount(tester);
      await tester.tap(find.text('学生チャット'));
      await tester.pump();
      await tester.tap(find.text('生徒2'));
      await tester.pumpAndSettle();
      expect(find.text('履歴メッセージ201'), findsOneWidget);
      pendingHistory!.complete(
        envelope({
          'list': [message(101)],
          'total': 1,
        }),
      );
      await tester.pumpAndSettle();
      expect(find.text('履歴メッセージ101'), findsNothing);
      expect(find.text('履歴メッセージ201'), findsOneWidget);
    },
  );
}
