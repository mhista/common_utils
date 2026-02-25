
// import 'package:common_utils2/src/medias/video/video_item.dart';
// import 'package:flutter_test/flutter_test.dart';


// class TestVideoItem extends VideoItem<String> {
//   TestVideoItem({required String id, required String url, required String data})
//       : super(id: id, videoUrl: url, data: data);

//   @override
//   TestVideoItem copyWithData(String newData) => TestVideoItem(
//         id: id,
//         url: videoUrl,
//         data: newData,
//       );
// }

// void main() {
//   group('VideoPreloadCubit', () {
//     late List<VideoItem<String>> testItems;

//     setUp(() {
//       testItems = List.generate(
//         10,
//         (i) => TestVideoItem(
//           id: 'video_$i',
//           url: 'https://example.com/video$i.mp4',
//           data: 'Data $i',
//         ),
//       );
//     });

//     blocTest<VideoPreloadCubit<String>, VideoPreloadState<String>>(
//       'emits [loading, ready] when init is called',
//       build: () => VideoPreloadCubit<String>(items: testItems),
//       act: (cubit) => cubit.init(0),
//       expect: () => [
//         isA<VideoPreloadState<String>>(),
//         isA<VideoPreloadState<String>>(),
//       ],
//     );

//     blocTest<VideoPreloadCubit<String>, VideoPreloadState<String>>(
//       'updates item data without reinitializing controller',
//       build: () => VideoPreloadCubit<String>(items: testItems),
//       seed: () => VideoPreloadState.ready(
//         currentIndex: 0,
//         currentItemId: 'video_0',
//         controllers: {},
//         items: testItems,
//       ),
//       act: (cubit) {
//         cubit.updateItemData('video_0', 'Updated Data');
//       },
//       verify: (cubit) {
//         final state = cubit.state as VideoPreloadReady<String>;
//         expect(state.items[0].data, 'Updated Data');
//       },
//     );

//     blocTest<VideoPreloadCubit<String>, VideoPreloadState<String>>(
//       'updates items list and preserves matching controllers',
//       build: () => VideoPreloadCubit<String>(items: testItems),
//       seed: () => VideoPreloadState.ready(
//         currentIndex: 0,
//         currentItemId: 'video_0',
//         controllers: {},
//         items: testItems,
//       ),
//       act: (cubit) async {
//         final newItems = testItems.sublist(0, 5);
//         await cubit.updateItems(newItems);
//       },
//       verify: (cubit) {
//         final state = cubit.state as VideoPreloadReady<String>;
//         expect(state.items.length, 5);
//       },
//     );

//     test('disposeExcept keeps only relevant controllers', () async {
//       final cubit = VideoPreloadCubit<String>(
//         items: testItems,
//         config: VideoPreloadConfig(keepBehind: 1, preloadAhead: 1),
//       );

//       await cubit.init(5);
//       await cubit.disposeExcept(5);

//       // Controllers should exist for indices 4, 5, 6 only
//       final state = cubit.state as VideoPreloadReady<String>;
//       expect(state.controllers.length, lessThanOrEqualTo(3));

//       await cubit.close();
//     });

//     test('config values are respected', () {
//       final config = VideoPreloadConfig(
//         preloadAhead: 3,
//         keepBehind: 2,
//         maxConcurrentInits: 5,
//       );

//       final cubit = VideoPreloadCubit<String>(
//         items: testItems,
//         config: config,
//       );

//       expect(cubit.config.preloadAhead, 3);
//       expect(cubit.config.keepBehind, 2);
//       expect(cubit.config.maxConcurrentInits, 5);

//       cubit.close();
//     });
//   });
// }
