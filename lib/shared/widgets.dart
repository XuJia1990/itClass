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
    this.badge,
  });

  final String title;
  final String subtitle;
  final String detail;
  final VoidCallback onTap;
  final bool selected;
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

class _CodeScoringWorkspace extends StatefulWidget {
  const _CodeScoringWorkspace({
    required this.assignment,
    required this.controller,
    required this.onScore,
  });

  final CodeAssignment assignment;
  final TextEditingController controller;
  final Future<ScoreResult> Function() onScore;

  @override
  State<_CodeScoringWorkspace> createState() => _CodeScoringWorkspaceState();
}

class _CodeScoringWorkspaceState extends State<_CodeScoringWorkspace> {
  ScoreResult? _result;
  bool _scoring = false;

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
            onPressed: _scoring ? null : _score,
            icon: _scoring
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.fact_check_rounded),
            label: Text(_scoring ? '採点中' : 'コードを提出して採点'),
          ),
        ),
        if (_result != null) ...[
          const SizedBox(height: 18),
          _ScoreCard(result: _result!),
        ],
      ],
    );
  }

  Future<void> _score() async {
    setState(() => _scoring = true);
    try {
      final result = await widget.onScore();
      if (!mounted) return;
      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('採点に失敗しました：$error')));
    } finally {
      if (mounted) setState(() => _scoring = false);
    }
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
    required this.onVideoPositionSaved,
    required this.mode,
    required this.exams,
    required this.onOpenExam,
  });

  final Lesson lesson;
  final List<LearningVideo> videos;
  final List<double> videoProgress;
  final void Function(int index, double progress) onVideoProgressChanged;
  final Future<void> Function(
    int index,
    int positionSeconds,
    int durationSeconds,
    bool ended,
  )
  onVideoPositionSaved;
  final LearningMode mode;
  final List<SchoolExamSummary> exams;
  final ValueChanged<int> onOpenExam;

  @override
  State<_LearningWorkspace> createState() => _LearningWorkspaceState();
}

class _LearningWorkspaceState extends State<_LearningWorkspace> {
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
            onPositionSaved: widget.onVideoPositionSaved,
          )
        else if (widget.mode == LearningMode.questionBank)
          _QuestionBankOutlineWorkspace(
            exams: widget.exams,
            onOpenExam: widget.onOpenExam,
          )
        else ...[
          _SectionHeader(
            icon: Icons.menu_book_rounded,
            title: lesson.title,
            subtitle: '${lesson.level} · ${lesson.summary}',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lesson.summary, style: const TextStyle(height: 1.7)),
                  if (lesson.fileName.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      lesson.fileName,
                      style: const TextStyle(color: _AppPalette.muted),
                    ),
                  ],
                  if (lesson.documentUrl.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () => launchUrl(
                        Uri.parse(lesson.documentUrl),
                        mode: LaunchMode.externalApplication,
                      ),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text('教材を開く'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final section in lesson.sections) ...[
            _LessonSectionCard(section: section),
            const SizedBox(height: 12),
          ],
          if (lesson.code.isNotEmpty) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: SelectableText(
                  lesson.code,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ),
          ],
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
    required this.onPositionSaved,
  });

  final List<LearningVideo> videos;
  final List<double> progress;
  final void Function(int index, double progress) onProgressChanged;
  final Future<void> Function(
    int index,
    int positionSeconds,
    int durationSeconds,
    bool ended,
  )
  onPositionSaved;

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
            key: ValueKey(videos[i].id ?? videos[i].videoUrl),
            video: videos[i],
            progress: progress[i],
            onMarkWatched: () => onProgressChanged(i, 1.0),
            onProgressChanged: (value) => onProgressChanged(i, value),
            onPositionSaved: (position, duration, ended) =>
                onPositionSaved(i, position, duration, ended),
          ),
      ],
    );
  }
}

class _VideoProgressCard extends StatefulWidget {
  const _VideoProgressCard({
    super.key,
    required this.video,
    required this.progress,
    required this.onMarkWatched,
    required this.onProgressChanged,
    required this.onPositionSaved,
  });

  final LearningVideo video;
  final double progress;
  final VoidCallback onMarkWatched;
  final ValueChanged<double> onProgressChanged;
  final Future<void> Function(int position, int duration, bool ended)
  onPositionSaved;

  @override
  State<_VideoProgressCard> createState() => _VideoProgressCardState();
}

class _VideoProgressCardState extends State<_VideoProgressCard> {
  VideoPlayerController? _controller;
  bool _showPlayer = false;
  bool _loading = false;
  String? _error;
  int _lastUiSecond = -1;
  bool _endedSaved = false;
  bool _savingPosition = false;

  @override
  void dispose() {
    unawaited(_saveCurrentPosition());
    _controller?.removeListener(_handlePlaybackProgress);
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
                  onPressed: widget.progress >= 1.0 ? null : _markWatched,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(widget.progress >= 1.0 ? '視聴済み' : '視聴済みにする'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePlayer() async {
    if (_showPlayer) {
      await _controller?.pause();
      await _saveCurrentPosition();
      if (!mounted) return;
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
      if (widget.video.lastPositionSeconds > 0) {
        await controller.seekTo(
          Duration(seconds: widget.video.lastPositionSeconds),
        );
      }
      controller.addListener(_handlePlaybackProgress);
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

  void _handlePlaybackProgress() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final position = controller.value.position.inSeconds;
    final duration = controller.value.duration.inSeconds;
    if (duration <= 0) return;
    final ended = controller.value.isCompleted || position >= duration;
    if (position != _lastUiSecond) {
      _lastUiSecond = position;
      widget.onProgressChanged((position / duration).clamp(0.0, 1.0));
      if (mounted) setState(() {});
    }
    if (ended && !_endedSaved) {
      unawaited(_saveCurrentPosition(completed: true));
    }
  }

  void _markWatched() {
    final duration =
        _controller?.value.duration.inSeconds ?? widget.video.durationSeconds;
    _endedSaved = true;
    widget.onMarkWatched();
    unawaited(_savePosition(duration, duration, true));
  }

  Future<void> _saveCurrentPosition({bool completed = false}) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final duration = controller.value.duration.inSeconds;
    if (duration <= 0) return;
    final position = controller.value.position.inSeconds.clamp(0, duration);
    final ended =
        completed || controller.value.isCompleted || position >= duration;
    if (ended) _endedSaved = true;
    await _savePosition(position, duration, ended);
  }

  Future<void> _savePosition(int position, int duration, bool ended) async {
    if (_savingPosition) return;
    _savingPosition = true;
    try {
      await widget.onPositionSaved(position, duration, ended);
    } catch (error) {
      debugPrint('[itClass video] progress save failed: $error');
    } finally {
      _savingPosition = false;
    }
  }

  Widget _videoPlayerArea() {
    final controller = _controller;

    if (_loading) {
      return const _InlineNotice(
        tone: _NoticeTone.warning,
        title: '動画読み込み中',
        message: '授業動画を読み込んでいます。',
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
                onPressed: () async {
                  if (controller.value.isPlaying) {
                    await controller.pause();
                    await _saveCurrentPosition();
                  } else {
                    await controller.play();
                  }
                  if (mounted) setState(() {});
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
  const _QuestionBankOutlineWorkspace({
    required this.exams,
    required this.onOpenExam,
  });

  final List<SchoolExamSummary> exams;
  final ValueChanged<int> onOpenExam;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader(
          icon: Icons.account_tree_rounded,
          title: '問題バンク',
          subtitle: 'バックエンドで公開されているテスト問題を確認します。',
        ),
        const SizedBox(height: 16),
        if (exams.isEmpty)
          const _InlineNotice(
            tone: _NoticeTone.warning,
            title: '問題データがありません',
            message: '先生がテストを公開すると、ここに表示されます。',
          ),
        for (var i = 0; i < exams.length; i++)
          Card(
            child: ListTile(
              leading: const Icon(Icons.quiz_outlined),
              title: Text(exams[i].title),
              subtitle: Text(
                '${exams[i].isAvailable ? '受験可能' : '受付終了'} · ${exams[i].description}',
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: exams[i].isAvailable ? () => onOpenExam(i) : null,
            ),
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

class _ExamWorkspace extends StatelessWidget {
  const _ExamWorkspace({
    required this.lesson,
    required this.questions,
    required this.selectedAnswers,
    required this.submittedIndexes,
    required this.onSelect,
    required this.onSubmit,
    required this.result,
  });

  final Lesson lesson;
  final List<ExamQuestion> questions;
  final Map<int, int> selectedAnswers;
  final Set<int> submittedIndexes;
  final void Function(int questionIndex, int answerIndex) onSelect;
  final ValueChanged<int> onSubmit;
  final ExamResult? result;

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
          result: result,
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
              answerResult: result?.answerFor(
                questions[questionIndex].paperQuestionId,
              ),
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
    required this.result,
  });

  final List<ExamQuestion> questions;
  final Map<int, int> selectedAnswers;
  final Set<int> submittedIndexes;
  final ExamResult? result;

  @override
  Widget build(BuildContext context) {
    final total = questions.length;
    final submitted = submittedIndexes.length;
    final progress = total == 0 ? 0.0 : submitted / total;
    final score = result?.totalScore.round();

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
                _MetricPill('自動採点', score == null ? '未採点' : '$score点'),
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
    required this.answerResult,
  });

  final int number;
  final ExamQuestion question;
  final int? selectedAnswer;
  final bool submitted;
  final ValueChanged<int> onSelect;
  final VoidCallback onSubmit;
  final ExamAnswerResult? answerResult;

  @override
  Widget build(BuildContext context) {
    final isCorrect = answerResult?.correct;

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
                if (answerResult != null)
                  _StatusPill(
                    isCorrect == null
                        ? '採点待ち'
                        : isCorrect
                        ? '正解'
                        : '要復習',
                  )
                else if (submitted)
                  const _StatusPill('保存済み'),
              ],
            ),
            if (answerResult != null) ...[
              const SizedBox(height: 12),
              _InlineNotice(
                tone: isCorrect == true
                    ? _NoticeTone.success
                    : _NoticeTone.warning,
                title: isCorrect == true ? '正解' : '採点結果',
                message: [
                  if (answerResult!.analysis.isNotEmpty) answerResult!.analysis,
                  if (answerResult!.referenceAnswer.isNotEmpty)
                    '参考答案：${answerResult!.referenceAnswer}',
                  '得点：${answerResult!.score.round()}点',
                ].join('\n'),
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
          title: '学生のAI質問対応',
          subtitle: '学生が AI に送った質問と AI の初期回答です。必要に応じて先生が追加回答します。',
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
            hintText: '学生への回答を入力してください。',
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
                  Text('得点：${item.score}点'),
                  Text('コメント：${item.feedback}'),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _TeacherChatWorkspace extends StatefulWidget {
  const _TeacherChatWorkspace({required this.student});

  final StudentProfile student;

  @override
  State<_TeacherChatWorkspace> createState() => _TeacherChatWorkspaceState();
}

class _TeacherChatWorkspaceState extends State<_TeacherChatWorkspace> {
  final _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  StreamSubscription<ChatMessage>? _chatMessageSubscription;
  int? _conversationId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _chatMessageSubscription = SchoolChatRealtime.instance.messages.listen(
      _handleRealtimeMessage,
    );
    unawaited(_loadConversation());
  }

  @override
  void didUpdateWidget(covariant _TeacherChatWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.student.accountId != widget.student.accountId ||
        oldWidget.student.classroomId != widget.student.classroomId) {
      _conversationId = null;
      unawaited(_loadConversation());
    }
  }

  @override
  void dispose() {
    unawaited(_chatMessageSubscription?.cancel());
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(
          icon: Icons.chat_bubble_rounded,
          title: '${widget.student.name} とチャット',
          subtitle: '学生との直接メッセージ · ${widget.student.status}',
        ),
        const SizedBox(height: 16),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_messages.isEmpty)
          const _InlineNotice(
            tone: _NoticeTone.warning,
            title: 'メッセージはありません',
            message: '最初のメッセージを送信できます。',
          )
        else
          for (final message in _messages) _MessageBubble(message: message),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          minLines: 3,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '先生の返信を入力',
            filled: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: _send,
            icon: const Icon(Icons.send_rounded),
            label: const Text('返信を送信'),
          ),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    try {
      final student = widget.student;
      if (student.accountId == null || student.classroomId == null) {
        throw const ApiException('学生IDまたはクラスIDがありません。');
      }
      final conversationId =
          _conversationId ??
          await ItClassApi.instance.getOrCreateChat(
            classroomId: student.classroomId!,
            peerAccountId: student.accountId!,
          );
      _conversationId = conversationId;
      final message = await ItClassApi.instance.sendChatMessage(
        conversationId: conversationId,
        content: text,
      );
      if (!mounted) return;
      setState(() {
        _upsertMessage(message);
        _controller.clear();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('返信送信に失敗しました：$error')));
    }
  }

  Future<void> _loadConversation() async {
    setState(() {
      _loading = true;
      _messages.clear();
    });
    try {
      final student = widget.student;
      if (student.accountId == null || student.classroomId == null) {
        throw const ApiException('学生IDまたはクラスIDがありません。');
      }
      final conversationId = await ItClassApi.instance.getOrCreateChat(
        classroomId: student.classroomId!,
        peerAccountId: student.accountId!,
      );
      final messages = await ItClassApi.instance.chatMessages(conversationId);
      if (!mounted) return;
      setState(() {
        _conversationId = conversationId;
        _messages.addAll(messages);
      });
      _markLatestStudentMessageRead(messages);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('会話履歴の取得に失敗しました：$error')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleRealtimeMessage(ChatMessage message) {
    if (!mounted || message.conversationId != _conversationId) return;
    setState(() => _upsertMessage(message));
    if (message.author == MessageAuthor.student && message.id != null) {
      unawaited(
        ItClassApi.instance.readChatMessages(
          conversationId: message.conversationId!,
          messageId: message.id!,
        ),
      );
    }
  }

  void _upsertMessage(ChatMessage message) {
    final id = message.id;
    final index = id == null
        ? -1
        : _messages.indexWhere((item) => item.id == id);
    if (index >= 0) {
      _messages[index] = message;
    } else {
      _messages.add(message);
    }
  }

  void _markLatestStudentMessageRead(List<ChatMessage> messages) {
    final conversationId = _conversationId;
    final incoming = messages
        .where(
          (message) =>
              message.author == MessageAuthor.student && message.id != null,
        )
        .toList();
    if (conversationId == null || incoming.isEmpty) return;
    final latestId = incoming
        .map((message) => message.id!)
        .reduce((left, right) => left > right ? left : right);
    unawaited(
      ItClassApi.instance.readChatMessages(
        conversationId: conversationId,
        messageId: latestId,
      ),
    );
  }
}

class _LearningUploadWorkspace extends StatefulWidget {
  const _LearningUploadWorkspace({
    required this.type,
    required this.classrooms,
  });

  final UploadMaterialType type;
  final List<SchoolClassroom> classrooms;

  @override
  State<_LearningUploadWorkspace> createState() =>
      _LearningUploadWorkspaceState();
}

class _LearningUploadWorkspaceState extends State<_LearningUploadWorkspace> {
  final _testTitleController = TextEditingController();
  final _testCategoryController = TextEditingController();
  int _selectedTestLesson = 0;
  int _questionCount = 3;
  List<ExamQuestion> _draftQuestions = const [];
  List<Lesson> _availableLessons = const [];
  bool _loadingLessons = false;
  bool _generatingQuestions = false;
  String? _lessonError;

  @override
  void initState() {
    super.initState();
    unawaited(_loadAvailableLessons());
  }

  @override
  void didUpdateWidget(covariant _LearningUploadWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldClassroomId = oldWidget.classrooms.isEmpty
        ? null
        : oldWidget.classrooms.first.id;
    final classroomId = widget.classrooms.isEmpty
        ? null
        : widget.classrooms.first.id;
    if (oldClassroomId != classroomId) {
      unawaited(_loadAvailableLessons());
    }
  }

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
          _UploadDropZone(
            icon: Icons.video_file_rounded,
            title: '授業動画をアップロード',
            subtitle: '先生が録画した授業を MP4 / MOV として登録し、学生の動画一覧と進捗管理に反映します。',
            buttonLabel: '動画ファイルを選択',
            allowedExtensions: const ['mp4', 'mov'],
            fileType: FileType.custom,
            onUpload: _uploadCourseMaterial,
          ),
          const SizedBox(height: 16),
          const _InlineNotice(
            tone: _NoticeTone.success,
            title: 'アップロード先',
            message: 'アップロード完了後、バックエンドの動画教材一覧から学生画面へ反映されます。',
          ),
        ] else if (widget.type == UploadMaterialType.pdf) ...[
          _UploadDropZone(
            icon: Icons.picture_as_pdf_rounded,
            title: 'PDF教材をアップロード',
            subtitle: 'PDF教材を AI教室の文書学習に登録します。',
            buttonLabel: 'PDFファイルを選択',
            allowedExtensions: const ['pdf'],
            fileType: FileType.custom,
            onUpload: _uploadCourseMaterial,
          ),
          const SizedBox(height: 16),
          const _InlineNotice(
            tone: _NoticeTone.success,
            title: 'アップロード先',
            message: 'アップロード完了後、バックエンドの文書教材一覧から学生画面へ反映されます。',
          ),
        ] else ...[
          if (_lessonError != null) ...[
            _InlineNotice(
              tone: _NoticeTone.warning,
              title: '教材取得エラー',
              message: _lessonError!,
            ),
            const SizedBox(height: 16),
          ],
          if (_loadingLessons) ...[
            const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 16),
          ],
          _TeacherTestUploadPanel(
            titleController: _testTitleController,
            categoryController: _testCategoryController,
            lessons: _availableLessons,
            selectedLessonIndex: _selectedTestLesson,
            questionCount: _questionCount,
            questions: _draftQuestions,
            generating: _generatingQuestions,
            onLessonChanged: (index) => setState(() {
              _selectedTestLesson = index;
              final lesson = _availableLessons[index];
              _testTitleController.text = '${lesson.title} テスト';
              _testCategoryController.text = lesson.level;
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
          const _InlineNotice(
            tone: _NoticeTone.success,
            title: '公開先',
            message: 'アップロードしたテストはバックエンドで公開され、学生のテスト一覧へ反映されます。',
          ),
        ],
      ],
    );
  }

  Future<void> _loadAvailableLessons() async {
    if (widget.classrooms.isEmpty) {
      setState(() {
        _availableLessons = const [];
        _lessonError = null;
      });
      return;
    }
    setState(() {
      _loadingLessons = true;
      _lessonError = null;
    });
    try {
      final docs = await ItClassApi.instance.courseDocuments(
        classroomId: widget.classrooms.first.id,
      );
      if (!mounted) return;
      setState(() {
        _availableLessons = docs.list;
        _selectedTestLesson = 0;
        if (_availableLessons.isNotEmpty) {
          final lesson = _availableLessons.first;
          _testTitleController.text = '${lesson.title} テスト';
          _testCategoryController.text = lesson.level;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _lessonError = 'バックエンド教材の取得に失敗しました：$error');
    } finally {
      if (mounted) setState(() => _loadingLessons = false);
    }
  }

  Future<void> _generateDraftQuestions() async {
    if (_availableLessons.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('先にバックエンドへ教材を登録してください。')));
      return;
    }
    setState(() => _generatingQuestions = true);
    try {
      final lesson =
          _availableLessons[_selectedTestLesson.clamp(
            0,
            _availableLessons.length - 1,
          )];
      final questions = await ItClassApi.instance.generateExamQuestions(
        programmingLanguage: lesson.level,
        topic: lesson.title,
        count: _questionCount,
      );
      if (!mounted) return;
      setState(() => _draftQuestions = questions);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('AI問題生成に失敗しました：$error')));
    } finally {
      if (mounted) setState(() => _generatingQuestions = false);
    }
  }

  void _addDraftQuestion() {
    setState(() {
      _draftQuestions = [
        ..._draftQuestions,
        const ExamQuestion(
          topic: '',
          question: '',
          options: ['', '', '', ''],
          answerIndex: 0,
          explanation: '',
        ),
      ];
    });
  }

  Future<void> _uploadCourseMaterial(PlatformFile file) async {
    if (widget.classrooms.isEmpty) {
      throw const ApiException('担当クラスがありません。先に后台でクラスを作成してください。');
    }
    final classroomId = widget.classrooms.first.id;
    final url = await ItClassApi.instance.uploadFile(
      file,
      directory: widget.type == UploadMaterialType.video
          ? 'course-video'
          : 'course-document',
    );
    if (widget.type == UploadMaterialType.video) {
      await ItClassApi.instance.createCourseVideo(
        classroomId: classroomId,
        title: file.name,
        fileUrl: url,
        file: file,
      );
    } else {
      await ItClassApi.instance.createCourseDocument(
        classroomId: classroomId,
        title: file.name,
        fileUrl: url,
        file: file,
      );
    }
  }

  Future<void> _uploadDraftTest() async {
    if (_draftQuestions.isEmpty) {
      await _generateDraftQuestions();
    }
    if (!mounted) return;
    if (_draftQuestions.isEmpty) return;
    if (widget.classrooms.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('担当クラスがありません。')));
      return;
    }
    final title = _testTitleController.text.trim();
    if (title.isEmpty ||
        _draftQuestions.any(
          (question) =>
              question.question.trim().isEmpty ||
              question.options.length < 2 ||
              question.options.any((option) => option.trim().isEmpty),
        )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('テスト名、問題文、すべての選択肢を入力してください。')),
      );
      return;
    }
    if (_availableLessons.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('先にバックエンドへ教材を登録してください。')));
      return;
    }
    try {
      final lesson =
          _availableLessons[_selectedTestLesson.clamp(
            0,
            _availableLessons.length - 1,
          )];
      final questionIds = <int>[];
      for (final question in _draftQuestions) {
        questionIds.add(
          await ItClassApi.instance.createQuestion(
            question,
            programmingLanguage: lesson.level,
          ),
        );
      }
      final paperId = await ItClassApi.instance.createPaper(
        title: title,
        description: _testCategoryController.text.trim(),
        questionIds: questionIds,
      );
      await ItClassApi.instance.createAndPublishExam(
        classroomId: widget.classrooms.first.id,
        paperId: paperId,
        title: title,
        description: _testCategoryController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('テストをアップロードしました。学生のテスト一覧に反映されます。')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('テストアップロードに失敗しました：$error')));
    }
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
    required this.onUpload,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final List<String> allowedExtensions;
  final FileType fileType;
  final Future<void> Function(PlatformFile file) onUpload;

  @override
  State<_UploadDropZone> createState() => _UploadDropZoneState();
}

class _UploadDropZoneState extends State<_UploadDropZone> {
  PlatformFile? _selectedFile;
  bool _uploading = false;

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
                      uploading: _uploading,
                      onUpload: () => unawaited(_uploadSelectedFile()),
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
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _selectedFile = result.files.single);
    });
  }

  Future<void> _uploadSelectedFile() async {
    final file = _selectedFile;
    if (file == null) return;
    setState(() => _uploading = true);
    try {
      await widget.onUpload(file);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${file.name} をアップロードしました。')));
      setState(() => _selectedFile = null);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('アップロードに失敗しました：$error')));
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }
}

class _SelectedFilePanel extends StatelessWidget {
  const _SelectedFilePanel({
    required this.file,
    required this.uploading,
    required this.onUpload,
  });

  final PlatformFile file;
  final bool uploading;
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
            onPressed: uploading ? null : onUpload,
            icon: uploading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_rounded),
            label: Text(uploading ? 'アップロード中' : 'アップロード'),
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
    required this.lessons,
    required this.selectedLessonIndex,
    required this.questionCount,
    required this.questions,
    required this.generating,
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
  final List<Lesson> lessons;
  final int selectedLessonIndex;
  final int questionCount;
  final List<ExamQuestion> questions;
  final bool generating;
  final ValueChanged<int> onLessonChanged;
  final ValueChanged<int> onQuestionCountChanged;
  final Future<void> Function() onGenerate;
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
                          initialValue: lessons.isEmpty
                              ? null
                              : selectedLessonIndex.clamp(
                                  0,
                                  lessons.length - 1,
                                ),
                          decoration: const InputDecoration(
                            labelText: '出題内容',
                            prefixIcon: Icon(Icons.menu_book_rounded),
                          ),
                          items: [
                            for (var i = 0; i < lessons.length; i++)
                              DropdownMenuItem<int>(
                                value: i,
                                child: Text(lessons[i].title),
                              ),
                          ],
                          onChanged: lessons.isEmpty
                              ? null
                              : (value) {
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
            if (lessons.isEmpty)
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: '教材データがありません',
                message: 'テスト生成には、先にバックエンドへPDF教材を登録してください。',
              )
            else
              _InlineNotice(
                tone: _NoticeTone.success,
                title: 'テスト内容',
                message:
                    '${lessons[selectedLessonIndex.clamp(0, lessons.length - 1)].title} について、選択問題を $questionCount 問生成します。先生は生成後に確認、編集、削除、追加できます。',
              ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: lessons.isEmpty || generating
                      ? null
                      : () => unawaited(onGenerate()),
                  icon: generating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(generating ? '生成中' : 'AIで選択問題を生成'),
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
        paperQuestionId: this.question.paperQuestionId,
        questionId: this.question.questionId,
        type: this.question.type,
        optionKeys: this.question.optionKeys,
        score: this.question.score,
        topic: topic ?? this.question.topic,
        question: question ?? this.question.question,
        options: options ?? this.question.options,
        answerIndex: answerIndex ?? this.question.answerIndex,
        explanation: explanation ?? this.question.explanation,
      ),
    );
  }
}

class _UserRoleManagementWorkspace extends StatefulWidget {
  const _UserRoleManagementWorkspace({
    required this.section,
    required this.classrooms,
    required this.assignedStudents,
    required this.allStudents,
    required this.onChanged,
  });

  final SystemManagementSection section;
  final List<SchoolClassroom> classrooms;
  final List<StudentProfile> assignedStudents;
  final List<StudentProfile> allStudents;
  final Future<void> Function() onChanged;

  @override
  State<_UserRoleManagementWorkspace> createState() =>
      _UserRoleManagementWorkspaceState();
}

class _UserRoleManagementWorkspaceState
    extends State<_UserRoleManagementWorkspace> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  late List<StudentProfile> _managedStudents;
  late Set<int> _assignedStudentIds;
  int? _existingStudentId;

  List<StudentProfile> get _availableStudents => _managedStudents
      .where(
        (student) =>
            student.accountId != null &&
            !_assignedStudentIds.contains(student.accountId),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    _managedStudents = List.of(widget.allStudents);
    _assignedStudentIds = widget.assignedStudents
        .map((student) => student.accountId)
        .whereType<int>()
        .toSet();
    _existingStudentId = _availableStudents.isEmpty
        ? null
        : _availableStudents.first.accountId;
  }

  @override
  void didUpdateWidget(covariant _UserRoleManagementWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allStudents != widget.allStudents ||
        oldWidget.assignedStudents != widget.assignedStudents) {
      _managedStudents = List.of(widget.allStudents);
      _assignedStudentIds = widget.assignedStudents
          .map((student) => student.accountId)
          .whereType<int>()
          .toSet();
      if (!_availableStudents.any(
        (student) => student.accountId == _existingStudentId,
      )) {
        _existingStudentId = _availableStudents.isEmpty
            ? null
            : _availableStudents.first.accountId;
      }
    }
  }

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
                  child: DropdownButtonFormField<int>(
                    initialValue: _existingStudentId,
                    decoration: const InputDecoration(labelText: '既存学生'),
                    items: [
                      for (final student in _availableStudents)
                        DropdownMenuItem(
                          value: student.accountId,
                          child: Text('${student.name} · ${student.email}'),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _existingStudentId = value);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _availableStudents.isEmpty
                      ? null
                      : _addExistingStudent,
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
          subtitle: '全学生のアカウント、メール、連絡先を確認します。',
        ),
        const SizedBox(height: 12),
        if (_managedStudents.isEmpty)
          const _InlineNotice(
            tone: _NoticeTone.warning,
            title: '学生データがありません',
            message: 'バックエンドに学生アカウントが登録されていません。',
          ),
        for (final student in _managedStudents)
          _UserRoleCard(
            name: student.name,
            email: student.email,
            role: '学生',
            status: student.status,
            phone: student.phone,
          ),
      ],
    );
  }

  Future<void> _createStudent() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('学生名、账号、初期密码を入力してください。')));
      return;
    }
    try {
      if (widget.classrooms.isNotEmpty) {
        final student = await ItClassApi.instance.createStudent(
          classroomId: widget.classrooms.first.id,
          programmingLanguage: widget.classrooms.first.programmingLanguage,
          realName: name,
          username: email,
          password: password,
          mobile: phone,
        );
        if (!mounted) return;
        setState(() {
          _managedStudents.add(student);
          if (student.accountId != null) {
            _assignedStudentIds.add(student.accountId!);
          }
        });
        await widget.onChanged();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('学生アカウント ${student.accountNo ?? ''} を作成しました。'),
          ),
        );
      } else {
        throw const ApiException('担当クラスがありません。');
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('学生作成に失敗しました：$error')));
    }
  }

  Future<void> _addExistingStudent() async {
    if (_existingStudentId == null) return;
    final existing = _managedStudents.firstWhere(
      (student) => student.accountId == _existingStudentId,
    );
    if (_assignedStudentIds.contains(existing.accountId)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${existing.name} はすでに一覧にあります。')));
      return;
    }
    try {
      if (widget.classrooms.isEmpty || existing.accountId == null) {
        throw const ApiException('担当クラスまたは学生IDがありません。');
      }
      await ItClassApi.instance.addExistingStudent(
        classroomId: widget.classrooms.first.id,
        studentAccountId: existing.accountId!,
      );
      if (!mounted) return;
      setState(() {
        _assignedStudentIds.add(existing.accountId!);
        _existingStudentId = _availableStudents.isEmpty
            ? null
            : _availableStudents.first.accountId;
      });
      await widget.onChanged();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${existing.name} を追加しました。')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('既存学生の追加に失敗しました：$error')));
    }
  }
}

class _UserRoleCard extends StatelessWidget {
  const _UserRoleCard({
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.phone,
  });

  final String name;
  final String email;
  final String role;
  final String status;
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(name.substring(0, 1))),
        title: Text(name),
        subtitle: Text('$email\n$status · $phone · パスワード設定済み'),
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
        subtitle: 'ニックネーム・メール',
        detail: 'ニックネームとメールを変更します。',
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
        detail: '現在のパスワードを確認して新しいパスワードに変更します。',
        onTap: () => onSelect(ProfileSettingSection.password),
      ),
      _CompactListCard(
        selected: selected == ProfileSettingSection.contact,
        title: '連絡先',
        subtitle: '電話番号',
        detail: '学校アカウントの電話番号を変更します。',
        onTap: () => onSelect(ProfileSettingSection.contact),
      ),
      _CompactListCard(
        selected: selected == ProfileSettingSection.basicInfo,
        title: 'アカウント情報',
        subtitle: 'プログラミング言語',
        detail: 'オンライン教室アカウントの学習言語を変更します。',
        onTap: () => onSelect(ProfileSettingSection.basicInfo),
      ),
    ],
  );
}

class _ProfileSettingsWorkspace extends StatefulWidget {
  const _ProfileSettingsWorkspace({
    required this.roleTitle,
    required this.roleSubtitle,
    required this.initialRealName,
    required this.initialNickname,
    required this.initialEmail,
    required this.initialPhone,
    required this.initialAvatar,
    required this.initialBasicInfo,
    required this.section,
    required this.onProfileChanged,
  });

  final String roleTitle;
  final String roleSubtitle;
  final String initialRealName;
  final String initialNickname;
  final String initialEmail;
  final String initialPhone;
  final String initialAvatar;
  final String initialBasicInfo;
  final ProfileSettingSection section;
  final ValueChanged<MemberProfile> onProfileChanged;

  @override
  State<_ProfileSettingsWorkspace> createState() =>
      _ProfileSettingsWorkspaceState();
}

class _ProfileSettingsWorkspaceState extends State<_ProfileSettingsWorkspace> {
  late final TextEditingController _nameController;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  late final TextEditingController _avatarController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _basicInfoController;
  late String _savedName;
  late String _savedEmail;
  late String _savedPhone;
  late String _savedAvatar;
  late String _savedRealName;
  late String _savedBasicInfo;
  bool _loadingProfile = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialNickname);
    _avatarController = TextEditingController(text: widget.initialAvatar);
    _phoneController = TextEditingController(text: widget.initialPhone);
    _emailController = TextEditingController(text: widget.initialEmail);
    _basicInfoController = TextEditingController(text: widget.initialBasicInfo);
    _savedName = widget.initialNickname.trim().isEmpty
        ? widget.initialRealName
        : widget.initialNickname;
    _savedEmail = widget.initialEmail;
    _savedPhone = widget.initialPhone;
    _savedAvatar = widget.initialAvatar;
    _savedRealName = widget.initialRealName;
    _savedBasicInfo = widget.initialBasicInfo;
    unawaited(_loadProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _oldPasswordController.dispose();
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
                      backgroundImage: _avatarController.text.isEmpty
                          ? null
                          : NetworkImage(_avatarController.text),
                      child: _avatarController.text.isEmpty
                          ? Text(
                              _nameController.text.isEmpty
                                  ? '学'
                                  : _nameController.text.substring(0, 1),
                              style: const TextStyle(
                                color: _AppPalette.sky,
                                fontWeight: FontWeight.w900,
                              ),
                            )
                          : null,
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
                if (_loadingProfile)
                  const LinearProgressIndicator()
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: _saving ? null : _saveProfile,
                        icon: const Icon(Icons.save_rounded),
                        label: Text(_saving ? '保存中' : '保存'),
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

  Future<void> _chooseAvatar() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _saving = true);
    try {
      final url = await ItClassApi.instance.uploadFile(
        result.files.single,
        directory: 'itclass/avatar',
      );
      if (!mounted) return;
      setState(() => _avatarController.text = url);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('アイコンをアップロードしました。保存すると反映されます。')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('アイコンのアップロードに失敗しました：$error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveProfile() async {
    if (widget.section == ProfileSettingSection.password &&
        _passwordController.text.length < 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('新しいパスワードは4文字以上で入力してください。')));
      return;
    }
    if (widget.section == ProfileSettingSection.password &&
        _passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('パスワードと確認パスワードが一致しません。')));
      return;
    }

    setState(() => _saving = true);
    try {
      if (widget.section == ProfileSettingSection.password) {
        if (_oldPasswordController.text.isEmpty) {
          throw const ApiException('現在のパスワードを入力してください。');
        }
        await ItClassApi.instance.updatePassword(
          oldPassword: _oldPasswordController.text,
          newPassword: _passwordController.text,
        );
      } else {
        final profile = await ItClassApi.instance.updateProfile(
          realName: _savedRealName,
          nickname: _nameController.text.trim(),
          email: _emailController.text.trim(),
          avatar: _avatarController.text.trim(),
          mobile: _phoneController.text.trim(),
          programmingLanguage: _basicInfoController.text.trim(),
        );
        if (!mounted) return;
        _applyProfile(profile);
      }
      if (!mounted) return;
      setState(() {
        _passwordController.clear();
        _confirmPasswordController.clear();
        _oldPasswordController.clear();
      });
      final message = widget.section == ProfileSettingSection.password
          ? 'パスワードを変更しました。'
          : 'プロフィールを保存しました。';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存に失敗しました：$error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _loadProfile() async {
    setState(() => _loadingProfile = true);
    try {
      final profile = await ItClassApi.instance.getCurrentUser();
      if (!mounted) return;
      _applyProfile(profile);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('プロフィール取得に失敗しました：$error')));
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  void _resetProfile() {
    setState(() {
      _nameController.text = _savedName;
      _emailController.text = _savedEmail;
      _passwordController.clear();
      _confirmPasswordController.clear();
      _oldPasswordController.clear();
      _avatarController.text = _savedAvatar;
      _phoneController.text = _savedPhone;
      _basicInfoController.text = _savedBasicInfo;
    });
  }

  void _applyProfile(MemberProfile profile) {
    setState(() {
      _savedRealName = profile.realName;
      _nameController.text = profile.nickname;
      _emailController.text = profile.email;
      _phoneController.text = profile.mobile;
      _avatarController.text = profile.avatar;
      _basicInfoController.text = profile.programmingLanguage;
      _savedName = profile.nickname.trim().isEmpty
          ? profile.realName
          : profile.nickname;
      _savedEmail = profile.email;
      _savedPhone = profile.mobile;
      _savedAvatar = profile.avatar;
      _savedBasicInfo = profile.programmingLanguage;
    });
    widget.onProfileChanged(profile);
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
                  labelText: 'ニックネーム',
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
                  backgroundImage: _avatarController.text.isEmpty
                      ? null
                      : NetworkImage(_avatarController.text),
                  child: _avatarController.text.isEmpty
                      ? Text(
                          _nameController.text.isEmpty
                              ? '学'
                              : _nameController.text.substring(0, 1),
                          style: const TextStyle(
                            color: _AppPalette.sky,
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                          ),
                        )
                      : null,
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
          TextField(
            controller: _oldPasswordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: '現在のパスワード',
              prefixIcon: Icon(Icons.password_rounded),
            ),
          ),
          const SizedBox(height: 10),
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
            maxLines: 1,
            decoration: const InputDecoration(
              labelText: 'プログラミング言語',
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
