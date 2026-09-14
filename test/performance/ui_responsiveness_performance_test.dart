import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:goen/services/go_engine_service.dart';
import 'performance_utils.dart';

void main() {
  group('UI Responsiveness Performance Tests', () {
    late GoEngineService service;

    setUp(() {
      service = GoEngineService();
    });

    /// Simulate board rendering preparation
    Future<void> _simulateBoardRenderPrep(BoardState boardState) async {
      await Future.delayed(const Duration(milliseconds: 5));
    }

    /// Simulate UI update for move
    Future<void> _simulateMoveUIUpdate() async {
      await Future.delayed(const Duration(milliseconds: 10));
    }

    test('⚡ UI responsiveness during move validation', () async {
      final board = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: true,
      );

      // Simulate user tapping to place a move
      const moveCount = 30;
      var totalTime = 0;

      for (int i = 0; i < moveCount; i++) {
        final measurement = await PerformanceHelper.measureAsync(
          () async {
            // Validate move
            service.validateMove(
              boardState: board,
              row: i % 9,
              col: (i + 1) % 9,
            );
            // Update UI
            await _simulateMoveUIUpdate();
          },
          label: 'Move $i validation + UI update',
        );

        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / moveCount;

      PerformanceHelper.expectWithinThreshold(
        averageMs.toInt(),
        PerformanceThresholds.uiResponsiveness,
        operationName: 'Average move + UI update time',
      );
    });

    test('⚡ Board rendering responsiveness (simulated)', () async {
      final board = BoardState(
        boardSize: 19,
        stones: List.generate(19, (r) => List.generate(19, (c) => -1)),
        isPlayerBlack: true,
      );

      const renderCount = 60; // Simulate 60fps expectation
      final measurements = <int>[];

      for (int i = 0; i < renderCount; i++) {
        final measurement = await PerformanceHelper.measureAsync(
          () => _simulateBoardRenderPrep(board),
          label: 'Frame ${i + 1} render prep',
        );

        measurements.add(measurement.milliseconds);
      }

      // Calculate stats for all frames
      final stats = PerformanceStats.fromMeasurements(measurements);

      print('''
🎬 Frame Rendering Statistics ($renderCount frames):
   Min: ${stats.minMs}ms (${(1000 / stats.minMs).toStringAsFixed(1)} FPS)
   Max: ${stats.maxMs}ms (${(1000 / stats.maxMs).toStringAsFixed(1)} FPS)
   Avg: ${stats.averageMs.toStringAsFixed(2)}ms (${(1000 / stats.averageMs).toStringAsFixed(1)} FPS)
   Median: ${stats.medianMs}ms (${(1000 / stats.medianMs).toStringAsFixed(1)} FPS)
''');

      // At least 50% of frames should hit 60fps (16.67ms)
      final sixtyFpsFrames = measurements.where((m) => m <= 16).length;
      final sixtyFpsRatio = sixtyFpsFrames / renderCount;

      expect(
        sixtyFpsRatio,
        greaterThanOrEqualTo(0.5),
        reason: 'At least 50% of frames should hit 60fps',
      );

      // No frame should exceed 33ms (30fps minimum)
      expect(
        stats.maxMs,
        lessThanOrEqualTo(33),
        reason: 'No frame should exceed 30fps threshold',
      );
    });

    test('⚡ Concurrent validation and rendering doesn\'t block', () async {
      final board = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: true,
      );

      // Measure time for validation while rendering is happening
      final measurement = await PerformanceHelper.measureAsync(
        () async {
          // Simulate rendering
          final renderFuture = _simulateBoardRenderPrep(board);

          // Do validation concurrently
          service.validateMove(boardState: board, row: 2, col: 3);

          await renderFuture;
        },
        label: 'Concurrent validation + rendering',
      );

      PerformanceHelper.expectWithinThreshold(
        measurement.milliseconds,
        PerformanceThresholds.uiResponsiveness + 20, // Allow some overhead
        operationName: 'Concurrent operations',
      );
    });

    test('⚡ Sequential gameplay actions maintain responsiveness', () async {
      final board = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: true,
      );

      // Simulate 10 consecutive game actions
      const actionCount = 10;
      final actionTimes = <int>[];

      for (int i = 0; i < actionCount; i++) {
        final measurement = await PerformanceHelper.measureAsync(
          () async {
            // 1. Validate move
            service.validateMove(
              boardState: board,
              row: i % 9,
              col: (i + 1) % 9,
            );
            // 2. Update UI
            await _simulateMoveUIUpdate();
            // 3. Prepare next render
            await _simulateBoardRenderPrep(board);
          },
          label: 'Action $i complete cycle',
        );

        actionTimes.add(measurement.milliseconds);
      }

      // Check consistency (standard deviation shouldn't be too high)
      final stats = PerformanceStats.fromMeasurements(actionTimes);

      expect(
        stats.averageMs,
        lessThanOrEqualTo(PerformanceThresholds.uiResponsiveness.toDouble()),
        reason: 'Average action cycle should be responsive',
      );

      // Variance should be low (consistent performance)
      expect(
        stats.stdDevMs,
        lessThan(10), // Standard deviation shouldn't exceed 10ms
        reason: 'Action timing should be consistent',
      );

      print('''
🎮 Gameplay Action Statistics:
   Avg Response Time: ${stats.averageMs.toStringAsFixed(2)}ms
   Consistency (StdDev): ${stats.stdDevMs.toStringAsFixed(2)}ms
   Min: ${stats.minMs}ms | Max: ${stats.maxMs}ms
''');
    });

    test('⚡ First touch response is fast', () async {
      final board = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: true,
      );

      // Measure first interaction latency (critical for user perception)
      final firstTouchTime = await PerformanceHelper.measureAsync(
        () async {
          service.validateMove(boardState: board, row: 2, col: 3);
          await _simulateMoveUIUpdate();
        },
        label: 'First touch response',
      );

      PerformanceHelper.expectWithinThreshold(
        firstTouchTime.milliseconds,
        PerformanceThresholds.uiResponsiveness,
        operationName: 'First touch response',
      );
    });

    test('⚡ Rapid succession moves stay responsive', () async {
      final board = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: true,
      );

      // Simulate rapid tapping (stress test)
      const rapidMoves = 20;
      final rapidTimes = <int>[];

      for (int i = 0; i < rapidMoves; i++) {
        final start = DateTime.now();

        service.validateMove(
          boardState: board,
          row: i % 9,
          col: (i + 1) % 9,
        );

        final elapsed = DateTime.now().difference(start).inMilliseconds;
        rapidTimes.add(elapsed);
      }

      final stats = PerformanceStats.fromMeasurements(rapidTimes);

      // Even under stress, moves should be fast
      expect(
        stats.maxMs,
        lessThanOrEqualTo(5),
        reason: 'Even rapid moves should complete in <5ms',
      );

      print('''
🚀 Rapid Move Stress Test ($rapidMoves moves):
   Max Time: ${stats.maxMs}ms
   Avg Time: ${stats.averageMs.toStringAsFixed(3)}ms
   No timeout or lag detected ✓
''');
    });

    test('⚡ Board state updates don\'t lag rendering', () async {
      final board = BoardState(
        boardSize: 19,
        stones: List.generate(19, (r) => List.filled(19, -1)),
        isPlayerBlack: true,
      );

      // Simulate rendering 10 frames while updating board state
      const frameCount = 10;
      const updatesPerFrame = 2;
      final frameTimes = <int>[];

      for (int frame = 0; frame < frameCount; frame++) {
        final frameStart = DateTime.now();

        // Perform board updates
        for (int update = 0; update < updatesPerFrame; update++) {
          service.validateMove(
            boardState: board,
            row: (frame * updatesPerFrame + update) % 19,
            col: ((frame * updatesPerFrame + update) + 1) % 19,
          );
        }

        // Render frame
        await _simulateBoardRenderPrep(board);

        final frameTime = DateTime.now().difference(frameStart).inMilliseconds;
        frameTimes.add(frameTime);
      }

      // All frames should render quickly
      for (final frameTime in frameTimes) {
        expect(
          frameTime,
          lessThanOrEqualTo(50), // Should be well under 50ms per frame
          reason: 'Frame rendering with updates should stay fast',
        );
      }
    });

    test('🔄 Long game session responsiveness', () async {
      final board = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: true,
      );

      // Simulate 100 moves in a game (40-50 is typical for 9x9)
      const moveCount = 100;
      final moveProfile = PerformanceProfile('Long Game Session (100 moves)');

      var totalTime = 0;

      for (int i = 0; i < moveCount; i++) {
        final measurement = await PerformanceHelper.measureAsync(
          () async {
            service.validateMove(
              boardState: board,
              row: i % 9,
              col: (i + 1) % 9,
            );
            await _simulateMoveUIUpdate();
          },
        );

        totalTime += measurement.milliseconds;

        // Log milestones
        if (i == 0) {
          moveProfile.record('Move 1', measurement.milliseconds);
        } else if (i == moveCount ~/ 4) {
          moveProfile.record('Move ${i + 1} (1/4)', measurement.milliseconds);
        } else if (i == moveCount ~/ 2) {
          moveProfile.record('Move ${i + 1} (1/2)', measurement.milliseconds);
        } else if (i == (3 * moveCount) ~/ 4) {
          moveProfile.record('Move ${i + 1} (3/4)', measurement.milliseconds);
        } else if (i == moveCount - 1) {
          moveProfile.record('Move $moveCount (end)', measurement.milliseconds);
        }
      }

      moveProfile.printReport();

      final averageMs = totalTime / moveCount;
      expect(
        averageMs,
        lessThanOrEqualTo(PerformanceThresholds.uiResponsiveness.toDouble()),
        reason: 'Long game session should maintain responsiveness',
      );
    });

    test('💾 Memory pressure during gameplay', () async {
      PerformanceHelper.logMemorySample('Game start');

      final board = BoardState(
        boardSize: 19,
        stones: List.generate(19, (r) => List.filled(19, -1)),
        isPlayerBlack: true,
      );

      // Simulate heavy gameplay with many moves
      for (int i = 0; i < 200; i++) {
        service.validateMove(
          boardState: board,
          row: i % 19,
          col: (i + 1) % 19,
        );

        if (i % 50 == 0) {
          PerformanceHelper.logMemorySample('After ${i + 1} moves');
        }
      }

      PerformanceHelper.logMemorySample('Game end');
    });
  });
}
