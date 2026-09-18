import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/leaderboard.dart';

final _logger = Logger();

/// Leaderboard データベース操作サービス
class LeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String leaderboardCollection = 'leaderboards';

  /// ランキングを取得（期間・タイプ別）
  Future<List<LeaderboardEntry>> getLeaderboard({
    required LeaderboardPeriod period,
    required LeaderboardType type,
    int limit = 100,
  }) async {
    try {
      _logger.i('Fetching leaderboard: period=$period, type=$type');

      final query = _firestore
          .collection(leaderboardCollection)
          .doc(period.toShortString())
          .collection(type.toShortString())
          .orderBy('rank')
          .limit(limit);

      final snapshot = await query.get();
      final entries = snapshot.docs
          .map((doc) => LeaderboardEntry.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      _logger.i('✅ Leaderboard fetched: ${entries.length} entries');
      return entries;
    } catch (e) {
      _logger.e('Error fetching leaderboard: $e');
      rethrow;
    }
  }

  /// ユーザーのランキングを取得
  Future<LeaderboardEntry?> getUserRank({
    required String uid,
    required LeaderboardPeriod period,
    required LeaderboardType type,
  }) async {
    try {
      _logger.i('Fetching user rank: uid=$uid, period=$period, type=$type');

      final doc = await _firestore
          .collection(leaderboardCollection)
          .doc(period.toShortString())
          .collection(type.toShortString())
          .doc(uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      return LeaderboardEntry.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      _logger.e('Error fetching user rank: $e');
      rethrow;
    }
  }

  /// ランキングを更新（自動計算・バッチ更新）
  Future<void> updateLeaderboard({
    required LeaderboardPeriod period,
    required LeaderboardType type,
    required List<LeaderboardEntry> entries,
  }) async {
    try {
      _logger.i('Updating leaderboard: period=$period, type=$type');

      final batch = _firestore.batch();
      final collectionRef = _firestore
          .collection(leaderboardCollection)
          .doc(period.toShortString())
          .collection(type.toShortString());

      // ランク順にソート
      entries.sort((a, b) => a.rank.compareTo(b.rank));

      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i].copyWith(rank: i + 1);
        batch.set(collectionRef.doc(entry.uid), entry.toFirestore());
      }

      await batch.commit();
      _logger.i('✅ Leaderboard updated');
    } catch (e) {
      _logger.e('Error updating leaderboard: $e');
      rethrow;
    }
  }

  /// ユーザーのスコアを更新
  Future<void> updateUserScore({
    required String uid,
    required String displayName,
    required LeaderboardPeriod period,
    required LeaderboardType type,
    required int rating,
    required int gamesPlayed,
    required int wins,
    required int puzzlesSolved,
  }) async {
    try {
      _logger.i('Updating user score: uid=$uid, rating=$rating');

      final winRate = gamesPlayed > 0 ? wins / gamesPlayed : 0.0;

      final entry = LeaderboardEntry(
        uid: uid,
        displayName: displayName,
        rank: 0, // Will be recalculated by batch process
        rating: rating,
        gamesPlayed: gamesPlayed,
        wins: wins,
        winRate: winRate,
        puzzlesSolved: puzzlesSolved,
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection(leaderboardCollection)
          .doc(period.toShortString())
          .collection(type.toShortString())
          .doc(uid)
          .set(entry.toFirestore(), SetOptions(merge: true));

      _logger.i('✅ User score updated');
    } catch (e) {
      _logger.e('Error updating user score: $e');
      rethrow;
    }
  }

  /// 期間別ランキングをリセット
  Future<void> resetLeaderboard({
    required LeaderboardPeriod period,
    required LeaderboardType type,
  }) async {
    try {
      _logger.w('Resetting leaderboard: period=$period, type=$type');

      final snapshot = await _firestore
          .collection(leaderboardCollection)
          .doc(period.toShortString())
          .collection(type.toShortString())
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _logger.i('✅ Leaderboard reset');
    } catch (e) {
      _logger.e('Error resetting leaderboard: $e');
      rethrow;
    }
  }
}

extension on LeaderboardEntry {
  LeaderboardEntry copyWith({
    String? uid,
    String? displayName,
    int? rank,
    int? rating,
    int? gamesPlayed,
    int? wins,
    double? winRate,
    int? puzzlesSolved,
    DateTime? lastUpdated,
  }) {
    return LeaderboardEntry(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      rank: rank ?? this.rank,
      rating: rating ?? this.rating,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      winRate: winRate ?? this.winRate,
      puzzlesSolved: puzzlesSolved ?? this.puzzlesSolved,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
