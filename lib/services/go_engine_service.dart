import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:logger/logger.dart';

/// Go board state representation for engine communication
class _EngineBoardState {
  final int boardSize; // 9, 13, or 19
  final List<List<int>> stones; // -1=empty, 0=black, 1=white
  final bool isPlayerBlack;

  _EngineBoardState({
    required this.boardSize,
    required this.stones,
    required this.isPlayerBlack,
  });

  /// Convert to SGF (Standard Game Format) for engine
  String toSgf() {
    final buffer = StringBuffer();
    buffer.write('(;GM[1]SZ[$boardSize]');

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        if (stones[row][col] != -1) {
          final stoneType = stones[row][col] == 0 ? 'B' : 'W';
          buffer.write(';$stoneType[${_coordToSgf(col)},${_coordToSgf(row)}]');
        }
      }
    }
    buffer.write(')');
    return buffer.toString();
  }

  String _coordToSgf(int coord) {
    // SGF uses letters: a-s for 19x19
    return String.fromCharCode(97 + coord);
  }

  @override
  String toString() =>
      '_EngineBoardState(size: ${boardSize}x$boardSize, playerBlack: $isPlayerBlack)';
}

/// AI move response
class AIMove {
  final int row;
  final int col;
  final double confidence; // 0.0-1.0
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

/// Game end result with scoring
class GameEndResult {
  final bool gameEnded;
  final double blackScore; // Chinese rules
  final double whiteScore;
  final String? winner; // 'black', 'white', 'draw'
  final String? scoringMethod; // 'chinese', 'japanese', etc.

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

/// Service for interacting with GNU Go engine via Cloud Functions
/// Uses Cloud Functions for cost efficiency & scalability
class GoEngineService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final Logger _logger = Logger();

  // Configuration
  static const Duration _timeout = Duration(seconds: 15);
  static const int _maxRetries = 2;
  static const String _regionDefault = 'us-central1';

  /// Request AI move from GNU Go engine
  ///
  /// Parameters:
  /// - boardState: Current board position
  /// - aiLevel: Difficulty 1-10 (1=easiest, 10=hardest)
  /// - movesCount: How many moves have been played (for time management)
  Future<AIMove> requestAiMove({
    required _EngineBoardState boardState,
    required int aiLevel,
    int movesCount = 0,
  }) async {
    assert(aiLevel >= 1 && aiLevel <= 10, 'aiLevel must be 1-10');

    _logger.i('Requesting AI move: level=$aiLevel, boardSize=${boardState.boardSize}');

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final callable = _functions
            .httpsCallable('requestAiMove');

        final result = await callable.call({
          'boardState': _encodeBoardState(boardState),
          'aiLevel': aiLevel,
          'movesCount': movesCount,
          'boardSize': boardState.boardSize,
          'timeout': _timeout.inSeconds,
        }).timeout(_timeout);

        _logger.i('✅ AI move received: $result');
        return AIMove.fromJson(result.data as Map<String, dynamic>);
      } on FirebaseFunctionsException catch (e) {
        _logger.w('❌ Cloud Function error (attempt ${attempt + 1}/$_maxRetries): ${e.message}');

        if (attempt < _maxRetries) {
          // Exponential backoff: 1s, 2s, 4s
          final delayMs = Duration(milliseconds: 1000 * (1 << attempt));
          await Future.delayed(delayMs);
          continue;
        }

        rethrow;
      } on TimeoutException catch (e) {
        _logger.w('⏱️ Request timeout (attempt ${attempt + 1}/$_maxRetries): $e');

        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: 1000 * (1 << attempt)));
          continue;
        }

        throw GoEngineException('AI move request timed out after $_maxRetries retries', e);
      } catch (e) {
        _logger.e('🔥 Unexpected error: $e');
        rethrow;
      }
    }

    throw GoEngineException('Failed to get AI move after $_maxRetries retries');
  }

  /// Judge if game has ended and calculate score (Chinese rules)
  ///
  /// Returns:
  /// - gameEnded: true if both players pass or board is full
  /// - blackScore/whiteScore: Points including territory (Chinese rules)
  /// - winner: 'black', 'white', or 'draw'
  Future<GameEndResult> judgeGameEnd({
    required _EngineBoardState boardState,
    required bool lastPlayerPassed,
  }) async {
    _logger.i('Judging game end: boardSize=${boardState.boardSize}, lastPassed=$lastPlayerPassed');

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final callable = _functions
            .httpsCallable('judgeGameEnd');

        final result = await callable.call({
          'boardState': _encodeBoardState(boardState),
          'lastPlayerPassed': lastPlayerPassed,
          'boardSize': boardState.boardSize,
          'scoringMethod': 'chinese', // Always use Chinese rules
          'timeout': _timeout.inSeconds,
        }).timeout(_timeout);

        _logger.i('✅ Game judgment received: $result');
        return GameEndResult.fromJson(result.data as Map<String, dynamic>);
      } on FirebaseFunctionsException catch (e) {
        _logger.w('❌ Cloud Function error (attempt ${attempt + 1}/$_maxRetries): ${e.message}');

        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: 1000 * (1 << attempt)));
          continue;
        }

        rethrow;
      } on TimeoutException catch (e) {
        _logger.w('⏱️ Request timeout (attempt ${attempt + 1}/$_maxRetries): $e');

        if (attempt < _maxRetries) {
          await Future.delayed(Duration(milliseconds: 1000 * (1 << attempt)));
          continue;
        }

        throw GoEngineException('Game judgment timed out after $_maxRetries retries', e);
      } catch (e) {
        _logger.e('🔥 Unexpected error: $e');
        rethrow;
      }
    }

    throw GoEngineException('Failed to judge game end after $_maxRetries retries');
  }

  /// Validate a move (check if legal)
  ///
  /// Useful for quick client-side validation before sending to engine
  bool validateMove({
    required BoardState boardState,
    required int row,
    required int col,
  }) {
    if (row < 0 || row >= boardState.boardSize || col < 0 || col >= boardState.boardSize) {
      return false;
    }

    // Position must be empty
    if (boardState.stones[row][col] != -1) {
      return false;
    }

    return true;
  }

  /// Encode board state for Cloud Function transmission
  Map<String, dynamic> _encodeBoardState(_EngineBoardState state) {
    return {
      'boardSize': state.boardSize,
      'stones': state.stones.map((row) => row.toList()).toList(),
      'isPlayerBlack': state.isPlayerBlack,
    };
  }
}

/// Custom exception for Go engine errors
class GoEngineException implements Exception {
  final String message;
  final Object? originalException;

  GoEngineException(this.message, [this.originalException]);

  @override
  String toString() => 'GoEngineException: $message${originalException != null ? ' (caused by: $originalException)' : ''}';
}
