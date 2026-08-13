import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/ui_kit/chips/status_chip.dart';
import '../../shared/ui_kit/overlays/bulk_action_bar.dart';
import 'models/budget_models.dart';
import 'presentation/providers/budget_providers.dart';

String _formatCurrency(int paise) {
  return '₹${(paise / 100).round()}';
}

/// The full enterprise budget table
class BudgetTableScreen extends ConsumerStatefulWidget {
  const BudgetTableScreen({super.key});

  @override
  ConsumerState<BudgetTableScreen> createState() => _BudgetTableScreenState();
}

class _BudgetTableScreenState extends ConsumerState<BudgetTableScreen> {
  final Set<String> _selected = {};
  String _query = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<MockBudgetCategory> _getFiltered(List<MockBudgetCategory> categories) {
    final list = _query.isEmpty
        ? categories
        : categories
            .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();
    if (_sortColumnIndex == null) return list;
    final sorted = [...list];
    sorted.sort((a, b) {
      final aProgress =
          a.allocatedPaise > 0 ? (a.utilizedPaise / a.allocatedPaise) : 0.0;
      final bProgress =
          b.allocatedPaise > 0 ? (b.utilizedPaise / b.allocatedPaise) : 0.0;
      final result = switch (_sortColumnIndex) {
        0 => a.name.compareTo(b.name),
        3 => aProgress.compareTo(bProgress),
        _ => 0,
      };
      return _sortAscending ? result : -result;
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final budget = ref.watch(budgetProvider);
    if (budget == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Budget Details')),
        body: const Center(child: Text('Unauthorized or budget not found.')),
      );
    }

    final rows = _getFiltered(budget.categories);

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Details · ${budget.categories.length} categories'),
        actions: [
          IconButton(
              onPressed: () {}, icon: const Icon(Icons.view_column_outlined)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search categories…',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  sortColumnIndex: _sortColumnIndex,
                  sortAscending: _sortAscending,
                  showCheckboxColumn: true,
                  columns: [
                    DataColumn(
                      label: const Text('Category'),
                      onSort: (i, asc) => setState(() {
                        _sortColumnIndex = i;
                        _sortAscending = asc;
                      }),
                    ),
                    const DataColumn(label: Text('Allocated')),
                    const DataColumn(label: Text('Spent')),
                    DataColumn(
                      label: const Text('%'),
                      numeric: true,
                      onSort: (i, asc) => setState(() {
                        _sortColumnIndex = i;
                        _sortAscending = asc;
                      }),
                    ),
                    const DataColumn(label: Text('Status')),
                  ],
                  rows: [
                    for (final category in rows) ...[
                      () {
                        final progress = category.allocatedPaise > 0
                            ? (category.utilizedPaise / category.allocatedPaise)
                            : 0.0;
                        final percentLabel =
                            '${(progress * 100).toStringAsFixed(0)}%';
                        return DataRow(
                          selected: _selected.contains(category.id),
                          onSelectChanged: (selected) => setState(() {
                            if (selected ?? false) {
                              _selected.add(category.id);
                            } else {
                              _selected.remove(category.id);
                            }
                          }),
                          cells: [
                            DataCell(Text(category.name)),
                            DataCell(
                                Text(_formatCurrency(category.allocatedPaise))),
                            DataCell(
                                Text(_formatCurrency(category.utilizedPaise))),
                            DataCell(Text(percentLabel)),
                            DataCell(
                              StatusChip(
                                label: percentLabel,
                                type: progress >= 1.0
                                    ? StatusChipType.error
                                    : (progress >= 0.8
                                        ? StatusChipType.warning
                                        : StatusChipType.success),
                              ),
                            ),
                          ],
                        );
                      }()
                    ]
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '1-${rows.length} of ${budget.categories.length} categories'),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.chevron_left)),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.chevron_right)),
                  ],
                ),
              ],
            ),
          ),
          if (_selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: BulkActionBar(
                selectedCount: _selected.length,
                actions: [
                  BulkAction(label: 'Export', onPressed: () {}),
                  BulkAction(label: 'Change Owner', onPressed: () {}),
                ],
                onCancel: () => setState(_selected.clear),
              ),
            ),
        ],
      ),
    );
  }
}
