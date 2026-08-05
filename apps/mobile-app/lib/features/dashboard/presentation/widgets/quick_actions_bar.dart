import 'package:flutter/material.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';

class QuickActionButtonItem {
  const QuickActionButtonItem({
    required this.id,
    required this.label,
    required this.icon,
    this.primary = false,
  });

  final String id;
  final String label;
  final IconData icon;
  final bool primary;
}

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    super.key,
    required this.actions,
    required this.onActionTap,
  });

  final List<QuickActionButtonItem> actions;
  final ValueChanged<QuickActionButtonItem> onActionTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: actions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _QuickActionButton(
                  action: action,
                  onTap: () => onActionTap(action),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.action,
    required this.onTap,
  });

  final QuickActionButtonItem action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;

    return Material(
      color: action.primary ? colors.brandOrange : colors.card,
      borderRadius: BorderRadius.circular(16),
      elevation: action.primary ? 4 : 0,
      shadowColor: action.primary ? colors.brandOrange.withValues(alpha: 0.4) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: action.primary ? null : Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                action.icon,
                color: action.primary ? Colors.white : colors.brandOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                action.label,
                style: TextStyle(
                  color: action.primary ? Colors.white : colors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
