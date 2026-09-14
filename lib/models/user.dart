import 'package:cloud_firestore/cloud_firestore.dart';

/// User profile and subscription status
class User {
  final String uid;
  final String email;
  final String? displayName;
  final bool subscriptionActive;
  final DateTime subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final bool tutorialCompleted;
  final int gamesPlayedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.uid,
    required this.email,
    this.displayName,
    required this.subscriptionActive,
    required this.subscriptionStartDate,
    this.subscriptionEndDate,
    required this.tutorialCompleted,
    required this.gamesPlayedCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document
  factory User.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return User(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      subscriptionActive: data['subscriptionActive'] ?? false,
      subscriptionStartDate: (data['subscriptionStartDate'] as Timestamp).toDate(),
      subscriptionEndDate: data['subscriptionEndDate'] != null
          ? (data['subscriptionEndDate'] as Timestamp).toDate()
          : null,
      tutorialCompleted: data['tutorialCompleted'] ?? false,
      gamesPlayedCount: data['gamesPlayedCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'subscriptionActive': subscriptionActive,
      'subscriptionStartDate': Timestamp.fromDate(subscriptionStartDate),
      'subscriptionEndDate': subscriptionEndDate != null
          ? Timestamp.fromDate(subscriptionEndDate!)
          : null,
      'tutorialCompleted': tutorialCompleted,
      'gamesPlayedCount': gamesPlayedCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Copy with modifications
  User copyWith({
    String? email,
    String? displayName,
    bool? subscriptionActive,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    bool? tutorialCompleted,
    int? gamesPlayedCount,
    DateTime? updatedAt,
  }) {
    return User(
      uid: uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      subscriptionActive: subscriptionActive ?? this.subscriptionActive,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
      gamesPlayedCount: gamesPlayedCount ?? this.gamesPlayedCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  String toString() =>
      'User(uid: $uid, email: $email, subscriptionActive: $subscriptionActive, tutorialCompleted: $tutorialCompleted)';
}
