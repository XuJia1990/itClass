import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_class/main.dart';

void main() {
  late ItClassApi previous;
  late AuthSession? previousSession;
  Completer<http.Response>? pending;
  final requests = <http.Request>[];
  http.Response response(Object? data, {int code = 0}) => http.Response(
    jsonEncode({
      'code': code,
      'data': data,
      'msg': code == 0 ? '' : '採点できません。再試行してください。',
    }),
    200,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
  Map<String, Object> assignment(int id, String language) => {
    'id': id,
    'title': '$language練習$id',
    'level': language,
    'status': '第1回',
    'summary': '課題$id',
    'prompt': '課題$id',
    'starterCode': 'draft$id',
    'requirements': <String>[],
  };
  Map<String, Object> result() => {
    'score': 100,
    'gradingMethod': 'REFERENCE_MATCH',
    'examTitle': 'Flutter練習1',
    'examDate': '2026/11/20',
    'correctItems': ['一致'],
    'deductions': <Object>[],
    'standardAnswer': 'reference',
    'tips': <String>[],
  };
  setUp(() {
    previous = ItClassApi.instance;
    previousSession = ItClassSession.current;
    pending = null;
    requests.clear();
    ItClassSession.current = AuthSession.fromJson({
      'userId': 1,
      'schoolAccountId': 1,
      'schoolAccountType': 2,
      'accessToken': 'fixture',
      'nickname': '学生',
    });
    ItClassApi.instance = ItClassApi.forTesting(
      MockClient((r) async {
        requests.add(r);
        final path = r.url.path;
        if (path.endsWith('/code-scoring/assignment/list')) {
          return response([
            assignment(1, 'Flutter'),
            assignment(2, 'Flutter'),
            assignment(3, 'JAVA'),
            assignment(4, 'PHP'),
          ]);
        }
        if (path.endsWith('/code-scoring/score')) {
          return pending?.future ?? response(result());
        }
        if (path.endsWith('/account/profile')) {
          return response({'nickname': '学生'});
        }
        if (path.endsWith('/ai-tutor/config/get')) {
          return response({'welcomeMessage': 'こんにちは'});
        }
        if (path.endsWith('/page')) {
          return response({'list': <Object>[], 'total': 0});
        }
        return response(<Object>[]);
      }),
    );
  });
  tearDown(() {
    ItClassApi.instance = previous;
    ItClassSession.current = previousSession;
  });
  Future<void> mount(WidgetTester t) async {
    t.view.physicalSize = const Size(1400, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(const MaterialApp(home: StudentHomePage()));
    await t.pumpAndSettle();
    await t.tap(find.text('コード採点'));
    await t.pumpAndSettle();
  }

  Future<void> language(WidgetTester t, String value) async {
    await t.tap(find.byType(DropdownButtonFormField<String>));
    await t.pumpAndSettle();
    await t.tap(find.text(value).last);
    await t.pumpAndSettle();
  }

  testWidgets(
    'filters real languages, defaults first and keeps separate drafts',
    (t) async {
      await mount(t);
      expect(find.text('Flutter練習1'), findsOneWidget);
      expect(find.text('JAVA練習3'), findsNothing);
      expect(find.text('コード課題'), findsNothing);
      expect(find.text('先生に相談'), findsNothing);
      await t.enterText(find.byType(TextField), 'my Flutter draft');
      await t.tap(find.byType(DropdownButtonFormField<String>));
      await t.pumpAndSettle();
      expect(find.text('すべて'), findsNothing);
      expect(find.text('すべての言語'), findsNothing);
      await t.tap(find.text('PHP').last);
      await t.pumpAndSettle();
      expect(find.text('PHP練習4'), findsOneWidget);
      expect(find.text('Flutter練習1'), findsNothing);
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        'draft4',
      );
      await language(t, 'Flutter');
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        'my Flutter draft',
      );
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'changing question discards delayed old grade; edits clear current result',
    (t) async {
      await mount(t);
      pending = Completer<http.Response>();
      await t.ensureVisible(find.text('コードを提出して採点'));
      await t.tap(find.text('コードを提出して採点'));
      await t.pump();
      await t.tap(find.text('Flutter練習2'));
      await t.pump();
      pending!.complete(response(result()));
      await t.pumpAndSettle();
      expect(find.text('標準答案との一致を確認しました。'), findsNothing);
      pending = null;
      await t.ensureVisible(find.text('コードを提出して採点'));
      await t.tap(find.text('コードを提出して採点'));
      await t.pumpAndSettle();
      expect(find.text('標準答案との一致を確認しました。'), findsOneWidget);
      await t.enterText(find.byType(TextField), 'changed');
      await t.pump();
      expect(find.text('標準答案との一致を確認しました。'), findsNothing);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox.shrink());
    },
  );
  testWidgets(
    'review failure preserves code and never displays a guessed score',
    (t) async {
      await mount(t);
      await t.enterText(find.byType(TextField), 'keep my code');
      pending = Completer<http.Response>();
      await t.ensureVisible(find.text('コードを提出して採点'));
      await t.tap(find.text('コードを提出して採点'));
      await t.pump();
      pending!.complete(response(null, code: 1004002053));
      await t.pumpAndSettle();
      expect(find.textContaining('採点できません'), findsOneWidget);
      expect(
        t.widget<TextField>(find.byType(TextField)).controller!.text,
        'keep my code',
      );
      expect(
        requests.where((r) => r.url.path.endsWith('/code-scoring/score')),
        hasLength(1),
      );
      await t.pumpWidget(const SizedBox.shrink());
    },
  );
}
