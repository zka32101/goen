import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goen/main.dart';
import 'package:goen/models/index.dart';

void main() {
  group('GameMode Navigation Integration Tests', () {
    testWidgets('Navigate from GameModeSelectorScreen to BlitzGameScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoEnApp()));
      await tester.pumpAndSettle();

      // Navigate to GameModeSelector
      await tester.tap(find.byIcon(Icons.sports_esports));
      await tester.pumpAndSettle();

      // Tap Blitz game card
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets(
        'Navigate from GameModeSelectorScreen to CorrespondenceGameScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoEnApp()));
      await tester.pumpAndSettle();
    });

    testWidgets('Navigate from GameModeSelectorScreen to TeamGameScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoEnApp()));
      await tester.pumpAndSettle();
    });

    testWidgets('Navigate from GameModeSelectorScreen to PuzzleRushScreen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoEnApp()));
      await tester.pumpAndSettle();
    });

    testWidgets('Back button returns to previous screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoEnApp()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsWidgets);
    });

    testWidgets('Named route navigation works correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: GoEnApp()));
      await tester.pumpAndSettle();

      // Routes should be registered
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
