part of '../main.dart';

const int schoolAccountTypeTeacher = 1;
const int schoolAccountTypeStudent = 2;
const int chatContentTypeText = 1;
const int questionTypeSingleChoice = 1;
const int paperStatusReady = 10;
const int examResultPublishImmediate = 0;

class ItClassSession {
  ItClassSession._();

  static AuthSession? current;

  static bool get isSignedIn => current != null;

  static void clear() {
    current = null;
  }
}

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.schoolAccountId,
    required this.schoolAccountType,
    required this.realName,
    required this.email,
    required this.mobile,
    required this.programmingLanguage,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      userId: _asInt(json['userId']) ?? 0,
      accessToken: '${json['accessToken'] ?? ''}',
      refreshToken: '${json['refreshToken'] ?? ''}',
      schoolAccountId: _asInt(json['schoolAccountId']) ?? 0,
      schoolAccountType: _asInt(json['schoolAccountType']) ?? 0,
      realName: _asString(
        json['realName'] ?? json['nickname'] ?? json['username'],
      ),
      email: _asString(json['email']),
      mobile: _asString(json['mobile']),
      programmingLanguage: _asString(json['programmingLanguage']),
    );
  }

  final int userId;
  final String accessToken;
  final String refreshToken;
  final int schoolAccountId;
  final int schoolAccountType;
  final String realName;
  final String email;
  final String mobile;
  final String programmingLanguage;
}

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiPage<T> {
  const ApiPage({required this.list, required this.total});

  final List<T> list;
  final int total;
}

class SchoolClassroom {
  const SchoolClassroom({
    required this.id,
    required this.name,
    required this.programmingLanguage,
  });

  factory SchoolClassroom.fromJson(Map<String, dynamic> json) {
    return SchoolClassroom(
      id: _asInt(json['id']) ?? _asInt(json['classroomId']) ?? 0,
      name: _asString(
        json['name'] ?? json['classroomName'],
        fallback: 'Classroom',
      ),
      programmingLanguage: _asString(
        json['programmingLanguage'],
        fallback: 'Java',
      ),
    );
  }

  final int id;
  final String name;
  final String programmingLanguage;
}

class SchoolExamSummary {
  const SchoolExamSummary({
    required this.id,
    required this.title,
    required this.description,
    required this.latestAttemptId,
    required this.latestScore,
  });

  factory SchoolExamSummary.fromJson(Map<String, dynamic> json) {
    return SchoolExamSummary(
      id: _asInt(json['id']) ?? 0,
      title: _asString(json['title'], fallback: 'Exam'),
      description: _asString(json['description']),
      latestAttemptId: _asInt(json['latestAttemptId']),
      latestScore: _asInt(json['latestScore']),
    );
  }

  final int id;
  final String title;
  final String description;
  final int? latestAttemptId;
  final int? latestScore;
}

class ExamAttemptPayload {
  const ExamAttemptPayload({
    required this.attemptId,
    required this.examTitle,
    required this.questions,
  });

  factory ExamAttemptPayload.fromJson(Map<String, dynamic> json) {
    return ExamAttemptPayload(
      attemptId: _asInt(json['attemptId']) ?? 0,
      examTitle: _asString(json['examTitle'], fallback: 'Exam'),
      questions: _asList(
        json['questions'],
      ).map((item) => _examQuestionFromJson(_asMap(item))).toList(),
    );
  }

  final int attemptId;
  final String examTitle;
  final List<ExamQuestion> questions;
}

class ItClassApi {
  ItClassApi._();

  static final ItClassApi instance = ItClassApi._();

  static final String baseUrl = _resolveApiBaseUrl();
  static const String tenantId = String.fromEnvironment(
    'TWSCHOOL_TENANT_ID',
    defaultValue: '1',
  );

  final http.Client _client = http.Client();

  Future<AuthSession> accountLogin({
    required String account,
    required String password,
  }) async {
    final data = await _post<Map<String, dynamic>>(
      '/member/auth/account-login',
      body: {'accountNo': account, 'password': password},
    );
    final session = AuthSession.fromJson(data);
    ItClassSession.current = session;
    return session;
  }

  Future<void> logout() async {
    try {
      await _post<dynamic>('/member/auth/logout');
    } catch (_) {
      // The UI should still return to the login screen when logout fails.
    } finally {
      ItClassSession.clear();
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() {
    return _get<Map<String, dynamic>>('/member/user/get');
  }

  Future<void> updateProfile({
    required String nickname,
    required String email,
    required String mobile,
  }) {
    return _put<void>(
      '/member/user/update',
      body: {'nickname': nickname, 'email': email, 'mobile': mobile},
    );
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return _put<void>(
      '/member/user/update-password',
      body: {'oldPassword': oldPassword, 'password': newPassword},
    );
  }

  Future<List<SchoolClassroom>> myClassrooms() async {
    final data = await _get<List<dynamic>>('/school/classroom/my-list');
    return data.map((item) => SchoolClassroom.fromJson(_asMap(item))).toList();
  }

  Future<ApiPage<LearningVideo>> courseVideos({int? classroomId}) async {
    final data = await _get<Map<String, dynamic>>(
      '/school/course-video/page',
      query: {
        'pageNo': '1',
        'pageSize': '100',
        if (classroomId != null) 'classroomId': '$classroomId',
      },
    );
    return _page(data, _learningVideoFromJson);
  }

  Future<void> saveVideoProgress({
    required int courseVideoId,
    required int positionSeconds,
    required int durationSeconds,
    required bool ended,
  }) {
    return _post<void>(
      '/school/video-progress/save',
      body: {
        'courseVideoId': courseVideoId,
        'positionSeconds': positionSeconds,
        'durationSeconds': durationSeconds,
        'ended': ended,
      },
    );
  }

  Future<ApiPage<Lesson>> courseDocuments({int? classroomId}) async {
    final data = await _get<Map<String, dynamic>>(
      '/school/course-document/page',
      query: {
        'pageNo': '1',
        'pageSize': '100',
        if (classroomId != null) 'classroomId': '$classroomId',
      },
    );
    return _page(data, _lessonFromDocumentJson);
  }

  Future<int> createCourseVideo({
    required int classroomId,
    required String title,
    required String fileUrl,
    required PlatformFile file,
  }) async {
    final data = await _post<dynamic>(
      '/school/course-video/teacher-create',
      body: {
        'classroomId': classroomId,
        'title': title,
        'description': 'Uploaded from itClass app',
        'videoUrl': fileUrl,
        'videoPath': fileUrl,
        'fileName': file.name,
        'fileSize': file.size,
        'contentType': _contentType(file),
        'chapterNo': 1,
        'sort': 0,
      },
    );
    return _asInt(data) ?? 0;
  }

  Future<int> createCourseDocument({
    required int classroomId,
    required String title,
    required String fileUrl,
    required PlatformFile file,
  }) async {
    final data = await _post<dynamic>(
      '/school/course-document/teacher-create',
      body: {
        'classroomId': classroomId,
        'title': title,
        'description': 'Uploaded from itClass app',
        'documentUrl': fileUrl,
        'documentPath': fileUrl,
        'fileName': file.name,
        'fileSize': file.size,
        'contentType': _contentType(file),
        'chapterNo': 1,
        'sort': 0,
      },
    );
    return _asInt(data) ?? 0;
  }

  Future<String> uploadFile(
    PlatformFile file, {
    String directory = 'itclass',
  }) async {
    final uri = _uri('/infra/file/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers(json: false));
    request.fields['path'] = '$directory/${file.name}';
    if (file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
      );
    } else if (file.path != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path!));
    } else {
      throw const ApiException('ファイル内容を読み取れませんでした');
    }
    _logRequest('POST', uri, request.headers, {
      'fields': request.fields,
      'files': [
        for (final item in request.files)
          {
            'field': item.field,
            'filename': item.filename,
            'length': item.length,
            'contentType': '${item.contentType}',
          },
      ],
    });
    try {
      final stopwatch = Stopwatch()..start();
      final streamed = await _client.send(request);
      final response = await http.Response.fromStream(streamed);
      stopwatch.stop();
      _logResponse(response, elapsed: stopwatch.elapsed);
      return _decodeResponse<String>(response);
    } catch (error, stackTrace) {
      _logError('POST', uri, error, stackTrace);
      rethrow;
    }
  }

  Future<SchoolExamSummary?> firstExam() async {
    final page = await examPage();
    return page.list.isEmpty ? null : page.list.first;
  }

  Future<ApiPage<SchoolExamSummary>> examPage() async {
    final data = await _get<Map<String, dynamic>>(
      '/school/exam/page',
      query: {'pageNo': '1', 'pageSize': '100'},
    );
    return _page(data, SchoolExamSummary.fromJson);
  }

  Future<ExamAttemptPayload> startExam(int examId) async {
    final data = await _post<Map<String, dynamic>>(
      '/school/exam/start',
      query: {'examId': '$examId'},
    );
    return ExamAttemptPayload.fromJson(data);
  }

  Future<void> saveExamAnswer({
    required int attemptId,
    required int paperQuestionId,
    required String answerContent,
  }) {
    return _post<void>(
      '/school/exam/save-answer',
      body: {
        'attemptId': attemptId,
        'paperQuestionId': paperQuestionId,
        'answerContent': answerContent,
      },
    );
  }

  Future<void> submitExam({
    required int attemptId,
    required List<ExamQuestion> questions,
    required Map<int, int> selectedAnswers,
  }) {
    return _post<void>(
      '/school/exam/submit',
      body: {
        'attemptId': attemptId,
        'answers': [
          for (var i = 0; i < questions.length; i++)
            if (questions[i].paperQuestionId != null &&
                selectedAnswers[i] != null)
              {
                'paperQuestionId': questions[i].paperQuestionId,
                'answerContent': _answerContent(
                  questions[i],
                  selectedAnswers[i]!,
                ),
              },
        ],
      },
    );
  }

  Future<ApiPage<CodeReviewItem>> examAttempts() async {
    final data = await _get<Map<String, dynamic>>(
      '/school/exam-teacher/attempt/page',
      query: {'pageNo': '1', 'pageSize': '100'},
    );
    return _page(data, _codeReviewItemFromAttemptJson);
  }

  Future<List<CodeAssignment>> codeAssignments() async {
    final data = await _get<List<dynamic>>(
      '/school/code-scoring/assignment/list',
    );
    return data.map((item) => _codeAssignmentFromJson(_asMap(item))).toList();
  }

  Future<ScoreResult> scoreCode({
    required int assignmentId,
    required String code,
  }) async {
    final data = await _post<Map<String, dynamic>>(
      '/school/code-scoring/score',
      body: {'assignmentId': assignmentId, 'code': code},
    );
    return _scoreResultFromJson(data);
  }

  Future<ApiPage<Topic>> aiConversations({int? classroomId}) async {
    final data = await _get<Map<String, dynamic>>(
      '/school/ai-tutor/conversation/page',
      query: {
        'pageNo': '1',
        'pageSize': '100',
        if (classroomId != null) 'classroomId': '$classroomId',
      },
    );
    return _page(data, _topicFromAiConversationJson);
  }

  Future<List<ChatMessage>> aiConversationQuestions(int conversationId) async {
    final data = await _get<List<dynamic>>(
      '/school/ai-tutor/conversation/questions',
      query: {'conversationId': '$conversationId'},
    );
    return data
        .expand((item) => _chatMessagesFromAiQuestionJson(_asMap(item)))
        .toList();
  }

  Future<int> ensureAiConversation(int classroomId) async {
    final page = await _get<Map<String, dynamic>>(
      '/school/ai-tutor/conversation/page',
      query: {'pageNo': '1', 'pageSize': '1', 'classroomId': '$classroomId'},
    );
    final conversations = _asList(page['list']);
    if (conversations.isNotEmpty) {
      return _asInt(_asMap(conversations.first)['id']) ?? 0;
    }
    final data = await _post<dynamic>(
      '/school/ai-tutor/conversation/create',
      body: {'classroomId': classroomId, 'title': 'itClass Chat'},
    );
    return _asInt(data) ?? 0;
  }

  Future<String> askAi({
    required int conversationId,
    required String content,
  }) async {
    final data = await _post<Map<String, dynamic>>(
      '/school/ai-tutor/ask',
      body: {'conversationId': conversationId, 'content': content},
    );
    return _asString(
      data['effectiveAnswer'] ?? data['aiAnswer'] ?? data['teacherAnswer'],
      fallback: 'AI回答を取得しましたが、回答本文が空でした。',
    );
  }

  Future<ApiPage<TeacherRequest>> teacherAiQuestions({int? classroomId}) async {
    final data = await _get<Map<String, dynamic>>(
      '/school/ai-teacher/question/page',
      query: {
        'pageNo': '1',
        'pageSize': '100',
        if (classroomId != null) 'classroomId': '$classroomId',
      },
    );
    return _page(data, _teacherRequestFromJson);
  }

  Future<void> replyAiQuestion({
    required int questionId,
    required String answer,
  }) {
    return _post<void>(
      '/school/ai-teacher/question/reply',
      body: {'questionId': questionId, 'answer': answer},
    );
  }

  Future<List<StudentProfile>> chatContacts({int? classroomId}) async {
    final data = await _get<List<dynamic>>(
      '/school/chat/contact/list',
      query: {if (classroomId != null) 'classroomId': '$classroomId'},
    );
    return data
        .map((item) => _studentProfileFromContactJson(_asMap(item)))
        .toList();
  }

  Future<int> getOrCreateChat({
    required int classroomId,
    required int peerAccountId,
  }) async {
    final data = await _post<dynamic>(
      '/school/chat/conversation/get-or-create',
      body: {'classroomId': classroomId, 'peerAccountId': peerAccountId},
    );
    return _asInt(data) ?? _asInt(_asMap(data)['id']) ?? 0;
  }

  Future<List<ChatMessage>> chatMessages(int conversationId) async {
    final data = await _get<Map<String, dynamic>>(
      '/school/chat/message/page',
      query: {
        'pageNo': '1',
        'pageSize': '100',
        'conversationId': '$conversationId',
      },
    );
    return _page(data, _chatMessageFromJson).list.reversed.toList();
  }

  Future<List<ExamQuestion>> generateExamQuestions({
    required String programmingLanguage,
    required String topic,
    required int count,
  }) async {
    final data = await _post<List<dynamic>>(
      '/school/ai-teacher/exam/question/generate',
      body: {
        'programmingLanguage': programmingLanguage,
        'topic': topic,
        'questionTypes': [questionTypeSingleChoice],
        'count': count.clamp(1, 5),
        'difficulty': 1,
        'requirements': 'itClass 先生画面から生成',
      },
    );
    return data
        .map((item) => _generatedExamQuestionFromJson(_asMap(item)))
        .toList();
  }

  Future<ChatMessage> sendChatMessage({
    required int conversationId,
    required String content,
  }) async {
    final data = await _post<Map<String, dynamic>>(
      '/school/chat/message/send',
      body: {
        'conversationId': conversationId,
        'contentType': chatContentTypeText,
        'content': content,
      },
    );
    return _chatMessageFromJson(data);
  }

  Future<List<StudentProfile>> simpleStudents() async {
    final data = await _get<List<dynamic>>(
      '/school/account/student/list-simple',
    );
    return data
        .map((item) => _studentProfileFromAccountJson(_asMap(item)))
        .toList();
  }

  Future<int> createStudent({
    required int classroomId,
    required String realName,
    required String username,
    required String password,
    required String mobile,
  }) async {
    final data = await _post<dynamic>(
      '/school/account/create-student',
      body: {
        'classroomId': classroomId,
        'realName': realName,
        'username': username,
        'password': password,
        'mobile': mobile,
      },
    );
    return _asInt(data) ?? 0;
  }

  Future<int> addExistingStudent({
    required int classroomId,
    required int studentAccountId,
  }) async {
    final data = await _post<dynamic>(
      '/school/account/add-existing-student',
      body: {'classroomId': classroomId, 'studentAccountId': studentAccountId},
    );
    return _asInt(data) ?? 0;
  }

  Future<int> createQuestion(ExamQuestion question) async {
    final data = await _post<dynamic>(
      '/school/exam-teacher/question/save',
      body: {
        'type': question.type ?? questionTypeSingleChoice,
        'difficulty': 1,
        'programmingLanguage': 'Java',
        'title': question.topic,
        'content': question.question,
        'referenceAnswer': question.explanation,
        'analysis': question.explanation,
        'defaultScore': question.score ?? 10,
        'status': 0,
        'options': [
          for (var i = 0; i < question.options.length; i++)
            {
              'optionKey': _optionKey(i),
              'content': question.options[i],
              'correct': i == question.answerIndex,
              'sort': i,
            },
        ],
      },
    );
    return _asInt(data) ?? 0;
  }

  Future<int> createPaper({
    required String title,
    required String description,
    required List<int> questionIds,
  }) async {
    final data = await _post<dynamic>(
      '/school/exam-teacher/paper/save',
      body: {
        'title': title,
        'description': description,
        'durationMinutes': 30,
        'status': paperStatusReady,
        'questions': [
          for (var i = 0; i < questionIds.length; i++)
            {'questionId': questionIds[i], 'score': 10, 'sort': i},
        ],
      },
    );
    return _asInt(data) ?? 0;
  }

  Future<int> createAndPublishExam({
    required int classroomId,
    required int paperId,
    required String title,
    required String description,
  }) async {
    final now = DateTime.now();
    final data = await _post<dynamic>(
      '/school/exam-teacher/exam/save',
      body: {
        'paperId': paperId,
        'title': title,
        'description': description,
        'classroomIds': [classroomId],
        'startTime': now.subtract(const Duration(minutes: 1)).toIso8601String(),
        'endTime': now.add(const Duration(days: 30)).toIso8601String(),
        'durationMinutes': 30,
        'passScore': 60,
        'maxAttempts': 3,
        'shuffleQuestions': false,
        'shuffleOptions': false,
        'resultPublishType': examResultPublishImmediate,
        'showAnswer': true,
      },
    );
    final examId = _asInt(data) ?? 0;
    await _put<void>(
      '/school/exam-teacher/exam/publish',
      query: {'id': '$examId'},
    );
    return examId;
  }

  Future<T> _get<T>(String path, {Map<String, String>? query}) {
    return _send<T>('GET', path, query: query);
  }

  Future<T> _post<T>(String path, {Map<String, String>? query, Object? body}) {
    return _send<T>('POST', path, query: query, body: body);
  }

  Future<T> _put<T>(String path, {Map<String, String>? query, Object? body}) {
    return _send<T>('PUT', path, query: query, body: body);
  }

  Future<T> _send<T>(
    String method,
    String path, {
    Map<String, String>? query,
    Object? body,
  }) async {
    final uri = _uri(path, query);
    final headers = _headers();
    final encodedBody = body == null ? null : jsonEncode(body);
    _logRequest(method, uri, headers, body);
    late final http.Response response;
    try {
      final stopwatch = Stopwatch()..start();
      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers);
        case 'PUT':
          response = await _client.put(
            uri,
            headers: headers,
            body: encodedBody ?? '{}',
          );
        default:
          response = await _client.post(
            uri,
            headers: headers,
            body: encodedBody ?? '{}',
          );
      }
      stopwatch.stop();
      _logResponse(response, elapsed: stopwatch.elapsed);
    } catch (error, stackTrace) {
      _logError(method, uri, error, stackTrace);
      rethrow;
    }
    return _decodeResponse<T>(response);
  }

  T _decodeResponse<T>(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('HTTP ${response.statusCode}: $body');
    }
    if (body.isEmpty) return null as T;
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic> && decoded.containsKey('code')) {
      final code = _asInt(decoded['code']) ?? 0;
      if (code != 0 && code != 200) {
        throw ApiException(
          _asString(
            decoded['msg'] ?? decoded['message'],
            fallback: 'API error $code',
          ),
        );
      }
      return decoded['data'] as T;
    }
    return decoded as T;
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalized').replace(queryParameters: query);
  }

  Map<String, String> _headers({bool json = true}) {
    return {
      'tenant-id': tenantId,
      if (json) 'Content-Type': 'application/json',
      if (json) 'Accept': 'application/json',
      if (ItClassSession.current?.accessToken.isNotEmpty ?? false)
        'Authorization': 'Bearer ${ItClassSession.current!.accessToken}',
    };
  }

  void _logRequest(
    String method,
    Uri uri,
    Map<String, String> headers,
    Object? body,
  ) {
    debugPrint(
      '[itClass API] --> $method $uri\n'
      'headers=${_compactJson(_sanitize(headers))}\n'
      'body=${_compactJson(_sanitize(body))}',
      wrapWidth: 1200,
    );
  }

  void _logResponse(http.Response response, {required Duration elapsed}) {
    debugPrint(
      '[itClass API] <-- ${response.statusCode} ${response.request?.method ?? ''} '
      '${response.request?.url ?? response.reasonPhrase ?? ''} '
      '(${elapsed.inMilliseconds}ms)\n'
      'headers=${_compactJson(_sanitize(response.headers))}\n'
      'body=${_trimLogBody(utf8.decode(response.bodyBytes))}',
      wrapWidth: 1200,
    );
  }

  void _logError(String method, Uri uri, Object error, StackTrace stackTrace) {
    debugPrint(
      '[itClass API] xx> $method $uri\n'
      'error=$error\n'
      'stack=$stackTrace',
      wrapWidth: 1200,
    );
  }
}

Object? _sanitize(Object? value) {
  const sensitiveKeys = {
    'authorization',
    'password',
    'oldpassword',
    'newpassword',
    'accesstoken',
    'refreshtoken',
    'token',
  };
  if (value is Map) {
    return {
      for (final entry in value.entries)
        '${entry.key}': sensitiveKeys.contains('${entry.key}'.toLowerCase())
            ? '***'
            : _sanitize(entry.value),
    };
  }
  if (value is Iterable && value is! String) {
    return value.map(_sanitize).toList();
  }
  return value;
}

String _compactJson(Object? value) {
  if (value == null) return 'null';
  try {
    return _trimLogBody(jsonEncode(value));
  } catch (_) {
    return _trimLogBody('$value');
  }
}

String _trimLogBody(String value) {
  const maxLength = 6000;
  if (value.length <= maxLength) return value;
  return '${value.substring(0, maxLength)}... <trimmed ${value.length - maxLength} chars>';
}

String _resolveApiBaseUrl() {
  final runtimeValue = getRuntimeApiBaseUrl();
  if (runtimeValue != null && runtimeValue.isNotEmpty) {
    return _normalizeApiBaseUrl(runtimeValue);
  }
  const buildValue = String.fromEnvironment(
    'TWSCHOOL_API_BASE_URL',
    defaultValue: '/app-api',
  );
  return _normalizeApiBaseUrl(buildValue);
}

String _normalizeApiBaseUrl(String value) {
  final trimmed = value.trim().replaceFirst(RegExp(r'/+$'), '');
  if (trimmed.isEmpty) return '/app-api';
  final uri = Uri.tryParse(trimmed);
  if (uri != null && uri.hasScheme && (uri.path.isEmpty || uri.path == '/')) {
    return '$trimmed/app-api';
  }
  return trimmed;
}

ApiPage<T> _page<T>(
  Map<String, dynamic> data,
  T Function(Map<String, dynamic>) mapper,
) {
  return ApiPage<T>(
    list: _asList(data['list']).map((item) => mapper(_asMap(item))).toList(),
    total: _asInt(data['total']) ?? 0,
  );
}

LearningVideo _learningVideoFromJson(Map<String, dynamic> json) {
  final durationSeconds = _asInt(json['durationSeconds']) ?? 0;
  final progressPercent = _asInt(json['progressPercent']);
  return LearningVideo(
    id: _asInt(json['id']),
    classroomId: _asInt(json['classroomId']),
    title: _asString(json['title'], fallback: 'Course Video'),
    category: _asString(
      json['classroomProgrammingLanguage'] ?? json['classroomName'],
      fallback: 'Java',
    ),
    duration: durationSeconds > 0 ? '${(durationSeconds / 60).ceil()}分' : '未設定',
    progress: ((progressPercent ?? 0) / 100).clamp(0.0, 1.0),
    description: _asString(json['description']),
    videoUrl: _asString(json['playUrl'] ?? json['videoUrl']),
  );
}

Lesson _lessonFromDocumentJson(Map<String, dynamic> json) {
  final title = _asString(json['title'], fallback: 'Document');
  final description = _asString(
    json['description'],
    fallback: 'アップロード教材を確認します。',
  );
  final url = _asString(json['accessUrl'] ?? json['documentUrl']);
  return Lesson(
    id: _asInt(json['id']),
    classroomId: _asInt(json['classroomId']),
    title: title,
    level: _asString(
      json['classroomProgrammingLanguage'] ?? json['classroomName'],
      fallback: 'Java',
    ),
    summary: description,
    content: url.isEmpty ? description : '$description\n\n資料URL: $url',
    code: '// ${title.replaceAll('\n', ' ')}',
    sections: [
      LessonSection(
        heading: '教材概要',
        body: description,
        keyPoints: const ['教材を読む', '要点を確認する', '問題バンクで復習する'],
      ),
    ],
    exercise: const LessonExercise(
      question: 'この教材を読んだあと、最初に確認するべきことはどれですか？',
      options: ['要点を整理する', '何もせず閉じる', '関係ない動画を見る', 'ログアウトする'],
      answerIndex: 0,
      correctReason: '要点整理が理解の確認になります。',
      wrongReason: '教材の内容に沿って復習しましょう。',
      standardAnswer: '教材の要点をまとめ、関連問題を解きます。',
    ),
    aiSummary: description,
  );
}

ExamQuestion _examQuestionFromJson(Map<String, dynamic> json) {
  final options = _asList(json['options']);
  final labels = options.map((item) => _asMap(item)).toList();
  final optionKeys = labels
      .map((item) => _asString(item['optionKey']))
      .toList();
  final saved = _asString(json['savedAnswer']);
  final answerIndex = saved.isEmpty ? 0 : optionKeys.indexOf(saved);
  return ExamQuestion(
    paperQuestionId: _asInt(json['paperQuestionId']),
    questionId: _asInt(json['questionId']),
    type: _asInt(json['type']),
    optionKeys: optionKeys,
    score: _asInt(json['score']),
    topic: _asString(json['title'], fallback: 'テスト問題'),
    question: _asString(json['content'], fallback: _asString(json['title'])),
    options: labels
        .map(
          (item) => _asString(
            item['content'],
            fallback: _asString(item['optionKey']),
          ),
        )
        .toList(),
    answerIndex: answerIndex < 0 ? 0 : answerIndex,
    explanation: _asString(
      json['analysis'] ?? json['referenceAnswer'],
      fallback: '提出後に結果を確認してください。',
    ),
  );
}

ExamQuestion _generatedExamQuestionFromJson(Map<String, dynamic> json) {
  final options = _asList(json['options']).map((item) => _asMap(item)).toList();
  final optionKeys = options
      .map((item) => _asString(item['optionKey']))
      .toList();
  final answerIndex = options.indexWhere((item) => item['correct'] == true);
  return ExamQuestion(
    type: _asInt(json['type']) ?? questionTypeSingleChoice,
    optionKeys: optionKeys,
    score: _asInt(json['defaultScore']) ?? 10,
    topic: _asString(json['title'], fallback: 'AI生成問題'),
    question: _asString(json['content'], fallback: _asString(json['title'])),
    options: options
        .map(
          (item) => _asString(
            item['content'],
            fallback: _asString(item['optionKey']),
          ),
        )
        .toList(),
    answerIndex: answerIndex < 0 ? 0 : answerIndex,
    explanation: _asString(
      json['analysis'] ?? json['referenceAnswer'],
      fallback: 'AI生成問題の解説です。',
    ),
  );
}

TeacherRequest _teacherRequestFromJson(Map<String, dynamic> json) {
  final teacherAnswer = _asString(json['teacherAnswer']);
  return TeacherRequest(
    questionId: _asInt(json['id']),
    conversationId: _asInt(json['conversationId']),
    classroomId: _asInt(json['classroomId']),
    student: _asString(
      json['studentName'] ?? json['studentAccountNo'],
      fallback: 'Student',
    ),
    category: _asString(json['classroomName'], fallback: 'AI質問'),
    question: _asString(json['questionContent']),
    aiAnswer: _asString(
      json['aiAnswer'] ?? json['aiErrorMessage'],
      fallback: 'AI回答なし',
    ),
    answered: teacherAnswer.isNotEmpty,
    teacherAnswer: teacherAnswer.isEmpty ? null : teacherAnswer,
  );
}

StudentProfile _studentProfileFromContactJson(Map<String, dynamic> json) {
  return StudentProfile(
    _asString(json['realName'] ?? json['nickname'], fallback: 'Student'),
    _asString(json['classroomName'], fallback: '学生'),
    'チャット履歴を取得できます。',
    accountId: _asInt(json['accountId']),
    classroomId: _asInt(json['classroomId']),
    accountNo: _asString(json['accountNo']),
    email: _asString(json['accountNo']),
    password: '******',
    phone: '',
  );
}

StudentProfile _studentProfileFromAccountJson(Map<String, dynamic> json) {
  return StudentProfile(
    _asString(json['realName'] ?? json['nickname'], fallback: 'Student'),
    _asString(json['status']) == '0' ? '生徒 · 有効' : '生徒',
    'まだ質問はありません。',
    accountId: _asInt(json['id']),
    accountNo: _asString(json['accountNo']),
    email: _asString(json['email'] ?? json['username'] ?? json['accountNo']),
    password: '******',
    phone: _asString(json['mobile']),
  );
}

ChatMessage _chatMessageFromJson(Map<String, dynamic> json) {
  final currentId = ItClassSession.current?.schoolAccountId;
  final senderId = _asInt(json['senderAccountId']);
  final senderType = _asInt(json['senderAccountType']);
  final author = senderId == currentId
      ? (ItClassSession.current?.schoolAccountType == schoolAccountTypeTeacher
            ? MessageAuthor.teacher
            : MessageAuthor.student)
      : senderType == schoolAccountTypeTeacher
      ? MessageAuthor.teacher
      : MessageAuthor.student;
  return ChatMessage(
    author,
    _asString(json['content'] ?? json['fileName']),
    id: _asInt(json['id']),
    conversationId: _asInt(json['conversationId']),
  );
}

CodeReviewItem _codeReviewItemFromAttemptJson(Map<String, dynamic> json) {
  final score =
      _asInt(json['totalScore']) ??
      _asInt(json['objectiveScore']) ??
      _asInt(json['subjectiveScore']) ??
      0;
  final status = _asInt(json['status']);
  final passed = json['passed'] == true;
  final feedback = switch (status) {
    30 => passed ? '採点済み：合格です。' : '採点済み：復習が必要です。',
    20 => '提出済み：先生の確認待ちです。',
    10 => '受験中：まだ提出されていません。',
    _ => '受験記録を確認できます。',
  };
  return CodeReviewItem(
    _asString(
      json['studentRealName'] ?? json['studentAccountNo'],
      fallback: 'Student',
    ),
    _asString(json['examTitle'], fallback: 'Exam'),
    score,
    feedback,
  );
}

String _answerContent(ExamQuestion question, int answerIndex) {
  final keys = question.optionKeys;
  if (keys != null && answerIndex >= 0 && answerIndex < keys.length) {
    return keys[answerIndex];
  }
  return _optionKey(answerIndex);
}

String _optionKey(int index) => String.fromCharCode('A'.codeUnitAt(0) + index);

Topic _topicFromAiConversationJson(Map<String, dynamic> json) {
  final title = _asString(json['title'], fallback: 'AI会話');
  return Topic(
    title,
    _asString(json['classroomName'], fallback: 'AI質問'),
    _asString(
      json['lastQuestionContent'] ?? json['lastMessageContent'],
      fallback: title,
    ),
    _asString(json['lastAnswerContent'], fallback: ''),
    id: _asInt(json['id']),
  );
}

List<ChatMessage> _chatMessagesFromAiQuestionJson(Map<String, dynamic> json) {
  final question = _asString(json['questionContent']);
  final answer = _asString(
    json['effectiveAnswer'] ?? json['aiAnswer'] ?? json['teacherAnswer'],
  );
  return [
    if (question.isNotEmpty) ChatMessage.student(question),
    if (answer.isNotEmpty) ChatMessage.ai(answer),
  ];
}

CodeAssignment _codeAssignmentFromJson(Map<String, dynamic> json) {
  return CodeAssignment(
    id: _asInt(json['id']),
    title: _asString(json['title'], fallback: 'Code Assignment'),
    level: _asString(json['level'], fallback: 'Java'),
    status: _asString(json['status'], fallback: 'API課題'),
    summary: _asString(json['summary']),
    prompt: _asString(json['prompt']),
    requirements: _asList(
      json['requirements'],
    ).map((item) => _asString(item)).where((item) => item.isNotEmpty).toList(),
    starterCode: _asString(json['starterCode']),
    standardAnswer: _asString(json['standardAnswer']),
    expectedKeywords: _asList(
      json['expectedKeywords'],
    ).map((item) => _asString(item)).where((item) => item.isNotEmpty).toList(),
  );
}

ScoreResult _scoreResultFromJson(Map<String, dynamic> json) {
  return ScoreResult(
    score: _asInt(json['score']) ?? 0,
    examTitle: _asString(json['examTitle'], fallback: 'Code Assignment'),
    examDate: _asString(json['examDate']),
    correctItems: _asList(
      json['correctItems'],
    ).map((item) => _asString(item)).where((item) => item.isNotEmpty).toList(),
    deductions: _asList(
      json['deductions'],
    ).map((item) => _scoreDeductionFromJson(_asMap(item))).toList(),
    standardAnswer: _asString(json['standardAnswer']),
    tips: _asList(
      json['tips'],
    ).map((item) => _asString(item)).where((item) => item.isNotEmpty).toList(),
  );
}

ScoreDeduction _scoreDeductionFromJson(Map<String, dynamic> json) {
  return ScoreDeduction(
    points: _asInt(json['points']) ?? 0,
    title: _asString(json['title']),
    reason: _asString(json['reason']),
    fix: _asString(json['fix']),
  );
}

String _contentType(PlatformFile file) {
  final extension = (file.extension ?? '').toLowerCase();
  switch (extension) {
    case 'mp4':
      return 'video/mp4';
    case 'mov':
      return 'video/quicktime';
    case 'pdf':
      return 'application/pdf';
    default:
      return 'application/octet-stream';
  }
}

Map<String, dynamic> _asMap(Object? value) {
  return value is Map<String, dynamic> ? value : <String, dynamic>{};
}

List<dynamic> _asList(Object? value) {
  return value is List ? value : const [];
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('${value ?? ''}');
}

String _asString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = '$value';
  return text.isEmpty ? fallback : text;
}
