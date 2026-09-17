import 'package:flutter/material.dart';

/// Animated timer bar showing remaining time with color feedback.
/// Green > 50%, Orange > 20%, Red <= 20%
class TimerBar extends StatelessWidget {
  final int totalSeconds;
  final int remainingSeconds;

  const TimerBar({
    super.key,
    required this.totalSeconds,
    required this.remainingSeconds,
  });

  Color _barColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (totalSeconds == 0) return colorScheme.primary;
    final fraction = remainingSeconds / totalSeconds;
    if (fraction > 0.5) return Colors.green.shade600;
    if (fraction > 0.2) return Colors.orange.shade600;
    return colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fraction = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    final barColor = _barColor(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: barColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: fraction, end: fraction),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 10,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${remainingSeconds}s',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: barColor,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
