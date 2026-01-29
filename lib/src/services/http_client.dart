import 'dart:io';
import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

/// HTTP Client Service with Logger Integration
/// Customizable HTTP client using Dio with interceptors and error handling
class HttpClient {
  late Dio _dio;
  final String baseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;
  final Map<String, String> headers;
  final bool enableLogging;

  HttpClient({
    required this.baseUrl,
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
    this.headers = const {},
    this.enableLogging = true,
    List<Interceptor>? interceptors,
  }) {
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

    // Add logging interceptor if enabled
    if (enableLogging) {
      _dio.interceptors.add(TalkerDioLogger(
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
        ),
    ),);
    }

    // Add error interceptor
    _dio.interceptors.add(ErrorInterceptor());

    // Add custom interceptors if provided
    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }
  }

  /// Get Dio instance for custom configurations
  Dio get dio => _dio;

  // ==================== GET Requests ====================

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

  Future<ApiResponse<String>> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      return ApiResponse.success(
        data: savePath,
        message: 'File downloaded successfully',
      );
    } catch (e) {
      return _handleError<String>(e);
    }
  }

  // ==================== Error Handling ====================

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
          message: 'No internet connection',
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

  String _extractErrorMessage(Response? response) {
    if (response?.data is Map) {
      final data = response!.data as Map<String, dynamic>;
      return data['message'] ?? data['error'] ?? 'Server error occurred';
    }
    return response?.statusMessage ?? 'Server error occurred';
  }

  // ==================== Utility Methods ====================

  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  void updateHeaders(Map<String, String> newHeaders) {
    _dio.options.headers.addAll(newHeaders);
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  void clearHeaders() {
    _dio.options.headers.clear();
  }
}

// ==================== Interceptors ====================



/// Error Interceptor with Retry Logic
class ErrorInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;

  ErrorInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err) && err.requestOptions.extra['retryCount'] == null) {
      err.requestOptions.extra['retryCount'] = 0;
    }

    final retryCount = err.requestOptions.extra['retryCount'] ?? 0;

    if (retryCount < maxRetries && _shouldRetry(err)) {
      err.requestOptions.extra['retryCount'] = retryCount + 1;
      
      await Future.delayed(retryDelay * (retryCount + 1));

      try {
        final response = await Dio().fetch(err.requestOptions);
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        (err.response?.statusCode ?? 0) >= 500;
  }
}

/// Auth Interceptor
class AuthInterceptor extends Interceptor {
  final String Function() getToken;
  final Future<String> Function()? refreshToken;

  AuthInterceptor({
    required this.getToken,
    this.refreshToken,
  });

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
        handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}

// ==================== API Response Models ====================

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

  factory ApiResponse.error({
    required ApiError error,
  }) {
    return ApiResponse._(
      error: error,
      isSuccess: false,
    );
  }
}

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
}

enum ApiErrorType {
  network,
  timeout,
  server,
  cancelled,
  ssl,
  unknown,
}