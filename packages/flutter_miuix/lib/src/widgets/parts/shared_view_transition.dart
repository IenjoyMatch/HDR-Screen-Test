part of '../miuix_widgets.dart';

/// 将明确的内容来源与下一次页面打开关联；只处理 Flutter 页面内的视觉过渡。
/// Android SharedView Kit 的 ActivityOptions 不适用于同一个 Activity 内的路由。
/// 此控件不是该 SDK 的包装，也不向系统宣称厂商能力。
/// 每个 Navigator 配一个稳定的 MiuixSharedViewObserver，主题使用
/// MiuixNavigationPageTransitionsBuilder。来源回调调用既有 Navigator.push。
/// open 的 Future 表示导航已派发，不表示详情已经关闭；需要等待结果时
/// 应在回调中保存 Navigator.push 返回的 Future，例如视频位置同步。
///
/// ```dart
/// final observer = MiuixSharedViewObserver();
/// // MaterialApp 的 navigatorObservers 包含 observer。
/// // 页面过渡主题使用 MiuixNavigationPageTransitionsBuilder。
/// MiuixSharedViewSource(
///   radius: 24,
///   builder: (context, open) => GestureDetector(
///     onTap: () => open(() {
///       Navigator.of(context).push(MiuixPageRoute<void>(
///         builder: (_) => const Scaffold(body: Text('详情')),
///       ));
///     }),
///     child: const SizedBox(width: 240, height: 160),
///   ),
/// );
/// ```
///
/// 视频和平台纹理使用 captureImage: false，仅登记位置，避免生成黑色快照。
/// 来源在详情期间被移除或滚出可用区域时，关闭降为淡出，不复用旧矩形。
class MiuixSharedViewSource extends StatefulWidget {
  const MiuixSharedViewSource({
    super.key,
    required this.builder,
    this.radius = 24,
    this.captureImage = true,
  });
  // open 保留原导航回调，业务页面不必复制或更换自己的导航协议。
  // builder 的 context 位于来源边界内，沿当前 Navigator 导航。
  // 业务对象与页面构造仍归调用方，来源控件不持有数据控制器。
  final Widget Function(BuildContext, Future<void> Function(VoidCallback) open)
  builder;
  // 圆角是应用设计值，不是金标联盟或手机厂商公布的参数。
  final double radius;
  // 视频或平台纹理只登记几何位置，避免捕获黑帧。
  final bool captureImage;
  // 每个来源单独保留按压图层，列表重排依靠调用方稳定 key 维护身份。
  @override
  State<MiuixSharedViewSource> createState() => MiuixSharedViewSourceState();
}

// 每个 Navigator 独立登记，只能消费同一次同步导航中的来源。
// Expando 不持有已经销毁的 Navigator 或路由，图片由退出完成回调释放。
final _miuixSharedPending = Expando<_MiuixSharedCapture>('shared pending');
final _miuixSharedRoutes = Expando<_MiuixSharedCapture>('shared routes');
final _miuixSharedCovers = Expando<PageRoute<dynamic>>('shared covers');

/// 为使用 MIUIX 过渡主题的 Navigator 登记一次，覆盖 Material 和 MIUIX 路由。
/// 未安装观察者时原导航仍照常执行，不保留没有消费者的图片。
class MiuixSharedViewObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // 观察者只消费自己的导航，不将一个窗口的来源交给另一个窗口。
    // 没有来源的程序跳转不进入这条分支。
    final nav = navigator;
    // 只关联明确来源的普通页面，弹窗、根页和全屏对话框保留各自的过渡。
    final capture = nav == null ? null : _miuixSharedPending[nav];
    if (capture == null ||
        route is! PageRoute ||
        route.fullscreenDialog ||
        !identical(previousRoute, capture.sourceRoute)) {
      return;
    }
    // 同步 didPush 立即领取来源，不能误用到网络请求之后的另一页面。
    _miuixSharedPending[nav!] = null;
    // 领取发生在同步 didPush 中，页面首帧即可读取来源。
    // 一个来源只对应一个目标，不允许后续路由再次领取。
    capture.claimed = true;
    _miuixSharedRoutes[route] = capture;
    _miuixSharedCovers[previousRoute!] = route;
    // 源页保持原位，返回落点不会随传统四分之一屏视差一起滑走。
    // completed 在退出动画结束后完成，不能在 pop 请求发出时就释放图片。
    // 保留页面退出期间的最后一帧，防止 GPU 使用已经销毁的图像。
    route.completed.whenComplete(() {
      if (identical(_miuixSharedCovers[previousRoute], route)) {
        _miuixSharedCovers[previousRoute] = null;
      }
      _miuixSharedRoutes[route] = null;
      capture.dispose();
    });
  }
}

class _MiuixSharedCapture {
  _MiuixSharedCapture(
    this.image,
    this.resolveBounds,
    this.sourceRoute,
    this.radius,
  );
  // 位图只存在内存，既不落盘，也不跨账号或窗口共用。
  final ui.Image? image;
  // 位置通过回调读取，来源被刷新或窗口改变后不复用点击时的旧矩形。
  // 图像保留点击时外观，位置则绑定当前实际布局。
  final Rect? Function() resolveBounds;
  final ModalRoute<dynamic>? sourceRoute;
  final double radius;
  // claimed 表示生命周期已交给目标路由，未领取的图片由调用结束时释放。
  // disposed 保护异常清理与正常退出重合时的重复释放。
  bool claimed = false, disposed = false;
  void dispose() {
    // 未领取与正常退出可能走同一个清理边界，图像只能释放一次。
    if (disposed) return;
    disposed = true;
    image?.dispose();
  }
}

/// 外部放大按钮可通过 `GlobalKey<MiuixSharedViewSourceState>` 调用 open。
/// key 应指向实际图片或卡片，不应把不相关标题和工具按钮一起包入来源。
/// 控制器只绑定界面寿命；它不保留账号、不发起数据读取，也不更改原导航结果。
///
/// 指针按下只准备上一帧，抬起是否打开仍由原点击回调决定。
/// 没有导航的滚动、长按和取消会在指针分发结束后释放临时帧。
/// 来源图片被路由领取后，由路由退出完成时释放，二者不能重复销毁。
/// 源控件在目标页打开期间销毁时，路由仍持有自己的图片直至退出。
///
/// 几何回调只查询当前布局，不主动滚动列表或重建来源页面。
/// 来源滚出当前窗口时不把用户拉回旧位置，而是使用淡出关闭。
/// 下一次点击会读取新的位置和新图层，不长期缓存失效截图。
/// 此状态对象不跨 Navigator、引擎或 Activity 传递。
class MiuixSharedViewSourceState extends State<MiuixSharedViewSource> {
  final _boundary = GlobalKey();
  bool _opening = false;
  // 按下时保存上一帧，避免按钮的按压重绘让抬手截图失效。
  ui.Image? _prepared;

  // 图像采集只记录 Flutter 图层，不编码 PNG，不访问文件或网络。
  // 像素比按来源面积限制，宽屏不为一张小卡分配整屏截图。
  ui.Image? _image(Rect bounds) {
    final boundary = _boundary.currentContext?.findRenderObject();
    // 平台纹理与未完成绘制的图层只做几何过渡。
    if (!widget.captureImage ||
        boundary is! RenderRepaintBoundary ||
        boundary.debugNeedsPaint) {
      return null;
    }
    // 像素预算约一百万，浮点逻辑坐标不取整以保留卡片边缘。
    // 缩小位图只影响过渡清晰度，不改变终点页面的真实分辨率。
    final ratio = math.min(
      MediaQuery.devicePixelRatioOf(context),
      math.sqrt(1000000 / (bounds.width * bounds.height)),
    );
    return boundary.toImageSync(pixelRatio: ratio);
  }

  void _prepare(PointerDownEvent event) {
    _prepared?.dispose();
    _prepared = null;
    // 锁定和减少动画时不捕获页面，即使程序直接调用回调也遵循相同约束。
    if (MiuixBackGestureScope.blockedOf(context) ||
        MediaQuery.disableAnimationsOf(context)) {
      return;
    }
    // 按压只准备视觉帧，不领取下一页面，也不抢占滚动手势。
    // 实际是否导航仍由原控件的点击回调决定。
    final bounds = _bounds(Navigator.of(context));
    if (bounds == null) return;
    try {
      _prepared = _image(bounds);
    } catch (_) {
      /* 几何过渡仍可用。 */
    }
  }

  void _releasePrepared() {
    // 释放任务绑定图片身份，后来的第二次按压不会被旧回调误清理。
    // 长按、滚动或点击未导航时同样清理，不形成来源图片缓存。
    final image = _prepared;
    // onTap 在本轮指针分发中领取图片，未导航的点击在绘制后释放。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!identical(_prepared, image)) return;
      _prepared = null;
      image?.dispose();
    });
  }

  @override
  void dispose() {
    _prepared?.dispose();
    _prepared = null;
    super.dispose();
  }

  // 所有矩形使用当前 Navigator 的逻辑像素，不能混用屏幕物理坐标。
  // 局部坐标先转全局再转宿主，兼容嵌套 Navigator 与平板侧栏偏移。
  Rect? _bounds(NavigatorState navigator) {
    // 返回时重新读取来源位置，旋转、分屏和列表更新后不使用旧坐标。
    final box = _boundary.currentContext?.findRenderObject();
    final host = navigator.context.findRenderObject();
    if (!mounted ||
        box is! RenderBox ||
        host is! RenderBox ||
        !box.attached ||
        !host.attached ||
        !box.hasSize ||
        !host.hasSize) {
      return null;
    }
    final rect = host.globalToLocal(box.localToGlobal(Offset.zero)) & box.size;
    // 来源被移除或移到屏幕外时淡出，不把页面收回一个错误的位置。
    if (rect.isEmpty || !(Offset.zero & host.size).overlaps(rect)) return null;
    return rect;
  }

  Future<void> open(VoidCallback navigate) async {
    // 同一来源只接纳一次点击，等待截图不能堆叠多个详情页面。
    if (_opening || !mounted) return;
    final navigator = Navigator.of(context);
    final route = ModalRoute.of(context);
    // 无障碍减少动画时直接导航，不截图、不等待下一帧。
    if (MiuixBackGestureScope.blockedOf(context)) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      navigate();
      return;
    }
    // 截图失败只放弃过渡，原页面操作仍执行一次。
    // 来源在本次打开前已经销毁时不创建孤立的目标窗口。
    _opening = true;
    _MiuixSharedCapture? capture;
    try {
      final bounds = _bounds(navigator);
      final boundary = _boundary.currentContext?.findRenderObject();
      if (bounds != null && boundary is RenderRepaintBoundary) {
        // 点击只记录图层，不等待 PNG 编码或文件 I/O。
        final image = _prepared ?? _image(bounds);
        // 图片交给路由后不再由按压生命周期管理，避免动画中途提前释放。
        _prepared = null;
        if (!mounted || !navigator.mounted || route?.isCurrent == false) {
          image?.dispose();
          return;
        }
        capture = _MiuixSharedCapture(
          image,
          () => _bounds(navigator),
          route,
          widget.radius,
        );
      }
    } catch (_) {
      // 绘制尚未就绪或平台截图失败只取消动画，不阻断原本的页面操作。
      capture?.dispose();
      capture = null;
    } finally {
      _opening = false;
    }
    if (!mounted || !navigator.mounted || route?.isCurrent == false) {
      capture?.dispose();
      return;
    }
    // 来源只在回调的同步导航阶段有效，异步网络完成后的跳转不复用旧截图。
    // 登记仅在导航回调执行期间存在，不把异步业务结果绑定到旧点击。
    // 回调抛错时仍撤销登记，避免污染下次普通页面打开。
    _miuixSharedPending[navigator] = capture;
    try {
      navigate();
    } finally {
      _miuixSharedPending[navigator] = null;
      if (capture?.claimed == false) capture?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: _prepare,
    onPointerUp: (_) => _releasePrepared(),
    onPointerCancel: (_) => _releasePrepared(),
    child: RepaintBoundary(
      key: _boundary,
      // 截图层不替换子树或控制器，返回后保留原滚动与输入状态。
      child: widget.builder(context, open),
    ),
  );
}

class _MiuixSharedViewTransition extends StatelessWidget {
  const _MiuixSharedViewTransition({
    required this.route,
    required this.capture,
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });
  final PageRoute<dynamic> route;
  final _MiuixSharedCapture capture;
  final Animation<double> animation, secondaryAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) => _MiuixPredictivePageTransition(
    // 共享转场使用同一导航所有权仲裁，弹窗仍可优先接管系统返回。
    // 取消保留当前页面，提交才由原路由移除详情。
    route: route,
    child: child,
    // 复用原手势所有权与收尾状态，不能另外注册一个竞争返回的观察者。
    builder: (context, gesture, child) => AnimatedBuilder(
      animation: Listenable.merge([animation, secondaryAnimation]),
      child: child,
      builder: (context, child) => LayoutBuilder(
        builder: (context, constraints) {
          final owns = identical(gesture.owner, route);
          // 拖动直接跟随系统进度，取消和提交继续沿原曲线接续，不跳到另一轨道。
          final p = MediaQuery.disableAnimationsOf(context)
              ? 1.0
              : owns
              ? gesture.resolveTrack(
                  animation.value,
                  MiuixNavigationTransitionMotion.curve,
                )
              : MiuixNavigationTransitionMotion.resolve(animation);
          // 终点来自目标路由的布局约束，不假定手机全屏尺寸。
          // 旋转、分屏和桌面窗口改变后按本帧可用空间重新计算。
          final full = Offset.zero & constraints.biggest;
          final source = capture.resolveBounds();
          // 打开沿点击位置展开；来源失效的返回仅淡出，保留可操作的正常导航栈。
          final valid = source != null && !capture.disposed;
          // 来源失效时保持目标全尺寸，仅改变透明度，不飞向屏幕角落。
          // 正常情况下只变换视觉容器，内部文本继续按终点尺寸布局。
          var rect = valid ? Rect.lerp(source, full, p)! : full;
          if (owns && valid) {
            // 左右边缘提供相反的横向反馈，最终仍准确收回同一个来源位置。
            final sign = gesture.swipeEdge == SwipeEdge.right ? -1.0 : 1.0;
            rect = rect.shift(Offset(sign * 40 * p * (1 - p), 0));
          }
          final covered = _miuixSharedCovers[route] == null
              ? secondaryAnimation.value
              : 0.0;
          // 新页面覆盖当前详情时仍保留原路由的正常视差；共享展开的来源页保持静止。
          // 保留详情被另一个页面覆盖时的原有视差，避免新增一条割裂的导航轨道。
          // 静态终点始终回到零位移，不给后续触摸留下坐标偏差。
          return FractionalTranslation(
            translation: Offset(-covered / 4, 0),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 遮罩独立于缩放内容，动画中不会从卡片边缘漏出未覆盖区域。
                ColoredBox(color: Colors.black.withValues(alpha: .16 * p)),
                Positioned.fromRect(
                  rect: rect,
                  child: ClipRRect(
                    key: const ValueKey('miuix-shared-view-flight'),
                    borderRadius: BorderRadius.circular(
                      capture.radius * (1 - p),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // 容器本身保持不透明，避免目标文字和底下的列表文字重叠。
                        ColoredBox(
                          color: Theme.of(context).colorScheme.surface
                              .withValues(alpha: valid ? 1 : p),
                        ),
                        // 内容按最终页面尺寸排版后缩放，不在动画每帧反复换行。
                        Opacity(
                          // 目标内容较早完成显现，缩短两组文字重叠的交叉淡入区间。
                          opacity: valid
                              ? (p * 2).clamp(0.0, 1.0)
                              : p.clamp(0.0, 1.0),
                          child: FittedBox(
                            // 等比放大并裁切窗口，动画中不把文字横向拉长。
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            child: SizedBox(
                              width: full.width,
                              height: full.height,
                              child: child,
                            ),
                          ),
                        ),
                        if (valid && capture.image != null && p < 1)
                          IgnorePointer(
                            child: Opacity(
                              opacity: (1 - p * 3).clamp(0.0, 1.0),
                              // 来源保持捕获时的内容，仅在打开和收回初段参与衔接。
                              child: RawImage(
                                image: capture.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
}
