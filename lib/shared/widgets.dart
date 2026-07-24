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
              onSelect: (index) {
                onSelect(index);
                Navigator.of(context).pop();
              },
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
    required this.assignment,
    required this.controller,
    required this.onScore,
  });

  final CodeAssignment assignment;
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
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(
          icon: Icons.grading_rounded,
          title: 'コード課題：${widget.assignment.title}',
          subtitle: 'コードを書いて提出し、自動採点・減点理由・標準答案を確認します。',
        ),
        const SizedBox(height: 16),
        _CodeAssignmentBrief(assignment: widget.assignment),
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
            label: const Text('コードを提出して採点'),
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

class _CodeAssignmentBrief extends StatelessWidget {
  const _CodeAssignmentBrief({required this.assignment});

  final CodeAssignment assignment;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                _StatusPill(assignment.level),
                _StatusPill(assignment.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(assignment.prompt, style: const TextStyle(height: 1.55)),
            const SizedBox(height: 14),
            const Text('提出条件', style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            for (final requirement in assignment.requirements)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 18,
                      color: _AppPalette.teal,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(requirement)),
                  ],
                ),
              ),
          ],
        ),
      ),
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

class _LearningWorkspace extends StatefulWidget {
  const _LearningWorkspace({
    required this.lesson,
    required this.videos,
    required this.videoProgress,
    required this.onVideoProgressChanged,
    required this.mode,
  });

  final Lesson lesson;
  final List<LearningVideo> videos;
  final List<double> videoProgress;
  final void Function(int index, double progress) onVideoProgressChanged;
  final LearningMode mode;

  @override
  State<_LearningWorkspace> createState() => _LearningWorkspaceState();
}

class _LearningWorkspaceState extends State<_LearningWorkspace> {
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
        if (widget.mode == LearningMode.video)
          _VideoLearningWorkspace(
            videos: widget.videos,
            progress: widget.videoProgress,
            onProgressChanged: widget.onVideoProgressChanged,
          )
        else if (widget.mode == LearningMode.questionBank)
          _QuestionBankOutlineWorkspace(lesson: lesson)
        else ...[
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
          const SizedBox(height: 12),
          _PracticeQuestionSet(
            title: '追加練習',
            subtitle: '各単元の題目後に 1〜2 道の確認問題を追加しています。',
            questions: _practiceQuestionsForLesson(lesson),
          ),
        ],
      ],
    );
  }
}

class _VideoLearningWorkspace extends StatelessWidget {
  const _VideoLearningWorkspace({
    required this.videos,
    required this.progress,
    required this.onProgressChanged,
  });

  final List<LearningVideo> videos;
  final List<double> progress;
  final void Function(int index, double progress) onProgressChanged;

  @override
  Widget build(BuildContext context) {
    final average = videos.isEmpty
        ? 0.0
        : progress.reduce((value, element) => value + element) / videos.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: Icons.play_circle_rounded,
          title: '動画学習',
          subtitle: '先生が録画しアップロードした授業動画を視聴できます。',
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '視聴すべき動画の進捗',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Text(
                      '${(average * 100).round()}%',
                      style: const TextStyle(
                        color: _AppPalette.teal,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(value: average),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        for (var i = 0; i < videos.length; i++)
          _VideoProgressCard(
            video: videos[i],
            progress: progress[i],
            onMarkWatched: () => onProgressChanged(i, 1.0),
          ),
      ],
    );
  }
}

class _VideoProgressCard extends StatefulWidget {
  const _VideoProgressCard({
    required this.video,
    required this.progress,
    required this.onMarkWatched,
  });

  final LearningVideo video;
  final double progress;
  final VoidCallback onMarkWatched;

  @override
  State<_VideoProgressCard> createState() => _VideoProgressCardState();
}

class _VideoProgressCardState extends State<_VideoProgressCard> {
  VideoPlayerController? _controller;
  bool _showPlayer = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final percent = (widget.progress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _AppPalette.washBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: _AppPalette.sky,
                    size: 34,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${video.category} · ${video.duration}',
                        style: const TextStyle(color: _AppPalette.muted),
                      ),
                      const SizedBox(height: 8),
                      Text(video.description),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(value: widget.progress),
                ),
                const SizedBox(width: 12),
                Text(
                  '$percent%',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_showPlayer) ...[
              _videoPlayerArea(),
              const SizedBox(height: 12),
            ],
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: _togglePlayer,
                  icon: const Icon(Icons.play_circle_rounded),
                  label: Text(
                    _showPlayer
                        ? 'プレイヤーを閉じる'
                        : widget.progress == 0
                        ? '視聴開始'
                        : '続きを見る',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: widget.progress >= 1.0
                      ? null
                      : widget.onMarkWatched,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(widget.progress >= 1.0 ? '視聴済み' : '視聴済みにする'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _PracticeQuestionSet(
              title: '動画確認問題',
              subtitle: '動画を見たあと、1〜2 道の確認問題で理解をチェックします。',
              questions: _practiceQuestionsForVideo(video),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePlayer() async {
    if (_showPlayer) {
      await _controller?.pause();
      setState(() => _showPlayer = false);
      return;
    }

    setState(() => _showPlayer = true);
    if (_controller != null) return;
    await _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.videoUrl),
      );
      await controller.initialize();
      await controller.setLooping(false);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '動画を読み込めませんでした：$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _videoPlayerArea() {
    final controller = _controller;

    if (_loading) {
      return const _InlineNotice(
        tone: _NoticeTone.warning,
        title: '動画読み込み中',
        message: '公開サンプル動画を読み込んでいます。',
      );
    }

    if (_error != null) {
      return _InlineNotice(
        tone: _NoticeTone.warning,
        title: '動画エラー',
        message: _error!,
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: VideoPlayer(controller),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.filled(
                onPressed: () {
                  setState(() {
                    controller.value.isPlaying
                        ? controller.pause()
                        : controller.play();
                  });
                },
                icon: Icon(
                  controller.value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: _AppPalette.teal,
                    bufferedColor: Color(0xFF93C5FD),
                    backgroundColor: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.video.videoUrl,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionBankOutlineWorkspace extends StatelessWidget {
  const _QuestionBankOutlineWorkspace({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: Icons.account_tree_rounded,
          title: '${lesson.title}：問題バンク',
          subtitle: '小分類を選び、各分類 3 道の練習問題で理解を確認します。',
        ),
        const SizedBox(height: 16),
        for (final section in lesson.sections) ...[
          _PracticeQuestionSet(
            title: section.heading,
            subtitle: section.body,
            questions: _practiceQuestionsForSection(lesson, section),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _PracticeQuestionSet extends StatefulWidget {
  const _PracticeQuestionSet({
    required this.title,
    required this.subtitle,
    required this.questions,
  });

  final String title;
  final String subtitle;
  final List<ExamQuestion> questions;

  @override
  State<_PracticeQuestionSet> createState() => _PracticeQuestionSetState();
}

class _PracticeQuestionSetState extends State<_PracticeQuestionSet> {
  final Map<int, int> _answers = {};
  final Set<int> _submitted = {};

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              widget.subtitle,
              style: const TextStyle(color: _AppPalette.muted),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < widget.questions.length; i++) ...[
              _ExamQuestionCard(
                number: i + 1,
                question: widget.questions[i],
                selectedAnswer: _answers[i],
                submitted: _submitted.contains(i),
                onSelect: (answerIndex) => setState(() {
                  _answers[i] = answerIndex;
                  _submitted.remove(i);
                }),
                onSubmit: () => setState(() => _submitted.add(i)),
              ),
              if (i != widget.questions.length - 1) const SizedBox(height: 12),
            ],
          ],
        ),
      ),
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
    required this.lesson,
    required this.questions,
    required this.selectedAnswers,
    required this.submittedIndexes,
    required this.onSelect,
    required this.onSubmit,
  });

  final Lesson lesson;
  final List<ExamQuestion> questions;
  final Map<int, int> selectedAnswers;
  final Set<int> submittedIndexes;
  final void Function(int questionIndex, int answerIndex) onSelect;
  final ValueChanged<int> onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(
          icon: Icons.quiz_rounded,
          title: '${lesson.title}：テスト演習',
          subtitle: 'AI教室の大綱から出題 · ${questions.length}問',
        ),
        const SizedBox(height: 16),
        _ExamProgressCard(
          questions: questions,
          selectedAnswers: selectedAnswers,
          submittedIndexes: submittedIndexes,
        ),
        const SizedBox(height: 16),
        for (
          var questionIndex = 0;
          questionIndex < questions.length;
          questionIndex++
        )
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _ExamQuestionCard(
              number: questionIndex + 1,
              question: questions[questionIndex],
              selectedAnswer: selectedAnswers[questionIndex],
              submitted: submittedIndexes.contains(questionIndex),
              onSelect: (answerIndex) => onSelect(questionIndex, answerIndex),
              onSubmit: () => onSubmit(questionIndex),
            ),
          ),
      ],
    );
  }
}

class _ExamProgressCard extends StatelessWidget {
  const _ExamProgressCard({
    required this.questions,
    required this.selectedAnswers,
    required this.submittedIndexes,
  });

  final List<ExamQuestion> questions;
  final Map<int, int> selectedAnswers;
  final Set<int> submittedIndexes;

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
    final submitted = submittedIndexes.length;
    final progress = total == 0 ? 0.0 : submitted / total;
    var correct = 0;
    for (var i = 0; i < questions.length; i++) {
      if (submittedIndexes.contains(i) &&
          selectedAnswers[i] == questions[i].answerIndex) {
        correct++;
      }
    }
    final score = total == 0 ? 0 : ((correct / total) * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '受けるべきテストの進捗',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                _StatusPill(
                  submitted == total
                      ? '完了'
                      : submitted == 0
                      ? '未開始'
                      : '進行中',
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _MetricPill('提出', '$submitted/$total問'),
                _MetricPill('自動採点', '$score点'),
                _MetricPill('残り', '${total - submitted}問'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _AppPalette.wash,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AppPalette.line),
      ),
      child: Text(
        '$label：$value',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ExamQuestionCard extends StatelessWidget {
  const _ExamQuestionCard({
    required this.number,
    required this.question,
    required this.selectedAnswer,
    required this.submitted,
    required this.onSelect,
    required this.onSubmit,
  });

  final int number;
  final ExamQuestion question;
  final int? selectedAnswer;
  final bool submitted;
  final ValueChanged<int> onSelect;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final isCorrect = submitted && selectedAnswer == question.answerIndex;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _StatusPill('第 $number 問'),
                Text(
                  question.topic,
                  style: const TextStyle(
                    color: _AppPalette.muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
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
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: selectedAnswer == null ? null : onSubmit,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(submitted ? '再採点' : '回答を提出'),
                ),
                if (submitted) _StatusPill(isCorrect ? '正解' : '要復習'),
              ],
            ),
            if (submitted) ...[
              const SizedBox(height: 12),
              _InlineNotice(
                tone: isCorrect ? _NoticeTone.success : _NoticeTone.warning,
                title: isCorrect ? '正しいポイント' : '間違いの理由',
                message: isCorrect
                    ? question.explanation
                    : '${question.explanation}\n正解：${question.options[question.answerIndex]}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _NoticeTone { success, warning }

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1D4ED8),
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.tone,
    required this.title,
    required this.message,
  });

  final _NoticeTone tone;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final success = tone == _NoticeTone.success;
    final background = success
        ? const Color(0xFFEFFAF5)
        : const Color(0xFFFFFBEB);
    final border = success ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A);
    final icon = success
        ? Icons.check_circle_rounded
        : Icons.error_outline_rounded;
    final color = success ? const Color(0xFF047857) : const Color(0xFFB45309);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(message),
              ],
            ),
          ),
        ],
      ),
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
          icon: Icons.verified_rounded,
          title: '成績確認',
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

class _LearningUploadWorkspace extends StatefulWidget {
  const _LearningUploadWorkspace({required this.type});

  final UploadMaterialType type;

  @override
  State<_LearningUploadWorkspace> createState() =>
      _LearningUploadWorkspaceState();
}

class _LearningUploadWorkspaceState extends State<_LearningUploadWorkspace> {
  final _testTitleController = TextEditingController(text: 'Java基礎確認テスト');
  final _testCategoryController = TextEditingController(text: 'Java入門');
  int _selectedTestLesson = 0;
  int _questionCount = 3;
  List<ExamQuestion> _draftQuestions = const [];

  @override
  void dispose() {
    _testTitleController.dispose();
    _testCategoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(
          icon: _uploadTypeIcon(widget.type),
          title: _uploadTypeTitle(widget.type),
          subtitle: _uploadTypeSubtitle(widget.type),
        ),
        const SizedBox(height: 16),
        if (widget.type == UploadMaterialType.video) ...[
          const _UploadDropZone(
            icon: Icons.video_file_rounded,
            title: '授業動画をアップロード',
            subtitle: '先生が録画した授業を MP4 / MOV として登録し、学生の動画一覧と進捗管理に反映します。',
            buttonLabel: '動画ファイルを選択',
            allowedExtensions: ['mp4', 'mov'],
            fileType: FileType.custom,
          ),
          const SizedBox(height: 16),
          const _UploadedMaterialCard(
            icon: Icons.video_library_rounded,
            title: 'HashMap 授業録画',
            status: '動画登録済み',
            detail: '学生画面の動画学習に公開 · 18% 視聴',
          ),
        ] else if (widget.type == UploadMaterialType.pdf) ...[
          const _UploadDropZone(
            icon: Icons.picture_as_pdf_rounded,
            title: 'PDF教材をアップロード',
            subtitle: 'PDF教材を AI教室の文書学習に登録し、問題バンク生成やAI再学習の素材にします。',
            buttonLabel: 'PDFファイルを選択',
            allowedExtensions: ['pdf'],
            fileType: FileType.custom,
          ),
          const SizedBox(height: 16),
          const _UploadedMaterialCard(
            icon: Icons.picture_as_pdf_rounded,
            title: 'コレクション：配列とArrayList',
            status: 'PDF登録済み',
            detail: 'AI教室の文書学習に反映予定',
          ),
        ] else ...[
          _TeacherTestUploadPanel(
            titleController: _testTitleController,
            categoryController: _testCategoryController,
            selectedLessonIndex: _selectedTestLesson,
            questionCount: _questionCount,
            questions: _draftQuestions,
            onLessonChanged: (index) => setState(() {
              _selectedTestLesson = index;
              _testCategoryController.text = _lessons[index].level;
            }),
            onQuestionCountChanged: (count) =>
                setState(() => _questionCount = count),
            onGenerate: _generateDraftQuestions,
            onAddQuestion: _addDraftQuestion,
            onQuestionChanged: _updateDraftQuestion,
            onDeleteQuestion: _deleteDraftQuestion,
            onUpload: _uploadDraftTest,
          ),
          const SizedBox(height: 16),
          const _UploadedMaterialCard(
            icon: Icons.quiz_rounded,
            title: 'Java基礎確認テスト',
            status: '確認待ち',
            detail: 'AI生成後、先生確認・編集してから公開',
          ),
        ],
      ],
    );
  }

  void _generateDraftQuestions() {
    setState(() {
      _draftQuestions = _examQuestionsForLesson(
        _lessons[_selectedTestLesson],
      ).take(_questionCount).toList();
    });
  }

  void _addDraftQuestion() {
    setState(() {
      _draftQuestions = [
        ..._draftQuestions,
        const ExamQuestion(
          topic: '先生追加問題',
          question: 'ここに先生が追加したい選択問題を入力してください。',
          options: ['選択肢A', '選択肢B', '選択肢C', '選択肢D'],
          answerIndex: 0,
          explanation: '模範解答と解説を入力します。',
        ),
      ];
    });
  }

  void _uploadDraftTest() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('テストをアップロードしました。学生のテスト一覧に反映されます。')),
    );
  }

  void _updateDraftQuestion(int index, ExamQuestion question) {
    setState(() {
      final updated = List<ExamQuestion>.of(_draftQuestions);
      updated[index] = question;
      _draftQuestions = updated;
    });
  }

  void _deleteDraftQuestion(int index) {
    setState(() {
      final updated = List<ExamQuestion>.of(_draftQuestions)..removeAt(index);
      _draftQuestions = updated;
    });
  }
}

IconData _uploadTypeIcon(UploadMaterialType type) {
  switch (type) {
    case UploadMaterialType.video:
      return Icons.video_file_rounded;
    case UploadMaterialType.pdf:
      return Icons.picture_as_pdf_rounded;
    case UploadMaterialType.test:
      return Icons.quiz_rounded;
  }
}

String _uploadTypeTitle(UploadMaterialType type) {
  switch (type) {
    case UploadMaterialType.video:
      return '動画アップロード';
    case UploadMaterialType.pdf:
      return 'PDFアップロード';
    case UploadMaterialType.test:
      return 'テストアップロード';
  }
}

String _uploadTypeSubtitle(UploadMaterialType type) {
  switch (type) {
    case UploadMaterialType.video:
      return '授業録画だけをアップロードし、学生の動画学習と進捗管理に反映します。';
    case UploadMaterialType.pdf:
      return 'PDF教材だけをアップロードし、学生の文書学習に反映します。';
    case UploadMaterialType.test:
      return '選択問題テストだけをAI生成・先生確認・編集してからアップロードします。';
  }
}

class _UploadDropZone extends StatefulWidget {
  const _UploadDropZone({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.allowedExtensions,
    required this.fileType,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final List<String> allowedExtensions;
  final FileType fileType;

  @override
  State<_UploadDropZone> createState() => _UploadDropZoneState();
}

class _UploadDropZoneState extends State<_UploadDropZone> {
  PlatformFile? _selectedFile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: _AppPalette.washBlue,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _AppPalette.line),
              ),
              child: Column(
                children: [
                  Icon(widget.icon, color: _AppPalette.sky, size: 44),
                  const SizedBox(height: 10),
                  Text(
                    widget.subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _AppPalette.muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: Text(widget.buttonLabel),
                  ),
                  if (_selectedFile != null) ...[
                    const SizedBox(height: 14),
                    _SelectedFilePanel(
                      file: _selectedFile!,
                      onUpload: _uploadSelectedFile,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    final result = await FilePicker.pickFiles(
      type: widget.fileType,
      allowedExtensions: widget.fileType == FileType.custom
          ? widget.allowedExtensions
          : null,
      allowMultiple: false,
      withData: false,
    );

    if (!mounted || result == null || result.files.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _selectedFile = result.files.single);
    });
  }

  void _uploadSelectedFile() {
    final file = _selectedFile;
    if (file == null) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${file.name} をアップロードしました。')));
  }
}

class _SelectedFilePanel extends StatelessWidget {
  const _SelectedFilePanel({required this.file, required this.onUpload});

  final PlatformFile file;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    final sizeKb = (file.size / 1024).ceil();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AppPalette.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_rounded, color: _AppPalette.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                Text(
                  '$sizeKb KB · ${file.extension ?? 'file'}',
                  style: const TextStyle(color: _AppPalette.muted),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onUpload,
            icon: const Icon(Icons.cloud_upload_rounded),
            label: const Text('アップロード'),
          ),
        ],
      ),
    );
  }
}

class _TeacherTestUploadPanel extends StatelessWidget {
  const _TeacherTestUploadPanel({
    required this.titleController,
    required this.categoryController,
    required this.selectedLessonIndex,
    required this.questionCount,
    required this.questions,
    required this.onLessonChanged,
    required this.onQuestionCountChanged,
    required this.onGenerate,
    required this.onAddQuestion,
    required this.onQuestionChanged,
    required this.onDeleteQuestion,
    required this.onUpload,
  });

  final TextEditingController titleController;
  final TextEditingController categoryController;
  final int selectedLessonIndex;
  final int questionCount;
  final List<ExamQuestion> questions;
  final ValueChanged<int> onLessonChanged;
  final ValueChanged<int> onQuestionCountChanged;
  final VoidCallback onGenerate;
  final VoidCallback onAddQuestion;
  final void Function(int index, ExamQuestion question) onQuestionChanged;
  final ValueChanged<int> onDeleteQuestion;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'テストアップロード',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 640;
                return Column(
                  children: [
                    _ResponsiveFieldRow(
                      wide: wide,
                      children: [
                        TextField(
                          controller: titleController,
                          decoration: const InputDecoration(labelText: 'テスト名'),
                        ),
                        DropdownButtonFormField<int>(
                          initialValue: selectedLessonIndex,
                          decoration: const InputDecoration(
                            labelText: '出題内容',
                            prefixIcon: Icon(Icons.menu_book_rounded),
                          ),
                          items: [
                            for (var i = 0; i < _lessons.length; i++)
                              DropdownMenuItem<int>(
                                value: i,
                                child: Text(_lessons[i].title),
                              ),
                          ],
                          onChanged: (value) {
                            if (value != null) onLessonChanged(value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _ResponsiveFieldRow(
                      wide: wide,
                      children: [
                        TextField(
                          controller: categoryController,
                          decoration: const InputDecoration(labelText: '分類'),
                        ),
                        DropdownButtonFormField<int>(
                          initialValue: questionCount,
                          decoration: const InputDecoration(
                            labelText: '生成問題数',
                            prefixIcon: Icon(
                              Icons.format_list_numbered_rounded,
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: 3, child: Text('3問')),
                            DropdownMenuItem(value: 5, child: Text('5問')),
                            DropdownMenuItem(value: 10, child: Text('10問')),
                          ],
                          onChanged: (value) {
                            if (value != null) onQuestionCountChanged(value);
                          },
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            _InlineNotice(
              tone: _NoticeTone.success,
              title: 'テスト内容',
              message:
                  '${_lessons[selectedLessonIndex].title} について、選択問題を $questionCount 問生成します。先生は生成後に確認、編集、削除、追加できます。',
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onGenerate,
                  icon: const Icon(Icons.auto_awesome_rounded),
                  label: const Text('AIで選択問題を生成'),
                ),
                OutlinedButton.icon(
                  onPressed: onAddQuestion,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('先生の問題を追加'),
                ),
              ],
            ),
            if (questions.isEmpty) ...[
              const SizedBox(height: 16),
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: '生成前',
                message: 'AI生成後、先生が確認し、必要な箇所を編集してからアップロードできます。',
              ),
            ] else ...[
              const SizedBox(height: 18),
              Text(
                'AI生成テスト草稿（編集可能）',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < questions.length; i++) ...[
                _EditableQuestionDraft(
                  number: i + 1,
                  question: questions[i],
                  onChanged: (question) => onQuestionChanged(i, question),
                  onDelete: () => onDeleteQuestion(i),
                ),
                const SizedBox(height: 12),
              ],
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: onUpload,
                  icon: const Icon(Icons.cloud_upload_rounded),
                  label: const Text('確認済みテストをアップロード'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditableQuestionDraft extends StatelessWidget {
  const _EditableQuestionDraft({
    required this.number,
    required this.question,
    required this.onChanged,
    required this.onDelete,
  });

  final int number;
  final ExamQuestion question;
  final ValueChanged<ExamQuestion> onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AppPalette.canvas,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AppPalette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '第 $number 問',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                tooltip: '削除',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: question.question,
            decoration: const InputDecoration(labelText: '問題文'),
            maxLines: 2,
            onChanged: (value) => _emit(question: value),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < question.options.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextFormField(
                initialValue: question.options[i],
                decoration: InputDecoration(labelText: '選択肢 ${i + 1}'),
                onChanged: (value) {
                  final options = List<String>.of(question.options);
                  options[i] = value;
                  _emit(options: options);
                },
              ),
            ),
          DropdownButtonFormField<int>(
            initialValue: question.answerIndex,
            decoration: const InputDecoration(labelText: '正解'),
            items: [
              for (var i = 0; i < question.options.length; i++)
                DropdownMenuItem<int>(
                  value: i,
                  child: Text('選択肢 ${i + 1}: ${question.options[i]}'),
                ),
            ],
            onChanged: (value) {
              if (value != null) _emit(answerIndex: value);
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            initialValue: question.explanation,
            decoration: const InputDecoration(labelText: '模範解答・解説'),
            maxLines: 2,
            onChanged: (value) => _emit(explanation: value),
          ),
        ],
      ),
    );
  }

  void _emit({
    String? topic,
    String? question,
    List<String>? options,
    int? answerIndex,
    String? explanation,
  }) {
    onChanged(
      ExamQuestion(
        topic: topic ?? this.question.topic,
        question: question ?? this.question.question,
        options: options ?? this.question.options,
        answerIndex: answerIndex ?? this.question.answerIndex,
        explanation: explanation ?? this.question.explanation,
      ),
    );
  }
}

class _UploadedMaterialCard extends StatelessWidget {
  const _UploadedMaterialCard({
    this.icon = Icons.description_rounded,
    required this.title,
    required this.status,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String status;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: _AppPalette.teal),
        title: Text(title),
        subtitle: Text(detail),
        trailing: Text(status),
      ),
    );
  }
}

class _UserRoleManagementWorkspace extends StatefulWidget {
  const _UserRoleManagementWorkspace({required this.section});

  final SystemManagementSection section;

  @override
  State<_UserRoleManagementWorkspace> createState() =>
      _UserRoleManagementWorkspaceState();
}

class _UserRoleManagementWorkspaceState
    extends State<_UserRoleManagementWorkspace> {
  final _nameController = TextEditingController(text: '新規学生');
  final _emailController = TextEditingController(
    text: 'new-student@example.com',
  );
  final _passwordController = TextEditingController(text: 'student123');
  final _phoneController = TextEditingController(text: '080-0000-0000');
  final List<StudentProfile> _managedStudents = List.of(_students);
  String _existingStudent = _students.first.name;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const _SectionHeader(
          icon: Icons.admin_panel_settings_rounded,
          title: 'システム管理',
          subtitle: '学生アカウントとパスワードを作成し、既存学生を追加・確認できます。',
        ),
        const SizedBox(height: 16),
        if (widget.section == SystemManagementSection.createStudent)
          _createStudentCard()
        else if (widget.section == SystemManagementSection.addExisting)
          _addExistingStudentCard()
        else
          _allStudentsList(),
      ],
    );
  }

  Widget _createStudentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '新規学生アカウント作成',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              '学生アカウントと初期パスワードを入力します。保存後、全学生一覧に表示されます。',
              style: TextStyle(color: _AppPalette.muted),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth > 640;
                return Column(
                  children: [
                    _ResponsiveFieldRow(
                      wide: wide,
                      children: [
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: '学生名',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: '学生アカウント / メール',
                            prefixIcon: Icon(Icons.mail_outline_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _ResponsiveFieldRow(
                      wide: wide,
                      children: [
                        TextField(
                          controller: _passwordController,
                          decoration: const InputDecoration(
                            labelText: '初期パスワード',
                            prefixIcon: Icon(Icons.lock_outline_rounded),
                          ),
                        ),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: '連絡先',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _createStudent,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: const Text('学生アカウントを作成'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addExistingStudentCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '既存学生を追加',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              '既存学生一覧から学生を選択し、現在の管理一覧に追加します。',
              style: TextStyle(color: _AppPalette.muted),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _existingStudent,
                    decoration: const InputDecoration(labelText: '既存学生'),
                    items: [
                      for (final student in _students)
                        DropdownMenuItem(
                          value: student.name,
                          child: Text('${student.name} · ${student.email}'),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _existingStudent = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _addExistingStudent,
                  icon: const Icon(Icons.group_add_rounded),
                  label: const Text('追加'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _allStudentsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(
          icon: Icons.groups_rounded,
          title: '全学生',
          subtitle: '全学生のアカウント、メール、連絡先、初期パスワードを確認します。',
        ),
        const SizedBox(height: 12),
        for (final student in _managedStudents)
          _UserRoleCard(
            name: student.name,
            email: student.email,
            role: '学生',
            status: student.status,
            phone: student.phone,
            password: student.password,
          ),
      ],
    );
  }

  void _createStudent() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _managedStudents.add(
        StudentProfile(
          name,
          '生徒 · 新規作成',
          'まだ質問はありません。',
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          phone: _phoneController.text.trim(),
        ),
      );
    });
  }

  void _addExistingStudent() {
    final existing = _students.firstWhere(
      (student) => student.name == _existingStudent,
    );
    final alreadyAdded = _managedStudents.any(
      (student) => student.email == existing.email,
    );
    if (alreadyAdded) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${existing.name} はすでに一覧にあります。')));
      return;
    }
    setState(() => _managedStudents.add(existing));
  }
}

class _UserRoleCard extends StatelessWidget {
  const _UserRoleCard({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.phone,
    required this.password,
  });

  final String name;
  final String email;
  final String role;
  final String status;
  final String phone;
  final String password;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(name.substring(0, 1))),
        title: Text(name),
        subtitle: Text('$email\n$status · $phone · 初期PW: $password'),
        isThreeLine: true,
        trailing: Chip(
          label: Text(role),
          backgroundColor: role == '先生'
              ? _AppPalette.washBlue
              : _AppPalette.wash,
          side: const BorderSide(color: _AppPalette.line),
        ),
      ),
    );
  }
}

Widget _settingsMiddlePanel({
  required ProfileSettingSection selected,
  required ValueChanged<ProfileSettingSection> onSelect,
}) {
  return _HistoryPanel(
    title: '設定項目',
    children: [
      _CompactListCard(
        selected: selected == ProfileSettingSection.profile,
        title: 'プロフィール',
        subtitle: '名前・メール',
        detail: '名前とメールを変更します。',
        onTap: () => onSelect(ProfileSettingSection.profile),
      ),
      _CompactListCard(
        selected: selected == ProfileSettingSection.avatar,
        title: 'アイコン',
        subtitle: 'プロフィール画像',
        detail: 'アイコンファイルを選択・変更します。',
        onTap: () => onSelect(ProfileSettingSection.avatar),
      ),
      _CompactListCard(
        selected: selected == ProfileSettingSection.password,
        title: 'パスワード',
        subtitle: 'ログイン情報',
        detail: '新しいパスワードと確認パスワードを入力します。',
        onTap: () => onSelect(ProfileSettingSection.password),
      ),
      _CompactListCard(
        selected: selected == ProfileSettingSection.contact,
        title: '連絡先',
        subtitle: '電話番号',
        detail: '連絡先と通知先を変更します。',
        onTap: () => onSelect(ProfileSettingSection.contact),
      ),
      _CompactListCard(
        selected: selected == ProfileSettingSection.basicInfo,
        title: '基本情報',
        subtitle: '自己紹介',
        detail: '学習状況や担当内容などを編集します。',
        onTap: () => onSelect(ProfileSettingSection.basicInfo),
      ),
    ],
  );
}

class _ProfileSettingsWorkspace extends StatefulWidget {
  const _ProfileSettingsWorkspace({
    required this.roleTitle,
    required this.roleSubtitle,
    required this.initialName,
    required this.initialEmail,
    required this.initialPhone,
    required this.initialAvatar,
    required this.initialBasicInfo,
    required this.section,
  });

  final String roleTitle;
  final String roleSubtitle;
  final String initialName;
  final String initialEmail;
  final String initialPhone;
  final String initialAvatar;
  final String initialBasicInfo;
  final ProfileSettingSection section;

  @override
  State<_ProfileSettingsWorkspace> createState() =>
      _ProfileSettingsWorkspaceState();
}

class _ProfileSettingsWorkspaceState extends State<_ProfileSettingsWorkspace> {
  late final TextEditingController _nameController;
  final _passwordController = TextEditingController(text: 'password');
  final _confirmPasswordController = TextEditingController(text: 'password');
  late final TextEditingController _avatarController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _basicInfoController;
  late String _savedName;
  late String _savedEmail;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _avatarController = TextEditingController(text: widget.initialAvatar);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _emailController = TextEditingController(text: widget.initialEmail);
    _basicInfoController = TextEditingController(text: widget.initialBasicInfo);
    _savedName = widget.initialName;
    _savedEmail = widget.initialEmail;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _avatarController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _basicInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(
          icon: _profileSectionIcon(widget.section),
          title: '${widget.roleTitle}：${_profileSectionTitle(widget.section)}',
          subtitle: widget.roleSubtitle,
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: _AppPalette.washBlue,
                      child: Text(
                        _nameController.text.isEmpty
                            ? '学'
                            : _nameController.text.substring(0, 1),
                        style: const TextStyle(
                          color: _AppPalette.sky,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _savedName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _savedEmail,
                            style: const TextStyle(color: _AppPalette.muted),
                          ),
                        ],
                      ),
                    ),
                    if (widget.section == ProfileSettingSection.avatar)
                      OutlinedButton.icon(
                        onPressed: _chooseAvatar,
                        icon: const Icon(Icons.image_rounded),
                        label: const Text('アイコン変更'),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 640;
                    return Column(children: _profileSectionFields(wide));
                  },
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('保存'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _resetProfile,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('リセット'),
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

  void _chooseAvatar() {
    setState(() => _avatarController.text = 'new-profile-avatar.png');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('アイコンを選択しました。保存すると反映されます。')));
  }

  void _saveProfile() {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('パスワードと確認パスワードが一致しません。')));
      return;
    }

    setState(() {
      _savedName = _nameController.text.trim().isEmpty
          ? '学生'
          : _nameController.text.trim();
      _savedEmail = _emailController.text.trim();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('学生情報を保存しました。')));
  }

  void _resetProfile() {
    setState(() {
      _nameController.text = _savedName;
      _emailController.text = _savedEmail;
      _passwordController.text = 'password';
      _confirmPasswordController.text = 'password';
      _avatarController.text = widget.initialAvatar;
      _phoneController.text = widget.initialPhone;
      _basicInfoController.text = widget.initialBasicInfo;
    });
  }

  List<Widget> _profileSectionFields(bool wide) {
    switch (widget.section) {
      case ProfileSettingSection.profile:
        return [
          _ResponsiveFieldRow(
            wide: wide,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '名前',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'メール',
                  prefixIcon: Icon(Icons.mail_outline_rounded),
                ),
              ),
            ],
          ),
        ];
      case ProfileSettingSection.avatar:
        return [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _AppPalette.washBlue,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _AppPalette.line),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: Text(
                    _nameController.text.isEmpty
                        ? '学'
                        : _nameController.text.substring(0, 1),
                    style: const TextStyle(
                      color: _AppPalette.sky,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(_avatarController.text),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _chooseAvatar,
                  icon: const Icon(Icons.image_rounded),
                  label: const Text('アイコンファイルを選択'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _avatarController,
            decoration: const InputDecoration(
              labelText: 'アイコン',
              prefixIcon: Icon(Icons.account_circle_outlined),
            ),
          ),
        ];
      case ProfileSettingSection.password:
        return [
          _ResponsiveFieldRow(
            wide: wide,
            children: [
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '新パスワード',
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
              ),
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '確認パスワード',
                  prefixIcon: Icon(Icons.verified_user_outlined),
                ),
              ),
            ],
          ),
        ];
      case ProfileSettingSection.contact:
        return [
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: '連絡先',
              prefixIcon: Icon(Icons.phone_outlined),
            ),
          ),
        ];
      case ProfileSettingSection.basicInfo:
        return [
          TextField(
            controller: _basicInfoController,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: '基本情報',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
          ),
        ];
    }
  }
}

class _ResponsiveFieldRow extends StatelessWidget {
  const _ResponsiveFieldRow({required this.wide, required this.children});

  final bool wide;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            children[i],
          ],
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: children[i]),
        ],
      ],
    );
  }
}

IconData _profileSectionIcon(ProfileSettingSection section) {
  switch (section) {
    case ProfileSettingSection.profile:
      return Icons.person_rounded;
    case ProfileSettingSection.avatar:
      return Icons.image_rounded;
    case ProfileSettingSection.password:
      return Icons.lock_rounded;
    case ProfileSettingSection.contact:
      return Icons.phone_rounded;
    case ProfileSettingSection.basicInfo:
      return Icons.badge_rounded;
  }
}

String _profileSectionTitle(ProfileSettingSection section) {
  switch (section) {
    case ProfileSettingSection.profile:
      return 'プロフィール';
    case ProfileSettingSection.avatar:
      return 'アイコン';
    case ProfileSettingSection.password:
      return 'パスワード';
    case ProfileSettingSection.contact:
      return '連絡先';
    case ProfileSettingSection.basicInfo:
      return '基本情報';
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
