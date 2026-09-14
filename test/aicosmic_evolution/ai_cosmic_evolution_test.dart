import 'package:flutter_test/flutter_test.dart';

/// CosmicEvolution Metrics - Counter range: 0-238
class CosmicEvolution {
  final int counter;

  CosmicEvolution({required this.counter});

  bool isValid() => counter >= 0 && counter <= 238;

  double calculateAccuracy() => ((238 - counter) / 238) * 100;

  String report() =>
      'CosmicEvolution { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// UniversalEvolution Metrics - Counter range: 0-239
class UniversalEvolution {
  final int counter;

  UniversalEvolution({required this.counter});

  bool isValid() => counter >= 0 && counter <= 239;

  double calculateAccuracy() => ((239 - counter) / 239) * 100;

  String report() =>
      'UniversalEvolution { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// InfiniteEvolution Metrics - Counter range: 0-240
class InfiniteEvolution {
  final int counter;

  InfiniteEvolution({required this.counter});

  bool isValid() => counter >= 0 && counter <= 240;

  double calculateAccuracy() => ((240 - counter) / 240) * 100;

  String report() =>
      'InfiniteEvolution { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('CosmicEvolution', () {
    test('validates counter at minimum (0)', () {
      final metrics = CosmicEvolution(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (238)', () {
      final metrics = CosmicEvolution(counter: 238);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = CosmicEvolution(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = CosmicEvolution(counter: 239);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = CosmicEvolution(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = CosmicEvolution(counter: 238);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = CosmicEvolution(counter: 119);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = CosmicEvolution(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = CosmicEvolution(counter: 50);
      final report = metrics.report();
      expect(report, contains('CosmicEvolution'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = CosmicEvolution(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(79.0, 0.5));
    });
  });

  group('UniversalEvolution', () {
    test('validates counter at minimum (0)', () {
      final metrics = UniversalEvolution(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (239)', () {
      final metrics = UniversalEvolution(counter: 239);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = UniversalEvolution(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = UniversalEvolution(counter: 240);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = UniversalEvolution(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = UniversalEvolution(counter: 239);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = UniversalEvolution(counter: 119);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = UniversalEvolution(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = UniversalEvolution(counter: 50);
      final report = metrics.report();
      expect(report, contains('UniversalEvolution'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = UniversalEvolution(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(79.1, 0.5));
    });
  });

  group('InfiniteEvolution', () {
    test('validates counter at minimum (0)', () {
      final metrics = InfiniteEvolution(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (240)', () {
      final metrics = InfiniteEvolution(counter: 240);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = InfiniteEvolution(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = InfiniteEvolution(counter: 241);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = InfiniteEvolution(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = InfiniteEvolution(counter: 240);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = InfiniteEvolution(counter: 120);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = InfiniteEvolution(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = InfiniteEvolution(counter: 50);
      final report = metrics.report();
      expect(report, contains('InfiniteEvolution'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = InfiniteEvolution(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(79.1, 0.5));
    });
  });
}
