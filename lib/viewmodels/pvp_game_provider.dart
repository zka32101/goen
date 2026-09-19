import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/pvp_game.dart';
import '../services/pvp_game_service.dart';
import 'tournament_provider.dart';

final _logger = Logger();

final pvpGameServiceProvider = Provider((ref) {
  return PvpGameService(FirebaseFirestore.instance);
});

/// 対局のリアルタイム盤面（両対局者・観戦者共通で購読）
final pvpGameStreamProvider =
    StreamProvider.family<PvpGame?, String>((ref, gameId) {
  final service = ref.watch(pvpGameServiceProvider);
  return service.streamGame(gameId);
});

/// ユーザーが参加中の対局一覧
final userActivePvpGamesProvider =
    FutureProvider.family<List<PvpGame>, String>((ref, uid) async {
  final service = ref.watch(pvpGameServiceProvider);
  try {
    final games = await service.getUserActiveGames(uid);
    _logger.i('Fetched ${games.length} active PvP games for $uid');
    return games;
  } catch (e) {
    _logger.e('Error fetching active PvP games: $e');
    rethrow;
  }
});

final createPvpGameProvider = Provider((ref) {
  return (
    int boardSize,
    String blackUid,
    String blackDisplayName,
    String whiteUid,
    String whiteDisplayName, {
    String? matchId,
  }) async {
    final service = ref.watch(pvpGameServiceProvider);
    try {
      final game = await service.createGame(
        boardSize: boardSize,
        blackUid: blackUid,
        blackDisplayName: blackDisplayName,
        whiteUid: whiteUid,
        whiteDisplayName: whiteDisplayName,
        matchId: matchId,
      );
      _logger.i('Created PvP game: ${game.id}');
      return game;
    } catch (e) {
      _logger.e('Error creating PvP game: $e');
      rethrow;
    }
  };
});

/// トーナメント試合用の対局作成。両対局者がほぼ同時に開始しても
/// 対局が2つ作られないよう、Firestoreトランザクションで排他制御される
/// （PvpGameService.createGameForTournamentMatch参照）。
final createTournamentGameProvider = Provider((ref) {
  return (
    String tournamentId,
    String matchId,
    int boardSize,
    String blackUid,
    String blackDisplayName,
    String whiteUid,
    String whiteDisplayName,
  ) async {
    final service = ref.watch(pvpGameServiceProvider);
    try {
      final gameId = await service.createGameForTournamentMatch(
        tournamentId: tournamentId,
        matchId: matchId,
        boardSize: boardSize,
        blackUid: blackUid,
        blackDisplayName: blackDisplayName,
        whiteUid: whiteUid,
        whiteDisplayName: whiteDisplayName,
      );
      _logger.i('Tournament game ready: $gameId');
      return gameId;
    } catch (e) {
      _logger.e('Error creating tournament game: $e');
      rethrow;
    }
  };
});

final applyPvpMoveProvider = Provider((ref) {
  return (String gameId, String uid, int row, int col) async {
    final service = ref.watch(pvpGameServiceProvider);
    try {
      return await service.applyMove(gameId: gameId, uid: uid, row: row, col: col);
    } catch (e) {
      _logger.e('Error applying PvP move: $e');
      rethrow;
    }
  };
});

final passPvpGameProvider = Provider((ref) {
  return (String gameId, String uid) async {
    final service = ref.watch(pvpGameServiceProvider);
    try {
      // pass()'s return value is whether the pass itself was accepted
      // (legal turn), not whether it ended the game — the game-over check
      // happens inside _reportTournamentResultIfNeeded via game.isFinished.
      final accepted = await service.pass(gameId: gameId, uid: uid);
      if (accepted) {
        await _reportTournamentResultIfNeeded(ref, service, gameId);
      }
      return accepted;
    } catch (e) {
      _logger.e('Error passing PvP game: $e');
      rethrow;
    }
  };
});

final resignPvpGameProvider = Provider((ref) {
  return (String gameId, String uid) async {
    final service = ref.watch(pvpGameServiceProvider);
    try {
      await service.resign(gameId: gameId, uid: uid);
      _logger.i('Resigned PvP game: $gameId');
      await _reportTournamentResultIfNeeded(ref, service, gameId);
    } catch (e) {
      _logger.e('Error resigning PvP game: $e');
      rethrow;
    }
  };
});

/// 対局がトーナメント試合に紐づいていれば、確定した勝者を
/// TournamentServiceへ反映する（ラウンド完結・次ラウンド生成のトリガー）。
Future<void> _reportTournamentResultIfNeeded(
  Ref ref,
  PvpGameService service,
  String gameId,
) async {
  try {
    final game = await service.getGame(gameId);
    if (game == null || game.tournamentId == null || game.tournamentMatchId == null) return;
    if (!game.isFinished || game.winnerUid == null) return; // 未終局、または引き分けなら反映しない

    final tournamentService = ref.read(tournamentServiceProvider);
    await tournamentService.recordMatchResult(
      tournamentId: game.tournamentId!,
      matchId: game.tournamentMatchId!,
      winnerUid: game.winnerUid!,
    );
    _logger.i('Reported tournament result for match ${game.tournamentMatchId}');
  } catch (e) {
    _logger.w('Failed to report tournament result (non-fatal): $e');
  }
}
