import 'package:flutter/material.dart';
import '../../models/extended_game_models.dart';

/// Widget for displaying player's current rank
class LeaderboardRankCardWidget extends StatelessWidget {
  final LeaderboardEntry? playerRank;
  final String period;
  final bool isLoading;

  const LeaderboardRankCardWidget({
    Key? key,
    this.playerRank,
    required this.period,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Card(
        color: Colors.grey[900],
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (playerRank == null) {
      return Card(
        color: Colors.grey[900],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'ランキングデータなし',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
        ),
      );
    }

    return Card(
      color: Colors.gradient,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey[900]!,
              Colors.grey[850]!,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: _getRankColor(playerRank!.rank),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'あなたのランク',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[700]?.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.amber[600]!),
                    ),
                    child: Text(
                      _formatPeriod(period),
                      style: TextStyle(
                        color: Colors.amber[300],
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Main rank display
              Row(
                children: [
                  // Rank badge
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getRankColor(playerRank!.rank).withOpacity(0.2),
                      border: Border.all(
                        color: _getRankColor(playerRank!.rank),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getRankMedal(playerRank!.rank),
                            style: const TextStyle(fontSize: 32),
                          ),
                          Text(
                            '#${playerRank!.rank}',
                            style: TextStyle(
                              color: _getRankColor(playerRank!.rank),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Stats
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating
                        Row(
                          children: [
                            Icon(Icons.trending_up,
                                size: 16, color: Colors.amber[600]),
                            const SizedBox(width: 6),
                            Text(
                              'Rating',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              playerRank!.rating.toStringAsFixed(0),
                              style: TextStyle(
                                color: Colors.amber[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Win/Loss
                        Row(
                          children: [
                            Icon(Icons.sports_score,
                                size: 16, color: Colors.green[600]),
                            const SizedBox(width: 6),
                            Text(
                              '勝敗',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${playerRank!.wins}W - ${playerRank!.losses}L',
                              style: TextStyle(
                                color: Colors.green[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Win rate
                        Row(
                          children: [
                            Icon(Icons.percent,
                                size: 16, color: Colors.blue[600]),
                            const SizedBox(width: 6),
                            Text(
                              '勝率',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${playerRank!.winRate.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress bar to next rank
              _buildProgressToNextRank(playerRank!.rank),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressToNextRank(int currentRank) {
    if (currentRank == 1) {
      return Center(
        child: Text(
          '🏆 最上位ランク',
          style: TextStyle(
            color: Colors.amber[600],
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ランク #${currentRank - 1} へ',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 11,
              ),
            ),
            Text(
              '次のランクまで',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.6,
            minHeight: 6,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
              Colors.amber[600]!,
            ),
          ),
        ),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.yellow[700]!;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[700]!;
      default:
        return Colors.blue[600]!;
    }
  }

  String _getRankMedal(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '⭐';
    }
  }

  String _formatPeriod(String period) {
    switch (period) {
      case 'allTime':
        return '全期間';
      case 'monthly':
        return '月間';
      case 'weekly':
        return '週間';
      case 'daily':
        return '日間';
      default:
        return period;
    }
  }
}

/// Compact rank card for player summary
class CompactRankCardWidget extends StatelessWidget {
  final LeaderboardEntry entry;
  final VoidCallback? onTap;

  const CompactRankCardWidget({
    Key? key,
    required this.entry,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Rank number
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber[700]?.withOpacity(0.2),
                border: Border.all(color: Colors.amber[600]!),
              ),
              child: Center(
                child: Text(
                  '#${entry.rank}',
                  style: TextStyle(
                    color: Colors.amber[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Rating
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${entry.rating.toStringAsFixed(0)} • ${entry.winRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
