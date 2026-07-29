import 'package:flutter/material.dart';

import '../../core/core.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Widget? leading;
  final String? title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null ||
            subtitle != null ||
            leading != null ||
            trailing != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(title!, style: AppTypography.titleMedium(context)),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(subtitle!,
                            style: AppTypography.caption(context,
                                color: AppColors.mutedTextFor(context))),
                      ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        if (title != null ||
            subtitle != null ||
            leading != null ||
            trailing != null)
          const SizedBox(height: 12),
        child,
      ],
    );

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: content,
        ),
      ),
    );
  }
}
