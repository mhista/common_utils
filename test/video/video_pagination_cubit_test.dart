
// import 'package:flutter_test/flutter_test.dart';
// import 'package:bloc_test/bloc_test.dart';
// import 'package:common_utils2/video.dart';

// void main() {
//   group('VideoPaginationCubit', () {
//     late List<VideoItem<String>> initialItems;

//     setUp(() {
//       initialItems = List.generate(
//         10,
//         (i) => TestVideoItem(
//           id: 'video_$i',
//           url: 'https://example.com/video$i.mp4',
//           data: 'Data $i',
//         ),
//       );
//     });

//     Future<List<VideoItem<String>>> mockFetchPage(int page) async {
//       await Future.delayed(const Duration(milliseconds: 100));
//       if (page >= 3) return []; // Simulate end of content

//       return List.generate(
//         10,
//         (i) => TestVideoItem(
//           id: 'video_${page}_$i',
//           url: 'https://example.com/video${page}_$i.mp4',
//           data: 'Data ${page}_$i',
//         ),
//       );
//     }

//     blocTest<VideoPaginationCubit<String>, VideoPreloadState<String>>(
//       'fetches next page when threshold is reached',
//       build: () => VideoPaginationCubit<String>(
//         initialItems: initialItems,
//         fetchPage: mockFetchPage,
//         paginationConfig: PaginationConfig(
//           fetchThreshold: 3,
//           pageSize: 10,
//         ),
//       ),
//       act: (cubit) async {
//         await cubit.init(0);
//         await cubit.onPageChanged(8); // Within threshold
//       },
//       wait: const Duration(milliseconds: 200),
//       verify: (cubit) {
//         expect(cubit.state.items.length, greaterThan(10));
//       },
//     );

//     test('prevents duplicate fetch requests', () async {
//       int fetchCount = 0;

//       Future<List<VideoItem<String>>> countingFetch(int page) async {
//         fetchCount++;
//         return mockFetchPage(page);
//       }

//       final cubit = VideoPaginationCubit<String>(
//         initialItems: initialItems,
//         fetchPage: countingFetch,
//         paginationConfig: PaginationConfig(
//           fetchThreshold: 3,
//           pageSize: 10,
//         ),
//       );

//       await cubit.init(0);
      
//       // Trigger multiple times rapidly
//       cubit.onPageChanged(8);
//       cubit.onPageChanged(8);
//       cubit.onPageChanged(8);

//       await Future.delayed(const Duration(milliseconds: 300));

//       expect(fetchCount, 1); // Should only fetch once

//       await cubit.close();
//     });

//     test('refresh resets to first page', () async {
//       final cubit = VideoPaginationCubit<String>(
//         initialItems: initialItems,
//         fetchPage: mockFetchPage,
//       );

//       await cubit.init(0);
//       await cubit.onPageChanged(8);
//       await Future.delayed(const Duration(milliseconds: 200));

//       // Now refresh
//       await cubit.refresh();

//       final state = cubit.state as VideoPreloadReady<String>;
//       expect(state.currentIndex, 0);

//       await cubit.close();
//     });

//     test('hasMore is false when empty page returned', () async {
//       final cubit = VideoPaginationCubit<String>(
//         initialItems: initialItems,
//         fetchPage: (page) async => [], // Always return empty
//       );

//       await cubit.init(0);
//       await cubit.onPageChanged(8);
//       await Future.delayed(const Duration(milliseconds: 200));

//       expect(cubit.hasMore, false);

//       await cubit.close();
//     });
//   });
// }

