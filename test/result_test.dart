import 'package:common_utils2/common_utils2.dart';
import 'package:flutter_test/flutter_test.dart';

class _TypedFailure implements Exception {
  const _TypedFailure(this.code);
  final String code;
}

void main() {
  group('Result.guard', () {
    test('wraps a successful value', () async {
      final r = await Result.guard(() async => 42);
      expect(r.isSuccess, isTrue);
      expect(r.dataOrNull, 42);
    });

    test('captures an Exception with its stack trace', () async {
      final r = await Result.guard<int>(() => throw const FormatException('bad'));
      expect(r.isFailure, isTrue);
      expect(r.exceptionOrNull, isA<FormatException>());
      expect(r.stackTraceOrNull, isNotNull);
    });

    test('wraps non-Exception errors instead of crashing', () async {
      final r = await Result.guard<int>(() => throw StateError('boom'));
      expect(r.isFailure, isTrue);
      expect(r.errorOrNull, contains('boom'));
      expect(r.exceptionOrNull, isA<Exception>());
    });

    test('mapError can supply a typed exception and message', () async {
      final r = await Result.guard<int>(
        () => throw Exception('raw'),
        mapError: (e, st) =>
            (message: 'Friendly', exception: const _TypedFailure('E1')),
      );
      expect(r.errorOrNull, 'Friendly');
      expect((r.exceptionOrNull! as _TypedFailure).code, 'E1');
    });

    test('strips the "Exception: " prefix from messages', () async {
      final r = await Result.guard<int>(() => throw Exception('network down'));
      expect(r.errorOrNull, 'network down');
    });
  });

  group('Result helpers', () {
    test('fold collapses both branches', () {
      final ok = Result<int>.success(2);
      final ko = Result<int>.failure('nope');
      expect(ok.fold((d) => d * 2, (f) => -1), 4);
      expect(ko.fold((d) => d * 2, (f) => f.message.length), 4);
    });

    test('map keeps failure details including stack trace', () {
      final st = StackTrace.current;
      final ko = Result<int>.failure('x', stackTrace: st);
      final mapped = ko.map((d) => '$d');
      expect(mapped.stackTraceOrNull, same(st));
    });

    test('guardSync works for synchronous code', () {
      expect(Result.guardSync(() => int.parse('7')).dataOrNull, 7);
      expect(Result.guardSync(() => int.parse('x')).isFailure, isTrue);
    });
  });
}
