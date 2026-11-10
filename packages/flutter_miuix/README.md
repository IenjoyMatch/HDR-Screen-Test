# flutter_miuix

`flutter_miuix` 是面向 Flutter 应用的 MIUIX 组件库，当前重点支持 Android 和 Windows。组件、主题、图标、玻璃模糊、弹层和导航均使用 Flutter 实现；Android 包额外自带原生震动桥接。

## 环境要求

- Flutter 3.38 或更高版本
- Dart 3.10 或更高版本
- Android：minSdk 21、compileSdk 36、JDK 17
- Windows：Visual Studio 的“使用 C++ 的桌面开发”工作负载

## 添加依赖

解压发行包后，在应用的 `pubspec.yaml` 中添加：

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_miuix:
    path: ../flutter_miuix
```

然后执行：

```powershell
flutter pub get
```

代码统一从公开入口导入：

```dart
import 'package:flutter_miuix/flutter_miuix.dart';
```

## 最小示例

```dart
import 'package:flutter/material.dart';
import 'package:flutter_miuix/flutter_miuix.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final miuixTheme = MiuixThemeData.defaults(
      seedColor: const Color(0xFF3482FF),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, child) => MiuixTheme(
        data: miuixTheme,
        child: child ?? const SizedBox.shrink(),
      ),
      home: MiuixScaffold(
        topBar: const MiuixTopAppBar(title: 'flutter_miuix'),
        body: Center(
          child: MiuixButton(
            label: '开始使用',
            filled: true,
            onPressed: () {},
          ),
        ),
      ),
    );
  }
}
```

## 功能范围

- 颜色、排版、间距、圆角、动画和五档玻璃强度主题令牌
- TopAppBar、普通/悬浮 NavigationBar、NavigationRail、TabRow
- Button、Card、Switch、Checkbox、Radio、Slider、RangeSlider
- ColorPicker、ColorPalette、SearchBar、TextField、NumberPicker
- 设置项、Snackbar、Tooltip、Badge、PullToRefresh
- Dialog、BottomSheet、Dropdown、级联菜单和锚点弹层
- Calendar、日期/时间/日期时间/时长选择器
- PIN/OTP、自动完成、多选、表单字段与表单分组
- 侧滑操作、右键/长按菜单、骨架屏、标准空状态、列表分组
- 评分、旋钮、时间线与轮播
- 自适应 Scaffold、NavigationDrawer、SplitView/ResizablePane
- 日期范围、月/年选择、周历、分组日程视图
- 重排列表、树、搜索选择/ComboBox、标签输入和五类 Chip
- 流程步骤器、可排序数据表、Sliver TopAppBar
- Windows 原生文件拖放/Android 选择器桥接与命令面板
- MIUIX 图标字体、超椭圆和液态玻璃效果
- Android 原生 MIUIX 震动角色；Windows 自动使用 Flutter 安全回退

## 大标题与刷新布局约定

`MiuixTopAppBar` 的大标题只应在页面内容确实超过可视高度时随滚动折叠。内容不足一屏时，`MiuixTopAppBarScrollBehavior` 会保持展开状态；即使列表为了支持下拉刷新使用了 `AlwaysScrollableScrollPhysics`，回弹手势也不会触发大小标题切换。

下拉刷新圆形指示器应显示在完整标题区域下方，而不是覆盖状态栏或标题。`MiuixScaffold` 会自动把标题连接到页面滚动；应用只需把标题区高度同时用于列表和刷新指示器的顶部间距。仅当 `MiuixPullToRefresh` 没有放在 `MiuixScaffold` 中时，才需要给它显式传入 `topAppBarScrollBehavior`：

```dart
// 在 State 中创建，并在 dispose() 中释放。
final scrollBehavior = MiuixTopAppBarScrollBehavior();
final topBar = MiuixTopAppBar(
  title: '通知中心',
  subtitle: '全部消息',
  scrollBehavior: scrollBehavior,
);
final topContentInset = MediaQuery.viewPaddingOf(context).top +
    topBar.preferredSize.height +
    12;

return MiuixScaffold(
  topBar: topBar,
  body: MiuixPullToRefresh.source(
    contentPadding: EdgeInsets.only(top: topContentInset),
    onRefresh: refresh,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16, topContentInset, 16, 24),
      children: const [/* 页面内容 */],
    ),
  ),
);
```

判断能否折叠应以实际 `ScrollMetrics` 为准，不要通过写死屏幕高度、条目数量或字体大小推测；这样字体缩放、横屏和平板布局变化后仍能保持正确行为。

## 平台说明

- [完整接入指南](doc/GETTING_STARTED_ZH.md)
- [Android 集成说明](doc/ANDROID.md)
- [Windows 集成说明](doc/WINDOWS.md)
- [常用组件示例](doc/COMPONENTS_ZH.md)
- [扩展组件指南](doc/EXTENSIONS_ZH.md)
- [当前界面实现与控件使用指南](doc/CURRENT_UI_IMPLEMENTATION_AND_USAGE_ZH.md)
- [HyperOS 4 官方软件风格实施规范](doc/HYPEROS4_OFFICIAL_APP_DESIGN_SPEC_ZH.md)

Flutter 组件库不会以独立 `.aar` 或 `.dll` 的方式包含 Dart 界面代码。正确的分发物是本源码包：消费应用构建时，Flutter 会把组件代码、字体和着色器编译进 Android APK/AAB 或 Windows EXE。Android 目录中的原生插件会自动参与 Android 构建。

后续新增、重做和视觉修复默认遵循 HyperOS 4 风格实施规范；现有公共 API
尽量保持兼容，但旧版 MIUIX 视觉不再作为新组件的默认设计目标。

上述新增基础控件全部位于 `lib/src/extensions/` 并由
`package:flutter_miuix/flutter_miuix.dart` 公开导出。它们属于
`flutter_miuix` 的跨平台扩展，不冒充当前 Compose MIUIX 官方目录中的原生组件；
示例程序只负责展示和回归验证。

## 验证

```powershell
flutter analyze lib test
flutter test
.\tool\build_release_cycle.ps1
```

完整 Release 周期同时构建 Android arm64-v8a、Windows x64 和两份可复用
组件库压缩包。每个产物族保留最近 3 个带构建号的检查点；不带构建号的文件始终
覆盖为最新版下载别名。具体规则参见根目录 `AGENTS.md`。

旧文件入口 `package:flutter_miuix/miuix_flutter.dart` 暂时保留兼容；新项目应使用 `package:flutter_miuix/flutter_miuix.dart`。
