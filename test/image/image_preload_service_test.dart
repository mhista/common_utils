
import 'package:common_utils2/src/medias/image/image_preload_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImagePreloadService', () {
    test('singleton returns same instance', () {
      final instance1 = ImagePreloadService();
      final instance2 = ImagePreloadService();

      expect(instance1, same(instance2));
    });

    test('isCached returns false for non-cached URLs', () {
      final service = ImagePreloadService();
      expect(service.isCached('https://example.com/image.jpg'), false);
    });

    testWidgets('preloadSingle adds to cache', (tester) async {
      final service = ImagePreloadService();
      final url = 'https://via.placeholder.com/150';

      await tester.pumpWidget(MaterialApp(home: Container()));

      await service.preloadSingle(url, tester.element(find.byType(Container)));

      expect(service.isCached(url), true);
    });
  });
}
