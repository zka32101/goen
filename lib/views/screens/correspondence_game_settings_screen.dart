import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// CorrespondenceGameSettingsScreen
class CorrespondenceGameSettingsScreen extends ConsumerWidget {
  const CorrespondenceGameSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building CorrespondenceGameSettingsScreen');

    final boardSize = ref.watch(correspondenceBoardSizeProvider);
    final playerColor = ref.watch(correspondencePlayerColorProvider);
    final isValid = ref.watch(isCorrespondenceSettingsValidProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('ターンベース対局設定'),
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
            _buildSectionTitle(context, 'ボードサイズ'),
            const SizedBox(height: 12),
            _buildBoardSizeSelector(ref, boardSize),
            const SizedBox(height: 32),

            _buildSectionTitle(context, '手番'),
            const SizedBox(height: 12),
            _buildColorSelector(ref, playerColor),
            const SizedBox(height: 32),

            _buildSectionTitle(context, '考慮時間'),
            const SizedBox(height: 12),
            _buildConsiderationTimeInfo(context),
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
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBoardSizeSelector(WidgetRef ref, String selected) {
    return Row(
      children: ['9', '13', '19'].map((size) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selected == size ? Colors.amber[600] : Colors.grey[800],
              ),
              onPressed: () {
                ref.read(correspondenceBoardSizeProvider.notifier).state = size;
              },
              child: Text('${size}×$size', style: TextStyle(
                color: selected == size ? Colors.black : Colors.white,
              )),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector(WidgetRef ref, String selected) {
    return Row(
      children: ['black', 'white', 'random'].map((color) {
        final label = color == 'black' ? '黒' : color == 'white' ? '白' : 'ランダム';
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: selected == color ? Colors.amber[600] : Colors.grey[800],
              ),
              onPressed: () {
                ref.read(correspondencePlayerColorProvider.notifier).state = color;
              },
              child: Text(label, style: TextStyle(
                color: selected == color ? Colors.black : Colors.white,
              )),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildConsiderationTimeInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '1手につき24時間の考慮時間があります',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.white70,
        ),
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
                final settings = ref.watch(correspondenceGameSettingsProvider);
                _logger.i('Starting Correspondence game: $settings');

                // Save settings to persistent storage
                await ref.read(saveCorrespondenceSettingsProvider(settings).future);

                // Navigate to game screen
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/correspondence-game',
                    (route) => route.settings.name == '/home',
                    arguments: {'settings': settings},
                  );
                }
              }
            : null,
        child: const Text('ゲーム開始'),
      ),
    );
  }
}
