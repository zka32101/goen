import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/extended_game_models.dart';

final _logger = Logger();

/// Service for managing leaderboards and rankings
class LeaderboardService {
  final FirebaseFirestore _firestore;

  const LeaderboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _firestoreInstance;

  static final _firestoreInstance = FirebaseFirestore.instance;

  /// Update leaderboard entry
  Future<bool> updateLeaderboardEntry({
    required String userId,
    required String displayName,
    required double rating,
    required int wins,
    required int losses,
    required int totalGames,
    required String period,
    String? avatarUrl,
  }) async {
    try {
      _logger.i('Updating leaderboard entry for: $userId in period: $period');

      final winRate = totalGames > 0 ? (wins / totalGames) * 100 : 0.0;

      await _firestore
          .collection('leaderboards')
          .doc(period)
          .collection('entries')
          .doc(userId)
          .set({
        'userId': userId,
        'displayName': displayName,
        'rating': rating,
        'wins': wins,
        'losses': losses,
        'totalGames': totalGames,
        'winRate': winRate,
        'avatarUrl': avatarUrl ?? '',
        'updatedAt': DateTime.now(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      _logger.e('Failed to update leaderboard entry: $e');
      return false;
    }
  }

  /// Get top players
  Future<List<LeaderboardEntry>> getTopPlayers({
    required String period,
    int limit = 50,
  }) async {
    try {
      _logger.i('Getting top $limit players for period: $period');

      final querySnapshot = await _firestore
          .collection('leaderboards')
          .doc(period)
          .collection('entries')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      var rank = 1;
      final entries = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return LeaderboardEntry(
          userId: data['userId'] as String,
          displayName: data['displayName'] as String,
          rank: rank++,
          rating: (data['rating'] as num).toDouble(),
          wins: data['wins'] as int,
          losses: data['losses'] as int,
          totalGames: data['totalGames'] as int,
          period: period,
          winRate: (data['winRate'] as num).toDouble(),
          avatarUrl: data['avatarUrl'] as String?,
        );
      }).toList();

      return entries;
    } catch (e) {
      _logger.e('Failed to get top players: $e');
      return [];
    }
  }

  /// Get player rank
  Future<LeaderboardEntry?> getPlayerRank({
    required String userId,
    required String period,
  }) async {
    try {
      _logger.i('Getting rank for user: $userId in period: $period');

      final doc = await _firestore
          .collection('leaderboards')
          .doc(period)
          .collection('entries')
          .doc(userId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;

      // Get rank
      final higherRatings = await _firestore
          .collection('leaderboards')
          .doc(period)
          .collection('entries')
          .where('rating', isGreaterThan: data['rating'])
          .count()
          .get();

      final rank = higherRatings.count + 1;

      return LeaderboardEntry(
        userId: data['userId'] as String,
        displayName: data['displayName'] as String,
        rank: rank,
        rating: (data['rating'] as num).toDouble(),
        wins: data['wins'] as int,
        losses: data['losses'] as int,
        totalGames: data['totalGames'] as int,
        period: period,
        winRate: (data['winRate'] as num).toDouble(),
        avatarUrl: data['avatarUrl'] as String?,
      );
    } catch (e) {
      _logger.e('Failed to get player rank: $e');
      return null;
    }
  }

  /// Get players in rating range
  Future<List<LeaderboardEntry>> getPlayersInRange({
    required String period,
    required double minRating,
    required double maxRating,
    int limit = 50,
  }) async {
    try {
      _logger.i('Getting players between $minRating-$maxRating for $period');

      final querySnapshot = await _firestore
          .collection('leaderboards')
          .doc(period)
          .collection('entries')
          .where('rating', isGreaterThanOrEqualTo: minRating)
          .where('rating', isLessThanOrEqualTo: maxRating)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      var rank = 1;
      final entries = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return LeaderboardEntry(
          userId: data['userId'] as String,
          displayName: data['displayName'] as String,
          rank: rank++,
          rating: (data['rating'] as num).toDouble(),
          wins: data['wins'] as int,
          losses: data['losses'] as int,
          totalGames: data['totalGames'] as int,
          period: period,
          winRate: (data['winRate'] as num).toDouble(),
          avatarUrl: data['avatarUrl'] as String?,
        );
      }).toList();

      return entries;
    } catch (e) {
      _logger.e('Failed to get players in range: $e');
      return [];
    }
  }

  /// Stream leaderboard (real-time)
  Stream<List<LeaderboardEntry>> streamLeaderboard({
    required String period,
    int limit = 50,
  }) {
    return _firestore
        .collection('leaderboards')
        .doc(period)
        .collection('entries')
        .orderBy('rating', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      var rank = 1;
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return LeaderboardEntry(
          userId: data['userId'] as String,
          displayName: data['displayName'] as String,
          rank: rank++,
          rating: (data['rating'] as num).toDouble(),
          wins: data['wins'] as int,
          losses: data['losses'] as int,
          totalGames: data['totalGames'] as int,
          period: period,
          winRate: (data['winRate'] as num).toDouble(),
          avatarUrl: data['avatarUrl'] as String?,
        );
      }).toList();
    });
  }

  /// Get available periods
  Future<List<String>> getAvailablePeriods() async {
    try {
      _logger.i('Getting available leaderboard periods');

      final querySnapshot =
          await _firestore.collection('leaderboards').get();

      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      _logger.e('Failed to get periods: $e');
      return ['allTime', 'monthly', 'weekly', 'daily'];
    }
  }

  /// Get leaderboard statistics
  Future<Map<String, dynamic>> getLeaderboardStats({
    required String period,
  }) async {
    try {
      _logger.i('Getting leaderboard stats for: $period');

      final count = await _firestore
          .collection('leaderboards')
          .doc(period)
          .collection('entries')
          .count()
          .get();

      final topPlayer = await _firestore
          .collection('leaderboards')
          .doc(period)
          .collection('entries')
          .orderBy('rating', descending: true)
          .limit(1)
          .get();

      if (topPlayer.docs.isEmpty) {
        return {
          'totalPlayers': 0,
          'topRating': 0.0,
        };
      }

      final topData = topPlayer.docs.first.data();

      return {
        'totalPlayers': count.count,
        'topRating': (topData['rating'] as num).toDouble(),
      };
    } catch (e) {
      _logger.e('Failed to get leaderboard stats: $e');
      return {};
    }
  }

  /// Reset leaderboard for a period
  Future<bool> resetLeaderboard({required String period}) async {
    try {
      _logger.w('Resetting leaderboard for period: $period');

      final querySnapshot = await _firestore
          .collection('leaderboards')
          .doc(period)
          .collection('entries')
          .get();

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      _logger.i('Leaderboard reset completed for: $period');
      return true;
    } catch (e) {
      _logger.e('Failed to reset leaderboard: $e');
      return false;
    }
  }
}
