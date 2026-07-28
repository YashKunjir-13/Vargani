import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';

/// Reusable app bar matching the exact screenshot design with prominent Back Button:
/// - Prominent Back Button ('<')
/// - Orange 'पप' logo badge
/// - Title & Subtitle ('Donor Portal' / 'Treasurer Portal')
/// - Segmented Language Pill ('म', 'हि', 'EN')
/// - Action / Logout button in soft red container
class PautiAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const PautiAppBar({
    super.key,
    required this.title,
    this.subtitle = 'Donor Portal',
    this.showBackButton = true,
    this.onBackPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLang = ref.watch(appLanguageProvider);
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: const Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
        ),
        child: Row(
          children: [
            // Prominent Back Button
            if (showBackButton) ...[
              InkWell(
                onTap: onBackPressed ??
                    () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFFEDD5), width: 1.5),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],

            // Orange 'पप' Logo Badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryLight.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'पप',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Segmented Language Selector Pill ('म', 'हि', 'EN')
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3EFE6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE6DFC5), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: AppLanguage.values.map((lang) {
                  final isSelected = lang == currentLang;
                  final displayLabel = switch (lang) {
                    AppLanguage.marathi => 'म',
                    AppLanguage.hindi => 'हि',
                    AppLanguage.english => 'EN',
                  };

                  return GestureDetector(
                    onTap: () {
                      ref.read(appLanguageProvider.notifier).setLanguage(lang);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryLight : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        displayLabel,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(width: 6),

            // Soft Red Logout Button Container
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out of Donor Portal')),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFFD6D6), width: 1),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
