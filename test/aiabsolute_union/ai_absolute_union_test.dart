import 'package:flutter_test/flutter_test.dart';

/// AbsoluteUnionMetrics - Counter range: 0-199
class AbsoluteUnionMetrics {
  final int counter;

  AbsoluteUnionMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 199;

  double calculateAccuracy() => ((199 - counter) / 199) * 100;

  String report() =>
      'AbsoluteUnionMetrics { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// PerfectUnionMetrics - Counter range: 0-200
class PerfectUnionMetrics {
  final int counter;

  PerfectUnionMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 200;

  double calculateAccuracy() => ((200 - counter) / 200) * 100;

  String report() =>
      'PerfectUnionMetrics { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// EternalUnionMetrics - Counter range: 0-201
class EternalUnionMetrics {
  final int counter;

  EternalUnionMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 201;

  double calculateAccuracy() => ((201 - counter) / 201) * 100;

  String report() =>
      'EternalUnionMetrics { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('AbsoluteUnionMetrics', () {
    test('validates counter at minimum (0)', () {
      final metrics = AbsoluteUnionMetrics(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (199)', () {
      final metrics = AbsoluteUnionMetrics(counter: 199);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = AbsoluteUnionMetrics(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = AbsoluteUnionMetrics(counter: 200);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = AbsoluteUnionMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = AbsoluteUnionMetrics(counter: 199);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = AbsoluteUnionMetrics(counter: 99);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = AbsoluteUnionMetrics(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = AbsoluteUnionMetrics(counter: 50);
      final report = metrics.report();
      expect(report, contains('AbsoluteUnionMetrics'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = AbsoluteUnionMetrics(counter: 49);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.3, 0.5));
    });
  });

  group('PerfectUnionMetrics', () {
    test('validates counter at minimum (0)', () {
      final metrics = PerfectUnionMetrics(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (200)', () {
      final metrics = PerfectUnionMetrics(counter: 200);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = PerfectUnionMetrics(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = PerfectUnionMetrics(counter: 201);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = PerfectUnionMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = PerfectUnionMetrics(counter: 200);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = PerfectUnionMetrics(counter: 100);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.01));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = PerfectUnionMetrics(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = PerfectUnionMetrics(counter: 50);
      final report = metrics.report();
      expect(report, contains('PerfectUnionMetrics'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = PerfectUnionMetrics(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.0, 0.01));
    });
  });

  group('EternalUnionMetrics', () {
    test('validates counter at minimum (0)', () {
      final metrics = EternalUnionMetrics(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (201)', () {
      final metrics = EternalUnionMetrics(counter: 201);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = EternalUnionMetrics(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = EternalUnionMetrics(counter: 202);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = EternalUnionMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = EternalUnionMetrics(counter: 201);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = EternalUnionMetrics(counter: 100);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = EternalUnionMetrics(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = EternalUnionMetrics(counter: 50);
      final report = metrics.report();
      expect(report, contains('EternalUnionMetrics'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = EternalUnionMetrics(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.1, 0.5));
    });
  });
}
