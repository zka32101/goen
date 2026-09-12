import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// PuzzleRushSettingsScreen
class PuzzleRushSettingsScreen extends ConsumerWidget {
  const PuzzleRushSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building PuzzleRushSettingsScreen');

    final difficulty = ref.watch(puzzleRushDifficultyProvider);
    final isValid = ref.watch(isPuzzleRushSettingsValidProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('詰碁ラッシュ設定'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, '難易度を選択'),
            const SizedBox(height: 16),
            _buildDifficultyCards(ref, difficulty),
            const SizedBox(height: 32),

            _buildSessionInfo(context),
            const SizedBox(height: 32),

            _buildStartButton(context, ref, isValid),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDifficultyCards(WidgetRef ref, String selected) {
    final difficulties = [
      {'label': '初級', 'value': 'easy', 'color': Colors.green[700]},
      {'label': '中級', 'value': 'normal', 'color': Colors.yellow[700]},
      {'label': '上級', 'value': 'hard', 'color': Colors.orange[700]},
      {'label': '最高級', 'value': 'expert', 'color': Colors.red[700]},
    ];

    return Column(
      children: difficulties.map((diff) {
        final isSelected = selected == diff['value'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              ref.read(puzzleRushDifficultyProvider.notifier).state =
                  diff['value'] as String;
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? (diff['color'] as Color?)?.withAlpha(100)
                    : Colors.grey[900],
                border: Border.all(
                  color: isSelected
                      ? (diff['color'] as Color?)!
                      : Colors.grey[700]!,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    diff['label'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: diff['color'] as Color?),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSessionInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'セッション情報',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.timer, color: Colors.amber[600], size: 20),
              const SizedBox(width: 8),
              Text(
                '5分間のセッション',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.whatshot, color: Colors.orange[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'コンボシステム搭載',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.leaderboard, color: Colors.amber[400], size: 20),
              const SizedBox(width: 8),
              Text(
                'グローバルリーダーボード',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context, WidgetRef ref, bool isValid) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isValid ? Colors.amber[600] : Colors.grey[600],
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: isValid
            ? () async {
                final settings = ref.watch(puzzleRushSettingsProvider);
                _logger.i('Starting Puzzle Rush: $settings');

                // Save settings to persistent storage
                await ref.read(savePuzzleRushSettingsProvider(settings).future);

                // Navigate to game screen
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/puzzle-rush',
                    (route) => route.settings.name == '/home',
                    arguments: {'settings': settings},
                  );
                }
              }
            : null,
        child: const Text(
          'ゲーム開始',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
