import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goen/views/screens/team_game_settings_screen.dart';

void main() {
  group('TeamGameSettingsScreen Tests', () {
    testWidgets('初期表示確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TeamGameSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('チーム戦設定'), findsOneWidget);
      expect(find.text('チーム1 (白石)'), findsOneWidget);
      expect(find.text('チーム2 (黒石)'), findsOneWidget);
    });

    testWidgets('チーム情報表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TeamGameSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('プレイヤー'), findsWidgets);
    });

    testWidgets('ボードサイズ選択', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: TeamGameSettingsScreen()),
            theme: ThemeData.dark(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('9×9'), findsOneWidget);
      expect(find.text('19×19'), findsOneWidget);
    });
  });
}
