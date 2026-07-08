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
  });

  final String title;
  final String level;
  final String summary;
  final String content;
  final String code;
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
  const ScoreResult(this.score, this.tips);

  final int score;
  final List<String> tips;
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
