import 'package:flutter_test/flutter_test.dart';

/// InfiniteSynchronization Metrics - Counter range: 0-229
class InfiniteSynchronization {
  final int counter;

  InfiniteSynchronization({required this.counter});

  bool isValid() => counter >= 0 && counter <= 229;

  double calculateAccuracy() => ((229 - counter) / 229) * 100;

  String report() =>
      'InfiniteSynchronization { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// PerfectSynchronization Metrics - Counter range: 0-230
class PerfectSynchronization {
  final int counter;

  PerfectSynchronization({required this.counter});

  bool isValid() => counter >= 0 && counter <= 230;

  double calculateAccuracy() => ((230 - counter) / 230) * 100;

  String report() =>
      'PerfectSynchronization { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// EternalSynchronization Metrics - Counter range: 0-231
class EternalSynchronization {
  final int counter;

  EternalSynchronization({required this.counter});

  bool isValid() => counter >= 0 && counter <= 231;

  double calculateAccuracy() => ((231 - counter) / 231) * 100;

  String report() =>
      'EternalSynchronization { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('InfiniteSynchronization', () {
    test('validates counter at minimum (0)', () {
      final metrics = InfiniteSynchronization(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (229)', () {
      final metrics = InfiniteSynchronization(counter: 229);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = InfiniteSynchronization(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = InfiniteSynchronization(counter: 230);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = InfiniteSynchronization(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = InfiniteSynchronization(counter: 229);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = InfiniteSynchronization(counter: 114);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = InfiniteSynchronization(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = InfiniteSynchronization(counter: 50);
      final report = metrics.report();
      expect(report, contains('InfiniteSynchronization'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = InfiniteSynchronization(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(78.1, 0.5));
    });
  });

  group('PerfectSynchronization', () {
    test('validates counter at minimum (0)', () {
      final metrics = PerfectSynchronization(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (230)', () {
      final metrics = PerfectSynchronization(counter: 230);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = PerfectSynchronization(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = PerfectSynchronization(counter: 231);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = PerfectSynchronization(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = PerfectSynchronization(counter: 230);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = PerfectSynchronization(counter: 115);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = PerfectSynchronization(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = PerfectSynchronization(counter: 50);
      final report = metrics.report();
      expect(report, contains('PerfectSynchronization'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = PerfectSynchronization(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(78.2, 0.5));
    });
  });

  group('EternalSynchronization', () {
    test('validates counter at minimum (0)', () {
      final metrics = EternalSynchronization(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (231)', () {
      final metrics = EternalSynchronization(counter: 231);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = EternalSynchronization(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = EternalSynchronization(counter: 232);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = EternalSynchronization(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = EternalSynchronization(counter: 231);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = EternalSynchronization(counter: 115);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = EternalSynchronization(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = EternalSynchronization(counter: 50);
      final report = metrics.report();
      expect(report, contains('EternalSynchronization'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = EternalSynchronization(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(78.3, 0.5));
    });
  });
}
