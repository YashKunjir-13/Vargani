import 'package:flutter/material.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';

/// Inline, real error presentation for auth forms -- no SnackBars, no
/// canned "not available yet" copy. Shown directly above the submit button
/// so the message survives scrolling and stays visible while the user
/// corrects the form.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background =
        isDark ? const Color(0xFF3A1F1F) : const Color(0xFFFDECEC);
    final border = isDark ? const Color(0xFF6B3232) : const Color(0xFFF5C2C2);
    final foreground =
        isDark ? const Color(0xFFFFB4B4) : const Color(0xFFB3261E);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: foreground, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(color: foreground, fontSize: 14, height: 1.3)),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: foreground,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: Text(context.l10n.retry),
            ),
          ],
        ],
      ),
    );
  }
}
