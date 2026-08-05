import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_config.dart';

/// Builds the app's single Dio instance: base URL per environment, sane
/// timeouts, and a request interceptor that attaches the stored access
/// token so callers never have to thread it through manually.
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
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['x-tenant-id'] ??= '00000000-0000-4000-a000-000000000001';
        options.headers['x-dev-organization-id'] ??= '00000000-0000-4000-a000-000000000001';
        final accessToken = await tokenStorage.readAccessToken();
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
    ),
  );

  return dio;
}
