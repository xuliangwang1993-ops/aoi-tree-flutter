import 'package:aoi_tree_flutter/data/aoi_repository.dart';
import 'package:aoi_tree_flutter/models/aoi_node.dart';
import 'package:aoi_tree_flutter/pages/aoi_tree_page.dart';
import 'package:aoi_tree_flutter/theme/aoi_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('数据模型', () {
    test('AoiLeaf 解析字段', () {
      final leaf = AoiLeaf.fromJson({
        'id': 'aoi/M00/0',
        'name': 'M00.1',
        'label': '依赖与版本锁定',
        'summary': '锁定精确依赖版本',
        'risk': 'write',
        'leafType': 'interface',
        'evidence': 'spec/modules/M00_foundation.md:11',
      });

      expect(leaf.name, 'M00.1');
      expect(leaf.label, '依赖与版本锁定');
      expect(leaf.risk, 'write');
      expect(leaf.leafTypeLabel, '接口');
    });

    test('AoiModule 解析子节点并给出裸名', () {
      final m = AoiModule.fromJson({
        'id': 'aoi/M00',
        'name': 'M00',
        'label': 'M00 公共底座',
        'summary': '工程底座',
        'risk': 'destructive',
        'wave': 'A',
        'tools': [
          {
            'id': 'aoi/M00/0',
            'name': 'M00.1',
            'label': '依赖与版本锁定',
            'summary': 's',
            'risk': 'write',
            'leafType': 'interface',
          },
        ],
      });

      expect(m.leaves, hasLength(1));
      expect(m.bareLabel, '公共底座');
      expect(m.wave, 'A');
    });

    test('AoiTree 统计叶子数与批次', () {
      final tree = AoiTree.fromJsonList([
        {
          'id': 'aoi/M00',
          'name': 'M00',
          'label': 'M00 公共底座',
          'summary': '',
          'risk': 'read',
          'wave': 'A',
          'tools': [
            {
              'id': 'a',
              'name': 'M00.1',
              'label': 'a',
              'summary': '',
              'risk': 'read',
              'leafType': 'capability',
            },
            {
              'id': 'b',
              'name': 'M00.2',
              'label': 'b',
              'summary': '',
              'risk': 'read',
              'leafType': 'capability',
            },
          ],
        },
        {
          'id': 'aoi/M01',
          'name': 'M01',
          'label': 'M01 网关',
          'summary': '',
          'risk': 'read',
          'wave': 'B',
          'tools': [],
        },
      ]);

      expect(tree.modules, hasLength(2));
      expect(tree.leafCount, 2);
      expect(tree.waveCounts, {'A': 1, 'B': 1});
    });
  });

  group('真实资源数据', () {
    testWidgets('assets 里的能力树可解析且节点齐全', (tester) async {
      final tree = await tester.runAsync(() => const AoiRepository().load());

      expect(tree, isNotNull);
      expect(tree!.modules, hasLength(12));
      expect(tree.leafCount, 68);
      expect(tree.modules.map((m) => m.name).toList(), [
        'M00',
        'M01',
        'M02',
        'M03',
        'M04',
        'M05',
        'M06',
        'M07',
        'M08',
        'M09',
        'M10',
        'M11',
      ]);
    });
  });

  group('界面渲染', () {
    testWidgets('树能渲染出全部模块且可折叠', (tester) async {
      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final tree = await tester.runAsync(() => const AoiRepository().load());
      await tester.pumpWidget(
        MaterialApp(
          theme: AoiTheme.build(),
          home: AoiTreePage(tree: tree!),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Capability Tree'), findsOneWidget);

      for (final m in tree.modules) {
        expect(find.text(m.name), findsWidgets, reason: '缺少模块 ${m.name}');
      }

      expect(find.text('依赖与版本锁定'), findsWidgets);

      await tester.tap(find.text('全折叠'));
      await tester.pumpAndSettle();
      expect(find.text('依赖与版本锁定'), findsNothing);
    });

    testWidgets('搜索能过滤模块', (tester) async {
      tester.view.physicalSize = const Size(1600, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final tree = await tester.runAsync(() => const AoiRepository().load());
      await tester.pumpWidget(
        MaterialApp(
          theme: AoiTheme.build(),
          home: AoiTreePage(tree: tree!),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '配方');
      await tester.pumpAndSettle();

      expect(find.text('M07'), findsWidgets);
      expect(find.text('M00'), findsNothing);
    });
  });
}
