import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/go_engine_service.dart';
import 'performance_utils.dart';

void main() {
  group('Game Logic Performance Tests', () {
    late GoEngineService service;

    setUp(() {
      service = GoEngineService();
    });

    /// Create an empty board
    List<List<int>> _createEmptyBoard(int size) {
      return List<List<int>>.generate(
        size,
        (row) => List<int>.generate(size, (col) => -1),
      );
    }

    /// Apply a move to the board
    List<List<int>> _applyMove(
      List<List<int>> board,
      int row,
      int col,
      int color,
    ) {
      final newBoard = board.map((row) => [...row]).toList();
      newBoard[row][col] = color;
      return newBoard;
    }

    /// Generate a sequence of moves
    List<({int row, int col, int color})> _generateMoveSequence(
      int count, {
      int boardSize = 9,
    }) {
      final moves = <({int row, int col, int color})>[];
      int colorIndex = 0;

      for (int i = 0; i < count; i++) {
        final row = (i * 2) % boardSize;
        final col = (i * 3) % boardSize;
        if (row < boardSize && col < boardSize) {
          moves.add((row: row, col: col, color: colorIndex % 2));
          colorIndex++;
        }
      }

      return moves;
    }

    test('⚡ Create empty board for various sizes', () {
      final sizes = [7, 9, 13, 19];

      for (final size in sizes) {
        final measurement = PerformanceHelper.measureSync(
          () => _createEmptyBoard(size),
          label: 'Create empty $size×$size board',
        );

        expect(
          measurement.milliseconds,
          lessThanOrEqualTo(10),
          reason: 'Board creation exceeded threshold',
        );
      }
    });

    test('⚡ Single move placement is extremely fast', () {
      final board = _createEmptyBoard(9);

      const iterations = 1000;
      var totalTime = 0;

      for (int i = 0; i < iterations; i++) {
        final measurement = PerformanceHelper.measureSync(
          () => _applyMove(board, 2, 3, 0),
        );
        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / iterations;
      expect(
        averageMs,
        lessThan(0.5),
        reason: 'Move placement should be sub-millisecond',
      );
    });

    test('⚡ Sequential move placement maintains performance', () async {
      final board = _createEmptyBoard(9);

      final stats = await PerformanceHelper.measureMultiple(
        () => Future.value(_applyMove(board, 2, 3, 0)),
        iterations: 500,
        label: 'Sequential move placement (500 iterations)',
      );

      expect(stats.averageWithinThreshold(1), true);
      expect(stats.maxMs, lessThanOrEqualTo(5));
    });

    test('⚡ Generate game move sequence is efficient', () {
      const moveCounts = [10, 50, 100, 200];

      for (final moveCount in moveCounts) {
        final measurement = PerformanceHelper.measureSync(
          () => _generateMoveSequence(moveCount),
          label: 'Generate $moveCount moves',
        );

        expect(
          measurement.milliseconds,
          lessThanOrEqualTo(PerformanceThresholds.gameLogicOperation),
          reason: 'Move sequence generation for $moveCount moves exceeded threshold',
        );
      }
    });

    test('⚡ Validate moves in sequence on board', () {
      final board = BoardState(
        boardSize: 9,
        stones: _createEmptyBoard(9),
        isPlayerBlack: true,
      );

      const moveCount = 50;
      final moves = _generateMoveSequence(moveCount);

      var totalTime = 0;
      var validCount = 0;

      for (final move in moves) {
        final measurement = PerformanceHelper.measureSync(
          () => service.validateMove(
            boardState: board,
            row: move.row,
            col: move.col,
          ),
        );

        totalTime += measurement.milliseconds;
        if (measurement.result) validCount++;
      }

      final averageMs = totalTime / moves.length;
      expect(
        averageMs,
        lessThan(1.0),
        reason: 'Average move validation should be sub-millisecond',
      );
      expect(validCount, greaterThan(0));
    });

    test('🔍 Detect capture sequences', () {
      // Simulate a capture sequence
      var board = _createEmptyBoard(9);

      // Create a surrounded white stone (will be captured)
      board = _applyMove(board, 4, 4, 1); // White stone at center
      board = _applyMove(board, 3, 4, 0); // Black above
      board = _applyMove(board, 5, 4, 0); // Black below
      board = _applyMove(board, 4, 3, 0); // Black left
      board = _applyMove(board, 4, 5, 0); // Black right

      final boardState = BoardState(
        boardSize: 9,
        stones: board,
        isPlayerBlack: true,
      );

      const iterations = 100;
      var totalTime = 0;

      for (int i = 0; i < iterations; i++) {
        // Validate the final capturing move
        final measurement = PerformanceHelper.measureSync(
          () => service.validateMove(
            boardState: boardState,
            row: 4,
            col: 4,
          ),
        );

        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / iterations;
      expect(averageMs, lessThan(1.0));
    });

    test('🔍 Territory detection performance (empty regions)', () {
      var board = _createEmptyBoard(19);

      // Add some stones to create regions
      for (int i = 0; i < 10; i++) {
        board = _applyMove(board, i, 0, 0);
        board = _applyMove(board, i, 18, 1);
      }

      final boardState = BoardState(
        boardSize: 19,
        stones: board,
        isPlayerBlack: true,
      );

      // Check empty territory locations
      const iterations = 200;
      var totalTime = 0;

      for (int i = 0; i < iterations; i++) {
        final measurement = PerformanceHelper.measureSync(
          () => service.validateMove(
            boardState: boardState,
            row: 9,
            col: 9,
          ),
        );

        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / iterations;
      expect(averageMs, lessThan(1.0));
    });

    test('🔄 Complex game state progression', () {
      final sizes = [7, 9, 13];

      for (final size in sizes) {
        var board = _createEmptyBoard(size);
        final moves = _generateMoveSequence(size * size ~/ 2, boardSize: size);

        final measurement = PerformanceHelper.measureSync(
          () {
            for (final move in moves) {
              board = _applyMove(board, move.row, move.col, move.color);
            }
            return board;
          },
          label: 'Play ${moves.length} moves on $size×$size board',
        );

        final expectedThreshold = (moves.length * 0.1).toInt() + 10;
        expect(
          measurement.milliseconds,
          lessThanOrEqualTo(expectedThreshold),
          reason: 'Complex move sequence exceeded expected threshold',
        );
      }
    });

    test('🔄 Board cloning efficiency', () {
      final original = _createEmptyBoard(19);
      for (int i = 0; i < 100; i++) {
        original[i ~/ 19][i % 19] = i % 2;
      }

      const iterations = 1000;
      var totalTime = 0;

      for (int i = 0; i < iterations; i++) {
        final measurement = PerformanceHelper.measureSync(
          () => original.map((row) => [...row]).toList(),
        );

        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / iterations;
      expect(
        averageMs,
        lessThan(0.5),
        reason: 'Board cloning should be very fast',
      );
    });

    test('📊 Move validation with edge cases', () {
      final board = BoardState(
        boardSize: 9,
        stones: _createEmptyBoard(9),
        isPlayerBlack: true,
      );

      // Test all edge positions
      final edgePositions = [
        (0, 0), // Top-left
        (0, 8), // Top-right
        (8, 0), // Bottom-left
        (8, 8), // Bottom-right
        (4, 0), // Top center
        (0, 4), // Left center
        (4, 8), // Right center
        (8, 4), // Bottom center
      ];

      const iterations = 10;
      var totalTime = 0;

      for (int i = 0; i < iterations; i++) {
        for (final pos in edgePositions) {
          final measurement = PerformanceHelper.measureSync(
            () => service.validateMove(
              boardState: board,
              row: pos.$1,
              col: pos.$2,
            ),
          );

          totalTime += measurement.milliseconds;
        }
      }

      final totalPositions = edgePositions.length * iterations;
      final averageMs = totalTime / totalPositions;

      expect(averageMs, lessThan(0.5));
    });

    test('📊 Move validation with occupied positions', () {
      var board = _createEmptyBoard(9);

      // Place stones at various positions
      for (int i = 0; i < 5; i++) {
        board = _applyMove(board, i * 2, i * 2, i % 2);
      }

      final boardState = BoardState(
        boardSize: 9,
        stones: board,
        isPlayerBlack: true,
      );

      // Test both valid and invalid moves
      const iterations = 500;
      var totalTime = 0;

      for (int i = 0; i < iterations; i++) {
        final row = (i % 9);
        final col = ((i + 1) % 9);

        final measurement = PerformanceHelper.measureSync(
          () => service.validateMove(
            boardState: boardState,
            row: row,
            col: col,
          ),
        );

        totalTime += measurement.milliseconds;
      }

      final averageMs = totalTime / iterations;
      expect(averageMs, lessThan(0.3));
    });

    test('💾 Memory efficiency of board operations', () {
      final profile = PerformanceProfile('Board Operations Memory Profile');

      // Create boards of increasing size
      for (final size in [7, 9, 13, 19]) {
        PerformanceHelper.logMemorySample('Before creating $size×$size board');

        final measurement = PerformanceHelper.measureSync(
          () => _createEmptyBoard(size),
        );

        profile.record('Create $size×$size board', measurement.milliseconds);

        PerformanceHelper.logMemorySample('After creating $size×$size board');
      }

      profile.printReport();
    });

    test('⚙️ Performance profile of full game simulation', () {
      final profile = PerformanceProfile('Full Game Simulation');

      var board = _createEmptyBoard(9);
      final boardState = BoardState(
        boardSize: 9,
        stones: board,
        isPlayerBlack: true,
      );

      final moves = _generateMoveSequence(40, boardSize: 9);

      PerformanceHelper.logMemorySample('Game start');

      for (final move in moves) {
        final measurement = PerformanceHelper.measureSync(
          () => service.validateMove(
            boardState: boardState,
            row: move.row,
            col: move.col,
          ),
        );

        profile.record('Validate move ${moves.indexOf(move) + 1}', measurement.milliseconds);
      }

      PerformanceHelper.logMemorySample('Game end');

      profile.printReport();
    });
  });
}
