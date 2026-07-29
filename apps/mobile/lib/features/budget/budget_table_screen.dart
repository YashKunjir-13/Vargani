import 'package:flutter/material.dart';

import '../../shared/ui_kit/chips/status_chip.dart';
import '../../shared/ui_kit/overlays/bulk_action_bar.dart';
import 'models/budget_models.dart';

/// The full enterprise budget table -- its own screen rather than folded
/// into the Overview scroll, since search, column visibility, bulk export
/// and pagination need room the hub can't spare.
class BudgetTableScreen extends StatefulWidget {
  final List<BudgetCategoryData> categories;

  const BudgetTableScreen({super.key, required this.categories});

  @override
  State<BudgetTableScreen> createState() => _BudgetTableScreenState();
}

class _BudgetTableScreenState extends State<BudgetTableScreen> {
  final Set<String> _selected = {};
  String _query = '';
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<BudgetCategoryData> get _filtered {
    final list = _query.isEmpty
        ? widget.categories
        : widget.categories.where((c) => c.name.toLowerCase().contains(_query.toLowerCase())).toList();
    if (_sortColumnIndex == null) return list;
    final sorted = [...list];
    sorted.sort((a, b) {
      final result = switch (_sortColumnIndex) {
        1 => a.name.compareTo(b.name),
        4 => a.progress.compareTo(b.progress),
        _ => 0,
      };
      return _sortAscending ? result : -result;
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Details · ${widget.categories.length} categories'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.view_column_outlined)),
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
                    for (final category in rows)
                      DataRow(
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
                          DataCell(Text(category.allocatedLabel)),
                          DataCell(Text(category.spentLabel)),
                          DataCell(Text(category.percentLabel)),
                          DataCell(
                            StatusChip(
                              label: category.percentLabel,
                              type: category.progress >= 1.0
                                  ? StatusChipType.error
                                  : (category.progress >= 0.8 ? StatusChipType.warning : StatusChipType.success),
                            ),
                          ),
                        ],
                      ),
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
                Text('1-${rows.length} of ${widget.categories.length} categories'),
                Row(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
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
