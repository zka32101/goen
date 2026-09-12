import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/index.dart';
import '../../viewmodels/index.dart';
import '../widgets/index.dart';

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

        return ListView.separated(
          separatorBuilder: (context, index) =>
              Divider(color: Colors.grey[800], height: 1),
          itemCount: entries.length,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: CompactRankCardWidget(
                entry: entry,
                onTap: () {
                  // Future: Navigate to player profile
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('エラー: $err')),
    );
  }

}
