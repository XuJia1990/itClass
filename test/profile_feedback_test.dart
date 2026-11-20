import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_class/main.dart';

void main() {
  testWidgets('saved avatar reaches sidebar and empty contact does not save', (
    t,
  ) async {
    final previous = ItClassApi.instance;
    final session = ItClassSession.current;
    addTearDown(() {
      ItClassApi.instance = previous;
      ItClassSession.current = session;
    });
    t.view.physicalSize = const Size(1600, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    var avatar = 'https://example.test/avatar1.png';
    for (final url in [avatar, 'https://example.test/avatar2.png']) {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawColor(Colors.teal, BlendMode.src);
      final image = await t.runAsync(
        () => recorder.endRecording().toImage(2, 2),
      );
      PaintingBinding.instance.imageCache.putIfAbsent(
        NetworkImage(url),
        () => OneFrameImageStreamCompleter(
          Future.value(ImageInfo(image: image!)),
        ),
      );
    }
    final writes = <http.Request>[];
    ItClassSession.current = AuthSession.fromJson({
      'userId': 1,
      'schoolAccountId': 1,
      'schoolAccountType': 2,
      'accessToken': 'test',
      'nickname': '学生',
    });
    ItClassApi.instance = ItClassApi.forTesting(
      MockClient((r) async {
        Object? data = [];
        if (r.url.path.endsWith('/account/profile')) {
          if (r.method == 'PUT') writes.add(r);
          data = {'nickname': '学生', 'avatar': avatar, 'mobile': '09012345678'};
        } else if (r.url.path.endsWith('/page')) {
          data = {'list': [], 'total': 0};
        } else if (r.url.path.endsWith('/config/get')) {
          data = {'welcomeMessage': 'こんにちは'};
        }
        return http.Response(
          jsonEncode({'code': 0, 'data': data}),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );
    await t.pumpWidget(const MaterialApp(home: StudentHomePage()));
    await t.pumpAndSettle();
    await t.tap(find.text('設定').first);
    await t.pumpAndSettle();
    expect(find.byKey(ValueKey('sidebar-avatar-$avatar')), findsOneWidget);
    expect(find.text('アカウント情報'), findsNothing);
    avatar = 'https://example.test/avatar2.png';
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(find.byKey(ValueKey('sidebar-avatar-$avatar')), findsOneWidget);
    expect(writes, hasLength(1));
    await t.tap(find.text('連絡先').first);
    await t.pumpAndSettle();
    await t.enterText(find.widgetWithText(TextField, '連絡先'), '   ');
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(find.text('連絡先（電話番号）を入力してください。'), findsOneWidget);
    expect(writes, hasLength(1));
    await t.enterText(find.widgetWithText(TextField, '連絡先'), '09022223333');
    await t.tap(find.text('保存'));
    await t.pumpAndSettle();
    expect(writes, hasLength(2));
    expect(jsonDecode(writes.last.body)['mobile'], '09022223333');
    expect(t.takeException(), isNull);
  });
}
