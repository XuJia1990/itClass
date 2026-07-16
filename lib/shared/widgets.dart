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
            backgroundColor: _AppPalette.canvas,
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
                Container(
                  width: 310,
                  decoration: const BoxDecoration(
                    color: _AppPalette.paper,
                    border: Border(right: BorderSide(color: _AppPalette.line)),
                  ),
                  child: middle,
                ),
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
          backgroundColor: _AppPalette.canvas,
          appBar: AppBar(
            title: Text(title),
            actions: topActions,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: _AppPalette.line),
            ),
          ),
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
                    SizedBox(width: 310, child: middle),
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
      width: compact ? null : 248,
      decoration: const BoxDecoration(
        color: Color(0xFFF0F7F5),
        border: Border(right: BorderSide(color: _AppPalette.line)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _AppPalette.ink,
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
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: _AppPalette.ink,
                          ),
                        ),
                        Text(
                          profileRole,
                          style: const TextStyle(color: _AppPalette.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _AppPalette.line),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.local_florist_rounded,
                      color: _AppPalette.teal,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '今日の学習を続けましょう',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
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
      padding: const EdgeInsets.only(bottom: 7),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(color: _AppPalette.teal.withValues(alpha: 0.20))
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: selected
                      ? item.color.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 18, color: item.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    color: selected ? _AppPalette.ink : _AppPalette.muted,
                  ),
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
      color: _AppPalette.paper,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
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
                        color: _AppPalette.ink,
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
                  padding: EdgeInsets.zero,
                  children: [
                    if (onAction != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FilledButton.icon(
                          onPressed: onAction,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(actionLabel ?? '新規作成'),
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
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected ? _AppPalette.wash : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? _AppPalette.teal.withValues(alpha: 0.28)
                : _AppPalette.line,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(13),
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
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: _AppPalette.ink,
                        ),
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
                              : _AppPalette.wash,
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
                  style: const TextStyle(color: _AppPalette.muted),
                ),
                const SizedBox(height: 6),
                Text(
                  detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.35),
                ),
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
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: _AppPalette.line)),
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
                          fontWeight: FontWeight.w900,
                          color: _AppPalette.ink,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _AppPalette.muted),
                      ),
                    ],
                  ),
                ),
                ...actions,
              ],
            ),
          ),
          Expanded(
            child: Container(color: _AppPalette.canvas, child: child),
          ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _AppPalette.washBlue,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _AppPalette.line),
        ),
        child: DropdownButton<String>(
          value: value,
          underline: const SizedBox.shrink(),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          items: [
            for (final item in values)
              DropdownMenuItem<String>(value: item, child: Text(item)),
          ],
          onChanged: onChanged,
        ),
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
            padding: const EdgeInsets.all(24),
            children: [
              _SectionHeader(
                icon: Icons.forum_rounded,
                title: title,
                subtitle: emptyHint,
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
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _AppPalette.line)),
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
              ? _AppPalette.wash
              : isTeacher
              ? _AppPalette.washBlue
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _AppPalette.line),
        ),
        child: Text(message.text, style: const TextStyle(height: 1.5)),
      ),
    );
  }
}

class _WorkspaceControlBar extends StatelessWidget {
  const _WorkspaceControlBar({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AppPalette.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune_rounded, color: _AppPalette.teal),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
          const Spacer(),
          _SubjectSelector(value: value, values: values, onChanged: onChanged),
        ],
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
  String _subject = 'Java基礎';

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _WorkspaceControlBar(
          label: '採点科目',
          value: _subject,
          values: const ['Java基礎', '配列とHashMap', 'オブジェクト指向'],
          onChanged: (value) {
            if (value != null) setState(() => _subject = value);
          },
        ),
        const SizedBox(height: 14),
        _SectionHeader(
          icon: Icons.grading_rounded,
          title: 'コード採点（テスト）',
          subtitle: '日付・科目・正しい点・減点理由・標準答案をまとめて確認できます。',
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.controller,
          minLines: 14,
          maxLines: 22,
          style: const TextStyle(fontFamily: 'monospace'),
          decoration: InputDecoration(
            filled: true,
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.examTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '受験日：${result.examDate}',
                        style: const TextStyle(color: _AppPalette.muted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _AppPalette.wash,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _AppPalette.line),
                  ),
                  child: Text(
                    '${result.score}/100',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: _AppPalette.teal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _ResultBlock(
              icon: Icons.check_circle_rounded,
              title: '正しくできている点',
              color: _AppPalette.teal,
              items: result.correctItems,
            ),
            const SizedBox(height: 14),
            _DeductionBlock(deductions: result.deductions),
            const SizedBox(height: 14),
            _ResultBlock(
              icon: Icons.tips_and_updates_rounded,
              title: '採点コメント',
              color: _AppPalette.sky,
              items: result.tips,
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _AppPalette.washBlue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _AppPalette.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '標準答案',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  SelectableText(
                    result.standardAnswer,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultBlock extends StatelessWidget {
  const _ResultBlock({
    required this.icon,
    required this.title,
    required this.color,
    required this.items,
  });

  final IconData icon;
  final String title;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(color: color)),
                  Expanded(
                    child: Text(item, style: const TextStyle(height: 1.45)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DeductionBlock extends StatelessWidget {
  const _DeductionBlock({required this.deductions});

  final List<ScoreDeduction> deductions;

  @override
  Widget build(BuildContext context) {
    final total = deductions.fold<int>(0, (sum, item) => sum + item.points);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.report_problem_rounded,
                color: Color(0xFFC2410C),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '減点：-$total点',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final item in deductions)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '-${item.points}点：${item.title}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 3),
                  Text('理由：${item.reason}'),
                  Text('改善：${item.fix}'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LessonWorkspace extends StatefulWidget {
  const _LessonWorkspace({required this.lesson});

  final Lesson lesson;

  @override
  State<_LessonWorkspace> createState() => _LessonWorkspaceState();
}

class _LessonWorkspaceState extends State<_LessonWorkspace> {
  String _subject = 'Java基礎';
  bool _showSummary = false;
  int? _selectedAnswer;
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _WorkspaceControlBar(
          label: '学習言語',
          value: _subject,
          values: const ['Java基礎', 'Java文法', 'Web API'],
          onChanged: (value) {
            if (value != null) setState(() => _subject = value);
          },
        ),
        const SizedBox(height: 14),
        _SectionHeader(
          icon: Icons.menu_book_rounded,
          title: lesson.title,
          subtitle: '${lesson.level} · ${lesson.summary}',
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(lesson.content, style: const TextStyle(height: 1.7)),
          ),
        ),
        const SizedBox(height: 16),
        for (final section in lesson.sections) ...[
          _LessonSectionCard(section: section),
          const SizedBox(height: 12),
        ],
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
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => setState(() => _showSummary = !_showSummary),
          icon: const Icon(Icons.auto_awesome_rounded),
          label: Text(_showSummary ? 'AIまとめを閉じる' : 'AIまとめ・解析'),
        ),
        if (_showSummary) ...[
          const SizedBox(height: 12),
          _AiSummaryCard(summary: lesson.aiSummary),
        ],
        const SizedBox(height: 16),
        _LessonExerciseCard(
          exercise: lesson.exercise,
          selectedAnswer: _selectedAnswer,
          submitted: _submitted,
          onSelect: (value) => setState(() {
            _selectedAnswer = value;
            _submitted = false;
          }),
          onSubmit: _selectedAnswer == null
              ? null
              : () => setState(() => _submitted = true),
        ),
      ],
    );
  }
}

class _LessonSectionCard extends StatelessWidget {
  const _LessonSectionCard({required this.section});

  final LessonSection section;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.heading,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(section.body, style: const TextStyle(height: 1.7)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final point in section.keyPoints)
                  Chip(
                    label: Text(point),
                    backgroundColor: _AppPalette.wash,
                    side: const BorderSide(color: _AppPalette.line),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AppPalette.washBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AppPalette.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: _AppPalette.sky),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AIまとめ・解析',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(summary, style: const TextStyle(height: 1.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonExerciseCard extends StatelessWidget {
  const _LessonExerciseCard({
    required this.exercise,
    required this.selectedAnswer,
    required this.submitted,
    required this.onSelect,
    required this.onSubmit,
  });

  final LessonExercise exercise;
  final int? selectedAnswer;
  final bool submitted;
  final ValueChanged<int> onSelect;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedAnswer == exercise.answerIndex;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.edit_note_rounded,
              title: '理解度チェック',
              subtitle: '選択後に、正しい点と間違いの理由を確認できます。',
            ),
            const SizedBox(height: 16),
            Text(
              exercise.question,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < exercise.options.length; i++)
              _AnswerOptionTile(
                label: exercise.options[i],
                selected: selectedAnswer == i,
                onTap: () => onSelect(i),
              ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.check_rounded),
              label: const Text('練習を採点'),
            ),
            if (submitted) ...[
              const SizedBox(height: 14),
              _ExerciseAnalysisCard(
                isCorrect: isCorrect,
                correctReason: exercise.correctReason,
                wrongReason: exercise.wrongReason,
                standardAnswer: exercise.standardAnswer,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExerciseAnalysisCard extends StatelessWidget {
  const _ExerciseAnalysisCard({
    required this.isCorrect,
    required this.correctReason,
    required this.wrongReason,
    required this.standardAnswer,
  });

  final bool isCorrect;
  final String correctReason;
  final String wrongReason;
  final String standardAnswer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect ? _AppPalette.wash : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? _AppPalette.teal : const Color(0xFFFED7AA),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                color: isCorrect ? _AppPalette.teal : const Color(0xFFC2410C),
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? '正解です' : 'もう少しです',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('正しいポイント：$correctReason'),
          if (!isCorrect) ...[
            const SizedBox(height: 6),
            Text('間違いの理由：$wrongReason'),
          ],
          const SizedBox(height: 10),
          Text(
            '標準答案：$standardAnswer',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
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
      padding: const EdgeInsets.all(24),
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
              color: selected ? const Color(0xFF10B981) : _AppPalette.line,
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
      padding: const EdgeInsets.all(24),
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
                  style: const TextStyle(color: _AppPalette.muted),
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
      padding: const EdgeInsets.all(24),
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
      padding: const EdgeInsets.all(24),
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
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(
          icon: Icons.chat_bubble_rounded,
          title: '${student.name} とチャット',
          subtitle: student.status,
        ),
        const SizedBox(height: 16),
        _MessageBubble(message: ChatMessage.student(student.lastQuestion)),
        _MessageBubble(
          message: ChatMessage.teacher('まずエラー内容を確認し、実行できる修正版を提案します。'),
        ),
        const SizedBox(height: 16),
        TextField(
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '先生の返信を入力',
            filled: true,
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
      padding: const EdgeInsets.all(24),
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
      padding: const EdgeInsets.all(24),
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
            color: _AppPalette.washBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _AppPalette.sky),
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
              Text(subtitle, style: const TextStyle(color: _AppPalette.muted)),
            ],
          ),
        ),
      ],
    );
  }
}
