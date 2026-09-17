import 'package:flutter/material.dart';
import '../models/enums.dart';

/// Displays a grade (S/A/B/C/D) in a colored circular badge.
class GradeBadge extends StatelessWidget {
  final Grade grade;
  final double size;

  const GradeBadge({
    super.key,
    required this.grade,
    this.size = 80,
  });

  Color _bgColor(BuildContext context) {
    switch (grade) {
      case Grade.s: return Colors.purple.shade600;
      case Grade.a: return Colors.green.shade600;
      case Grade.b: return Colors.blue.shade600;
      case Grade.c: return Colors.orange.shade600;
      case Grade.d: return Theme.of(context).colorScheme.error;
    }
  }

  String get _label {
    switch (grade) {
      case Grade.s: return 'S';
      case Grade.a: return 'A';
      case Grade.b: return 'B';
      case Grade.c: return 'C';
      case Grade.d: return 'D';
    }
  }

  String get _description {
    switch (grade) {
      case Grade.s: return 'Superb!';
      case Grade.a: return 'Excellent!';
      case Grade.b: return 'Good';
      case Grade.c: return 'Fair';
      case Grade.d: return 'Keep Practicing';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _bgColor(context);
    final fontSize = size * 0.45;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            boxShadow: [
              BoxShadow(
                color: bgColor.withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              _label,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _description,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: bgColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
