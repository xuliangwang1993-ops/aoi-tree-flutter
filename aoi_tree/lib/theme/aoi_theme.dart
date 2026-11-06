import 'package:flutter/material.dart';

/// AOI 树的视觉规范。
///
/// 深色"电影感"底 + 按施工批次(A/B/C/D)区分的强调色，
/// 风险等级用红/琥珀/青三档区分。
class AoiPalette {
  const AoiPalette._();

  // 底色
  static const bg = Color(0xFF07090F);
  static const bgElevated = Color(0xFF0D111B);
  static const panel = Color(0xFF111725);
  static const panelHover = Color(0xFF161E30);
  static const stroke = Color(0xFF212B40);
  static const strokeSoft = Color(0xFF182030);

  // 文字
  static const text = Color(0xFFE6EDF8);
  static const textDim = Color(0xFF9AA9C2);
  static const textFaint = Color(0xFF5E6E88);

  // 批次色
  static const waveA = Color(0xFF4ECDC4);
  static const waveB = Color(0xFF6C8CFF);
  static const waveC = Color(0xFFB585FF);
  static const waveD = Color(0xFFFFB454);

  // 风险色
  static const riskDestructive = Color(0xFFFF6B6B);
  static const riskWrite = Color(0xFFFFC857);
  static const riskRead = Color(0xFF4ECDC4);

  static Color wave(String w) => switch (w) {
    'A' => waveA,
    'B' => waveB,
    'C' => waveC,
    'D' => waveD,
    _ => textFaint,
  };

  static Color risk(String r) => switch (r) {
    'destructive' => riskDestructive,
    'write' => riskWrite,
    'read' => riskRead,
    _ => textFaint,
  };

  static String riskLabel(String r) => switch (r) {
    'destructive' => '破坏性',
    'write' => '可写',
    'read' => '只读',
    _ => r,
  };
}

class AoiTheme {
  const AoiTheme._();

  static ThemeData build() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AoiPalette.bg,
      colorScheme: base.colorScheme.copyWith(
        primary: AoiPalette.waveB,
        surface: AoiPalette.panel,
        onSurface: AoiPalette.text,
      ),
      dividerColor: AoiPalette.stroke,
      textTheme: base.textTheme.apply(
        bodyColor: AoiPalette.text,
        displayColor: AoiPalette.text,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(
          AoiPalette.textFaint.withValues(alpha: 0.35),
        ),
        radius: const Radius.circular(8),
        thickness: const WidgetStatePropertyAll(6),
      ),
    );
  }
}
