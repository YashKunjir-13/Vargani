import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/language_selector.dart';

class DashboardHeader extends ConsumerWidget implements PreferredSizeWidget {
  const DashboardHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeText = 'पप',
    this.onProfileTap,
    this.onNotificationTap,
    this.unreadNotificationsCount = 3,
  });

  final String title;
  final String subtitle;
  final String badgeText;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final int unreadNotificationsCount;

  @override
  Size get preferredSize => const Size.fromHeight(88);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.authColors;
    final l10n = context.l10n;

    return Container(
      color: colors.card,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Logo / Profile Badge
            GestureDetector(
              onTap: onProfileTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.brandOrange,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colors.brandOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Title & Subtitle
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.secondaryText,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),



            // Compact Language Selector
            const AuthLanguageSelector(),

            const SizedBox(width: 6),

            // Notification Bell with Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: onNotificationTap ?? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('You have $unreadNotificationsCount unread notifications'),
                        backgroundColor: colors.brandOrange,
                      ),
                    );
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: colors.surfaceMuted,
                    padding: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    Icons.notifications_none_outlined,
                    color: colors.text,
                    size: 22,
                  ),
                  tooltip: l10n.notifications,
                ),
                if (unreadNotificationsCount > 0)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$unreadNotificationsCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
