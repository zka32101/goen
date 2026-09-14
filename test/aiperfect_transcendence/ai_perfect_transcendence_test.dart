import 'package:flutter_test/flutter_test.dart';

/// PerfectTranscendence Metrics - Counter range: 0-214
class PerfectTranscendence {
  final int counter;

  PerfectTranscendence({required this.counter});

  bool isValid() => counter >= 0 && counter <= 214;

  double calculateAccuracy() => ((214 - counter) / 214) * 100;

  String report() =>
      'PerfectTranscendence { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// AbsoluteTranscendence Metrics - Counter range: 0-215
class AbsoluteTranscendence {
  final int counter;

  AbsoluteTranscendence({required this.counter});

  bool isValid() => counter >= 0 && counter <= 215;

  double calculateAccuracy() => ((215 - counter) / 215) * 100;

  String report() =>
      'AbsoluteTranscendence { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// EternalTranscendence Metrics - Counter range: 0-216
class EternalTranscendence {
  final int counter;

  EternalTranscendence({required this.counter});

  bool isValid() => counter >= 0 && counter <= 216;

  double calculateAccuracy() => ((216 - counter) / 216) * 100;

  String report() =>
      'EternalTranscendence { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('PerfectTranscendence', () {
    test('validates counter at minimum (0)', () {
      final metrics = PerfectTranscendence(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (214)', () {
      final metrics = PerfectTranscendence(counter: 214);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = PerfectTranscendence(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = PerfectTranscendence(counter: 215);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = PerfectTranscendence(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = PerfectTranscendence(counter: 214);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = PerfectTranscendence(counter: 107);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = PerfectTranscendence(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = PerfectTranscendence(counter: 50);
      final report = metrics.report();
      expect(report, contains('PerfectTranscendence'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = PerfectTranscendence(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(76.6, 0.5));
    });
  });

  group('AbsoluteTranscendence', () {
    test('validates counter at minimum (0)', () {
      final metrics = AbsoluteTranscendence(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (215)', () {
      final metrics = AbsoluteTranscendence(counter: 215);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = AbsoluteTranscendence(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = AbsoluteTranscendence(counter: 216);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = AbsoluteTranscendence(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = AbsoluteTranscendence(counter: 215);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = AbsoluteTranscendence(counter: 107);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = AbsoluteTranscendence(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = AbsoluteTranscendence(counter: 50);
      final report = metrics.report();
      expect(report, contains('AbsoluteTranscendence'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = AbsoluteTranscendence(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(76.7, 0.5));
    });
  });

  group('EternalTranscendence', () {
    test('validates counter at minimum (0)', () {
      final metrics = EternalTranscendence(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (216)', () {
      final metrics = EternalTranscendence(counter: 216);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = EternalTranscendence(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = EternalTranscendence(counter: 217);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = EternalTranscendence(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = EternalTranscendence(counter: 216);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = EternalTranscendence(counter: 108);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = EternalTranscendence(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = EternalTranscendence(counter: 50);
      final report = metrics.report();
      expect(report, contains('EternalTranscendence'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = EternalTranscendence(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(76.8, 0.5));
    });
  });
}
