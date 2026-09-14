import 'package:flutter_test/flutter_test.dart';

/// EternalConvergenceMetrics - Counter range: 0-202
class EternalConvergenceMetrics {
  final int counter;

  EternalConvergenceMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 202;

  double calculateAccuracy() => ((202 - counter) / 202) * 100;

  String report() =>
      'EternalConvergenceMetrics { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// InfiniteConvergenceMetrics - Counter range: 0-203
class InfiniteConvergenceMetrics {
  final int counter;

  InfiniteConvergenceMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 203;

  double calculateAccuracy() => ((203 - counter) / 203) * 100;

  String report() =>
      'InfiniteConvergenceMetrics { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// AbsoluteConvergenceMetrics - Counter range: 0-204
class AbsoluteConvergenceMetrics {
  final int counter;

  AbsoluteConvergenceMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 204;

  double calculateAccuracy() => ((204 - counter) / 204) * 100;

  String report() =>
      'AbsoluteConvergenceMetrics { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('EternalConvergenceMetrics', () {
    test('validates counter at minimum (0)', () {
      final metrics = EternalConvergenceMetrics(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (202)', () {
      final metrics = EternalConvergenceMetrics(counter: 202);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = EternalConvergenceMetrics(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = EternalConvergenceMetrics(counter: 203);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = EternalConvergenceMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = EternalConvergenceMetrics(counter: 202);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = EternalConvergenceMetrics(counter: 101);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = EternalConvergenceMetrics(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = EternalConvergenceMetrics(counter: 50);
      final report = metrics.report();
      expect(report, contains('EternalConvergenceMetrics'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = EternalConvergenceMetrics(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.2, 0.5));
    });
  });

  group('InfiniteConvergenceMetrics', () {
    test('validates counter at minimum (0)', () {
      final metrics = InfiniteConvergenceMetrics(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (203)', () {
      final metrics = InfiniteConvergenceMetrics(counter: 203);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = InfiniteConvergenceMetrics(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = InfiniteConvergenceMetrics(counter: 204);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = InfiniteConvergenceMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = InfiniteConvergenceMetrics(counter: 203);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = InfiniteConvergenceMetrics(counter: 101);
      expect(metrics.calculateAccuracy(), closeTo(49.7, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = InfiniteConvergenceMetrics(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = InfiniteConvergenceMetrics(counter: 50);
      final report = metrics.report();
      expect(report, contains('InfiniteConvergenceMetrics'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = InfiniteConvergenceMetrics(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.3, 0.5));
    });
  });

  group('AbsoluteConvergenceMetrics', () {
    test('validates counter at minimum (0)', () {
      final metrics = AbsoluteConvergenceMetrics(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (204)', () {
      final metrics = AbsoluteConvergenceMetrics(counter: 204);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = AbsoluteConvergenceMetrics(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = AbsoluteConvergenceMetrics(counter: 205);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = AbsoluteConvergenceMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = AbsoluteConvergenceMetrics(counter: 204);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = AbsoluteConvergenceMetrics(counter: 102);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = AbsoluteConvergenceMetrics(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = AbsoluteConvergenceMetrics(counter: 50);
      final report = metrics.report();
      expect(report, contains('AbsoluteConvergenceMetrics'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = AbsoluteConvergenceMetrics(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.4, 0.5));
    });
  });
}
