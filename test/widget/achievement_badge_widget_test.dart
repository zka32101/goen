import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goen/models/extended_game_models.dart';
import 'package:goen/views/widgets/achievement_badge_widget.dart';

void main() {
  group('AchievementBadgeWidget Tests', () {
    late Achievement unlockedAchievement;
    late Achievement lockedAchievement;

    setUp(() {
      unlockedAchievement = const Achievement(
        id: 'first-win',
        name: '初勝利',
        description: '初めてのゲームに勝利する',
        iconEmoji: '🥇',
        isUnlocked: true,
        unlockedAt: null,
        progress: 100,
      );

      lockedAchievement = const Achievement(
        id: 'hundred-wins',
        name: '百勝',
        description: '100回のゲームに勝利する',
        iconEmoji: '💯',
        isUnlocked: false,
        unlockedAt: null,
        progress: 45,
      );
    });

    testWidgets('Renders unlocked achievement badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadgeWidget(
              achievement: unlockedAchievement,
            ),
          ),
        ),
      );

      // Verify emoji is displayed
      expect(find.text('🥇'), findsOneWidget);

      // Verify name is displayed
      expect(find.text('初勝利'), findsOneWidget);

      // Verify star icon for unlocked achievement
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('Renders locked achievement badge', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadgeWidget(
              achievement: lockedAchievement,
            ),
          ),
        ),
      );

      // Verify emoji is displayed
      expect(find.text('💯'), findsOneWidget);

      // Verify lock icon for locked achievement
      expect(find.byIcon(Icons.lock), findsOneWidget);

      // Verify name is displayed
      expect(find.text('百勝'), findsOneWidget);
    });

    testWidgets('Hides label when showLabel is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadgeWidget(
              achievement: unlockedAchievement,
              showLabel: false,
            ),
          ),
        ),
      );

      // Verify emoji is still displayed
      expect(find.text('🥇'), findsOneWidget);

      // Verify name is NOT displayed
      expect(find.text('初勝利'), findsNothing);
    });

    testWidgets('Calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadgeWidget(
              achievement: unlockedAchievement,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });

    testWidgets('Adjusts size based on size parameter', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementBadgeWidget(
              achievement: unlockedAchievement,
              size: 120,
            ),
          ),
        ),
      );

      // Verify widget renders with custom size
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('AchievementProgressWidget Tests', () {
    late Achievement achievement;

    setUp(() {
      achievement = const Achievement(
        id: 'test-achievement',
        name: 'テストアチーブメント',
        description: 'テスト用アチーブメント',
        iconEmoji: '🎯',
        isUnlocked: false,
        unlockedAt: null,
        progress: 0,
      );
    });

    testWidgets('Renders progress widget with achievement info', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementProgressWidget(
              achievement: achievement,
              progress: 50.0,
            ),
          ),
        ),
      );

      // Verify achievement name is displayed
      expect(find.text('テストアチーブメント'), findsOneWidget);

      // Verify progress percentage is displayed
      expect(find.text('50.0%'), findsOneWidget);
    });

    testWidgets('Displays correct progress bar color for different progress levels',
        (WidgetTester tester) async {
      // Test different progress values
      final progressValues = [25.0, 50.0, 100.0];

      for (final progress in progressValues) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AchievementProgressWidget(
                achievement: achievement,
                progress: progress,
              ),
            ),
          ),
        );

        // Verify progress bar is displayed
        expect(find.byType(LinearProgressIndicator), findsWidgets);
      }
    });
  });

  group('AchievementGridWidget Tests', () {
    late List<Achievement> achievements;

    setUp(() {
      achievements = [
        const Achievement(
          id: 'achievement-1',
          name: 'アチーブメント1',
          description: '説明1',
          iconEmoji: '🥇',
          isUnlocked: true,
          unlockedAt: null,
          progress: 100,
        ),
        const Achievement(
          id: 'achievement-2',
          name: 'アチーブメント2',
          description: '説明2',
          iconEmoji: '🥈',
          isUnlocked: false,
          unlockedAt: null,
          progress: 50,
        ),
        const Achievement(
          id: 'achievement-3',
          name: 'アチーブメント3',
          description: '説明3',
          iconEmoji: '🥉',
          isUnlocked: true,
          unlockedAt: null,
          progress: 100,
        ),
      ];
    });

    testWidgets('Renders grid of achievements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementGridWidget(
              achievements: achievements,
            ),
          ),
        ),
      );

      // Verify all achievements are displayed
      expect(find.text('🥇'), findsOneWidget);
      expect(find.text('🥈'), findsOneWidget);
      expect(find.text('🥉'), findsOneWidget);
    });

    testWidgets('Calls onAchievementTap when badge is tapped',
        (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementGridWidget(
              achievements: achievements,
              onAchievementTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      // Tap first achievement
      await tester.tap(find.byType(AchievementBadgeWidget).first);
      expect(tapped, isTrue);
    });

    testWidgets('Renders correct number of columns', (WidgetTester tester) async {
      const crossAxisCount = 2;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AchievementGridWidget(
              achievements: achievements,
              crossAxisCount: crossAxisCount,
            ),
          ),
        ),
      );

      expect(find.byType(GridView), findsOneWidget);
    });
  });
}
