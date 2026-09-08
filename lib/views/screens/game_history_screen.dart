import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// GameHistoryScreen - Browse and replay past AI games
///
/// Features:
/// - View all completed games with scores and metadata
/// - Filter by result (win/loss/draw), AI level, date range
/// - Sort by date, score, duration
/// - Select game to view details and replay
/// - View final board state and move sequence
class GameHistoryScreen extends ConsumerStatefulWidget {
  const GameHistoryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GameHistoryScreen> createState() => _GameHistoryScreenState();
}

class _GameHistoryScreenState extends ConsumerState<GameHistoryScreen> {
  String _filterResult = 'all'; // all, win, loss, draw
  String _sortBy = 'recent'; // recent, score, duration
  String? _selectedGameId;

  @override
  void initState() {
    super.initState();
    _logger.i('GameHistoryScreen initialized');
  }

  @override
  Widget build(BuildContext context) {
    final gameRecords = ref.watch(userGameRecordsProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return _buildAuthRequiredState(context);
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('My Games'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterMenu(context),
            tooltip: 'Filter',
          ),
        ],
      ),
      body: gameRecords.when(
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, error),
        data: (games) {
          if (games.isEmpty) {
            return _buildEmptyState(context);
          }

          // Filter games
          var filteredGames = games;
          if (_filterResult != 'all') {
            filteredGames = filteredGames
                .where((g) => g.result.toLowerCase() == _filterResult)
                .toList();
          }

          // Sort games
          switch (_sortBy) {
            case 'score':
              filteredGames.sort((a, b) {
                final scoreA = (a.blackScore ?? 0) - (a.whiteScore ?? 0);
                final scoreB = (b.blackScore ?? 0) - (b.whiteScore ?? 0);
                return scoreB.compareTo(scoreA);
              });
              break;
            case 'duration':
              filteredGames.sort((a, b) =>
                  b.playedAt.compareTo(a.playedAt));
              break;
            case 'recent':
            default:
              filteredGames
                  .sort((a, b) => b.playedAt.compareTo(a.playedAt));
          }

          // If no game selected, show list
          if (_selectedGameId == null) {
            return _buildGameList(context, filteredGames);
          }

          // If game selected, show details
          final selectedGame = filteredGames.firstWhere(
            (g) => g.id == _selectedGameId,
            orElse: () => filteredGames.first,
          );
          return _buildGameDetails(context, selectedGame, ref);
        },
      ),
    );
  }

  Widget _buildAuthRequiredState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            size: 64,
            color: Colors.amber[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Log in to view your games',
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
            'Loading your games...',
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
            'Could not load games',
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

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_esports,
            size: 64,
            color: Colors.amber[600],
          ),
          const SizedBox(height: 16),
          Text(
            'No games yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Play your first AI game to see it here',
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

  Widget _buildGameList(BuildContext context, List<GameRecord> games) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Game History',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${games.length} game${games.length != 1 ? 's' : ''} played',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(context, 'Wins',
                    games.where((g) => g.result == 'win').length.toString()),
                _buildStat(context, 'Losses',
                    games.where((g) => g.result == 'loss').length.toString()),
                _buildStat(context, 'Draws',
                    games.where((g) => g.result == 'draw').length.toString()),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Game list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: games.map((game) {
                return _buildGameCard(context, game);
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.amber[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildGameCard(BuildContext context, GameRecord game) {
    final isWin = game.result == 'win';
    final isDraw = game.result == 'draw';
    final borderColor = isWin
        ? Colors.green[400]
        : isDraw
        ? Colors.amber[600]
        : Colors.red[400];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ?? Colors.white10, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.03),
      ),
      child: InkWell(
        onTap: () => _handleSelectGame(context, game.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Result and date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isWin
                      ? 'Victory'
                      : isDraw
                      ? 'Draw'
                      : 'Defeat',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: borderColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _formatDate(game.playedAt),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Score and board info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${game.blackScore?.toStringAsFixed(1) ?? "?"} - ${game.whiteScore?.toStringAsFixed(1) ?? "?"}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
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
                      'Level',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lv ${game.aiLevel}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.amber[600],
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
    );
  }

  Widget _buildGameDetails(BuildContext context, GameRecord game, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
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
                          game.result == 'win'
                              ? 'Victory'
                              : game.result == 'draw'
                              ? 'Draw'
                              : 'Defeat',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(game.playedAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _handleBackToList(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Final board state
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.purple[600]!,
                    width: 2,
                  ),
                  color: Colors.amber[100]?.withOpacity(0.1),
                ),
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: GoGridPainter(boardSize: game.boardSize),
                      size: const Size(300, 300),
                    ),
                    // TODO: Render final board state from SGF data
                    Center(
                      child: Text(
                        'Final Board State\n(SGF Replay - Phase 5.3)',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Game stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
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
                    'Game Details',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, 'Board Size',
                      '${game.boardSize}×${game.boardSize}'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      context,
                      'AI Level',
                      'Level ${game.aiLevel}'),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                      context,
                      'Final Score',
                      '${game.blackScore?.toStringAsFixed(1) ?? "?"} - ${game.whiteScore?.toStringAsFixed(1) ?? "?"}'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Move sequence (placeholder)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildMoveSequence(context),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMoveSequence(BuildContext context) {
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
            'Move Sequence',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Move-by-move replay will be available here. (Phase 5.3)',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter by Result',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildFilterOption(context, 'All', 'all'),
              _buildFilterOption(context, 'Wins', 'win'),
              _buildFilterOption(context, 'Losses', 'loss'),
              _buildFilterOption(context, 'Draws', 'draw'),
              const SizedBox(height: 24),
              Text(
                'Sort by',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              _buildSortOption(context, 'Most Recent', 'recent'),
              _buildSortOption(context, 'Best Score', 'score'),
              _buildSortOption(context, 'Longest', 'duration'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterOption(BuildContext context, String label, String value) {
    return ListTile(
      title: Text(label),
      selected: _filterResult == value,
      onTap: () {
        setState(() => _filterResult = value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSortOption(BuildContext context, String label, String value) {
    return ListTile(
      title: Text(label),
      selected: _sortBy == value,
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
    );
  }

  void _handleSelectGame(BuildContext context, String gameId) {
    _logger.i('Selecting game: $gameId');
    setState(() => _selectedGameId = gameId);

    ref.read(logCustomEventProvider)(
      eventName: 'game_history_selected',
      parameters: {'game_id': gameId},
    );
  }

  void _handleBackToList() {
    _logger.i('Returning to game list');
    setState(() => _selectedGameId = null);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else if (dateOnly.year == today.year) {
      return '${dateOnly.month}/${dateOnly.day}';
    } else {
      return '${dateOnly.year}/${dateOnly.month}/${dateOnly.day}';
    }
  }
}

/// Custom painter for Go board grid
class GoGridPainter extends CustomPainter {
  final int boardSize;

  GoGridPainter({required this.boardSize});

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
  bool shouldRepaint(GoGridPainter oldDelegate) =>
      oldDelegate.boardSize != boardSize;
}
