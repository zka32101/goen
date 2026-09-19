import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// 棋風の相性画面 - 自分の棋風プロファイルと、フレンドとの相性を表示
class PlaystyleScreen extends ConsumerWidget {
  const PlaystyleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('棋風の相性'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        actions: uid == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: '棋風を再分析',
                  onPressed: () => _recompute(context, ref, uid),
                ),
              ],
      ),
      body: uid == null
          ? const Center(
              child: Text('ログインが必要です', style: TextStyle(color: Colors.white70)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMyProfile(ref, uid),
                  const SizedBox(height: 28),
                  Text(
                    'フレンドとの相性',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildCompatibilityList(ref, uid),
                ],
              ),
            ),
    );
  }

  Widget _buildMyProfile(WidgetRef ref, String uid) {
    final profileAsync = ref.watch(playstyleProfileProvider(uid));
    return profileAsync.when(
      data: (profile) {
        if (profile.gamesAnalyzed == 0) {
          return _infoBox('まだ対局データがありません。対局を重ねると棋風が分析されます。');
        }
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.cyan[400]!),
            borderRadius: BorderRadius.circular(12),
            color: Colors.cyan[400]?.withOpacity(0.08),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'あなたの棋風（${profile.gamesAnalyzed}局分析）',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildBar('攻撃性', profile.aggressiveness, Colors.redAccent),
              const SizedBox(height: 8),
              _buildBar('地合い重視度', profile.territoriality, Colors.blueAccent),
              const SizedBox(height: 8),
              _buildBar('捨て石率', profile.sacrificeRate, Colors.orangeAccent),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        _logger.e('Playstyle profile error: $err');
        return Text('エラー: $err', style: const TextStyle(color: Colors.redAccent));
      },
    );
  }

  Widget _buildBar(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[300], fontSize: 12)),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  Widget _buildCompatibilityList(WidgetRef ref, String uid) {
    final friendsAsync = ref.watch(friendsStreamProvider(uid));
    return friendsAsync.when(
      data: (friends) {
        if (friends.isEmpty) {
          return _infoBox('フレンドを追加すると、棋風の相性がわかります。');
        }
        final compatAsync = ref.watch(compatibleFriendsProvider(uid));
        return compatAsync.when(
          data: (results) {
            if (results.isEmpty) {
              return _infoBox('相性を計算するデータがまだありません。');
            }
            return Column(
              children: results.map((c) {
                final isComplementary = c.compatibilityType == 'complementary';
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      isComplementary ? Icons.compare_arrows : Icons.favorite,
                      color: isComplementary ? Colors.orangeAccent : Colors.pinkAccent,
                    ),
                    title: Text(c.otherDisplayName, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(
                      isComplementary ? '補完し合う棋風 - 学び合える相手' : '似た棋風 - 共感し合える相手',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    trailing: Text(
                      '${(c.compatibilityScore * 100).round()}%',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) {
            _logger.e('Compatibility error: $err');
            return Text('エラー: $err', style: const TextStyle(color: Colors.redAccent));
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        _logger.e('Friends list error: $err');
        return Text('エラー: $err', style: const TextStyle(color: Colors.redAccent));
      },
    );
  }

  Widget _infoBox(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message, style: TextStyle(color: Colors.grey[400])),
    );
  }

  Future<void> _recompute(BuildContext context, WidgetRef ref, String uid) async {
    try {
      await ref.read(computePlaystyleProfileProvider)(uid);
      ref.invalidate(playstyleProfileProvider(uid));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('棋風を再分析しました')),
        );
      }
    } catch (e) {
      _logger.e('Error recomputing playstyle: $e');
    }
  }
}
