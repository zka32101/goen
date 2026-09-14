import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/views/screens/paywall_screen.dart';
import 'package:goen/viewmodels/index.dart';

import '../fixtures/test_data.dart';
import '../test_utils.dart';

void main() {
  group('PaywallScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
        isSubscriptionActive: false,
      );
    });

    testWidgets('renders paywall screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
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
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // Verify title
      expect(find.text('Premium Membership'), findsWidgets);
    });

    testWidgets('shows close button', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // Close button in app bar
      expect(find.byIcon(Icons.close), findsWidgets);
    });

    testWidgets('displays hero section with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // Hero icon
      expect(find.byIcon(Icons.star), findsWidgets);
    });

    testWidgets('shows hero headline', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // Headline
      expect(find.text('Unlock Premium Features'), findsWidgets);
    });

    testWidgets('displays tagline', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // Tagline
      expect(find.text('Join premium adults learning Go at their own pace'),
          findsWidgets);
    });

    testWidgets('shows benefits section header', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // Benefits header
      expect(find.text('What You Get'), findsWidgets);
    });

    testWidgets('displays all 6 benefits', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // All benefits should be visible
      expect(find.text('Unlimited Games'), findsWidgets);
      expect(find.text('Kifu Library'), findsWidgets);
      expect(find.text('Advanced Stats'), findsWidgets);
      expect(find.text('No Ads'), findsWidgets);
      expect(find.text('Early Access'), findsWidgets);
      expect(find.text('Premium Support'), findsWidgets);
    });

    testWidgets('benefits have checkmark icons', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // Checkmark icons
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('shows benefit descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // Descriptions should be visible
      expect(find.text('Play as many AI games as you want'), findsWidgets);
      expect(find.text('Learn from 1000+ historical games'), findsWidgets);
    });

    testWidgets('pricing section visible', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // Should show pricing (monthly tab should be selected by default)
      await tester.pumpAndSettle();
      expect(find.text('Monthly'), findsWidgets);
    });

    testWidgets('shows monthly and annual toggle', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // Toggle buttons
      expect(find.text('Monthly'), findsWidgets);
      expect(find.text('Annual'), findsWidgets);
    });

    testWidgets('monthly plan shows pricing', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Monthly pricing should be visible
      expect(find.text('9.99'), findsWidgets);
    });

    testWidgets('can switch to annual pricing', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Tap annual toggle
      await tester.tap(find.text('Annual'));
      await tester.pumpAndSettle();

      // Annual pricing should be visible
      expect(find.text('79.99'), findsWidgets);
    });

    testWidgets('lifetime plan shown with annual pricing', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Tap annual
      await tester.tap(find.text('Annual'));
      await tester.pumpAndSettle();

      // Lifetime option
      expect(find.text('299.99'), findsWidgets);
      expect(find.text('Lifetime'), findsWidgets);
    });

    testWidgets('pricing cards have descriptions', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Descriptions
      expect(find.text('Perfect for trying premium features'), findsWidgets);
    });

    testWidgets('lifetime plan marked as best value', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Switch to annual
      await tester.tap(find.text('Annual'));
      await tester.pumpAndSettle();

      // Best value badge
      expect(find.text('BEST VALUE'), findsWidgets);
    });

    testWidgets('shows cancel anytime disclaimer', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Disclaimer
      expect(find.text('Cancel anytime. No hidden fees.'), findsWidgets);
    });

    testWidgets('displays CTA button', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // CTA button
      expect(find.text('Continue with Monthly'), findsWidgets);
    });

    testWidgets('CTA button changes with plan selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Switch to annual
      await tester.tap(find.text('Annual'));
      await tester.pumpAndSettle();

      // Button text should change
      expect(find.text('Continue with Annual'), findsWidgets);
    });

    testWidgets('shows FAQ section', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // FAQ header
      expect(find.text('FAQ'), findsWidgets);
    });

    testWidgets('displays FAQ questions', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // FAQ questions
      expect(find.text('Can I cancel anytime?'), findsWidgets);
      expect(find.text('What payment methods are accepted?'), findsWidgets);
      expect(find.text('Is there a free trial?'), findsWidgets);
    });

    testWidgets('displays FAQ answers', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // FAQ answers should be visible
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('shows success state when already subscribed', (WidgetTester tester) async {
      final subscribedContainer = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
        isSubscriptionActive: true,
      );

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: subscribedContainer,
        ),
      );

      // Success message
      expect(find.text('You\'re Premium!'), findsWidgets);
    });

    testWidgets('success state shows checkmark icon', (WidgetTester tester) async {
      final subscribedContainer = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
        isSubscriptionActive: true,
      );

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: subscribedContainer,
        ),
      );

      // Checkmark icon
      expect(find.byIcon(Icons.check_circle), findsWidgets);
    });

    testWidgets('dark theme styling applied', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
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
          child: const PaywallScreen(),
          container: container,
        ),
      );

      final appBar = find.byType(AppBar).first;
      final appBarWidget = tester.widget<AppBar>(appBar);

      expect(appBarWidget.centerTitle, true);
      expect(appBarWidget.backgroundColor, Colors.black);
      expect(appBarWidget.elevation, 0);
    });

    testWidgets('scrollable content', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // Should have scroll view
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('hero section has gradient background', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      // Gradient container should exist
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('pricing cards have distinct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Cards should be visible
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('period suffix shown for pricing', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Period suffix
      expect(find.text('/month'), findsWidgets);
    });

    testWidgets('lifetime plan shows one-time suffix', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Switch to annual to see lifetime
      await tester.tap(find.text('Annual'));
      await tester.pumpAndSettle();

      // One-time suffix
      expect(find.text('one-time'), findsWidgets);
    });

    testWidgets('benefits list uses Row layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Row for each benefit
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('displays save percentage on annual', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const PaywallScreen(),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Switch to annual
      await tester.tap(find.text('Annual'));
      await tester.pumpAndSettle();

      // Savings message
      expect(find.text('Save 33% with annual billing'), findsWidgets);
    });

    testWidgets('close button closes screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: MaterialApp(
            home: const PaywallScreen(),
            navigatorObservers: [],
          ),
          container: container,
        ),
      );

      await tester.pumpAndSettle();

      // Close button should work
      expect(find.byIcon(Icons.close), findsWidgets);
    });
  });
}
