import 'package:flutter/foundation.dart';

/// Maps the app's build environment to the API's base URL.
///
/// `10.0.2.2` is the Android emulator's alias for the host machine's
/// `localhost`. On Web (Chrome) or desktop/iOS simulator, `127.0.0.1` is used.
/// For physical devices, you must provide the Mac's LAN IP via dart-define:
/// --dart-define=BACKEND_HOST=192.168.x.x
String apiBaseUrlFor(String environment) {
  switch (environment) {
    case 'prod':
      return 'https://api.pautipustak.example/api/v1';
    case 'staging':
      return 'https://staging-api.pautipustak.example/api/v1';
    case 'dev':
    default:
      // Allow overriding the backend host/port via flutter run --dart-define
      const String customHost = String.fromEnvironment('BACKEND_HOST');
      const String port =
          String.fromEnvironment('BACKEND_PORT', defaultValue: '3000');

      if (customHost.isNotEmpty) {
        return 'http://$customHost:$port/api/v1';
      }

      if (kIsWeb) {
        return 'http://localhost:$port/api/v1';
      }

      if (defaultTargetPlatform == TargetPlatform.android) {
        // Default for Android Emulator
        return 'http://10.0.2.2:$port/api/v1';
      }

      // Default for iOS Simulator and Desktop
      return 'http://127.0.0.1:$port/api/v1';
  }
}
