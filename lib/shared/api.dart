part of '../main.dart';

const int schoolAccountTypeTeacher = 1;
const int schoolAccountTypeStudent = 2;
const int chatContentTypeText = 1;
const int questionTypeSingleChoice = 1;
const int paperStatusReady = 10;
const int examResultPublishImmediate = 0;

class AuthSession {
  const AuthSession({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.schoolAccountId,
    required this.schoolAccountType,
    required this.realName,
    required this.nickname,
    required this.avatar,
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
      nickname: _asString(json['nickname']),
      avatar: _asString(json['avatar']),
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
  final String nickname;
  final String avatar;
  final String email;
  final String mobile;
  final String programmingLanguage;

  String get displayName => nickname.trim().isEmpty ? realName : nickname;

  bool get isUsable =>
      userId > 0 &&
      schoolAccountId > 0 &&
      accessToken.isNotEmpty &&
      refreshToken.isNotEmpty &&
      (schoolAccountType == schoolAccountTypeStudent ||
          schoolAccountType == schoolAccountTypeTeacher);

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'schoolAccountId': schoolAccountId,
    'schoolAccountType': schoolAccountType,
    'realName': realName,
    'nickname': nickname,
    'avatar': avatar,
    'email': email,
    'mobile': mobile,
    'programmingLanguage': programmingLanguage,
  };

  AuthSession withTokens(Map<String, dynamic> tokens) => AuthSession.fromJson({
    ...toJson(),
    'accessToken': tokens['accessToken'],
    'refreshToken': tokens['refreshToken'] ?? refreshToken,
  });

  AuthSession copyWithProfile(MemberProfile profile) {
    return AuthSession(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
      schoolAccountId: schoolAccountId,
      schoolAccountType: schoolAccountType,
      realName: profile.realName,
      nickname: profile.nickname,
      avatar: profile.avatar,
      email: profile.email,
      mobile: profile.mobile,
      programmingLanguage: profile.programmingLanguage,
    );
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.code});

  final String message;
  final int? code;

  @override
  String toString() => message;
}

class AiTutorConfig {
  const AiTutorConfig({
    required this.welcomeMessage,
    required this.autoAnswerEnabled,
  });

  final String welcomeMessage;
  final bool autoAnswerEnabled;
}

class SchoolChatRealtime {
  SchoolChatRealtime._();

  static final SchoolChatRealtime instance = SchoolChatRealtime._();
  static const _messageType = 'school-chat-message';
  static const _reconnectDelay = Duration(seconds: 3);

  final _messages = StreamController<ChatMessage>.broadcast();
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  String? _token;
  bool _closedByClient = true;

  Stream<ChatMessage> get messages => _messages.stream;

  static Uri webSocketUri(String token) {
    final base = Uri.parse(ItClassApi.baseUrl);
    return base.replace(
      scheme: base.scheme == 'https' ? 'wss' : 'ws',
      path: '/infra/ws',
      queryParameters: {'token': token},
    );
  }

  void connect() {
    final token = ItClassSession.current?.accessToken ?? '';
    if (token.isEmpty) return;
    if (_token == token && _channel != null) return;
    disconnect();
    _closedByClient = false;
    _token = token;
    _open();
  }

  void disconnect() {
    _closedByClient = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    unawaited(_subscription?.cancel());
    _subscription = null;
    unawaited(_channel?.sink.close());
    _channel = null;
    _token = null;
  }

  void _open() {
    final token = _token;
    if (_closedByClient || token == null || token.isEmpty) return;
    final uri = webSocketUri(token);
    try {
      final channel = WebSocketChannel.connect(uri);
      _channel = channel;
      debugPrint(
        '[itClass WS] connecting '
        '${uri.scheme}://${uri.authority}${uri.path}',
      );
      _subscription = channel.stream.listen(
        _handleFrame,
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('[itClass WS] error=$error');
          _scheduleReconnect();
        },
        onDone: () {
          debugPrint('[itClass WS] disconnected');
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } catch (error) {
      debugPrint('[itClass WS] connect failed: $error');
      _scheduleReconnect();
    }
  }

  void _handleFrame(dynamic frame) {
    try {
      final envelope = _asMap(jsonDecode('$frame'));
      if (_asString(envelope['type']) != _messageType) return;
      final rawContent = envelope['content'];
      final content = rawContent is String
          ? _asMap(jsonDecode(rawContent))
          : _asMap(rawContent);
      final message = _chatMessageFromJson(content);
      if (message.id == null || message.conversationId == null) return;
      debugPrint(
        '[itClass WS] <-- $_messageType '
        'conversation=${message.conversationId} message=${message.id}',
      );
      _messages.add(message);
    } catch (error) {
      debugPrint('[itClass WS] ignored invalid frame: $error');
    }
  }

  void _scheduleReconnect() {
    _channel = null;
    _subscription = null;
    if (_closedByClient || _reconnectTimer?.isActive == true) return;
    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectTimer = null;
      _open();
    });
  }
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
      programmingLanguage: _asString(json['programmingLanguage']),
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
    required this.status,
    required this.startTime,
    required this.endTime,
    this.alwaysAvailable = true,
    this.durationMinutes = 0,
    this.maxAttempts = 0,
    this.teachers = const [],
  });

  factory SchoolExamSummary.fromJson(Map<String, dynamic> json) {
    return SchoolExamSummary(
      id: _asInt(json['id']) ?? 0,
      title: _asString(json['title'], fallback: 'Exam'),
      description: _asString(json['description']),
      latestAttemptId: _asInt(json['latestAttemptId']),
      latestScore: _asInt(json['latestScore']),
      status: _asInt(json['status']) ?? 0,
      startTime: _asDateTime(json['startTime']),
      endTime: _asDateTime(json['endTime']),
      alwaysAvailable: json['alwaysAvailable'] != false,
      durationMinutes: _asInt(json['durationMinutes']) ?? 0,
      maxAttempts: _asInt(json['maxAttempts']) ?? 0,
      teachers: _asList(
        json['teachers'],
      ).map((e) => ResourceTeacher.fromJson(_asMap(e))).toList(),
    );
  }

  final int id;
  final String title;
  final String description;
  final int? latestAttemptId;
  final int? latestScore;
  final int status;
  final DateTime? startTime;
  final DateTime? endTime;
  final bool alwaysAvailable;
  final int durationMinutes;
  final int maxAttempts;
  final List<ResourceTeacher> teachers;

  bool get isAvailable {
    return status == 10;
  }
}

class SchoolPracticeQuestionOption {
  const SchoolPracticeQuestionOption({
    required this.key,
    required this.content,
  });

  factory SchoolPracticeQuestionOption.fromJson(Map<String, dynamic> json) {
    return SchoolPracticeQuestionOption(
      key: _asString(json['key']),
      content: _asString(json['content']),
    );
  }

  final String key;
  final String content;
}

class SchoolPracticeQuestion {
  const SchoolPracticeQuestion({
    required this.id,
    required this.classroomId,
    required this.courseVideoId,
    required this.chapterNo,
    required this.lessonTitle,
    required this.programmingLanguage,
    required this.title,
    required this.content,
    required this.options,
    required this.correctOption,
    required this.analysis,
    required this.difficulty,
    required this.sort,
  });

  factory SchoolPracticeQuestion.fromJson(Map<String, dynamic> json) {
    return SchoolPracticeQuestion(
      id: _asInt(json['id']) ?? 0,
      classroomId: _asInt(json['classroomId']) ?? 0,
      courseVideoId: _asInt(json['courseVideoId']),
      chapterNo: _asInt(json['chapterNo']) ?? 0,
      lessonTitle: _asString(json['lessonTitle'], fallback: '練習問題'),
      programmingLanguage: _asString(json['programmingLanguage']),
      title: _asString(json['title'], fallback: '練習問題'),
      content: _asString(json['content']),
      options: _asList(json['options'])
          .map((item) => SchoolPracticeQuestionOption.fromJson(_asMap(item)))
          .toList(),
      correctOption: _asString(json['correctOption']),
      analysis: _asString(json['analysis']),
      difficulty: _asInt(json['difficulty']) ?? 1,
      sort: _asInt(json['sort']) ?? 0,
    );
  }

  final int id;
  final int classroomId;
  final int? courseVideoId;
  final int chapterNo;
  final String lessonTitle;
  final String programmingLanguage;
  final String title;
  final String content;
  final List<SchoolPracticeQuestionOption> options;
  final String correctOption;
  final String analysis;
  final int difficulty;
  final int sort;
}

class ExamAttemptPayload {
  const ExamAttemptPayload({
    required this.attemptId,
    required this.examTitle,
    required this.questions,
    this.deadlineTime,
  });

  factory ExamAttemptPayload.fromJson(Map<String, dynamic> json) {
    return ExamAttemptPayload(
      attemptId: _asInt(json['attemptId']) ?? 0,
      examTitle: _asString(json['examTitle'], fallback: 'Exam'),
      deadlineTime: _asDateTime(json['deadlineTime']),
      questions: _asList(
        json['questions'],
      ).map((item) => _examQuestionFromJson(_asMap(item))).toList(),
    );
  }

  final int attemptId;
  final String examTitle;
  final List<ExamQuestion> questions;
  final DateTime? deadlineTime;
}

class ItClassApi {
  ItClassApi._() : _client = http.Client(), _realtimeEnabled = true;

  @visibleForTesting
  ItClassApi.forTesting(this._client) : _realtimeEnabled = false;

  static ItClassApi _instance = ItClassApi._();
  static ItClassApi get instance => _instance;

  @visibleForTesting
  static set instance(ItClassApi api) => _instance = api;

  static final String baseUrl = _resolveApiBaseUrl();
  static const String tenantId = String.fromEnvironment(
    'TWSCHOOL_TENANT_ID',
    defaultValue: '1',
  );

  final http.Client _client;
  final bool _realtimeEnabled;
  Future<void>? _refreshing;
  int? _refreshGeneration;

  void connectRealtime() {
    if (_realtimeEnabled) SchoolChatRealtime.instance.connect();
  }

  Future<AuthSession> accountLogin({
    required String account,
    required String password,
    int? expectedAccountType,
  }) async {
    final generation = ItClassSession.generation;
    final data = await _post<Map<String, dynamic>>(
      '/member/auth/account-login',
      body: {'username': account, 'password': password},
    );
    final session = AuthSession.fromJson(data);
    if (expectedAccountType != null &&
        session.schoolAccountType != expectedAccountType) {
      throw const ApiException('このアカウントでは選択した画面にログインできません。');
    }
    await ItClassSession.start(session, generation);
    connectRealtime();
    return session;
  }

  Future<void> logout() async {
    // Capture the old authorization before clearing it locally.
    final request = _post<dynamic>('/member/auth/logout');
    final clearing = ItClassSession.clear();
    try {
      await request.timeout(const Duration(seconds: 8));
    } catch (_) {
      // The UI should still return to the login screen when logout fails.
    } finally {
      await clearing;
    }
  }

  Future<void> _refreshSession(String failedToken, int generation) async {
    final session = ItClassSession.current;
    if (session == null || ItClassSession.generation != generation) {
      throw const ApiException('再度ログインしてください。', code: 401);
    }
    if (session.accessToken != failedToken) return;
    if (_refreshing != null && _refreshGeneration == generation) {
      return _refreshing!;
    }
    final operation = _renewSession(session, generation);
    _refreshing = operation;
    _refreshGeneration = generation;
    try {
      await operation;
    } finally {
      if (identical(_refreshing, operation)) _refreshing = null;
    }
  }

  Future<void> _renewSession(AuthSession session, int generation) async {
    try {
      final data = await _post<Map<String, dynamic>>(
        '/member/auth/refresh-token',
        query: {'refreshToken': session.refreshToken},
      );
      if (ItClassSession.generation != generation ||
          ItClassSession.current == null) {
        throw const ApiException('ログイン処理がキャンセルされました。', code: 401);
      }
      if (_asInt(data['userId']) != session.userId ||
          _asString(data['accessToken']).isEmpty) {
        throw const ApiException('再度ログインしてください。', code: 401);
      }
      // Refresh responses contain tokens only; keep the current school role/profile.
      await ItClassSession.replace(
        ItClassSession.current!.withTokens(data),
        generation,
      );
      if (ItClassSession.generation == generation) connectRealtime();
    } on ApiException catch (error) {
      if ((error.code == 400 || error.code == 401) &&
          ItClassSession.generation == generation) {
        await ItClassSession.clear();
      }
      rethrow;
    }
  }

  Future<MemberProfile> getCurrentUser() async {
    final data = await _get<Map<String, dynamic>>('/school/account/profile');
    return MemberProfile(
      realName: _asString(data['realName']),
      nickname: _asString(data['nickname']),
      avatar: _asString(data['avatar']),
      mobile: _asString(data['mobile']),
      email: _asString(data['email']),
      programmingLanguage: _asString(data['programmingLanguage']),
    );
  }

  Future<MemberProfile> updateProfile({
    required String realName,
    required String nickname,
    required String email,
    required String avatar,
    required String mobile,
    required String programmingLanguage,
  }) async {
    await _put<void>(
      '/school/account/profile',
      body: {
        'realName': realName,
        'nickname': nickname,
        'email': email,
        'avatar': avatar,
        'mobile': mobile,
        'programmingLanguage': programmingLanguage,
      },
    );
    return getCurrentUser();
  }

  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) {
    return _put<void>(
      '/school/account/password',
      body: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }

  Future<List<SchoolClassroom>> myClassrooms() async {
    final data = await _get<List<dynamic>>('/school/classroom/my-list');
    return data.map((item) => SchoolClassroom.fromJson(_asMap(item))).toList();
  }

  Future<ApiPage<LearningVideo>> courseVideos({
    int? classroomId,
    String? programmingLanguage,
  }) async {
    return _allPages(
      '/school/course-video/page',
      _learningVideoFromJson,
      query: {
        'pageNo': '1',
        'pageSize': '100',
        if (classroomId != null) 'classroomId': '$classroomId',
        'programmingLanguage': ?programmingLanguage,
      },
    );
  }

  Future<void> saveVideoProgress({
    required int courseVideoId,
    required int contentVersion,
    required int positionSeconds,
    required int durationSeconds,
    required bool ended,
  }) {
    return _post<void>(
      '/school/video-progress/save',
      body: {
        'courseVideoId': courseVideoId,
        'contentVersion': contentVersion,
        'positionSeconds': positionSeconds,
        'durationSeconds': durationSeconds,
        'ended': ended,
      },
    );
  }

  Future<ApiPage<Lesson>> courseDocuments({int? classroomId}) async {
    return _allPages(
      '/school/course-document/page',
      _lessonFromDocumentJson,
      query: {
        'pageNo': '1',
        'pageSize': '100',
        if (classroomId != null) 'classroomId': '$classroomId',
      },
    );
  }

  Future<LearningVideo> courseVideo(int id) async => _learningVideoFromJson(
    await _get<Map<String, dynamic>>(
      '/school/course-video/get',
      query: {'id': '$id'},
    ),
  );

  Future<Lesson> courseDocument(int id) async => _lessonFromDocumentJson(
    await _get<Map<String, dynamic>>(
      '/school/course-document/get',
      query: {'id': '$id'},
    ),
  );

  Future<Map<String, dynamic>> videoProgress(int id) =>
      _get<Map<String, dynamic>>(
        '/school/video-progress/get',
        query: {'courseVideoId': '$id'},
      );

  Future<List<ResourceTeacher>> resourceTeachers(
    String resourceType,
    int resourceId,
  ) async {
    final data = await _get<List<dynamic>>(
      '/school/resource/teachers',
      query: {'resourceType': resourceType, 'resourceId': '$resourceId'},
    );
    return data.map((e) => ResourceTeacher.fromJson(_asMap(e))).toList();
  }

  Future<List<SchoolPracticeQuestion>> practiceQuestions({
    int? classroomId,
  }) async {
    final data = await _get<List<dynamic>>(
      '/school/practice-question/list',
      query: {if (classroomId != null) 'classroomId': '$classroomId'},
    );
    return data
        .map((item) => SchoolPracticeQuestion.fromJson(_asMap(item)))
        .toList();
  }

  Future<int> createCourseVideo({
    int? classroomId,
    String? programmingLanguage,
    List<int>? teacherAccountIds,
    int chapterNo = 1,
    String description = '',
    required String title,
    required String fileUrl,
    required PlatformFile file,
  }) async {
    final data = await _post<dynamic>(
      '/school/course-video/teacher-create',
      body: {
        'classroomId': classroomId,
        'title': title,
        'description': description,
        'programmingLanguage': programmingLanguage,
        'teacherAccountIds': ?teacherAccountIds,
        'videoUrl': fileUrl,
        'videoPath': fileUrl,
        'fileName': file.name,
        'fileSize': file.size,
        'contentType': _contentType(file),
        'chapterNo': chapterNo,
        'sort': 0,
      },
    );
    return _asInt(data) ?? _asInt(_asMap(data)['id']) ?? 0;
  }

  Future<int> createCourseDocument({
    int? classroomId,
    String? programmingLanguage,
    List<int>? teacherAccountIds,
    int chapterNo = 1,
    String description = '',
    required String title,
    required String fileUrl,
    required PlatformFile file,
  }) async {
    final data = await _post<dynamic>(
      '/school/course-document/teacher-create',
      body: {
        'classroomId': classroomId,
        'title': title,
        'description': description,
        'programmingLanguage': programmingLanguage,
        'teacherAccountIds': ?teacherAccountIds,
        'documentUrl': fileUrl,
        'documentPath': fileUrl,
        'fileName': file.name,
        'fileSize': file.size,
        'contentType': _contentType(file),
        'chapterNo': chapterNo,
        'sort': 0,
      },
    );
    return _asInt(data) ?? 0;
  }

  Future<String> uploadFile(
    PlatformFile file, {
    String directory = 'itclass',
    bool retryAuthentication = true,
  }) async {
    final generation = ItClassSession.generation;
    final token = ItClassSession.current?.accessToken;
    final uri = _uri('/infra/file/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers(json: false));
    request.fields['directory'] = directory;
    final contentType = MediaType.parse(_contentType(file));
    if (file.bytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes!,
          filename: file.name,
          contentType: contentType,
        ),
      );
    } else if (file.path != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path!,
          contentType: contentType,
        ),
      );
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
      try {
        return _decodeResponse<String>(response);
      } on ApiException catch (error) {
        if (error.code != 401 || token == null) rethrow;
        if (!retryAuthentication) {
          if (generation == ItClassSession.generation) {
            await ItClassSession.clear();
          }
          rethrow;
        }
        await _refreshSession(token, generation);
        if (generation != ItClassSession.generation) rethrow;
        return uploadFile(
          file,
          directory: directory,
          retryAuthentication: false,
        );
      }
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
    return _allPages(
      '/school/exam/page',
      SchoolExamSummary.fromJson,
      query: {'pageNo': '1', 'pageSize': '100'},
    );
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
    Map<int, String> writtenAnswers = const {},
  }) {
    return _post<void>(
      '/school/exam/submit',
      body: {
        'attemptId': attemptId,
        'answers': [
          for (var i = 0; i < questions.length; i++)
            if (questions[i].paperQuestionId != null &&
                (selectedAnswers[i] != null || writtenAnswers[i] != null))
              {
                'paperQuestionId': questions[i].paperQuestionId,
                'answerContent':
                    writtenAnswers[i] ??
                    _answerContent(questions[i], selectedAnswers[i]!),
              },
        ],
      },
    );
  }

  Future<ExamResult> examResult(int attemptId) async {
    final data = await _get<Map<String, dynamic>>(
      '/school/exam/result',
      query: {'attemptId': '$attemptId'},
    );
    return _examResultFromJson(data);
  }

  Future<ApiPage<CodeReviewItem>> examAttempts() async {
    final data = await _get<Map<String, dynamic>>(
      '/school/exam-teacher/attempt/page',
      query: {'pageNo': '1', 'pageSize': '100'},
    );
    return _page(data, _codeReviewItemFromAttemptJson);
  }

  Future<List<CodeAssignment>> codeAssignments({
    String? programmingLanguage,
  }) async {
    final data = await _get<List<dynamic>>(
      '/school/code-scoring/assignment/list',
      query: {'programmingLanguage': ?programmingLanguage},
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
        .expand((item) => chatMessagesFromAiQuestionJson(_asMap(item)))
        .toList();
  }

  Future<AiTutorConfig> aiTutorConfig() async {
    final data = await _get<Map<String, dynamic>>(
      '/school/ai-tutor/config/get',
    );
    return AiTutorConfig(
      welcomeMessage: _asString(data['welcomeMessage']),
      autoAnswerEnabled: data['autoAnswerEnabled'] == true,
    );
  }

  Future<String> aiTutorWelcomeMessage([int? classroomId]) async =>
      (await aiTutorConfig()).welcomeMessage;

  Future<int> ensureAiConversation([int? classroomId]) async {
    final data = await _post<dynamic>(
      '/school/ai-tutor/conversation/create',
      body: {'title': 'プログラミングの質問'},
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
    return aiAskAnswerFromJson(data);
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
    final result = <StudentProfile>[];
    var pageNo = 1;
    while (true) {
      final data = await _get<Map<String, dynamic>>(
        '/school/chat/conversation/page',
        query: {
          'pageNo': '${pageNo++}',
          'pageSize': '100',
          if (classroomId != null) 'classroomId': '$classroomId',
        },
      );
      final page = _page(data, _chatContactFromConversationJson);
      result.addAll(page.list);
      if (page.list.isEmpty || result.length >= page.total) break;
    }
    return result;
  }

  Future<List<ChatConversationSummary>> chatConversations({
    int? classroomId,
  }) async {
    final data = await _get<Map<String, dynamic>>(
      '/school/chat/conversation/page',
      query: {
        'pageNo': '1',
        'pageSize': '100',
        if (classroomId != null) 'classroomId': '$classroomId',
      },
    );
    return _page(data, _chatConversationSummaryFromJson).list;
  }

  Future<int> getOrCreateChat({
    int? classroomId,
    required int peerAccountId,
    String? resourceType,
    int? resourceId,
  }) async {
    final data = await _post<dynamic>(
      '/school/chat/conversation/get-or-create',
      body: {
        'peerAccountId': peerAccountId,
        if (resourceType != null && resourceId != null) ...{
          'resourceType': resourceType,
          'resourceId': resourceId,
        } else
          'classroomId': ?classroomId,
      },
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

  Future<void> readChatMessages({
    required int conversationId,
    required int messageId,
  }) {
    return _put<void>(
      '/school/chat/message/read',
      body: {'conversationId': conversationId, 'messageId': messageId},
    );
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

  Future<StudentProfile> createStudent({
    int? classroomId,
    String? programmingLanguage,
    required String realName,
    required String username,
    required String password,
    required String mobile,
  }) async {
    final data = await _post<dynamic>(
      '/school/account/create-student',
      body: {
        'realName': realName,
        'nickname': realName,
        'email': username,
        'password': password,
        'mobile': mobile,
      },
    );
    return _studentProfileFromAccountJson(_asMap(data));
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

  Future<int> createQuestion(
    ExamQuestion question, {
    required String programmingLanguage,
    List<int>? teacherAccountIds,
  }) async {
    final data = await _post<dynamic>(
      '/school/exam-teacher/question/save',
      body: {
        'teacherAccountIds': ?teacherAccountIds,
        'type': question.type ?? questionTypeSingleChoice,
        'difficulty': 1,
        'programmingLanguage': programmingLanguage,
        'title': question.topic,
        'content': question.question,
        'referenceAnswer': _optionKey(question.answerIndex),
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
    List<int>? teacherAccountIds,
    int durationMinutes = 0,
  }) async {
    final data = await _post<dynamic>(
      '/school/exam-teacher/paper/save',
      body: {
        'teacherAccountIds': ?teacherAccountIds,
        'title': title,
        'description': description,
        'durationMinutes': durationMinutes,
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
    int? classroomId,
    required int paperId,
    required String title,
    required String description,
    int durationMinutes = 0,
    int maxAttempts = 0,
    int passScore = 60,
    List<int>? teacherAccountIds,
  }) async {
    final data = await _post<dynamic>(
      '/school/exam-teacher/exam/save',
      body: {
        'paperId': paperId,
        'title': title,
        'description': description,
        'durationMinutes': durationMinutes,
        'passScore': passScore,
        'maxAttempts': maxAttempts,
        'teacherAccountIds': ?teacherAccountIds,
        'shuffleQuestions': false,
        'shuffleOptions': false,
        'resultPublishType': examResultPublishImmediate,
        'showAnswer': true,
      },
    );
    return _asInt(data) ?? 0;
  }

  Future<T> _get<T>(String path, {Map<String, String>? query}) {
    return _send<T>('GET', path, query: query);
  }

  Future<ApiPage<T>> _allPages<T>(
    String path,
    T Function(Map<String, dynamic>) mapper, {
    Map<String, String>? query,
  }) async {
    final items = <T>[];
    var pageNo = 1;
    while (true) {
      final data = await _get<Map<String, dynamic>>(
        path,
        query: {...?query, 'pageNo': '${pageNo++}', 'pageSize': '100'},
      );
      final page = _page(data, mapper);
      items.addAll(page.list);
      if (page.list.isEmpty || items.length >= page.total) {
        return ApiPage(list: items, total: page.total);
      }
    }
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
    bool retryAuthentication = true,
  }) async {
    final uri = _uri(path, query);
    final generation = ItClassSession.generation;
    final token = ItClassSession.current?.accessToken;
    final authEndpoint = path.startsWith('/member/auth/');
    final headers = _headers();
    if (authEndpoint && path != '/member/auth/logout') {
      headers.remove('Authorization');
    }
    final encodedBody = body == null ? null : jsonEncode(body);
    _logRequest(method, uri, headers, body);
    late final http.Response response;
    try {
      final stopwatch = Stopwatch()..start();
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(const Duration(seconds: 20));
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: encodedBody ?? '{}')
              .timeout(const Duration(seconds: 20));
        default:
          response = await _client
              .post(uri, headers: headers, body: encodedBody ?? '{}')
              .timeout(const Duration(seconds: 20));
      }
      stopwatch.stop();
      _logResponse(response, elapsed: stopwatch.elapsed);
    } catch (error, stackTrace) {
      _logError(method, uri, error, stackTrace);
      rethrow;
    }
    try {
      return _decodeResponse<T>(response);
    } on ApiException catch (error) {
      if (error.code != 401 || authEndpoint || token == null) rethrow;
      if (!retryAuthentication) {
        if (generation == ItClassSession.generation) {
          await ItClassSession.clear();
        }
        rethrow;
      }
      await _refreshSession(token, generation);
      if (generation != ItClassSession.generation) rethrow;
      return _send<T>(
        method,
        path,
        query: query,
        body: body,
        retryAuthentication: false,
      );
    }
  }

  T _decodeResponse<T>(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        'HTTP ${response.statusCode}: $body',
        code: response.statusCode,
      );
    }
    if (body.isEmpty) return null as T;
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic> && decoded.containsKey('code')) {
      final code = _asInt(decoded['code']) ?? 0;
      if (code != 0) {
        throw ApiException(
          _asString(
            decoded['msg'] ?? decoded['message'],
            fallback: 'API error $code',
          ),
          code: code,
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
      '[itClass API] --> $method ${_safeLogUri(uri)}\n'
      'headers=${_compactJson(_sanitize(headers))}\n'
      'body=${_compactJson(_sanitize(body))}',
      wrapWidth: 1200,
    );
  }

  void _logResponse(http.Response response, {required Duration elapsed}) {
    final responseBody = utf8.decode(response.bodyBytes);
    Object? sanitizedBody = responseBody;
    try {
      sanitizedBody = _sanitize(jsonDecode(responseBody));
    } catch (_) {
      // Preserve non-JSON error bodies in the log.
    }
    debugPrint(
      '[itClass API] <-- ${response.statusCode} ${response.request?.method ?? ''} '
      '${response.request == null ? response.reasonPhrase ?? '' : _safeLogUri(response.request!.url)} '
      '(${elapsed.inMilliseconds}ms)\n'
      'headers=${_compactJson(_sanitize(response.headers))}\n'
      'body=${_compactJson(sanitizedBody)}',
      wrapWidth: 1200,
    );
  }

  void _logError(String method, Uri uri, Object error, StackTrace stackTrace) {
    debugPrint(
      '[itClass API] xx> $method ${_safeLogUri(uri)}\n'
      'error=${uri.queryParameters.containsKey('refreshToken') ? error.runtimeType : error}\n'
      'stack=$stackTrace',
      wrapWidth: 1200,
    );
  }
}

Uri _safeLogUri(Uri uri) => uri.hasQuery
    ? uri.replace(
        queryParameters: Map<String, String>.from(
          _sanitize(uri.queryParameters) as Map,
        ),
      )
    : uri;

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
    defaultValue: 'https://api-dev.tw-onlineschool.com/app-api',
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
      json['programmingLanguage'] ??
          json['classroomProgrammingLanguage'] ??
          json['classroomName'],
    ),
    duration: durationSeconds > 0 ? '${(durationSeconds / 60).ceil()}分' : '未設定',
    progress: ((progressPercent ?? 0) / 100).clamp(0.0, 1.0),
    description: _asString(json['description']),
    videoUrl: _resolveFileAccessUrl(
      accessUrl: json['playUrl'],
      sourceUrl: json['videoUrl'],
    ),
    durationSeconds: durationSeconds,
    lastPositionSeconds: _asInt(json['lastPositionSeconds']) ?? 0,
    contentVersion: _asInt(json['contentVersion']) ?? 0,
    teachers: _asList(
      json['teachers'],
    ).map((e) => ResourceTeacher.fromJson(_asMap(e))).toList(),
  );
}

Lesson _lessonFromDocumentJson(Map<String, dynamic> json) {
  final title = _asString(json['title'], fallback: 'Document');
  final description = _asString(
    json['description'],
    fallback: 'アップロード教材を確認します。',
  );
  final url = _resolveFileAccessUrl(
    accessUrl: json['accessUrl'],
    sourceUrl: json['documentUrl'],
  );
  return Lesson(
    id: _asInt(json['id']),
    classroomId: _asInt(json['classroomId']),
    title: title,
    level: _asString(
      json['programmingLanguage'] ??
          json['classroomProgrammingLanguage'] ??
          json['classroomName'],
    ),
    teachers: _asList(
      json['teachers'],
    ).map((e) => ResourceTeacher.fromJson(_asMap(e))).toList(),
    summary: description,
    content: url.isEmpty ? description : '$description\n\n資料URL: $url',
    code: '',
    sections: const [],
    exercise: const LessonExercise(
      question: '',
      options: [],
      answerIndex: 0,
      correctReason: '',
      wrongReason: '',
      standardAnswer: '',
    ),
    aiSummary: description,
    documentUrl: url,
    fileName: _asString(json['fileName']),
  );
}

String _resolveFileAccessUrl({
  required Object? accessUrl,
  required Object? sourceUrl,
}) {
  final access = _asString(accessUrl);
  final source = _asString(sourceUrl);
  if (access.isEmpty) return source;
  if (source.isEmpty) return access;
  final accessUri = Uri.tryParse(access);
  final sourceUri = Uri.tryParse(source);
  final sourceIsHttp =
      sourceUri?.scheme == 'http' || sourceUri?.scheme == 'https';
  if (accessUri != null && sourceIsHttp) {
    final decodedPath = Uri.decodeComponent(accessUri.path).toLowerCase();
    if (decodedPath.startsWith('/http://') ||
        decodedPath.startsWith('/https://')) {
      return source;
    }
  }
  return access;
}

ExamQuestion _examQuestionFromJson(Map<String, dynamic> json) {
  final options = _asList(json['options']);
  final labels = options.map((item) => _asMap(item)).toList();
  final optionKeys = labels
      .map((item) => _asString(item['optionKey']))
      .toList();
  return ExamQuestion(
    paperQuestionId: _asInt(json['paperQuestionId']),
    questionId: _asInt(json['questionId']),
    type: _asInt(json['type']),
    optionKeys: optionKeys,
    score: _asInt(json['score']),
    savedAnswer: _asString(json['savedAnswer']),
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
    answerIndex: -1,
    explanation: _asString(
      json['analysis'] ?? json['referenceAnswer'],
      fallback: '提出後に結果を確認してください。',
    ),
  );
}

ExamResult _examResultFromJson(Map<String, dynamic> json) {
  return ExamResult(
    attemptId: _asInt(json['attemptId']) ?? 0,
    totalScore: _asDouble(json['totalScore']) ?? 0,
    paperTotalScore: _asDouble(json['paperTotalScore']) ?? 0,
    passed: json['passed'] is bool ? json['passed'] as bool : null,
    answersVisible: json['answersVisible'] == true,
    answers: _asList(json['answers']).map((item) {
      final answer = _asMap(item);
      return ExamAnswerResult(
        paperQuestionId: _asInt(answer['paperQuestionId']) ?? 0,
        answerContent: _asString(answer['answerContent']),
        referenceAnswer: _asString(answer['referenceAnswer']),
        analysis: _asString(answer['analysis']),
        score: _asDouble(answer['score']) ?? 0,
        correct: answer['correct'] is bool ? answer['correct'] as bool : null,
      );
    }).toList(),
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

StudentProfile _chatContactFromConversationJson(Map<String, dynamic> json) {
  final nickname = _asString(json['peerNickname']).trim();
  final realName = _asString(json['peerRealName'], fallback: 'ユーザー');
  return StudentProfile(
    nickname.isEmpty ? realName : nickname,
    _asString(json['resourceName'] ?? json['classroomName'], fallback: '会話'),
    _asString(json['lastMessageContent'], fallback: '会話履歴を開く'),
    accountId: _asInt(json['peerAccountId']),
    classroomId: _asInt(json['classroomId']),
    accountNo: _asString(json['peerAccountNo']),
    conversationId: _asInt(json['id']),
    resourceType: json['resourceType'] as String?,
    resourceId: _asInt(json['resourceId']),
    resourceName: _asString(json['resourceName']),
    unreadCount: _asInt(json['unreadCount']) ?? 0,
    lastMessageTime: _asDateTime(json['lastMessageTime']),
    email: _asString(json['peerAccountNo']),
    phone: '',
  );
}

StudentProfile _studentProfileFromAccountJson(Map<String, dynamic> json) {
  return StudentProfile(
    _asString(json['realName'] ?? json['nickname'], fallback: 'Student'),
    _asString(json['status']) == '0' ? '生徒 · 有効' : '生徒',
    '学生アカウント',
    accountId: _asInt(json['id']),
    accountNo: _asString(json['accountNo']),
    email: _asString(json['email'] ?? json['username'] ?? json['accountNo']),
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

ChatConversationSummary _chatConversationSummaryFromJson(
  Map<String, dynamic> json,
) {
  return ChatConversationSummary(
    id: _asInt(json['id']) ?? 0,
    classroomId: _asInt(json['classroomId']) ?? 0,
    peerAccountId: _asInt(json['peerAccountId']) ?? 0,
    lastMessageId: _asInt(json['lastMessageId']),
    lastMessageContent: _asString(json['lastMessageContent']),
    lastMessageTime: _asDateTime(json['lastMessageTime']),
    unreadCount: _asInt(json['unreadCount']) ?? 0,
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

List<ChatMessage> chatMessagesFromAiQuestionJson(Map<String, dynamic> json) {
  final question = _asString(json['questionContent']);
  if (_asInt(json['status']) == 20) {
    return [
      if (question.isNotEmpty) ChatMessage.student(question),
      ChatMessage.ai(aiAnswerPendingTeacherMessage),
    ];
  }
  final aiAnswer = _asString(json['aiAnswer']);
  final teacherAnswer = _asString(json['teacherAnswer']);
  final legacyAnswer = _asString(json['effectiveAnswer']);
  return [
    if (question.isNotEmpty) ChatMessage.student(question),
    if (aiAnswer.isNotEmpty) ChatMessage.ai(aiAnswer),
    if (teacherAnswer.isNotEmpty) ChatMessage.teacher(teacherAnswer),
    if (aiAnswer.isEmpty && teacherAnswer.isEmpty && legacyAnswer.isNotEmpty)
      ChatMessage.ai(legacyAnswer),
  ];
}

const aiAnswerPendingTeacherMessage = '先生による確認が必要です。回答をお待ちください。';

String aiAskAnswerFromJson(Map<String, dynamic> json) {
  if (_asInt(json['status']) == 20) return aiAnswerPendingTeacherMessage;
  for (final answer in [
    json['effectiveAnswer'],
    json['aiAnswer'],
    json['teacherAnswer'],
  ]) {
    final text = _asString(answer);
    if (text.trim().isNotEmpty) return text;
  }
  return 'AIの回答を取得できませんでした。時間をおいて再度お試しください。';
}

CodeAssignment _codeAssignmentFromJson(Map<String, dynamic> json) {
  return CodeAssignment(
    id: _asInt(json['id']),
    title: _asString(json['title'], fallback: 'Code Assignment'),
    level: _asString(json['level']),
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
    case 'ppt':
      return 'application/vnd.ms-powerpoint';
    case 'pptx':
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
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

double? _asDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse('${value ?? ''}');
}

DateTime? _asDateTime(Object? value) {
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
  return DateTime.tryParse('${value ?? ''}');
}

String _asString(Object? value, {String fallback = ''}) {
  if (value == null) return fallback;
  final text = '$value';
  return text.isEmpty ? fallback : text;
}
