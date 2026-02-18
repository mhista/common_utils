
import 'package:firebase_messaging/firebase_messaging.dart' as fm;
import 'package:flutter/foundation.dart';

class TopicManager {
  final fm.FirebaseMessaging _fcm;
  final _active = <String>{};

  TopicManager(this._fcm);

  Set<String> get active => Set.unmodifiable(_active);

  Future<void> subscribe(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      _active.add(topic);
      debugPrint('📌 Subscribed: $topic');
    } catch (e) {
      debugPrint('❌ Subscribe error ($topic): $e');
    }
  }

  Future<void> unsubscribe(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      _active.remove(topic);
      debugPrint('📌 Unsubscribed: $topic');
    } catch (e) {
      debugPrint('❌ Unsubscribe error ($topic): $e');
    }
  }

  Future<void> subscribeMany(List<String> topics) =>
      Future.wait(topics.map(subscribe));

  Future<void> unsubscribeAll() =>
      Future.wait(_active.toList().map(unsubscribe));
}