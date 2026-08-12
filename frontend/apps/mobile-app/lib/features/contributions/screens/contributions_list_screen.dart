import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../rbac/presentation/providers/mock_rbac_provider.dart';
import '../models/contribution.dart';
import '../state/contributions_notifier.dart';

class ContributionsListScreen extends ConsumerStatefulWidget {
  const ContributionsListScreen({super.key});

  @override
  ConsumerState<ContributionsListScreen> createState() =>
      _ContributionsListScreenState();
}

class _ContributionsListScreenState
    extends ConsumerState<ContributionsListScreen> {
  String _searchQuery = '';
  DonationType? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final contributions = ref.watch(contributionsProvider);
    final rbacState = ref.watch(mockRbacProvider);
    final canCreate = rbacState.hasPermission('contribution.create') ||
        rbacState.hasPermission('collections.create');
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM yyyy');

    final filtered = contributions.where((c) {
      final matchesSearch = c.contributorName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          c.donationType.label
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          (c.itemDescription
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);
      final matchesCategory =
          _selectedCategory == null || c.donationType == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: PautiAppBar(
        title: L10n.tr(ref, 'contributions'),
        subtitle: 'In-Kind & Non-Monetary Log',
        showBackButton: true,
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/contributions/new'),
              icon: const Icon(Icons.volunteer_activism_outlined),
              label: const Text('Record Contribution'),
            )
          : null,
      body: Column(
        children: [
          // Search Bar
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: const InputDecoration(
                hintText: 'Search contributor or item description...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
            ),
          ),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All Categories'),
                  selected: _selectedCategory == null,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = null);
                  },
                ),
                const SizedBox(width: 8),
                ...DonationType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.label),
                      selected: _selectedCategory == type,
                      onSelected: (selected) {
                        setState(
                            () => _selectedCategory = selected ? type : null);
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'No non-monetary contributions found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
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
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.contributorName,
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme.primaryContainer
                                              .withValues(alpha: 0.6),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          item.donationType.label,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: theme.colorScheme.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    StatusChip(label: item.status.label),
                                    const SizedBox(height: 4),
                                    Text(
                                      dateFormat.format(item.date),
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                              color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (item.itemDescription != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                item.itemDescription!,
                                style: theme.textTheme.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
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
