part of '../miuix_widgets.dart';

/// 普通和展开式侧栏共享的显式选中颜色，不缓存或重算调用方主题。
class _MiuixNavigationRailColors extends InheritedWidget {
  const _MiuixNavigationRailColors({
    // 配对颜色是调用方已经确认的值，作用域不再运行对比度调色。
    required this.foreground,
    required this.background,
    required super.child,
  });

  // 两项都可为空，以保留既有 MIUIX 默认和 source 兼容分支。
  final Color? foreground;
  // 背景为 null 才使用默认玻璃透明度，显式实色不被淡化。
  final Color? background;

  // 订阅颜色变化；切换主题不依赖重建目的地列表才能生效。
  static _MiuixNavigationRailColors? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_MiuixNavigationRailColors>();

  @override
  // 仅通知依赖颜色的子项，单纯改变回调或目的地数据不增加颜色通知。
  // 展开动画的后代与普通子项订阅同一作用域，不保留过期颜色副本。
  bool updateShouldNotify(_MiuixNavigationRailColors oldWidget) =>
      foreground != oldWidget.foreground || background != oldWidget.background;
}
