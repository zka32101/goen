import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/pvp_game.dart';
import '../services/pvp_game_service.dart';

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
      return await service.pass(gameId: gameId, uid: uid);
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
    } catch (e) {
      _logger.e('Error resigning PvP game: $e');
      rethrow;
    }
  };
});
