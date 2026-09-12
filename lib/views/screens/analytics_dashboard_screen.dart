import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/index.dart';
import '../../viewmodels/index.dart';

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
      child: Card(
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ボードサイズ別勝率',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              winRateAsync.when(
                data: (winRates) {
                  if (winRates.isEmpty) {
                    return Text('データなし',
                        style: TextStyle(color: Colors.grey[400]));
                  }

                  return Column(
                    children: winRates.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                entry.key,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: entry.value / 100,
                                  minHeight: 24,
                                  backgroundColor: Colors.grey[800],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    entry.value >= 60
                                        ? Colors.green[600]!
                                        : entry.value >= 40
                                            ? Colors.amber[600]!
                                            : Colors.red[600]!,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${entry.value.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('エラー: $err'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinRateByAiLevel(WidgetRef ref, String userId) {
    final winRateAsync = ref.watch(winRateByAiLevelProvider(userId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI レベル別勝率',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              winRateAsync.when(
                data: (winRates) {
                  if (winRates.isEmpty) {
                    return Text('データなし',
                        style: TextStyle(color: Colors.grey[400]));
                  }

                  return Column(
                    children: winRates.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final level = entry.value.key;
                      final winRate = entry.value.value;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 60,
                              child: Text(
                                'Lv $level',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: winRate / 100,
                                  minHeight: 24,
                                  backgroundColor: Colors.grey[800],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    winRate >= 60
                                        ? Colors.green[600]!
                                        : winRate >= 40
                                            ? Colors.amber[600]!
                                            : Colors.red[600]!,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${winRate.toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('エラー: $err'),
              ),
            ],
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

              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return _buildAchievementBadge(achievement);
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

  Widget _buildAchievementBadge(Achievement achievement) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              achievement.iconEmoji,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
