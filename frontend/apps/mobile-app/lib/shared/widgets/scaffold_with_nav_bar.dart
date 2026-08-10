import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';

import '../../core/theme/app_colors.dart';
import '../../features/bills/models/bill.dart';
import '../../features/bills/state/bills_notifier.dart';
import '../../features/payments/models/payment.dart';
import '../../features/payments/state/payments_notifier.dart';

/// Persistent shell layout with an animated Material 3 NavigationBar and status badge indicators.
class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavBar({
    super.key,
    required this.child,
  });

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/payments')) return 1;
    if (location.startsWith('/receipts')) return 2;
    if (location.startsWith('/bills')) return 3;
    if (location.startsWith('/contributions')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/payments');
        break;
      case 2:
        context.go('/receipts');
        break;
      case 3:
        context.go('/bills');
        break;
      case 4:
        context.go('/contributions');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _calculateSelectedIndex(context);
    final asyncPayments = ref.watch(paymentsProvider);
    final bills = ref.watch(billsProvider);

    final pendingMatchCount = asyncPayments.maybeWhen(
      data: (list) => list.where((p) => p.status == PaymentStatus.pendingMatch).length,
      orElse: () => 0,
    );
    final pendingApprovalCount = bills.where((b) => b.status == BillStatus.pendingApproval).length;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final l10n = context.l10n;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
          ),
          boxShadow: isDark ? AppColors.softShadowDark : AppColors.softShadowLight,
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) => _onItemTapped(index, context),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home_rounded),
              label: l10n.homeTab,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pendingMatchCount > 0,
                label: Text('$pendingMatchCount'),
                backgroundColor: AppColors.statusPending,
                child: const Icon(Icons.qr_code_2_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: pendingMatchCount > 0,
                label: Text('$pendingMatchCount'),
                backgroundColor: AppColors.statusPending,
                child: const Icon(Icons.qr_code_2_rounded),
              ),
              label: l10n.paymentsTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.receipt_long_outlined),
              selectedIcon: const Icon(Icons.receipt_long_rounded),
              label: l10n.receiptsTab,
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: pendingApprovalCount > 0,
                label: Text('$pendingApprovalCount'),
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.receipt_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: pendingApprovalCount > 0,
                label: Text('$pendingApprovalCount'),
                backgroundColor: AppColors.primaryLight,
                child: const Icon(Icons.receipt_rounded),
              ),
              label: l10n.billsTab,
            ),
            NavigationDestination(
              icon: const Icon(Icons.volunteer_activism_outlined),
              selectedIcon: const Icon(Icons.volunteer_activism_rounded),
              label: l10n.contributionsTab,
            ),
          ],
        ),
      ),
    );
  }
}
