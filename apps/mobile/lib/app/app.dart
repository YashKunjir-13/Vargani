import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/core.dart';
import 'home_screen.dart';

class PautiPustakApp extends ConsumerWidget {
  final String environment;

  const PautiPustakApp({super.key, required this.environment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Pauti Pustak ($environment)',
      debugShowCheckedModeBanner: environment != 'prod',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeModeFromPreference(preference),
      home: const HomeScreen(),
    );
  }
}
