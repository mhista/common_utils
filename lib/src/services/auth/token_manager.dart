import 'dart:convert';

import 'package:common_utils2/common_utils2.dart';

// import 'package:common_utils2/common_utils2.dart';

/// Token Manager Service
/// 
/// Handles token lifecycle, expiry checking, and refresh logic
class TokenManager {
  TokenManager._();

  static TokenManager? _instance;
  static TokenManager get instance => _instance ??= TokenManager._();

  final _storage = StorageService.instance;
  final _logger = LoggerService.instance;

  // Storage keys
  static const String _accessTokenKey = 'accessToken';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _tokenExpiryKey = 'tokenExpiry';
  static const String _tokenIssuedAtKey = 'tokenIssuedAt';

  // ==================== Save Tokens ====================

  /// Save tokens after login/refresh
  /// 
  /// [accessToken] - JWT access token
  /// [refreshToken] - Opaque refresh token
  /// [expiresIn] - Access token TTL in seconds (e.g., 900 = 15 minutes)
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
  }) async {
    final now = DateTime.now();
    final expiry = now.add(Duration(seconds: expiresIn));

    await _storage.setBatch({
      _accessTokenKey: accessToken,
      _refreshTokenKey: refreshToken,
      _tokenExpiryKey: expiry.millisecondsSinceEpoch,
      _tokenIssuedAtKey: now.millisecondsSinceEpoch,
    });

    _logger.info('Tokens saved. Expires at: ${expiry.toLocal()}');
  }

  // ==================== Get Tokens ====================

  /// Get access token
  String? get accessToken => _storage.getString(_accessTokenKey);

  /// Get refresh token
  String? get refreshToken => _storage.getString(_refreshTokenKey);

  /// Get token expiry time
  DateTime? get tokenExpiry {
    final timestamp = _storage.getInt(_tokenExpiryKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Get token issued time
  DateTime? get tokenIssuedAt {
    final timestamp = _storage.getInt(_tokenIssuedAtKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  // ==================== Token Status ====================

  /// Check if user has any tokens (logged in)
  bool get hasTokens {
    return accessToken != null && refreshToken != null;
  }

  /// Check if access token is expired
  bool get isAccessTokenExpired {
    final expiry = tokenExpiry;
    if (expiry == null) return true;
    
    // Add 30 second buffer to refresh before actual expiry
    final expiryWithBuffer = expiry.subtract(Duration(seconds: 30));
    return DateTime.now().isAfter(expiryWithBuffer);
  }

  /// Check if access token is valid (not expired and exists)
  bool get isAccessTokenValid {
    return accessToken != null && !isAccessTokenExpired;
  }

  /// Get time until token expires
  Duration? get timeUntilExpiry {
    final expiry = tokenExpiry;
    if (expiry == null) return null;
    
    final diff = expiry.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  /// Get time since token was issued
  Duration? get tokenAge {
    final issuedAt = tokenIssuedAt;
    if (issuedAt == null) return null;
    return DateTime.now().difference(issuedAt);
  }

  // ==================== Token Refresh ====================

  /// Check if token needs refresh
  /// 
  /// Refresh when:
  /// 1. Access token expired or will expire in < 2 minutes
  /// 2. Refresh token still valid
  bool get needsRefresh {
    if (!hasTokens) return false;
    if (refreshToken == null) return false;

    final expiry = tokenExpiry;
    if (expiry == null) return true;

    // Refresh if expires in less than 2 minutes
    final refreshThreshold = expiry.subtract(Duration(minutes: 2));
    return DateTime.now().isAfter(refreshThreshold);
  }

  /// Attempt to refresh access token
  /// 
  /// Returns:
  /// - true: Refresh successful
  /// - false: Refresh failed, need to re-login
  Future<TokenRefreshResult> attemptRefresh(String endpoint) async {
    final currentRefreshToken = refreshToken;

    if (currentRefreshToken == null) {
      _logger.warning('No refresh token available');
      return TokenRefreshResult.noRefreshToken();
    }

    try {
      _logger.info('Attempting token refresh...');

      final response = await HttpClient.instance.post<Map<String, dynamic>>(
        endpoint,
        data: {'refreshToken': currentRefreshToken},
      );

      if (response.isSuccess) {
        final data = response.data!;
        
        await saveTokens(
          accessToken: data['accessToken'] as String,
          refreshToken: data['refreshToken'] as String,
          expiresIn: data['expiresIn'] as int,
        );

        _logger.info('Token refresh successful');
        return TokenRefreshResult.success();
      } else {
        _logger.error('Token refresh failed: ${response.error!.message}');
        
        // Check if it's a 401/403 (refresh token invalid/expired)
        if (response.error!.statusCode == 401 || 
            response.error!.statusCode == 403) {
          await clearTokens();
          return TokenRefreshResult.refreshTokenExpired();
        }

        return TokenRefreshResult.failed(response.error!.message);
      }
    } catch (e, stackTrace) {
      _logger.error('Token refresh exception', e, stackTrace);
      return TokenRefreshResult.failed(e.toString());
    }
  }

  // ==================== JWT Decoding (Optional) ====================

  /// Decode JWT payload (without verification)
  /// 
  /// Useful for getting expiry from token itself
  Map<String, dynamic>? decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload (middle part)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      _logger.error('Failed to decode JWT', e);
      return null;
    }
  }

  /// Get expiry from JWT token itself
  DateTime? getJwtExpiry(String token) {
    final payload = decodeJwt(token);
    if (payload == null) return null;

    final exp = payload['exp'] as int?;
    if (exp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }

  /// Check if JWT is expired by decoding it
  bool isJwtExpired(String token) {
    final expiry = getJwtExpiry(token);
    if (expiry == null) return true;
    return DateTime.now().isAfter(expiry);
  }

  // ==================== Cleanup ====================

  /// Clear all tokens (logout)
  Future<void> clearTokens() async {
    await _storage.removeBatch([
      _accessTokenKey,
      _refreshTokenKey,
      _tokenExpiryKey,
      _tokenIssuedAtKey,
    ]);

    _logger.info('All tokens cleared');
  }

  // ==================== Monitoring ====================

  /// Get token status for debugging
  Map<String, dynamic> getTokenStatus() {
    return {
      'hasTokens': hasTokens,
      'accessTokenValid': isAccessTokenValid,
      'accessTokenExpired': isAccessTokenExpired,
      'needsRefresh': needsRefresh,
      'timeUntilExpiry': timeUntilExpiry?.inSeconds,
      'tokenAge': tokenAge?.inMinutes,
      'tokenExpiry': tokenExpiry?.toIso8601String(),
      'tokenIssuedAt': tokenIssuedAt?.toIso8601String(),
    };
  }
}

// ==================== Models ====================

/// Token refresh result
class TokenRefreshResult {
  final bool success;
  final TokenRefreshStatus status;
  final String? message;

  TokenRefreshResult._({
    required this.success,
    required this.status,
    this.message,
  });

  factory TokenRefreshResult.success() {
    return TokenRefreshResult._(
      success: true,
      status: TokenRefreshStatus.success,
    );
  }

  factory TokenRefreshResult.failed(String message) {
    return TokenRefreshResult._(
      success: false,
      status: TokenRefreshStatus.failed,
      message: message,
    );
  }

  factory TokenRefreshResult.refreshTokenExpired() {
    return TokenRefreshResult._(
      success: false,
      status: TokenRefreshStatus.refreshTokenExpired,
      message: 'Refresh token expired. Please login again.',
    );
  }

  factory TokenRefreshResult.noRefreshToken() {
    return TokenRefreshResult._(
      success: false,
      status: TokenRefreshStatus.noRefreshToken,
      message: 'No refresh token available',
    );
  }

  /// Should force user to re-login
  bool get shouldReLogin {
    return status == TokenRefreshStatus.refreshTokenExpired ||
           status == TokenRefreshStatus.noRefreshToken;
  }
}

enum TokenRefreshStatus {
  success,
  failed,
  refreshTokenExpired,
  noRefreshToken,
}

// ==================== Usage Examples ====================

// void tokenManagerExamples() async {
//   final tokenManager = TokenManager.instance;

//   // After login - save tokens
//   await tokenManager.saveTokens(
//     accessToken: 'eyJhbGc...',
//     refreshToken: 'opaque-refresh-token',
//     expiresIn: 900, // 15 minutes
//   );

//   // Check token status
//   print('Has tokens: ${tokenManager.hasTokens}');
//   print('Token expired: ${tokenManager.isAccessTokenExpired}');
//   print('Time until expiry: ${tokenManager.timeUntilExpiry}');

//   // Check if refresh needed
//   if (tokenManager.needsRefresh) {
//     final result = await tokenManager.attemptRefresh('/auth/refresh');
    
//     if (result.shouldReLogin) {
//       // Navigate to login screen
//       print('Please login again');
//     }
//   }

//   // Get token status
//   print(tokenManager.getTokenStatus());

//   // Logout - clear tokens
//   await tokenManager.clearTokens();
// }