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
      title: 'IT教師',
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
