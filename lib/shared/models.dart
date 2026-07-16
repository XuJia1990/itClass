part of '../main.dart';

class MenuItem {
  const MenuItem(this.icon, this.label, this.color);

  final IconData icon;
  final String label;
  final Color color;
}

class ChatMessage {
  const ChatMessage(this.author, this.text);

  factory ChatMessage.student(String text) {
    return ChatMessage(MessageAuthor.student, text);
  }

  factory ChatMessage.ai(String text) {
    return ChatMessage(MessageAuthor.ai, text);
  }

  factory ChatMessage.teacher(String text) {
    return ChatMessage(MessageAuthor.teacher, text);
  }

  final MessageAuthor author;
  final String text;
}

enum MessageAuthor { student, ai, teacher }

class Topic {
  const Topic(this.title, this.category, this.question, this.answer);

  final String title;
  final String category;
  final String question;
  final String answer;
}

class Lesson {
  const Lesson({
    required this.title,
    required this.level,
    required this.summary,
    required this.content,
    required this.code,
    required this.sections,
    required this.exercise,
    required this.aiSummary,
  });

  final String title;
  final String level;
  final String summary;
  final String content;
  final String code;
  final List<LessonSection> sections;
  final LessonExercise exercise;
  final String aiSummary;
}

class LessonSection {
  const LessonSection({
    required this.heading,
    required this.body,
    required this.keyPoints,
  });

  final String heading;
  final String body;
  final List<String> keyPoints;
}

class LessonExercise {
  const LessonExercise({
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.correctReason,
    required this.wrongReason,
    required this.standardAnswer,
  });

  final String question;
  final List<String> options;
  final int answerIndex;
  final String correctReason;
  final String wrongReason;
  final String standardAnswer;
}

class ExamQuestion {
  const ExamQuestion({
    required this.topic,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });

  final String topic;
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;
}

class ScoreResult {
  const ScoreResult({
    required this.score,
    required this.examTitle,
    required this.examDate,
    required this.correctItems,
    required this.deductions,
    required this.standardAnswer,
    required this.tips,
  });

  final int score;
  final String examTitle;
  final String examDate;
  final List<String> correctItems;
  final List<ScoreDeduction> deductions;
  final String standardAnswer;
  final List<String> tips;
}

class ScoreDeduction {
  const ScoreDeduction({
    required this.points,
    required this.title,
    required this.reason,
    required this.fix,
  });

  final int points;
  final String title;
  final String reason;
  final String fix;
}

class TeacherRequest {
  const TeacherRequest({
    required this.student,
    required this.category,
    required this.question,
    required this.aiAnswer,
    this.answered = false,
    this.teacherAnswer,
  });

  final String student;
  final String category;
  final String question;
  final String aiAnswer;
  final bool answered;
  final String? teacherAnswer;

  TeacherRequest copyWith({bool? answered, String? teacherAnswer}) {
    return TeacherRequest(
      student: student,
      category: category,
      question: question,
      aiAnswer: aiAnswer,
      answered: answered ?? this.answered,
      teacherAnswer: teacherAnswer ?? this.teacherAnswer,
    );
  }
}

class StudentProfile {
  const StudentProfile(this.name, this.status, this.lastQuestion);

  final String name;
  final String status;
  final String lastQuestion;
}

class ExamReport {
  const ExamReport(
    this.student,
    this.score,
    this.weakness,
    this.recommendation,
  );

  final String student;
  final int score;
  final String weakness;
  final String recommendation;
}

class CodeReviewItem {
  const CodeReviewItem(this.student, this.title, this.score, this.feedback);

  final String student;
  final String title;
  final int score;
  final String feedback;
}
