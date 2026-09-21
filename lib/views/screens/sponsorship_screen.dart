import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:goen/models/index.dart';
import 'package:goen/viewmodels/index.dart';
import 'package:goen/config/theme.dart';

final _logger = Logger();

/// SponsorshipScreen - スポンサーシップ管理
class SponsorshipScreen extends ConsumerWidget {
  const SponsorshipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _logger.i('Building SponsorshipScreen');

    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.sumi,
        appBar: AppBar(
          title: const Text('スポンサーシップ'),
          backgroundColor: AppColors.sumi,
        ),
        body: const Center(
          child: Text('ログインが必要です', style: TextStyle(color: AppColors.washiDim)),
        ),
      );
    }
    final uid = currentUser.uid;

    final sponsorInfo = ref.watch(sponsorInfoProvider(uid));
    final incomingSponsors = ref.watch(incomingSponsorsProvider(uid));
    final notifications = ref.watch(sponsorshipNotificationsProvider(uid));

    return Scaffold(
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: const Text('スポンサーシップ'),
        centerTitle: true,
        backgroundColor: AppColors.sumi,
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
            uid,
            info,
            incomingSponsors,
            notifications,
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.kin),
          ),
        ),
        error: (error, stack) => Center(
          child: Text('エラー: $error', style: const TextStyle(color: AppColors.washi)),
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
            color: AppColors.kin,
          ),
          const SizedBox(height: 24),
          Text(
            'スポンサーシップ',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.washi,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'スポンサーシップが設定されていません',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.washiDim,
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
    String uid,
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
              border: Border.all(color: AppColors.kin, width: 2),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.kin.withAlpha(50),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'スポンサーシップ統計',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.kin,
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
                      AppColors.kin,
                    ),
                    _buildStatColumn(
                      context,
                      '\$${(info.totalMonthlyUSD / 100).toStringAsFixed(2)}',
                      '月間収入',
                      AppColors.wakatake,
                    ),
                    _buildStatColumn(
                      context,
                      '${info.availableTiers.length}',
                      'ティア',
                      AppColors.aiLight,
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
                    color: AppColors.washi,
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
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.kin),
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
                    color: AppColors.washi,
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
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.kin),
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
              icon: const Icon(Icons.add),
              label: const Text('ティアを追加'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kin,
              ),
              onPressed: () => _showCreateTierDialog(context, ref, uid),
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
              Icon(Icons.favorite, color: AppColors.shuLight, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      sponsor.sponsorDisplayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.washi,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${sponsor.tierName} • $startDate',
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
                  color: AppColors.kin,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '\$${(sponsor.amountUSD / 100).toStringAsFixed(2)}/月',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.sumi,
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
                color: AppColors.washiDim,
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
            color: AppColors.kin,
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
                    color: AppColors.washi,
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

  void _showCreateTierDialog(BuildContext context, WidgetRef ref, String uid) {
    _logger.i('Creating a sponsorship tier');
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.sumiSurface,
        title: const Text('新しいティアを追加'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'ティア名（例: 応援者）'),
                style: const TextStyle(color: AppColors.washi),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: '月額（USD）'),
                style: const TextStyle(color: AppColors.washi),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: '説明'),
                style: const TextStyle(color: AppColors.washi),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('キャンセル'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final priceInputUSD = double.tryParse(priceController.text.trim());
              if (name.isEmpty || priceInputUSD == null || priceInputUSD <= 0) {
                return;
              }
              // amountUSD/priceUSD are stored in cents everywhere else in this
              // feature (see the "/ 100" divisions when displaying them).
              final priceUSD = (priceInputUSD * 100).round();
              Navigator.pop(dialogContext);
              final result = await ref.read(createSponsorshipTierProvider)(
                userId: uid,
                name: name,
                priceUSD: priceUSD,
                description: descriptionController.text.trim(),
                benefits: const [],
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result != null ? 'ティアを作成しました' : 'エラーが発生しました')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.kin),
            child: const Text('作成'),
          ),
        ],
      ),
    ).then((_) {
      nameController.dispose();
      priceController.dispose();
      descriptionController.dispose();
    });
  }
}
