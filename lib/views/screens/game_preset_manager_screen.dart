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
    _showPresetDialog(context, userId);
  }

  /// [editing]を渡すと既存プリセットの編集モードになり、モードは変更不可
  /// （一覧がモードでフィルタされているため、変更すると一覧から消えてしまう）。
  void _showPresetDialog(BuildContext context, String userId, {GamePreset? editing}) {
    showDialog(
      context: context,
      builder: (_) => _PresetFormDialog(
        userId: userId,
        gameMode: editing?.gameMode ?? _selectedMode,
        editing: editing,
      ),
    );
  }

  void _duplicatePreset(
    BuildContext context,
    String userId,
    GamePreset preset,
  ) async {
    final success = await ref.read(
      createGamePresetProvider((
        userId: userId,
        name: '${preset.name}のコピー',
        gameMode: preset.gameMode,
        boardSize: preset.boardSize,
        aiLevel: preset.aiLevel,
        playerColor: preset.playerColor,
        handicap: preset.handicap,
      )).future,
    );

    if (success) {
      ref.invalidate(presetsByModeProvider((userId, preset.gameMode)));
    }
    if (!context.mounted) return;
    _showMessage(context, success ? 'プリセットを複製しました' : 'エラーが発生しました');
  }

  void _playPreset(
    BuildContext context,
    String userId,
    GamePreset preset,
  ) async {
    // BlitzGameScreenはボード対局として汎用的にこの3項目(盤サイズ/AIレベル/
    // 対AI)だけで開始できるが、correspondence/teamは対戦相手・チーム構成が
    // プリセットに保存されておらず、puzzleは盤サイズ/AIレベルではなく難易度
    // で開始するため、この一覧からの直接開始はblitzモードのみ対応する。
    if (preset.gameMode != 'blitz') {
      _showMessage(context, 'このモードのプリセットからの開始には対応していません');
      return;
    }

    await ref.read(incrementPresetUsageProvider((userId, preset.id)).future);
    ref.invalidate(presetsByModeProvider((userId, preset.gameMode)));
    if (!context.mounted) return;

    Navigator.pushNamed(
      context,
      '/blitz-game',
      arguments: {
        'settings': BlitzGameSettings(
          boardSize: preset.boardSize.toString(),
          aiLevel: preset.aiLevel,
          opponentType: 'ai',
        ),
      },
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
        _playPreset(context, userId, preset);
        break;
      case 'edit':
        _showPresetDialog(context, userId, editing: preset);
        break;
      case 'duplicate':
        _duplicatePreset(context, userId, preset);
        break;
      case 'delete':
        _deletePreset(context, userId, preset);
        break;
    }
  }

  void _deletePreset(BuildContext context, String userId, GamePreset preset) {
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
                deleteGamePresetProvider((userId, preset.id)).future,
              );
              if (success) {
                ref.invalidate(presetsByModeProvider((userId, preset.gameMode)));
              }
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

/// プリセット作成/編集の入力ダイアログ。[TextEditingController]をこの
/// ウィジェット自身のStateに持たせてdispose()で破棄する — showDialogの
/// 戻り値Futureに`.then(() => controller.dispose())`する方式だと、ダイアログを
/// 閉じるポップ遷移のアニメーション中にTextFieldがまだツリーに残っている
/// うちにcontrollerが先に破棄され、"used after being disposed"で落ちる。
class _PresetFormDialog extends ConsumerStatefulWidget {
  final String userId;
  final String gameMode;
  final GamePreset? editing;

  const _PresetFormDialog({
    required this.userId,
    required this.gameMode,
    this.editing,
  });

  @override
  ConsumerState<_PresetFormDialog> createState() => _PresetFormDialogState();
}

class _PresetFormDialogState extends ConsumerState<_PresetFormDialog> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.editing?.name);
  late int _selectedBoardSize = widget.editing?.boardSize ?? 19;
  late int _selectedAiLevel = widget.editing?.aiLevel ?? 5;
  // 0 = 互先（ハンディなし）
  late int _handicapStones = widget.editing?.handicap?.handicapStones ?? 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.editing;
    return AlertDialog(
      backgroundColor: AppColors.sumiSurface,
      title: Text(editing == null ? '新しいプリセットを作成' : 'プリセットを編集'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
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
                  selected: _selectedBoardSize == size,
                  onSelected: (_) => setState(() => _selectedBoardSize = size),
                  backgroundColor: AppColors.sumiCard,
                  selectedColor: AppColors.kin,
                  labelStyle: TextStyle(
                    color: _selectedBoardSize == size ? AppColors.sumi : AppColors.washi,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'AIレベル: $_selectedAiLevel',
              style: TextStyle(color: AppColors.washiDim, fontSize: 12),
            ),
            Slider(
              value: _selectedAiLevel.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: '$_selectedAiLevel',
              activeColor: AppColors.kin,
              onChanged: (value) => setState(() => _selectedAiLevel = value.toInt()),
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
                  selected: _handicapStones == stones,
                  onSelected: (_) => setState(() => _handicapStones = stones),
                  backgroundColor: AppColors.sumiCard,
                  selectedColor: Colors.orange[800],
                  labelStyle: TextStyle(
                    color: _handicapStones == stones ? AppColors.sumi : AppColors.washi,
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
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.kin),
          child: Text(editing == null ? '作成' : '保存'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    final name = _nameController.text;
    if (name.isEmpty) return;

    final handicap = _handicapStones > 0
        ? HandicapSettings(handicapStones: _handicapStones)
        : null;
    final editing = widget.editing;

    final success = editing == null
        ? await ref.read(createGamePresetProvider((
            userId: widget.userId,
            name: name,
            gameMode: widget.gameMode,
            boardSize: _selectedBoardSize,
            aiLevel: _selectedAiLevel,
            playerColor: 'black',
            handicap: handicap,
          )).future)
        : await ref.read(updateGamePresetProvider((
            userId: widget.userId,
            presetId: editing.id,
            name: name,
            gameMode: widget.gameMode,
            boardSize: _selectedBoardSize,
            aiLevel: _selectedAiLevel,
            playerColor: 'black',
            handicap: handicap,
          )).future);

    if (success) {
      ref.invalidate(presetsByModeProvider((widget.userId, widget.gameMode)));
    }
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? (editing == null ? 'プリセットを作成しました' : 'プリセットを更新しました')
            : 'エラーが発生しました'),
      ),
    );
  }
}
