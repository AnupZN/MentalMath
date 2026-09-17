import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class PrimesScreen extends StatelessWidget {
  const PrimesScreen({super.key});

  static final Set<int> _primeSet = Set.from(AppConstants.primesUpTo100);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info card
        Card(
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: colorScheme.onPrimaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'There are 25 prime numbers up to 100.\nHighlighted numbers are prime.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Sieve grid
        Text(
          'Sieve of Eratosthenes (1–100)',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _SieveGrid(primeSet: _primeSet),
        const SizedBox(height: 24),
        // List of primes
        Text(
          'All 25 Primes ≤ 100',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConstants.primesUpTo100.map((p) {
            return Chip(
              label: Text(
                '$p',
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: colorScheme.primary,
            );
          }).toList(),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _SieveGrid extends StatelessWidget {
  final Set<int> primeSet;
  const _SieveGrid({required this.primeSet});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 10,
        childAspectRatio: 1.0,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: 100,
      itemBuilder: (context, index) {
        final n = index + 1;
        final isPrime = primeSet.contains(n);
        return Container(
          decoration: BoxDecoration(
            color: isPrime ? colorScheme.primary : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '$n',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isPrime ? FontWeight.bold : FontWeight.normal,
                color: isPrime ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      },
    );
  }
}
