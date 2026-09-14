import 'package:goen/models/index.dart';

/// Fixture data for testing
class TestData {
  /// Sample user for testing
  static User testUser = User(
    uid: 'test-user-123',
    email: 'test@example.com',
    displayName: 'Test Player',
    subscriptionActive: false,
    tutorialCompleted: true,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 9, 1),
  );

  /// Premium user fixture
  static User premiumUser = User(
    uid: 'premium-user-456',
    email: 'premium@example.com',
    displayName: 'Premium Player',
    subscriptionActive: true,
    tutorialCompleted: true,
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime(2026, 9, 1),
  );

  /// Sample board state (empty 9x9)
  static BoardState emptyBoardState = BoardState(
    boardSize: 9,
    stones: List.generate(
      9,
      (row) => List.generate(9, (col) => -1),
    ),
    isPlayerBlack: true,
  );

  /// Sample board state with stones
  static BoardState boardWithStones = BoardState(
    boardSize: 9,
    stones: List.generate(
      9,
      (row) => List.generate(
        9,
        (col) {
          if (row == 3 && col == 3) return 0; // Black stone
          if (row == 3 && col == 5) return 1; // White stone
          return -1; // Empty
        },
      ),
    ),
    isPlayerBlack: true,
  );

  /// Sample tsume-go problem
  static TsumeGoProblem tsumeGoProblem = TsumeGoProblem(
    id: 'tsume-001',
    difficulty: 2,
    sgfData:
        '(;GM[1]FF[4]CA[UTF-8]AP[Sabaki:0.52.3]KM[6.5]SZ[9];B[ee];W[de];B[df])',
    solutionSgf:
        '(;GM[1]FF[4];B[ee];W[de];B[df]WR[3k]BR[1d])',
    explanation: 'Capture the white stone by playing at D-5 (d5).',
    source: 'Daily Tsume Collection',
    createdAt: DateTime(2026, 9, 1),
  );

  /// Sample game record (win)
  static GameRecord gameRecordWin = GameRecord(
    id: 'game-win-001',
    uid: 'test-user-123',
    boardSize: 9,
    sgfData: '(;GM[1]FF[4]CA[UTF-8]SZ[9]KM[6.5];B[pd];W[dp])',
    result: 'win',
    blackScore: 50.5,
    whiteScore: 42.0,
    aiLevel: 3,
    playedAt: DateTime(2026, 9, 1),
  );

  /// Sample game record (loss)
  static GameRecord gameRecordLoss = GameRecord(
    id: 'game-loss-001',
    uid: 'test-user-123',
    boardSize: 9,
    sgfData: '(;GM[1]FF[4]CA[UTF-8]SZ[9]KM[6.5];B[pd];W[dp])',
    result: 'loss',
    blackScore: 38.0,
    whiteScore: 45.5,
    aiLevel: 5,
    playedAt: DateTime(2026, 8, 31),
  );

  /// Sample kifu (historical game)
  static KifuLibrary honinboGame = KifuLibrary(
    id: 'kifu-honinbo-001',
    title: 'Honinbo Shusaku vs Inoue Inseki',
    players: ['Honinbo Shusaku', 'Inoue Inseki'],
    sgfData: '''(;GM[1]FF[4]CA[UTF-8]AP[Sabaki:0.52.3]
    SZ[19]KM[0.5]RE[W+1]DT[1840]
    ;B[pd];W[dp];B[pq];W[cf])''',
    aiCommentaryData: null,
    category: 'Historical (Edo Period)',
    source: 'Go Archives',
    createdAt: DateTime(1840, 1, 1),
  );

  /// Sample kifu (modern game)
  static KifuLibrary alphagonGame = KifuLibrary(
    id: 'kifu-alphago-001',
    title: 'AlphaGo vs Lee Sedol - Game 1',
    players: ['AlphaGo', 'Lee Sedol'],
    sgfData: '''(;GM[1]FF[4]CA[UTF-8]AP[GoKifu:1.0]
    SZ[19]KM[7.5]RE[B+R]DT[2016-03-09]
    ;B[qd];W[dc];B[pq];W[cp])''',
    aiCommentaryData: null,
    category: 'Modern (AI Era)',
    source: 'DeepMind',
    createdAt: DateTime(2016, 3, 9),
  );

  /// AI opponent configurations
  static AIOpponentConfig levelOneConfig = AIOpponentConfig(
    level: 1,
    name: 'Beginner',
    description: 'Good for learning basic tactics',
    kgsRating: '20k',
  );

  static AIOpponentConfig levelFiveConfig = AIOpponentConfig(
    level: 5,
    name: 'Intermediate',
    description: 'Balanced challenge',
    kgsRating: '10k',
  );

  static AIOpponentConfig levelTenConfig = AIOpponentConfig(
    level: 10,
    name: 'Expert',
    description: 'Challenging gameplay',
    kgsRating: '1k',
  );
}
