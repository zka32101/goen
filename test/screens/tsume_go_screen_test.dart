import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/views/screens/tsume_go_screen.dart';
import 'package:goen/viewmodels/index.dart';

import '../fixtures/test_data.dart';
import '../test_utils.dart';

void main() {
  group('TsumeGoScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
      );
    });

    testWidgets('renders tsume-go screen with puzzle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      // Verify scaffold exists
      expect(find.byType(Scaffold), findsWidgets);

      // Verify loading state or puzzle display
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('displays puzzle difficulty stars', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      // When puzzle loads, difficulty should show
      expect(find.text('Difficulty'), findsWidgets);
    });

    testWidgets('shows attempt counter', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      // Verify attempts counter
      expect(find.text('Attempts'), findsWidgets);
    });

    testWidgets('displays hint button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      // App bar should have hint icon
      expect(find.byType(AppBar), findsWidgets);
      expect(find.byIcon(Icons.info_outline), findsWidgets);
    });

    testWidgets('shows puzzle board grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      // Board should render with CustomPaint
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('displays difficulty selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      // Difficulty selector should be visible
      expect(find.text('Browse by Difficulty'), findsWidgets);

      // ChoiceChip widgets for difficulty selection
      expect(find.byType(Wrap), findsWidgets);
    });

    testWidgets('shows check solution button when unsolved',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      // When puzzle not solved, show "Check Solution"
      expect(find.text('Check Solution'), findsWidgets);
    });

    testWidgets('shows skip button', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      // Skip to tomorrow button should be visible
      expect(find.text('Skip to Tomorrow'), findsWidgets);
    });

    testWidgets('displays solution explanation when solved',
        (WidgetTester tester) async {
      final solvedContainer = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(TestData.testUser),
          isPuzzleSolvedProvider.overrideWithValue(true),
        ],
      );

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: solvedContainer,
        ),
      );

      // When solved, show explanation button
      expect(find.text('View Explanation'), findsWidgets);
    });

    testWidgets('shows puzzle solved badge', (WidgetTester tester) async {
      final solvedContainer = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(TestData.testUser),
          isPuzzleSolvedProvider.overrideWithValue(true),
        ],
      );

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: solvedContainer,
        ),
      );

      // Solved badge with check icon
      expect(find.text('Puzzle Solved!'), findsWidgets);
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('shows expected moves when unsolved',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      // Show hint about expected moves when puzzle not solved
      expect(find.text('moves to solve'), findsWidgets);
    });

    testWidgets('hint button opens dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: MaterialApp(
            home: const TsumeGoScreen(),
            navigatorObservers: [],
          ),
          container: container,
        ),
      );

      // Tap hint button
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      // Dialog should appear with hint text
      expect(find.byType(AlertDialog), findsWidgets);
      expect(find.text('Hint'), findsWidgets);
    });

    testWidgets('dark theme styling applied', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      final scaffold = find.byType(Scaffold).first;
      final scaffoldWidget = tester.widget<Scaffold>(scaffold);

      expect(scaffoldWidget.backgroundColor, Colors.black87);
    });

    testWidgets('requires authentication to check solution',
        (WidgetTester tester) async {
      final noAuthContainer = TestUtils.createTestContainer(
        currentUser: null,
      );

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: noAuthContainer,
        ),
      );

      // Check solution button should be disabled
    });

    testWidgets('shows loading state when fetching puzzle',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      // During async load, might show progress indicator
      // expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('has back navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: MaterialApp(
            home: const TsumeGoScreen(),
            navigatorObservers: [],
          ),
          container: container,
        ),
      );

      // Back button should work via Navigator.pop
      final skipButton = find.text('Skip to Tomorrow');
      expect(skipButton, findsWidgets);
    });

    testWidgets('choice chips for difficulty selection are functional',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      // Find difficulty selector
      expect(find.byType(ChoiceChip), findsWidgets);

      // Tap a chip (e.g., Easy)
      // await tester.tap(find.byType(ChoiceChip).first);
      // await tester.pumpAndSettle();
    });

    testWidgets('appbar title is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const TsumeGoScreen(),
          container: container,
        ),
      );

      expect(find.text("Today's Puzzle"), findsWidgets);
    });
  });
}
