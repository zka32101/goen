import 'package:riverpod/riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/services/index.dart';

final _logger = Logger();

// ================== TODAY'S PUZZLE ==================

/// Singleton instance of FirestoreService (shared with game_provider)
final tsumeGoFirestoreProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Today's daily tsume-go problem
/// Deterministic: same problem for all users on same day
final todaysTsumeProblemProvider = FutureProvider<TsumeGoProblem?>((ref) async {
  _logger.i('Fetching today\'s tsume-go problem');

  final firestoreService = ref.watch(tsumeGoFirestoreProvider);
  try {
    final problem = await firestoreService.getTodaysTsumeProblem();
    _logger.i('✅ Today\'s problem fetched: ${problem?.id ?? 'none'}');
    return problem;
  } catch (e) {
    _logger.e('❌ Failed to fetch today\'s problem: $e');
    rethrow;
  }
});

// ================== TSUME-GO PUZZLE STATE ==================

/// Current puzzle being solved (can override today's default)
final currentTsumeProblemProvider = StateProvider<TsumeGoProblem?>((ref) {
  // Initialize with today's problem
  final todaysProblem = ref.watch(todaysTsumeProblemProvider);
  return todaysProblem.value;
});

/// Current puzzle solution attempt
final currentPuzzleBoardProvider = StateProvider<BoardState>((ref) {
  final problem = ref.watch(currentTsumeProblemProvider);
  if (problem == null) {
    return BoardState(
      boardSize: 9,
      stones: List.generate(9, (_) => List.filled(9, 0)),
      capturedBlack: 0,
      capturedWhite: 0,
      isBlackTurn: true,
    );
  }

  // Parse SGF to board state (TBD: implement SGF parser)
  // For now, use placeholder
  return BoardState(
    boardSize: 9,
    stones: List.generate(9, (_) => List.filled(9, 0)),
    capturedBlack: 0,
    capturedWhite: 0,
    isBlackTurn: true,
  );
});

/// Is current puzzle solved?
final isPuzzleSolvedProvider = StateProvider<bool>((ref) {
  return false;
});

/// Number of attempts on current puzzle
final puzzleAttemptCountProvider = StateProvider<int>((ref) {
  return 0;
});

/// Time spent on current puzzle (in seconds)
final puzzleSolvingTimeProvider = StateProvider<int>((ref) {
  return 0;
});

// ================== PUZZLE ACTIONS ==================

/// Load a specific puzzle by ID
final loadPuzzleProvider = FutureProvider.family<TsumeGoProblem?, String>(
  (ref, problemId) async {
    _logger.i('Loading puzzle: $problemId');

    final firestoreService = ref.watch(tsumeGoFirestoreProvider);
    try {
      final problem = await firestoreService.getTsumeProblem(problemId);
      if (problem != null) {
        ref.read(currentTsumeProblemProvider.notifier).state = problem;
        ref.read(isPuzzleSolvedProvider.notifier).state = false;
        ref.read(puzzleAttemptCountProvider.notifier).state = 0;
        _logger.i('✅ Puzzle loaded: $problemId');
      }
      return problem;
    } catch (e) {
      _logger.e('❌ Failed to load puzzle: $e');
      rethrow;
    }
  },
);

/// Get puzzles by difficulty level
final tsumeProblemesByDifficultyProvider =
    FutureProvider.family<List<TsumeGoProblem>, int>(
  (ref, difficulty) async {
    _logger.i('Fetching tsume-go problems: difficulty=$difficulty');

    final firestoreService = ref.watch(tsumeGoFirestoreProvider);
    try {
      final problems = await firestoreService.getTsumeProblems(difficulty, limit: 10);
      _logger.i('✅ Problems fetched: ${problems.length}');
      return problems;
    } catch (e) {
      _logger.e('❌ Failed to fetch problems: $e');
      rethrow;
    }
  },
);

/// Check if puzzle solution is correct
/// Returns true if user's solution matches expected solution
final checkPuzzleSolutionProvider = Provider.family<bool, String>(
  (ref, userSolutionSgf) {
    final problem = ref.watch(currentTsumeProblemProvider);
    if (problem == null) {
      return false;
    }

    // TBD: Implement SGF comparison logic
    // For now, placeholder comparison
    _logger.i('Checking puzzle solution...');
    return userSolutionSgf == problem.solutionSgf;
  },
);

/// Record puzzle attempt
final recordPuzzleAttemptProvider = FutureProvider.family<String, ({String uid, bool isCorrect, String userSolutionSgf})>(
  (ref, params) async {
    final problem = ref.watch(currentTsumeProblemProvider);
    if (problem == null) {
      throw Exception('No current puzzle selected');
    }

    _logger.i('Recording puzzle attempt: uid=${params.uid}, correct=${params.isCorrect}');

    final firestoreService = ref.watch(tsumeGoFirestoreProvider);
    final log = UserTsumeGoLog(
      id: '', // Firestore will auto-generate
      uid: params.uid,
      problemId: problem.id,
      isCorrect: params.isCorrect,
      solvedAt: DateTime.now(),
      attemptCount: ref.watch(puzzleAttemptCountProvider),
      solvingTime: Duration(seconds: ref.watch(puzzleSolvingTimeProvider)),
      userSolutionSgf: params.userSolutionSgf,
    );

    try {
      final logId = await firestoreService.saveTsumeGoLog(log);
      if (params.isCorrect) {
        ref.read(isPuzzleSolvedProvider.notifier).state = true;
      } else {
        ref.read(puzzleAttemptCountProvider.notifier).state += 1;
      }
      _logger.i('✅ Puzzle attempt recorded: $logId');
      return logId;
    } catch (e) {
      _logger.e('❌ Failed to record puzzle attempt: $e');
      rethrow;
    }
  },
);

// ================== STREAK TRACKING ==================

/// User's current tsume-go solving streak (in days)
final tsumeGoStreakProvider = FutureProvider.family<int, String>(
  (ref, uid) async {
    _logger.i('Calculating tsume-go streak for user: $uid');

    final firestoreService = ref.watch(tsumeGoFirestoreProvider);
    try {
      final streak = await firestoreService.getTsumeGoStreak(uid);
      _logger.i('✅ Streak calculated: $streak days');
      return streak;
    } catch (e) {
      _logger.e('❌ Failed to calculate streak: $e');
      rethrow;
    }
  },
);

// ================== DIFFICULTY SELECTION ==================

/// Selected difficulty level (1-5)
final selectedDifficultyProvider = StateProvider<int>((ref) {
  return 1; // Default to easiest
});

/// Available puzzle difficulties with labels
final difficultyLevelsProvider = Provider<Map<int, String>>((ref) {
  return {
    1: '初心者向け (Beginner)',
    2: '初級 (Elementary)',
    3: '中級 (Intermediate)',
    4: '上級 (Advanced)',
    5: 'プロ級 (Professional)',
  };
});

/// Switch to different difficulty
final setDifficultyProvider = Provider<void Function(int)>((ref) {
  return (difficulty) {
    _logger.i('Switching to difficulty: $difficulty');
    ref.read(selectedDifficultyProvider.notifier).state = difficulty;
  };
});

// ================== PUZZLE HISTORY ==================

/// Get user's tsume-go solving history
final userTsumeGoLogsProvider = FutureProvider.family<List<UserTsumeGoLog>, String>(
  (ref, uid) async {
    _logger.i('Fetching tsume-go logs for user: $uid');

    final firestoreService = ref.watch(tsumeGoFirestoreProvider);
    try {
      // TBD: Implement paginated fetch in FirestoreService
      // For now, get recent attempts by fetching streak and working backwards
      final streak = await firestoreService.getTsumeGoStreak(uid);
      _logger.i('✅ Streak fetched: $streak days');

      // Return empty list for now - will be populated by detail fetch
      return [];
    } catch (e) {
      _logger.e('❌ Failed to fetch tsume-go logs: $e');
      rethrow;
    }
  },
);
