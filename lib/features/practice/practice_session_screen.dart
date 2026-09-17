import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/enums.dart';
import '../../providers/session_provider.dart';
import '../../widgets/numeric_keypad.dart';
import '../../widgets/question_card.dart';
import '../../widgets/timer_bar.dart';

class PracticeSessionScreen extends ConsumerStatefulWidget {
  final Operation operation;
  final DifficultyLevel difficulty;
  final int questionCount;
  final bool timedMode;
  final int timeLimitSeconds;
  final FeedbackMode feedbackMode;

  const PracticeSessionScreen({
    super.key,
    required this.operation,
    required this.difficulty,
    required this.questionCount,
    required this.timedMode,
    required this.timeLimitSeconds,
    required this.feedbackMode,
  });

  @override
  ConsumerState<PracticeSessionScreen> createState() => _PracticeSessionScreenState();
}

class _PracticeSessionScreenState extends ConsumerState<PracticeSessionScreen>
    with SingleTickerProviderStateMixin {
  String _currentInput = '';
  bool _showFeedback = false;
  bool _lastAnswerCorrect = false;
  int _remainingSeconds = 0;
  Timer? _questionTimer;

  // Feedback animation
  late AnimationController _feedbackController;
  late Animation<double> _feedbackOpacity;

  @override
  void initState() {
    super.initState();
    _feedbackController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _feedbackOpacity = Tween<double>(begin: 0, end: 1).animate(_feedbackController);
    _remainingSeconds = widget.timeLimitSeconds;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sessionProvider.notifier).startSession(
        widget.operation,
        widget.difficulty,
        widget.questionCount,
      );
      if (widget.timedMode) {
        _startQuestionTimer();
      }
    });
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    _questionTimer?.cancel();
    super.dispose();
  }

  void _startQuestionTimer() {
    _questionTimer?.cancel();
    setState(() => _remainingSeconds = widget.timeLimitSeconds);
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _remainingSeconds--);
      if (_remainingSeconds <= 0) {
        timer.cancel();
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    _submitAnswer(null); // timed out → mark incorrect
  }

  void _onDigitPressed(int digit) {
    if (_currentInput.length >= 6) return; // max 6 digits
    setState(() => _currentInput += '$digit');
  }

  void _onBackspace() {
    if (_currentInput.isNotEmpty) {
      setState(() => _currentInput = _currentInput.substring(0, _currentInput.length - 1));
    }
  }

  void _onSubmit() {
    if (_currentInput.isEmpty) return;
    final answer = int.tryParse(_currentInput);
    _submitAnswer(answer);
  }

  void _submitAnswer(int? answer) {
    _questionTimer?.cancel();
    
    final sessionState = ref.read(sessionProvider);
    final currentQ = sessionState.questions[sessionState.currentIndex];
    final isCorrect = answer == currentQ.correctAnswer;
    
    final notifier = ref.read(sessionProvider.notifier);
    notifier.submitAnswer(answer);

    if (widget.feedbackMode == FeedbackMode.instant) {
      _showInstantFeedback(isCorrect, isCorrect ? null : currentQ.correctAnswer);
    }
    _advance();
  }

  void _showInstantFeedback(bool isCorrect, int? correctAnswer) {
    setState(() {
      _showFeedback = true;
      _lastAnswerCorrect = isCorrect;
    });
    _feedbackController.forward(from: 0);

    // Subtle, rapid auto-fade (300ms) that does NOT block user typing
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _feedbackController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showFeedback = false;
            });
          }
        });
      }
    });
  }

  void _advance() {
    setState(() => _currentInput = '');
    final sessionState = ref.read(sessionProvider);
    final isLast = sessionState.currentIndex + 1 >= sessionState.questions.length;

    if (isLast) {
      ref.read(sessionProvider.notifier).completeSession();
      final finalState = ref.read(sessionProvider);
      // Build result from session state
      _navigateToResults(finalState);
    } else {
      ref.read(sessionProvider.notifier).nextQuestion();
      if (widget.timedMode) {
        _startQuestionTimer();
      }
    }
  }

  void _navigateToResults(dynamic sessionState) {
    context.go('/practice/results', extra: sessionState);
  }

  Future<bool> _onWillPop() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Practice?'),
        content: const Text('Your progress in this session will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Continue')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Exit')),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (sessionState.status == SessionStatus.idle ||
        sessionState.questions.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQ = sessionState.questions[sessionState.currentIndex];
    final progress = (sessionState.currentIndex) / sessionState.questions.length;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.go('/practice');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldExit = await _onWillPop();
              if (shouldExit && context.mounted) {
                context.go('/practice');
              }
            },
          ),
          title: Text(
            'Question ${sessionState.currentIndex + 1} of ${sessionState.questions.length}',
            style: theme.textTheme.titleMedium,
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: colorScheme.surfaceContainerHighest,
            ),
          ),
        ),
        body: Column(
          children: [
            // Timer bar (timed mode only)
            if (widget.timedMode)
              TimerBar(
                totalSeconds: widget.timeLimitSeconds,
                remainingSeconds: _remainingSeconds,
              ),

            // Streak indicator
            if (sessionState.streak > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange.shade600, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${sessionState.streak} streak!',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            // Question card area
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: QuestionCard(question: currentQ),
                  ),

                  // Instant rapid feedback pill (non-blocking)
                  if (_showFeedback)
                    Positioned(
                      top: 4,
                      child: FadeTransition(
                        opacity: _feedbackOpacity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: _lastAnswerCorrect
                                ? Colors.green.shade600
                                : colorScheme.error,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (_lastAnswerCorrect ? Colors.green : colorScheme.error).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _lastAnswerCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _lastAnswerCorrect ? 'Correct! +1' : 'Incorrect',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Numeric keypad
            SafeArea(
              child: NumericKeypad(
                currentInput: _currentInput,
                onDigitPressed: _onDigitPressed,
                onBackspace: _onBackspace,
                onSubmit: _currentInput.isEmpty ? null : _onSubmit,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
