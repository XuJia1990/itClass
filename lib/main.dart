import 'package:flutter/material.dart';

void main() {
  runApp(const ItClassApp());
}

class ItClassApp extends StatelessWidget {
  const ItClassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'itClass',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('itClass'), centerTitle: false),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 720;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Flex(
                  direction: wide ? Axis.horizontal : Axis.vertical,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: wide
                      ? CrossAxisAlignment.center
                      : CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: wide ? 5 : 0,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Build once. Learn anywhere.',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'A Flutter starter for web, Android, and iOS.',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 28),
                          FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text('Get started'),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: wide ? 48 : 0, height: wide ? 0 : 32),
                    Expanded(
                      flex: wide ? 4 : 0,
                      child: _PlatformPanel(theme: theme),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlatformPanel extends StatelessWidget {
  const _PlatformPanel({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final platforms = [
      _PlatformItem(Icons.public_rounded, 'Web'),
      _PlatformItem(Icons.android_rounded, 'Android'),
      _PlatformItem(Icons.phone_iphone_rounded, 'iOS'),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final platform in platforms)
              ListTile(
                leading: Icon(platform.icon, color: theme.colorScheme.primary),
                title: Text(platform.label),
                subtitle: const Text('Ready to run'),
              ),
          ],
        ),
      ),
    );
  }
}

class _PlatformItem {
  const _PlatformItem(this.icon, this.label);

  final IconData icon;
  final String label;
}
