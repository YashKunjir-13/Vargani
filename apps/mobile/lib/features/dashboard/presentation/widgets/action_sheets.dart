import 'package:flutter/material.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_buttons.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_text_fields.dart';

class DashboardActionSheets {
  static void showCollectDonationSheet(BuildContext context) {
    final colors = context.authColors;
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    String selectedMethod = 'UPI (GPay/PhonePe)';

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
                    children: ['UPI (GPay/PhonePe)', 'Cash', 'Net Banking', 'Cheque'].map((method) {
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
                    label: 'Issue Receipt & Record',
                    icon: Icons.receipt_long,
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Donation of ₹${amountController.text.isEmpty ? '5001' : amountController.text} collected successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
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

  static void showReceiptDetailModal(BuildContext context, String receiptNo, String donor, String amount) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Receipt $receiptNo PDF downloaded successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
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
