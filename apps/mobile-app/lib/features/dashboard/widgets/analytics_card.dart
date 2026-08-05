import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/ui_kit/charts/mini_sparkline.dart';
import '../../../shared/ui_kit/chips/status_chip.dart';
import '../models/dashboard_models.dart';

class AnalyticsCard extends StatelessWidget {
  final AnalyticsCardData data;

  const AnalyticsCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 220,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.pushNamed(data.routeName),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: data.accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(data.icon, color: data.accentColor, size: 20),
                    ),
                    Icon(Icons.chevron_right,
                        color: theme.colorScheme.onSurfaceVariant, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  data.value,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                MiniSparkline(values: data.sparklineData, color: data.accentColor, height: 32),
                const SizedBox(height: 8),
                StatusChip(label: data.statusLabel, type: StatusChipType.info),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
