import 'package:flutter_test/flutter_test.dart';

/// EternalActualization Metrics - Counter range: 0-223
class EternalActualization {
  final int counter;

  EternalActualization({required this.counter});

  bool isValid() => counter >= 0 && counter <= 223;

  double calculateAccuracy() => ((223 - counter) / 223) * 100;

  String report() =>
      'EternalActualization { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// PerfectActualization Metrics - Counter range: 0-224
class PerfectActualization {
  final int counter;

  PerfectActualization({required this.counter});

  bool isValid() => counter >= 0 && counter <= 224;

  double calculateAccuracy() => ((224 - counter) / 224) * 100;

  String report() =>
      'PerfectActualization { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// InfiniteActualization Metrics - Counter range: 0-225
class InfiniteActualization {
  final int counter;

  InfiniteActualization({required this.counter});

  bool isValid() => counter >= 0 && counter <= 225;

  double calculateAccuracy() => ((225 - counter) / 225) * 100;

  String report() =>
      'InfiniteActualization { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('EternalActualization', () {
    test('validates counter at minimum (0)', () {
      final metrics = EternalActualization(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (223)', () {
      final metrics = EternalActualization(counter: 223);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = EternalActualization(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = EternalActualization(counter: 224);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = EternalActualization(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = EternalActualization(counter: 223);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = EternalActualization(counter: 111);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = EternalActualization(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = EternalActualization(counter: 50);
      final report = metrics.report();
      expect(report, contains('EternalActualization'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = EternalActualization(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(77.5, 0.5));
    });
  });

  group('PerfectActualization', () {
    test('validates counter at minimum (0)', () {
      final metrics = PerfectActualization(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (224)', () {
      final metrics = PerfectActualization(counter: 224);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = PerfectActualization(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = PerfectActualization(counter: 225);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = PerfectActualization(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = PerfectActualization(counter: 224);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = PerfectActualization(counter: 112);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = PerfectActualization(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = PerfectActualization(counter: 50);
      final report = metrics.report();
      expect(report, contains('PerfectActualization'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = PerfectActualization(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(77.6, 0.5));
    });
  });

  group('InfiniteActualization', () {
    test('validates counter at minimum (0)', () {
      final metrics = InfiniteActualization(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (225)', () {
      final metrics = InfiniteActualization(counter: 225);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = InfiniteActualization(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = InfiniteActualization(counter: 226);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = InfiniteActualization(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = InfiniteActualization(counter: 225);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = InfiniteActualization(counter: 112);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = InfiniteActualization(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = InfiniteActualization(counter: 50);
      final report = metrics.report();
      expect(report, contains('InfiniteActualization'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = InfiniteActualization(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(77.7, 0.5));
    });
  });
}
