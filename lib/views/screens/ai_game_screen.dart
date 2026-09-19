import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/services/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/utils/stone_feedback.dart';
import 'package:goen/utils/wa_decorations.dart';
import 'package:goen/config/theme.dart';

final _logger = Logger();

/// AIGameScreen - Live gameplay against GNU Go engine
///
/// Core features:
/// - Interactive 9x9 Go board (configurable)
/// - Real-time AI move requests with retry logic
/// - Move validation and illegal move prevention
/// - Game ending with score calculation (Chinese rules)
/// - Move-by-move game recording
///
/// Priority: Aha moment path - Capture stone on first move
class AIGameScreen extends ConsumerStatefulWidget {
  const AIGameScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AIGameScreen> createState() => _AIGameScreenState();
}

class _AIGameScreenState extends ConsumerState<AIGameScreen> {
  late int _selectedRow;
  late int _selectedCol;

  // 捕獲演出用 — イベントIDをキーにしたAnimatedSwitcherで、連続で
  // 石を取ってもその都度新しいアニメーションとして表示させる。
  int _captureEventId = 0;
  int? _captureFlashCount;

  @override
  void initState() {
    super.initState();
    _logger.i('AIGameScreen initialized');
    _selectedRow = -1;
    _selectedCol = -1;
  }

  void _triggerCaptureFlash(int count) {
    if (count <= 0) return;
    setState(() {
      _captureEventId++;
      _captureFlashCount = count;
    });
  }

  @override
  Widget build(BuildContext context) {
    final boardState = ref.watch(gameBoardStateProvider);
    final isGameActive = ref.watch(isGameActiveProvider);
    final aiLevel = ref.watch(aiLevelProvider);
    final movesCount = ref.watch(movesCountProvider);
    final moveHistory = ref.watch(moveHistoryProvider);
    final lastMove = moveHistory.isNotEmpty ? moveHistory.last : null;

    // React to the AI's move once Fuego resolves it: apply it to the board
    // (captures included) the same way a human move is applied.
    ref.listen<AsyncValue<AIMove?>>(aiMoveProvider, (previous, next) {
      final aiMove = next.valueOrNull;
      if (aiMove == null) return;

      if (aiMove.isPass) {
        _logger.i('AI passed');
        final gameEnded = ref.read(applyPassProvider)();
        ref.read(logCustomEventProvider)(
          eventName: 'ai_pass',
          parameters: {'move_number': ref.read(movesCountProvider)},
        );
        if (gameEnded) {
          _endGameByPasses(context, ref);
        }
        return;
      }

      final beforeCaptures = (
        black: ref.read(gameBoardStateProvider).capturedBlack,
        white: ref.read(gameBoardStateProvider).capturedWhite,
      );
      final applied = ref.read(applyMoveProvider)(aiMove.row, aiMove.col);
      if (!applied) {
        _logger.e('❌ AI returned an illegal move: [${aiMove.row},${aiMove.col}]');
        return;
      }
      final afterState = ref.read(gameBoardStateProvider);
      final capturedDelta = (afterState.capturedBlack - beforeCaptures.black) +
          (afterState.capturedWhite - beforeCaptures.white);
      if (capturedDelta > 0) {
        playCaptureFeedback();
        _triggerCaptureFlash(capturedDelta);
      } else {
        playStonePlaceFeedback();
      }

      ref.read(logCustomEventProvider)(
        eventName: 'ai_move',
        parameters: {
          'row': aiMove.row,
          'col': aiMove.col,
          'move_number': ref.read(movesCountProvider),
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text('対局 - Level $aiLevel'),
        centerTitle: true,
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 青海波の地紋。碁盤や文字を邪魔しない薄さで全面に敷く。
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: SeigaihaPatternPainter(color: AppColors.accent.withOpacity(0.04)),
              ),
            ),
          ),
          Column(
            children: [
              // Game info
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const HankoSeal(character: '碁'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '盤の大きさ',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                        Text(
                          '${boardState.boardSize}×${boardState.boardSize}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          'アゲハマ（黒/白）',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                        Text(
                          '${boardState.capturedBlack} / ${boardState.capturedWhite}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '手数',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.grey500,
                          ),
                        ),
                        Text(
                          '$movesCount',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Go board
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: _buildGoBoard(context, ref, boardState, lastMove),
                  ),
                ),
              ),

              // 指し手リスト（タップで局面をプレビュー表示）
              if (moveHistory.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildMoveList(context, moveHistory, boardState.boardSize),
                ),

              // Position evaluation display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _buildPositionEvaluation(context, ref),
              ),

          // Game controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // AI move status
                if (ref.watch(aiMoveProvider).isLoading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: _AiThinkingIndicator(),
                  ),

                // Button row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isGameActive ? () => _handlePass(context, ref) : null,
                        child: const Text('Pass'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isGameActive ? () => _handleResign(context, ref) : null,
                        child: const Text('Resign'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: !isGameActive ? () => _handleNewGame(context, ref) : null,
                        child: Text(
                          isGameActive ? 'Playing...' : 'New Game',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build the interactive Go board
  Widget _buildGoBoard(
    BuildContext context,
    WidgetRef ref,
    BoardState boardState,
    ({int row, int col, String player})? lastMove,
  ) {
    final boardSize = boardState.boardSize;
    final cellSize = 300 / boardSize;

    return GestureDetector(
      onTapDown: (details) {
        if (!ref.read(isGameActiveProvider)) return;
        // Human always plays black; ignore taps while the AI is thinking.
        if (!ref.read(gameBoardStateProvider).isBlackTurn) return;

        // Convert tap position to board coordinates
        final localPosition = details.localPosition;
        final row = (localPosition.dy / cellSize).floor();
        final col = (localPosition.dx / cellSize).floor();

        // Validate position
        if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
          _handleBoardTap(context, ref, row, col);
        }
      },
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryDark,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(4),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFC79A5C), // 榧(かや)材の明るい木目色
              Color(0xFFA87C45),
              Color(0xFFC79A5C),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 木目
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: WoodGrainPainter(color: Colors.black.withOpacity(0.08)),
                ),
              ),
            ),

            // Grid lines
            CustomPaint(
              painter: _GoGridPainter(boardSize: boardSize),
              size: const Size(300, 300),
            ),

            // Stones
            ..._buildStones(boardSize, cellSize, boardState.stones),

            // 直前の一手を示す朱の印
            if (lastMove != null)
              Positioned(
                left: lastMove.col * cellSize + cellSize / 2 - cellSize * 0.12,
                top: lastMove.row * cellSize + cellSize / 2 - cellSize * 0.12,
                child: IgnorePointer(
                  child: Container(
                    width: cellSize * 0.24,
                    height: cellSize * 0.24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: lastMove.player == 'black' ? Colors.white : Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),

            // Legal move indicator
            if (_selectedRow >= 0 && _selectedCol >= 0)
              Positioned(
                left: _selectedCol * cellSize + cellSize / 2 - cellSize * 0.15,
                top: _selectedRow * cellSize + cellSize / 2 - cellSize * 0.15,
                child: Container(
                  width: cellSize * 0.3,
                  height: cellSize * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accent.withOpacity(0.5),
                    border: Border.all(
                      color: AppColors.accent,
                      width: 2,
                    ),
                  ),
                ),
              ),

            // Capture celebration flash
            if (_captureFlashCount != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: _CaptureFlash(
                    key: ValueKey(_captureEventId),
                    count: _captureFlashCount!,
                    onDone: () {
                      if (mounted) setState(() => _captureFlashCount = null);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build stone widgets
  List<Widget> _buildStones(
    int boardSize,
    double cellSize,
    List<List<int>> stones,
  ) {
    final stoneWidgets = <Widget>[];
    final stoneRadius = cellSize * 0.4;

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final stone = stones[row][col];
        if (stone != 0) {
          // 0 = empty, 1 = black, 2 = white
          final isBlack = stone == 1;
          final border = isBlack
              ? null
              : Border.all(color: Colors.grey[400]!, width: 0.5);

          stoneWidgets.add(
            Positioned(
              left: col * cellSize + cellSize / 2 - stoneRadius,
              top: row * cellSize + cellSize / 2 - stoneRadius,
              child: Container(
                width: stoneRadius * 2,
                height: stoneRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: border,
                  // 光源が左上にあるガラス/石のような艶を出すため、
                  // ハイライトを左上にずらしたradialGradientにする。
                  gradient: RadialGradient(
                    center: const Alignment(-0.35, -0.4),
                    radius: 0.9,
                    colors: isBlack
                        ? [Colors.grey[700]!, Colors.black]
                        : [Colors.white, Colors.grey[350]!],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 5,
                      offset: Offset(1.5, 2.5),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      }
    }

    return stoneWidgets;
  }

  void _handleBoardTap(
    BuildContext context,
    WidgetRef ref,
    int row,
    int col,
  ) {
    _logger.i('Board tapped: row=$row, col=$col');

    // Applies the move (occupancy/suicide/ko checked internally) and, on
    // success, updates stones, captures, turn and the ko point.
    final beforeCaptures = (
      black: ref.read(gameBoardStateProvider).capturedBlack,
      white: ref.read(gameBoardStateProvider).capturedWhite,
    );
    final applied = ref.read(applyMoveProvider)(row, col);

    if (!applied) {
      _logger.w('Illegal move attempt: [$row,$col]');
      playIllegalMoveFeedback();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That move is illegal (occupied, suicide, or ko)'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final afterState = ref.read(gameBoardStateProvider);
    final capturedDelta = (afterState.capturedBlack - beforeCaptures.black) +
        (afterState.capturedWhite - beforeCaptures.white);
    if (capturedDelta > 0) {
      playCaptureFeedback();
      _triggerCaptureFlash(capturedDelta);
    } else {
      playStonePlaceFeedback();
    }

    _logger.i('Legal move applied: [$row,$col]');

    // Log move
    ref.read(logCustomEventProvider)(
      eventName: 'player_move',
      parameters: {
        'row': row,
        'col': col,
        'move_number': ref.read(movesCountProvider),
      },
    );

    // positionEvaluationProvider watches board state directly and
    // recomputes on its own; no manual refresh needed here.

    // Request AI move after a short delay so the player can see their
    // stone land before the AI responds. `aiMoveProvider` itself checks
    // whose turn it is, so an invalidate here is a no-op if this move
    // somehow didn't flip the turn.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.invalidate(aiMoveProvider);
      }
    });
  }

  void _handlePass(BuildContext context, WidgetRef ref) {
    if (!ref.read(gameBoardStateProvider).isBlackTurn) return;

    _logger.i('Player passed');
    final gameEnded = ref.read(applyPassProvider)();

    ref.read(logCustomEventProvider)(
      eventName: 'player_pass',
      parameters: {'move_number': ref.read(movesCountProvider)},
    );

    if (gameEnded) {
      _endGameByPasses(context, ref);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You passed. Game will end if AI passes too.'),
        duration: Duration(seconds: 2),
      ),
    );

    // Let the AI respond, same pacing as after a stone placement.
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.invalidate(aiMoveProvider);
      }
    });
  }

  /// Two consecutive passes: score the game and move to the result screen.
  Future<void> _endGameByPasses(BuildContext context, WidgetRef ref) async {
    _logger.i('🏁 Game ended by two consecutive passes');
    ref.read(isGameActiveProvider.notifier).state = false;

    try {
      final result = await ref.read(judgeGameEndProvider.future);
      ref.read(gameResultProvider.notifier).state = result;

      final resultLabel = result.winner == 'black'
          ? 'win'
          : result.winner == 'white'
              ? 'lose'
              : 'draw';

      ref.read(logCustomEventProvider)(
        eventName: 'ai_game_completed',
        parameters: {
          'result': resultLabel,
          'ai_level': ref.read(aiLevelProvider),
        },
      );

      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed('/game-result', arguments: {
        'result': resultLabel,
        'blackScore': result.blackScore,
        'whiteScore': result.whiteScore,
      });
    } catch (e) {
      _logger.e('❌ Failed to judge game end: $e');
    }
  }

  void _handleResign(BuildContext context, WidgetRef ref) {
    _logger.w('Player resigned');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryDark,
        title: const Text('Resign Game?'),
        content: const Text('Are you sure you want to resign?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(logGameResignationProvider)(
                aiLevel: ref.read(aiLevelProvider),
                boardSize: ref.read(gameBoardStateProvider).boardSize,
                movesCount: ref.read(movesCountProvider),
              );
              // Mark inactive so the board/buttons freeze immediately;
              // startNewGameProvider (via New Game / Play Again) is what
              // actually resets state for the next game.
              ref.read(isGameActiveProvider.notifier).state = false;
              Navigator.of(context).pushReplacementNamed('/game-result', arguments: {
                'result': 'resign',
              });
            },
            child: const Text('Resign'),
          ),
        ],
      ),
    );
  }

  void _handleNewGame(BuildContext context, WidgetRef ref) {
    _logger.i('Starting new game');
    ref.read(startNewGameProvider)();
  }

  /// Build position evaluation widget
  Widget _buildPositionEvaluation(BuildContext context, WidgetRef ref) {
    final evaluation = ref.watch(positionEvaluationProvider);

    return evaluation.when(
      data: (eval) {
        final scoreDiff = eval.scoreDiff;
        final assessment = eval.assessment;
        final blackWinProb = eval.blackWinProb;

        // Determine color based on score difference
        final evalColor = scoreDiff > 0
            ? Colors.blue[400]! // Black winning
            : scoreDiff < 0
                ? Colors.orange[400]! // White winning
                : AppColors.accent; // Even

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: evalColor, width: 1),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[850]?.withOpacity(0.5),
          ),
          child: Column(
            children: [
              // Assessment text
              Text(
                assessment,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: evalColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Score difference display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Score Diff: ${scoreDiff.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '黒勝率: ${(blackWinProb * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Win probability bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: blackWinProb,
                  minHeight: 8,
                  backgroundColor: Colors.white30,
                  valueColor: AlwaysStoppedAnimation(evalColor),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white30, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[850]?.withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.accent),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '形勢を計算中...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red[400]!, width: 1),
          borderRadius: BorderRadius.circular(8),
          color: Colors.red[900]?.withOpacity(0.2),
        ),
        child: Text(
          '形勢評価エラー',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.red[400],
          ),
        ),
      ),
    );
  }

  /// 指し手の一覧。タップすると、その時点までの局面をライブの対局状態を
  /// 変えずにプレビューできる（棋譜観戦の簡易版）。
  Widget _buildMoveList(
    BuildContext context,
    List<({int row, int col, String player})> history,
    int boardSize,
  ) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: history.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final move = history[index];
          final isBlack = move.player == 'black';
          return GestureDetector(
            onTap: () => _showMovePreview(context, history, boardSize, index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.grey700),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isBlack ? Colors.black : Colors.white,
                      border: isBlack ? null : Border.all(color: Colors.grey[400]!),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// `history`の先頭から`upToIndex`（0始まり、その手を含む）までを
  /// GoRulesで再生し、その時点の盤面を求める。ライブの対局状態
  /// （gameBoardStateProvider等）には一切触れない、表示専用の計算。
  List<List<int>> _replayHistoryUpTo(
    List<({int row, int col, String player})> history,
    int boardSize,
    int upToIndex,
  ) {
    var stones = List.generate(boardSize, (_) => List.filled(boardSize, 0));
    int? koRow;
    int? koCol;

    for (var i = 0; i <= upToIndex && i < history.length; i++) {
      final move = history[i];
      final player = move.player == 'black' ? 1 : 2;
      final result = GoRules.applyMove(
        stones: stones,
        boardSize: boardSize,
        row: move.row,
        col: move.col,
        player: player,
        koRow: koRow,
        koCol: koCol,
      );
      if (result == null) continue;
      stones = result.stones;
      koRow = result.koRow;
      koCol = result.koCol;
    }
    return stones;
  }

  void _showMovePreview(
    BuildContext context,
    List<({int row, int col, String player})> history,
    int boardSize,
    int index,
  ) {
    final stones = _replayHistoryUpTo(history, boardSize, index);
    final cellSize = 240 / boardSize;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.primaryDark,
        title: Text('${index + 1}手目の局面', style: const TextStyle(color: Colors.white)),
        content: SizedBox(
          width: 240,
          height: 240,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFC79A5C),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              CustomPaint(
                painter: _GoGridPainter(boardSize: boardSize),
                size: const Size(240, 240),
              ),
              ..._buildPreviewStones(boardSize, cellSize, stones),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('閉じる'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPreviewStones(int boardSize, double cellSize, List<List<int>> stones) {
    final widgets = <Widget>[];
    final radius = cellSize * 0.4;
    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final stone = stones[row][col];
        if (stone == 0) continue;
        final isBlack = stone == 1;
        widgets.add(Positioned(
          left: col * cellSize + cellSize / 2 - radius,
          top: row * cellSize + cellSize / 2 - radius,
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isBlack ? Colors.black : Colors.white,
              border: isBlack ? null : Border.all(color: Colors.grey[400]!),
            ),
          ),
        ));
      }
    }
    return widgets;
  }
}

/// AIの「考え中」演出。墨がにじむような、ゆっくり明滅する円で表現する。
class _AiThinkingIndicator extends StatefulWidget {
  const _AiThinkingIndicator();

  @override
  State<_AiThinkingIndicator> createState() => _AiThinkingIndicatorState();
}

class _AiThinkingIndicatorState extends State<_AiThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static const _phrases = ['思案中…', '次の一手を練っています…', '盤面を読んでいます…'];
  int _phraseIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _cyclePhrase();
  }

  void _cyclePhrase() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _phraseIndex = (_phraseIndex + 1) % _phrases.length);
      _cyclePhrase();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            return Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.25 + 0.35 * t),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.4 + 0.4 * t),
                  width: 1.5,
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 12),
        Text(
          _phrases[_phraseIndex],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.grey300,
          ),
        ),
      ],
    );
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

    // Star points (hoshi) - standard positions per board size, matching
    // real Go boards instead of only having them on 9x9.
    final starPositions = switch (boardSize) {
      9 => const [(2, 2), (2, 6), (4, 4), (6, 2), (6, 6)],
      13 => const [(3, 3), (3, 9), (6, 6), (9, 3), (9, 9)],
      19 => const [
          (3, 3), (3, 9), (3, 15),
          (9, 3), (9, 9), (9, 15),
          (15, 3), (15, 9), (15, 15),
        ],
      _ => const <(int, int)>[],
    };

    if (starPositions.isNotEmpty) {
      final starPaint = Paint()
        ..color = Colors.white60
        ..strokeWidth = 0;

      for (final (row, col) in starPositions) {
        canvas.drawCircle(
          Offset(col * step + step / 2, row * step + step / 2),
          3,
          starPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GoGridPainter oldDelegate) =>
      oldDelegate.boardSize != boardSize;
}

/// 捕獲時の演出。「アゲハマができた瞬間」を気持ちよく見せるための、
/// フェードイン→少し留まる→フェードアウトするだけの軽量な演出。
/// AnimationController/TickerProviderは使わず、Future.delayed +
/// AnimatedOpacity/AnimatedScaleだけで完結させている。
class _CaptureFlash extends StatefulWidget {
  final int count;
  final VoidCallback onDone;

  const _CaptureFlash({super.key, required this.count, required this.onDone});

  @override
  State<_CaptureFlash> createState() => _CaptureFlashState();
}

class _CaptureFlashState extends State<_CaptureFlash> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _visible = false);
    });
    Future.delayed(const Duration(milliseconds: 1300), widget.onDone);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: AnimatedScale(
          scale: _visible ? 1.0 : 0.7,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: Text(
              widget.count > 1 ? '${widget.count}石 捕獲！' : '捕獲！',
              style: TextStyle(
                color: AppColors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
