import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class CubesScreen extends StatefulWidget {
  const CubesScreen({super.key});

  @override
  State<CubesScreen> createState() => _CubesScreenState();
}

class _CubesScreenState extends State<CubesScreen> {
  String _selectedRange = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<int> _filteredNumbers() {
    List<int> numbers = List.generate(AppConstants.maxCube, (i) => i + 1);

    if (_selectedRange == '1–10') {
      numbers = numbers.where((n) => n <= 10).toList();
    } else if (_selectedRange == '11–20') {
      numbers = numbers.where((n) => n >= 11 && n <= 20).toList();
    } else if (_selectedRange == '21–30') {
      numbers = numbers.where((n) => n >= 21 && n <= 30).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim();
      numbers = numbers.where((n) {
        final cube = n * n * n;
        return '$n'.contains(query) || '$cube'.contains(query);
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
              hintText: 'Search number or cube...',
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
            children: ['All', '1–10', '11–20', '21–30'].map((range) {
              final selected = _selectedRange == range;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(range == 'All' ? 'All (1–30)' : range),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedRange = range),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),

        // List / Grid of cubes
        Expanded(
          child: numbers.isEmpty
              ? Center(
                  child: Text(
                    'No cubes match "$_searchQuery"',
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
                    final cube = n * n * n;

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
                                        color: colorScheme.tertiary,
                                      ),
                                    ),
                                    Transform.translate(
                                      offset: const Offset(1, -6),
                                      child: Text(
                                        '³',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.tertiary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$n×$n×$n',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),

                            // Equals and Cube result
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
                                  '$cube',
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
