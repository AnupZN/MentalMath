import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/enums.dart';
import '../../models/session_result.dart';
import '../../providers/progress_provider.dart';
import '../../widgets/grade_badge.dart';
import '../../widgets/stat_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(progressProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MentalMath'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero section
          _HeroSection(width: width),
          const SizedBox(height: 24),
          // Quick stats
          Text('Your Progress', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          progressAsync.when(
            data: (progress) => _StatsSection(
              totalSessions: progress.totalSessions,
              accuracy: progress.overallAccuracy,
              bestStreak: progress.bestStreak,
              colorScheme: colorScheme,
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const Text('Unable to load progress'),
          ),
          const SizedBox(height: 24),
          // Recent sessions
          Text('Recent Sessions', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          progressAsync.when(
            data: (progress) {
              final recent = progress.recentSessions(3);
              if (recent.isEmpty) {
                return _EmptySessionsCard(colorScheme: colorScheme);
              }
              return Column(
                children: recent.map((s) => _SessionTile(session: s)).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 80), // bottom nav clearance
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final double width;
  const _HeroSection({required this.width});

  @override
  Widget build(BuildContext context) {
    final isWide = width > 500;
    final cards = [
      _HeroCard(
        icon: Icons.menu_book_rounded,
        title: 'Learn',
        subtitle: 'Tables (inc. primes), squares & cubes',
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => context.go('/learn'),
      ),
      _HeroCard(
        icon: Icons.calculate_rounded,
        title: 'Practice',
        subtitle: 'Arithmetic, tables, squares & cubes',
        gradient: const LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () => context.go('/practice'),
      ),
    ];

    if (isWide) {
      return Row(
        children: cards.map((c) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: c))).toList(),
      );
    }
    return Column(
      children: [
        cards[0],
        const SizedBox(height: 12),
        cards[1],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _HeroCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 6,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 140,
          decoration: BoxDecoration(gradient: gradient),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 48),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final int totalSessions;
  final double accuracy;
  final int bestStreak;
  final ColorScheme colorScheme;

  const _StatsSection({
    required this.totalSessions,
    required this.accuracy,
    required this.bestStreak,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.analytics_outlined,
            value: '$totalSessions',
            label: 'Sessions',
            iconColor: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            icon: Icons.percent_rounded,
            value: totalSessions == 0 ? '--' : '${(accuracy * 100).toStringAsFixed(0)}%',
            label: 'Accuracy',
            iconColor: Colors.green.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            icon: Icons.local_fire_department_rounded,
            value: '$bestStreak',
            label: 'Best Streak',
            iconColor: Colors.orange.shade600,
          ),
        ),
      ],
    );
  }
}

class _EmptySessionsCard extends StatelessWidget {
  final ColorScheme colorScheme;
  const _EmptySessionsCard({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.emoji_events_outlined, size: 48, color: colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'No sessions yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a practice session or explore the Learn section to begin your mental math journey!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final SessionResult session;
  const _SessionTile({required this.session});

  String _operationLabel(Operation op) {
    switch (op) {
      case Operation.addition: return 'Addition';
      case Operation.subtraction: return 'Subtraction';
      case Operation.multiplication: return 'Multiplication';
      case Operation.division: return 'Division';
      case Operation.tables: return 'Tables';
      case Operation.square: return 'Squares';
      case Operation.cube: return 'Cubes';
    }
  }

  String _diffLabel(DifficultyLevel l) => 'Level ${l.index + 1}';

  void _showSessionDetails(BuildContext context, SessionResult s) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateStr = DateFormat('MMMM d, y • HH:mm').format(s.startTime);
    final totalSec = s.totalTime.inSeconds;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            GradeBadge(grade: s.grade, size: 72),
            const SizedBox(height: 12),
            Text(
              '${_operationLabel(s.operation)} — ${_diffLabel(s.difficulty)}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              dateStr,
              style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: StatCard(
                    icon: Icons.check_circle_outline,
                    value: '${s.correct}/${s.totalQuestions}',
                    label: 'Correct',
                    iconColor: Colors.green.shade600,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icon: Icons.percent,
                    value: '${(s.accuracy * 100).toStringAsFixed(0)}%',
                    label: 'Accuracy',
                    iconColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatCard(
                    icon: Icons.timer_outlined,
                    value: '${totalSec}s',
                    label: 'Duration',
                    iconColor: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateStr = DateFormat('MMM d, HH:mm').format(session.startTime);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => _showSessionDetails(context, session),
        leading: GradeBadge(grade: session.grade, size: 40),
        title: Text(
          '${_operationLabel(session.operation)} · ${_diffLabel(session.difficulty)}',
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${session.correct}/${session.totalQuestions} correct · ${(session.accuracy * 100).toStringAsFixed(0)}%',
          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dateStr,
              style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
