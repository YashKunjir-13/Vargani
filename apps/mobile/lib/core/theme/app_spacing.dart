/// 8-point spacing scale. Never use a raw spacing number in widget code.
class AppSpacing {
  AppSpacing._();

  static const double space4 = 4;
  static const double space8 = 8;
  static const double space12 = 12;
  static const double space16 = 16;
  static const double space20 = 20;
  static const double space24 = 24;
  static const double space32 = 32;
  static const double space40 = 40;
  static const double space48 = 48;
  static const double space64 = 64;

  // Backward compatibility aliases
  static const double xs = space4;
  static const double sm = space8;
  static const double md = space16;
  static const double lg = space24;
  static const double xl = space32;
  static const double xxl = space48;

  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
}

class AppRadius {
  AppRadius._();

  static const double small = 8;
  static const double medium = 12;
  static const double large = 16;
  static const double extraLarge = 24;
}

/// MD3 elevation levels, in logical dp, matched to the approved design tokens.
class AppElevation {
  AppElevation._();

  static const double level1 = 1;
  static const double level2 = 3;
  static const double level3 = 6;
}

/// Icon sizes from the approved iconography scale.
class AppIconSize {
  AppIconSize._();

  /// 12dp -- for icons nested inside compact chips (e.g. [StatusChip]),
  /// smaller than the general iconography scale below.
  static const double compact = 12;

  static const double small = 18;
  static const double medium = 20;
  static const double large = 24;
  static const double extraLarge = 32;
}
