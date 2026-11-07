import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_class/main.dart';

void main() {
  test('network and platform failures never expose technical details', () {
    final errors = <Object>[
      http.ClientException(
        'Failed to fetch',
        Uri.parse('https://api.example.com/app-api/member/auth/account-login'),
      ),
      TimeoutException('GET /app-api/school/course-video/page'),
      const FormatException('<html>proxy at 127.0.0.1:48080</html>'),
      StateError('Authorization: Bearer hidden-token'),
    ];
    for (final error in errors) {
      final message = userFacingError(error);
      expect(message, isNot(contains('app-api')));
      expect(message, isNot(contains('hidden-token')));
      expect(message, isNot(contains('127.0.0.1')));
      expect(message, isNot(contains('Exception')));
    }
  });

  test('API diagnostics are hidden even inside a business-error envelope', () {
    for (final detail in [
      'HTTP 502: proxy unavailable',
      'SQLSTATE: relation school_account not found',
      'POST /school/course-document/teacher-update failed',
      'TWSCHOOL_API_BASE_URL or web/app-config.js is missing',
      'api-dev.tw-onlineschool.com cannot be resolved',
      'cn.iocoder.yudao.module.school.ServiceException',
      '{"accessToken":"hidden-token"}',
    ]) {
      expect(
        userFacingError(ApiException(detail, code: 1004002045)),
        '操作を完了できませんでした。時間をおいてもう一度お試しください。',
      );
    }
  });

  test('actionable business errors remain readable', () {
    for (final error in [
      const ApiException('ユーザー名またはパスワードが正しくありません', code: 1004002009),
      const ApiException('受験可能回数を超えています', code: 1004002029),
      const ApiException('他の講師が更新しました。最新の内容を再読み込みしてください。', code: 1004002045),
    ]) {
      expect(userFacingError(error), error.message);
    }
    expect(
      userFacingError(const ApiException('HTTP 401', code: 401)),
      contains('再度ログイン'),
    );
    expect(
      userFacingError(const ApiException('HTTP 403', code: 403)),
      contains('権限'),
    );
    expect(
      userFacingError(const ApiException('HTTP 429', code: 429)),
      contains('少し待って'),
    );
  });

  testWidgets('failed login shows a useful notice without the API URL', (
    tester,
  ) async {
    final original = ItClassApi.instance;
    ItClassApi.instance = ItClassApi.forTesting(
      MockClient((request) async {
        throw http.ClientException('Failed to fetch', request.url);
      }),
    );
    addTearDown(() => ItClassApi.instance = original);
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: StudentLoginPage()));
    await tester.enterText(
      find.widgetWithText(TextField, 'ログインID'),
      'test-account',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'パスワード'),
      'test-password',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'ログイン'));
    await tester.pumpAndSettle();
    expect(find.textContaining('通信状態を確認'), findsOneWidget);
    final visibleText = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? text.textSpan?.toPlainText() ?? '')
        .join('\n');
    expect(visibleText, isNot(contains('/app-api')));
    expect(visibleText, isNot(contains('twcschool')));
    expect(visibleText, isNot(contains('ClientException')));
    expect(visibleText, isNot(contains('TWSCHOOL_API_BASE_URL')));
    expect(tester.takeException(), isNull);
  });
}
