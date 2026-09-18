import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/enums.dart';
import '../../models/question_attempt.dart';
import '../../providers/session_provider.dart';
import '../../services/scoring_service.dart';
import '../../widgets/grade_badge.dart';
import '../../widgets/stat_card.dart';

class PracticeResultsScreen extends StatelessWidget {
  final SessionState sessionState;

  const PracticeResultsScreen({
    super.key,
    required this.sessionState,
  });

  String _operationLabel(Operation? op) {
    switch (op) {
      case Operation.addition: return 'Addition';
      case Operation.subtraction: return 'Subtraction';
      case Operation.multiplication: return 'Multiplication';
      case Operation.division: return 'Division';
      case Operation.tables: return 'Tables';
      case Operation.square: return 'Squares';
      case Operation.cube: return 'Cubes';
      case null: return 'Practice';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final attempts = sessionState.attempts;
    final correct = attempts.where((a) => a.isCorrect).length;
    final total = attempts.length;
    final accuracy = ScoringService.calculateAccuracy(correct, total);
    final grade = ScoringService.calculateGrade(accuracy);
    final bestStreak = sessionState.bestStreak;
    final totalTime = sessionState.startTime != null
        ? DateTime.now().difference(sessionState.startTime!)
        : Duration.zero;
    final avgTime = ScoringService.calculateAvgResponseTime(attempts);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(sessionState.returnPath ?? '/practice');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            sessionState.targetNumber != null
                ? 'Results · Table of ${sessionState.targetNumber}'
                : 'Results · ${_operationLabel(sessionState.operation)}',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
            onPressed: () => context.go(sessionState.returnPath ?? '/practice'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.home_outlined),
              tooltip: 'Home',
              onPressed: () => context.go('/'),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Grade + summary card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    GradeBadge(grade: grade, size: 90),
                    const SizedBox(height: 20),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.check_circle_outline,
                            value: '$correct/$total',
                            label: 'Correct',
                            iconColor: Colors.green.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            icon: Icons.percent,
                            value: '${(accuracy * 100).toStringAsFixed(0)}%',
                            label: 'Accuracy',
                            iconColor: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            icon: Icons.local_fire_department,
                            value: '$bestStreak',
                            label: 'Best Streak',
                            iconColor: Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.timer_outlined,
                            value: _formatDuration(totalTime),
                            label: 'Total Time',
                            iconColor: colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatCard(
                            icon: Icons.speed_outlined,
                            value: total > 0 ? '${avgTime.inSeconds}s avg' : '--',
                            label: 'Per Question',
                            iconColor: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.go(sessionState.returnPath ?? '/practice'),
                    icon: Icon(sessionState.returnPath == '/learn' ? Icons.menu_book_outlined : Icons.tune),
                    label: Text(sessionState.returnPath == '/learn' ? 'Back to Tables' : 'Change'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () {
                      if (sessionState.targetNumber != null) {
                        context.go(
                          '/practice/session',
                          extra: {
                            'operation': sessionState.operation?.index ?? Operation.tables.index,
                            'difficulty': sessionState.difficulty?.index ?? DifficultyLevel.level1.index,
                            'count': sessionState.questions.length,
                            'timed': false,
                            'timeLimit': 20,
                            'feedback': FeedbackMode.instant.index,
                            'targetNumber': sessionState.targetNumber,
                            'returnPath': sessionState.returnPath ?? '/learn',
                          },
                        );
                      } else {
                        context.go('/practice');
                      }
                    },
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Practice Again'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Question review
            if (attempts.isNotEmpty) ...[
              Text(
                'Review',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...attempts.asMap().entries.map((entry) {
                final i = entry.key;
                final attempt = entry.value;
                return _AttemptTile(index: i + 1, attempt: attempt);
              }),
            ],
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m > 0) return '${m}m ${s}s';
    return '${d.inSeconds}s';
  }
}

class _AttemptTile extends StatelessWidget {
  final int index;
  final QuestionAttempt attempt;

  const _AttemptTile({required this.index, required this.attempt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final q = attempt.question;
    final isCorrect = attempt.isCorrect;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isCorrect
          ? Colors.green.withValues(alpha: 0.08)
          : colorScheme.errorContainer.withValues(alpha: 0.3),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCorrect ? Colors.green.shade600 : colorScheme.error,
          radius: 16,
          child: Icon(
            isCorrect ? Icons.check : Icons.close,
            color: Colors.white,
            size: 16,
          ),
        ),
        title: Text(
          '${q.displayString} = ${q.correctAnswer}',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isCorrect
              ? 'Your answer: ${attempt.userAnswer} · ${attempt.responseTime.inSeconds}s'
              : attempt.userAnswer == null
                  ? 'Timed out · ${attempt.responseTime.inSeconds}s'
                  : 'Your answer: ${attempt.userAnswer} · ${attempt.responseTime.inSeconds}s',
          style: theme.textTheme.bodySmall?.copyWith(
            color: isCorrect ? Colors.green.shade700 : colorScheme.error,
          ),
        ),
        trailing: Text(
          '#$index',
          style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}
