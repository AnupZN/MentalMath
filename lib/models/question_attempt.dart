import 'question.dart';

class QuestionAttempt {
  final Question question;
  final int? userAnswer;
  final bool isCorrect;
  final Duration responseTime;

  const QuestionAttempt({
    required this.question,
    this.userAnswer,
    required this.isCorrect,
    required this.responseTime,
  });

  factory QuestionAttempt.fromQuestion({
    required Question question,
    int? userAnswer,
    required Duration responseTime,
  }) {
    return QuestionAttempt(
      question: question,
      userAnswer: userAnswer,
      isCorrect: userAnswer == question.correctAnswer,
      responseTime: responseTime,
    );
  }

  QuestionAttempt copyWith({
    Question? question,
    int? userAnswer,
    bool? isCorrect,
    Duration? responseTime,
  }) {
    return QuestionAttempt(
      question: question ?? this.question,
      userAnswer: userAnswer ?? this.userAnswer,
      isCorrect: isCorrect ?? this.isCorrect,
      responseTime: responseTime ?? this.responseTime,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'question_id': question.id,
    'userAnswer': userAnswer,
    'isCorrect': isCorrect,
    'responseTimeMs': responseTime.inMilliseconds,
  };
}