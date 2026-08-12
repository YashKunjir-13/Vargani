import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';

/// Builds the app's single Dio instance: base URL per environment, sane
/// timeouts, and a request interceptor that attaches the stored access
/// token so callers never have to thread it through manually.
class AuthQueuedInterceptor extends QueuedInterceptor {
  AuthQueuedInterceptor({required this.dio, required this.tokenStorage, required this.environment});

  final Dio dio;
  final TokenStorage tokenStorage;
  final String environment;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await tokenStorage.readAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    final activeTenantId = await tokenStorage.readActiveTenantId();
    if (activeTenantId != null) {
      options.headers['X-Tenant-Id'] = activeTenantId;
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('/auth/refresh') &&
        !err.requestOptions.path.contains('/auth/login')) {
      final refreshToken = await tokenStorage.readRefreshToken();
      if (refreshToken != null) {
        try {
          final refreshDio = Dio(BaseOptions(baseUrl: apiBaseUrlFor(environment)));
          final response = await refreshDio.post<Map<String, dynamic>>(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          final data = response.data!['data'] as Map<String, dynamic>;
          final newAccessToken = data['accessToken'] as String;
          final newRefreshToken = data['refreshToken'] as String;

          await tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );

          final retryOptions = err.requestOptions;
          retryOptions.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await dio.fetch<dynamic>(retryOptions);
          return handler.resolve(retryResponse);
        } catch (refreshError) {
          await tokenStorage.clear();
        }
      }
    }
    handler.next(err);
  }
}

Dio buildApiClient({required String environment, required TokenStorage tokenStorage}) {
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
