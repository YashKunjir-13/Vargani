import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:pauti_pustak_mobile/core/session/session_controller.dart";
import "package:pauti_pustak_mobile/shared/utils/pdf_download_utils.dart";
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_buttons.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_text_fields.dart';
import 'package:pauti_pustak_mobile/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:pauti_pustak_mobile/features/payments/state/payments_notifier.dart';
import 'package:pauti_pustak_mobile/features/receipts/models/receipt.dart';
import 'package:pauti_pustak_mobile/shared/utils/pdf_generator.dart';

class DashboardActionSheets {
  static void showCollectDonationSheet(BuildContext context, {WidgetRef? ref, String? mandalName}) {
    final colors = context.authColors;

    String? currentUserName;
    String? currentUserPhone;
    if (ref != null) {
      final user = ref.read(sessionControllerProvider).user;
      currentUserName = user?.donorProfile?.fullName ?? user?.displayName;
      currentUserPhone = user?.primaryMobile;
    }

    final nameController = TextEditingController(text: currentUserName ?? '');
    final mobileController = TextEditingController(text: currentUserPhone ?? '');
    final amountController = TextEditingController();
    String selectedMethod = 'Cash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Collect Donation',
                        style: TextStyle(
                          color: colors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: Icon(Icons.close, color: colors.secondaryText),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    label: 'Donor Name',
                    hint: 'e.g. Rajesh Sharma',
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    label: 'Mobile Number',
                    hint: 'e.g. 9876543210',
                    controller: mobileController,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    label: 'Amount (₹)',
                    hint: 'e.g. 5001',
                    controller: amountController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Cash', 'UPI', 'Net Banking', 'Cheque'].map((method) {
                      final selected = method == selectedMethod;
                      return ChoiceChip(
                        label: Text(method),
                        selected: selected,
                        selectedColor: colors.brandOrange,
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : colors.text,
                          fontWeight: FontWeight.w800,
                        ),
                        onSelected: (_) => setState(() => selectedMethod = method),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  AuthPrimaryButton(
                    label: 'Proceed to Payment',
                    icon: Icons.receipt_long,
                    onPressed: () {
                      final donorName = nameController.text.trim().isEmpty ? 'Authenticated Donor' : nameController.text.trim();
                      final mobile = mobileController.text.trim();
                      final amountText = amountController.text.trim().isEmpty ? '5001' : amountController.text.trim();
                      final amountVal = double.tryParse(amountText) ?? 5001.0;
                      final amountPaise = (amountVal * 100).round();

                      Navigator.pop(ctx);

                      // Open Temporary Payment Confirmation Dialog
                      showDialog(
                        context: context,
                        builder: (confirmCtx) {
                          return AlertDialog(
                            backgroundColor: colors.card,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            title: Row(
                              children: [
                                Icon(Icons.verified_user_outlined, color: colors.brandOrange, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'Confirm Donation',
                                  style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Review donation details before issuing official receipt:',
                                  style: TextStyle(color: colors.secondaryText, fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceMuted,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: colors.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Donor: $donorName', style: TextStyle(color: colors.text, fontWeight: FontWeight.bold)),
                                      if (mobile.isNotEmpty) Text('Mobile: $mobile', style: TextStyle(color: colors.secondaryText, fontSize: 12)),
                                      Text('Amount: ₹${amountVal.toStringAsFixed(0)}', style: TextStyle(color: colors.brandOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Text('Payment Method: $selectedMethod', style: TextStyle(color: colors.secondaryText, fontSize: 12)),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                                  ),
                                  child: const Text(
                                    '⚡ Direct confirmation mode (No Razorpay gateway required)',
                                    style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(confirmCtx),
                                child: Text('Cancel', style: TextStyle(color: colors.secondaryText)),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.brandOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () async {
                                  showDialog(
                                    context: confirmCtx,
                                    barrierDismissible: false,
                                    builder: (loadingCtx) => Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          color: colors.card,
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            CircularProgressIndicator(color: colors.brandOrange),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Issuing Official Receipt...',
                                              style: TextStyle(color: colors.text, fontSize: 14, fontWeight: FontWeight.w600, decoration: TextDecoration.none),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );

                                  Receipt? receipt;
                                  try {
                                    if (ref != null) {
                                      final r = ref;
                                      receipt = await r.read(paymentsProvider.notifier).collectDonationAndGenerateReceipt(
                                        donorName: donorName,
                                        contact: mobile.isEmpty ? null : mobile,
                                        amount: amountVal,
                                        paymentMethod: selectedMethod,
                                      );

                                      final activeOrgName = r.read(sessionControllerProvider).user?.organization?.name ?? 'My Mandal';

                                      r.read(donorDashboardProvider.notifier).addDonation(
                                        amountPaise: amountPaise,
                                        paymentMethod: selectedMethod,
                                        mandalName: mandalName ?? activeOrgName,
                                      );

                                      r.read(mandalDashboardProvider.notifier).addDonation(
                                        amountPaise: amountPaise,
                                        paymentMethod: selectedMethod,
                                        donorName: donorName,
                                      );
                                    }

                                    if (confirmCtx.mounted) {
                                      Navigator.pop(confirmCtx); // Pop loading dialog
                                      Navigator.pop(confirmCtx); // Pop confirm dialog
                                    }
                                  } catch (err) {
                                    if (confirmCtx.mounted) {
                                      Navigator.pop(confirmCtx); // Pop loading dialog
                                      Navigator.pop(confirmCtx); // Pop confirm dialog
                                    }
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to collect donation: $err'),
                                          backgroundColor: Colors.red.shade700,
                                        ),
                                      );
                                    }
                                    return;
                                  }

                                  if (!context.mounted) return;

                                  final activeOrgName = ref?.read(sessionControllerProvider).user?.organization?.name ?? 'My Mandal';
                                  final receiptNo = receipt?.receiptNumber ?? 'RCPT-2026-000001';
                                  final receiptId = receipt?.id ?? '';
                                  final mName = receipt?.mandalName ?? mandalName ?? activeOrgName;

                                  // Show Receipt Success Dialog
                                  showDialog(
                                    context: context,
                                    builder: (successCtx) {
                                      return AlertDialog(
                                        backgroundColor: colors.card,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                        title: Row(
                                          children: [
                                            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Donation Successful!',
                                              style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.w900),
                                            ),
                                          ],
                                        ),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Official digital receipt generated successfully.',
                                              style: TextStyle(color: colors.secondaryText, fontSize: 13),
                                            ),
                                            const SizedBox(height: 16),
                                            Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: colors.surfaceMuted,
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: colors.border),
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'RECEIPT NO',
                                                    style: TextStyle(color: colors.secondaryText, fontSize: 11, fontWeight: FontWeight.w700),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    receiptNo,
                                                    style: TextStyle(color: colors.brandOrange, fontSize: 18, fontWeight: FontWeight.w900),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    donorName,
                                                    style: TextStyle(color: colors.text, fontSize: 15, fontWeight: FontWeight.bold),
                                                  ),
                                                  if (mobile.isNotEmpty)
                                                    Text(
                                                      'Mobile: $mobile',
                                                      style: TextStyle(color: colors.secondaryText, fontSize: 12),
                                                    ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '₹${amountVal.toStringAsFixed(0)}',
                                                    style: TextStyle(color: colors.text, fontSize: 24, fontWeight: FontWeight.w900),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Text(
                                                    'Method: $selectedMethod • Status: Confirmed',
                                                    style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(successCtx),
                                            child: Text('Done', style: TextStyle(color: colors.secondaryText)),
                                          ),
                                          if (receiptId.isNotEmpty)
                                            ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: colors.brandOrange,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                              ),
                                              onPressed: () {
                                                Navigator.pop(successCtx);
                                                context.push('/receipts/$receiptId');
                                              },
                                              icon: const Icon(Icons.receipt, size: 16),
                                              label: const Text('View Receipt'),
                                            ),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue.shade700,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                            onPressed: () {
                                              Printing.layoutPdf(
                                                onLayout: (format) async {
                                                  final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
                                                  return PdfReceiptGenerator.generateReceiptPdf(
                                                    receiptNumber: receiptNo,
                                                    mandalName: mName,
                                                    donorName: donorName,
                                                    amountText: currency.format(amountVal),
                                                    dateText: DateFormat('d MMM yyyy').format(DateTime.now()),
                                                    typeLabel: 'Festival Donation — Ganpati Utsav 2026',
                                                  );
                                                },
                                              );
                                            },
                                            icon: const Icon(Icons.download, size: 16),
                                            label: const Text('PDF'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.check, size: 18),
                                label: const Text('Confirm & Issue Receipt'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  static void showAddExpenseSheet(BuildContext context) {
    final colors = context.authColors;
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Expense / Bill',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(Icons.close, color: colors.secondaryText),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Expense Description',
                hint: 'e.g. Mandap Light Flowers Decor',
                controller: titleController,
              ),
              const SizedBox(height: 16),
              AuthTextField(
                label: 'Amount (₹)',
                hint: 'e.g. 15000',
                controller: amountController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              AuthPrimaryButton(
                label: 'Submit for Approval',
                icon: Icons.send,
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Expense submitted successfully for approval!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static void showReceiptDetailModal(BuildContext context, String receiptId, String receiptNo, String donor, String amount) {
    final colors = context.authColors;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.verified, color: colors.brandOrange, size: 28),
              const SizedBox(width: 10),
              Text(
                'Official Digital Receipt',
                style: TextStyle(color: colors.text, fontSize: 18, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    Text('RECEIPT NO: $receiptNo', style: TextStyle(color: colors.brandOrange, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(donor, style: TextStyle(color: colors.text, fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(amount, style: TextStyle(color: colors.text, fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    const Text('Status: Confirmed • 80G Tax Exempted', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close', style: TextStyle(color: colors.secondaryText)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.brandOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                final dio = ProviderScope.containerOf(context).read(dioProvider);
                PdfDownloadUtils.downloadReceiptPdf(context, dio, receiptId, receiptNo);
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download PDF'),
            ),
          ],
        );
      },
    );
  }
}
