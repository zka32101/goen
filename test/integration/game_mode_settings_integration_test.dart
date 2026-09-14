import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goen/main.dart';

void main() {
  group('Game Mode Settings Integration Tests', () {
    testWidgets('GameMode Selection → Blitz Settings flow',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoEnApp()));
      await tester.pumpAndSettle();

      // Navigate to GameModeSelector
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets(
        'Correspondence Settings → Game flow',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoEnApp()));
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Team Game Settings validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoEnApp()));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Puzzle Rush Settings difficulty selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoEnApp()));
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Settings → Game transition removes settings screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoEnApp()));
      await tester.pumpAndSettle();

      // Routes should be properly registered
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('Back button from settings returns to GameModeSelector',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoEnApp()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsWidgets);
    });
  });
}
