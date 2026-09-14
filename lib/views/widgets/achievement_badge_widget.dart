import 'package:flutter/material.dart';
import '../../models/extended_game_models.dart';

/// Widget for displaying a single achievement badge
class AchievementBadgeWidget extends StatelessWidget {
  final Achievement achievement;
  final bool showLabel;
  final VoidCallback? onTap;
  final double size;

  const AchievementBadgeWidget({
    Key? key,
    required this.achievement,
    this.showLabel = true,
    this.onTap,
    this.size = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge container
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: achievement.isUnlocked
                  ? Colors.amber[700]?.withOpacity(0.2)
                  : Colors.grey[800]?.withOpacity(0.5),
              border: Border.all(
                color: achievement.isUnlocked
                    ? Colors.amber[600]!
                    : Colors.grey[700]!,
                width: 2,
              ),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Achievement emoji
                  Text(
                    achievement.iconEmoji,
                    style: TextStyle(
                      fontSize: size * 0.5,
                      color: achievement.isUnlocked
                          ? Colors.white
                          : Colors.grey[600],
                    ),
                  ),

                  // Lock icon if not unlocked
                  if (!achievement.isUnlocked)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        width: size * 0.25,
                        height: size * 0.25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[900],
                        ),
                        child: Icon(
                          Icons.lock,
                          size: size * 0.15,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),

                  // Star for unlocked achievement
                  if (achievement.isUnlocked)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: size * 0.25,
                        height: size * 0.25,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.amber[700],
                        ),
                        child: Icon(
                          Icons.star,
                          size: size * 0.15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          if (showLabel) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: size,
              child: Text(
                achievement.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: achievement.isUnlocked
                      ? Colors.white
                      : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget for displaying achievement progress
class AchievementProgressWidget extends StatelessWidget {
  final Achievement achievement;
  final double progress; // 0.0 to 100.0

  const AchievementProgressWidget({
    Key? key,
    required this.achievement,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Badge
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: achievement.isUnlocked
                    ? Colors.amber[700]?.withOpacity(0.2)
                    : Colors.grey[800]?.withOpacity(0.5),
                border: Border.all(
                  color: achievement.isUnlocked
                      ? Colors.amber[600]!
                      : Colors.grey[700]!,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  achievement.iconEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 6,
                      backgroundColor: Colors.grey[800],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress >= 100
                            ? Colors.green[600]!
                            : progress >= 50
                                ? Colors.amber[600]!
                                : Colors.red[600]!,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${progress.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid view for multiple achievements
class AchievementGridWidget extends StatelessWidget {
  final List<Achievement> achievements;
  final int crossAxisCount;
  final VoidCallback? onAchievementTap;

  const AchievementGridWidget({
    Key? key,
    required this.achievements,
    this.crossAxisCount = 3,
    this.onAchievementTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        return AchievementBadgeWidget(
          achievement: achievements[index],
          onTap: onAchievementTap,
        );
      },
    );
  }
}
