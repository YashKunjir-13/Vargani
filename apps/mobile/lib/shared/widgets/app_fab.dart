import 'package:flutter/material.dart';

class AppFab extends StatelessWidget {
  const AppFab({super.key, required this.label, this.onPressed, this.icon = Icons.add});

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
