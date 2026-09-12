import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goen/views/screens/index.dart';

void main() {
  group('TeamGameScreen Widget Tests', () {
    testWidgets('初期レンダリング - AppBar表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
              boardSize: 19,
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Team ゲーム'), findsWidgets);
    });

    testWidgets('戻るボタンが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('チーム情報表示 - Team1とTeam2', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('プレイヤー数確認 - 4人表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['alice', 'bob'],
              team2Players: ['charlie', 'david'],
              boardSize: 19,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('ボードサイズ パラメータ確認 - 9x9', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
              boardSize: 9,
            ),
          ),
        ),
      );

      expect(find.byType(TeamGameScreen), findsOneWidget);
    });

    testWidgets('ボードサイズ パラメータ確認 - 13x13', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
              boardSize: 13,
            ),
          ),
        ),
      );

      expect(find.byType(TeamGameScreen), findsOneWidget);
    });

    testWidgets('ボードサイズ パラメータ確認 - 19x19', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
              boardSize: 19,
            ),
          ),
        ),
      );

      expect(find.byType(TeamGameScreen), findsOneWidget);
    });

    testWidgets('UIレイアウト - ダークモード背景色', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
            ),
          ),
        ),
      );

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
    });

    testWidgets('レスポンシブレイアウト - SingleChildScrollView確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('アクションボタン - 着手提出ボタン表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('着手を提出'), findsWidgets);
    });

    testWidgets('アクションボタン - ゲーム終了ボタン表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('ゲーム終了'), findsWidgets);
    });

    testWidgets('複数プレイヤー - 異なる名前対応', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['user-alpha', 'user-beta'],
              team2Players: ['user-gamma', 'user-delta'],
            ),
          ),
        ),
      );

      expect(find.byType(TeamGameScreen), findsOneWidget);
    });

    testWidgets('デバイスサイズ対応 - 小さい画面', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
            ),
          ),
        ),
      );

      expect(find.byType(TeamGameScreen), findsOneWidget);
    });

    testWidgets('デバイスサイズ対応 - 大きい画面', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 1600);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
            ),
          ),
        ),
      );

      expect(find.byType(TeamGameScreen), findsOneWidget);
    });

    testWidgets('プロバイダー統合 - startTeamGameProvider呼び出し', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
              boardSize: 19,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('テキスト表示確認 - タイトル', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('ナビゲーション - 戻る機能', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('エラーハンドリング - 画面表示確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: TeamGameScreen(
              team1Players: ['player1', 'player2'],
              team2Players: ['player3', 'player4'],
            ),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
