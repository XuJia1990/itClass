part of '../main.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({super.key});

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  StudentSection _section = StudentSection.aiChat;
  int _selectedLesson = 0;
  int _selectedExamQuestion = 0;
  int? _selectedAnswer;
  int? _lastExamScore;
  String _selectedChatStudent = '佐藤';

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
      subtitle: '学生画面：AI質問、コード採点、AI教室、テスト演習',
      profileName: '佐藤（学生）',
      profileRole: '学生',
      activeIndex: StudentSection.values.indexOf(_section),
      items: _studentMenu,
      onSelect: (index) {
        setState(() => _section = StudentSection.values[index]);
        Navigator.of(context).maybePop();
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
          title: 'AI教室：Java基礎',
          children: [
            for (var i = 0; i < _lessons.length; i++)
              _CompactListCard(
                selected: _selectedLesson == i,
                title: _lessons[i].title,
                subtitle: _lessons[i].level,
                detail: _lessons[i].summary,
                onTap: () => setState(() => _selectedLesson = i),
              ),
          ],
        );
      case StudentSection.exam:
        return _HistoryPanel(
          title: 'テスト問題',
          actionLabel: _lastExamScore == null ? null : 'スコア $_lastExamScore',
          children: [
            for (var i = 0; i < _examQuestions.length; i++)
              _CompactListCard(
                selected: _selectedExamQuestion == i,
                title: '第 ${i + 1} 問',
                subtitle: _examQuestions[i].topic,
                detail: _examQuestions[i].question,
                onTap: () => setState(() {
                  _selectedExamQuestion = i;
                  _selectedAnswer = null;
                }),
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
      case StudentSection.settings:
        return _HistoryPanel(
          title: _section == StudentSection.codeScoring ? 'コード履歴' : '設定',
          children: [
            _CompactListCard(
              title: 'Two Sum 演習',
              subtitle: '採点済み',
              detail: 'ループ、配列、条件分岐を使う総合問題',
              onTap: () {},
            ),
            _CompactListCard(
              title: 'String 反転',
              subtitle: '未提出',
              detail: 'StringBuilder または双方向ポインタで実装',
              onTap: () {},
            ),
          ],
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
          controller: _codeInput,
          onScore: _scoreCode,
        );
      case StudentSection.learning:
        return _LessonWorkspace(lesson: _lessons[_selectedLesson]);
      case StudentSection.exam:
        return _ExamWorkspace(
          question: _examQuestions[_selectedExamQuestion],
          index: _selectedExamQuestion,
          total: _examQuestions.length,
          selectedAnswer: _selectedAnswer,
          onSelect: (value) => setState(() => _selectedAnswer = value),
          onNext: () => setState(() {
            if (_selectedExamQuestion < _examQuestions.length - 1) {
              _selectedExamQuestion++;
              _selectedAnswer = null;
            }
          }),
          onSubmit: _submitExam,
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
        return _SettingsWorkspace(
          role: '学生画面',
          rows: const [
            ('学習言語', 'Java'),
            ('AI回答スタイル', 'ヒントを先に表示'),
            ('テストモード', '演習モード'),
            ('API状態', 'バックエンド接続待ち'),
          ],
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
    var score = 60;
    final tips = <String>[];

    if (code.contains('class ')) {
      score += 8;
      tips.add('クラス定義があります。');
    } else {
      tips.add('明確な class でコードをまとめると読みやすくなります。');
    }
    if (code.contains('for') || code.contains('while')) {
      score += 8;
      tips.add('ループ構造があり、配列問題に対応できます。');
    }
    if (code.contains('Map') || code.contains('HashMap')) {
      score += 12;
      tips.add('Map を使うと検索の平均計算量を O(1) にできます。');
    }
    if (code.contains('return')) {
      score += 6;
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
      examTitle: 'Java基礎・配列とHashMap実技テスト',
      examDate: _todayLabel(),
      correctItems: const [
        'HashMap を使い、二重ループを避けられています。',
        'target - nums[i] で必要な値を計算できています。',
        '見つかった場合に添字の配列を返せています。',
        '見つからない場合の戻り値も用意されています。',
      ],
      deductions: baseDeductions,
      standardAnswer: _standardTwoSumAnswer,
      tips: tips,
    );
  }

  void _submitExam() {
    final answer = _selectedAnswer;
    if (answer == null) return;

    final current = _examQuestions[_selectedExamQuestion];
    final correct = answer == current.answerIndex;
    setState(() {
      _lastExamScore = correct ? 100 : 0;
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
