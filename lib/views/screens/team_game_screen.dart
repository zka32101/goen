import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// TeamGameScreen - 2vs2 協力戦
///
/// Features:
/// - Team composition display (2 vs 2)
/// - Real-time move synchronization
/// - Team statistics and win/loss tracking
/// - Move history with player attribution
/// - Team-based notifications
/// - Game results with team analysis
class TeamGameScreen extends ConsumerStatefulWidget {
  final List<String> team1Players;
  final List<String> team2Players;
  final int boardSize;

  const TeamGameScreen({
    Key? key,
    required this.team1Players,
    required this.team2Players,
    this.boardSize = 19,
  }) : super(key: key);

  @override
  ConsumerState<TeamGameScreen> createState() => _TeamGameScreenState();
}

class _TeamGameScreenState extends ConsumerState<TeamGameScreen> {
  late int _selectedRow;
  late int _selectedCol;

  @override
  void initState() {
    super.initState();
    _logger.i(
      'TeamGameScreen initialized - '
      'team1: ${widget.team1Players}, team2: ${widget.team2Players}',
    );
    _selectedRow = -1;
    _selectedCol = -1;
  }

  @override
  Widget build(BuildContext context) {
    _logger.i('Building TeamGameScreen');

    final gameAsync = ref.watch(
      startTeamGameProvider(
        (
          team1Players: widget.team1Players,
          team2Players: widget.team2Players,
          boardSize: widget.boardSize,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Team ゲーム'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: gameAsync.when(
        data: (game) => _buildGameBoard(context, ref, game),
        loading: () => _buildLoadingState(context),
        error: (error, stackTrace) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildGameBoard(
    BuildContext context,
    WidgetRef ref,
    TeamGameRecord game,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Team information
          Container(
            color: Colors.black,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Team 1 (White)
                _buildTeamInfo(
                  context,
                  'チーム1 (白)',
                  widget.team1Players,
                  Colors.white,
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                // Team 2 (Black)
                _buildTeamInfo(
                  context,
                  'チーム2 (黒)',
                  widget.team2Players,
                  Colors.black,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Game status
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ゲーム状態',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      Chip(
                        label: Text(
                          game.result == 'draw' ? '進行中' : game.result,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: game.result == 'draw'
                            ? Colors.blue.shade600
                            : Colors.green.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
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
                            '着手数',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            '${game.moveHistory.length}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
            ),
          ),
          const SizedBox(height: 16),

          // Move history by team
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'チーム1の着手',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: game.team1Moves.isEmpty
                      ? Text(
                          'まだ着手なし',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        )
                      : Text(
                          game.team1Moves,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'チーム2の着手',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: game.team2Moves.isEmpty
                      ? Text(
                          'まだ着手なし',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        )
                      : Text(
                          game.team2Moves,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontFamily: 'monospace',
                          ),
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _handleAddMove(context, ref, game),
                  icon: const Icon(Icons.touch_app),
                  label: const Text('着手を提出'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => _handleEndGame(context, ref, game),
                  icon: const Icon(Icons.stop_circle),
                  label: const Text('ゲーム終了'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.red.shade600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(
    BuildContext context,
    String teamName,
    List<String> players,
    Color teamColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: teamColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              teamName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: players.map((player) {
            return Chip(
              label: Text(
                player.length > 8 ? '${player.substring(0, 8)}...' : player,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              backgroundColor: Colors.grey.shade800,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _handleAddMove(
    BuildContext context,
    WidgetRef ref,
    TeamGameRecord game,
  ) async {
    _logger.i('Adding move to Team game: ${game.id}');

    try {
      const move = 'D4'; // Example move
      final playerColor = game.moveHistory.length % 2 == 0 ? 'white' : 'black';

      await ref.read(
        addTeamMoveProvider(
          (
            gameId: game.id,
            move: move,
            playerColor: playerColor,
          ),
        ).future,
      );

      _logger.i('Move added successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('着手 $move を記録しました')),
      );
    } catch (e) {
      _logger.e('Error adding move: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラー: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleEndGame(
    BuildContext context,
    WidgetRef ref,
    TeamGameRecord game,
  ) async {
    _logger.i('Ending Team game: ${game.id}');

    try {
      const result = 'team1_win'; // Example result

      await ref.read(
        endTeamGameProvider(
          (
            gameId: game.id,
            result: result,
            sgfData: '', // Would generate real SGF
          ),
        ).future,
      );

      _logger.i('Game ended successfully');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ゲームを終了しました')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      _logger.e('Error ending game: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('エラー: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'ゲームを準備中...',
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

  @override
  void dispose() {
    _logger.i('TeamGameScreen disposed');
    super.dispose();
  }
}
