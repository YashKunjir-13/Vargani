import 'package:flutter/material.dart';

class AppBottomNavItem {
  const AppBottomNavItem({required this.icon, required this.label, required this.route});

  final IconData icon;
  final String label;
  final String route;
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({super.key, required this.items, required this.currentIndex});

  final List<AppBottomNavItem> items;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: (_) {},
      destinations: items
          .map(
            (item) => NavigationDestination(
              icon: Icon(item.icon),
              label: item.label,
            ),
          )
          .toList(),
    );
  }
}
