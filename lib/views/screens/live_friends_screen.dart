import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// いま対局中のフレンド画面 - ライブ観戦できるフレンドの対局一覧
class LiveFriendsScreen extends ConsumerWidget {
  const LiveFriendsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('いま対局中のフレンド'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
        actions: uid == null
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => ref.invalidate(liveFriendActivitiesProvider(uid)),
                ),
              ],
      ),
      body: uid == null
          ? const Center(
              child: Text('ログインが必要です', style: TextStyle(color: Colors.white70)),
            )
          : _buildActivityList(context, ref, uid),
    );
  }

  Widget _buildActivityList(BuildContext context, WidgetRef ref, String uid) {
    final activitiesAsync = ref.watch(liveFriendActivitiesProvider(uid));
    return activitiesAsync.when(
      data: (activities) {
        if (activities.isEmpty) {
          return Center(
            child: Text(
              'いま対局中のフレンドはいません',
              style: TextStyle(color: Colors.grey[500]),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: activities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final activity = activities[index];
            return Card(
              color: Colors.grey[900],
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  child: Icon(Icons.live_tv, color: Colors.white),
                ),
                title: Text(activity.hostDisplayName, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  '${activity.gameType} / 観戦者 ${activity.spectatorCount}人',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
                  onPressed: () => _joinSpectate(context, ref, uid, activity.sessionId),
                  child: const Text('観戦する', style: TextStyle(color: Colors.white)),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        _logger.e('Live friend activities error: $err');
        return Center(
          child: Text('エラー: $err', style: const TextStyle(color: Colors.redAccent)),
        );
      },
    );
  }

  Future<void> _joinSpectate(
    BuildContext context,
    WidgetRef ref,
    String uid,
    String sessionId,
  ) async {
    try {
      await ref.read(joinSpectatorSessionProvider)(sessionId, uid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('観戦を開始しました')),
        );
      }
    } catch (e) {
      _logger.e('Error joining spectate session: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('観戦を開始できませんでした: $e')),
        );
      }
    }
  }
}
