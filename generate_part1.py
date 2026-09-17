import os
import json

base_dir = "/home/reed/Coding/MentalMath"

files = {
    "lib/models/enums.dart": """enum Operation { addition, subtraction, multiplication, division }
enum DifficultyLevel { level1, level2, level3, level4, level5, level6 }
enum FeedbackMode { instant, endOfSession }
enum ThemeModePreference { system, light, dark }
enum Grade { s, a, b, c, d }""",
    
    "lib/models/question.dart": """import 'enums.dart';

class Question {
  final String id;
  final Operation operation;
  final int operand1;
  final int operand2;
  final int correctAnswer;
  final DifficultyLevel difficulty;

  const Question({
    required this.id,
    required this.operation,
    required this.operand1,
    required this.operand2,
    required this.correctAnswer,
    required this.difficulty,
  });

  String get displayString => '$operand1 $operatorSymbol $operand2';

  String get operatorSymbol {
    switch (operation) {
      case Operation.addition: return '+';
      case Operation.subtraction: return '-';
      case Operation.multiplication: return '×';
      case Operation.division: return '÷';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Question &&
          other.id == id &&
          other.operation == operation &&
          other.operand1 == operand1 &&
          other.operand2 == operand2 &&
          other.correctAnswer == correctAnswer &&
          other.difficulty == difficulty;

  @override
  int get hashCode =>
      id.hashCode ^
      operation.hashCode ^
      operand1.hashCode ^
      operand2.hashCode ^
      correctAnswer.hashCode ^
      difficulty.hashCode;
}""",

    "lib/models/question_attempt.dart": """import 'question.dart';

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
}""",

    "lib/models/session_result.dart": """import 'enums.dart';
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
}""",

    "lib/models/app_settings.dart": """import 'enums.dart';

class AppSettings {
  final int questionCount;
  final bool timedMode;
  final int timeLimitSeconds;
  final FeedbackMode feedbackMode;
  final ThemeModePreference themeModePreference;

  const AppSettings({
    this.questionCount = 10,
    this.timedMode = false,
    this.timeLimitSeconds = 20,
    this.feedbackMode = FeedbackMode.instant,
    this.themeModePreference = ThemeModePreference.system,
  });

  AppSettings copyWith({
    int? questionCount,
    bool? timedMode,
    int? timeLimitSeconds,
    FeedbackMode? feedbackMode,
    ThemeModePreference? themeModePreference,
  }) {
    return AppSettings(
      questionCount: questionCount ?? this.questionCount,
      timedMode: timedMode ?? this.timedMode,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      feedbackMode: feedbackMode ?? this.feedbackMode,
      themeModePreference: themeModePreference ?? this.themeModePreference,
    );
  }

  Map<String, dynamic> toJson() => {
    'questionCount': questionCount,
    'timedMode': timedMode,
    'timeLimitSeconds': timeLimitSeconds,
    'feedbackMode': feedbackMode.name,
    'themeModePreference': themeModePreference.name,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      questionCount: json['questionCount'] as int? ?? 10,
      timedMode: json['timedMode'] as bool? ?? false,
      timeLimitSeconds: json['timeLimitSeconds'] as int? ?? 20,
      feedbackMode: FeedbackMode.values.firstWhere(
        (e) => e.name == json['feedbackMode'],
        orElse: () => FeedbackMode.instant,
      ),
      themeModePreference: ThemeModePreference.values.firstWhere(
        (e) => e.name == json['themeModePreference'],
        orElse: () => ThemeModePreference.system,
      ),
    );
  }
}""",

    "lib/models/progress_data.dart": """import 'session_result.dart';

class ProgressData {
  final List<SessionResult> sessions;

  const ProgressData({this.sessions = const []});

  int get totalSessions => sessions.length;
  int get totalCorrect => sessions.fold(0, (sum, s) => sum + s.correct);
  int get totalQuestions => sessions.fold(0, (sum, s) => sum + s.totalQuestions);
  
  double get overallAccuracy {
    if (totalQuestions == 0) return 0.0;
    return totalCorrect / totalQuestions;
  }

  int get bestStreak {
    if (sessions.isEmpty) return 0;
    return sessions.map((s) => s.bestStreak).reduce((a, b) => a > b ? a : b);
  }

  List<SessionResult> recentSessions(int n) {
    final sorted = List<SessionResult>.from(sessions)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    return sorted.take(n).toList();
  }

  Map<String, dynamic> toJson() => {
    'sessions': sessions.map((s) => s.toJson()).toList(),
  };

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    final list = json['sessions'] as List?;
    if (list == null) return const ProgressData();
    return ProgressData(
      sessions: list.map((e) => SessionResult.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}""",

    "lib/services/question_generator.dart": """import 'dart:math' as math;
import '../models/enums.dart';
import '../models/question.dart';

class QuestionGenerator {
  static final _random = math.Random();

  static List<Question> generate({
    required Operation operation,
    required DifficultyLevel difficulty,
    required int count,
  }) {
    final poolSize = math.min(count * 3, 200);
    final Set<String> seen = {};
    final List<Question> candidates = [];
    int attempts = 0;

    while (candidates.length < poolSize && attempts < poolSize * 5) {
      attempts++;
      int op1 = 0;
      int op2 = 0;

      switch (operation) {
        case Operation.addition:
          final pair = _generateAddition(difficulty);
          op1 = pair.$1;
          op2 = pair.$2;
          break;
        case Operation.subtraction:
          final pair = _generateSubtraction(difficulty);
          op1 = pair.$1;
          op2 = pair.$2;
          break;
        case Operation.multiplication:
          final pair = _generateMultiplication(difficulty);
          op1 = pair.$1;
          op2 = pair.$2;
          break;
        case Operation.division:
          final pair = _generateDivision(difficulty);
          op1 = pair.$1;
          op2 = pair.$2;
          break;
      }

      if (_validate(operation, op1, op2)) {
        final key = '\$op1,\$op2';
        if (!seen.contains(key)) {
          seen.add(key);
          candidates.add(_createQuestion(operation, difficulty, op1, op2, candidates.length));
        }
      }
    }

    candidates.shuffle(_random);

    if (candidates.length < count) {
      final additionalNeeded = count - candidates.length;
      for (int i = 0; i < additionalNeeded; i++) {
        final base = candidates[i % candidates.length];
        candidates.add(_createQuestion(operation, difficulty, base.operand1, base.operand2, candidates.length));
      }
    }

    return candidates.take(count).toList();
  }

  static Question _createQuestion(Operation op, DifficultyLevel diff, int op1, int op2, int index) {
    int ans = 0;
    switch (op) {
      case Operation.addition: ans = op1 + op2; break;
      case Operation.subtraction: ans = op1 - op2; break;
      case Operation.multiplication: ans = op1 * op2; break;
      case Operation.division: ans = op1 ~/ op2; break;
    }
    return Question(
      id: '\${op.name}_\${diff.name}_\${index}_\${DateTime.now().microsecondsSinceEpoch}',
      operation: op,
      operand1: op1,
      operand2: op2,
      correctAnswer: ans,
      difficulty: diff,
    );
  }

  static bool _validate(Operation op, int op1, int op2) {
    if (op == Operation.division && op2 == 0) return false;
    int ans = 0;
    switch (op) {
      case Operation.addition: ans = op1 + op2; break;
      case Operation.subtraction: ans = op1 - op2; break;
      case Operation.multiplication: ans = op1 * op2; break;
      case Operation.division: 
        if (op1 % op2 != 0) return false;
        ans = op1 ~/ op2; 
        break;
    }
    if (ans < 0) return false;
    return true;
  }

  static (int, int) _generateAddition(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.level1:
        return (_rand(1, 9), _rand(1, 9));
      case DifficultyLevel.level2:
        return _random.nextBool() ? (_rand(1, 9), _rand(10, 99)) : (_rand(10, 99), _rand(1, 9));
      case DifficultyLevel.level3:
        return (_rand(10, 99), _rand(10, 99));
      case DifficultyLevel.level4:
        return _random.nextBool() ? (_rand(1, 9), _rand(100, 999)) : (_rand(100, 999), _rand(1, 9));
      case DifficultyLevel.level5:
        return _random.nextBool() ? (_rand(10, 99), _rand(100, 999)) : (_rand(100, 999), _rand(10, 99));
      case DifficultyLevel.level6:
        return (_rand(100, 999), _rand(100, 999));
    }
  }

  static (int, int) _generateSubtraction(DifficultyLevel level) {
    int op1, op2;
    switch (level) {
      case DifficultyLevel.level1:
        op2 = _rand(1, 9);
        op1 = _rand(math.max(2, op2), 9);
        break;
      case DifficultyLevel.level2:
        op1 = _rand(10, 99);
        op2 = _rand(1, 9);
        break;
      case DifficultyLevel.level3:
        op2 = _rand(10, 99);
        op1 = _rand(op2, 99);
        break;
      case DifficultyLevel.level4:
        op1 = _rand(100, 999);
        op2 = _rand(1, 9);
        break;
      case DifficultyLevel.level5:
        op1 = _rand(100, 999);
        op2 = _rand(10, 99);
        break;
      case DifficultyLevel.level6:
        op2 = _rand(100, 999);
        op1 = _rand(op2, 999);
        break;
    }
    return (op1, op2);
  }

  static const _primes = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97];

  static (int, int) _generateMultiplication(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.level1:
        return (_rand(1, 5), _rand(2, 10));
      case DifficultyLevel.level2:
        return (_rand(6, 12), _rand(2, 10));
      case DifficultyLevel.level3:
        return (_rand(11, 15), _rand(2, 10));
      case DifficultyLevel.level4:
        return (_rand(16, 25), _rand(2, 10));
      case DifficultyLevel.level5:
        return (_primes[_rand(0, _primes.length - 1)], _rand(2, 10));
      case DifficultyLevel.level6:
        return (_rand(12, 99), _rand(2, 9));
    }
  }

  static (int, int) _generateDivision(DifficultyLevel level) {
    int divisor, quotient;
    switch (level) {
      case DifficultyLevel.level1:
        divisor = _rand(2, 5); quotient = _rand(2, 10); break;
      case DifficultyLevel.level2:
        divisor = _rand(2, 10); quotient = _rand(2, 12); break;
      case DifficultyLevel.level3:
        divisor = _rand(11, 15); quotient = _rand(2, 10); break;
      case DifficultyLevel.level4:
        divisor = _rand(16, 25); quotient = _rand(2, 10); break;
      case DifficultyLevel.level5:
        divisor = _rand(2, 9); quotient = _rand(10, 99); break;
      case DifficultyLevel.level6:
        final smallPrimes = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47];
        divisor = smallPrimes[_rand(0, smallPrimes.length - 1)];
        quotient = _rand(2, 10);
        break;
    }
    return (divisor * quotient, divisor);
  }

  static int _rand(int min, int max) => min + _random.nextInt(max - min + 1);
}""",

    "lib/services/scoring_service.dart": """import '../models/enums.dart';
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
      if (attempts[i].isCorrect) streak++;
      else break;
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
}"""
}

for path, content in files.items():
    full_path = os.path.join(base_dir, path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w") as f:
        f.write(content)
