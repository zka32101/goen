import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// YouTubeShareScreen - ゲームをYouTubeで共有
class YouTubeShareScreen extends ConsumerWidget {
  const YouTubeShareScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building YouTubeShareScreen');

    final isConnected = ref.watch(youtubeConnectedProvider('current_user'));
    final uploads = ref.watch(youtubeUploadsProvider('current_user'));
    final autoShare = ref.watch(youtubeAutoShareProvider('current_user'));

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('YouTube 共有'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: isConnected.when(
        data: (connected) {
          if (!connected) {
            return _buildConnectionRequired(context);
          }
          return _buildConnectedView(context, ref, uploads, autoShare);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'エラー: $error',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// YouTube 未接続時の画面
  Widget _buildConnectionRequired(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 24),
          Text(
            'YouTube チャンネルを接続',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'ゲーム動画を自動的に YouTube にアップロードできます',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.login),
            label: const Text('YouTube で接続'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () => _connectYouTube(context),
          ),
        ],
      ),
    );
  }

  /// 接続済み時の表示
  Widget _buildConnectedView(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<YouTubeUploadResult>> uploads,
    AsyncValue<bool> autoShare,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 接続済みヘッダー
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.green[900]?.withAlpha(50),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[400]),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YouTube チャンネル接続済み',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.green[400],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ゲーム動画を共有できます',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 自動共有設定
          autoShare.when(
            data: (enabled) => Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Colors.amber[400],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '自動共有',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ゲーム終了後に自動的にアップロード',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: (value) => _toggleAutoShare(ref, value),
                    activeColor: Colors.red[600],
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // アップロード一覧
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'アップロード履歴',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                uploads.when(
                  data: (uploadList) {
                    if (uploadList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'まだアップロードはありません',
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
                      itemCount: uploadList.length,
                      itemBuilder: (context, index) {
                        final upload = uploadList[index];
                        return _buildUploadCard(context, upload);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
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
              label: const Text('YouTube を切断'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
              ),
              onPressed: () => _disconnectYouTube(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  /// アップロード情報カード
  Widget _buildUploadCard(BuildContext context, YouTubeUploadResult upload) {
    Color statusColor;
    IconData statusIcon;

    switch (upload.status) {
      case 'completed':
        statusColor = Colors.green[400]!;
        statusIcon = Icons.check_circle;
      case 'processing':
        statusColor = Colors.amber[400]!;
        statusIcon = Icons.hourglass_bottom;
      case 'failed':
        statusColor = Colors.red[400]!;
        statusIcon = Icons.error;
      default:
        statusColor = Colors.grey[400]!;
        statusIcon = Icons.info;
    }

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
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upload.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      upload.uploadedAt.toString().split('.')[0],
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _openYouTubeVideo(upload.url),
                child: Icon(
                  Icons.open_in_new,
                  color: statusColor,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(30),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              upload.status == 'completed' ? '完了' :
              upload.status == 'processing' ? '処理中' :
              upload.status == 'failed' ? 'エラー' : '不明',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== Actions ==========

  void _connectYouTube(BuildContext context) {
    _logger.i('Connecting to YouTube');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('YouTube 認証画面が開きます')),
    );
  }

  void _toggleAutoShare(WidgetRef ref, bool enabled) {
    _logger.i('Toggle auto-share: $enabled');
    // ref.read(setAutoShareProvider('current_user'))(enabled);
  }

  void _disconnectYouTube(BuildContext context, WidgetRef ref) {
    _logger.i('Disconnecting from YouTube');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('YouTube を切断'),
        content: const Text('本当に YouTube との接続を切断しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // ref.read(disconnectYouTubeProvider('current_user'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('YouTube を切断しました')),
              );
            },
            child: const Text('切断', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openYouTubeVideo(String url) {
    _logger.i('Opening YouTube video: $url');
  }
}
