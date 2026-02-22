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
  /// 
  /// Example:
  /// ```dart
  /// HttpClient.instance.addInterceptors([
  ///   AuthInterceptor(...),
  ///   CacheInterceptor(),
  ///   CustomHeaderInterceptor(),
  /// ]);
  /// ```
  void addInterceptors(List<Interceptor> interceptors) {
    _dio.interceptors.addAll(interceptors);
  }

  /// Remove a specific interceptor
  /// 
  /// Returns true if the interceptor was found and removed.
  /// 
  /// Example:
  /// ```dart
  /// final authInterceptor = AuthInterceptor(...);
  /// HttpClient.instance.addInterceptor(authInterceptor);
  /// 
  /// // Later, remove it
  /// HttpClient.instance.removeInterceptor(authInterceptor);
  /// ```
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
  /// 
  /// Example:
  /// ```dart
  /// // Remove any AuthInterceptor
  /// HttpClient.instance.removeInterceptorByType<AuthInterceptor>();
  /// ```
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
  /// 
  /// Example:
  /// ```dart
  /// final count = HttpClient.instance.removeAllInterceptorsByType<AuthInterceptor>();
  /// print('Removed $count auth interceptors');
  /// ```
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
  /// 
  /// Example:
  /// ```dart
  /// // Clear all custom interceptors
  /// HttpClient.instance.clearCustomInterceptors();
  /// ```
  void clearCustomInterceptors() {
    // Keep only logging and error interceptors
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
  /// 
  /// Example:
  /// ```dart
  /// HttpClient.instance.clearAllInterceptors();
  /// ```
  void clearAllInterceptors() {
    _dio.interceptors.clear();
    _loggingInterceptor = null;
    _errorInterceptor = null;
  }

  /// Get list of all current interceptors
  /// 
  /// Returns an unmodifiable list of interceptors.
  /// 
  /// Example:
  /// ```dart
  /// final interceptors = HttpClient.instance.getInterceptors();
  /// print('Active interceptors: ${interceptors.length}');
  /// 
  /// for (var interceptor in interceptors) {
  ///   print(interceptor.runtimeType);
  /// }
  /// ```
  List<Interceptor> getInterceptors() {
    return List.unmodifiable(_dio.interceptors);
  }

  /// Check if a specific interceptor exists
  /// 
  /// Example:
  /// ```dart
  /// final authInterceptor = AuthInterceptor(...);
  /// if (HttpClient.instance.hasInterceptor(authInterceptor)) {
  ///   print('Auth interceptor is active');
  /// }
  /// ```
  bool hasInterceptor(Interceptor interceptor) {
    return _dio.interceptors.contains(interceptor);
  }

  /// Check if an interceptor of a specific type exists
  /// 
  /// Example:
  /// ```dart
  /// if (HttpClient.instance.hasInterceptorOfType<AuthInterceptor>()) {
  ///   print('Auth interceptor is active');
  /// }
  /// ```
  bool hasInterceptorOfType<T extends Interceptor>() {
    return _dio.interceptors.any((i) => i is T);
  }

  /// Replace an interceptor
  /// 
  /// Replaces the old interceptor with a new one at the same position.
  /// Returns true if the old interceptor was found and replaced.
  /// 
  /// Example:
  /// ```dart
  /// final oldAuth = AuthInterceptor(...);
  /// final newAuth = AuthInterceptor(...);
  /// 
  /// HttpClient.instance.replaceInterceptor(oldAuth, newAuth);
  /// ```
  bool replaceInterceptor(Interceptor oldInterceptor, Interceptor newInterceptor) {
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
  /// 
  /// Example:
  /// ```dart
  /// final newAuth = AuthInterceptor(...);
  /// HttpClient.instance.replaceInterceptorByType<AuthInterceptor>(newAuth);
  /// ```
  bool replaceInterceptorByType<T extends Interceptor>(Interceptor newInterceptor) {
    final index = _dio.interceptors.indexWhere((i) => i is T);
    if (index != -1) {
      _dio.interceptors[index] = newInterceptor;
      return true;
    }
    return false;
  }

  // ==================== GET Requests ====================

  /// Make a GET request
  /// 
  /// [path] - API endpoint path (e.g., '/users/1')
  /// [queryParameters] - URL query parameters
  /// [options] - Additional Dio options
  /// [cancelToken] - Token to cancel the request
  /// [parser] - Function to parse response data to type T
  /// 
  /// Example:
  /// ```dart
  /// final response = await client.get<User>(
  ///   '/users/1',
  ///   parser: (data) => User.fromJson(data),
  /// );
  /// 
  /// if (response.isSuccess) {
  ///   final user = response.data;
  ///   print(user.name);
  /// } else {
  ///   print(response.error!.message);
  /// }
  /// ```
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
  /// 
  /// [path] - API endpoint path (e.g., '/auth/login')
  /// [data] - Request body (will be JSON encoded)
  /// [queryParameters] - URL query parameters
  /// [options] - Additional Dio options
  /// [cancelToken] - Token to cancel the request
  /// [parser] - Function to parse response data to type T
  /// 
  /// Example:
  /// ```dart
  /// final response = await client.post<LoginResponse>(
  ///   '/auth/login',
  ///   data: {
  ///     'email': 'user@example.com',
  ///     'password': 'password123',
  ///   },
  ///   parser: (data) => LoginResponse.fromJson(data),
  /// );
  /// ```
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
  /// 
  /// Example:
  /// ```dart
  /// final response = await client.put<User>(
  ///   '/users/1',
  ///   data: {
  ///     'name': 'John Doe',
  ///     'email': 'john@example.com',
  ///   },
  ///   parser: (data) => User.fromJson(data),
  /// );
  /// ```
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
  /// 
  /// Example:
  /// ```dart
  /// final response = await client.patch<User>(
  ///   '/users/1',
  ///   data: {'name': 'Jane Doe'}, // Only update name
  ///   parser: (data) => User.fromJson(data),
  /// );
  /// ```
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
  /// 
  /// Example:
  /// ```dart
  /// final response = await client.delete<void>('/users/1');
  /// 
  /// if (response.isSuccess) {
  ///   print('User deleted');
  /// }
  /// ```
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

  /// Upload a single file
  /// 
  /// [path] - API endpoint path
  /// [file] - File to upload
  /// [fileKey] - Form field name for the file (default: 'file')
  /// [data] - Additional form data
  /// [onSendProgress] - Callback for upload progress
  /// 
  /// Example:
  /// ```dart
  /// final file = File('/path/to/image.jpg');
  /// final response = await client.uploadFile<UploadResponse>(
  ///   '/upload',
  ///   file,
  ///   fileKey: 'image',
  ///   data: {'title': 'My Image'},
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
        fileKey: await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        ...?data,
      });

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

  /// Upload multiple files
  /// 
  /// Example:
  /// ```dart
  /// final files = [
  ///   File('/path/to/image1.jpg'),
  ///   File('/path/to/image2.jpg'),
  /// ];
  /// 
  /// final response = await client.uploadFiles<UploadResponse>(
  ///   '/upload/batch',
  ///   files,
  ///   fileKey: 'images',
  ///   parser: (data) => UploadResponse.fromJson(data),
  /// );
  /// ```
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

      final formData = FormData.fromMap({
        fileKey: multipartFiles,
        ...?data,
      });

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

  /// Download a file
  /// 
  /// [url] - File URL to download
  /// [savePath] - Local path where file will be saved
  /// [onReceiveProgress] - Callback for download progress
  /// 
  /// Example:
  /// ```dart
  /// final response = await client.downloadFile(
  ///   'https://example.com/file.pdf',
  ///   '/storage/downloads/file.pdf',
  ///   onReceiveProgress: (received, total) {
  ///     print('Progress: ${(received / total * 100).toStringAsFixed(0)}%');
  ///   },
  /// );
  /// 
  /// if (response.isSuccess) {
  ///   print('File saved to: ${response.data}');
  /// }
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

  /// Handle errors and convert to ApiResponse
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      return ApiResponse.error(
        error: _dioErrorToApiError(error),
      );
    }
    return ApiResponse.error(
      error: ApiError(
        type: ApiErrorType.unknown,
        message: error.toString(),
      ),
    );
  }

  /// Convert DioException to ApiError
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

  /// Extract error message from response
  String _extractErrorMessage(Response? response) {
    if (response?.data is Map) {
      final data = response!.data as Map<String, dynamic>;
      // Try common error message fields
      return data['message'] as String? ??
          data['error'] as String? ??
          data['detail'] as String? ??
          data['msg'] as String? ??
          'Server error occurred';
    }
    return response?.statusMessage ?? 'Server error occurred';
  }

  // ==================== Utility Methods ====================

  /// Update base URL
  /// 
  /// Useful for switching between environments.
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Update headers
  /// 
  /// Add or update default headers for all requests.
  void updateHeaders(Map<String, String> newHeaders) {
    _dio.options.headers.addAll(newHeaders);
  }

  /// Set authentication token
  /// 
  /// Adds Bearer token to all requests.
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  /// Remove authentication token
  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  /// Remove a specific header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  /// Clear all custom headers
  void clearHeaders() {
    _dio.options.headers.clear();
    // Re-add content type
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  /// Get current headers
  Map<String, dynamic> get currentHeaders => Map.from(_dio.options.headers);

  /// Get current base URL
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
    // Initialize retry count
    if (err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 0;
    }

    final retryCount = err.requestOptions.extra['retryCount'] as int;

    // Check if should retry
    if (retryCount < maxRetries && _shouldRetry(err)) {
      // Increment retry count
      err.requestOptions.extra['retryCount'] = retryCount + 1;

      // Wait before retry (exponential backoff)
      await Future.delayed(retryDelay * (retryCount + 1));

      try {
        // Retry the request
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // If retry fails, continue with error
        return handler.next(err);
      }
    }

    // No more retries, pass error
    handler.next(err);
  }

  /// Determine if request should be retried
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

  AuthInterceptor({
    required this.getToken,
    this.refreshToken,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add token to request headers
    final token = getToken();
    if (token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized
    if (err.response?.statusCode == 401 && refreshToken != null) {
      try {
        // Refresh token
        final newToken = await refreshToken!();

        // Update request with new token
        err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

        // Retry original request
        final response = await Dio().fetch(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        // Token refresh failed, pass error
        return handler.next(err);
      }
    }

    // Not a 401 or no refresh function, pass error
    handler.next(err);
  }
}

// ==================== API Response Models ====================

/// API Response wrapper
/// 
/// Wraps all API responses for type-safe handling.
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

  /// Create success response
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

  /// Create error response
  factory ApiResponse.error({
    required ApiError error,
  }) {
    return ApiResponse._(
      error: error,
      statusCode: error.statusCode,
      isSuccess: false,
    );
  }

  /// Check if response is error
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

  /// Check if error is network-related
  bool get isNetworkError =>
      type == ApiErrorType.network ||
      type == ApiErrorType.timeout ||
      type == ApiErrorType.connectionError;

  /// Check if error is server-related
  bool get isServerError => type == ApiErrorType.server;

  /// Check if error is client-related (4xx)
  bool get isClientError =>
      statusCode != null && statusCode! >= 400 && statusCode! < 500;

  @override
  String toString() {
    return 'ApiError(type: $type, message: $message, statusCode: $statusCode)';
  }
}

/// API Error types
enum ApiErrorType {
  /// Network connection error
  network,

  /// Request timeout
  timeout,

  /// Server error (5xx)
  server,

  /// Request cancelled
  cancelled,

  /// SSL certificate error
  ssl,

  /// Connection error
  connectionError,

  /// Unknown error
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