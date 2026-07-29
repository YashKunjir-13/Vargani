import 'package:flutter/material.dart';

class AppTypography {
  static TextStyle display(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ) ??
        const TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
  }

  static TextStyle titleLarge(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ) ??
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w700);
  }

  static TextStyle titleMedium(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ) ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  }

  static TextStyle body(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: color,
            ) ??
        const TextStyle(fontSize: 14);
  }

  static TextStyle label(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ) ??
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600);
  }

  static TextStyle bodySmall(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ) ??
        const TextStyle(fontSize: 12);
  }

  static TextStyle caption(BuildContext context, {Color? color}) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
            ) ??
        const TextStyle(fontSize: 12);
  }
}
