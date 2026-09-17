import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../models/enums.dart';
import '../../providers/settings_provider.dart';

class PracticeHomeScreen extends ConsumerStatefulWidget {
  const PracticeHomeScreen({super.key});

  @override
  ConsumerState<PracticeHomeScreen> createState() => _PracticeHomeScreenState();
}

class _PracticeHomeScreenState extends ConsumerState<PracticeHomeScreen> {
  Operation _selectedOp = Operation.addition;
  DifficultyLevel _selectedLevel = DifficultyLevel.level1;
  int _questionCount = 10;
  bool _timedMode = false;
  int _timeLimitSeconds = 20;
  FeedbackMode _feedbackMode = FeedbackMode.instant;
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadSettings());
  }

  void _loadSettings() {
    final settingsAsync = ref.read(settingsProvider);
    settingsAsync.whenData((settings) {
      if (!_settingsLoaded) {
        setState(() {
          _questionCount = settings.questionCount;
          _timedMode = settings.timedMode;
          _timeLimitSeconds = settings.timeLimitSeconds;
          _feedbackMode = settings.feedbackMode;
          _settingsLoaded = true;
        });
      }
    });
  }

  String _opName(Operation op) {
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

  IconData _opIcon(Operation op) {
    switch (op) {
      case Operation.addition: return Icons.add;
      case Operation.subtraction: return Icons.remove;
      case Operation.multiplication: return Icons.close;
      case Operation.division: return Icons.percent;
      case Operation.tables: return Icons.table_chart_outlined;
      case Operation.square: return Icons.superscript_rounded;
      case Operation.cube: return Icons.category_outlined;
    }
  }

  String _levelDescription(Operation op, DifficultyLevel level) {
    switch (op) {
      case Operation.addition:
        switch (level) {
          case DifficultyLevel.level1: return '1-digit + 1-digit  (e.g. 3 + 7)';
          case DifficultyLevel.level2: return 'Mixed 1 & 2-digit  (e.g. 6 + 24)';
          case DifficultyLevel.level3: return '2-digit + 2-digit  (e.g. 34 + 57)';
          case DifficultyLevel.level4: return '1-digit + 3-digit  (e.g. 6 + 234)';
          case DifficultyLevel.level5: return '2-digit + 3-digit  (e.g. 45 + 234)';
          case DifficultyLevel.level6: return '3-digit + 3-digit  (e.g. 234 + 567)';
        }
      case Operation.subtraction:
        switch (level) {
          case DifficultyLevel.level1: return '1-digit − 1-digit  (e.g. 9 − 4)';
          case DifficultyLevel.level2: return '2-digit − 1-digit  (e.g. 45 − 7)';
          case DifficultyLevel.level3: return '2-digit − 2-digit  (e.g. 78 − 35)';
          case DifficultyLevel.level4: return '3-digit − 1-digit  (e.g. 456 − 7)';
          case DifficultyLevel.level5: return '3-digit − 2-digit  (e.g. 456 − 78)';
          case DifficultyLevel.level6: return '3-digit − 3-digit  (e.g. 876 − 345)';
        }
      case Operation.multiplication:
        switch (level) {
          case DifficultyLevel.level1: return 'Tables 1–5 × 1–10  (e.g. 4 × 7)';
          case DifficultyLevel.level2: return 'Tables 6–12 × 1–10  (e.g. 8 × 9)';
          case DifficultyLevel.level3: return 'Tables 11–15 × 1–10  (e.g. 13 × 7)';
          case DifficultyLevel.level4: return 'Tables 16–25 × 1–10  (e.g. 19 × 8)';
          case DifficultyLevel.level5: return 'Prime tables ≤100  (e.g. 17 × 6)';
          case DifficultyLevel.level6: return '2-digit × 1-digit  (e.g. 34 × 7)';
        }
      case Operation.division:
        switch (level) {
          case DifficultyLevel.level1: return 'Divide by 2–5  (e.g. 24 ÷ 4)';
          case DifficultyLevel.level2: return 'Divide by 2–10  (e.g. 56 ÷ 7)';
          case DifficultyLevel.level3: return 'Divide by 11–15  (e.g. 91 ÷ 13)';
          case DifficultyLevel.level4: return 'Divide by 16–25  (e.g. 144 ÷ 18)';
          case DifficultyLevel.level5: return '3-digit ÷ 1-digit  (e.g. 672 ÷ 7)';
          case DifficultyLevel.level6: return 'Divide by prime  (e.g. 133 ÷ 19)';
        }
      case Operation.tables:
        switch (level) {
          case DifficultyLevel.level1: return 'Tables 2–5 × 1–10';
          case DifficultyLevel.level2: return 'Tables 6–10 × 1–10';
          case DifficultyLevel.level3: return 'Tables 11–15 × 1–10';
          case DifficultyLevel.level4: return 'Tables 16–20 × 1–10';
          case DifficultyLevel.level5: return 'Tables 21–25 × 1–10';
          case DifficultyLevel.level6: return 'Prime Tables (2–97 × 1–10)';
        }
      case Operation.square:
        switch (level) {
          case DifficultyLevel.level1: return 'Squares 1² – 10²';
          case DifficultyLevel.level2: return 'Squares 11² – 15²';
          case DifficultyLevel.level3: return 'Squares 16² – 20²';
          case DifficultyLevel.level4: return 'Squares 21² – 25²';
          case DifficultyLevel.level5: return 'Squares 26² – 30²';
          case DifficultyLevel.level6: return 'Squares 31² – 50²';
        }
      case Operation.cube:
        switch (level) {
          case DifficultyLevel.level1: return 'Cubes 1³ – 5³';
          case DifficultyLevel.level2: return 'Cubes 6³ – 10³';
          case DifficultyLevel.level3: return 'Cubes 11³ – 15³';
          case DifficultyLevel.level4: return 'Cubes 16³ – 20³';
          case DifficultyLevel.level5: return 'Cubes 21³ – 25³';
          case DifficultyLevel.level6: return 'Cubes 1³ – 30³ (Speed Mix)';
        }
    }
  }

  Widget _buildOpTile(Operation op, ColorScheme colorScheme, ThemeData theme) {
    final selected = _selectedOp == op;
    return GestureDetector(
      onTap: () => setState(() => _selectedOp = op),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: selected ? colorScheme.primaryContainer : colorScheme.surfaceContainerLow,
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _opIcon(op),
              color: selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              _opName(op),
              style: theme.textTheme.titleSmall?.copyWith(
                color: selected ? colorScheme.primary : colorScheme.onSurface,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startSession() {
    context.go(
      '/practice/session',
      extra: {
        'operation': _selectedOp.index,
        'difficulty': _selectedLevel.index,
        'count': _questionCount,
        'timed': _timedMode,
        'timeLimit': _timeLimitSeconds,
        'feedback': _feedbackMode.index,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Practice')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Operation selector
          Text('Arithmetic', style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              Operation.addition,
              Operation.subtraction,
              Operation.multiplication,
              Operation.division,
            ].map((op) => _buildOpTile(op, colorScheme, theme)).toList(),
          ),
          const SizedBox(height: 14),
          Text('Powers & Tables', style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Operation.tables,
              Operation.square,
              Operation.cube,
            ].map((op) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: SizedBox(
                  height: 48,
                  child: _buildOpTile(op, colorScheme, theme),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),

          // Difficulty selector
          Text('Difficulty Level', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: DifficultyLevel.values.map((level) {
              final selected = _selectedLevel == level;
              final label = 'L${level.index + 1}';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedLevel = level),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 44,
                      decoration: BoxDecoration(
                        color: selected ? colorScheme.primary : colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          label,
                          style: TextStyle(
                            color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          // Level description
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: ValueKey(_selectedOp.name + _selectedLevel.name),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _levelDescription(_selectedOp, _selectedLevel),
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Configuration
          Text('Session Settings', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                // Question count
                Row(
                  children: [
                    const Icon(Icons.quiz_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text('Questions', style: theme.textTheme.bodyMedium),
                    const Spacer(),
                    DropdownButton<int>(
                      value: _questionCount,
                      underline: const SizedBox.shrink(),
                      items: AppConstants.questionCountOptions
                          .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                          .toList(),
                      onChanged: (v) => setState(() => _questionCount = v!),
                    ),
                  ],
                ),
                const Divider(),
                // Timed mode (timer per question)
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 20),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Timer per question', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                        Text('Countdown for each question', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                    const Spacer(),
                    Switch(
                      value: _timedMode,
                      onChanged: (v) => setState(() => _timedMode = v),
                    ),
                  ],
                ),
                if (_timedMode) ...[
                  const Divider(),
                  Row(
                    children: [
                      const Icon(Icons.speed_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text('Time limit', style: theme.textTheme.bodyMedium),
                      const Spacer(),
                      DropdownButton<int>(
                        value: _timeLimitSeconds,
                        underline: const SizedBox.shrink(),
                        items: AppConstants.timeLimitOptions
                            .map((n) => DropdownMenuItem(value: n, child: Text('${n}s per question')))
                            .toList(),
                        onChanged: (v) => setState(() => _timeLimitSeconds = v!),
                      ),
                    ],
                  ),
                ],
                const Divider(),
                // Feedback mode
                Row(
                  children: [
                    const Icon(Icons.flash_on_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text('Feedback', style: theme.textTheme.bodyMedium),
                    const Spacer(),
                    SegmentedButton<FeedbackMode>(
                      segments: const [
                        ButtonSegment(value: FeedbackMode.instant, label: Text('Rapid')),
                        ButtonSegment(value: FeedbackMode.endOfSession, label: Text('End')),
                      ],
                      selected: {_feedbackMode},
                      onSelectionChanged: (s) => setState(() => _feedbackMode = s.first),
                    ),
                  ],
                ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Start button
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: _startSession,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Practice', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
