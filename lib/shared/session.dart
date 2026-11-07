part of '../main.dart';

abstract class SessionStorage {
  Future<String?> read();
  Future<void> write(String value);
  Future<void> delete();
}

class SecureSessionStorage implements SessionStorage {
  const SecureSessionStorage();
  static const _storage = FlutterSecureStorage();
  String get _key =>
      'itclass.session.v1.${Uri.encodeComponent('${ItClassApi.baseUrl}|${ItClassApi.tenantId}')}';
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
  @override
  Future<void> delete() => _storage.delete(key: _key);
}

class ItClassSession {
  ItClassSession._();

  static final changes = ValueNotifier<AuthSession?>(null);
  static SessionStorage storage = const SecureSessionStorage();
  static int _generation = 0;
  static Future<void>? _writes;
  static AuthSession? get current => changes.value;
  static set current(AuthSession? value) {
    _generation++;
    changes.value = value;
  }

  static int get generation => _generation;
  static bool get isSignedIn => current != null;
  static Future<void> get pendingWrites => _writes ?? Future<void>.value();

  // Serialize writes so a delayed login/profile save cannot undo logout.
  static Future<void> _enqueue(Future<void> Function() operation) {
    final work = (_writes ?? Future<void>.value()).then((_) => operation());
    final settled = work.catchError((Object _) {});
    _writes = settled;
    unawaited(
      settled.then((_) {
        if (identical(_writes, settled)) _writes = null;
      }),
    );
    return work;
  }

  static Future<void> start(AuthSession session, int expectedGeneration) async {
    if (_generation != expectedGeneration) {
      throw const ApiException('ログイン処理がキャンセルされました。');
    }
    if (!session.isUsable) throw const ApiException('ログイン情報が不完全です。');
    final generation = ++_generation;
    final store = storage;
    await _enqueue(() => store.write(jsonEncode(session.toJson())));
    if (_generation != generation) {
      throw const ApiException('ログイン処理がキャンセルされました。');
    }
    changes.value = session;
  }

  static Future<void> replace(
    AuthSession session,
    int expectedGeneration,
  ) async {
    if (_generation != expectedGeneration || current == null) return;
    changes.value = session;
    final store = storage;
    await _enqueue(() => store.write(jsonEncode(session.toJson())));
  }

  static Future<void> clear() async {
    _generation++;
    SchoolChatRealtime.instance.disconnect();
    changes.value = null;
    final store = storage;
    await _enqueue(store.delete);
  }

  static void updateProfile(MemberProfile profile) {
    final updated = current?.copyWithProfile(profile);
    if (updated == null) return;
    unawaited(
      replace(updated, _generation).catchError((Object _) {
        debugPrint('[itClass session] Profile cache could not be updated.');
      }),
    );
  }

  static Future<AuthSession?> restore() async {
    final generation = _generation;
    if (_writes != null) await _writes;
    final encoded = await storage.read();
    if (_generation != generation) return current;
    if (encoded == null || encoded.isEmpty) return null;
    AuthSession session;
    try {
      session = AuthSession.fromJson(_asMap(jsonDecode(encoded)));
      if (!session.isUsable) throw const FormatException('Invalid session');
    } catch (_) {
      await clear();
      return null;
    }
    current = session;
    final restoredGeneration = _generation;
    try {
      final profile = await ItClassApi.instance.getCurrentUser().timeout(
        const Duration(seconds: 12),
      );
      if (_generation == restoredGeneration && current != null) {
        await replace(current!.copyWithProfile(profile), restoredGeneration);
      }
    } catch (error) {
      // 401/invalid refresh clears the session in the API layer. Network/server
      // failures keep the cached login, letting the normal page retry its data.
      debugPrint('[itClass session] Profile validation deferred.');
    }
    if (current != null) ItClassApi.instance.connectRealtime();
    return current;
  }
}

class _SessionEntry extends StatefulWidget {
  const _SessionEntry();
  @override
  State<_SessionEntry> createState() => _SessionEntryState();
}

class _SessionEntryState extends State<_SessionEntry> {
  bool _restoring = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    ItClassSession.changes.addListener(_sessionChanged);
    unawaited(_restore());
  }

  @override
  void dispose() {
    ItClassSession.changes.removeListener(_sessionChanged);
    super.dispose();
  }

  void _sessionChanged() {
    if (!mounted) return;
    setState(() {});
    if (ItClassSession.current == null && !_restoring) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && ItClassSession.current == null) {
          itClassNavigatorKey.currentState?.popUntil((route) => route.isFirst);
        }
      });
    }
  }

  Future<void> _restore() async {
    setState(() {
      _restoring = true;
      _error = null;
    });
    try {
      if (ItClassSession.current == null) await ItClassSession.restore();
    } catch (_) {
      if (mounted) _error = '保存したログイン情報を読み込めませんでした。再試行してください。';
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_restoring) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              TextButton(onPressed: _restore, child: const Text('再試行')),
            ],
          ),
        ),
      );
    }
    return switch (ItClassSession.current?.schoolAccountType) {
      schoolAccountTypeStudent => const StudentHomePage(),
      schoolAccountTypeTeacher => const TeacherHomePage(),
      _ => const LoginPage(),
    };
  }
}
