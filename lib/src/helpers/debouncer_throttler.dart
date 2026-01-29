import 'dart:async';

/// Debouncer
/// Delays function execution until after wait time has elapsed since last invocation
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// Run the callback after delay
  void call(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Run the callback with arguments after delay
  void run(void Function() callback) {
    call(callback);
  }

  /// Cancel any pending callback
  void cancel() {
    _timer?.cancel();
  }

  /// Check if timer is active
  bool get isActive => _timer?.isActive ?? false;

  /// Dispose and cancel timer
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Throttler
/// Ensures function is not called more than once in specified time period
class Throttler {
  final Duration duration;
  bool _isThrottled = false;
  Timer? _timer;

  Throttler({this.duration = const Duration(milliseconds: 500)});

  /// Run the callback if not throttled
  void call(void Function() callback) {
    if (_isThrottled) return;

    callback();
    _isThrottled = true;

    _timer = Timer(duration, () {
      _isThrottled = false;
    });
  }

  /// Run the callback with arguments if not throttled
  void run(void Function() callback) {
    call(callback);
  }

  /// Reset throttle state
  void reset() {
    _isThrottled = false;
    _timer?.cancel();
  }

  /// Check if currently throttled
  bool get isThrottled => _isThrottled;

  /// Dispose and reset
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _isThrottled = false;
  }
}

/// Typed Debouncer
/// Debouncer that can handle typed callbacks with return values
class TypedDebouncer<T> {
  final Duration delay;
  Timer? _timer;
  Completer<T>? _completer;

  TypedDebouncer({this.delay = const Duration(milliseconds: 500)});

  /// Run the callback and return Future
  Future<T> call(T Function() callback) {
    _timer?.cancel();
    _completer?.completeError('Cancelled');
    _completer = Completer<T>();

    _timer = Timer(delay, () {
      if (!_completer!.isCompleted) {
        try {
          final result = callback();
          _completer!.complete(result);
        } catch (e) {
          _completer!.completeError(e);
        }
      }
    });

    return _completer!.future;
  }

  /// Cancel any pending callback
  void cancel() {
    _timer?.cancel();
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError('Cancelled');
    }
  }

  /// Dispose
  void dispose() {
    cancel();
    _timer = null;
    _completer = null;
  }
}

/// Async Debouncer
/// Debouncer for async functions
class AsyncDebouncer {
  final Duration delay;
  Timer? _timer;

  AsyncDebouncer({this.delay = const Duration(milliseconds: 500)});

  /// Run async callback after delay
  Future<void> call(Future<void> Function() callback) async {
    _timer?.cancel();
    final completer = Completer<void>();

    _timer = Timer(delay, () async {
      try {
        await callback();
        completer.complete();
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  /// Cancel any pending callback
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

/// Async Throttler
/// Throttler for async functions
class AsyncThrottler {
  final Duration duration;
  bool _isThrottled = false;
  Timer? _timer;

  AsyncThrottler({this.duration = const Duration(milliseconds: 500)});

  /// Run async callback if not throttled
  Future<void> call(Future<void> Function() callback) async {
    if (_isThrottled) return;

    _isThrottled = true;
    await callback();

    _timer = Timer(duration, () {
      _isThrottled = false;
    });
  }

  /// Reset throttle state
  void reset() {
    _isThrottled = false;
    _timer?.cancel();
  }

  /// Check if currently throttled
  bool get isThrottled => _isThrottled;

  /// Dispose
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _isThrottled = false;
  }
}

/// Rate Limiter
/// Limits function calls to specified number per time period
class RateLimiter {
  final int maxCalls;
  final Duration period;
  final List<DateTime> _callTimes = [];

  RateLimiter({
    required this.maxCalls,
    required this.period,
  });

  /// Try to execute callback, returns false if rate limit exceeded
  bool call(void Function() callback) {
    final now = DateTime.now();
    
    // Remove old call times
    _callTimes.removeWhere(
      (time) => now.difference(time) > period,
    );

    if (_callTimes.length >= maxCalls) {
      return false;
    }

    _callTimes.add(now);
    callback();
    return true;
  }

  /// Get remaining calls allowed
  int get remainingCalls => maxCalls - _callTimes.length;

  /// Get time until next available call
  Duration? get timeUntilNextCall {
    if (_callTimes.length < maxCalls) return Duration.zero;
    
    final oldestCall = _callTimes.first;
    final elapsed = DateTime.now().difference(oldestCall);
    final remaining = period - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Reset the rate limiter
  void reset() {
    _callTimes.clear();
  }
}

/// Usage Examples
void debouncerExamples() {
  // Basic Debouncer
  final debouncer = Debouncer(delay: Duration(milliseconds: 500));
  
  // In a search field
  // onChanged: (value) {
  //   debouncer(() {
  //     performSearch(value);
  //   });
  // }

  // Typed Debouncer
  final typedDebouncer = TypedDebouncer<String>(
    delay: Duration(milliseconds: 500),
  );
  
  // Future<String> result = typedDebouncer(() {
  //   return fetchSearchResults(query);
  // });

  // Async Debouncer
  final asyncDebouncer = AsyncDebouncer(
    delay: Duration(milliseconds: 500),
  );
  
  // await asyncDebouncer(() async {
  //   await saveData();
  // });
}

void throttlerExamples() {
  // Basic Throttler
  final throttler = Throttler(duration: Duration(seconds: 1));
  
  // In a button
  // onPressed: () {
  //   throttler(() {
  //     submitForm();
  //   });
  // }

  // Async Throttler
  final asyncThrottler = AsyncThrottler(
    duration: Duration(seconds: 1),
  );
  
  // await asyncThrottler(() async {
  //   await uploadFile();
  // });
}

void rateLimiterExamples() {
  // Rate Limiter (max 5 calls per minute)
  final rateLimiter = RateLimiter(
    maxCalls: 5,
    period: Duration(minutes: 1),
  );
  
  // bool success = rateLimiter(() {
  //   callAPI();
  // });
  //
  // if (!success) {
  //   print('Rate limit exceeded. Try again in ${rateLimiter.timeUntilNextCall}');
  // }
}