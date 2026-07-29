import 'package:flutter/material.dart';

/// Centralized color palette for Pauti Pustak design system.
/// Matches the authentic warm festival design system with rich saffron, terracotta, and warm cream.
class AppColors {
  AppColors._();

  // Primary Brand Colors - Saffron, Terracotta & Warm Gold
  static const Color primaryLight = Color(0xFFE05300); // Deep Vibrant Saffron / Orange
  static const Color primaryDark = Color(0xFFF97316);

  static const Color terracottaBanner = Color(0xFF782506); // Rich Terracotta Header Banner
  static const Color amountTerracotta = Color(0xFF9A3412); // Terracotta Amount Text

  static const Color secondaryLight = Color(0xFF1E3A8A); // Royal Navy
  static const Color secondaryDark = Color(0xFF60A5FA);

  static const Color accentGold = Color(0xFFEAB308); // Festive Gold
  static const Color accentGoldDark = Color(0xFFFACC15);

  // Background & Surface - Light Mode
  static const Color bgLight = Color(0xFFFAF7F2); // Warm Cream Off-White
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF4EFE6);
  static const Color borderLight = Color(0xFFF0E8DD);
  static const Color navIndicatorLight = Color(0xFFFFEAD5); // Soft Saffron Highlight

  // Background & Surface - Dark Mode
  static const Color bgDark = Color(0xFF0B0F19); // Rich Deep Slate
  static const Color surfaceDark = Color(0xFF151E2E);
  static const Color surfaceVariantDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF27354A);
  static const Color navIndicatorDark = Color(0xFF431407); // Dark Warm Saffron Container

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textMutedLight = Color(0xFF9CA3AF);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Mint Green Status Badges
  static const Color mintGreenBg = Color(0xFFDCFCE7);
  static const Color mintGreenText = Color(0xFF15803D);

  // Workflow Status Colors
  static const Color statusPending = Color(0xFFD97706); // Amber
  static const Color statusConfirmed = Color(0xFF2563EB); // Blue
  static const Color statusReceipted = Color(0xFF15803D); // Emerald Green
  static const Color statusVoided = Color(0xFF64748B); // Slate/Grey
  static const Color statusApproved = Color(0xFF059669); // Emerald
  static const Color statusRejected = Color(0xFFDC2626); // Red
  static const Color statusDraft = Color(0xFF475569); // Dark Slate

  // Amount Box Containers
  static const Color amberBoxBg = Color(0xFFFFFBEB);
  static const Color amberBoxBorder = Color(0xFFFDE68A);

  // Optional Badge Tag Accent
  static const Color optionalTagBg = Color(0xFFFEF3C7);
  static const Color optionalTagText = Color(0xFF92400E);

  // Elevation & Glow Shadows
  static final List<BoxShadow> softShadowLight = [
    BoxShadow(
      color: const Color(0xFF1F2937).withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1F2937).withValues(alpha: 0.02),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static final List<BoxShadow> softShadowDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

