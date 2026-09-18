import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/fuego_engine_service.dart';

void main() {
  group('Fuego Engine Service', () {
    late FuegoEngineService engineService;

    setUpAll(() {
      // Fuego エンジンを初期化
      try {
        engineService = FuegoEngineService();
      } on Exception catch (e) {
        // Fuego ライブラリが見つからない場合はスキップ
        print('⚠️ Fuego initialization skipped: $e');
        print('💡 ネイティブライブラリを配置してください: android/app/src/main/jniLibs/arm64-v8a/libfuego.so');
      }
    });

    tearDownAll(() {
      engineService.dispose();
    });

    test('AIMove should be created correctly', () {
      final move = AIMove(row: 3, col: 4, confidence: 0.9);

      expect(move.row, equals(3));
      expect(move.col, equals(4));
      expect(move.confidence, equals(0.9));
      expect(move.toString(), contains('AIMove'));
    });

    test('AIMove.fromJson should parse correctly', () {
      final json = {
        'row': 5,
        'col': 6,
        'confidence': 0.85,
        'reasoning': 'Test move',
      };

      final move = AIMove.fromJson(json);

      expect(move.row, equals(5));
      expect(move.col, equals(6));
      expect(move.confidence, equals(0.85));
      expect(move.reasoning, equals('Test move'));
    });

    test('GameEndResult should calculate winner correctly', () {
      final result = GameEndResult(
        gameEnded: true,
        blackScore: 30.0,
        whiteScore: 25.0,
        winner: 'black',
      );

      expect(result.gameEnded, isTrue);
      expect(result.blackScore, equals(30.0));
      expect(result.winner, equals('black'));
    });

    test('FuegoEngineService.validateMove should verify legal positions', () {
      final boardSize = 9;
      final stones = List.generate(
        boardSize,
        (_) => List.filled(boardSize, 0),
      );

      // 空いている位置は合法
      expect(
        engineService.validateMove(
          boardSize: boardSize,
          stones: stones,
          row: 4,
          col: 4,
        ),
        isTrue,
      );

      // 既に石がある位置は非合法
      stones[3][3] = 1;
      expect(
        engineService.validateMove(
          boardSize: boardSize,
          stones: stones,
          row: 3,
          col: 3,
        ),
        isFalse,
      );

      // ボード外は非合法
      expect(
        engineService.validateMove(
          boardSize: boardSize,
          stones: stones,
          row: -1,
          col: 4,
        ),
        isFalse,
      );

      expect(
        engineService.validateMove(
          boardSize: boardSize,
          stones: stones,
          row: 9,
          col: 4,
        ),
        isFalse,
      );
    });

    test('GameEndResult.fromJson should parse correctly', () {
      final json = {
        'gameEnded': true,
        'blackScore': 32.5,
        'whiteScore': 28.75,
        'winner': 'black',
        'scoringMethod': 'chinese',
      };

      final result = GameEndResult.fromJson(json);

      expect(result.gameEnded, isTrue);
      expect(result.blackScore, equals(32.5));
      expect(result.whiteScore, equals(28.75));
      expect(result.winner, equals('black'));
      expect(result.scoringMethod, equals('chinese'));
    });

    test('FuegoEngineService should handle empty board', () {
      final boardSize = 9;
      final stones = List.generate(
        boardSize,
        (_) => List.filled(boardSize, 0),
      );

      // Empty board should have all legal positions
      for (int row = 0; row < boardSize; row++) {
        for (int col = 0; col < boardSize; col++) {
          expect(
            engineService.validateMove(
              boardSize: boardSize,
              stones: stones,
              row: row,
              col: col,
            ),
            isTrue,
            reason: 'Empty board position ($row, $col) should be legal',
          );
        }
      }
    });

    test('FuegoException should format message correctly', () {
      final exception = FuegoException('Test error', Exception('Cause'));

      expect(
        exception.toString(),
        contains('FuegoException: Test error'),
      );
      expect(
        exception.toString(),
        contains('caused by'),
      );
    });

    // 注: 実際の Fuego AI 呼び出しテストは
    // ネイティブライブラリが必要なため、
    // 統合テストで実行してください
    //
    // flutter test test/fuego_engine_integration_test.dart
  });
}
