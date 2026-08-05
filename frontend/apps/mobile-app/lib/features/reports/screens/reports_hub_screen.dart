import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/pauti_app_bar.dart';

class ReportsHubScreen extends StatelessWidget {
  const ReportsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Financial Reports & Audit',
        subtitle: 'Reports & One-Click Audit Export',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          // One-Click Audit Export Hero Banner Card
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primaryLight.withValues(alpha: 0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user, color: Colors.white, size: 28),
                    const SizedBox(width: 10),
                    Text(
                      'One-Click Audit Package',
                      style: AppTypography.titleLarge(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Bundles day-wise ledger, receipts, vendor bills, and audit trail into a verified PDF / Excel zip package.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showExportAuditDialog(context),
                  icon: const Icon(Icons.download, color: AppColors.primaryLight),
                  label: const Text('Export Complete Audit Package', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryLight,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          Text(
            'UML Financial Reports',
            style: AppTypography.titleLarge(context).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),

          // 1. Day-Wise Summary Report
          _ReportCard(
            title: '1. Day-Wise Financial Summary',
            subtitle: 'Daily collections, Daan Peti cash counts, and expense payouts',
            icon: Icons.calendar_today_outlined,
            formatTag: 'PDF / CSV',
            onTap: () => _showReportPreviewModal(context, 'Day-Wise Financial Summary', 'Daily collection trend: Day 1: ₹1.2L • Day 2: ₹1.8L • Day 3: ₹1.82L'),
          ),
          const SizedBox(height: AppSpacing.md),

          // 2. Category-Wise Expense Report
          _ReportCard(
            title: '2. Category-Wise Expense Report',
            subtitle: 'Decoration, Catering, Sound, CCTV & Vendor Payout breakdown',
            icon: Icons.pie_chart_outline,
            formatTag: 'PDF / Excel',
            onTap: () => _showReportPreviewModal(context, 'Category-Wise Expense Report', 'Decoration: ₹17.0L • Catering: ₹9.0L • Sound: ₹6.4L • Security: ₹2.0L'),
          ),
          const SizedBox(height: AppSpacing.md),

          // 3. Donor-Wise Contribution Report
          _ReportCard(
            title: '3. Donor-Wise Contribution Report',
            subtitle: 'All 342 contributors sorted by amount, date & payment mode',
            icon: Icons.groups_outlined,
            formatTag: 'PDF / Excel',
            onTap: () => _showReportPreviewModal(context, 'Donor-Wise Contribution Report', 'Total Donors: 342 • Top Contributor: Ramesh Patil (₹25,00,000)'),
          ),
          const SizedBox(height: AppSpacing.md),

          // 4. Final Accounts / Closure Report
          _ReportCard(
            title: '4. Final Accounts & Closure Report',
            subtitle: 'Balance Sheet, P&L, Audit Cert, and Festival Closure Document',
            icon: Icons.account_balance_wallet_outlined,
            formatTag: 'PDF (Certified)',
            onTap: () => _showReportPreviewModal(context, 'Final Accounts & Closure Report', 'Total Revenue: ₹48.23L • Total Expenditure: ₹11.48L • Surplus: ₹36.75L'),
          ),
        ],
      ),
    );
  }

  void _showReportPreviewModal(BuildContext context, String title, String summaryText) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.assessment_outlined, color: AppColors.primaryLight, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(summaryText, style: const TextStyle(fontSize: 14, height: 1.4)),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$title preview generated.')),
                      );
                    },
                    icon: const Icon(Icons.visibility_outlined),
                    label: const Text('Preview'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$title downloaded in PDF/Excel format.')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExportAuditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified_user, color: AppColors.primaryLight),
            SizedBox(width: 8),
            Text('Generate Audit Package'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Includes:'),
            SizedBox(height: 6),
            Text('• Signed Day-wise Cash & Vault Logs'),
            Text('• OCR Verified Vendor Bills & Invoices'),
            Text('• Sequential RCPT & CRCPT Receipts'),
            Text('• Bank Reconciled Deposit Slips'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Audit Zip Package generated & ready for download!'),
                  backgroundColor: AppColors.primaryLight,
                ),
              );
            },
            icon: const Icon(Icons.archive_outlined),
            label: const Text('Export ZIP Package'),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String formatTag;
  final VoidCallback onTap;

  const _ReportCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.formatTag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.12),
            child: Icon(icon, color: AppColors.primaryLight, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: AppColors.mutedTextFor(context), fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(formatTag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
