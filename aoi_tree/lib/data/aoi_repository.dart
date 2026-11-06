import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/aoi_node.dart';

/// 从打包资源里读取 AOI 能力树。
class AoiRepository {
  const AoiRepository();

  static const _assetPath = 'assets/aoi_nodes.json';

  Future<AoiTree> load() async {
    final raw = await rootBundle.loadString(_assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw FormatException('能力树数据应为数组，实际为 ${decoded.runtimeType}');
    }
    return AoiTree.fromJsonList(decoded);
  }
}
