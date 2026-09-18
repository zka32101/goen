import 'package:riverpod/riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/notification.dart';
import 'package:goen/services/notification_service.dart';

final _logger = Logger();

/// Notification Service プロバイダー
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// ユーザーの通知一覧
final userNotificationsProvider =
    FutureProvider.family<List<AppNotification>, String>(
  (ref, uid) async {
    _logger.i('Loading notifications for user: $uid');
    final service = ref.watch(notificationServiceProvider);

    try {
      final notifications = await service.getUserNotifications(uid);
      _logger.i('✅ Notifications loaded: ${notifications.length}');
      return notifications;
    } catch (e) {
      _logger.e('❌ Failed to load notifications: $e');
      rethrow;
    }
  },
);

/// 未読通知のみ
final unreadNotificationsProvider =
    FutureProvider.family<List<AppNotification>, String>(
  (ref, uid) async {
    _logger.i('Loading unread notifications');
    final service = ref.watch(notificationServiceProvider);

    try {
      final notifications =
          await service.getUserNotifications(uid, unreadOnly: true);
      _logger.i('✅ Unread notifications loaded: ${notifications.length}');
      return notifications;
    } catch (e) {
      _logger.e('❌ Failed to load unread: $e');
      rethrow;
    }
  },
);

/// 未読通知数
final unreadNotificationCountProvider =
    FutureProvider.family<int, String>((ref, uid) async {
  final unread = await ref.watch(unreadNotificationsProvider(uid).future);
  return unread.length;
});

/// 通知設定を取得
final notificationPreferenceProvider =
    FutureProvider.family<NotificationPreference?, String>(
  (ref, uid) async {
    _logger.i('Loading notification preference');
    final service = ref.watch(notificationServiceProvider);

    try {
      final preference = await service.getNotificationPreference(uid);
      return preference;
    } catch (e) {
      _logger.e('❌ Failed to load preference: $e');
      return null;
    }
  },
);

/// 通知を送信
final sendNotificationProvider = Provider<
    Future<String?> Function({
      required String uid,
      required String title,
      required String body,
      required String type,
      Map<String, dynamic>? data,
    })>((ref) {
  final service = ref.read(notificationServiceProvider);

  return ({
    required String uid,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    _logger.i('Sending notification');
    try {
      final notificationId = await service.sendNotification(
        uid: uid,
        title: title,
        body: body,
        type: type,
        data: data,
      );
      _logger.i('✅ Notification sent');
      return notificationId;
    } catch (e) {
      _logger.e('❌ Failed to send notification: $e');
      rethrow;
    }
  };
});

/// 通知を既読に
final markNotificationAsReadProvider = Provider<
    Future<void> Function({
      required String uid,
      required String notificationId,
    })>((ref) {
  final service = ref.read(notificationServiceProvider);

  return ({
    required String uid,
    required String notificationId,
  }) async {
    _logger.i('Marking as read');
    try {
      await service.markAsRead(uid, notificationId);
      _logger.i('✅ Marked as read');
    } catch (e) {
      _logger.e('❌ Failed to mark as read: $e');
      rethrow;
    }
  };
});

/// FCM トークン登録
final registerFcmTokenProvider = Provider<
    Future<void> Function({
      required String uid,
      required String token,
      String? deviceName,
      String? platform,
    })>((ref) {
  final service = ref.read(notificationServiceProvider);

  return ({
    required String uid,
    required String token,
    String? deviceName,
    String? platform,
  }) async {
    _logger.i('Registering FCM token');
    try {
      await service.registerFcmToken(
        uid: uid,
        token: token,
        deviceName: deviceName,
        platform: platform,
      );
      _logger.i('✅ FCM token registered');
    } catch (e) {
      _logger.e('❌ Failed to register: $e');
      rethrow;
    }
  };
});

/// 通知設定を保存
final saveNotificationPreferenceProvider = Provider<
    Future<void> Function(NotificationPreference)>((ref) {
  final service = ref.read(notificationServiceProvider);

  return (preference) async {
    _logger.i('Saving preference');
    try {
      await service.saveNotificationPreference(preference);
      _logger.i('✅ Preference saved');
    } catch (e) {
      _logger.e('❌ Failed to save: $e');
      rethrow;
    }
  };
});

/// 通知をクリア
final clearNotificationsProvider = Provider<
    Future<void> Function(String)>((ref) {
  final service = ref.read(notificationServiceProvider);

  return (uid) async {
    _logger.w('Clearing notifications');
    try {
      await service.clearNotifications(uid);
      _logger.i('✅ Cleared');
    } catch (e) {
      _logger.e('❌ Failed to clear: $e');
      rethrow;
    }
  };
});
