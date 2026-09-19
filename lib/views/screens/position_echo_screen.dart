import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// 局面の轍画面 - 名局と同じ局面に辿り着いた記録
class PositionEchoScreen extends ConsumerWidget {
  const PositionEchoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final uid = currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('局面の轍'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: uid == null
          ? const Center(
              child: Text('ログインが必要です', style: TextStyle(color: Colors.white70)),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '対局中に名局(秀策の碁など)と同じ局面へ辿り着くと、ここに記録されます',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: _buildEchoList(ref, uid)),
                ],
              ),
            ),
    );
  }

  Widget _buildEchoList(WidgetRef ref, String uid) {
    final echoesAsync = ref.watch(historicalEchoesProvider(uid));
    return echoesAsync.when(
      data: (echoes) {
        if (echoes.isEmpty) {
          return Center(
            child: Text(
              'まだ名局との縁は記録されていません',
              style: TextStyle(color: Colors.grey[500]),
            ),
          );
        }
        return ListView.separated(
          itemCount: echoes.length,
          separatorBuilder: (_, __) => Divider(color: Colors.grey[850]),
          itemBuilder: (context, index) {
            final echo = echoes[index];
            return ListTile(
              leading: const Icon(Icons.history_edu, color: Colors.deepPurpleAccent),
              title: Text(
                echo.kifuTitle ?? '名局',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '${echo.moveNumber}手目 / ${echo.boardSize}路盤',
                style: TextStyle(color: Colors.grey[400]),
              ),
              trailing: Text(
                _formatDate(echo.reachedAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) {
        _logger.e('Position echo error: $err');
        return Text('エラー: $err', style: const TextStyle(color: Colors.redAccent));
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
