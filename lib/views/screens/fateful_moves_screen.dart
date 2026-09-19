import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// 運命の一手画面 - 対局中に検出された劇的な瞬間の記録
class FatefulMovesScreen extends ConsumerWidget {
  const FatefulMovesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('運命の一手'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: uid == null
          ? const Center(
              child: Text('ログインが必要です', style: TextStyle(color: Colors.white70)),
            )
          : _buildMovesList(ref, uid),
    );
  }

  Widget _buildMovesList(WidgetRef ref, String uid) {
    final movesAsync = ref.watch(fatefulMovesProvider(uid));
    return movesAsync.when(
      data: (moves) {
        if (moves.isEmpty) {
          return Center(
            child: Text(
              '大石を仕留めたり劫を制したりすると、ここに記録されます',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: moves.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final move = moves[index];
            return Card(
              color: Colors.grey[900],
              child: ListTile(
                leading: Icon(_iconFor(move.type), color: Colors.orangeAccent),
                title: Text(
                  move.type.getDisplayName(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${move.moveNumber}手目 / ${move.stonesCaptured}子捕獲',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: move.sharedWithFriends
                    ? const Icon(Icons.share, color: Colors.greenAccent, size: 18)
                    : null,
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        _logger.e('Fateful moves error: $err');
        return Center(
          child: Text('エラー: $err', style: const TextStyle(color: Colors.redAccent)),
        );
      },
    );
  }

  IconData _iconFor(FatefulMoveType type) {
    switch (type) {
      case FatefulMoveType.bigCapture:
        return Icons.whatshot;
      case FatefulMoveType.tesuji:
        return Icons.auto_awesome;
      case FatefulMoveType.koFight:
        return Icons.sync_alt;
      case FatefulMoveType.lifeAndDeath:
        return Icons.favorite;
    }
  }
}
