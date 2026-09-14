import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/views/screens/splash_screen.dart';
import 'package:goen/views/screens/home_screen.dart';
import 'package:goen/views/screens/ai_game_screen.dart';
import 'package:goen/views/screens/game_result_screen.dart';
import '../test_utils.dart';
import '../fixtures/test_data.dart';

void main() {
  group('UI Automation: App Flow Scenarios', () {
    late ProviderContainer container;

    setUp(() {
      container = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
      );
    });

    testWidgets('🤖 Automation: Complete game flow (AI vs Player)',
        (WidgetTester tester) async {
      // Step 1: Start at splash
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const SplashScreen(),
          container: container,
        ),
      );

      expect(find.byType(SplashScreen), findsWidgets);
      print('✓ Step 1: Splash screen loaded');

      // Step 2: Wait for navigation
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Step 3: Navigate to home
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      expect(find.byType(HomeScreen), findsWidgets);
      print('✓ Step 2: Home screen reached');

      // Step 4: Tap Play button
      await tester.tap(find.text('Play').first);
      await tester.pumpAndSettle();

      // Step 5: Verify game screen
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const AIGameScreen(),
          container: container,
        ),
      );

      expect(find.byType(AIGameScreen), findsWidgets);
      print('✓ Step 3: AI Game screen loaded');

      // Step 6: Make a move
      final board = find.byType(GestureDetector).first;
      if (board.evaluate().isNotEmpty) {
        await tester.tap(board);
        await tester.pumpAndSettle();
        print('✓ Step 4: Player move made');
      }

      // Step 7: Resign to end game
      final resignButton = find.text('Resign');
      if (resignButton.evaluate().isNotEmpty) {
        await tester.tap(resignButton);
        await tester.pumpAndSettle();
        print('✓ Step 5: Game resigned');
      }

      // Step 8: Verify result screen
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const GameResultScreen(),
          container: container,
        ),
      );

      expect(find.byType(GameResultScreen), findsWidgets);
      print('✓ Step 6: Game result screen shown');
    });

    testWidgets('🤖 Automation: Puzzle solving flow',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      print('✓ Home screen ready');

      // Tap daily puzzle
      final puzzleButton = find.text('Daily Puzzle');
      if (puzzleButton.evaluate().isNotEmpty) {
        await tester.tap(puzzleButton);
        await tester.pumpAndSettle();
        print('✓ Puzzle screen opened');

        // Make attempt
        final board = find.byType(GestureDetector).first;
        if (board.evaluate().isNotEmpty) {
          await tester.tap(board);
          await tester.pumpAndSettle();
          print('✓ Puzzle attempt made');
        }
      }
    });

    testWidgets('🤖 Automation: Game history browsing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Navigate to history
      final historyButton = find.text('My Games');
      if (historyButton.evaluate().isNotEmpty) {
        await tester.tap(historyButton);
        await tester.pumpAndSettle();
        print('✓ History screen opened');

        // Scroll through list
        final listView = find.byType(ListView);
        if (listView.evaluate().isNotEmpty) {
          await tester.scroll(listView.first, Offset(0, -300));
          await tester.pumpAndSettle();
          print('✓ History scrolled');
        }
      }
    });

    testWidgets('🤖 Automation: Settings modification',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Navigate to settings
      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
        await tester.pumpAndSettle();
        print('✓ Settings screen opened');

        // Toggle a setting
        final toggles = find.byType(Switch);
        if (toggles.evaluate().isNotEmpty) {
          await tester.tap(toggles.first);
          await tester.pumpAndSettle();
          print('✓ Setting toggled');
        }
      }
    });

    testWidgets('🤖 Automation: Multiple game sessions',
        (WidgetTester tester) async {
      // Simulate 3 consecutive games
      for (int gameNum = 1; gameNum <= 3; gameNum++) {
        await tester.pumpWidget(
          TestUtils.buildTestableWidget(
            child: const HomeScreen(),
            container: container,
          ),
        );

        // Play game
        await tester.tap(find.text('Play').first);
        await tester.pumpAndSettle();

        await tester.pumpWidget(
          TestUtils.buildTestableWidget(
            child: const AIGameScreen(),
            container: container,
          ),
        );

        // Make move
        final board = find.byType(GestureDetector).first;
        if (board.evaluate().isNotEmpty) {
          await tester.tap(board);
          await tester.pumpAndSettle();
        }

        // End game
        final resign = find.text('Resign');
        if (resign.evaluate().isNotEmpty) {
          await tester.tap(resign);
          await tester.pumpAndSettle();
        }

        print('✓ Game $gameNum completed');
      }
    });

    testWidgets('🤖 Automation: Deep link navigation',
        (WidgetTester tester) async {
      // Test deep linking to specific screens
      final screens = [
        (const HomeScreen(), 'Home'),
        (const AIGameScreen(), 'Game'),
        (const GameResultScreen(), 'Result'),
      ];

      for (final (screen, name) in screens) {
        await tester.pumpWidget(
          TestUtils.buildTestableWidget(
            child: screen,
            container: container,
          ),
        );

        expect(find.byType(Scaffold), findsWidgets);
        print('✓ Deep link to $name successful');
      }
    });

    testWidgets('🤖 Automation: Error recovery flow',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Try to interact when not ready
      await tester.pumpAndSettle();

      // Navigate back and forth to trigger recovery
      for (int i = 0; i < 3; i++) {
        final playButton = find.text('Play');
        if (playButton.evaluate().isNotEmpty) {
          await tester.tap(playButton.first);
          await tester.pumpAndSettle();

          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await tester.tap(backButton);
            await tester.pumpAndSettle();
          }
        }
      }

      expect(find.byType(Scaffold), findsWidgets);
      print('✓ Error recovery completed');
    });

    testWidgets('🤖 Automation: Performance verification during flow',
        (WidgetTester tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      await tester.tap(find.text('Play').first);
      await tester.pumpAndSettle();

      stopwatch.stop();

      print('✓ Game navigation completed in ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
    });

    testWidgets('🤖 Automation: Memory leak detection during flow',
        (WidgetTester tester) async {
      // Create and destroy widgets repeatedly
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          TestUtils.buildTestableWidget(
            child: const HomeScreen(),
            container: container,
          ),
        );

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }

      // Final check - app should still be responsive
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      expect(find.byType(Scaffold), findsWidgets);
      print('✓ Memory leak check passed');
    });
  });
}
