import 'package:flutter/widgets.dart';
import 'package:pauti_pustak_mobile/l10n/app_localizations.dart';

extension LocalizationBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
