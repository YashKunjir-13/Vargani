import 'package:flutter/foundation.dart';

/// Maps the app's build environment to the API's base URL.
///
/// `10.0.2.2` is the Android emulator's alias for the host machine's
/// `localhost`. On Web (Chrome) or desktop/iOS simulator, `localhost` is used.
String apiBaseUrlFor(String environment) {
  switch (environment) {
    case 'prod':
      return 'https://api.pautipustak.example/api/v1';
    case 'staging':
      return 'https://staging-api.pautipustak.example/api/v1';
    case 'dev':
    default:
      if (kIsWeb) {
        return 'http://localhost:3000/api/v1';
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:3000/api/v1';
      }
      return 'http://localhost:3000/api/v1';
  }
}
