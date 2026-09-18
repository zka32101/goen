import 'dart:collection';
import 'package:logger/logger.dart';
import 'package:goen/native/fuego_bindings.dart';
import 'package:goen/services/go_rules.dart';
import 'dart:math' as math;

/// AI move response (Fuego version)
class AIMove {
  final int row;
  final int col;
  final double confidence;
  final String? reasoning;

  AIMove({
    required this.row,
    required this.col,
    this.confidence = 0.8,
    this.reasoning,
  });

  factory AIMove.fromJson(Map<String, dynamic> json) {
    return AIMove(
      row: json['row'] as int,
      col: json['col'] as int,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.8,
      reasoning: json['reasoning'] as String?,
    );
  }

  @override
  String toString() => 'AIMove(row: $row, col: $col, confidence: $confidence)';
}

/// Game end result
class GameEndResult {
  final bool gameEnded;
  final double blackScore;
  final double whiteScore;
  final String? winner;
  final String? scoringMethod;

  GameEndResult({
    required this.gameEnded,
    required this.blackScore,
    required this.whiteScore,
    this.winner,
    this.scoringMethod = 'chinese',
  });

  factory GameEndResult.fromJson(Map<String, dynamic> json) {
    return GameEndResult(
      gameEnded: json['gameEnded'] as bool? ?? false,
      blackScore: (json['blackScore'] as num?)?.toDouble() ?? 0.0,
      whiteScore: (json['whiteScore'] as num?)?.toDouble() ?? 0.0,
      winner: json['winner'] as String?,
      scoringMethod: json['scoringMethod'] as String? ?? 'chinese',
    );
  }

  @override
  String toString() =>
      'GameEndResult(ended: $gameEnded, black: $blackScore, white: $whiteScore, winner: $winner)';
}

/// Fuego Go エンジン (On-device, lightweight)
///
/// 特徴:
/// - ローカルで実行 (Firebase 不要)
/// - 高速 (1秒以内)
/// - 9x9 最適化
/// - オフライン対応
class FuegoEngineService {
  late FuegoNative _fuego;
  final Logger _logger = Logger();

  FuegoEngineService() {
    _initialize();
  }

  void _initialize() {
    try {
      _fuego = FuegoNative();
      final result = _fuego.initialize();
      _logger.i('✅ Fuego エンジン初期化成功 (code: $result)');
    } catch (e) {
      _logger.e('❌ Fuego 初期化失敗: $e');
      rethrow;
    }
  }

  /// AI の手を取得
  ///
  /// Parameters:
  /// - boardSize: ボードサイズ (9, 13, 19)
  /// - stones: ボード状態 (0=empty, 1=black, 2=white)
  /// - isPlayerBlack: プレイヤーが黒か
  /// - aiLevel: AI レベル (1-10)
  /// - movesCount: 既に打たれた手数
  Future<AIMove> requestAiMove({
    required int boardSize,
    required List<List<int>> stones,
    required bool isPlayerBlack,
    required int aiLevel,
    int movesCount = 0,
  }) async {
    assert(aiLevel >= 1 && aiLevel <= 10, 'aiLevel must be 1-10');

    _logger.i('🎯 Fuego: AI の手を要求 (level=$aiLevel, size=$boardSize)');

    try {
      // ボード状態を 1D 配列に変換
      final boardFlat = <int>[];
      for (int row = 0; row < boardSize; row++) {
        for (int col = 0; col < boardSize; col++) {
          boardFlat.add(stones[row][col]);
        }
      }

      _logger.d('📦 ボード状態を Fuego に送信 (${boardFlat.length} セル)');

      // Fuego から手を取得
      final moveId = _fuego.getMove(boardFlat, boardSize, aiLevel);
      final (row, col) = _fuego.getMoveCoords(moveId);

      _logger.i('✅ Fuego 応答: row=$row, col=$col');

      return AIMove(
        row: row,
        col: col,
        confidence: 0.85,
        reasoning: 'Fuego evaluation',
      );
    } catch (e) {
      _logger.e('🔥 Fuego エラー: $e');
      rethrow;
    }
  }

  /// ゲーム終局を判定 (簡易版)
  ///
  /// 注: Fuego は主に手の推奨に特化しているため、
  /// 終局判定はシンプルな実装
  Future<GameEndResult> judgeGameEnd({
    required int boardSize,
    required List<List<int>> stones,
    required bool isPlayerBlack,
    required bool lastPlayerPassed,
  }) async {
    _logger.i('🏁 ゲーム終了判定: lastPassed=$lastPlayerPassed');

    try {
      // 簡易的な終局判定
      final blackStones = stones.expand((row) => row).where((s) => s == 1).length;
      final whiteStones = stones.expand((row) => row).where((s) => s == 2).length;

      _logger.i('📊 石数: 黒=$blackStones, 白=$whiteStones');

      // 中国ルール: 石数 + 陣地
      final blackScore = blackStones.toDouble();
      final whiteScore = whiteStones.toDouble() + 3.75; // コミ

      final winner = blackScore > whiteScore
          ? 'black'
          : whiteScore > blackScore
              ? 'white'
              : 'draw';

      return GameEndResult(
        gameEnded: true,
        blackScore: blackScore,
        whiteScore: whiteScore,
        winner: winner,
        scoringMethod: 'chinese',
      );
    } catch (e) {
      _logger.e('🔥 終局判定エラー: $e');
      rethrow;
    }
  }

  /// 着手が合法か検証（石取り・自殺手禁止・コウを考慮）
  bool validateMove({
    required int boardSize,
    required List<List<int>> stones,
    required int row,
    required int col,
    required int player,
    int? koRow,
    int? koCol,
  }) {
    return GoRules.isLegalMove(
      stones: stones,
      boardSize: boardSize,
      row: row,
      col: col,
      player: player,
      koRow: koRow,
      koCol: koCol,
    );
  }

  /// 盤面の形勢を評価 (簡易版)
  ///
  /// 石数と領地推定に基づいて評価を計算
  /// 中国ルール対応 (コミ 3.75)
  Future<PositionEvaluation> evaluatePosition({
    required List<List<int>> stones,
    required int boardSize,
  }) async {
    _logger.i('📊 形勢評価開始 (boardSize=$boardSize)');

    try {
      // 石数をカウント
      int blackStones = 0;
      int whiteStones = 0;
      for (int row = 0; row < boardSize; row++) {
        for (int col = 0; col < boardSize; col++) {
          if (stones[row][col] == 1) {
            blackStones++;
          } else if (stones[row][col] == 2) {
            whiteStones++;
          }
        }
      }

      // 領地推定（簡易版: 連結した空点をカウント）
      final visited = List.generate(boardSize, (_) => List.filled(boardSize, false));
      int blackTerritory = 0;
      int whiteTerritory = 0;

      for (int row = 0; row < boardSize; row++) {
        for (int col = 0; col < boardSize; col++) {
          if (stones[row][col] == 0 && !visited[row][col]) {
            final territory = _evaluateTerritory(stones, visited, row, col, boardSize);
            if (territory['owner'] == 'black') {
              blackTerritory += territory['count'] as int;
            } else if (territory['owner'] == 'white') {
              whiteTerritory += territory['count'] as int;
            }
          }
        }
      }

      // スコア計算（中国ルール）
      final blackScore = blackStones.toDouble() + blackTerritory.toDouble();
      final whiteScore = whiteStones.toDouble() + whiteTerritory.toDouble() + 3.75; // コミ

      _logger.i(
        '📈 石: 黒=$blackStones, 白=$whiteStones | 領地: 黒=$blackTerritory, 白=$whiteTerritory',
      );

      final scoreDiff = blackScore - whiteScore;

      // 評価テキスト
      String assessment;
      if (scoreDiff > 10) {
        assessment = '黒が圧倒的に優勢';
      } else if (scoreDiff > 5) {
        assessment = '黒が優勢';
      } else if (scoreDiff > 1) {
        assessment = '黒がやや優勢';
      } else if (scoreDiff < -10) {
        assessment = '白が圧倒的に優勢';
      } else if (scoreDiff < -5) {
        assessment = '白が優勢';
      } else if (scoreDiff < -1) {
        assessment = '白がやや優勢';
      } else {
        assessment = '互角';
      }

      // 勝率推定（シグモイド関数使用）
      final blackWinProbability = 1.0 / (1.0 + math.exp(-scoreDiff / 10.0));

      _logger.i(
        '✅ 形勢評価: $assessment (スコア差: $scoreDiff, 黒勝率: ${(blackWinProbability * 100).toStringAsFixed(1)}%)',
      );

      return PositionEvaluation(
        blackScore: blackScore,
        whiteScore: whiteScore,
        scoreDiff: scoreDiff,
        assessment: assessment,
        blackWinProbability: blackWinProbability,
      );
    } catch (e) {
      _logger.e('🔥 形勢評価エラー: $e');
      rethrow;
    }
  }

  /// 連結された領地を判定
  Map<String, dynamic> _evaluateTerritory(
    List<List<int>> stones,
    List<List<bool>> visited,
    int startRow,
    int startCol,
    int boardSize,
  ) {
    final queue = Queue<(int, int)>();
    queue.add((startRow, startCol));
    visited[startRow][startCol] = true;

    int emptyCount = 0;
    final adjacentOwners = <int>{};

    while (queue.isNotEmpty) {
      final (row, col) = queue.removeFirst();
      emptyCount++;

      // 隣接セルを調査
      final neighbors = [
        (row - 1, col),
        (row + 1, col),
        (row, col - 1),
        (row, col + 1),
      ];

      for (final (nextRow, nextCol) in neighbors) {
        if (nextRow < 0 || nextRow >= boardSize || nextCol < 0 || nextCol >= boardSize) {
          continue;
        }

        final cell = stones[nextRow][nextCol];
        if (cell == 0) {
          // 空点
          if (!visited[nextRow][nextCol]) {
            visited[nextRow][nextCol] = true;
            queue.add((nextRow, nextCol));
          }
        } else {
          // 石
          adjacentOwners.add(cell);
        }
      }
    }

    // 単独の所有者のみ領地と認定
    if (adjacentOwners.length == 1) {
      final owner = adjacentOwners.first;
      return {
        'owner': owner == 1 ? 'black' : 'white',
        'count': emptyCount,
      };
    }

    return {'owner': 'neutral', 'count': 0};
  }

  /// エンジンをクリーンアップ
  void dispose() {
    try {
      _fuego.dispose();
      _logger.i('✅ Fuego エンジン クリーンアップ完了');
    } catch (e) {
      _logger.e('❌ クリーンアップエラー: $e');
    }
  }
}

/// Board position evaluation result
class PositionEvaluation {
  final double blackScore;
  final double whiteScore;
  final double scoreDiff;
  final String assessment;
  final double blackWinProbability;

  PositionEvaluation({
    required this.blackScore,
    required this.whiteScore,
    required this.scoreDiff,
    required this.assessment,
    required this.blackWinProbability,
  });

  @override
  String toString() =>
      'Evaluation(black: $blackScore, white: $whiteScore, diff: $scoreDiff, black_win: $blackWinProbability)';
}

/// Custom exception for Fuego engine errors
class FuegoException implements Exception {
  final String message;
  final Object? originalException;

  FuegoException(this.message, [this.originalException]);

  @override
  String toString() =>
      'FuegoException: $message${originalException != null ? ' (caused by: $originalException)' : ''}';
}
