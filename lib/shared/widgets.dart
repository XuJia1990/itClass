part of '../main.dart';

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
                label: const Text('ロール切替'),
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
                          child: Text(actionLabel ?? '新規作成'),
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
          subtitle: 'Java コードを貼り付けると、まずルールベースで採点します。後から AI/API に接続できます。',
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
              'スコア：${result.score} / 100',
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
                  'サンプルコード',
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
          title: 'テスト演習 ${index + 1} / $total',
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
                      label: const Text('回答を提出'),
                    ),
                    OutlinedButton.icon(
                      onPressed: onNext,
                      icon: const Icon(Icons.navigate_next_rounded),
                      label: const Text('次の問題'),
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
          subtitle: 'AI が回答できない、または学生が納得できない場合は先生が確認して返信します。',
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${request.student} の質問',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(request.question),
                const SizedBox(height: 12),
                Text(
                  'AI の初期回答：${request.aiAnswer}',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                if (request.teacherAnswer != null) ...[
                  const Divider(height: 26),
                  Text('先生の回答：${request.teacherAnswer}'),
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
            hintText: '学生への回答を入力してください。AI再学習資料としても保存されます。',
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
            label: const Text('学生へ回答'),
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
          subtitle: '学生の提出内容、AIスコア、先生コメントを確認します。',
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
                  Text('AIスコア：${item.score} / 100'),
                  Text('コメント：${item.feedback}'),
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
          subtitle: '平均点 ${average.toStringAsFixed(1)}。弱点の把握に利用します。',
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
            hintText: '先生の返信を入力',
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
          subtitle: '基本設定です。後からユーザー管理 API やシステム管理 API に接続できます。',
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
