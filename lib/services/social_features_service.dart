import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/sns_models.dart';

final _logger = Logger();

/// Service for social features: friends, invitations, leaderboards, tournaments
class SocialFeaturesService {
  final FirebaseFirestore _firestore;

  SocialFeaturesService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // ===== Friend Management =====

  /// Add a friend (sends a pending request)
  Future<bool> addFriend({
    required String userId,
    required String friendId,
  }) async {
    try {
      final friend = Friend(
        userId: userId,
        friendId: friendId,
        displayName: '', // Will be populated from user data
        addedAt: DateTime.now(),
        status: FriendStatus.pending,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .set(friend.toJson());

      return true;
    } catch (e) {
      _logger.e('Failed to add friend: $e');
      return false;
    }
  }

  /// Accept a friend request
  Future<bool> acceptFriendRequest({
    required String userId,
    required String friendId,
  }) async {
    try {
      // Update incoming request
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .update({'status': 'accepted'});

      return true;
    } catch (e) {
      _logger.e('Failed to accept friend request: $e');
      return false;
    }
  }

  /// Block a friend
  Future<bool> blockFriend({
    required String userId,
    required String friendId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .doc(friendId)
          .update({'status': 'blocked'});

      return true;
    } catch (e) {
      _logger.e('Failed to block friend: $e');
      return false;
    }
  }

  /// Get user's friend list (accepted only)
  Future<List<Friend>> getFriendsList({
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .where('status', isEqualTo: 'accepted')
          .get();

      return snapshot.docs
          .map((doc) => Friend.fromJson({...doc.data(), 'friendId': doc.id}))
          .toList();
    } catch (e) {
      _logger.e('Failed to fetch friends list: $e');
      return [];
    }
  }

  /// Get pending friend requests
  Future<List<Friend>> getPendingRequests({
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('friends')
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs
          .map((doc) => Friend.fromJson({...doc.data(), 'friendId': doc.id}))
          .toList();
    } catch (e) {
      _logger.e('Failed to fetch pending requests: $e');
      return [];
    }
  }

  /// Check if two users are friends
  Future<bool> areFriends({
    required String userId1,
    required String userId2,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId1)
          .collection('friends')
          .doc(userId2)
          .get();

      if (!doc.exists) return false;
      final friend = Friend.fromJson(doc.data()!);
      return friend.status == FriendStatus.accepted;
    } catch (e) {
      _logger.e('Failed to check friendship: $e');
      return false;
    }
  }

  // ===== Game Invitations =====

  /// Send a game invitation
  Future<GameInvitation?> sendGameInvitation({
    required String fromUserId,
    required String toUserId,
    required String gameModeId,
  }) async {
    try {
      final invitationId = _firestore.collection('game_invitations').doc().id;

      // Get game mode
      final modeDoc = await _firestore.collection('game_modes').doc(gameModeId).get();
      if (!modeDoc.exists) return null;

      final gameMode = GameMode.fromJson({...modeDoc.data()!, 'id': gameModeId});

      final invitation = GameInvitation(
        invitationId: invitationId,
        fromUserId: fromUserId,
        toUserId: toUserId,
        gameMode: gameMode,
        createdAt: DateTime.now(),
        status: InvitationStatus.pending,
      );

      await _firestore
          .collection('game_invitations')
          .doc(invitationId)
          .set(invitation.toJson());

      return invitation;
    } catch (e) {
      _logger.e('Failed to send game invitation: $e');
      return null;
    }
  }

  /// Accept a game invitation
  Future<bool> acceptInvitation({
    required String invitationId,
  }) async {
    try {
      await _firestore.collection('game_invitations').doc(invitationId).update({
        'status': 'accepted',
        'respondedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _logger.e('Failed to accept invitation: $e');
      return false;
    }
  }

  /// Decline a game invitation
  Future<bool> declineInvitation({
    required String invitationId,
  }) async {
    try {
      await _firestore.collection('game_invitations').doc(invitationId).update({
        'status': 'declined',
        'respondedAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      _logger.e('Failed to decline invitation: $e');
      return false;
    }
  }

  /// Get pending invitations for a user
  Future<List<GameInvitation>> getPendingInvitations({
    required String userId,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('game_invitations')
          .where('toUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs
          .map((doc) => GameInvitation.fromJson({...doc.data(), 'invitationId': doc.id}))
          .toList();
    } catch (e) {
      _logger.e('Failed to fetch pending invitations: $e');
      return [];
    }
  }

  // ===== Leaderboards =====

  /// Get global leaderboard
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    int limit = 100,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('leaderboard_global')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .asMap()
          .entries
          .map((entry) {
            final data = entry.value.data();
            return LeaderboardEntry.fromJson({
              ...data,
              'rank': entry.key + 1,
              'scope': 'global',
            });
          })
          .toList();
    } catch (e) {
      _logger.e('Failed to fetch global leaderboard: $e');
      return [];
    }
  }

  /// Get monthly leaderboard
  Future<List<LeaderboardEntry>> getMonthlyLeaderboard({
    int limit = 100,
  }) async {
    try {
      final now = DateTime.now();
      final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';

      final snapshot = await _firestore
          .collection('leaderboard_monthly')
          .doc(monthKey)
          .collection('entries')
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .asMap()
          .entries
          .map((entry) {
            final data = entry.value.data();
            return LeaderboardEntry.fromJson({
              ...data,
              'rank': entry.key + 1,
              'scope': 'monthly',
            });
          })
          .toList();
    } catch (e) {
      _logger.e('Failed to fetch monthly leaderboard: $e');
      return [];
    }
  }

  /// Get user's rank in a leaderboard
  Future<int?> getUserRank({
    required String userId,
    required LeaderboardScope scope,
  }) async {
    try {
      final collection = scope == LeaderboardScope.global
          ? 'leaderboard_global'
          : 'leaderboard_monthly';

      final userDoc = await _firestore
          .collection(collection)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) return null;

      final userRating = userDoc.docs.first['rating'] as int;

      final higherRankedCount = await _firestore
          .collection(collection)
          .where('rating', isGreaterThan: userRating)
          .count()
          .get();

      return higherRankedCount.count! + 1;
    } catch (e) {
      _logger.e('Failed to get user rank: $e');
      return null;
    }
  }

  /// Update user rating
  Future<bool> updateUserRating({
    required String userId,
    required int newRating,
  }) async {
    try {
      // Update global leaderboard
      await _firestore
          .collection('leaderboard_global')
          .doc(userId)
          .set({'userId': userId, 'rating': newRating}, SetOptions(merge: true));

      // Update monthly leaderboard
      final now = DateTime.now();
      final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      await _firestore
          .collection('leaderboard_monthly')
          .doc(monthKey)
          .collection('entries')
          .doc(userId)
          .set({'userId': userId, 'rating': newRating}, SetOptions(merge: true));

      return true;
    } catch (e) {
      _logger.e('Failed to update user rating: $e');
      return false;
    }
  }

  // ===== Tournaments =====

  /// Get active tournaments
  Future<List<Tournament>> getActiveTournaments() async {
    try {
      final snapshot = await _firestore
          .collection('tournaments')
          .where('status', isEqualTo: 'active')
          .get();

      return snapshot.docs
          .map((doc) => Tournament.fromJson({...doc.data(), 'tournamentId': doc.id}))
          .toList();
    } catch (e) {
      _logger.e('Failed to fetch active tournaments: $e');
      return [];
    }
  }

  /// Register for a tournament
  Future<bool> registerForTournament({
    required String tournamentId,
    required String userId,
  }) async {
    try {
      await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('participants')
          .doc(userId)
          .set({'userId': userId, 'registeredAt': DateTime.now().toIso8601String()});

      return true;
    } catch (e) {
      _logger.e('Failed to register for tournament: $e');
      return false;
    }
  }

  /// Get tournament bracket
  Future<Map<String, dynamic>?> getTournamentBracket({
    required String tournamentId,
  }) async {
    try {
      final doc = await _firestore
          .collection('tournaments')
          .doc(tournamentId)
          .collection('bracket')
          .doc('root')
          .get();

      return doc.data();
    } catch (e) {
      _logger.e('Failed to fetch tournament bracket: $e');
      return null;
    }
  }

  // ===== Chat During Observation =====

  /// Send a chat message during game observation
  Future<ChatMessage?> sendChatMessage({
    required String userId,
    required String displayName,
    required String content,
    String? gameId,
  }) async {
    try {
      final messageId = _firestore.collection('chat_messages').doc().id;

      final message = ChatMessage(
        messageId: messageId,
        fromUserId: userId,
        fromDisplayName: displayName,
        content: content,
        sentAt: DateTime.now(),
        gameId: gameId,
      );

      await _firestore
          .collection('chat_messages')
          .doc(messageId)
          .set(message.toJson());

      return message;
    } catch (e) {
      _logger.e('Failed to send chat message: $e');
      return null;
    }
  }

  /// Get chat messages for a game
  Future<List<ChatMessage>> getGameChat({
    required String gameId,
    int limit = 50,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('chat_messages')
          .where('gameId', isEqualTo: gameId)
          .orderBy('sentAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ChatMessage.fromJson({...doc.data(), 'messageId': doc.id}))
          .toList()
          .reversed
          .toList();
    } catch (e) {
      _logger.e('Failed to fetch chat messages: $e');
      return [];
    }
  }

  /// Stream chat messages for real-time updates
  Stream<ChatMessage> streamGameChat({
    required String gameId,
  }) {
    return _firestore
        .collection('chat_messages')
        .where('gameId', isEqualTo: gameId)
        .orderBy('sentAt')
        .snapshots()
        .expand((snapshot) {
      return snapshot.docChanges.map((change) {
        return ChatMessage.fromJson({
          ...change.doc.data()!,
          'messageId': change.doc.id,
        });
      });
    });
  }

  // ===== Social Analytics =====

  /// Get social analytics for a user
  Future<SocialAnalytics?> getSocialAnalytics({
    required String userId,
  }) async {
    try {
      final doc = await _firestore
          .collection('user_analytics')
          .doc(userId)
          .collection('social')
          .doc('current')
          .get();

      if (!doc.exists) return null;
      return SocialAnalytics.fromJson({...doc.data()!, 'userId': userId});
    } catch (e) {
      _logger.e('Failed to fetch social analytics: $e');
      return null;
    }
  }

  /// Update social analytics after a social action
  Future<bool> updateSocialAnalytics({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore
          .collection('user_analytics')
          .doc(userId)
          .collection('social')
          .doc('current')
          .set(updates, SetOptions(merge: true));

      return true;
    } catch (e) {
      _logger.e('Failed to update social analytics: $e');
      return false;
    }
  }
}
