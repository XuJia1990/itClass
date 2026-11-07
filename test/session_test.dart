import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:it_class/main.dart';

import 'session_test_support.dart';

Map<String, dynamic> loginData({int role = schoolAccountTypeStudent}) => {
  'userId': 99,
  'schoolAccountId': 9,
  'schoolAccountType': role,
  'accessToken': 'old-access',
  'refreshToken': 'refresh-secret',
  'realName': 'テスト氏名',
  'nickname': '表示名',
  'programmingLanguage': 'JAVA',
};

http.Response envelope(Object? data, {int code = 0}) => http.Response(
  jsonEncode({'code': code, 'data': data, 'msg': 'テスト応答'}),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemorySessionStorage store;
  late SessionStorage originalStore;
  late ItClassApi originalApi;

  setUp(() {
    originalStore = ItClassSession.storage;
    originalApi = ItClassApi.instance;
    store = MemorySessionStorage();
    ItClassSession.storage = store;
    ItClassSession.current = null;
  });
  tearDown(() async {
    await ItClassSession.pendingWrites;
    ItClassSession.current = null;
    ItClassSession.storage = originalStore;
    ItClassApi.instance = originalApi;
  });

  for (final role in [schoolAccountTypeStudent, schoolAccountTypeTeacher]) {
    test(
      'role $role login survives process memory reset without storing password',
      () async {
        ItClassApi.instance = ItClassApi.forTesting(
          MockClient((request) async {
            if (request.url.path.endsWith('/account-login')) {
              return envelope(loginData(role: role));
            }
            expect(request.url.path, endsWith('/account/profile'));
            expect(request.headers['Authorization'], 'Bearer old-access');
            return envelope({'realName': '更新名', 'nickname': '最新表示名'});
          }),
        );
        await ItClassApi.instance.accountLogin(
          account: 'demo',
          password: 'do-not-store',
          expectedAccountType: role,
        );
        expect(store.value, isNot(contains('do-not-store')));
        expect(store.value, isNot(contains('password')));
        ItClassSession.current = null;
        final restored = await ItClassSession.restore();
        expect(restored!.schoolAccountType, role);
        expect(restored.displayName, '最新表示名');
        expect(restored.refreshToken, 'refresh-secret');
      },
    );
  }

  test('wrong login role is never persisted', () async {
    final api = ItClassApi.forTesting(
      MockClient(
        (_) async => envelope(loginData(role: schoolAccountTypeTeacher)),
      ),
    );
    await expectLater(
      api.accountLogin(
        account: 'demo',
        password: 'pw',
        expectedAccountType: schoolAccountTypeStudent,
      ),
      throwsA(isA<ApiException>()),
    );
    expect(store.value, isNull);
    expect(ItClassSession.current, isNull);
  });

  test(
    'parallel 401s refresh once and preserve school identity from token-only response',
    () async {
      ItClassSession.current = AuthSession.fromJson(loginData());
      var refreshes = 0;
      var reads = 0;
      final refreshResponse = Completer<http.Response>();
      final api = ItClassApi.forTesting(
        MockClient((request) async {
          if (request.url.path.endsWith('/refresh-token')) {
            refreshes++;
            expect(
              request.url.queryParameters['refreshToken'],
              'refresh-secret',
            );
            expect(request.headers.containsKey('Authorization'), isFalse);
            return refreshResponse.future;
          }
          reads++;
          if (request.headers['Authorization'] == 'Bearer old-access') {
            return envelope(null, code: 401);
          }
          expect(request.headers['Authorization'], 'Bearer new-access');
          return envelope({'realName': '先生'});
        }),
      );
      final requests = Future.wait([
        api.getCurrentUser(),
        api.getCurrentUser(),
      ]);
      await Future<void>.delayed(Duration.zero);
      expect(refreshes, 1);
      refreshResponse.complete(
        envelope({
          'userId': 99,
          'accessToken': 'new-access',
          'refreshToken': 'refresh-secret',
          'schoolAccountId': null,
          'schoolAccountType': null,
        }),
      );
      await requests;
      expect(reads, 4);
      expect(refreshes, 1);
      expect(ItClassSession.current!.schoolAccountId, 9);
      expect(
        ItClassSession.current!.schoolAccountType,
        schoolAccountTypeStudent,
      );
      expect(ItClassSession.current!.displayName, '表示名');
      expect(jsonDecode(store.value!)['accessToken'], 'new-access');
    },
  );

  test('repeated 401 stops after one replay and clears cached login', () async {
    ItClassSession.current = AuthSession.fromJson(loginData());
    store.value = jsonEncode(loginData());
    var calls = 0;
    final api = ItClassApi.forTesting(
      MockClient((request) async {
        calls++;
        if (request.url.path.endsWith('/refresh-token')) {
          return envelope({'userId': 99, 'accessToken': 'new'});
        }
        return http.Response('', 401);
      }),
    );
    await expectLater(api.getCurrentUser(), throwsA(isA<ApiException>()));
    expect(calls, 3);
    expect(ItClassSession.current, isNull);
    expect(store.value, isNull);
  });

  for (final code in [400, 401]) {
    test('invalid refresh $code returns to login on restore', () async {
      store.value = jsonEncode(loginData());
      ItClassApi.instance = ItClassApi.forTesting(
        MockClient(
          (request) async => envelope(
            null,
            code: request.url.path.endsWith('/refresh-token') ? code : 401,
          ),
        ),
      );
      expect(await ItClassSession.restore(), isNull);
      expect(store.value, isNull);
    });
  }

  test(
    'temporary network failure keeps login for a subsequent retry',
    () async {
      store.value = jsonEncode(loginData());
      ItClassApi.instance = ItClassApi.forTesting(
        MockClient((_) async => throw http.ClientException('offline')),
      );
      expect(await ItClassSession.restore(), isNotNull);
      expect(store.value, isNotNull);
      await ItClassApi.instance.logout();
      expect(ItClassSession.current, isNull);
      expect(store.value, isNull);
    },
  );

  test(
    'logout prevents an in-flight refresh from restoring old login',
    () async {
      ItClassSession.current = AuthSession.fromJson(loginData());
      store.value = jsonEncode(loginData());
      final refreshed = Completer<http.Response>();
      final api = ItClassApi.forTesting(
        MockClient((request) async {
          if (request.url.path.endsWith('/refresh-token')) {
            return refreshed.future;
          }
          if (request.url.path.endsWith('/logout')) return envelope(true);
          return envelope(null, code: 401);
        }),
      );
      final pending = expectLater(
        api.getCurrentUser(),
        throwsA(isA<ApiException>()),
      );
      await Future<void>.delayed(Duration.zero);
      await api.logout();
      refreshed.complete(envelope({'userId': 99, 'accessToken': 'late-token'}));
      await pending;
      expect(ItClassSession.current, isNull);
      expect(store.value, isNull);
    },
  );

  test('corrupt cache is removed without a network request', () async {
    store.value = '{broken';
    ItClassApi.instance = ItClassApi.forTesting(
      MockClient((_) async => throw StateError('must not request')),
    );
    expect(await ItClassSession.restore(), isNull);
    expect(store.value, isNull);
  });
}
