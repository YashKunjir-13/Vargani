import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/pauti_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../contribution_receipts/state/contribution_receipts_notifier.dart';
import '../models/contribution.dart';
import '../state/contributions_notifier.dart';

class ContributionDetailScreen extends ConsumerWidget {
  final String contributionId;

  const ContributionDetailScreen({super.key, required this.contributionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributions = ref.watch(contributionsProvider);
    final contribution =
        contributions.where((c) => c.id == contributionId).firstOrNull;
    final receipts = ref.watch(contributionReceiptsProvider);
    final linkedReceipt =
        receipts.where((r) => r.contributionId == contributionId).firstOrNull;
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');

    if (contribution == null) {
      return const Scaffold(
        appBar: PautiAppBar(
            title: 'Contribution',
            subtitle: 'Treasurer Portal',
            showBackButton: true),
        body: Center(child: Text('Not found')),
      );
    }

    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Contribution Detail',
        subtitle: 'In-Kind Record Overview',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                contribution.donationType.label,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              StatusChip(label: contribution.status.label),
            ],
          ),
          const SizedBox(height: 20),
          _Row(label: 'Contributor', value: contribution.contributorName),
          if (contribution.contact != null)
            _Row(label: 'Contact', value: contribution.contact!),
          _Row(label: 'Date', value: dateFormat.format(contribution.date)),
          if (contribution.itemDescription != null)
            _Row(label: 'Description', value: contribution.itemDescription!),
          if (contribution.quantity != null)
            _Row(
              label: 'Quantity',
              value:
                  '${contribution.quantity?.toStringAsFixed(0)} ${contribution.unit ?? ''}',
            ),
          if (contribution.weightGrams != null)
            _Row(label: 'Weight', value: '${contribution.weightGrams} g'),
          if (contribution.estimatedValue != null)
            _Row(
              label: 'Estimated Value',
              value:
                  '₹${NumberFormat('#,##,###').format(contribution.estimatedValue)}',
            ),
          if (contribution.notes != null)
            _Row(label: 'Notes', value: contribution.notes!),
          if (contribution.certificatePhotoUrl != null)
            const _Row(
                label: 'Certificate', value: 'Purity Certificate Attached'),
          _Row(label: 'Recorded By', value: contribution.recordedBy),
          const SizedBox(height: 12),
          Text(
            'Non-monetary contribution records are tracked under festival organization inventory.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 28),
          if (linkedReceipt != null)
            OutlinedButton.icon(
              onPressed: () =>
                  context.push('/contribution-receipts/${linkedReceipt.id}'),
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(
                  'View Receipt ${linkedReceipt.contributionReceiptNumber}'),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 130,
              child:
                  Text(label, style: TextStyle(color: Colors.grey.shade600))),
          Expanded(
              child: Text(value,
                  style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
