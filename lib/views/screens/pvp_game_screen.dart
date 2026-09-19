import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/pvp_game.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// PvP対局画面 - マッチング成立後の2人プレイヤー間リアルタイム対局
class PvpGameScreen extends ConsumerStatefulWidget {
  final String gameId;
  final String uid;

  const PvpGameScreen({Key? key, required this.gameId, required this.uid}) : super(key: key);

  @override
  ConsumerState<PvpGameScreen> createState() => _PvpGameScreenState();
}

class _PvpGameScreenState extends ConsumerState<PvpGameScreen> {
  bool _isSubmittingMove = false;
  bool _resultShown = false;

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(pvpGameStreamProvider(widget.gameId));

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('対局'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: gameAsync.when(
        data: (game) {
          if (game == null) {
            return Center(
              child: Text('対局が見つかりません', style: TextStyle(color: Colors.grey[500])),
            );
          }

          if (game.isFinished) {
            WidgetsBinding.instance.addPostFrameCallback((_) => _showResultDialog(context, game));
          }

          return _buildContent(context, game);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          _logger.e('PvP game stream error: $err');
          return Center(child: Text('エラー: $err', style: const TextStyle(color: Colors.redAccent)));
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PvpGame game) {
    final isMyTurn = game.isActive && game.isTurnOf(widget.uid);
    final myColor = game.playerColorOf(widget.uid);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPlayersHeader(game, isMyTurn),
          const SizedBox(height: 20),
          Center(child: _buildBoard(context, game, isMyTurn)),
          const SizedBox(height: 16),
          Text(
            '${game.movesCount}手目 — 黒${game.capturedWhite}目捕獲 / 白${game.capturedBlack}目捕獲',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(height: 20),
          if (game.isActive && myColor != 0) _buildControls(context, game),
        ],
      ),
    );
  }

  Widget _buildPlayersHeader(PvpGame game, bool isMyTurn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPlayerBadge(game.blackDisplayName, isBlack: true, isTurn: game.isActive && game.isBlackTurn),
        Text('vs', style: TextStyle(color: Colors.grey[600])),
        _buildPlayerBadge(game.whiteDisplayName, isBlack: false, isTurn: game.isActive && !game.isBlackTurn),
      ],
    );
  }

  Widget _buildPlayerBadge(String name, {required bool isBlack, required bool isTurn}) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isBlack ? Colors.black : Colors.white,
            border: isTurn ? Border.all(color: Colors.amber[600]!, width: 3) : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 13)),
        if (isTurn) Text('手番', style: TextStyle(color: Colors.amber[600], fontSize: 11)),
      ],
    );
  }

  Widget _buildBoard(BuildContext context, PvpGame game, bool isMyTurn) {
    final boardSize = game.boardSize;
    const boardPixelSize = 320.0;
    final cellSize = boardPixelSize / boardSize;

    return GestureDetector(
      onTapDown: (details) {
        if (!isMyTurn || _isSubmittingMove) return;
        final row = (details.localPosition.dy / cellSize).floor();
        final col = (details.localPosition.dx / cellSize).floor();
        if (row >= 0 && row < boardSize && col >= 0 && col < boardSize) {
          _handleTap(game, row, col);
        }
      },
      child: Container(
        width: boardPixelSize,
        height: boardPixelSize,
        decoration: BoxDecoration(
          border: Border.all(color: isMyTurn ? Colors.amber[600]! : Colors.grey[700]!, width: 2),
          color: Colors.amber[100]?.withOpacity(0.1),
        ),
        child: Stack(
          children: [
            CustomPaint(
              painter: _PvpGridPainter(boardSize: boardSize),
              size: const Size(boardPixelSize, boardPixelSize),
            ),
            ..._buildStones(boardSize, cellSize, game.stones),
            if (game.lastMoveRow != null && game.lastMoveCol != null)
              Positioned(
                left: game.lastMoveCol! * cellSize + cellSize / 2 - cellSize * 0.12,
                top: game.lastMoveRow! * cellSize + cellSize / 2 - cellSize * 0.12,
                child: Container(
                  width: cellSize * 0.24,
                  height: cellSize * 0.24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStones(int boardSize, double cellSize, List<List<int>> stones) {
    final stoneWidgets = <Widget>[];
    final stoneRadius = cellSize * 0.4;

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final stone = stones[row][col];
        if (stone != 0) {
          final color = stone == 1 ? Colors.black : Colors.white;
          final border = stone == 1 ? null : Border.all(color: Colors.black, width: 1);
          stoneWidgets.add(
            Positioned(
              left: col * cellSize + cellSize / 2 - stoneRadius,
              top: row * cellSize + cellSize / 2 - stoneRadius,
              child: Container(
                width: stoneRadius * 2,
                height: stoneRadius * 2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  border: border,
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(2, 2)),
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

  Widget _buildControls(BuildContext context, PvpGame game) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton.icon(
          onPressed: () => _handlePass(game),
          icon: const Icon(Icons.skip_next),
          label: const Text('パス'),
        ),
        const SizedBox(width: 16),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
          onPressed: () => _confirmResign(context, game),
          icon: const Icon(Icons.flag),
          label: const Text('投了'),
        ),
      ],
    );
  }

  Future<void> _handleTap(PvpGame game, int row, int col) async {
    setState(() => _isSubmittingMove = true);
    try {
      final success = await ref.read(applyPvpMoveProvider)(widget.gameId, widget.uid, row, col);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('その手は打てません')),
        );
      }
    } catch (e) {
      _logger.e('Error applying move: $e');
    } finally {
      if (mounted) setState(() => _isSubmittingMove = false);
    }
  }

  Future<void> _handlePass(PvpGame game) async {
    try {
      await ref.read(passPvpGameProvider)(widget.gameId, widget.uid);
    } catch (e) {
      _logger.e('Error passing: $e');
    }
  }

  Future<void> _confirmResign(BuildContext context, PvpGame game) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('投了しますか？', style: TextStyle(color: Colors.white)),
        content: const Text('この対局に負けとして記録されます。', style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('キャンセル', style: TextStyle(color: Colors.blue[400])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('投了する', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(resignPvpGameProvider)(widget.gameId, widget.uid);
      } catch (e) {
        _logger.e('Error resigning: $e');
      }
    }
  }

  void _showResultDialog(BuildContext context, PvpGame game) {
    if (_resultShown) return;
    _resultShown = true;

    final won = game.winnerUid == widget.uid;
    final isDraw = game.winnerUid == null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          isDraw ? '引き分け' : (won ? 'あなたの勝ちです！' : 'あなたの負けです'),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          game.result == 'resignation' ? '投了による決着' : '目算による決着',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: Text('閉じる', style: TextStyle(color: Colors.amber[600])),
          ),
        ],
      ),
    );
  }
}

class _PvpGridPainter extends CustomPainter {
  final int boardSize;

  _PvpGridPainter({required this.boardSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1;

    final cellSize = size.width / boardSize;

    for (int i = 0; i < boardSize; i++) {
      final offset = cellSize * i + cellSize / 2;
      canvas.drawLine(Offset(offset, cellSize / 2), Offset(offset, size.height - cellSize / 2), paint);
      canvas.drawLine(Offset(cellSize / 2, offset), Offset(size.width - cellSize / 2, offset), paint);
    }
  }

  @override
  bool shouldRepaint(_PvpGridPainter oldDelegate) => oldDelegate.boardSize != boardSize;
}
