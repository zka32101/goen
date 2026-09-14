import 'package:flutter_test/flutter_test.dart';

/// UniversalCommandMetrics - Counter: 154
class UniversalCommandMetrics {
  final int counter;

  UniversalCommandMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 154;

  double calculateAccuracy() => ((154 - counter) / 154) * 100;

  String report() => '''UniversalCommandMetrics {
  counter: $counter,
  accuracy: ${calculateAccuracy().toStringAsFixed(2)}%,
  validation: ${isValid()}
}''';
}

/// AbsoluteAuthorityMetrics - Counter: 155
class AbsoluteAuthorityMetrics {
  final int counter;

  AbsoluteAuthorityMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 155;

  double calculateAccuracy() => ((155 - counter) / 155) * 100;

  String report() => '''AbsoluteAuthorityMetrics {
  counter: $counter,
  accuracy: ${calculateAccuracy().toStringAsFixed(2)}%,
  validation: ${isValid()}
}''';
}

/// InfiniteDominionMetrics - Counter: 156
class InfiniteDominionMetrics {
  final int counter;

  InfiniteDominionMetrics({required this.counter});

  bool isValid() => counter >= 0 && counter <= 156;

  double calculateAccuracy() => ((156 - counter) / 156) * 100;

  String report() => '''InfiniteDominionMetrics {
  counter: $counter,
  accuracy: ${calculateAccuracy().toStringAsFixed(2)}%,
  validation: ${isValid()}
}''';
}

void main() {
  group('UniversalCommandMetrics', () {
    test('validates counter range correctly', () {
      expect(UniversalCommandMetrics(counter: 0).isValid(), true);
      expect(UniversalCommandMetrics(counter: 154).isValid(), true);
      expect(UniversalCommandMetrics(counter: 155).isValid(), false);
    });

    test('perfect state has maximum accuracy', () {
      final metrics = UniversalCommandMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), 100.0);
    });

    test('partial state calculates correct accuracy', () {
      final metrics = UniversalCommandMetrics(counter: 77);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy > 49.0 && accuracy < 51.0, true);
    });

    test('worst state has minimum accuracy', () {
      final metrics = UniversalCommandMetrics(counter: 154);
      expect(metrics.calculateAccuracy() < 1.0, true);
    });

    test('rejects invalid counter states', () {
      expect(UniversalCommandMetrics(counter: -1).isValid(), false);
      expect(UniversalCommandMetrics(counter: 200).isValid(), false);
    });

    test('report format is consistent', () {
      final metrics = UniversalCommandMetrics(counter: 50);
      final report = metrics.report();
      expect(report.contains('UniversalCommandMetrics'), true);
      expect(report.contains('counter: 50'), true);
      expect(report.contains('accuracy:'), true);
    });

    test('accuracy threshold is correct', () {
      final metrics = UniversalCommandMetrics(counter: 5);
      expect(metrics.calculateAccuracy() > 96.0, true);
    });

    test('all counters in range are valid', () {
      for (int i = 0; i <= 154; i++) {
        expect(UniversalCommandMetrics(counter: i).isValid(), true);
      }
    });

    test('boundary conditions are precise', () {
      expect(UniversalCommandMetrics(counter: 0).isValid(), true);
      expect(UniversalCommandMetrics(counter: 154).isValid(), true);
      expect(UniversalCommandMetrics(counter: -1).isValid(), false);
      expect(UniversalCommandMetrics(counter: 155).isValid(), false);
    });

    test('cross-metric accuracy consistency', () {
      final m1 = UniversalCommandMetrics(counter: 0);
      final m2 = AbsoluteAuthorityMetrics(counter: 0);
      expect(m1.calculateAccuracy() == 100.0 && m2.calculateAccuracy() == 100.0, true);
    });
  });

  group('AbsoluteAuthorityMetrics', () {
    test('validates counter range correctly', () {
      expect(AbsoluteAuthorityMetrics(counter: 0).isValid(), true);
      expect(AbsoluteAuthorityMetrics(counter: 155).isValid(), true);
      expect(AbsoluteAuthorityMetrics(counter: 156).isValid(), false);
    });

    test('perfect state has maximum accuracy', () {
      final metrics = AbsoluteAuthorityMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), 100.0);
    });

    test('partial state calculates correct accuracy', () {
      final metrics = AbsoluteAuthorityMetrics(counter: 77);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy > 49.0 && accuracy < 51.0, true);
    });

    test('worst state has minimum accuracy', () {
      final metrics = AbsoluteAuthorityMetrics(counter: 155);
      expect(metrics.calculateAccuracy() < 1.0, true);
    });

    test('rejects invalid counter states', () {
      expect(AbsoluteAuthorityMetrics(counter: -1).isValid(), false);
      expect(AbsoluteAuthorityMetrics(counter: 200).isValid(), false);
    });

    test('report format is consistent', () {
      final metrics = AbsoluteAuthorityMetrics(counter: 50);
      final report = metrics.report();
      expect(report.contains('AbsoluteAuthorityMetrics'), true);
      expect(report.contains('counter: 50'), true);
    });

    test('accuracy threshold is correct', () {
      final metrics = AbsoluteAuthorityMetrics(counter: 5);
      expect(metrics.calculateAccuracy() > 96.0, true);
    });

    test('all counters in range are valid', () {
      for (int i = 0; i <= 155; i++) {
        expect(AbsoluteAuthorityMetrics(counter: i).isValid(), true);
      }
    });

    test('boundary conditions are precise', () {
      expect(AbsoluteAuthorityMetrics(counter: 0).isValid(), true);
      expect(AbsoluteAuthorityMetrics(counter: 155).isValid(), true);
      expect(AbsoluteAuthorityMetrics(counter: -1).isValid(), false);
      expect(AbsoluteAuthorityMetrics(counter: 156).isValid(), false);
    });

    test('cross-metric accuracy consistency', () {
      final m1 = AbsoluteAuthorityMetrics(counter: 0);
      final m2 = InfiniteDominionMetrics(counter: 0);
      expect(m1.calculateAccuracy() == 100.0 && m2.calculateAccuracy() == 100.0, true);
    });
  });

  group('InfiniteDominionMetrics', () {
    test('validates counter range correctly', () {
      expect(InfiniteDominionMetrics(counter: 0).isValid(), true);
      expect(InfiniteDominionMetrics(counter: 156).isValid(), true);
      expect(InfiniteDominionMetrics(counter: 157).isValid(), false);
    });

    test('perfect state has maximum accuracy', () {
      final metrics = InfiniteDominionMetrics(counter: 0);
      expect(metrics.calculateAccuracy(), 100.0);
    });

    test('partial state calculates correct accuracy', () {
      final metrics = InfiniteDominionMetrics(counter: 78);
      final accuracy = metrics.calculateAccuracy();
      expect(accuracy > 49.0 && accuracy < 51.0, true);
    });

    test('worst state has minimum accuracy', () {
      final metrics = InfiniteDominionMetrics(counter: 156);
      expect(metrics.calculateAccuracy() < 1.0, true);
    });

    test('rejects invalid counter states', () {
      expect(InfiniteDominionMetrics(counter: -1).isValid(), false);
      expect(InfiniteDominionMetrics(counter: 200).isValid(), false);
    });

    test('report format is consistent', () {
      final metrics = InfiniteDominionMetrics(counter: 50);
      final report = metrics.report();
      expect(report.contains('InfiniteDominionMetrics'), true);
      expect(report.contains('counter: 50'), true);
    });

    test('accuracy threshold is correct', () {
      final metrics = InfiniteDominionMetrics(counter: 5);
      expect(metrics.calculateAccuracy() > 96.0, true);
    });

    test('all counters in range are valid', () {
      for (int i = 0; i <= 156; i++) {
        expect(InfiniteDominionMetrics(counter: i).isValid(), true);
      }
    });

    test('boundary conditions are precise', () {
      expect(InfiniteDominionMetrics(counter: 0).isValid(), true);
      expect(InfiniteDominionMetrics(counter: 156).isValid(), true);
      expect(InfiniteDominionMetrics(counter: -1).isValid(), false);
      expect(InfiniteDominionMetrics(counter: 157).isValid(), false);
    });

    test('cross-metric accuracy consistency', () {
      final m1 = InfiniteDominionMetrics(counter: 0);
      final m2 = UniversalCommandMetrics(counter: 0);
      expect(m1.calculateAccuracy() == 100.0 && m2.calculateAccuracy() == 100.0, true);
    });
  });
}
