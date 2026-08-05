import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/contribution_receipt.dart';
import '../state/contribution_receipts_notifier.dart';

class ContributionReceiptsListScreen extends ConsumerStatefulWidget {
  const ContributionReceiptsListScreen({super.key});

  @override
  ConsumerState<ContributionReceiptsListScreen> createState() =>
      _ContributionReceiptsListScreenState();
}

class _ContributionReceiptsListScreenState
    extends ConsumerState<ContributionReceiptsListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final receipts = ref.watch(contributionReceiptsProvider);
    final theme = Theme.of(context);
    final dateFormat = DateFormat('d MMM yyyy');

    final filtered = receipts.where((r) {
      return r.contributorName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          r.contributionReceiptNumber
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          r.donationType.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: PautiAppBar(
        title: L10n.tr(ref, 'contribution_receipts'),
        subtitle: 'Contributor Portal',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Banner about CRCPT independent numbering
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: theme.colorScheme.secondary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.tag_outlined,
                    size: 20, color: theme.colorScheme.secondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Independent CRCPT- numbering scheme for non-monetary items. Separate counter, never collides with RCPT-.',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search contributor or CRCPT #...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // List View
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.tag_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text('No contribution receipts found',
                            style: theme.textTheme.titleMedium),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final receipt = filtered[index];
                      return AppCard(
                        onTap: () => context
                            .push('/contribution-receipts/${receipt.id}'),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  theme.colorScheme.secondaryContainer,
                              child: Icon(
                                Icons.volunteer_activism_outlined,
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
                                    receipt.contributionReceiptNumber,
                                    style: theme.textTheme.titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${receipt.contributorName} • ${receipt.donationType}',
                                    style: theme.textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    'Issued: ${dateFormat.format(receipt.issuedDate)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                StatusChip(label: receipt.status.label),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.chat_outlined,
                                      size: 13,
                                      color: receipt.whatsappDeliveryStatus ==
                                              ContributionReceiptWhatsappStatus
                                                  .sent
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      receipt.whatsappDeliveryStatus.label,
                                      style: theme.textTheme.labelSmall,
                                    ),
                                  ],
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
      ),
    );
  }
}
