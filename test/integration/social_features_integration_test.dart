import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/models/extended_game_models.dart';
import 'package:goen/services/friend_service.dart';
import 'package:goen/services/game_invitation_service.dart';
import 'package:goen/services/leaderboard_service.dart';

void main() {
  late FriendService friendService;
  late GameInvitationService invitationService;
  late LeaderboardService leaderboardService;

  // Test user IDs
  const testUserId1 = 'test-user-1';
  const testUserId2 = 'test-user-2';
  const testUserId3 = 'test-user-3';

  setUpAll(() {
    // Initialize services with mock/test Firestore
    friendService = const FriendService();
    invitationService = const GameInvitationService();
    leaderboardService = const LeaderboardService();
  });

  group('Friend System Integration Tests', () {
    test('Add friend and check friendship status', () async {
      final success = await friendService.addFriend(
        currentUid: testUserId1,
        friendUid: testUserId2,
      );

      expect(success, isTrue);
    });

    test('Accept friend request', () async {
      await friendService.addFriend(
        currentUid: testUserId1,
        friendUid: testUserId2,
      );

      final accepted = await friendService.acceptFriendRequest(
        currentUid: testUserId2,
        friendUid: testUserId1,
      );

      expect(accepted, isTrue);
    });

    test('Block user', () async {
      final blocked = await friendService.blockFriend(
        currentUid: testUserId1,
        friendUid: testUserId3,
      );

      expect(blocked, isTrue);
    });

    test('Get friends list', () async {
      await friendService.addFriend(
        currentUid: testUserId1,
        friendUid: testUserId2,
      );

      final friends = await friendService.getFriends(
        uid: testUserId1,
        status: 'pending',
      );

      expect(friends, isNotEmpty);
    });

    test('Remove friend', () async {
      await friendService.addFriend(
        currentUid: testUserId1,
        friendUid: testUserId2,
      );

      final removed = await friendService.removeFriend(
        currentUid: testUserId1,
        friendUid: testUserId2,
      );

      expect(removed, isTrue);
    });

    test('Search users', () async {
      final users = await friendService.searchUsers(query: 'test');

      expect(users, isA<List<UserProfile>>());
    });
  });

  group('Game Invitation Integration Tests', () {
    test('Send game invitation', () async {
      final sent = await invitationService.sendInvitation(
        fromUid: testUserId1,
        toUid: testUserId2,
        gameMode: 'blitz',
        boardSize: 19,
        aiLevel: 5,
      );

      expect(sent, isTrue);
    });

    test('Accept game invitation', () async {
      await invitationService.sendInvitation(
        fromUid: testUserId1,
        toUid: testUserId2,
        gameMode: 'blitz',
        boardSize: 19,
        aiLevel: 5,
      );

      final incoming = await invitationService.getIncomingInvitations(
        uid: testUserId2,
      );

      if (incoming.isNotEmpty) {
        final accepted = await invitationService.acceptInvitation(
          invitationId: incoming[0].id,
        );

        expect(accepted, isTrue);
      }
    });

    test('Decline game invitation', () async {
      await invitationService.sendInvitation(
        fromUid: testUserId1,
        toUid: testUserId2,
        gameMode: 'correspondence',
        boardSize: 13,
        aiLevel: 3,
      );

      final incoming = await invitationService.getIncomingInvitations(
        uid: testUserId2,
      );

      if (incoming.isNotEmpty) {
        final declined = await invitationService.declineInvitation(
          invitationId: incoming[0].id,
        );

        expect(declined, isTrue);
      }
    });

    test('Get incoming invitations', () async {
      final invitations =
          await invitationService.getIncomingInvitations(uid: testUserId2);

      expect(invitations, isA<List<GameInvitation>>());
    });

    test('Get outgoing invitations', () async {
      final invitations =
          await invitationService.getOutgoingInvitations(uid: testUserId1);

      expect(invitations, isA<List<GameInvitation>>());
    });

    test('Cleanup expired invitations', () async {
      final deletedCount = await invitationService.cleanupExpiredInvitations();

      expect(deletedCount, isA<int>());
      expect(deletedCount, greaterThanOrEqualTo(0));
    });

    test('Get invitation statistics', () async {
      final stats = await invitationService.getInvitationStats(
        uid: testUserId1,
      );

      expect(stats, isA<Map<String, dynamic>>());
      expect(stats, containsPair('incomingCount', isA<int>()));
      expect(stats, containsPair('outgoingCount', isA<int>()));
    });
  });

  group('Leaderboard Integration Tests', () {
    test('Update leaderboard entry', () async {
      final updated = await leaderboardService.updateLeaderboardEntry(
        userId: testUserId1,
        displayName: 'Test Player 1',
        rating: 1500.0,
        wins: 15,
        losses: 5,
        totalGames: 20,
        period: 'allTime',
      );

      expect(updated, isTrue);
    });

    test('Get top players', () async {
      // Add multiple players first
      for (int i = 0; i < 5; i++) {
        await leaderboardService.updateLeaderboardEntry(
          userId: 'player-$i',
          displayName: 'Player $i',
          rating: 1200.0 + (i * 100),
          wins: 10 + i,
          losses: 5,
          totalGames: 15 + i,
          period: 'allTime',
        );
      }

      final topPlayers = await leaderboardService.getTopPlayers(
        period: 'allTime',
        limit: 10,
      );

      expect(topPlayers, isNotEmpty);
      expect(topPlayers[0].rank, equals(1));
    });

    test('Get player rank', () async {
      await leaderboardService.updateLeaderboardEntry(
        userId: testUserId1,
        displayName: 'Test Player',
        rating: 1400.0,
        wins: 10,
        losses: 5,
        totalGames: 15,
        period: 'monthly',
      );

      final playerRank = await leaderboardService.getPlayerRank(
        userId: testUserId1,
        period: 'monthly',
      );

      expect(playerRank, isNotNull);
      expect(playerRank!.userId, equals(testUserId1));
    });

    test('Get leaderboard statistics', () async {
      final stats = await leaderboardService.getLeaderboardStats(
        period: 'allTime',
      );

      expect(stats, isA<Map<String, dynamic>>());
      expect(stats, containsPair('totalPlayers', isA<int>()));
      expect(stats, containsPair('topRating', isA<double>()));
    });

    test('Get players in rating range', () async {
      final players = await leaderboardService.getPlayersInRange(
        period: 'allTime',
        minRating: 1200.0,
        maxRating: 1600.0,
        limit: 10,
      );

      expect(players, isA<List<LeaderboardEntry>>());
    });
  });

  group('Social Features Integration Scenarios', () {
    test('Complete friend addition workflow', () async {
      // User 1 sends friend request to User 2
      final sent = await friendService.addFriend(
        currentUid: testUserId1,
        friendUid: testUserId2,
        notes: 'Great player!',
      );
      expect(sent, isTrue);

      // User 2 accepts the request
      final accepted = await friendService.acceptFriendRequest(
        currentUid: testUserId2,
        friendUid: testUserId1,
      );
      expect(accepted, isTrue);

      // Verify friendship
      final isFriend = await friendService.isFriend(
        currentUid: testUserId1,
        friendUid: testUserId2,
      );
      expect(isFriend, isTrue);
    });

    test('Complete game invitation workflow', () async {
      // User 1 sends game invitation to User 2
      final sent = await invitationService.sendInvitation(
        fromUid: testUserId1,
        toUid: testUserId2,
        gameMode: 'blitz',
        boardSize: 19,
        aiLevel: 6,
        customMessage: 'Want to play?',
      );
      expect(sent, isTrue);

      // Get User 2's incoming invitations
      final incoming = await invitationService.getIncomingInvitations(
        uid: testUserId2,
      );
      expect(incoming, isNotEmpty);

      // User 2 accepts the invitation
      if (incoming.isNotEmpty) {
        final accepted = await invitationService.acceptInvitation(
          invitationId: incoming[0].id,
        );
        expect(accepted, isTrue);
      }
    });

    test('Leaderboard update with multiple players', () async {
      // Update multiple players' rankings
      final playerStats = [
        {'userId': 'player-1', 'rating': 1800.0, 'wins': 30, 'losses': 10},
        {'userId': 'player-2', 'rating': 1700.0, 'wins': 25, 'losses': 12},
        {'userId': 'player-3', 'rating': 1600.0, 'wins': 20, 'losses': 15},
      ];

      for (final stats in playerStats) {
        final updated = await leaderboardService.updateLeaderboardEntry(
          userId: stats['userId'] as String,
          displayName: 'Player ${stats['userId']}',
          rating: stats['rating'] as double,
          wins: stats['wins'] as int,
          losses: stats['losses'] as int,
          totalGames: (stats['wins'] as int) + (stats['losses'] as int),
          period: 'weekly',
        );
        expect(updated, isTrue);
      }

      // Get top players and verify ordering
      final topPlayers = await leaderboardService.getTopPlayers(
        period: 'weekly',
        limit: 10,
      );

      expect(topPlayers.length, greaterThan(0));
      for (int i = 0; i < topPlayers.length - 1; i++) {
        expect(
          topPlayers[i].rating,
          greaterThanOrEqualTo(topPlayers[i + 1].rating),
          reason: 'Leaderboard should be sorted by rating (descending)',
        );
      }
    });
  });
}
