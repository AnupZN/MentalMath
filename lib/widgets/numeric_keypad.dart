import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A custom numeric keypad widget that avoids the system keyboard.
/// Provides digit input, backspace, and submit callbacks.
class NumericKeypad extends StatelessWidget {
  final String currentInput;
  final bool disabled;
  final VoidCallback? onSubmit;
  final Function(int digit) onDigitPressed;
  final VoidCallback onBackspace;

  const NumericKeypad({
    super.key,
    required this.currentInput,
    required this.onDigitPressed,
    required this.onBackspace,
    this.onSubmit,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Input display
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: currentInput.isEmpty
                  ? colorScheme.outlineVariant
                  : colorScheme.primary,
              width: currentInput.isEmpty ? 1 : 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  currentInput.isEmpty ? 'Enter answer...' : currentInput,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: currentInput.isEmpty
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Keypad grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildRow(context, [7, 8, 9]),
              const SizedBox(height: 8),
              _buildRow(context, [4, 5, 6]),
              const SizedBox(height: 8),
              _buildRow(context, [1, 2, 3]),
              const SizedBox(height: 8),
              _buildBottomRow(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, List<int> digits) {
    return Row(
      children: digits
          .map((d) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _DigitButton(
                    digit: d,
                    disabled: disabled,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onDigitPressed(d);
                    },
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        // Backspace
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              height: 64,
              child: FilledButton.tonal(
                onPressed: disabled
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        onBackspace();
                      },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Icon(
                  Icons.backspace_outlined,
                  color: disabled ? colorScheme.onSurfaceVariant : colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ),
        // Zero
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _DigitButton(
              digit: 0,
              disabled: disabled,
              onPressed: () {
                HapticFeedback.lightImpact();
                onDigitPressed(0);
              },
            ),
          ),
        ),
        // Submit
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              height: 64,
              child: FilledButton(
                onPressed: (disabled || currentInput.isEmpty || onSubmit == null)
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        onSubmit!();
                      },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: colorScheme.primary,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DigitButton extends StatelessWidget {
  final int digit;
  final bool disabled;
  final VoidCallback onPressed;

  const _DigitButton({
    required this.digit,
    required this.disabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 64,
      child: FilledButton.tonal(
        onPressed: disabled ? null : onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          '$digit',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
