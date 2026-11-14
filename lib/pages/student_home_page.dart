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
  int _selectedPracticeChapter = 0;
  int _selectedExamLesson = 0;
  int _selectedCodeAssignment = 0;
  List<Topic> _apiTopics = const [];
  List<LearningVideo> _apiVideos = const [];
  List<Lesson> _apiLessons = const [];
  List<SchoolPracticeQuestion> _apiPracticeQuestions = const [];
  List<SchoolExamSummary> _apiExams = const [];
  List<SchoolClassroom> _availableClassrooms = const [];
  String? _examLanguage;
  String? _teacherLanguage;
  bool _showExamHistory = false;
  List<ExamQuestion> _apiExamQuestions = const [];
  List<StudentProfile> _chatContacts = const [];
  List<ResourceTeacher> _courseTeachers = const [];
  bool _teacherDirectoryLoading = false;
  String? _teacherDirectoryError;
  List<CodeAssignment> _apiCodeAssignments = const [];
  String? _selectedLanguage;
  bool _languageSelectionInitialized = false;
  StudentProfile? _selectedChatContact;
  bool _showTeacherDirectory = true;
  String? _directoryTeacherKey;
  bool _directoryConsultationBusy = false;
  bool _directoryCreating = false;
  String? _directoryError;
  final Map<String, Future<int>> _resourceChatCreations = {};
  final Map<int, StudentProfile> _pendingChatContacts = {};
  int _chatRequestId = 0;
  int _contactsRequestId = 0;
  int _aiRequestId = 0;
  int? _aiConversationId;
  int? _chatConversationId;
  int? _examAttemptId;
  int? _loadedExamId;
  int? _loadingExamId;
  ExamResult? _examResult;
  String _aiWelcomeMessage = '';
  bool _aiAutoAnswerEnabled = true;
  String? _apiError;
  String? _examError;
  String? _chatError;
  bool _dataLoading = false;
  bool _chatLoading = false;
  bool _teacherSending = false;
  bool _aiSending = false;
  bool _aiLoading = false;
  final Map<String, double> _videoProgress = {};
  final Map<int, String> _examAnswers = {};
  final Map<int, String> _savedExamAnswers = {};
  final Set<int> _savingExamAnswers = {};
  DateTime? _examDeadline;
  bool _examSubmitting = false;
  bool _examSubmitted = false;

  final _aiInput = TextEditingController();
  final _teacherInput = TextEditingController();
  final _codeInput = TextEditingController();
  StreamSubscription<ChatMessage>? _chatMessageSubscription;

  final List<ChatMessage> _aiMessages = [];

  final List<ChatMessage> _teacherMessages = [];

  bool _matchesResourceLanguage(String language) {
    return _selectedLanguage == null ||
        language.trim().toUpperCase() == _selectedLanguage!.toUpperCase();
  }

  List<LearningVideo> get _videos => _apiVideos
      .where((video) => _matchesResourceLanguage(video.category))
      .toList();

  List<Lesson> get _lessonsForLearning => _apiLessons
      .where((lesson) => _matchesResourceLanguage(lesson.level))
      .toList();

  List<String> get _resourceLanguages {
    final labels = <String, String>{};
    for (final language in [
      ..._apiVideos.map((video) => video.category),
      ..._apiLessons.map((lesson) => lesson.level),
      ..._apiPracticeQuestions.map((question) => question.programmingLanguage),
    ]) {
      final name = language.trim();
      if (name.isNotEmpty) labels.putIfAbsent(name.toUpperCase(), () => name);
    }
    return labels.values.toList()..sort(
      (left, right) => left.toUpperCase().compareTo(right.toUpperCase()),
    );
  }

  List<String> get _allLearningLanguages => _uniqueLanguages([
    ..._resourceLanguages,
    ..._apiExams.map((exam) => exam.programmingLanguage),
    ..._availableClassrooms.map((room) => room.programmingLanguage),
  ]);

  bool _examMatches(SchoolExamSummary exam) =>
      _examLanguage == null ||
      exam.programmingLanguage.trim().toUpperCase() ==
          _examLanguage!.toUpperCase();

  String _videoKey(LearningVideo video) =>
      '${video.id ?? video.videoUrl}:${video.contentVersion}';

  double _progressFor(LearningVideo video) =>
      _videoProgress[_videoKey(video)] ?? video.progress;

  List<_PracticeLessonGroup> get _practiceLessonGroups {
    // Chapter numbers repeat across public courses and languages.
    final groups =
        <(int?, String, int?, int, String), List<SchoolPracticeQuestion>>{};
    for (final question in _apiPracticeQuestions) {
      if (!_matchesResourceLanguage(question.programmingLanguage)) {
        continue;
      }
      final key = (
        question.classroomId,
        question.programmingLanguage.trim().toUpperCase(),
        question.courseVideoId,
        question.chapterNo,
        question.lessonTitle,
      );
      groups.putIfAbsent(key, () => []).add(question);
    }
    final result = [
      for (final questions in groups.values)
        _PracticeLessonGroup(
          chapterNo: questions.first.chapterNo,
          title: questions.first.lessonTitle,
          language: questions.first.programmingLanguage,
          questions: questions,
        ),
    ];
    result.sort((left, right) {
      final language = left.language.compareTo(right.language);
      if (language != 0) return language;
      final chapter = left.chapterNo.compareTo(right.chapterNo);
      return chapter != 0 ? chapter : left.title.compareTo(right.title);
    });
    return result;
  }

  List<StudentProfile> get _teacherContacts => _chatContacts;

  List<_StudentTeacherDirectoryEntry> get _teacherDirectory {
    final entries = <String, _StudentTeacherDirectoryEntry>{};
    for (final teacher in _courseTeachers) {
      if (teacher.accountId <= 0 || teacher.status != 0) continue;
      final key = '${teacher.accountId}';
      entries.putIfAbsent(
        key,
        () => _StudentTeacherDirectoryEntry(key, teacher: teacher),
      );
    }
    final seenConversations = <int>{};
    for (final contact in _teacherContacts) {
      final conversationId = contact.conversationId;
      if (conversationId != null && !seenConversations.add(conversationId)) {
        continue;
      }
      final accountId = contact.accountId;
      final entry = entries['$accountId'];
      // History enriches eligible course teachers; it does not grant eligibility.
      if (entry == null) continue;
      entry.conversations.add(contact);
    }
    for (final entry in entries.values) {
      entry.conversations.sort(_compareStudentChatContacts);
    }
    return entries.values.toList()..sort((left, right) {
      final unread = (right.unreadCount > 0 ? 1 : 0).compareTo(
        left.unreadCount > 0 ? 1 : 0,
      );
      if (unread != 0) return unread;
      final latest = (right.latestMessageTime?.millisecondsSinceEpoch ?? 0)
          .compareTo(left.latestMessageTime?.millisecondsSinceEpoch ?? 0);
      if (latest != 0) return latest;
      final name = left.name.compareTo(right.name);
      return name != 0 ? name : left.key.compareTo(right.key);
    });
  }

  bool get _teacherConversationVisible =>
      _section == StudentSection.askTeacher &&
      !_showTeacherDirectory &&
      _directoryTeacherKey == null &&
      _selectedChatContact != null;

  List<CodeAssignment> get _codeAssignmentsForScoring => _apiCodeAssignments;

  @override
  void initState() {
    super.initState();
    _chatMessageSubscription = SchoolChatRealtime.instance.messages.listen(
      _handleRealtimeChatMessage,
    );
    unawaited(_loadStudentData());
  }

  @override
  void dispose() {
    unawaited(_chatMessageSubscription?.cancel());
    _aiInput.dispose();
    _teacherInput.dispose();
    _codeInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 720;
    return _ResponsiveShell(
      title: 'Eden AI プログラミング教師',
      subtitle: '学生画面：動画学習、文書学習、問題演習、テスト進捗',
      profileName: '${ItClassSession.current?.displayName ?? ''}（学生）',
      profileRole: '学生',
      activeIndex: StudentSection.values.indexOf(_section),
      items: _studentMenu,
      onSelect: (index) {
        final section = StudentSection.values[index];
        setState(() => _section = section);
        if (section == StudentSection.askTeacher) {
          unawaited(_refreshTeacherDirectory());
          unawaited(_refreshTeacherContacts());
        }
      },
      onLogout: _logout,
      middle: _studentMiddlePanel(context),
      content: Column(
        children: [
          if (mobile && _section == StudentSection.learning)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                children: [
                  _languageSelector(),
                  const SizedBox(height: 12),
                  _learningModeSelector(),
                ],
              ),
            ),
          if (_dataLoading) const LinearProgressIndicator(),
          if (_apiError != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: Text(_apiError!)),
                  TextButton(
                    onPressed: _dataLoading ? null : _loadStudentData,
                    child: const Text('再読み込み'),
                  ),
                ],
              ),
            ),
          Expanded(child: _studentContent(context)),
        ],
      ),
      topActions: const [],
    );
  }

  Widget _languageSelector() {
    // Classroom categories may exist before any course is published.
    final languages = _resourceLanguages;
    final selected = languages.contains(_selectedLanguage)
        ? _selectedLanguage
        : languages.firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          '学習言語',
          style: TextStyle(
            color: _AppPalette.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          key: ValueKey('language-$selected'),
          initialValue: selected,
          isExpanded: true,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.code_rounded),
          ),
          hint: Text(_dataLoading ? '読み込み中…' : '公開中のコースはありません'),
          items: [
            for (final language in languages)
              DropdownMenuItem(value: language, child: Text(language)),
          ],
          onChanged: _dataLoading || languages.isEmpty
              ? null
              : _changeResourceLanguage,
        ),
      ],
    );
  }

  Widget _learningModeSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        '学習タイプ',
        style: TextStyle(color: _AppPalette.muted, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      DropdownButtonFormField<LearningMode>(
        key: ValueKey(_learningMode),
        initialValue: _learningMode,
        isExpanded: true,
        decoration: const InputDecoration(prefixIcon: Icon(Icons.tune_rounded)),
        items: const [
          DropdownMenuItem(value: LearningMode.video, child: Text('動画学習')),
          DropdownMenuItem(value: LearningMode.document, child: Text('文書学習')),
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
            _selectedPracticeChapter = 0;
          });
        },
      ),
    ],
  );

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
                message: 'プログラミングについて質問すると、ここに会話が表示されます。',
              ),
            for (final topic in _apiTopics)
              _CompactListCard(
                title: topic.title,
                subtitle: topic.category,
                detail: topic.question,
                onTap: () => _loadAiTopic(topic),
              ),
          ],
        );
      case StudentSection.learning:
        return _HistoryPanel(
          title: _learningModeLabel(_learningMode),
          children: [
            _languageSelector(),
            const Divider(height: 24, color: _AppPalette.line),
            _learningModeSelector(),
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
                  message: '公開中の動画はまだありません。絞り込み中の場合は「すべて」を選択してください。',
                ),
            if (_learningMode == LearningMode.video)
              for (var i = 0; i < _videos.length; i++)
                _CompactListCard(
                  selected: _selectedLesson == i,
                  title: _videos[i].title,
                  subtitle:
                      '${_videos[i].category} · ${(_progressFor(_videos[i]) * 100).round()}%',
                  detail: _videos[i].description,
                  onTap: () => setState(() => _selectedLesson = i),
                ),
            if (_learningMode == LearningMode.document &&
                _lessonsForLearning.isEmpty)
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: '教材データがありません',
                message: '公開中の教材はまだありません。絞り込み中の場合は「すべて」を選択してください。',
              ),
            if (_learningMode == LearningMode.document)
              for (var i = 0; i < _lessonsForLearning.length; i++)
                _CompactListCard(
                  selected: _selectedLesson == i,
                  title: _lessonsForLearning[i].title,
                  subtitle: _lessonsForLearning[i].level,
                  detail: _lessonsForLearning[i].summary,
                  onTap: () => setState(() => _selectedLesson = i),
                ),
            if (_learningMode == LearningMode.questionBank &&
                _practiceLessonGroups.isEmpty)
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: '問題データがありません',
                message: '公開中の練習問題はまだありません。絞り込み中の場合は「すべて」を選択してください。',
              ),
            if (_learningMode == LearningMode.questionBank)
              for (var i = 0; i < _practiceLessonGroups.length; i++)
                _CompactListCard(
                  selected: _selectedPracticeChapter == i,
                  title: _practiceLessonGroups[i].title,
                  subtitle:
                      '${_practiceLessonGroups[i].language} · 第${_practiceLessonGroups[i].chapterNo}課 · ${_practiceLessonGroups[i].questions.length}問',
                  detail: _practiceLessonGroups[i].questions
                      .map((question) => question.title)
                      .join(' / '),
                  onTap: () => setState(() => _selectedPracticeChapter = i),
                ),
          ],
        );
      case StudentSection.exam:
        return _HistoryPanel(
          title: 'テスト',
          actionLabel: _examProgressLabel,
          children: [
            _LearningLanguageFilter(
              languages: _allLearningLanguages,
              value: _examLanguage,
              onChanged: _changeExamLanguage,
            ),
            const SizedBox(height: 12),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: false, label: Text('受験する')),
                ButtonSegment(value: true, label: Text('成績履歴')),
              ],
              selected: {_showExamHistory},
              onSelectionChanged: (values) =>
                  setState(() => _showExamHistory = values.first),
            ),
            const SizedBox(height: 12),
            if (!_showExamHistory)
              for (var i = 0; i < _apiExams.length; i++)
                if (_examMatches(_apiExams[i]))
                  _CompactListCard(
                    selected: _selectedExamLesson == i,
                    title: _apiExams[i].title,
                    subtitle:
                        '${_apiExams[i].programmingLanguage} · ${_apiExams[i].ownerTeacherName}',
                    detail: _apiExams[i].latestScore == null
                        ? _examLimitsLabel(_apiExams[i])
                        : '最新 ${_apiExams[i].latestScore}点',
                    onTap: () => setState(() => _selectedExamLesson = i),
                  ),
            if (!_showExamHistory && !_apiExams.any(_examMatches))
              const Text('この言語のテストはありません。'),
          ],
        );
      case StudentSection.askTeacher:
        return _teacherDirectoryPanel();
      case StudentSection.codeScoring:
        return _HistoryPanel(
          title: 'コード課題',
          children: [
            if (_codeAssignmentsForScoring.isEmpty)
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: 'コード課題がありません',
                message: '公開中のコード課題はまだありません。公開されるとここに表示されます。',
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
        return Column(
          children: [
            if (!_aiAutoAnswerEnabled)
              const Padding(
                padding: EdgeInsets.all(12),
                child: _InlineNotice(
                  tone: _NoticeTone.warning,
                  title: 'AIの自動回答は停止中です',
                  message: '質問は送信できます。担当者の確認・回答をお待ちください。',
                ),
              ),
            Expanded(
              child: _ChatWorkspace(
                title: 'AI会話',
                emptyHint: '例：HashMap と ArrayList の違いは何ですか？',
                messages: _aiMessages,
                controller: _aiInput,
                sendLabel: _aiSending ? '回答待ち…' : '送信',
                onSend: _sendAiMessage,
              ),
            ),
          ],
        );
      case StudentSection.codeScoring:
        if (_codeAssignmentsForScoring.isEmpty) {
          return const Center(
            child: _InlineNotice(
              tone: _NoticeTone.warning,
              title: 'コード課題がありません',
              message: '公開中のコード課題はまだありません。公開されるとここに表示されます。',
            ),
          );
        }
        final assignment = _codeAssignmentsForScoring[_selectedCodeAssignment];
        return Column(
          children: [
            if (assignment.id != null)
              _resourceConsultation(
                'QUESTION',
                assignment.id!,
                assignment.title,
              ),
            Expanded(
              child: _CodeScoringWorkspace(
                assignment: assignment,
                controller: _codeInput,
                onScore: _scoreCode,
              ),
            ),
          ],
        );
      case StudentSection.learning:
        if (_dataLoading &&
            _apiVideos.isEmpty &&
            _apiLessons.isEmpty &&
            _apiPracticeQuestions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_learningMode == LearningMode.video) {
          final videos = _videos;
          if (videos.isEmpty) return _emptyResourceContent('動画');
          final video = videos[_selectedLesson.clamp(0, videos.length - 1)];
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              _VideoProgressCard(
                key: ValueKey(_videoKey(video)),
                video: video,
                progress: _progressFor(video),
                onMarkWatched: () => _updateVideoProgress(video, 1),
                onProgressChanged: (progress) =>
                    _updateVideoProgress(video, progress),
                onPositionSaved: (position, duration, ended) =>
                    _saveVideoProgress(video, position, duration, ended),
              ),
              if (video.id != null)
                _resourceConsultation('VIDEO', video.id!, video.title),
            ],
          );
        }
        if (_learningMode == LearningMode.questionBank) {
          final groups = _practiceLessonGroups;
          if (groups.isEmpty) return _emptyResourceContent('練習問題');
          final group =
              groups[_selectedPracticeChapter.clamp(0, groups.length - 1)];
          return _StudentPracticeWorkspace(
            questions: group.questions,
            consultationBuilder: (question) =>
                question.courseVideoId == null || question.courseVideoId! <= 0
                ? const SizedBox.shrink()
                : _resourceConsultation(
                    'VIDEO',
                    question.courseVideoId!,
                    question.lessonTitle,
                  ),
          );
        }
        final lessons = _lessonsForLearning;
        if (lessons.isEmpty) return _emptyResourceContent('教材');
        final lesson = lessons[_selectedLesson.clamp(0, lessons.length - 1)];
        return Column(
          children: [
            if (lesson.id != null)
              _resourceConsultation('DOCUMENT', lesson.id!, lesson.title),
            Expanded(
              child: _LearningWorkspace(
                lesson: lesson,
                videos: const [],
                videoProgress: const [],
                onVideoProgressChanged: (_, _) {},
                onVideoPositionSaved: (_, _, _, _) async {},
                mode: LearningMode.document,
                practiceQuestions: const [],
              ),
            ),
          ],
        );
      case StudentSection.exam:
        if (_showExamHistory) {
          return _StudentExamHistoryWorkspace(
            key: ValueKey(_examLanguage),
            language: _examLanguage,
          );
        }
        final usingApi = _apiExams.isNotEmpty;
        if (!_apiExams.any(_examMatches) &&
            (_examAttemptId == null || _examSubmitted)) {
          return const Center(child: Text('この言語のテストはありません。'));
        }
        if (!usingApi) {
          return const Center(
            child: _InlineNotice(
              tone: _NoticeTone.warning,
              title: 'テストデータがありません',
              message: '公開中のテストはまだありません。公開されるとここに表示されます。',
            ),
          );
        }
        final examIndex = _selectedExamLesson.clamp(0, _apiExams.length - 1);
        final selectedExam = _apiExams[examIndex];
        return Column(
          children: [
            _resourceConsultation('EXAM', selectedExam.id, selectedExam.title),
            Expanded(child: _examContent(selectedExam)),
          ],
        );
      case StudentSection.askTeacher:
        return _teacherContent();
      case StudentSection.settings:
        return _ProfileSettingsWorkspace(
          roleTitle: '学生設定',
          roleSubtitle: 'プロフィール、アイコン、連絡先、パスワードを変更できます。',
          initialRealName: ItClassSession.current?.realName ?? '',
          initialNickname: ItClassSession.current?.nickname ?? '',
          initialEmail: ItClassSession.current?.email ?? '',
          initialPhone: ItClassSession.current?.mobile ?? '',
          initialAvatar: ItClassSession.current?.avatar ?? '',
          initialBasicInfo: ItClassSession.current?.programmingLanguage ?? '',
          section: _settingSection,
          onProfileChanged: (profile) {
            setState(() => ItClassSession.updateProfile(profile));
          },
        );
    }
  }

  Widget _teacherDirectoryPanel() {
    final directory = _teacherDirectory
        .where(
          (entry) =>
              _teacherLanguage == null ||
              entry.teacher.programmingLanguages.any(
                (language) =>
                    language.trim().toUpperCase() ==
                    _teacherLanguage!.toUpperCase(),
              ),
        )
        .toList();
    return ListView(
      key: const ValueKey('student-teacher-directory'),
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionHeader(
          icon: Icons.people_outline,
          title: '先生一覧',
          subtitle: 'すべての学習言語の担当の先生です。先生を選んで相談できます。',
        ),
        const SizedBox(height: 16),
        _LearningLanguageFilter(
          languages: _uniqueLanguages(
            _courseTeachers
                .expand((teacher) => teacher.programmingLanguages)
                .toList(),
          ),
          value: _teacherLanguage,
          onChanged: (value) => setState(() => _teacherLanguage = value),
        ),
        if (_teacherDirectoryLoading || _directoryCreating)
          const LinearProgressIndicator(),
        if (_teacherDirectoryError != null) ...[
          Text(
            _teacherDirectoryError!,
            style: const TextStyle(color: _AppPalette.coral),
          ),
          TextButton(
            onPressed: _teacherDirectoryLoading
                ? null
                : _refreshTeacherDirectory,
            child: const Text('先生一覧を再読み込み'),
          ),
        ],
        if (_directoryError != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _directoryError!,
              style: const TextStyle(color: _AppPalette.coral),
            ),
          ),
        if (_chatError != null) ...[
          Text(_chatError!, style: const TextStyle(color: _AppPalette.coral)),
          TextButton(
            onPressed: _refreshTeacherContacts,
            child: const Text('会話履歴を再読み込み'),
          ),
        ],
        const SizedBox(height: 16),
        if (directory.isEmpty && _teacherDirectoryError == null)
          _InlineNotice(
            tone: _NoticeTone.warning,
            title: _teacherDirectoryLoading
                ? '担当の先生を読み込み中です'
                : '担当の先生がまだ登録されていません',
            message: '学習コースに担当の先生が登録されると、ここから相談できます。',
          ),
        for (final entry in directory)
          KeyedSubtree(
            key: ValueKey('teacher-directory-${entry.key}'),
            child: _CompactListCard(
              selected:
                  !_showTeacherDirectory &&
                  (_directoryTeacherKey == entry.key ||
                      (_directoryTeacherKey == null &&
                          '${_selectedChatContact?.accountId}' == entry.key)),
              title: entry.name,
              subtitle: entry.languageLabel,
              detail: entry.conversations.isNotEmpty
                  ? entry.conversations.first.lastQuestion
                  : '質問を送信できます。',
              badge: entry.unreadCount > 0 ? '${entry.unreadCount}件未読' : null,
              showNotificationDot: entry.unreadCount > 0,
              onTap: () {
                if (_teacherDirectoryLoading || _directoryConsultationBusy) {
                  return;
                }
                unawaited(_consultDirectoryTeacher(entry));
              },
            ),
          ),
      ],
    );
  }

  Widget _teacherContent() {
    final directory = _teacherDirectory;
    _StudentTeacherDirectoryEntry? selectedTeacher;
    for (final entry in directory) {
      if (entry.key == _directoryTeacherKey) selectedTeacher = entry;
    }
    if (_showTeacherDirectory ||
        (_selectedChatContact == null && selectedTeacher == null)) {
      if (MediaQuery.sizeOf(context).width < 720) {
        return _teacherDirectoryPanel();
      }
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 40,
                color: _AppPalette.muted,
              ),
              SizedBox(height: 16),
              Text(
                '先生を選んでください',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8),
              Text(
                '左の先生一覧から相談する先生を選んでください。過去の会話も先生ごとに確認できます。',
                textAlign: TextAlign.center,
                style: TextStyle(color: _AppPalette.muted),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() {
                _showTeacherDirectory = true;
                _directoryTeacherKey = null;
              }),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('先生一覧'),
            ),
            if (selectedTeacher == null &&
                _selectedChatContact?.accountId != null)
              TextButton.icon(
                onPressed: () => setState(() {
                  _directoryTeacherKey = '${_selectedChatContact!.accountId}';
                }),
                icon: const Icon(Icons.history_rounded),
                label: const Text('会話履歴'),
              ),
          ],
        ),
        if (_directoryCreating) const LinearProgressIndicator(),
        Expanded(
          child: selectedTeacher != null
              ? _teacherOverview(selectedTeacher)
              : _selectedTeacherChat(),
        ),
      ],
    );
  }

  Widget _teacherOverview(_StudentTeacherDirectoryEntry entry) => ListView(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    children: [
      _SectionHeader(
        icon: Icons.person_outline,
        title: entry.name,
        subtitle: entry.languageLabel,
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _dataLoading || _directoryConsultationBusy
            ? null
            : () => unawaited(_consultDirectoryTeacher(entry)),
        icon: const Icon(Icons.chat_bubble_outline_rounded),
        label: const Text('チャットに戻る'),
      ),
      if (_directoryError != null)
        Text(
          _directoryError!,
          style: const TextStyle(color: _AppPalette.coral),
        ),
      const SizedBox(height: 20),
      const Text('会話履歴', style: TextStyle(fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      for (final contact in entry.conversations)
        KeyedSubtree(
          key: ValueKey('teacher-conversation-${contact.conversationId}'),
          child: _CompactListCard(
            title: _contactResourceLabel(contact),
            subtitle: contact.name,
            detail: contact.lastQuestion,
            badge: contact.unreadCount > 0 ? '${contact.unreadCount}件未読' : null,
            showNotificationDot: contact.unreadCount > 0,
            onTap: () => _selectTeacherContact(contact),
          ),
        ),
    ],
  );

  Widget _selectedTeacherChat() {
    final contact = _selectedChatContact;
    if (contact == null) return const SizedBox.shrink();
    if (_chatLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_chatConversationId == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_chatError ?? '会話を読み込めませんでした。'),
            TextButton(
              onPressed: () => _selectTeacherContact(contact),
              child: const Text('再試行'),
            ),
          ],
        ),
      );
    }
    return _ChatWorkspace(
      title: '先生に質問：${contact.name}',
      emptyHint: '先生に学習について質問できます。',
      messages: _teacherMessages,
      peerName: contact.name,
      controller: _teacherInput,
      sendLabel: _teacherSending ? '送信中…' : '先生へ送信',
      onSend: _sendTeacherMessage,
    );
  }

  Future<void> _consultDirectoryTeacher(
    _StudentTeacherDirectoryEntry entry,
  ) async {
    if (_directoryConsultationBusy) return;
    // Existing histories open immediately, without another selection screen.
    if (entry.conversations.isNotEmpty) {
      await _selectTeacherContact(entry.conversations.first);
      return;
    }
    final teacher = entry.teacher;
    setState(() {
      _directoryConsultationBusy = true;
      _directoryCreating = true;
      _directoryError = null;
    });
    try {
      final conversationId = await ItClassApi.instance.getOrCreateChat(
        peerAccountId: teacher.accountId,
      );
      if (conversationId <= 0) throw const ApiException('会話を作成できませんでした。');
      if (!mounted) return;
      await _openTeacherContact(
        StudentProfile(
          entry.name,
          entry.languageLabel,
          '質問を送信できます。',
          accountId: teacher.accountId,
          accountNo: teacher.accountNo,
          conversationId: conversationId,
          email: '',
          phone: '',
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = '相談を開始できませんでした：${userFacingError(error)}';
      setState(() => _directoryError = message);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() {
          _directoryConsultationBusy = false;
          _directoryCreating = false;
        });
      }
    }
  }

  Future<int> _getOrCreateResourceChat(
    String type,
    int id,
    int peerAccountId,
  ) async {
    final key = '$type:$id:$peerAccountId';
    final existing = _resourceChatCreations[key];
    if (existing != null) return existing;
    final request = ItClassApi.instance
        .getOrCreateChat(
          peerAccountId: peerAccountId,
          resourceType: type,
          resourceId: id,
        )
        .then((conversationId) {
          if (conversationId <= 0) throw const ApiException('会話を作成できませんでした。');
          return conversationId;
        });
    _resourceChatCreations[key] = request;
    try {
      return await request;
    } finally {
      if (identical(_resourceChatCreations[key], request)) {
        _resourceChatCreations.remove(key);
      }
    }
  }

  Widget _examContent(SchoolExamSummary selectedExam) {
    if (!selectedExam.isAvailable) {
      return const Center(
        child: _InlineNotice(
          tone: _NoticeTone.warning,
          title: '現在受験できません',
          message: 'このテストは現在停止されています。',
        ),
      );
    }
    if (_loadingExamId == selectedExam.id) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadedExamId != selectedExam.id) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _InlineNotice(
                  tone: _NoticeTone.warning,
                  title: _examError == null ? 'テストを開始してください' : 'テストを開始できません',
                  message:
                      _examError ??
                      '${_examLimitsLabel(selectedExam)}。開始ボタンを押すと問題を読み込みます。',
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loadSelectedExam,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(_examError == null ? 'テスト開始' : '再試行'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return _StudentExamWorkspace(
      key: ValueKey(_examAttemptId),
      title: selectedExam.title,
      limitsLabel:
          '${_examDeadline == null ? '時間制限なし' : '制限時間あり'} · ${selectedExam.maxAttempts == 0 ? '回数制限なし' : '${selectedExam.maxAttempts}回まで'}',
      questions: _apiExamQuestions,
      answers: _examAnswers,
      savedAnswers: _savedExamAnswers,
      savingAnswers: _savingExamAnswers,
      deadline: _examDeadline,
      submitting: _examSubmitting,
      submitted: _examSubmitted,
      result: _examResult,
      error: _examError,
      onChanged: (index, answer) =>
          setState(() => _examAnswers[index] = answer),
      onSave: (index) => unawaited(_saveBackendExamAnswer(index)),
      onSubmit: () => unawaited(_submitSelectedExam()),
      onRefreshResult: () => unawaited(_refreshExamResult()),
      onRetake: () {
        setState(() => _loadedExamId = null);
        unawaited(_loadSelectedExam());
      },
    );
  }

  String _examLimitsLabel(SchoolExamSummary exam) {
    final duration = exam.durationMinutes == 0
        ? '時間制限なし'
        : '${exam.durationMinutes}分';
    final attempts = exam.maxAttempts == 0
        ? '回数制限なし'
        : '${exam.maxAttempts}回まで';
    return '$duration · $attempts';
  }

  Widget _emptyResourceContent(String resource) => Center(
    child: _InlineNotice(
      tone: _NoticeTone.warning,
      title: '$resourceがありません',
      message: _selectedLanguage != null
          ? 'この条件に一致する公開リソースはありません。絞り込みを「すべて」に変更してください。'
          : '公開中の$resourceはまだありません。公開されるとここに表示されます。',
    ),
  );

  Widget _resourceConsultation(String type, int id, String name) => Padding(
    padding: const EdgeInsets.all(12),
    child: _StudentResourceConsultationButton(
      key: ValueKey('$type:$id'),
      resourceType: type,
      resourceId: id,
      createConversation: (teacher) =>
          _getOrCreateResourceChat(type, id, teacher.accountId),
      onConversationCreated: (conversationId, teacher) => unawaited(
        _openResourceConversation(conversationId, teacher, type, id, name),
      ),
    ),
  );

  void _sendAiMessage() {
    final text = _aiInput.text.trim();
    if (text.isEmpty || _aiSending || _aiLoading) return;
    final requestId = _aiRequestId;
    setState(() {
      _aiSending = true;
      _aiMessages.add(ChatMessage.student(text));
      _aiInput.clear();
    });
    unawaited(_sendAiMessageToApi(text, requestId));
  }

  Future<void> _sendAiMessageToApi(String text, int requestId) async {
    try {
      final conversationId =
          _aiConversationId ?? await ItClassApi.instance.ensureAiConversation();
      if (!mounted || requestId != _aiRequestId) return;
      _aiConversationId = conversationId;
      final answer = await ItClassApi.instance.askAi(
        conversationId: conversationId,
        content: text,
      );
      if (!mounted || requestId != _aiRequestId) return;
      setState(() => _aiMessages.add(ChatMessage.ai(answer)));
      final topics = await ItClassApi.instance.aiConversations();
      if (mounted) setState(() => _apiTopics = topics.list);
    } catch (error) {
      if (!mounted || requestId != _aiRequestId) return;
      setState(
        () => _aiMessages.add(
          ChatMessage.ai('質問の送信に失敗しました：${userFacingError(error)}'),
        ),
      );
    } finally {
      if (mounted && requestId == _aiRequestId) {
        setState(() => _aiSending = false);
      }
    }
  }

  void _sendTeacherMessage() {
    final text = _teacherInput.text.trim();
    final conversationId = _chatConversationId;
    if (text.isEmpty ||
        conversationId == null ||
        _chatLoading ||
        _teacherSending) {
      return;
    }
    final requestId = _chatRequestId;
    setState(() {
      _teacherSending = true;
      _teacherInput.clear();
    });
    unawaited(_sendTeacherMessageToApi(text, conversationId, requestId));
  }

  Future<void> _sendTeacherMessageToApi(
    String text,
    int conversationId,
    int requestId,
  ) async {
    try {
      final message = await ItClassApi.instance.sendChatMessage(
        conversationId: conversationId,
        content: text,
      );
      if (!mounted) return;
      if (requestId == _chatRequestId &&
          _chatConversationId == conversationId) {
        setState(() => _upsertTeacherMessage(message));
      }
      await _refreshTeacherContacts();
    } catch (error) {
      if (!mounted) return;
      if (requestId == _chatRequestId && _teacherInput.text.isEmpty) {
        _teacherInput.text = text;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('先生への送信に失敗しました：${userFacingError(error)}')),
      );
    } finally {
      if (mounted && requestId == _chatRequestId) {
        setState(() => _teacherSending = false);
      }
    }
  }

  Future<ScoreResult> _scoreCode() async {
    final assignment = _codeAssignmentsForScoring[_selectedCodeAssignment];
    if (assignment.id == null) {
      throw const ApiException('この課題を開けませんでした。一覧を更新してもう一度お試しください。');
    }
    return ItClassApi.instance.scoreCode(
      assignmentId: assignment.id!,
      code: _codeInput.text,
    );
  }

  bool get _examExpired =>
      _examDeadline != null && !DateTime.now().isBefore(_examDeadline!);

  String? get _examProgressLabel {
    if (_apiExams.isEmpty ||
        _loadedExamId != _apiExams[_selectedExamLesson].id) {
      return null;
    }
    if (_examResult?.passed != null) {
      return '結果 ${_examResult!.totalScore.round()}点';
    }
    if (_examSubmitted) return '提出済み';
    if (_savedExamAnswers.isEmpty) return null;
    return '保存 ${_savedExamAnswers.length}/${_apiExamQuestions.length}';
  }

  Future<void> _saveBackendExamAnswer(int index) async {
    final attemptId = _examAttemptId;
    final answer = _examAnswers[index];
    if (attemptId == null ||
        answer == null ||
        _examSubmitted ||
        _examSubmitting ||
        _examExpired ||
        _savingExamAnswers.contains(index)) {
      return;
    }
    final question = _apiExamQuestions[index];
    if (question.paperQuestionId == null) return;
    setState(() => _savingExamAnswers.add(index));
    try {
      await ItClassApi.instance.saveExamAnswer(
        attemptId: attemptId,
        paperQuestionId: question.paperQuestionId!,
        answerContent: answer,
      );
      if (!mounted || attemptId != _examAttemptId) return;
      setState(() => _savedExamAnswers[index] = answer);
    } catch (error) {
      if (!mounted || attemptId != _examAttemptId) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('回答保存に失敗しました：${userFacingError(error)}')),
      );
    } finally {
      if (mounted && attemptId == _examAttemptId) {
        setState(() => _savingExamAnswers.remove(index));
      }
    }
  }

  Future<void> _submitSelectedExam() async {
    final attemptId = _examAttemptId;
    if (attemptId == null ||
        _examSubmitting ||
        _examSubmitted ||
        _savingExamAnswers.isNotEmpty) {
      return;
    }
    final questions = List<ExamQuestion>.of(_apiExamQuestions);
    // After the server deadline only previously saved answers may be submitted.
    final answers = Map<int, String>.of(
      _examExpired ? _savedExamAnswers : _examAnswers,
    );
    setState(() {
      _examSubmitting = true;
      _examError = null;
    });
    try {
      await ItClassApi.instance.submitExam(
        attemptId: attemptId,
        questions: questions,
        selectedAnswers: const {},
        writtenAnswers: answers,
      );
      if (!mounted || attemptId != _examAttemptId) return;
      setState(() => _examSubmitted = true);
      await _refreshExamResult();
    } catch (error) {
      if (!mounted || attemptId != _examAttemptId) return;
      setState(() => _examError = '提出に失敗しました：${userFacingError(error)}');
    } finally {
      if (mounted && attemptId == _examAttemptId) {
        setState(() => _examSubmitting = false);
      }
    }
  }

  Future<void> _refreshExamResult() async {
    final attemptId = _examAttemptId;
    if (attemptId == null) return;
    try {
      final result = await ItClassApi.instance.examResult(attemptId);
      if (!mounted || attemptId != _examAttemptId) return;
      setState(() {
        _examResult = result;
        _examError = null;
      });
    } catch (error) {
      if (!mounted || attemptId != _examAttemptId) return;
      setState(
        () => _examError =
            '提出済みです。採点結果はまだ取得できません。時間をおいて再確認してください。\n${userFacingError(error)}',
      );
    }
  }

  Future<void> _loadStudentData() async {
    if (_dataLoading) return;
    setState(() {
      _apiError = null;
      _dataLoading = true;
    });
    final errors = <String>[];
    Future<void> load<T>(
      String label,
      Future<T> Function() fetch,
      void Function(T) apply,
    ) async {
      try {
        final value = await fetch();
        if (mounted) setState(() => apply(value));
      } catch (error) {
        errors.add('$label：${userFacingError(error)}');
      }
    }

    // Public resources do not depend on classroom membership.
    await Future.wait([
      load(
        '教室',
        ItClassApi.instance.myClassrooms,
        (value) => _availableClassrooms = value,
      ),
      load(
        'AI会話',
        () => ItClassApi.instance.aiConversations(),
        (value) => _apiTopics = value.list,
      ),
      load('AI設定', ItClassApi.instance.aiTutorConfig, (config) {
        _aiWelcomeMessage = config.welcomeMessage;
        _aiAutoAnswerEnabled = config.autoAnswerEnabled;
        if (_aiMessages.isEmpty && config.welcomeMessage.isNotEmpty) {
          _aiMessages.add(ChatMessage.ai(config.welcomeMessage));
        }
      }),
      load('動画', () => ItClassApi.instance.courseVideos(), (value) {
        _apiVideos = value.list;
        _selectedLesson = 0;
        for (final video in value.list) {
          _videoProgress[_videoKey(video)] = video.progress;
        }
      }),
      load('教材', () => ItClassApi.instance.courseDocuments(), (value) {
        _apiLessons = value.list;
        _selectedLesson = 0;
      }),
      load('練習問題', () => ItClassApi.instance.practiceQuestions(), (value) {
        _apiPracticeQuestions = value;
        _selectedPracticeChapter = 0;
      }),
      load('テスト', ItClassApi.instance.examPage, (value) {
        final selectedId = _apiExams.isEmpty
            ? null
            : _apiExams[_selectedExamLesson.clamp(0, _apiExams.length - 1)].id;
        _apiExams = value.list;
        final index = value.list.indexWhere((exam) => exam.id == selectedId);
        _selectedExamLesson = index < 0 ? 0 : index;
      }),
      _refreshTeacherDirectory(),
      _refreshTeacherContacts(),
      load('コード課題', ItClassApi.instance.codeAssignments, (value) {
        _apiCodeAssignments = value;
        _selectedCodeAssignment = 0;
        if (_codeInput.text.isEmpty && value.isNotEmpty) {
          _codeInput.text = value.first.starterCode;
        }
      }),
    ]);
    if (!mounted) return;
    setState(() {
      _dataLoading = false;
      _apiError = errors.isEmpty
          ? null
          : '一部のデータを読み込めませんでした。\n${errors.join('\n')}';
      final languages = _resourceLanguages;
      if (!_languageSelectionInitialized ||
          (_selectedLanguage != null &&
              !languages.contains(_selectedLanguage))) {
        _selectedLanguage = languages.isEmpty ? null : languages.first;
        _languageSelectionInitialized = languages.isNotEmpty;
        _selectedLesson = 0;
        _selectedPracticeChapter = 0;
      }
    });
  }

  void _changeResourceLanguage(String? language) {
    setState(() {
      _selectedLanguage = language;
      _languageSelectionInitialized = true;
      _selectedLesson = 0;
      _selectedPracticeChapter = 0;
    });
  }

  void _changeExamLanguage(String? language) {
    setState(() {
      _examLanguage = language;
      if (_examAttemptId == null || _examSubmitted) {
        final index = _apiExams.indexWhere(_examMatches);
        if (index >= 0) _selectedExamLesson = index;
      }
    });
  }

  Future<void> _loadSelectedExam() async {
    if (_apiExams.isEmpty) return;
    final examIndex = _selectedExamLesson.clamp(0, _apiExams.length - 1);
    final exam = _apiExams[examIndex];
    if (!exam.isAvailable) {
      setState(() => _examError = 'このテストは現在受験できません。');
      return;
    }
    if (_loadedExamId == exam.id || _loadingExamId == exam.id) return;
    setState(() {
      _loadingExamId = exam.id;
      _examError = null;
    });
    try {
      final attempt = await ItClassApi.instance.startExam(exam.id);
      if (!mounted || _loadingExamId != exam.id) return;
      setState(() {
        _examAttemptId = attempt.attemptId;
        _loadedExamId = exam.id;
        _apiExamQuestions = attempt.questions;
        _examResult = null;
        _examDeadline = attempt.deadlineTime;
        _examSubmitted = false;
        _examSubmitting = false;
        _savingExamAnswers.clear();
        _examAnswers.clear();
        _savedExamAnswers.clear();
        for (var i = 0; i < attempt.questions.length; i++) {
          final saved = attempt.questions[i].savedAnswer;
          if (saved.isNotEmpty) {
            _examAnswers[i] = saved;
            _savedExamAnswers[i] = saved;
          }
        }
      });
    } catch (error) {
      if (!mounted || _loadingExamId != exam.id) return;
      final message = 'テスト開始に失敗しました：${userFacingError(error)}';
      setState(() => _examError = message);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted && _loadingExamId == exam.id) {
        setState(() => _loadingExamId = null);
      }
    }
  }

  void _updateVideoProgress(LearningVideo video, double progress) {
    if (!mounted) return;
    setState(() => _videoProgress[_videoKey(video)] = progress.clamp(0, 1));
  }

  Future<void> _saveVideoProgress(
    LearningVideo video,
    int positionSeconds,
    int durationSeconds,
    bool ended,
  ) async {
    if (video.id == null) return;
    await ItClassApi.instance.saveVideoProgress(
      courseVideoId: video.id!,
      contentVersion: video.contentVersion,
      positionSeconds: positionSeconds,
      durationSeconds: durationSeconds,
      ended: ended,
    );
  }

  Future<void> _logout() async {
    await ItClassApi.instance.logout();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _startNewAiTopic() {
    ++_aiRequestId;
    setState(() {
      _aiConversationId = null;
      _aiLoading = false;
      _aiSending = false;
      _aiInput.clear();
      _aiMessages.clear();
      if (_aiWelcomeMessage.isNotEmpty) {
        _aiMessages.add(ChatMessage.ai(_aiWelcomeMessage));
      }
    });
  }

  Future<void> _loadAiTopic(Topic topic) async {
    if (topic.id == null) return;
    final requestId = ++_aiRequestId;
    setState(() {
      _aiConversationId = topic.id;
      _aiLoading = true;
      _aiSending = false;
      _aiInput.clear();
      _aiMessages
        ..clear()
        ..add(ChatMessage.ai('会話履歴を読み込み中です。'));
    });
    try {
      final messages = await ItClassApi.instance.aiConversationQuestions(
        topic.id!,
      );
      if (!mounted || requestId != _aiRequestId) return;
      setState(() {
        _aiMessages
          ..clear()
          ..addAll(messages);
      });
    } catch (error) {
      if (!mounted || requestId != _aiRequestId) return;
      setState(() {
        _aiMessages
          ..clear()
          ..add(ChatMessage.ai('AI会話履歴の取得に失敗しました：${userFacingError(error)}'));
      });
    } finally {
      if (mounted && requestId == _aiRequestId) {
        setState(() => _aiLoading = false);
      }
    }
  }

  Future<void> _openResourceConversation(
    int conversationId,
    ResourceTeacher teacher,
    String resourceType,
    int resourceId,
    String resourceName,
  ) async {
    if (!mounted) return;
    final contact = StudentProfile(
      _resourceTeacherName(teacher),
      'リソース相談',
      '質問を送信できます。',
      accountId: teacher.accountId,
      accountNo: teacher.accountNo,
      conversationId: conversationId,
      resourceType: resourceType,
      resourceId: resourceId,
      resourceName: resourceName,
      email: '',
      phone: '',
    );
    await _openTeacherContact(contact);
  }

  Future<void> _openTeacherContact(StudentProfile contact) async {
    if (!mounted) return;
    final conversationId = contact.conversationId!;
    // Empty conversations are intentionally omitted by the server's history.
    setState(() {
      _pendingChatContacts[conversationId] = contact;
      if (!_chatContacts.any((item) => item.conversationId == conversationId)) {
        _chatContacts = [contact, ..._chatContacts];
      }
      _section = StudentSection.askTeacher;
    });
    await _selectTeacherContact(contact);
    if (mounted) await _refreshTeacherContacts();
  }

  Future<void> _selectTeacherContact(StudentProfile contact) async {
    final requestId = ++_chatRequestId;
    setState(() {
      _showTeacherDirectory = false;
      _directoryTeacherKey = null;
      _selectedChatContact = contact;
      _chatConversationId = null;
      _chatLoading = true;
      _chatError = null;
      _teacherSending = false;
      _teacherInput.clear();
      _teacherMessages.clear();
    });
    try {
      var conversationId = contact.conversationId;
      if (conversationId == null) {
        if (contact.accountId == null) throw const ApiException('先生を選択してください。');
        final type = contact.resourceType;
        final hasResource =
            type != null && type.isNotEmpty && contact.resourceId != null;
        // Legacy contacts may still require their own original classroom.
        conversationId = await ItClassApi.instance.getOrCreateChat(
          peerAccountId: contact.accountId!,
          classroomId: hasResource ? null : contact.classroomId,
          resourceType: hasResource ? type : null,
          resourceId: hasResource ? contact.resourceId : null,
        );
      }
      if (conversationId <= 0) throw const ApiException('会話を作成できませんでした。');
      if (!mounted || requestId != _chatRequestId) return;
      _chatConversationId = conversationId;
      final messages = await ItClassApi.instance.chatMessages(conversationId);
      if (!mounted || requestId != _chatRequestId) return;
      final selected = contact.copyWith(
        conversationId: conversationId,
        unreadCount: 0,
      );
      setState(() {
        _selectedChatContact = selected;
        _chatConversationId = conversationId;
        _chatContacts = [
          for (final item in _chatContacts)
            if (_sameChatContact(item, contact)) selected else item,
        ];
        final arrivedDuringLoad = List<ChatMessage>.of(_teacherMessages);
        _teacherMessages.clear();
        for (final message in [...messages, ...arrivedDuringLoad]) {
          _upsertTeacherMessage(message);
        }
      });
      _markLatestTeacherMessageRead(_teacherMessages);
    } catch (error) {
      if (!mounted || requestId != _chatRequestId) return;
      setState(() {
        _chatConversationId = null;
        _chatError = '会話履歴の取得に失敗しました：${userFacingError(error)}';
      });
    } finally {
      if (mounted && requestId == _chatRequestId) {
        setState(() => _chatLoading = false);
      }
    }
  }

  Future<void> _refreshTeacherDirectory() async {
    if (_teacherDirectoryLoading) return;
    setState(() {
      _teacherDirectoryLoading = true;
      _teacherDirectoryError = null;
    });
    try {
      final teachers = await ItClassApi.instance.teacherDirectory();
      if (!mounted) return;
      setState(() {
        _courseTeachers = teachers
            .where((teacher) => teacher.accountId > 0 && teacher.status == 0)
            .toList();
        final languages = _uniqueLanguages(
          _courseTeachers
              .expand((teacher) => teacher.programmingLanguages)
              .toList(),
        );
        if (!languages.contains(_teacherLanguage)) _teacherLanguage = null;
        final selectedId = _selectedChatContact?.accountId;
        if (selectedId != null &&
            !_courseTeachers.any(
              (teacher) => teacher.accountId == selectedId,
            )) {
          _chatRequestId++;
          _selectedChatContact = null;
          _chatConversationId = null;
          _teacherMessages.clear();
          _showTeacherDirectory = true;
          _directoryTeacherKey = null;
        }
      });
    } catch (error) {
      if (mounted) {
        setState(
          () => _teacherDirectoryError =
              '先生一覧を読み込めませんでした：${userFacingError(error)}',
        );
      }
    } finally {
      if (mounted) setState(() => _teacherDirectoryLoading = false);
    }
  }

  Future<void> _refreshTeacherContacts() async {
    final requestId = ++_contactsRequestId;
    try {
      final contacts = await ItClassApi.instance.chatContacts();
      if (!mounted || requestId != _contactsRequestId) return;
      for (final contact in contacts) {
        _pendingChatContacts.remove(contact.conversationId);
      }
      final merged = [...contacts, ..._pendingChatContacts.values];
      StudentProfile? selected;
      for (final contact in merged) {
        if (_sameChatContact(_selectedChatContact, contact)) {
          selected = contact;
          break;
        }
      }
      setState(() {
        _chatContacts = merged;
        // A refreshed history must not change the active conversation or draft.
        if (selected != null) _selectedChatContact = selected;
        if (!_chatLoading && _chatConversationId != null) _chatError = null;
      });
    } catch (error) {
      if (!mounted || requestId != _contactsRequestId) return;
      setState(() => _chatError = '会話一覧の更新に失敗しました：${userFacingError(error)}');
    }
  }

  void _handleRealtimeChatMessage(ChatMessage message) {
    if (!mounted) return;
    if (message.conversationId != null &&
        message.conversationId == _chatConversationId) {
      setState(() => _upsertTeacherMessage(message));
      if (_teacherConversationVisible && !_chatLoading) {
        _markLatestTeacherMessageRead([message]);
      }
    }
    unawaited(_refreshTeacherContacts());
  }

  void _upsertTeacherMessage(ChatMessage message) {
    final id = message.id;
    final index = id == null
        ? -1
        : _teacherMessages.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _teacherMessages[index] = message;
    } else {
      _teacherMessages.add(message);
    }
  }

  void _markLatestTeacherMessageRead(List<ChatMessage> messages) {
    final conversationId = _chatConversationId;
    final incoming = messages
        .where(
          (message) =>
              message.author == MessageAuthor.teacher && message.id != null,
        )
        .toList();
    if (conversationId == null || incoming.isEmpty) return;
    final latestId = incoming
        .map((message) => message.id!)
        .reduce((left, right) => left > right ? left : right);
    if (!_teacherConversationVisible) return;
    unawaited(_readTeacherMessages(conversationId, latestId));
  }

  Future<void> _readTeacherMessages(int conversationId, int messageId) async {
    try {
      await ItClassApi.instance.readChatMessages(
        conversationId: conversationId,
        messageId: messageId,
      );
      if (!mounted) return;
      setState(() {
        _chatContacts = [
          for (final contact in _chatContacts)
            if (contact.conversationId == conversationId)
              contact.copyWith(unreadCount: 0)
            else
              contact,
        ];
      });
    } catch (_) {
      // A failed read receipt must not discard an otherwise readable history.
    }
  }
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

class _PracticeLessonGroup {
  const _PracticeLessonGroup({
    required this.chapterNo,
    required this.title,
    required this.language,
    required this.questions,
  });

  final int chapterNo;
  final String title;
  final String language;
  final List<SchoolPracticeQuestion> questions;
}

class _StudentTeacherDirectoryEntry {
  _StudentTeacherDirectoryEntry(this.key, {required this.teacher});

  final String key;
  final ResourceTeacher teacher;
  final List<StudentProfile> conversations = [];

  String get name => _resourceTeacherName(teacher);

  String get languageLabel {
    final languages = _uniqueLanguages(teacher.programmingLanguages);
    return '担当言語：${languages.isEmpty ? '言語未設定' : languages.join(' / ')}';
  }

  int get unreadCount => conversations.fold(
    0,
    (total, contact) =>
        total + (contact.unreadCount > 0 ? contact.unreadCount : 0),
  );
  DateTime? get latestMessageTime =>
      conversations.isEmpty ? null : conversations.first.lastMessageTime;
}

int _compareStudentChatContacts(StudentProfile left, StudentProfile right) {
  final time = (right.lastMessageTime?.millisecondsSinceEpoch ?? 0).compareTo(
    left.lastMessageTime?.millisecondsSinceEpoch ?? 0,
  );
  return time != 0
      ? time
      : (right.conversationId ?? 0).compareTo(left.conversationId ?? 0);
}

bool _sameChatContact(StudentProfile? left, StudentProfile right) {
  if (left == null) return false;
  if (left.conversationId != null || right.conversationId != null) {
    return left.conversationId != null &&
        left.conversationId == right.conversationId;
  }
  return left.accountId != null &&
      left.accountId == right.accountId &&
      left.classroomId == right.classroomId &&
      left.resourceType == right.resourceType &&
      left.resourceId == right.resourceId;
}

String _contactResourceLabel(StudentProfile contact) {
  final type = contact.resourceType;
  if (type == null || type.isEmpty) {
    if (contact.classroomId == null) return '先生とのチャット';
    return contact.status.isEmpty ? '以前の会話' : '以前の会話 · ${contact.status}';
  }
  final label = switch (type) {
    'VIDEO' => '動画',
    'DOCUMENT' => '教材',
    'QUESTION' => '問題',
    'PAPER' => '試験問題集',
    'EXAM' => 'テスト',
    _ => type,
  };
  final name = contact.resourceName.trim();
  return name.isEmpty ? label : '$label · $name';
}

String _resourceTeacherName(ResourceTeacher teacher) {
  if (teacher.realName.trim().isNotEmpty) return teacher.realName;
  if (teacher.accountNo.trim().isNotEmpty) return teacher.accountNo;
  return '担当の先生';
}

class _StudentResourceConsultationButton extends StatefulWidget {
  const _StudentResourceConsultationButton({
    super.key,
    required this.resourceType,
    required this.resourceId,
    required this.createConversation,
    required this.onConversationCreated,
  });

  final String resourceType;
  final int resourceId;
  final Future<int> Function(ResourceTeacher teacher) createConversation;
  final void Function(int conversationId, ResourceTeacher teacher)
  onConversationCreated;

  @override
  State<_StudentResourceConsultationButton> createState() =>
      _StudentResourceConsultationButtonState();
}

class _StudentResourceConsultationButtonState
    extends State<_StudentResourceConsultationButton> {
  bool _busy = false;
  bool _choosingTeacher = false;
  String? _error;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      OutlinedButton.icon(
        onPressed: _busy ? null : _consult,
        icon: _busy && !_choosingTeacher
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chat_bubble_outline_rounded),
        label: Text(
          _choosingTeacher
              ? '先生を選択'
              : _busy
              ? '読み込み中…'
              : '先生に相談',
        ),
      ),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            _error!,
            style: const TextStyle(color: _AppPalette.coral),
          ),
        ),
    ],
  );

  Future<void> _consult() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final teachers = await ItClassApi.instance.resourceTeachers(
        widget.resourceType,
        widget.resourceId,
      );
      if (!mounted) return;
      final available = {
        for (final teacher in teachers)
          if (teacher.accountId > 0 && teacher.status == 0)
            teacher.accountId: teacher,
      }.values.toList();
      if (available.isEmpty) {
        setState(() => _error = '現在相談できる担当の先生はいません。時間をおいて再確認してください。');
        return;
      }
      setState(() => _choosingTeacher = true);
      final teacher = await showDialog<ResourceTeacher>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('相談する先生を選択'),
          content: SizedBox(
            width: 400,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (final teacher in available)
                    ListTile(
                      leading: teacher.avatar.isEmpty
                          ? const CircleAvatar(
                              child: Icon(Icons.person_outline),
                            )
                          : ClipOval(
                              child: Image.network(
                                teacher.avatar,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const CircleAvatar(
                                  child: Icon(Icons.person_outline),
                                ),
                              ),
                            ),
                      title: Text(_resourceTeacherName(teacher)),
                      subtitle: teacher.accountNo.isEmpty
                          ? null
                          : Text(teacher.accountNo),
                      onTap: () => Navigator.of(dialogContext).pop(teacher),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('キャンセル'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      setState(() => _choosingTeacher = false);
      if (teacher == null) return;
      final conversationId = await widget.createConversation(teacher);
      if (!mounted) return;
      if (conversationId <= 0) throw const ApiException('会話を作成できませんでした。');
      widget.onConversationCreated(conversationId, teacher);
    } catch (error) {
      if (mounted) {
        setState(() => _error = '相談を開始できませんでした：${userFacingError(error)}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _choosingTeacher = false;
        });
      }
    }
  }
}

class _StudentPracticeWorkspace extends StatefulWidget {
  const _StudentPracticeWorkspace({
    required this.questions,
    required this.consultationBuilder,
  });

  final List<SchoolPracticeQuestion> questions;
  final Widget Function(SchoolPracticeQuestion) consultationBuilder;

  @override
  State<_StudentPracticeWorkspace> createState() =>
      _StudentPracticeWorkspaceState();
}

class _StudentPracticeWorkspaceState extends State<_StudentPracticeWorkspace> {
  final Map<int, String> _answers = {};
  final Set<int> _checked = {};

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      _SectionHeader(
        icon: Icons.account_tree_rounded,
        title: widget.questions.first.lessonTitle,
        subtitle:
            '${widget.questions.first.programmingLanguage} · ${widget.questions.length}問',
      ),
      const SizedBox(height: 16),
      for (var i = 0; i < widget.questions.length; i++) ...[
        _PracticeQuestionCard(
          number: i + 1,
          question: widget.questions[i],
          selectedOption: _answers[widget.questions[i].id],
          checked: _checked.contains(widget.questions[i].id),
          onOptionSelected: (answer) => setState(() {
            _answers[widget.questions[i].id] = answer;
            _checked.remove(widget.questions[i].id);
          }),
          onCheck: _answers[widget.questions[i].id] == null
              ? null
              : () => setState(() => _checked.add(widget.questions[i].id)),
        ),
        widget.consultationBuilder(widget.questions[i]),
        const SizedBox(height: 12),
      ],
    ],
  );
}

class _StudentExamWorkspace extends StatefulWidget {
  const _StudentExamWorkspace({
    super.key,
    required this.title,
    required this.limitsLabel,
    required this.questions,
    required this.answers,
    required this.savedAnswers,
    required this.savingAnswers,
    required this.deadline,
    required this.submitting,
    required this.submitted,
    required this.result,
    required this.error,
    required this.onChanged,
    required this.onSave,
    required this.onSubmit,
    required this.onRefreshResult,
    required this.onRetake,
  });

  final String title;
  final String limitsLabel;
  final List<ExamQuestion> questions;
  final Map<int, String> answers;
  final Map<int, String> savedAnswers;
  final Set<int> savingAnswers;
  final DateTime? deadline;
  final bool submitting;
  final bool submitted;
  final ExamResult? result;
  final String? error;
  final void Function(int index, String answer) onChanged;
  final ValueChanged<int> onSave;
  final VoidCallback onSubmit;
  final VoidCallback onRefreshResult;
  final VoidCallback onRetake;

  @override
  State<_StudentExamWorkspace> createState() => _StudentExamWorkspaceState();
}

class _StudentExamWorkspaceState extends State<_StudentExamWorkspace> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant _StudentExamWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.deadline != widget.deadline ||
        oldWidget.submitted != widget.submitted) {
      _syncTimer();
    }
  }

  void _syncTimer() {
    _timer?.cancel();
    if (widget.deadline == null || widget.submitted) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {});
      if (_expired) timer.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _expired =>
      widget.deadline != null && !DateTime.now().isBefore(widget.deadline!);
  bool get _editable => !widget.submitted && !widget.submitting && !_expired;

  String _optionKey(ExamQuestion question, int index) =>
      question.optionKeys != null && index < question.optionKeys!.length
      ? question.optionKeys![index]
      : String.fromCharCode(65 + index);

  Set<String> _selectedKeys(String answer) {
    try {
      final decoded = jsonDecode(answer);
      if (decoded is List) return decoded.map((value) => '$value').toSet();
      if (decoded is String) return {decoded};
    } catch (_) {
      // Historical answers may be a single key or comma-separated keys.
    }
    return answer
        .split(',')
        .map((key) => key.trim())
        .where((key) => key.isNotEmpty)
        .toSet();
  }

  String get _timeLabel {
    final seconds = widget.deadline!
        .difference(DateTime.now())
        .inSeconds
        .clamp(0, 1 << 31);
    return '残り ${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(
          icon: Icons.quiz_outlined,
          title: widget.title,
          subtitle: widget.limitsLabel,
        ),
        if (widget.deadline != null && !widget.submitted) ...[
          const SizedBox(height: 12),
          Text(_expired ? '制限時間が終了しました。保存済みの回答を提出できます。' : _timeLabel),
        ],
        if (widget.error != null) ...[
          const SizedBox(height: 12),
          Text(widget.error!, style: const TextStyle(color: _AppPalette.coral)),
        ],
        if (widget.submitted) ...[
          const SizedBox(height: 16),
          _InlineNotice(
            tone: result?.passed == true
                ? _NoticeTone.success
                : _NoticeTone.warning,
            title: result?.passed == null ? '提出済み・採点待ち' : '採点結果',
            message: result?.passed == null
                ? '記述・プログラミングの回答は先生が確認します。採点後に結果を確認してください。'
                : '${result!.totalScore} / ${result.paperTotalScore}点 · ${result.passed! ? '合格' : '不合格'}',
          ),
          Wrap(
            spacing: 12,
            children: [
              TextButton(
                onPressed: widget.onRefreshResult,
                child: const Text('結果を再確認'),
              ),
              TextButton(
                onPressed: widget.submitting ? null : widget.onRetake,
                child: const Text('もう一度受験する'),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        for (var i = 0; i < widget.questions.length; i++) _questionCard(i),
        if (!widget.submitted)
          FilledButton.icon(
            onPressed: widget.submitting || widget.savingAnswers.isNotEmpty
                ? null
                : widget.onSubmit,
            icon: const Icon(Icons.send_outlined),
            label: Text(widget.submitting ? '提出中…' : 'テストを提出'),
          ),
      ],
    );
  }

  Widget _questionCard(int index) {
    final question = widget.questions[index];
    final answer = widget.answers[index] ?? '';
    final selected = _selectedKeys(answer);
    final saved =
        widget.savedAnswers.containsKey(index) &&
        widget.savedAnswers[index] == answer;
    final saving = widget.savingAnswers.contains(index);
    final feedback = widget.result?.answerFor(question.paperQuestionId);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '第${index + 1}問 · ${question.topic}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            SelectableText(question.question),
            const SizedBox(height: 14),
            if (question.options.isNotEmpty)
              for (var option = 0; option < question.options.length; option++)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${_optionKey(question, option)}. ${question.options[option]}',
                  ),
                  value: selected.contains(_optionKey(question, option)),
                  onChanged: !_editable
                      ? null
                      : (checked) {
                          final key = _optionKey(question, option);
                          if (question.type == 2) {
                            final keys = {...selected};
                            if (checked == true) {
                              keys.add(key);
                            } else {
                              keys.remove(key);
                            }
                            final ordered = [
                              for (var j = 0; j < question.options.length; j++)
                                if (keys.contains(_optionKey(question, j)))
                                  _optionKey(question, j),
                            ];
                            widget.onChanged(index, jsonEncode(ordered));
                          } else {
                            widget.onChanged(index, checked == true ? key : '');
                          }
                        },
                )
            else
              TextFormField(
                key: ValueKey(question.paperQuestionId ?? index),
                initialValue: answer,
                enabled: _editable,
                minLines: question.type == 6 ? 8 : 3,
                maxLines: null,
                autocorrect: question.type != 6,
                enableSuggestions: question.type != 6,
                style: question.type == 6
                    ? const TextStyle(fontFamily: 'monospace')
                    : null,
                decoration: InputDecoration(
                  labelText: question.type == 6 ? 'コードを入力' : '回答を入力',
                ),
                onChanged: (value) => widget.onChanged(index, value),
              ),
            if (!widget.submitted) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed:
                    !_editable ||
                        saving ||
                        !widget.answers.containsKey(index) ||
                        saved
                    ? null
                    : () => widget.onSave(index),
                child: Text(
                  saving
                      ? '保存中…'
                      : saved
                      ? '保存済み'
                      : '回答を保存',
                ),
              ),
            ],
            if (feedback != null && widget.result!.answersVisible) ...[
              const SizedBox(height: 12),
              Text('参考回答：${feedback.referenceAnswer}'),
              Text(feedback.analysis),
              if (feedback.graderComment.isNotEmpty)
                Text('先生コメント：${feedback.graderComment}'),
            ],
          ],
        ),
      ),
    );
  }
}
