import 'package:flutter/material.dart';

part 'pages/login_page.dart';
part 'pages/student_home_page.dart';
part 'pages/teacher_home_page.dart';
part 'shared/widgets.dart';
part 'shared/models.dart';
part 'shared/mock_data.dart';

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
      title: 'IT教師',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _AppPalette.sky,
          primary: _AppPalette.teal,
          secondary: _AppPalette.coral,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: _AppPalette.canvas,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: _AppPalette.ink,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: _AppPalette.line),
            borderRadius: BorderRadius.circular(8),
          ),
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _AppPalette.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _AppPalette.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: _AppPalette.teal, width: 1.4),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _AppPalette.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _AppPalette.ink,
            side: const BorderSide(color: _AppPalette.line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: _AppPalette.ink,
          displayColor: _AppPalette.ink,
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class _AppPalette {
  const _AppPalette._();

  static const canvas = Color(0xFFF6F8F7);
  static const paper = Color(0xFFFFFFFF);
  static const wash = Color(0xFFEFF8F6);
  static const washBlue = Color(0xFFEAF4FF);
  static const ink = Color(0xFF172033);
  static const muted = Color(0xFF667085);
  static const line = Color(0xFFE3E8EF);
  static const teal = Color(0xFF159A8C);
  static const sky = Color(0xFF4DA3D9);
  static const coral = Color(0xFFF08A72);
}
