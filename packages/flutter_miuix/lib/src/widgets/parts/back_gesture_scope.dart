part of '../miuix_widgets.dart';

/// 为整个导航树统一设置预测性返回；普通返回仍由原来的栈处理。
/// 放在 Navigator 外，页面、嵌套栈和浮层都会读取同一个选择。
class MiuixBackGestureScope extends InheritedWidget {
  // 值未变化时不通知，避免普通根页面刷新引起额外导航更新。
  // 页面结果读取器随 widget 更新，不在 initState 冻结旧回调。
  // scope 不创建 Navigator，也不改变其 GlobalKey。
  // 切换设置时保留当前页面、滚动和输入状态。
  const MiuixBackGestureScope({
    super.key,
    required this.enabled,
    this.blocked = false,
    required super.child,
  });

  /// 只控制手势预览，不改变返回结果或页面的退出限制。
  final bool enabled;

  /// 认证遮罩等保护层可同时禁止预览与普通返回，不能与用户关闭动画混用。
  final bool blocked;

  // 保护状态参与依赖更新，既有页面与弹窗也必须立即生效。
  static bool blockedOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<MiuixBackGestureScope>()
          ?.blocked ??
      false;

  // 注册表在事件到来时读取，避免保留切换设置前的闭包值。
  static bool enabledOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<MiuixBackGestureScope>()
          ?.enabled ??
      true;

  // 组合式保护层可能派生更严格的 scope，因此这里建立依赖。
  // 只读取一次或使用 getInheritedWidget 会让派生层保留旧开关。
  // 未提供 scope 的现有应用继续沿用开启行为，保持 API 兼容。

  @override
  bool updateShouldNotify(MiuixBackGestureScope oldWidget) =>
      oldWidget.enabled != enabled || oldWidget.blocked != blocked;
}

// PopScope 必须位于 ModalRoute 内；根 Navigator 外的观察者来不及拦截 WidgetsApp。
// 每个导航表面注册相同保护，避免普通返回先改变遮罩后的页面。
class _MiuixBackGuard extends StatelessWidget {
  // 保护不执行补 pop，也不带退出副作用，解除后原路由立即恢复正常。
  // Object? 作为结果超类型兼容所有 PageRoute 和 PopupRoute 的返回数据。
  // 与用户的 enabled 选择分开，关闭动画不应把页面锁死。
  const _MiuixBackGuard({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    canPop: !MiuixBackGestureScope.blockedOf(context),
    child: child,
  );
}

/// 提前提供系统返回的结果，无需先拦截返回再手动 pop。
/// 手势取消不读取结果；提交时与顶部返回按钮共享最新值。
class MiuixResultPageRoute<T> extends MiuixPageRoute<T> {
  // 结果类型沿用 Navigator 的泛型，避免用动态转换传递页面数据。
  // 明确传给 Navigator.pop 的结果仍由 Flutter 优先采用。
  MiuixResultPageRoute({
    required super.builder,
    super.settings,
    super.fullscreenDialog,
  });

  // 页面通过 ResultScope 注册读取器，不把页面状态复制进导航层。
  T? Function()? _readResult;

  // 无显式结果的系统返回在提交时读取，不在 build 阶段冻结值。
  // 这也覆盖没有更新整个页面、只更新控制器的相机变化。

  @override
  T? get currentResult => _readResult?.call() ?? super.currentResult;
}

/// 将页面的当前结果接入 ResultPageRoute，保持正常的可返回状态。
class MiuixPageResult<T> extends StatefulWidget {
  // 页面只提供结果读取，不负责调用 Navigator 或驱动过渡动画。
  // onPopInvoked 再 pop 会错过手势的提前判定，所以不走那条路径。
  const MiuixPageResult({super.key, required this.result, required this.child});

  final T? Function() result;
  // 包装不增加绘制层或布局约束，保留原页面尺寸。
  final Widget child;

  @override
  State<MiuixPageResult<T>> createState() => _MiuixPageResultState<T>();
}

class _MiuixPageResultState<T> extends State<MiuixPageResult<T>> {
  MiuixResultPageRoute<T>? _route;
  // 保持回调身份稳定，卸载旧页面时不能清除后来注册的读取器。
  late final T? Function() _read = _result;
  T? _result() => widget.result();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (identical(_route, route)) return;
    _detach();
    if (route is MiuixResultPageRoute<T>) {
      _route = route;
      route._readResult = _read;
    }
    // 独立帮助截图可把同一页面作为 home 展示，无须模拟返回结果。
    // 这种宿主没有 ResultPageRoute，不注册读取器即可。
  }

  void _detach() {
    // 路由完成之前保留读取器；dispose 后不再访问页面状态。
    if (identical(_route?._readResult, _read)) _route?._readResult = null;
    _route = null;
  }

  @override
  void dispose() {
    _detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
