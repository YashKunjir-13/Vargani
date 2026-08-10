import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pauti_pustak_mobile/features/authentication/presentation/widgets/auth_design_tokens.dart';

class AccessRestrictedScreen extends StatelessWidget {
  final String? moduleTitle;

  const AccessRestrictedScreen({super.key, this.moduleTitle});

  @override
  Widget build(BuildContext context) {
    final colors = context.authColors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.card,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.text),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
        ),
        title: Text(
          'Access Restricted',
          style: TextStyle(
            color: colors.text,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 64,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Access Restricted',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  moduleTitle != null
                      ? "You don't have permission to access $moduleTitle."
                      : "You don't have permission to access this module.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.secondaryText,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Back to Dashboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.brandOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
