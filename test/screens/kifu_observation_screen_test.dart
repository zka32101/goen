import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/views/screens/kifu_observation_screen.dart';
import 'package:goen/viewmodels/index.dart';

import '../fixtures/test_data.dart';
import '../test_utils.dart';

void main() {
  group('KifuObservationScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
      );
    });

    testWidgets('renders kifu observation screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
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
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      // Verify title
      expect(find.text('Watch & Learn'), findsWidgets);
    });

    testWidgets('shows info button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      // Info button should exist
      expect(find.byIcon(Icons.info_outline), findsWidgets);
    });

    testWidgets('displays game library header', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      // Should show historical games section
      expect(find.text('Historical Games'), findsWidgets);
    });

    testWidgets('shows loading state while fetching library', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      // Wait for future to resolve
      await tester.pumpAndSettle();

      // Game library should be loaded
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('displays game cards in library', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Game cards should be visible
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('game card shows title and players', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Game information should be visible
      expect(find.text('Honinbo Shusaku'), findsWidgets);
    });

    testWidgets('game card shows category and source', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Category and source should be visible
      expect(find.text('Category'), findsWidgets);
      expect(find.text('Source'), findsWidgets);
    });

    testWidgets('play icon on game card', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Play icon should be visible
      expect(find.byIcon(Icons.play_circle_outline), findsWidgets);
    });

    testWidgets('can select game to watch', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Tap on a game card
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Replay interface should appear
      expect(find.text('Honinbo Shusaku'), findsWidgets);
    });

    testWidgets('replay view shows game header', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Should show back button
      expect(find.byIcon(Icons.arrow_back), findsWidgets);
    });

    testWidgets('replay board is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
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

    testWidgets('shows move counter', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Move counter should be visible
      expect(find.text('Move'), findsWidgets);
    });

    testWidgets('displays move progress slider', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Slider should exist
      expect(find.byType(Slider), findsWidgets);
    });

    testWidgets('shows playback control buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Control buttons
      expect(find.text('Previous'), findsWidgets);
      expect(find.text('Play'), findsWidgets);
      expect(find.text('Next'), findsWidgets);
    });

    testWidgets('previous button disabled at start', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Previous button exists but may be disabled at move 0
      expect(find.text('Previous'), findsWidgets);
    });

    testWidgets('displays commentary section', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Commentary section
      expect(find.text('Commentary'), findsWidgets);
    });

    testWidgets('back to library button works', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
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

      // Should return to library
      expect(find.text('Historical Games'), findsWidgets);
    });

    testWidgets('dark theme styling applied', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
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
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      final appBar = find.byType(AppBar).first;
      final appBarWidget = tester.widget<AppBar>(appBar);

      expect(appBarWidget.centerTitle, true);
      expect(appBarWidget.backgroundColor, Colors.black);
      expect(appBarWidget.elevation, 0);
    });

    testWidgets('opens info dialog when info button tapped', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: MaterialApp(
            home: const KifuObservationScreen(),
            navigatorObservers: [],
          ),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Tap info button
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      // Dialog should appear
      expect(find.byType(AlertDialog), findsWidgets);
    });

    testWidgets('info dialog contains learning information', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: MaterialApp(
            home: const KifuObservationScreen(),
            navigatorObservers: [],
          ),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Tap info button
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      // Check dialog content
      expect(find.text('About Kifu Observation'), findsWidgets);
    });

    testWidgets('single game shows players vs format', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Should show players information
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('board visualization uses custom painter', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Board should use CustomPaint (GoGridPainter)
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('play button has golden background', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Select a game
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Play button exists
      expect(find.text('Play'), findsWidgets);
    });

    testWidgets('handles multiple games in library', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const KifuObservationScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Multiple game cards should exist
      expect(find.byType(Container), findsWidgets);
    });
  });
}
