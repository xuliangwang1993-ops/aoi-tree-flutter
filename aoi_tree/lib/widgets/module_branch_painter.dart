import 'package:flutter/material.dart';

import '../theme/aoi_theme.dart';

/// 单个模块节点的"主干 + 分支 + 叶子连线"绘制器。
///
/// 每个模块卡片自己负责画自己的这部分连线，所以无论卡片高度、
/// 叶子数量、展开状态怎么变，线永远对得上——比全局画布算坐标可靠得多。
class ModuleBranchPainter extends CustomPainter {
  ModuleBranchPainter({
    required this.accent,
    required this.isFirst,
    required this.isLast,
    required this.leafRailOffsets,
    required this.leafColors,
    required this.headerHeight,
    required this.expanded,
  });

  /// 该模块的强调色（按批次）。
  final Color accent;

  /// 是否是第一个模块（第一段不上探到卡片外）。
  final bool isFirst;

  /// 是否是最后一个模块（最后一段不下探）。
  final bool isLast;

  /// 每个叶子挂点的 y 偏移（相对卡片顶部）。
  final List<double> leafRailOffsets;

  /// 每个叶子连线颜色。
  final List<Color> leafColors;

  /// 头部高度：主干线在整个卡片上是贯穿的，含 header。
  final double headerHeight;

  /// 是否展开。折叠时只画 header 段。
  final bool expanded;

  static const double trunkX = 18;
  static const double leafRailX = 40;

  @override
  void paint(Canvas canvas, Size size) {
    final bottom = expanded ? size.height : headerHeight;

    // ---- 竖直主干（贯穿整张卡片）----
    final trunkPaint = Paint()
      ..color = accent.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(trunkX, isFirst ? headerHeight * 0.5 : 0),
      Offset(trunkX, isLast ? headerHeight * 0.5 : bottom),
      trunkPaint,
    );

    // ---- 主干 -> 头部圆点 ----
    final nodeY = headerHeight * 0.5;
    canvas.drawCircle(Offset(trunkX, nodeY), 5, Paint()..color = accent);
    canvas.drawCircle(
      Offset(trunkX, nodeY),
      9,
      Paint()..color = accent.withValues(alpha: 0.18),
    );

    if (!expanded || leafRailOffsets.isEmpty) return;

    // ---- 竖直到叶子导轨的分支 ----
    final lastRail = leafRailOffsets.last;

    final railPaint = Paint()
      ..color = accent.withValues(alpha: 0.22)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final railPath = Path()
      ..moveTo(trunkX, nodeY)
      ..cubicTo(
        trunkX + 8,
        nodeY,
        leafRailX - 8,
        nodeY + 6,
        leafRailX,
        nodeY + 14,
      )
      ..lineTo(leafRailX, lastRail);
    canvas.drawPath(railPath, railPaint);

    // ---- 导轨 -> 每个叶子 ----
    for (var i = 0; i < leafRailOffsets.length; i++) {
      final y = leafRailOffsets[i];
      final c = i < leafColors.length ? leafColors[i] : accent;
      final p = Paint()
        ..color = c.withValues(alpha: 0.45)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(
        Path()
          ..moveTo(leafRailX, y)
          ..cubicTo(leafRailX + 8, y, leafRailX + 12, y, leafRailX + 22, y),
        p,
      );
      canvas.drawCircle(Offset(leafRailX, y), 2.6, Paint()..color = c);
    }
  }

  @override
  bool shouldRepaint(ModuleBranchPainter old) =>
      old.expanded != expanded ||
      old.leafRailOffsets.length != leafRailOffsets.length ||
      old.accent != accent;
}

/// 顶部总览用的装饰性主干（纯视觉，不承载交互）。
class TrunkBackdropPainter extends CustomPainter {
  TrunkBackdropPainter({required this.tint});

  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          tint.withValues(alpha: 0.0),
          tint.withValues(alpha: 0.06),
          AoiPalette.waveA.withValues(alpha: 0.10),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(TrunkBackdropPainter old) => old.tint != tint;
}
