import 'package:flutter_test/flutter_test.dart';

/// EternalAscension Metrics - Counter range: 0-217
class EternalAscension {
  final int counter;

  EternalAscension({required this.counter});

  bool isValid() => counter >= 0 && counter <= 217;

  double calculateAccuracy() => ((217 - counter) / 217) * 100;

  String report() =>
      'EternalAscension { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// InfiniteAscension Metrics - Counter range: 0-218
class InfiniteAscension {
  final int counter;

  InfiniteAscension({required this.counter});

  bool isValid() => counter >= 0 && counter <= 218;

  double calculateAccuracy() => ((218 - counter) / 218) * 100;

  String report() =>
      'InfiniteAscension { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// AbsoluteAscension Metrics - Counter range: 0-219
class AbsoluteAscension {
  final int counter;

  AbsoluteAscension({required this.counter});

  bool isValid() => counter >= 0 && counter <= 219;

  double calculateAccuracy() => ((219 - counter) / 219) * 100;

  String report() =>
      'AbsoluteAscension { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('EternalAscension', () {
    test('validates counter at minimum (0)', () {
      final metrics = EternalAscension(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (217)', () {
      final metrics = EternalAscension(counter: 217);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = EternalAscension(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = EternalAscension(counter: 218);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = EternalAscension(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = EternalAscension(counter: 217);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = EternalAscension(counter: 108);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = EternalAscension(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = EternalAscension(counter: 50);
      final report = metrics.report();
      expect(report, contains('EternalAscension'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = EternalAscension(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(77.0, 0.5));
    });
  });

  group('InfiniteAscension', () {
    test('validates counter at minimum (0)', () {
      final metrics = InfiniteAscension(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (218)', () {
      final metrics = InfiniteAscension(counter: 218);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = InfiniteAscension(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = InfiniteAscension(counter: 219);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = InfiniteAscension(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = InfiniteAscension(counter: 218);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = InfiniteAscension(counter: 109);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = InfiniteAscension(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = InfiniteAscension(counter: 50);
      final report = metrics.report();
      expect(report, contains('InfiniteAscension'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = InfiniteAscension(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(77.1, 0.5));
    });
  });

  group('AbsoluteAscension', () {
    test('validates counter at minimum (0)', () {
      final metrics = AbsoluteAscension(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (219)', () {
      final metrics = AbsoluteAscension(counter: 219);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = AbsoluteAscension(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = AbsoluteAscension(counter: 220);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = AbsoluteAscension(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = AbsoluteAscension(counter: 219);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = AbsoluteAscension(counter: 109);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = AbsoluteAscension(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = AbsoluteAscension(counter: 50);
      final report = metrics.report();
      expect(report, contains('AbsoluteAscension'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = AbsoluteAscension(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(77.2, 0.5));
    });
  });
}
