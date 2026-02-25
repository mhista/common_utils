
// import 'package:flutter_test/flutter_test.dart';
// import 'package:bloc_test/bloc_test.dart';
// import 'package:common_utils2/media.dart';

// class TestMediaItem extends MediaItem<String> {
//   TestMediaItem({required String id, required List<MediaContent> content})
//       : super(id: id, content: content, data: 'Test data');

//   @override
//   TestMediaItem copyWithData(String newData) => TestMediaItem(
//         id: id,
//         content: content,
//       );
// }

// void main() {
//   group('MixedMediaCubit', () {
//     late List<MediaItem<String>> testItems;

//     setUp(() {
//       testItems = [
//         TestMediaItem(
//           id: '1',
//           content: [
//             MediaContent(
//               id: 'c1',
//               type: MediaType.image,
//               url: 'https://example.com/image.jpg',
//             ),
//           ],
//         ),
//         TestMediaItem(
//           id: '2',
//           content: [
//             MediaContent(
//               id: 'c2',
//               type: MediaType.video,
//               url: 'https://example.com/video.mp4',
//               thumbnailUrl: 'https://example.com/thumb.jpg',
//             ),
//           ],
//         ),
//       ];
//     });

//     blocTest<MixedMediaCubit<String>, MixedMediaState<String>>(
//       'updateItems updates state',
//       build: () => MixedMediaCubit<String>(items: testItems),
//       act: (cubit) => cubit.updateItems(testItems.sublist(0, 1)),
//       verify: (cubit) {
//         expect(cubit.state.items.length, 1);
//       },
//     );

//     blocTest<MixedMediaCubit<String>, MixedMediaState<String>>(
//       'updateItemData updates specific item',
//       build: () => MixedMediaCubit<String>(items: testItems),
//       act: (cubit) => cubit.updateItemData('1', 'Updated data'),
//       verify: (cubit) {
//         final item = cubit.state.items.firstWhere((i) => i.id == '1');
//         expect(item.data, 'Updated data');
//       },
//     );

//     test('hasVideo detects video content', () {
//       final item = testItems[1];
//       expect(item.hasVideo, true);
//     });

//     test('hasImage detects image content', () {
//       final item = testItems[0];
//       expect(item.hasImage, true);
//     });

//     test('primaryType returns first content type', () {
//       expect(testItems[0].primaryType, MediaType.image);
//       expect(testItems[1].primaryType, MediaType.video);
//     });
//   });
// }
