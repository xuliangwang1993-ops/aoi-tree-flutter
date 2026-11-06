import 'package:flutter/material.dart';

import '../models/aoi_node.dart';
import '../theme/aoi_theme.dart';
import 'module_branch_painter.dart';

/// 一个模块节点卡片：头部（编号 / 名称 / 徽章）+ 可折叠的叶子列表。
class ModuleCard extends StatefulWidget {
  const ModuleCard({
    super.key,
    required this.module,
    required this.expanded,
    required this.isFirst,
    required this.isLast,
    required this.onToggle,
    this.highlight = '',
  });

  final AoiModule module;
  final bool expanded;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onToggle;

  /// 搜索高亮词，空串表示不高亮。
  final String highlight;

  static const double headerHeight = 76;
  static const double leafHeight = 46;
  static const double leafTopPadding = 8;
  static const double leafBottomPadding = 14;

  @override
  State<ModuleCard> createState() => _ModuleCardState();
}

class _ModuleCardState extends State<ModuleCard> {
  @override
  Widget build(BuildContext context) {
    final m = widget.module;
    final accent = AoiPalette.wave(m.wave);
    final leaves = m.leaves;
    final expanded = widget.expanded;

    // 叶子列表的轨道 y 坐标：只依赖固定高度常量，和实际布局必然对齐。
    final railOffsets = <double>[
      for (var i = 0; i < leaves.length; i++)
        ModuleCard.headerHeight +
            ModuleCard.leafTopPadding +
            i * ModuleCard.leafHeight +
            ModuleCard.leafHeight / 2,
    ];

    // 整张卡片（header + 叶子）共用一层背景和边框，叶子才不会"飘"在底色上。
    return Container(
      decoration: BoxDecoration(
        color: AoiPalette.panel.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: expanded ? accent.withValues(alpha: 0.45) : AoiPalette.stroke,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: ModuleBranchPainter(
          accent: accent,
          isFirst: widget.isFirst,
          isLast: widget.isLast,
          leafRailOffsets: railOffsets,
          leafColors: leaves
              .map((l) => AoiPalette.risk(l.risk))
              .toList(growable: false),
          headerHeight: ModuleCard.headerHeight,
          expanded: expanded,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(m, accent, expanded),
            // 展开动画交给 AnimatedSize 管理高度，避免手算高度和裁剪不同步。
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: ModuleCard.leafTopPadding),
                        for (final leaf in leaves)
                          _LeafRow(
                            leaf: leaf,
                            accent: accent,
                            highlight: widget.highlight,
                          ),
                        const SizedBox(height: ModuleCard.leafBottomPadding),
                      ],
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AoiModule m, Color accent, bool expanded) {
    final riskColor = AoiPalette.risk(m.risk);

    return InkWell(
      onTap: widget.onToggle,
      hoverColor: AoiPalette.panelHover,
      child: Container(
        height: ModuleCard.headerHeight,
        padding: const EdgeInsets.only(left: 34, right: 16),
        decoration: BoxDecoration(
          // 展开时 header 略微提亮，形成"卡片标题区"的层次
          color: expanded ? accent.withValues(alpha: 0.05) : Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: expanded
                  ? accent.withValues(alpha: 0.18)
                  : Colors.transparent,
            ),
          ),
        ),
        child: Row(
          children: [
            // 展开箭头
            AnimatedRotation(
              turns: widget.expanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 220),
              child: Icon(
                Icons.chevron_right,
                size: 18,
                color: widget.expanded ? accent : AoiPalette.textFaint,
              ),
            ),
            const SizedBox(width: 10),

            // 模块编号
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(7),
                border: Border.all(color: accent.withValues(alpha: 0.4)),
              ),
              child: Text(
                m.name,
                style: TextStyle(
                  color: accent,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 名称 + 摘要
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          m.label.replaceFirst('${m.name} ', ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: AoiPalette.text,
                          ),
                        ),
                      ),
                      if (m.optional) ...[
                        const SizedBox(width: 8),
                        _MiniTag(text: '可选', color: AoiPalette.textFaint),
                      ],
                      if (m.remoteOnly) ...[
                        const SizedBox(width: 6),
                        _MiniTag(text: '仅远程', color: AoiPalette.waveC),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    m.summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AoiPalette.textDim,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // 风险
            _MiniTag(text: AoiPalette.riskLabel(m.risk), color: riskColor),
            const SizedBox(width: 8),

            // 叶子数
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AoiPalette.bgElevated,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${m.leaves.length}',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AoiPalette.textDim,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 一行叶子。
class _LeafRow extends StatelessWidget {
  const _LeafRow({
    required this.leaf,
    required this.accent,
    required this.highlight,
  });

  final AoiLeaf leaf;
  final Color accent;
  final String highlight;

  @override
  Widget build(BuildContext context) {
    final riskColor = AoiPalette.risk(leaf.risk);

    return Tooltip(
      message: leaf.excerpt?.isNotEmpty == true
          ? '${leaf.summary}\n\n证据：${leaf.evidence ?? "-"}\n${leaf.excerpt}'
          : leaf.summary,
      waitDuration: const Duration(milliseconds: 450),
      child: SizedBox(
        height: ModuleCard.leafHeight,
        child: Container(
          margin: const EdgeInsets.only(left: 62, right: 4),
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            children: [
              // 叶子类型
              Container(
                width: 3,
                height: 22,
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),

              Flexible(
                child: Text(
                  leaf.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AoiPalette.text,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 类型徽章
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AoiPalette.bgElevated,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  leaf.leafTypeLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AoiPalette.textFaint,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // 编号
              Text(
                leaf.name,
                style: TextStyle(
                  fontSize: 10.5,
                  color: accent.withValues(alpha: 0.75),
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 小号标签。
class _MiniTag extends StatelessWidget {
  const _MiniTag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color, height: 1.2),
      ),
    );
  }
}
