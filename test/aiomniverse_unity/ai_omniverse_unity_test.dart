import 'package:flutter_test/flutter_test.dart';

/// OmniverseUnity Metrics - Counter range: 0-226
class OmniverseUnity {
  final int counter;

  OmniverseUnity({required this.counter});

  bool isValid() => counter >= 0 && counter <= 226;

  double calculateAccuracy() => ((226 - counter) / 226) * 100;

  String report() =>
      'OmniverseUnity { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// UniversalUnity Metrics - Counter range: 0-227
class UniversalUnity {
  final int counter;

  UniversalUnity({required this.counter});

  bool isValid() => counter >= 0 && counter <= 227;

  double calculateAccuracy() => ((227 - counter) / 227) * 100;

  String report() =>
      'UniversalUnity { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// InfiniteUnity Metrics - Counter range: 0-228
class InfiniteUnity {
  final int counter;

  InfiniteUnity({required this.counter});

  bool isValid() => counter >= 0 && counter <= 228;

  double calculateAccuracy() => ((228 - counter) / 228) * 100;

  String report() =>
      'InfiniteUnity { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('OmniverseUnity', () {
    test('validates counter at minimum (0)', () {
      final metrics = OmniverseUnity(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (226)', () {
      final metrics = OmniverseUnity(counter: 226);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = OmniverseUnity(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = OmniverseUnity(counter: 227);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = OmniverseUnity(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = OmniverseUnity(counter: 226);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = OmniverseUnity(counter: 113);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = OmniverseUnity(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = OmniverseUnity(counter: 50);
      final report = metrics.report();
      expect(report, contains('OmniverseUnity'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = OmniverseUnity(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(77.8, 0.5));
    });
  });

  group('UniversalUnity', () {
    test('validates counter at minimum (0)', () {
      final metrics = UniversalUnity(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (227)', () {
      final metrics = UniversalUnity(counter: 227);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = UniversalUnity(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = UniversalUnity(counter: 228);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = UniversalUnity(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = UniversalUnity(counter: 227);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = UniversalUnity(counter: 113);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = UniversalUnity(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = UniversalUnity(counter: 50);
      final report = metrics.report();
      expect(report, contains('UniversalUnity'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = UniversalUnity(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(77.9, 0.5));
    });
  });

  group('InfiniteUnity', () {
    test('validates counter at minimum (0)', () {
      final metrics = InfiniteUnity(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (228)', () {
      final metrics = InfiniteUnity(counter: 228);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = InfiniteUnity(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = InfiniteUnity(counter: 229);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = InfiniteUnity(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = InfiniteUnity(counter: 228);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = InfiniteUnity(counter: 114);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = InfiniteUnity(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = InfiniteUnity(counter: 50);
      final report = metrics.report();
      expect(report, contains('InfiniteUnity'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = InfiniteUnity(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(78.0, 0.5));
    });
  });
}
