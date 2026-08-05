import 'package:flutter/material.dart';

/// A section title with an optional trailing widget (typically a "See all"
/// link or an action button), used above every grouped section on every
/// hub screen (Quick Analytics, Trends, Recent Activity, ...).
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
