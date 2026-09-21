import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/index.dart';
import '../../viewmodels/index.dart';
import 'package:goen/config/theme.dart';

/// Game preset manager screen
class GamePresetManagerScreen extends ConsumerStatefulWidget {
  const GamePresetManagerScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GamePresetManagerScreen> createState() =>
      _GamePresetManagerScreenState();
}

class _GamePresetManagerScreenState
    extends ConsumerState<GamePresetManagerScreen> {
  String _selectedMode = 'blitz';

  @override
  Widget build(BuildContext context) {
    // currentUserProvider is a plain Provider<User?> (not an AsyncValue),
    // so this reads the user directly rather than through AsyncValue.when.
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: const Text('ゲームプリセット'),
        backgroundColor: AppColors.sumiSurface,
        elevation: 0,
      ),
      body: currentUser == null
          ? const Center(child: Text('ログインしてください'))
          : Column(
              children: [
                // Game mode filter
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildModeChip('blitz', 'ブリッツ'),
                        const SizedBox(width: 8),
                        _buildModeChip('correspondence', '対局'),
                        const SizedBox(width: 8),
                        _buildModeChip('team', 'チーム'),
                        const SizedBox(width: 8),
                        _buildModeChip('puzzle', 'パズル'),
                      ],
                    ),
                  ),
                ),

                // Presets list
                Expanded(
                  child: _buildPresetsList(currentUser.uid),
                ),
              ],
            ),
      floatingActionButton: currentUser == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showCreatePresetDialog(context, currentUser.uid),
              backgroundColor: AppColors.kin,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildModeChip(String value, String label) {
    return FilterChip(
      label: Text(label),
      selected: _selectedMode == value,
      onSelected: (selected) {
        setState(() {
          _selectedMode = selected ? value : _selectedMode;
        });
      },
      backgroundColor: AppColors.sumiCard,
      selectedColor: AppColors.kin,
      labelStyle: TextStyle(
        color: _selectedMode == value ? AppColors.sumi : AppColors.washi,
      ),
    );
  }

  Widget _buildPresetsList(String userId) {
    final presetsAsync = ref.watch(presetsByModeProvider((userId, _selectedMode)));

    return presetsAsync.when(
      data: (presets) {
        if (presets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.tune_outlined, size: 64, color: AppColors.washiDim),
                const SizedBox(height: 16),
                Text('このモードのプリセットはありません',
                    style: TextStyle(color: AppColors.washiDim)),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: presets.length,
          itemBuilder: (context, index) {
            final preset = presets[index];
            return _buildPresetTile(context, userId, preset);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
    );
  }

  Widget _buildPresetTile(
    BuildContext context,
    String userId,
    GamePreset preset,
  ) {
    return Card(
      color: AppColors.sumiSurface,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preset.name,
                        style: const TextStyle(
                          color: AppColors.washi,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildBoardBadge(preset.boardSize),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.aiLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Level ${preset.aiLevel}',
                              style: TextStyle(
                                color: AppColors.aiLight,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (preset.handicap != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[900],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '置碁${preset.handicap!.handicapStones}',
                                style: TextStyle(
                                  color: Colors.orange[300],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '使用回数: ${preset.usageCount}',
                        style:
                            TextStyle(color: AppColors.washiDim, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: AppColors.sumiSurface,
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      child: Text('このプリセットでゲーム開始'),
                      value: 'play',
                    ),
                    const PopupMenuItem(
                      child: Text('編集'),
                      value: 'edit',
                    ),
                    const PopupMenuItem(
                      child: Text('複製'),
                      value: 'duplicate',
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      child: Text('削除', style: TextStyle(color: Colors.red)),
                      value: 'delete',
                    ),
                  ],
                  onSelected: (value) {
                    _handlePresetAction(
                        context, userId, preset, value as String);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardBadge(int boardSize) {
    final emoji = _getBoardEmoji(boardSize);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.fuji,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$emoji ${boardSize}×$boardSize',
        style: TextStyle(
          color: AppColors.fuji,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getBoardEmoji(int size) {
    switch (size) {
      case 9:
        return '📦';
      case 13:
        return '📋';
      case 19:
        return '🎴';
      default:
        return '🎲';
    }
  }

  void _showCreatePresetDialog(BuildContext context, String userId) {
    final nameController = TextEditingController();
    int selectedBoardSize = 19;
    int selectedAiLevel = 5;
    int handicapStones = 0; // 0 = 互先（ハンディなし）

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.sumiSurface,
          title: const Text('新しいプリセットを作成'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    hintText: 'プリセット名',
                    hintStyle: TextStyle(color: AppColors.washiDim),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.kin),
                    ),
                  ),
                  style: const TextStyle(color: AppColors.washi),
                ),
                const SizedBox(height: 20),
                Text('盤の大きさ', style: TextStyle(color: AppColors.washiDim, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [9, 13, 19].map((size) {
                    return ChoiceChip(
                      label: Text('$size路盤'),
                      selected: selectedBoardSize == size,
                      onSelected: (_) => setDialogState(() => selectedBoardSize = size),
                      backgroundColor: AppColors.sumiCard,
                      selectedColor: AppColors.kin,
                      labelStyle: TextStyle(
                        color: selectedBoardSize == size ? AppColors.sumi : AppColors.washi,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  'AIレベル: $selectedAiLevel',
                  style: TextStyle(color: AppColors.washiDim, fontSize: 12),
                ),
                Slider(
                  value: selectedAiLevel.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$selectedAiLevel',
                  activeColor: AppColors.kin,
                  onChanged: (value) =>
                      setDialogState(() => selectedAiLevel = value.toInt()),
                ),
                const SizedBox(height: 12),
                Text('置き碁（ハンディキャップ）', style: TextStyle(color: AppColors.washiDim, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [0, 2, 3, 4, 5, 6, 7, 8, 9].map((stones) {
                    final label = stones == 0 ? '互先' : '$stones子';
                    return ChoiceChip(
                      label: Text(label),
                      selected: handicapStones == stones,
                      onSelected: (_) => setDialogState(() => handicapStones = stones),
                      backgroundColor: AppColors.sumiCard,
                      selectedColor: Colors.orange[800],
                      labelStyle: TextStyle(
                        color: handicapStones == stones ? AppColors.sumi : AppColors.washi,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  _createPreset(
                    context,
                    userId,
                    nameController.text,
                    selectedBoardSize,
                    selectedAiLevel,
                    handicapStones > 0
                        ? HandicapSettings(handicapStones: handicapStones)
                        : null,
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.kin),
              child: const Text('作成'),
            ),
          ],
        ),
      ),
    ).then((_) => nameController.dispose());
  }

  void _createPreset(
    BuildContext context,
    String userId,
    String name,
    int boardSize,
    int aiLevel,
    HandicapSettings? handicap,
  ) async {
    final success = await ref.read(
      createGamePresetProvider((
        userId: userId,
        name: name,
        gameMode: _selectedMode,
        boardSize: boardSize,
        aiLevel: aiLevel,
        playerColor: 'black',
        handicap: handicap,
      )).future,
    );

    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'プリセットを作成しました' : 'エラーが発生しました'),
      ),
    );
  }

  void _handlePresetAction(
    BuildContext context,
    String userId,
    GamePreset preset,
    String action,
  ) {
    switch (action) {
      case 'play':
        _showMessage(context, 'ゲーム開始機能は準備中です');
        break;
      case 'edit':
        _showMessage(context, '編集機能は準備中です');
        break;
      case 'duplicate':
        _showMessage(context, '複製機能は準備中です');
        break;
      case 'delete':
        _deletePreset(context, userId, preset.id);
        break;
    }
  }

  void _deletePreset(BuildContext context, String userId, String presetId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.sumiSurface,
        title: const Text('プリセットを削除しますか？'),
        content: const Text('この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref.read(
                deleteGamePresetProvider((userId, presetId)).future,
              );
              if (!context.mounted) return;
              Navigator.pop(context);
              _showMessage(context,
                  success ? '削除しました' : 'エラーが発生しました');
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.shuLight),
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
