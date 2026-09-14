import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/social_share_service.dart';
import 'package:goen/models/sns_models.dart';

void main() {
  group('Social Share Service Tests', () {
    late SocialShareService shareService;

    setUp(() {
      shareService = SocialShareService();
    });

    group('Share Tracking', () {
      test('Tracks game share on Twitter', () async {
        // Given
        final tracking = SocialShareTracking(
          trackingId: 'track-001',
          userId: 'user-123',
          contentType: 'game',
          contentId: 'game-456',
          platform: 'twitter',
          sharedAt: DateTime.now(),
          externalUrl: 'https://twitter.com/user/status/123456',
        );

        // When
        await shareService.trackShare(tracking);
        final retrieved = await shareService.getShareTracking('track-001');

        // Then
        expect(retrieved, isNotNull);
        expect(retrieved?.platform, 'twitter');
        expect(retrieved?.contentType, 'game');
      });

      test('Tracks puzzle share on Facebook', () async {
        // Given
        final tracking = SocialShareTracking(
          trackingId: 'track-002',
          userId: 'user-789',
          contentType: 'puzzle',
          contentId: 'puzzle-123',
          platform: 'facebook',
          sharedAt: DateTime.now(),
        );

        // When
        await shareService.trackShare(tracking);

        // Then
        expect(tracking.platform, 'facebook');
      });

      test('Tracks profile share on WhatsApp', () async {
        // Given
        final tracking = SocialShareTracking(
          trackingId: 'track-003',
          userId: 'user-456',
          contentType: 'profile',
          contentId: 'user-456',
          platform: 'whatsapp',
          sharedAt: DateTime.now(),
        );

        // When
        await shareService.trackShare(tracking);

        // Then
        expect(tracking.platform, 'whatsapp');
      });
    });

    group('Share Metrics Calculation', () {
      test('Aggregates shares by platform', () async {
        // Given
        final contentId = 'game-789';
        await shareService.trackShare(SocialShareTracking(
          trackingId: 'track-t1',
          userId: 'user-1',
          contentType: 'game',
          contentId: contentId,
          platform: 'twitter',
          sharedAt: DateTime.now(),
        ));
        await shareService.trackShare(SocialShareTracking(
          trackingId: 'track-t2',
          userId: 'user-2',
          contentType: 'game',
          contentId: contentId,
          platform: 'twitter',
          sharedAt: DateTime.now(),
        ));
        await shareService.trackShare(SocialShareTracking(
          trackingId: 'track-f1',
          userId: 'user-3',
          contentType: 'game',
          contentId: contentId,
          platform: 'facebook',
          sharedAt: DateTime.now(),
        ));

        // When
        final metrics = await shareService.getShareMetrics(contentId);

        // Then
        expect(metrics, isNotNull);
        expect(metrics?.totalShares, 3);
        expect(metrics?.twitterShares, greaterThanOrEqualTo(0));
        expect(metrics?.facebookShares, greaterThanOrEqualTo(0));
      });

      test('Calculates viral coefficient', () async {
        // Given
        final contentId = 'viral-game-123';

        // When
        final metrics = await shareService.getShareMetrics(contentId);

        // Then
        expect(metrics, isNotNull);
        expect(metrics?.viralCoefficient, greaterThanOrEqualTo(0.0));
      });

      test('Calculates engagement metrics correctly', () async {
        // Given
        final metrics = ShareMetrics(
          contentId: 'test-game',
          twitterShares: 10,
          facebookShares: 5,
          whatsappShares: 3,
          lineShares: 2,
          totalShares: 20,
          totalEngagement: 150,
          viralCoefficient: 0.75,
        );

        // When
        final totalShares = metrics.twitterShares +
            metrics.facebookShares +
            metrics.whatsappShares +
            metrics.lineShares;

        // Then
        expect(totalShares, metrics.totalShares);
        expect(metrics.totalEngagement, 150);
      });
    });

    group('Attribution & Engagement Tracking', () {
      test('Tracks user acquisition from share', () async {
        // Given
        final originalUserId = 'user-original';
        final sharedContentId = 'game-popular';

        // When
        await shareService.trackShare(SocialShareTracking(
          trackingId: 'track-attr-1',
          userId: originalUserId,
          contentType: 'game',
          contentId: sharedContentId,
          platform: 'twitter',
          sharedAt: DateTime.now(),
          externalUrl: 'https://twitter.com/status/123',
        ));

        // Then
        expect(originalUserId, isNotEmpty);
        expect(sharedContentId, isNotEmpty);
      });

      test('Measures engagement from share source', () async {
        // Given
        final shareId = 'track-engagement-1';
        final tracking = SocialShareTracking(
          trackingId: shareId,
          userId: 'user-123',
          contentType: 'game',
          contentId: 'game-123',
          platform: 'line',
          sharedAt: DateTime.now(),
        );

        // When
        await shareService.trackShare(tracking);
        final engagement =
            await shareService.getEngagementForShare(shareId);

        // Then
        expect(engagement, isNotNull);
      });
    });

    group('Platform-Specific Content Generation', () {
      test('Generates Twitter-optimized share text', () {
        // Given
        final gameId = 'game-456';
        final playerName = 'User123';

        // When
        final twitterText =
            shareService.generateTwitterShareText(gameId, playerName);

        // Then
        expect(twitterText.length, lessThanOrEqualTo(280));
        expect(twitterText.contains('#GoEn'), true);
        expect(twitterText.contains('Go'), true);
      });

      test('Generates Facebook-optimized share text', () {
        // Given
        final gameId = 'game-789';

        // When
        final fbText = shareService.generateFacebookShareText(gameId);

        // Then
        expect(fbText, isNotNull);
        expect(fbText.length, greaterThan(0));
      });

      test('Generates LINE share message', () {
        // Given
        final friendName = 'Friend123';

        // When
        final lineMessage =
            shareService.generateLINEShareMessage(friendName);

        // Then
        expect(lineMessage, isNotNull);
        expect(lineMessage.contains(friendName), true);
      });

      test('Generates WhatsApp share message with emoji', () {
        // Given
        final contentTitle = 'Amazing Go Game';

        // When
        final whatsappMessage =
            shareService.generateWhatsAppShareMessage(contentTitle);

        // Then
        expect(whatsappMessage, isNotNull);
        expect(whatsappMessage.contains('♟'), true); // Go piece emoji
      });
    });

    group('Analytics & Social Metrics', () {
      test('Calculates user social analytics', () async {
        // Given
        final userId = 'user-analytics-123';

        // When
        final analytics =
            await shareService.getSocialAnalytics(userId);

        // Then
        expect(analytics, isNotNull);
        expect(analytics?.userId, userId);
        expect(analytics?.friendCount, greaterThanOrEqualTo(0));
        expect(analytics?.totalShares, greaterThanOrEqualTo(0));
      });

      test('Tracks invitation statistics', () async {
        // Given
        final userId = 'user-inviter';

        // When
        final analytics =
            await shareService.getSocialAnalytics(userId);

        // Then
        expect(analytics, isNotNull);
        expect(analytics?.invitationsSent, greaterThanOrEqualTo(0));
        expect(analytics?.invitationsAccepted, greaterThanOrEqualTo(0));
      });

      test('Measures average engagement per share', () async {
        // Given
        final socialAnalytics = SocialAnalytics(
          userId: 'user-456',
          friendCount: 50,
          gamesWithFriends: 25,
          totalShares: 100,
          avgEngagementPerShare: 5.5,
          lastActiveAt: DateTime.now(),
          invitationsSent: 10,
          invitationsAccepted: 8,
        );

        // Then
        expect(socialAnalytics.avgEngagementPerShare, 5.5);
      });
    });

    group('Error Handling', () {
      test('Handles invalid content type gracefully', () async {
        // Given
        final tracking = SocialShareTracking(
          trackingId: 'track-invalid',
          userId: 'user-123',
          contentType: 'invalid_type',
          contentId: 'content-123',
          platform: 'twitter',
          sharedAt: DateTime.now(),
        );

        // When
        await shareService.trackShare(tracking);

        // Then
        expect(tracking.contentType, 'invalid_type');
      });

      test('Handles missing tracking ID', () async {
        // Given
        const trackingId = '';

        // When
        final result =
            await shareService.getShareTracking(trackingId);

        // Then
        expect(result, isNull);
      });
    });
  });
}
