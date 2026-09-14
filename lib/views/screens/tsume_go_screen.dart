import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/views/widgets/index.dart';

final _logger = Logger();

/// TsumeGoScreen - Daily tsume-go puzzle gameplay
///
/// Features:
/// - Load today's deterministic daily puzzle
/// - Interactive puzzle board with solution validation
/// - Difficulty level selection (1-5)
/// - Attempt tracking and streak display
/// - Hint system
class TsumeGoScreen extends ConsumerStatefulWidget {
  const TsumeGoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<TsumeGoScreen> createState() => _TsumeGoScreenState();
}

class _TsumeGoScreenState extends ConsumerState<TsumeGoScreen> {
  late int _selectedRow;
  late int _selectedCol;

  @override
  void initState() {
    super.initState();
    _logger.i('TsumeGoScreen initialized');
    _selectedRow = -1;
    _selectedCol = -1;
  }

  @override
  Widget build(BuildContext context) {
    final todaysPuzzle = ref.watch(todaysTsumeProblemProvider);
    final isPuzzleSolved = ref.watch(isPuzzleSolvedProvider);
    final attemptCount = ref.watch(puzzleAttemptCountProvider);
    final currentUser = ref.watch(currentUserProvider);
    final selectedDifficulty = ref.watch(selectedDifficultyProvider);
    final difficultyLevels = ref.watch(difficultyLevelsProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text("Today's Puzzle"),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showHint(context),
            tooltip: 'Hint',
          ),
        ],
      ),
      floatingActionButton: todaysPuzzle.maybeWhen(
        data: (puzzle) {
          if (puzzle != null && isPuzzleSolved) {
            final puzzleShareData = PuzzleShareData(
              puzzleId: puzzle.id,
              difficulty: _getDifficultyLabel(puzzle.difficulty),
              attemptCount: attemptCount,
              solvingTime: Duration(seconds: 300), // Placeholder
              isSolved: true,
              currentStreak: ref.watch(puzzleStreakProvider) ?? 0,
            );
            return PuzzleShareButton(
              puzzleData: puzzleShareData,
              onShared: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Puzzle shared successfully!')),
                );
              },
            );
          }
          return null;
        },
        orElse: () => null,
      ),
      body: todaysPuzzle.when(
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, error),
        data: (puzzle) {
          if (puzzle == null) {
            return _buildNoPuzzleState(context);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Puzzle header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Difficulty',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(
                                  puzzle.difficulty,
                                  (_) => Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Attempts',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$attemptCount',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                  color: Colors.amber[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (!isPuzzleSolved)
                        Text(
                          '${puzzle.expectedMoves} moves to solve',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                            color: Colors.white70,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[700]?.withOpacity(0.3),
                            border: Border.all(
                              color: Colors.green[400]!,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 16,
                                color: Colors.green[400],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Puzzle Solved!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  color: Colors.green[400],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Puzzle board
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPuzzleBoard(context, puzzle),
                  ),
                ),

                const SizedBox(height: 32),

                // Difficulty selector (when not solved)
                if (!isPuzzleSolved && currentUser != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildDifficultySelector(context, ref),
                  ),

                const SizedBox(height: 32),

                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      if (!isPuzzleSolved)
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                ),
                                onPressed: currentUser != null
                                    ? () => _handleSubmitSolution(
                                      context,
                                      ref,
                                      puzzle,
                                      currentUser,
                                    )
                                    : null,
                                child: const Text('Check Solution'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => _handleSkipPuzzle(context),
                                child: const Text('Skip to Tomorrow'),
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[600],
                                ),
                                onPressed: () => _handleShowExplanation(context, puzzle),
                                child: const Text('View Explanation'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Back'),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.amber[600]!),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading today\'s puzzle...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Could not load puzzle',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPuzzleState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 64,
            color: Colors.amber[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No puzzle available today',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back tomorrow for a new puzzle',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzleBoard(BuildContext context, TsumeGoProblem puzzle) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.amber[600]!,
          width: 2,
        ),
        color: Colors.amber[100]?.withOpacity(0.1),
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: _GoGridPainter(boardSize: 9),
            size: const Size(300, 300),
          ),
          // TODO: Render puzzle board from SGF data
          Center(
            child: Text(
              'Puzzle Board\n(SGF Parser - Phase 5.1)',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySelector(BuildContext context, WidgetRef ref) {
    final selectedDifficulty = ref.watch(selectedDifficultyProvider);
    final difficultyLevels = ref.watch(difficultyLevelsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse by Difficulty',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: difficultyLevels.entries.map((entry) {
              final level = entry.key;
              final label = entry.value;
              final isSelected = selectedDifficulty == level;

              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(setDifficultyProvider)(level);
                  }
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showHint(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Hint'),
        content: const Text(
          'Look for weak stones that can be captured. In tsume-go, find the forcing sequence that leads to capturing opponent\'s stones.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _handleSubmitSolution(
    BuildContext context,
    WidgetRef ref,
    TsumeGoProblem puzzle,
    User currentUser,
  ) {
    _logger.i('Submitting solution for puzzle ${puzzle.id}');
    // TODO: Validate solution and record attempt
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Solution checking - Phase 5.1')),
    );
  }

  void _handleSkipPuzzle(BuildContext context) {
    _logger.i('Skipping puzzle');
    Navigator.pop(context);
  }

  void _handleShowExplanation(BuildContext context, TsumeGoProblem puzzle) {
    _logger.i('Showing explanation for puzzle ${puzzle.id}');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Explanation'),
        content: SingleChildScrollView(
          child: Text(
            puzzle.explanation ?? 'No explanation available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getDifficultyLabel(int difficulty) {
    switch (difficulty) {
      case 1:
        return 'easy';
      case 2:
        return 'easy';
      case 3:
        return 'medium';
      case 4:
        return 'hard';
      case 5:
        return 'master';
      default:
        return 'medium';
    }
  }
}

/// Custom painter for Go board grid
class _GoGridPainter extends CustomPainter {
  final int boardSize;

  _GoGridPainter({required this.boardSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 1;

    final step = size.width / boardSize;

    // Horizontal lines
    for (int i = 0; i < boardSize; i++) {
      canvas.drawLine(
        Offset(0, i * step),
        Offset(size.width, i * step),
        paint,
      );
    }

    // Vertical lines
    for (int i = 0; i < boardSize; i++) {
      canvas.drawLine(
        Offset(i * step, 0),
        Offset(i * step, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GoGridPainter oldDelegate) =>
      oldDelegate.boardSize != boardSize;
}
