import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/dashboard_models.dart';
import 'progress_widget.dart';
import 'status_badge.dart';

class FinancialSummaryCard extends StatelessWidget {
  final FinancialSummaryData data;

  const FinancialSummaryCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Available Balance',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.availableBalance,
                    style: theme.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              StatusBadge(label: data.liveStatusLabel, type: StatusType.success),
            ],
          ),
          const SizedBox(height: 20),
          ProgressWidget(
            value: data.progress,
            color: theme.colorScheme.primary,
            showPercentageLabel: false,
          ),
          const SizedBox(height: 8),
          Text(
            '${currency.format(data.achievedAmount)} of ${currency.format(data.targetAmount)} target · ${(data.progress * 100).toStringAsFixed(0)}% achieved',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryStat(
                  label: "Today's Collection",
                  value: data.todaysCollection,
                  color: Colors.green.shade700,
                ),
              ),
              Expanded(
                child: _SummaryStat(
                  label: "Today's Expenses",
                  value: data.todaysExpenses,
                  color: theme.colorScheme.error,
                ),
              ),
              Expanded(
                child: _SummaryStat(
                  label: 'Net Balance',
                  value: data.netBalance,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleSmall
              ?.copyWith(color: color, fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
