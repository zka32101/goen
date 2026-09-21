import 'package:riverpod/riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/leaderboard.dart';
import 'package:goen/models/tournament.dart';
import 'package:goen/services/tournament_service.dart';
import 'leaderboard_provider.dart';

final _logger = Logger();

/// Tournament Service プロバイダー
final tournamentServiceProvider = Provider<TournamentService>((ref) {
  return TournamentService();
});

/// アクティブなトーナメント一覧
final activeTournamentsProvider = FutureProvider<List<Tournament>>((ref) async {
  _logger.i('Loading active tournaments');
  final service = ref.watch(tournamentServiceProvider);

  try {
    final tournaments = await service.getActiveTournaments();
    _logger.i('✅ Active tournaments loaded: ${tournaments.length}');
    return tournaments;
  } catch (e) {
    _logger.e('❌ Failed to load tournaments: $e');
    rethrow;
  }
});

/// ユーザーが参加しているトーナメント
final userTournamentsProvider = FutureProvider.family<List<Tournament>, String>(
  (ref, uid) async {
    _logger.i('Loading user tournaments: $uid');
    final service = ref.watch(tournamentServiceProvider);

    try {
      final tournaments = await service.getUserTournaments(uid);
      _logger.i('✅ User tournaments loaded: ${tournaments.length}');
      return tournaments;
    } catch (e) {
      _logger.e('❌ Failed to load user tournaments: $e');
      rethrow;
    }
  },
);

/// トーナメント試合リスト
final tournamentMatchesProvider = FutureProvider.family<List<TournamentMatch>,
    ({String tournamentId, int? round})>((ref, params) async {
  _logger.i('Loading matches for tournament: ${params.tournamentId}');
  final service = ref.watch(tournamentServiceProvider);

  try {
    final matches = await service.getTournamentMatches(
      tournamentId: params.tournamentId,
      round: params.round,
    );
    _logger.i('✅ Matches loaded: ${matches.length}');
    return matches;
  } catch (e) {
    _logger.e('❌ Failed to load matches: $e');
    rethrow;
  }
});

/// トーナメント作成
final createTournamentProvider = Provider<
    Future<Tournament?> Function({
      required String name,
      required String description,
      required DateTime startDate,
      required DateTime endDate,
      required int maxParticipants,
      required String format,
      required String createdByUid,
      int boardSize,
    })>((ref) {
  final service = ref.read(tournamentServiceProvider);

  return ({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int maxParticipants,
    required String format,
    required String createdByUid,
    int boardSize = 19,
  }) async {
    _logger.i('Creating tournament');
    try {
      final tournament = await service.createTournament(
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        maxParticipants: maxParticipants,
        format: format,
        createdByUid: createdByUid,
        boardSize: boardSize,
      );
      _logger.i('✅ Tournament created');
      return tournament;
    } catch (e) {
      _logger.e('❌ Failed to create tournament: $e');
      rethrow;
    }
  };
});

/// トーナメント開始（1回戦のブラケットを自動生成し、statusをactiveへ）
final startTournamentProvider = Provider<Future<void> Function(String)>((ref) {
  final service = ref.read(tournamentServiceProvider);

  return (String tournamentId) async {
    _logger.i('Starting tournament: $tournamentId');
    try {
      await service.startTournament(tournamentId);
      _logger.i('✅ Tournament started');
    } catch (e) {
      _logger.e('❌ Failed to start tournament: $e');
      rethrow;
    }
  };
});

/// トーナメント参加
final joinTournamentProvider = Provider<
    Future<bool> Function({
      required String tournamentId,
      required String uid,
      required String displayName,
    })>((ref) {
  final service = ref.read(tournamentServiceProvider);

  return ({
    required String tournamentId,
    required String uid,
    required String displayName,
  }) async {
    _logger.i('Joining tournament');
    try {
      final success = await service.joinTournament(
        tournamentId: tournamentId,
        uid: uid,
        displayName: displayName,
      );
      _logger.i('✅ Tournament joined');
      return success;
    } catch (e) {
      _logger.e('❌ Failed to join tournament: $e');
      rethrow;
    }
  };
});

/// 試合結果記録
final recordMatchResultProvider = Provider<
    Future<void> Function({
      required String tournamentId,
      required String matchId,
      required String winnerUid,
    })>((ref) {
  final service = ref.read(tournamentServiceProvider);

  return ({
    required String tournamentId,
    required String matchId,
    required String winnerUid,
  }) async {
    _logger.i('Recording match result');
    try {
      await service.recordMatchResult(
        tournamentId: tournamentId,
        matchId: matchId,
        winnerUid: winnerUid,
      );
      _logger.i('✅ Match result recorded');
      await _reflectTournamentWinIfCompleted(ref, service, tournamentId);
    } catch (e) {
      _logger.e('❌ Failed to record match result: $e');
      rethrow;
    }
  };
});

/// このトーナメントがこの試合結果でちょうど完結したなら（優勝者が確定
/// したなら）、リーダーボード(tournamentタイプ)に反映する。LeaderboardType.
/// tournament は宣言以来一度も配線されておらず、常に空だった。
/// Best-effort: never blocks the (already successful) match-result save.
Future<void> _reflectTournamentWinIfCompleted(
  Ref ref,
  TournamentService service,
  String tournamentId,
) async {
  try {
    final tournament = await service.getTournament(tournamentId);
    if (tournament == null || tournament.status != 'completed' || tournament.winnerId == null) {
      return;
    }
    await ref.read(incrementUserStatsProvider)(
      uid: tournament.winnerId!,
      displayName: 'Player',
      period: LeaderboardPeriod.allTime,
      type: LeaderboardType.tournament,
      tournamentWinsDelta: 1,
    );
    _logger.i('🏆 Tournament win reflected on leaderboard: ${tournament.winnerId}');
  } catch (e) {
    _logger.w('Failed to reflect tournament win on leaderboard (non-fatal): $e');
  }
}
