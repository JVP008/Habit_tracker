/// Base class for all application exceptions
abstract class AppException implements Exception {
  /// A message describing the error
  final String message;

  /// The underlying exception that caused this exception
  final dynamic cause;

  /// Stack trace for debugging
  final StackTrace? stackTrace;

  const AppException({required this.message, this.cause, this.stackTrace});

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when there's an error with the database
class DatabaseException extends AppException {
  const DatabaseException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Thrown when a requested resource is not found
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Thrown when there's a network error
class NetworkException extends AppException {
  final int? statusCode;
  final String? response;

  const NetworkException({
    required super.message,
    this.statusCode,
    this.response,
    super.cause,
    super.stackTrace,
  });

  /// Creates a NetworkException from a DioError
  factory NetworkException.fromDioError(dynamic error) {
    try {
      return NetworkException(
        message: error?.response?.data?['message'] ?? 'Network request failed',
        statusCode: error?.response?.statusCode,
        response: error?.response?.data?.toString(),
        cause: error,
        stackTrace: error?.stackTrace,
      );
    } catch (_) {
      return const NetworkException(message: 'Network request failed');
    }
  }
}

/// Thrown when there's an authentication error
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Thrown when there's an authorization error
class AuthorizationException extends AppException {
  const AuthorizationException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Thrown when there's a validation error
class ValidationException extends AppException {
  final Map<String, List<String>> errors;

  const ValidationException({
    required this.errors,
    super.message = 'Validation failed',
    super.cause,
    super.stackTrace,
  });

  @override
  String toString() => '$runtimeType: $message\nErrors: $errors';
}

/// Thrown when a feature is not implemented
class NotImplementedException extends AppException {
  const NotImplementedException({
    super.message = 'Not implemented',
    super.cause,
    super.stackTrace,
  });
}

/// Thrown when a feature is not available
class NotAvailableException extends AppException {
  const NotAvailableException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Thrown when a request times out
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timed out',
    super.cause,
    super.stackTrace,
  });
}

/// Thrown when a cache operation fails
class CacheException extends AppException {
  const CacheException({required super.message, super.cause, super.stackTrace});
}

/// Thrown when there's a conflict with the current state of the resource
class ConflictException extends AppException {
  const ConflictException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}

/// Thrown when a request is cancelled
class CancelledException extends AppException {
  const CancelledException({
    super.message = 'Request was cancelled',
    super.cause,
    super.stackTrace,
  });
}

/// Thrown when a request is rate limited
class RateLimitException extends AppException {
  final Duration? retryAfter;

  const RateLimitException({
    required super.message,
    this.retryAfter,
    super.cause,
    super.stackTrace,
  });

  @override
  String toString() => retryAfter != null
      ? '$runtimeType: $message. Retry after ${retryAfter!.inSeconds} seconds'
      : super.toString();
}

/// Thrown when the app is in an invalid state
class InvalidStateException extends AppException {
  const InvalidStateException({
    required super.message,
    super.cause,
    super.stackTrace,
  });
}
