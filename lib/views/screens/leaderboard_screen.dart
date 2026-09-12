import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/index.dart';
import '../../viewmodels/index.dart';

/// Global leaderboard screen
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          title: const Text('リーダーボード'),
          backgroundColor: Colors.grey[900],
          elevation: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: '全期間'),
              Tab(text: '月間'),
              Tab(text: '週間'),
              Tab(text: '日間'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLeaderboardList(ref, 'allTime'),
            _buildLeaderboardList(ref, 'monthly'),
            _buildLeaderboardList(ref, 'weekly'),
            _buildLeaderboardList(ref, 'daily'),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(WidgetRef ref, String period) {
    final leaderboardAsync = ref.watch(
      leaderboardStreamProvider((period, 100)),
    );

    return leaderboardAsync.when(
      data: (entries) {
        if (entries.isEmpty) {
          return Center(
            child: Text('ランキングデータはまだありません',
                style: TextStyle(color: Colors.grey[400])),
          );
        }

        return ListView.builder(
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return _buildLeaderboardTile(context, entry, index + 1);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
    );
  }

  Widget _buildLeaderboardTile(
    BuildContext context,
    LeaderboardEntry entry,
    int displayRank,
  ) {
    final medalIcon = _getMedalIcon(displayRank);
    final medalColor = _getMedalColor(displayRank);

    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Medal / Rank
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: medalColor?.withOpacity(0.2),
                border: Border.all(color: medalColor ?? Colors.grey[600]!),
              ),
              child: Center(
                child: medalIcon != null
                    ? Text(medalIcon, style: const TextStyle(fontSize: 24))
                    : Text(
                        '#$displayRank',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),

            // Player info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.trending_up,
                          size: 14, color: Colors.amber[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Rating: ${entry.rating.toStringAsFixed(0)}',
                        style: TextStyle(color: Colors.amber[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${entry.wins}W-${entry.losses}L',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      const SizedBox(width: 12),
                      Text('勝率: ${entry.winRate.toStringAsFixed(1)}%',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),

            // Avatar
            CircleAvatar(
              backgroundColor: Colors.amber[700],
              radius: 24,
              backgroundImage: entry.avatarUrl != null
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              child: entry.avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  String? _getMedalIcon(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return null;
    }
  }

  Color? _getMedalColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.yellow[700];
      case 2:
        return Colors.grey[400];
      case 3:
        return Colors.orange[700];
      default:
        return null;
    }
  }
}
