import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_class/main.dart';

const warning = '未回答の問題があります。すべての問題に回答してから提出してください。';
http.Response ok(Object? data, {int code = 0, String msg = ''}) =>
    http.Response(
      jsonEncode({'code': code, 'data': data, 'msg': msg}),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
void main() {
  late ItClassApi previous;
  late AuthSession? session;
  final saved = <int, String>{};
  final submitted = <Map<String, dynamic>>[];
  var failSave = false;
  Completer<void>? saving;
  setUp(() {
    previous = ItClassApi.instance;
    session = ItClassSession.current;
    saved.clear();
    submitted.clear();
    failSave = false;
    saving = null;
    ItClassSession.current = AuthSession.fromJson({
      'schoolAccountId': 1,
      'schoolAccountType': 2,
      'accessToken': 'fixture',
    });
    final client = MockClient((r) async {
      final path = r.url.path.replaceFirst('/app-api/school/', '');
      switch (path) {
        case 'classroom/my-list':
        case 'teacher/list':
        case 'practice-question/list':
        case 'code-scoring/assignment/list':
          return ok([]);
        case 'ai-tutor/config/get':
          return ok({'autoAnswerEnabled': true});
        case 'ai-tutor/conversation/page':
        case 'chat/conversation/page':
        case 'course-video/page':
        case 'course-document/page':
          return ok({'list': [], 'total': 0});
        case 'exam/page':
          return ok({
            'list': [
              {
                'id': 1,
                'title': '保存確認テスト',
                'programmingLanguage': 'JAVA',
                'status': 10,
                'alwaysAvailable': true,
                'durationMinutes': 0,
                'maxAttempts': 0,
              },
            ],
            'total': 1,
          });
        case 'exam/start':
          return ok({
            'attemptId': 1,
            'examId': 1,
            'status': 0,
            'questions': [
              for (final id in [11, 12])
                {
                  'paperQuestionId': id,
                  'questionId': id,
                  'type': 1,
                  'title': '問題$id',
                  'content': '選択してください$id',
                  'score': 5,
                  'savedAnswer': saved[id],
                  'options': [
                    {'optionKey': 'A', 'content': '選択肢A$id'},
                    {'optionKey': 'B', 'content': '選択肢B$id'},
                  ],
                },
            ],
          });
        case 'exam/save-answer':
          final body = jsonDecode(r.body);
          if (saving != null) await saving!.future;
          if (failSave) return ok(null, code: 500);
          saved[body['paperQuestionId']] = body['answerContent'];
          return ok(true);
        case 'exam/submit':
          submitted.add(jsonDecode(r.body));
          return ok({'attemptId': 1});
        case 'exam/result':
          return ok({
            'attemptId': 1,
            'status': 30,
            'passed': true,
            'totalScore': 10,
            'paperTotalScore': 10,
            'answers': [],
          });
        default:
          throw StateError('Unexpected endpoint $path');
      }
    });
    ItClassApi.instance = ItClassApi.forTesting(client);
    addTearDown(client.close);
  });
  tearDown(() {
    ItClassApi.instance = previous;
    ItClassSession.current = session;
  });
  Future<void> tap(WidgetTester t, Finder f) async {
    await t.ensureVisible(f);
    await t.tap(f);
    await t.pumpAndSettle();
  }

  Future<void> mount(WidgetTester t) async {
    t.view.physicalSize = const Size(1600, 1200);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(const MaterialApp(home: StudentHomePage()));
    await t.pumpAndSettle();
    await tap(t, find.text('テスト').first);
    await tap(t, find.text('テスト開始'));
  }

  Finder card(int id) =>
      find.ancestor(of: find.text('選択してください$id'), matching: find.byType(Card));
  Future<void> choose(WidgetTester t, int id, {String key = 'A'}) =>
      tap(t, find.text('$key. 選択肢$key$id'));
  Future<void> save(WidgetTester t, int id) =>
      tap(t, find.descendant(of: card(id), matching: find.text('回答を保存')));
  Future<void> rejected(WidgetTester t) async {
    await tap(t, find.text('テストを提出'));
    expect(find.text(warning).hitTestable(), findsOneWidget);
    expect(submitted, isEmpty);
  }

  testWidgets(
    'every answer needs a successful save; changing a saved answer requires saving again',
    (t) async {
      await mount(t);
      await rejected(t);
      await choose(t, 11);
      await choose(t, 12);
      await rejected(t); // all selected, none saved
      await save(t, 11);
      await rejected(t); // one missing save
      await save(t, 12);
      await choose(t, 11, key: 'B');
      await rejected(t);
      await save(t, 11);
      await tap(t, find.text('テストを提出'));
      expect(submitted, hasLength(1));
      expect(saved, {11: 'B', 12: 'A'});
      expect(submitted.single['answers'], [
        {'paperQuestionId': 11, 'answerContent': 'B'},
        {'paperQuestionId': 12, 'answerContent': 'A'},
      ]);
      expect(find.text('テストを提出しました。採点結果は「成績履歴」で確認できます。'), findsOneWidget);
    },
  );
  testWidgets(
    'failed and pending saves cannot submit; a saved empty choice is unanswered',
    (t) async {
      await mount(t);
      await choose(t, 11);
      await choose(t, 12);
      await save(t, 12);
      failSave = true;
      await save(t, 11);
      await rejected(t);
      failSave = false;
      saving = Completer<void>();
      final saveButton = find.descendant(
        of: card(11),
        matching: find.text('回答を保存'),
      );
      await t.ensureVisible(saveButton);
      await t.tap(saveButton);
      await t.pump();
      await rejected(t);
      saving!.complete();
      await t.pumpAndSettle();
      saving = null;
      await choose(t, 11); // uncheck A
      await save(t, 11);
      await rejected(t);
    },
  );
  testWidgets(
    'reopening restores saved answers and allows submission without saving again',
    (t) async {
      saved.addAll({11: 'A', 12: 'B'});
      await mount(t);
      expect(find.text('保存済み'), findsNWidgets(2));
      await tap(t, find.text('テストを提出'));
      expect(submitted, hasLength(1));
    },
  );
}
