import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_miuix/flutter_miuix.dart';

const channel = MethodChannel('hdr_screen_test/display');
void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'HDR Screen Test',
    builder: (context, child) => MiuixTheme(
      data: MiuixThemeData.defaults(seedColor: const Color(0xff3482ff))
          .copyWith(
            hyperOs4: const MiuixHyperOs4Tokens(
              floatingNavigationHeight: 52,
              floatingNavigationItemHeight: 48,
              floatingNavigationContentSpacing: 2,
              floatingNavigationHorizontalPadding: 3,
              floatingNavigationSelectionInset: 0,
            ),
          ),
      child: child ?? const SizedBox.shrink(),
    ),
    home: const Home(),
  );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  Map<Object?, Object?>? info;
  String? error;
  int tab = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  Future<void> refresh() async {
    try {
      final result = await channel.invokeMapMethod<Object?, Object?>('info');
      if (mounted)
        setState(() {
          info = result;
          error = null;
        });
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  Future<void> video() async {
    try {
      await channel.invokeMethod<bool>('pickVideo');
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('无法打开视频：$e')));
    }
  }

  String number(String key, {int digits = 1, String suffix = ''}) {
    final value = info?[key];
    return value is num ? '${value.toStringAsFixed(digits)}$suffix' : '未提供';
  }

  Widget row(String name, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(name, style: const TextStyle(color: Color(0xff778397))),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
  Widget card(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: MiuixCard(
      glass: false,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    ),
  );
  Widget get displayPage {
    final rates =
        (info?['rates'] as List?)
            ?.map((e) => (e as num).toStringAsFixed(1))
            .join(' / ') ??
        '未提供';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '了解你的屏幕',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text('显示参数由设备系统报告', style: TextStyle(color: Color(0xff778397))),
        const SizedBox(height: 22),
        if (error != null)
          card('无法读取屏幕信息', [
            Text(error!),
            TextButton(onPressed: refresh, child: const Text('重试')),
          ])
        else if (info == null)
          const Center(child: CircularProgressIndicator())
        else ...[
          card('设备', [
            row('型号', '${info!['device']}'),
            row('系统', '${info!['android']}'),
          ]),
          card('显示参数', [
            row('当前分辨率', '${info!['width']} × ${info!['height']} px'),
            row('刷新率', number('refresh', suffix: ' Hz')),
            row('支持的刷新率', '$rates Hz'),
            row('窗口尺寸', '${info!['widthDp']} × ${info!['heightDp']} dp'),
            row('逻辑密度', '${info!['density']} dpi'),
            row('X / Y 物理密度', '${number('xdpi')} / ${number('ydpi')} dpi'),
            row('对角线（估算）', number('diagonal', digits: 2, suffix: ' 英寸')),
            row(
              '广色域',
              info!['wide'] == null
                  ? '系统版本不支持查询'
                  : (info!['wide'] == true ? '支持' : '未报告支持'),
            ),
          ]),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '物理密度和尺寸由厂商报告，可能与实测值不同。',
              style: TextStyle(color: Color(0xff778397), height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: 'HDR Screen Test',
              applicationVersion: '0.1.5',
            ),
            child: const Text('开源许可证'),
          ),
        ],
      ],
    );
  }

  Widget get hdrPage {
    final types = (info?['hdrTypes'] as List?)?.join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HDR 测试',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        const Text(
          '查看能力并播放本地 HDR 测试视频',
          style: TextStyle(color: Color(0xff778397)),
        ),
        const SizedBox(height: 22),
        card('设备报告的 HDR 能力', [
          row(
            '支持格式',
            info == null
                ? '读取中'
                : (types == null || types.isEmpty ? '未报告支持' : types),
          ),
          row('期望峰值亮度', number('max', suffix: ' cd/m²')),
          row('期望全屏平均亮度', number('average', suffix: ' cd/m²')),
          row('期望最低亮度', number('min', digits: 4, suffix: ' cd/m²')),
          row('当前 HDR / SDR 比率', number('ratio', digits: 2, suffix: '×')),
        ]),
        card('HDR 测试图', [
          const Text(
            'PQ 亮度阶梯、HLG 渐变和 PQ 面积色块。仅 Android 14 及以上可用；信号数值不是实测亮度。',
            style: TextStyle(height: 1.5, color: Color(0xff778397)),
          ),
          const SizedBox(height: 16),
          MiuixButton(
            label: '打开 HDR 测试图',
            filled: true,
            onPressed: () async {
              if ((info?['api'] as int? ?? 0) < 34) {
                if (context.mounted)
                  showDialog<void>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('需要 Android 14'),
                      content: const Text(
                        'PQ 和 HLG 测试图需要 Android 14 或更高版本。你仍可播放 HDR 视频。',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('知道了'),
                        ),
                      ],
                    ),
                  );
                return;
              }
              try {
                await channel.invokeMethod<bool>('patterns');
              } catch (e) {
                if (context.mounted)
                  showDialog<void>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('无法打开测试图'),
                      content: Text(e.toString()),
                    ),
                  );
              }
            },
          ),
        ]),
        card('播放 HDR 视频', [
          const Text(
            '选择设备上的 HDR10、HLG 等测试视频，通过系统视频解码器和原生 SurfaceView 播放。实际效果取决于视频、解码器及屏幕。',
            style: TextStyle(height: 1.5, color: Color(0xff778397)),
          ),
          const SizedBox(height: 16),
          MiuixButton(label: '选择视频', filled: true, onPressed: video),
        ]),
        card('辅助观察图案 · SDR', [
          const Text(
            '纯色与灰阶可用于检查坏点、均匀性和暗部层次。以下图案是 SDR，不能用于测量 HDR 峰值。',
            style: TextStyle(height: 1.5, color: Color(0xff778397)),
          ),
          const SizedBox(height: 14),
          MiuixButton(
            label: '打开全屏图案',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const Patterns())),
          ),
        ]),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '亮度数值是系统提供的目标值，并非实测结果。',
            style: TextStyle(color: Color(0xff778397), height: 1.5),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => MiuixScaffold(
    extendBody: true,
    topBar: const MiuixTopAppBar(
      title: 'HDR Screen Test',
      large: false,
      glass: false,
    ),
    body: SafeArea(
      top: false,
      bottom: false,
      child: RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.paddingOf(context).top +
                MiuixTopAppBar.collapsedLargeHeight +
                20,
            20,
            150,
          ),
          children: [tab == 0 ? displayPage : hdrPage],
        ),
      ),
    ),
    bottomBar: MiuixFloatingNavigationBar(
      capsule: true,
      selectionHorizontalInset: 0,
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      items: const [
        MiuixNavigationItem(
          icon: Icon(Icons.phone_android_rounded),
          label: '屏幕',
        ),
        MiuixNavigationItem(icon: Icon(Icons.hdr_on_rounded), label: 'HDR 测试'),
      ],
    ),
  );
}

class Patterns extends StatefulWidget {
  const Patterns({super.key});
  @override
  State<Patterns> createState() => _PatternsState();
}

class _PatternsState extends State<Patterns> {
  int index = 0;
  static const colors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.green,
    Colors.blue,
    Color(0xff101010),
    Color(0xff808080),
  ];
  static const labels = ['白', '黑', '红', '绿', '蓝', '暗灰', '中灰'];
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: colors[index],
    body: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => setState(() => index = (index + 1) % colors.length),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child: SafeArea(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${labels[index]} · 轻触切换',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  FilledButton.tonal(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('退出'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

