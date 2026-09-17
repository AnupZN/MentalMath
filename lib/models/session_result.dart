import 'enums.dart';
import 'question_attempt.dart';

class SessionResult {
  final String sessionId;
  final Operation operation;
  final DifficultyLevel difficulty;
  final DateTime startTime;
  final Duration totalTime;
  final int totalQuestions;
  final int correct;
  final int incorrect;
  final List<QuestionAttempt> attempts;
  final int streak;
  final int bestStreak;

  const SessionResult({
    required this.sessionId,
    required this.operation,
    required this.difficulty,
    required this.startTime,
    required this.totalTime,
    required this.totalQuestions,
    required this.correct,
    required this.incorrect,
    required this.attempts,
    required this.streak,
    required this.bestStreak,
  });

  double get accuracy => totalQuestions == 0 ? 0.0 : correct / totalQuestions;

  Grade get grade {
    final acc = accuracy * 100;
    if (acc >= 95) return Grade.s;
    if (acc >= 85) return Grade.a;
    if (acc >= 70) return Grade.b;
    if (acc >= 55) return Grade.c;
    return Grade.d;
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'operation': operation.name,
    'difficulty': difficulty.name,
    'startTime': startTime.toIso8601String(),
    'totalTimeMs': totalTime.inMilliseconds,
    'totalQuestions': totalQuestions,
    'correct': correct,
    'incorrect': incorrect,
    'streak': streak,
    'bestStreak': bestStreak,
  };

  factory SessionResult.fromJson(Map<String, dynamic> json) {
    return SessionResult(
      sessionId: json['sessionId'] as String,
      operation: Operation.values.firstWhere((e) => e.name == json['operation']),
      difficulty: DifficultyLevel.values.firstWhere((e) => e.name == json['difficulty']),
      startTime: DateTime.parse(json['startTime'] as String),
      totalTime: Duration(milliseconds: json['totalTimeMs'] as int),
      totalQuestions: json['totalQuestions'] as int,
      correct: json['correct'] as int,
      incorrect: json['incorrect'] as int,
      attempts: [], // Load attempts separately or skip if not needed in summary
      streak: json['streak'] as int,
      bestStreak: json['bestStreak'] as int,
    );
  }
}