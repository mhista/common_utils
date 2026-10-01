
import 'dart:async';

/// Result
/// A type-safe wrapper for handling success and failure states.
///
/// ```dart
/// final result = await Result.guard(() => api.fetchUser(id));
/// switch (result) {
///   case Success(:final data): print(data);
///   case Failure(:final message): print(message);
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Create a success result
  factory Result.success(T data) = Success<T>;

  /// Create a failure result.
  ///
  /// [exception] can be any [Exception] — including your own typed failure
  /// classes (e.g. `class AppFailure implements Exception`), which lets you
  /// carry rich error information without a second Result type.
  factory Result.failure(
    String message, {
    Exception? exception,
    StackTrace? stackTrace,
  }) = Failure<T>;

  /// Runs [body] and captures any thrown error as a [Failure].
  ///
  /// * Exceptions are stored as-is in [Failure.exception].
  /// * Non-[Exception] errors (e.g. `Error`, `String`) are wrapped so the
  ///   result never throws a `TypeError` while being built.
  /// * [mapError] lets you convert a raw error into a friendly message and/or
  ///   a typed exception (return `null` for the message to use `error.toString()`).
  ///
  /// ```dart
  /// final r = await Result.guard(
  ///   () => supabase.from('profiles').select().single(),
  ///   mapError: (e, st) => (message: 'Could not load profile', exception: null),
  /// );
  /// ```
  static Future<Result<V>> guard<V>(
    FutureOr<V> Function() body, {
    ({String? message, Exception? exception}) Function(
      Object error,
      StackTrace stackTrace,
    )?
    mapError,
  }) async {
    try {
      return Success<V>(await body());
    } catch (error, stackTrace) {
      final mapped = mapError?.call(error, stackTrace);
      return Failure<V>(
        mapped?.message ?? _messageOf(error),
        exception:
            mapped?.exception ??
            (error is Exception ? error : _WrappedError(error)),
        stackTrace: stackTrace,
      );
    }
  }

  /// Synchronous variant of [guard].
  static Result<V> guardSync<V>(V Function() body) {
    try {
      return Success<V>(body());
    } catch (error, stackTrace) {
      return Failure<V>(
        _messageOf(error),
        exception: error is Exception ? error : _WrappedError(error),
        stackTrace: stackTrace,
      );
    }
  }

  static String _messageOf(Object error) {
    final text = error.toString();
    return text.startsWith('Exception: ') ? text.substring(11) : text;
  }

  /// Check if result is success
  bool get isSuccess => this is Success<T>;

  /// Check if result is failure
  bool get isFailure => this is Failure<T>;

  /// Get data if success, null otherwise
  T? get dataOrNull => switch (this) {
        Success(data: final data) => data,
        Failure() => null,
      };

  /// Get error message if failure, null otherwise
  String? get errorOrNull => switch (this) {
        Success() => null,
        Failure(message: final message) => message,
      };

  /// Get exception if failure, null otherwise
  Exception? get exceptionOrNull => switch (this) {
        Success() => null,
        Failure(exception: final exception) => exception,
      };

  /// Get the captured stack trace if failure, null otherwise
  StackTrace? get stackTraceOrNull => switch (this) {
        Success() => null,
        Failure(stackTrace: final stackTrace) => stackTrace,
      };

  /// Collapse both branches into a single value.
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(Failure<T> failure) onFailure,
  ) {
    return switch (this) {
      Success(data: final data) => onSuccess(data),
      final Failure<T> failure => onFailure(failure),
    };
  }

  /// Transform the data if success
  Result<R> map<R>(R Function(T) transform) {
    return switch (this) {
      Success(data: final data) => Result.success(transform(data)),
      Failure(
        message: final message,
        exception: final exception,
        stackTrace: final stackTrace,
      ) =>
        Result.failure(message, exception: exception, stackTrace: stackTrace),
    };
  }

  /// FlatMap for chaining operations
  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    return switch (this) {
      Success(data: final data) => transform(data),
      Failure(
        message: final message,
        exception: final exception,
        stackTrace: final stackTrace,
      ) =>
        Result.failure(message, exception: exception, stackTrace: stackTrace),
    };
  }

  /// Execute callback on success
  Result<T> onSuccess(void Function(T) callback) {
    if (this is Success<T>) {
      callback((this as Success<T>).data);
    }
    return this;
  }

  /// Execute callback on failure
  Result<T> onFailure(void Function(String, Exception?) callback) {
    if (this is Failure<T>) {
      final failure = this as Failure<T>;
      callback(failure.message, failure.exception);
    }
    return this;
  }

  /// Get data or throw exception
  T getOrThrow() {
    return switch (this) {
      Success(data: final data) => data,
      Failure(message: final message, exception: final exception) =>
        throw exception ?? Exception(message),
    };
  }

  /// Get data or return default value
  T getOrDefault(T defaultValue) {
    return switch (this) {
      Success(data: final data) => data,
      Failure() => defaultValue,
    };
  }

  /// Get data or compute from error
  T getOrElse(T Function(String) compute) {
    return switch (this) {
      Success(data: final data) => data,
      Failure(message: final message) => compute(message),
    };
  }

  /// Recover from failure
  Result<T> recover(T Function(String) recovery) {
    return switch (this) {
      Success() => this,
      Failure(message: final message) => Result.success(recovery(message)),
    };
  }

  /// Recover from failure with Result
  Result<T> recoverWith(Result<T> Function(String) recovery) {
    return switch (this) {
      Success() => this,
      Failure(message: final message) => recovery(message),
    };
  }

  /// When pattern matching
  R when<R>({
    required R Function(T data) success,
    required R Function(String message, Exception? exception) failure,
  }) {
    return switch (this) {
      Success(data: final data) => success(data),
      Failure(message: final message, exception: final exception) =>
        failure(message, exception),
    };
  }
}

/// Success result
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

/// Failure result
final class Failure<T> extends Result<T> {
  final String message;
  final Exception? exception;

  /// Where the failure was captured (set automatically by [Result.guard]).
  /// Excluded from equality.
  final StackTrace? stackTrace;

  const Failure(this.message, {this.exception, this.stackTrace});

  @override
  String toString() => 'Failure(message: $message, exception: $exception)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          exception == other.exception;

  @override
  int get hashCode => message.hashCode ^ exception.hashCode;
}

/// Loading State Wrapper
/// Represents the state of an asynchronous operation
sealed class AsyncState<T> {
  const AsyncState();

  factory AsyncState.initial() = Initial<T>;
  factory AsyncState.loading() = Loading<T>;
  factory AsyncState.success(T data) = AsyncSuccess<T>;
  factory AsyncState.error(String message, {Exception? exception}) =
      AsyncError<T>;

  bool get isInitial => this is Initial<T>;
  bool get isLoading => this is Loading<T>;
  bool get isSuccess => this is AsyncSuccess<T>;
  bool get isError => this is AsyncError<T>;

  T? get dataOrNull => switch (this) {
        AsyncSuccess(data: final data) => data,
        _ => null,
      };

  String? get errorOrNull => switch (this) {
        AsyncError(message: final message) => message,
        _ => null,
      };

  AsyncState<R> map<R>(R Function(T) transform) {
    return switch (this) {
      AsyncSuccess(data: final data) => AsyncState.success(transform(data)),
      AsyncError(message: final message, exception: final exception) =>
        AsyncState.error(message, exception: exception),
      Initial() => AsyncState.initial(),
      Loading() => AsyncState.loading(),
    };
  }

  R when<R>({
    required R Function() initial,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message, Exception? exception) error,
  }) {
    return switch (this) {
      Initial() => initial(),
      Loading() => loading(),
      AsyncSuccess(data: final data) => success(data),
      AsyncError(message: final message, exception: final exception) =>
        error(message, exception),
    };
  }

  R maybeWhen<R>({
    R Function()? initial,
    R Function()? loading,
    R Function(T data)? success,
    R Function(String message, Exception? exception)? error,
    required R Function() orElse,
  }) {
    return switch (this) {
      Initial() => initial?.call() ?? orElse(),
      Loading() => loading?.call() ?? orElse(),
      AsyncSuccess(data: final data) => success?.call(data) ?? orElse(),
      AsyncError(message: final message, exception: final exception) =>
        error?.call(message, exception) ?? orElse(),
    };
  }
}

final class Initial<T> extends AsyncState<T> {
  const Initial();

  @override
  String toString() => 'Initial()';
}

final class Loading<T> extends AsyncState<T> {
  const Loading();

  @override
  String toString() => 'Loading()';
}

final class AsyncSuccess<T> extends AsyncState<T> {
  final T data;

  const AsyncSuccess(this.data);

  @override
  String toString() => 'Success(data: $data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncSuccess<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;
}

final class AsyncError<T> extends AsyncState<T> {
  final String message;
  final Exception? exception;

  const AsyncError(this.message, {this.exception});

  @override
  String toString() => 'Error(message: $message, exception: $exception)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AsyncError<T> &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          exception == other.exception;

  @override
  int get hashCode => message.hashCode ^ exception.hashCode;
}

// Usage examples live in the package README and example/ app —
// they are intentionally not part of the public library API.

/// Wraps a non-[Exception] error (e.g. an [Error] or a thrown String) so it can
/// travel inside [Failure.exception].
final class _WrappedError implements Exception {
  const _WrappedError(this.error);
  final Object error;

  @override
  String toString() => error.toString();
}
