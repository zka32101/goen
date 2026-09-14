import 'package:flutter_test/flutter_test.dart';

/// OmniverseResonance Metrics - Counter range: 0-241
class OmniverseResonance {
  final int counter;

  OmniverseResonance({required this.counter});

  bool isValid() => counter >= 0 && counter <= 241;

  double calculateAccuracy() => ((241 - counter) / 241) * 100;

  String report() =>
      'OmniverseResonance { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// UniversalResonance Metrics - Counter range: 0-242
class UniversalResonance {
  final int counter;

  UniversalResonance({required this.counter});

  bool isValid() => counter >= 0 && counter <= 242;

  double calculateAccuracy() => ((242 - counter) / 242) * 100;

  String report() =>
      'UniversalResonance { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// InfiniteResonance Metrics - Counter range: 0-243
class InfiniteResonance {
  final int counter;

  InfiniteResonance({required this.counter});

  bool isValid() => counter >= 0 && counter <= 243;

  double calculateAccuracy() => ((243 - counter) / 243) * 100;

  String report() =>
      'InfiniteResonance { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('OmniverseResonance', () {
    test('validates counter at minimum (0)', () {
      final metrics = OmniverseResonance(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (241)', () {
      final metrics = OmniverseResonance(counter: 241);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = OmniverseResonance(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = OmniverseResonance(counter: 242);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = OmniverseResonance(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = OmniverseResonance(counter: 241);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = OmniverseResonance(counter: 120);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = OmniverseResonance(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = OmniverseResonance(counter: 50);
      final report = metrics.report();
      expect(report, contains('OmniverseResonance'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = OmniverseResonance(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(79.2, 0.5));
    });
  });

  group('UniversalResonance', () {
    test('validates counter at minimum (0)', () {
      final metrics = UniversalResonance(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (242)', () {
      final metrics = UniversalResonance(counter: 242);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = UniversalResonance(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = UniversalResonance(counter: 243);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = UniversalResonance(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = UniversalResonance(counter: 242);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = UniversalResonance(counter: 121);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = UniversalResonance(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = UniversalResonance(counter: 50);
      final report = metrics.report();
      expect(report, contains('UniversalResonance'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = UniversalResonance(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(79.3, 0.5));
    });
  });

  group('InfiniteResonance', () {
    test('validates counter at minimum (0)', () {
      final metrics = InfiniteResonance(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (243)', () {
      final metrics = InfiniteResonance(counter: 243);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = InfiniteResonance(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = InfiniteResonance(counter: 244);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = InfiniteResonance(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = InfiniteResonance(counter: 243);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = InfiniteResonance(counter: 121);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = InfiniteResonance(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = InfiniteResonance(counter: 50);
      final report = metrics.report();
      expect(report, contains('InfiniteResonance'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = InfiniteResonance(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(79.4, 0.5));
    });
  });
}
