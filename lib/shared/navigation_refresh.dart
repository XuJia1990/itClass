part of '../main.dart';

/// Repeated clicks during a read request one more read, never parallel reads
/// of the same page. Nothing runs unless the user (or initial load) requests it.
class _NavigationRefreshQueue {
  final _running = <Object, Future<void>>{};
  final _queued = <Object>{};
  bool _disposed = false;

  Future<void> run(Object key, Future<void> Function() refresh) {
    if (_disposed) return Future.value();
    final running = _running[key];
    if (running != null) {
      _queued.add(key);
      return running;
    }
    final future = Future<void>(() async {
      do {
        _queued.remove(key);
        if (_disposed) return;
        await refresh();
      } while (!_disposed && _queued.contains(key));
    });
    _running[key] = future.whenComplete(() {
      _running.remove(key);
    });
    return _running[key]!;
  }

  void dispose() {
    _disposed = true;
    _queued.clear();
  }
}

class _NavigationRefreshScope extends InheritedWidget {
  const _NavigationRefreshScope({required this.revision, required super.child});
  final int revision;

  @override
  bool updateShouldNotify(_NavigationRefreshScope oldWidget) =>
      revision != oldWidget.revision;
}

/// Refresh an already open workspace without remounting its form or draft.
mixin _NavigationRefresh<T extends StatefulWidget> on State<T> {
  final _navigationReads = _NavigationRefreshQueue();
  int? _navigationRevision;
  Future<void> onNavigationRefresh();

  Future<void> refreshFromNavigation() =>
      _navigationReads.run('page', () async {
        if (mounted) await onNavigationRefresh();
      });

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final revision = context
        .dependOnInheritedWidgetOfExactType<_NavigationRefreshScope>()
        ?.revision;
    final previous = _navigationRevision;
    _navigationRevision = revision;
    if (previous != null && revision != previous) {
      unawaited(refreshFromNavigation());
    }
  }

  @override
  void dispose() {
    _navigationReads.dispose();
    super.dispose();
  }
}
