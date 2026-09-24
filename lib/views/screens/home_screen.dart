import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/utils/shoji_transition.dart';
import 'package:goen/views/widgets/ad_banner.dart';
import 'ai_game_screen.dart';
import 'game_mode_selector_screen.dart';
import 'package:goen/config/theme.dart';

final _logger = Logger();

/// HomeScreen - Main hub for all Go learning activities
///
/// Provides access to:
/// - Play AI Game (main path to Aha moment)
/// - Daily Tsume-Go puzzle
/// - Watch kifu library (observation)
/// - Game history
/// - Settings
class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building HomeScreen');

    final currentUser = ref.watch(currentUserProvider);
    final isSubscriptionActive = ref.watch(isSubscriptionActiveProvider);

    return Scaffold(
      backgroundColor: AppColors.sumi,
      bottomNavigationBar: const AdBanner(),
      appBar: AppBar(
        title: const Text('碁縁'),
        centerTitle: true,
        backgroundColor: AppColors.sumi,
        elevation: 0,
        actions: [
          _buildNotificationButton(context, ref, currentUser?.uid),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(context),
            tooltip: 'Settings',
            // Default IconButton constraints render a 40x40 tap target,
            // short of WCAG's 44x44dp minimum.
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User greeting & subscription status
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.washiDim,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentUser?.displayName ?? 'Player',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.washi,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isSubscriptionActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.kin,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Premium',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.sumi,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Main action cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Game Mode Selection - Primary CTA (Phase 58)
                  _buildActionCard(
                    context,
                    title: 'Game Modes',
                    subtitle: 'Choose your game style',
                    icon: Icons.sports_esports,
                    color: AppColors.kin,
                    onTap: () => _navigateToGameModeSelector(context),
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),

                  // Classic AI Game option
                  _buildActionCard(
                    context,
                    title: 'Play AI Game',
                    subtitle: 'Challenge the Go engine',
                    icon: Icons.smart_toy,
                    color: AppColors.kin,
                    onTap: () => _navigateToAiGame(context, ref),
                  ),
                  const SizedBox(height: 16),

                  // Daily Tsume-Go puzzle
                  _buildActionCard(
                    context,
                    title: "Today's Puzzle",
                    subtitle: 'Solve the daily tsume-go',
                    icon: Icons.lightbulb,
                    color: AppColors.aiLight,
                    onTap: () => _navigateToTsumeGo(context),
                  ),
                  const SizedBox(height: 16),

                  // Watch Kifu
                  _buildActionCard(
                    context,
                    title: 'Watch & Learn',
                    subtitle: 'Study historical games',
                    icon: Icons.visibility,
                    color: AppColors.wakatake,
                    onTap: () => _navigateToKifuObservation(context),
                  ),
                  const SizedBox(height: 16),

                  // Game History
                  _buildActionCard(
                    context,
                    title: 'My Games',
                    subtitle: 'Review your past games',
                    icon: Icons.history,
                    color: AppColors.fuji,
                    onTap: () => _navigateToGameHistory(context),
                  ),
                  const SizedBox(height: 16),

                  // 縁 (En) hub
                  _buildActionCard(
                    context,
                    title: '縁',
                    subtitle: '碁を通じたつながりを見る',
                    icon: Icons.favorite,
                    color: Colors.pink[300]!,
                    onTap: () => _navigateToEnHub(context),
                  ),
                  const SizedBox(height: 16),

                  // Tournament
                  _buildActionCard(
                    context,
                    title: 'トーナメント',
                    subtitle: '大会に参加して腕を試そう',
                    icon: Icons.emoji_events,
                    color: AppColors.kin,
                    onTap: () => _navigateToTournament(context),
                  ),
                  const SizedBox(height: 16),

                  // Active PvP games (マッチング/トーナメント経由で始めた対局に戻る)
                  _buildActionCard(
                    context,
                    title: '対局中の対局',
                    subtitle: '進行中のPvP対局に戻る',
                    icon: Icons.people_alt,
                    color: AppColors.shuLight,
                    onTap: () => _navigateToPvpGames(context),
                  ),
                  const SizedBox(height: 16),

                  // How to Play (persistent reference, unlike onboarding)
                  _buildActionCard(
                    context,
                    title: '遊び方',
                    subtitle: 'ルールをいつでも確認できます',
                    icon: Icons.menu_book,
                    color: Colors.teal[300]!,
                    onTap: () => _navigateToHowToPlay(context),
                  ),
                  const SizedBox(height: 16),

                  // Joseki (strategy) library
                  _buildActionCard(
                    context,
                    title: '戦法（定石）',
                    subtitle: '代表的な定石と狙いを学ぶ',
                    icon: Icons.auto_stories,
                    color: Colors.indigo[300]!,
                    onTap: () => _navigateToJoseki(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Game count stats
            if (currentUser != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildStatsSection(context, currentUser),
              ),

            const SizedBox(height: 32),

            // Paywall teaser (for free users after 2 games)
            if (!isSubscriptionActive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildPaywallTeaser(context, ref),
              ),

            const SizedBox(height: 32),

            // Settings Reset Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildSettingsResetButton(context, ref),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Action card widget
  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(
            color: color,
            width: isPrimary ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isPrimary
              ? color.withOpacity(0.15)
              : AppColors.washi.withOpacity(0.05),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.washi,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.washiDim,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: color,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Stats section showing game counts
  Widget _buildStatsSection(BuildContext context, User user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.washi.withOpacity(0.03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              label: 'Games Played',
              value: '${user.gamesPlayedCount}',
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white10,
          ),
          Expanded(
            child: _buildStatItem(
              context,
              label: 'Member Since',
              value: _formatDate(user.createdAt),
            ),
          ),
        ],
      ),
    );
  }

  /// Single stat item
  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.kin,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.washiDim,
          ),
        ),
      ],
    );
  }

  /// Settings reset button
  Widget _buildSettingsResetButton(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.shuLight, width: 1),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.shuDark.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.refresh,
                color: AppColors.shuLight,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'Game Settings',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.washi,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Reset all game settings (board size, difficulty, etc.) to defaults.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.washiDim,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.shuLight,
                // vertical: 10 rendered a ~40dp-tall touch target, short of
                // WCAG's 44dp minimum.
                minimumSize: const Size.fromHeight(44),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: () => _showResetConfirmationDialog(context, ref),
              child: Text(
                'Reset Settings',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.washi,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Paywall teaser for free users
  Widget _buildPaywallTeaser(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.kin, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.kin.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: AppColors.kin,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Unlock Premium',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.washi,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Play unlimited games, get detailed AI analysis, and watch expert kifu commentary.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.washiDim,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kin,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _navigateToPaywall(context, ref),
              child: Text(
                'Upgrade Now',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.sumi,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _navigateToGameModeSelector(BuildContext context) {
    _logger.i('Navigating to Game Mode Selector');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GameModeSelectorScreen(),
      ),
    );
  }

  void _navigateToAiGame(BuildContext context, WidgetRef ref) {
    _logger.i('Navigating to AI Game');
    ref.read(logPaywallTriggeredProvider)(gameNumber: 1);
    // gameBoardStateProvider etc. are plain globals that outlive this
    // screen; without resetting them here, a previous game's finished
    // board would still be showing (see startNewGameProvider's doc).
    ref.read(startNewGameProvider)();
    // 障子が開いて対局へ入るような節目の演出にするため、通常の
    // pushNamedではなくカスタムトランジションで直接pushする。
    Navigator.of(context).push(shojiTransitionRoute(const AIGameScreen()));
  }

  void _navigateToTsumeGo(BuildContext context) {
    _logger.i('Navigating to Tsume-Go');
    Navigator.of(context).pushNamed('/tsume-go');
  }

  void _navigateToKifuObservation(BuildContext context) {
    _logger.i('Navigating to Kifu Observation');
    Navigator.of(context).pushNamed('/kifu-observation');
  }

  void _navigateToGameHistory(BuildContext context) {
    _logger.i('Navigating to Game History');
    Navigator.of(context).pushNamed('/game-history');
  }

  void _navigateToEnHub(BuildContext context) {
    _logger.i('Navigating to En Hub');
    Navigator.of(context).pushNamed('/en-hub');
  }

  void _navigateToTournament(BuildContext context) {
    _logger.i('Navigating to Tournament');
    Navigator.of(context).pushNamed('/tournament');
  }

  void _navigateToPvpGames(BuildContext context) {
    _logger.i('Navigating to active PvP games');
    Navigator.of(context).pushNamed('/pvp-games');
  }

  void _navigateToNotifications(BuildContext context) {
    _logger.i('Navigating to Notifications');
    Navigator.of(context).pushNamed('/notifications');
  }

  void _navigateToHowToPlay(BuildContext context) {
    _logger.i('Navigating to How to Play');
    Navigator.of(context).pushNamed('/how-to-play');
  }

  void _navigateToJoseki(BuildContext context) {
    _logger.i('Navigating to Joseki');
    Navigator.of(context).pushNamed('/joseki');
  }

  /// Notification bell with an unread-count badge
  Widget _buildNotificationButton(BuildContext context, WidgetRef ref, String? uid) {
    // Default IconButton constraints render a 40x40 tap target, short of
    // WCAG's 44x44dp minimum.
    const minTapTarget = BoxConstraints(minWidth: 44, minHeight: 44);

    if (uid == null) {
      return IconButton(
        icon: const Icon(Icons.notifications_none),
        onPressed: () => _navigateToNotifications(context),
        tooltip: 'Notifications',
        constraints: minTapTarget,
      );
    }

    final unreadCountAsync = ref.watch(unreadNotificationCountProvider(uid));
    final unreadCount = unreadCountAsync.valueOrNull ?? 0;

    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () => _navigateToNotifications(context),
          tooltip: 'Notifications',
          constraints: minTapTarget,
        ),
        if (unreadCount > 0)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                unreadCount > 9 ? '9+' : '$unreadCount',
                style: const TextStyle(color: AppColors.washi, fontSize: 9, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _navigateToSettings(BuildContext context) {
    _logger.i('Navigating to Settings');
    Navigator.of(context).pushNamed('/settings');
  }

  void _navigateToPaywall(BuildContext context, WidgetRef ref) {
    _logger.i('Navigating to Paywall');
    ref.read(logPaywallTriggeredProvider)(gameNumber: 3);
    Navigator.of(context).pushNamed('/paywall');
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Settings reset methods
  void _showResetConfirmationDialog(BuildContext context, WidgetRef ref) {
    _logger.i('Showing reset confirmation dialog');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.sumiSurface,
          title: Text(
            'Reset Settings?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.washi,
            ),
          ),
          content: Text(
            'This will reset all game settings (board size, difficulty, player color, etc.) to their default values.\n\nThis action cannot be undone.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.washiDim,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.aiLight),
              ),
            ),
            TextButton(
              onPressed: () async {
                _logger.i('Confirming settings reset');
                Navigator.pop(dialogContext);

                // Show loading indicator
                _showResetProgressDialog(context);

                try {
                  // Reset all settings
                  final result =
                      await ref.read(clearAllSettingsProvider.future);

                  if (context.mounted) {
                    Navigator.pop(context); // Close progress dialog

                    if (result) {
                      _logger.i('Settings reset successfully');
                      _showResetSuccessSnackbar(context);
                    } else {
                      _logger.e('Settings reset failed');
                      _showResetErrorSnackbar(context);
                    }
                  }
                } catch (e) {
                  _logger.e('Error resetting settings: $e');
                  if (context.mounted) {
                    Navigator.pop(context); // Close progress dialog
                    _showResetErrorSnackbar(context);
                  }
                }
              },
              child: Text(
                'Reset',
                style: TextStyle(color: AppColors.shuLight),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showResetProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.sumiSurface,
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.kin),
              ),
              const SizedBox(width: 16),
              Text(
                'Resetting settings...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.washi,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetSuccessSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.wakatake),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'All settings have been reset to defaults',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.washi,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.wakatakeDark,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showResetErrorSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: AppColors.shuLight),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Failed to reset settings',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.washi,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.shuDark,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
