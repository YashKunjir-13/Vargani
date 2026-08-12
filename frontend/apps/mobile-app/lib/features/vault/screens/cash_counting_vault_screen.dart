import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';
import '../models/vault_models.dart';
import '../state/vault_notifier.dart';

class CashCountingVaultScreen extends ConsumerStatefulWidget {
  const CashCountingVaultScreen({super.key});

  @override
  ConsumerState<CashCountingVaultScreen> createState() =>
      _CashCountingVaultScreenState();
}

class _CashCountingVaultScreenState
    extends ConsumerState<CashCountingVaultScreen> {
  final _currencyFormat =
      NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(vaultProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final inVaultTotal = records
        .where((r) => r.status == VaultStatus.inVault)
        .fold(0, (sum, r) => sum + r.totalAmount);
    final inTransitTotal = records
        .where((r) => r.status == VaultStatus.inTransit)
        .fold(0, (sum, r) => sum + r.totalAmount);
    final depositedTotal = records
        .where((r) => r.status == VaultStatus.deposited)
        .fold(0, (sum, r) => sum + r.totalAmount);

    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Cash Counting & Vault',
        subtitle: 'Daan Peti & Vault Lifecycle',
        showBackButton: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCashCountSheet(context),
        icon: const Icon(Icons.calculate_outlined),
        label: const Text('Count Cash'),
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // Subsystem summary cards
          Row(
            children: [
              Expanded(
                child: _VaultStatCard(
                  title: 'In-Vault',
                  amount: _currencyFormat.format(inVaultTotal),
                  color: Colors.amber.shade800,
                  icon: Icons.shield_outlined,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _VaultStatCard(
                  title: 'In-Transit',
                  amount: _currencyFormat.format(inTransitTotal),
                  color: Colors.orange.shade700,
                  icon: Icons.local_shipping_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _VaultStatCard(
            title: 'Bank Deposited',
            amount: _currencyFormat.format(depositedTotal),
            color: Colors.green.shade700,
            icon: Icons.account_balance_outlined,
          ),

          const SizedBox(height: AppSpacing.xl),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daan Peti & Cash Logs',
                style: AppTypography.titleLarge(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${records.length} records',
                style: AppTypography.caption(context,
                    color: AppColors.mutedTextFor(context)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          ...records.map((record) => _buildRecordCard(context, record, isDark)),
        ],
      ),
    );
  }

  Widget _buildRecordCard(
      BuildContext context, VaultDepositRecord record, bool isDark) {
    final statusColor = switch (record.status) {
      VaultStatus.inVault => Colors.amber.shade800,
      VaultStatus.inTransit => Colors.orange.shade800,
      VaultStatus.deposited => Colors.green.shade700,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: statusColor),
                      const SizedBox(width: 6),
                      Text(
                        record.status.label,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  DateFormat('dd MMM, hh:mm a').format(record.date),
                  style: TextStyle(
                      fontSize: 12, color: AppColors.mutedTextFor(context)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      AppColors.primaryLight.withValues(alpha: 0.12),
                  child: const Icon(Icons.inbox_outlined,
                      color: AppColors.primaryLight, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.sourceLabel,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'ID: ${record.id}',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.mutedTextFor(context)),
                      ),
                    ],
                  ),
                ),
                Text(
                  _currencyFormat.format(record.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Dual Digital Sign-Off badges (Treasurer + President)
            Row(
              children: [
                _SignOffBadge(
                  roleLabel: 'Treasurer',
                  isSigned: record.treasurerSigned,
                ),
                const SizedBox(width: 8),
                _SignOffBadge(
                  roleLabel: 'President',
                  isSigned: record.presidentSigned,
                  onSignTap: !record.presidentSigned
                      ? () {
                          ref
                              .read(vaultProvider.notifier)
                              .signOffAsPresident(record.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'President sign-off recorded for ${record.id}')),
                          );
                        }
                      : null,
                ),
                const Spacer(),
                if (record.status == VaultStatus.inVault)
                  TextButton.icon(
                    onPressed: () {
                      ref
                          .read(vaultProvider.notifier)
                          .updateStatus(record.id, VaultStatus.inTransit);
                    },
                    icon: const Icon(Icons.local_shipping_outlined, size: 16),
                    label: const Text('Mark Transit'),
                  )
                else if (record.status == VaultStatus.inTransit)
                  TextButton.icon(
                    onPressed: () => _showDepositDialog(context, record),
                    icon: const Icon(Icons.account_balance_outlined, size: 16),
                    label: const Text('Record Deposit'),
                  ),
              ],
            ),
            if (record.bankReferenceNumber != null) ...[
              const SizedBox(height: 6),
              Text(
                'Bank Ref: ${record.bankReferenceNumber}',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDepositDialog(BuildContext context, VaultDepositRecord record) {
    final refController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Bank Deposit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Record ID: ${record.id}'),
            Text('Total Amount: ${_currencyFormat.format(record.totalAmount)}'),
            const SizedBox(height: 16),
            TextField(
              controller: refController,
              decoration: const InputDecoration(
                labelText: 'Bank Reference / UTR Number',
                hintText: 'e.g. SBI-TXN-9842104921',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(vaultProvider.notifier).updateStatus(
                    record.id,
                    VaultStatus.deposited,
                    bankReferenceNumber: refController.text.trim().isNotEmpty
                        ? refController.text.trim()
                        : 'REF-BANK-CONFIRMED',
                  );
              Navigator.pop(context);
            },
            child: const Text('Confirm Deposit'),
          ),
        ],
      ),
    );
  }

  void _showAddCashCountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _CashDenominationSheet(),
    );
  }
}

class _VaultStatCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;

  const _VaultStatCard({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(amount,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignOffBadge extends StatelessWidget {
  final String roleLabel;
  final bool isSigned;
  final VoidCallback? onSignTap;

  const _SignOffBadge({
    required this.roleLabel,
    required this.isSigned,
    this.onSignTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSigned ? Colors.green.shade700 : Colors.grey.shade600;

    return GestureDetector(
      onTap: onSignTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSigned ? Icons.check_circle : Icons.error_outline,
                size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              '$roleLabel: ${isSigned ? 'Signed' : 'Pending'}',
              style: TextStyle(
                  fontSize: 11, color: color, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _CashDenominationSheet extends ConsumerStatefulWidget {
  const _CashDenominationSheet();

  @override
  ConsumerState<_CashDenominationSheet> createState() =>
      _CashDenominationSheetState();
}

class _CashDenominationSheetState
    extends ConsumerState<_CashDenominationSheet> {
  final _sourceController =
      TextEditingController(text: 'Daan Peti #1 (Main Sanctuary)');
  int c500 = 0, c200 = 0, c100 = 0, c50 = 0, c20 = 0, c10 = 0, coins = 0;

  int get total =>
      (c500 * 500) +
      (c200 * 200) +
      (c100 * 100) +
      (c50 * 50) +
      (c20 * 20) +
      (c10 * 10) +
      coins;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency =
        NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daan Peti Cash Counter',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sourceController,
              decoration: const InputDecoration(
                labelText: 'Collection Source / Daan Peti ID',
                prefixIcon: Icon(Icons.inbox_outlined),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'DENOMINATION BREAKDOWN',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            _buildDenominationRow(
                '₹500', 500, c500, (val) => setState(() => c500 = val)),
            _buildDenominationRow(
                '₹200', 200, c200, (val) => setState(() => c200 = val)),
            _buildDenominationRow(
                '₹100', 100, c100, (val) => setState(() => c100 = val)),
            _buildDenominationRow(
                '₹50', 50, c50, (val) => setState(() => c50 = val)),
            _buildDenominationRow(
                '₹20', 20, c20, (val) => setState(() => c20 = val)),
            _buildDenominationRow(
                '₹10', 10, c10, (val) => setState(() => c10 = val)),
            _buildCoinsRow(),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Counted Cash:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(
                    currency.format(total),
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: AppColors.primaryLight),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: total > 0
                  ? () {
                      final newRecord = VaultDepositRecord(
                        id: 'VLT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                        date: DateTime.now(),
                        sourceLabel: _sourceController.text.trim(),
                        denominations: CashDenominationCount(
                          count500: c500,
                          count200: c200,
                          count100: c100,
                          count50: c50,
                          count20: c20,
                          count10: c10,
                          coinsAmount: coins,
                        ),
                        status: VaultStatus.inVault,
                        treasurerSigned: true,
                        presidentSigned: false,
                      );
                      ref.read(vaultProvider.notifier).addRecord(newRecord);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Cash count logged: ${currency.format(total)}')),
                      );
                    }
                  : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Save & Sign Off Cash Count'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: AppColors.primaryLight,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDenominationRow(String label, int multiplier, int currentCount,
      ValueChanged<int> onChanged) {
    final currency =
        NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Text('×'),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: TextFormField(
              initialValue: currentCount == 0 ? '' : '$currentCount',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                isDense: true,
              ),
              onChanged: (val) {
                onChanged(int.tryParse(val) ?? 0);
              },
            ),
          ),
          const Spacer(),
          Text(
            currency.format(currentCount * multiplier),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsRow() {
    final currency =
        NumberFormat.currency(symbol: '₹', locale: 'en_IN', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const SizedBox(
            width: 60,
            child: Text('Coins', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const Text('='),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: TextFormField(
              initialValue: coins == 0 ? '' : '$coins',
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'Total Coins ₹',
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                isDense: true,
              ),
              onChanged: (val) {
                setState(() => coins = int.tryParse(val) ?? 0);
              },
            ),
          ),
          const Spacer(),
          Text(
            currency.format(coins),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
