import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// TwitchStreamScreen - Twitch ストリーム配信
class TwitchStreamScreen extends ConsumerWidget {
  const TwitchStreamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building TwitchStreamScreen');

    final isConnected = ref.watch(twitchConnectedProvider('current_user'));
    final activeStream = ref.watch(activeTwitchStreamProvider('current_game'));
    final history = ref.watch(twitchStreamHistoryProvider('current_user'));

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Twitch 配信'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: isConnected.when(
        data: (connected) {
          if (!connected) {
            return _buildConnectionRequired(context);
          }
          return _buildConnectedView(context, ref, activeStream, history);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        ),
        error: (error, stack) => Center(
          child: Text('エラー: $error', style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  /// Twitch 未接続時の画面
  Widget _buildConnectionRequired(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.streaming,
            size: 64,
            color: Colors.purple[400],
          ),
          const SizedBox(height: 24),
          Text(
            'Twitch チャンネルを接続',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ゲーム中に Twitch でリアルタイム配信できます',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('Twitch で接続'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => _connectTwitch(context),
          ),
        ],
      ),
    );
  }

  /// 接続済み時の表示
  Widget _buildConnectedView(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<TwitchStreamInfo?> activeStream,
    AsyncValue<List<TwitchStreamInfo>> history,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // アクティブストリーム表示
          activeStream.when(
            data: (stream) {
              if (stream != null) {
                return _buildActiveStreamCard(context, stream);
              } else {
                return _buildNoActiveStream(context, ref);
              }
            },
            loading: () => const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                ),
              ),
            ),
            error: (error, stack) => SizedBox(
              height: 200,
              child: Center(
                child: Text('エラー: $error', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),

          // ストリーム履歴
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ストリーム履歴',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                history.when(
                  data: (streamList) {
                    if (streamList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'ストリーム履歴がありません',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: streamList.length,
                      itemBuilder: (context, index) {
                        final stream = streamList[index];
                        return _buildStreamHistoryCard(context, stream);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                  ),
                  error: (error, stack) => Text(
                    'エラー: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ),

          // 切断ボタン
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Twitch を切断'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
              ),
              onPressed: () => _disconnectTwitch(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  /// アクティブなストリーム表示
  Widget _buildActiveStreamCard(BuildContext context, TwitchStreamInfo stream) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple[400]!, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.purple[900]?.withAlpha(50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ライブインジケーター
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red[400],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red[400]!.withAlpha(100),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.red[400],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ストリーム情報
          Text(
            stream.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // ビューア数
          Row(
            children: [
              Icon(Icons.visibility, color: Colors.purple[400], size: 16),
              const SizedBox(width: 8),
              Text(
                '${stream.viewers} 人視聴中',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // カテゴリ
          if (stream.category != null)
            Row(
              children: [
                Icon(Icons.tag, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Text(
                  stream.category!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // アクション
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.stop_circle),
                  label: const Text('配信終了'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                  ),
                  onPressed: () => _endStream(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Twitch で見る'),
                  onPressed: () => _openTwitchChannel(stream.channelName),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ストリームが未開始の場合
  Widget _buildNoActiveStream(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.info_outline,
            size: 48,
            color: Colors.white54,
          ),
          const SizedBox(height: 16),
          Text(
            'アクティブな配信はありません',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            label: const Text('配信を開始'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
            ),
            onPressed: () => _startStream(context, ref),
          ),
        ],
      ),
    );
  }

  /// ストリーム履歴カード
  Widget _buildStreamHistoryCard(BuildContext context, TwitchStreamInfo stream) {
    final duration = DateTime.now().difference(stream.startedAt);
    final durationText = duration.inHours > 0
        ? '${duration.inHours}時間${duration.inMinutes % 60}分'
        : '${duration.inMinutes}分';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.play_circle, color: Colors.purple[400], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  stream.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.visibility, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Text(
                '${stream.viewers} 人',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                ),
              ),
              const SizedBox(width: 16),
              Icon(Icons.schedule, color: Colors.white54, size: 14),
              const SizedBox(width: 4),
              Text(
                durationText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== Actions ==========

  void _connectTwitch(BuildContext context) {
    _logger.i('Connecting to Twitch');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Twitch 認証画面が開きます')),
    );
  }

  void _startStream(BuildContext context, WidgetRef ref) {
    _logger.i('Starting Twitch stream');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('配信を開始しました')),
    );
  }

  void _endStream(BuildContext context) {
    _logger.i('Ending Twitch stream');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('配信を終了'),
        content: const Text('配信を終了しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('配信を終了しました')),
              );
            },
            child: const Text('終了'),
          ),
        ],
      ),
    );
  }

  void _disconnectTwitch(BuildContext context, WidgetRef ref) {
    _logger.i('Disconnecting from Twitch');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Twitch を切断'),
        content: const Text('本当に Twitch との接続を切断しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Twitch を切断しました')),
              );
            },
            child: const Text('切断', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openTwitchChannel(String channelName) {
    _logger.i('Opening Twitch channel: $channelName');
  }
}
