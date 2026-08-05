import 'package:flutter/material.dart';

/// Brightness-aware color tokens for the authentication feature.
/// Access via `context.authColors` rather than constructing directly.
class AuthColors {
  const AuthColors._({
    required this.brandOrange,
    required this.gold,
    required this.mutedAction,
    required this.background,
    required this.inputSurface,
    required this.card,
    required this.text,
    required this.secondaryText,
    required this.border,
    required this.surfaceMuted,
    required this.surfaceMutedBorder,
    required this.introCardBackground,
    required this.introCardBackgroundGold,
    required this.introCardBorder,
    required this.introCardBorderGold,
    required this.typeCardBackground,
    required this.typeCardBackgroundGold,
    required this.cardShadow,
    required this.iconShadow,
  });

  final Color brandOrange;
  final Color gold;
  final Color mutedAction;
  final Color background;
  final Color inputSurface;
  final Color card;
  final Color text;
  final Color secondaryText;
  final Color border;
  final Color surfaceMuted;
  final Color surfaceMutedBorder;
  final Color introCardBackground;
  final Color introCardBackgroundGold;
  final Color introCardBorder;
  final Color introCardBorderGold;
  final Color typeCardBackground;
  final Color typeCardBackgroundGold;
  final Color cardShadow;
  final Color iconShadow;

  static const _light = AuthColors._(
    brandOrange: Color(0xFFF57400),
    gold: Color(0xFFE5A000),
    mutedAction: Color(0xFFF8B57F),
    background: Color(0xFFFFFBF2),
    inputSurface: Color(0xFFFFF8EF),
    card: Colors.white,
    text: Color(0xFF24150E),
    secondaryText: Color(0xFF7C5B3A),
    border: Color(0xFFEEDBC8),
    surfaceMuted: Color(0xFFF6E9C8),
    surfaceMutedBorder: Color(0xFFE5D1A8),
    introCardBackground: Color(0xFFFFF9F1),
    introCardBackgroundGold: Color(0xFFFFF8D9),
    introCardBorder: Color(0xFFFFCCA0),
    introCardBorderGold: Color(0xFFE5A000),
    typeCardBackground: Color(0xFFFFF9F1),
    typeCardBackgroundGold: Color(0xFFFFF4C8),
    cardShadow: Color(0x12000000),
    iconShadow: Color(0x26000000),
  );

  static const _dark = AuthColors._(
    brandOrange: Color(0xFFFF8A3D),
    gold: Color(0xFFE5B84B),
    mutedAction: Color(0xFF6B4A2E),
    background: Color(0xFF181310),
    inputSurface: Color(0xFF241C15),
    card: Color(0xFF2A2119),
    text: Color(0xFFF5E9DC),
    secondaryText: Color(0xFFD0B08A),
    border: Color(0xFF4A3823),
    surfaceMuted: Color(0xFF332512),
    surfaceMutedBorder: Color(0xFF4A3823),
    introCardBackground: Color(0xFF2A2013),
    introCardBackgroundGold: Color(0xFF332A13),
    introCardBorder: Color(0xFF4A3823),
    introCardBorderGold: Color(0xFFE5B84B),
    typeCardBackground: Color(0xFF2A2013),
    typeCardBackgroundGold: Color(0xFF33290F),
    cardShadow: Color(0x40000000),
    iconShadow: Color(0x40000000),
  );

  static AuthColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}

extension AuthColorsContext on BuildContext {
  AuthColors get authColors => AuthColors.of(this);
}

abstract final class AuthSpacing {
  static const page = 24.0;
  static const section = 24.0;
  static const field = 20.0;
}
