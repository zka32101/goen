import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/index.dart';

final _logger = Logger();

/// 実力マッチングEngine - レート差の近いプレイヤー同士を「運命の対戦」として結びつける
class MatchingService {
  final FirebaseFirestore _firestore;

  /// マッチ判定の許容レート差（この範囲内なら「縁がある」と判定）
  static const int maxRatingDiff = 200;

  MatchingService(this._firestore);

  Future<void> joinQueue({
    required String uid,
    required String displayName,
    required int rating,
    required int boardSize,
  }) async {
    try {
      await _firestore.collection('matchmaking_queue').doc(uid).set(
            MatchmakingQueueEntry(
              uid: uid,
              displayName: displayName,
              rating: rating,
              boardSize: boardSize,
              queuedAt: DateTime.now(),
              status: 'waiting',
            ).toFirestore(),
          );
      _logger.i('User $uid joined matchmaking queue (rating: $rating, boardSize: $boardSize)');
    } catch (e) {
      _logger.e('Error joining matchmaking queue: $e');
      rethrow;
    }
  }

  Future<void> leaveQueue(String uid) async {
    try {
      await _firestore.collection('matchmaking_queue').doc(uid).delete();
      _logger.i('User $uid left matchmaking queue');
    } catch (e) {
      _logger.e('Error leaving matchmaking queue: $e');
      rethrow;
    }
  }

  /// レート差が最も近い待機中プレイヤーを探し、マッチが見つかれば成立させる
  Future<MatchResult?> findMatch({
    required String uid,
    required String displayName,
    required int rating,
    required int boardSize,
  }) async {
    try {
      final snapshots = await _firestore
          .collection('matchmaking_queue')
          .where('boardSize', isEqualTo: boardSize)
          .where('status', isEqualTo: 'waiting')
          .get();

      MatchmakingQueueEntry? bestCandidate;
      int bestDiff = 1 << 30;

      for (final doc in snapshots.docs) {
        if (doc.id == uid) continue;
        final entry = MatchmakingQueueEntry.fromFirestore(doc);
        final diff = (entry.rating - rating).abs();
        if (diff <= maxRatingDiff && diff < bestDiff) {
          bestCandidate = entry;
          bestDiff = diff;
        }
      }

      if (bestCandidate == null) {
        _logger.i('No compatible match found for $uid yet');
        return null;
      }

      final matchRef = _firestore.collection('match_results').doc();
      final match = MatchResult(
        id: matchRef.id,
        player1Uid: uid,
        player1DisplayName: displayName,
        player1Rating: rating,
        player2Uid: bestCandidate.uid,
        player2DisplayName: bestCandidate.displayName,
        player2Rating: bestCandidate.rating,
        boardSize: boardSize,
        ratingDiff: bestDiff,
        createdAt: DateTime.now(),
      );

      final batch = _firestore.batch();
      batch.set(matchRef, match.toFirestore());
      batch.update(_firestore.collection('matchmaking_queue').doc(uid), {'status': 'matched'});
      batch.update(
        _firestore.collection('matchmaking_queue').doc(bestCandidate.uid),
        {'status': 'matched'},
      );
      await batch.commit();

      _logger.i('Match found: $uid <-> ${bestCandidate.uid} (rating diff: $bestDiff)');
      return match;
    } catch (e) {
      _logger.e('Error finding match: $e');
      rethrow;
    }
  }

  Future<List<MatchResult>> getMatchHistory(String uid, {int limit = 50}) async {
    try {
      final p1Snapshots = await _firestore
          .collection('match_results')
          .where('player1Uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();
      final p2Snapshots = await _firestore
          .collection('match_results')
          .where('player2Uid', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      final matches = [
        ...p1Snapshots.docs.map((doc) => MatchResult.fromFirestore(doc)),
        ...p2Snapshots.docs.map((doc) => MatchResult.fromFirestore(doc)),
      ];
      matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return matches.take(limit).toList();
    } catch (e) {
      _logger.e('Error getting match history: $e');
      rethrow;
    }
  }

  Future<void> attachGameToMatch(String matchId, String gameId) async {
    try {
      await _firestore.collection('match_results').doc(matchId).update({'gameId': gameId});
      _logger.i('Attached game $gameId to match $matchId');
    } catch (e) {
      _logger.e('Error attaching game to match: $e');
      rethrow;
    }
  }
}
