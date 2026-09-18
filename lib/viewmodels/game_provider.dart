import 'package:riverpod/riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/services/index.dart';
import 'package:goen/services/fuego_engine_service.dart';
import 'package:goen/services/go_rules.dart';

final _logger = Logger();

// ================== SERVICE PROVIDERS ==================

/// Singleton instance of Fuego AI Engine (On-device)
/// Lightweight, fast, offline-capable Go engine
final aiEngineServiceProvider = Provider<FuegoEngineService>((ref) {
  return FuegoEngineService();
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

/// How many passes have been played in a row (resets to 0 the moment
/// either side places a stone). Two in a row ends the game.
final consecutivePassesProvider = StateProvider<int>((ref) {
  return 0;
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

/// Request AI move from Fuego engine (On-device)
/// Fast (~200-400ms), offline-capable.
///
/// Returns null when it isn't the AI's turn yet. Reads (rather than
/// watches) board/level/move-count so this only recomputes when explicitly
/// invalidated by the caller after a legal player move — otherwise every
/// board mutation (including the AI's own move) would re-trigger a new
/// request and risk the AI racing against itself.
final aiMoveProvider = FutureProvider.autoDispose<AIMove?>((ref) async {
  final boardState = ref.read(gameBoardStateProvider);

  // The human always plays black in this screen; nothing to compute
  // until it's white's (the AI's) turn.
  if (boardState.isBlackTurn) {
    return null;
  }

  final aiLevel = ref.read(aiLevelProvider);
  final movesCount = ref.read(movesCountProvider);

  _logger.i('🎯 Fuego: AI move request (level=$aiLevel, size=${boardState.boardSize})');

  final aiEngine = ref.read(aiEngineServiceProvider);
  try {
    final aiMove = await aiEngine.requestAiMove(
      boardSize: boardState.boardSize,
      stones: boardState.stones,
      isPlayerBlack: true,
      aiLevel: aiLevel,
      movesCount: movesCount,
    );
    _logger.i('✅ Fuego response: $aiMove');
    return aiMove;
  } catch (e) {
    _logger.e('❌ Fuego request failed: $e');
    rethrow;
  }
});

// ================== GAME LOGIC ==================

/// Validate if a move is legal (client-side check): occupancy, suicide,
/// and simple ko, for whichever color's turn it currently is.
final validateMoveProvider = Provider.family<bool, ({int row, int col})>(
  (ref, params) {
    final boardState = ref.watch(gameBoardStateProvider);
    final aiEngine = ref.watch(aiEngineServiceProvider);
    final player = boardState.isBlackTurn ? 1 : 2;
    return aiEngine.validateMove(
      boardSize: boardState.boardSize,
      stones: boardState.stones,
      row: params.row,
      col: params.col,
      player: player,
      koRow: boardState.koRow,
      koCol: boardState.koCol,
    );
  },
);

/// Attempts to play a stone at (row, col) for whichever color's turn it
/// currently is. On success, applies captures, flips the turn, updates the
/// ko point, records history, and returns true. Returns false (without any
/// state change) if the move is illegal.
final applyMoveProvider = Provider<bool Function(int row, int col)>((ref) {
  return (row, col) {
    final board = ref.read(gameBoardStateProvider);
    final player = board.isBlackTurn ? 1 : 2;

    final result = GoRules.applyMove(
      stones: board.stones,
      boardSize: board.boardSize,
      row: row,
      col: col,
      player: player,
      koRow: board.koRow,
      koCol: board.koCol,
    );

    if (result == null) {
      _logger.w('Illegal move rejected: player=$player [$row,$col]');
      return false;
    }

    ref.read(gameBoardStateProvider.notifier).state = board.copyWith(
      stones: result.stones,
      capturedBlack: player == 2 ? board.capturedBlack + result.capturedCount : null,
      capturedWhite: player == 1 ? board.capturedWhite + result.capturedCount : null,
      isBlackTurn: !board.isBlackTurn,
      lastMoveRow: row,
      lastMoveCol: col,
      koRow: result.koRow,
      koCol: result.koCol,
    );

    ref.read(addMoveProvider)(row, col, player == 1 ? 'black' : 'white');

    // A real move breaks any run of passes.
    ref.read(consecutivePassesProvider.notifier).state = 0;
    ref.read(lastPlayerPassedProvider.notifier).state = false;

    _logger.i(
      '✅ Move applied: player=$player [$row,$col] captured=${result.capturedCount}',
    );
    return true;
  };
});

/// Passes for whichever color's turn it currently is: flips the turn,
/// clears any ko restriction, and increments the consecutive-pass count.
/// Returns true when this was the second consecutive pass, meaning the
/// game has now ended.
final applyPassProvider = Provider<bool Function()>((ref) {
  return () {
    final board = ref.read(gameBoardStateProvider);
    final player = board.isBlackTurn ? 1 : 2;

    ref.read(gameBoardStateProvider.notifier).state = board.copyWith(
      isBlackTurn: !board.isBlackTurn,
      koRow: null,
      koCol: null,
    );

    ref.read(lastPlayerPassedProvider.notifier).state = true;
    final passes = ref.read(consecutivePassesProvider.notifier).state + 1;
    ref.read(consecutivePassesProvider.notifier).state = passes;

    _logger.i('Pass: player=$player consecutivePasses=$passes');
    return passes >= 2;
  };
});

/// Judge if game has ended and calculate score (Fuego).
/// Only runs when explicitly read/invalidated (e.g. after both players
/// pass) — it does not watch board state, since that would re-run scoring
/// on every single stone placed.
final judgeGameEndProvider = FutureProvider.autoDispose<GameEndResult>((ref) async {
  final boardState = ref.read(gameBoardStateProvider);
  final lastPlayerPassed = ref.read(lastPlayerPassedProvider);

  _logger.i('🏁 Fuego: Game end judgment (size=${boardState.boardSize})');

  final aiEngine = ref.read(aiEngineServiceProvider);
  try {
    final result = await aiEngine.judgeGameEnd(
      boardSize: boardState.boardSize,
      stones: boardState.stones,
      isPlayerBlack: true,
      lastPlayerPassed: lastPlayerPassed,
    );
    _logger.i('✅ Fuego judgment: $result');
    return result;
  } catch (e) {
    _logger.e('❌ Fuego judgment failed: $e');
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

/// Save the just-finished game to Firestore.
///
/// This is a plain action (like [applyMoveProvider]/[applyPassProvider]),
/// not a `FutureProvider.family` — a family provider caches by its
/// argument value, so two different games with the same
/// (uid, boardSize, result) tuple (e.g. two 9x9 wins in a row) would
/// collide and the second "Save Game" tap would silently return the
/// first game's cached result instead of writing the new one.
final saveGameRecordProvider = Provider<
    Future<String> Function({
      required String uid,
      required int boardSize,
      required String result,
    })>((ref) {
  return ({required uid, required boardSize, required result}) async {
    _logger.i('Saving game record for user: $uid');

    final boardState = ref.read(gameBoardStateProvider);
    final aiLevel = ref.read(aiLevelProvider);
    final movesCount = ref.read(movesCountProvider);

    // Generate SGF from board state
    final sgfData = boardState.toSgf();

    final gameRecord = GameRecord(
      id: '', // Firestore will auto-generate
      uid: uid,
      boardSize: boardSize,
      sgfData: sgfData,
      result: _parseResult(result),
      aiLevel: aiLevel,
      playedAt: DateTime.now(),
      movesCount: movesCount,
      gameDuration: Duration.zero, // TBD: track actual duration
    );

    final firestoreService = ref.read(firestoreServiceProvider);
    try {
      final gameId = await firestoreService.saveGameRecord(gameRecord);
      _logger.i('✅ Game record saved: $gameId');
      return gameId;
    } catch (e) {
      _logger.e('❌ Game record save failed: $e');
      rethrow;
    }
  };
});

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
    case 'resign':
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

// ================== POSITION EVALUATION ==================

/// Evaluate current board position (形勢評価)
/// Returns score difference and assessment
final positionEvaluationProvider = FutureProvider.autoDispose<({double scoreDiff, String assessment, double blackWinProb})>((ref) async {
  final boardState = ref.watch(gameBoardStateProvider);

  _logger.i('📊 Position evaluation request (size=${boardState.boardSize})');

  final aiEngine = ref.watch(aiEngineServiceProvider);
  try {
    final evaluation = await aiEngine.evaluatePosition(
      stones: boardState.stones,
      boardSize: boardState.boardSize,
    );
    _logger.i('✅ Evaluation: ${evaluation.assessment}');

    return (
      scoreDiff: evaluation.scoreDiff,
      assessment: evaluation.assessment,
      blackWinProb: evaluation.blackWinProbability,
    );
  } catch (e) {
    _logger.e('❌ Evaluation failed: $e');
    rethrow;
  }
});

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
