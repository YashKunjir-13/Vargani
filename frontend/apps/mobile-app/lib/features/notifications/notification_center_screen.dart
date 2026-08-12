import 'package:flutter/material.dart';

import '../../shared/ui_kit/cards/alert_card.dart';
import '../../shared/ui_kit/overlays/bulk_action_bar.dart';
import '../../shared/ui_kit/rows/notification_card.dart';
import 'models/notification_models.dart';

/// The Notification Center hub. Selection mode (bulk actions) lives on this
/// same screen rather than a separate route, so triage never loses the
/// user's scroll position.
class NotificationCenterScreen extends StatefulWidget {
  final NotificationSummaryData summary;
  final List<NotificationItemData> items;
  final String? priorityAlertTitle;
  final String? priorityAlertSubtitle;
  final ValueChanged<NotificationItemData>? onOpenItem;
  final VoidCallback? onOpenFilters;
  final VoidCallback? onOpenSettings;
  final void Function(String primaryActionId)? onPrimaryAction;

  const NotificationCenterScreen({
    super.key,
    required this.summary,
    required this.items,
    this.priorityAlertTitle,
    this.priorityAlertSubtitle,
    this.onOpenItem,
    this.onOpenFilters,
    this.onOpenSettings,
    this.onPrimaryAction,
  });

  @override
  State<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final Set<String> _selected = {};

  bool get _selectionMode => _selected.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final groups = <String, List<NotificationItemData>>{};
    for (final item in widget.items) {
      groups.putIfAbsent(item.groupLabel, () => []).add(item);
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Notifications'),
            Text(
              '${widget.summary.unreadCount} unread',
              style: textTheme.labelMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: widget.onOpenFilters,
              icon: const Icon(Icons.filter_list)),
          IconButton(
              onPressed: widget.onOpenSettings,
              icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                      child: _SummaryTile(
                          value: '${widget.summary.unreadCount}',
                          label: 'Unread')),
                  Expanded(
                    child: _SummaryTile(
                      value: '${widget.summary.criticalCount}',
                      label: 'Critical',
                      valueColor: colorScheme.error,
                    ),
                  ),
                  Expanded(
                      child: _SummaryTile(
                          value: '${widget.summary.approvalsCount}',
                          label: 'Approvals')),
                  Expanded(
                      child: _SummaryTile(
                          value: '${widget.summary.paymentsDueCount}',
                          label: 'Payments Due')),
                ],
              ),
              if (widget.priorityAlertTitle != null) ...[
                const SizedBox(height: 16),
                AlertCard(
                  icon: Icons.priority_high_rounded,
                  title: widget.priorityAlertTitle!,
                  subtitle: widget.priorityAlertSubtitle,
                  tone: AlertTone.critical,
                ),
              ],
              const SizedBox(height: 16),
              for (final group in groups.entries) ...[
                Text(
                  group.key.toUpperCase(),
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                for (final item in group.value)
                  NotificationCard(
                    icon: item.icon,
                    iconBackground: item.iconBackground,
                    iconColor: item.iconColor,
                    title: item.title,
                    description: item.description,
                    isUnread: item.isUnread,
                    primaryActionLabel: item.primaryActionLabel,
                    onPrimaryAction: widget.onPrimaryAction == null
                        ? null
                        : () => widget.onPrimaryAction!(item.id),
                    secondaryActionLabel: item.secondaryActionLabel,
                    onSecondaryAction: () {},
                    onSelectedChanged: _selectionMode
                        ? (checked) => _toggleSelection(item.id, checked)
                        : null,
                    isSelected: _selected.contains(item.id),
                    onTap: _selectionMode
                        ? () => _toggleSelection(
                            item.id, !_selected.contains(item.id))
                        : (widget.onOpenItem == null
                            ? null
                            : () => widget.onOpenItem!(item)),
                  ),
                const SizedBox(height: 8),
              ],
            ],
          ),
          if (_selectionMode)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: BulkActionBar(
                selectedCount: _selected.length,
                actions: [
                  BulkAction(
                      label: 'Mark Read',
                      onPressed: () => setState(_selected.clear)),
                  BulkAction(
                      label: 'Archive',
                      onPressed: () => setState(_selected.clear)),
                ],
                onCancel: () => setState(_selected.clear),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleSelection(String id, bool? checked) {
    setState(() {
      if (checked ?? false) {
        _selected.add(id);
      } else {
        _selected.remove(id);
      }
    });
  }
}

class _SummaryTile extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;

  const _SummaryTile(
      {required this.value, required this.label, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            color: valueColor ?? colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Text(label,
            style: textTheme.labelSmall
                ?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}
