part of '../miuix_widgets.dart';

/// 为已有的页内导航提供返回预览，不复制页面、控制器或业务状态。
/// history 必须依次包含之前的位置和当前位置；提交才调用 onBack。
/// 预览帧只存在内存中，退出此组件后释放，不写入磁盘。
class MiuixBackHistory extends StatefulWidget {
  // handlesBack 可独立关闭，适用于底部标签切换后仍保留的隐藏页面。
  // canPreview 仅限制连续预览，不影响原有的普通返回委派。
  // 位置列表按值比较，重建新列表本身不会捕获图片。
  // 非空尺寸检查保证计算截图比例时不会除以零。
  // onBack 可以拒绝退出，此时 history 不变，当前页面继续显示。
  // 手势进度已经由公共驱动归一化，页面层不再计算阈值。
  // 拖动只读内存中的来源画面，不访问平台存储或网络。
  // 绘制边界由元素生命周期管理，不放进全局静态缓存。
  // 标识由调用方提供，不根据标题、列表索引或显示文本猜测来源。
  // 同一页面刷新保持同一个标识，真正进入新位置才添加标识。
  const MiuixBackHistory({
    super.key,
    required this.history,
    required this.onBack,
    required this.child,
    this.handlesBack = true,
    this.canPreview = true,
  });

  final List<Object> history;
  // 列表需是当前构建的快照；直接修改旧列表会失去前后位置对比。
  // 上层负责真正退栈，可异步结束登录、导出等平台操作。
  final Future<void> Function() onBack;
  // 只绘制当前页面，历史页不创建另一份控制器或定时器。
  final Widget child;
  // 只有页内导航可退时接管离散返回，根页面仍交给外层 Navigator。
  final bool handlesBack;
  // 嵌套栈、保存中和系统授权流程可拒绝预览，保持原退出约束。
  final bool canPreview;

  @override
  State<MiuixBackHistory> createState() => _MiuixBackHistoryState();
}

class _MiuixBackHistoryState extends State<MiuixBackHistory>
    with SingleTickerProviderStateMixin {
  final _boundary = GlobalKey();
  // GlobalKey 只定位绘制边界，不把它放到不同历史分支中复制。
  // 每个仍可返回的位置只保留一帧，覆盖旧帧前先释放句柄。
  final _frames = <Object, ui.Image>{};
  // 仅在手势期间驱动布局，常规刷新不会捕获图片。
  late final _progress = AnimationController(vsync: this, value: 0);
  // 动画值表示当前页离开比例，零始终表示原页面完整显示。
  bool _committing = false;
  // 从物理触摸边缘确定方向，右侧起手不能仍向右移动页面。
  SwipeEdge _edge = SwipeEdge.left;

  ui.Image? get _previous => widget.history.length < 2
      ? null
      : _frames[widget.history[widget.history.length - 2]];
  // 只展示直接来源，不能把更早的历史画面误当作下一次返回目标。

  @override
  void didUpdateWidget(MiuixBackHistory oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 普通状态更新不属于导航，不能用刷新后的内容覆盖来源画面。
    if (listEquals(oldWidget.history, widget.history)) return;
    // 此时边界仍是上一帧的实际绘制结果，包含滚动位置和展开状态。
    // 不通过截图插件或系统截图，避免 FLAG_SECURE 与额外权限依赖。
    if (oldWidget.history.isNotEmpty &&
        widget.history.contains(oldWidget.history.last)) {
      // 只有旧位置仍留在新栈中才捕获，退出时不再保存离开的详情。
      final render = _boundary.currentContext?.findRenderObject();
      if (render is _MiuixBackRenderBoundary && render.canCapture) {
        // 使用逻辑像素，单帧最多一百万像素，避免高分辨率手机放大内存。
        final pixels = render.size.width * render.size.height;
        // 长宽同比缩放，不通过改变页面约束来制作缩略图。
        final ratio = math.min(1.0, math.sqrt(1000000 / pixels));
        // 同步取得上一帧的图层；光栅化由引擎处理，不等待平台截图。
        final image = render.toImageSync(pixelRatio: ratio);
        _release(_frames.remove(oldWidget.history.last));
        _frames[oldWidget.history.last] = image;
        // 相同位置重复进入会替换为最近画面，保留最新滚动来源。
      }
    }
    // 退出的位置不再参与预览，释放其图片，不能累积跨页面历史。
    final stale = _frames.keys
        .where((key) => !widget.history.contains(key))
        .toList();
    // 先生成键列表再移除，不能遍历 Map 时修改它的结构。
    for (final key in stale) {
      _release(_frames.remove(key));
    }
    // 导航完成后真实页面接替预览，不能沿用上一手势的位移。
    _progress.value = 0;
  }

  void _release(ui.Image? image) {
    // RawImage 可能仍在当前帧绘制，延至本帧完成后释放图像句柄。
    if (image == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => image.dispose());
    // 图像句柄没有跨组件共享，移出 Map 后只在这里释放一次。
  }

  Future<void> _cancel() async {
    // 已提交的返回不能被迟到的取消事件反向触发第二次导航。
    if (_committing) return;
    await _progress.animateTo(
      0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
    // 取消只回收位移，不调用 onBack，也不使历史标识变化。
  }

  Future<void> _back() async {
    // 锁定期间不能由普通返回回调修改隐藏的页内位置栈。
    if (MiuixBackGestureScope.blockedOf(context)) return;
    // 硬件返回与手势提交可能紧邻到来，只允许一个待完成操作。
    if (_committing) return;
    _committing = true;
    try {
      // 离散返回直接执行原操作；预测手势先贴合到目标帧再修改页面。
      if (_progress.value > 0 && _previous != null) {
        // 只有实际拖动过才补齐过渡，硬件返回不额外等待这段动画。
        await _progress.animateTo(
          1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
        );
      }
      // 等待平台清理期间保留原页面；失败也由原页面展示原因。
      if (mounted && !MiuixBackGestureScope.blockedOf(context)) {
        await widget.onBack();
      }
    } finally {
      // 调用方取消退出或报告错误时，也必须恢复可操作的当前页。
      if (mounted) _progress.value = 0;
      _committing = false;
    }
  }

  @override
  void dispose() {
    // dispose 不执行 onBack，销毁隐藏页面不能被算成用户返回。
    _progress.dispose();
    for (final frame in _frames.values) {
      _release(frame);
    }
    _frames.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope<Object?>(
    // 普通返回先委派给原导航，不能因子路由能预览就放行外层根路由。
    canPop: !widget.handlesBack && !MiuixBackGestureScope.blockedOf(context),
    onPopInvokedWithResult: (didPop, _) {
      // 已经由外层正常弹出的路由不再执行一次页内返回。
      if (!didPop && widget.handlesBack) unawaited(_back());
    },
    child: _buildPreview(context),
  );

  Widget _buildPreview(BuildContext context) => MiuixPredictiveBackHandler(
    enabled: widget.handlesBack,
    handleDiscreteBack: false,
    // 预测事件和离散返回分开仲裁，防止根路由漏接嵌套栈的硬件返回。
    canStart: (_) => widget.canPreview && !_committing && _previous != null,
    onProgress: (event) {
      _edge = event.swipeEdge == MiuixNavSwipeEdge.right
          ? SwipeEdge.right
          : SwipeEdge.left;
      // 新一轮拖动可立即接续取消动画，不等待它归零后再跟手。
      _progress.stop();
      _progress.value = event.progress;
    },
    onCommit: () => unawaited(_back()),
    // 回调不等待动画阻塞平台通道；重入由 _committing 防护。
    onCancel: () => unawaited(_cancel()),
    child: AnimatedBuilder(
      animation: _progress,
      // 边界与实际页面保持同一元素位置，不重建页面或其滚动控制器。
      child: _MiuixBackFrameBoundary(key: _boundary, child: widget.child),
      builder: (context, child) {
        final progress = _progress.value;
        final previous = _previous;
        final direction = _edge == SwipeEdge.left ? 1.0 : -1.0;
        // 保持当前页全尺寸绘制，预览帧只负责露出的下层区域。
        // 仅图像参与下层视差，真实控件始终保持同一个元素树。
        return Stack(
          fit: StackFit.expand,
          children: [
            if (progress > 0 && previous != null)
              // 零进度不插入 RawImage，静止页面没有额外图片合成。
              // 预览图无交互和语义，读屏始终只访问当前页面。
              ExcludeSemantics(
                child: IgnorePointer(
                  child: FractionalTranslation(
                    translation: Offset(-direction * (1 - progress) / 4, 0),
                    child: RawImage(image: previous, fit: BoxFit.fill),
                  ),
                ),
              ),
            FractionalTranslation(
              translation: Offset(direction * progress, 0),
              child: IgnorePointer(ignoring: progress > 0, child: child),
              // 手势中的点击不能落在正在移动的控件上触发另一轮导航。
            ),
          ],
        );
      },
    ),
  );
}

// 读取受保护的 layer 必须在 RenderObject 子类内完成。
// 不能用 debugLayer 判定 Release 能力；它在 Release 恒为 null。
class _MiuixBackRenderBoundary extends RenderRepaintBoundary {
  // Release 也检查真实图层，避免首次绘制前调用 toImageSync。
  // debugNeedsPaint 只在断言构建提供补充检查，不作为 Release 图层依据。
  bool get canCapture =>
      attached &&
      hasSize &&
      layer is OffsetLayer &&
      !debugNeedsPaint &&
      !size.isEmpty;
}

// 与普通 RepaintBoundary 使用相同的布局、绘制及语义行为。
class _MiuixBackFrameBoundary extends RepaintBoundary {
  // RenderObject 的生命周期仍由 Flutter 元素管理，图片另行持有。
  const _MiuixBackFrameBoundary({super.key, required super.child});

  @override
  RenderRepaintBoundary createRenderObject(BuildContext context) =>
      _MiuixBackRenderBoundary();
}
