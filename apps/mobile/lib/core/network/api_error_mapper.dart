import 'package:dio/dio.dart';

import 'api_exception.dart';

/// Runs [call], letting a successful [Response] through unchanged and
/// converting any Dio failure into the matching [ApiException] subtype so
/// callers only ever handle one exception hierarchy.
Future<T> guardApiCall<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (error) {
    throw _mapDioException(error);
  }
}

ApiException _mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkApiException(
        'Could not reach the server. Check your connection and try again.',
      );
    case DioExceptionType.cancel:
      return const NetworkApiException('Request was cancelled.');
    case DioExceptionType.badCertificate:
      return const NetworkApiException('Could not establish a secure connection.');
    case DioExceptionType.badResponse:
      return _mapStatusCode(error.response);
    case DioExceptionType.unknown:
    default:
      return const NetworkApiException(
        'Could not reach the server. Check your connection and try again.',
      );
  }
}

ApiException _mapStatusCode(Response<dynamic>? response) {
  final statusCode = response?.statusCode ?? 0;
  final body = response?.data;
  final message = _extractMessage(body);
  final fieldErrors = _extractFieldErrors(body);

  switch (statusCode) {
    case 400:
    case 422:
      return ValidationApiException(message ?? 'Please check the form and try again.',
          fieldErrors: fieldErrors);
    case 401:
      return UnauthorizedApiException(message ?? 'Invalid credentials.');
    case 403:
      return ForbiddenApiException(message ?? 'You are not allowed to do that.');
    case 404:
      return NotFoundApiException(message ?? 'The requested resource was not found.');
    case 409:
      return ConflictApiException(message ?? 'This already exists.');
    default:
      if (statusCode >= 500) {
        return ServerApiException(
          message ?? 'Something went wrong on our end. Please try again shortly.',
        );
      }
      return UnknownApiException(message ?? 'Something went wrong. Please try again.');
  }
}

String? _extractMessage(dynamic body) {
  if (body is Map<String, dynamic>) {
    final message = body['message'];
    if (message is String) return message;
    if (message is List && message.isNotEmpty) return message.first.toString();
  }
  return null;
}

List<String> _extractFieldErrors(dynamic body) {
  if (body is Map<String, dynamic>) {
    final message = body['message'];
    if (message is List) {
      return message.map((e) => e.toString()).toList();
    }
  }
  return const [];
}
