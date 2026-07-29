/// Maps the app's build environment to the API's base URL.
///
/// `10.0.2.2` is the Android emulator's alias for the host machine's
/// `localhost`, which is how the emulator reaches a locally-run backend.
String apiBaseUrlFor(String environment) {
  switch (environment) {
    case 'prod':
      return 'https://api.pautipustak.example/api/v1';
    case 'staging':
    case 'dev':
    default:
      return 'http://10.0.2.2:3000/api/v1';
  }
}
