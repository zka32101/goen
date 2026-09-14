import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// CorrespondenceGameScreen - 手紙型ターン制対局
///
/// Features:
/// - Ongoing games list with status
/// - Turn-by-turn move submission
/// - Current player color indicator
/// - Opponent notification system
/// - Game history with timestamps
/// - Game abandonment option
class CorrespondenceGameScreen extends ConsumerWidget {
  final String uid;
  final String opponentUid;
  final int boardSize;

  const CorrespondenceGameScreen({
    Key? key,
    required this.uid,
    required this.opponentUid,
    this.boardSize = 19,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building CorrespondenceGameScreen');

    final gamesAsync = ref.watch(
      userCorrespondenceGamesProvider(uid),
    );
    final pendingMovesAsync = ref.watch(
      pendingMoveCountProvider(uid),
    );

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('手紙型対局'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Pending moves badge
            pendingMovesAsync.when(
              data: (count) {
                if (count == 0) {
                  return const SizedBox.shrink();
                }
                return Container(
                  color: Colors.amber.shade700,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        '待機中の着手: $count',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, _) {
                _logger.e('Error fetching pending moves: $error');
                return const SizedBox.shrink();
              },
            ),

            // Games list
            gamesAsync.when(
              data: (games) {
                if (games.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildGamesList(context, ref, games);
              },
              loading: () => _buildLoadingState(context),
              error: (error, stackTrace) =>
                  _buildErrorState(context, error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesList(
    BuildContext context,
    WidgetRef ref,
    List<CorrespondenceGameRecord> games,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ゲーム一覧',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...games.map((game) => _buildGameCard(context, ref, game)),
        ],
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    WidgetRef ref,
    CorrespondenceGameRecord game,
  ) {
    final isMyTurn = game.currentPlayerColor == 'black';
    final statusColor = isMyTurn ? Colors.green.shade600 : Colors.orange.shade600;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(
          color: statusColor,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
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
                    'ゲーム ID',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    game.id.substring(0, 8),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Chip(
                label: Text(
                  game.status == 'active' ? 'アクティブ' : '完了',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: game.status == 'active'
                    ? Colors.blue.shade600
                    : Colors.grey.shade700,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ボードサイズ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '${game.boardSize}×${game.boardSize}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'ターン数',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    '${game.currentTurnNumber}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Current player
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  game.currentPlayerColor == 'black'
                      ? Icons.circle
                      : Icons.circle_outlined,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isMyTurn ? 'あなたの番です' : '相手の番を待機中',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Last move info
          if (game.moveHistory.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '最後の着手',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    game.moveHistory.last,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: game.status == 'active' && isMyTurn
                      ? () => _handleAddMove(context, ref, game)
                      : null,
                  icon: const Icon(Icons.touch_app),
                  label: const Text('着手'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: Colors.blue.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: game.status == 'active'
                      ? () => _handleAbandonGame(context, ref, game)
                      : null,
                  icon: const Icon(Icons.close),
                  label: const Text('放棄'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    backgroundColor: Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAddMove(
    BuildContext context,
    WidgetRef ref,
    CorrespondenceGameRecord game,
  ) async {
    _logger.i('Adding move to Correspondence game: ${game.id}');

    try {
      const move = 'D4'; // Example move
      final playerColor =
          game.currentPlayerColor == 'black' ? 'white' : 'black';

      await ref.read(
        addCorrespondenceMoveProvider(
          (
            gameId: game.id,
            move: move,
            playerColor: playerColor,
          ),
        ).future,
      );

      _logger.i('Move added successfully');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('着手 $move を記録しました')),
        );
      }
    } catch (e) {
      _logger.e('Error adding move: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleAbandonGame(
    BuildContext context,
    WidgetRef ref,
    CorrespondenceGameRecord game,
  ) async {
    _logger.i('Abandoning Correspondence game: ${game.id}');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        title: const Text('ゲームを放棄しますか？'),
        content: const Text('この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('放棄'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(
        abandonCorrespondenceGameProvider(game.id).future,
      );

      _logger.i('Game abandoned successfully');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ゲームを放棄しました')),
        );
      }
    } catch (e) {
      _logger.e('Error abandoning game: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('エラー: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mail_outline,
            color: Colors.white54,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            '手紙型対局がありません',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.add),
            label: const Text('新しいゲームを開始'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'ゲーム一覧を読み込み中...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 48),
          const SizedBox(height: 16),
          Text(
            'エラーが発生しました',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('戻る'),
          ),
        ],
      ),
    );
  }
}
