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

  /// 試合結果を記録
  Future<void> recordMatchResult({
    required String tournamentId,
    required String matchId,
    required String winnerUid,
  }) async {
    try {
      _logger.i('Recording match result: $matchId');

      await _firestore
          .collection(tournamentsCollection)
          .doc(tournamentId)
          .collection(matchesCollection)
          .doc(matchId)
          .update({
        'winnerUid': winnerUid,
        'status': 'completed',
        'completedAt': Timestamp.now(),
      });

      _logger.i('✅ Match result recorded');
    } catch (e) {
      _logger.e('Error recording match result: $e');
      rethrow;
    }
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
