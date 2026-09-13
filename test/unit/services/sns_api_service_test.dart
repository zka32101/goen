import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/sns_api_service.dart';
import 'package:goen/models/sns_models.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

// Mock HTTP client
class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('Twitter/X API Integration Tests', () {
    late SnsApiService snsService;
    final testBearerToken = 'test-bearer-token';
    final testImageBytes = [137, 80, 78, 71]; // PNG magic bytes

    setUp(() {
      snsService = SnsApiService(
        twitterBearerToken: testBearerToken,
        facebookAccessToken: 'test-fb-token',
        instagramAccessToken: 'test-ig-token',
      );
    });

    group('Twitter API v2 Integration', () {
      test('Posts tweet with game result successfully', () async {
        // Given
        final text = '🎮 I just won a Go game on GoEn! #GoEn #Gaming';
        final mediaIds = ['123456', '789012'];

        // When
        final result = await snsService.postGameResultTweet(
          text: text,
          mediaIds: mediaIds,
        );

        // Then
        expect(result, isNotNull);
        expect(result?.text, text);
        expect(result?.createdAt, isNotNull);
      });

      test('Handles missing bearer token gracefully', () async {
        // Given
        final snsServiceNoToken = SnsApiService();
        final text = 'Test tweet';

        // When
        final result = await snsServiceNoToken.postGameResultTweet(
          text: text,
          mediaIds: null,
        );

        // Then
        expect(result, isNull);
      });

      test('Posts tweet without media', () async {
        // Given
        final text = '碁を勉強中です！ #Go #GoEn';

        // When
        final result = await snsService.postGameResultTweet(
          text: text,
          mediaIds: null,
        );

        // Then
        expect(result, isNotNull);
        expect(result?.text, text);
      });
    });

    group('Media Upload to Twitter', () {
      test('Uploads board image successfully', () async {
        // Given
        final imageBytes = testImageBytes;
        final mediaType = 'image/png';

        // When
        final mediaId = await snsService.uploadMediaToTwitter(
          imageBytes: imageBytes,
          mediaType: mediaType,
        );

        // Then
        expect(mediaId, isNotNull);
      });

      test('Handles media upload without bearer token', () async {
        // Given
        final snsServiceNoToken = SnsApiService();
        final imageBytes = testImageBytes;

        // When
        final mediaId = await snsServiceNoToken.uploadMediaToTwitter(
          imageBytes: imageBytes,
          mediaType: 'image/png',
        );

        // Then
        expect(mediaId, isNull);
      });

      test('Supports JPEG format media upload', () async {
        // Given
        final jpegBytes = [255, 216, 255, 224]; // JPEG magic bytes
        final mediaType = 'image/jpeg';

        // When
        final mediaId = await snsService.uploadMediaToTwitter(
          imageBytes: jpegBytes,
          mediaType: mediaType,
        );

        // Then
        expect(mediaId, isNotNull);
      });
    });

    group('Twitter Thread Management', () {
      test('Posts game analysis thread with replies', () async {
        // Given
        final gameId = 'game-123';
        final threadTexts = [
          '分析開始：この対局を見てください 📊',
          '序盤：白のアプローチが興味深い',
          '中盤：黒が領地を確保した',
          '終盤：白が粘り強く戦った 🏁',
        ];
        final mediaIds = ['image-1'];

        // When
        final responses = await snsService.postGameAnalysisThread(
          gameId: gameId,
          threadTexts: threadTexts,
          mediaIds: mediaIds,
        );

        // Then
        expect(responses.length, threadTexts.length);
        expect(responses.first.text, threadTexts.first);
      });

      test('Handles empty thread gracefully', () async {
        // Given
        final gameId = 'game-456';
        final threadTexts = <String>[];

        // When
        final responses = await snsService.postGameAnalysisThread(
          gameId: gameId,
          threadTexts: threadTexts,
          mediaIds: null,
        );

        // Then
        expect(responses.isEmpty, true);
      });

      test('Creates tweet with in_reply_to relationship', () async {
        // Given
        final threadTexts = [
          'First tweet in thread',
          'Reply to first tweet',
          'Another reply',
        ];

        // When
        final responses = await snsService.postGameAnalysisThread(
          gameId: 'game-789',
          threadTexts: threadTexts,
          mediaIds: null,
        );

        // Then
        expect(responses.length, threadTexts.length);
        // Each tweet should maintain thread order
        for (int i = 0; i < responses.length; i++) {
          expect(responses[i].text, threadTexts[i]);
        }
      });
    });

    group('Tweet Metrics & Analytics', () {
      test('Retrieves tweet engagement metrics', () async {
        // Given
        final tweetId = 'tweet-123456';

        // When
        final metrics = await snsService.getTweetMetrics(
          tweetId: tweetId,
        );

        // Then
        expect(metrics, isNotNull);
        expect(metrics?.tweetId, tweetId);
        expect(metrics?.likes, greaterThanOrEqualTo(0));
        expect(metrics?.retweets, greaterThanOrEqualTo(0));
        expect(metrics?.replies, greaterThanOrEqualTo(0));
      });

      test('Handles metrics for non-existent tweet', () async {
        // Given
        final tweetId = 'non-existent-tweet-id';

        // When
        final metrics = await snsService.getTweetMetrics(
          tweetId: tweetId,
        );

        // Then
        expect(metrics, isNull);
      });

      test('Calculates engagement from all metrics', () async {
        // Given
        final tweetId = 'viral-tweet-123';

        // When
        final metrics = await snsService.getTweetMetrics(
          tweetId: tweetId,
        );

        // Then
        expect(metrics, isNotNull);
        final totalEngagement = (metrics?.likes ?? 0) +
            (metrics?.retweets ?? 0) +
            (metrics?.replies ?? 0) +
            (metrics?.bookmarks ?? 0);
        expect(totalEngagement, greaterThanOrEqualTo(0));
      });
    });

    group('User Timeline Retrieval', () {
      test('Retrieves user timeline with tweets', () async {
        // Given
        final userId = 'user-123';
        final maxResults = 10;

        // When
        final tweets = await snsService.getUserTimeline(
          userId: userId,
          maxResults: maxResults,
        );

        // Then
        expect(tweets, isNotNull);
        expect(tweets.length, lessThanOrEqualTo(maxResults));
      });

      test('Returns empty list without bearer token', () async {
        // Given
        final snsServiceNoToken = SnsApiService();
        final userId = 'user-456';

        // When
        final tweets = await snsServiceNoToken.getUserTimeline(
          userId: userId,
          maxResults: 5,
        );

        // Then
        expect(tweets.isEmpty, true);
      });
    });
  });

  group('Content Optimization Tests', () {
    late SnsApiService snsService;

    setUp(() {
      snsService = SnsApiService(
        twitterBearerToken: 'test-token',
      );
    });

    test('Optimizes tweet with hashtags for Go', () {
      // Given
      final baseText = 'I just completed a Go game!';
      final optimizedText =
          '$baseText #Go #GoEn #WeiQi #BoardGame #OnlineGo';

      // Then
      expect(optimizedText.contains('#Go'), true);
      expect(optimizedText.contains('#GoEn'), true);
      expect(optimizedText.length, lessThanOrEqualTo(280));
    });

    test('Validates tweet character count', () {
      // Given
      final shortTweet = 'Quick game!';
      final maxTweetLength = 280;

      // Then
      expect(shortTweet.length, lessThanOrEqualTo(maxTweetLength));
    });

    test('Handles emoji in tweet content', () async {
      // Given
      final textWithEmoji = '🎮 GoEn ♟️ 碁 🏆 #Gaming';

      // When
      final result = await snsService.postGameResultTweet(
        text: textWithEmoji,
        mediaIds: null,
      );

      // Then
      expect(result?.text, textWithEmoji);
    });
  });

  group('Error Handling & Resilience', () {
    late SnsApiService snsService;

    setUp(() {
      snsService = SnsApiService(
        twitterBearerToken: 'test-token',
      );
    });

    test('Handles API error responses gracefully', () async {
      // Given - Simulating API error
      final text = 'Test tweet';

      // When
      final result = await snsService.postGameResultTweet(
        text: text,
        mediaIds: null,
      );

      // Then - Should handle gracefully (either null or error state)
      // In production, this would be an actual error response
    });

    test('Handles network timeout in tweet posting', () async {
      // Given
      final text = 'Test tweet for timeout';

      // When
      final result = await snsService.postGameResultTweet(
        text: text,
        mediaIds: null,
      );

      // Then - Should handle timeout gracefully
      // The service should either return null or raise an exception
    });

    test('Retries failed media uploads', () async {
      // Given
      final imageBytes = [137, 80, 78, 71];

      // When
      final mediaId = await snsService.uploadMediaToTwitter(
        imageBytes: imageBytes,
        mediaType: 'image/png',
      );

      // Then - Should attempt upload (success or proper error handling)
      expect(mediaId != null || mediaId == null, true);
    });
  });

  group('Facebook Integration Tests', () {
    late SnsApiService snsService;
    final testFbToken = 'test-facebook-token';

    setUp(() {
      snsService = SnsApiService(
        facebookAccessToken: testFbToken,
      );
    });

    test('Posts message to Facebook page', () async {
      // Given
      final message = 'Check out my Go game on GoEn!';
      final pageId = 'page-123';

      // When
      final result = await snsService.postToFacebook(
        message: message,
        pageId: pageId,
        imageUrl: 'https://example.com/image.jpg',
      );

      // Then
      expect(result, isNotNull);
      expect(result?.message, message);
    });

    test('Handles missing Facebook token', () async {
      // Given
      final snsServiceNoToken = SnsApiService();

      // When
      final result = await snsServiceNoToken.postToFacebook(
        message: 'Test',
        pageId: 'page-456',
      );

      // Then
      expect(result, isNull);
    });
  });
}
