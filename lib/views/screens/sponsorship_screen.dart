import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';

final _logger = Logger();

/// SponsorshipScreen - スポンサーシップ管理
class SponsorshipScreen extends ConsumerWidget {
  const SponsorshipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building SponsorshipScreen');

    final sponsorInfo = ref.watch(sponsorInfoProvider('current_user'));
    final incomingSponsors = ref.watch(incomingSponsorsProvider('current_user'));
    final notifications = ref.watch(sponsorshipNotificationsProvider('current_user'));

    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('スポンサーシップ'),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: sponsorInfo.when(
        data: (info) {
          if (info == null) {
            return _buildEmptyState(context);
          }
          return _buildSponsorshipView(
            context,
            ref,
            info,
            incomingSponsors,
            notifications,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
        ),
        error: (error, stack) => Center(
          child: Text('エラー: $error', style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }

  /// 空状態
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.amber[400],
          ),
          const SizedBox(height: 24),
          Text(
            'スポンサーシップ',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'スポンサーシップが設定されていません',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// スポンサーシップ表示
  Widget _buildSponsorshipView(
    BuildContext context,
    WidgetRef ref,
    SponsorInfo info,
    AsyncValue<List<SponsorshipRecord>> incomingSponsors,
    AsyncValue<List<SponsorshipNotification>> notifications,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 統計情報
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber[600]!, width: 2),
              borderRadius: BorderRadius.circular(8),
              color: Colors.amber[900]?.withAlpha(50),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'スポンサーシップ統計',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Colors.amber[400],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      context,
                      '${info.totalSponsorshipCount}',
                      'スポンサー数',
                      Colors.amber[400]!,
                    ),
                    _buildStatColumn(
                      context,
                      '\$${(info.totalMonthlyUSD / 100).toStringAsFixed(2)}',
                      '月間収入',
                      Colors.green[400]!,
                    ),
                    _buildStatColumn(
                      context,
                      '${info.availableTiers.length}',
                      'ティア',
                      Colors.blue[400]!,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // スポンサー一覧
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'スポンサー一覧',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                incomingSponsors.when(
                  data: (sponsors) {
                    if (sponsors.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            'スポンサーがいません',
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
                      itemCount: sponsors.length,
                      itemBuilder: (context, index) {
                        final sponsor = sponsors[index];
                        return _buildSponsorCard(context, sponsor);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
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

          // 通知
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '最近のスポンサーシップ活動',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                notifications.when(
                  data: (notifs) {
                    if (notifs.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            '活動がありません',
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
                      itemCount: notifs.length.clamp(0, 5), // 最新5件
                      itemBuilder: (context, index) {
                        final notif = notifs[index];
                        return _buildNotificationCard(context, notif);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
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

          // ティア管理ボタン
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.settings),
              label: const Text('ティア設定'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[600],
              ),
              onPressed: () => _manageTiers(context),
            ),
          ),
        ],
      ),
    );
  }

  /// 統計カラム
  Widget _buildStatColumn(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.white54,
          ),
        ),
      ],
    );
  }

  /// スポンサーカード
  Widget _buildSponsorCard(BuildContext context, SponsorshipRecord sponsor) {
    final startDate = sponsor.startDate.toString().split(' ')[0];

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
              Icon(Icons.favorite, color: Colors.red[400], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sponsor.sponsorUserId,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      startDate,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber[600],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '\$${(sponsor.amountUSD / 100).toStringAsFixed(2)}/月',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (sponsor.message.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '「${sponsor.message}」',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// 通知カード
  Widget _buildNotificationCard(
    BuildContext context,
    SponsorshipNotification notif,
  ) {
    final typeText = notif.type == 'new_sponsor' ? '新しいスポンサー' :
                     notif.type == 'tier_upgrade' ? 'ティアアップグレード' :
                     '更新';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications,
            color: Colors.amber[400],
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$typeText - ${notif.sponsorName}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${(notif.amountUSD / 100).toStringAsFixed(2)} • ${notif.tier}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ========== Actions ==========

  void _manageTiers(BuildContext context) {
    _logger.i('Managing sponsorship tiers');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ティア設定画面（次フェーズで実装）')),
    );
  }
}
