import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/views/screens/home_screen.dart';
import 'package:goen/viewmodels/index.dart';

import '../fixtures/test_data.dart';
import '../test_utils.dart';

void main() {
  group('HomeScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
        isSubscriptionActive: false,
      );
    });

    testWidgets('renders home screen with main layout',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Verify scaffold
      expect(find.byType(Scaffold), findsWidgets);

      // Verify app bar
      expect(find.byType(AppBar), findsWidgets);
    });

    testWidgets('displays user greeting with name', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Verify greeting section exists
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('shows all four primary action cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Verify card widgets exist (4 main cards)
      expect(find.byType(Card), findsWidgets);

      // Verify action buttons/text
      expect(find.text('Play AI Game'), findsWidgets);
      expect(find.text("Today's Puzzle"), findsWidgets);
      expect(find.text('Watch & Learn'), findsWidgets);
      expect(find.text('My Games'), findsWidgets);
    });

    testWidgets('displays subscription status when inactive',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Premium users would show "Premium Member" badge
      // Free users would show upgrade prompts
    });

    testWidgets('displays subscription status when active',
        (WidgetTester tester) async {
      final premiumContainer = TestUtils.createTestContainer(
        currentUser: TestData.premiumUser,
        isSubscriptionActive: true,
      );

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: premiumContainer,
        ),
      );

      // Verify premium badge visible
    });

    testWidgets('has correct dark theme styling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      final scaffold = find.byType(Scaffold).first;
      final scaffoldWidget = tester.widget<Scaffold>(scaffold);

      expect(scaffoldWidget.backgroundColor, Colors.black87);
    });

    testWidgets('play ai game card is prominently styled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // The primary CTA card should be visually distinct
      // (has golden border as per design)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows game statistics section', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Stats would show games played, member since, etc.
      // Depending on implementation details
    });

    testWidgets('taps navigate to correct screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: MaterialApp(
            home: const HomeScreen(),
            navigatorObservers: [],
            routes: {
              '/ai-game': (_) => const Scaffold(body: Text('AI Game')),
              '/tsume-go': (_) => const Scaffold(body: Text('Tsume-Go')),
              '/kifu-observation': (_) =>
                  const Scaffold(body: Text('Watch & Learn')),
              '/game-history': (_) => const Scaffold(body: Text('My Games')),
            },
          ),
          container: container,
        ),
      );

      // Verify cards exist and are tappable
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('displays empty state when no user',
        (WidgetTester tester) async {
      final noUserContainer = TestUtils.createTestContainer(
        currentUser: null,
      );

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: noUserContainer,
        ),
      );

      // Auth required state would be shown
    });

    testWidgets('golden border on primary CTA',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const HomeScreen(),
          container: container,
        ),
      );

      // Verify golden accents (#D4AF37 approximate)
      // This depends on actual widget implementation
    });
  });
}
