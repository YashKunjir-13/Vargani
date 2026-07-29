import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/app_localizations.dart';
import '../core/permissions/user_role.dart';
import '../core/theme/app_colors.dart';
import '../features/bills/models/bill.dart';
import '../features/bills/state/bills_notifier.dart';
import '../features/contribution_receipts/state/contribution_receipts_notifier.dart';
import '../features/contributions/state/contributions_notifier.dart';
import '../features/payments/models/payment.dart';
import '../features/payments/state/payments_notifier.dart';
import '../features/receipts/state/receipts_notifier.dart';
import '../features/templates/state/templates_notifier.dart';
import '../shared/widgets/app_card.dart';
import '../shared/widgets/pauti_app_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentsProvider);
    final receipts = ref.watch(receiptsProvider);
    final bills = ref.watch(billsProvider);
    final contributions = ref.watch(contributionsProvider);
    final contributionReceipts = ref.watch(contributionReceiptsProvider);
    final activeTemplate = ref.watch(activeTemplateProvider);
    final currentRole = ref.watch(userRoleProvider);
    final theme = Theme.of(context);

    final pendingMatchCount = payments.where((p) => p.status == PaymentStatus.pendingMatch).length;
    final pendingApprovalCount = bills.where((b) => b.status == BillStatus.pendingApproval).length;

    return Scaffold(
      appBar: const PautiAppBar(
        title: 'Pauti Pustak',
        subtitle: 'Donor Portal',
        showBackButton: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card with Active Mandal Info & Current Role Pill
          AppCard(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 28,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10n.tr(ref, 'mandal_name'),
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.textPrimaryLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            L10n.tr(ref, 'festival_year'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          const Icon(Icons.person_pin, size: 16, color: AppColors.primaryLight),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Role: ${currentRole.label}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textPrimaryLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        const Icon(Icons.branding_watermark_outlined, size: 16, color: AppColors.primaryLight),
                        const SizedBox(width: 4),
                        Text(
                          'Tmpl: ${activeTemplate.id}',
                          style: const TextStyle(
                            color: AppColors.textSecondaryLight,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            'Core App Modules',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 1. Template Upload + Calibration Module
          _ModuleCard(
            icon: Icons.dashboard_customize_outlined,
            color: Colors.amber.shade800,
            title: L10n.tr(ref, 'template_calibration'),
            subtitle: 'Draggable field markers & active mandal branding',
            badge: 'Active: ${activeTemplate.id}',
            onTap: () => context.push('/templates'),
          ),
          const SizedBox(height: 12),

          // 2. Payment Collection
          _ModuleCard(
            icon: Icons.qr_code_2,
            color: Colors.teal,
            title: L10n.tr(ref, 'payment_collection'),
            subtitle: '${payments.length} payments recorded',
            badge: pendingMatchCount > 0 ? '$pendingMatchCount pending match' : null,
            onTap: () => context.push('/payments'),
          ),
          const SizedBox(height: 12),

          // 3. Receipt View / History (Donor-facing)
          _ModuleCard(
            icon: Icons.receipt_long_outlined,
            color: Colors.green,
            title: L10n.tr(ref, 'receipts'),
            subtitle: '${receipts.length} receipts issued • PDF re-download',
            onTap: () => context.push('/receipts'),
          ),
          const SizedBox(height: 12),

          // 4. Bill Generation
          _ModuleCard(
            icon: Icons.receipt_outlined,
            color: Colors.deepOrange,
            title: L10n.tr(ref, 'bill_generation'),
            subtitle: '${bills.length} bills tracked • OCR pre-fill review',
            badge: pendingApprovalCount > 0 ? '$pendingApprovalCount awaiting approval' : null,
            onTap: () => context.push('/bills'),
          ),
          const SizedBox(height: 12),

          // 5. Contributions Entry Form (Non-monetary)
          _ModuleCard(
            icon: Icons.volunteer_activism_outlined,
            color: Colors.pink,
            title: L10n.tr(ref, 'contributions'),
            subtitle: '${contributions.length} logged • Dynamic Gold/Silver picker',
            onTap: () => context.push('/contributions'),
          ),
          const SizedBox(height: 12),

          // 6. Contribution Receipts (Contributor-facing)
          _ModuleCard(
            icon: Icons.tag_outlined,
            color: Colors.deepPurple,
            title: L10n.tr(ref, 'contribution_receipts'),
            subtitle: '${contributionReceipts.length} issued • Independent CRCPT- counter',
            onTap: () => context.push('/contribution-receipts'),
          ),
        ],
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ],
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  badge!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}

