import '../../../core/storage/token_storage.dart';
import 'auth_remote_datasource.dart';
import 'models/auth_models.dart';

/// Coordinates the auth remote data source with secure token persistence so
/// callers only ever deal in [AuthUser]/[AuthSession], never raw tokens.
class AuthRepository {
  AuthRepository({required AuthRemoteDataSource remoteDataSource, required TokenStorage tokenStorage})
      : _remote = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  Future<AuthUser> registerTrust({
    required String mandalTrustName,
    String? registrationNumber,
    required String presidentHeadName,
    String? addressLine1,
    required String city,
    required String state,
    required String postalCode,
    required int festivalYear,
    required String phoneNumber,
    String? password,
    required String preferredLanguage,
  }) async {
    final session = await _remote.registerTrust(
      mandalTrustName: mandalTrustName,
      registrationNumber: registrationNumber,
      presidentHeadName: presidentHeadName,
      addressLine1: addressLine1,
      city: city,
      state: state,
      postalCode: postalCode,
      festivalYear: festivalYear,
      phoneNumber: phoneNumber,
      password: password,
      preferredLanguage: preferredLanguage,
    );
    await _persist(session);
    await _tokenStorage.saveRole(LoginRole.mandal.name);
    return session.user;
  }

  Future<AuthUser> registerDonor({
    required String fullName,
    String? email,
    String? panNumber,
    String? addressLine1,
    required String city,
    String? postalCode,
    required String phoneNumber,
    String? password,
    required String preferredLanguage,
  }) async {
    final session = await _remote.registerDonor(
      fullName: fullName,
      email: email,
      panNumber: panNumber,
      addressLine1: addressLine1,
      city: city,
      postalCode: postalCode,
      phoneNumber: phoneNumber,
      password: password,
      preferredLanguage: preferredLanguage,
    );
    await _persist(session);
    await _tokenStorage.saveRole(LoginRole.donor.name);
    return session.user;
  }

  Future<AuthUser> login({required String phoneNumber, required String password, required LoginRole role}) async {
    final session = await _remote.login(phoneNumber: phoneNumber, password: password, role: role);
    await _persist(session);
    await _tokenStorage.saveRole(role.name);
    return session.user;
  }

  Future<OtpRequestResult> requestOtp({required String phoneNumber, required OtpPurpose purpose}) {
    return _remote.requestOtp(phoneNumber: phoneNumber, purpose: purpose);
  }

  Future<AuthUser> verifyOtp({required String phoneNumber, required String otp, required OtpPurpose purpose, required LoginRole role}) async {
    final session = await _remote.verifyOtp(phoneNumber: phoneNumber, otp: otp, purpose: purpose);
    await _persist(session);
    await _tokenStorage.saveRole(role.name);
    return session.user;
  }

  /// Attempts to restore a session from a previously persisted refresh
  /// token. Returns null if there is none, or if it's no longer valid.
  Future<({AuthUser user, LoginRole role})?> restoreSession() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return null;

    final roleStr = await _tokenStorage.readRole();
    if (roleStr == null) return null; // If role is missing, session is invalid for our dashboards
    final role = LoginRole.values.firstWhere((e) => e.name == roleStr, orElse: () => LoginRole.mandal);

    final refreshed = await _remote.refresh(refreshToken);
    await _tokenStorage.saveTokens(
      accessToken: refreshed.accessToken,
      refreshToken: refreshed.refreshToken,
    );
    final user = await _remote.me();
    return (user: user, role: role);
  }

  /// Revokes the session on the server, then always clears local tokens --
  /// even if the server call fails (e.g. offline), so a restart never
  /// silently signs the user back in.
  Future<void> logout() async {
    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken != null) {
        await _remote.logout(refreshToken);
      }
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<void> _persist(AuthSession session) => _tokenStorage.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );

  Future<void> createMpin({required String mpin}) {
    return _remote.createMpin(mpin: mpin);
  }

  Future<AuthUser> loginMpin({
    required String phoneNumber,
    required String mpin,
    required LoginRole role,
  }) async {
    final session = await _remote.loginMpin(phoneNumber: phoneNumber, mpin: mpin, role: role);
    await _persist(session);
    await _tokenStorage.saveRole(role.name);
    return session.user;
  }

  Future<OtpRequestResult> forgotMpin({required String phoneNumber}) {
    return _remote.forgotMpin(phoneNumber: phoneNumber);
  }

  Future<AuthUser> verifyMpinReset({
    required String phoneNumber,
    required String otp,
    required String newMpin,
    required LoginRole role,
  }) async {
    final session = await _remote.verifyMpinReset(
      phoneNumber: phoneNumber,
      otp: otp,
      newMpin: newMpin,
      role: role,
    );
    await _persist(session);
    await _tokenStorage.saveRole(role.name);
    return session.user;
  }
}
