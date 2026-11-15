import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_class/main.dart';

http.Response ok(Object? data, {int code = 0}) => http.Response(
  jsonEncode({'code': code, 'data': data, 'msg': code == 0 ? '' : '通信エラー'}),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  late ItClassApi previousApi;
  late AuthSession? previousSession;
  final stored = <String, Map<String, dynamic>>{};
  final writes = <Map<String, dynamic>>[];
  bool fail = false;
  Completer<void>? pending;
  int revision = 0;

  void login(String token) {
    ItClassSession.current = AuthSession.fromJson({
      'userId': token == 'studentA' ? 1 : 2,
      'schoolAccountId': token == 'studentA' ? 1 : 2,
      'schoolAccountType': 2,
      'accessToken': token,
      'nickname': token,
    });
  }

  setUp(() {
    previousApi = ItClassApi.instance;
    previousSession = ItClassSession.current;
    stored.clear();
    writes.clear();
    fail = false;
    pending = null;
    revision = 0;
    login('studentA');
    final client = MockClient((r) async {
      final owner = r.headers['Authorization'] ?? r.headers['authorization']!;
      final path = r.url.path.replaceFirst('/app-api/school/', '');
      if (path == 'practice-question/list') {
        return ok([
          {
            'id': 41,
            'classroomId': 1,
            'chapterNo': 1,
            'programmingLanguage': 'JAVA',
            'lessonTitle': 'Java練習01',
            'title': 'JVM問題',
            'content': 'JVMは何を実行しますか？',
            'options': [
              {'key': 'A', 'content': 'PDFを表示'},
              {'key': 'B', 'content': 'バイトコードを実行'},
            ],
            'correctOption': 'B',
            'analysis': '解説',
            'answer': stored[owner],
          },
        ]);
      }
      if (path == 'practice-question/answer') {
        final body = jsonDecode(r.body) as Map<String, dynamic>;
        writes.add(body);
        if (pending != null) await pending!.future;
        if (fail) return ok(null, code: 500);
        final answer = <String, dynamic>{
          ...?stored[owner],
          'questionId': body['questionId'],
          'selectedOption': body['selectedOption'],
          'updateTime':
              '2026-11-15T10:00:${(++revision).toString().padLeft(2, '0')}',
          if (body['checkAnswer'] == true) ...{
            'checkedOption': body['selectedOption'],
            'correct': body['selectedOption'] == 'B',
            'correctOption': 'B',
            'analysis': '解説',
            'checkedAt': '2026-11-15T10:00:00',
          },
        };
        stored[owner] = answer;
        return ok(answer);
      }
      if (path == 'ai-tutor/config/get') return ok({'welcomeMessage': 'こんにちは'});
      if (path.endsWith('/page')) return ok({'list': [], 'total': 0});
      if (path == 'classroom/my-list') {
        return ok([
          {'id': 1, 'name': 'JAVA', 'programmingLanguage': 'JAVA'},
        ]);
      }
      return ok([]);
    });
    ItClassApi.instance = ItClassApi.forTesting(client);
    addTearDown(client.close);
  });
  tearDown(() {
    ItClassApi.instance = previousApi;
    ItClassSession.current = previousSession;
  });

  Future<void> open(WidgetTester t) async {
    t.view.physicalSize = const Size(1600, 1200);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(MaterialApp(home: StudentHomePage(key: UniqueKey())));
    await t.pumpAndSettle();
    await t.tap(find.text('AI教室').first);
    await t.pumpAndSettle();
    await t.tap(find.byType(DropdownButtonFormField<LearningMode>));
    await t.pumpAndSettle();
    await t.tap(find.text('問題バンク').last);
    await t.pumpAndSettle();
  }

  Future<void> tap(WidgetTester t, String label) async {
    await t.tap(find.text(label).first);
    await t.pumpAndSettle();
  }

  testWidgets(
    'draft and server-checked result survive page recreation and a new login',
    (t) async {
      await open(t);
      await tap(t, 'PDFを表示');
      expect(writes.last['checkAnswer'], false);
      expect(find.text('選択を保存済み・未確認'), findsOneWidget);
      await open(t);
      expect(find.text('選択を保存済み・未確認'), findsOneWidget);
      await tap(t, '解答を確認');
      expect(find.text('不正解・保存済み'), findsOneWidget);
      expect(find.textContaining('1/1問確認済み'), findsWidgets);
      await tap(t, 'バイトコードを実行');
      expect(find.textContaining('前回の確認：A · 不正解'), findsOneWidget);
      login('studentA');
      await open(t);
      expect(find.text('選択を保存済み・未確認'), findsOneWidget);
      expect(find.textContaining('前回の確認：A · 不正解'), findsOneWidget);
      await tap(t, '解答を確認');
      expect(find.text('正解・保存済み'), findsOneWidget);
      await open(t);
      expect(find.text('正解です'), findsOneWidget);
      expect(find.textContaining('1問正解'), findsOneWidget);
      expect(t.takeException(), isNull);
    },
  );

  testWidgets('different student has no answers from the previous account', (
    t,
  ) async {
    await open(t);
    await tap(t, 'バイトコードを実行');
    await tap(t, '解答を確認');
    login('studentB');
    await open(t);
    expect(find.text('未回答'), findsOneWidget);
    expect(find.textContaining('前回の確認'), findsNothing);
    login('studentA');
    await open(t);
    expect(find.text('正解です'), findsOneWidget);
  });

  testWidgets(
    'failed check keeps saved draft and supports retry without showing a result',
    (t) async {
      await open(t);
      await tap(t, 'バイトコードを実行');
      fail = true;
      await tap(t, '解答を確認');
      expect(find.text('正解です'), findsNothing);
      expect(find.text('選択を保存済み・未確認'), findsOneWidget);
      expect(find.text('保存を再試行'), findsOneWidget);
      fail = false;
      await tap(t, '保存を再試行');
      expect(find.text('正解です'), findsOneWidget);
    },
  );

  testWidgets(
    'in-flight save blocks duplicate writes and does not poll when idle',
    (t) async {
      await open(t);
      pending = Completer<void>();
      await t.tap(find.text('バイトコードを実行'));
      await t.pump();
      await t.tap(find.text('PDFを表示'));
      await t.pump();
      expect(writes.length, 1);
      pending!.complete();
      await t.pumpAndSettle();
      final count = writes.length;
      await t.pump(const Duration(minutes: 1));
      expect(writes.length, count);
      expect(t.takeException(), isNull);
    },
  );
}
