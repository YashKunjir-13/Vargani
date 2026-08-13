import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';

/// Builds the app's single Dio instance: base URL per environment, sane
/// timeouts, and a request interceptor that attaches the stored access
/// token so callers never have to thread it through manually.
class AuthQueuedInterceptor extends QueuedInterceptor {
  AuthQueuedInterceptor({
    required this.dio,
    required this.tokenStorage,
    required this.environment,
  });

  final Dio dio;
  final TokenStorage tokenStorage;
  final String environment;

  bool _isRefreshing = false;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await tokenStorage.readAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Prefer the currently active tenant when available.
    // Fall back to the organization ID for donor/organization flows.
    final activeTenantId = await tokenStorage.readActiveTenantId();

    if (activeTenantId != null && activeTenantId.isNotEmpty) {
      options.headers['X-Tenant-Id'] = activeTenantId;
    } else {
      final organizationId = await tokenStorage.readOrganizationId();

      if (organizationId != null && organizationId.isNotEmpty) {
        final hasTenantHeader = options.headers.keys.any(
          (key) => key.toLowerCase() == 'x-tenant-id',
        );

        if (!hasTenantHeader) {
          options.headers['X-Tenant-Id'] = organizationId;
        }
      }
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final isAuthEndpoint = err.requestOptions.path.contains('/auth/refresh') ||
        err.requestOptions.path.contains('/auth/login');

    if (err.response?.statusCode != 401 || isAuthEndpoint || _isRefreshing) {
      handler.next(err);
      return;
    }

    _isRefreshing = true;

    try {
      final refreshToken = await tokenStorage.readRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        handler.next(err);
        return;
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: apiBaseUrlFor(environment),
          connectTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      final response = await refreshDio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      final data = response.data?['data'] as Map<String, dynamic>?;

      if (data == null || data['accessToken'] == null) {
        handler.next(err);
        return;
      }

      final newAccessToken = data['accessToken'] as String;
      final newRefreshToken = (data['refreshToken'] as String?) ?? refreshToken;

      await tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      final retryOptions = err.requestOptions;

      retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await dio.fetch<dynamic>(retryOptions);

      handler.resolve(retryResponse);
    } catch (_) {
      await tokenStorage.clear();
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }
}

Dio buildApiClient({
  required String environment,
  required TokenStorage tokenStorage,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrlFor(environment),
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.add(
    AuthQueuedInterceptor(
      dio: dio,
      tokenStorage: tokenStorage,
      environment: environment,
    ),
  );

  return dio;
}
