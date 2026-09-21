import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewmodels/index.dart';
import 'package:goen/config/theme.dart';

/// Analytics dashboard screen
class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: const Text('ゲーム統計'),
        backgroundColor: AppColors.sumiSurface,
        elevation: 0,
      ),
      body: currentUser == null
          ? const Center(child: Text('ログインしてください'))
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPlaceholderCard('総ゲーム数', '0'),
                    const SizedBox(height: 16),
                    _buildPlaceholderCard('総勝利数', '0'),
                    const SizedBox(height: 16),
                    _buildPlaceholderCard('勝率', '0%'),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        '詳細統計はまだ利用できません',
                        style: TextStyle(color: AppColors.washiDim),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPlaceholderCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sumiSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: AppColors.washi)),
          Text(value, style: const TextStyle(color: Colors.amber, fontSize: 18)),
        ],
      ),
    );
  }
}
