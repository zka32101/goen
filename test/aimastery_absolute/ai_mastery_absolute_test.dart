import 'package:flutter_test/flutter_test.dart';

/// AbsoluteMasteryMetrics - Counter: 157
class AbsoluteMasteryMetrics {
  final int counter;

  AbsoluteMasteryMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 157;

  double calculateAccuracy() => ((157 - counter) / 157) * 100;

  String report() => '''AbsoluteMasteryMetrics {
  counter: $counter,
  accuracy: ${calculateAccuracy().toStringAsFixed(2)}%,
  validation: ${isValid()}
}''';
}

/// PerfectSovereigntyMetrics - Counter: 158
class PerfectSovereigntyMetrics {
  final int counter;

  PerfectSovereigntyMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 158;

  double calculateAccuracy() => ((158 - counter) / 158) * 100;

  String report() => '''PerfectSovereigntyMetrics {
  counter: $counter,
  accuracy: ${calculateAccuracy().toStringAsFixed(2)}%,
  validation: ${isValid()}
}''';
}

/// UltimatePowerMetrics - Counter: 159
class UltimatePowerMetrics {
  final int counter;

  UltimatePowerMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 159;

  double calculateAccuracy() => ((159 - counter) / 159) * 100;

  String report() => '''UltimatePowerMetrics {
  counter: $counter,
  accuracy: ${calculateAccuracy().toStringAsFixed(2)}%,
  validation: ${isValid()}
}''';
}

void main() {
  group('AbsoluteMasteryMetrics', () {
    test('validates counter range correctly', () {
      expect(AbsoluteMasteryMetrics(counter: 0).isValid(), true);
      expect(AbsoluteMasteryMetrics(counter: 157).isValid(), true);
      expect(AbsoluteMasteryMetrics(counter: 158).isValid(), false);
    });

    test('perfect state has maximum accuracy', () {
      final metrics = AbsoluteMasteryMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), 100.0);
    });

    test('partial state calculates correct accuracy', () {
      final metrics = AbsoluteMasteryMetrics(counter: 78);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy > 49.0 && accuracy < 51.0, true);
    });

    test('worst state has minimum accuracy', () {
      final metrics = AbsoluteMasteryMetrics(counter: 157);
      expect(metrics.calculateAccuracy() < 1.0, true);
    });

    test('rejects invalid counter states', () {
      expect(AbsoluteMasteryMetrics(counter: -1).isValid(), false);
      expect(AbsoluteMasteryMetrics(counter: 200).isValid(), false);
    });

    test('report format is consistent', () {
      final metrics = AbsoluteMasteryMetrics(counter: 50);
      final report = metrics.report();
      expect(report.contains('AbsoluteMasteryMetrics'), true);
      expect(report.contains('counter: 50'), true);
      expect(report.contains('accuracy:'), true);
    });

    test('accuracy threshold is correct', () {
      final metrics = AbsoluteMasteryMetrics(counter: 5);
      expect(metrics.calculateAccuracy() > 96.0, true);
    });

    test('all counters in range are valid', () {
      for (int i = 0; i <= 157; i++) {
        expect(AbsoluteMasteryMetrics(counter: i).isValid(), true);
      }
    });

    test('boundary conditions are precise', () {
      expect(AbsoluteMasteryMetrics(counter: 0).isValid(), true);
      expect(AbsoluteMasteryMetrics(counter: 157).isValid(), true);
      expect(AbsoluteMasteryMetrics(counter: -1).isValid(), false);
      expect(AbsoluteMasteryMetrics(counter: 158).isValid(), false);
    });

    test('cross-metric accuracy consistency', () {
      final m1 = AbsoluteMasteryMetrics(counter: 0);
      final m2 = PerfectSovereigntyMetrics(counter: 0);
      expect(m1.calculateAccuracy() == 100.0 && m2.calculateAccuracy() == 100.0, true);
    });
  });

  group('PerfectSovereigntyMetrics', () {
    test('validates counter range correctly', () {
      expect(PerfectSovereigntyMetrics(counter: 0).isValid(), true);
      expect(PerfectSovereigntyMetrics(counter: 158).isValid(), true);
      expect(PerfectSovereigntyMetrics(counter: 159).isValid(), false);
    });

    test('perfect state has maximum accuracy', () {
      final metrics = PerfectSovereigntyMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), 100.0);
    });

    test('partial state calculates correct accuracy', () {
      final metrics = PerfectSovereigntyMetrics(counter: 79);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy > 49.0 && accuracy < 51.0, true);
    });

    test('worst state has minimum accuracy', () {
      final metrics = PerfectSovereigntyMetrics(counter: 158);
      expect(metrics.calculateAccuracy() < 1.0, true);
    });

    test('rejects invalid counter states', () {
      expect(PerfectSovereigntyMetrics(counter: -1).isValid(), false);
      expect(PerfectSovereigntyMetrics(counter: 200).isValid(), false);
    });

    test('report format is consistent', () {
      final metrics = PerfectSovereigntyMetrics(counter: 50);
      final report = metrics.report();
      expect(report.contains('PerfectSovereigntyMetrics'), true);
      expect(report.contains('counter: 50'), true);
    });

    test('accuracy threshold is correct', () {
      final metrics = PerfectSovereigntyMetrics(counter: 5);
      expect(metrics.calculateAccuracy() > 96.0, true);
    });

    test('all counters in range are valid', () {
      for (int i = 0; i <= 158; i++) {
        expect(PerfectSovereigntyMetrics(counter: i).isValid(), true);
      }
    });

    test('boundary conditions are precise', () {
      expect(PerfectSovereigntyMetrics(counter: 0).isValid(), true);
      expect(PerfectSovereigntyMetrics(counter: 158).isValid(), true);
      expect(PerfectSovereigntyMetrics(counter: -1).isValid(), false);
      expect(PerfectSovereigntyMetrics(counter: 159).isValid(), false);
    });

    test('cross-metric accuracy consistency', () {
      final m1 = PerfectSovereigntyMetrics(counter: 0);
      final m2 = UltimatePowerMetrics(counter: 0);
      expect(m1.calculateAccuracy() == 100.0 && m2.calculateAccuracy() == 100.0, true);
    });
  });

  group('UltimatePowerMetrics', () {
    test('validates counter range correctly', () {
      expect(UltimatePowerMetrics(counter: 0).isValid(), true);
      expect(UltimatePowerMetrics(counter: 159).isValid(), true);
      expect(UltimatePowerMetrics(counter: 160).isValid(), false);
    });

    test('perfect state has maximum accuracy', () {
      final metrics = UltimatePowerMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), 100.0);
    });

    test('partial state calculates correct accuracy', () {
      final metrics = UltimatePowerMetrics(counter: 79);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy > 49.0 && accuracy < 51.0, true);
    });

    test('worst state has minimum accuracy', () {
      final metrics = UltimatePowerMetrics(counter: 159);
      expect(metrics.calculateAccuracy() < 1.0, true);
    });

    test('rejects invalid counter states', () {
      expect(UltimatePowerMetrics(counter: -1).isValid(), false);
      expect(UltimatePowerMetrics(counter: 200).isValid(), false);
    });

    test('report format is consistent', () {
      final metrics = UltimatePowerMetrics(counter: 50);
      final report = metrics.report();
      expect(report.contains('UltimatePowerMetrics'), true);
      expect(report.contains('counter: 50'), true);
    });

    test('accuracy threshold is correct', () {
      final metrics = UltimatePowerMetrics(counter: 5);
      expect(metrics.calculateAccuracy() > 96.0, true);
    });

    test('all counters in range are valid', () {
      for (int i = 0; i <= 159; i++) {
        expect(UltimatePowerMetrics(counter: i).isValid(), true);
      }
    });

    test('boundary conditions are precise', () {
      expect(UltimatePowerMetrics(counter: 0).isValid(), true);
      expect(UltimatePowerMetrics(counter: 159).isValid(), true);
      expect(UltimatePowerMetrics(counter: -1).isValid(), false);
      expect(UltimatePowerMetrics(counter: 160).isValid(), false);
    });

    test('cross-metric accuracy consistency', () {
      final m1 = UltimatePowerMetrics(counter: 0);
      final m2 = AbsoluteMasteryMetrics(counter: 0);
      expect(m1.calculateAccuracy() == 100.0 && m2.calculateAccuracy() == 100.0, true);
    });
  });
}
