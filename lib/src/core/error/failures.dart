import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  /// A message describing the failure
  final String message;

  /// The underlying exception that caused this failure
  final dynamic exception;

  /// Stack trace for debugging
  final StackTrace? stackTrace;

  const Failure({required this.message, this.exception, this.stackTrace});

  @override
  List<Object?> get props => [message, exception, stackTrace];

  @override
  String toString() => '$runtimeType: $message';
}

/// A failure that wraps an exception
class ExceptionFailure extends Failure {
  const ExceptionFailure({
    required super.message,
    required super.exception,
    super.stackTrace,
  });

  /// Creates an ExceptionFailure from an exception
  factory ExceptionFailure.fromException(
    dynamic exception, [
    StackTrace? stackTrace,
  ]) {
    return ExceptionFailure(
      message: exception.toString(),
      exception: exception,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }
}

/// A failure that represents a database error
class DatabaseFailure extends Failure {
  const DatabaseFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  /// Creates a DatabaseFailure from an exception
  factory DatabaseFailure.fromException(
    dynamic exception, [
    StackTrace? stackTrace,
  ]) {
    return DatabaseFailure(
      message: exception is String
          ? exception
          : exception?.toString() ?? 'Database error',
      exception: exception,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }
}

/// A failure that represents a network error
class NetworkFailure extends Failure {
  /// The HTTP status code, if available
  final int? statusCode;

  /// The response body, if available
  final dynamic response;

  const NetworkFailure({
    required super.message,
    this.statusCode,
    this.response,
    super.exception,
    super.stackTrace,
  });

  /// Creates a NetworkFailure from an exception
  factory NetworkFailure.fromException(
    dynamic exception, [
    StackTrace? stackTrace,
  ]) {
    return NetworkFailure(
      message: exception?.toString() ?? 'Network error',
      statusCode: exception?.response?.statusCode,
      response: exception?.response?.data,
      exception: exception,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  @override
  List<Object?> get props => [
    message,
    statusCode,
    response,
    exception,
    stackTrace,
  ];
}

/// A failure that represents a validation error
class ValidationFailure extends Failure {
  /// A map of field names to error messages
  final Map<String, List<String>> errors;

  const ValidationFailure({
    required this.errors,
    super.message = 'Validation failed',
    super.exception,
    super.stackTrace,
  });

  /// Creates a ValidationFailure from a map of errors
  factory ValidationFailure.fromErrors(
    Map<String, dynamic> errors, {
    String message = 'Validation failed',
  }) {
    final Map<String, List<String>> formattedErrors = {};

    errors.forEach((key, value) {
      if (value is List) {
        formattedErrors[key] = value.cast<String>();
      } else if (value is String) {
        formattedErrors[key] = [value];
      } else {
        formattedErrors[key] = [value.toString()];
      }
    });

    return ValidationFailure(errors: formattedErrors, message: message);
  }

  @override
  List<Object?> get props => [message, errors, exception, stackTrace];

  @override
  String toString() => '$runtimeType: $message\nErrors: $errors';
}

/// A failure that represents an authentication error
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  /// Creates an AuthenticationFailure from an exception
  factory AuthenticationFailure.fromException(
    dynamic exception, [
    StackTrace? stackTrace,
  ]) {
    return AuthenticationFailure(
      message: exception?.message ?? 'Authentication failed',
      exception: exception,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }
}

/// A failure that represents an authorization error
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  /// Creates an AuthorizationFailure from an exception
  factory AuthorizationFailure.fromException(
    dynamic exception, [
    StackTrace? stackTrace,
  ]) {
    return AuthorizationFailure(
      message: exception?.message ?? 'Authorization failed',
      exception: exception,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }
}

/// A failure that represents a not found error
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  /// Creates a NotFoundFailure for a specific resource
  factory NotFoundFailure.resource(String resource, [String? id]) {
    return NotFoundFailure(
      message: id != null
          ? 'The requested $resource with ID $id was not found'
          : 'The requested $resource was not found',
    );
  }
}

/// A failure that represents a cache error
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  /// Creates a CacheFailure from an exception
  factory CacheFailure.fromException(
    dynamic exception, [
    StackTrace? stackTrace,
  ]) {
    return CacheFailure(
      message: exception?.toString() ?? 'Cache error',
      exception: exception,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }
}

/// A failure that represents a server error
class ServerFailure extends Failure {
  /// The HTTP status code, if available
  final int? statusCode;

  /// The response body, if available
  final dynamic response;

  const ServerFailure({
    required super.message,
    this.statusCode,
    this.response,
    super.exception,
    super.stackTrace,
  });

  /// Creates a ServerFailure from an exception
  factory ServerFailure.fromException(
    dynamic exception, [
    StackTrace? stackTrace,
  ]) {
    return ServerFailure(
      message: exception?.response?.data?['message'] ?? 'Server error',
      statusCode: exception?.response?.statusCode,
      response: exception?.response?.data,
      exception: exception,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  @override
  List<Object?> get props => [
    message,
    statusCode,
    response,
    exception,
    stackTrace,
  ];
}

/// A failure that represents a timeout error
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Request timed out',
    super.exception,
    super.stackTrace,
  });

  /// Creates a TimeoutFailure from an exception
  factory TimeoutFailure.fromException(
    dynamic exception, [
    StackTrace? stackTrace,
  ]) {
    return TimeoutFailure(
      message: exception?.message ?? 'Request timed out',
      exception: exception,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }
}

/// A failure that represents a rate limit error
class RateLimitFailure extends Failure {
  /// The amount of time to wait before retrying
  final Duration? retryAfter;

  const RateLimitFailure({
    required super.message,
    this.retryAfter,
    super.exception,
    super.stackTrace,
  });

  @override
  List<Object?> get props => [message, retryAfter, exception, stackTrace];

  @override
  String toString() => retryAfter != null
      ? '$runtimeType: $message. Retry after ${retryAfter!.inSeconds} seconds'
      : super.toString();
}

/// A failure that represents a feature that is not available
class NotAvailableFailure extends Failure {
  const NotAvailableFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  /// Creates a NotAvailableFailure for a specific feature
  factory NotAvailableFailure.feature(String feature) {
    return NotAvailableFailure(
      message: 'The $feature feature is not available',
    );
  }
}

/// A failure that represents a cancelled operation
class CancelledFailure extends Failure {
  const CancelledFailure({
    super.message = 'Operation was cancelled',
    super.exception,
    super.stackTrace,
  });
}

/// A failure that represents an invalid state
class InvalidStateFailure extends Failure {
  const InvalidStateFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  /// Creates an InvalidStateFailure for a specific state
  factory InvalidStateFailure.state(String state) {
    return InvalidStateFailure(message: 'Invalid state: $state');
  }
}

/// A failure that represents a platform-specific error
class PlatformFailure extends Failure {
  const PlatformFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  /// Creates a PlatformFailure from an exception
  factory PlatformFailure.fromException(
    dynamic exception, [
    StackTrace? stackTrace,
  ]) {
    return PlatformFailure(
      message: exception?.toString() ?? 'Platform error',
      exception: exception,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }
}

/// A failure that represents a parsing error
class ParsingFailure extends Failure {
  /// The data that failed to be parsed
  final dynamic data;

  const ParsingFailure({
    required super.message,
    this.data,
    super.exception,
    super.stackTrace,
  });

  /// Creates a ParsingFailure from an exception
  factory ParsingFailure.fromException(
    dynamic exception, {
    dynamic data,
    StackTrace? stackTrace,
  }) {
    return ParsingFailure(
      message: exception?.toString() ?? 'Failed to parse data',
      data: data,
      exception: exception,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  @override
  List<Object?> get props => [message, data, exception, stackTrace];
}

/// A failure that represents a feature that is not implemented
class NotImplementedFailure extends Failure {
  const NotImplementedFailure({
    super.message = 'Not implemented',
    super.exception,
    super.stackTrace,
  });

  /// Creates a NotImplementedFailure for a specific feature
  factory NotImplementedFailure.feature(String feature) {
    return NotImplementedFailure(
      message: 'The $feature feature is not implemented',
    );
  }
}

/// A failure that represents a conflict with the current state of the resource
class ConflictFailure extends Failure {
  const ConflictFailure({
    required super.message,
    super.exception,
    super.stackTrace,
  });

  /// Creates a ConflictFailure for a specific resource
  factory ConflictFailure.resource(String resource, [String? id]) {
    return ConflictFailure(
      message: id != null
          ? 'The $resource with ID $id is in an invalid state for this operation'
          : 'The $resource is in an invalid state for this operation',
    );
  }
}

/// Extension methods for handling Either with Failure
extension EitherFailureX<L, R> on Either<L, R> {
  /// Maps the left side (failure) to a different type
  Either<T, R> mapLeft<T>(T Function(L) f) {
    return fold((l) => Left(f(l)), (r) => Right(r));
  }

  /// Maps the right side (success) to a different type
  Either<L, T> mapRight<T>(T Function(R) f) {
    return fold((l) => Left(l), (r) => Right(f(r)));
  }

  /// Handles the result of an Either with callbacks
  Future<void> onSuccess(FutureOr<void> Function(R) onSuccess) async {
    return fold((_) {}, (r) async => await onSuccess(r));
  }

  /// Handles the failure of an Either with a callback
  Future<void> onFailure(FutureOr<void> Function(L) onFailure) async {
    return fold((l) async => await onFailure(l), (_) {});
  }
}

/// Extension methods for handling `Future<Either>`
extension FutureEitherX<L, R> on Future<Either<L, R>> {
  /// Maps the right side (success) of the Either to a different type
  Future<Either<L, T>> mapRight<T>(FutureOr<T> Function(R) f) async {
    return then(
      (either) => either.fold((l) => Left(l), (r) async => Right(await f(r))),
    );
  }

  /// Maps the left side (failure) of the Either to a different type
  Future<Either<T, R>> mapLeft<T>(FutureOr<T> Function(L) f) async {
    return then(
      (either) => either.fold((l) async => Left(await f(l)), (r) => Right(r)),
    );
  }

  /// Handles the success case of the Either
  Future<Either<L, R>> onSuccess(FutureOr<void> Function(R) onSuccess) async {
    return then((either) async {
      await either.fold((_) {}, (r) async => await onSuccess(r));
      return either;
    });
  }

  /// Handles the failure case of the Either
  Future<Either<L, R>> onFailure(FutureOr<void> Function(L) onFailure) async {
    return then((either) async {
      await either.fold((l) async => await onFailure(l), (_) {});
      return either;
    });
  }

  /// Gets the right value or throws an exception
  Future<R> getOrThrow() async {
    return (await this).fold(
      (l) => throw l is Failure ? l : Exception(l),
      (r) => r,
    );
  }

  /// Gets the right value or a default value
  Future<R> getOrElse(R Function(L) orElse) async {
    return (await this).fold(orElse, (r) => r);
  }
}

/// Extension for converting exceptions to `Either<Failure, R>`
extension FutureExtension<T> on Future<T> {
  /// Converts a Future that may throw to a `Future<Either<Failure, T>>`
  Future<Either<Failure, T>> toEither() async {
    try {
      final result = await this;
      return Right(result);
    } on Failure catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      return Left(ExceptionFailure.fromException(e, stackTrace));
    }
  }

  /// Handles the success and error cases of a Future
  Future<void> handle({
    required FutureOr<void> Function(T) onSuccess,
    FutureOr<void> Function(dynamic, StackTrace)? onError,
  }) async {
    try {
      final result = await this;
      await onSuccess(result);
    } catch (e, stackTrace) {
      if (onError != null) {
        await onError(e, stackTrace);
      } else {
        rethrow;
      }
    }
  }
}
