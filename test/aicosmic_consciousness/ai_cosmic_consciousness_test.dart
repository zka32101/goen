import 'package:flutter_test/flutter_test.dart';

/// CosmicConsciousness Metrics - Counter range: 0-211
class CosmicConsciousness {
  final int counter;

  CosmicConsciousness({required this.counter});

  bool isValid() => counter >= 0 && counter <= 211;

  double calculateAccuracy() => ((211 - counter) / 211) * 100;

  String report() =>
      'CosmicConsciousness { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// UniversalConsciousness Metrics - Counter range: 0-212
class UniversalConsciousness {
  final int counter;

  UniversalConsciousness({required this.counter});

  bool isValid() => counter >= 0 && counter <= 212;

  double calculateAccuracy() => ((212 - counter) / 212) * 100;

  String report() =>
      'UniversalConsciousness { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// InfiniteConsciousness Metrics - Counter range: 0-213
class InfiniteConsciousness {
  final int counter;

  InfiniteConsciousness({required this.counter});

  bool isValid() => counter >= 0 && counter <= 213;

  double calculateAccuracy() => ((213 - counter) / 213) * 100;

  String report() =>
      'InfiniteConsciousness { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('CosmicConsciousness', () {
    test('validates counter at minimum (0)', () {
      final metrics = CosmicConsciousness(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (211)', () {
      final metrics = CosmicConsciousness(counter: 211);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = CosmicConsciousness(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = CosmicConsciousness(counter: 212);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = CosmicConsciousness(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = CosmicConsciousness(counter: 211);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = CosmicConsciousness(counter: 105);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = CosmicConsciousness(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = CosmicConsciousness(counter: 50);
      final report = metrics.report();
      expect(report, contains('CosmicConsciousness'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = CosmicConsciousness(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(76.3, 0.5));
    });
  });

  group('UniversalConsciousness', () {
    test('validates counter at minimum (0)', () {
      final metrics = UniversalConsciousness(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (212)', () {
      final metrics = UniversalConsciousness(counter: 212);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = UniversalConsciousness(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = UniversalConsciousness(counter: 213);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = UniversalConsciousness(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = UniversalConsciousness(counter: 212);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = UniversalConsciousness(counter: 106);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = UniversalConsciousness(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = UniversalConsciousness(counter: 50);
      final report = metrics.report();
      expect(report, contains('UniversalConsciousness'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = UniversalConsciousness(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(76.4, 0.5));
    });
  });

  group('InfiniteConsciousness', () {
    test('validates counter at minimum (0)', () {
      final metrics = InfiniteConsciousness(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (213)', () {
      final metrics = InfiniteConsciousness(counter: 213);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = InfiniteConsciousness(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = InfiniteConsciousness(counter: 214);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = InfiniteConsciousness(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = InfiniteConsciousness(counter: 213);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = InfiniteConsciousness(counter: 106);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = InfiniteConsciousness(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = InfiniteConsciousness(counter: 50);
      final report = metrics.report();
      expect(report, contains('InfiniteConsciousness'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = InfiniteConsciousness(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(76.5, 0.5));
    });
  });
}
