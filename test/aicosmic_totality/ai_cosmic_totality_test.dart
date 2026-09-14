import 'package:flutter_test/flutter_test.dart';

/// CosmicTotality Metrics - Counter range: 0-232
class CosmicTotality {
  final int counter;

  CosmicTotality({required this.counter});

  bool isValid() => counter >= 0 && counter <= 232;

  double calculateAccuracy() => ((232 - counter) / 232) * 100;

  String report() =>
      'CosmicTotality { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// UniversalTotality Metrics - Counter range: 0-233
class UniversalTotality {
  final int counter;

  UniversalTotality({required this.counter});

  bool isValid() => counter >= 0 && counter <= 233;

  double calculateAccuracy() => ((233 - counter) / 233) * 100;

  String report() =>
      'UniversalTotality { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// InfiniteTotality Metrics - Counter range: 0-234
class InfiniteTotality {
  final int counter;

  InfiniteTotality({required this.counter});

  bool isValid() => counter >= 0 && counter <= 234;

  double calculateAccuracy() => ((234 - counter) / 234) * 100;

  String report() =>
      'InfiniteTotality { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('CosmicTotality', () {
    test('validates counter at minimum (0)', () {
      final metrics = CosmicTotality(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (232)', () {
      final metrics = CosmicTotality(counter: 232);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = CosmicTotality(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = CosmicTotality(counter: 233);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = CosmicTotality(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = CosmicTotality(counter: 232);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = CosmicTotality(counter: 116);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = CosmicTotality(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = CosmicTotality(counter: 50);
      final report = metrics.report();
      expect(report, contains('CosmicTotality'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = CosmicTotality(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(78.4, 0.5));
    });
  });

  group('UniversalTotality', () {
    test('validates counter at minimum (0)', () {
      final metrics = UniversalTotality(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (233)', () {
      final metrics = UniversalTotality(counter: 233);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = UniversalTotality(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = UniversalTotality(counter: 234);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = UniversalTotality(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = UniversalTotality(counter: 233);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = UniversalTotality(counter: 116);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = UniversalTotality(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = UniversalTotality(counter: 50);
      final report = metrics.report();
      expect(report, contains('UniversalTotality'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = UniversalTotality(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(78.5, 0.5));
    });
  });

  group('InfiniteTotality', () {
    test('validates counter at minimum (0)', () {
      final metrics = InfiniteTotality(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (234)', () {
      final metrics = InfiniteTotality(counter: 234);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = InfiniteTotality(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = InfiniteTotality(counter: 235);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = InfiniteTotality(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = InfiniteTotality(counter: 234);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = InfiniteTotality(counter: 117);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = InfiniteTotality(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = InfiniteTotality(counter: 50);
      final report = metrics.report();
      expect(report, contains('InfiniteTotality'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = InfiniteTotality(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(78.6, 0.5));
    });
  });
}
