import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';

/// Builds the app's single Dio instance: base URL per environment, sane
/// timeouts, and a request interceptor that attaches the stored access
/// token so callers never have to thread it through manually.
bool _isRefreshing = false;

Dio buildApiClient(
    {required String environment, required TokenStorage tokenStorage}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: apiBaseUrlFor(environment),
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await tokenStorage.readAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        final orgId = await tokenStorage.readOrganizationId();
        if (orgId != null && orgId.isNotEmpty) {
          final hasTenantHeader = options.headers.keys.any(
            (k) => k.toLowerCase() == 'x-tenant-id',
          );
          if (!hasTenantHeader) {
            options.headers['X-Tenant-Id'] = orgId;
          }
        }
        handler.next(options);
      },
      onError: (err, handler) async {
        final isAuthEndpoint =
            err.requestOptions.path.contains('/auth/refresh') ||
                err.requestOptions.path.contains('/auth/login');

        if (err.response?.statusCode == 401 &&
            !isAuthEndpoint &&
            !_isRefreshing) {
          _isRefreshing = true;
          try {
            final refreshToken = await tokenStorage.readRefreshToken();
            if (refreshToken != null) {
              final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
              final response = await refreshDio.post<Map<String, dynamic>>(
                '/auth/refresh',
                data: {'refreshToken': refreshToken},
              );
              final data = response.data?['data'] as Map<String, dynamic>?;
              if (data != null && data['accessToken'] != null) {
                final newAccess = data['accessToken'] as String;
                final newRefresh =
                    (data['refreshToken'] as String?) ?? refreshToken;
                await tokenStorage.saveTokens(
                    accessToken: newAccess, refreshToken: newRefresh);

                final retryOptions = err.requestOptions;
                retryOptions.headers['Authorization'] = 'Bearer $newAccess';
                final retriedResponse = await dio.fetch(retryOptions);
                _isRefreshing = false;
                return handler.resolve(retriedResponse);
              }
            }
          } catch (_) {
            await tokenStorage.clear();
          } finally {
            _isRefreshing = false;
          }
        }
        handler.next(err);
      },
    ),
  );

  return dio;
}
