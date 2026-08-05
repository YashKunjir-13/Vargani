import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/authentication/presentation/widgets/auth_design_tokens.dart';
import '../../features/dashboard/presentation/providers/dashboard_providers.dart';
import 'app_bottom_nav.dart';
import '../../core/core.dart';


class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.body,
    this.leading,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showBackButton = true,
  });

  final String title;
  final Widget? body;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.authColors;
    final l10n = context.l10n;
    final activeTabIndex = ref.watch(dashboardTabProvider);

    final effectiveBottomNav = bottomNavigationBar ??
        Container(
          decoration: BoxDecoration(
            color: colors.card,
            border: Border(top: BorderSide(color: colors.border)),
          ),
          child: AppBottomNav(
            currentIndex: activeTabIndex,
            onTap: (index) {
              ref.read(dashboardTabProvider.notifier).setTab(index);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            items: [
              AppBottomNavItem(
                icon: Icons.dashboard_outlined,
                selectedIcon: Icons.dashboard,
                label: l10n.mandalDashboardTitle.split(' ').first,
                route: '',
              ),
              const AppBottomNavItem(
                icon: Icons.monetization_on_outlined,
                selectedIcon: Icons.monetization_on,
                label: 'Contributions',
                route: '',
              ),
              const AppBottomNavItem(
                icon: Icons.description_outlined,
                selectedIcon: Icons.description,
                label: 'Bills',
                route: '',
              ),
              const AppBottomNavItem(
                icon: Icons.assessment_outlined,
                selectedIcon: Icons.assessment,
                label: 'Reports',
                route: '',
              ),
              AppBottomNavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: l10n.profile,
                route: '',
              ),
            ],
          ),
        );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: leading ??
            (showBackButton
                ? IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.text),
                    onPressed: () => Navigator.of(context).maybePop(),
                  )
                : null),
        title: Text(
          title,
          style: TextStyle(
            color: colors.text,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          ...?actions,
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: body,
      bottomNavigationBar: effectiveBottomNav,
      floatingActionButton: floatingActionButton,
    );
  }
}
