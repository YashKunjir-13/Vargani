import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists the access/refresh token pair in the platform secure store
/// (Android Keystore / iOS Keychain), so they survive app restarts but
/// never touch plain SharedPreferences.
class TokenStorage {
  TokenStorage({FlutterSecureStorage? secureStorage})
      : _storage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';
  static const _roleKey = 'auth.role';

  // Tenant context used by the current NEX-UP implementation.
  static const _activeTenantIdKey = 'auth.active_tenant_id';

  // Organization context used by the donor dashboard implementation.
  static const _orgKey = 'auth.organization_id';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> readAccessToken() =>
      _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() =>
      _storage.read(key: _refreshTokenKey);

  Future<void> saveRole(String role) =>
      _storage.write(key: _roleKey, value: role);

  Future<String?> readRole() =>
      _storage.read(key: _roleKey);

  // Tenant methods
  Future<void> saveActiveTenantId(String tenantId) =>
      _storage.write(key: _activeTenantIdKey, value: tenantId);

  Future<String?> readActiveTenantId() =>
      _storage.read(key: _activeTenantIdKey);

  // Organization methods
  Future<void> saveOrganizationId(String orgId) =>
      _storage.write(key: _orgKey, value: orgId);

  Future<String?> readOrganizationId() =>
      _storage.read(key: _orgKey);

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _activeTenantIdKey);
    await _storage.delete(key: _orgKey);
  }
}
