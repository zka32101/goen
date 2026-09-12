import 'package:riverpod/riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/services/index.dart';

final _logger = Logger();

// ================== SERVICE PROVIDERS ==================

/// YouTube シェアサービス
final youtubeShareServiceProvider = Provider<YouTubeShareService>((ref) {
  return YouTubeShareService();
});

/// Twitch シェアサービス
final twitchShareServiceProvider = Provider<TwitchShareService>((ref) {
  return TwitchShareService();
});

/// スポンサーシップサービス
final sponsorshipServiceProvider = Provider<SponsorshipService>((ref) {
  return SponsorshipService();
});

// ================== YOUTUBE PROVIDERS ==================

/// YouTube 接続状態
final youtubeConnectedProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  try {
    final service = ref.watch(youtubeShareServiceProvider);
    _logger.d('Checking YouTube connection for user: $userId');
    final isConnected = await service.isYouTubeConnected(userId);
    return isConnected;
  } catch (e) {
    _logger.e('Error checking YouTube connection: $e');
    rethrow;
  }
});

/// ユーザーのYouTubeアップロード一覧
final youtubeUploadsProvider =
    FutureProvider.family<List<YouTubeUploadResult>, String>((ref, userId) async {
  try {
    final service = ref.watch(youtubeShareServiceProvider);
    _logger.d('Fetching YouTube uploads for user: $userId');
    final uploads = await service.getUserUploads(userId);
    return uploads;
  } catch (e) {
    _logger.e('Error fetching YouTube uploads: $e');
    rethrow;
  }
});

/// 自動共有設定
final youtubeAutoShareProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  try {
    final service = ref.watch(youtubeShareServiceProvider);
    _logger.d('Checking auto-share setting for user: $userId');
    final enabled = await service.isAutoShareEnabled(userId);
    return enabled;
  } catch (e) {
    _logger.e('Error checking auto-share: $e');
    rethrow;
  }
});

// ================== TWITCH PROVIDERS ==================

/// Twitch 接続状態
final twitchConnectedProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  try {
    final service = ref.watch(twitchShareServiceProvider);
    _logger.d('Checking Twitch connection for user: $userId');
    final isConnected = await service.isTwitchConnected(userId);
    return isConnected;
  } catch (e) {
    _logger.e('Error checking Twitch connection: $e');
    rethrow;
  }
});

/// アクティブなTwitchストリーム
final activeTwitchStreamProvider =
    FutureProvider.family<TwitchStreamInfo?, String>((ref, gameId) async {
  try {
    final service = ref.watch(twitchShareServiceProvider);
    _logger.d('Fetching active Twitch stream for game: $gameId');
    final stream = await service.getActiveStream(gameId);
    return stream;
  } catch (e) {
    _logger.e('Error fetching active stream: $e');
    rethrow;
  }
});

/// ユーザーのストリーム履歴
final twitchStreamHistoryProvider =
    FutureProvider.family<List<TwitchStreamInfo>, String>((ref, userId) async {
  try {
    final service = ref.watch(twitchShareServiceProvider);
    _logger.d('Fetching stream history for user: $userId');
    final history = await service.getStreamHistory(userId);
    return history;
  } catch (e) {
    _logger.e('Error fetching stream history: $e');
    rethrow;
  }
});

// ================== SPONSORSHIP PROVIDERS ==================

/// ユーザーが受けているスポンサーシップ
final incomingSponsorsProvider =
    FutureProvider.family<List<SponsorshipRecord>, String>(
        (ref, userId) async {
  try {
    final service = ref.watch(sponsorshipServiceProvider);
    _logger.d('Fetching incoming sponsorships for user: $userId');
    final sponsorships = await service.getIncomingSponsorships(userId);
    return sponsorships;
  } catch (e) {
    _logger.e('Error fetching incoming sponsorships: $e');
    rethrow;
  }
});

/// ユーザーがしているスポンサーシップ
final outgoingSponsorsProvider =
    FutureProvider.family<List<SponsorshipRecord>, String>(
        (ref, userId) async {
  try {
    final service = ref.watch(sponsorshipServiceProvider);
    _logger.d('Fetching outgoing sponsorships for user: $userId');
    final sponsorships = await service.getOutgoingSponsorships(userId);
    return sponsorships;
  } catch (e) {
    _logger.e('Error fetching outgoing sponsorships: $e');
    rethrow;
  }
});

/// スポンサー情報（統計）
final sponsorInfoProvider =
    FutureProvider.family<SponsorInfo?, String>((ref, userId) async {
  try {
    final service = ref.watch(sponsorshipServiceProvider);
    _logger.d('Fetching sponsor info for user: $userId');
    final info = await service.getSponsorInfo(userId);
    return info;
  } catch (e) {
    _logger.e('Error fetching sponsor info: $e');
    rethrow;
  }
});

/// スポンサーシップ通知
final sponsorshipNotificationsProvider =
    FutureProvider.family<List<SponsorshipNotification>, String>(
        (ref, userId) async {
  try {
    final service = ref.watch(sponsorshipServiceProvider);
    _logger.d('Fetching sponsorship notifications for user: $userId');
    final notifications = await service.getNotifications(userId);
    return notifications;
  } catch (e) {
    _logger.e('Error fetching notifications: $e');
    rethrow;
  }
});

// ================== ACTION PROVIDERS ==================

/// YouTube アップロード実行
final uploadToYouTubeProvider =
    FutureProvider.family<YouTubeUploadResult?, YouTubeShareData>(
        (ref, shareData) async {
  try {
    final service = ref.watch(youtubeShareServiceProvider);
    _logger.i('Uploading to YouTube: ${shareData.title}');
    final result = await service.uploadGameToYouTube(shareData);
    return result;
  } catch (e) {
    _logger.e('Error uploading to YouTube: $e');
    rethrow;
  }
});

/// Twitch ストリーム開始
final startTwitchStreamProvider =
    FutureProvider.family<TwitchStreamInfo?, TwitchStreamData>(
        (ref, streamData) async {
  try {
    final service = ref.watch(twitchShareServiceProvider);
    _logger.i('Starting Twitch stream: ${streamData.streamTitle}');
    final result = await service.startGameStream(streamData);
    return result;
  } catch (e) {
    _logger.e('Error starting Twitch stream: $e');
    rethrow;
  }
});

/// スポンサーシップ開始
final startSponsorshipProvider = FutureProvider.family<
    SponsorshipRecord?,
    ({
      String sponsorUserId,
      String sponsoredUserId,
      String tierId,
      String message
    })>((ref, params) async {
  try {
    final service = ref.watch(sponsorshipServiceProvider);
    _logger.i(
        'Starting sponsorship: ${params.sponsorUserId} -> ${params.sponsoredUserId}');
    final result = await service.startSponsorship(
      params.sponsorUserId,
      params.sponsoredUserId,
      params.tierId,
      params.message,
    );
    // 関連プロバイダーを無効化（リフレッシュ）
    ref.invalidate(incomingSponsorsProvider(params.sponsoredUserId));
    ref.invalidate(sponsorInfoProvider(params.sponsoredUserId));
    return result;
  } catch (e) {
    _logger.e('Error starting sponsorship: $e');
    rethrow;
  }
});

// ================== UI STATE PROVIDERS ==================

/// ストリーミングUIステート
class StreamingUIState {
  final bool isLoading;
  final String? error;
  final String? selectedTab; // 'youtube', 'twitch', 'sponsorship'

  StreamingUIState({
    this.isLoading = false,
    this.error,
    this.selectedTab,
  });

  StreamingUIState copyWith({
    bool? isLoading,
    String? error,
    String? selectedTab,
  }) {
    return StreamingUIState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }
}

class StreamingUINotifier extends StateNotifier<StreamingUIState> {
  StreamingUINotifier() : super(StreamingUIState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading, error: null);
  }

  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void selectTab(String tab) {
    state = state.copyWith(selectedTab: tab);
  }
}

final streamingUIProvider =
    StateNotifierProvider<StreamingUINotifier, StreamingUIState>(
  (ref) => StreamingUINotifier(),
);
