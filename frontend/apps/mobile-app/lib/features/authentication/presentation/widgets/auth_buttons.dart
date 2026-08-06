import 'package:flutter/material.dart';

import 'auth_design_tokens.dart';

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = _primaryButtonStyle(context);
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: icon == null
          ? FilledButton(
              onPressed: onPressed,
              style: style,
              child: Text(label),
            )
          : FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: style,
            ),
    );
  }
}

class AuthSecondaryButton extends StatelessWidget {
  const AuthSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = _secondaryButtonStyle(context);
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: icon == null
          ? OutlinedButton(
              onPressed: onPressed,
              style: style,
              child: Text(label),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
              style: style,
            ),
    );
  }
}

class AuthTextButton extends StatelessWidget {
  const AuthTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final style = _textButtonStyle(context);
    return icon == null
        ? TextButton(onPressed: onPressed, style: style, child: Text(label))
        : TextButton.icon(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            label: Text(label),
            style: style,
          );
  }
}

ButtonStyle _primaryButtonStyle(BuildContext context) {
  final colors = context.authColors;
  return FilledButton.styleFrom(
    backgroundColor: colors.brandOrange,
    disabledBackgroundColor: colors.mutedAction,
    foregroundColor: Colors.white,
    disabledForegroundColor: Colors.white,
    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

ButtonStyle _secondaryButtonStyle(BuildContext context) {
  final colors = context.authColors;
  return OutlinedButton.styleFrom(
    foregroundColor: colors.text,
    side: BorderSide(color: colors.border),
    textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

ButtonStyle _textButtonStyle(BuildContext context) {
  return TextButton.styleFrom(
    foregroundColor: context.authColors.brandOrange,
    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
  );
}
