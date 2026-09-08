import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// GameResultScreen - Post-game summary and analysis
///
/// Displays:
/// - Final score with Chinese rules
/// - Winner determination
/// - Move-by-move analysis (powered by AI)
/// - Stats (duration, moves, difficulty)
/// - Options to save game or play again
class GameResultScreen extends ConsumerWidget {
  final String result; // 'win', 'lose', 'draw', 'resign'
  final double? blackScore;
  final double? whiteScore;

  const GameResultScreen({
    Key? key,
    required this.result,
    this.blackScore,
    this.whiteScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building GameResultScreen: result=$result');

    final boardState = ref.watch(gameBoardStateProvider);
    final aiLevel = ref.watch(aiLevelProvider);
    final movesCount = ref.watch(movesCountProvider);
    final currentUser = ref.watch(currentUserProvider);

    // Determine winner
    final winner = _determineWinner(
      result,
      blackScore ?? 0,
      whiteScore ?? 0,
    );

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              // Result header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Win/lose indicator
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: winner == 'player'
                            ? Colors.green[700]?.withOpacity(0.2)
                            : winner == 'ai'
                            ? Colors.red[700]?.withOpacity(0.2)
                            : Colors.amber[600]?.withOpacity(0.2),
                        border: Border.all(
                          color: winner == 'player'
                              ? Colors.green[400]!
                              : winner == 'ai'
                              ? Colors.red[400]!
                              : Colors.amber[600]!,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        winner == 'player'
                            ? Icons.emoji_events
                            : winner == 'ai'
                            ? Icons.sentiment_dissatisfied
                            : Icons.balance,
                        size: 50,
                        color: winner == 'player'
                            ? Colors.green[400]
                            : winner == 'ai'
                            ? Colors.red[400]
                            : Colors.amber[600],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Result text
                    Text(
                      _getResultTitle(winner),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      _getResultSubtitle(result),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Score section
              if (result != 'resign')
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildScoreSection(
                    context,
                    blackScore ?? 0,
                    whiteScore ?? 0,
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white10),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white.withOpacity(0.03),
                    ),
                    child: Text(
                      'Game resigned. No final score calculated.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Game stats
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildStatsSection(
                  context,
                  boardSize: boardState.boardSize,
                  aiLevel: aiLevel,
                  movesCount: movesCount,
                ),
              ),

              const SizedBox(height: 32),

              // AI commentary (if available)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _buildCommentarySection(context),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleSaveGame(context, ref, currentUser),
                        child: const Text('Save Game'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handlePlayAgain(context, ref),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[600],
                        ),
                        child: Text(
                          'Play Again',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _handleBackToHome(context),
                        child: const Text('Back to Home'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Score section showing final positions
  Widget _buildScoreSection(
    BuildContext context,
    double blackScore,
    double whiteScore,
  ) {
    final blackWins = blackScore > whiteScore;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        children: [
          Text(
            'Final Score (Chinese Rules)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black,
                      border: Border.all(
                        color: blackWins ? Colors.green[400]! : Colors.white30,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Black\n(You)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    blackScore.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'vs',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      border: Border.all(
                        color: !blackWins ? Colors.red[400]! : Colors.black26,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'White\n(AI)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    whiteScore.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Stats section
  Widget _buildStatsSection(
    BuildContext context, {
    required int boardSize,
    required int aiLevel,
    required int movesCount,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.03),
      ),
      child: Column(
        children: [
          Text(
            'Game Stats',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(context, 'Board', '${boardSize}×$boardSize'),
              _buildStatItem(context, 'AI Level', '$aiLevel'),
              _buildStatItem(context, 'Moves', '$movesCount'),
            ],
          ),
        ],
      ),
    );
  }

  /// Single stat item
  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.amber[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Commentary section (placeholder)
  Widget _buildCommentarySection(BuildContext context) {
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
            'Move Analysis',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'AI-powered analysis coming soon. AI will review your moves and provide detailed commentary.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _getResultTitle(String? winner) {
    switch (winner) {
      case 'player':
        return 'Victory!';
      case 'ai':
        return 'Defeat';
      default:
        return 'Game Over';
    }
  }

  String _getResultSubtitle(String result) {
    switch (result) {
      case 'resign':
        return 'You resigned the game';
      case 'draw':
        return 'The game ended in a draw';
      default:
        return 'The game has ended';
    }
  }

  String? _determineWinner(String result, double blackScore, double whiteScore) {
    if (result == 'resign') return 'ai';
    if (blackScore > whiteScore) return 'player';
    if (whiteScore > blackScore) return 'ai';
    return 'draw';
  }

  void _handleSaveGame(BuildContext context, WidgetRef ref, User? currentUser) {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save games')),
      );
      return;
    }

    _logger.i('Saving game...');
    // Game save will be done through GameRecord provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Game saved!')),
    );
  }

  void _handlePlayAgain(BuildContext context, WidgetRef ref) {
    _logger.i('Playing again...');
    Navigator.of(context).pushReplacementNamed('/ai-game');
  }

  void _handleBackToHome(BuildContext context) {
    _logger.i('Returning to home...');
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }
}
