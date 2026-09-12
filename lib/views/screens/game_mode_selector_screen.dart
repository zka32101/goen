import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// GameModeSelectorScreen - Choose your game mode
///
/// Displays available game modes:
/// - Blitz (5分高速対局)
/// - Correspondence (ターンベース)
/// - Team Play (2vs2チーム戦)
/// - Puzzle Rush (詰碁タイムアタック)
///
/// Selection navigates to the appropriate game screen with settings
class GameModeSelectorScreen extends ConsumerWidget {
  const GameModeSelectorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building GameModeSelectorScreen');

    final gameModes = ref.watch(activeGameModesProvider);
    final selectedMode = ref.watch(selectedGameModeProvider);
    final uiState = ref.watch(gameModeUIProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('ゲームモード選択'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: gameModes.when(
        data: (modes) {
          if (modes.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildModesList(context, ref, modes, selectedMode, uiState);
        },
        loading: () => _buildLoadingState(context),
        error: (error, stackTrace) =>
            _buildErrorState(context, error.toString()),
      ),
    );
  }

  /// Build the game modes list/grid
  Widget _buildModesList(
    BuildContext context,
    WidgetRef ref,
    List<GameMode> modes,
    GameMode? selectedMode,
    GameModeUIState uiState,
  ) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'マッチするモードを選択',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            // Display modes as cards in a grid
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: modes.length,
              itemBuilder: (context, index) {
                final mode = modes[index];
                final isSelected = selectedMode?.id == mode.id;
                return _buildModeCard(
                  context,
                  ref,
                  mode,
                  isSelected,
                  uiState.isLoading,
                );
              },
            ),
            if (uiState.error != null) ...[
              const SizedBox(height: 16),
              _buildErrorSnackbar(uiState.error!),
            ],
          ],
        ),
      ),
    );
  }

  /// Build individual mode card
  Widget _buildModeCard(
    BuildContext context,
    WidgetRef ref,
    GameMode mode,
    bool isSelected,
    bool isLoading,
  ) {
    return GestureDetector(
      onTap: isLoading
          ? null
          : () => _selectMode(context, ref, mode),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.amber[600]! : Colors.grey[700]!,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.amber[900]?.withAlpha(50) : Colors.grey[900],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mode icon & name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModeIcon(mode.type),
                  const SizedBox(height: 8),
                  Text(
                    mode.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              // Mode details
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildModeBadge(mode),
                  const SizedBox(height: 4),
                  if (mode.timeLimit > 0)
                    Text(
                      '${mode.timeLimit}秒',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  if (mode.maxPlayers > 1)
                    Text(
                      '最大${mode.maxPlayers}人',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get icon for game mode type
  Widget _buildModeIcon(GameModeType type) {
    IconData iconData;
    Color color;

    switch (type) {
      case GameModeType.blitz:
        iconData = Icons.lightning_bolt;
        color = Colors.red[400]!;
      case GameModeType.correspondence:
        iconData = Icons.schedule;
        color = Colors.blue[400]!;
      case GameModeType.team:
        iconData = Icons.group;
        color = Colors.green[400]!;
      case GameModeType.puzzleRush:
        iconData = Icons.quiz;
        color = Colors.purple[400]!;
    }

    return Icon(iconData, color: color, size: 28);
  }

  /// Build difficulty/type badge
  Widget _buildModeBadge(GameMode mode) {
    Color badgeColor;
    String difficultyText;

    switch (mode.difficulty) {
      case 'easy':
        badgeColor = Colors.green[700]!;
        difficultyText = '初級';
      case 'medium':
        badgeColor = Colors.yellow[700]!;
        difficultyText = '中級';
      case 'hard':
        badgeColor = Colors.red[700]!;
        difficultyText = '上級';
      case 'master':
        badgeColor = Colors.purple[700]!;
        difficultyText = 'マスター';
      default:
        badgeColor = Colors.grey[600]!;
        difficultyText = mode.difficulty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        difficultyText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Handle mode selection and navigation
  void _selectMode(BuildContext context, WidgetRef ref, GameMode mode) {
    _logger.i('Selected game mode: ${mode.name}');

    // Update UI state
    ref.read(gameModeUIProvider.notifier).selectMode(mode);
    ref.read(selectedGameModeProvider.notifier).state = mode;

    // Navigate based on mode type
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!context.mounted) return;

      switch (mode.type) {
        case GameModeType.blitz:
          _navigateToBlitzGame(context, mode);
        case GameModeType.correspondence:
          _navigateToCorrespondenceGame(context, mode);
        case GameModeType.team:
          _navigateToTeamGame(context, mode);
        case GameModeType.puzzleRush:
          _navigateToPuzzleRush(context, mode);
      }
    });
  }

  void _navigateToBlitzGame(BuildContext context, GameMode mode) {
    _logger.i('Navigating to Blitz game: ${mode.name}');
    // Navigate to appropriate game screen
    // For now: Navigator.of(context).pushNamed('/ai-game', arguments: mode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ブリッツゲーム開始: ${mode.name}')),
    );
  }

  void _navigateToCorrespondenceGame(BuildContext context, GameMode mode) {
    _logger.i('Navigating to Correspondence game: ${mode.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ターンベース対局開始: ${mode.name}')),
    );
  }

  void _navigateToTeamGame(BuildContext context, GameMode mode) {
    _logger.i('Navigating to Team game: ${mode.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('チーム戦開始: ${mode.name}')),
    );
  }

  void _navigateToPuzzleRush(BuildContext context, GameMode mode) {
    _logger.i('Navigating to Puzzle Rush: ${mode.name}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('詰碁ラッシュ開始: ${mode.name}')),
    );
  }

  // ================== UI BUILDERS ==================

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
          const SizedBox(height: 16),
          Text(
            'ゲームモード読込中...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
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
            Icons.sports_esports_outlined,
            size: 48,
            color: Colors.white30,
          ),
          const SizedBox(height: 16),
          Text(
            'ゲームモードがありません',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'エラーが発生しました',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorSnackbar(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[300]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
