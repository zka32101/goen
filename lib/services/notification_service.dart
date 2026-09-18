import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/notification.dart';

final _logger = Logger();

/// 通知サービス (FCM + Firestore統合)
class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String notificationsCollection = 'notifications';
  static const String fcmTokensCollection = 'fcmTokens';
  static const String preferencesCollection = 'notificationPreferences';

  /// 通知を送信（保存）
  Future<String?> sendNotification({
    required String uid,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    try {
      _logger.i('Sending notification to user: $uid');

      final docRef = _firestore
          .collection(notificationsCollection)
          .doc(uid)
          .collection('messages')
          .doc();

      final notification = AppNotification(
        id: docRef.id,
        uid: uid,
        title: title,
        body: body,
        data: data,
        type: type,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await docRef.set(notification.toFirestore());
      _logger.i('✅ Notification sent: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.e('Error sending notification: $e');
      rethrow;
    }
  }

  /// ユーザーの通知一覧
  Future<List<AppNotification>> getUserNotifications(
    String uid, {
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      _logger.i('Fetching notifications for user: $uid');

      var query = _firestore
          .collection(notificationsCollection)
          .doc(uid)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (unreadOnly) {
        query = query.where('isRead', isEqualTo: false) as Query;
      }

      final snapshot = await query.get();
      final notifications = snapshot.docs
          .map((doc) => AppNotification.fromFirestore(
              doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();

      _logger.i('✅ Notifications fetched: ${notifications.length}');
      return notifications;
    } catch (e) {
      _logger.e('Error fetching notifications: $e');
      rethrow;
    }
  }

  /// 通知を既読に
  Future<void> markAsRead(String uid, String notificationId) async {
    try {
      _logger.i('Marking notification as read');

      await _firestore
          .collection(notificationsCollection)
          .doc(uid)
          .collection('messages')
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': Timestamp.now(),
      });

      _logger.i('✅ Notification marked as read');
    } catch (e) {
      _logger.e('Error marking as read: $e');
      rethrow;
    }
  }

  /// FCM トークンを登録
  Future<void> registerFcmToken({
    required String uid,
    required String token,
    String? deviceName,
    String? platform,
  }) async {
    try {
      _logger.i('Registering FCM token');

      await _firestore
          .collection(notificationsCollection)
          .doc(uid)
          .collection(fcmTokensCollection)
          .doc(token)
          .set({
        'uid': uid,
        'deviceName': deviceName,
        'platform': platform,
        'registeredAt': Timestamp.now(),
      });

      _logger.i('✅ FCM token registered');
    } catch (e) {
      _logger.e('Error registering FCM token: $e');
      rethrow;
    }
  }

  /// 通知設定を取得
  Future<NotificationPreference?> getNotificationPreference(
      String uid) async {
    try {
      _logger.i('Fetching notification preference');

      final doc = await _firestore
          .collection(notificationsCollection)
          .doc(uid)
          .collection(preferencesCollection)
          .doc('settings')
          .get();

      if (!doc.exists) {
        return null;
      }

      return NotificationPreference.fromFirestore(
          doc as DocumentSnapshot<Map<String, dynamic>>);
    } catch (e) {
      _logger.e('Error fetching preference: $e');
      rethrow;
    }
  }

  /// 通知設定を保存
  Future<void> saveNotificationPreference(
      NotificationPreference preference) async {
    try {
      _logger.i('Saving notification preference');

      await _firestore
          .collection(notificationsCollection)
          .doc(preference.uid)
          .collection(preferencesCollection)
          .doc('settings')
          .set(preference.toFirestore());

      _logger.i('✅ Preference saved');
    } catch (e) {
      _logger.e('Error saving preference: $e');
      rethrow;
    }
  }

  /// 通知をクリア
  Future<void> clearNotifications(String uid) async {
    try {
      _logger.w('Clearing all notifications for user: $uid');

      final snapshot = await _firestore
          .collection(notificationsCollection)
          .doc(uid)
          .collection('messages')
          .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      _logger.i('✅ Notifications cleared');
    } catch (e) {
      _logger.e('Error clearing notifications: $e');
      rethrow;
    }
  }
}
