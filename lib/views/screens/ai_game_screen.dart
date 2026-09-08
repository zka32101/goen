import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

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

  @override
  void initState() {
    super.initState();
    _logger.i('AIGameScreen initialized');
    _selectedRow = -1;
    _selectedCol = -1;
  }

  @override
  Widget build(BuildContext context) {
    final boardState = ref.watch(gameBoardStateProvider);
    final isGameActive = ref.watch(isGameActiveProvider);
    final aiLevel = ref.watch(aiLevelProvider);
    final movesCount = ref.watch(movesCountProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Text('AI Game - Level $aiLevel'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Game info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Board Size',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '${boardState.boardSize}×${boardState.boardSize}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Moves',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      '$movesCount',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
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
                child: _buildGoBoard(context, ref, boardState),
              ),
            ),
          ),

          // Game controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // AI move status
                if (ref.watch(aiMoveProvider).isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              Colors.amber[600]!,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'AI is thinking...',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Button row
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isGameActive ? () => _handlePass(context) : null,
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
    );
  }

  /// Build the interactive Go board
  Widget _buildGoBoard(
    BuildContext context,
    WidgetRef ref,
    BoardState boardState,
  ) {
    final boardSize = boardState.boardSize;
    final cellSize = 300 / boardSize;

    return GestureDetector(
      onTapDown: (details) {
        if (!ref.read(isGameActiveProvider)) return;

        // Convert tap position to board coordinates
        final localPosition = details.localPosition;
        final row = (localPosition.dy / cellSize).floor();
        final col = (localPosition.dx / cellSize).floor();

        // Validate position
        if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
          _handleBoardTap(context, ref, row, col, boardState);
        }
      },
      child: Container(
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
            // Grid lines
            CustomPaint(
              painter: _GoGridPainter(boardSize: boardSize),
              size: const Size(300, 300),
            ),

            // Stones
            ..._buildStones(boardSize, cellSize, boardState.stones),

            // Legal move indicator
            if (_selectedRow >= 0 && _selectedCol >= 0)
              Positioned(
                left: _selectedCol * cellSize + cellSize / 2 - 8,
                top: _selectedRow * cellSize + cellSize / 2 - 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.amber[600]?.withOpacity(0.5),
                    border: Border.all(
                      color: Colors.amber[600]!,
                      width: 2,
                    ),
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

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final stone = stones[row][col];
        if (stone != 0) {
          // 0 = empty, 1 = black, 2 = white
          final color = stone == 1 ? Colors.black : Colors.white;
          final border = stone == 1 ? null : Border.all(
            color: Colors.black,
            width: 1,
          );

          stoneWidgets.add(
            Positioned(
              left: col * cellSize + cellSize / 2 - 14,
              top: row * cellSize + cellSize / 2 - 14,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: border,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 4,
                      offset: Offset(2, 2),
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
    BoardState boardState,
  ) {
    _logger.i('Board tapped: row=$row, col=$col');

    // Validate move
    final isLegal = ref.read(
      validateMoveProvider((row: row, col: col)),
    );

    if (!isLegal) {
      _logger.w('Illegal move attempt: [$row,$col]');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That position is already occupied'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _logger.i('Legal move: [$row,$col]');

    // Update board and add to history
    final currentBoard = ref.read(gameBoardStateProvider);
    final newStones = List.generate(
      currentBoard.boardSize,
      (i) => i == row
          ? [
              ...currentBoard.stones[i]
                  .sublist(0, col),
              1, // Black stone (player) - 0=empty, 1=black, 2=white
              ...currentBoard.stones[i].sublist(col + 1),
            ]
          : currentBoard.stones[i],
    );

    ref.read(gameBoardStateProvider.notifier).state = BoardState(
      boardSize: currentBoard.boardSize,
      stones: newStones,
      capturedBlack: currentBoard.capturedBlack,
      capturedWhite: currentBoard.capturedWhite,
      isBlackTurn: currentBoard.isBlackTurn,
    );

    // Add move to history
    ref.read(addMoveProvider)(row, col, 'black');

    // Log move
    ref.read(logCustomEventProvider)(
      eventName: 'player_move',
      parameters: {
        'row': row,
        'col': col,
        'move_number': ref.read(movesCountProvider),
      },
    );

    // Request AI move after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ref.refresh(aiMoveProvider);
      }
    });
  }

  void _handlePass(BuildContext context) {
    _logger.i('Player passed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You passed. Game will end if AI passes too.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleResign(BuildContext context, WidgetRef ref) {
    _logger.w('Player resigned');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
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
    ref.invalidate(gameBoardStateProvider);
    ref.invalidate(movesCountProvider);
    ref.invalidate(gameResultProvider);
    ref.read(isGameActiveProvider.notifier).state = true;
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

    // Star points (hoshi) for 9x9 board
    if (boardSize == 9) {
      final starPaint = Paint()
        ..color = Colors.white60
        ..strokeWidth = 0;

      final starPositions = [
        (2, 2),
        (2, 6),
        (4, 4),
        (6, 2),
        (6, 6),
      ];

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
