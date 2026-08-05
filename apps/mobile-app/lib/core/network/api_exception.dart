/// Typed representation of every failure the API client can surface, mapped
/// from either a Dio/HTTP response or a transport-level failure. Screens
/// switch on this to show a meaningful, localizable message instead of a
/// raw exception string.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;
}

/// HTTP 400 / 422 — request body failed validation. [fieldErrors] holds the
/// raw messages returned by the backend's ValidationPipe, if any.
class ValidationApiException extends ApiException {
  const ValidationApiException(super.message, {this.fieldErrors = const []});

  final List<String> fieldErrors;
}

/// HTTP 401 — missing/invalid/expired credentials or token.
class UnauthorizedApiException extends ApiException {
  const UnauthorizedApiException(super.message);
}

/// HTTP 403 — authenticated but not allowed (e.g. inactive/locked account).
class ForbiddenApiException extends ApiException {
  const ForbiddenApiException(super.message);
}

/// HTTP 404 — resource does not exist.
class NotFoundApiException extends ApiException {
  const NotFoundApiException(super.message);
}

/// HTTP 409 — conflicts with existing state (e.g. duplicate registration).
class ConflictApiException extends ApiException {
  const ConflictApiException(super.message);
}

/// HTTP 5xx — the server failed to process an otherwise valid request.
class ServerApiException extends ApiException {
  const ServerApiException(super.message);
}

/// No HTTP response at all: timeout, offline, DNS failure, connection reset.
class NetworkApiException extends ApiException {
  const NetworkApiException(super.message);
}

/// Anything that doesn't map to a more specific case above.
class UnknownApiException extends ApiException {
  const UnknownApiException(super.message);
}
