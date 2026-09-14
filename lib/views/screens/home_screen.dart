import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

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
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('碁縁'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _navigateToSettings(context),
            tooltip: 'Settings',
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
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currentUser?.displayName ?? 'Player',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
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
                            color: Colors.amber[600],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Premium',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.black,
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
                  // Play AI Game - Primary CTA
                  _buildActionCard(
                    context,
                    title: 'Play AI Game',
                    subtitle: 'Challenge the Go engine',
                    icon: Icons.sports_esports,
                    color: Colors.amber[600]!,
                    onTap: () => _navigateToAiGame(context, ref),
                    isPrimary: true,
                  ),
                  const SizedBox(height: 16),

                  // Daily Tsume-Go puzzle
                  _buildActionCard(
                    context,
                    title: "Today's Puzzle",
                    subtitle: 'Solve the daily tsume-go',
                    icon: Icons.lightbulb,
                    color: Colors.cyan[400]!,
                    onTap: () => _navigateToTsumeGo(context),
                  ),
                  const SizedBox(height: 16),

                  // Watch Kifu
                  _buildActionCard(
                    context,
                    title: 'Watch & Learn',
                    subtitle: 'Study historical games',
                    icon: Icons.visibility,
                    color: Colors.green[600]!,
                    onTap: () => _navigateToKifuObservation(context),
                  ),
                  const SizedBox(height: 16),

                  // Game History
                  _buildActionCard(
                    context,
                    title: 'My Games',
                    subtitle: 'Review your past games',
                    icon: Icons.history,
                    color: Colors.purple[400]!,
                    onTap: () => _navigateToGameHistory(context),
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
              : Colors.white.withOpacity(0.05),
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
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
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
        color: Colors.white.withOpacity(0.03),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            label: 'Games Played',
            value: '${user.gamesPlayedCount}',
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white10,
          ),
          _buildStatItem(
            context,
            label: 'Member Since',
            value: _formatDate(user.createdAt),
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
            color: Colors.amber[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// Paywall teaser for free users
  Widget _buildPaywallTeaser(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.amber[600]!, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.amber[600]?.withOpacity(0.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Unlock Premium',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Play unlimited games, get detailed AI analysis, and watch expert kifu commentary.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _navigateToPaywall(context, ref),
              child: Text(
                'Upgrade Now',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.black,
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
  void _navigateToAiGame(BuildContext context, WidgetRef ref) {
    _logger.i('Navigating to AI Game');
    ref.read(logPaywallTriggeredProvider)(gameNumber: 1);
    Navigator.of(context).pushNamed('/ai-game');
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
}
