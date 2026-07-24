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
  String _selectedChatStudent = '佐藤';
  final Map<String, int> _examAnswers = {};
  final Set<String> _submittedExamQuestions = {};

  final _aiInput = TextEditingController();
  final _teacherInput = TextEditingController();
  final _codeInput = TextEditingController(text: _defaultCode);

  final List<ChatMessage> _aiMessages = [
    ChatMessage.ai('こんにちは。IT教師 AI です。Java、アルゴリズム、Web API、テスト問題について質問できます。'),
  ];

  final List<ChatMessage> _teacherMessages = [
    ChatMessage.teacher('AI の説明が分かりにくい場合は、先生に質問できます。'),
    ChatMessage.student('先生、Java の List と配列はどのように使い分けますか？'),
  ];

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
      profileName: '佐藤（学生）',
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
          onAction: () => setState(() {
            _aiMessages
              ..clear()
              ..add(ChatMessage.ai('新しい話題を作成しました。プログラミングの質問を入力してください。'));
          }),
          children: [
            for (final topic in _studentTopics)
              _CompactListCard(
                title: topic.title,
                subtitle: topic.category,
                detail: topic.question,
                trailing: '名前変更',
                onTap: () => setState(() {
                  _aiMessages
                    ..clear()
                    ..add(ChatMessage.student(topic.question))
                    ..add(ChatMessage.ai(topic.answer));
                }),
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
            if (_learningMode == LearningMode.video)
              for (var i = 0; i < _learningVideos.length; i++)
                _CompactListCard(
                  selected: _selectedLesson == i,
                  title: _learningVideos[i].title,
                  subtitle:
                      '${_learningVideos[i].category} · ${(_learningVideos[i].progress * 100).round()}%',
                  detail: _learningVideos[i].description,
                  onTap: () => setState(() => _selectedLesson = i),
                )
            else
              for (var i = 0; i < _lessons.length; i++)
                _CompactListCard(
                  selected: _selectedLesson == i,
                  title: _lessons[i].title,
                  subtitle: _learningMode == LearningMode.document
                      ? _lessons[i].level
                      : '${_lessons[i].sections.length}小分類 · 各3問',
                  detail: _learningMode == LearningMode.document
                      ? _lessons[i].summary
                      : '問題バンク：${_lessons[i].sections.map((e) => e.heading).join(' / ')}',
                  onTap: () => setState(() => _selectedLesson = i),
                ),
          ],
        );
      case StudentSection.exam:
        return _HistoryPanel(
          title: 'テスト範囲',
          actionLabel: _examProgressLabel,
          children: [
            for (var i = 0; i < _lessons.length; i++)
              _CompactListCard(
                selected: _selectedExamLesson == i,
                title: _lessons[i].title,
                subtitle: _examLessonProgressLabel(i),
                detail: _lessons[i].summary,
                onTap: () => setState(() => _selectedExamLesson = i),
              ),
          ],
        );
      case StudentSection.askTeacher:
        return _HistoryPanel(
          title: '先生との会話',
          children: [
            for (final student in _students)
              _CompactListCard(
                selected: _selectedChatStudent == student.name,
                title: student.name,
                subtitle: student.status,
                detail: student.lastQuestion,
                onTap: () =>
                    setState(() => _selectedChatStudent = student.name),
              ),
          ],
        );
      case StudentSection.codeScoring:
        return _HistoryPanel(
          title: 'コード課題',
          children: [
            for (var i = 0; i < _codeAssignments.length; i++)
              _CompactListCard(
                selected: _selectedCodeAssignment == i,
                title: _codeAssignments[i].title,
                subtitle:
                    '${_codeAssignments[i].level} · ${_codeAssignments[i].status}',
                detail: _codeAssignments[i].summary,
                onTap: () => setState(() {
                  _selectedCodeAssignment = i;
                  _codeInput.text = _codeAssignments[i].starterCode;
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
        return _CodeScoringWorkspace(
          assignment: _codeAssignments[_selectedCodeAssignment],
          controller: _codeInput,
          onScore: _scoreCode,
        );
      case StudentSection.learning:
        return _LearningWorkspace(
          lesson: _lessons[_selectedLesson],
          videos: _learningVideos,
          mode: _learningMode,
        );
      case StudentSection.exam:
        final questions = _examQuestionsForLesson(
          _lessons[_selectedExamLesson],
        );
        return _ExamWorkspace(
          lesson: _lessons[_selectedExamLesson],
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
          initialName: '佐藤',
          initialEmail: 'student@example.com',
          initialPhone: '080-2222-3333',
          initialAvatar: 'student-avatar.png',
          initialBasicInfo: 'Java基礎を学習中。HashMap と Web API を重点的に復習しています。',
          section: _settingSection,
        );
    }
  }

  void _sendAiMessage() {
    final text = _aiInput.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _aiMessages.add(ChatMessage.student(text));
      _aiMessages.add(ChatMessage.ai(_mockAiAnswer(text)));
      _aiInput.clear();
    });
  }

  void _sendTeacherMessage() {
    final text = _teacherInput.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _teacherMessages.add(ChatMessage.student(text));
      _teacherMessages.add(
        ChatMessage.teacher('受け取りました。コードとエラー内容を確認して、具体的にアドバイスします。'),
      );
      _teacherInput.clear();
    });
  }

  ScoreResult _scoreCode() {
    final code = _codeInput.text;
    final assignment = _codeAssignments[_selectedCodeAssignment];
    var score = 45;
    final tips = <String>[];

    for (final keyword in assignment.expectedKeywords) {
      if (code.contains(keyword)) {
        score += 8;
        tips.add('$keyword を使えています。');
      }
    }

    if (code.contains('class ')) {
      tips.add('クラス定義があります。');
    } else {
      tips.add('明確な class でコードをまとめると読みやすくなります。');
    }
    if (code.contains('for') || code.contains('while')) {
      tips.add('ループ構造があり、配列問題に対応できます。');
    }
    if (code.contains('Map') || code.contains('HashMap')) {
      tips.add('Map を使うと検索の平均計算量を O(1) にできます。');
    }
    if (code.contains('return')) {
      tips.add('戻り値が明確です。');
    }
    if (!code.contains(';')) {
      score -= 10;
      tips.add('Java の文には通常セミコロンが必要です。文法を確認してください。');
    }

    final baseDeductions = <ScoreDeduction>[
      const ScoreDeduction(
        points: 4,
        title: '入力チェックが少ない',
        reason: 'nums が null の場合や要素数が 2 未満の場合の説明がありません。',
        fix: '最初に null と length を確認すると、実務コードとしてより安全です。',
      ),
      const ScoreDeduction(
        points: 2,
        title: '計算量の説明が不足',
        reason: 'HashMap を使っている理由は良いですが、O(n) である説明がコメントにありません。',
        fix: '提出時に「時間計算量 O(n)、空間計算量 O(n)」を明記しましょう。',
      ),
    ];

    return ScoreResult(
      score: score.clamp(0, 94).toInt(),
      examTitle: assignment.title,
      examDate: _todayLabel(),
      correctItems: assignment.requirements,
      deductions: baseDeductions,
      standardAnswer: assignment.standardAnswer,
      tips: tips,
    );
  }

  String _examKey(int lessonIndex, int questionIndex) {
    return '$lessonIndex:$questionIndex';
  }

  String? get _examProgressLabel {
    final questions = _examQuestionsForLesson(_lessons[_selectedExamLesson]);
    final submitted = _submittedCount(_selectedExamLesson, questions.length);
    if (submitted == 0) return null;
    return '回答 $submitted/${questions.length} · ${_examScore(_selectedExamLesson, questions)}点';
  }

  String _examLessonProgressLabel(int lessonIndex) {
    final questions = _examQuestionsForLesson(_lessons[lessonIndex]);
    final submitted = _submittedCount(lessonIndex, questions.length);
    final score = _examScore(lessonIndex, questions);
    if (submitted == 0) return '未開始 · ${questions.length}問';
    if (submitted == questions.length) return '完了 · $score点';
    return '進行中 $submitted/${questions.length} · $score点';
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

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }
}

String _todayLabel() {
  final now = DateTime.now();
  final month = now.month.toString().padLeft(2, '0');
  final day = now.day.toString().padLeft(2, '0');
  return '${now.year}/$month/$day';
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
