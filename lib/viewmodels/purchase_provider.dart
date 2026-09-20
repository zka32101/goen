import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riverpod/riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/services/index.dart';
import 'package:goen/viewmodels/auth_provider.dart';

final _logger = Logger();

/// Singleton instance of PurchaseService
final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  return PurchaseService();
});

/// Buys the given subscription plan through the platform store, persists
/// the resulting subscription status to Firestore on success, and
/// refreshes AuthService's cache + currentUserProvider so the paywall gate
/// reflects it immediately.
///
/// Throws [PurchaseUnavailableException] when the store or product isn't
/// available yet (e.g. product IDs not configured in App Store
/// Connect/Play Console) rather than faking success — see the Twitch/
/// YouTube "not yet available" precedent elsewhere in the app.
final purchaseSubscriptionProvider = Provider<Future<void> Function(SubscriptionPlan plan)>((ref) {
  final purchaseService = ref.watch(purchaseServiceProvider);
  final authService = ref.watch(authServiceProvider);
  final firestoreService = FirestoreService();

  return (plan) async {
    _logger.i('Purchase initiated: ${plan.name}');

    final available = await purchaseService.isAvailable();
    if (!available) {
      throw PurchaseUnavailableException('この端末では購入機能を利用できません。');
    }

    final product = await purchaseService.fetchProduct(plan.productId);
    if (product == null) {
      throw PurchaseUnavailableException('このプランは現在ご購入いただけません。しばらくしてから再度お試しください。');
    }

    final completer = Completer<PurchaseDetails>();
    late final StreamSubscription<List<PurchaseDetails>> subscription;
    subscription = purchaseService.purchaseStream.listen(
      (purchases) {
        for (final purchase in purchases) {
          if (purchase.productID != product.id || completer.isCompleted) continue;
          switch (purchase.status) {
            case PurchaseStatus.purchased:
            case PurchaseStatus.restored:
              completer.complete(purchase);
              break;
            case PurchaseStatus.error:
              // Acknowledge it too, or the store will keep redelivering
              // this failed transaction on every future launch.
              purchaseService.completePurchase(purchase);
              completer.completeError(purchase.error ?? Exception('Purchase failed'));
              break;
            case PurchaseStatus.canceled:
              purchaseService.completePurchase(purchase);
              completer.completeError(Exception('canceled'));
              break;
            case PurchaseStatus.pending:
              break;
          }
        }
      },
      onError: (Object e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
    );

    try {
      final started = await purchaseService.buy(product);
      if (!started) {
        throw Exception('Failed to start purchase flow');
      }

      final purchase = await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw Exception('Purchase timed out'),
      );

      final uid = authService.currentUser?.uid;
      if (uid != null) {
        // Re-fetch the authoritative Firestore record rather than trusting
        // authService.currentUser here: that getter can still return a
        // fabricated fallback (tutorialCompleted/gamesPlayedCount reset to
        // false/0) in the brief window before the auth stream's first
        // event lands, and saveUser's merge-set would otherwise overwrite
        // those real fields with the fallback's zeroed-out ones.
        final now = DateTime.now();
        final freshUser = await firestoreService.getUser(uid) ?? authService.currentUser!;
        final entitlementLength = plan.entitlementLength;
        final updated = freshUser.copyWith(
          subscriptionActive: true,
          subscriptionStartDate: now,
          // null entitlementLength (lifetime) means no expiration.
          subscriptionEndDate: entitlementLength == null ? null : now.add(entitlementLength),
          updatedAt: now,
        );
        await firestoreService.saveUser(updated);
        authService.refreshCachedUser(updated);
        ref.invalidate(currentUserProvider);
      }

      await purchaseService.completePurchase(purchase);
      _logger.i('✅ Purchase completed: ${product.id}');
    } finally {
      await subscription.cancel();
    }
  };
});
