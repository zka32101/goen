import 'package:flutter/material.dart';
import 'package:goen/config/theme.dart';

/// 遊び方説明 - オンボーディングと違い、いつでも開けるルールリファレンス。
/// 対局中に「これどうだったっけ」となったときに参照できることを意図している。
class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({Key? key}) : super(key: key);

  static const _sections = <_RuleSection>[
    _RuleSection(
      icon: Icons.dashboard_outlined,
      title: '盤の各部の名称',
      body: '碁盤の線が交わる点を「交点」といい、石はここに置きます。'
          '盤の端を「辺」、四隅を「隅」、盤の中心を「天元」と呼びます。'
          '9路盤・13路盤・19路盤には、目印として少し大きめの黒い点が打たれている交点があり、'
          'これを「星」と呼びます(中心の星は特に「天元」)。対局中に位置を伝えるときによく使う言葉です。',
      diagram: _BoardAnatomyDiagram(),
    ),
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
          '呼吸点が1つだけになった状態を「アタリ」といい、次に相手が打つとその石は取られてしまいます。'
          '下の図では、左の石には呼吸点が4つありますが、右の石は3方向を囲まれてアタリ(呼吸点1つ)になっています。',
      diagram: _LibertyComparisonDiagram(),
    ),
    _RuleSection(
      icon: Icons.remove_circle_outline,
      title: '石を取る（アゲハマ）',
      body: '呼吸点が0になった石(の塊)は盤上から取り除かれます。'
          '取った石は「アゲハマ」として最後の計算に使います。',
    ),
    _RuleSection(
      icon: Icons.block_outlined,
      title: '禁止手：自殺手',
      body: '打った後に自分の石(の塊)の呼吸点が0になってしまう手は、原則として打てません(自殺手の禁止)。'
          'ただし、その手で相手の石を取れて結果的に呼吸点ができる場合は例外として打つことができます。',
      diagram: _SuicideMoveDiagram(),
    ),
    _RuleSection(
      icon: Icons.map_outlined,
      title: '陣地（中国ルール）',
      body: '碁縁は中国ルールを採用しています。最終的な得点は「自分の石の数 + 自分が囲んだ陣地の数」で計算し、'
          '数の多い方が勝ちです。日本ルールと違い、盤上に残っている自分の石もそのまま点数に数えます。',
    ),
    _RuleSection(
      icon: Icons.replay,
      title: '禁止手：コウ',
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
      backgroundColor: AppColors.sumi,
      appBar: AppBar(
        title: const Text('遊び方'),
        backgroundColor: AppColors.sumiSurface,
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
        leading: Icon(section.icon, color: AppColors.kin),
        title: Text(
          section.title,
          style: const TextStyle(color: AppColors.washi, fontWeight: FontWeight.bold),
        ),
        collapsedBackgroundColor: AppColors.sumiSurface,
        backgroundColor: AppColors.sumiSurface,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (section.diagram != null) ...[
                  Center(child: section.diagram),
                  const SizedBox(height: 16),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    section.body,
                    style: TextStyle(color: AppColors.washiDim, height: 1.7),
                  ),
                ),
              ],
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
  final Widget? diagram;

  const _RuleSection({
    required this.icon,
    required this.title,
    required this.body,
    this.diagram,
  });
}

/// 盤の各部の名称（交点・辺・隅・天元・星）を示す簡易図。
class _BoardAnatomyDiagram extends StatelessWidget {
  const _BoardAnatomyDiagram();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: CustomPaint(painter: _BoardAnatomyPainter()),
    );
  }
}

class _BoardAnatomyPainter extends CustomPainter {
  static const _lines = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.washiDim
      ..strokeWidth = 1;
    final step = size.width / (_lines - 1);

    for (var i = 0; i < _lines; i++) {
      canvas.drawLine(Offset(i * step, 0), Offset(i * step, size.height), gridPaint);
      canvas.drawLine(Offset(0, i * step), Offset(size.width, i * step), gridPaint);
    }

    Offset pointAt(int col, int row) => Offset(col * step, row * step);

    void drawHoshi(Offset center) {
      canvas.drawCircle(center, 4, Paint()..color = AppColors.washi);
    }

    void drawLabel(String text, Offset anchor, Offset labelOffset) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(color: AppColors.kin, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelPos = anchor + labelOffset;
      tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));

      final linePaint = Paint()
        ..color = AppColors.kin.withOpacity(0.6)
        ..strokeWidth = 1;
      canvas.drawLine(anchor, labelPos, linePaint);
    }

    // 隅 (corner)
    final corner = pointAt(0, 0);
    canvas.drawCircle(corner, 3, Paint()..color = AppColors.wakatake);
    drawLabel('隅', corner, const Offset(-22, -18));

    // 辺 (side, middle of the top edge)
    final side = pointAt((_lines - 1) ~/ 2, 0);
    canvas.drawCircle(side, 3, Paint()..color = AppColors.aiLight);
    drawLabel('辺', side, const Offset(0, -22));

    // 天元 (center) - drawn as a hoshi point
    final center = pointAt((_lines - 1) ~/ 2, (_lines - 1) ~/ 2);
    drawHoshi(center);
    drawLabel('天元(星)', center, const Offset(0, 26));

    // 星 (corner-ish star point, offset from the true corner)
    final hoshi = pointAt(2, 2);
    drawHoshi(hoshi);
    drawLabel('星', hoshi, const Offset(-26, 8));

    // 交点 (a plain, unremarkable intersection)
    final plainPoint = pointAt(4, 5);
    drawLabel('交点', plainPoint, const Offset(28, 10));
  }

  @override
  bool shouldRepaint(_BoardAnatomyPainter oldDelegate) => false;
}

/// 呼吸点4つの通常の石と、呼吸点1つ(アタリ)の石を並べて見せる図。
class _LibertyComparisonDiagram extends StatelessWidget {
  const _LibertyComparisonDiagram();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: CustomPaint(painter: _LibertyPainter(surroundedSides: const {})),
            ),
            const SizedBox(height: 4),
            Text('呼吸点 4つ', style: TextStyle(color: AppColors.washiDim, fontSize: 12)),
          ],
        ),
        const SizedBox(width: 24),
        Column(
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: CustomPaint(
                painter: _LibertyPainter(surroundedSides: const {
                  _Side.left,
                  _Side.top,
                  _Side.right,
                }),
              ),
            ),
            const SizedBox(height: 4),
            Text('アタリ（呼吸点1つ）', style: TextStyle(color: AppColors.shuLight, fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

enum _Side { top, bottom, left, right }

class _LibertyPainter extends CustomPainter {
  final Set<_Side> surroundedSides;

  const _LibertyPainter({required this.surroundedSides});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = AppColors.washiDim
      ..strokeWidth = 1;
    final step = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    for (var i = 0; i <= 2; i++) {
      canvas.drawLine(Offset(i * step, 0), Offset(i * step, size.height), gridPaint);
      canvas.drawLine(Offset(0, i * step), Offset(size.width, i * step), gridPaint);
    }

    final neighbors = {
      _Side.top: center - Offset(0, step),
      _Side.bottom: center + Offset(0, step),
      _Side.left: center - Offset(step, 0),
      _Side.right: center + Offset(step, 0),
    };

    // 中央の黒石
    canvas.drawCircle(center, 14, Paint()..color = AppColors.sumi);
    canvas.drawCircle(
      center,
      14,
      Paint()
        ..color = AppColors.washi
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    for (final entry in neighbors.entries) {
      if (surroundedSides.contains(entry.key)) {
        // 相手の石で塞がれている呼吸点
        canvas.drawCircle(entry.value, 12, Paint()..color = AppColors.washi);
      } else {
        // 開いている呼吸点を強調する輪
        canvas.drawCircle(
          entry.value,
          9,
          Paint()
            ..color = AppColors.wakatake
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_LibertyPainter oldDelegate) =>
      oldDelegate.surroundedSides != surroundedSides;
}

/// 自殺手（呼吸点0になる着手）が禁止であることを示す図。
class _SuicideMoveDiagram extends StatelessWidget {
  const _SuicideMoveDiagram();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 130,
          height: 130,
          child: CustomPaint(painter: _LibertyPainter(surroundedSides: _Side.values.toSet())),
        ),
        const SizedBox(height: 4),
        Text('この位置は打てません（呼吸点0）', style: TextStyle(color: AppColors.shuLight, fontSize: 12)),
      ],
    );
  }
}
