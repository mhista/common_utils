
// import 'package:flutter_test/flutter_test.dart';
// import 'package:bloc_test/bloc_test.dart';
// import 'package:common_utils2/notifications.dart';

// void main() {
//   group('NotificationCubit', () {
//     late NotificationCubit cubit;

//     setUp(() {
//       cubit = NotificationCubit();
//     });

//     tearDown(() {
//       cubit.close();
//     });

//     blocTest<NotificationCubit, NotificationState>(
//       'addFromPayload adds entry to store',
//       build: () => NotificationCubit(),
//       act: (cubit) async {
//         final payload = NotificationPayload.local(
//           title: 'Test',
//           body: 'Test body',
//           type: 'test',
//         );
//         await cubit.addFromPayload(payload);
//       },
//       verify: (cubit) {
//         expect(cubit.state.entries.length, 1);
//         expect(cubit.state.entries.first.title, 'Test');
//       },
//     );

//     blocTest<NotificationCubit, NotificationState>(
//       'markRead updates read status',
//       build: () => NotificationCubit(),
//       seed: () => NotificationState(
//         entries: [
//           NotificationEntry(
//             id: '1',
//             title: 'Test',
//             type: 'test',
//             channelId: 'general',
//             data: {},
//             receivedAt: DateTime.now(),
//             isRead: false,
//           ),
//         ],
//       ),
//       act: (cubit) async {
//         await cubit.markRead('1');
//       },
//       verify: (cubit) {
//         expect(cubit.state.entries.first.isRead, true);
//       },
//     );

//     blocTest<NotificationCubit, NotificationState>(
//       'markAllRead marks all entries as read',
//       build: () => NotificationCubit(),
//       seed: () => NotificationState(
//         entries: List.generate(
//           5,
//           (i) => NotificationEntry(
//             id: '$i',
//             title: 'Test $i',
//             type: 'test',
//             channelId: 'general',
//             data: {},
//             receivedAt: DateTime.now(),
//             isRead: false,
//           ),
//         ),
//       ),
//       act: (cubit) async {
//         await cubit.markAllRead();
//       },
//       verify: (cubit) {
//         expect(
//           cubit.state.entries.every((e) => e.isRead),
//           true,
//         );
//       },
//     );

//     test('unreadCount calculates correctly', () {
//       final state = NotificationState(
//         entries: [
//           NotificationEntry(
//             id: '1',
//             title: 'Test',
//             type: 'test',
//             channelId: 'general',
//             data: {},
//             receivedAt: DateTime.now(),
//             isRead: false,
//           ),
//           NotificationEntry(
//             id: '2',
//             title: 'Test 2',
//             type: 'test',
//             channelId: 'general',
//             data: {},
//             receivedAt: DateTime.now(),
//             isRead: true,
//           ),
//           NotificationEntry(
//             id: '3',
//             title: 'Test 3',
//             type: 'test',
//             channelId: 'general',
//             data: {},
//             receivedAt: DateTime.now(),
//             isRead: false,
//           ),
//         ],
//       );

//       expect(state.unreadCount, 2);
//     });

//     test('mergeFromServer preserves local read state', () async {
//       final cubit = NotificationCubit();
      
//       // Add local entry and mark as read
//       await cubit.addEntry(
//         NotificationEntry(
//           id: '1',
//           title: 'Local',
//           type: 'test',
//           channelId: 'general',
//           data: {},
//           receivedAt: DateTime.now(),
//           isRead: true,
//         ),
//       );

//       // Merge from server (same ID, different data, unread)
//       await cubit.mergeFromServer([
//         NotificationEntry(
//           id: '1',
//           title: 'Server Version',
//           type: 'test',
//           channelId: 'general',
//           data: {'updated': true},
//           receivedAt: DateTime.now(),
//           isRead: false, // Server says unread
//         ),
//       ]);

//       final entry = cubit.state.entries.first;
//       expect(entry.title, 'Server Version'); // Title updated
//       expect(entry.isRead, true); // Read state preserved

//       await cubit.close();
//     });
//   });
// }
