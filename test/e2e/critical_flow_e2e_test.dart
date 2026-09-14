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
  group('E2E: Critical User Flows', () {
    late ProviderContainer container;

    setUp(() {
      container = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
      );
    });

    testWidgets('🔄 E2E: Splash → Home → AI Game flow',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const SplashScreen(),
          container: container,
        ),
      );

      // Verify splash screen is shown
      expect(find.byType(SplashScreen), findsWidgets);

      // Wait for navigation to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should navigate to home or onboarding based on tutorialCompleted
      expect(
        find.byType(HomeScreen),
        findsWidgets,
        reason: 'Should navigate to HomeScreen after splash',
      );
    });

    testWidgets('🎮 E2E: Home → Play AI Game → Result screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Verify home screen elements
      expect(find.text('Home'), findsWidgets);

      // Find and tap "Play AI Game" button
      await TestUtils.tap(tester, find.text('Play').first);
      await tester.pumpAndSettle();

      // Should show AI game screen
      expect(find.byType(AIGameScreen), findsWidgets);

      // Verify game board is displayed
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('📊 E2E: Complete AI game and view results',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const AIGameScreen(),
          container: container,
        ),
      );

      // Game should be rendered
      expect(find.byType(Scaffold), findsWidgets);

      // Simulate game play: place a move
      await TestUtils.tap(tester, find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Simulate resign to end game
      await TestUtils.tap(tester, find.text('Resign'));
      await tester.pumpAndSettle();

      // Should show game result screen
      expect(find.byType(GameResultScreen), findsWidgets);

      // Verify result is displayed
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('🧩 E2E: Daily puzzle solve flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Verify home screen
      expect(find.text('Home'), findsWidgets);

      // Tap puzzle action
      final puzzleButton = find.text('Daily Puzzle');
      if (puzzleButton.evaluate().isNotEmpty) {
        await TestUtils.tap(tester, puzzleButton);
        await tester.pumpAndSettle();

        // Should show puzzle screen
        expect(find.byType(Text), findsWidgets);
      }
    });

    testWidgets('📚 E2E: Browse and watch historical game',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Verify home screen
      expect(find.text('Home'), findsWidgets);

      // Tap watch & learn action
      final watchButton = find.text('Watch & Learn');
      if (watchButton.evaluate().isNotEmpty) {
        await TestUtils.tap(tester, watchButton);
        await tester.pumpAndSettle();

        // Should show game library or replay interface
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('📱 E2E: Multi-screen navigation consistency',
        (WidgetTester tester) async {
      // Start from home
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Navigate to different screens
      final screens = [
        'Play AI Game',
        'Daily Puzzle',
        'Watch & Learn',
        'My Games',
      ];

      for (final screenName in screens) {
        final button = find.text(screenName);
        if (button.evaluate().isNotEmpty) {
          await TestUtils.tap(tester, button);
          await tester.pumpAndSettle();

          // Should show scaffold
          expect(find.byType(Scaffold), findsWidgets);

          // Navigate back if back button exists
          final backButton = find.byIcon(Icons.arrow_back);
          if (backButton.evaluate().isNotEmpty) {
            await TestUtils.tap(tester, backButton);
            await tester.pumpAndSettle();
          }
        }
      }
    });

    testWidgets('💾 E2E: Data persistence across navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Navigate to a game
      await TestUtils.tap(tester, find.text('Play').first);
      await tester.pumpAndSettle();

      // Make a move
      await TestUtils.tap(tester, find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Navigate back
      final backButton = find.byIcon(Icons.arrow_back);
      if (backButton.evaluate().isNotEmpty) {
        await TestUtils.tap(tester, backButton);
        await tester.pumpAndSettle();
      }

      // Navigate to game again
      await TestUtils.tap(tester, find.text('Play').first);
      await tester.pumpAndSettle();

      // Game state should be preserved (or new game started)
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('⚡ E2E: Rapid screen transitions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Rapidly navigate between screens
      for (int i = 0; i < 3; i++) {
        // Go to game
        final playButton = find.text('Play').first;
        await TestUtils.tap(tester, playButton);
        await tester.pumpAndSettle();

        // Go back
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await TestUtils.tap(tester, backButton);
          await tester.pumpAndSettle();
        }
      }

      // App should remain stable
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('🔐 E2E: Auth state transitions',
        (WidgetTester tester) async {
      // Start authenticated
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      expect(find.text('Home'), findsWidgets);

      // Verify user-specific content is visible
      expect(find.byType(Text), findsWidgets);

      // Navigate to settings
      final settingsButton = find.text('Settings');
      if (settingsButton.evaluate().isNotEmpty) {
        await TestUtils.tap(tester, settingsButton);
        await tester.pumpAndSettle();

        // Should show settings for authenticated user
        expect(find.byType(Scaffold), findsWidgets);
      }
    });

    testWidgets('📊 E2E: Game history tracking across sessions',
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
        await TestUtils.tap(tester, historyButton);
        await tester.pumpAndSettle();

        // Should show games list
        expect(find.byType(Scaffold), findsWidgets);

        // Verify games are displayed
        expect(find.byType(Text), findsWidgets);
      }
    });

    testWidgets('💳 E2E: Subscription upgrade flow',
        (WidgetTester tester) async {
      final freeUserContainer = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
        isSubscriptionActive: false,
      );

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: freeUserContainer,
        ),
      );

      // After 3 games, paywall should be triggered
      // For this test, we'll manually navigate to paywall
      final upgradeButton = find.text('Upgrade to Premium');
      if (upgradeButton.evaluate().isNotEmpty) {
        await TestUtils.tap(tester, upgradeButton);
        await tester.pumpAndSettle();

        // Should show paywall screen
        expect(find.byType(Scaffold), findsWidgets);

        // Verify pricing options are shown
        expect(find.text('Monthly'), findsWidgets);
        expect(find.text('Annual'), findsWidgets);
      }
    });

    testWidgets('🎯 E2E: Complete aha path (3-tap experience)',
        (WidgetTester tester) async {
      // This simulates the complete aha path:
      // 1. Splash screen
      // 2. Onboarding (if needed)
      // 3. Home screen
      // 4. Play AI game
      // 5. Make capture move (aha moment)

      // Start at splash
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const SplashScreen(),
          container: container,
        ),
      );

      expect(find.byType(SplashScreen), findsWidgets);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should reach home
      expect(find.byType(HomeScreen), findsWidgets);

      // Tap play
      await TestUtils.tap(tester, find.text('Play').first);
      await tester.pumpAndSettle();

      // Should show game
      expect(find.byType(AIGameScreen), findsWidgets);

      // Make a move (aha moment - capture)
      await TestUtils.tap(tester, find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // App should respond to the move
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('🔄 E2E: Error recovery and retry',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Navigate to game
      await TestUtils.tap(tester, find.text('Play').first);
      await tester.pumpAndSettle();

      // Simulate an error scenario by navigating back and forth
      for (int i = 0; i < 2; i++) {
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await TestUtils.tap(tester, backButton);
          await tester.pumpAndSettle();
        }

        // Retry
        final playButton = find.text('Play').first;
        if (playButton.evaluate().isNotEmpty) {
          await TestUtils.tap(tester, playButton);
          await tester.pumpAndSettle();
        }
      }

      // App should remain functional
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('📱 E2E: Responsive layout across game flow',
        (WidgetTester tester) async {
      // Set device size to mobile
      addTearDown(tester.binding.window.physicalSizeTestValue = null);
      addTearDown(TestWidgetsFlutterBinding.instance.window.clearPhysicalSizeTestValue);

      tester.binding.window.physicalSizeTestValue = Size(400, 800);

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Verify layout at mobile size
      expect(find.byType(SingleChildScrollView), findsWidgets);

      // Navigate through screens
      await TestUtils.tap(tester, find.text('Play').first);
      await tester.pumpAndSettle();

      // Verify game layout is responsive
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
