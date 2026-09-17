import '../models/enums.dart';
import '../models/question_attempt.dart';
import '../models/session_result.dart';

class ScoringService {
  static Grade calculateGrade(double accuracy) {
    final acc = accuracy * 100;
    if (acc >= 95) return Grade.s;
    if (acc >= 85) return Grade.a;
    if (acc >= 70) return Grade.b;
    if (acc >= 55) return Grade.c;
    return Grade.d;
  }

  static int calculateStreak(List<QuestionAttempt> attempts) {
    int streak = 0;
    for (int i = attempts.length - 1; i >= 0; i--) {
      if (attempts[i].isCorrect) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  static int calculateBestStreak(List<QuestionAttempt> attempts) {
    int best = 0;
    int current = 0;
    for (final attempt in attempts) {
      if (attempt.isCorrect) {
        current++;
        if (current > best) best = current;
      } else {
        current = 0;
      }
    }
    return best;
  }

  static double calculateAccuracy(int correct, int total) {
    if (total == 0) return 0.0;
    return correct / total;
  }

  static Duration calculateAvgResponseTime(List<QuestionAttempt> attempts) {
    if (attempts.isEmpty) return Duration.zero;
    final totalMs = attempts.fold(0, (sum, a) => sum + a.responseTime.inMilliseconds);
    return Duration(milliseconds: totalMs ~/ attempts.length);
  }

  static SessionResult buildSessionResult({
    required String sessionId,
    required Operation operation,
    required DifficultyLevel difficulty,
    required DateTime startTime,
    required Duration totalTime,
    required List<QuestionAttempt> attempts,
  }) {
    final correct = attempts.where((a) => a.isCorrect).length;
    final total = attempts.length;
    
    return SessionResult(
      sessionId: sessionId,
      operation: operation,
      difficulty: difficulty,
      startTime: startTime,
      totalTime: totalTime,
      totalQuestions: total,
      correct: correct,
      incorrect: total - correct,
      attempts: attempts,
      streak: calculateStreak(attempts),
      bestStreak: calculateBestStreak(attempts),
    );
  }
}