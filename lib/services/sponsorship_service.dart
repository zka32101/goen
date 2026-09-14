import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';

final _logger = Logger();

/// スポンサーシップ管理サービス
class SponsorshipService {
  final FirebaseFirestore _firestore;

  SponsorshipService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// スポンサーシップを開始
  Future<SponsorshipRecord?> startSponsorship(
    String sponsorUserId,
    String sponsoredUserId,
    String tierId,
    String message,
  ) async {
    try {
      _logger.i('Starting sponsorship: $sponsorUserId -> $sponsoredUserId');

      // ティア情報を取得
      final tierDoc = await _firestore
          .collection('users')
          .doc(sponsoredUserId)
          .collection('sponsorshipTiers')
          .doc(tierId)
          .get();

      if (!tierDoc.exists) {
        throw Exception('Sponsorship tier not found');
      }

      final tierData = tierDoc.data()!;
      final amountUSD = tierData['priceUSD'] as int;

      // スポンサーシップレコードを作成
      final docRef =
          _firestore.collection('sponsorships').doc();

      final sponsorshipData = {
        'id': docRef.id,
        'sponsorUserId': sponsorUserId,
        'sponsoredUserId': sponsoredUserId,
        'tierId': tierId,
        'tierName': tierData['name'],
        'amountUSD': amountUSD,
        'message': message,
        'perks': tierData['benefits'] ?? [],
        'status': 'active',
        'startDate': FieldValue.serverTimestamp(),
        'endDate': null,
      };

      await docRef.set(sponsorshipData);

      // 通知を作成
      await _createSponsorshipNotification(
        sponsoredUserId,
        sponsorUserId,
        amountUSD,
        tierData['name'] ?? 'Unknown Tier',
        'new_sponsor',
      );

      _logger.i('Sponsorship created: ${docRef.id}');

      return SponsorshipRecord(
        id: docRef.id,
        sponsorUserId: sponsorUserId,
        sponsoredUserId: sponsoredUserId,
        amountUSD: amountUSD,
        startDate: DateTime.now(),
        status: 'active',
        message: message,
        perks: List<String>.from(tierData['benefits'] ?? []),
      );
    } catch (e) {
      _logger.e('Error starting sponsorship: $e');
      rethrow;
    }
  }

  /// スポンサーシップをキャンセル
  Future<bool> cancelSponsorship(String sponsorshipId) async {
    try {
      _logger.i('Cancelling sponsorship: $sponsorshipId');

      await _firestore.collection('sponsorships').doc(sponsorshipId).update({
        'status': 'cancelled',
        'endDate': FieldValue.serverTimestamp(),
      });

      _logger.i('Sponsorship cancelled: $sponsorshipId');
      return true;
    } catch (e) {
      _logger.e('Error cancelling sponsorship: $e');
      rethrow;
    }
  }

  /// スポンサーシップをアップグレード
  Future<bool> upgradeSponsor ship(
    String sponsorshipId,
    String newTierId,
  ) async {
    try {
      _logger.i('Upgrading sponsorship: $sponsorshipId to tier: $newTierId');

      final doc = await _firestore
          .collection('sponsorships')
          .doc(sponsorshipId)
          .get();

      if (!doc.exists) {
        throw Exception('Sponsorship not found');
      }

      final data = doc.data()!;
      final sponsoredUserId = data['sponsoredUserId'] as String;

      // 新しいティアを取得
      final tierDoc = await _firestore
          .collection('users')
          .doc(sponsoredUserId)
          .collection('sponsorshipTiers')
          .doc(newTierId)
          .get();

      if (!tierDoc.exists) {
        throw Exception('New tier not found');
      }

      final tierData = tierDoc.data()!;

      await doc.reference.update({
        'tierId': newTierId,
        'tierName': tierData['name'],
        'amountUSD': tierData['priceUSD'],
        'perks': tierData['benefits'] ?? [],
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // アップグレード通知を作成
      await _createSponsorshipNotification(
        sponsoredUserId,
        data['sponsorUserId'],
        tierData['priceUSD'],
        tierData['name'],
        'tier_upgrade',
      );

      _logger.i('Sponsorship upgraded: $sponsorshipId');
      return true;
    } catch (e) {
      _logger.e('Error upgrading sponsorship: $e');
      rethrow;
    }
  }

  /// ユーザーが受けているスポンサーシップを取得
  Future<List<SponsorshipRecord>> getIncomingSponsorships(String userId) async {
    try {
      _logger.d('Fetching incoming sponsorships for user: $userId');

      final querySnapshot = await _firestore
          .collection('sponsorships')
          .where('sponsoredUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('startDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data;
        return SponsorshipRecord(
          id: doc.id,
          sponsorUserId: data['sponsorUserId'] ?? '',
          sponsoredUserId: data['sponsoredUserId'] ?? '',
          amountUSD: data['amountUSD'] ?? 0,
          startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          endDate: data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
          status: data['status'] ?? 'active',
          message: data['message'] ?? '',
          perks: List<String>.from(data['perks'] ?? []),
        );
      }).toList();
    } catch (e) {
      _logger.e('Error fetching incoming sponsorships: $e');
      rethrow;
    }
  }

  /// ユーザーがしているスポンサーシップを取得
  Future<List<SponsorshipRecord>> getOutgoingSponsorships(String userId) async {
    try {
      _logger.d('Fetching outgoing sponsorships for user: $userId');

      final querySnapshot = await _firestore
          .collection('sponsorships')
          .where('sponsorUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .orderBy('startDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data;
        return SponsorshipRecord(
          id: doc.id,
          sponsorUserId: data['sponsorUserId'] ?? '',
          sponsoredUserId: data['sponsoredUserId'] ?? '',
          amountUSD: data['amountUSD'] ?? 0,
          startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
          endDate: data['endDate'] != null
              ? (data['endDate'] as Timestamp).toDate()
              : null,
          status: data['status'] ?? 'active',
          message: data['message'] ?? '',
          perks: List<String>.from(data['perks'] ?? []),
        );
      }).toList();
    } catch (e) {
      _logger.e('Error fetching outgoing sponsorships: $e');
      rethrow;
    }
  }

  /// スポンサー情報を取得
  Future<SponsorInfo?> getSponsorInfo(String userId) async {
    try {
      _logger.d('Fetching sponsor info for user: $userId');

      // ユーザー情報と統計を取得
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return null;
      }

      // スポンサー数を計算
      final incomingSnapshot = await _firestore
          .collection('sponsorships')
          .where('sponsoredUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      final outgoingSnapshot = await _firestore
          .collection('sponsorships')
          .where('sponsorUserId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();

      // 月間収入を計算
      int monthlyUSD = 0;
      for (var doc in incomingSnapshot.docs) {
        monthlyUSD += (doc['amountUSD'] as int? ?? 0);
      }

      // 利用可能なティアを取得
      final tiersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sponsorshipTiers')
          .get();

      final tiers = tiersSnapshot.docs.map((doc) {
        final data = doc.data;
        return SponsorshipTier(
          id: doc.id,
          name: data['name'] ?? '',
          priceUSD: data['priceUSD'] ?? 0,
          description: data['description'] ?? '',
          benefits: List<String>.from(data['benefits'] ?? []),
          currentSubscribers: data['currentSubscribers'] ?? 0,
        );
      }).toList();

      return SponsorInfo(
        userId: userId,
        displayName: userDoc['displayName'] ?? 'Unknown',
        avatarUrl: userDoc['profileImageUrl'],
        totalSponsorCount: outgoingSnapshot.size,
        totalSponsorshipCount: incomingSnapshot.size,
        totalMonthlyUSD: monthlyUSD,
        availableTiers: tiers,
      );
    } catch (e) {
      _logger.e('Error fetching sponsor info: $e');
      rethrow;
    }
  }

  /// スポンサーシップティアを作成
  Future<SponsorshipTier?> createSponsorshipTier(
    String userId,
    String name,
    int priceUSD,
    String description,
    List<String> benefits,
  ) async {
    try {
      _logger.i('Creating sponsorship tier for user: $userId');

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('sponsorshipTiers')
          .doc();

      final tierData = {
        'name': name,
        'priceUSD': priceUSD,
        'description': description,
        'benefits': benefits,
        'currentSubscribers': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await docRef.set(tierData);
      _logger.i('Sponsorship tier created: ${docRef.id}');

      return SponsorshipTier(
        id: docRef.id,
        name: name,
        priceUSD: priceUSD,
        description: description,
        benefits: benefits,
      );
    } catch (e) {
      _logger.e('Error creating sponsorship tier: $e');
      rethrow;
    }
  }

  /// スポンサーシップ通知を作成（内部用）
  Future<void> _createSponsorshipNotification(
    String recipientUserId,
    String sponsorUserId,
    int amountUSD,
    String tier,
    String type,
  ) async {
    try {
      // スポンサー情報を取得
      final sponsorDoc =
          await _firestore.collection('users').doc(sponsorUserId).get();
      final sponsorName =
          sponsorDoc.data()?['displayName'] ?? 'Anonymous Sponsor';

      // 通知を作成
      await _firestore
          .collection('users')
          .doc(recipientUserId)
          .collection('sponsorshipNotifications')
          .add({
        'sponsorUserId': sponsorUserId,
        'sponsorName': sponsorName,
        'amountUSD': amountUSD,
        'tier': tier,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Sponsorship notification created for: $recipientUserId');
    } catch (e) {
      _logger.e('Error creating sponsorship notification: $e');
    }
  }

  /// スポンサーシップ通知を取得
  Future<List<SponsorshipNotification>> getNotifications(String userId) async {
    try {
      _logger.d('Fetching sponsorship notifications for user: $userId');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('sponsorshipNotifications')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data;
        return SponsorshipNotification(
          id: doc.id,
          recipientUserId: userId,
          sponsorUserId: data['sponsorUserId'] ?? '',
          sponsorName: data['sponsorName'] ?? 'Anonymous',
          amountUSD: data['amountUSD'] ?? 0,
          tier: data['tier'] ?? 'Unknown',
          type: data['type'] ?? 'new_sponsor',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isRead: data['isRead'] ?? false,
        );
      }).toList();
    } catch (e) {
      _logger.e('Error fetching sponsorship notifications: $e');
      rethrow;
    }
  }
}
