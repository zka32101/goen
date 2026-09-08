import 'package:riverpod/riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/services/index.dart';

final _logger = Logger();

// ================== SERVICE PROVIDERS ==================

/// Singleton instance of GoEngineService
final goEngineServiceProvider = Provider<GoEngineService>((ref) {
  return GoEngineService();
});

/// Singleton instance of FirestoreService
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// ================== GAME STATE PROVIDERS ==================

/// Current game board state
/// Mutable state for live gameplay
final gameBoardStateProvider = StateProvider<BoardState>((ref) {
  return BoardState(
    boardSize: 9, // Default to 9x9
    stones: List.generate(9, (_) => List.filled(9, 0)),
    capturedBlack: 0,
    capturedWhite: 0,
    isBlackTurn: true,
  );
});

/// Current AI opponent difficulty (1-10)
final aiLevelProvider = StateProvider<int>((ref) {
  return 5; // Default to intermediate level
});

/// Number of moves played in current game
final movesCountProvider = StateProvider<int>((ref) {
  return 0;
});

/// Did the last player pass?
final lastPlayerPassedProvider = StateProvider<bool>((ref) {
  return false;
});

/// Is the game currently active?
final isGameActiveProvider = StateProvider<bool>((ref) {
  return false;
});

/// Current game result (null if game in progress)
final gameResultProvider = StateProvider<GameEndResult?>((ref) {
  return null;
});

// ================== AI MOVE REQUESTS ==================

/// Request AI move from Go engine
/// Depends on current board state and AI level
final aiMoveProvider = FutureProvider.autoDispose<AIMove>((ref) async {
  final boardState = ref.watch(gameBoardStateProvider);
  final aiLevel = ref.watch(aiLevelProvider);
  final movesCount = ref.watch(movesCountProvider);

  _logger.i('Requesting AI move: level=$aiLevel, boardSize=${boardState.boardSize}');

  final goEngineService = ref.watch(goEngineServiceProvider);
  try {
    final aiMove = await goEngineService.requestAiMove(
      boardSize: boardState.boardSize,
      stones: boardState.stones,
      isPlayerBlack: boardState.isBlackTurn,
      aiLevel: aiLevel,
      movesCount: movesCount,
    );
    _logger.i('✅ AI move received: $aiMove');
    return aiMove;
  } catch (e) {
    _logger.e('❌ AI move request failed: $e');
    rethrow;
  }
});

// ================== GAME LOGIC ==================

/// Validate if a move is legal (client-side check)
final validateMoveProvider = Provider.family<bool, ({int row, int col})>(
  (ref, params) {
    final boardState = ref.watch(gameBoardStateProvider);
    final goEngineService = ref.watch(goEngineServiceProvider);
    return goEngineService.validateMove(
      boardSize: boardState.boardSize,
      stones: boardState.stones,
      row: params.row,
      col: params.col,
    );
  },
);

/// Judge if game has ended and calculate score
final judgeGameEndProvider = FutureProvider.autoDispose<GameEndResult>((ref) async {
  final boardState = ref.watch(gameBoardStateProvider);
  final lastPlayerPassed = ref.watch(lastPlayerPassedProvider);

  _logger.i('Judging game end: boardSize=${boardState.boardSize}');

  final goEngineService = ref.watch(goEngineServiceProvider);
  try {
    final result = await goEngineService.judgeGameEnd(
      boardSize: boardState.boardSize,
      stones: boardState.stones,
      isPlayerBlack: boardState.isBlackTurn,
      lastPlayerPassed: lastPlayerPassed,
    );
    _logger.i('✅ Game judgment received: $result');
    return result;
  } catch (e) {
    _logger.e('❌ Game judgment failed: $e');
    rethrow;
  }
});

// ================== MOVE HISTORY ==================

/// Stores the sequence of moves in the current game
/// Used for SGF generation and replay
final moveHistoryProvider = StateProvider<List<({int row, int col, String player})>>((ref) {
  return [];
});

/// Add move to history and update board state
final addMoveProvider = Provider<void Function(int, int, String)>((ref) {
  return (row, col, player) {
    _logger.i('Adding move: $player at [$row, $col]');

    final history = ref.read(moveHistoryProvider);
    ref.read(moveHistoryProvider.notifier).state = [
      ...history,
      (row: row, col: col, player: player),
    ];

    // Update moves count
    ref.read(movesCountProvider.notifier).state++;

    _logger.i('✅ Move added to history');
  };
});

// ================== GAME RECORD SAVING ==================

/// Save completed game to Firestore
final saveGameRecordProvider = FutureProvider.family<String, ({String uid, int boardSize, String result})>(
  (ref, params) async {
    _logger.i('Saving game record for user: ${params.uid}');

    final boardState = ref.watch(gameBoardStateProvider);
    final aiLevel = ref.watch(aiLevelProvider);
    final movesCount = ref.watch(movesCountProvider);
    final moveHistory = ref.watch(moveHistoryProvider);

    // Generate SGF from board state
    final sgfData = boardState.toSgf();

    final gameRecord = GameRecord(
      id: '', // Firestore will auto-generate
      uid: params.uid,
      boardSize: params.boardSize,
      sgfData: sgfData,
      result: _parseResult(params.result),
      aiLevel: aiLevel,
      playedAt: DateTime.now(),
      movesCount: movesCount,
      gameDuration: Duration.zero, // TBD: track actual duration
    );

    final firestoreService = ref.watch(firestoreServiceProvider);
    try {
      final gameId = await firestoreService.saveGameRecord(gameRecord);
      _logger.i('✅ Game record saved: $gameId');
      return gameId;
    } catch (e) {
      _logger.e('❌ Game record save failed: $e');
      rethrow;
    }
  },
);

/// Helper: parse result string to GameResult enum
GameResult _parseResult(String result) {
  switch (result.toLowerCase()) {
    case 'win':
    case 'playerwin':
      return GameResult.playerWin;
    case 'lose':
    case 'aiwin':
      return GameResult.aiWin;
    case 'draw':
      return GameResult.draw;
    case 'resignation':
      return GameResult.resignation;
    default:
      return GameResult.unknown;
  }
}

// ================== GAME HISTORY ==================

/// Get user's game records (paginated)
final userGameRecordsProvider = FutureProvider.family<List<GameRecord>, String>(
  (ref, uid) async {
    _logger.i('Fetching game records for user: $uid');

    final firestoreService = ref.watch(firestoreServiceProvider);
    try {
      final records = await firestoreService.getUserGameRecords(uid, limit: 20);
      _logger.i('✅ Game records fetched: ${records.length}');
      return records;
    } catch (e) {
      _logger.e('❌ Failed to fetch game records: $e');
      rethrow;
    }
  },
);

/// Get specific game record by ID
final gameRecordProvider = FutureProvider.family<GameRecord?, String>(
  (ref, gameId) async {
    _logger.i('Fetching game record: $gameId');

    final firestoreService = ref.watch(firestoreServiceProvider);
    try {
      final record = await firestoreService.getGameRecord(gameId);
      _logger.i('✅ Game record fetched: $gameId');
      return record;
    } catch (e) {
      _logger.e('❌ Failed to fetch game record: $e');
      rethrow;
    }
  },
);

// ================== AI OPPONENT CONFIG ==================

/// Selected AI opponent configuration
final selectedAiConfigProvider = StateProvider<AIOpponentConfig>((ref) {
  return AIOpponentConfig.intermediate();
});

/// Switch AI difficulty preset
final setAiConfigProvider = Provider<void Function(AIOpponentConfig)>((ref) {
  return (config) {
    _logger.i('Switching AI config: level ${config.level}');
    ref.read(selectedAiConfigProvider.notifier).state = config;
    ref.read(aiLevelProvider.notifier).state = config.level;
  };
});
