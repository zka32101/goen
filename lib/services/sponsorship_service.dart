import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';

final _logger = Logger();

/// スポンサーシップ管理サービス
class SponsorshipService {
  final FirebaseFirestore _firestore;

  SponsorshipService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// スポンサーシップを開始。
  ///
  /// Firestoreのトランザクション内では特定ドキュメント参照の読み取りしか
  /// できず、クエリは打てない。そのため、ドキュメントIDを
  /// `{sponsorUserId}_{sponsoredUserId}` の決め打ちにして、重複確認と
  /// ティアの `currentSubscribers` 加算を1つのトランザクション内で完結させ、
  /// 二重タップでの二重登録・購読者数の不整合を防ぐ（同じ相手への再スポンサー
  /// はこの1レコードを使い回し、statusを'active'に戻す）。
  Future<SponsorshipRecord?> startSponsorship(
    String sponsorUserId,
    String sponsoredUserId,
    String tierId,
    String message,
  ) async {
    try {
      _logger.i('Starting sponsorship: $sponsorUserId -> $sponsoredUserId');

      final sponsorDoc =
          await _firestore.collection('users').doc(sponsorUserId).get();
      final sponsorDisplayName =
          sponsorDoc.data()?['displayName'] ?? 'Anonymous Sponsor';

      final tierRef = _firestore
          .collection('users')
          .doc(sponsoredUserId)
          .collection('sponsorshipTiers')
          .doc(tierId);
      final docRef = _firestore
          .collection('sponsorships')
          .doc('${sponsorUserId}_$sponsoredUserId');

      final result = await _firestore.runTransaction<SponsorshipRecord?>((transaction) async {
        final tierDoc = await transaction.get(tierRef);
        if (!tierDoc.exists) {
          throw Exception('Sponsorship tier not found');
        }

        final existingDoc = await transaction.get(docRef);
        if (existingDoc.exists && existingDoc.data()?['status'] == 'active') {
          _logger.w('Sponsor $sponsorUserId already sponsors $sponsoredUserId');
          return null;
        }

        final tierData = tierDoc.data()!;
        final amountUSD = tierData['priceUSD'] as int;
        final tierName = tierData['name'] ?? 'Unknown Tier';
        final perks = List<String>.from(tierData['benefits'] ?? []);
        final maxSlots = tierData['maxSlots'] as int? ?? 0;
        final currentSubscribers = tierData['currentSubscribers'] as int? ?? 0;

        if (maxSlots > 0 && currentSubscribers >= maxSlots) {
          throw Exception('Sponsorship tier is full');
        }

        transaction.set(docRef, {
          'id': docRef.id,
          'sponsorUserId': sponsorUserId,
          'sponsorDisplayName': sponsorDisplayName,
          'sponsoredUserId': sponsoredUserId,
          'tierId': tierId,
          'tierName': tierName,
          'amountUSD': amountUSD,
          'message': message,
          'perks': perks,
          'status': 'active',
          'startDate': FieldValue.serverTimestamp(),
          'endDate': null,
        });
        transaction.update(tierRef, {'currentSubscribers': currentSubscribers + 1});

        return SponsorshipRecord(
          id: docRef.id,
          sponsorUserId: sponsorUserId,
          sponsorDisplayName: sponsorDisplayName,
          sponsoredUserId: sponsoredUserId,
          tierId: tierId,
          tierName: tierName,
          amountUSD: amountUSD,
          startDate: DateTime.now(),
          endDate: null,
          status: 'active',
          message: message,
          perks: perks,
        );
      });

      if (result != null) {
        await _createSponsorshipNotification(
          sponsoredUserId,
          sponsorUserId,
          result.amountUSD,
          result.tierName,
          'new_sponsor',
        );
        _logger.i('Sponsorship created: ${result.id}');
      }

      return result;
    } catch (e) {
      _logger.e('Error starting sponsorship: $e');
      rethrow;
    }
  }

  /// スポンサーシップをキャンセルし、ティアの購読者数を1減らす。
  Future<bool> cancelSponsorship(String sponsorshipId) async {
    try {
      _logger.i('Cancelling sponsorship: $sponsorshipId');

      final sponsorshipRef = _firestore.collection('sponsorships').doc(sponsorshipId);

      await _firestore.runTransaction<void>((transaction) async {
        final doc = await transaction.get(sponsorshipRef);
        if (!doc.exists) return;

        final data = doc.data()!;
        if (data['status'] != 'active') return;

        transaction.update(sponsorshipRef, {
          'status': 'cancelled',
          'endDate': FieldValue.serverTimestamp(),
        });

        final sponsoredUserId = data['sponsoredUserId'] as String?;
        final tierId = data['tierId'] as String?;
        if (sponsoredUserId != null && tierId != null) {
          final tierRef = _firestore
              .collection('users')
              .doc(sponsoredUserId)
              .collection('sponsorshipTiers')
              .doc(tierId);
          final tierDoc = await transaction.get(tierRef);
          if (tierDoc.exists) {
            final current = tierDoc.data()?['currentSubscribers'] as int? ?? 0;
            transaction.update(tierRef, {
              'currentSubscribers': current > 0 ? current - 1 : 0,
            });
          }
        }
      });

      _logger.i('Sponsorship cancelled: $sponsorshipId');
      return true;
    } catch (e) {
      _logger.e('Error cancelling sponsorship: $e');
      rethrow;
    }
  }

  /// スポンサーシップをアップグレード
  Future<bool> upgradeSponsorship(
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
        final data = doc.data();
        return SponsorshipRecord(
          id: doc.id,
          sponsorUserId: data['sponsorUserId'] ?? '',
          sponsorDisplayName: data['sponsorDisplayName'] ?? 'Anonymous Sponsor',
          sponsoredUserId: data['sponsoredUserId'] ?? '',
          tierId: data['tierId'] ?? '',
          tierName: data['tierName'] ?? 'Unknown Tier',
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
        final data = doc.data();
        return SponsorshipRecord(
          id: doc.id,
          sponsorUserId: data['sponsorUserId'] ?? '',
          sponsorDisplayName: data['sponsorDisplayName'] ?? 'Anonymous Sponsor',
          sponsoredUserId: data['sponsoredUserId'] ?? '',
          tierId: data['tierId'] ?? '',
          tierName: data['tierName'] ?? 'Unknown Tier',
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
        final data = doc.data();
        return SponsorshipTier(
          id: doc.id,
          name: data['name'] ?? '',
          priceUSD: data['priceUSD'] ?? 0,
          description: data['description'] ?? '',
          benefits: List<String>.from(data['benefits'] ?? []),
          currentSubscribers: data['currentSubscribers'] ?? 0,
        );
      }).toList();

      // DocumentSnapshot's operator[] throws StateError for a field that's
      // absent from the document entirely (unlike a plain Map, where a
      // missing key just reads as null) — User has no profileImageUrl field
      // at all, so this must go through data() first to stay safe.
      final userData = userDoc.data() ?? {};
      return SponsorInfo(
        userId: userId,
        displayName: userData['displayName'] ?? 'Unknown',
        avatarUrl: userData['profileImageUrl'],
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
    List<String> benefits, {
    int maxSlots = 0,
  }) async {
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
        'maxSlots': maxSlots,
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
        maxSlots: maxSlots,
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
        final data = doc.data();
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
