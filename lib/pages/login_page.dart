part of '../main.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        color: _AppPalette.canvas,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth > 820;

                    return Flex(
                      direction: wide ? Axis.horizontal : Axis.vertical,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: wide ? 6 : 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _BrandHeader(),
                              const SizedBox(height: 28),
                              Text(
                                'AI と先生で、\nプログラミング学習をやさしく進める。',
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  height: 1.14,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Java 学習、コード採点、テスト、先生への質問をひとつにまとめた学習プラットフォームです。',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: _AppPalette.muted,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 22),
                              const Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _FeatureChip('AI質問解析'),
                                  _FeatureChip('コード採点'),
                                  _FeatureChip('Java学習'),
                                  _FeatureChip('テスト演習'),
                                  _FeatureChip('先生チャット'),
                                ],
                              ),
                              const SizedBox(height: 28),
                              const _LoginPreviewPanel(),
                            ],
                          ),
                        ),
                        SizedBox(width: wide ? 44 : 0, height: wide ? 0 : 24),
                        Expanded(
                          flex: wide ? 4 : 0,
                          child: Align(
                            alignment: Alignment.center,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 430),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _RoleLoginCard(
                                    title: '学生ログイン',
                                    subtitle: 'AI会話、学習資料、コード採点、テスト、先生への質問',
                                    icon: Icons.person_rounded,
                                    color: _AppPalette.teal,
                                    onTap: () =>
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                const StudentHomePage(),
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: 14),
                                  _RoleLoginCard(
                                    title: '先生ログイン',
                                    subtitle: '学生の質問対応、コード確認、テスト分析',
                                    icon: Icons.admin_panel_settings_rounded,
                                    color: _AppPalette.sky,
                                    onTap: () =>
                                        Navigator.of(context).pushReplacement(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                const TeacherHomePage(),
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: 18),
                                  const _LoginNote(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: _AppPalette.ink,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.school_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'IT教師',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            Text(
              'AI Programming Tutor',
              style: TextStyle(color: _AppPalette.muted),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoginPreviewPanel extends StatelessWidget {
  const _LoginPreviewPanel();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                _MiniStatusTile(
                  icon: Icons.psychology_alt_rounded,
                  label: 'AI質問',
                  value: '12件',
                  color: _AppPalette.teal,
                ),
                SizedBox(width: 10),
                _MiniStatusTile(
                  icon: Icons.quiz_rounded,
                  label: '本日の演習',
                  value: '84点',
                  color: _AppPalette.coral,
                ),
                SizedBox(width: 10),
                _MiniStatusTile(
                  icon: Icons.rate_review_rounded,
                  label: '先生対応',
                  value: '3件',
                  color: _AppPalette.sky,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _AppPalette.wash,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _AppPalette.line),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: _AppPalette.teal),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'HashMap の検索が速い理由を、例題とコードで確認しましょう。',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
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

class _MiniStatusTile extends StatelessWidget {
  const _MiniStatusTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _AppPalette.muted, fontSize: 12),
            ),
          ],
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
      side: const BorderSide(color: _AppPalette.line),
      backgroundColor: Colors.white,
      labelStyle: const TextStyle(
        color: _AppPalette.ink,
        fontWeight: FontWeight.w700,
      ),
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
                width: 50,
                height: 50,
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
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _AppPalette.muted,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginNote extends StatelessWidget {
  const _LoginNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AppPalette.washBlue,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _AppPalette.line),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: _AppPalette.sky, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '現在はデモ用ログインです。API 接続後に認証へ切り替えます。',
              style: TextStyle(color: _AppPalette.muted),
            ),
          ),
        ],
      ),
    );
  }
}
