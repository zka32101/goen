import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/index.dart';
import '../../viewmodels/index.dart';
import '../widgets/index.dart';

/// Analytics dashboard screen
class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('ゲーム統計'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: currentUser.when(
        data: (user) {
          if (user == null) {
            return Center(child: Text('ログインしてください'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Summary cards
                _buildSummarySection(ref, user.uid),

                const SizedBox(height: 24),

                // Win rate by board size
                _buildWinRateByBoardSize(ref, user.uid),

                const SizedBox(height: 24),

                // Win rate by AI level
                _buildWinRateByAiLevel(ref, user.uid),

                const SizedBox(height: 24),

                // Achievements
                _buildAchievementsSection(ref, user.uid),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }

  Widget _buildSummarySection(WidgetRef ref, String userId) {
    final statsAsync = ref.watch(userStatisticsProvider(userId));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: statsAsync.when(
        data: (stats) {
          if (stats == null) {
            return Center(
              child: Text('統計データはまだありません',
                  style: TextStyle(color: Colors.grey[400])),
            );
          }

          return Column(
            children: [
              // Main stats grid
              GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    '${stats.totalGamesPlayed}',
                    'ゲーム数',
                    Colors.blue[700]!,
                  ),
                  _buildStatCard(
                    '${stats.totalWins}',
                    '勝利',
                    Colors.green[700]!,
                  ),
                  _buildStatCard(
                    '${stats.winRate.toStringAsFixed(1)}%',
                    '勝率',
                    Colors.amber[700]!,
                  ),
                  _buildStatCard(
                    '${stats.averageGameDuration.toStringAsFixed(0)}分',
                    '平均時間',
                    Colors.purple[700]!,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Favorite info
              Card(
                color: Colors.grey[900],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('好みのモード',
                              style: TextStyle(color: Colors.grey[400],
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(stats.favoriteGameMode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                      Column(
                        children: [
                          Text('好みのレベル',
                              style: TextStyle(color: Colors.grey[400],
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('Lv${stats.favoriteAiLevel}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                      Column(
                        children: [
                          Text('好みのサイズ',
                              style: TextStyle(color: Colors.grey[400],
                                  fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('${stats.favoriteBoardSize}×${stats.favoriteBoardSize}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('エラー: $err')),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinRateByBoardSize(WidgetRef ref, String userId) {
    final winRateAsync = ref.watch(winRateByBoardSizeProvider(userId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: winRateAsync.when(
        data: (winRates) {
          return WinRateBarChartWidget(
            data: winRates,
            title: 'ボードサイズ別勝率',
            xAxisLabel: 'ボードサイズ',
            yAxisLabel: '勝率（%）',
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Card(
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('エラー: $err',
                style: TextStyle(color: Colors.red[600])),
          ),
        ),
      ),
    );
  }

  Widget _buildWinRateByAiLevel(WidgetRef ref, String userId) {
    final winRateAsync = ref.watch(winRateByAiLevelProvider(userId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: winRateAsync.when(
        data: (winRates) {
          // Convert Map<int, double> to Map<String, double>
          final chartData = <String, double>{
            for (var entry in winRates.entries) 'Lv${entry.key}': entry.value
          };

          return WinRateBarChartWidget(
            data: chartData,
            title: 'AI レベル別勝率',
            xAxisLabel: 'AIレベル',
            yAxisLabel: '勝率（%）',
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Card(
          color: Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('エラー: $err',
                style: TextStyle(color: Colors.red[600])),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(WidgetRef ref, String userId) {
    final achievementsAsync = ref.watch(unlockedAchievementsProvider(userId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'アチーブメント',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          achievementsAsync.when(
            data: (achievements) {
              if (achievements.isEmpty) {
                return Card(
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('アチーブメントを獲得してください',
                        style: TextStyle(color: Colors.grey[400])),
                  ),
                );
              }

              return AchievementGridWidget(
                achievements: achievements,
                crossAxisCount: 3,
                onAchievementTap: () {
                  // Future: Show achievement detail dialog
                },
              );
            },
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('エラー: $err'),
          ),
        ],
      ),
    );
  }
}
