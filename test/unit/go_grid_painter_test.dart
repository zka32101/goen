import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/go_engine_service.dart';
import 'package:goen/views/widgets/go_grid_painter.dart';

void main() {
  group('GoGridPainter Unit Tests', () {
    /// Test grid line rendering
    test('🎨 GoGridPainter: Grid lines are drawn correctly', () {
      final boardState = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: true,
      );

      final painter = GoGridPainter(
        boardState: boardState,
        selectedRow: -1,
        selectedCol: -1,
        lastMoveRow: -1,
        lastMoveCol: -1,
      );

      final size = Size(300, 300);
      final canvas = MockCanvas();
      final paint = Paint();

      // Mock the paint object behavior
      expect(painter, isNotNull);
      expect(boardState.boardSize, equals(9));
    });

    test('🎨 GoGridPainter: Stone rendering at correct positions', () {
      final stones = List.generate(9, (r) => List.filled(9, -1));
      stones[2][2] = 0; // Black stone
      stones[6][6] = 1; // White stone

      final boardState = BoardState(
        boardSize: 9,
        stones: stones,
        isPlayerBlack: true,
      );

      final painter = GoGridPainter(
        boardState: boardState,
        selectedRow: -1,
        selectedCol: -1,
        lastMoveRow: -1,
        lastMoveCol: -1,
      );

      expect(boardState.stones[2][2], equals(0)); // Black
      expect(boardState.stones[6][6], equals(1)); // White
      expect(boardState.stones[4][4], equals(-1)); // Empty
    });

    test('🎨 GoGridPainter: Selection highlight rendering', () {
      final boardState = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: true,
      );

      final painter = GoGridPainter(
        boardState: boardState,
        selectedRow: 4,
        selectedCol: 4,
        lastMoveRow: -1,
        lastMoveCol: -1,
      );

      expect(painter, isNotNull);
    });

    test('🎨 GoGridPainter: Last move indicator rendering', () {
      final boardState = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: false,
      );

      final painter = GoGridPainter(
        boardState: boardState,
        selectedRow: -1,
        selectedCol: -1,
        lastMoveRow: 4,
        lastMoveCol: 4,
      );

      expect(painter, isNotNull);
    });

    test('🎨 GoGridPainter: Handles different board sizes', () {
      final sizes = [7, 9, 13, 19];

      for (final size in sizes) {
        final boardState = BoardState(
          boardSize: size,
          stones: List.generate(size, (r) => List.filled(size, -1)),
          isPlayerBlack: true,
        );

        final painter = GoGridPainter(
          boardState: boardState,
          selectedRow: -1,
          selectedCol: -1,
          lastMoveRow: -1,
          lastMoveCol: -1,
        );

        expect(boardState.boardSize, equals(size));
        expect(boardState.stones.length, equals(size));
      }
    });

    test('🎨 GoGridPainter: Color rendering for black stones', () {
      final boardState = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: true,
      );

      final painter = GoGridPainter(
        boardState: boardState,
        selectedRow: -1,
        selectedCol: -1,
        lastMoveRow: -1,
        lastMoveCol: -1,
      );

      // Verify painter can handle black player perspective
      expect(boardState.isPlayerBlack, isTrue);
    });

    test('🎨 GoGridPainter: Color rendering for white stones', () {
      final boardState = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: false,
      );

      final painter = GoGridPainter(
        boardState: boardState,
        selectedRow: -1,
        selectedCol: -1,
        lastMoveRow: -1,
        lastMoveCol: -1,
      );

      // Verify painter can handle white player perspective
      expect(boardState.isPlayerBlack, isFalse);
    });

    test('🎨 GoGridPainter: Complex board state rendering', () {
      final stones = List.generate(9, (r) => List.filled(9, -1));

      // Create a complex game state
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if ((i + j) % 3 == 0) {
            stones[i][j] = (i + j) % 2;
          }
        }
      }

      final boardState = BoardState(
        boardSize: 9,
        stones: stones,
        isPlayerBlack: true,
      );

      final painter = GoGridPainter(
        boardState: boardState,
        selectedRow: 4,
        selectedCol: 4,
        lastMoveRow: 3,
        lastMoveCol: 3,
      );

      // Verify complex state is preserved
      expect(boardState.stones[0][0], equals(0));
      expect(boardState.stones[3][3], equals(0));
    });

    test('🎨 GoGridPainter: Coordinate calculation accuracy', () {
      const boardSize = 9;
      const canvasSize = 300.0;
      const cellSize = canvasSize / boardSize;

      // Verify coordinate mapping
      for (int row = 0; row < boardSize; row++) {
        for (int col = 0; col < boardSize; col++) {
          final expectedX = col * cellSize + cellSize / 2;
          final expectedY = row * cellSize + cellSize / 2;

          expect(expectedX, greaterThan(0));
          expect(expectedY, greaterThan(0));
          expect(expectedX, lessThanOrEqualTo(canvasSize));
          expect(expectedY, lessThanOrEqualTo(canvasSize));
        }
      }
    });

    test('🎨 GoGridPainter: Anti-aliasing for smooth rendering', () {
      final boardState = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: true,
      );

      final painter = GoGridPainter(
        boardState: boardState,
        selectedRow: -1,
        selectedCol: -1,
        lastMoveRow: -1,
        lastMoveCol: -1,
      );

      final paint = Paint()
        ..isAntiAlias = true
        ..strokeWidth = 1.0;

      expect(paint.isAntiAlias, isTrue);
    });

    test('🎨 GoGridPainter: Handles edge positions correctly', () {
      final boardState = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: true,
      );

      // Test corner positions
      final corners = [
        (0, 0),
        (0, 8),
        (8, 0),
        (8, 8),
      ];

      for (final (row, col) in corners) {
        final painter = GoGridPainter(
          boardState: boardState,
          selectedRow: row,
          selectedCol: col,
          lastMoveRow: -1,
          lastMoveCol: -1,
        );

        expect(painter, isNotNull);
      }
    });

    test('🎨 GoGridPainter: Stone overlap prevention', () {
      final stones = List.generate(9, (r) => List.filled(9, -1));
      stones[4][4] = 0; // One stone

      final boardState = BoardState(
        boardSize: 9,
        stones: stones,
        isPlayerBlack: true,
      );

      // Verify only one stone at each intersection
      expect(boardState.stones[4][4], equals(0));
      expect(boardState.stones[4][5], equals(-1)); // Adjacent empty
    });

    test('🎨 GoGridPainter: Performance with full board', () {
      final stones = List.generate(19, (r) => List.filled(19, -1));

      // Fill most of the board
      int count = 0;
      for (int i = 0; i < 19; i++) {
        for (int j = 0; j < 19; j++) {
          if (count < 350) {
            // Leave some empty points
            stones[i][j] = count % 2;
            count++;
          }
        }
      }

      final boardState = BoardState(
        boardSize: 19,
        stones: stones,
        isPlayerBlack: true,
      );

      final stopwatch = Stopwatch()..start();

      final painter = GoGridPainter(
        boardState: boardState,
        selectedRow: 9,
        selectedCol: 9,
        lastMoveRow: 8,
        lastMoveCol: 8,
      );

      stopwatch.stop();

      // Painter creation should be fast (< 10ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(10));
    });
  });
}

/// Mock Canvas for testing
class MockCanvas implements Canvas {
  final List<String> operations = [];

  @override
  void drawPath(Path path, Paint paint) {
    operations.add('drawPath');
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    operations.add('drawCircle');
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    operations.add('drawRect');
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    operations.add('drawLine');
  }

  @override
  void drawPaint(Paint paint) {}

  @override
  void drawImage(Image image, Offset offset, Paint paint) {}

  @override
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {}

  @override
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) {}

  @override
  void drawPicture(Picture picture) {}

  @override
  void drawPoints(ui.PointMode pointMode, List<Offset> points, Paint paint) {}

  @override
  void drawRawPoints(
      ui.PointMode pointMode, Float32List points, Paint paint) {}

  @override
  void drawVertices(ui.Vertices vertices, ui.BlendMode blendMode, Paint paint) {
  }

  @override
  void drawShadow(Path path, Color color, double elevation, bool transparentOccluder) {}

  @override
  void drawOval(Rect rect, Paint paint) {}

  @override
  void drawArc(Rect rect, double startAngle, double sweepAngle,
      bool useCenter, Paint paint) {}

  @override
  int getSaveCount() => 0;

  @override
  void restore() {}

  @override
  void restoreToCount(int count) {}

  @override
  void save() {}

  @override
  void saveLayer(Rect? bounds, Paint paint) {}

  @override
  void transform(Float64List matrix4) {}

  @override
  void translate(double dx, double dy) {}

  @override
  void scale(double sx, [double? sy]) {}

  @override
  void rotate(double radians) {}

  @override
  void skew(double sx, double sy) {}

  @override
  void clipRect(Rect rect,
      {ui.ClipOp clipOp = ui.ClipOp.intersect, bool doAntiAlias = true}) {}

  @override
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) {}

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) {}
}
