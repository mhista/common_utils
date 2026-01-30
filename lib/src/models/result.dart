import 'package:flutter/foundation.dart';

/// Result
/// A type-safe wrapper for handling success and failure states
sealed class Result<T> {
  const Result();

  /// Create a success result
  factory Result.success(T data) = Success<T>;

  /// Create a failure result
  factory Result.failure(String message, {Exception? exception}) = Failure<T>;

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

  /// Transform the data if success
  Result<R> map<R>(R Function(T) transform) {
    return switch (this) {
      Success(data: final data) => Result.success(transform(data)),
      Failure(message: final message, exception: final exception) =>
        Result.failure(message, exception: exception),
    };
  }

  /// FlatMap for chaining operations
  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    return switch (this) {
      Success(data: final data) => transform(data),
      Failure(message: final message, exception: final exception) =>
        Result.failure(message, exception: exception),
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

  const Failure(this.message, {this.exception});

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

/// Usage Examples
void resultExamples() {
  // Creating results
  final success = Result<String>.success('Hello World');
  final failure = Result<String>.failure('Something went wrong');

  // Checking state
  if (success.isSuccess) {
    debugPrint(success.dataOrNull); // Hello World
  }

  // Pattern matching with when
  final message = success.when(
    success: (data) => 'Got: $data',
    failure: (error, exception) => 'Error: $error',
  );

  // Transforming data
  final lengthResult = success.map((data) => data.length);

  // Chaining operations
  final result = success
      .map((data) => data.toUpperCase())
      .onSuccess((data) => debugPrint('Success: $data'))
      .onFailure((error, exception) => debugPrint('Error: $error'));

  // Getting data with fallback
  final data = failure.getOrDefault('Default value');

  // Recovering from failure
  final recovered = failure.recover((error) => 'Recovered value');
}

void asyncStateExamples() {
  // Creating states
  AsyncState<String> state = AsyncState.initial();
  state = AsyncState.loading();
  state = AsyncState.success('Data loaded');
  state = AsyncState.error('Failed to load');

  // Pattern matching
  final widget = state.when(
    initial: () => 'Initial state',
    loading: () => 'Loading...',
    success: (data) => 'Loaded: $data',
    error: (message, exception) => 'Error: $message',
  );

  // Maybe when (with fallback)
  final result = state.maybeWhen(
    success: (data) => data,
    orElse: () => 'No data',
  );
}

// Example with repository pattern
class UserRepository {
  Future<Result<User>> getUser(String id) async {
    try {
      // Simulated API call
      final userData = await fetchUserFromAPI(id);
      return Result.success(User.fromJson(userData));
    } catch (e) {
      return Result.failure(
        'Failed to fetch user',
        exception: e as Exception,
      );
    }
  }

  Future<Map<String, dynamic>> fetchUserFromAPI(String id) async {
    // Simulated
    return {'id': id, 'name': 'John Doe'};
  }
}

class User {
  final String id;
  final String name;

  User({required this.id, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
    );
  }
}