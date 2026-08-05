import 'package:flutter/material.dart';

/// Success / warning / info colors, with their container pairs.
///
/// [ColorScheme] has no native slots for these three, so they live in a
/// separate [ThemeExtension] instead of being folded into primary/secondary
/// (which are reserved for brand color, not status).
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;

  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;

  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;

  const SemanticColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  static const light = SemanticColors(
    success: Color(0xFF2E7D32),
    onSuccess: Color(0xFFFFFFFF),
    successContainer: Color(0xFFE3F1E4),
    onSuccessContainer: Color(0xFF0F3D13),
    warning: Color(0xFF9A6A00),
    onWarning: Color(0xFFFFFFFF),
    warningContainer: Color(0xFFFFF1CC),
    onWarningContainer: Color(0xFF3D2900),
    info: Color(0xFF1D5FA8),
    onInfo: Color(0xFFFFFFFF),
    infoContainer: Color(0xFFE3EEFB),
    onInfoContainer: Color(0xFF0B2F52),
  );

  static const dark = SemanticColors(
    success: Color(0xFF8FD69A),
    onSuccess: Color(0xFF0F3D13),
    successContainer: Color(0xFF1E4E24),
    onSuccessContainer: Color(0xFFD9F0DB),
    warning: Color(0xFFF2C05C),
    onWarning: Color(0xFF3D2900),
    warningContainer: Color(0xFF4E3900),
    onWarningContainer: Color(0xFFFFEAB8),
    info: Color(0xFF9CC5F2),
    onInfo: Color(0xFF0B2F52),
    infoContainer: Color(0xFF123A63),
    onInfoContainer: Color(0xFFDCEAFB),
  );

  @override
  SemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      onWarningContainer: onWarningContainer ?? this.onWarningContainer,
      info: info ?? this.info,
      onInfo: onInfo ?? this.onInfo,
      infoContainer: infoContainer ?? this.infoContainer,
      onInfoContainer: onInfoContainer ?? this.onInfoContainer,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      onSuccessContainer: Color.lerp(onSuccessContainer, other.onSuccessContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      onWarningContainer: Color.lerp(onWarningContainer, other.onWarningContainer, t)!,
      info: Color.lerp(info, other.info, t)!,
      onInfo: Color.lerp(onInfo, other.onInfo, t)!,
      infoContainer: Color.lerp(infoContainer, other.infoContainer, t)!,
      onInfoContainer: Color.lerp(onInfoContainer, other.onInfoContainer, t)!,
    );
  }
}
