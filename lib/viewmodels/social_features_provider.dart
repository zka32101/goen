import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../models/extended_game_models.dart';
import '../services/friend_service.dart';
import '../services/game_invitation_service.dart';
import '../services/leaderboard_service.dart';

// ==================== Service Providers ====================

/// Friend Service Provider
final friendServiceProvider = Provider<FriendService>((ref) {
  return const FriendService();
});

/// Game Invitation Service Provider
final gameInvitationServiceProvider = Provider<GameInvitationService>((ref) {
  return const GameInvitationService();
});

/// Leaderboard Service Provider
final leaderboardServiceProvider = Provider<LeaderboardService>((ref) {
  return const LeaderboardService();
});

// ==================== Friend System Providers ====================

/// Get current user's accepted friends
final acceptedFriendsProvider = FutureProvider.family<List<Friend>, String>(
  (ref, uid) async {
    final service = ref.watch(friendServiceProvider);
    return service.getFriends(uid: uid, status: 'accepted');
  },
);

/// Get current user's pending friend requests
final pendingFriendRequestsProvider =
    FutureProvider.family<List<Friend>, String>(
  (ref, uid) async {
    final service = ref.watch(friendServiceProvider);
    return service.getPendingRequests(uid: uid);
  },
);

/// Stream friend list (real-time)
final friendsStreamProvider = StreamProvider.family<List<Friend>, String>(
  (ref, uid) {
    final service = ref.watch(friendServiceProvider);
    return service.streamFriends(uid: uid, status: 'accepted');
  },
);

/// Add friend provider
final addFriendProvider =
    FutureProvider.family<bool, (String, String, String?)>(
  (ref, params) async {
    final (currentUid, friendUid, notes) = params;
    final service = ref.watch(friendServiceProvider);
    return service.addFriend(
      currentUid: currentUid,
      friendUid: friendUid,
      notes: notes,
    );
  },
);

/// Accept friend request provider
final acceptFriendRequestProvider =
    FutureProvider.family<bool, (String, String)>(
  (ref, params) async {
    final (currentUid, friendUid) = params;
    final service = ref.watch(friendServiceProvider);
    return service.acceptFriendRequest(
      currentUid: currentUid,
      friendUid: friendUid,
    );
  },
);

/// Block friend provider
final blockFriendProvider = FutureProvider.family<bool, (String, String)>(
  (ref, params) async {
    final (currentUid, friendUid) = params;
    final service = ref.watch(friendServiceProvider);
    return service.blockFriend(currentUid: currentUid, friendUid: friendUid);
  },
);

/// Search users provider
final searchUsersProvider = FutureProvider.family<List<UserProfile>, String>(
  (ref, query) async {
    if (query.isEmpty) return [];
    final service = ref.watch(friendServiceProvider);
    return service.searchUsers(query: query);
  },
);

// ==================== Game Invitation Providers ====================

/// Get incoming game invitations
final incomingInvitationsProvider =
    FutureProvider.family<List<GameInvitation>, String>(
  (ref, uid) async {
    final service = ref.watch(gameInvitationServiceProvider);
    return service.getIncomingInvitations(uid: uid);
  },
);

/// Get outgoing game invitations
final outgoingInvitationsProvider =
    FutureProvider.family<List<GameInvitation>, String>(
  (ref, uid) async {
    final service = ref.watch(gameInvitationServiceProvider);
    return service.getOutgoingInvitations(uid: uid);
  },
);

/// Stream incoming invitations (real-time)
final incomingInvitationsStreamProvider =
    StreamProvider.family<List<GameInvitation>, String>(
  (ref, uid) {
    final service = ref.watch(gameInvitationServiceProvider);
    return service.streamIncomingInvitations(uid: uid);
  },
);

/// Send game invitation provider
final sendGameInvitationProvider = FutureProvider.family<bool,
    ({
      String fromUid,
      String toUid,
      String gameMode,
      int boardSize,
      int aiLevel,
      String? customMessage,
    })>(
  (ref, params) async {
    final service = ref.watch(gameInvitationServiceProvider);
    return service.sendInvitation(
      fromUid: params.fromUid,
      toUid: params.toUid,
      gameMode: params.gameMode,
      boardSize: params.boardSize,
      aiLevel: params.aiLevel,
      customMessage: params.customMessage,
    );
  },
);

/// Accept game invitation provider
final acceptGameInvitationProvider =
    FutureProvider.family<bool, String>(
  (ref, invitationId) async {
    final service = ref.watch(gameInvitationServiceProvider);
    return service.acceptInvitation(invitationId: invitationId);
  },
);

/// Decline game invitation provider
final declineGameInvitationProvider =
    FutureProvider.family<bool, String>(
  (ref, invitationId) async {
    final service = ref.watch(gameInvitationServiceProvider);
    return service.declineInvitation(invitationId: invitationId);
  },
);

// ==================== Leaderboard Providers ====================

/// Get top players for a period
final topPlayersProvider =
    FutureProvider.family<List<LeaderboardEntry>, (String, int)>(
  (ref, params) async {
    final (period, limit) = params;
    final service = ref.watch(leaderboardServiceProvider);
    return service.getTopPlayers(period: period, limit: limit);
  },
);

/// Get player's current rank
final playerRankProvider =
    FutureProvider.family<LeaderboardEntry?, (String, String)>(
  (ref, params) async {
    final (userId, period) = params;
    final service = ref.watch(leaderboardServiceProvider);
    return service.getPlayerRank(userId: userId, period: period);
  },
);

/// Stream leaderboard (real-time)
final leaderboardStreamProvider =
    StreamProvider.family<List<LeaderboardEntry>, (String, int)>(
  (ref, params) {
    final (period, limit) = params;
    final service = ref.watch(leaderboardServiceProvider);
    return service.streamLeaderboard(period: period, limit: limit);
  },
);

/// Get leaderboard statistics
final leaderboardStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, period) async {
    final service = ref.watch(leaderboardServiceProvider);
    return service.getLeaderboardStats(period: period);
  },
);

/// Update leaderboard entry provider
final updateLeaderboardEntryProvider = FutureProvider.family<bool,
    ({
      String userId,
      String displayName,
      double rating,
      int wins,
      int losses,
      int totalGames,
      String period,
      String? avatarUrl,
    })>(
  (ref, params) async {
    final service = ref.watch(leaderboardServiceProvider);
    return service.updateLeaderboardEntry(
      userId: params.userId,
      displayName: params.displayName,
      rating: params.rating,
      wins: params.wins,
      losses: params.losses,
      totalGames: params.totalGames,
      period: params.period,
      avatarUrl: params.avatarUrl,
    );
  },
);

// ==================== Computed Providers ====================

/// Check if users are friends
final isFriendProvider = FutureProvider.family<bool, (String, String)>(
  (ref, params) async {
    final (currentUid, targetUid) = params;
    final service = ref.watch(friendServiceProvider);
    return service.isFriend(currentUid: currentUid, friendUid: targetUid);
  },
);

/// Get user profile (for friend display)
final userProfileProvider = FutureProvider.family<UserProfile?, String>(
  (ref, uid) async {
    final firestore = FirebaseFirestore.instance;
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;
      return UserProfile.fromJson({...doc.data()!, 'uid': doc.id});
    } catch (e) {
      return null;
    }
  },
);

/// Get all leaderboard periods
final leaderboardPeriodsProvider =
    FutureProvider<List<String>>((ref) async {
  final service = ref.watch(leaderboardServiceProvider);
  return service.getAvailablePeriods();
});

/// Filtered leaderboard by difficulty tier
final tierLeaderboardProvider = FutureProvider.family<List<LeaderboardEntry>,
    ({String period, double minRating, double maxRating, int limit})>(
  (ref, params) async {
    final service = ref.watch(leaderboardServiceProvider);
    return service.getPlayersInRange(
      period: params.period,
      minRating: params.minRating,
      maxRating: params.maxRating,
      limit: params.limit,
    );
  },
);
