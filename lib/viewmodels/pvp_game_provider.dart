import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/leaderboard.dart';
import '../models/pvp_game.dart';
import '../services/pvp_game_service.dart';
import 'leaderboard_provider.dart';
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
      // happens inside _onGameFinished via game.isFinished.
      final accepted = await service.pass(gameId: gameId, uid: uid);
      if (accepted) {
        await _onGameFinished(ref, service, gameId);
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
      await _onGameFinished(ref, service, gameId);
    } catch (e) {
      _logger.e('Error resigning PvP game: $e');
      rethrow;
    }
  };
});

/// 対局が終局していれば、Eloレーティングの反映とトーナメント結果報告
/// （紐づいていれば）を行う。それぞれ独立してbest-effortで処理し、
/// 片方の失敗が他方をブロックしたり対局そのものの完了を妨げたりしない。
Future<void> _onGameFinished(
  Ref ref,
  PvpGameService service,
  String gameId,
) async {
  PvpGame? game;
  try {
    game = await service.getGame(gameId);
  } catch (e) {
    _logger.w('Failed to fetch finished game (non-fatal): $e');
    return;
  }
  if (game == null || !game.isFinished) return;

  try {
    await _updateEloRatings(ref, game);
  } catch (e) {
    _logger.w('Failed to update Elo ratings (non-fatal): $e');
  }

  if (game.tournamentId == null || game.tournamentMatchId == null || game.winnerUid == null) {
    return; // 未紐付け、または引き分けならトーナメント結果は反映しない
  }
  try {
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

/// 終局したPvP対局の結果を標準的なElo式でレーティングに反映する
/// （K=32固定）。leaderboards/all_time/rating/{uid} を読み書きする —
/// daily/weekly/monthly はリセット機構（Cloud Functions相当）がまだ
/// 無いため対象外（更新するとリセットされないまま累積するだけになる）。
Future<void> _updateEloRatings(Ref ref, PvpGame game) async {
  const kFactor = 32;
  final leaderboardService = ref.read(leaderboardServiceProvider);
  final incrementStats = ref.read(incrementUserStatsProvider);

  final blackEntry = await leaderboardService.getUserRank(
    uid: game.blackUid,
    period: LeaderboardPeriod.allTime,
    type: LeaderboardType.rating,
  );
  final whiteEntry = await leaderboardService.getUserRank(
    uid: game.whiteUid,
    period: LeaderboardPeriod.allTime,
    type: LeaderboardType.rating,
  );
  final blackRating = blackEntry?.rating ?? 1200;
  final whiteRating = whiteEntry?.rating ?? 1200;

  final double blackScore;
  if (game.winnerUid == game.blackUid) {
    blackScore = 1.0;
  } else if (game.winnerUid == game.whiteUid) {
    blackScore = 0.0;
  } else {
    blackScore = 0.5; // 引き分け
  }
  final whiteScore = 1.0 - blackScore;

  final expectedBlack = 1.0 / (1.0 + pow(10, (whiteRating - blackRating) / 400));
  final expectedWhite = 1.0 - expectedBlack;

  final newBlackRating = (blackRating + kFactor * (blackScore - expectedBlack)).round();
  final newWhiteRating = (whiteRating + kFactor * (whiteScore - expectedWhite)).round();

  await incrementStats(
    uid: game.blackUid,
    displayName: game.blackDisplayName,
    period: LeaderboardPeriod.allTime,
    type: LeaderboardType.rating,
    newRating: newBlackRating,
    gamesPlayedDelta: 1,
    winsDelta: blackScore == 1.0 ? 1 : 0,
  );
  await incrementStats(
    uid: game.whiteUid,
    displayName: game.whiteDisplayName,
    period: LeaderboardPeriod.allTime,
    type: LeaderboardType.rating,
    newRating: newWhiteRating,
    gamesPlayedDelta: 1,
    winsDelta: whiteScore == 1.0 ? 1 : 0,
  );
  _logger.i(
    'Elo updated: black ${game.blackUid} $blackRating->$newBlackRating, '
    'white ${game.whiteUid} $whiteRating->$newWhiteRating',
  );
}
