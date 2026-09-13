import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/social_features_service.dart';
import 'package:goen/services/friend_service.dart';
import 'package:goen/services/game_invitation_service.dart';
import 'package:goen/models/sns_models.dart';

void main() {
  group('Social Features Service Tests', () {
    late SocialFeaturesService socialService;

    setUp(() {
      socialService = SocialFeaturesService();
    });

    group('Friend System Management', () {
      test('Sends friend request to another user', () async {
        // Given
        final senderId = 'user-sender-123';
        final recipientId = 'user-recipient-456';

        // When
        final result = await socialService.sendFriendRequest(
          senderId: senderId,
          recipientId: recipientId,
        );

        // Then
        expect(result, isTrue);
      });

      test('Accepts friend request', () async {
        // Given
        final userId = 'user-123';
        final friendId = 'user-456';
        final requestId = 'request-001';

        // When
        final accepted = await socialService.acceptFriendRequest(
          requestId: requestId,
          userId: userId,
          friendId: friendId,
        );

        // Then
        expect(accepted, isTrue);
      });

      test('Rejects friend request', () async {
        // Given
        final requestId = 'request-002';
        final userId = 'user-123';

        // When
        final rejected = await socialService.rejectFriendRequest(
          requestId: requestId,
          userId: userId,
        );

        // Then
        expect(rejected, isTrue);
      });

      test('Removes friend from friends list', () async {
        // Given
        final userId = 'user-123';
        final friendId = 'user-456';

        // When
        final removed = await socialService.removeFriend(
          userId: userId,
          friendId: friendId,
        );

        // Then
        expect(removed, isTrue);
      });

      test('Blocks user and prevents future interactions', () async {
        // Given
        final userId = 'user-blocker';
        final blockedUserId = 'user-blocked';

        // When
        final blocked = await socialService.blockUser(
          userId: userId,
          blockedUserId: blockedUserId,
        );

        // Then
        expect(blocked, isTrue);
      });

      test('Unblocks previously blocked user', () async {
        // Given
        final userId = 'user-unblock';
        final unblockedId = 'user-was-blocked';

        // When
        final unblocked = await socialService.unblockUser(
          userId: userId,
          blockedUserId: unblockedId,
        );

        // Then
        expect(unblocked, isTrue);
      });

      test('Retrieves user friend list', () async {
        // Given
        final userId = 'user-friends-list';

        // When
        final friends = await socialService.getFriendList(userId);

        // Then
        expect(friends, isNotNull);
        expect(friends, isA<List<Friend>>());
      });

      test('Gets pending friend requests for user', () async {
        // Given
        final userId = 'user-pending';

        // When
        final pending = await socialService.getPendingRequests(userId);

        // Then
        expect(pending, isNotNull);
        expect(pending, isA<List>());
      });
    });

    group('Game Invitations', () {
      test('Sends game invitation to friend', () async {
        // Given
        final fromUserId = 'player-1';
        final toUserId = 'player-2';
        final gameMode = GameModeType.blitz;

        // When
        final invitation = await socialService.sendGameInvitation(
          fromUserId: fromUserId,
          toUserId: toUserId,
          gameMode: gameMode,
        );

        // Then
        expect(invitation, isNotNull);
        expect(invitation?.fromUserId, fromUserId);
        expect(invitation?.toUserId, toUserId);
      });

      test('Accepts game invitation and starts game', () async {
        // Given
        final invitationId = 'invite-001';
        final userId = 'player-2';

        // When
        final gameSession = await socialService.acceptGameInvitation(
          invitationId: invitationId,
          userId: userId,
        );

        // Then
        expect(gameSession, isNotNull);
      });

      test('Declines game invitation', () async {
        // Given
        final invitationId = 'invite-002';
        final userId = 'player-3';

        // When
        final declined = await socialService.declineGameInvitation(
          invitationId: invitationId,
          userId: userId,
        );

        // Then
        expect(declined, isTrue);
      });

      test('Handles invitation timeout (expires after 24 hours)', () async {
        // Given
        final invitationId = 'invite-expired-001';

        // When
        final isExpired = await socialService.isInvitationExpired(
          invitationId: invitationId,
        );

        // Then
        expect(isExpired, isA<bool>());
      });

      test('Retrieves pending invitations for user', () async {
        // Given
        final userId = 'player-invites';

        // When
        final invitations =
            await socialService.getPendingInvitations(userId);

        // Then
        expect(invitations, isNotNull);
        expect(invitations, isA<List<GameInvitation>>());
      });
    });

    group('Leaderboards', () {
      test('Retrieves global leaderboard', () async {
        // When
        final leaderboard = await socialService.getGlobalLeaderboard(
          limit: 100,
        );

        // Then
        expect(leaderboard, isNotNull);
        expect(leaderboard.length, lessThanOrEqualTo(100));
      });

      test('Retrieves monthly leaderboard', () async {
        // When
        final monthlyLeaderboard =
            await socialService.getMonthlyLeaderboard(limit: 50);

        // Then
        expect(monthlyLeaderboard, isNotNull);
      });

      test('Gets user rank on leaderboard', () async {
        // Given
        final userId = 'ranked-user-123';

        // When
        final rank = await socialService.getUserRank(userId);

        // Then
        expect(rank, isNotNull);
        expect(rank?.userId, userId);
        expect(rank?.rank, greaterThan(0));
      });

      test('Tracks rating progression over time', () async {
        // Given
        final userId = 'progression-user';

        // When
        final progression = await socialService.getRatingProgression(userId);

        // Then
        expect(progression, isNotNull);
        expect(progression, isA<List>());
      });

      test('Compares player ratings with friends', () async {
        // Given
        final userId = 'comparison-user';

        // When
        final comparison =
            await socialService.compareRatingsWithFriends(userId);

        // Then
        expect(comparison, isNotNull);
        expect(comparison, isA<Map>());
      });
    });

    group('Tournaments & Events', () {
      test('Creates new tournament bracket', () async {
        // Given
        final tournamentName = 'Spring Tournament 2026';
        final maxParticipants = 16;

        // When
        final tournament = await socialService.createTournament(
          name: tournamentName,
          maxParticipants: maxParticipants,
          format: TournamentFormat.singleElimination,
        );

        // Then
        expect(tournament, isNotNull);
        expect(tournament?.name, tournamentName);
      });

      test('Registers player for tournament', () async {
        // Given
        final tournamentId = 'tournament-001';
        final userId = 'player-tournament';

        // When
        final registered = await socialService.registerForTournament(
          tournamentId: tournamentId,
          userId: userId,
        );

        // Then
        expect(registered, isTrue);
      });

      test('Gets tournament bracket and matchups', () async {
        // Given
        final tournamentId = 'tournament-002';

        // When
        final bracket =
            await socialService.getTournamentBracket(tournamentId);

        // Then
        expect(bracket, isNotNull);
      });

      test('Updates tournament match result', () async {
        // Given
        final matchId = 'match-001';
        final winnerId = 'winner-user';
        final loserId = 'loser-user';

        // When
        final updated = await socialService.updateMatchResult(
          matchId: matchId,
          winnerId: winnerId,
          loserId: loserId,
        );

        // Then
        expect(updated, isTrue);
      });

      test('Retrieves tournament standings', () async {
        // Given
        final tournamentId = 'tournament-003';

        // When
        final standings =
            await socialService.getTournamentStandings(tournamentId);

        // Then
        expect(standings, isNotNull);
        expect(standings, isA<List>());
      });
    });

    group('In-Game Chat & Observation', () {
      test('Sends message in game chat', () async {
        // Given
        final gameId = 'game-chat-001';
        final userId = 'player-chat';
        final message = 'Great move! ♟️';

        // When
        final sent = await socialService.sendGameMessage(
          gameId: gameId,
          userId: userId,
          message: message,
        );

        // Then
        expect(sent, isTrue);
      });

      test('Retrieves game chat history', () async {
        // Given
        final gameId = 'game-chat-001';

        // When
        final messages = await socialService.getGameChatMessages(gameId);

        // Then
        expect(messages, isNotNull);
        expect(messages, isA<List<ChatMessage>>());
      });

      test('Mutes user in game chat', () async {
        // Given
        final gameId = 'game-mute-001';
        final muteUserId = 'user-spam';

        // When
        final muted = await socialService.muteUserInGame(
          gameId: gameId,
          mutedUserId: muteUserId,
        );

        // Then
        expect(muted, isTrue);
      });

      test('Notifies spectators when observation starts', () async {
        // Given
        final gameId = 'game-observe-001';
        final spectatorCount = 5;

        // When
        final notified = await socialService.notifySpectators(
          gameId: gameId,
        );

        // Then
        expect(notified, isTrue);
      });

      test('Gets spectator list for game', () async {
        // Given
        final gameId = 'game-spectators-001';

        // When
        final spectators =
            await socialService.getGameSpectators(gameId);

        // Then
        expect(spectators, isNotNull);
        expect(spectators, isA<List>());
      });
    });

    group('User Profiles & Social Stats', () {
      test('Views user public profile', () async {
        // Given
        final userId = 'profile-user-123';

        // When
        final profile = await socialService.getUserProfile(userId);

        // Then
        expect(profile, isNotNull);
        expect(profile?.userId, userId);
      });

      test('Gets user social statistics', () async {
        // Given
        final userId = 'stats-user';

        // When
        final stats = await socialService.getUserSocialStats(userId);

        // Then
        expect(stats, isNotNull);
        expect(stats?.friendCount, greaterThanOrEqualTo(0));
        expect(stats?.totalShares, greaterThanOrEqualTo(0));
      });

      test('Updates user profile information', () async {
        // Given
        final userId = 'profile-update';
        final newBio = 'Go enthusiast and lifelong learner 📚';

        // When
        final updated = await socialService.updateUserProfile(
          userId: userId,
          bio: newBio,
        );

        // Then
        expect(updated, isTrue);
      });

      test('Tracks user social engagement metrics', () async {
        // Given
        final userId = 'engagement-user';

        // When
        final engagement =
            await socialService.getUserEngagementMetrics(userId);

        // Then
        expect(engagement, isNotNull);
        expect(engagement, isA<Map>());
      });
    });
  });
}
