import 'package:flutter/material.dart';

void main() {
  runApp(const ItClassApp());
}

enum StudentSection {
  aiChat,
  codeScoring,
  learning,
  exam,
  askTeacher,
  settings,
}

enum TeacherSection {
  pendingAi,
  codeScoring,
  examAnalysis,
  studentMessages,
  relearning,
  system,
  settings,
}

class ItClassApp extends StatelessWidget {
  const ItClassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'it教师',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0EA5E9),
          primary: const Color(0xFF0F766E),
          secondary: const Color(0xFFF59E0B),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 760;

                return Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: wide ? 5 : 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF111827),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            'it教师',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '面向 Web、iOS、Android 的 AI 编程学习平台。',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              _FeatureChip('AI解析问题'),
                              _FeatureChip('コード採点'),
                              _FeatureChip('Java学习'),
                              _FeatureChip('考试练习'),
                              _FeatureChip('师生聊天'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: wide ? 44 : 0, height: wide ? 0 : 28),
                    Expanded(
                      flex: wide ? 4 : 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RoleLoginCard(
                            title: '学生端登录',
                            subtitle: 'AI 会话、学习资料、代码採点、考试与问老师',
                            icon: Icons.person_rounded,
                            color: const Color(0xFF10B981),
                            onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => const StudentHomePage(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _RoleLoginCard(
                            title: '老师端登录',
                            subtitle: '回答学生问题、批改代码、查看考试分析',
                            icon: Icons.admin_panel_settings_rounded,
                            color: const Color(0xFF2563EB),
                            onTap: () => Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => const TeacherHomePage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      side: const BorderSide(color: Color(0xFFD1D5DB)),
      backgroundColor: Colors.white,
    );
  }
}

class _RoleLoginCard extends StatelessWidget {
  const _RoleLoginCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

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
  String _selectedChatStudent = '小刘';

  final _aiInput = TextEditingController();
  final _teacherInput = TextEditingController();
  final _codeInput = TextEditingController(text: _defaultCode);

  final List<ChatMessage> _aiMessages = [
    ChatMessage.ai('你好，我是 it教师 AI。可以问我 Java、算法、Web API 或考试题。'),
  ];

  final List<ChatMessage> _teacherMessages = [
    ChatMessage.teacher('遇到 AI 解释不清楚的问题，可以发给老师。'),
    ChatMessage.student('老师，Java 的 List 和数组什么时候用比较好？'),
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
      subtitle: '学生端：AI 问答、コード採点、Java 学习、考试练习',
      profileName: '小刘（学生）',
      profileRole: 'Student',
      activeIndex: StudentSection.values.indexOf(_section),
      items: _studentMenu,
      onSelect: (index) {
        setState(() => _section = StudentSection.values[index]);
        Navigator.of(context).maybePop();
      },
      onLogout: _logout,
      middle: _studentMiddlePanel(context),
      content: _studentContent(context),
      topActions: [
        _SubjectSelector(
          value: 'Java 基础',
          values: const ['Java 基础', '面向对象', 'Web API'],
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _studentMiddlePanel(BuildContext context) {
    switch (_section) {
      case StudentSection.aiChat:
        return _HistoryPanel(
          title: '履历',
          actionLabel: '新的话题',
          onAction: () => setState(() {
            _aiMessages
              ..clear()
              ..add(ChatMessage.ai('新的话题已创建。请直接输入你的编程问题。'));
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
          title: 'Java学习资料',
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
          title: '考试题库',
          actionLabel: _lastExamScore == null ? null : '得分 $_lastExamScore',
          children: [
            for (var i = 0; i < _examQuestions.length; i++)
              _CompactListCard(
                selected: _selectedExamQuestion == i,
                title: '第 ${i + 1} 题',
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
          title: '老师会话',
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
          title: _section == StudentSection.codeScoring ? '代码记录' : '设置',
          children: [
            _CompactListCard(
              title: 'Two Sum 练习',
              subtitle: '採点済み',
              detail: '循环、数组、条件判断综合题',
              onTap: () {},
            ),
            _CompactListCard(
              title: 'String 反转',
              subtitle: '未提交',
              detail: '使用 StringBuilder 或双指针完成',
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
          emptyHint: '试试问：HashMap 和 ArrayList 有什么区别？',
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
          title: '问老师：$_selectedChatStudent',
          emptyHint: '把 AI 没讲清楚的问题发给老师。',
          messages: _teacherMessages,
          controller: _teacherInput,
          sendLabel: '发送给老师',
          onSend: _sendTeacherMessage,
        );
      case StudentSection.settings:
        return _SettingsWorkspace(
          role: '学生端',
          rows: const [
            ('学习语言', 'Java'),
            ('AI 回答风格', '先提示，再给答案'),
            ('考试模式', '练习模式'),
            ('API 状态', '等待后端接入'),
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
      _teacherMessages.add(ChatMessage.teacher('已收到。我会结合你的代码和错误信息给你具体建议。'));
      _teacherInput.clear();
    });
  }

  ScoreResult _scoreCode() {
    final code = _codeInput.text;
    var score = 60;
    final tips = <String>[];

    if (code.contains('class ')) {
      score += 8;
      tips.add('类定义完整。');
    } else {
      tips.add('建议使用明确的 class 包装代码。');
    }
    if (code.contains('for') || code.contains('while')) {
      score += 8;
      tips.add('包含循环结构，适合处理数组题。');
    }
    if (code.contains('Map') || code.contains('HashMap')) {
      score += 12;
      tips.add('使用 Map 可以把查找复杂度降到 O(1)。');
    }
    if (code.contains('return')) {
      score += 6;
      tips.add('有明确返回值。');
    }
    if (!code.contains(';')) {
      score -= 10;
      tips.add('Java 语句通常需要分号，注意语法完整性。');
    }

    return ScoreResult(score.clamp(0, 100), tips);
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
              ? '回答正确：${current.explanation}'
              : '还差一点：${current.explanation}',
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

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  TeacherSection _section = TeacherSection.pendingAi;
  int _selectedRequest = 0;
  int _selectedStudent = 0;
  final _replyInput = TextEditingController();

  final List<TeacherRequest> _requests = List.of(_teacherRequests);

  @override
  void dispose() {
    _replyInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ResponsiveShell(
      title: _teacherTitle(_section),
      subtitle: '老师端：回答问题、查看代码採点、分析考试结果',
      profileName: 'Admin（先生）',
      profileRole: 'Teacher',
      activeIndex: TeacherSection.values.indexOf(_section),
      items: _teacherMenu,
      onSelect: (index) {
        setState(() => _section = TeacherSection.values[index]);
        Navigator.of(context).maybePop();
      },
      onLogout: _logout,
      middle: _teacherMiddlePanel(),
      content: _teacherContent(),
      topActions: [
        _SubjectSelector(
          value: '汎用プログラミング',
          values: const ['汎用プログラミング', 'Java', 'Web API'],
          onChanged: (_) {},
        ),
      ],
    );
  }

  Widget _teacherMiddlePanel() {
    switch (_section) {
      case TeacherSection.pendingAi:
        return _HistoryPanel(
          title: 'AI会話未回答',
          actionLabel: '${_requests.where((e) => !e.answered).length}件',
          children: [
            for (var i = 0; i < _requests.length; i++)
              _CompactListCard(
                selected: _selectedRequest == i,
                title: _requests[i].student,
                subtitle: _requests[i].category,
                detail: _requests[i].question,
                badge: _requests[i].answered ? '回答済み' : '未回答',
                onTap: () => setState(() => _selectedRequest = i),
              ),
          ],
        );
      case TeacherSection.studentMessages:
        return _HistoryPanel(
          title: '学生',
          children: [
            for (var i = 0; i < _students.length; i++)
              _CompactListCard(
                selected: _selectedStudent == i,
                title: _students[i].name,
                subtitle: _students[i].status,
                detail: _students[i].lastQuestion,
                onTap: () => setState(() => _selectedStudent = i),
              ),
          ],
        );
      case TeacherSection.examAnalysis:
        return _HistoryPanel(
          title: 'テスト解答分析',
          children: [
            for (final report in _examReports)
              _CompactListCard(
                title: report.student,
                subtitle: '${report.score}点',
                detail: report.weakness,
                onTap: () {},
              ),
          ],
        );
      case TeacherSection.codeScoring:
      case TeacherSection.relearning:
      case TeacherSection.system:
      case TeacherSection.settings:
        return _HistoryPanel(
          title: '管理メニュー',
          children: [
            _CompactListCard(
              title: '採点待ちコード',
              subtitle: '6件',
              detail: '配列、Map、例外処理の課題',
              onTap: () {},
            ),
            _CompactListCard(
              title: 'AI再学習データ',
              subtitle: '12件',
              detail: '先生回答を今後の AI 回答に反映予定',
              onTap: () {},
            ),
          ],
        );
    }
  }

  Widget _teacherContent() {
    switch (_section) {
      case TeacherSection.pendingAi:
        return _TeacherRequestWorkspace(
          request: _requests[_selectedRequest],
          controller: _replyInput,
          onSubmit: _answerRequest,
        );
      case TeacherSection.codeScoring:
        return _TeacherCodeReviewWorkspace(requests: _codeReviewItems);
      case TeacherSection.examAnalysis:
        return _ExamAnalysisWorkspace(reports: _examReports);
      case TeacherSection.studentMessages:
        return _TeacherChatWorkspace(student: _students[_selectedStudent]);
      case TeacherSection.relearning:
        return const _SimpleWorkspace(
          icon: Icons.auto_awesome_rounded,
          title: 'AI再学習',
          body: '老师回答过的问题会整理成训练资料。后端 API 接入后，可把高质量回答上传到知识库。',
        );
      case TeacherSection.system:
        return const _SettingsWorkspace(
          role: '系统管理',
          rows: [
            ('题库来源', 'Mock 数据，等待 API'),
            ('用户管理', '学生与老师角色'),
            ('审核流程', 'AI 无法回答时转人工'),
            ('平台', 'Web / iOS / Android'),
          ],
        );
      case TeacherSection.settings:
        return const _SettingsWorkspace(
          role: '老师端设置',
          rows: [
            ('通知', '未回答问题提醒'),
            ('默认科目', '汎用プログラミング'),
            ('语言', '中文 / 日本語'),
            ('主题', 'Light'),
          ],
        );
    }
  }

  void _answerRequest() {
    final text = _replyInput.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _requests[_selectedRequest] = _requests[_selectedRequest].copyWith(
        answered: true,
        teacherAnswer: text,
      );
      _replyInput.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已发送给学生，并保存为 AI 再学习资料。')));
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }
}

class _ResponsiveShell extends StatelessWidget {
  const _ResponsiveShell({
    required this.title,
    required this.subtitle,
    required this.profileName,
    required this.profileRole,
    required this.items,
    required this.activeIndex,
    required this.onSelect,
    required this.onLogout,
    required this.middle,
    required this.content,
    required this.topActions,
  });

  final String title;
  final String subtitle;
  final String profileName;
  final String profileRole;
  final List<MenuItem> items;
  final int activeIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final Widget middle;
  final Widget content;
  final List<Widget> topActions;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 980;
        final tablet = constraints.maxWidth >= 720 && !desktop;

        if (desktop) {
          return Scaffold(
            body: Row(
              children: [
                _SideMenu(
                  profileName: profileName,
                  profileRole: profileRole,
                  items: items,
                  activeIndex: activeIndex,
                  onSelect: onSelect,
                  onLogout: onLogout,
                ),
                SizedBox(width: 300, child: middle),
                Expanded(
                  child: _ContentFrame(
                    title: title,
                    subtitle: subtitle,
                    actions: topActions,
                    child: content,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(title), actions: topActions),
          drawer: Drawer(
            child: _SideMenu(
              profileName: profileName,
              profileRole: profileRole,
              items: items,
              activeIndex: activeIndex,
              onSelect: onSelect,
              onLogout: onLogout,
              compact: true,
            ),
          ),
          body: tablet
              ? Row(
                  children: [
                    SizedBox(width: 300, child: middle),
                    Expanded(child: content),
                  ],
                )
              : content,
        );
      },
    );
  }
}

class _SideMenu extends StatelessWidget {
  const _SideMenu({
    required this.profileName,
    required this.profileRole,
    required this.items,
    required this.activeIndex,
    required this.onSelect,
    required this.onLogout,
    this.compact = false,
  });

  final String profileName;
  final String profileRole;
  final List<MenuItem> items;
  final int activeIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? null : 250,
      color: const Color(0xFFD7ECFF),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          profileRole,
                          style: const TextStyle(color: Color(0xFF475569)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              for (var i = 0; i < items.length; i++)
                _MenuTile(
                  item: items[i],
                  selected: activeIndex == i,
                  onTap: () => onSelect(i),
                ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('ログアウト'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(builder: (_) => const LoginPage()),
                ),
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('身份切换'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final MenuItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFBFEAD9) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF10B981).withValues(alpha: 0.14),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 20, color: item.color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({
    required this.title,
    required this.children,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (actionLabel != null)
                    TextButton(onPressed: onAction, child: Text(actionLabel!)),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    if (onAction != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FilledButton(
                          onPressed: onAction,
                          child: Text(actionLabel ?? '新建'),
                        ),
                      ),
                    ...children,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactListCard extends StatelessWidget {
  const _CompactListCard({
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.onTap,
    this.selected = false,
    this.trailing,
    this.badge,
  });

  final String title;
  final String subtitle;
  final String detail;
  final VoidCallback onTap;
  final bool selected;
  final String? trailing;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        color: selected ? const Color(0xFFEFFAF5) : Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badge == '未回答'
                              ? const Color(0xFFFFF7ED)
                              : const Color(0xFFEFFAF5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            color: badge == '未回答'
                                ? const Color(0xFFC2410C)
                                : const Color(0xFF047857),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (trailing != null)
                      Text(
                        trailing!,
                        style: const TextStyle(
                          color: Color(0xFF0EA5E9),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 6),
                Text(detail, maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentFrame extends StatelessWidget {
  const _ContentFrame({
    required this.title,
    required this.subtitle,
    required this.actions,
    required this.child,
  });

  final String title;
  final String subtitle;
  final List<Widget> actions;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFF3F6FE),
              border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                ...actions,
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SubjectSelector extends StatelessWidget {
  const _SubjectSelector({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        items: [
          for (final item in values)
            DropdownMenuItem<String>(value: item, child: Text(item)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}

class _ChatWorkspace extends StatelessWidget {
  const _ChatWorkspace({
    required this.title,
    required this.emptyHint,
    required this.messages,
    required this.controller,
    required this.sendLabel,
    required this.onSend,
  });

  final String title;
  final String emptyHint;
  final List<ChatMessage> messages;
  final TextEditingController controller;
  final String sendLabel;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              if (messages.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 120),
                    child: Text(emptyHint, textAlign: TextAlign.center),
                  ),
                )
              else
                for (final message in messages)
                  _MessageBubble(message: message),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'あなたのプログラミングに関する質問を入力してください。',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onSubmitted: (_) => onSend(),
                ),
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: onSend,
                icon: const Icon(Icons.send_rounded),
                label: Text(sendLabel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isStudent = message.author == MessageAuthor.student;
    final isTeacher = message.author == MessageAuthor.teacher;

    return Align(
      alignment: isStudent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isStudent
              ? const Color(0xFFDCFCE7)
              : isTeacher
              ? const Color(0xFFE0F2FE)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(message.text),
      ),
    );
  }
}

class _CodeScoringWorkspace extends StatefulWidget {
  const _CodeScoringWorkspace({
    required this.controller,
    required this.onScore,
  });

  final TextEditingController controller;
  final ScoreResult Function() onScore;

  @override
  State<_CodeScoringWorkspace> createState() => _CodeScoringWorkspaceState();
}

class _CodeScoringWorkspaceState extends State<_CodeScoringWorkspace> {
  ScoreResult? _result;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(
          icon: Icons.grading_rounded,
          title: 'コード採点',
          subtitle: '粘贴 Java 代码，系统会先做规则评分，后续可接 AI/API。',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.controller,
          minLines: 14,
          maxLines: 22,
          style: const TextStyle(fontFamily: 'monospace'),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () => setState(() => _result = widget.onScore()),
            icon: const Icon(Icons.fact_check_rounded),
            label: const Text('採点する'),
          ),
        ),
        if (_result != null) ...[
          const SizedBox(height: 18),
          _ScoreCard(result: _result!),
        ],
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({required this.result});

  final ScoreResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '评分：${result.score} / 100',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            for (final tip in result.tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(tip)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LessonWorkspace extends StatelessWidget {
  const _LessonWorkspace({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(
          icon: Icons.menu_book_rounded,
          title: lesson.title,
          subtitle: '${lesson.level} · ${lesson.summary}',
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(lesson.content),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '示例代码',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  lesson.code,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExamWorkspace extends StatelessWidget {
  const _ExamWorkspace({
    required this.question,
    required this.index,
    required this.total,
    required this.selectedAnswer,
    required this.onSelect,
    required this.onNext,
    required this.onSubmit,
  });

  final ExamQuestion question;
  final int index;
  final int total;
  final int? selectedAnswer;
  final ValueChanged<int> onSelect;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(
          icon: Icons.quiz_rounded,
          title: '考试练习 ${index + 1} / $total',
          subtitle: question.topic,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  question.question,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < question.options.length; i++)
                  _AnswerOptionTile(
                    label: question.options[i],
                    selected: selectedAnswer == i,
                    onTap: () => onSelect(i),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: selectedAnswer == null ? null : onSubmit,
                      icon: const Icon(Icons.check_rounded),
                      label: const Text('提交答案'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onNext,
                      icon: const Icon(Icons.navigate_next_rounded),
                      label: const Text('下一题'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnswerOptionTile extends StatelessWidget {
  const _AnswerOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEFFAF5) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: selected
                  ? const Color(0xFF10B981)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(
                selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: selected
                    ? const Color(0xFF047857)
                    : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(label)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherRequestWorkspace extends StatelessWidget {
  const _TeacherRequestWorkspace({
    required this.request,
    required this.controller,
    required this.onSubmit,
  });

  final TeacherRequest request;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(
          icon: Icons.support_agent_rounded,
          title: 'AI回答不能（先生対応）',
          subtitle: 'AI 无法回答或学生不满意时，由老师确认并回复。',
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${request.student} 的问题',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(request.question),
                const SizedBox(height: 12),
                Text(
                  'AI 初步回答：${request.aiAnswer}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                if (request.teacherAnswer != null) ...[
                  const Divider(height: 26),
                  Text('老师已回答：${request.teacherAnswer}'),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          minLines: 5,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: '请输入给学生的回答，也会保存为 AI 再学习资料。',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: onSubmit,
            icon: const Icon(Icons.send_rounded),
            label: const Text('回答学生'),
          ),
        ),
      ],
    );
  }
}

class _TeacherCodeReviewWorkspace extends StatelessWidget {
  const _TeacherCodeReviewWorkspace({required this.requests});

  final List<CodeReviewItem> requests;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const _SectionHeader(
          icon: Icons.rate_review_rounded,
          title: 'コード採点管理',
          subtitle: '查看学生提交、AI 评分和老师建议。',
        ),
        const SizedBox(height: 16),
        for (final item in requests)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.student} · ${item.title}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text('AI评分：${item.score} / 100'),
                  Text('建议：${item.feedback}'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ExamAnalysisWorkspace extends StatelessWidget {
  const _ExamAnalysisWorkspace({required this.reports});

  final List<ExamReport> reports;

  @override
  Widget build(BuildContext context) {
    final average =
        reports.fold<int>(0, (sum, item) => sum + item.score) / reports.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(
          icon: Icons.bar_chart_rounded,
          title: 'テスト解答分析',
          subtitle: '平均分 ${average.toStringAsFixed(1)}，用于定位薄弱知识点。',
        ),
        const SizedBox(height: 16),
        for (final report in reports)
          Card(
            child: ListTile(
              leading: CircleAvatar(child: Text('${report.score}')),
              title: Text(report.student),
              subtitle: Text(report.weakness),
              trailing: Text(report.recommendation),
            ),
          ),
      ],
    );
  }
}

class _TeacherChatWorkspace extends StatelessWidget {
  const _TeacherChatWorkspace({required this.student});

  final StudentProfile student;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(
          icon: Icons.chat_bubble_rounded,
          title: '与 ${student.name} 聊天',
          subtitle: student.status,
        ),
        const SizedBox(height: 16),
        _MessageBubble(message: ChatMessage.student(student.lastQuestion)),
        _MessageBubble(
          message: ChatMessage.teacher('我先看你的错误信息，再给你一个可执行的修改版本。'),
        ),
        const SizedBox(height: 16),
        TextField(
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '输入老师回复',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }
}

class _SettingsWorkspace extends StatelessWidget {
  const _SettingsWorkspace({required this.role, required this.rows});

  final String role;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(
          icon: Icons.settings_rounded,
          title: role,
          subtitle: '基础配置，后续可接用户中心和系统管理 API。',
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              for (final row in rows)
                ListTile(title: Text(row.$1), trailing: Text(row.$2)),
            ],
          ),
        ),
      ],
    );
  }
}

class _SimpleWorkspace extends StatelessWidget {
  const _SimpleWorkspace({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [_SectionHeader(icon: icon, title: title, subtitle: body)],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF0369A1)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: Color(0xFF64748B))),
            ],
          ),
        ),
      ],
    );
  }
}

class MenuItem {
  const MenuItem(this.icon, this.label, this.color);

  final IconData icon;
  final String label;
  final Color color;
}

class ChatMessage {
  const ChatMessage(this.author, this.text);

  factory ChatMessage.student(String text) {
    return ChatMessage(MessageAuthor.student, text);
  }

  factory ChatMessage.ai(String text) {
    return ChatMessage(MessageAuthor.ai, text);
  }

  factory ChatMessage.teacher(String text) {
    return ChatMessage(MessageAuthor.teacher, text);
  }

  final MessageAuthor author;
  final String text;
}

enum MessageAuthor { student, ai, teacher }

class Topic {
  const Topic(this.title, this.category, this.question, this.answer);

  final String title;
  final String category;
  final String question;
  final String answer;
}

class Lesson {
  const Lesson({
    required this.title,
    required this.level,
    required this.summary,
    required this.content,
    required this.code,
  });

  final String title;
  final String level;
  final String summary;
  final String content;
  final String code;
}

class ExamQuestion {
  const ExamQuestion({
    required this.topic,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  final String topic;
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;
}

class ScoreResult {
  const ScoreResult(this.score, this.tips);

  final int score;
  final List<String> tips;
}

class TeacherRequest {
  const TeacherRequest({
    required this.student,
    required this.category,
    required this.question,
    required this.aiAnswer,
    this.answered = false,
    this.teacherAnswer,
  });

  final String student;
  final String category;
  final String question;
  final String aiAnswer;
  final bool answered;
  final String? teacherAnswer;

  TeacherRequest copyWith({bool? answered, String? teacherAnswer}) {
    return TeacherRequest(
      student: student,
      category: category,
      question: question,
      aiAnswer: aiAnswer,
      answered: answered ?? this.answered,
      teacherAnswer: teacherAnswer ?? this.teacherAnswer,
    );
  }
}

class StudentProfile {
  const StudentProfile(this.name, this.status, this.lastQuestion);

  final String name;
  final String status;
  final String lastQuestion;
}

class ExamReport {
  const ExamReport(
    this.student,
    this.score,
    this.weakness,
    this.recommendation,
  );

  final String student;
  final int score;
  final String weakness;
  final String recommendation;
}

class CodeReviewItem {
  const CodeReviewItem(this.student, this.title, this.score, this.feedback);

  final String student;
  final String title;
  final int score;
  final String feedback;
}

const _studentMenu = [
  MenuItem(Icons.forum_rounded, 'AI会話', Color(0xFF38BDF8)),
  MenuItem(Icons.grading_rounded, 'コード採点', Color(0xFF84CC16)),
  MenuItem(Icons.menu_book_rounded, 'AI学习', Color(0xFFF59E0B)),
  MenuItem(Icons.quiz_rounded, '考试', Color(0xFFEF4444)),
  MenuItem(Icons.support_agent_rounded, 'AI回答不能（先生対応）', Color(0xFFF97316)),
  MenuItem(Icons.settings_rounded, '設定', Color(0xFF475569)),
];

const _teacherMenu = [
  MenuItem(Icons.mark_chat_unread_rounded, 'AI回答不能（先生対応）', Color(0xFFF97316)),
  MenuItem(Icons.grading_rounded, 'コード採点', Color(0xFF84CC16)),
  MenuItem(Icons.analytics_rounded, 'テスト解答分析', Color(0xFFEF4444)),
  MenuItem(Icons.chat_rounded, '学生聊天', Color(0xFF38BDF8)),
  MenuItem(Icons.auto_awesome_rounded, 'AI再学習', Color(0xFF8B5CF6)),
  MenuItem(Icons.admin_panel_settings_rounded, 'システム管理', Color(0xFF22C55E)),
  MenuItem(Icons.settings_rounded, '設定', Color(0xFF475569)),
];

const _students = [
  StudentProfile('中村', '生徒 · 在线', 'GET 和 POST 方法的主要区别是什么？'),
  StudentProfile('小刘', '生徒 · 提交代码', '为什么 HashMap 查找会更快？'),
  StudentProfile('xiaowang', '生徒 · 考试中', '接口和抽象类怎么选择？'),
  StudentProfile('takahashi', '生徒 · 等待回答', 'NullPointerException 怎么排查？'),
  StudentProfile('kumagai', '生徒 · 复习中', 'final 关键字用在哪里？'),
  StudentProfile('yamada', '生徒 · 离线', 'Java Stream 和 for 循环哪个好？'),
];

const _studentTopics = [
  Topic(
    'GETとPOSTメソッドの...',
    'プログラミング',
    'GETとPOSTメソッドの主な違いは何ですか？',
    'GET 常用于读取资源，参数会出现在 URL；POST 常用于提交数据，参数放在请求体中。重要区别是语义、缓存、长度限制和安全表现。',
  ),
  Topic(
    'アジャイル開発とはどの...',
    'プログラミング',
    'アジャイル開発はどのようなものですか？',
    '敏捷开发强调小步迭代、持续反馈和快速交付。团队会把需求拆成短周期任务，每次交付可运行的软件。',
  ),
  Topic(
    '基本設計書に何の内...',
    'プログラミング',
    '基本設計書に何の内容が記載されますか？',
    '基本设计书通常包含系统结构、功能列表、画面设计、数据结构、外部接口、权限和异常处理等内容。',
  ),
  Topic(
    'AJAXのデバッグにはど...',
    'プログラミング',
    'AJAXのデバッグにはどのようなツールを使うか？',
    '浏览器 DevTools 的 Network 面板最常用，可以查看请求 URL、Header、Payload、Response 和状态码。',
  ),
];

const _lessons = [
  Lesson(
    title: 'Java 变量与数据类型',
    level: '入门',
    summary: '理解 int、double、boolean、String 的使用。',
    content:
        '变量是程序中保存数据的名字。Java 是强类型语言，声明变量时需要指定类型。常见基础类型包括 int、long、double、boolean，字符串使用 String 类。',
    code:
        'int age = 18;\ndouble price = 29.9;\nboolean passed = true;\nString name = "Eden";',
  ),
  Lesson(
    title: 'if 与 switch 条件判断',
    level: '入门',
    summary: '根据不同条件执行不同代码。',
    content: 'if 适合范围判断和复杂条件，switch 适合对固定值做分支处理。写条件时要注意 == 与 equals 的区别。',
    code:
        'String level = "A";\nif ("A".equals(level)) {\n  System.out.println("优秀");\n}',
  ),
  Lesson(
    title: 'for 与 while 循环',
    level: '入门',
    summary: '重复执行一段逻辑。',
    content: 'for 循环适合次数明确的场景，while 适合根据条件持续执行的场景。循环里通常要注意边界、跳出条件和性能。',
    code: 'for (int i = 0; i < 5; i++) {\n  System.out.println(i);\n}',
  ),
  Lesson(
    title: '数组与 ArrayList',
    level: '基础',
    summary: '保存一组同类型数据。',
    content:
        '数组长度固定，访问速度快；ArrayList 长度可变，常用于业务列表。数组用 length，ArrayList 用 size()。',
    code:
        'List<String> names = new ArrayList<>();\nnames.add("小刘");\nSystem.out.println(names.size());',
  ),
  Lesson(
    title: 'HashMap 的键值对',
    level: '基础',
    summary: '通过 key 快速查找 value。',
    content: 'HashMap 用键值对保存数据，适合通过唯一 key 快速查找。常见操作包括 put、get、containsKey。',
    code:
        'Map<String, Integer> scores = new HashMap<>();\nscores.put("Java", 90);\nSystem.out.println(scores.get("Java"));',
  ),
  Lesson(
    title: '类与对象',
    level: '基础',
    summary: '把数据和行为封装在一起。',
    content: '类是模板，对象是具体实例。字段保存状态，方法描述行为。面向对象代码更容易维护和扩展。',
    code:
        'class Student {\n  String name;\n  void study() {\n    System.out.println(name + " studying");\n  }\n}',
  ),
  Lesson(
    title: '继承与接口',
    level: '进阶',
    summary: '复用代码与定义能力。',
    content: '继承用于表达 is-a 关系，接口用于定义能力和规范。Java 类只能单继承，但可以实现多个接口。',
    code:
        'interface RunnableTask {\n  void run();\n}\nclass Job implements RunnableTask {\n  public void run() {}\n}',
  ),
  Lesson(
    title: '异常处理',
    level: '进阶',
    summary: '处理程序运行时的错误。',
    content: 'try-catch 可以捕获异常并给出处理逻辑。不要吞掉异常，至少记录错误信息或返回明确提示。',
    code:
        'try {\n  int value = Integer.parseInt("12");\n} catch (NumberFormatException e) {\n  System.out.println("格式错误");\n}',
  ),
  Lesson(
    title: 'Java Stream',
    level: '进阶',
    summary: '声明式处理集合数据。',
    content: 'Stream 适合过滤、映射、聚合等集合操作。可读性好，但复杂逻辑不一定比普通循环更清楚。',
    code:
        'List<Integer> nums = List.of(1, 2, 3);\nint sum = nums.stream().mapToInt(Integer::intValue).sum();',
  ),
  Lesson(
    title: 'REST API 基础',
    level: '应用',
    summary: '理解接口请求和响应。',
    content:
        'REST API 通常通过 HTTP 方法表达动作，通过 JSON 传输数据。常见状态码有 200、201、400、401、404、500。',
    code: 'GET /api/questions\nPOST /api/exams\nContent-Type: application/json',
  ),
];

const _examQuestions = [
  ExamQuestion(
    topic: 'Java 基础',
    question: 'Java 中用于表示字符串的类型是？',
    options: ['char', 'String', 'boolean', 'double'],
    answerIndex: 1,
    explanation: 'String 是 Java 中表示字符串的类。',
  ),
  ExamQuestion(
    topic: '集合',
    question: 'ArrayList 获取元素个数的方法是？',
    options: ['length', 'size()', 'count()', 'total()'],
    answerIndex: 1,
    explanation: '集合使用 size()，数组使用 length。',
  ),
  ExamQuestion(
    topic: 'Map',
    question: 'HashMap 中判断 key 是否存在的方法是？',
    options: ['hasKey', 'containsKey', 'includeKey', 'findKey'],
    answerIndex: 1,
    explanation: 'containsKey 可以判断指定 key 是否存在。',
  ),
  ExamQuestion(
    topic: '控制流程',
    question: 'for 循环中 i < arr.length 的主要作用是？',
    options: ['避免越界', '创建数组', '排序', '转换类型'],
    answerIndex: 0,
    explanation: '数组下标从 0 开始，i < length 可以避免越界。',
  ),
  ExamQuestion(
    topic: '面向对象',
    question: 'Java 类的实例通常叫做？',
    options: ['方法', '包', '对象', '接口'],
    answerIndex: 2,
    explanation: '对象是类创建出来的具体实例。',
  ),
  ExamQuestion(
    topic: '接口',
    question: '一个类实现接口使用哪个关键字？',
    options: ['extends', 'implements', 'interface', 'package'],
    answerIndex: 1,
    explanation: 'implements 用于实现接口。',
  ),
  ExamQuestion(
    topic: '异常',
    question: '捕获异常通常使用哪个结构？',
    options: ['if-else', 'try-catch', 'switch', 'for'],
    answerIndex: 1,
    explanation: 'try-catch 用于捕获并处理异常。',
  ),
  ExamQuestion(
    topic: 'HTTP',
    question: '通常用于读取资源的 HTTP 方法是？',
    options: ['GET', 'POST', 'DELETE', 'PATCH'],
    answerIndex: 0,
    explanation: 'GET 语义上用于读取资源。',
  ),
  ExamQuestion(
    topic: 'HTTP',
    question: '404 状态码通常表示？',
    options: ['成功', '未授权', '资源不存在', '服务器内部错误'],
    answerIndex: 2,
    explanation: '404 表示客户端请求的资源不存在。',
  ),
  ExamQuestion(
    topic: '算法',
    question: 'HashMap 常见查找平均时间复杂度是？',
    options: ['O(1)', 'O(n)', 'O(log n)', 'O(n²)'],
    answerIndex: 0,
    explanation: 'HashMap 平均情况下可以做到常数时间查找。',
  ),
  ExamQuestion(
    topic: 'Java 基础',
    question: '比较字符串内容更推荐使用？',
    options: ['==', 'equals', '!=', 'compareAddress'],
    answerIndex: 1,
    explanation: 'equals 比较字符串内容，== 比较引用地址。',
  ),
  ExamQuestion(
    topic: '关键字',
    question: 'final 修饰变量后通常表示？',
    options: ['可随意修改', '只能赋值一次', '自动排序', '转换为字符串'],
    answerIndex: 1,
    explanation: 'final 变量赋值后不能再次改变引用或基础值。',
  ),
];

const _teacherRequests = [
  TeacherRequest(
    student: '中村',
    category: 'AI会話',
    question: 'GET 和 POST 除了参数位置不同，还有什么设计区别？',
    aiAnswer: 'GET 用 URL，POST 用 body。',
  ),
  TeacherRequest(
    student: '小刘',
    category: '代码採点',
    question: 'Two Sum 用两层 for 可以过吗，为什么老师建议 HashMap？',
    aiAnswer: 'HashMap 更快。',
  ),
  TeacherRequest(
    student: 'takahashi',
    category: '异常处理',
    question: 'NullPointerException 一般怎么一步步排查？',
    aiAnswer: '检查空对象。',
  ),
  TeacherRequest(
    student: 'xiaowang',
    category: '考试',
    question: '接口和抽象类都能定义方法，区别到底是什么？',
    aiAnswer: '接口更抽象。',
    answered: true,
    teacherAnswer: '接口偏能力规范，抽象类偏共同父类和复用状态。',
  ),
];

const _examReports = [
  ExamReport('中村', 82, 'HTTP 方法和状态码还需加强', '复习 REST API'),
  ExamReport('小刘', 76, '集合与 Map 的复杂度理解不稳', '练习 HashMap 题'),
  ExamReport('xiaowang', 91, '面向对象掌握较好', '进入接口设计'),
  ExamReport('takahashi', 68, '异常处理题错误较多', '复习 try-catch'),
  ExamReport('kumagai', 88, '基础语法稳定', '开始 Stream'),
];

const _codeReviewItems = [
  CodeReviewItem('小刘', 'Two Sum', 84, '可以通过，建议说明时间复杂度。'),
  CodeReviewItem('中村', '字符串反转', 72, '注意边界条件和空字符串。'),
  CodeReviewItem('takahashi', '学生成绩统计', 65, '方法拆分还不够清晰。'),
];

const _defaultCode = '''
import java.util.*;

class Solution {
  public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> seen = new HashMap<>();
    for (int i = 0; i < nums.length; i++) {
      int need = target - nums[i];
      if (seen.containsKey(need)) {
        return new int[] { seen.get(need), i };
      }
      seen.put(nums[i], i);
    }
    return new int[] {};
  }
}
''';

String _teacherTitle(TeacherSection section) {
  switch (section) {
    case TeacherSection.pendingAi:
      return 'AI回答不能（先生対応）';
    case TeacherSection.codeScoring:
      return 'コード採点';
    case TeacherSection.examAnalysis:
      return 'テスト解答分析';
    case TeacherSection.studentMessages:
      return '学生聊天';
    case TeacherSection.relearning:
      return 'AI再学習';
    case TeacherSection.system:
      return 'システム管理';
    case TeacherSection.settings:
      return '設定';
  }
}

String _mockAiAnswer(String text) {
  final lower = text.toLowerCase();
  if (lower.contains('hashmap') || text.contains('Map')) {
    return 'HashMap 用 key-value 存储数据，平均查找复杂度是 O(1)。比如 Two Sum 里，每次把数字和下标放入 Map，就不用再用第二层循环查找。';
  }
  if (text.contains('GET') || text.contains('POST') || lower.contains('post')) {
    return 'GET 适合读取数据，参数通常在 URL 中；POST 适合提交或创建数据，参数放在请求体。实际开发还要看幂等性、缓存、日志安全和接口语义。';
  }
  if (text.contains('接口') || text.contains('抽象')) {
    return '接口用于定义能力，例如 Comparable；抽象类用于表达共同父类，可以保存字段和复用部分实现。Java 类可以实现多个接口，但只能继承一个类。';
  }
  return '我先给你一个学习路径：1. 明确输入输出；2. 写一个最小示例；3. 分析边界情况；4. 再看时间复杂度。这个问题如果你愿意，也可以转给老师人工确认。';
}
