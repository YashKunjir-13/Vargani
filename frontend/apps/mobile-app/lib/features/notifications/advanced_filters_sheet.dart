import 'package:flutter/material.dart';

import '../../shared/ui_kit/buttons/primary_button.dart';
import '../../shared/ui_kit/buttons/secondary_button.dart';
import '../../shared/ui_kit/surfaces/app_bottom_sheet.dart';

/// Notifications' advanced filter sheet -- read status, priority, category
/// and date range all apply simultaneously (additive facets, not a single
/// dropdown), per the approved spec.
class NotificationFiltersSheet extends StatefulWidget {
  const NotificationFiltersSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show<void>(context,
        builder: (_) => const NotificationFiltersSheet());
  }

  @override
  State<NotificationFiltersSheet> createState() =>
      _NotificationFiltersSheetState();
}

class _NotificationFiltersSheetState extends State<NotificationFiltersSheet> {
  final Set<String> _readStatus = {'Unread'};
  final Set<String> _priorities = {'Critical', 'High'};
  final Set<String> _categories = {'Budget'};
  String _dateRange = 'Today';

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: 'Filters',
      trailing: TextButton(
        onPressed: () => setState(() {
          _readStatus
            ..clear()
            ..add('Unread');
          _priorities
            ..clear()
            ..addAll(['Critical', 'High']);
          _categories
            ..clear()
            ..add('Budget');
          _dateRange = 'Today';
        }),
        child: const Text('Reset'),
      ),
      actions: [
        SecondaryButton(
            label: 'Clear all', onPressed: () => Navigator.of(context).pop()),
        PrimaryButton(
            label: 'Apply (4)', onPressed: () => Navigator.of(context).pop()),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MultiChipGroup(
              label: 'Read status',
              options: const ['Unread', 'Read'],
              selected: _readStatus),
          const SizedBox(height: 20),
          _MultiChipGroup(
            label: 'Priority',
            options: const ['Critical', 'High', 'Medium', 'Low'],
            selected: _priorities,
          ),
          const SizedBox(height: 20),
          _MultiChipGroup(
            label: 'Category',
            options: const [
              'Financial',
              'Budget',
              'Audit',
              'Receipts',
              'Vendors',
              'Milestones'
            ],
            selected: _categories,
          ),
          const SizedBox(height: 20),
          _FilterGroup(
            label: 'Date range',
            child: Wrap(
              spacing: 8,
              children: [
                for (final range in [
                  'Today',
                  'Yesterday',
                  'Last 7 Days',
                  'Last 30 Days',
                  'Custom'
                ])
                  ChoiceChip(
                    label: Text(range),
                    selected: _dateRange == range,
                    onSelected: (_) => setState(() => _dateRange = range),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MultiChipGroup extends StatefulWidget {
  final String label;
  final List<String> options;
  final Set<String> selected;

  const _MultiChipGroup(
      {required this.label, required this.options, required this.selected});

  @override
  State<_MultiChipGroup> createState() => _MultiChipGroupState();
}

class _MultiChipGroupState extends State<_MultiChipGroup> {
  @override
  Widget build(BuildContext context) {
    return _FilterGroup(
      label: widget.label,
      child: Wrap(
        spacing: 8,
        children: [
          for (final option in widget.options)
            FilterChip(
              label: Text(option),
              selected: widget.selected.contains(option),
              onSelected: (isSelected) => setState(() {
                if (isSelected) {
                  widget.selected.add(option);
                } else {
                  widget.selected.remove(option);
                }
              }),
            ),
        ],
      ),
    );
  }
}

class _FilterGroup extends StatelessWidget {
  final String label;
  final Widget child;

  const _FilterGroup({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context)
              .textTheme
              .labelMedium
              ?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
