/// AOI 能力树的数据模型。
///
/// 数据来源：aoi-m11-preview 线上包内嵌的 capability tree JSON，
/// 结构为 模块(M00..M11) -> 叶子(M00.1 .. M11.7)。
library;

/// 叶子节点（能力 / 接口 / 场景）。
class AoiLeaf {
  const AoiLeaf({
    required this.id,
    required this.name,
    required this.label,
    required this.summary,
    required this.risk,
    required this.leafType,
    this.evidence,
    this.excerpt,
  });

  final String id;
  final String name;
  final String label;
  final String summary;
  final String risk;
  final String leafType;
  final String? evidence;
  final String? excerpt;

  factory AoiLeaf.fromJson(Map<String, dynamic> json) {
    return AoiLeaf(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      label: (json['label'] ?? '') as String,
      summary: (json['summary'] ?? '') as String,
      risk: (json['risk'] ?? 'read') as String,
      leafType: (json['leafType'] ?? 'capability') as String,
      evidence: json['evidence'] as String?,
      excerpt: json['excerpt'] as String?,
    );
  }

  /// 叶子类型的中文标签。
  String get leafTypeLabel => switch (leafType) {
    'interface' => '接口',
    'scenario' => '场景',
    'capability' => '能力',
    _ => leafType,
  };
}

/// 模块节点（M00..M11）。
class AoiModule {
  const AoiModule({
    required this.id,
    required this.name,
    required this.label,
    required this.summary,
    required this.risk,
    required this.wave,
    required this.optional,
    required this.remoteOnly,
    required this.leaves,
    this.note,
  });

  final String id;
  final String name;
  final String label;
  final String summary;
  final String risk;
  final String wave;
  final bool optional;
  final bool remoteOnly;
  final String? note;
  final List<AoiLeaf> leaves;

  factory AoiModule.fromJson(Map<String, dynamic> json) {
    final rawTools = (json['tools'] as List?) ?? const [];
    return AoiModule(
      id: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      label: (json['label'] ?? '') as String,
      summary: (json['summary'] ?? '') as String,
      risk: (json['risk'] ?? 'read') as String,
      wave: (json['wave'] ?? '-') as String,
      optional: json['optional'] == true,
      remoteOnly: json['remoteOnly'] == true,
      note: json['note'] as String?,
      leaves: rawTools
          .whereType<Map<String, dynamic>>()
          .map(AoiLeaf.fromJson)
          .toList(growable: false),
    );
  }

  /// 去掉 "M00 " 前缀后的纯名字。
  String get bareLabel {
    final prefix = '$name ';
    return label.startsWith(prefix) ? label.substring(prefix.length) : label;
  }
}

/// 整棵树的元信息。
class AoiTree {
  const AoiTree({required this.modules});

  final List<AoiModule> modules;

  int get leafCount => modules.fold(0, (sum, m) => sum + m.leaves.length);

  /// 按施工批次(A/B/C/D)分组统计。
  Map<String, int> get waveCounts {
    final map = <String, int>{};
    for (final m in modules) {
      map[m.wave] = (map[m.wave] ?? 0) + 1;
    }
    return map;
  }

  factory AoiTree.fromJsonList(List<dynamic> list) {
    return AoiTree(
      modules: list
          .whereType<Map<String, dynamic>>()
          .map(AoiModule.fromJson)
          .toList(growable: false),
    );
  }
}
