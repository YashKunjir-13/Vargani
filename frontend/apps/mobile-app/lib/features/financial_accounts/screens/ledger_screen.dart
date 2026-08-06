import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../models/ledger_models.dart';
import '../state/ledger_notifier.dart';

class LedgerScreen extends ConsumerWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(bankAccountProvider);
    final deposits = ref.watch(bankDepositsProvider);
    final currency = NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Ledger & Bank Deposits',
        subtitle: 'Treasury & Bank Account Summary',
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRecordDepositDialog(context, ref),
        icon: const Icon(Icons.add_task),
        label: const Text('Record Deposit'),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Bank Balance Card
          AppCard(
            color: AppColors.primaryLight.withValues(alpha: 0.08),
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
                          account.bankName,
                          style: AppTypography.titleLarge(context).copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'A/C: ${account.accountNumber} • IFSC: ${account.ifscCode}',
                          style: AppTypography.caption(context, color: AppColors.mutedTextFor(context)),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryLight,
                      child: Icon(Icons.account_balance, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available Bank Balance', style: AppTypography.caption(context)),
                          const SizedBox(height: 4),
                          Text(
                            currency.format(account.currentBalance),
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primaryLight),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.grey.shade300),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pending Deposits', style: AppTypography.caption(context)),
                          const SizedBox(height: 4),
                          Text(
                            currency.format(account.pendingVaultDeposits),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            'Recent Bank Deposits',
            style: AppTypography.titleLarge(context).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),

          ...deposits.map((dep) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: AppCard(
                child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.green.shade50,
                    child: Icon(Icons.arrow_downward, color: Colors.green.shade700, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dep.bankName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'Ref: ${dep.referenceNumber}',
                          style: TextStyle(fontSize: 12, color: AppColors.mutedTextFor(context)),
                        ),
                        Text(
                          'Deposited by ${dep.depositedBy} • ${DateFormat('dd MMM, yyyy').format(dep.date)}',
                          style: TextStyle(fontSize: 11, color: AppColors.mutedTextFor(context)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currency.format(dep.amount),
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.green.shade700),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Text(
                          dep.status,
                          style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        ],
      ),
    );
  }

  void _showRecordDepositDialog(BuildContext context, WidgetRef ref) {
    final amountController = TextEditingController();
    final refController = TextEditingController();
    final depositorController = TextEditingController(text: 'Priya Deshmukh (Treasurer)');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Bank Deposit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Deposit Amount (₹)', prefixIcon: Icon(Icons.attach_money)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: refController,
              decoration: const InputDecoration(labelText: 'Bank Ref / Counter Slip #', prefixIcon: Icon(Icons.receipt_long)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: depositorController,
              decoration: const InputDecoration(labelText: 'Deposited By', prefixIcon: Icon(Icons.person)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text) ?? 0;
              if (amt > 0) {
                final newEntry = BankDepositEntry(
                  id: 'DEP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                  date: DateTime.now(),
                  amount: amt,
                  bankName: 'State Bank of India',
                  referenceNumber: refController.text.trim().isNotEmpty ? refController.text.trim() : 'SBI-SLIP-RECONCILED',
                  depositedBy: depositorController.text.trim(),
                  status: 'Reconciled',
                );
                ref.read(bankDepositsProvider.notifier).addDeposit(newEntry);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deposit of ₹$amt recorded successfully.')),
                );
              }
            },
            child: const Text('Save Record'),
          ),
        ],
      ),
    );
  }
}
