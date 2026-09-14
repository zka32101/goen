import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/extended_game_models.dart';

final _logger = Logger();

/// Service for managing friend relationships
class FriendService {
  final FirebaseFirestore _firestore;

  const FriendService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _firestore;

  static final _firestore = FirebaseFirestore.instance;

  /// Add a friend (sends pending request)
  Future<bool> addFriend({
    required String currentUid,
    required String friendUid,
    String? notes,
  }) async {
    try {
      _logger.i('Adding friend: $friendUid to user: $currentUid');

      final now = DateTime.now();

      // Add to current user's friends collection
      await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .doc(friendUid)
          .set({
        'uid': friendUid,
        'status': 'pending',
        'addedAt': now,
        'notes': notes ?? '',
      });

      return true;
    } catch (e) {
      _logger.e('Failed to add friend: $e');
      return false;
    }
  }

  /// Accept friend request
  Future<bool> acceptFriendRequest({
    required String currentUid,
    required String friendUid,
  }) async {
    try {
      _logger.i('Accepting friend request from: $friendUid');

      await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .doc(friendUid)
          .update({'status': 'accepted'});

      return true;
    } catch (e) {
      _logger.e('Failed to accept friend request: $e');
      return false;
    }
  }

  /// Reject/Block friend request
  Future<bool> blockFriend({
    required String currentUid,
    required String friendUid,
  }) async {
    try {
      _logger.i('Blocking friend: $friendUid');

      await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .doc(friendUid)
          .update({'status': 'blocked'});

      return true;
    } catch (e) {
      _logger.e('Failed to block friend: $e');
      return false;
    }
  }

  /// Remove friend
  Future<bool> removeFriend({
    required String currentUid,
    required String friendUid,
  }) async {
    try {
      _logger.i('Removing friend: $friendUid');

      await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .doc(friendUid)
          .delete();

      return true;
    } catch (e) {
      _logger.e('Failed to remove friend: $e');
      return false;
    }
  }

  /// Get friends list
  Future<List<Friend>> getFriends({
    required String uid,
    String status = 'accepted',
  }) async {
    try {
      _logger.i('Getting friends for user: $uid with status: $status');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('friends')
          .where('status', isEqualTo: status)
          .get();

      final friends = querySnapshot.docs
          .map((doc) => Friend.fromJson({...doc.data(), 'uid': doc.id}))
          .toList();

      return friends;
    } catch (e) {
      _logger.e('Failed to get friends: $e');
      return [];
    }
  }

  /// Get pending friend requests
  Future<List<Friend>> getPendingRequests({required String uid}) async {
    try {
      _logger.i('Getting pending friend requests for: $uid');

      return await getFriends(uid: uid, status: 'pending');
    } catch (e) {
      _logger.e('Failed to get pending requests: $e');
      return [];
    }
  }

  /// Get blocked users
  Future<List<Friend>> getBlockedUsers({required String uid}) async {
    try {
      _logger.i('Getting blocked users for: $uid');

      return await getFriends(uid: uid, status: 'blocked');
    } catch (e) {
      _logger.e('Failed to get blocked users: $e');
      return [];
    }
  }

  /// Check if user is friend
  Future<bool> isFriend({
    required String currentUid,
    required String friendUid,
  }) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .doc(friendUid)
          .get();

      if (!doc.exists) return false;

      final friend = Friend.fromJson({...doc.data()!, 'uid': doc.id});
      return friend.status == 'accepted';
    } catch (e) {
      _logger.e('Failed to check friend status: $e');
      return false;
    }
  }

  /// Update friend notes
  Future<bool> updateFriendNotes({
    required String currentUid,
    required String friendUid,
    required String notes,
  }) async {
    try {
      _logger.i('Updating friend notes for: $friendUid');

      await _firestore
          .collection('users')
          .doc(currentUid)
          .collection('friends')
          .doc(friendUid)
          .update({'notes': notes});

      return true;
    } catch (e) {
      _logger.e('Failed to update friend notes: $e');
      return false;
    }
  }

  /// Stream friends list (real-time)
  Stream<List<Friend>> streamFriends({
    required String uid,
    String status = 'accepted',
  }) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('friends')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Friend.fromJson({...doc.data(), 'uid': doc.id}))
          .toList();
    });
  }

  /// Search for users to add as friends
  Future<List<UserProfile>> searchUsers({required String query}) async {
    try {
      _logger.i('Searching for users: $query');

      final querySnapshot = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: '${query}z')
          .limit(10)
          .get();

      final users = querySnapshot.docs
          .map((doc) => UserProfile.fromJson({...doc.data(), 'uid': doc.id}))
          .toList();

      return users;
    } catch (e) {
      _logger.e('Failed to search users: $e');
      return [];
    }
  }
}
