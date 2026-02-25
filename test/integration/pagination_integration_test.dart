
// import 'package:common_utils2/src/medias/video/video_item.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   group('Pagination Integration', () {
//     test('like during pagination preserves video state', () async {
//       // Simulate: User likes post, pagination happens, controller stays alive

//       final initialItems = List.generate(
//         10,
//         (i) => TestVideoItem(
//           id: 'video_$i',
//           url: 'https://example.com/video$i.mp4',
//           data: 'Liked: false',
//         ),
//       );

//       Future<List<VideoItem<String>>> mockFetch(int page) async {
//         await Future.delayed(const Duration(milliseconds: 50));
//         return List.generate(
//           10,
//           (i) => TestVideoItem(
//             id: 'video_${page}_$i',
//             url: 'https://example.com/video${page}_$i.mp4',
//             data: 'Liked: false',
//           ),
//         ),
//       );

//       final cubit = VideoPaginationCubit<String>(
//         initialItems: initialItems,
//         fetchPage: mockFetch,
//         paginationConfig: PaginationConfig(fetchThreshold: 3),
//       );

//       await cubit.init(0);

//       // User likes video 5
//       cubit.updateItemData('video_5', 'Liked: true');

//       // User scrolls to video 8 (triggers pagination)
//       await cubit.onPageChanged(8);
//       await Future.delayed(const Duration(milliseconds: 100));

//       // Verify: Like state preserved
//       final state = cubit.state as VideoPreloadReady<String>;
//       final likedItem = state.items.firstWhere((i) => i.id == 'video_5');
//       expect(likedItem.data, 'Liked: true');

//       // Verify: New items were added
//       expect(state.items.length, greaterThan(10));

//       await cubit.close();
//     });
//   });
// }