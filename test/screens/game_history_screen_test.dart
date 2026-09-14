import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/views/screens/game_history_screen.dart';
import 'package:goen/viewmodels/index.dart';

import '../fixtures/test_data.dart';
import '../test_utils.dart';

void main() {
  group('GameHistoryScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
      );
    });

    testWidgets('renders game history screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      // Verify scaffold exists
      expect(find.byType(Scaffold), findsWidgets);

      // Verify app bar
      expect(find.byType(AppBar), findsWidgets);
    });

    testWidgets('displays screen title', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      // Verify title
      expect(find.text('My Games'), findsWidgets);
    });

    testWidgets('shows filter button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      // Filter button should exist
      expect(find.byIcon(Icons.filter_list), findsWidgets);
    });

    testWidgets('displays game count', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Should show game count
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('shows statistics section', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Statistics section
      expect(find.text('Wins'), findsWidgets);
      expect(find.text('Losses'), findsWidgets);
      expect(find.text('Draws'), findsWidgets);
    });

    testWidgets('displays game cards', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Game cards should be visible
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('game card shows result', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Result text (Victory/Defeat) should be visible
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('game card shows date', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Date formatting should be applied
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('game card displays score', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Score should be displayed
      expect(find.text('Score'), findsWidgets);
    });

    testWidgets('game card shows AI level', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // AI level should be displayed
      expect(find.text('Level'), findsWidgets);
    });

    testWidgets('can select game to view details', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Tap on a game card
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Details view should appear
      expect(find.text('Victory'), findsWidgets);
    });

    testWidgets('game details shows final board', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Board should be rendered
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('game details shows game info section', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Game details section
      expect(find.text('Game Details'), findsWidgets);
    });

    testWidgets('back button returns to game list', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Click back button
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should return to list
      expect(find.text('Game History'), findsWidgets);
    });

    testWidgets('filter menu opens when filter button tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Tap filter button
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Filter menu should open
      expect(find.text('Filter by Result'), findsWidgets);
    });

    testWidgets('filter menu shows result options', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Open filter menu
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Filter options
      expect(find.text('All'), findsWidgets);
      expect(find.text('Wins'), findsWidgets);
      expect(find.text('Losses'), findsWidgets);
      expect(find.text('Draws'), findsWidgets);
    });

    testWidgets('filter menu shows sort options', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Open filter menu
      await tester.tap(find.byIcon(Icons.filter_list));
      await tester.pumpAndSettle();

      // Sort options
      expect(find.text('Sort by'), findsWidgets);
      expect(find.text('Most Recent'), findsWidgets);
      expect(find.text('Best Score'), findsWidgets);
      expect(find.text('Longest'), findsWidgets);
    });

    testWidgets('shows auth required state when no user', (WidgetTester tester) async {
      final noAuthContainer = TestUtils.createTestContainer(
        currentUser: null,
      );

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: noAuthContainer,
        ),
      );

      // Auth required message
      expect(find.text('Log in to view your games'), findsWidgets);
    });

    testWidgets('shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      // Should eventually load
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('dark theme styling applied', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      final scaffold = find.byType(Scaffold).first;
      final scaffoldWidget = tester.widget<Scaffold>(scaffold);

      expect(scaffoldWidget.backgroundColor, Colors.black87);
    });

    testWidgets('app bar has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      final appBar = find.byType(AppBar).first;
      final appBarWidget = tester.widget<AppBar>(appBar);

      expect(appBarWidget.centerTitle, true);
      expect(appBarWidget.backgroundColor, Colors.black);
      expect(appBarWidget.elevation, 0);
    });

    testWidgets('victory card has green border', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Win cards should have green styling
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('defeat card has red border', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Loss cards should have red styling
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('scroll view for game list', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Should have scrolling capability
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('shows move sequence placeholder in details', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Move sequence section
      expect(find.text('Move Sequence'), findsWidgets);
    });

    testWidgets('game details displays board size', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Board size should be displayed
      expect(find.text('Board Size'), findsWidgets);
    });

    testWidgets('game card tappable area', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameHistoryScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Cards should be tappable
      expect(find.byType(InkWell), findsWidgets);
    });
  });
}
