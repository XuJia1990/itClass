part of '../main.dart';

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
                            'IT教師',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Web、iOS、Android に対応した AI プログラミング学習プラットフォーム。',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 20),
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
                            title: '学生ログイン',
                            subtitle: 'AI会話、学習資料、コード採点、テスト、先生への質問',
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
                            title: '先生ログイン',
                            subtitle: '学生の質問対応、コード確認、テスト分析',
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
