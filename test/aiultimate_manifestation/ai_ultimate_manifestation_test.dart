import 'package:flutter_test/flutter_test.dart';

/// UltimateManifestation Metrics - Counter range: 0-205
class UltimateManifestation {
  final int counter;

  UltimateManifestation({required this.counter});

  bool isValid() => counter >= 0 && counter <= 205;

  double calculateAccuracy() => ((205 - counter) / 205) * 100;

  String report() =>
      'UltimateManifestation { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// AbsoluteManifestation Metrics - Counter range: 0-206
class AbsoluteManifestation {
  final int counter;

  AbsoluteManifestation({required this.counter});

  bool isValid() => counter >= 0 && counter <= 206;

  double calculateAccuracy() => ((206 - counter) / 206) * 100;

  String report() =>
      'AbsoluteManifestation { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

/// CosmicManifestation Metrics - Counter range: 0-207
class CosmicManifestation {
  final int counter;

  CosmicManifestation({required this.counter});

  bool isValid() => counter >= 0 && counter <= 207;

  double calculateAccuracy() => ((207 - counter) / 207) * 100;

  String report() =>
      'CosmicManifestation { counter: $counter, accuracy: ${calculateAccuracy().toStringAsFixed(2)}%, validation: ${isValid()} }';
}

void main() {
  group('UltimateManifestation', () {
    test('validates counter at minimum (0)', () {
      final metrics = UltimateManifestation(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (205)', () {
      final metrics = UltimateManifestation(counter: 205);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = UltimateManifestation(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = UltimateManifestation(counter: 206);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = UltimateManifestation(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = UltimateManifestation(counter: 205);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = UltimateManifestation(counter: 102);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = UltimateManifestation(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = UltimateManifestation(counter: 50);
      final report = metrics.report();
      expect(report, contains('UltimateManifestation'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = UltimateManifestation(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.6, 0.5));
    });
  });

  group('AbsoluteManifestation', () {
    test('validates counter at minimum (0)', () {
      final metrics = AbsoluteManifestation(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (206)', () {
      final metrics = AbsoluteManifestation(counter: 206);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = AbsoluteManifestation(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = AbsoluteManifestation(counter: 207);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = AbsoluteManifestation(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = AbsoluteManifestation(counter: 206);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = AbsoluteManifestation(counter: 103);
      expect(metrics.calculateAccuracy(), closeTo(50.0, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = AbsoluteManifestation(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = AbsoluteManifestation(counter: 50);
      final report = metrics.report();
      expect(report, contains('AbsoluteManifestation'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = AbsoluteManifestation(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.7, 0.5));
    });
  });

  group('CosmicManifestation', () {
    test('validates counter at minimum (0)', () {
      final metrics = CosmicManifestation(counter: 0);
      expect(metrics.isValid(), true);
    });

    test('validates counter at maximum (207)', () {
      final metrics = CosmicManifestation(counter: 207);
      expect(metrics.isValid(), true);
    });

    test('rejects counter below minimum', () {
      final metrics = CosmicManifestation(counter: -1);
      expect(metrics.isValid(), false);
    });

    test('rejects counter above maximum', () {
      final metrics = CosmicManifestation(counter: 208);
      expect(metrics.isValid(), false);
    });

    test('calculates accuracy at perfect state (100%)', () {
      final metrics = CosmicManifestation(counter: 0);
      expect(metrics.calculateAccuracy(), closeTo(100.0, 0.01));
    });

    test('calculates accuracy at worst state (~0%)', () {
      final metrics = CosmicManifestation(counter: 207);
      expect(metrics.calculateAccuracy(), closeTo(0.0, 0.01));
    });

    test('calculates accuracy at midpoint (~50%)', () {
      final metrics = CosmicManifestation(counter: 103);
      expect(metrics.calculateAccuracy(), closeTo(50.2, 0.5));
    });

    test('maintains minimum threshold (96.2%)', () {
      final metrics = CosmicManifestation(counter: 8);
      expect(metrics.calculateAccuracy(), greaterThanOrEqualTo(96.0));
    });

    test('generates report string', () {
      final metrics = CosmicManifestation(counter: 50);
      final report = metrics.report();
      expect(report, contains('CosmicManifestation'));
      expect(report, contains('counter: 50'));
      expect(report, contains('accuracy:'));
      expect(report, contains('validation: true'));
    });

    test('accuracy formula consistency', () {
      final metrics = CosmicManifestation(counter: 50);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy, closeTo(75.8, 0.5));
    });
  });
}
