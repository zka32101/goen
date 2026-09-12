import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// BlitzGameSettingsScreen - Blitz game settings before starting
class BlitzGameSettingsScreen extends ConsumerWidget {
  const BlitzGameSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building BlitzGameSettingsScreen');

    final boardSize = ref.watch(blitzBoardSizeProvider);
    final aiLevel = ref.watch(blitzAiLevelProvider);
    final isValid = ref.watch(isBlitzSettingsValidProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('ブリッツゲーム設定'),
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
            // Board Size Selection
            _buildSectionTitle(context, 'ボードサイズ'),
            const SizedBox(height: 12),
            _buildBoardSizeSelector(ref, boardSize),
            const SizedBox(height: 32),

            // AI Level Selection
            _buildSectionTitle(context, 'AI難易度'),
            const SizedBox(height: 12),
            _buildAILevelSlider(context, ref, aiLevel),
            const SizedBox(height: 32),

            // Start Button
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
                ref.read(blitzBoardSizeProvider.notifier).state = size;
              },
              child: Text(
                '${size}×$size',
                style: TextStyle(
                  color: selected == size ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAILevelSlider(
      BuildContext context, WidgetRef ref, int level) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Slider(
          value: level.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: Colors.amber[600],
          onChanged: (value) {
            ref.read(blitzAiLevelProvider.notifier).state = value.toInt();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('初級', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white54)),
              Text('Level $level', style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white)),
              Text('上級', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white54)),
            ],
          ),
        ),
      ],
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
                final settings = ref.watch(blitzGameSettingsProvider);
                _logger.i('Starting Blitz game with settings: $settings');

                // Save settings to persistent storage
                await ref.read(saveBlitzSettingsProvider(settings).future);

                // Navigate to Blitz game screen with settings
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/blitz-game',
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
