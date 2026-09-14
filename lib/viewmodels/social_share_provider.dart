import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/social_share_service.dart';
import '../models/social_share_models.dart';
import 'analytics_provider.dart';

part 'social_share_provider.g.dart';

/// Provider for the SocialShareService
@riverpod
SocialShareService socialShareService(SocialShareServiceRef ref) {
  return const SocialShareService();
}

/// Provider to share a game to Twitter
@riverpod
Future<bool> shareGameToTwitter(
  ShareGameToTwitterRef ref, {
  required GameShareData gameData,
}) async {
  final service = ref.watch(socialShareServiceProvider);
  final analytics = ref.watch(analyticsProvider);

  final success = await service.shareGameToTwitter(gameData);

  if (success) {
    analytics.logEvent(
      name: 'game_shared',
      parameters: {
        'platform': 'twitter',
        'result': gameData.result,
        'board_size': gameData.boardSize,
        'ai_level': gameData.aiLevel,
      },
    );
  }

  return success;
}

/// Provider to share a puzzle achievement to Twitter
@riverpod
Future<bool> sharePuzzleToTwitter(
  SharePuzzleToTwitterRef ref, {
  required PuzzleShareData puzzleData,
}) async {
  final service = ref.watch(socialShareServiceProvider);
  final analytics = ref.watch(analyticsProvider);

  final success = await service.sharePuzzleToTwitter(puzzleData);

  if (success) {
    analytics.logEvent(
      name: 'puzzle_shared',
      parameters: {
        'platform': 'twitter',
        'difficulty': puzzleData.difficulty,
        'solved': puzzleData.isSolved,
        'attempts': puzzleData.attemptCount,
      },
    );
  }

  return success;
}

/// Provider to share profile to Twitter
@riverpod
Future<bool> shareProfileToTwitter(
  ShareProfileToTwitterRef ref, {
  required ProfileShareData profileData,
}) async {
  final service = ref.watch(socialShareServiceProvider);
  final analytics = ref.watch(analyticsProvider);

  final success = await service.shareProfileToTwitter(profileData);

  if (success) {
    final winRate = profileData.totalGamesPlayed > 0
        ? (profileData.winCount / profileData.totalGamesPlayed) * 100
        : 0.0;
    analytics.logEvent(
      name: 'profile_shared',
      parameters: {
        'platform': 'twitter',
        'total_games': profileData.totalGamesPlayed,
        'win_rate': winRate,
        'puzzles_solved': profileData.totalPuzzlesSolved,
      },
    );
  }

  return success;
}

/// Provider to share to a specific platform
@riverpod
Future<bool> shareWithPlatform(
  ShareWithPlatformRef ref, {
  required ShareContent content,
  required SocialPlatform platform,
}) async {
  final service = ref.watch(socialShareServiceProvider);
  final analytics = ref.watch(analyticsProvider);

  final success = await service.shareWithPlatform(content, platform: platform);

  if (success) {
    analytics.logEvent(
      name: 'content_shared_to_platform',
      parameters: {
        'platform': platform.toString().split('.').last,
      },
    );
  }

  return success;
}

/// Provider for generic share to system share sheet
@riverpod
Future<bool> shareGeneric(
  ShareGenericRef ref, {
  required ShareContent content,
}) async {
  final service = ref.watch(socialShareServiceProvider);
  return service.shareGeneric(content);
}

/// State for tracking share UI visibility
class ShareUIState {
  final bool isShareDialogOpen;
  final bool isLoading;
  final String? errorMessage;

  ShareUIState({
    this.isShareDialogOpen = false,
    this.isLoading = false,
    this.errorMessage,
  });

  ShareUIState copyWith({
    bool? isShareDialogOpen,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ShareUIState(
      isShareDialogOpen: isShareDialogOpen ?? this.isShareDialogOpen,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier for share UI state
class ShareUINotifier extends StateNotifier<ShareUIState> {
  ShareUINotifier() : super(ShareUIState());

  void openShareDialog() {
    state = state.copyWith(isShareDialogOpen: true);
  }

  void closeShareDialog() {
    state = state.copyWith(isShareDialogOpen: false, errorMessage: null);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }
}

/// Provider for share UI state
@riverpod
class ShareUI extends _$ShareUI {
  @override
  ShareUIState build() {
    return ShareUIState();
  }

  void openShareDialog() {
    state = state.copyWith(isShareDialogOpen: true);
  }

  void closeShareDialog() {
    state = state.copyWith(isShareDialogOpen: false, errorMessage: null);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }
}
