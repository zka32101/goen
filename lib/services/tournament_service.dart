import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/tournament.dart';

final _logger = Logger();

/// トーナメント管理サービス
class TournamentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String tournamentsCollection = 'tournaments';
  static const String participantsCollection = 'participants';
  static const String matchesCollection = 'matches';

  /// トーナメント作成
  Future<Tournament?> createTournament({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required int maxParticipants,
    required String format,
  }) async {
    try {
      _logger.i('Creating tournament: $name');

      final docRef = _firestore.collection(tournamentsCollection).doc();
      final tournament = Tournament(
        id: docRef.id,
        name: name,
        description: description,
        startDate: startDate,
        endDate: endDate,
        maxParticipants: maxParticipants,
        format: format,
        status: 'upcoming',
        participantUids: [],
        createdAt: DateTime.now(),
      );

      await docRef.set(tournament.toFirestore());
      _logger.i('✅ Tournament created: ${docRef.id}');
      return tournament;
    } catch (e) {
      _logger.e('Error creating tournament: $e');
      rethrow;
    }
  }

  /// トーナメントに参加
  Future<bool> joinTournament({
    required String tournamentId,
    required String uid,
    required String displayName,
  }) async {
    try {
      _logger.i('Joining tournament: $tournamentId');

      final tournamentRef =
          _firestore.collection(tournamentsCollection).doc(tournamentId);
      final tournamentDoc = await tournamentRef.get();

      if (!tournamentDoc.exists) {
        throw Exception('Tournament not found');
      }

      final tournament = Tournament.fromFirestore(
          tournamentDoc as DocumentSnapshot<Map<String, dynamic>>);

      if (tournament.isFull) {
        throw Exception('Tournament is full');
      }

      // Add participant
      await tournamentRef.collection(participantsCollection).doc(uid).set({
        'tournamentId': tournamentId,
        'displayName': displayName,
        'seed': tournament.participantUids.length + 1,
        'currentRound': 1,
        'joinedAt': Timestamp.now(),
      });

      // Update participant list in tournament
      await tournamentRef.update({
        'participantUids': FieldValue.arrayUnion([uid]),
      });

      _logger.i('✅ User joined tournament');
      return true;
    } catch (e) {
      _logger.e('Error joining tournament: $e');
      rethrow;
    }
  }

  /// トーナメントを開始し、参加者から1回戦のブラケットを生成する。
  /// 現状シングルエリミネーション形式のみ対応（round_robin/swissは未実装）。
  /// 参加者が奇数なら最後の1人は不戦勝として自動的に2回戦へ進む。
  Future<void> startTournament(String tournamentId) async {
    try {
      final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);
      final tournamentDoc = await tournamentRef.get();
      if (!tournamentDoc.exists) throw Exception('Tournament not found');

      final tournament = Tournament.fromFirestore(
          tournamentDoc as DocumentSnapshot<Map<String, dynamic>>);
      if (tournament.format != 'single_elimination') {
        throw Exception('${tournament.format} is not yet supported for automatic bracket generation');
      }
      if (tournament.participantUids.length < 2) {
        throw Exception('Not enough participants to start');
      }

      final participantsSnapshot =
          await tournamentRef.collection(participantsCollection).get();
      final displayNames = <String, String>{
        for (final doc in participantsSnapshot.docs)
          doc.id: (doc.data()['displayName'] as String?) ?? 'Player',
      };

      await _generateRound(
        tournamentId: tournamentId,
        round: 1,
        playerUids: List<String>.from(tournament.participantUids),
        displayNames: displayNames,
      );

      await tournamentRef.update({'status': 'active'});
      // 稀なケース（全員不戦勝で1ラウンド目が即完了）でも進行が止まらないようにする。
      await _advanceRoundIfComplete(tournamentId: tournamentId, round: 1);
      _logger.i('✅ Tournament started with round 1 bracket: $tournamentId');
    } catch (e) {
      _logger.e('Error starting tournament: $e');
      rethrow;
    }
  }

  /// プレイヤーのリストからペアを作り、指定ラウンドの試合を生成する。
  /// 奇数なら最後の1人を不戦勝として即座に勝者確定させる。
  Future<void> _generateRound({
    required String tournamentId,
    required int round,
    required List<String> playerUids,
    required Map<String, String> displayNames,
  }) async {
    final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (var i = 0; i < playerUids.length; i += 2) {
      final player1Uid = playerUids[i];
      final hasOpponent = i + 1 < playerUids.length;
      final player2Uid = hasOpponent ? playerUids[i + 1] : null;

      final matchRef = tournamentRef.collection(matchesCollection).doc();
      final match = TournamentMatch(
        id: matchRef.id,
        tournamentId: tournamentId,
        player1Uid: player1Uid,
        player1DisplayName: displayNames[player1Uid],
        player2Uid: player2Uid,
        player2DisplayName: player2Uid != null ? displayNames[player2Uid] : null,
        round: round,
        // 不戦勝は即座に完了扱いにする。
        winnerUid: hasOpponent ? null : player1Uid,
        status: hasOpponent ? 'pending' : 'completed',
        scheduledAt: now,
        completedAt: hasOpponent ? null : now,
      );
      batch.set(matchRef, match.toFirestore());
    }

    await batch.commit();
    _logger.i('Generated round $round with ${(playerUids.length / 2).ceil()} matches for $tournamentId');
  }

  /// 対局が紐づく試合に勝者を紐付ける。実際のPvpGame作成はプロバイダー層が行う。
  Future<void> attachGameToMatch({
    required String tournamentId,
    required String matchId,
    required String gameId,
  }) async {
    try {
      await _firestore
          .collection(tournamentsCollection)
          .doc(tournamentId)
          .collection(matchesCollection)
          .doc(matchId)
          .update({'gameId': gameId, 'status': 'in_progress'});
    } catch (e) {
      _logger.e('Error attaching game to tournament match: $e');
      rethrow;
    }
  }

  /// トーナメント試合取得
  Future<List<TournamentMatch>> getTournamentMatches({
    required String tournamentId,
    int? round,
  }) async {
    try {
      _logger.i('Fetching matches for tournament: $tournamentId');

      var query = _firestore
          .collection(tournamentsCollection)
          .doc(tournamentId)
          .collection(matchesCollection)
          .orderBy('round')
          .orderBy('scheduledAt');

      if (round != null) {
        query = query.where('round', isEqualTo: round) as Query;
      }

      final snapshot = await query.get();
      final matches = snapshot.docs
          .map((doc) => TournamentMatch.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      _logger.i('✅ Matches fetched: ${matches.length}');
      return matches;
    } catch (e) {
      _logger.e('Error fetching matches: $e');
      rethrow;
    }
  }

  /// 試合結果を記録する。そのラウンドの全試合が完了していれば、
  /// 勝者同士で次ラウンドを自動生成する。決勝が完了していれば
  /// トーナメント自体を完了にし、優勝者を確定する。
  Future<void> recordMatchResult({
    required String tournamentId,
    required String matchId,
    required String winnerUid,
  }) async {
    try {
      _logger.i('Recording match result: $matchId');

      final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);
      final matchRef = tournamentRef.collection(matchesCollection).doc(matchId);
      final matchDoc = await matchRef.get();
      if (!matchDoc.exists) throw Exception('Match not found: $matchId');
      final round = (matchDoc.data()?['round'] as int?) ?? 1;

      await matchRef.update({
        'winnerUid': winnerUid,
        'status': 'completed',
        'completedAt': Timestamp.now(),
      });
      _logger.i('✅ Match result recorded');

      await _advanceRoundIfComplete(tournamentId: tournamentId, round: round);
    } catch (e) {
      _logger.e('Error recording match result: $e');
      rethrow;
    }
  }

  /// 指定ラウンドの全試合が完了していれば、勝者同士で次ラウンドを生成する。
  /// 勝者が1人だけならその人が優勝者としてトーナメントを完了させる。
  Future<void> _advanceRoundIfComplete({
    required String tournamentId,
    required int round,
  }) async {
    final tournamentRef = _firestore.collection(tournamentsCollection).doc(tournamentId);
    final roundMatchesSnapshot = await tournamentRef
        .collection(matchesCollection)
        .where('round', isEqualTo: round)
        .get();
    final roundMatches = roundMatchesSnapshot.docs
        .map((doc) => TournamentMatch.fromFirestore(
            doc as DocumentSnapshot<Map<String, dynamic>>))
        .toList();

    if (roundMatches.isEmpty || roundMatches.any((m) => !m.isCompleted)) {
      return; // まだ全試合が終わっていない
    }

    final winners = roundMatches.map((m) => m.winnerUid).whereType<String>().toList();

    if (winners.length <= 1) {
      final championUid = winners.isNotEmpty ? winners.first : null;
      await tournamentRef.update({
        'status': 'completed',
        'winnerId': championUid,
      });
      _logger.i('🏆 Tournament completed: $tournamentId winner=$championUid');
      return;
    }

    final displayNames = <String, String>{
      for (final m in roundMatches) ...{
        if (m.player1Uid != null) m.player1Uid!: m.player1DisplayName ?? 'Player',
        if (m.player2Uid != null) m.player2Uid!: m.player2DisplayName ?? 'Player',
      },
    };

    await _generateRound(
      tournamentId: tournamentId,
      round: round + 1,
      playerUids: winners,
      displayNames: displayNames,
    );
    _logger.i('Advanced $tournamentId to round ${round + 1} with ${winners.length} players');
  }

  /// アクティブなトーナメント一覧
  Future<List<Tournament>> getActiveTournaments() async {
    try {
      _logger.i('Fetching active tournaments');

      final snapshot = await _firestore
          .collection(tournamentsCollection)
          .where('status', whereIn: ['active', 'upcoming'])
          .orderBy('startDate')
          .get();

      final tournaments = snapshot.docs
          .map((doc) => Tournament.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      _logger.i('✅ Active tournaments fetched: ${tournaments.length}');
      return tournaments;
    } catch (e) {
      _logger.e('Error fetching active tournaments: $e');
      rethrow;
    }
  }

  /// ユーザーが参加しているトーナメント
  Future<List<Tournament>> getUserTournaments(String uid) async {
    try {
      _logger.i('Fetching user tournaments: $uid');

      final snapshot = await _firestore
          .collection(tournamentsCollection)
          .where('participantUids', arrayContains: uid)
          .get();

      final tournaments = snapshot.docs
          .map((doc) => Tournament.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      _logger.i('✅ User tournaments fetched: ${tournaments.length}');
      return tournaments;
    } catch (e) {
      _logger.e('Error fetching user tournaments: $e');
      rethrow;
    }
  }
}
