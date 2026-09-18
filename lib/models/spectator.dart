import 'package:cloud_firestore/cloud_firestore.dart';

class SpectatorSession {
  final String id;
  final String gameId;
  final String gameType; // 'ai_game', 'pvp_game', 'kifu_replay'
  final String hostUid;
  final String? hostDisplayName;
  final List<String> spectatorUids;
  final int spectatorCount;
  final int moveIndex;
  final bool isLive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? endedAt;

  SpectatorSession({
    required this.id,
    required this.gameId,
    required this.gameType,
    required this.hostUid,
    this.hostDisplayName,
    required this.spectatorUids,
    required this.spectatorCount,
    required this.moveIndex,
    required this.isLive,
    required this.createdAt,
    this.updatedAt,
    this.endedAt,
  });

  bool get isActive => endedAt == null && isLive;

  factory SpectatorSession.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return SpectatorSession(
      id: doc.id,
      gameId: data['gameId'] as String? ?? '',
      gameType: data['gameType'] as String? ?? 'ai_game',
      hostUid: data['hostUid'] as String? ?? '',
      hostDisplayName: data['hostDisplayName'] as String?,
      spectatorUids: List<String>.from(data['spectatorUids'] as List<dynamic>? ?? []),
      spectatorCount: data['spectatorCount'] as int? ?? 0,
      moveIndex: data['moveIndex'] as int? ?? 0,
      isLive: data['isLive'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      endedAt: data['endedAt'] != null
          ? (data['endedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'gameId': gameId,
      'gameType': gameType,
      'hostUid': hostUid,
      'hostDisplayName': hostDisplayName,
      'spectatorUids': spectatorUids,
      'spectatorCount': spectatorCount,
      'moveIndex': moveIndex,
      'isLive': isLive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt ?? DateTime.now()),
      'endedAt': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
    };
  }
}

class SpectatorComment {
  final String id;
  final String spectatorSessionId;
  final String uid;
  final String displayName;
  final String comment;
  final int moveIndex;
  final DateTime createdAt;
  final List<String> likes;

  SpectatorComment({
    required this.id,
    required this.spectatorSessionId,
    required this.uid,
    required this.displayName,
    required this.comment,
    required this.moveIndex,
    required this.createdAt,
    required this.likes,
  });

  factory SpectatorComment.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return SpectatorComment(
      id: doc.id,
      spectatorSessionId: data['spectatorSessionId'] as String? ?? '',
      uid: data['uid'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      comment: data['comment'] as String? ?? '',
      moveIndex: data['moveIndex'] as int? ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      likes: List<String>.from(data['likes'] as List<dynamic>? ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'spectatorSessionId': spectatorSessionId,
      'uid': uid,
      'displayName': displayName,
      'comment': comment,
      'moveIndex': moveIndex,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }
}

class SpectatorNotification {
  final String id;
  final String uid;
  final String title;
  final String body;
  final String? spectatorSessionId;
  final String? hostUid;
  final String? hostDisplayName;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  SpectatorNotification({
    required this.id,
    required this.uid,
    required this.title,
    required this.body,
    this.spectatorSessionId,
    this.hostUid,
    this.hostDisplayName,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory SpectatorNotification.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return SpectatorNotification(
      id: doc.id,
      uid: data['uid'] as String? ?? '',
      title: data['title'] as String? ?? '',
      body: data['body'] as String? ?? '',
      spectatorSessionId: data['spectatorSessionId'] as String?,
      hostUid: data['hostUid'] as String?,
      hostDisplayName: data['hostDisplayName'] as String?,
      isRead: data['isRead'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      readAt: data['readAt'] != null
          ? (data['readAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'title': title,
      'body': body,
      'spectatorSessionId': spectatorSessionId,
      'hostUid': hostUid,
      'hostDisplayName': hostDisplayName,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }
}
