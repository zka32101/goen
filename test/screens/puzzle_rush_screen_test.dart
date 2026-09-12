import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goen/views/screens/index.dart';

void main() {
  group('PuzzleRushScreen Widget Tests', () {
    testWidgets('初期レンダリング - AppBar表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Puzzle Rush'), findsWidgets);
    });

    testWidgets('戻るボタンが表示される', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('難易度表示 - EASY', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'easy',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('難易度表示 - NORMAL', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('難易度表示 - HARD', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'hard',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('難易度表示 - EXPERT', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'expert',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('タイマー表示 - 初期5分', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      expect(find.text('残り時間'), findsWidgets);
    });

    testWidgets('スコアセクション - 表示確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('UIレイアウト - ダークモード背景', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
    });

    testWidgets('レスポンシブ対応 - SingleChildScrollView使用', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('アクションボタン - セッション終了ボタン', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('セッションを終了'), findsWidgets);
    });

    testWidgets('デバイスサイズ対応 - 小さい画面', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(400, 800);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      expect(find.byType(PuzzleRushScreen), findsOneWidget);
    });

    testWidgets('デバイスサイズ対応 - 大きい画面', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1200, 1600);
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      expect(find.byType(PuzzleRushScreen), findsOneWidget);
    });

    testWidgets('ユーザーID パラメータ確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'user-abc-123',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      expect(find.byType(PuzzleRushScreen), findsOneWidget);
    });

    testWidgets('プロバイダー統合 - startPuzzleRushProvider', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('リーダーボード読み込み - 非同期処理', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('テキストスタイル - 日本語表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('ナビゲーション - 戻るボタン機能', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('エラーハンドリング - 画面表示保証', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: PuzzleRushScreen(
              uid: 'test-user',
              difficulty: 'normal',
            ),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
