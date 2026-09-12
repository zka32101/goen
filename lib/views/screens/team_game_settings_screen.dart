import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// TeamGameSettingsScreen
class TeamGameSettingsScreen extends ConsumerWidget {
  const TeamGameSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building TeamGameSettingsScreen');

    final boardSize = ref.watch(teamBoardSizeProvider);
    final team1 = ref.watch(team1PlayersProvider);
    final team2 = ref.watch(team2PlayersProvider);
    final isValid = ref.watch(isTeamSettingsValidProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('チーム戦設定'),
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

            _buildSectionTitle(context, 'チーム1 (白石)'),
            const SizedBox(height: 12),
            _buildTeamInfo(context, team1),
            const SizedBox(height: 32),

            _buildSectionTitle(context, 'チーム2 (黒石)'),
            const SizedBox(height: 12),
            _buildTeamInfo(context, team2),
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
                ref.read(teamBoardSizeProvider.notifier).state = size;
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

  Widget _buildTeamInfo(BuildContext context, List<String> players) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!),
      ),
      child: Column(
        children: [
          Text(
            '${players.length}/2 プレイヤー',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: players.length == 2 ? Colors.green[400] : Colors.yellow[600],
            ),
          ),
          const SizedBox(height: 8),
          if (players.isNotEmpty)
            ...players.map((p) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(p, style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.white70,
              )),
            )).toList()
          else
            Text('プレイヤー未選択', style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white54,
            )),
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
                final settings = ref.watch(teamGameSettingsProvider);
                _logger.i('Starting Team game: $settings');

                // Save settings to persistent storage
                await ref.read(saveTeamSettingsProvider(settings).future);

                // Navigate to game screen
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/team-game',
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
