import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pauti_pustak_mobile/core/localization/locale_controller.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';
import 'package:pauti_pustak_mobile/core/theme/app_theme.dart';

import 'auth_design_tokens.dart';

/// Shared language control for all authentication screens.
class AuthLanguageSelector extends ConsumerWidget {
  const AuthLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLocale = ref.watch(localeControllerProvider);
    final controller = ref.read(localeControllerProvider.notifier);
    final l10n = context.l10n;
    final colors = context.authColors;

    return Semantics(
      label: l10n.selectLanguage,
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              label: 'म',
              semanticsLabel: l10n.languageMarathi,
              selected: selectedLocale.languageCode == 'mr',
              onSelected: () =>
                  unawaited(controller.selectLocale(const Locale('mr'))),
            ),
            _LanguageOption(
              label: 'हि',
              semanticsLabel: l10n.languageHindi,
              selected: selectedLocale.languageCode == 'hi',
              onSelected: () =>
                  unawaited(controller.selectLocale(const Locale('hi'))),
            ),
            _LanguageOption(
              label: 'EN',
              semanticsLabel: l10n.languageEnglish,
              selected: selectedLocale.languageCode == 'en',
              onSelected: () =>
                  unawaited(controller.selectLocale(const Locale('en'))),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.semanticsLabel,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final String semanticsLabel;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(minWidth: 34),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: selected
                ? BoxDecoration(
                    color: colors.brandOrange,
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : colors.secondaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthThemeToggle extends ConsumerWidget {
  const AuthThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.authColors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = ref.read(appThemeModeProvider.notifier);

    return Semantics(
      label: 'Toggle Theme',
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              icon: Icons.wb_sunny_rounded,
              semanticsLabel: 'Light Mode',
              selected: !isDark,
              onSelected: () => controller.setThemeMode(ThemeMode.light),
            ),
            _ThemeOption(
              icon: Icons.nightlight_round,
              semanticsLabel: 'Dark Mode',
              selected: isDark,
              onSelected: () => controller.setThemeMode(ThemeMode.dark),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.semanticsLabel,
    required this.selected,
    required this.onSelected,
  });

  final IconData icon;
  final String semanticsLabel;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onSelected,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(minWidth: 38),
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: selected
                ? BoxDecoration(
                    color: colors.brandOrange,
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Icon(
              icon,
              size: 20,
              color: selected ? Colors.white : colors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}
