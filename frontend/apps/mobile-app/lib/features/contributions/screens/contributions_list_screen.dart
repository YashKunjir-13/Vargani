import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/contribution.dart';
import '../state/contributions_notifier.dart';

class ContributionsListScreen extends ConsumerStatefulWidget {
  const ContributionsListScreen({super.key});

  @override
  ConsumerState<ContributionsListScreen> createState() => _ContributionsListScreenState();
}

class _ContributionsListScreenState extends ConsumerState<ContributionsListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final contributions = ref.watch(contributionsProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');

    final filtered = contributions.where((c) {
      return c.contributorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.donationType.label.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.itemDescription?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();

    return Scaffold(
      appBar: PautiAppBar(
        title: L10n.tr(ref, 'contributions'),
        subtitle: 'Treasurer Portal',
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/contributions/new'),
        icon: const Icon(Icons.volunteer_activism_outlined),
        label: const Text('Record Contribution'),
      ),
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search contributor or item type...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No contributions found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filtered[index];

                      return AppCard(
                        onTap: () => context.push('/contributions/${item.id}'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.contributorName,
                                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      item.donationType.label,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                StatusChip(label: item.status.label),
                              ],
                            ),
                            if (item.itemDescription != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                item.itemDescription!,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                            if (item.weightGrams != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Weight: ${item.weightGrams}g ${item.estimatedValue != null ? "• Est: ₹${item.estimatedValue!.toInt()}" : ""}',
                                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ],
                            const Divider(height: 20),
                            Text(
                              dateFormat.format(item.date),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
