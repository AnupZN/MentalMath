import os

base_dir = "/home/reed/Coding/MentalMath"

files = {
    "lib/services/persistence_service.dart": """import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/progress_data.dart';

class PersistenceService {
  final SharedPreferences _prefs;
  
  static const _settingsKey = 'app_settings';
  static const _progressKey = 'app_progress';

  PersistenceService(this._prefs);

  void saveSettings(AppSettings settings) {
    _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  AppSettings loadSettings() {
    final str = _prefs.getString(_settingsKey);
    if (str != null) {
      try {
        return AppSettings.fromJson(jsonDecode(str) as Map<String, dynamic>);
      } catch (_) {}
    }
    return const AppSettings();
  }

  void saveProgressData(ProgressData data) {
    _prefs.setString(_progressKey, jsonEncode(data.toJson()));
  }

  ProgressData loadProgressData() {
    final str = _prefs.getString(_progressKey);
    if (str != null) {
      try {
        return ProgressData.fromJson(jsonDecode(str) as Map<String, dynamic>);
      } catch (_) {}
    }
    return const ProgressData();
  }
}""",
    
    "lib/providers/shared_preferences_provider.dart": """import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at app startup');
});""",

    "lib/providers/settings_provider.dart": """import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings.dart';
import '../services/persistence_service.dart';
import 'shared_preferences_provider.dart';

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  late PersistenceService _persistenceService;

  @override
  FutureOr<AppSettings> build() {
    _persistenceService = PersistenceService(ref.watch(sharedPreferencesProvider));
    return _persistenceService.loadSettings();
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _persistenceService.saveSettings(settings);
      return settings;
    });
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);""",

    "lib/providers/progress_provider.dart": """import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/progress_data.dart';
import '../models/session_result.dart';
import '../services/persistence_service.dart';
import 'shared_preferences_provider.dart';

class ProgressNotifier extends AsyncNotifier<ProgressData> {
  late PersistenceService _persistenceService;

  @override
  FutureOr<ProgressData> build() {
    _persistenceService = PersistenceService(ref.watch(sharedPreferencesProvider));
    return _persistenceService.loadProgressData();
  }

  Future<void> addSessionResult(SessionResult result) async {
    final current = state.value ?? const ProgressData();
    final updated = ProgressData(sessions: [...current.sessions, result]);
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      _persistenceService.saveProgressData(updated);
      return updated;
    });
  }
}

final progressProvider = AsyncNotifierProvider<ProgressNotifier, ProgressData>(ProgressNotifier.new);""",

    "lib/providers/session_provider.dart": """import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/question.dart';
import '../models/question_attempt.dart';
import '../models/session_result.dart';
import '../services/question_generator.dart';
import '../services/scoring_service.dart';
import 'progress_provider.dart';
import 'package:uuid/uuid.dart';

enum SessionStatus { idle, inProgress, completed }

class SessionState {
  final SessionStatus status;
  final Operation? operation;
  final DifficultyLevel? difficulty;
  final List<Question> questions;
  final int currentIndex;
  final List<QuestionAttempt> attempts;
  final DateTime? startTime;
  final DateTime? questionStartTime;
  final int streak;
  final int bestStreak;
  final String sessionId;

  const SessionState({
    this.status = SessionStatus.idle,
    this.operation,
    this.difficulty,
    this.questions = const [],
    this.currentIndex = 0,
    this.attempts = const [],
    this.startTime,
    this.questionStartTime,
    this.streak = 0,
    this.bestStreak = 0,
    this.sessionId = '',
  });

  SessionState copyWith({
    SessionStatus? status,
    Operation? operation,
    DifficultyLevel? difficulty,
    List<Question>? questions,
    int? currentIndex,
    List<QuestionAttempt>? attempts,
    DateTime? startTime,
    DateTime? questionStartTime,
    int? streak,
    int? bestStreak,
    String? sessionId,
  }) {
    return SessionState(
      status: status ?? this.status,
      operation: operation ?? this.operation,
      difficulty: difficulty ?? this.difficulty,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      attempts: attempts ?? this.attempts,
      startTime: startTime ?? this.startTime,
      questionStartTime: questionStartTime ?? this.questionStartTime,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      sessionId: sessionId ?? this.sessionId,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  void startSession(Operation op, DifficultyLevel diff, int count) {
    final questions = QuestionGenerator.generate(operation: op, difficulty: diff, count: count);
    state = SessionState(
      status: SessionStatus.inProgress,
      operation: op,
      difficulty: diff,
      questions: questions,
      currentIndex: 0,
      attempts: [],
      startTime: DateTime.now(),
      questionStartTime: DateTime.now(),
      streak: 0,
      bestStreak: 0,
      sessionId: const Uuid().v4(),
    );
  }

  void startQuestionTimer() {
    state = state.copyWith(questionStartTime: DateTime.now());
  }

  void submitAnswer(int? answer) {
    if (state.status != SessionStatus.inProgress) return;
    
    final currentQ = state.questions[state.currentIndex];
    final isCorrect = answer == currentQ.correctAnswer;
    
    final now = DateTime.now();
    final responseTime = state.questionStartTime != null ? now.difference(state.questionStartTime!) : Duration.zero;

    final attempt = QuestionAttempt(
      question: currentQ,
      userAnswer: answer,
      isCorrect: isCorrect,
      responseTime: responseTime,
    );

    final newAttempts = [...state.attempts, attempt];
    final newStreak = isCorrect ? state.streak + 1 : 0;
    final newBest = newStreak > state.bestStreak ? newStreak : state.bestStreak;

    state = state.copyWith(
      attempts: newAttempts,
      streak: newStreak,
      bestStreak: newBest,
    );
  }

  void nextQuestion() {
    if (state.status != SessionStatus.inProgress) return;
    
    if (state.currentIndex + 1 < state.questions.length) {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        questionStartTime: DateTime.now(),
      );
    } else {
      completeSession();
    }
  }

  void completeSession() {
    if (state.status != SessionStatus.inProgress) return;

    final result = ScoringService.buildSessionResult(
      sessionId: state.sessionId,
      operation: state.operation!,
      difficulty: state.difficulty!,
      startTime: state.startTime!,
      totalTime: DateTime.now().difference(state.startTime!),
      attempts: state.attempts,
    );

    ref.read(progressProvider.notifier).addSessionResult(result);

    state = state.copyWith(status: SessionStatus.completed);
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);""",

    "lib/core/theme/app_theme.dart": """import 'package:flutter/material.dart';

class AppTheme {
  static const Color seedColor = Color(0xFF3F51B5); // Indigo
  
  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light),
      useMaterial3: true,
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark),
      useMaterial3: true,
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
    );
  }
}""",
    
    "lib/core/constants/app_constants.dart": """class AppConstants {
  static const int maxSquare = 30;
  static const int maxCube = 25;
  static const int maxTable = 25;
  static const List<int> primesUpTo100 = [2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97];
  static const List<int> questionCountOptions = [5, 10, 15, 20, 25, 30];
  static const List<int> timeLimitOptions = [10, 15, 20, 30, 45, 60];
}"""
}

for path, content in files.items():
    full_path = os.path.join(base_dir, path)
    os.makedirs(os.path.dirname(full_path), exist_ok=True)
    with open(full_path, "w") as f:
        f.write(content)
