import 'dart:io';
import 'package:dio/dio.dart';
import 'package:talker/talker.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// Singleton HTTP Client Service
///
/// A comprehensive HTTP client built on Dio with:
/// - Singleton pattern for shared instance across app
/// - Dynamic interceptor management (add/remove after init)
/// - Automatic retry logic for failed requests
/// - Token-based authentication with auto-refresh
/// - Request/response logging with Talker
/// - Type-safe error handling
/// - File upload/download support
/// - OpenAPI/Swagger compatible
///
/// MULTIPART / FILE UPLOAD — IMPORTANT NOTE:
/// ──────────────────────────────────────────
/// Never set Content-Type to 'multipart/form-data' manually in headers.
/// When Dio sends a [FormData] body it automatically generates:
///
///   Content-Type: multipart/form-data; boundary=----dartBoundary...
///
/// If you override this header manually (even with the correct value) you
/// strip the `boundary` parameter, which the server uses to split fields.
/// The result is a malformed request body that the server cannot parse,
/// typically returning a connection error with a null status code.
///
/// Rule: pass [FormData] and let Dio handle Content-Type entirely.
///
/// Usage:
/// ```dart
/// // Initialize once in main.dart
/// HttpClient.init(
///   baseUrl: 'https://api.example.com',
///   interceptors: [
///     AuthInterceptor(
///       getToken: () => storage.getString('token'),
///       refreshToken: () async => await refreshMyToken(),
///     ),
///   ],
/// );
///
/// // Add interceptors later
/// HttpClient.instance.addInterceptor(MyCustomInterceptor());
///
/// // Use anywhere in your app
/// final client = HttpClient.instance;
/// final response = await client.get<User>('/users/1', parser: User.fromJson);
/// ```
class HttpClient {
  // ==================== Singleton Setup ====================

  /// Private constructor
  HttpClient._({
    required this.baseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.sendTimeout,
    required this.headers,
    required this.enableLogging,
    List<Interceptor>? interceptors,
    Talker? talker,
  }) {
    _initializeDio(interceptors, talker);
  }

  /// Singleton instance
  static HttpClient? _instance;

  /// Dio instance
  late Dio _dio;

  /// Configuration
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final Map<String, String> headers;
  final bool enableLogging;

  /// Track logging interceptor reference
  TalkerDioLogger? _loggingInterceptor;

  /// Track error interceptor reference
  ErrorInterceptor? _errorInterceptor;

  /// Initialize singleton instance
  ///
  /// Call this once in main.dart before using the client.
  ///
  /// Example:
  /// ```dart
  /// HttpClient.init(
  ///   baseUrl: 'https://auth-api.merkado.site',
  ///   connectTimeout: Duration(seconds: 30),
  ///   headers: {'Content-Type': 'application/json'},
  ///   enableLogging: true,
  ///   interceptors: [
  ///     AuthInterceptor(
  ///       getToken: () => StorageService.instance.getString('accessToken') ?? '',
  ///       refreshToken: () async {
  ///         // Your token refresh logic
  ///         return await refreshAccessToken();
  ///       },
  ///     ),
  ///   ],
  /// );
  /// ```
  static void init({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Duration sendTimeout = const Duration(seconds: 30),
    Map<String, String> headers = const {},
    bool enableLogging = true,
    List<Interceptor>? interceptors,
    Talker? talker,
  }) {
    _instance ??= HttpClient._(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      sendTimeout: sendTimeout,
      headers: headers,
      enableLogging: enableLogging,
      interceptors: interceptors,
      talker: talker,
    );
  }

  /// Get singleton instance
  ///
  /// Throws exception if not initialized.
  static HttpClient get instance {
    if (_instance == null) {
      throw HttpClientNotInitializedException();
    }
    return _instance!;
  }

  /// Check if instance is initialized
  static bool get isInitialized => _instance != null;

  /// Reset singleton (useful for testing)
  static void reset() {
    _instance = null;
  }

  // ==================== Initialization ====================

  /// Initialize Dio with interceptors
  void _initializeDio(List<Interceptor>? customInterceptors, Talker? talker) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: connectTimeout,
        receiveTimeout: receiveTimeout,
        sendTimeout: sendTimeout,
        headers: headers,
        // ⚠️ Do NOT set contentType here to 'multipart/form-data'.
        // JSON is the correct default. Dio overrides it automatically
        // (with the required boundary) when a FormData body is passed.
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
      ),
    );

    // Add logging interceptor first (to log everything)
    if (enableLogging) {
      _loggingInterceptor = TalkerDioLogger(
        talker: talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
          printRequestData: true,
          printResponseData: true,
        ),
      );
      _dio.interceptors.add(_loggingInterceptor!);
    }

    // Add error/retry interceptor
    _errorInterceptor = ErrorInterceptor();
    _dio.interceptors.add(_errorInterceptor!);

    // Add custom interceptors (like Auth)
    if (customInterceptors != null) {
      _dio.interceptors.addAll(customInterceptors);
    }
  }

  /// Get raw Dio instance for advanced use cases
  Dio get dio => _dio;

  // ==================== Interceptor Management ====================

  /// Add a single interceptor
  ///
  /// The interceptor will be added after logging and error interceptors
  /// but you can control the position with the [index] parameter.
  ///
  /// Example:
  /// ```dart
  /// // Add auth interceptor after initialization
  /// HttpClient.instance.addInterceptor(
  ///   AuthInterceptor(
  ///     getToken: () => token,
  ///     refreshToken: () async => await refresh(),
  ///   ),
  /// );
  ///
  /// // Add at specific position (0 = first)
  /// HttpClient.instance.addInterceptor(
  ///   MyInterceptor(),
  ///   index: 0,
  /// );
  /// ```
  void addInterceptor(Interceptor interceptor, {int? index}) {
    if (index != null) {
      _dio.interceptors.insert(index, interceptor);
    } else {
      _dio.interceptors.add(interceptor);
    }
  }

  /// Add multiple interceptors at once
  void addInterceptors(List<Interceptor> interceptors) {
    _dio.interceptors.addAll(interceptors);
  }

  /// Remove a specific interceptor
  ///
  /// Returns true if the interceptor was found and removed.
  bool removeInterceptor(Interceptor interceptor) {
    final index = _dio.interceptors.indexOf(interceptor);
    if (index != -1) {
      _dio.interceptors.removeAt(index);
      return true;
    }
    return false;
  }

  /// Remove interceptor by type
  ///
  /// Removes the first interceptor matching the given type.
  /// Returns true if an interceptor was found and removed.
  bool removeInterceptorByType<T extends Interceptor>() {
    final index = _dio.interceptors.indexWhere((i) => i is T);
    if (index != -1) {
      _dio.interceptors.removeAt(index);
      return true;
    }
    return false;
  }

  /// Remove all interceptors of a specific type
  ///
  /// Returns the number of interceptors removed.
  int removeAllInterceptorsByType<T extends Interceptor>() {
    int count = 0;
    _dio.interceptors.removeWhere((i) {
      if (i is T) {
        count++;
        return true;
      }
      return false;
    });
    return count;
  }

  /// Clear all custom interceptors
  ///
  /// This removes all interceptors except the built-in logging and error interceptors.
  void clearCustomInterceptors() {
    _dio.interceptors.clear();
    if (_loggingInterceptor != null) {
      _dio.interceptors.add(_loggingInterceptor!);
    }
    if (_errorInterceptor != null) {
      _dio.interceptors.add(_errorInterceptor!);
    }
  }

  /// Clear ALL interceptors (including logging and error interceptors)
  ///
  /// ⚠️ Use with caution - this removes even the built-in interceptors.
  void clearAllInterceptors() {
    _dio.interceptors.clear();
    _loggingInterceptor = null;
    _errorInterceptor = null;
  }

  /// Get list of all current interceptors
  List<Interceptor> getInterceptors() {
    return List.unmodifiable(_dio.interceptors);
  }

  /// Check if a specific interceptor exists
  bool hasInterceptor(Interceptor interceptor) {
    return _dio.interceptors.contains(interceptor);
  }

  /// Check if an interceptor of a specific type exists
  bool hasInterceptorOfType<T extends Interceptor>() {
    return _dio.interceptors.any((i) => i is T);
  }

  /// Replace an interceptor at the same position.
  /// Returns true if the old interceptor was found and replaced.
  bool replaceInterceptor(
    Interceptor oldInterceptor,
    Interceptor newInterceptor,
  ) {
    final index = _dio.interceptors.indexOf(oldInterceptor);
    if (index != -1) {
      _dio.interceptors[index] = newInterceptor;
      return true;
    }
    return false;
  }

  /// Replace interceptor by type
  ///
  /// Replaces the first interceptor of the specified type with a new one.
  /// Returns true if an interceptor was found and replaced.
  bool replaceInterceptorByType<T extends Interceptor>(
    Interceptor newInterceptor,
  ) {
    final index = _dio.interceptors.indexWhere((i) => i is T);
    if (index != -1) {
      _dio.interceptors[index] = newInterceptor;
      return true;
    }
    return false;
  }

  // ==================== GET Requests ====================

  /// Make a GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(
        data: parser != null ? parser(response.data) : response.data as T,
        statusCode: response.statusCode,
        message: response.statusMessage,
      );
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // ==================== POST Requests ====================

  /// Make a POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(
        data: parser != null ? parser(response.data) : response.data as T,
        statusCode: response.statusCode,
        message: response.statusMessage,
      );
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // ==================== PUT Requests ====================

  /// Make a PUT request (full update)
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(
        data: parser != null ? parser(response.data) : response.data as T,
        statusCode: response.statusCode,
        message: response.statusMessage,
      );
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // ==================== PATCH Requests ====================

  /// Make a PATCH request (partial update)
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(
        data: parser != null ? parser(response.data) : response.data as T,
        statusCode: response.statusCode,
        message: response.statusMessage,
      );
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // ==================== DELETE Requests ====================

  /// Make a DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(
        data: parser != null ? parser(response.data) : response.data as T,
        statusCode: response.statusCode,
        message: response.statusMessage,
      );
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // ==================== File Upload ====================

  /// Upload a single file using multipart/form-data.
  ///
  /// WHY NO Content-Type HEADER HERE:
  /// Dio sets Content-Type automatically to:
  ///   multipart/form-data; boundary=----dartBoundaryXXXX
  /// when the request body is [FormData]. The `boundary` value is
  /// generated per-request and is required by the server to split
  /// form fields. Setting the header manually (even to the right MIME
  /// type) strips the boundary, producing a malformed body that the
  /// server rejects with a connection-level error (null status code).
  ///
  /// Rule: never set Content-Type for multipart requests. Pass FormData
  /// and let Dio handle it.
  ///
  /// Example:
  /// ```dart
  /// final file = File('/path/to/image.jpg');
  /// final response = await client.uploadFile<UploadResponse>(
  ///   '/upload',
  ///   file,
  ///   fileKey: 'file',
  ///   onSendProgress: (sent, total) {
  ///     print('Progress: ${(sent / total * 100).toStringAsFixed(0)}%');
  ///   },
  ///   parser: (data) => UploadResponse.fromJson(data),
  /// );
  /// ```
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    File file, {
    String fileKey = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(file.path, filename: fileName),
        ...?data,
      });

      // Do NOT pass options with Content-Type — Dio sets it with the
      // correct boundary value automatically when body is FormData.
      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return ApiResponse.success(
        data: parser != null ? parser(response.data) : response.data as T,
        statusCode: response.statusCode,
        message: response.statusMessage,
      );
    } catch (e) {
      return _handleError<T>(e);
    }
    // No finally block needed — there is no Content-Type to restore.
    // The default JSON content type on _dio.options is never touched.
  }

  /// Upload multiple files using multipart/form-data.
  ///
  /// Same Content-Type rule as [uploadFile] — never set it manually.
  Future<ApiResponse<T>> uploadFiles<T>(
    String path,
    List<File> files, {
    String fileKey = 'files',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
    T Function(dynamic)? parser,
  }) async {
    try {
      final multipartFiles = <MultipartFile>[];
      for (final file in files) {
        final fileName = file.path.split('/').last;
        multipartFiles.add(
          await MultipartFile.fromFile(file.path, filename: fileName),
        );
      }

      final formData = FormData.fromMap({fileKey: multipartFiles, ...?data});

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );

      return ApiResponse.success(
        data: parser != null ? parser(response.data) : response.data as T,
        statusCode: response.statusCode,
        message: response.statusMessage,
      );
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // ==================== File Download ====================

  /// Download a file to [savePath].
  ///
  /// Example:
  /// ```dart
  /// final response = await client.downloadFile(
  ///   'https://example.com/file.pdf',
  ///   '/storage/downloads/file.pdf',
  ///   onReceiveProgress: (received, total) {
  ///     print('${(received / total * 100).toStringAsFixed(0)}%');
  ///   },
  /// );
  /// ```
  Future<ApiResponse<String>> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        queryParameters: queryParameters,
        options: options,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );
      return ApiResponse.success(
        data: savePath,
        statusCode: 200,
        message: 'File downloaded successfully',
      );
    } catch (e) {
      return _handleError<String>(e);
    }
  }

  // ==================== Error Handling ====================

  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      return ApiResponse.error(error: _dioErrorToApiError(error));
    }
    return ApiResponse.error(
      error: ApiError(type: ApiErrorType.unknown, message: error.toString()),
    );
  }

  ApiError _dioErrorToApiError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiError(
          type: ApiErrorType.timeout,
          message: 'Request timeout. Please check your connection.',
          statusCode: error.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return ApiError(
          type: ApiErrorType.server,
          message: _extractErrorMessage(error.response),
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
      case DioExceptionType.cancel:
        return ApiError(
          type: ApiErrorType.cancelled,
          message: 'Request cancelled',
        );
      case DioExceptionType.connectionError:
        return ApiError(
          type: ApiErrorType.network,
          message: 'No internet connection. Please check your network.',
        );
      case DioExceptionType.badCertificate:
        return ApiError(
          type: ApiErrorType.ssl,
          message: 'SSL certificate verification failed',
        );
      default:
        return ApiError(
          type: ApiErrorType.unknown,
          message: error.message ?? 'An unknown error occurred',
        );
    }
  }

  /// Extract error message from response.
  ///
  /// Handles both flat and validation-style error shapes:
  ///
  ///   Flat:       { "message": "Email already in use" }
  ///   Validation: { "message": ["phone must be a string", "country is required"] }
  ///   NestJS:     { "error": "Bad Request", "statusCode": 400, "message": [...] }
  ///
  /// For list payloads, messages are joined with " · " so the consuming app
  /// receives a single readable string without needing to handle two shapes.
  String _extractErrorMessage(Response? response) {
    if (response?.data is Map) {
      final data = response!.data as Map<String, dynamic>;
      final raw =
          data['message'] ?? data['error'] ?? data['detail'] ?? data['msg'];
      if (raw is List) {
        final joined = raw
            .map((e) => e.toString())
            .where((s) => s.isNotEmpty)
            .join(' · ');
        return joined.isNotEmpty ? joined : 'Server error occurred';
      }
      if (raw is String && raw.isNotEmpty) return raw;
    }
    return response?.statusMessage ?? 'Server error occurred';
  }

  // ==================== Utility Methods ====================

  /// Update base URL — used by datasources to switch between service hosts.
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Add or update default headers for all requests.
  void updateHeaders(Map<String, String> newHeaders) {
    _dio.options.headers.addAll(newHeaders);
  }

  /// Set Bearer token on all subsequent requests.
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove Bearer token.
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Remove a specific header by key.
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Clear all custom headers and restore the default Content-Type.
  void clearHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  /// Current headers snapshot.
  Map<String, dynamic> get currentHeaders => Map.from(_dio.options.headers);

  /// Current base URL.
  String get currentBaseUrl => _dio.options.baseUrl;
}

// ==================== Interceptors ====================

/// Error Interceptor with Retry Logic
///
/// Automatically retries failed requests with exponential backoff.
/// Retries on: timeout, connection errors, 5xx server errors.
class ErrorInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  ErrorInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 0;
    }
    final retryCount = err.requestOptions.extra['retryCount'] as int;

    if (retryCount < maxRetries && _shouldRetry(err)) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      await Future.delayed(retryDelay * (retryCount + 1));
      try {
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

/// Auth Interceptor
///
/// Handles token injection and automatic token refresh on 401 errors.
///
/// Usage:
/// ```dart
/// AuthInterceptor(
///   getToken: () => StorageService.instance.getString('accessToken') ?? '',
///   refreshToken: () async {
///     final response = await refreshMyToken();
///     await StorageService.instance.setString('accessToken', response.token);
///     return response.token;
///   },
/// )
/// ```
class AuthInterceptor extends Interceptor {
  final String Function() getToken;
  final Future<String> Function()? refreshToken;

  AuthInterceptor({required this.getToken, this.refreshToken});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = getToken();
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && refreshToken != null) {
      try {
        final newToken = await refreshToken!();
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}

// ==================== API Response Models ====================

/// API Response wrapper
class ApiResponse<T> {
  final T? data;
  final ApiError? error;
  final int? statusCode;
  final String? message;
  final bool isSuccess;

  ApiResponse._({
    this.data,
    this.error,
    this.statusCode,
    this.message,
    required this.isSuccess,
  });

  factory ApiResponse.success({
    required T data,
    int? statusCode,
    String? message,
  }) {
    return ApiResponse._(
      data: data,
      statusCode: statusCode,
      message: message,
      isSuccess: true,
    );
  }

  factory ApiResponse.error({required ApiError error}) {
    return ApiResponse._(
      error: error,
      statusCode: error.statusCode,
      isSuccess: false,
    );
  }

  bool get isError => !isSuccess;

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResponse.success(data: $data, statusCode: $statusCode)';
    } else {
      return 'ApiResponse.error(error: ${error?.message}, statusCode: $statusCode)';
    }
  }
}

/// API Error details
class ApiError {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiError({
    required this.type,
    required this.message,
    this.statusCode,
    this.data,
  });

  bool get isNetworkError =>
      type == ApiErrorType.network ||
      type == ApiErrorType.timeout ||
      type == ApiErrorType.connectionError;

  bool get isServerError => type == ApiErrorType.server;

  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  @override
  String toString() =>
      'ApiError(type: $type, message: $message, statusCode: $statusCode)';
}

/// API Error types
enum ApiErrorType {
  network,
  timeout,
  server,
  cancelled,
  ssl,
  connectionError,
  unknown,
}

// ==================== Exceptions ====================

/// Exception thrown when HttpClient is used without initialization
class HttpClientNotInitializedException implements Exception {
  final String message;

  HttpClientNotInitializedException([
    this.message = 'HttpClient not initialized. Call HttpClient.init() first.',
  ]);

  @override
  String toString() => 'HttpClientNotInitializedException: $message';
}