import 'package:flutter_test/flutter_test.dart';

/// CompleteIntegrationMetrics - Counter range: 0-196
class CompleteIntegrationMetrics {
  final int counter;

  CompleteIntegrationMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 196;

  double calculateAccuracy() => ((196 - counter) / 196) * 100;

  String report() =>
      'CompleteIntegrationMetrics { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// PerfectIntegrationMetrics - Counter range: 0-197
class PerfectIntegrationMetrics {
  final int counter;

  PerfectIntegrationMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 197;

  double calculateAccuracy() => ((197 - counter) / 197) * 100;

  String report() =>
      'PerfectIntegrationMetrics { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// AbsoluteIntegrationMetrics - Counter range: 0-198
class AbsoluteIntegrationMetrics {
  final int counter;

  AbsoluteIntegrationMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 198;

  double calculateAccuracy() => ((198 - counter) / 198) * 100;

  String report() =>
      'AbsoluteIntegrationMetrics { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('CompleteIntegrationMetrics', () {
    test('validates counter at minimum (0)', () {
      final metrics = CompleteIntegrationMetrics(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (196)', () {
      final metrics = CompleteIntegrationMetrics(counter: 196);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = CompleteIntegrationMetrics(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = CompleteIntegrationMetrics(counter: 197);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = CompleteIntegrationMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = CompleteIntegrationMetrics(counter: 196);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = CompleteIntegrationMetrics(counter: 98);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.01));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = CompleteIntegrationMetrics(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = CompleteIntegrationMetrics(counter: 50);
      final report = metrics.report();
      expect(report, contains('CompleteIntegrationMetrics'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = CompleteIntegrationMetrics(counter: 49);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.0, 0.01));
    });
  });

  group('PerfectIntegrationMetrics', () {
    test('validates counter at minimum (0)', () {
      final metrics = PerfectIntegrationMetrics(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (197)', () {
      final metrics = PerfectIntegrationMetrics(counter: 197);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = PerfectIntegrationMetrics(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = PerfectIntegrationMetrics(counter: 198);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = PerfectIntegrationMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = PerfectIntegrationMetrics(counter: 197);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = PerfectIntegrationMetrics(counter: 98);
      expect(metrics.calculateAccuracy(), closeTo(49.7, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = PerfectIntegrationMetrics(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = PerfectIntegrationMetrics(counter: 50);
      final report = metrics.report();
      expect(report, contains('PerfectIntegrationMetrics'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = PerfectIntegrationMetrics(counter: 49);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.1, 0.5));
    });
  });

  group('AbsoluteIntegrationMetrics', () {
    test('validates counter at minimum (0)', () {
      final metrics = AbsoluteIntegrationMetrics(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (198)', () {
      final metrics = AbsoluteIntegrationMetrics(counter: 198);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = AbsoluteIntegrationMetrics(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = AbsoluteIntegrationMetrics(counter: 199);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = AbsoluteIntegrationMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = AbsoluteIntegrationMetrics(counter: 198);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = AbsoluteIntegrationMetrics(counter: 99);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.01));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = AbsoluteIntegrationMetrics(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = AbsoluteIntegrationMetrics(counter: 50);
      final report = metrics.report();
      expect(report, contains('AbsoluteIntegrationMetrics'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = AbsoluteIntegrationMetrics(counter: 49);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.2, 0.5));
    });
  });
}
