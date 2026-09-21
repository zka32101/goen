import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/config/theme.dart';

final _logger = Logger();

/// 縁スコア画面 - フレンドとのつながりの深さを可視化
class EnScoreScreen extends ConsumerStatefulWidget {
  const EnScoreScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EnScoreScreen> createState() => _EnScoreScreenState();
}

class _EnScoreScreenState extends ConsumerState<EnScoreScreen> {
  bool _isCalculating = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: const Text('縁スコア'),
        backgroundColor: AppColors.sumiSurface,
        elevation: 0,
        actions: uid == null
            ? null
            : [
                IconButton(
                  icon: _isCalculating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: _isCalculating ? null : () => _recalculateAll(uid),
                ),
              ],
      ),
      body: uid == null
          ? const Center(
              child: Text('ログインが必要です', style: TextStyle(color: AppColors.washiDim)),
            )
          : _buildConnectionsList(uid),
    );
  }

  Widget _buildConnectionsList(String uid) {
    final connectionsAsync = ref.watch(enConnectionsProvider(uid));
    return connectionsAsync.when(
      data: (connections) {
        if (connections.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                '右上の更新ボタンで、フレンドとの縁スコアを計算できます',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.washiDim),
              ),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: connections.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final c = connections[index];
            return Card(
              color: AppColors.sumiSurface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          c.friendDisplayName,
                          style: const TextStyle(color: AppColors.washi, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.pink[300]?.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            c.level,
                            style: TextStyle(color: Colors.pink[200], fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: c.score / 100,
                        minHeight: 8,
                        backgroundColor: AppColors.sumiCard,
                        valueColor: const AlwaysStoppedAnimation(Colors.pinkAccent),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '縁スコア ${c.score} / 100',
                      style: TextStyle(color: AppColors.washiDim, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${c.friendshipDays}日の友情 / 対戦${c.matchesPlayed}回 / '
                      '共同観戦${c.sharedSpectateSessions}回 / 局面共有${c.sharedPositionEchoes}回',
                      style: TextStyle(color: AppColors.washiDim, fontSize: 11),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        _logger.e('En connections error: $err');
        return Center(
          child: Text('エラー: $err', style: const TextStyle(color: Colors.redAccent)),
        );
      },
    );
  }

  Future<void> _recalculateAll(String uid) async {
    setState(() => _isCalculating = true);
    try {
      final friends = await ref.read(friendsStreamProvider(uid).future);
      for (final Friend friend in friends) {
        await ref.read(calculateEnScoreProvider)(
          uid,
          friend.uid,
          friend.displayName,
          friend.addedAt,
        );
      }
      ref.invalidate(enConnectionsProvider(uid));
    } catch (e) {
      _logger.e('Error recalculating en scores: $e');
    } finally {
      if (mounted) {
        setState(() => _isCalculating = false);
      }
    }
  }
}
