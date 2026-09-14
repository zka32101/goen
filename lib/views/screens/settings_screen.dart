import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/views/widgets/index.dart';

final _logger = Logger();

/// SettingsScreen - User preferences and account management
///
/// Features:
/// - Display and edit user profile (name, email)
/// - Board size preference (7x7, 9x9, 13x13, 19x19)
/// - AI difficulty preference slider
/// - Subscription status and upgrade option
/// - Privacy and data settings
/// - Account management (sign out, delete account)
/// - App information and credits
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _displayNameController;
  int _selectedBoardSize = 9;
  int _selectedAiLevel = 5;

  @override
  void initState() {
    super.initState();
    _logger.i('SettingsScreen initialized');
    _displayNameController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isSubscriptionActive = ref.watch(isSubscriptionActiveProvider);

    if (currentUser == null) {
      return _buildAuthRequiredState(context);
    }

    // Initialize name controller with current user name
    if (_displayNameController.text.isEmpty && currentUser.displayName != null) {
      _displayNameController.text = currentUser.displayName ?? '';
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile section
            _buildSection(
              context,
              'Profile',
              _buildProfileSettings(context, currentUser),
            ),

            // Subscription section
            _buildSection(
              context,
              'Subscription',
              _buildSubscriptionSettings(context, isSubscriptionActive),
            ),

            // Preferences section
            _buildSection(
              context,
              'Preferences',
              _buildPreferenceSettings(context),
            ),

            // Privacy section
            _buildSection(
              context,
              'Privacy & Data',
              _buildPrivacySettings(context),
            ),

            // Account section
            _buildSection(
              context,
              'Account',
              _buildAccountSettings(context, ref),
            ),

            // App info section
            _buildSection(
              context,
              'About',
              _buildAppInfo(context),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.amber[600],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white10),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withOpacity(0.03),
            ),
            child: child,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileSettings(BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Display Name',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _displayNameController,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: Colors.white30),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Colors.white10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.amber[600]!),
            ),
          ),
          onChanged: (value) {
            _logger.i('Display name changed: $value');
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Email',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white10),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            user.email,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _handleShareProfile(context, user),
            child: const Text('Share Profile'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _handleSaveProfile(context),
            child: const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionSettings(BuildContext context, bool isActive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Subscription',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isActive ? Colors.green[400] : Colors.white70,
                  ),
                ),
              ],
            ),
            if (!isActive)
              Icon(
                Icons.lock,
                color: Colors.amber[600],
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          isActive
              ? 'You have access to all premium features including unlimited games, historical kifu library, and advanced statistics.'
              : 'Upgrade to premium to unlock unlimited games, historical kifu library, and advanced statistics.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 16),
        if (!isActive)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleUpgrade(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
              ),
              child: Text(
                'Upgrade to Premium',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPreferenceSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferred Board Size',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [7, 9, 13, 19].map((size) {
            return ChoiceChip(
              label: Text('${size}×$size'),
              selected: _selectedBoardSize == size,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedBoardSize = size);
                  _logger.i('Board size preference changed to $size');
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text(
          'Default AI Difficulty',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Slider(
              value: _selectedAiLevel.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              label: 'Level $_selectedAiLevel',
              activeColor: Colors.amber[600],
              onChanged: (value) {
                setState(() => _selectedAiLevel = value.toInt());
                _logger.i('AI difficulty preference changed to $value');
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Beginner',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Level $_selectedAiLevel',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.amber[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Expert',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPrivacySettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSettingSwitch(
          context,
          'Share game statistics',
          'Allow your win rate to be visible in leaderboards',
          true,
          (value) => _logger.i('Statistics sharing: $value'),
        ),
        const SizedBox(height: 16),
        _buildSettingSwitch(
          context,
          'Anonymous mode',
          'Hide your profile name in replays',
          false,
          (value) => _logger.i('Anonymous mode: $value'),
        ),
        const SizedBox(height: 16),
        Text(
          'Data & Privacy',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We respect your privacy. Your game data is stored securely and never sold to third parties. Read our privacy policy for more details.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => _handleOpenPrivacyPolicy(context),
          child: const Text('Read Privacy Policy'),
        ),
      ],
    );
  }

  Widget _buildSettingSwitch(
    BuildContext context,
    String title,
    String subtitle,
    bool initialValue,
    Function(bool) onChanged,
  ) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: initialValue,
              onChanged: (value) {
                setState(() {});
                onChanged(value);
              },
              activeColor: Colors.amber[600],
            ),
          ],
        );
      },
    );
  }

  Widget _buildAccountSettings(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _handleSignOut(context, ref),
            child: const Text('Sign Out'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _handleDeleteAccount(context, ref),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.red[400]!),
            ),
            child: Text(
              'Delete Account',
              style: TextStyle(color: Colors.red[400]),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Permanently delete your account and all associated data.',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.red[300],
          ),
        ),
      ],
    );
  }

  Widget _buildAppInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(context, 'App Name', 'GoEn - 碁縁'),
        const SizedBox(height: 12),
        _buildInfoRow(context, 'Version', '1.0.0'),
        const SizedBox(height: 12),
        _buildInfoRow(context, 'Build', '2026.09.01'),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => _handleOpenTerms(context),
          child: const Text('Terms of Service'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _handleOpenPrivacyPolicy(context),
          child: const Text('Privacy Policy'),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => _handleOpenCredits(context),
          child: const Text('Credits & Attribution'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAuthRequiredState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock,
            size: 64,
            color: Colors.amber[600],
          ),
          const SizedBox(height: 16),
          Text(
            'Log in to access settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  void _handleSaveProfile(BuildContext context) {
    _logger.i('Saving profile changes');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated!')),
    );
  }

  void _handleShareProfile(BuildContext context, User user) {
    _logger.i('Opening share dialog for user profile');
    final profileShareData = ProfileShareData(
      userId: user.uid,
      displayName: user.displayName ?? 'GoEn Player',
      totalGamesPlayed: 0, // TODO: Fetch from gameProvider
      winCount: 0, // TODO: Fetch from gameProvider
      currentPuzzleStreak: 0, // TODO: Fetch from puzzleProvider
      totalPuzzlesSolved: 0, // TODO: Fetch from puzzleProvider
    );

    final profileContent = _generateProfileShareContent(profileShareData);

    showModalBottomSheet(
      context: context,
      builder: (_) => ShareDialog(
        content: profileContent,
        onShare: (platform) async {
          _logger.i('Sharing profile via $platform');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile shared via $platform!')),
          );
        },
      ),
    );
  }

  ShareContent _generateProfileShareContent(ProfileShareData data) {
    final winRate = data.totalGamesPlayed > 0
        ? ((data.winCount / data.totalGamesPlayed) * 100).toStringAsFixed(1)
        : '0.0';

    final text = '''🎓 碁縁でのプログレス報告

👤 ${data.displayName}
🎮 対局数: ${data.totalGamesPlayed}
🏆 勝利数: ${data.winCount} (勝率: $winRate%)
💯 詰碁: ${data.totalPuzzlesSolved}問
🔥 連続成功: ${data.currentPuzzleStreak}問

AI解説で碁を上達しよう！''';

    return ShareContent(
      text: text,
      hashtags: '#碁 #碁縁 #Go学習 #AI解説',
    );
  }

  void _handleUpgrade(BuildContext context) {
    _logger.i('Opening paywall for upgrade');
    Navigator.of(context).pushNamed('/paywall');
  }

  void _handleSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Sign Out?'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logger.i('User signed out');
              ref.read(signOutProvider);
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/splash',
                (route) => false,
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _handleDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Delete Account?'),
        content: const Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logger.w('User deleted account');
              ref.read(deleteAccountProvider);
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/splash',
                (route) => false,
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red[400]),
            ),
          ),
        ],
      ),
    );
  }

  void _handleOpenTerms(BuildContext context) {
    _logger.i('Opening terms of service');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of Service - Phase 5.4')),
    );
  }

  void _handleOpenPrivacyPolicy(BuildContext context) {
    _logger.i('Opening privacy policy');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy - Phase 5.4')),
    );
  }

  void _handleOpenCredits(BuildContext context) {
    _logger.i('Opening credits');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Credits'),
        content: const SingleChildScrollView(
          child: Text(
            'GoEn - 碁縁\n\n'
            'Premium adult Go learning platform\n\n'
            'Built with Flutter, Firebase, and GNU Go\n\n'
            'Historical games sourced from public Go archives\n\n'
            'Music and sound effects by [TBD]\n\n'
            'Thank you for playing!',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
