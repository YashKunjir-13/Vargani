import 'package:flutter/widgets.dart';
import 'package:pauti_pustak_mobile/l10n/app_localizations.dart';

typedef FieldValidator = String? Function(String? value);

/// Single source of truth for authentication form validation, shared by
/// login, trust registration, and donor registration forms.
abstract final class AuthValidators {
  static final _phone = RegExp(r'^[6-9]\d{9}$');
  static final _email = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
  static final _pinCode = RegExp(r'^\d{6}$');
  static final _pan = RegExp(r'^[A-Z]{5}\d{4}[A-Z]$');

  static FieldValidator required(AppLocalizations l10n) {
    return (value) => (value == null || value.trim().isEmpty)
        ? l10n.errorRequiredField
        : null;
  }

  static FieldValidator phone(AppLocalizations l10n) {
    return (value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return l10n.errorRequiredField;
      return _phone.hasMatch(trimmed) ? null : l10n.errorInvalidPhoneNumber;
    };
  }

  static FieldValidator email(AppLocalizations l10n) {
    return (value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return null;
      return _email.hasMatch(trimmed) ? null : l10n.errorInvalidEmail;
    };
  }

  static FieldValidator optionalEmail(AppLocalizations l10n) => email(l10n);

  static FieldValidator pinCode(AppLocalizations l10n) {
    return (value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return null;
      return _pinCode.hasMatch(trimmed) ? null : l10n.errorInvalidPinCode;
    };
  }

  static FieldValidator pinCodeRequired(AppLocalizations l10n) {
    return (value) {
      final trimmed = value?.trim() ?? '';
      if (trimmed.isEmpty) return l10n.errorRequiredField;
      return _pinCode.hasMatch(trimmed) ? null : l10n.errorInvalidPinCode;
    };
  }

  static FieldValidator password(AppLocalizations l10n) {
    return (value) {
      final trimmed = value ?? '';
      if (trimmed.isEmpty) return l10n.errorRequiredField;
      return trimmed.length >= 8 ? null : l10n.errorPasswordTooShort;
    };
  }

  static FieldValidator confirmPassword(
      AppLocalizations l10n, TextEditingController password) {
    return (value) {
      final trimmed = value ?? '';
      if (trimmed.isEmpty) return l10n.errorRequiredField;
      return trimmed == password.text ? null : l10n.errorPasswordMismatch;
    };
  }

  static FieldValidator pan(AppLocalizations l10n) {
    return (value) {
      final trimmed = value?.trim().toUpperCase() ?? '';
      if (trimmed.isEmpty) return null;
      return _pan.hasMatch(trimmed) ? null : l10n.errorInvalidPanNumber;
    };
  }

  static FieldValidator optionalPan(AppLocalizations l10n) => pan(l10n);

  /// Runs a list of validators drawn from this class against their
  /// controllers and reports whether every one currently passes, without
  /// mutating any FormField's displayed error state.
  static bool allValid(Iterable<String?> results) =>
      results.every((result) => result == null);
}
