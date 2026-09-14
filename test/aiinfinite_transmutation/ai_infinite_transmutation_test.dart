import 'package:flutter_test/flutter_test.dart';

/// InfiniteTransmutation Metrics - Counter range: 0-244
class InfiniteTransmutation {
  final int counter;

  InfiniteTransmutation({required this.counter});

  bool isValid() => counter >= 0 && counter <= 244;

  double calculateAccuracy() => ((244 - counter) / 244) * 100;

  String report() =>
      'InfiniteTransmutation { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// PerfectTransmutation Metrics - Counter range: 0-245
class PerfectTransmutation {
  final int counter;

  PerfectTransmutation({required this.counter});

  bool isValid() => counter >= 0 && counter <= 245;

  double calculateAccuracy() => ((245 - counter) / 245) * 100;

  String report() =>
      'PerfectTransmutation { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// EternalTransmutation Metrics - Counter range: 0-246
class EternalTransmutation {
  final int counter;

  EternalTransmutation({required this.counter});

  bool isValid() => counter >= 0 && counter <= 246;

  double calculateAccuracy() => ((246 - counter) / 246) * 100;

  String report() =>
      'EternalTransmutation { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('InfiniteTransmutation', () {
    test('validates counter at minimum (0)', () {
      final metrics = InfiniteTransmutation(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (244)', () {
      final metrics = InfiniteTransmutation(counter: 244);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = InfiniteTransmutation(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = InfiniteTransmutation(counter: 245);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = InfiniteTransmutation(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = InfiniteTransmutation(counter: 244);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = InfiniteTransmutation(counter: 122);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = InfiniteTransmutation(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = InfiniteTransmutation(counter: 50);
      final report = metrics.report();
      expect(report, contains('InfiniteTransmutation'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = InfiniteTransmutation(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(79.5, 0.5));
    });
  });

  group('PerfectTransmutation', () {
    test('validates counter at minimum (0)', () {
      final metrics = PerfectTransmutation(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (245)', () {
      final metrics = PerfectTransmutation(counter: 245);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = PerfectTransmutation(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = PerfectTransmutation(counter: 246);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = PerfectTransmutation(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = PerfectTransmutation(counter: 245);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = PerfectTransmutation(counter: 122);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = PerfectTransmutation(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = PerfectTransmutation(counter: 50);
      final report = metrics.report();
      expect(report, contains('PerfectTransmutation'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = PerfectTransmutation(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(79.5, 0.5));
    });
  });

  group('EternalTransmutation', () {
    test('validates counter at minimum (0)', () {
      final metrics = EternalTransmutation(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (246)', () {
      final metrics = EternalTransmutation(counter: 246);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = EternalTransmutation(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = EternalTransmutation(counter: 247);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = EternalTransmutation(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = EternalTransmutation(counter: 246);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = EternalTransmutation(counter: 123);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = EternalTransmutation(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = EternalTransmutation(counter: 50);
      final report = metrics.report();
      expect(report, contains('EternalTransmutation'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = EternalTransmutation(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(79.6, 0.5));
    });
  });
}
