// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/pdf_generator.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../state/receipts_notifier.dart';

class ReceiptsListScreen extends ConsumerStatefulWidget {
  const ReceiptsListScreen({super.key});

  @override
  ConsumerState<ReceiptsListScreen> createState() => _ReceiptsListScreenState();
}

class _ReceiptsListScreenState extends ConsumerState<ReceiptsListScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final asyncReceipts = ref.watch(receiptsProvider);
    final theme = Theme.of(context);
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM yyyy');

    return Scaffold(
      appBar: PautiAppBar(
        title: L10n.tr(ref, 'receipt_generation'),
        subtitle: 'Mandal Management',
        showBackButton: true,
      ),
      body: asyncReceipts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Failed to load receipts: $err'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(receiptsProvider.notifier).loadReceipts(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (receipts) {
          final totalDonated = receipts.fold<double>(0, (sum, r) => sum + r.amount);
          final totalReceiptsCount = receipts.length;
          final pendingCount = receipts.where((r) => r.receiptNumber.startsWith('PENDING')).length;

          final filtered = receipts.where((r) {
            return r.donorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                r.receiptNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                r.mandalName.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          // 1. Metric Summary Cards Row (3 KPI Cards)
          Row(
            children: [
              // Total Amount Stat Card
              Expanded(
                child: _KpiStatCard(
                  title: 'Total Issued',
                  value: currency.format(totalDonated),
                  valueColor: AppColors.primaryLight,
                ),
              ),
              const SizedBox(width: 10),

              // Receipts Count Stat Card
              Expanded(
                child: _KpiStatCard(
                  title: 'Issued',
                  value: '$totalReceiptsCount',
                  valueColor: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(width: 10),

              // Pending Generation Stat Card
              Expanded(
                child: _KpiStatCard(
                  title: 'Pending',
                  value: '$pendingCount',
                  valueColor: AppColors.statusPending,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Processing Warning Card (Yellow Alert Box)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.amberBoxBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.amberBoxBorder, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Icon(Icons.access_time_filled, color: Color(0xFFD97706), size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '1 receipt being processed',
                        style: TextStyle(
                          color: Color(0xFF78350F),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'The mandal treasurer will issue your receipt shortly.',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Search Field
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: const InputDecoration(
              hintText: 'Search mandal, donor or receipt #...',
              prefixIcon: Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
          ),
          const SizedBox(height: 20),

          // 3. Issued Receipts Section
          Text(
            'Issued Receipts',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),

          if (filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('No issued receipts found'),
              ),
            )
          else
            ...filtered.map((receipt) {
              final initial = receipt.mandalName.isNotEmpty ? receipt.mandalName[0] : 'M';

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => context.push('/receipts/${receipt.id}'),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Saffron Initial Avatar
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Title & Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    receipt.mandalName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textPrimaryLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: const [
                                      Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondaryLight),
                                      SizedBox(width: 2),
                                      Text(
                                        'Dadar, Mumbai',
                                        style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Amount & Date
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currency.format(receipt.amount),
                                  style: const TextStyle(
                                    color: AppColors.textPrimaryLight,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateFormat.format(receipt.issuedDate),
                                  style: const TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        // Bottom Row: [ Receipt Issued Tag ] | [ Receipt # ] | [ ↓ PDF Link ]
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.mintGreenBg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Receipt Issued',
                                style: TextStyle(
                                  color: AppColors.mintGreenText,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                receipt.receiptNumber,
                                style: const TextStyle(
                                  color: AppColors.textSecondaryLight,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            // PDF Quick Download Link
                            InkWell(
                              onTap: () {
                                Printing.layoutPdf(
                                  onLayout: (format) async {
                                    return PdfReceiptGenerator.generateReceiptPdf(
                                      receiptNumber: receipt.receiptNumber,
                                      mandalName: receipt.mandalName,
                                      donorName: receipt.donorName,
                                      amountText: currency.format(receipt.amount),
                                      dateText: dateFormat.format(receipt.issuedDate),
                                      typeLabel: 'Monetary Collection',
                                    );
                                  },
                                );
                              },
                              child: Row(
                                children: const [
                                  Icon(Icons.download_rounded, size: 14, color: AppColors.primaryLight),
                                  SizedBox(width: 2),
                                  Text(
                                    'PDF',
                                    style: TextStyle(
                                      color: AppColors.primaryLight,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          const SizedBox(height: 16),

          // 4. Awaiting Receipt Section
          Text(
            'Awaiting Receipt',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderLight, width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.access_time_rounded, color: Color(0xFFD97706)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Shree Siddhivinayak Ganpati...',
                        style: TextStyle(
                          color: AppColors.textPrimaryLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '25 Aug 2024 • Card Collection',
                        style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '₹501',
                  style: TextStyle(
                    color: AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      );
    },
  ),
);
  }
}

class _KpiStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _KpiStatCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondaryLight,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
