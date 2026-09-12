import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/extended_game_models.dart';

final _logger = Logger();

/// Service for managing game invitations
class GameInvitationService {
  final FirebaseFirestore _firestore;

  const GameInvitationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _firestoreInstance;

  static final _firestoreInstance = FirebaseFirestore.instance;

  /// Send game invitation
  Future<bool> sendInvitation({
    required String fromUid,
    required String toUid,
    required String gameMode,
    required int boardSize,
    required int aiLevel,
    String? customMessage,
    Duration expirationTime = const Duration(days: 7),
  }) async {
    try {
      _logger.i('Sending game invitation from $fromUid to $toUid');

      final now = DateTime.now();
      final expiresAt = now.add(expirationTime);
      final invitationId = _firestore.collection('gameInvitations').doc().id;

      await _firestore.collection('gameInvitations').doc(invitationId).set({
        'id': invitationId,
        'fromUid': fromUid,
        'toUid': toUid,
        'gameMode': gameMode,
        'boardSize': boardSize,
        'aiLevel': aiLevel,
        'createdAt': now,
        'expiresAt': expiresAt,
        'status': 'pending',
        'customMessage': customMessage ?? '',
      });

      return true;
    } catch (e) {
      _logger.e('Failed to send invitation: $e');
      return false;
    }
  }

  /// Accept game invitation
  Future<bool> acceptInvitation({
    required String invitationId,
  }) async {
    try {
      _logger.i('Accepting invitation: $invitationId');

      await _firestore
          .collection('gameInvitations')
          .doc(invitationId)
          .update({'status': 'accepted'});

      return true;
    } catch (e) {
      _logger.e('Failed to accept invitation: $e');
      return false;
    }
  }

  /// Decline game invitation
  Future<bool> declineInvitation({
    required String invitationId,
  }) async {
    try {
      _logger.i('Declining invitation: $invitationId');

      await _firestore
          .collection('gameInvitations')
          .doc(invitationId)
          .update({'status': 'declined'});

      return true;
    } catch (e) {
      _logger.e('Failed to decline invitation: $e');
      return false;
    }
  }

  /// Cancel sent invitation
  Future<bool> cancelInvitation({
    required String invitationId,
  }) async {
    try {
      _logger.i('Canceling invitation: $invitationId');

      await _firestore
          .collection('gameInvitations')
          .doc(invitationId)
          .delete();

      return true;
    } catch (e) {
      _logger.e('Failed to cancel invitation: $e');
      return false;
    }
  }

  /// Get incoming invitations
  Future<List<GameInvitation>> getIncomingInvitations({
    required String uid,
  }) async {
    try {
      _logger.i('Getting incoming invitations for: $uid');

      final now = DateTime.now();

      final querySnapshot = await _firestore
          .collection('gameInvitations')
          .where('toUid', isEqualTo: uid)
          .where('status', isEqualTo: 'pending')
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .get();

      final invitations = querySnapshot.docs
          .map((doc) => GameInvitation.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return invitations;
    } catch (e) {
      _logger.e('Failed to get incoming invitations: $e');
      return [];
    }
  }

  /// Get outgoing invitations
  Future<List<GameInvitation>> getOutgoingInvitations({
    required String uid,
  }) async {
    try {
      _logger.i('Getting outgoing invitations for: $uid');

      final now = DateTime.now();

      final querySnapshot = await _firestore
          .collection('gameInvitations')
          .where('fromUid', isEqualTo: uid)
          .where('status', isEqualTo: 'pending')
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .get();

      final invitations = querySnapshot.docs
          .map((doc) => GameInvitation.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return invitations;
    } catch (e) {
      _logger.e('Failed to get outgoing invitations: $e');
      return [];
    }
  }

  /// Get invitation by ID
  Future<GameInvitation?> getInvitation({required String invitationId}) async {
    try {
      _logger.i('Getting invitation: $invitationId');

      final doc = await _firestore
          .collection('gameInvitations')
          .doc(invitationId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return GameInvitation.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      _logger.e('Failed to get invitation: $e');
      return null;
    }
  }

  /// Stream incoming invitations (real-time)
  Stream<List<GameInvitation>> streamIncomingInvitations({
    required String uid,
  }) {
    final now = DateTime.now();

    return _firestore
        .collection('gameInvitations')
        .where('toUid', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GameInvitation.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Clean up expired invitations
  Future<int> cleanupExpiredInvitations() async {
    try {
      _logger.i('Cleaning up expired invitations');

      final now = DateTime.now();

      final querySnapshot = await _firestore
          .collection('gameInvitations')
          .where('expiresAt', isLessThan: now)
          .where('status', isEqualTo: 'pending')
          .get();

      var deletedCount = 0;

      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
        deletedCount++;
      }

      _logger.i('Deleted $deletedCount expired invitations');
      return deletedCount;
    } catch (e) {
      _logger.e('Failed to cleanup expired invitations: $e');
      return 0;
    }
  }

  /// Get invitation statistics
  Future<Map<String, dynamic>> getInvitationStats({required String uid}) async {
    try {
      _logger.i('Getting invitation stats for: $uid');

      final incoming = await getIncomingInvitations(uid: uid);
      final outgoing = await getOutgoingInvitations(uid: uid);

      return {
        'incomingCount': incoming.length,
        'outgoingCount': outgoing.length,
        'incomingByMode': _groupByMode(incoming),
      };
    } catch (e) {
      _logger.e('Failed to get invitation stats: $e');
      return {};
    }
  }

  Map<String, int> _groupByMode(List<GameInvitation> invitations) {
    final grouped = <String, int>{};

    for (final invitation in invitations) {
      grouped[invitation.gameMode] = (grouped[invitation.gameMode] ?? 0) + 1;
    }

    return grouped;
  }
}
