import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/question.dart';

/// Displays a math question prominently with large, adaptive typography.
/// Scales down automatically on narrow phone screens.
class QuestionCard extends StatelessWidget {
  final Question question;
  final bool showAnswer;

  const QuestionCard({
    super.key,
    required this.question,
    this.showAnswer = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Adaptive font size: smaller on compact phones
    final double fontSize = screenWidth < 360 ? 36 : 45;
    final double operatorFontSize = screenWidth < 360 ? 32 : 40;
    final double hPadding = screenWidth < 360 ? 16.0 : 24.0;
    final double vPadding = screenWidth < 400 ? 20.0 : 28.0;

    final baseStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: colorScheme.onSurface,
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text('${question.operand1}', style: baseStyle),
                  if (question.operation == Operation.square || question.operation == Operation.cube) ...[
                    Transform.translate(
                      offset: const Offset(2, -14),
                      child: Text(
                        question.operation == Operation.square ? '2' : '3',
                        style: baseStyle.copyWith(
                          fontSize: fontSize * 0.6,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        question.operatorSymbol,
                        style: baseStyle.copyWith(
                          fontSize: operatorFontSize,
                          fontWeight: FontWeight.w300,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    Text('${question.operand2}', style: baseStyle),
                  ],
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '=',
                      style: baseStyle.copyWith(
                        fontWeight: FontWeight.w300,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    showAnswer ? '${question.correctAnswer}' : '?',
                    style: baseStyle.copyWith(
                      color: showAnswer
                          ? Colors.green.shade600
                          : colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
