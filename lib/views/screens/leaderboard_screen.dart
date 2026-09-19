import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../models/index.dart';
import '../../viewmodels/index.dart';
import '../../utils/go_rank.dart';

final _logger = Logger();

/// Global leaderboard screen
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(leaderboardPeriodProvider);
    final type = ref.watch(leaderboardTypeProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('リーダーボード'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildPeriodSelector(ref, period),
          _buildTypeSelector(ref, type),
          Expanded(
            child: _buildLeaderboardList(ref, period, type),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(WidgetRef ref, LeaderboardPeriod current) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: LeaderboardPeriod.values
              .map((period) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(period.getDisplayName()),
                      selected: current == period,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(leaderboardPeriodProvider.notifier).state =
                              period;
                        }
                      },
                      selectedColor: Colors.amber[600],
                      backgroundColor: Colors.grey[800],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTypeSelector(WidgetRef ref, LeaderboardType current) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: LeaderboardType.values
              .map((type) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(type.getDisplayName()),
                      selected: current == type,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(leaderboardTypeProvider.notifier).state =
                              type;
                        }
                      },
                      selectedColor: Colors.amber[600],
                      backgroundColor: Colors.grey[800],
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(
    WidgetRef ref,
    LeaderboardPeriod period,
    LeaderboardType type,
  ) {
    final leaderboardAsync = ref.watch(
      leaderboardProvider((period: period, type: type, limit: 100)),
    );

    return leaderboardAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Text(
              'ランキングデータはまだありません',
              style: TextStyle(color: Colors.grey[400]),
            ),
          );
        }

        return ListView.separated(
          separatorBuilder: (context, index) =>
              Divider(color: Colors.grey[800], height: 1),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildRankCard(entry);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) {
        _logger.e('Leaderboard error: $err');
        return Center(child: Text('エラー: $err'));
      },
    );
  }

  Widget _buildRankCard(LeaderboardEntry entry) {
    final medalColor = _getMedalColor(entry.rank);
    final medalEmoji = _getMedalEmoji(entry.rank);

    return Container(
      color: entry.rank <= 3 ? Colors.grey[850] : Colors.transparent,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: medalColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              medalEmoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          entry.displayName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          'レート: ${entry.rating} (${formatGoRank(entry.rating)}) | ${entry.gamesPlayed}試合 (勝: ${entry.wins})',
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.rank}位',
              style: TextStyle(
                color: Colors.amber[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '勝率: ${(entry.winRate * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.grey[400], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.yellow[700]!;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  String _getMedalEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '${rank}';
    }
  }
}
