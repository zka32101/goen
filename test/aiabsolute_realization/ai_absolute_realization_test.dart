import 'package:flutter_test/flutter_test.dart';

/// AbsoluteRealization Metrics - Counter range: 0-208
class AbsoluteRealization {
  final int counter;

  AbsoluteRealization({required this.counter});

  bool isValid() => counter >= 0 && counter <= 208;

  double calculateAccuracy() => ((208 - counter) / 208) * 100;

  String report() =>
      'AbsoluteRealization { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// PerfectRealization Metrics - Counter range: 0-209
class PerfectRealization {
  final int counter;

  PerfectRealization({required this.counter});

  bool isValid() => counter >= 0 && counter <= 209;

  double calculateAccuracy() => ((209 - counter) / 209) * 100;

  String report() =>
      'PerfectRealization { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// CosmicRealization Metrics - Counter range: 0-210
class CosmicRealization {
  final int counter;

  CosmicRealization({required this.counter});

  bool isValid() => counter >= 0 && counter <= 210;

  double calculateAccuracy() => ((210 - counter) / 210) * 100;

  String report() =>
      'CosmicRealization { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('AbsoluteRealization', () {
    test('validates counter at minimum (0)', () {
      final metrics = AbsoluteRealization(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (208)', () {
      final metrics = AbsoluteRealization(counter: 208);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = AbsoluteRealization(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = AbsoluteRealization(counter: 209);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = AbsoluteRealization(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = AbsoluteRealization(counter: 208);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = AbsoluteRealization(counter: 104);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = AbsoluteRealization(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = AbsoluteRealization(counter: 50);
      final report = metrics.report();
      expect(report, contains('AbsoluteRealization'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = AbsoluteRealization(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.9, 0.5));
    });
  });

  group('PerfectRealization', () {
    test('validates counter at minimum (0)', () {
      final metrics = PerfectRealization(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (209)', () {
      final metrics = PerfectRealization(counter: 209);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = PerfectRealization(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = PerfectRealization(counter: 210);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = PerfectRealization(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = PerfectRealization(counter: 209);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = PerfectRealization(counter: 104);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = PerfectRealization(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = PerfectRealization(counter: 50);
      final report = metrics.report();
      expect(report, contains('PerfectRealization'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = PerfectRealization(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(76.0, 0.5));
    });
  });

  group('CosmicRealization', () {
    test('validates counter at minimum (0)', () {
      final metrics = CosmicRealization(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (210)', () {
      final metrics = CosmicRealization(counter: 210);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = CosmicRealization(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = CosmicRealization(counter: 211);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = CosmicRealization(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = CosmicRealization(counter: 210);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = CosmicRealization(counter: 105);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = CosmicRealization(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = CosmicRealization(counter: 50);
      final report = metrics.report();
      expect(report, contains('CosmicRealization'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = CosmicRealization(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(76.1, 0.5));
    });
  });
}
