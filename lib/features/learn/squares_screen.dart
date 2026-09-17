import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class SquaresScreen extends StatefulWidget {
  const SquaresScreen({super.key});

  @override
  State<SquaresScreen> createState() => _SquaresScreenState();
}

class _SquaresScreenState extends State<SquaresScreen> {
  String _selectedRange = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<int> _filteredNumbers() {
    List<int> numbers = List.generate(AppConstants.maxSquare, (i) => i + 1);

    if (_selectedRange == '1–15') {
      numbers = numbers.where((n) => n <= 15).toList();
    } else if (_selectedRange == '16–30') {
      numbers = numbers.where((n) => n >= 16 && n <= 30).toList();
    } else if (_selectedRange == '31–50') {
      numbers = numbers.where((n) => n >= 31 && n <= 50).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim();
      numbers = numbers.where((n) {
        final square = n * n;
        return '$n'.contains(query) || '$square'.contains(query);
      }).toList();
    }

    return numbers;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final numbers = _filteredNumbers();
    final width = MediaQuery.sizeOf(context).width;
    final columns = width > 700 ? 3 : 2;

    return Column(
      children: [
        // Search and filter row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search number or square...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: colorScheme.outlineVariant),
              ),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),

        // Range chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: ['All', '1–15', '16–30', '31–50'].map((range) {
              final selected = _selectedRange == range;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(range == 'All' ? 'All (1–50)' : range),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedRange = range),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),

        // List / Grid of squares
        Expanded(
          child: numbers.isEmpty
              ? Center(
                  child: Text(
                    'No squares match "$_searchQuery"',
                    style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    childAspectRatio: 2.1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: numbers.length,
                  itemBuilder: (context, index) {
                    final n = numbers[index];
                    final square = n * n;
                    final delta = n > 1 ? (square - (n - 1) * (n - 1)) : 0;

                    return Card(
                      elevation: 1.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      color: colorScheme.surfaceContainerLow,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Base and power notation
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '$n',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(1, -6),
                                      child: Text(
                                        '²',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (delta > 0)
                                  Text(
                                    '+$delta diff',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 10,
                                    ),
                                  ),
                              ],
                            ),

                            // Equals and Square result
                            Row(
                              children: [
                                Text(
                                  '=',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$square',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
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
