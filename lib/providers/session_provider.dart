import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/enums.dart';
import '../models/question.dart';
import '../models/question_attempt.dart';
import '../services/question_generator.dart';
import '../services/scoring_service.dart';
import 'progress_provider.dart';

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
  final int? targetNumber;
  final String? returnPath;

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
    this.targetNumber,
    this.returnPath,
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
    int? targetNumber,
    String? returnPath,
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
      targetNumber: targetNumber ?? this.targetNumber,
      returnPath: returnPath ?? this.returnPath,
    );
  }
}

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() => const SessionState();

  void startSession(
    Operation op,
    DifficultyLevel diff,
    int count, {
    int? targetNumber,
    String? returnPath,
  }) {
    final questions = QuestionGenerator.generate(
      operation: op,
      difficulty: diff,
      count: count,
      targetNumber: targetNumber,
    );
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
      sessionId: 'session_${DateTime.now().microsecondsSinceEpoch}',
      targetNumber: targetNumber,
      returnPath: returnPath,
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

final sessionProvider = NotifierProvider<SessionNotifier, SessionState>(SessionNotifier.new);