import 'package:flutter/material.dart';

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
    return NavigationBar(
      selectedIndex: currentIndex,
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
    );
  }
}
