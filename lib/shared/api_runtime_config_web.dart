import 'dart:js_interop';
import 'dart:js_interop_unsafe';

@JS('globalThis')
external JSObject get _globalThis;

String? getRuntimeApiBaseUrl() {
  final value = _globalThis
      .getProperty<JSAny?>('ITCLASS_API_BASE_URL'.toJS)
      .dartify();
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
