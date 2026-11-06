import 'package:flutter/material.dart';

import '../models/aoi_node.dart';
import '../theme/aoi_theme.dart';
import '../widgets/module_card.dart';

/// AOI 能力树主界面。
class AoiTreePage extends StatefulWidget {
  const AoiTreePage({super.key, required this.tree});

  final AoiTree tree;

  @override
  State<AoiTreePage> createState() => _AoiTreePageState();
}

class _AoiTreePageState extends State<AoiTreePage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  /// 已展开的模块 id 集合；默认全部展开。
  late Set<String> _expanded;
  String _query = '';
  bool _singleColumn = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.tree.modules.map((m) => m.id).toSet();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 按搜索词过滤后的模块列表（匹配模块名或任一叶子）。
  List<AoiModule> get _visibleModules {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.tree.modules;

    return widget.tree.modules
        .where((m) {
          if (m.label.toLowerCase().contains(q)) return true;
          if (m.summary.toLowerCase().contains(q)) return true;
          return m.leaves.any(
            (l) =>
                l.label.toLowerCase().contains(q) ||
                l.summary.toLowerCase().contains(q) ||
                l.name.toLowerCase().contains(q),
          );
        })
        .toList(growable: false);
  }

  int get _visibleLeafCount =>
      _visibleModules.fold(0, (s, m) => s + m.leaves.length);

  void _expandAll() {
    setState(() => _expanded = widget.tree.modules.map((m) => m.id).toSet());
  }

  void _collapseAll() {
    setState(() => _expanded = <String>{});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildBody()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ 顶栏

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AoiPalette.strokeSoft)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 标题
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AoiPalette.waveA,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'AOI',
                        style: TextStyle(
                          fontSize: 13,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w700,
                          color: AoiPalette.waveA,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '能力树',
                        style: TextStyle(
                          fontSize: 13,
                          letterSpacing: 2,
                          color: AoiPalette.textDim.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Capability Tree',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w300,
                      height: 1.1,
                      color: AoiPalette.text,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              _buildStats(),
            ],
          ),
          const SizedBox(height: 16),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final waves = widget.tree.waveCounts;
    final sortedWaves = waves.keys.toList()..sort();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _stat('模块', '${widget.tree.modules.length}'),
        _divider(),
        _stat('叶子', '${widget.tree.leafCount}'),
        _divider(),
        for (var i = 0; i < sortedWaves.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          _waveChip(sortedWaves[i], waves[sortedWaves[i]]!),
        ],
      ],
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w600,
            color: AoiPalette.text,
            height: 1.0,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AoiPalette.textFaint),
        ),
      ],
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 26,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    color: AoiPalette.stroke,
  );

  Widget _waveChip(String wave, int count) {
    final c = AoiPalette.wave(wave);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: c.withValues(alpha: 0.35)),
          ),
          child: Text(
            '批次 $wave',
            style: TextStyle(fontSize: 10, color: c, height: 1.2),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 11,
            color: c.withValues(alpha: 0.8),
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar() {
    return Row(
      children: [
        // 搜索框
        SizedBox(
          width: 340,
          height: 36,
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _query = v),
            style: const TextStyle(fontSize: 12.5, color: AoiPalette.text),
            cursorColor: AoiPalette.waveB,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AoiPalette.panel,
              hintText: '搜索模块、能力或接口…',
              hintStyle: const TextStyle(
                fontSize: 12.5,
                color: AoiPalette.textFaint,
              ),
              prefixIcon: const Icon(
                Icons.search,
                size: 16,
                color: AoiPalette.textFaint,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 34,
                minHeight: 34,
              ),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 14,
                        color: AoiPalette.textFaint,
                      ),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AoiPalette.stroke),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AoiPalette.stroke),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AoiPalette.waveB.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
        ),
        if (_query.isNotEmpty) ...[
          const SizedBox(width: 12),
          Text(
            '命中 ${_visibleModules.length} 模块 / $_visibleLeafCount 叶子',
            style: const TextStyle(fontSize: 11, color: AoiPalette.textDim),
          ),
        ],
        const Spacer(),

        _toolButton(
          icon: _singleColumn ? Icons.view_column : Icons.view_agenda,
          label: _singleColumn ? '单栏' : '双栏',
          active: _singleColumn,
          onTap: () => setState(() => _singleColumn = !_singleColumn),
        ),
        const SizedBox(width: 8),
        _toolButton(icon: Icons.unfold_more, label: '全展开', onTap: _expandAll),
        const SizedBox(width: 8),
        _toolButton(icon: Icons.unfold_less, label: '全折叠', onTap: _collapseAll),
      ],
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) {
    final c = active ? AoiPalette.waveB : AoiPalette.textDim;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: active
              ? AoiPalette.waveB.withValues(alpha: 0.14)
              : AoiPalette.panel,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: active
                ? AoiPalette.waveB.withValues(alpha: 0.45)
                : AoiPalette.stroke,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: c),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 11.5, color: c)),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ 主体

  Widget _buildBody() {
    final modules = _visibleModules;

    if (modules.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 34, color: AoiPalette.textFaint),
            const SizedBox(height: 12),
            Text(
              '没有匹配「$_query」的节点',
              style: const TextStyle(fontSize: 13, color: AoiPalette.textDim),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 900;
        final oneCol = _singleColumn || narrow;

        return Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(20, 18, 24, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: oneCol
                    ? _buildColumnList(modules)
                    : _buildTwoColumn(modules),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTwoColumn(List<AoiModule> modules) {
    // 按模块高度做简单贪心分栏，视觉上左右两栏负载更均衡。
    final left = <AoiModule>[];
    final right = <AoiModule>[];
    var leftH = 0.0;
    var rightH = 0.0;

    for (final m in modules) {
      final h = _estimateHeight(m);
      if (leftH <= rightH) {
        left.add(m);
        leftH += h;
      } else {
        right.add(m);
        rightH += h;
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 左栏第一张卡片是整棵树的最顶端，主干线不用往上探。
        Expanded(child: _buildColumnList(left)),
        const SizedBox(width: 18),
        Expanded(child: _buildColumnList(right)),
      ],
    );
  }

  /// 卡片真实高度：header + (展开时) 上内边距 + 叶子行 + 下内边距。
  /// 必须和 ModuleCard 里用的常量保持一致，分栏才不会错位。
  double _estimateHeight(AoiModule m) {
    final expanded = _expanded.contains(m.id);
    return ModuleCard.headerHeight +
        (expanded
            ? ModuleCard.leafTopPadding +
                  m.leaves.length * ModuleCard.leafHeight +
                  ModuleCard.leafBottomPadding
            : 0);
  }

  Widget _buildColumnList(List<AoiModule> modules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < modules.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ModuleCard(
              module: modules[i],
              expanded: _expanded.contains(modules[i].id),
              // 每列自成一条主干：列首不向上探，列尾不向下探。
              isFirst: i == 0,
              isLast: i == modules.length - 1,
              highlight: _query,
              onToggle: () {
                setState(() {
                  final id = modules[i].id;
                  if (_expanded.contains(id)) {
                    _expanded.remove(id);
                  } else {
                    _expanded.add(id);
                  }
                });
              },
            ),
          ),
      ],
    );
  }

  // ------------------------------------------------------------------ 底栏

  Widget _buildFooter() {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AoiPalette.strokeSoft)),
        color: AoiPalette.bgElevated,
      ),
      child: Row(
        children: [
          _legendDot(AoiPalette.riskRead, '只读'),
          const SizedBox(width: 14),
          _legendDot(AoiPalette.riskWrite, '可写'),
          const SizedBox(width: 14),
          _legendDot(AoiPalette.riskDestructive, '破坏性'),
          const Spacer(),
          const Text(
            '数据源：aoi-m11-preview capability tree',
            style: TextStyle(fontSize: 10.5, color: AoiPalette.textFaint),
          ),
        ],
      ),
    );
  }

  Widget _legendDot(Color c, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AoiPalette.textDim),
        ),
      ],
    );
  }
}
