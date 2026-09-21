import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goen/config/theme.dart';

/// Global leaderboard screen
class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.sumi,
        appBar: AppBar(
          title: const Text('リーダーボード'),
          backgroundColor: AppColors.sumiSurface,
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
            _buildPlaceholder('全期間ランキング'),
            _buildPlaceholder('月間ランキング'),
            _buildPlaceholder('週間ランキング'),
            _buildPlaceholder('日間ランキング'),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String title) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 64, color: AppColors.kin),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: AppColors.washi, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'ランキングデータはまだありません',
            style: TextStyle(color: AppColors.washiDim),
          ),
        ],
      ),
    );
  }
}
