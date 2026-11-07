part of '../main.dart';

/// Presentation boundary: keep diagnostics in the API logs, never in a toast,
/// chat bubble, or page notice. Business errors still explain what to do next.
String userFacingError(Object error) {
  const fallback = '操作を完了できませんでした。時間をおいてもう一度お試しください。';
  if (error is http.ClientException || error is TimeoutException) {
    return '接続できませんでした。通信状態を確認してもう一度お試しください。';
  }
  if (error is! ApiException) return fallback;
  if (error.code == 401) return 'ログインの有効期限が切れました。再度ログインしてください。';
  if (error.code == 403) return 'この操作を行う権限がありません。';
  if (error.code == 429) return '操作が集中しています。少し待ってからもう一度お試しください。';
  if (error.code != null && error.code! >= 500 && error.code! < 600) {
    return fallback;
  }
  final message = error.message.trim();
  if (message.isEmpty ||
      message.length > 240 ||
      _technicalErrorText.hasMatch(message)) {
    return fallback;
  }
  return message;
}

final _technicalErrorText = RegExp(
  r'(?:https?|wss?)://|\b(?:localhost|api|backend|twcschool|twschool|HTTP|SQL|SQLSTATE|JDBC|JSON|URI|URL|CORS|XML|HTML|trace|stack|token|authorization)\b|'
  r'/(?:app-api|admin-api|school|member|infra|system|Users|var|tmp|etc)/?|'
  r'TWSCHOOL_|app-config|バックエンド|(?:\w+Exception|\w+Error)\b|'
  r'\b(?:\d{1,3}\.){3}\d{1,3}\b|\b(?:GET|POST|PUT|DELETE|PATCH|OPTIONS)\s+/|'
  r'\b[a-z\d-]+(?:\.[a-z\d-]+)*\.(?:com|net|org|jp|io|dev|local)\b|'
  r'<[^>]+>|[{}]|(?:cn|com|org)\.\w+\.',
  caseSensitive: false,
);
