import 'package:flutter/material.dart';

import 'data/aoi_repository.dart';
import 'models/aoi_node.dart';
import 'pages/aoi_tree_page.dart';
import 'theme/aoi_theme.dart';

void main() {
  runApp(const AoiTreeApp());
}

class AoiTreeApp extends StatelessWidget {
  const AoiTreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AOI 能力树',
      debugShowCheckedModeBanner: false,
      theme: AoiTheme.build(),
      home: const _Bootstrapper(),
    );
  }
}

/// 加载数据后进入主页面，加载中/失败都有明确状态。
class _Bootstrapper extends StatefulWidget {
  const _Bootstrapper();

  @override
  State<_Bootstrapper> createState() => _BootstrapperState();
}

class _BootstrapperState extends State<_Bootstrapper> {
  late Future<AoiTree> _future;

  @override
  void initState() {
    super.initState();
    _future = const AoiRepository().load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AoiTree>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AoiPalette.waveA,
                ),
              ),
            ),
          );
        }

        if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 36,
                      color: AoiPalette.riskDestructive,
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '能力树数据加载失败',
                      style: TextStyle(
                        fontSize: 15,
                        color: AoiPalette.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      '${snap.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AoiPalette.textDim,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () => setState(() {
                        _future = const AoiRepository().load();
                      }),
                      child: const Text('重试'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return AoiTreePage(tree: snap.data!);
      },
    );
  }
}
