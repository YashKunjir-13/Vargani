import 'package:flutter/material.dart';

/// Placeholder landing screen for the foundation phase. Replaced by the
/// real authenticated shell (dashboard, nav rail, event switcher) once
/// feature phases land.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pauti Pustak'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 72,
                color: Color(0xFF1E3A8A),
              ),
              const SizedBox(height: 16),
              Text(
                'Multi-tenant Event Financial-Management',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Enterprise Foundation Ready',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
