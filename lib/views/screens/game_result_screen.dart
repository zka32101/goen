import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/views/widgets/index.dart';
import 'package:goen/services/index.dart' show GameAnalysis;
import 'package:goen/utils/shoji_transition.dart';
import 'package:goen/utils/sgf_parser.dart';
import 'ai_game_screen.dart';
import 'package:goen/config/theme.dart';

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

    // Prepare game share data
    final gameShareData = GameShareData(
      gameId: '${DateTime.now().millisecondsSinceEpoch}',
      result: winner == 'player' ? 'win' : winner == 'ai' ? 'loss' : 'draw',
      blackScore: blackScore ?? 0,
      whiteScore: whiteScore ?? 0,
      boardSize: boardState.boardSize,
      aiLevel: aiLevel,
    );

    return Scaffold(
      backgroundColor: AppColors.sumi,
      floatingActionButton: GameShareButton(
        gameData: gameShareData,
        onShared: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Game shared successfully!')),
          );
        },
      ),
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
                    _maybeWithVictoryGlow(
                      isVictory: winner == 'player',
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: winner == 'player'
                              ? AppColors.wakatake.withOpacity(0.2)
                              : winner == 'ai'
                              ? AppColors.shuLight.withOpacity(0.2)
                              : AppColors.kin.withOpacity(0.2),
                          border: Border.all(
                            color: winner == 'player'
                                ? AppColors.wakatake
                                : winner == 'ai'
                                ? AppColors.shuLight
                                : AppColors.kin,
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
                              ? AppColors.wakatake
                              : winner == 'ai'
                              ? AppColors.shuLight
                              : AppColors.kin,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Result text
                    Text(
                      _getResultTitle(winner),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.washi,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      _getResultSubtitle(result),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.washiDim,
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
                      color: AppColors.washi.withOpacity(0.03),
                    ),
                    child: Text(
                      'Game resigned. No final score calculated.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.washiDim,
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
                child: _AiReviewSection(
                  // Real move-order SGF (see sgf_parser.dart), not
                  // boardState.toSgf()'s final-snapshot-only dialect —
                  // the AI review needs the actual move sequence to
                  // explain individual moves, not just the end position.
                  sgfData: generateSgfFromMoves(
                    ref.watch(moveHistoryProvider),
                    boardState.boardSize,
                  ),
                ),
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
                          backgroundColor: AppColors.kin,
                        ),
                        child: Text(
                          'Play Again',
                          style: TextStyle(
                            color: AppColors.sumi,
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

              // Leave room so the floating share button never covers the
              // last action button once scrolled to the end.
              const SizedBox(height: 104),
            ],
          ),
        ),
      ),
    );
  }

  /// 勝った時だけ、勝敗アイコンにゆっくり明滅する後光を付ける。
  Widget _maybeWithVictoryGlow({required bool isVictory, required Widget child}) {
    if (!isVictory) return child;
    return _VictoryGlow(child: child);
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
        color: AppColors.washi.withOpacity(0.03),
      ),
      child: Column(
        children: [
          Text(
            'Final Score (Chinese Rules)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.washiDim,
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
                      color: AppColors.sumi,
                      border: Border.all(
                        color: blackWins ? AppColors.wakatake : AppColors.grey500,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Black\n(You)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.washi,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    blackScore.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.washi,
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
                      color: AppColors.washiDim,
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
                      color: AppColors.washi,
                      border: Border.all(
                        color: !blackWins ? AppColors.shuLight : Colors.black26,
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'White\n(AI)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.sumi,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    whiteScore.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.washi,
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
        color: AppColors.washi.withOpacity(0.03),
      ),
      child: Column(
        children: [
          Text(
            'Game Stats',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.washi,
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
            color: AppColors.washiDim,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.kin,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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

  Future<void> _handleSaveGame(
    BuildContext context,
    WidgetRef ref,
    User? currentUser,
  ) async {
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save games')),
      );
      return;
    }

    _logger.i('Saving game...');
    final boardState = ref.read(gameBoardStateProvider);

    try {
      final gameId = await ref.read(saveGameRecordProvider)(
        uid: currentUser.uid,
        boardSize: boardState.boardSize,
        result: result,
        blackScore: blackScore,
        whiteScore: whiteScore,
      );
      _logger.i('✅ Game saved: $gameId');

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game saved!')),
      );
    } catch (e) {
      _logger.e('❌ Failed to save game: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save game: $e')),
      );
    }
  }

  void _handlePlayAgain(BuildContext context, WidgetRef ref) {
    _logger.i('Playing again...');
    // gameBoardStateProvider etc. are plain globals, not scoped to
    // AIGameScreen's lifecycle — without this, the new game would start
    // by showing the just-finished board instead of an empty one.
    ref.read(startNewGameProvider)();
    Navigator.of(context).pushReplacement(shojiTransitionRoute(const AIGameScreen()));
  }

  void _handleBackToHome(BuildContext context) {
    _logger.i('Returning to home...');
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }
}

/// AI振り返り（対局後レビュー） - ボタン押下でCloud Functionsを呼び、
/// 手ごとの解説と局面の総評を表示する。時間のかかる処理なので画面表示時に
/// 自動実行はせず、ユーザーの明示的な操作で開始する。
class _AiReviewSection extends ConsumerStatefulWidget {
  final String sgfData;

  const _AiReviewSection({required this.sgfData});

  @override
  ConsumerState<_AiReviewSection> createState() => _AiReviewSectionState();
}

class _AiReviewSectionState extends ConsumerState<_AiReviewSection> {
  GameAnalysis? _analysis;
  bool _loading = false;
  String? _error;

  Future<void> _runReview() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final analysis = await ref.read(generateGameAnalysisProvider)(
        sgfData: widget.sgfData,
        kifuId: 'review-${DateTime.now().millisecondsSinceEpoch}',
      );
      if (!mounted) return;
      setState(() => _analysis = analysis);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'AI振り返りの生成に失敗しました: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.washi.withOpacity(0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI振り返り',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.washi),
          ),
          const SizedBox(height: 12),
          if (_analysis == null && !_loading)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AIが対局を振り返り、良かった手・改善点を解説します。',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.washiDim,
                        height: 1.6,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _runReview,
                    child: const Text('AIで振り返る'),
                  ),
                ),
              ],
            ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.redAccent)),
          if (_analysis != null) _buildAnalysis(context, _analysis!),
        ],
      ),
    );
  }

  Widget _buildAnalysis(BuildContext context, GameAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          analysis.overallTheme,
          style: const TextStyle(color: AppColors.washi, height: 1.6),
        ),
        const SizedBox(height: 8),
        Text(
          '転換点: ${analysis.keyTurningPoints}',
          style: TextStyle(color: AppColors.washiDim, height: 1.6),
        ),
        const SizedBox(height: 8),
        Text(
          analysis.conclusion,
          style: TextStyle(color: AppColors.washiDim, height: 1.6),
        ),
        const SizedBox(height: 16),
        for (final move in analysis.moves) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '${move.moveNumber}手目 (${move.playerColor == 'black' ? '黒' : '白'} '
              '[${move.row},${move.col}]): ${move.basicExplanation}',
              style: TextStyle(color: AppColors.washiDim, fontSize: 13),
            ),
          ),
        ],
      ],
    );
  }
}

/// 勝利時のトロフィーアイコンをゆっくり明滅させる、控えめな祝福演出。
/// ゲームらしい楽しさを足す一方、派手な紙吹雪などは「大人向けプレミアム」
/// というトーンに合わないため、光量が上下するだけのシンプルな後光に留める。
class _VictoryGlow extends StatefulWidget {
  final Widget child;

  const _VictoryGlow({required this.child});

  @override
  State<_VictoryGlow> createState() => _VictoryGlowState();
}

class _VictoryGlowState extends State<_VictoryGlow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = 0.25 + _controller.value * 0.35;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.kin.withOpacity(glow),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
