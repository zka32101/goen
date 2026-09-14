import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/extended_game_models.dart';

final _logger = Logger();

/// Service for game analytics and statistics
class AnalyticsService {
  final FirebaseFirestore _firestore;

  const AnalyticsService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _firestoreInstance;

  static final _firestoreInstance = FirebaseFirestore.instance;

  /// Record a completed game
  Future<bool> recordGameResult({
    required String userId,
    required GameRecord gameRecord,
  }) async {
    try {
      _logger.i('Recording game result for user: $userId');

      final gameRecordId = _firestore
          .collection('users')
          .doc(userId)
          .collection('gameRecords')
          .doc()
          .id;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('gameRecords')
          .doc(gameRecordId)
          .set({
        ...gameRecord.toJson(),
        'recordId': gameRecordId,
      });

      // Update user statistics
      await _updateUserStats(userId);

      return true;
    } catch (e) {
      _logger.e('Failed to record game result: $e');
      return false;
    }
  }

  /// Get user game statistics
  Future<GameStatistics?> getUserStatistics({required String userId}) async {
    try {
      _logger.i('Getting statistics for user: $userId');

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('summary')
          .get();

      if (!doc.exists) {
        return null;
      }

      return GameStatistics.fromJson({...doc.data()!, 'userId': userId});
    } catch (e) {
      _logger.e('Failed to get user statistics: $e');
      return null;
    }
  }

  /// Get recent games
  Future<List<GameRecord>> getRecentGames({
    required String userId,
    int limit = 20,
  }) async {
    try {
      _logger.i('Getting recent games for user: $userId');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('gameRecords')
          .orderBy('playedAt', descending: true)
          .limit(limit)
          .get();

      final games = querySnapshot.docs
          .map((doc) => GameRecord.fromJson({...doc.data(), 'gameId': doc.id}))
          .toList();

      return games;
    } catch (e) {
      _logger.e('Failed to get recent games: $e');
      return [];
    }
  }

  /// Get win rate by board size
  Future<Map<String, double>> getWinRateByBoardSize({
    required String userId,
  }) async {
    try {
      _logger.i('Getting win rate by board size for: $userId');

      final games = await getRecentGames(userId: userId, limit: 100);

      final statsMap = <String, (int wins, int total)>{};

      for (final game in games) {
        final sizeKey = '${game.boardSize}x${game.boardSize}';
        final isWin = game.result == 'win' ? 1 : 0;

        if (statsMap.containsKey(sizeKey)) {
          final current = statsMap[sizeKey]!;
          statsMap[sizeKey] = (current.$1 + isWin, current.$2 + 1);
        } else {
          statsMap[sizeKey] = (isWin, 1);
        }
      }

      final winRates = <String, double>{};
      for (final entry in statsMap.entries) {
        winRates[entry.key] = (entry.value.$1 / entry.value.$2) * 100;
      }

      return winRates;
    } catch (e) {
      _logger.e('Failed to get win rate by board size: $e');
      return {};
    }
  }

  /// Get win rate by AI level
  Future<Map<int, double>> getWinRateByAiLevel({
    required String userId,
  }) async {
    try {
      _logger.i('Getting win rate by AI level for: $userId');

      final games = await getRecentGames(userId: userId, limit: 100);

      final statsMap = <int, (int wins, int total)>{};

      for (final game in games) {
        final isWin = game.result == 'win' ? 1 : 0;

        if (statsMap.containsKey(game.aiLevel)) {
          final current = statsMap[game.aiLevel]!;
          statsMap[game.aiLevel] = (current.$1 + isWin, current.$2 + 1);
        } else {
          statsMap[game.aiLevel] = (isWin, 1);
        }
      }

      final winRates = <int, double>{};
      for (final entry in statsMap.entries) {
        winRates[entry.key] = (entry.value.$1 / entry.value.$2) * 100;
      }

      return winRates;
    } catch (e) {
      _logger.e('Failed to get win rate by AI level: $e');
      return {};
    }
  }

  /// Get games by mode distribution
  Future<Map<String, int>> getGameDistributionByMode({
    required String userId,
    int daysBack = 30,
  }) async {
    try {
      _logger.i('Getting game distribution for user: $userId');

      final cutoffDate =
          DateTime.now().subtract(Duration(days: daysBack));

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('gameRecords')
          .where('playedAt', isGreaterThan: cutoffDate)
          .get();

      final distribution = <String, int>{};

      for (final doc in querySnapshot.docs) {
        final gameMode = doc['gameMode'] as String;
        distribution[gameMode] = (distribution[gameMode] ?? 0) + 1;
      }

      return distribution;
    } catch (e) {
      _logger.e('Failed to get game distribution: $e');
      return {};
    }
  }

  /// Get average game duration
  Future<double> getAverageGameDuration({required String userId}) async {
    try {
      _logger.i('Getting average game duration for: $userId');

      final games = await getRecentGames(userId: userId, limit: 50);

      if (games.isEmpty) return 0.0;

      final totalDuration = games.fold<int>(
        0,
        (sum, game) => sum + game.durationSeconds,
      );

      return totalDuration / games.length / 60; // Convert to minutes
    } catch (e) {
      _logger.e('Failed to get average game duration: $e');
      return 0.0;
    }
  }

  /// Stream user statistics (real-time)
  Stream<GameStatistics?> streamUserStatistics({required String userId}) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('stats')
        .doc('summary')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return GameStatistics.fromJson({...snapshot.data()!, 'userId': userId});
    });
  }

  /// Check and unlock achievements
  Future<List<Achievement>> checkAchievements({required String userId}) async {
    try {
      _logger.i('Checking achievements for user: $userId');

      final stats = await getUserStatistics(userId: userId);
      if (stats == null) return [];

      final unlockedAchievements = <Achievement>[];

      // Check each predefined achievement
      for (final achievement in PredefinedAchievements.all) {
        final isUnlocked = _checkAchievementCondition(achievement, stats);

        if (isUnlocked && !achievement.isUnlocked) {
          unlockedAchievements.add(
            achievement.copyWith(
              isUnlocked: true,
              unlockedAt: DateTime.now(),
            ),
          );

          // Save to Firestore
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('achievements')
              .doc(achievement.id)
              .set(unlockedAchievements.last.toJson());
        }
      }

      return unlockedAchievements;
    } catch (e) {
      _logger.e('Failed to check achievements: $e');
      return [];
    }
  }

  /// Get user's unlocked achievements
  Future<List<Achievement>> getUnlockedAchievements({
    required String userId,
  }) async {
    try {
      _logger.i('Getting unlocked achievements for: $userId');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .where('isUnlocked', isEqualTo: true)
          .get();

      final achievements = querySnapshot.docs
          .map((doc) => Achievement.fromJson(doc.data()))
          .toList();

      return achievements;
    } catch (e) {
      _logger.e('Failed to get unlocked achievements: $e');
      return [];
    }
  }

  /// Private helper methods

  Future<void> _updateUserStats(String userId) async {
    try {
      final games = await getRecentGames(userId: userId, limit: 100);

      if (games.isEmpty) return;

      final totalGames = games.length;
      final totalWins =
          games.where((g) => g.result == 'win').length;
      final totalLosses =
          games.where((g) => g.result == 'loss').length;
      final winRate =
          totalGames > 0 ? (totalWins / totalGames) * 100 : 0.0;

      final recentGames =
          games.take(10).toList();

      final avgDuration = games.fold<int>(
            0,
            (sum, game) => sum + game.durationSeconds,
          ) /
          games.length;

      final favoriteGameMode =
          _getFavoritMode(games);
      final favoriteAiLevel =
          _getFavoriteLevel(games);
      final favoriteBoardSize =
          _getFavoriteBoardSize(games);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('stats')
          .doc('summary')
          .set({
        'userId': userId,
        'totalGamesPlayed': totalGames,
        'totalWins': totalWins,
        'totalLosses': totalLosses,
        'winRate': winRate,
        'averageGameDuration': avgDuration / 60,
        'favoriteGameMode': favoriteGameMode,
        'favoriteAiLevel': favoriteAiLevel,
        'favoriteBoardSize': favoriteBoardSize,
        'lastPlayedAt': DateTime.now(),
        'recentGames': recentGames.map((g) => g.toJson()).toList(),
      }, SetOptions(merge: true));
    } catch (e) {
      _logger.e('Failed to update user stats: $e');
    }
  }

  String _getFavoritMode(List<GameRecord> games) {
    final modeCount = <String, int>{};
    for (final game in games) {
      modeCount[game.gameMode] = (modeCount[game.gameMode] ?? 0) + 1;
    }
    return modeCount.entries.maxBy((e) => e.value).key;
  }

  int _getFavoriteLevel(List<GameRecord> games) {
    final levelCount = <int, int>{};
    for (final game in games) {
      levelCount[game.aiLevel] = (levelCount[game.aiLevel] ?? 0) + 1;
    }
    return levelCount.entries.maxBy((e) => e.value).key;
  }

  int _getFavoriteBoardSize(List<GameRecord> games) {
    final sizeCount = <int, int>{};
    for (final game in games) {
      sizeCount[game.boardSize] = (sizeCount[game.boardSize] ?? 0) + 1;
    }
    return sizeCount.entries.maxBy((e) => e.value).key;
  }

  bool _checkAchievementCondition(
    Achievement achievement,
    GameStatistics stats,
  ) {
    switch (achievement.id) {
      case 'first_win':
        return stats.totalWins >= 1;
      case 'streak_5':
        return stats.totalWins >= 5;
      case 'explorer':
        return stats.gamesByMode.length >= 3;
      case 'master_10':
        return stats.totalWins >= 10 && stats.favoriteAiLevel >= 10;
      case 'century':
        return stats.totalGamesPlayed >= 100;
      case 'boardsize_collector':
        return stats.gamesByMode.values.any((v) => v >= 1);
      default:
        return false;
    }
  }
}
