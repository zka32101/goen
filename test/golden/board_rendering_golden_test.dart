import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/go_engine_service.dart';
import 'package:goen/views/widgets/go_grid_painter.dart';

/// Golden image tests for board rendering
///
/// Run with: flutter test --update-goldens to generate/update golden images
void main() {
  group('Board Rendering Golden Tests', () {
    /// Helper to create a test widget for board rendering
    Widget _createBoardTestWidget(
      BoardState boardState, {
      double size = 300,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: size,
              height: size,
              child: CustomPaint(
                painter: GoGridPainter(
                  boardState: boardState,
                  selectedRow: -1,
                  selectedCol: -1,
                  lastMoveRow: -1,
                  lastMoveCol: -1,
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('🎨 Golden: Empty 9×9 board', (WidgetTester tester) async {
      final boardState = BoardState(
        boardSize: 9,
        stones: List.generate(9, (r) => List.filled(9, -1)),
        isPlayerBlack: true,
      );

      await tester.pumpWidget(_createBoardTestWidget(boardState));

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_empty_9x9.png'),
      );
    });

    testWidgets('🎨 Golden: Empty 13×13 board', (WidgetTester tester) async {
      final boardState = BoardState(
        boardSize: 13,
        stones: List.generate(13, (r) => List.filled(13, -1)),
        isPlayerBlack: true,
      );

      await tester.pumpWidget(_createBoardTestWidget(boardState));

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_empty_13x13.png'),
      );
    });

    testWidgets('🎨 Golden: Empty 19×19 board', (WidgetTester tester) async {
      final boardState = BoardState(
        boardSize: 19,
        stones: List.generate(19, (r) => List.filled(19, -1)),
        isPlayerBlack: true,
      );

      await tester.pumpWidget(_createBoardTestWidget(boardState));

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_empty_19x19.png'),
      );
    });

    testWidgets('🎨 Golden: Opening position (corner stone)', (WidgetTester tester) async {
      final stones = List.generate(9, (r) => List.filled(9, -1));
      stones[2][2] = 0; // Black stone at 3-3 point

      final boardState = BoardState(
        boardSize: 9,
        stones: stones,
        isPlayerBlack: false,
      );

      await tester.pumpWidget(_createBoardTestWidget(boardState));

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_opening_position.png'),
      );
    });

    testWidgets('🎨 Golden: Early game (mixed stones)', (WidgetTester tester) async {
      final stones = List.generate(9, (r) => List.filled(9, -1));

      // Add some black and white stones
      stones[2][2] = 0; // Black
      stones[6][6] = 1; // White
      stones[2][6] = 1; // White
      stones[6][2] = 0; // Black
      stones[4][4] = 0; // Black center

      final boardState = BoardState(
        boardSize: 9,
        stones: stones,
        isPlayerBlack: true,
      );

      await tester.pumpWidget(_createBoardTestWidget(boardState));

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_early_game.png'),
      );
    });

    testWidgets('🎨 Golden: Mid-game (complex position)', (WidgetTester tester) async {
      final stones = List.generate(9, (r) => List.filled(9, -1));

      // Simulate a more complex mid-game position
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

      await tester.pumpWidget(_createBoardTestWidget(boardState));

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_mid_game.png'),
      );
    });

    testWidgets('🎨 Golden: End game (many stones)', (WidgetTester tester) async {
      final stones = List.generate(9, (r) => List.filled(9, -1));

      // Simulate near-full board
      int count = 0;
      for (int i = 0; i < 9; i++) {
        for (int j = 0; j < 9; j++) {
          if (count < 70) {
            // Leave a few empty points
            stones[i][j] = count % 2;
            count++;
          }
        }
      }

      final boardState = BoardState(
        boardSize: 9,
        stones: stones,
        isPlayerBlack: false,
      );

      await tester.pumpWidget(_createBoardTestWidget(boardState));

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_end_game.png'),
      );
    });

    testWidgets('🎨 Golden: Professional game position', (WidgetTester tester) async {
      // Simulate a real professional game position
      final stones = List.generate(19, (r) => List.filled(19, -1));

      // Black (standard opening for 19x19)
      stones[3][3] = 0;
      stones[3][15] = 0;
      stones[15][3] = 0;
      stones[15][15] = 0;

      // White responses and follow-ups
      stones[16][16] = 1;
      stones[16][2] = 1;
      stones[2][16] = 1;
      stones[2][2] = 1;

      final boardState = BoardState(
        boardSize: 19,
        stones: stones,
        isPlayerBlack: true,
      );

      await tester.pumpWidget(_createBoardTestWidget(boardState, size: 600));

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_professional_position.png'),
      );
    });

    testWidgets('🎨 Golden: Dark theme stone rendering', (WidgetTester tester) async {
      final stones = List.generate(9, (r) => List.filled(9, -1));
      stones[1][1] = 0; // Black
      stones[7][7] = 1; // White
      stones[4][4] = 0; // Black center

      final boardState = BoardState(
        boardSize: 9,
        stones: stones,
        isPlayerBlack: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            backgroundColor: Colors.black87,
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(
                  painter: GoGridPainter(
                    boardState: boardState,
                    selectedRow: -1,
                    selectedCol: -1,
                    lastMoveRow: -1,
                    lastMoveCol: -1,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_dark_theme.png'),
      );
    });

    testWidgets('🎨 Golden: Selected position highlight', (WidgetTester tester) async {
      final stones = List.generate(9, (r) => List.filled(9, -1));
      stones[2][2] = 0;
      stones[6][6] = 1;

      final boardState = BoardState(
        boardSize: 9,
        stones: stones,
        isPlayerBlack: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(
                  painter: GoGridPainter(
                    boardState: boardState,
                    selectedRow: 4, // Highlight center position
                    selectedCol: 4,
                    lastMoveRow: -1,
                    lastMoveCol: -1,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_selected_position.png'),
      );
    });

    testWidgets('🎨 Golden: Last move indicator', (WidgetTester tester) async {
      final stones = List.generate(9, (r) => List.filled(9, -1));
      stones[2][2] = 0;
      stones[6][6] = 1;
      stones[4][4] = 0; // Most recent move

      final boardState = BoardState(
        boardSize: 9,
        stones: stones,
        isPlayerBlack: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 300,
                height: 300,
                child: CustomPaint(
                  painter: GoGridPainter(
                    boardState: boardState,
                    selectedRow: -1,
                    selectedCol: -1,
                    lastMoveRow: 4, // Indicate last move
                    lastMoveCol: 4,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_last_move_indicator.png'),
      );
    });

    testWidgets('🎨 Golden: Size comparison (7×7 vs 19×19)', (WidgetTester tester) async {
      // 7x7
      final stones7x7 = List.generate(7, (r) => List.filled(7, -1));
      stones7x7[3][3] = 0;

      final boardState7x7 = BoardState(
        boardSize: 7,
        stones: stones7x7,
        isPlayerBlack: true,
      );

      await tester.pumpWidget(_createBoardTestWidget(boardState7x7, size: 200));

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_7x7_size.png'),
      );

      // Reset for 19x19
      await tester.pumpWidget(SizedBox.shrink()); // Clear widget tree

      final stones19x19 = List.generate(19, (r) => List.filled(19, -1));
      stones19x19[9][9] = 0;

      final boardState19x19 = BoardState(
        boardSize: 19,
        stones: stones19x19,
        isPlayerBlack: true,
      );

      await tester.pumpWidget(_createBoardTestWidget(boardState19x19, size: 500));

      await expectLater(
        find.byType(CustomPaint),
        matchesGoldenFile('goldens/board_19x19_size.png'),
      );
    });

    testWidgets('🎨 Golden: Coordinate rendering', (WidgetTester tester) async {
      // This test verifies that coordinate labels are visible
      final stones = List.generate(9, (r) => List.filled(9, -1));

      final boardState = BoardState(
        boardSize: 9,
        stones: stones,
        isPlayerBlack: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top coordinate labels
                  Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        9,
                        (i) => SizedBox(
                          width: 33.3,
                          child: Center(child: Text(String.fromCharCode(97 + i))),
                        ),
                      ),
                    ),
                  ),
                  // Board with side coordinates
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Side labels
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          9,
                          (i) => SizedBox(
                            height: 33.3,
                            width: 30,
                            child: Center(child: Text('${9 - i}')),
                          ),
                        ),
                      ),
                      // Board
                      SizedBox(
                        width: 300,
                        height: 300,
                        child: CustomPaint(
                          painter: GoGridPainter(
                            boardState: boardState,
                            selectedRow: -1,
                            selectedCol: -1,
                            lastMoveRow: -1,
                            lastMoveCol: -1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/board_with_coordinates.png'),
      );
    });
  });
}
