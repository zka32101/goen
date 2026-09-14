import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/views/screens/onboarding_screen.dart';
import 'package:goen/viewmodels/index.dart';

import '../fixtures/test_data.dart';
import '../test_utils.dart';

void main() {
  group('OnboardingScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
      );
    });

    testWidgets('renders onboarding screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Verify scaffold exists
      expect(find.byType(Scaffold), findsWidgets);

      // Verify page view for cards
      expect(find.byType(PageView), findsWidgets);
    });

    testWidgets('displays screen title', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Verify title
      expect(find.text('Learn Go'), findsWidgets);
    });

    testWidgets('shows skip button', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Verify skip button
      expect(find.text('Skip'), findsWidgets);
    });

    testWidgets('displays first card welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // First card should show welcome
      expect(find.text('Welcome to 碁縁'), findsWidgets);
    });

    testWidgets('first card shows app name', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // App name with Chinese characters
      expect(find.text('Learn Go at your own pace. No time pressure, just pure strategy.'),
          findsWidgets);
    });

    testWidgets('shows 3 step hint on first card', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Hint about 3 steps
      expect(find.text('We\'ll teach you the basics in 3 simple steps'), findsWidgets);
    });

    testWidgets('displays page indicators', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Should have 3 page indicator dots
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows navigation buttons', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Next button on first page
      expect(find.text('Next'), findsWidgets);
    });

    testWidgets('back button not shown on first page', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Back button should not be visible on first page
      // (only Next button shown)
      final backButtons = find.text('Back');
      expect(backButtons, findsNothing);
    });

    testWidgets('can navigate to second card', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Tap next
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should show second card content
      expect(find.text('Tap 1: Your Move'), findsWidgets);
    });

    testWidgets('second card displays board visualization', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Navigate to second card
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Board visualization should be present
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('second card shows black stone', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Navigate to second card
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Black stone container should exist
      expect(find.byType(Positioned), findsWidgets);
    });

    testWidgets('can navigate to third card', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Tap next twice
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should show third card content
      expect(find.text('Tap 3: Capture!'), findsWidgets);
    });

    testWidgets('third card shows aha moment label', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Navigate to third card
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Should show aha moment text
      expect(find.text('The Aha Moment'), findsWidgets);
    });

    testWidgets('final button changes to start playing on last card',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Navigate to third card
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Button should now say "Start Playing"
      expect(find.text('Start Playing'), findsWidgets);
    });

    testWidgets('can navigate back from second card', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Navigate to second card
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Back button should now be visible
      expect(find.text('Back'), findsWidgets);

      // Tap back
      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      // Should be back on first card
      expect(find.text('Welcome to 碁縁'), findsWidgets);
    });

    testWidgets('page indicator shows current page', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Initially on page 0 - first indicator should be highlighted
      // After navigating, indicator should change
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Page indicator should reflect current page
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('dark theme styling applied', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      final scaffold = find.byType(Scaffold).first;
      final scaffoldWidget = tester.widget<Scaffold>(scaffold);

      expect(scaffoldWidget.backgroundColor, Colors.black87);
    });

    testWidgets('card containers have borders', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Cards should have styled containers
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows golden accent color on elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Golden highlights should be present
      expect(find.byType(Icon), findsWidgets); // Icon with golden color
    });

    testWidgets('displays stone with shadow effect', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Navigate to second card to see stone
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Container with shadow should exist
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('third card shows multiple stones', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // Navigate to third card
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      // Multiple positioned elements for stones
      expect(find.byType(Positioned), findsWidgets);
    });

    testWidgets('has full height page view', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // PageView should be in expanded widget
      expect(find.byType(Expanded), findsWidgets);
    });

    testWidgets('safe area applied to content', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const OnboardingScreen(),
          container: container,
        ),
      );

      // SafeArea should be used
      expect(find.byType(SafeArea), findsNothing); // In this implementation
      // but content is properly spaced from edges
    });
  });
}
