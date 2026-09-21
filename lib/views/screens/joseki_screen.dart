import 'package:flutter/material.dart';
import 'package:goen/config/theme.dart';

/// 戦法（定石）ライブラリ - 代表的な隅の定石を、手順と狙いの解説付きで紹介する。
/// 対局のインポートやリプレイは行わず、静的な参考資料として提供する。
class JosekiScreen extends StatelessWidget {
  const JosekiScreen({Key? key}) : super(key: key);

  static const _josekis = <_Joseki>[
    _Joseki(
      name: '星の定石（ツケ引き）',
      moves: '黒1: 星 → 白2: ツケ → 黒3: ハネ → 白4: 引き → 黒5: 伸び',
      idea: 'お互いの陣地の境界線をシンプルに分け合う、最も基本的な定石。'
          '初心者同士でも打ちやすく、隅の生き死にで悩みにくい。',
    ),
    _Joseki(
      name: '小目の一間高ガカリ',
      moves: '黒1: 小目 → 白2: 一間高ガカリ → 黒3: ハサミ or 受け',
      idea: '小目に対する代表的なカカリ方の一つ。ハサミにするか、大人しく受けるかで'
          '戦いの規模が大きく変わるため、序盤の方針を決める重要な分岐点になる。',
    ),
    _Joseki(
      name: '大斜定石',
      moves: '黒1: 小目 → 白2: 大ゲイマガカリ → 黒3: 大斜掛かり',
      idea: '非常に変化が多いことで知られる難解な定石。'
          '筋を丸暗記するよりも、「お互いに相手の弱点を突き合っている」という'
          '全体の狙いを理解しておくと実戦で応用しやすい。',
    ),
    _Joseki(
      name: '一間バサミ定石',
      moves: '黒1: 星 → 白2: カカリ → 黒3: 一間バサミ → 白4: 三々',
      idea: 'カカってきた石を狭くハサむことで積極的に戦いに持ち込む定石。'
          '隅を白に渡す代わりに、外側に厚みを作って盤全体を主導権を握る狙いがある。',
    ),
    _Joseki(
      name: '三々入り',
      moves: '黒: 星 → 白: 三々に入る → 黒: 押さえ → 白: 生きる',
      idea: '隅の実利を確実に確保する打ち方。生きる代わりに黒に外側の厚みを与えるため、'
          'その後の展開でその厚みをどう活かされるかが焦点になる。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: const Text('戦法（定石）'),
        backgroundColor: AppColors.sumiSurface,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _josekis.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '代表的な隅の定石とその狙いを紹介します。丸暗記より、'
                '「なぜその手が打たれるか」を意識すると実戦で活きます。',
                style: TextStyle(color: AppColors.washiDim, height: 1.6),
              ),
            );
          }
          return _buildJosekiCard(_josekis[index - 1]);
        },
      ),
    );
  }

  Widget _buildJosekiCard(_Joseki joseki) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.washi.withOpacity(0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            joseki.name,
            style: const TextStyle(color: AppColors.washi, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            joseki.moves,
            style: TextStyle(color: AppColors.kin, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            joseki.idea,
            style: TextStyle(color: AppColors.washiDim, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _Joseki {
  final String name;
  final String moves;
  final String idea;

  const _Joseki({required this.name, required this.moves, required this.idea});
}
