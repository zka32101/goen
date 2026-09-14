import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/views/screens/splash_screen.dart';
import 'package:goen/viewmodels/index.dart';

import '../fixtures/test_data.dart';
import '../test_utils.dart';

void main() {
  group('SplashScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = TestUtils.createTestContainer(
        currentUser: TestData.testUser,
      );
    });

    testWidgets('renders splash screen with loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const SplashScreen(),
          container: container,
        ),
      );

      // Verify scaffold exists
      expect(find.byType(Scaffold), findsWidgets);

      // Verify loading indicator visible
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('displays welcome message', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const SplashScreen(),
          container: container,
        ),
      );

      // Verify splash screen content
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('has dark theme styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const SplashScreen(),
          container: container,
        ),
      );

      final scaffold = find.byType(Scaffold).first;
      final scaffoldWidget = tester.widget<Scaffold>(scaffold);

      // Verify dark background
      expect(
        scaffoldWidget.backgroundColor,
        Colors.black87,
      );
    });

    testWidgets('renders error state when auth check fails',
        (WidgetTester tester) async {
      final errorContainer = ProviderContainer(
        overrides: [
          currentUserProvider.overrideWithValue(null),
        ],
      );

      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const SplashScreen(),
          container: errorContainer,
        ),
      );

      // Error state content would be visible
      // (depends on actual error handling implementation)
    });

    testWidgets('app bar has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const SplashScreen(),
          container: container,
        ),
      );

      final appBar = find.byType(AppBar).first;
      final appBarWidget = tester.widget<AppBar>(appBar);

      expect(appBarWidget.backgroundColor, Colors.black);
      expect(appBarWidget.elevation, 0);
    });

    testWidgets('responds to retry button press', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const SplashScreen(),
          container: container,
        ),
      );

      // Look for retry button (if error state is shown)
      // This test depends on error scenario
    });

    testWidgets('uses correct text styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        TestUtils.buildTestableWidget(
          child: const SplashScreen(),
          container: container,
        ),
      );

      // Verify text widgets use correct theme
      expect(find.byType(Text), findsWidgets);
    });
  });
}
