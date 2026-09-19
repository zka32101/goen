import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/viewmodels/index.dart';
import 'matching_screen.dart';
import 'playstyle_screen.dart';
import 'position_echo_screen.dart';
import 'live_friends_screen.dart';
import 'fateful_moves_screen.dart';
import 'concurrent_players_screen.dart';
import 'en_score_screen.dart';

final _logger = Logger();

/// 縁ハブ画面 - 「碁縁」らしいつながり機能への入り口
class EnHubScreen extends ConsumerWidget {
  const EnHubScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('縁'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: uid == null
          ? const Center(
              child: Text(
                'ログインすると縁を確認できます',
                style: TextStyle(color: Colors.white70),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '碁を通じたつながり',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '対局・観戦・局面から生まれる、人との縁を可視化します',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                        ),
                  ),
                  const SizedBox(height: 20),
                  _buildCard(
                    context,
                    icon: Icons.favorite,
                    color: Colors.pink[300]!,
                    title: '縁スコア',
                    subtitle: 'フレンドとのつながりの深さ',
                    onTap: () => _push(context, const EnScoreScreen()),
                  ),
                  _buildCard(
                    context,
                    icon: Icons.handshake,
                    color: Colors.amber[600]!,
                    title: '実力マッチング',
                    subtitle: 'レートの近い相手との運命の対戦',
                    onTap: () => _push(context, const MatchingScreen()),
                  ),
                  _buildCard(
                    context,
                    icon: Icons.psychology,
                    color: Colors.cyan[400]!,
                    title: '棋風の相性',
                    subtitle: 'フレンドとの棋風の相性を診断',
                    onTap: () => _push(context, const PlaystyleScreen()),
                  ),
                  _buildCard(
                    context,
                    icon: Icons.history_edu,
                    color: Colors.deepPurple[300]!,
                    title: '局面の轍',
                    subtitle: '名局と同じ局面に辿り着いた記録',
                    onTap: () => _push(context, const PositionEchoScreen()),
                  ),
                  _buildCard(
                    context,
                    icon: Icons.live_tv,
                    color: Colors.red[400]!,
                    title: 'いま対局中のフレンド',
                    subtitle: 'ライブ観戦できるフレンドの対局',
                    onTap: () => _push(context, const LiveFriendsScreen()),
                  ),
                  _buildCard(
                    context,
                    icon: Icons.auto_awesome,
                    color: Colors.orange[400]!,
                    title: '運命の一手',
                    subtitle: '劇的な瞬間の記録とシェア',
                    onTap: () => _push(context, const FatefulMovesScreen()),
                  ),
                  _buildCard(
                    context,
                    icon: Icons.groups,
                    color: Colors.green[400]!,
                    title: '同時刻の碁盤',
                    subtitle: 'いま同じ時間に対局している仲間',
                    onTap: () => _push(context, const ConcurrentPlayersScreen()),
                  ),
                ],
              ),
            ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    _logger.i('Navigating to ${screen.runtimeType}');
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.6)),
            borderRadius: BorderRadius.circular(12),
            color: Colors.white.withOpacity(0.04),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.2),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
