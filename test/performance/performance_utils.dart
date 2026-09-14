import 'package:flutter_test/flutter_test.dart';

/// Threshold constants for performance benchmarks (milliseconds)
class PerformanceThresholds {
  /// AI move calculation should complete within 5 seconds for acceptable UX
  static const int aiMoveCalculation = 5000;

  /// Board rendering should complete within 100ms for 60fps performance
  static const int boardRendering = 100;

  /// Game logic operations (move validation, capture detection) should be <50ms
  static const int gameLogicOperation = 50;

  /// Firestore read operations should complete within 1000ms
  static const int firestoreRead = 1000;

  /// Firestore write operations should complete within 1500ms
  static const int firestoreWrite = 1500;

  /// UI responsiveness: response to user tap should be <200ms
  static const int uiResponsiveness = 200;

  /// Serialization/deserialization of game records should be <100ms
  static const int serialization = 100;
}

/// Performance measurement utilities
class PerformanceHelper {
  /// Measure execution time of an async operation
  static Future<({int milliseconds, T result})> measureAsync<T>(
    Future<T> Function() operation, {
    String? label,
  }) async {
    final stopwatch = Stopwatch()..start();
    final result = await operation();
    stopwatch.stop();

    if (label != null) {
      print('⏱️ $label: ${stopwatch.elapsedMilliseconds}ms');
    }

    return (milliseconds: stopwatch.elapsedMilliseconds, result: result);
  }

  /// Measure execution time of a sync operation
  static ({int milliseconds, T result}) measureSync<T>(
    T Function() operation, {
    String? label,
  }) {
    final stopwatch = Stopwatch()..start();
    final result = operation();
    stopwatch.stop();

    if (label != null) {
      print('⏱️ $label: ${stopwatch.elapsedMilliseconds}ms');
    }

    return (milliseconds: stopwatch.elapsedMilliseconds, result: result);
  }

  /// Verify operation completes within threshold
  static void expectWithinThreshold(
    int actualMs,
    int thresholdMs, {
    required String operationName,
  }) {
    expect(
      actualMs,
      lessThanOrEqualTo(thresholdMs),
      reason: '$operationName took ${actualMs}ms, exceeds threshold of ${thresholdMs}ms',
    );
  }

  /// Run operation multiple times and collect statistics
  static Future<PerformanceStats> measureMultiple<T>(
    Future<T> Function() operation, {
    int iterations = 10,
    String? label,
  }) async {
    final measurements = <int>[];

    for (int i = 0; i < iterations; i++) {
      final measurement = await measureAsync(operation);
      measurements.add(measurement.milliseconds);
    }

    final stats = PerformanceStats.fromMeasurements(measurements);

    if (label != null) {
      print('''
📊 $label Statistics ($iterations iterations):
   Min: ${stats.minMs}ms
   Max: ${stats.maxMs}ms
   Avg: ${stats.averageMs.toStringAsFixed(2)}ms
   Median: ${stats.medianMs}ms
   StdDev: ${stats.stdDevMs.toStringAsFixed(2)}ms
''');
    }

    return stats;
  }

  /// Measure memory usage (basic approximation)
  static void logMemorySample(String label) {
    // Note: Dart doesn't provide direct memory measurement in tests
    // This is a placeholder for future integration with profiling tools
    print('💾 Memory snapshot: $label');
  }
}

/// Statistics from multiple performance measurements
class PerformanceStats {
  final int minMs;
  final int maxMs;
  final double averageMs;
  final int medianMs;
  final double stdDevMs;
  final List<int> measurements;

  PerformanceStats({
    required this.minMs,
    required this.maxMs,
    required this.averageMs,
    required this.medianMs,
    required this.stdDevMs,
    required this.measurements,
  });

  factory PerformanceStats.fromMeasurements(List<int> measurements) {
    if (measurements.isEmpty) {
      throw ArgumentError('measurements cannot be empty');
    }

    final sorted = [...measurements]..sort();
    final min = sorted.first;
    final max = sorted.last;
    final avg = measurements.reduce((a, b) => a + b) / measurements.length;
    final median = sorted[(sorted.length / 2).floor()];

    // Calculate standard deviation
    final variance =
        measurements.map((m) => (m - avg) * (m - avg)).reduce((a, b) => a + b) /
            measurements.length;
    final stdDev = variance.isNaN ? 0 : (variance).sqrt();

    return PerformanceStats(
      minMs: min,
      maxMs: max,
      averageMs: avg,
      medianMs: median,
      stdDevMs: stdDev,
      measurements: measurements,
    );
  }

  /// Check if all measurements are within threshold
  bool allWithinThreshold(int thresholdMs) {
    return measurements.every((m) => m <= thresholdMs);
  }

  /// Check if average is within threshold
  bool averageWithinThreshold(int thresholdMs) {
    return averageMs <= thresholdMs;
  }
}

/// Profiling context for detailed performance analysis
class PerformanceProfile {
  final String name;
  final List<PerformanceMeasurement> measurements = [];
  final DateTime startTime = DateTime.now();

  PerformanceProfile(this.name);

  void record(String operationName, int durationMs) {
    measurements.add(
      PerformanceMeasurement(
        operation: operationName,
        durationMs: durationMs,
        timestamp: DateTime.now(),
      ),
    );
  }

  void printReport() {
    final totalDuration = measurements.fold<int>(
      0,
      (sum, m) => sum + m.durationMs,
    );

    print('''
╔═══════════════════════════════════════╗
║ Performance Profile: $name
╠═══════════════════════════════════════╣
''');

    for (final measurement in measurements) {
      final percentage = (measurement.durationMs / totalDuration * 100).toStringAsFixed(1);
      print('║ ${measurement.operation.padRight(25)} ${measurement.durationMs.toString().padLeft(6)}ms ($percentage%)');
    }

    print('''║ ───────────────────────────────────────
║ Total Duration: ${totalDuration}ms
╚═══════════════════════════════════════╝
''');
  }
}

/// Single performance measurement
class PerformanceMeasurement {
  final String operation;
  final int durationMs;
  final DateTime timestamp;

  PerformanceMeasurement({
    required this.operation,
    required this.durationMs,
    required this.timestamp,
  });
}
