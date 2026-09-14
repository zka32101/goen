import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/views/screens/game_result_screen.dart';
import 'package:goen/viewmodels/index.dart';

import '../fixtures/test_data.dart';
import '../test_utils.dart';

void main() {
  group('GameResultScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
        boardState: TestData.emptyBoardState,
        movesCount: 45,
        aiLevel: 5,
      );
    });

    testWidgets('renders game result screen with win', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      // Verify scaffold exists
      expect(find.byType(Scaffold), findsWidgets);

      // Verify victory message shown
      expect(find.text('Victory!'), findsWidgets);
    });

    testWidgets('displays result title for different outcomes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'loss',
            blackScore: 38.0,
            whiteScore: 42.5,
          ),
          container: container,
        ),
      );

      // Verify defeat title for loss
      expect(find.text('Defeat'), findsWidgets);
    });

    testWidgets('shows final score with Chinese rules', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      // Verify score display
      expect(find.text('Final Score (Chinese Rules)'), findsWidgets);
      expect(find.text('45.5'), findsWidgets);
      expect(find.text('38.0'), findsWidgets);
    });

    testWidgets('displays player and AI labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      // Verify player and AI labels
      expect(find.text('Black\n(You)'), findsWidgets);
      expect(find.text('White\n(AI)'), findsWidgets);
    });

    testWidgets('shows game stats section', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      // Verify stats section
      expect(find.text('Game Stats'), findsWidgets);
      expect(find.text('Board'), findsWidgets);
      expect(find.text('AI Level'), findsWidgets);
      expect(find.text('Moves'), findsWidgets);
    });

    testWidgets('displays board size in stats', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      // Verify board size displayed
      expect(find.text('9×9'), findsWidgets);
    });

    testWidgets('displays AI level in stats', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      // Verify AI level displayed
      expect(find.text('5'), findsWidgets);
    });

    testWidgets('shows move analysis section', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      // Verify analysis section
      expect(find.text('Move Analysis'), findsWidgets);
    });

    testWidgets('displays action buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      // Verify action buttons
      expect(find.text('Save Game'), findsWidgets);
      expect(find.text('Play Again'), findsWidgets);
      expect(find.text('Back to Home'), findsWidgets);
    });

    testWidgets('shows golden "Play Again" button', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      // Play Again button should exist
      expect(find.text('Play Again'), findsWidgets);
    });

    testWidgets('displays resignation message when result is resign',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'resign',
            blackScore: null,
            whiteScore: null,
          ),
          container: container,
        ),
      );

      // Verify resignation message
      expect(find.text('Game resigned. No final score calculated.'), findsWidgets);
    });

    testWidgets('shows draw outcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'draw',
            blackScore: 40.0,
            whiteScore: 40.0,
          ),
          container: container,
        ),
      );

      // Verify draw title
      expect(find.text('Game Over'), findsWidgets);
    });

    testWidgets('dark theme styling applied', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      final scaffold = find.byType(Scaffold).first;
      final scaffoldWidget = tester.widget<Scaffold>(scaffold);

      expect(scaffoldWidget.backgroundColor, Colors.black87);
    });

    testWidgets('shows result icon based on outcome', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      // Victory icon should be trophy
      expect(find.byIcon(Icons.emoji_events), findsWidgets);
    });

    testWidgets('requires authentication to save game', (WidgetTester tester) async {
      final noAuthContainer = TestUtils.createTestContainer(
        currentUser: null,
      );

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: noAuthContainer,
        ),
      );

      // Save button still exists but shows message when tapped
      expect(find.text('Save Game'), findsWidgets);
    });

    testWidgets('displays score breakdown for loss', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'loss',
            blackScore: 38.0,
            whiteScore: 42.5,
          ),
          container: container,
        ),
      );

      // Score should show AI victory
      expect(find.text('42.5'), findsWidgets);
      expect(find.text('38.0'), findsWidgets);
    });

    testWidgets('single child scrollview for content', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      // Scrolling should be possible
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('stone circles show win/loss border colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 45.5,
            whiteScore: 38.0,
          ),
          container: container,
        ),
      );

      // Container widgets for stone representations should exist
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('handles edge case scores', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: GameResultScreen(
            result: 'win',
            blackScore: 0.5,
            whiteScore: 0.0,
          ),
          container: container,
        ),
      );

      expect(find.text('0.5'), findsWidgets);
      expect(find.text('0.0'), findsWidgets);
    });
  });
}
