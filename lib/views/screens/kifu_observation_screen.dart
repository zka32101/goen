import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/utils/sgf_parser.dart';
import 'package:goen/config/theme.dart';

final _logger = Logger();

/// KifuObservationScreen - Watch and learn from historical Go games
///
/// Features:
/// - Browse kifu library (historical games by famous players)
/// - Select game to watch from list
/// - Move-by-move replay with board visualization
/// - AI commentary on key moves
/// - Track observation progress and completion rate
/// - Filter by player, era, or difficulty
class KifuObservationScreen extends ConsumerStatefulWidget {
  const KifuObservationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<KifuObservationScreen> createState() =>
      _KifuObservationScreenState();
}

class _KifuObservationScreenState extends ConsumerState<KifuObservationScreen> {
  late int _selectedRow;
  late int _selectedCol;
  int _currentMoveIndex = 0;
  String? _selectedGameId;
  int _totalMoves = 0;
  Timer? _autoplayTimer;

  @override
  void initState() {
    super.initState();
    _logger.i('KifuObservationScreen initialized');
    _selectedRow = -1;
    _selectedCol = -1;
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kifuLibrary = ref.watch(kifuLibraryProvider);

    return Scaffold(
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: const Text('Watch & Learn'),
        centerTitle: true,
        backgroundColor: AppColors.sumi,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
            tooltip: 'Learn',
          ),
        ],
      ),
      body: kifuLibrary.when(
        loading: () => _buildLoadingState(context),
        error: (error, stack) => _buildErrorState(context, error),
        data: (games) {
          if (games.isEmpty) {
            return _buildEmptyState(context);
          }

          // If no game selected, show library list
          if (_selectedGameId == null) {
            return _buildGameLibrary(context, games);
          }

          // If game selected, show replay interface
          final selectedGame = games
              .firstWhere((game) => game.id == _selectedGameId, orElse: () => games.first);
          return _buildGameReplay(context, selectedGame, ref);
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
              valueColor: AlwaysStoppedAnimation(AppColors.kin),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading kifu library...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.washiDim,
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
            color: AppColors.shuLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Could not load games',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.washi,
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
            Icons.library_books,
            size: 64,
            color: AppColors.kin,
          ),
          const SizedBox(height: 16),
          Text(
            'No games available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.washi,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for historical games from\nfamous Go players like Honinbo Shusaku',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.washiDim,
            ),
            textAlign: TextAlign.center,
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

  Widget _buildGameLibrary(BuildContext context, List<KifuLibrary> games) {
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
                  'Historical Games',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.washi,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Study games from master players and understand strategic concepts',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.washiDim,
                  ),
                ),
              ],
            ),
          ),

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

  Widget _buildGameCard(BuildContext context, KifuLibrary game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
        color: AppColors.washi.withOpacity(0.03),
      ),
      child: InkWell(
        onTap: () => _handleSelectGame(context, game.id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Game title and players
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.washi,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        game.players.isNotEmpty
                            ? '${game.players[0]} vs ${game.players.length > 1 ? game.players[1] : "?"}'
                            : 'Unknown players',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.washiDim,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.play_circle_outline,
                  size: 32,
                  color: AppColors.kin,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Game info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(context, 'Category', game.category.toString().split('.').last),
                _buildInfoItem(context, 'Source', game.source),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.washiDim,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.washi,
          ),
        ),
      ],
    );
  }

  Widget _buildGameReplay(BuildContext context, KifuLibrary game, WidgetRef ref) {
    final boardSize = parseSgfBoardSize(game.sgfData);
    final moves = parseSgfMoves(game.sgfData);
    _totalMoves = moves.length;
    if (_currentMoveIndex > _totalMoves) {
      _currentMoveIndex = _totalMoves;
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Game header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.washi,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            game.players.isNotEmpty
                                ? game.players.join(' vs ')
                                : 'Unknown players',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.washiDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _handleBackToLibrary(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${game.source} • ${game.category}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.washiDim,
                  ),
                ),
              ],
            ),
          ),

          // Game board
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildReplayBoard(context, boardSize, moves),
            ),
          ),

          const SizedBox(height: 32),

          // Move controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildMoveControls(context, moves.length),
          ),

          const SizedBox(height: 32),

          // Move commentary (placeholder)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildCommentarySection(context),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildReplayBoard(BuildContext context, int boardSize, List<SgfMove> moves) {
    final stones = replaySgfMoves(moves, boardSize, _currentMoveIndex);
    final cellSize = 300 / boardSize;

    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.wakatake,
          width: 2,
        ),
        color: AppColors.kinLight.withOpacity(0.1),
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: _GoGridPainter(boardSize: boardSize),
            size: const Size(300, 300),
          ),
          ..._buildReplayStones(boardSize, cellSize, stones),
        ],
      ),
    );
  }

  List<Widget> _buildReplayStones(int boardSize, double cellSize, List<List<int>> stones) {
    final stoneWidgets = <Widget>[];
    final stoneRadius = cellSize * 0.4;

    for (int row = 0; row < boardSize; row++) {
      for (int col = 0; col < boardSize; col++) {
        final stone = stones[row][col];
        if (stone == 0) continue;
        final isBlack = stone == 1;
        stoneWidgets.add(
          Positioned(
            left: col * cellSize + cellSize / 2 - stoneRadius,
            top: row * cellSize + cellSize / 2 - stoneRadius,
            child: Container(
              width: stoneRadius * 2,
              height: stoneRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isBlack ? null : Border.all(color: AppColors.washiDim, width: 0.5),
                gradient: RadialGradient(
                  center: const Alignment(-0.35, -0.4),
                  radius: 0.9,
                  colors: isBlack
                      ? [AppColors.washiDim, AppColors.sumi]
                      : [AppColors.washi, AppColors.washiDim],
                ),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 2)),
                ],
              ),
            ),
          ),
        );
      }
    }
    return stoneWidgets;
  }

  Widget _buildMoveControls(BuildContext context, int totalMoves) {
    final sliderMax = totalMoves > 0 ? totalMoves : 1;
    final isPlaying = _autoplayTimer != null;

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
            'Move $_currentMoveIndex / $totalMoves',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.washi,
            ),
          ),
          const SizedBox(height: 12),

          // Slider for move progress
          Slider(
            // _currentMoveIndex is kept within [0, _totalMoves] by the guard
            // in _buildGameReplay, so no extra clamping is needed here
            // (num.clamp() would return num, not double, and not typecheck).
            value: _currentMoveIndex.toDouble(),
            min: 0,
            max: sliderMax.toDouble(),
            divisions: sliderMax,
            label: '$_currentMoveIndex',
            activeColor: AppColors.kin,
            onChanged: totalMoves == 0
                ? null
                : (value) {
                    _stopAutoplay();
                    setState(() {
                      _currentMoveIndex = value.toInt();
                    });
                  },
          ),

          const SizedBox(height: 12),

          // Playback controls
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _currentMoveIndex > 0
                      ? () {
                          _stopAutoplay();
                          setState(() => _currentMoveIndex--);
                        }
                      : null,
                  icon: const Icon(Icons.skip_previous),
                  label: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: totalMoves == 0 ? null : () => _handleAutoplay(context, totalMoves),
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(isPlaying ? 'Pause' : 'Play'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kin,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _currentMoveIndex < totalMoves
                      ? () {
                          _stopAutoplay();
                          setState(() => _currentMoveIndex++);
                        }
                      : null,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Next'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentarySection(BuildContext context) {
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
            'Commentary',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.washi,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Move-by-move AI commentary and strategic analysis will appear here as you play through the game.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.washiDim,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sumiSurface,
        title: const Text('About Kifu Observation'),
        content: const Text(
          'Study games from master players like Honinbo Shusaku. Watch move-by-move replay and read AI commentary to understand strategic concepts and improve your game.',
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

  void _handleSelectGame(BuildContext context, String gameId) {
    _logger.i('Selecting game: $gameId');
    setState(() {
      _selectedGameId = gameId;
      _currentMoveIndex = 0;
    });

    ref.read(logCustomEventProvider)(
      eventName: 'kifu_selected',
      parameters: {'game_id': gameId},
    );
  }

  void _handleBackToLibrary() {
    _logger.i('Returning to library');
    _stopAutoplay();

    final currentUser = ref.read(currentUserProvider);
    final gameId = _selectedGameId;
    if (currentUser != null && gameId != null && _totalMoves > 0) {
      final completedRate = _currentMoveIndex / _totalMoves;
      ref
          .read(saveObservationLogProvider)(
            uid: currentUser.uid,
            kifuId: gameId,
            completedRate: completedRate,
          )
          .catchError((e) {
            _logger.e('❌ Failed to save observation log: $e');
            return '';
          });
    }

    setState(() {
      _selectedGameId = null;
      _currentMoveIndex = 0;
      _totalMoves = 0;
    });
  }

  void _handleAutoplay(BuildContext context, int totalMoves) {
    if (_autoplayTimer != null) {
      _stopAutoplay();
      return;
    }

    _logger.i('Starting autoplay from move $_currentMoveIndex');
    _autoplayTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (_currentMoveIndex >= totalMoves) {
        _stopAutoplay();
        return;
      }
      setState(() => _currentMoveIndex++);
    });
    setState(() {});
  }

  void _stopAutoplay() {
    if (_autoplayTimer == null) return;
    _autoplayTimer?.cancel();
    _autoplayTimer = null;
    if (mounted) setState(() {});
  }
}

/// Custom painter for Go board grid
class _GoGridPainter extends CustomPainter {
  final int boardSize;

  _GoGridPainter({required this.boardSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grey500
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

    // Star points (hoshi) for larger boards
    if (boardSize == 19) {
      final starPaint = Paint()
        ..color = Colors.white60
        ..strokeWidth = 0;

      final starPositions = [
        (3, 3), (3, 9), (3, 15),
        (9, 3), (9, 9), (9, 15),
        (15, 3), (15, 9), (15, 15),
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
