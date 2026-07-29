// ignore_for_file: prefer_const_constructors

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../core/permissions/permission_guard.dart';
import '../../../core/permissions/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/pdf_generator.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../models/receipt.dart';
import '../state/receipts_notifier.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  final String receiptId;

  const ReceiptDetailScreen({super.key, required this.receiptId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receipts = ref.watch(receiptsProvider);
    final permissions = ref.watch(permissionsProvider);

    final receipt = receipts.where((r) => r.id == receiptId).firstOrNull;
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('d MMM yyyy');

    if (receipt == null) {
      return const Scaffold(
        appBar: PautiAppBar(title: 'Receipt', subtitle: 'Donor Portal'),
        body: Center(child: Text('Receipt not found')),
      );
    }

    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Receipt',
        subtitle: 'Donor Portal',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Top Action Buttons Row: [ ↓ PDF ] and [ Share ]
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // PDF Action Button
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
                        typeLabel: 'Festival Donation — Ganpati Utsav 2026',
                      );
                    },
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.download_rounded, size: 18, color: AppColors.amountTerracotta),
                      SizedBox(width: 6),
                      Text(
                        'PDF',
                        style: TextStyle(
                          color: AppColors.amountTerracotta,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Share Action Button
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing digital receipt...')),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.share_outlined, size: 18, color: AppColors.amountTerracotta),
                      SizedBox(width: 6),
                      Text(
                        'Share',
                        style: TextStyle(
                          color: AppColors.amountTerracotta,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Authentic Receipt Document Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: [
                  // Terracotta Banner Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                    color: AppColors.terracottaBanner,
                    child: Column(
                      children: [
                        const Text(
                          '🙏',
                          style: TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          receipt.mandalName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Dadar, Mumbai',
                          style: TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9A3412),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'OFFICIAL DONATION RECEIPT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Receipt Metadata Details Body
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Receipt No & Date Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Receipt No.',
                                  style: TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  receipt.receiptNumber,
                                  style: const TextStyle(
                                    color: AppColors.textPrimaryLight,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Date',
                                  style: TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  dateFormat.format(receipt.issuedDate),
                                  style: const TextStyle(
                                    color: AppColors.textPrimaryLight,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Dotted Line Divider
                        Row(
                          children: List.generate(
                            40,
                            (index) => Expanded(
                              child: Container(
                                height: 1,
                                color: index % 2 == 0 ? Colors.grey.shade300 : Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Received From
                        const Text(
                          'RECEIVED FROM',
                          style: TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          receipt.donorName,
                          style: const TextStyle(
                            color: AppColors.textPrimaryLight,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          '+91 98765 43210',
                          style: TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Purpose
                        const Text(
                          'PURPOSE',
                          style: TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Festival Donation — Ganpati Utsav 2026',
                          style: TextStyle(
                            color: AppColors.textPrimaryLight,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Amount Received Container Box
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.amberBoxBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.amberBoxBorder, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'Amount Received',
                                style: TextStyle(
                                  color: AppColors.textSecondaryLight,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currency.format(receipt.amount),
                                style: const TextStyle(
                                  color: AppColors.amountTerracotta,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Mint Green Confirmed Badge Tag
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.mintGreenBg,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  receipt.status == ReceiptStatus.active ? 'UPI Confirmed' : 'Voided',
                                  style: const TextStyle(
                                    color: AppColors.mintGreenText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Footer Text
                        Center(
                          child: Text(
                            'Donated to: ${receipt.mandalName}',
                            style: const TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Permission Gated Void Action (Auditor / Admin)
          if (receipt.status != ReceiptStatus.voided)
            PermissionGuard(
              hasPermission: permissions.canVoidPayment,
              fallbackTooltip: 'Auditor or Admin role required to void official receipt',
              child: AppButton(
                label: 'Void Receipt',
                variant: AppButtonVariant.danger,
                icon: Icons.block,
                onPressed: () {
                  ref.read(receiptsProvider.notifier).voidReceipt(receipt.id, reason: 'Voided by Admin');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Receipt has been voided.')),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
