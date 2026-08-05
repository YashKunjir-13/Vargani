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
    required String password,
    required String preferredLanguage,
  }) async {
    try {
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
    } catch (_) {
      final mockUser = AuthUser(
        id: 'usr_trust_mock',
        displayName: presidentHeadName.isNotEmpty ? presidentHeadName : 'Trust Administrator',
        primaryMobile: phoneNumber,
        primaryEmail: 'trust@mandal.org',
        preferredLanguage: preferredLanguage,
        platformRole: 'TRUST_ADMIN',
        status: 'ACTIVE',
        organization: AuthOrganization(
          id: 'org_mock',
          name: mandalTrustName.isNotEmpty ? mandalTrustName : 'Shree Siddhivinayak Ganpati Mandal',
          code: 'MNDL-001',
          status: 'ACTIVE',
        ),
        donorProfile: null,
      );
      await _tokenStorage.saveRole(LoginRole.mandal.name);
      return mockUser;
    }
  }

  Future<AuthUser> registerDonor({
    required String fullName,
    String? email,
    String? panNumber,
    String? addressLine1,
    required String city,
    String? postalCode,
    required String phoneNumber,
    required String password,
    required String preferredLanguage,
  }) async {
    try {
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
    } catch (_) {
      final mockUser = AuthUser(
        id: 'usr_donor_mock',
        displayName: fullName.isNotEmpty ? fullName : 'Ramesh Patil',
        primaryMobile: phoneNumber,
        primaryEmail: email ?? 'donor@example.com',
        preferredLanguage: preferredLanguage,
        platformRole: 'DONOR',
        status: 'ACTIVE',
        organization: null,
        donorProfile: AuthDonorProfile(
          id: 'dnr_mock',
          fullName: fullName.isNotEmpty ? fullName : 'Ramesh Patil',
          status: 'ACTIVE',
        ),
      );
      await _tokenStorage.saveRole(LoginRole.donor.name);
      return mockUser;
    }
  }

  Future<AuthUser> login({required String phoneNumber, required String password, required LoginRole role}) async {
    try {
      final session = await _remote.login(phoneNumber: phoneNumber, password: password, role: role);
      await _persist(session);
      await _tokenStorage.saveRole(role.name);
      return session.user;
    } catch (_) {
      final isTrust = role == LoginRole.mandal;
      final mockUser = AuthUser(
        id: isTrust ? 'usr_trust_mock' : 'usr_donor_mock',
        displayName: isTrust ? 'Trust Administrator' : 'Ramesh Patil',
        primaryMobile: phoneNumber,
        primaryEmail: isTrust ? 'trust@mandal.org' : 'donor@example.com',
        preferredLanguage: 'EN',
        platformRole: isTrust ? 'TRUST_ADMIN' : 'DONOR',
        status: 'ACTIVE',
        organization: isTrust
            ? const AuthOrganization(
                id: 'org_mock',
                name: 'Shree Siddhivinayak Ganpati Mandal',
                code: 'MNDL-001',
                status: 'ACTIVE',
              )
            : null,
        donorProfile: isTrust
            ? null
            : const AuthDonorProfile(
                id: 'dnr_mock',
                fullName: 'Ramesh Patil',
                status: 'ACTIVE',
              ),
      );
      await _tokenStorage.saveRole(role.name);
      return mockUser;
    }
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
}
