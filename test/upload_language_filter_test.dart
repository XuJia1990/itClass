import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_class/main.dart';

void main() {
  late ItClassApi originalApi;
  late AuthSession? originalSession;
  late MockClient client;
  final requests = <http.Request>[];
  var languages = <String>[];
  setUp(() {
    originalApi = ItClassApi.instance;
    originalSession = ItClassSession.current;
    languages = ['Flutter', 'PHP'];
    requests.clear();
    ItClassSession.current = AuthSession.fromJson({
      'userId': 27,
      'schoolAccountId': 27,
      'schoolAccountType': 1,
      'accessToken': 'test-only',
      'realName': '担当先生',
    });
    client = MockClient((request) async {
      requests.add(request);
      final path = request.url.path;
      Object data;
      if (path.endsWith('/classroom/my-list')) {
        data = [
          for (var i = 0; i < languages.length; i++)
            {
              'id': i + 1,
              'name': languages[i],
              'programmingLanguage': languages[i],
            },
        ];
      } else if (path.endsWith('/classroom/available-list')) {
        fail('Upload filters must not use the global classroom catalog');
      } else if (path.endsWith('/teacher-page')) {
        data = {
          'list': [
            for (final language
                in request.url.queryParameters['programmingLanguages']!.split(
                  ',',
                ))
              {
                'id': language.hashCode.abs(),
                'title': '$language教材',
                'programmingLanguage': language,
                'status': 0,
                'chapterNo': 1,
              },
          ],
          'total': 41,
        };
      } else if (path.endsWith('/page')) {
        data = {'list': [], 'total': 0};
      } else if (path.endsWith('/list-simple')) {
        data = [];
      } else {
        fail('Unexpected endpoint $path');
      }
      return http.Response(
        jsonEncode({'code': 0, 'data': data, 'msg': ''}),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    ItClassApi.instance = ItClassApi.forTesting(client);
  });
  tearDown(() {
    ItClassApi.instance = originalApi;
    ItClassSession.current = originalSession;
    client.close();
  });

  Future<void> tap(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        350,
        scrollable: find.descendant(
          of: find.byType(ListView).last,
          matching: find.byType(Scrollable),
        ).first,
      );
    }
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<void> mount(WidgetTester tester, double width) async {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: TeacherHomePage()));
    await tester.pumpAndSettle();
    if (width < 980) await tap(tester, find.byTooltip('Open navigation menu'));
    await tap(tester, find.text('教材・テストアップロード'));
  }

  Future<void> selectLanguage(WidgetTester tester, String language) async {
    if (find.byType(DropdownButtonFormField<String>).evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        find.byType(DropdownButtonFormField<String>),
        -350,
        scrollable: find.descendant(
          of: find.byType(ListView).last,
          matching: find.byType(Scrollable),
        ).first,
      );
    }
    await tap(tester, find.byType(DropdownButtonFormField<String>));
    await tap(tester, find.text(language).last);
  }

  Future<void> selectType(
    WidgetTester tester,
    String type,
    double width,
  ) async {
    if (width < 980) await tap(tester, find.byTooltip('一覧・絞り込み'));
    await tap(tester, find.text(type));
    if (width < 980) await tap(tester, find.byTooltip('一覧を閉じる'));
  }

  http.Request last(String ending) =>
      requests.lastWhere((request) => request.url.path.endsWith(ending));

  for (final width in [1280.0, 390.0]) {
    testWidgets(
      'upload language scope follows teacher courses across tabs at $width',
      (tester) async {
        await mount(tester, width);
        final dropdown = tester.widget<DropdownButton<String>>(
          find.byType(DropdownButton<String>),
        );
        expect(dropdown.value, '');
        expect(dropdown.items!.map((item) => item.value), [
          '',
          'Flutter',
          'PHP',
        ]);
        expect(
          last(
            '/course-video/teacher-page',
          ).url.queryParameters['programmingLanguages'],
          'Flutter,PHP',
        );
        await tap(tester, find.widgetWithText(OutlinedButton, '次へ'));
        expect(
          last('/course-video/teacher-page').url.queryParameters['pageNo'],
          '2',
        );
        await selectLanguage(tester, 'Flutter');
        expect(
          last(
            '/course-video/teacher-page',
          ).url.queryParameters['programmingLanguages'],
          'Flutter',
        );
        expect(
          last('/course-video/teacher-page').url.queryParameters['pageNo'],
          '1',
        );
        expect(find.text('PHP教材'), findsNothing);
        await selectType(tester, '文書教材アップロード', width);
        expect(
          last(
            '/course-document/teacher-page',
          ).url.queryParameters['programmingLanguages'],
          'Flutter',
        );
        await selectType(tester, 'テストアップロード', width);
        await tap(tester, find.widgetWithText(ChoiceChip, '試験'));
        expect(
          last(
            '/exam-teacher/exam/page',
          ).url.queryParameters['programmingLanguages'],
          'Flutter',
        );
        await tap(tester, find.widgetWithText(ChoiceChip, '試験用紙'));
        expect(
          last(
            '/exam-teacher/paper/page',
          ).url.queryParameters['programmingLanguages'],
          'Flutter',
        );
        await tap(tester, find.widgetWithText(ChoiceChip, '問題'));
        expect(
          last(
            '/exam-teacher/question/page',
          ).url.queryParameters['programmingLanguages'],
          'Flutter',
        );
        await selectLanguage(tester, 'すべて');
        expect(
          last(
            '/exam-teacher/question/page',
          ).url.queryParameters['programmingLanguages'],
          'Flutter,PHP',
        );
        final count = requests.length;
        await tester.pump(const Duration(seconds: 30));
        expect(requests.length, count, reason: 'No background request loop');
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
  testWidgets(
    'teacher with no teaching languages never loads all shared resources',
    (tester) async {
      languages = [];
      await mount(tester, 1280);
      expect(find.text('担当する学習言語が登録されていません。'), findsOneWidget);
      expect(
        requests.where((r) => r.url.path.endsWith('/teacher-page')),
        isEmpty,
      );
      await selectType(tester, 'テストアップロード', 1280);
      expect(
        requests.where((r) => r.url.path.endsWith('/exam-teacher/exam/page')),
        isEmpty,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
