
import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart' as fm;
import 'package:flutter/foundation.dart';

class NotificationTokenManager {
  final fm.FirebaseMessaging _fcm;
  final Future<void> Function(String)? _onRefreshed;
  final _controller = StreamController<String>.broadcast();
  StreamSubscription<String>? _sub;
  String? _current;

  NotificationTokenManager(this._fcm, {Future<void> Function(String)? onRefreshed})
      : _onRefreshed = onRefreshed;

  String? get currentToken => _current;
  Stream<String> get stream => _controller.stream;

  Future<String?> initialize() async {
    try {
      _current = await _fcm.getToken();
      debugPrint('🔑 FCM token obtained');
      if (_current != null) await _onRefreshed?.call(_current!);

      _sub = _fcm.onTokenRefresh.listen((token) async {
        _current = token;
        _controller.add(token);
        debugPrint('🔄 FCM token refreshed');
        await _onRefreshed?.call(token);
      });
      return _current;
    } catch (e) {
      debugPrint('❌ TokenManager error: $e');
      return null;
    }
  }

  Future<void> delete() async {
    await _fcm.deleteToken();
    _current = null;
  }

  void dispose() {
    _sub?.cancel();
    _controller.close();
  }
}