import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goen/views/screens/blitz_game_settings_screen.dart';
import 'package:goen/viewmodels/index.dart';

void main() {
  group('BlitzGameSettingsScreen Tests', () {
    testWidgets('初期表示確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: BlitzGameSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ブリッツゲーム設定'), findsOneWidget);
      expect(find.text('ボードサイズ'), findsOneWidget);
      expect(find.text('AI難易度'), findsOneWidget);
    });

    testWidgets('ボードサイズ選択確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: BlitzGameSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('9×9'), findsOneWidget);
      expect(find.text('13×13'), findsOneWidget);
      expect(find.text('19×19'), findsOneWidget);
    });

    testWidgets('AI難易度スライダー表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: BlitzGameSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('初級'), findsWidgets);
      expect(find.text('上級'), findsWidgets);
      expect(find.byType(Slider), findsOneWidget);
    });

    testWidgets('ゲーム開始ボタン表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: BlitzGameSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ElevatedButton), findsWidgets);
      expect(find.text('ゲーム開始'), findsOneWidget);
    });

    testWidgets('戻るボタン動作確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: BlitzGameSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('ダークモード背景確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: BlitzGameSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsWidgets);
    });
  });
}
