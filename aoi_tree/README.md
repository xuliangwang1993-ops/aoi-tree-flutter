# AOI 能力树 · Flutter 版

用 Flutter 重新渲染的 AOI 能力树界面。数据源取自 `aoi-m11-preview.onrender.com`
线上包里内嵌的 capability tree JSON，**12 个模块 / 68 个叶子**，与线上完全一致。

## 运行

```bash
# Web（推荐，一条命令即可看效果）
flutter run -d chrome

# 构建静态产物
flutter build web --release
# 产物在 build/web，可直接丢给任意静态服务器

# Windows 桌面
flutter run -d windows
```

Flutter SDK 路径：`C:\src\flutter`（3.47.7 / Dart 3.13.5）

## 结构

```
lib/
  main.dart                           入口 + 数据加载状态（加载中 / 失败重试）
  models/aoi_node.dart                模块 / 叶子 / 整树模型
  data/aoi_repository.dart            从 assets 读取 JSON
  theme/aoi_theme.dart                配色（按施工批次 A/B/C/D 分色，按风险分级）
  pages/aoi_tree_page.dart            主界面：顶栏统计、搜索、双栏/单栏、滚动
  widgets/module_card.dart            模块卡片 + 可折叠叶子列表
  widgets/module_branch_painter.dart  主干 / 分支 / 叶子连线绘制
assets/aoi_nodes.json                 能力树数据
```

## 设计要点

**树形怎么画**：不画在一张全局画布上（那样算坐标极易错位），而是让**每个模块卡片
自己画自己的那一段**：竖直主干贯穿卡片、主干到头部圆点、主干弯折到叶子导轨、导轨
水平连到每个叶子。叶子行高度是固定常量 `leafHeight`，轨道偏移用同一套常量算，
所以无论卡片多高、展开折叠、窗口怎么缩放，连线永远对得上。

**展开折叠**：交给 `AnimatedSize` 管理高度，不手算高度做裁剪。

**双栏布局**：按模块的真实高度（`header + 叶子数 × 行高`）做贪心分栏，两栏负载均衡；
窗口宽度小于 900 时自动切单栏。

## 功能

- 搜索：匹配模块名 / 摘要 / 任一叶子，实时显示命中数
- 全展开 / 全折叠
- 双栏 / 单栏切换
- 叶子悬停显示完整说明、证据文件位置与原文摘录
- 顶栏统计：模块数、叶子数、各施工批次分布
- 底部图例：只读 / 可写 / 破坏性

## 数据来源

线上包 `assets/index-*.js` 里的 `Lv=JSON.parse(...)` 即这份树数据。
如需更新，替换 `assets/aoi_nodes.json` 即可，字段结构见 `models/aoi_node.dart`。