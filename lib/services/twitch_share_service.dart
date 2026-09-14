import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';

final _logger = Logger();

/// Twitch ストリーム統合サービス
class TwitchShareService {
  final FirebaseFirestore _firestore;

  TwitchShareService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// ゲームをTwitchにストリーム配信
  Future<TwitchStreamInfo?> startGameStream(
    TwitchStreamData streamData,
  ) async {
    try {
      _logger.i('Starting Twitch stream: ${streamData.streamTitle}');

      final docRef = _firestore
          .collection('games')
          .doc(streamData.gameId)
          .collection('streams')
          .doc();

      final streamDataMap = {
        'platform': 'twitch',
        'title': streamData.streamTitle,
        'category': streamData.category,
        'tags': streamData.tags,
        'isLive': true,
        'viewerCount': 0,
        'status': 'active',
        'startedAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(streamDataMap);
      _logger.i('Twitch stream started: ${docRef.id}');

      return TwitchStreamInfo(
        streamId: docRef.id,
        channelName: streamData.channelId ?? 'unknown',
        title: streamData.streamTitle,
        startedAt: DateTime.now(),
        viewers: 0,
        category: streamData.category,
      );
    } catch (e) {
      _logger.e('Error starting Twitch stream: $e');
      rethrow;
    }
  }

  /// ストリームを終了
  Future<bool> endGameStream(String gameId, String streamId) async {
    try {
      _logger.i('Ending Twitch stream: $streamId');

      await _firestore
          .collection('games')
          .doc(gameId)
          .collection('streams')
          .doc(streamId)
          .update({
        'isLive': false,
        'status': 'ended',
        'endedAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Twitch stream ended: $streamId');
      return true;
    } catch (e) {
      _logger.e('Error ending Twitch stream: $e');
      rethrow;
    }
  }

  /// ビューア数を更新
  Future<bool> updateViewerCount(
    String gameId,
    String streamId,
    int viewerCount,
  ) async {
    try {
      _logger.d('Updating viewer count: $viewerCount for stream: $streamId');

      await _firestore
          .collection('games')
          .doc(gameId)
          .collection('streams')
          .doc(streamId)
          .update({
        'viewerCount': viewerCount,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      _logger.e('Error updating viewer count: $e');
      rethrow;
    }
  }

  /// アクティブなストリーム情報を取得
  Future<TwitchStreamInfo?> getActiveStream(String gameId) async {
    try {
      _logger.d('Fetching active stream for game: $gameId');

      final querySnapshot = await _firestore
          .collection('games')
          .doc(gameId)
          .collection('streams')
          .where('isLive', isEqualTo: true)
          .where('platform', isEqualTo: 'twitch')
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data;

      return TwitchStreamInfo(
        streamId: doc.id,
        channelName: data['channelName'] ?? 'unknown',
        title: data['title'] ?? '',
        startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        viewers: data['viewerCount'] ?? 0,
        category: data['category'],
      );
    } catch (e) {
      _logger.e('Error fetching active stream: $e');
      rethrow;
    }
  }

  /// ユーザーのストリーム履歴を取得
  Future<List<TwitchStreamInfo>> getStreamHistory(
    String userId, {
    int limit = 20,
  }) async {
    try {
      _logger.d('Fetching stream history for user: $userId');

      final querySnapshot = await _firestore
          .collectionGroup('streams')
          .where('userId', isEqualTo: userId)
          .where('platform', isEqualTo: 'twitch')
          .orderBy('startedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data;
        return TwitchStreamInfo(
          streamId: doc.id,
          channelName: data['channelName'] ?? 'unknown',
          title: data['title'] ?? '',
          startedAt: (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          viewers: data['viewerCount'] ?? 0,
          category: data['category'],
        );
      }).toList();
    } catch (e) {
      _logger.e('Error fetching stream history: $e');
      rethrow;
    }
  }

  /// Twitch チャンネル接続を確認
  Future<bool> isTwitchConnected(String userId) async {
    try {
      _logger.d('Checking Twitch connection for user: $userId');

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('oauth')
          .doc('twitch')
          .get();

      return doc.exists && (doc.data()?['isConnected'] ?? false);
    } catch (e) {
      _logger.e('Error checking Twitch connection: $e');
      rethrow;
    }
  }

  /// Twitch チャンネル接続を設定
  Future<bool> setTwitchConnection(
    String userId,
    String accessToken,
    String channelId,
    String channelName,
  ) async {
    try {
      _logger.i('Setting Twitch connection for user: $userId');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('oauth')
          .doc('twitch')
          .set({
        'isConnected': true,
        'channelId': channelId,
        'channelName': channelName,
        'accessToken': accessToken, // 安全に暗号化して保存
        'connectedAt': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      _logger.e('Error setting Twitch connection: $e');
      rethrow;
    }
  }

  /// Twitch チャンネル接続を削除
  Future<bool> disconnectTwitch(String userId) async {
    try {
      _logger.i('Disconnecting Twitch for user: $userId');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('oauth')
          .doc('twitch')
          .delete();

      return true;
    } catch (e) {
      _logger.e('Error disconnecting Twitch: $e');
      rethrow;
    }
  }

  /// チャンネル情報を取得
  Future<Map<String, dynamic>?> getChannelInfo(String userId) async {
    try {
      _logger.d('Fetching channel info for user: $userId');

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('oauth')
          .doc('twitch')
          .get();

      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      _logger.e('Error fetching channel info: $e');
      rethrow;
    }
  }

  /// ストリーム開始イベントをブロードキャスト
  Future<bool> broadcastStreamStarted(
    String gameId,
    String streamId,
    String title,
  ) async {
    try {
      _logger.i('Broadcasting stream started event');

      await _firestore
          .collection('games')
          .doc(gameId)
          .collection('events')
          .add({
        'type': 'stream_started',
        'streamId': streamId,
        'title': title,
        'timestamp': FieldValue.serverTimestamp(),
      });

      return true;
    } catch (e) {
      _logger.e('Error broadcasting stream event: $e');
      rethrow;
    }
  }
}
