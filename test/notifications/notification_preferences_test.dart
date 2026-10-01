import 'package:common_utils2/common_utils2.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('NotificationPreferences', () {
    test('mute / unmute persists across instances', () async {
      final a = NotificationPreferences();
      await a.load();
      await a.setMuted('promotions', true);
      expect(a.isMuted('promotions'), isTrue);

      final b = NotificationPreferences();
      await b.load();
      expect(b.isMuted('promotions'), isTrue);

      await b.setMuted('promotions', false);
      expect(b.isMuted('promotions'), isFalse);
    });

    test('scopes are isolated (per account)', () async {
      final prefs = NotificationPreferences(scope: 'acc_personal');
      await prefs.load();
      await prefs.setMuted('orders', true);

      await prefs.switchScope('acc_business');
      expect(prefs.isMuted('orders'), isFalse);

      await prefs.switchScope('acc_personal');
      expect(prefs.isMuted('orders'), isTrue);
    });

    test('changes stream emits the muted set', () async {
      final prefs = NotificationPreferences();
      await prefs.load();
      final emitted = expectLater(
        prefs.changes,
        emits(equals({'calls'})),
      );
      await prefs.setMuted('calls', true);
      await emitted;
    });
  });

  group('NotificationCubit scopes', () {
    test('entries are stored per scope and derived counts work', () async {
      final cubit = NotificationCubit(scope: 'acc_1');
      await cubit.initialize();
      await cubit.addFromPayload(
        NotificationPayload.local(title: 'A', body: 'a', channelId: 'orders'),
      );
      await cubit.addFromPayload(
        NotificationPayload.local(title: 'B', body: 'b', channelId: 'messages'),
      );
      expect(cubit.state.unreadCount, 2);
      expect(cubit.state.unreadCountFor('orders'), 1);
      expect(cubit.state.unreadByChannel, {'orders': 1, 'messages': 1});

      await cubit.markChannelRead('orders');
      expect(cubit.state.unreadCountFor('orders'), 0);

      await cubit.switchScope('acc_2');
      expect(cubit.state.entries, isEmpty);

      await cubit.switchScope('acc_1');
      expect(cubit.state.entries.length, 2);
      await cubit.close();
    });
  });
}
