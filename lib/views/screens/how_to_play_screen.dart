import 'package:flutter/material.dart';

/// 遊び方説明 - オンボーディングと違い、いつでも開けるルールリファレンス。
/// 対局中に「これどうだったっけ」となったときに参照できることを意図している。
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({Key? key}) : super(key: key);

  static const _sections = <_RuleSection>[
    _RuleSection(
      icon: Icons.grid_on,
      title: '石を打つ',
      body: '黒番から交互に、盤の線と線が交わる「交点」に石を置いていきます。'
          '一度置いた石は、自分では動かせません。',
    ),
    _RuleSection(
      icon: Icons.hub_outlined,
      title: '呼吸点とアタリ',
      body: '石(または繋がった石の塊)の上下左右にある空いた交点を「呼吸点」と呼びます。'
          '呼吸点が1つだけになった状態を「アタリ」といい、次に相手が打つとその石は取られてしまいます。',
    ),
    _RuleSection(
      icon: Icons.remove_circle_outline,
      title: '石を取る（アゲハマ）',
      body: '呼吸点が0になった石(の塊)は盤上から取り除かれます。'
          '取った石は「アゲハマ」として最後の計算に使います。',
    ),
    _RuleSection(
      icon: Icons.map_outlined,
      title: '陣地（中国ルール）',
      body: '碁縁は中国ルールを採用しています。最終的な得点は「自分の石の数 + 自分が囲んだ陣地の数」で計算し、'
          '数の多い方が勝ちです。日本ルールと違い、盤上に残っている自分の石もそのまま点数に数えます。',
    ),
    _RuleSection(
      icon: Icons.replay,
      title: 'コウ',
      body: '1手前の局面に戻すだけの取り返しは禁止されています(コウ)。'
          '一度他の場所に打ってからでないと、同じ場所を取り返すことはできません。',
    ),
    _RuleSection(
      icon: Icons.flag_outlined,
      title: '終局',
      body: '両者が続けてパスすると対局が終了し、陣地を数えて勝敗を決めます。'
          '碁縁にはタイマーがないので、納得いくまでじっくり考えて大丈夫です。',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('遊び方'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _sections.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildSectionCard(_sections[index]),
      ),
    );
  }

  Widget _buildSectionCard(_RuleSection section) {
    return Theme(
      data: ThemeData.dark().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: Icon(section.icon, color: Colors.amber[600]),
        title: Text(
          section.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        collapsedBackgroundColor: Colors.grey[900],
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none,
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                section.body,
                style: TextStyle(color: Colors.grey[300], height: 1.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleSection {
  final IconData icon;
  final String title;
  final String body;

  const _RuleSection({required this.icon, required this.title, required this.body});
}
