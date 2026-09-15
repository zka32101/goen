import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/game_record.dart';

final _logger = Logger();

/// Service for game analytics and statistics
class AnalyticsService {
  final FirebaseFirestore _firestore;

  AnalyticsService({FirebaseFirestore? firestore})
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
        'id': gameRecord.id,
        'uid': gameRecord.uid,
        'boardSize': gameRecord.boardSize,
        'sgfData': gameRecord.sgfData,
        'result': gameRecord.result.toString(),
        'aiLevel': gameRecord.aiLevel,
        'playedAt': gameRecord.playedAt,
        'movesCount': gameRecord.movesCount,
        'gameDuration': gameRecord.gameDuration?.inSeconds,
        'blackScore': gameRecord.blackScore,
        'whiteScore': gameRecord.whiteScore,
      });

      return true;
    } catch (e) {
      _logger.e('Failed to record game result: $e');
      return false;
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

      final games = <GameRecord>[];
      for (final doc in querySnapshot.docs) {
        games.add(GameRecord.fromFirestore(doc));
      }

      return games;
    } catch (e) {
      _logger.e('Failed to get recent games: $e');
      return [];
    }
  }

  /// Record a user achievement (placeholder)
  Future<bool> recordAchievement({
    required String userId,
    required String achievementId,
  }) async {
    try {
      _logger.i('Recording achievement $achievementId for user: $userId');
      return true;
    } catch (e) {
      _logger.e('Failed to record achievement: $e');
      return false;
    }
  }
}
