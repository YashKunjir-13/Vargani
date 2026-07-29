import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/bill.dart';
import '../state/bills_notifier.dart';

class BillsListScreen extends ConsumerStatefulWidget {
  const BillsListScreen({super.key});

  @override
  ConsumerState<BillsListScreen> createState() => _BillsListScreenState();
}

class _BillsListScreenState extends ConsumerState<BillsListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final bills = ref.watch(billsProvider);
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM yyyy');

    final filtered = bills.where((b) {
      final matchesFilter = switch (_selectedFilter) {
        'Draft' => b.status == BillStatus.draft,
        'Pending Approval' => b.status == BillStatus.pendingApproval,
        'Approved' => b.status == BillStatus.approved,
        'Paid' => b.status == BillStatus.paid,
        'Cancelled' => b.status == BillStatus.cancelled,
        _ => true,
      };

      final matchesSearch = b.receiverName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.billNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.taskOrField.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: PautiAppBar(
        title: L10n.tr(ref, 'bill_generation'),
        subtitle: 'Treasurer Portal',
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/bills/new'),
        icon: const Icon(Icons.add),
        label: const Text('Create Bill'),
      ),
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search receiver, bill # or task...',
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'All',
                      'Draft',
                      'Pending Approval',
                      'Approved',
                      'Paid',
                      'Cancelled',
                    ].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedFilter = filter);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text('No bills found', style: theme.textTheme.titleMedium),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final bill = filtered[index];
                      return AppCard(
                        onTap: () => context.push('/bills/${bill.id}'),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: theme.colorScheme.secondaryContainer,
                              child: Icon(
                                Icons.receipt_outlined,
                                size: 20,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bill.billNumber,
                                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${bill.receiverName} • ${bill.taskOrField}',
                                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Date: ${dateFormat.format(bill.date)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currency.format(bill.amount),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                StatusChip(label: bill.status.label),
                              ],
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
