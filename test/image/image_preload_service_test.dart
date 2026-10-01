import 'dart:io';

import 'package:common_utils2/src/medias/image/image_preload_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Unit tests have no platform plugins: give flutter_cache_manager a
  // temp directory via a mocked path_provider channel.
  setUpAll(() {
    final tmp = Directory.systemTemp.createTempSync('common_utils_test').path;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => tmp,
    );
  });

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

    testWidgets(
      'preloadSingle adds to cache',
      (tester) async {
        final service = ImagePreloadService();
        const url = 'https://via.placeholder.com/150';

        await tester.pumpWidget(MaterialApp(home: Container()));

        await service.preloadSingle(url, tester.element(find.byType(Container)));

        expect(service.isCached(url), true);
      },
      // flutter test returns HTTP 400 for every real request.
      skip: true,
    );
  });
}
