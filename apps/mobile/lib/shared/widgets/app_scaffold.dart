import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/core.dart';

class AppScaffold extends ConsumerWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.body,
    this.leading,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showBackButton = true,
  });

  final String title;
  final Widget? body;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showBackButton;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themePreference = ref.watch(themeProvider);
    final language = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.of(context).maybePop(),
              )
            : null,
        title: Text(title),
        actions: [
          ...?actions,
          Switch(
            value: themePreference == AppThemePreference.dark,
            onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => ref.read(localeProvider.notifier).setLanguage(AppLanguage.values[(AppLanguage.values.indexOf(language) + 1) % AppLanguage.values.length]),
            child: Text(language.name.toUpperCase()),
          ),
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
        ],
      ),
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
