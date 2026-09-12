import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goen/views/screens/puzzle_rush_settings_screen.dart';

void main() {
  group('PuzzleRushSettingsScreen Tests', () {
    testWidgets('初期表示確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PuzzleRushSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('詰碁ラッシュ設定'), findsOneWidget);
      expect(find.text('難易度を選択'), findsOneWidget);
    });

    testWidgets('難易度カード表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PuzzleRushSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('初級'), findsOneWidget);
      expect(find.text('中級'), findsOneWidget);
      expect(find.text('上級'), findsOneWidget);
      expect(find.text('最高級'), findsOneWidget);
    });

    testWidgets('セッション情報表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PuzzleRushSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('セッション情報'), findsOneWidget);
      expect(find.text('5分間のセッション'), findsOneWidget);
      expect(find.text('コンボシステム搭載'), findsOneWidget);
    });

    testWidgets('ゲーム開始ボタン', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: PuzzleRushSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ゲーム開始'), findsOneWidget);
    });
  });
}
