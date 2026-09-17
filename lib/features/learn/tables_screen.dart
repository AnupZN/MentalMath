import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../models/enums.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  bool _showPrimeTables = false;

  Color _tableColor(int tableNum, BuildContext context) {
    final colors = [
      Colors.indigo.shade500,
      Colors.blue.shade600,
      Colors.teal.shade600,
      Colors.green.shade600,
      Colors.orange.shade700,
      Colors.deepPurple.shade500,
    ];
    if (tableNum <= 5) return colors[0];
    if (tableNum <= 10) return colors[1];
    if (tableNum <= 15) return colors[2];
    if (tableNum <= 20) return colors[3];
    if (tableNum <= 25) return colors[4];
    return colors[5];
  }

  void _showTableDetail(BuildContext context, int tableNum, {bool isPrime = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _TableDetailSheet(tableNum: tableNum, isPrime: isPrime),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final numbers = _showPrimeTables
        ? AppConstants.primesUpTo100
        : List.generate(AppConstants.maxTable, (i) => i + 1);

    return Column(
      children: [
        // Mode toggle header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.grid_view_rounded, size: 18),
                label: Text('Tables 1–25'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.star_rounded, size: 18),
                label: Text('Prime Tables (≤100)'),
              ),
            ],
            selected: {_showPrimeTables},
            onSelectionChanged: (s) => setState(() => _showPrimeTables = s.first),
          ),
        ),

        // Explanatory chip banner
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Icon(
                _showPrimeTables ? Icons.auto_awesome : Icons.touch_app_outlined,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                _showPrimeTables
                    ? '25 Prime number multiplication tables (2 to 97)'
                    : 'Tap any table to view full 1× to 12× multiplications',
                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Grid of tables
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _showPrimeTables ? 4 : 5,
              childAspectRatio: 1.0,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: numbers.length,
            itemBuilder: (context, index) {
              final tableNum = numbers[index];
              final color = _showPrimeTables ? Colors.deepPurple.shade600 : _tableColor(tableNum, context);

              return InkWell(
                onTap: () => _showTableDetail(context, tableNum, isPrime: _showPrimeTables),
                borderRadius: BorderRadius.circular(14),
                child: Ink(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$tableNum',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _showPrimeTables ? 'table' : '×',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TableDetailSheet extends StatelessWidget {
  final int tableNum;
  final bool isPrime;

  const _TableDetailSheet({required this.tableNum, this.isPrime = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Table of $tableNum',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (isPrime)
                        Text(
                          'Prime multiplication table',
                          style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600),
                        ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go(
                        '/practice/session',
                        extra: {
                          'operation': Operation.tables.index,
                          'difficulty': DifficultyLevel.level6.index,
                          'count': 10,
                          'timed': false,
                          'timeLimit': 10,
                          'feedback': FeedbackMode.instant.index,
                        },
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Practice'),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: 12,
                itemBuilder: (context, index) {
                  final multiplier = index + 1;
                  final result = tableNum * multiplier;
                  final isEven = index.isEven;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isEven
                          ? colorScheme.surfaceContainerLow
                          : colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '$tableNum',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '×',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 32,
                          child: Text(
                            '$multiplier',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            '=',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          '$result',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
