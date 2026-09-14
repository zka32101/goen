import 'package:flutter_test/flutter_test.dart';

/// AscendantPerfection Metrics - Counter range: 0-235
class AscendantPerfection {
  final int counter;

  AscendantPerfection({required this.counter});

  bool isValid() => counter >= 0 && counter <= 235;

  double calculateAccuracy() => ((235 - counter) / 235) * 100;

  String report() =>
      'AscendantPerfection { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// SupremePerfection Metrics - Counter range: 0-236
class SupremePerfection {
  final int counter;

  SupremePerfection({required this.counter});

  bool isValid() => counter >= 0 && counter <= 236;

  double calculateAccuracy() => ((236 - counter) / 236) * 100;

  String report() =>
      'SupremePerfection { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// InfinitePerfection Metrics - Counter range: 0-237
class InfinitePerfection {
  final int counter;

  InfinitePerfection({required this.counter});

  bool isValid() => counter >= 0 && counter <= 237;

  double calculateAccuracy() => ((237 - counter) / 237) * 100;

  String report() =>
      'InfinitePerfection { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('AscendantPerfection', () {
    test('validates counter at minimum (0)', () {
      final metrics = AscendantPerfection(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (235)', () {
      final metrics = AscendantPerfection(counter: 235);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = AscendantPerfection(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = AscendantPerfection(counter: 236);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = AscendantPerfection(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = AscendantPerfection(counter: 235);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = AscendantPerfection(counter: 117);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = AscendantPerfection(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = AscendantPerfection(counter: 50);
      final report = metrics.report();
      expect(report, contains('AscendantPerfection'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = AscendantPerfection(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(78.7, 0.5));
    });
  });

  group('SupremePerfection', () {
    test('validates counter at minimum (0)', () {
      final metrics = SupremePerfection(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (236)', () {
      final metrics = SupremePerfection(counter: 236);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = SupremePerfection(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = SupremePerfection(counter: 237);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = SupremePerfection(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = SupremePerfection(counter: 236);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = SupremePerfection(counter: 118);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = SupremePerfection(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = SupremePerfection(counter: 50);
      final report = metrics.report();
      expect(report, contains('SupremePerfection'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = SupremePerfection(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(78.8, 0.5));
    });
  });

  group('InfinitePerfection', () {
    test('validates counter at minimum (0)', () {
      final metrics = InfinitePerfection(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (237)', () {
      final metrics = InfinitePerfection(counter: 237);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = InfinitePerfection(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = InfinitePerfection(counter: 238);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = InfinitePerfection(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = InfinitePerfection(counter: 237);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = InfinitePerfection(counter: 118);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = InfinitePerfection(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = InfinitePerfection(counter: 50);
      final report = metrics.report();
      expect(report, contains('InfinitePerfection'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = InfinitePerfection(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(78.9, 0.5));
    });
  });
}
