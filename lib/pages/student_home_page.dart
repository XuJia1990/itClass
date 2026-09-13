part of '../main.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  StudentSection _section = StudentSection.aiChat;
  LearningMode _learningMode = LearningMode.video;
  ProfileSettingSection _settingSection = ProfileSettingSection.profile;
  int _selectedLesson = 0;
  int _selectedExamLesson = 0;
  int _selectedCodeAssignment = 0;
  String _selectedChatStudent = '';
  List<Topic> _apiTopics = const [];
  List<LearningVideo> _apiVideos = const [];
  List<Lesson> _apiLessons = const [];
  List<SchoolExamSummary> _apiExams = const [];
  List<ExamQuestion> _apiExamQuestions = const [];
  List<StudentProfile> _chatContacts = const [];
  List<CodeAssignment> _apiCodeAssignments = const [];
  int? _selectedClassroomId;
  int? _aiConversationId;
  int? _chatConversationId;
  int? _examAttemptId;
  int? _loadedExamId;
  bool _loading = false;
  String? _apiError;
  final List<double> _videoProgress = [];
  final Map<String, int> _examAnswers = {};
  final Set<String> _submittedExamQuestions = {};

  final _aiInput = TextEditingController();
  final _teacherInput = TextEditingController();
  final _codeInput = TextEditingController(text: _defaultCode);

  final List<ChatMessage> _aiMessages = [
    ChatMessage.ai('こんにちは。IT教師 AI です。Java、アルゴリズム、Web API、テスト問題について質問できます。'),
  ];

  final List<ChatMessage> _teacherMessages = [];

  List<LearningVideo> get _videos => _apiVideos;

  List<Lesson> get _lessonsForLearning => _apiLessons;

  List<StudentProfile> get _teacherContacts => _chatContacts;

  List<CodeAssignment> get _codeAssignmentsForScoring => _apiCodeAssignments;

  @override
  void initState() {
    super.initState();
    unawaited(_loadStudentData());
  }

  @override
  void dispose() {
    _aiInput.dispose();
    _teacherInput.dispose();
    _codeInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ResponsiveShell(
      title: 'Eden AI プログラミング教師',
      subtitle: '学生画面：動画学習、文書学習、問題演習、テスト進捗',
      profileName: '${ItClassSession.current?.realName ?? ''}（学生）',
      profileRole: '学生',
      activeIndex: StudentSection.values.indexOf(_section),
      items: _studentMenu,
      onSelect: (index) {
        setState(() => _section = StudentSection.values[index]);
      },
      onLogout: _logout,
      middle: _studentMiddlePanel(context),
      content: _studentContent(context),
      topActions: const [],
    );
  }

  Widget _studentMiddlePanel(BuildContext context) {
    switch (_section) {
      case StudentSection.aiChat:
        return _HistoryPanel(
          title: '履歴',
          actionLabel: '新しい話題',
          onAction: _startNewAiTopic,
          children: [
            if (_apiTopics.isEmpty)
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: 'AI会話履歴がありません',
                message: 'バックエンドから AI 会話履歴が返っていません。',
              ),
            for (final topic in _apiTopics)
              _CompactListCard(
                title: topic.title,
                subtitle: topic.category,
                detail: topic.question,
                trailing: '名前変更',
                onTap: () => _loadAiTopic(topic),
              ),
          ],
        );
      case StudentSection.learning:
        return _HistoryPanel(
          title: _learningModeLabel(_learningMode),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                '学習タイプ',
                style: TextStyle(
                  color: _AppPalette.muted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            DropdownButtonFormField<LearningMode>(
              initialValue: _learningMode,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.tune_rounded),
              ),
              items: const [
                DropdownMenuItem(
                  value: LearningMode.video,
                  child: Text('動画学習'),
                ),
                DropdownMenuItem(
                  value: LearningMode.document,
                  child: Text('文書学習'),
                ),
                DropdownMenuItem(
                  value: LearningMode.questionBank,
                  child: Text('問題バンク'),
                ),
              ],
              onChanged: (mode) {
                if (mode == null) return;
                setState(() {
                  _learningMode = mode;
                  _selectedLesson = 0;
                });
              },
            ),
            const Divider(height: 24, color: _AppPalette.line),
            if (_apiError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  _apiError!,
                  style: const TextStyle(color: _AppPalette.coral),
                ),
              ),
            if (_learningMode == LearningMode.video)
              if (_videos.isEmpty)
                const _InlineNotice(
                  tone: _NoticeTone.warning,
                  title: '動画データがありません',
                  message: 'バックエンドから視聴対象の動画が返っていません。',
                ),
            if (_learningMode == LearningMode.video)
              for (var i = 0; i < _videos.length; i++)
                _CompactListCard(
                  selected: _selectedLesson == i,
                  title: _videos[i].title,
                  subtitle:
                      '${_videos[i].category} · ${(_videoProgress[i] * 100).round()}%',
                  detail: _videos[i].description,
                  onTap: () => setState(() => _selectedLesson = i),
                ),
            if (_learningMode != LearningMode.video &&
                _lessonsForLearning.isEmpty)
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: '教材データがありません',
                message: 'バックエンドから文書教材が返っていません。',
              ),
            if (_learningMode != LearningMode.video)
              for (var i = 0; i < _lessonsForLearning.length; i++)
                _CompactListCard(
                  selected: _selectedLesson == i,
                  title: _lessonsForLearning[i].title,
                  subtitle: _learningMode == LearningMode.document
                      ? _lessonsForLearning[i].level
                      : '${_lessonsForLearning[i].sections.length}小分類 · 各3問',
                  detail: _learningMode == LearningMode.document
                      ? _lessonsForLearning[i].summary
                      : '問題バンク：${_lessonsForLearning[i].sections.map((e) => e.heading).join(' / ')}',
                  onTap: () => setState(() => _selectedLesson = i),
                ),
          ],
        );
      case StudentSection.exam:
        if (_apiExams.isNotEmpty) {
          return _HistoryPanel(
            title: '受験すべきテスト',
            actionLabel: _examProgressLabel,
            children: [
              for (var i = 0; i < _apiExams.length; i++)
                _CompactListCard(
                  selected: _selectedExamLesson == i,
                  title: _apiExams[i].title,
                  subtitle: _apiExams[i].latestScore == null
                      ? '未開始'
                      : '最新 ${_apiExams[i].latestScore}点',
                  detail: _apiExams[i].description,
                  onTap: () {
                    setState(() => _selectedExamLesson = i);
                    unawaited(_loadSelectedExam());
                  },
                ),
            ],
          );
        }
        return _HistoryPanel(
          title: '受験すべきテスト',
          actionLabel: _examProgressLabel,
          children: [
            const _InlineNotice(
              tone: _NoticeTone.warning,
              title: 'テストデータがありません',
              message: 'バックエンドから受験対象のテストが返っていません。',
            ),
          ],
        );
      case StudentSection.askTeacher:
        return _HistoryPanel(
          title: '先生との会話',
          children: [
            if (_teacherContacts.isEmpty)
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: '先生データがありません',
                message: 'バックエンドからチャット可能な先生が返っていません。',
              ),
            for (final student in _teacherContacts)
              _CompactListCard(
                selected: _selectedChatStudent == student.name,
                title: student.name,
                subtitle: student.status,
                detail: student.lastQuestion,
                onTap: () => _selectTeacherContact(student),
              ),
          ],
        );
      case StudentSection.codeScoring:
        return _HistoryPanel(
          title: 'コード課題',
          children: [
            if (_codeAssignmentsForScoring.isEmpty)
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: 'コード課題がありません',
                message: 'バックエンドからコード課題が返っていません。',
              ),
            for (var i = 0; i < _codeAssignmentsForScoring.length; i++)
              _CompactListCard(
                selected: _selectedCodeAssignment == i,
                title: _codeAssignmentsForScoring[i].title,
                subtitle:
                    '${_codeAssignmentsForScoring[i].level} · ${_codeAssignmentsForScoring[i].status}',
                detail: _codeAssignmentsForScoring[i].summary,
                onTap: () => setState(() {
                  _selectedCodeAssignment = i;
                  _codeInput.text = _codeAssignmentsForScoring[i].starterCode;
                }),
              ),
          ],
        );
      case StudentSection.settings:
        return _settingsMiddlePanel(
          selected: _settingSection,
          onSelect: (section) => setState(() => _settingSection = section),
        );
    }
  }

  Widget _studentContent(BuildContext context) {
    switch (_section) {
      case StudentSection.aiChat:
        return _ChatWorkspace(
          title: 'AI会話',
          emptyHint: '例：HashMap と ArrayList の違いは何ですか？',
          messages: _aiMessages,
          controller: _aiInput,
          sendLabel: '送信',
          onSend: _sendAiMessage,
        );
      case StudentSection.codeScoring:
        if (_codeAssignmentsForScoring.isEmpty) {
          return const Center(
            child: _InlineNotice(
              tone: _NoticeTone.warning,
              title: 'コード課題がありません',
              message: '先生がバックエンドにコード課題を登録すると表示されます。',
            ),
          );
        }
        return _CodeScoringWorkspace(
          assignment: _codeAssignmentsForScoring[_selectedCodeAssignment],
          controller: _codeInput,
          onScore: _scoreCode,
        );
      case StudentSection.learning:
        final lessons = _lessonsForLearning;
        if (_learningMode != LearningMode.video && lessons.isEmpty) {
          return const Center(
            child: _InlineNotice(
              tone: _NoticeTone.warning,
              title: '教材データがありません',
              message: '先生がバックエンドに教材を登録すると表示されます。',
            ),
          );
        }
        final selectedLesson = lessons.isEmpty
            ? 0
            : _selectedLesson.clamp(0, lessons.length - 1);
        return _LearningWorkspace(
          lesson: _learningMode == LearningMode.video
              ? _emptyLesson()
              : lessons[selectedLesson],
          videos: _videos,
          videoProgress: _videoProgress,
          onVideoProgressChanged: (index, progress) {
            setState(() => _videoProgress[index] = progress);
            final video = _videos[index];
            if (video.id != null) {
              unawaited(
                ItClassApi.instance.saveVideoProgress(
                  courseVideoId: video.id!,
                  positionSeconds: 0,
                  durationSeconds: 0,
                  ended: progress >= 1,
                ),
              );
            }
          },
          mode: _learningMode,
        );
      case StudentSection.exam:
        final usingApi = _apiExams.isNotEmpty;
        if (!usingApi) {
          return const Center(
            child: _InlineNotice(
              tone: _NoticeTone.warning,
              title: 'テストデータがありません',
              message: '先生がバックエンドにテストを公開すると表示されます。',
            ),
          );
        }
        if (usingApi &&
            (_loading || _loadedExamId != _apiExams[_selectedExamLesson].id)) {
          unawaited(_loadSelectedExam());
          return const Center(child: CircularProgressIndicator());
        }
        final lesson = _lessonFromExam(_apiExams[_selectedExamLesson]);
        final questions = _apiExamQuestions;
        return _ExamWorkspace(
          lesson: lesson,
          questions: questions,
          selectedAnswers: {
            for (var i = 0; i < questions.length; i++)
              if (_examAnswers[_examKey(_selectedExamLesson, i)] != null)
                i: _examAnswers[_examKey(_selectedExamLesson, i)]!,
          },
          submittedIndexes: {
            for (var i = 0; i < questions.length; i++)
              if (_submittedExamQuestions.contains(
                _examKey(_selectedExamLesson, i),
              ))
                i,
          },
          onSelect: (questionIndex, answerIndex) => setState(() {
            _examAnswers[_examKey(_selectedExamLesson, questionIndex)] =
                answerIndex;
          }),
          onSubmit: (questionIndex) => _submitExam(questionIndex, questions),
        );
      case StudentSection.askTeacher:
        if (_teacherContacts.isEmpty) {
          return const Center(
            child: _InlineNotice(
              tone: _NoticeTone.warning,
              title: '先生データがありません',
              message: 'バックエンドに担当先生が登録されていません。',
            ),
          );
        }
        return _ChatWorkspace(
          title: '先生に質問：$_selectedChatStudent',
          emptyHint: 'AI の説明で分からなかった内容を先生に送信できます。',
          messages: _teacherMessages,
          controller: _teacherInput,
          sendLabel: '先生へ送信',
          onSend: _sendTeacherMessage,
        );
      case StudentSection.settings:
        return _ProfileSettingsWorkspace(
          roleTitle: '学生設定',
          roleSubtitle: '名前、パスワード、アイコン、連絡先、メール、基本情報を変更できます。',
          initialName: ItClassSession.current?.realName ?? '',
          initialEmail: ItClassSession.current?.email ?? '',
          initialPhone: ItClassSession.current?.mobile ?? '',
          initialAvatar: '',
          initialBasicInfo: '',
          section: _settingSection,
        );
    }
  }

  void _sendAiMessage() {
    final text = _aiInput.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _aiMessages.add(ChatMessage.student(text));
      _aiInput.clear();
    });
    unawaited(_sendAiMessageToApi(text));
  }

  Future<void> _sendAiMessageToApi(String text) async {
    try {
      final classroomId = _selectedClassroomId;
      if (classroomId == null) {
        setState(() => _aiMessages.add(ChatMessage.ai('担当クラスがありません。')));
        return;
      }
      final conversationId =
          _aiConversationId ??
          await ItClassApi.instance.ensureAiConversation(classroomId);
      _aiConversationId = conversationId;
      final answer = await ItClassApi.instance.askAi(
        conversationId: conversationId,
        content: text,
      );
      if (!mounted) return;
      setState(() => _aiMessages.add(ChatMessage.ai(answer)));
    } catch (error) {
      if (!mounted) return;
      setState(() => _aiMessages.add(ChatMessage.ai('API接続に失敗しました：$error')));
    }
  }

  void _sendTeacherMessage() {
    final text = _teacherInput.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _teacherMessages.add(ChatMessage.student(text));
      _teacherInput.clear();
    });
    unawaited(_sendTeacherMessageToApi(text));
  }

  Future<void> _sendTeacherMessageToApi(String text) async {
    try {
      final classroomId = _selectedClassroomId;
      final peer = _teacherContacts.firstWhere(
        (student) => student.name == _selectedChatStudent,
        orElse: () => _teacherContacts.first,
      );
      if (classroomId == null || peer.accountId == null) return;
      final conversationId =
          _chatConversationId ??
          await ItClassApi.instance.getOrCreateChat(
            classroomId: peer.classroomId ?? classroomId,
            peerAccountId: peer.accountId!,
          );
      _chatConversationId = conversationId;
      await ItClassApi.instance.sendChatMessage(
        conversationId: conversationId,
        content: text,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('先生への送信に失敗しました：$error')));
    }
  }

  Future<ScoreResult> _scoreCode() async {
    final assignment = _codeAssignmentsForScoring[_selectedCodeAssignment];
    if (assignment.id == null) {
      throw const ApiException('コード課題IDがありません。バックエンドの課題データを確認してください。');
    }
    return ItClassApi.instance.scoreCode(
      assignmentId: assignment.id!,
      code: _codeInput.text,
    );
  }

  String _examKey(int lessonIndex, int questionIndex) {
    return '$lessonIndex:$questionIndex';
  }

  String? get _examProgressLabel {
    final questions = _apiExamQuestions;
    final submitted = _submittedCount(_selectedExamLesson, questions.length);
    if (submitted == 0) return null;
    return '回答 $submitted/${questions.length} · ${_examScore(_selectedExamLesson, questions)}点';
  }

  int _submittedCount(int lessonIndex, int total) {
    var count = 0;
    for (var i = 0; i < total; i++) {
      if (_submittedExamQuestions.contains(_examKey(lessonIndex, i))) {
        count++;
      }
    }
    return count;
  }

  int _examScore(int lessonIndex, List<ExamQuestion> questions) {
    if (questions.isEmpty) return 0;
    var correct = 0;
    for (var i = 0; i < questions.length; i++) {
      final key = _examKey(lessonIndex, i);
      if (_submittedExamQuestions.contains(key) &&
          _examAnswers[key] == questions[i].answerIndex) {
        correct++;
      }
    }
    return ((correct / questions.length) * 100).round();
  }

  void _submitExam(int questionIndex, List<ExamQuestion> questions) {
    final answer = _examAnswers[_examKey(_selectedExamLesson, questionIndex)];
    if (answer == null) return;

    final current = questions[questionIndex];
    final correct = answer == current.answerIndex;
    setState(() {
      _submittedExamQuestions.add(_examKey(_selectedExamLesson, questionIndex));
    });

    if (_examAttemptId != null && current.paperQuestionId != null) {
      unawaited(
        _saveBackendExamAnswer(questionIndex, current, answer, questions),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          correct
              ? '正解です：${current.explanation}'
              : 'もう少しです：${current.explanation}',
        ),
      ),
    );
  }

  Future<void> _saveBackendExamAnswer(
    int questionIndex,
    ExamQuestion question,
    int answer,
    List<ExamQuestion> questions,
  ) async {
    try {
      await ItClassApi.instance.saveExamAnswer(
        attemptId: _examAttemptId!,
        paperQuestionId: question.paperQuestionId!,
        answerContent: _answerContent(question, answer),
      );
      if (_submittedCount(_selectedExamLesson, questions.length) ==
          questions.length) {
        await ItClassApi.instance.submitExam(
          attemptId: _examAttemptId!,
          questions: questions,
          selectedAnswers: {
            for (var i = 0; i < questions.length; i++)
              if (_examAnswers[_examKey(_selectedExamLesson, i)] != null)
                i: _examAnswers[_examKey(_selectedExamLesson, i)]!,
          },
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('回答保存に失敗しました：$error')));
    }
  }

  Future<void> _loadStudentData() async {
    setState(() {
      _loading = true;
      _apiError = null;
    });
    try {
      final classrooms = await ItClassApi.instance.myClassrooms();
      final classroomId = classrooms.isNotEmpty ? classrooms.first.id : null;
      final topics = await ItClassApi.instance.aiConversations(
        classroomId: classroomId,
      );
      final videos = await ItClassApi.instance.courseVideos(
        classroomId: classroomId,
      );
      final docs = await ItClassApi.instance.courseDocuments(
        classroomId: classroomId,
      );
      final exams = await ItClassApi.instance.examPage();
      final contacts = await ItClassApi.instance.chatContacts(
        classroomId: classroomId,
      );
      final codeAssignments = await ItClassApi.instance.codeAssignments();
      if (!mounted) return;
      setState(() {
        _selectedClassroomId = classroomId;
        _apiTopics = topics.list;
        _apiVideos = videos.list;
        _apiLessons = docs.list;
        _apiExams = exams.list;
        _chatContacts = contacts;
        _apiCodeAssignments = codeAssignments;
        _selectedCodeAssignment = 0;
        if (_apiCodeAssignments.isNotEmpty) {
          _codeInput.text = _apiCodeAssignments.first.starterCode;
        }
        _videoProgress
          ..clear()
          ..addAll(_videos.map((video) => video.progress));
        if (_teacherContacts.isNotEmpty) {
          _selectedChatStudent = _teacherContacts.first.name;
        }
      });
      if (_apiExams.isNotEmpty) {
        await _loadSelectedExam();
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _apiError = 'APIデータ取得に失敗しました：$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadSelectedExam() async {
    if (_apiExams.isEmpty) return;
    final exam = _apiExams[_selectedExamLesson];
    if (_loadedExamId == exam.id && _apiExamQuestions.isNotEmpty) return;
    setState(() => _loading = true);
    try {
      final attempt = await ItClassApi.instance.startExam(exam.id);
      if (!mounted) return;
      setState(() {
        _examAttemptId = attempt.attemptId;
        _loadedExamId = exam.id;
        _apiExamQuestions = attempt.questions;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _apiError = 'テスト開始に失敗しました：$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await ItClassApi.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }

  void _startNewAiTopic() {
    setState(() {
      _aiConversationId = null;
      _aiMessages
        ..clear()
        ..add(ChatMessage.ai('新しい話題を作成しました。プログラミングの質問を入力してください。'));
    });
  }

  Future<void> _loadAiTopic(Topic topic) async {
    if (topic.id == null) return;
    setState(() {
      _aiConversationId = topic.id;
      _aiMessages
        ..clear()
        ..add(ChatMessage.ai('会話履歴を読み込み中です。'));
    });
    try {
      final messages = await ItClassApi.instance.aiConversationQuestions(
        topic.id!,
      );
      if (!mounted) return;
      setState(() {
        _aiMessages
          ..clear()
          ..addAll(messages);
        if (_aiMessages.isEmpty) {
          _aiMessages.add(ChatMessage.ai('この会話にはまだ質問がありません。'));
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _aiMessages
          ..clear()
          ..add(ChatMessage.ai('AI会話履歴の取得に失敗しました：$error'));
      });
    }
  }

  Future<void> _selectTeacherContact(StudentProfile student) async {
    setState(() {
      _selectedChatStudent = student.name;
      _teacherMessages
        ..clear()
        ..add(ChatMessage.teacher('会話履歴を読み込み中です。'));
    });
    try {
      final classroomId = student.classroomId ?? _selectedClassroomId;
      if (classroomId == null || student.accountId == null) {
        throw const ApiException('担当クラスまたは先生IDがありません。');
      }
      final conversationId = await ItClassApi.instance.getOrCreateChat(
        classroomId: classroomId,
        peerAccountId: student.accountId!,
      );
      final messages = await ItClassApi.instance.chatMessages(conversationId);
      if (!mounted) return;
      setState(() {
        _chatConversationId = conversationId;
        _teacherMessages
          ..clear()
          ..addAll(messages);
        if (_teacherMessages.isEmpty) {
          _teacherMessages.add(ChatMessage.teacher('まだメッセージはありません。'));
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _teacherMessages
          ..clear()
          ..add(ChatMessage.teacher('会話履歴の取得に失敗しました：$error'));
      });
    }
  }
}

Lesson _emptyLesson() {
  return const Lesson(
    title: '動画学習',
    level: '動画',
    summary: '',
    content: '',
    code: '',
    sections: [],
    exercise: LessonExercise(
      question: '',
      options: [],
      answerIndex: 0,
      correctReason: '',
      wrongReason: '',
      standardAnswer: '',
    ),
    aiSummary: '',
  );
}

Lesson _lessonFromExam(SchoolExamSummary exam) {
  return Lesson(
    id: exam.id,
    title: exam.title,
    level: 'テスト',
    summary: exam.description,
    content: exam.description,
    code: '',
    sections: const [],
    exercise: const LessonExercise(
      question: 'テストを開始します。',
      options: ['開始する', 'あとで確認する'],
      answerIndex: 0,
      correctReason: '',
      wrongReason: '',
      standardAnswer: '',
    ),
    aiSummary: exam.description,
  );
}

String _learningModeLabel(LearningMode mode) {
  switch (mode) {
    case LearningMode.video:
      return 'AI教室：動画学習';
    case LearningMode.document:
      return 'AI教室：文書学習';
    case LearningMode.questionBank:
      return 'AI教室：問題バンク';
  }
}
