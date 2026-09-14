import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/index.dart';
import '../../viewmodels/index.dart';

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
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('ゲームプリセット'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text('ログインしてください'));
          }

          return Column(
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
                child: _buildPresetsList(user.uid),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            _showCreatePresetDialog(context, currentUser.value?.uid ?? ''),
        backgroundColor: Colors.amber[700],
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
      backgroundColor: Colors.grey[800],
      selectedColor: Colors.amber[700],
      labelStyle: TextStyle(
        color: _selectedMode == value ? Colors.black : Colors.white,
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
                Icon(Icons.tune_outlined, size: 64, color: Colors.grey[600]),
                const SizedBox(height: 16),
                Text('このモードのプリセットはありません',
                    style: TextStyle(color: Colors.grey[400])),
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
      color: Colors.grey[900],
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
                          color: Colors.white,
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
                              color: Colors.blue[900],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Level ${preset.aiLevel}',
                              style: const TextStyle(
                                color: Colors.blue[300],
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
                                style: const TextStyle(
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
                            TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton(
                  color: Colors.grey[900],
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('このプリセットでゲーム開始'),
                      value: 'play',
                    ),
                    PopupMenuItem(
                      child: const Text('編集'),
                      value: 'edit',
                    ),
                    PopupMenuItem(
                      child: const Text('複製'),
                      value: 'duplicate',
                    ),
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      child: const Text('削除', style: TextStyle(color: Colors.red)),
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
        color: Colors.purple[900],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$emoji ${boardSize}×$boardSize',
        style: const TextStyle(
          color: Colors.purple[300],
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

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('新しいプリセットを作成'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'プリセット名',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber[700]!),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              // TODO: Add board size, AI level, handicap options
              Text('詳細設定は後で実装予定',
                  style: TextStyle(color: Colors.grey[500])),
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
                _createPreset(context, userId, nameController.text,
                    selectedBoardSize, selectedAiLevel);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
            child: const Text('作成'),
          ),
        ],
      ),
    );
  }

  void _createPreset(
    BuildContext context,
    String userId,
    String name,
    int boardSize,
    int aiLevel,
  ) async {
    final success = await ref.read(
      createGamePresetProvider((
        userId: userId,
        name: name,
        gameMode: _selectedMode,
        boardSize: boardSize,
        aiLevel: aiLevel,
        playerColor: 'black',
        handicap: null,
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
        backgroundColor: Colors.grey[900],
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
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
