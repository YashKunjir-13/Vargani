import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/payment.dart';
import '../state/payments_notifier.dart';

class PaymentsListScreen extends ConsumerStatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  ConsumerState<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends ConsumerState<PaymentsListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final asyncPayments = ref.watch(paymentsProvider);
    final theme = Theme.of(context);
    final currency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');

    return Scaffold(
      appBar: PautiAppBar(
        title: L10n.tr(ref, 'payment_collection'),
        subtitle: 'Donation Collection',
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/payments/new'),
        icon: const Icon(Icons.add),
        label: Text(L10n.tr(ref, 'record_payment')),
      ),
      body: asyncPayments.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load payments: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () =>
                    ref.read(paymentsProvider.notifier).loadPayments(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (payments) {
          final filtered = payments.where((p) {
            final matchesFilter = switch (_selectedFilter) {
              'Pending Match' => p.status == PaymentStatus.pendingMatch,
              'Confirmed' => p.status == PaymentStatus.confirmed,
              'Receipted' => p.status == PaymentStatus.receipted,
              'Voided' => p.status == PaymentStatus.voided,
              _ => true,
            };

            final matchesSearch = p.donorName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                p.id.toLowerCase().contains(_searchQuery.toLowerCase());

            return matchesFilter && matchesSearch;
          }).toList();

          return Column(
            children: [
              // Filter Chips & Search Bar Header
              Container(
                color: theme.colorScheme.surface,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: 'Search donor name or payment ID...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        isDense: true,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          'All',
                          'Pending Match',
                          'Confirmed',
                          'Receipted',
                          'Voided'
                        ].map((filter) {
                          final isSelected = filter == _selectedFilter;

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(filter),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _selectedFilter = filter),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Payments List
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No payments found'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final payment = filtered[index];

                          return AppCard(
                            onTap: () =>
                                context.push('/payments/${payment.id}'),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payment.donorName,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                                  fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'ID: ${payment.id} • ${payment.channel.label}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    StatusChip(label: payment.status.label),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      dateFormat
                                          .format(payment.paymentDateTime),
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    Text(
                                      currency.format(payment.amount),
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
