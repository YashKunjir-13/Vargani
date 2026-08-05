import 'package:flutter/widgets.dart';
import 'package:pauti_pustak_mobile/core/localization/localization_extensions.dart';
import 'package:pauti_pustak_mobile/core/network/api_exception.dart';

/// Turns any [ApiException] into a message worth showing a user. Network
/// failures get a fully localized, client-owned message; server-driven
/// messages (validation/conflict/unauthorized/etc.) are shown as returned,
/// since the backend does not yet localize its error strings.
String describeApiException(BuildContext context, ApiException exception) {
  if (exception is NetworkApiException) {
    return context.l10n.errorNetwork;
  }
  return exception.message;
}
