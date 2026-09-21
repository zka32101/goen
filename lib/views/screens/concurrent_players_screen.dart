import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/config/theme.dart';

final _logger = Logger();

/// 同時刻の碁盤画面 - いま同じ時間に対局しているプレイヤーを可視化
class ConcurrentPlayersScreen extends ConsumerWidget {
  const ConcurrentPlayersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid;
    final playersAsync = ref.watch(concurrentPlayersProvider(uid));

    return Scaffold(
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: const Text('同時刻の碁盤'),
        backgroundColor: AppColors.sumiSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(concurrentPlayersProvider(uid)),
          ),
        ],
      ),
      body: playersAsync.when(
        data: (players) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.wakatake),
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.wakatake.withOpacity(0.08),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.groups, color: AppColors.wakatake, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'いま ${players.length} 人が対局中',
                        style: const TextStyle(
                          color: AppColors.washi,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'あなたは一人ではありません',
                        style: TextStyle(color: AppColors.washiDim, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: players.isEmpty
                    ? Center(
                        child: Text(
                          'いま対局中の人はいません',
                          style: TextStyle(color: AppColors.washiDim),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: players.length,
                        separatorBuilder: (_, __) => Divider(color: AppColors.washiDim),
                        itemBuilder: (context, index) {
                          final player = players[index];
                          return ListTile(
                            leading: const Icon(Icons.circle, color: Colors.greenAccent, size: 12),
                            title: Text(player.displayName, style: const TextStyle(color: AppColors.washi)),
                            subtitle: Text(
                              '${player.gameType} / ${player.boardSize}路盤',
                              style: TextStyle(color: AppColors.washiDim),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          _logger.e('Concurrent players error: $err');
          return Center(
            child: Text('エラー: $err', style: const TextStyle(color: Colors.redAccent)),
          );
        },
      ),
    );
  }
}
