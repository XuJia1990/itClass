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
    this.notificationIndices = const {},
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
  final Set<int> notificationIndices;

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
                  notificationIndices: notificationIndices,
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
            actions: [
              ...topActions,
              if (!tablet)
                Builder(
                  builder: (context) => IconButton(
                    tooltip: '一覧・絞り込み',
                    icon: const Icon(Icons.view_list_outlined),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
            ],
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
              notificationIndices: notificationIndices,
              activeIndex: activeIndex,
              onSelect: (index) {
                onSelect(index);
                Navigator.of(context).pop();
              },
              onLogout: onLogout,
              compact: true,
            ),
          ),
          endDrawer: tablet
              ? null
              : Drawer(
                  child: SafeArea(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Builder(
                            builder: (context) => IconButton(
                              tooltip: '一覧を閉じる',
                              icon: const Icon(Icons.close),
                              onPressed: () =>
                                  Scaffold.of(context).closeEndDrawer(),
                            ),
                          ),
                        ),
                        Expanded(child: middle),
                      ],
                    ),
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
    this.notificationIndices = const {},
  });

  final String profileName;
  final String profileRole;
  final List<MenuItem> items;
  final int activeIndex;
  final ValueChanged<int> onSelect;
  final VoidCallback onLogout;
  final bool compact;
  final Set<int> notificationIndices;

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
                  showNotificationDot: notificationIndices.contains(i),
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
    this.showNotificationDot = false,
  });

  final MenuItem item;
  final bool selected;
  final VoidCallback onTap;
  final bool showNotificationDot;

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
              if (showNotificationDot)
                _NotificationDot(label: '${item.label}：未対応の通知あり'),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationDot extends StatelessWidget {
  const _NotificationDot({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(left: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFEF4444),
        shape: BoxShape.circle,
      ),
    ),
  );
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
    this.showNotificationDot = false,
    this.notificationLabel = '未読メッセージあり',
  });

  final String title;
  final String subtitle;
  final String detail;
  final VoidCallback onTap;
  final bool selected;
  final String? badge;
  final bool showNotificationDot;
  final String notificationLabel;

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
                          color: badge == '未回答' || badge == '先生未回答'
                              ? const Color(0xFFFFF7ED)
                              : _AppPalette.wash,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            color: badge == '未回答' || badge == '先生未回答'
                                ? const Color(0xFFC2410C)
                                : const Color(0xFF047857),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    if (showNotificationDot)
                      _NotificationDot(label: notificationLabel),
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
    this.peerName = '',
  });

  final String title;
  final String emptyHint;
  final List<ChatMessage> messages;
  final TextEditingController controller;
  final String sendLabel;
  final VoidCallback onSend;
  final String peerName;

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
                  _MessageBubble(message: message, peerName: peerName),
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
  const _MessageBubble({
    required this.message,
    this.viewer = MessageAuthor.student,
    this.peerName = '',
  });

  final ChatMessage message;
  final MessageAuthor viewer;
  final String peerName;

  @override
  Widget build(BuildContext context) {
    final isStudent = message.author == MessageAuthor.student;
    final isTeacher = message.author == MessageAuthor.teacher;
    final currentAccountId = ItClassSession.current?.schoolAccountId;
    final isOwn =
        message.author != MessageAuthor.ai &&
        (message.senderAccountId != null && currentAccountId != null
            ? message.senderAccountId == currentAccountId
            : message.author == viewer);
    final senderName = message.senderName.trim().isNotEmpty
        ? message.senderName.trim()
        : peerName.trim();
    final label = message.author == MessageAuthor.ai
        ? 'AI'
        : senderName.isNotEmpty
        ? senderName
        : isTeacher
        ? '先生'
        : '学生';
    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 680),
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
    );

    if (isOwn) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(alignment: Alignment.centerRight, child: bubble),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 740),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Padding(
                  padding: const EdgeInsets.only(top: 13, right: 8),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: _AppPalette.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Flexible(child: bubble),
            ],
          ),
        ),
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
    setState(() {
      _scoring = true;
      _result = null;
    });
    try {
      final result = await widget.onScore();
      if (!mounted) return;
      setState(() => _result = result);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ApiException && error.code == 1004002046
                ? 'この言語の自動採点は未対応です。テストから提出するか、担当の先生へ相談してください。'
                : '採点に失敗しました：${userFacingError(error)}',
          ),
        ),
      );
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
    required this.practiceQuestions,
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
  final List<SchoolPracticeQuestion> practiceQuestions;

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
          _PracticeQuestionBankWorkspace(questions: widget.practiceQuestions)
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
                      onPressed: () =>
                          unawaited(_openDocument(lesson.documentUrl)),
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

  Future<void> _openDocument(String url) async {
    try {
      final lesson = widget.lesson;
      final detail = lesson.id == null
          ? lesson
          : await ItClassApi.instance.courseDocument(lesson.id!);
      if (!mounted) return;
      final uri = Uri.tryParse(detail.documentUrl);
      if (uri == null || !uri.hasScheme) {
        throw const ApiException('この教材を開けませんでした。一覧を更新してもう一度お試しください。');
      }
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(detail.title),
          content: Text(detail.fileName),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('閉じる'),
            ),
            FilledButton.icon(
              icon: const Icon(Icons.open_in_new),
              label: const Text('教材を開く'),
              onPressed: () async {
                final opened = await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                  webOnlyWindowName: '_blank',
                );
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                if (!opened && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ブラウザで教材を開けませんでした。')),
                  );
                }
              },
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('教材を開けませんでした：${userFacingError(error)}')),
        );
    }
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
  LearningVideo? _loadedVideo;
  int? _contentVersion;
  double? _progress;
  int _maxPositionSeconds = 0;
  bool _showPlayer = false;
  bool _loading = false;
  String? _error;
  String? _saveError;
  bool _reloadRequired = false;
  bool _markingWatched = false;
  bool _closingPlayer = false;
  bool _disposing = false;
  bool _hasPlaybackActivity = false;
  int _loadGeneration = 0;
  int _lastUiSecond = -1;
  int _lastReportedSecond = 0;
  bool _endedSaved = false;
  Future<bool>? _saveInFlight;
  bool _isFullscreen = false;
  PageRoute<void>? _fullscreenRoute;
  int _playerSurfaceVersion = 0;

  @override
  void dispose() {
    _disposing = true;
    unawaited(_saveCurrentPosition());
    _controller?.removeListener(_handlePlaybackProgress);
    _controller?.dispose();
    super.dispose();
  }

  double get _displayProgress => (_progress ?? widget.progress).clamp(0.0, 1.0);

  bool get _busy => _loading || _markingWatched || _closingPlayer;

  @override
  Widget build(BuildContext context) {
    final video = _loadedVideo ?? widget.video;
    final percent = (_displayProgress * 100).round();

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
                  child: LinearProgressIndicator(value: _displayProgress),
                ),
                const SizedBox(width: 12),
                Text(
                  '$percent%',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_reloadRequired) ...[
              const _InlineNotice(
                tone: _NoticeTone.warning,
                title: '動画が更新されました',
                message:
                    '再生を停止しました。最新の動画と学習進捗を再読み込みしてください。'
                    '変更前の進捗は新しい動画に引き継がれません。',
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _busy ? null : _initializePlayer,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('最新の動画を再読み込み'),
              ),
              const SizedBox(height: 12),
            ] else if (_saveError != null) ...[
              _InlineNotice(
                tone: _NoticeTone.warning,
                title: '進捗を保存できませんでした',
                message: _saveError!,
              ),
              const SizedBox(height: 12),
            ],
            if (_showPlayer) ...[
              _videoPlayerArea(),
              const SizedBox(height: 12),
            ],
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: _busy || _reloadRequired ? null : _togglePlayer,
                  icon: const Icon(Icons.play_circle_rounded),
                  label: Text(
                    _showPlayer
                        ? 'プレイヤーを閉じる'
                        : _displayProgress == 0
                        ? '視聴開始'
                        : '続きを見る',
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: _busy || _reloadRequired || _displayProgress >= 1.0
                      ? null
                      : _markWatched,
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text(_displayProgress >= 1.0 ? '視聴済み' : '視聴済みにする'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePlayer() async {
    if (_busy || _reloadRequired) return;
    if (_showPlayer) {
      setState(() => _closingPlayer = true);
      try {
        await _controller?.pause();
        await _saveCurrentPosition();
        if (!mounted || _disposing) return;
        setState(() => _showPlayer = false);
      } finally {
        if (mounted && !_disposing) setState(() => _closingPlayer = false);
      }
      return;
    }

    // Opening again refreshes the signed URL and the current file's progress.
    await _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (_busy || _disposing) return;
    setState(() => _showPlayer = true);
    await _prepareVideo(createPlayer: true);
  }

  Future<bool> _prepareVideo({required bool createPlayer}) async {
    if (_loading || _disposing) return false;
    setState(() {
      _loading = true;
      _error = null;
      _saveError = null;
    });

    VideoPlayerController? initializingController;
    try {
      // Let an already issued save settle before replacing its playback session.
      await _saveInFlight;
      if (!mounted || _disposing) return false;
      _loadGeneration++;
      final oldController = _controller;
      _controller = null;
      oldController?.removeListener(_handlePlaybackProgress);
      await oldController?.dispose();
      _loadedVideo = null;
      _contentVersion = null;
      _hasPlaybackActivity = false;
      _endedSaved = false;

      var video = widget.video;
      var position = video.lastPositionSeconds;
      var progress = video.progress;
      var maxPosition = position;
      final id = video.id;
      if (id != null) {
        final detail = await ItClassApi.instance.courseVideo(id);
        final saved = await ItClassApi.instance.videoProgress(id);
        // Progress has no contentVersion. Bracket it with detail reads so a
        // replacement during these requests cannot mix two file versions.
        video = await ItClassApi.instance.courseVideo(id);
        if (!mounted || _disposing) return false;
        if (detail.contentVersion != video.contentVersion) {
          _requireReload();
          return false;
        }
        position = _progressNumber(saved['lastPositionSeconds']).toInt();
        maxPosition = _progressNumber(saved['maxPositionSeconds']).toInt();
        progress = saved['completed'] == true
            ? 1.0
            : (_progressNumber(saved['progressPercent']) / 100).clamp(0.0, 1.0);
      }
      if (!mounted || _disposing) return false;
      position = position < 0 ? 0 : position;
      if (createPlayer) {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(video.videoUrl),
        );
        initializingController = controller;
        await controller.initialize();
        await controller.setLooping(false);
        final duration = controller.value.duration.inSeconds;
        position = position.clamp(0, duration > 0 ? duration : 0);
        if (position > 0) {
          await controller.seekTo(Duration(seconds: position));
        }
        if (!mounted || _disposing) return false;
      }
      setState(() {
        _loadedVideo = video;
        _contentVersion = video.contentVersion;
        _maxPositionSeconds = maxPosition < 0 ? 0 : maxPosition;
        _lastUiSecond = position;
        _lastReportedSecond = position;
        _reloadRequired = false;
        _controller = initializingController;
        _playerSurfaceVersion++;
      });
      _controller?.addListener(_handlePlaybackProgress);
      initializingController = null;
      // A zero-filled response is authoritative, even if the list said 100%.
      _publishProgress(progress);
      return true;
    } catch (error) {
      if (!mounted || _disposing) return false;
      if (error is ApiException && error.code == 1004002045) {
        _requireReload();
      } else {
        setState(() {
          _showPlayer = true;
          _error = '動画を読み込めませんでした：${userFacingError(error)}';
        });
      }
      return false;
    } finally {
      await initializingController?.dispose();
      if (mounted && !_disposing) setState(() => _loading = false);
    }
  }

  num _progressNumber(dynamic value) =>
      value is num ? value : num.tryParse('$value') ?? 0;

  void _publishProgress(double progress) {
    if (!mounted || _disposing) return;
    setState(() => _progress = progress.clamp(0.0, 1.0));
    widget.onProgressChanged(_progress!);
  }

  void _requireReload() {
    // Latch before pausing: pause emits controller notifications synchronously.
    _reloadRequired = true;
    _saveError = null;
    final controller = _controller;
    if (controller != null && !_disposing) unawaited(controller.pause());
    if (!mounted || _disposing) return;
    final route = _fullscreenRoute;
    if (route != null && route.isActive) route.navigator?.removeRoute(route);
    setState(() {});
  }

  void _handlePlaybackProgress() {
    if (_reloadRequired || _loading || _disposing || _markingWatched) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final position = controller.value.position.inSeconds;
    final duration = controller.value.duration.inSeconds;
    if (duration <= 0) return;
    final ended = controller.value.isCompleted || position >= duration;
    if (controller.value.isPlaying || position != _lastUiSecond) {
      _hasPlaybackActivity = true;
    }
    if (position != _lastUiSecond) {
      _lastUiSecond = position;
      if (position > _maxPositionSeconds) _maxPositionSeconds = position;
      final progress = (_maxPositionSeconds / duration).clamp(0.0, 1.0);
      if (progress > _displayProgress) _publishProgress(progress);
      if (mounted) setState(() {});
    }
    if (ended && !_endedSaved && _saveError == null) {
      _endedSaved = true;
      unawaited(_saveCurrentPosition(completed: true));
    } else if (!ended &&
        controller.value.isPlaying &&
        _saveInFlight == null &&
        _saveError == null &&
        (position - _lastReportedSecond).abs() >= 15) {
      _lastReportedSecond = position;
      unawaited(_saveCurrentPosition());
    }
  }

  Future<void> _markWatched() async {
    if (_busy || _reloadRequired || _disposing) return;
    setState(() => _markingWatched = true);
    try {
      // Without an open player, the list's duration and version may be stale.
      if (_controller == null && !await _prepareVideo(createPlayer: false)) {
        return;
      }
      if (!mounted || _disposing || _reloadRequired) return;
      await _controller?.pause();
      final duration =
          _controller?.value.duration.inSeconds ??
          _loadedVideo!.durationSeconds;
      final saved = await _savePosition(duration, duration, true);
      if (!saved || !mounted || _disposing || _reloadRequired) return;
      _endedSaved = true;
      _hasPlaybackActivity = false;
      _publishProgress(1.0);
      widget.onMarkWatched();
    } finally {
      if (mounted && !_disposing) setState(() => _markingWatched = false);
    }
  }

  Future<void> _saveCurrentPosition({bool completed = false}) async {
    if (_reloadRequired ||
        _loading ||
        _markingWatched ||
        !_hasPlaybackActivity) {
      return;
    }
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final duration = controller.value.duration.inSeconds;
    if (duration <= 0) return;
    final position = controller.value.position.inSeconds.clamp(0, duration);
    final ended =
        completed || controller.value.isCompleted || position >= duration;
    await _savePosition(position, duration, ended);
  }

  Future<bool> _savePosition(int position, int duration, bool ended) async {
    final generation = _loadGeneration;
    final video = _loadedVideo;
    final contentVersion = _contentVersion;
    // Serialize saves so a pending autosave cannot swallow mark-complete.
    while (_saveInFlight != null) {
      await _saveInFlight;
    }
    if (_reloadRequired ||
        _loading ||
        generation != _loadGeneration ||
        video == null ||
        contentVersion == null) {
      return false;
    }
    final request = _sendPosition(
      video,
      contentVersion,
      position,
      duration,
      ended,
    );
    _saveInFlight = request;
    try {
      return await request;
    } finally {
      if (identical(_saveInFlight, request)) _saveInFlight = null;
    }
  }

  Future<bool> _sendPosition(
    LearningVideo video,
    int contentVersion,
    int position,
    int duration,
    bool ended,
  ) async {
    try {
      if (video.id == null) {
        await widget.onPositionSaved(position, duration, ended);
      } else {
        // The legacy parent callback cannot carry a content version. Keep all
        // persisted player/mark-complete saves on this versioned API path.
        await ItClassApi.instance.saveVideoProgress(
          courseVideoId: video.id!,
          contentVersion: contentVersion,
          positionSeconds: position,
          durationSeconds: duration,
          ended: ended,
        );
      }
      if (mounted && !_disposing) setState(() => _saveError = null);
      return true;
    } catch (error) {
      if (error is ApiException && error.code == 1004002045) {
        _requireReload();
      } else if (mounted && !_disposing) {
        setState(
          () => _saveError = '通信状態を確認し、もう一度操作してください：${userFacingError(error)}',
        );
      }
      return false;
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

    if (_reloadRequired) return const SizedBox.shrink();

    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InlineNotice(
            tone: _NoticeTone.warning,
            title: '動画エラー',
            message: _error!,
          ),
          TextButton.icon(
            onPressed: _busy ? null : _initializePlayer,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('再読み込み'),
          ),
        ],
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
            child: _isFullscreen
                ? const ColoredBox(color: Color(0xFF111827))
                : ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: KeyedSubtree(
                      key: ValueKey(_playerSurfaceVersion),
                      child: VideoPlayer(controller),
                    ),
                  ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.filled(
                onPressed: _busy
                    ? null
                    : () async {
                        if (_reloadRequired || _disposing) return;
                        if (controller.value.isPlaying) {
                          await controller.pause();
                          await _saveCurrentPosition();
                        } else {
                          _endedSaved = false;
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
                  allowScrubbing: !_busy,
                  colors: const VideoProgressColors(
                    playedColor: _AppPalette.teal,
                    bufferedColor: Color(0xFF93C5FD),
                    backgroundColor: Color(0xFF374151),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _busy ? null : _openFullscreen,
                tooltip: '全画面表示',
                color: Colors.white,
                icon: const Icon(Icons.fullscreen_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openFullscreen() async {
    final controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        _busy ||
        _reloadRequired ||
        _disposing ||
        _isFullscreen) {
      return;
    }

    setState(() => _isFullscreen = true);
    await WidgetsBinding.instance.endOfFrame;

    try {
      if (!mounted || _disposing || _reloadRequired) return;
      final route = PageRouteBuilder<void>(
        opaque: true,
        fullscreenDialog: true,
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 140),
        pageBuilder: (context, animation, secondaryAnimation) =>
            _FullscreenVideoPlayer(
              controller: controller,
              title: (_loadedVideo ?? widget.video).title,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      );
      _fullscreenRoute = route;
      await Navigator.of(context).push<void>(route);
    } finally {
      _fullscreenRoute = null;
      if (mounted && !_disposing) {
        setState(() {
          _isFullscreen = false;
          _playerSurfaceVersion++;
        });
      }
    }

    await _saveCurrentPosition();
  }
}

class _FullscreenVideoPlayer extends StatefulWidget {
  const _FullscreenVideoPlayer({required this.controller, required this.title});

  final VideoPlayerController controller;
  final String title;

  @override
  State<_FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<_FullscreenVideoPlayer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final value = controller.value;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: AspectRatio(
                  aspectRatio: value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 12,
              right: 64,
              child: Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Colors.black, blurRadius: 6)],
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 4,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                tooltip: '全画面を終了',
                color: Colors.white,
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xCC111827),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () async {
                          if (value.isPlaying) {
                            await controller.pause();
                          } else {
                            await controller.play();
                          }
                        },
                        tooltip: value.isPlaying ? '一時停止' : '再生',
                        color: Colors.white,
                        icon: Icon(
                          value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                        ),
                      ),
                      Expanded(
                        child: VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: _AppPalette.teal,
                            bufferedColor: Color(0xFF93C5FD),
                            backgroundColor: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_formatDuration(value.position)} / '
                        '${_formatDuration(value.duration)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: '全画面を終了',
                        color: Colors.white,
                        icon: const Icon(Icons.fullscreen_exit_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PracticeQuestionBankWorkspace extends StatefulWidget {
  const _PracticeQuestionBankWorkspace({required this.questions});

  final List<SchoolPracticeQuestion> questions;

  @override
  State<_PracticeQuestionBankWorkspace> createState() =>
      _PracticeQuestionBankWorkspaceState();
}

class _PracticeQuestionBankWorkspaceState
    extends State<_PracticeQuestionBankWorkspace> {
  final Map<int, String> _selectedOptions = {};
  final Set<int> _checkedQuestions = {};

  @override
  void didUpdateWidget(covariant _PracticeQuestionBankWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldIds = oldWidget.questions.map((question) => question.id).toSet();
    final newIds = widget.questions.map((question) => question.id).toSet();
    if (oldIds.length != newIds.length || !oldIds.containsAll(newIds)) {
      _selectedOptions.clear();
      _checkedQuestions.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.questions;
    final checkedCount = questions
        .where((question) => _checkedQuestions.contains(question.id))
        .length;
    final correctCount = questions.where((question) {
      return _checkedQuestions.contains(question.id) &&
          _selectedOptions[question.id] == question.correctOption;
    }).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: Icons.account_tree_rounded,
          title: '問題バンク',
          subtitle: questions.isEmpty
              ? '各コースの学習内容に対応した練習問題です。'
              : '第${questions.first.chapterNo}課 · ${questions.first.lessonTitle} · $checkedCount/${questions.length}問確認済み',
        ),
        const SizedBox(height: 16),
        if (questions.isEmpty)
          const _InlineNotice(
            tone: _NoticeTone.warning,
            title: '問題データがありません',
            message: 'このコースの練習問題はまだ登録されていません。',
          ),
        if (checkedCount == questions.length && questions.isNotEmpty) ...[
          _InlineNotice(
            tone: correctCount == questions.length
                ? _NoticeTone.success
                : _NoticeTone.warning,
            title: 'この課の練習が完了しました',
            message:
                '$correctCount/${questions.length}問正解です。解析を確認してから次の課へ進みましょう。',
          ),
          const SizedBox(height: 12),
        ],
        for (var i = 0; i < questions.length; i++) ...[
          _PracticeQuestionCard(
            number: i + 1,
            question: questions[i],
            selectedOption: _selectedOptions[questions[i].id],
            checked: _checkedQuestions.contains(questions[i].id),
            onOptionSelected: (option) {
              setState(() {
                _selectedOptions[questions[i].id] = option;
                _checkedQuestions.remove(questions[i].id);
              });
            },
            onCheck: _selectedOptions[questions[i].id] == null
                ? null
                : () => setState(() => _checkedQuestions.add(questions[i].id)),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PracticeQuestionCard extends StatelessWidget {
  const _PracticeQuestionCard({
    required this.number,
    required this.question,
    required this.selectedOption,
    required this.checked,
    required this.onOptionSelected,
    required this.onCheck,
  });

  final int number;
  final SchoolPracticeQuestion question;
  final String? selectedOption;
  final bool checked;
  final ValueChanged<String> onOptionSelected;
  final VoidCallback? onCheck;

  @override
  Widget build(BuildContext context) {
    final correct = checked && selectedOption == question.correctOption;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  label: Text('第$number問'),
                  backgroundColor: const Color(0xFFEFF6FF),
                  side: const BorderSide(color: Color(0xFFBFDBFE)),
                ),
                Text(
                  question.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.content,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            for (final option in question.options) ...[
              _PracticeOptionTile(
                option: option,
                selected: selectedOption == option.key,
                checked: checked,
                correctOption: question.correctOption,
                onTap: () => onOptionSelected(option.key),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 6),
            FilledButton.icon(
              onPressed: onCheck,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text('解答を確認'),
            ),
            if (checked) ...[
              const SizedBox(height: 14),
              _InlineNotice(
                tone: correct ? _NoticeTone.success : _NoticeTone.warning,
                title: correct ? '正解です' : 'もう一度確認しましょう',
                message: '正解：${question.correctOption}\n${question.analysis}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PracticeOptionTile extends StatelessWidget {
  const _PracticeOptionTile({
    required this.option,
    required this.selected,
    required this.checked,
    required this.correctOption,
    required this.onTap,
  });

  final SchoolPracticeQuestionOption option;
  final bool selected;
  final bool checked;
  final String correctOption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCorrect = checked && option.key == correctOption;
    final isWrong = checked && selected && !isCorrect;
    final borderColor = isCorrect
        ? const Color(0xFF16A34A)
        : isWrong
        ? _AppPalette.coral
        : selected
        ? _AppPalette.teal
        : _AppPalette.line;
    final backgroundColor = isCorrect
        ? const Color(0xFFF0FDF4)
        : isWrong
        ? const Color(0xFFFFF1F2)
        : selected
        ? const Color(0xFFF0FDFA)
        : Colors.white;
    return Material(
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                isCorrect
                    ? Icons.check_circle_rounded
                    : isWrong
                    ? Icons.cancel_rounded
                    : selected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: borderColor,
              ),
              const SizedBox(width: 10),
              Text(
                option.key,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(option.content)),
            ],
          ),
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

class _TeacherRequestWorkspace extends StatelessWidget {
  const _TeacherRequestWorkspace({
    required this.request,
    required this.controller,
    required this.onSubmit,
    this.sending = false,
  });

  final TeacherRequest request;
  final bool sending;
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
                if (request.teacherReplies.isNotEmpty) ...[
                  const Divider(height: 26),
                  const Text('先生の回答履歴'),
                  const SizedBox(height: 8),
                  for (final answer in request.teacherReplies)
                    _MessageBubble(
                      message: answer,
                      viewer: MessageAuthor.teacher,
                    ),
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
            onPressed: sending ? null : onSubmit,
            icon: const Icon(Icons.send_rounded),
            label: Text(sending ? '送信中…' : '学生へ回答'),
          ),
        ),
      ],
    );
  }
}

class _TeacherChatWorkspace extends StatefulWidget {
  const _TeacherChatWorkspace({required this.student, required this.onRead});

  final StudentProfile student;
  final ValueChanged<int> onRead;

  @override
  State<_TeacherChatWorkspace> createState() => _TeacherChatWorkspaceState();
}

class _TeacherChatWorkspaceState extends State<_TeacherChatWorkspace> {
  final _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  StreamSubscription<ChatMessage>? _chatMessageSubscription;
  int? _conversationId;
  bool _loading = false;
  bool _sending = false;
  bool _loadingOlder = false;
  bool _hasOlder = false;
  String? _historyError;
  int _loadGeneration = 0;

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
    if (oldWidget.student.conversationId != widget.student.conversationId) {
      _conversationId = null;
      _controller.clear();
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
        Row(
          children: [
            const Text('会話履歴', style: TextStyle(fontWeight: FontWeight.w800)),
            const Spacer(),
            TextButton.icon(
              onPressed: _loading || _loadingOlder ? null : _loadConversation,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('更新'),
            ),
          ],
        ),
        if (_historyError != null)
          _InlineNotice(
            tone: _NoticeTone.warning,
            title: '会話履歴を読み込めませんでした',
            message: _historyError!,
          ),
        if (_hasOlder)
          TextButton(
            onPressed: _loading || _loadingOlder ? null : _loadOlderMessages,
            child: Text(_loadingOlder ? '読み込み中…' : '以前のメッセージを表示'),
          ),
        if (_loading)
          const Center(child: CircularProgressIndicator())
        else if (_messages.isEmpty && _historyError == null)
          const _InlineNotice(
            tone: _NoticeTone.warning,
            title: 'メッセージはありません',
            message: '最初のメッセージを送信できます。',
          )
        else
          for (final message in _messages)
            _MessageBubble(
              message: message,
              viewer: MessageAuthor.teacher,
              peerName: widget.student.name,
            ),
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
            onPressed: _loading || _sending ? null : _send,
            icon: const Icon(Icons.send_rounded),
            label: Text(_sending ? '送信中…' : '返信を送信'),
          ),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _loading || _sending) return;
    setState(() => _sending = true);
    try {
      final student = widget.student;
      if (student.conversationId == null) {
        throw const ApiException('会話を選択してください。');
      }
      final conversationId = student.conversationId!;
      _conversationId = conversationId;
      final message = await ItClassApi.instance.sendChatMessage(
        conversationId: conversationId,
        content: text,
      );
      if (!mounted || widget.student.conversationId != conversationId) return;
      setState(() {
        _upsertMessage(message);
        _controller.clear();
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('返信送信に失敗しました：${userFacingError(error)}')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _loadConversation() async {
    final generation = ++_loadGeneration;
    final conversationId = widget.student.conversationId;
    setState(() {
      _loading = true;
      _historyError = null;
      _hasOlder = false;
      _loadingOlder = false;
      if (_conversationId != conversationId) _messages.clear();
      // Listen for new messages while the history request is in flight too.
      _conversationId = conversationId;
    });
    try {
      if (conversationId == null) {
        throw const ApiException('会話を選択してください。');
      }
      final page = await ItClassApi.instance.chatMessagePage(conversationId);
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        for (final message in page.list) {
          _upsertMessage(message);
        }
        _hasOlder = page.total > _messages.length;
      });
      _markLatestStudentMessageRead(page.list);
    } catch (error) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() => _historyError = userFacingError(error));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('会話履歴の取得に失敗しました：${userFacingError(error)}')),
      );
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadOlderMessages() async {
    final conversationId = _conversationId;
    final ids = _messages
        .map((message) => message.id)
        .whereType<int>()
        .toList();
    if (conversationId == null || ids.isEmpty || _loadingOlder || _loading) {
      return;
    }
    final generation = _loadGeneration;
    final beforeId = ids.reduce((a, b) => a < b ? a : b);
    setState(() {
      _loadingOlder = true;
      _historyError = null;
    });
    try {
      final page = await ItClassApi.instance.chatMessagePage(
        conversationId,
        beforeMessageId: beforeId,
      );
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        for (final message in page.list) {
          _upsertMessage(message);
        }
        _hasOlder = page.list.isNotEmpty && page.total > page.list.length;
      });
      _markLatestStudentMessageRead(page.list);
    } catch (error) {
      if (mounted && generation == _loadGeneration) {
        setState(() => _historyError = userFacingError(error));
      }
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _loadingOlder = false);
      }
    }
  }

  void _handleRealtimeMessage(ChatMessage message) {
    if (!mounted || message.conversationId != _conversationId) return;
    setState(() => _upsertMessage(message));
    if (message.author == MessageAuthor.student && message.id != null) {
      unawaited(_readThrough(message.conversationId!, message.id!));
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
    _messages.sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
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
    unawaited(_readThrough(conversationId, latestId));
  }

  Future<void> _readThrough(int conversationId, int messageId) async {
    try {
      await ItClassApi.instance.readChatMessages(
        conversationId: conversationId,
        messageId: messageId,
      );
      if (mounted) widget.onRead(conversationId);
    } catch (error) {
      debugPrint('[itClass chat] read failed: $error');
    }
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
  final _testLanguageController = TextEditingController();
  final _durationController = TextEditingController(text: '0');
  final _attemptsController = TextEditingController(text: '0');
  int _selectedTestLesson = 0;
  int _questionCount = 3;
  List<ExamQuestion> _draftQuestions = const [];
  List<Lesson> _availableLessons = const [];
  Set<int> _teacherIds = _currentResponsibleTeacherIds();
  bool _loadingLessons = false;
  bool _generatingQuestions = false;
  bool _savingTest = false;
  String? _lessonError;
  String? _savedDraftSignature;
  final List<int> _savedQuestionIds = [];
  int? _savedPaperId;
  int _assessmentRevision = 0;

  @override
  void initState() {
    super.initState();
    if (widget.type == UploadMaterialType.test) {
      unawaited(_loadAvailableLessons());
    }
  }

  @override
  void didUpdateWidget(covariant _LearningUploadWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.type != widget.type &&
        widget.type == UploadMaterialType.test) {
      unawaited(_loadAvailableLessons());
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _testTitleController,
      _testCategoryController,
      _testLanguageController,
      _durationController,
      _attemptsController,
    ]) {
      controller.dispose();
    }
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
        if (widget.type != UploadMaterialType.test)
          _TeacherMaterialManagement(
            key: ValueKey(widget.type),
            kind: widget.type == UploadMaterialType.video
                ? _TeacherMaterialKind.video
                : _TeacherMaterialKind.document,
            classrooms: widget.classrooms,
          )
        else ...[
          if (_lessonError != null) ...[
            _InlineNotice(
              tone: _NoticeTone.warning,
              title: '教材取得エラー',
              message: _lessonError!,
            ),
            TextButton(
              onPressed: _loadAvailableLessons,
              child: const Text('教材を再取得'),
            ),
          ],
          if (_loadingLessons || _savingTest) const LinearProgressIndicator(),
          AbsorbPointer(
            absorbing: _savingTest || _generatingQuestions,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('保存完了後、すべての正常な学生が受験できます。'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _testLanguageController,
                      decoration: const InputDecoration(
                        labelText: 'プログラミング言語（分類・任意）',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '制限時間（分）',
                        helperText: '0 = 時間制限なし',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _attemptsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '受験可能回数',
                        helperText: '0 = 回数制限なし',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ResponsibleTeacherPicker(
                      selectedIds: _teacherIds,
                      existingTeachers: _currentResponsibleTeachers(),
                      enabled: !_savingTest,
                      onChanged: (ids) => setState(() => _teacherIds = ids),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AbsorbPointer(
            absorbing: _savingTest,
            child: _TeacherTestUploadPanel(
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
                _testLanguageController.text = lesson.level;
              }),
              onQuestionCountChanged: (count) =>
                  setState(() => _questionCount = count),
              onGenerate: _generateDraftQuestions,
              onAddQuestion: _addDraftQuestion,
              onQuestionChanged: _updateDraftQuestion,
              onDeleteQuestion: _deleteDraftQuestion,
              onUpload: _uploadDraftTest,
            ),
          ),
          if (_savingTest) const Text('問題・試験用紙・試験を保存中です…'),
          const SizedBox(height: 24),
          _TeacherAssessmentManagement(key: ValueKey(_assessmentRevision)),
        ],
      ],
    );
  }

  Future<void> _loadAvailableLessons() async {
    if (_loadingLessons) return;
    setState(() {
      _loadingLessons = true;
      _lessonError = null;
    });
    try {
      final docs = await ItClassApi.instance.courseDocuments();
      if (!mounted) return;
      setState(() {
        _availableLessons = docs.list;
        _selectedTestLesson = 0;
        if (_availableLessons.isNotEmpty && _testTitleController.text.isEmpty) {
          final lesson = _availableLessons.first;
          _testTitleController.text = '${lesson.title} テスト';
          _testCategoryController.text = lesson.level;
          _testLanguageController.text = lesson.level;
        }
      });
    } catch (error) {
      if (mounted) setState(() => _lessonError = userFacingError(error));
    } finally {
      if (mounted) setState(() => _loadingLessons = false);
    }
  }

  Future<void> _generateDraftQuestions() async {
    if (_availableLessons.isEmpty || _generatingQuestions || _savingTest) {
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
        programmingLanguage: _testLanguageController.text.trim(),
        topic: lesson.title,
        count: _questionCount,
      );
      if (mounted) setState(() => _draftQuestions = questions);
    } catch (error) {
      if (mounted) _notice('AI問題生成に失敗しました：${userFacingError(error)}');
    } finally {
      if (mounted) setState(() => _generatingQuestions = false);
    }
  }

  void _addDraftQuestion() {
    setState(
      () => _draftQuestions = [
        ..._draftQuestions,
        const ExamQuestion(
          topic: '',
          question: '',
          options: ['', '', '', ''],
          answerIndex: 0,
          explanation: '',
        ),
      ],
    );
  }

  Future<void> _uploadDraftTest() async {
    if (_savingTest || _generatingQuestions || _draftQuestions.isEmpty) return;
    final title = _testTitleController.text.trim();
    final duration = int.tryParse(_durationController.text.trim());
    final attempts = int.tryParse(_attemptsController.text.trim());
    if (duration == null || duration < 0 || attempts == null || attempts < 0) {
      _notice('制限時間と受験回数は0以上の整数を入力してください。0は無制限です。');
      return;
    }
    if (_teacherIds.isEmpty) {
      _notice('担当講師を1名以上選択してください。');
      return;
    }
    if (title.isEmpty ||
        _draftQuestions.any(
          (question) =>
              question.question.trim().isEmpty ||
              question.options.length < 2 ||
              question.options.any((option) => option.trim().isEmpty) ||
              question.answerIndex < 0 ||
              question.answerIndex >= question.options.length,
        )) {
      _notice('テスト名、問題文、すべての選択肢と正解を入力してください。');
      return;
    }
    final language = _testLanguageController.text.trim();
    if (language.length > 64) {
      _notice('プログラミング言語は64文字以内で入力してください。');
      return;
    }
    // Reuse completed stages after a later stage fails, provided the draft has
    // not changed. Saving never retries automatically or creates a second exam.
    final signature = jsonEncode([
      title,
      _testCategoryController.text.trim(),
      language,
      duration,
      attempts,
      _teacherIds.toList()..sort(),
      for (final question in _draftQuestions)
        [
          question.topic,
          question.question,
          question.options,
          question.answerIndex,
          question.explanation,
        ],
    ]);
    if (signature != _savedDraftSignature) {
      _savedDraftSignature = signature;
      _savedQuestionIds.clear();
      _savedPaperId = null;
    }
    setState(() => _savingTest = true);
    try {
      for (var i = _savedQuestionIds.length; i < _draftQuestions.length; i++) {
        final question = _draftQuestions[i];
        final id = await ItClassApi.instance.createQuestion(
          ExamQuestion(
            topic: question.topic.trim().isEmpty
                ? '$title 第${i + 1}問'
                : question.topic,
            question: question.question,
            options: question.options,
            answerIndex: question.answerIndex,
            explanation: question.explanation,
            type: questionTypeSingleChoice,
            score: 10,
          ),
          programmingLanguage: language,
          teacherAccountIds: _teacherIds.toList(),
        );
        if (id <= 0) throw const ApiException('問題の保存結果を確認できませんでした。');
        _savedQuestionIds.add(id);
      }
      _savedPaperId ??= await ItClassApi.instance.createPaper(
        title: title,
        description: _testCategoryController.text.trim(),
        questionIds: _savedQuestionIds,
        programmingLanguage: language,
        teacherAccountIds: _teacherIds.toList(),
        durationMinutes: duration,
      );
      if (_savedPaperId! <= 0) {
        _savedPaperId = null;
        throw const ApiException('試験用紙の保存結果を確認できませんでした。');
      }
      final examId = await ItClassApi.instance.createAndPublishExam(
        paperId: _savedPaperId!,
        title: title,
        description: _testCategoryController.text.trim(),
        durationMinutes: duration,
        maxAttempts: attempts,
        passScore: _draftQuestions.length * 6,
        teacherAccountIds: _teacherIds.toList(),
      );
      if (examId <= 0) throw const ApiException('試験の保存結果を確認できませんでした。');
      if (!mounted) return;
      setState(() {
        _draftQuestions = const [];
        _assessmentRevision++;
        _savedDraftSignature = null;
        _savedQuestionIds.clear();
        _savedPaperId = null;
      });
      _notice('テストを保存しました。学生はすぐに受験できます。');
    } catch (error) {
      if (mounted) _notice('テスト保存に失敗しました：${userFacingError(error)}');
    } finally {
      if (mounted) setState(() => _savingTest = false);
    }
  }

  void _notice(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _updateDraftQuestion(int index, ExamQuestion question) {
    setState(() {
      final updated = List<ExamQuestion>.of(_draftQuestions);
      updated[index] = question;
      _draftQuestions = updated;
    });
  }

  void _deleteDraftQuestion(int index) {
    setState(
      () =>
          _draftQuestions = List<ExamQuestion>.of(_draftQuestions)
            ..removeAt(index),
    );
  }
}

IconData _uploadTypeIcon(UploadMaterialType type) {
  switch (type) {
    case UploadMaterialType.video:
      return Icons.video_file_rounded;
    case UploadMaterialType.pdf:
      return Icons.description_rounded;
    case UploadMaterialType.test:
      return Icons.quiz_rounded;
  }
}

String _uploadTypeTitle(UploadMaterialType type) {
  switch (type) {
    case UploadMaterialType.video:
      return '共有動画管理';
    case UploadMaterialType.pdf:
      return '共有文書教材管理';
    case UploadMaterialType.test:
      return '共有テスト管理';
  }
}

String _uploadTypeSubtitle(UploadMaterialType type) {
  switch (type) {
    case UploadMaterialType.video:
      return '授業動画の登録・共有編集・公開状態を管理します。教室の指定は任意です。';
    case UploadMaterialType.pdf:
      return 'PDF、PowerPoint、Word の登録・共有編集・公開状態を管理します。';
    case UploadMaterialType.test:
      return '問題を作成・確認して保存すると、学生はすぐに受験できます。';
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
  final Future<bool> Function(PlatformFile file) onUpload;

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
                    onPressed: _uploading ? null : _pickFile,
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
    if (file == null || _uploading) return;
    setState(() => _uploading = true);
    try {
      final saved = await widget.onUpload(file);
      if (!mounted || !saved) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${file.name} をアップロードしました。')));
      setState(() => _selectedFile = null);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('アップロードに失敗しました：${userFacingError(error)}')),
      );
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
                            labelText: 'AI生成の参考教材（任意）',
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
                message: '手動で問題を追加して保存できます。AI生成には参考教材を選択してください。',
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
                  label: const Text('確認済みテストを保存'),
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
    required this.allStudents,
    required this.onChanged,
  });

  final SystemManagementSection section;
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
  bool _creatingStudent = false;

  @override
  void initState() {
    super.initState();
    _managedStudents = List.of(widget.allStudents);
  }

  @override
  void didUpdateWidget(covariant _UserRoleManagementWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.allStudents != widget.allStudents) {
      _managedStudents = List.of(widget.allStudents);
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
          subtitle: '学生アカウントを作成し、一覧を確認できます。',
        ),
        const SizedBox(height: 16),
        if (widget.section == SystemManagementSection.createStudent)
          _createStudentCard()
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
              '教室や言語の指定は不要です。作成後、全学生一覧に表示され、公共教材を利用できます。',
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
              onPressed: _creatingStudent ? null : _createStudent,
              icon: const Icon(Icons.person_add_alt_1_rounded),
              label: Text(_creatingStudent ? '作成中' : '学生アカウントを作成'),
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
            message: '学生アカウントはまだ登録されていません。',
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
    if (_creatingStudent) return;
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final phone = _phoneController.text.trim();
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('学生名、メール、初期パスワードを入力してください。')),
      );
      return;
    }
    setState(() => _creatingStudent = true);
    try {
      final student = await ItClassApi.instance.createStudent(
        realName: name,
        username: email,
        password: password,
        mobile: phone,
      );
      if (!mounted) return;
      setState(() {
        _managedStudents.add(student);
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _phoneController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('学生アカウント ${student.accountNo ?? ''} を作成しました。')),
      );
      try {
        await widget.onChanged();
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '作成は完了しましたが一覧を更新できませんでした：${userFacingError(error)}',
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('学生作成に失敗しました：${userFacingError(error)}')),
        );
      }
    } finally {
      if (mounted) setState(() => _creatingStudent = false);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('アイコンのアップロードに失敗しました：${userFacingError(error)}')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存に失敗しました：${userFacingError(error)}')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('プロフィール取得に失敗しました：${userFacingError(error)}')),
      );
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
                OutlinedButton.icon(
                  onPressed: _chooseAvatar,
                  icon: const Icon(Icons.image_rounded),
                  label: const Text('アイコンファイルを選択'),
                ),
              ],
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
