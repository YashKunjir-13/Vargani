import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../shared/ui_kit/chips/status_chip.dart';
import '../models/dashboard_models.dart';

class TimelineItem extends StatelessWidget {
  final ActivityItemData data;

  const TimelineItem({super.key, required this.data});

  (IconData, Color) _iconAndColor(ColorScheme scheme) => switch (data.type) {
        ActivityType.receipt => (Icons.receipt_outlined, Colors.blue),
        ActivityType.expense => (Icons.payments_outlined, scheme.error),
        ActivityType.contribution => (Icons.groups_outlined, Colors.purple),
        ActivityType.audit => (Icons.fact_check_outlined, Colors.teal),
        ActivityType.notification => (Icons.notifications_outlined, Colors.amber.shade800),
        ActivityType.vendor => (Icons.storefront_outlined, Colors.indigo),
        ActivityType.sponsor => (Icons.handshake_outlined, Colors.green.shade700),
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = _iconAndColor(theme.colorScheme);
    final amount = data.amount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                if (data.statusLabel != null) ...[
                  const SizedBox(height: 6),
                  StatusChip(label: data.statusLabel!, type: StatusChipType.neutral),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (amount != null)
                Text(
                  amount,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: amount.startsWith('-') ? theme.colorScheme.error : Colors.green.shade700,
                  ),
                ),
              const SizedBox(height: 2),
              Text(
                DateFormat.MMMd().add_jm().format(data.timestamp),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
