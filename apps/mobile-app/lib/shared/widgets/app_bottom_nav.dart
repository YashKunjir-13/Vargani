import 'package:flutter/material.dart';
import '../../features/authentication/presentation/widgets/auth_design_tokens.dart';

class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    this.selectedIcon,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String route;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    final safeIndex = (currentIndex >= 0 && currentIndex < items.length) ? currentIndex : 0;

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: colors.card,
        indicatorColor: colors.brandOrange,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: Colors.white);
          }
          return IconThemeData(color: colors.secondaryText);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: colors.brandOrange,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            );
          }
          return TextStyle(
            color: colors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.normal,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: onTap ?? (_) {},
        destinations: items
            .map(
              (item) => NavigationDestination(
                icon: Icon(item.icon),
                selectedIcon: item.selectedIcon != null ? Icon(item.selectedIcon) : null,
                label: item.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
