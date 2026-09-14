import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/go_engine_service.dart';
import 'performance_utils.dart';

void main() {
  group('GoEngineService Performance Tests', () {
    late GoEngineService service;

    setUp(() {
      service = GoEngineService();
    });

    /// Helper to create a board state
    BoardState _createBoardState({
      int size = 9,
      int stoneCount = 10,
    }) {
      final stones = List<List<int>>.generate(
        size,
        (row) => List<int>.generate(size, (col) => -1),
      );

      // Add some stones for testing
      for (int i = 0; i < stoneCount && i < size * size; i++) {
        final row = i ~/ size;
        final col = i % size;
        stones[row][col] = i % 2; // Alternate black/white
      }

      return BoardState(
        boardSize: size,
        stones: stones,
        isPlayerBlack: true,
      );
    }

    test('⚡ BoardState.toSgf() performs within threshold', () {
      final boardState = _createBoardState(size: 19, stoneCount: 50);

      final measurement = PerformanceHelper.measureSync(
        () => boardState.toSgf(),
        label: 'SGF conversion (19x19 with 50 stones)',
      );

      PerformanceHelper.expectWithinThreshold(
        measurement.milliseconds,
        PerformanceThresholds.serialization,
        operationName: 'SGF conversion',
      );

      expect(measurement.result, isNotEmpty);
      expect(measurement.result, contains('GM[1]'));
    });

    test('⚡ SGF conversion handles various board sizes efficiently', () async {
      final sizes = [7, 9, 13, 19];
      final measurements = <int>[];

      for (final size in sizes) {
        final boardState = _createBoardState(size: size, stoneCount: 20);
        final measurement = PerformanceHelper.measureSync(
          () => boardState.toSgf(),
        );
        measurements.add(measurement.milliseconds);
      }

      // All sizes should be fast
      for (final ms in measurements) {
        expect(
          ms,
          lessThanOrEqualTo(PerformanceThresholds.serialization),
          reason: 'SGF conversion exceeded threshold',
        );
      }
    });

    test('⚡ Board encoding for Cloud Function is performant', () {
      final boardState = _createBoardState(size: 19, stoneCount: 100);

      final measurement = PerformanceHelper.measureSync(
        () => service.encodeboardState(boardState),
        label: 'Board encoding (19x19 with 100 stones)',
      );

      PerformanceHelper.expectWithinThreshold(
        measurement.milliseconds,
        PerformanceThresholds.gameLogicOperation,
        operationName: 'Board encoding',
      );

      expect(measurement.result, containsPair('boardSize', 19));
    });

    test('⚡ Move validation is sub-millisecond fast', () {
      final boardState = _createBoardState(size: 9, stoneCount: 20);

      // Perform multiple validations and measure average
      final validations = List.generate(
        1000,
        (i) => () => service.validateMove(
          boardState: boardState,
          row: 2,
          col: 3,
        ),
      );

      var totalTime = 0;
      for (final validation in validations) {
        final measurement = PerformanceHelper.measureSync(validation);
        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / validations.length;

      expect(
        averageMs,
        lessThan(1.0), // Should be sub-millisecond
        reason: 'Move validation average exceeded 1ms',
      );
    });

    test('⚡ Invalid move validation (out of bounds) is fast', () {
      final boardState = _createBoardState(size: 9);

      final validations = [
        // Out of bounds
        () => service.validateMove(
          boardState: boardState,
          row: -1,
          col: 5,
        ),
        // Column out of bounds
        () => service.validateMove(
          boardState: boardState,
          row: 5,
          col: 10,
        ),
        // Row out of bounds
        () => service.validateMove(
          boardState: boardState,
          row: 15,
          col: 5,
        ),
      ];

      for (final validation in validations) {
        final measurement = PerformanceHelper.measureSync(validation);
        expect(
          measurement.milliseconds,
          lessThanOrEqualTo(1),
          reason: 'Boundary validation exceeded threshold',
        );
        expect(measurement.result, false);
      }
    });

    test('⚡ Occupied position detection is efficient', () {
      final boardState = _createBoardState(size: 9, stoneCount: 40);

      // Find an occupied position
      int occupiedRow = -1, occupiedCol = -1;
      for (int i = 0; i < boardState.boardSize; i++) {
        for (int j = 0; j < boardState.boardSize; j++) {
          if (boardState.stones[i][j] != -1) {
            occupiedRow = i;
            occupiedCol = j;
            break;
          }
        }
        if (occupiedRow != -1) break;
      }

      if (occupiedRow != -1) {
        final measurement = PerformanceHelper.measureSync(
          () => service.validateMove(
            boardState: boardState,
            row: occupiedRow,
            col: occupiedCol,
          ),
        );

        expect(measurement.milliseconds, lessThanOrEqualTo(1));
        expect(measurement.result, false);
      }
    });

    test('⚡ Multiple board encodings maintain performance', () async {
      const iterations = 100;
      final boardState = _createBoardState(size: 19, stoneCount: 80);

      final stats = await PerformanceHelper.measureMultiple(
        () => Future.value(service.encodeboardState(boardState)),
        iterations: iterations,
        label: 'Board encoding (100 iterations)',
      );

      PerformanceHelper.expectWithinThreshold(
        stats.maxMs,
        PerformanceThresholds.gameLogicOperation,
        operationName: 'Max board encoding time',
      );

      expect(stats.averageWithinThreshold(PerformanceThresholds.gameLogicOperation), true);
    });

    test('⚡ SGF conversion with various stone densities', () {
      final densities = [1, 10, 30, 80, 150];

      for (final density in densities) {
        final boardState = _createBoardState(size: 19, stoneCount: density);
        final measurement = PerformanceHelper.measureSync(
          () => boardState.toSgf(),
        );

        expect(
          measurement.milliseconds,
          lessThanOrEqualTo(PerformanceThresholds.serialization),
          reason: 'SGF conversion with $density stones exceeded threshold',
        );
      }
    });

    test('📊 AIMove deserialization from JSON is fast', () {
      const json = {
        'row': 5,
        'col': 7,
        'confidence': 0.92,
        'reasoning': 'Defensive move to protect group',
      };

      const iterations = 1000;
      var totalTime = 0;

      for (int i = 0; i < iterations; i++) {
        final measurement = PerformanceHelper.measureSync(
          () => AIMove.fromJson(json),
        );
        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / iterations;
      expect(averageMs, lessThan(1.0));
    });

    test('📊 GameEndResult deserialization is performant', () {
      const json = {
        'gameEnded': true,
        'blackScore': 125.5,
        'whiteScore': 120.0,
        'winner': 'black',
        'scoringMethod': 'chinese',
      };

      const iterations = 1000;
      var totalTime = 0;

      for (int i = 0; i < iterations; i++) {
        final measurement = PerformanceHelper.measureSync(
          () => GameEndResult.fromJson(json),
        );
        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / iterations;
      expect(averageMs, lessThan(1.0));
    });

    test('🔄 Board state creation for different sizes', () {
      final sizes = [7, 9, 13, 19];
      final profile = PerformanceProfile('Board Initialization');

      for (final size in sizes) {
        final measurement = PerformanceHelper.measureSync(
          () => _createBoardState(size: size),
        );
        profile.record('Board $size×$size', measurement.milliseconds);

        expect(
          measurement.milliseconds,
          lessThanOrEqualTo(10), // Should be very fast
        );
      }

      profile.printReport();
    });

    test('🔄 Sequential validation on same board is consistent', () async {
      final boardState = _createBoardState(size: 9, stoneCount: 20);

      const validationCount = 50;
      final measurements = <int>[];

      for (int i = 0; i < validationCount; i++) {
        final row = (i % 7) + 1;
        final col = ((i + 1) % 7) + 1;

        final measurement = PerformanceHelper.measureSync(
          () => service.validateMove(
            boardState: boardState,
            row: row,
            col: col,
          ),
        );

        measurements.add(measurement.milliseconds);
      }

      // All validations should be extremely fast
      for (final ms in measurements) {
        expect(ms, lessThanOrEqualTo(1));
      }
    });

    test('🔄 Complex board state handling (high stone count)', () {
      // Test with nearly full board
      final boardState = _createBoardState(size: 19, stoneCount: 340);

      final sgfMeasurement = PerformanceHelper.measureSync(
        () => boardState.toSgf(),
        label: 'SGF conversion (19x19 nearly full)',
      );

      final encodeMeasurement = PerformanceHelper.measureSync(
        () => service.encodeboardState(boardState),
        label: 'Encoding (19x19 nearly full)',
      );

      expect(
        sgfMeasurement.milliseconds,
        lessThanOrEqualTo(PerformanceThresholds.serialization),
      );
      expect(
        encodeMeasurement.milliseconds,
        lessThanOrEqualTo(PerformanceThresholds.gameLogicOperation),
      );
    });

    test('💾 Memory efficiency of board state operations', () {
      final sizes = [7, 9, 13, 19];

      PerformanceHelper.logMemorySample('Before board operations');

      for (final size in sizes) {
        final boardState = _createBoardState(size: size, stoneCount: 100);
        final _ = boardState.toSgf();
        final __ = service.encodeboardState(boardState);
      }

      PerformanceHelper.logMemorySample('After board operations');

      // Note: Memory assertions would require actual memory measurement
      // This test documents where memory profiling should occur
    });
  });
}
