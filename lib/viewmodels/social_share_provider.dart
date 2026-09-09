import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/social_share_service.dart';
import '../models/social_share_models.dart';

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
  return service.shareGameToTwitter(gameData);
}

/// Provider to share a puzzle achievement to Twitter
@riverpod
Future<bool> sharePuzzleToTwitter(
  SharePuzzleToTwitterRef ref, {
  required PuzzleShareData puzzleData,
}) async {
  final service = ref.watch(socialShareServiceProvider);
  return service.sharePuzzleToTwitter(puzzleData);
}

/// Provider to share profile to Twitter
@riverpod
Future<bool> shareProfileToTwitter(
  ShareProfileToTwitterRef ref, {
  required ProfileShareData profileData,
}) async {
  final service = ref.watch(socialShareServiceProvider);
  return service.shareProfileToTwitter(profileData);
}

/// Provider to share to a specific platform
@riverpod
Future<bool> shareWithPlatform(
  ShareWithPlatformRef ref, {
  required ShareContent content,
  required SocialPlatform platform,
}) async {
  final service = ref.watch(socialShareServiceProvider);
  return service.shareWithPlatform(content, platform: platform);
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
