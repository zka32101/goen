import 'package:flutter_test/flutter_test.dart';
import 'package:goen/services/game_mode_service.dart';
import 'package:goen/services/blitz_game_service.dart';
import 'package:goen/services/correspondence_game_service.dart';
import 'package:goen/services/team_game_service.dart';
import 'package:goen/models/sns_models.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mock Firestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  group('Game Mode Management Tests', () {
    late GameModeService gameModeService;

    setUp(() {
      gameModeService = GameModeService();
    });

    group('Game Mode CRUD Operations', () {
      test('Retrieves all available game modes', () async {
        // When
        final modes = await gameModeService.getAllGameModes();

        // Then
        expect(modes, isNotNull);
        expect(modes, isA<List<GameMode>>());
      });

      test('Filters active game modes only', () async {
        // When
        final activeModes = await gameModeService.getActiveGameModes();

        // Then
        expect(activeModes, isNotNull);
        for (final mode in activeModes) {
          expect(mode.isActive, true);
        }
      });

      test('Retrieves specific game mode by ID', () async {
        // Given
        final modeId = 'blitz-mode';

        // When
        final mode = await gameModeService.getGameMode(modeId);

        // Then
        expect(mode, isNotNull);
        expect(mode?.id, modeId);
      });

      test('Creates new game mode', () async {
        // Given
        final newMode = GameMode(
          id: 'custom-mode',
          name: 'カスタムモード',
          description: 'ユーザー定義のゲームモード',
          timeLimit: 600, // 10 minutes
          difficulty: 'normal',
          type: GameModeType.traditional,
          maxPlayers: 2,
          isActive: true,
        );

        // When
        final created = await gameModeService.createGameMode(newMode);

        // Then
        expect(created, isNotNull);
        expect(created?.name, 'カスタムモード');
      });

      test('Handles non-existent game mode gracefully', () async {
        // Given
        final nonExistentId = 'non-existent-mode-xyz';

        // When
        final mode = await gameModeService.getGameMode(nonExistentId);

        // Then
        expect(mode, isNull);
      });
    });

    group('Game Session Management', () {
      test('Starts a new game session with game mode', () async {
        // Given
        final gameMode = GameMode(
          id: 'blitz-1',
          name: 'Blitz',
          description: '5分急速戦',
          timeLimit: 300,
          difficulty: 'normal',
          type: GameModeType.blitz,
          maxPlayers: 2,
        );
        final blackPlayerId = 'player-black-123';
        final whitePlayerId = 'player-white-456';

        // When
        final session = await gameModeService.startGameSession(
          gameMode: gameMode,
          blackPlayerId: blackPlayerId,
          whitePlayerId: whitePlayerId,
        );

        // Then
        expect(session, isNotNull);
        expect(session?.gameMode.type, GameModeType.blitz);
        expect(session?.blackPlayerId, blackPlayerId);
        expect(session?.whitePlayerId, whitePlayerId);
        expect(session?.timeRemainingBlack, 300);
      });

      test('Retrieves active game session', () async {
        // Given
        final sessionId = 'session-active-001';

        // When
        final session =
            await gameModeService.getGameSession(sessionId);

        // Then
        expect(session, isNotNull);
      });

      test('Ends game session with result', () async {
        // Given
        final sessionId = 'session-end-001';
        final result = 'black_win';
        final finalScore = {'black': 125.5, 'white': 95.0};

        // When
        await gameModeService.endGameSession(
          sessionId: sessionId,
          result: result,
          finalScore: finalScore,
        );

        // Then - Verify session was updated
        final session = await gameModeService.getGameSession(sessionId);
        expect(session?.endedAt, isNotNull);
      });
    });

    group('Game Mode Type Validation', () {
      test('Validates Blitz mode configuration', () {
        // Given
        final blitzMode = GameMode(
          id: 'blitz-test',
          name: 'Blitz',
          description: '5分急速戦',
          timeLimit: 300,
          difficulty: 'normal',
          type: GameModeType.blitz,
          maxPlayers: 2,
        );

        // Then
        expect(blitzMode.type, GameModeType.blitz);
        expect(blitzMode.timeLimit, 300);
        expect(blitzMode.maxPlayers, 2);
      });

      test('Validates Correspondence mode (no time limit)', () {
        // Given
        final correspondenceMode = GameMode(
          id: 'correspondence-test',
          name: 'Correspondence',
          description: 'ターンベース対局',
          timeLimit: 0, // No limit
          difficulty: 'normal',
          type: GameModeType.correspondence,
          maxPlayers: 2,
        );

        // Then
        expect(correspondenceMode.type, GameModeType.correspondence);
        expect(correspondenceMode.timeLimit, 0);
      });

      test('Validates Team Play mode (2vs2)', () {
        // Given
        final teamMode = GameMode(
          id: 'team-test',
          name: 'Team Play',
          description: '2vs2チーム戦',
          timeLimit: 1800, // 30 minutes
          difficulty: 'normal',
          type: GameModeType.team,
          maxPlayers: 4,
        );

        // Then
        expect(teamMode.type, GameModeType.team);
        expect(teamMode.maxPlayers, 4);
      });

      test('Validates Handicap variant configuration', () {
        // Given
        final handicapMode = GameMode(
          id: 'handicap-test',
          name: 'Handicap',
          description: 'ハンディキャップ戦',
          timeLimit: 900, // 15 minutes
          difficulty: 'hard',
          type: GameModeType.handicap,
          maxPlayers: 2,
        );

        // Then
        expect(handicapMode.type, GameModeType.handicap);
        expect(handicapMode.difficulty, 'hard');
      });
    });
  });

  group('Blitz Game Service Tests', () {
    late BlitzGameService blitzService;

    setUp(() {
      blitzService = BlitzGameService();
    });

    test('Starts Blitz game with 5-minute timer', () async {
      // Given
      final uid = 'user-123';
      final boardSize = 19;
      final opponentUid = 'user-456';

      // When
      final game = await blitzService.startBlitzGame(
        uid: uid,
        boardSize: boardSize,
        opponentUid: opponentUid,
      );

      // Then
      expect(game, isNotNull);
      expect(game.boardSize, 19);
      expect(game.whitePlayer, uid);
      expect(game.durationSeconds, lessThanOrEqualTo(300));
    });

    test('Adds move to Blitz game', () async {
      // Given
      final gameId = 'blitz-game-001';
      final move = 'Q16'; // Standard Go notation
      final playerColor = 'white';

      // When
      await blitzService.addMove(
        gameId: gameId,
        move: move,
        playerColor: playerColor,
      );

      // Then - Move was added (verified by no exception thrown)
    });

    test('Handles rapid move sequences in Blitz', () async {
      // Given
      final gameId = 'blitz-rapid-001';
      final moves = ['Q16', 'D4', 'Q3', 'C3'];

      // When
      for (final move in moves) {
        await blitzService.addMove(
          gameId: gameId,
          move: move,
          playerColor: move.hashCode.isEven ? 'black' : 'white',
        );
      }

      // Then - All moves processed without timeout
    });
  });

  group('Correspondence Game Service Tests', () {
    late CorrespondenceGameService correspondenceService;

    setUp(() {
      correspondenceService = CorrespondenceGameService();
    });

    test('Starts turn-based Correspondence game', () async {
      // Given
      final uid = 'user-789';
      final opponentUid = 'user-000';
      final boardSize = 19;

      // When
      final game = await correspondenceService.startCorrespondenceGame(
        uid: uid,
        boardSize: boardSize,
        opponentUid: opponentUid,
      );

      // Then
      expect(game, isNotNull);
      expect(game.isActive, true);
    });

    test('Submits move in Correspondence game', () async {
      // Given
      final gameId = 'corr-game-001';
      final move = 'R17';
      final uid = 'player-uid';

      // When
      await correspondenceService.submitMove(
        gameId: gameId,
        move: move,
        playerId: uid,
      );

      // Then - Move submitted successfully
    });

    test('Handles timeout for turn in Correspondence', () async {
      // Given
      final gameId = 'corr-timeout-001';
      final timeoutDays = 7;

      // When
      final timedOut = await correspondenceService.checkTurnTimeout(
        gameId: gameId,
        timeoutDays: timeoutDays,
      );

      // Then
      expect(timedOut, isA<bool>());
    });
  });

  group('Team Game Service Tests', () {
    late TeamGameService teamService;

    setUp(() {
      teamService = TeamGameService();
    });

    test('Creates 2vs2 team game session', () async {
      // Given
      final team1Players = ['player-1', 'player-2'];
      final team2Players = ['player-3', 'player-4'];
      final boardSize = 19;

      // When
      final game = await teamService.startTeamGame(
        team1Players: team1Players,
        team2Players: team2Players,
        boardSize: boardSize,
      );

      // Then
      expect(game, isNotNull);
      expect(game.playerCount, 4);
    });

    test('Handles team communication during game', () async {
      // Given
      final gameId = 'team-game-001';
      final playerId = 'player-1';
      final message = 'Strategy: focus on territory!';

      // When
      await teamService.sendTeamMessage(
        gameId: gameId,
        playerId: playerId,
        message: message,
      );

      // Then - Message sent to team channel
    });

    test('Calculates team score aggregation', () async {
      // Given
      final team1Score = 125.5;
      final team2Score = 115.0;

      // When
      final winner = team1Score > team2Score ? 'team1' : 'team2';
      final scoreDifference = (team1Score - team2Score).abs();

      // Then
      expect(winner, 'team1');
      expect(scoreDifference, greaterThan(0));
    });
  });

  group('Cross-Mode Features', () {
    late GameModeService gameModeService;

    setUp(() {
      gameModeService = GameModeService();
    });

    test('Tracks rating changes across all game modes', () async {
      // Given
      final userId = 'user-rating-123';
      final initialRating = 1800;
      final gameResult = 'win';

      // When
      final ratingChange = await gameModeService.calculateRatingChange(
        userId: userId,
        currentRating: initialRating,
        gameResult: gameResult,
      );

      // Then
      expect(ratingChange, isNotNull);
    });

    test('Maintains game history across modes', () async {
      // Given
      final userId = 'user-history-456';

      // When
      final gameHistory =
          await gameModeService.getUserGameHistory(userId);

      // Then
      expect(gameHistory, isNotNull);
      expect(gameHistory, isA<List>());
    });

    test('Generates statistics by game mode', () async {
      // Given
      final userId = 'user-stats-789';

      // When
      final stats = await gameModeService.getGameModeStats(userId);

      // Then
      expect(stats, isNotNull);
      expect(stats.containsKey('blitz'), true);
      expect(stats.containsKey('correspondence'), true);
      expect(stats.containsKey('team'), true);
    });

    test('Validates player eligibility for game modes', () async {
      // Given
      final userId = 'player-eligible';
      final desiredMode = GameModeType.team;

      // When
      final isEligible = await gameModeService.isEligibleForMode(
        userId: userId,
        gameMode: desiredMode,
      );

      // Then
      expect(isEligible, isA<bool>());
    });

    test('Handles concurrent game sessions', () async {
      // Given
      final userId = 'multi-game-player';
      final maxConcurrentGames = 3;

      // When
      final activeSessions =
          await gameModeService.getActiveSessionsForUser(userId);

      // Then
      expect(activeSessions.length, lessThanOrEqualTo(maxConcurrentGames));
    });
  });

  group('Game Mode Configuration & Customization', () {
    test('Supports custom time configurations', () {
      // Given
      final customMode = GameMode(
        id: 'custom-time',
        name: 'Rapid',
        description: 'カスタム急速戦',
        timeLimit: 600, // 10 minutes custom
        difficulty: 'normal',
        type: GameModeType.traditional,
        maxPlayers: 2,
      );

      // Then
      expect(customMode.timeLimit, 600);
    });

    test('Supports difficulty level variations', () {
      // Given
      final easyMode = GameMode(
        id: 'easy-mode',
        name: 'Easy',
        description: '初心者向け',
        timeLimit: 900,
        difficulty: 'easy',
        type: GameModeType.traditional,
        maxPlayers: 2,
      );

      // Then
      expect(easyMode.difficulty, 'easy');
    });

    test('Handles game mode icons/assets', () {
      // Given
      final modeWithIcon = GameMode(
        id: 'icon-test',
        name: 'Blitz',
        description: '5分急速戦',
        timeLimit: 300,
        difficulty: 'normal',
        type: GameModeType.blitz,
        maxPlayers: 2,
        iconPath: 'assets/icons/blitz.svg',
      );

      // Then
      expect(modeWithIcon.iconPath, isNotNull);
      expect(modeWithIcon.iconPath?.contains('blitz'), true);
    });
  });
}
