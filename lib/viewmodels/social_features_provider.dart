import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import '../models/extended_game_models.dart';
import '../services/friend_service.dart';
import '../services/game_invitation_service.dart';

// ==================== Service Providers ====================

/// Friend Service Provider
final friendServiceProvider = Provider<FriendService>((ref) {
  return FriendService();
});

/// Game Invitation Service Provider
final gameInvitationServiceProvider = Provider<GameInvitationService>((ref) {
  return GameInvitationService();
});

// Note: leaderboard providers used to live here, backed by a
// `LeaderboardService` API (getTopPlayers/getPlayerRank/streamLeaderboard/
// etc.) that no longer exists — `services/leaderboard_service.dart` was
// replaced by Phase 58's leaderboard system with a different API
// (getLeaderboard/getUserRank/updateLeaderboard/...). Those calls were
// dead code (nothing in lib/views referenced them) and didn't compile, so
// they were removed; use `leaderboard_provider.dart` instead.

// ==================== Friend System Providers ====================

/// Get current user's accepted friends
final acceptedFriendsProvider = FutureProvider.family<List<Friend>, String>(
  (ref, uid) async {
    final service = ref.watch(friendServiceProvider);
    return service.getFriends(uid: uid, status: 'accepted');
  },
);

/// Get current user's blocked users list.
///
/// FriendsScreen used to build this inline (a fresh anonymous
/// FutureProvider constructed on every build()), which never converges:
/// each instance resolves, triggers a rebuild, which constructs yet
/// another fresh instance, forever - an actual busy-rebuild loop, not
/// just a style nit. A stable family provider fixes that, same pattern
/// as pendingFriendRequestsProvider below.
final blockedFriendsProvider = FutureProvider.family<List<Friend>, String>(
  (ref, uid) async {
    final service = ref.watch(friendServiceProvider);
    return service.getBlockedUsers(uid: uid);
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

/// Unblock friend provider
final unblockFriendProvider = FutureProvider.family<bool, (String, String)>(
  (ref, params) async {
    final (currentUid, friendUid) = params;
    final service = ref.watch(friendServiceProvider);
    return service.unblockFriend(currentUid: currentUid, friendUid: friendUid);
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

// ==================== Computed Providers ====================

/// Check if users are friends
final isFriendProvider = FutureProvider.family<bool, (String, String)>(
  (ref, params) async {
    final (currentUid, targetUid) = params;
    final service = ref.watch(friendServiceProvider);
    return service.isFriend(currentUid: currentUid, friendUid: targetUid);
  },
);

/// Raw relationship status ('pending'/'accepted'/'blocked'), or null if no
/// relationship exists yet - used to decide what a "add friend" search
/// result should actually show/allow instead of always offering "追加"
/// (which would otherwise let re-tapping it reset an accepted friendship
/// back to pending, see FriendService.addFriend's guard).
final friendStatusProvider = FutureProvider.family<String?, (String, String)>(
  (ref, params) async {
    final (currentUid, targetUid) = params;
    final service = ref.watch(friendServiceProvider);
    return service.getFriendStatus(currentUid: currentUid, friendUid: targetUid);
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

