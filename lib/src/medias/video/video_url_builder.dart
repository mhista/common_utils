// ═════════════════════════════════════════════════════════════════════
// FILE: core/services/media/video_url_builder.dart
//
// Adds an auth token to a video URL as a query parameter.
// This is needed because some CDN/streaming servers cannot read the
// Authorization header from video player requests (the player sends
// a range request directly to the CDN, bypassing any custom headers).
//
// USAGE — in your video cubit:
//
//   // Opt-in (token appended):
//   final url = VideoUrlBuilder.build(
//     rawUrl: media.url,
//     token: await AuthSecureStorageService.instance.getAccessToken(),
//     appendTokenAsParam: true,       // opt-in flag
//   );
//
//   // Opt-out (url unchanged):
//   final url = VideoUrlBuilder.build(
//     rawUrl: media.url,
//     token: null,                    // or appendTokenAsParam: false
//   );
//
// PARAM NAME:
//   Defaults to 'token'. Your backend dev can tell you which name they
//   accept — common options: 'token', 'access_token', 'auth_token', 't'.
//   Pass tokenParamName to override.
//
// BOTH HEADER AND PARAM:
//   Still pass the Authorization header as well — some requests (e.g.
//   the initial HLS manifest fetch) DO honour headers. The query param
//   is the fallback for segment / range requests that don't.
// ═════════════════════════════════════════════════════════════════════

class VideoUrlBuilder {
  const VideoUrlBuilder._();

  /// Builds the final video URL, optionally appending the token as a
  /// query parameter.
  ///
  /// [rawUrl]              — the original CDN URL
  /// [token]               — the bearer token (null-safe: if null, url unchanged)
  /// [appendTokenAsParam]  — opt-in flag; default false (opt-out)
  /// [tokenParamName]      — query param key; default 'token'
  static String build({
    required String rawUrl,
    String? token,
    bool appendTokenAsParam = false,
    String tokenParamName = 'token',
  }) {
    if (!appendTokenAsParam || token == null || token.isEmpty) {
      return rawUrl;
    }

    try {
      final uri = Uri.parse(rawUrl);
      // Merge with existing query params — don't clobber them
      final params = Map<String, String>.from(uri.queryParameters);
      params[tokenParamName] = token;
      return uri.replace(queryParameters: params).toString();
    } catch (_) {
      // Malformed URL — return as-is rather than crash
      return rawUrl;
    }
  }

  /// Convenience: strips the token param from a URL (e.g. for logging).
  static String redact(String url, {String tokenParamName = 'token'}) {
    try {
      final uri = Uri.parse(url);
      if (!uri.queryParameters.containsKey(tokenParamName)) return url;
      final params = Map<String, String>.from(uri.queryParameters)
        ..remove(tokenParamName);
      return uri.replace(queryParameters: params).toString();
    } catch (_) {
      return url;
    }
  }
}