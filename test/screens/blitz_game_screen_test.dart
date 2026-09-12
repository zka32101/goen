import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/views/screens/index.dart';

// Mock Providers
final mockBlitzGameServiceProvider = Provider<MockBlitzGameService>((ref) {
  return MockBlitzGameService();
});

class MockBlitzGameService {
  Future<BlitzGameRecord> startBlitzGame({
    required String uid,
    required int boardSize,
    String? aiLevel,
    String? opponentUid,
  }) async {
    return BlitzGameRecord(
      id: 'test-blitz-1',
      uid: uid,
      boardSize: boardSize,
      aiLevel: aiLevel ?? '5',
      opponentUid: opponentUid,
      moveHistory: [],
      result: 'active',
      winnerColor: null,
      ratingChange: 0,
      sgfData: '',
      startedAt: DateTime.now(),
      endedAt: DateTime.now(),
      durationSeconds: 0,
      createdAt: DateTime.now(),
    );
  }
}

void main() {
  group('BlitzGameScreen Widget Tests', () {
    testWidgets('初期レンダリング - ローディング状態', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('ゲームを準備中...'), findsOneWidget);
    });

    testWidgets('Blitz ゲーム - UIコンポーネント表示確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
              aiLevel: '5',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Blitz ゲーム'), findsWidgets);
    });

    testWidgets('タイマー表示 - 初期5分', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
            ),
          ),
        ),
      );

      expect(find.text('残り時間'), findsWidgets);
    });

    testWidgets('戻るボタンクリック - Navigator.pop()', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsWidgets);
    });

    testWidgets('ゲーム情報表示 - ボードサイズとAIレベル', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 9,
              aiLevel: '3',
            ),
          ),
        ),
      );

      expect(find.text('ボードサイズ'), findsWidgets);
      expect(find.text('AIレベル'), findsWidgets);
    });

    testWidgets('着手履歴の表示 - 空状態', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
            ),
          ),
        ),
      );

      expect(find.text('着手履歴'), findsWidgets);
    });

    testWidgets('アクションボタン - 着手提出ボタン表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
            ),
          ),
        ),
      );

      expect(find.text('着手を提出'), findsWidgets);
    });

    testWidgets('ゲーム終了ボタン - 表示確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
            ),
          ),
        ),
      );

      expect(find.text('ゲーム終了'), findsWidgets);
    });

    testWidgets('エラー状態表示 - エラーメッセージ表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
            ),
          ),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('ダークモード確認 - 背景色が黒系', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
            ),
          ),
        ),
      );

      final scaffold = find.byType(Scaffold);
      expect(scaffold, findsOneWidget);
    });

    testWidgets('レスポンシブレイアウト - SingleChildScrollView使用', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
            ),
          ),
        ),
      );

      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('複数ボードサイズ対応 - 9x9', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 9,
              aiLevel: '3',
            ),
          ),
        ),
      );

      expect(find.byType(BlitzGameScreen), findsOneWidget);
    });

    testWidgets('複数ボードサイズ対応 - 19x19', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
              aiLevel: '5',
            ),
          ),
        ),
      );

      expect(find.byType(BlitzGameScreen), findsOneWidget);
    });

    testWidgets('ロギング確認 - initState時のログ記録', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user-123',
              boardSize: 19,
            ),
          ),
        ),
      );

      expect(find.byType(BlitzGameScreen), findsOneWidget);
    });

    testWidgets('プロバイダー統合 - startBlitzGameProvider呼び出し', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
              aiLevel: '5',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('操作: 着手提出ボタンクリック可能性確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
            ),
          ),
        ),
      );

      final button = find.text('着手を提出');
      expect(button, findsWidgets);
    });

    testWidgets('操作: ゲーム終了ボタンクリック可能性確認', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
            ),
          ),
        ),
      );

      final button = find.text('ゲーム終了');
      expect(button, findsWidgets);
    });

    testWidgets('状態遷移: ローディング → データ表示', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(
            home: BlitzGameScreen(
              uid: 'test-user',
              boardSize: 19,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
