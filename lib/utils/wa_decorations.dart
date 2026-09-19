import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 青海波（せいがいは）風の背景パターン。半円を規則的に重ねて描く、
/// 波を模した和柄。装飾用途なので、上に乗る文字や碁盤を邪魔しないよう
/// 低い不透明度で使うことを想定している。
class SeigaihaPatternPainter extends CustomPainter {
  final Color color;
  final double arcRadius;

  const SeigaihaPatternPainter({required this.color, this.arcRadius = 24});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rowHeight = arcRadius * 0.75;
    final rows = (size.height / rowHeight).ceil() + 1;
    final cols = (size.width / arcRadius).ceil() + 2;

    for (int row = 0; row < rows; row++) {
      final y = row * rowHeight;
      final xOffset = (row.isOdd) ? arcRadius / 2 : 0.0;
      for (int col = -1; col < cols; col++) {
        final x = col * arcRadius + xOffset;
        // 同心円弧を3重に重ねるのが青海波の特徴。
        for (int ring = 1; ring <= 3; ring++) {
          canvas.drawArc(
            Rect.fromCircle(center: Offset(x, y), radius: arcRadius * ring / 3),
            math.pi,
            math.pi,
            false,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(SeigaihaPatternPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.arcRadius != arcRadius;
}

/// 碁盤の木目を表現する、緩やかに波打つ縦筋のペインター。
/// 実写画像を使わず、少数の緩やかなベジェ曲線で「柾目」風の質感を出す。
class WoodGrainPainter extends CustomPainter {
  final Color color;
  final int lineCount;

  const WoodGrainPainter({required this.color, this.lineCount = 6});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final spacing = size.width / (lineCount + 1);
    for (int i = 1; i <= lineCount; i++) {
      final baseX = spacing * i;
      final path = Path()..moveTo(baseX, 0);
      // 数点の緩やかな揺らぎを与えて木目らしいカーブにする。
      final wiggle = spacing * 0.18 * (i.isEven ? 1 : -1);
      path.cubicTo(
        baseX + wiggle, size.height * 0.3,
        baseX - wiggle, size.height * 0.6,
        baseX + wiggle * 0.5, size.height,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WoodGrainPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.lineCount != lineCount;
}

/// 落款（らっかん）風の朱印。装飾目的のワンポイント。
class HankoSeal extends StatelessWidget {
  final String character;
  final double size;

  const HankoSeal({super.key, required this.character, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFB33A3A), // 朱色 (shu-iro)
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF8C2A2A), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 3, offset: const Offset(1, 1)),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        character,
        style: TextStyle(
          color: Colors.white.withOpacity(0.92),
          fontSize: size * 0.55,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }
}
