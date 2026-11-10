part of '../miuix_widgets.dart';

/// Blur pipelines exposed by the current MIUIX example's `BlurredBar` helper.
///
/// This enum describes the rendering pipeline, not merely an animation style.
/// The modes use different radii, tint profiles, and scroll rules.
/// Keeping that distinction in the component library lets applications build
/// the same settings surface as the upstream sample without reimplementing its
/// private `BlurredBar` wrapper around every [MiuixTopAppBar].
///
/// Both modes require [MiuixTopAppBar.glass] to be true. When glass is false,
/// the requested mode is retained as configuration but the bar paints the same
/// opaque MIUIX surface as the original example does on unsupported devices.
/// This makes it safe to preserve a user's selection while runtime blur support
/// is temporarily unavailable or disabled for performance reasons.
enum MiuixTopAppBarBlurStyle {
  /// Uniform 25dp texture blur with an 80% surface blend.
  gaussian,

  /// Top-heavy 10dp blur that fades clear toward the lower edge.
  progressive,

  /// Persistent top-to-bottom HyperOS glass gradient.
  ///
  /// Unlike [progressive], this material is visible before the page scrolls.
  /// It is the default HyperOS 4 presentation; the older uniform and
  /// scroll-revealed pipelines remain available explicitly.
  gradient,
}

/// Visual treatment for compact top-app-bar action slots.
///
/// This controls the action surfaces only. Every action child retains its own
/// callback, focus state, popup anchor, tooltip, semantics, and indication.
/// The wrapper therefore works with icon buttons and arbitrary popup triggers
/// without turning the group into a second competing gesture target.
enum MiuixTopAppBarActionStyle {
  /// Adaptive HyperOS actions: transparent with an expanded title, circular
  /// glass when the compact title is visible. Expanded actions share the
  /// title's backdrop instead of sampling it through a second circular layer.
  ///
  /// The compact row already spaces icon centers by 40dp and exposes 48dp
  /// Android semantic targets. The shared material follows those established
  /// measurements: every item has a 44dp visible circle inside its 48dp
  /// Android interaction target, with an 8dp visual gap. This keeps multiple
  /// compact actions from becoming one
  /// elongated oval while retaining 48dp popup anchors and semantic targets.
  ///
  /// Only the circular silhouettes sample the backdrop. Their 8dp gaps and all
  /// other empty title space remain part of the top-bar material instead of
  /// gaining a second opaque rectangle. Each circle reads the same global
  /// glass intensity and clips its filter to its own non-overlapping bounds.
  glass,

  /// Source-compatible icon-only slots without a shared background.
  ///
  /// Use this during migration when an application already provides its own
  /// action container. It removes only the shared glass surface and leaves the
  /// action layout, minimum target, title avoidance, and callbacks unchanged.
  plain,
}

/// Public source metrics shared by large and compact top app bars.
abstract final class MiuixTopAppBarDefaults {
  static const double titlePadding = 26;
  static const double navigationIconPadding = 16;
  static const double actionIconPadding = 16;
  static const double collapsedHeight = 52;
  static const double smallTopAppBarCenterHeight = 50;
  static const double largeTitleBottomPadding = 4;
  static const double subtitleBottomPadding = 8;
}

/// Hoistable source state for a collapsing [MiuixTopAppBar].
class MiuixTopAppBarState extends ChangeNotifier {
  MiuixTopAppBarState({
    double initialHeightOffsetLimit = -double.maxFinite,
    double initialHeightOffset = 0,
    double initialContentOffset = 0,
  }) : _heightOffsetLimit = initialHeightOffsetLimit.isFinite
           ? math.min(0.0, initialHeightOffsetLimit)
           : -double.maxFinite,
       _heightOffset = 0,
       _contentOffset = initialContentOffset.isFinite
           ? initialContentOffset
           : 0 {
    _heightOffset = _coerceHeight(initialHeightOffset);
  }

  double _heightOffsetLimit;
  double _heightOffset;
  double _contentOffset;
  // 布局内先同步字段，公开通知等待安全阶段；不能让下一次写入读到旧高度。
  bool _pendingReplaceNotification = false;

  // 显式写入已发布全部最新字段时，消费旧的待发布标记。
  // 帧后不能把同一份值再次当成尚未发送的新状态。
  void _publishChangedState() {
    _pendingReplaceNotification = false;
    notifyListeners();
  }

  double get heightOffsetLimit => _heightOffsetLimit;

  set heightOffsetLimit(double value) {
    final next = value.isFinite ? math.min(0.0, value) : -double.maxFinite;
    final nextHeight = _coerceHeight(_heightOffset, limit: next);
    if (next == _heightOffsetLimit && nextHeight == _heightOffset) return;
    _heightOffsetLimit = next;
    _heightOffset = nextHeight;
    _publishChangedState();
  }

  double get heightOffset => _heightOffset;

  set heightOffset(double value) {
    final next = _coerceHeight(value);
    if (next == _heightOffset) return;
    _heightOffset = next;
    _publishChangedState();
  }

  double get contentOffset => _contentOffset;

  set contentOffset(double value) {
    final next = value.isFinite ? value : 0.0;
    if (next == _contentOffset) return;
    _contentOffset = next;
    _publishChangedState();
  }

  double get collapsedFraction {
    if (_heightOffsetLimit == 0) return 0;
    return (_heightOffset / _heightOffsetLimit).clamp(0.0, 1.0);
  }

  double get overlappedFraction {
    if (_heightOffsetLimit == 0) return 0;
    final overlap = (_heightOffsetLimit - _contentOffset).clamp(
      _heightOffsetLimit,
      0.0,
    );
    return (1 - overlap / _heightOffsetLimit).clamp(0.0, 1.0);
  }

  double _coerceHeight(double value, {double? limit}) {
    final minimum = limit ?? _heightOffsetLimit;
    final finite = value.isFinite ? value : 0.0;
    return finite.clamp(minimum, 0.0);
  }

  void _replace({
    required double heightOffsetLimit,
    required double heightOffset,
    required double contentOffset,
    bool notify = true,
  }) {
    final nextLimit = math.min(0.0, heightOffsetLimit);
    final nextHeight = _coerceHeight(heightOffset, limit: nextLimit);
    final nextContent = contentOffset.isFinite ? contentOffset : 0.0;
    if (nextLimit == _heightOffsetLimit &&
        nextHeight == _heightOffset &&
        nextContent == _contentOffset &&
        (!notify || !_pendingReplaceNotification)) {
      return;
    }
    _heightOffsetLimit = nextLimit;
    _heightOffset = nextHeight;
    _contentOffset = nextContent;
    // 仅延迟订阅通知，字段先保持一致；公开 setter 的普通同步合同不变。
    // 同值请求不能清除已有待发布标记，否则帧后通知会丢失。
    if (!notify) {
      // 字段已经一致，帧后即使值未再变化，也仍须发布一次真实变更。
      _pendingReplaceNotification = true;
      return;
    }
    _publishChangedState();
  }
}

/// Drives the collapse state of a MIUIX large [MiuixTopAppBar].
///
/// The original component consumes vertical nested-scroll movement, then snaps
/// to the expanded or collapsed state when scrolling stops. [MiuixScaffold]
/// wires this object to descendant scrollables automatically.
class MiuixTopAppBarScrollBehavior extends ChangeNotifier {
  /// Creates a scroll behavior in its fully expanded state.
  MiuixTopAppBarScrollBehavior({
    this.snapDuration = const Duration(milliseconds: 300),
    MiuixTopAppBarState? state,
  }) : state = state ?? MiuixTopAppBarState() {
    final sourceLimit = this.state.heightOffsetLimit;
    if (sourceLimit.isFinite && sourceLimit < 0 && sourceLimit > -1000000) {
      _collapseExtent = -sourceLimit;
      _collapseFraction = this.state.collapsedFraction;
    }
    _contentOffset = this.state.contentOffset;
    this.state.addListener(_handleHoistedStateChange);
    _syncHoistedState();
    _settleTicker = Ticker(_tickSettle);
  }

  /// Maximum time allowed for the final source spring.
  ///
  /// The current MIUIX component uses a critically damped spring with a
  /// stiffness of 2500 rather than a duration tween. This compatibility value
  /// remains public so existing callers can disable settling with
  /// [Duration.zero] or cap an unusually long custom frame sequence.
  final Duration snapDuration;

  /// Independently observable source height and content offsets.
  final MiuixTopAppBarState state;

  bool _syncingHoistedState = false;

  double _collapseFraction = 0;
  double _collapseExtent = 38;
  double _contentOffset = 0;
  late final Ticker _settleTicker;
  Simulation? _settleSimulation;
  Duration? _settleSimulationStart;
  bool _settleIsDecay = false;
  double _settleTargetHeight = 0;
  bool _hasExplicitCollapseState = false;
  bool _restorationConsumed = false;
  // SmallTopAppBar pins the shared source height range to zero without losing
  // the independently accumulated content offset. A later large bar uses this
  // marker to restore its collapsed/expanded endpoint from that offset.
  bool _pinnedBySmallTopAppBar = false;
  bool _smallTopBarPinScheduled = false;
  bool _listenerNotificationScheduled = false;
  bool? _contentScrollable;
  int _topBarModeGeneration = 0;
  bool _disposed = false;
  bool _reduceMotion = false;

  /// Zero is fully expanded and one is fully collapsed.
  double get collapseFraction => _collapseFraction;

  /// Signed source content offset used by progressive top-bar blur.
  ///
  /// Upward scrolling is negative, matching Compose's nested-scroll state.
  /// The blur helper reaches full opacity after 48 logical pixels of upward
  /// content movement, independently of the large title's collapse extent.
  ///
  /// This value intentionally differs from [collapseFraction]. The large title
  /// saturates after its measured title column has collapsed, while list
  /// content can continue travelling behind the compact bar. Upstream keeps
  /// both quantities in its scroll state and uses the unbounded content offset
  /// for the progressive effect. Deriving one from the other would stop a
  /// title-only bar at roughly 79% blur because its source collapse extent is
  /// 38dp but the blur reveal distance is 48dp.
  ///
  /// Calls to [syncMetrics] preserve the raw scroll distance. Direct calls to
  /// [setCollapseFraction] synthesize the equivalent title-column distance so
  /// existing animation and test clients still receive deterministic state.
  /// Overscroll above the leading edge resolves to zero because the source
  /// blur does not appear while content is being pulled downward.
  double get contentOffset => _contentOffset;

  /// Applies a normalized collapse value.
  void setCollapseFraction(double value) {
    _cancelSettle();
    _hasExplicitCollapseState = true;
    final next = value.clamp(0.0, 1.0);
    final nextOffset = -next * _collapseExtent;
    if ((next - _collapseFraction).abs() < .0001 &&
        (nextOffset - _contentOffset).abs() < .0001) {
      return;
    }
    _collapseFraction = next;
    _contentOffset = nextOffset;
    _notifyStateAndListeners();
  }

  /// Expands the bar immediately, for example after changing root pages.
  void expand() {
    _cancelSettle();
    setCollapseFraction(0);
  }

  /// Synchronizes the bar with metrics restored without a drag notification.
  ///
  /// PageStorage and platform state restoration can place a ScrollPosition at
  /// a non-zero offset during layout. Compose derives its height offset from
  /// nested-scroll state, while Flutter emits only a metrics notification for
  /// this restoration path; consuming it prevents an expanded title over a
  /// deeply restored list.
  void syncMetrics(ScrollMetrics metrics) {
    if (metrics.axis != Axis.vertical) return;
    if (!_hasScrollableContent(metrics)) {
      // A page that already fits inside its viewport has no compact reading
      // state to reveal. Always-scrollable physics may still emit pull and
      // overscroll notifications for refresh, but those gestures must not
      // collapse the large title.
      expand();
      return;
    }
    _cancelSettle();
    // PageStorage and programmatic jumps can bypass handleNotification. A
    // shared SmallTopAppBar still pins heightOffset to zero on that path while
    // retaining the absolute content position for later large-bar recovery.
    final nextFraction = _pinnedBySmallTopAppBar
        ? 0.0
        : (metrics.pixels / _collapseExtent).clamp(0.0, 1.0);
    final nextOffset = -math.max(0.0, metrics.pixels);
    if ((nextFraction - _collapseFraction).abs() < .0001 &&
        (nextOffset - _contentOffset).abs() < .0001) {
      return;
    }
    _collapseFraction = nextFraction;
    _contentOffset = nextOffset;
    _notifyStateAndListeners();
  }

  /// Restores from an attached ScrollPosition unless the owner already set an
  /// authoritative top-bar state. Compose saves the two states separately;
  /// attaching a list must not overwrite an explicitly restored bar fraction.
  void _restoreFromMetrics(ScrollMetrics metrics) {
    if (_restorationConsumed) return;
    _restorationConsumed = true;
    if (_hasExplicitCollapseState) return;
    syncMetrics(metrics);
  }

  /// Keeps restored scroll metrics tied to the measured large-title column.
  ///
  /// Compose sets `heightOffsetLimit` to the height of that column, rather
  /// than to the visible difference between the expanded and collapsed
  /// surfaces. The Flutter widget supplies the matching source-calibrated
  /// extent because a scroll behavior can be created before its bar exists.
  void _attachCollapseExtent(double value) {
    if (!value.isFinite || value <= 0) return;
    final extentChanged = (value - _collapseExtent).abs() >= .0001;
    if (_smallTopBarPinScheduled) {
      // A large bar replaced the compact bar before its SideEffect frame.
      // Invalidate that deferred pin so it cannot overwrite the new owner.
      _topBarModeGeneration++;
      _smallTopBarPinScheduled = false;
    }
    _collapseExtent = value;
    if (!_pinnedBySmallTopAppBar) {
      if (extentChanged) _scheduleListenerNotification();
      return;
    }
    // Current TopAppBar.kt restores a shared state to the collapsed endpoint
    // whenever content moved upward while the compact bar kept height at zero.
    _collapseFraction = _contentOffset < 0 ? 1 : 0;
    _pinnedBySmallTopAppBar = false;
    _hasExplicitCollapseState = true;
    _scheduleListenerNotification();
  }

  /// Defers the source SmallTopAppBar SideEffect until this frame completes.
  void _schedulePinForSmallTopAppBar() {
    if ((_pinnedBySmallTopAppBar && _collapseFraction == 0) ||
        _smallTopBarPinScheduled) {
      return;
    }
    _smallTopBarPinScheduled = true;
    final generation = ++_topBarModeGeneration;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed || generation != _topBarModeGeneration) return;
      _smallTopBarPinScheduled = false;
      if (_pinnedBySmallTopAppBar && _collapseFraction == 0) return;
      _cancelSettle();
      _pinnedBySmallTopAppBar = true;
      _collapseFraction = 0;
      _hasExplicitCollapseState = true;
      _notifyStateAndListeners();
    });
  }

  /// Notifies external observers after a build-time large-bar restoration.
  void _scheduleListenerNotification() {
    if (_listenerNotificationScheduled) return;
    _listenerNotificationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed) return;
      _listenerNotificationScheduled = false;
      _notifyStateAndListeners();
    });
  }

  /// Consumes the vertical scroll notifications emitted below the scaffold.
  bool handleNotification(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (!_hasScrollableContent(notification.metrics)) {
      expand();
      return false;
    }
    if (_pinnedBySmallTopAppBar) {
      // A compact bar keeps heightOffset at zero, but the same connection must
      // retain contentOffset so a later large bar knows whether its compact
      // title should be visible. It never corrects the child scroll distance.
      if (notification is ScrollStartNotification) {
        _cancelSettle();
      } else if (notification is ScrollUpdateNotification ||
          notification is OverscrollNotification) {
        final nextOffset = -math.max(0.0, notification.metrics.pixels);
        _setContentOffset(nextOffset);
      }
      return false;
    }
    if (notification is ScrollStartNotification) {
      // A fresh pointer sequence owns the state immediately. Compose cancels
      // the running Animatable before applying nested-scroll deltas; retaining
      // a timer here made old settle frames fight a reversed gesture.
      _cancelSettle();
    } else if (notification case ScrollUpdateNotification(
      :final dragDetails,
      :final scrollDelta,
    )) {
      final delta = scrollDelta;
      if (delta == null) return false;
      if (dragDetails == null) {
        // State restoration and explicit jumps have no pointer delta to return
        // through correctBy. Synchronize both saved channels from the absolute
        // position, matching the package's established restoration contract.
        syncMetrics(notification.metrics);
        return false;
      }
      if (delta > 0) {
        // Compose consumes upward movement in onPreScroll until the measured
        // large-title column is fully collapsed. Its implementation returns
        // the complete available Y delta whenever heightOffset changed, even
        // when that single delta crosses the collapse limit. Flutter's
        // ScrollPosition has already accepted the delta when this notification
        // arrives, so return that complete update while the bar is changing.
        final consumed = _consumeCollapse(delta);
        if (consumed > 0) {
          final scrollable = notification.context == null
              ? null
              : Scrollable.maybeOf(notification.context!);
          scrollable?.position.correctBy(-delta);
        }
        if (consumed == 0) {
          _setContentOffset(_contentOffset - delta);
        }
      } else if (delta < 0) {
        // Downward movement belongs to the child until it reaches its leading
        // edge. Only the subsequent negative OverscrollNotification expands
        // the bar, mirroring upstream onPostScroll(available.y > 0).
        _setContentOffset(math.min(0.0, _contentOffset - delta));
      }
    } else if (notification case OverscrollNotification(
      :final dragDetails,
      :final overscroll,
    )) {
      if (dragDetails == null) {
        syncMetrics(notification.metrics);
        return false;
      }
      if (overscroll < 0) {
        _consumeExpand(-overscroll);
        _setContentOffset(0);
      } else if (overscroll > 0) {
        // A short list can reach its trailing boundary before the title is
        // collapsed. Upstream pre-scroll still gives that distance to the bar.
        _consumeCollapse(overscroll);
      }
    } else if (notification is ScrollEndNotification) {
      _settle(notification.dragDetails?.primaryVelocity ?? 0);
    }
    return false;
  }

  bool _hasScrollableContent(ScrollMetrics metrics) {
    final measured = metrics.maxScrollExtent - metrics.minScrollExtent > .5;
    // Collapsing the title also removes its leading content inset. A page that
    // was just barely taller than the viewport can therefore report a zero
    // range midway through the same gesture. Retain the authoritative range
    // measured while expanded so the bar does not oscillate; it is measured
    // again as soon as the title returns to its expanded endpoint.
    if (measured || _collapseFraction <= .0001) {
      _contentScrollable = measured;
    }
    return measured || (_contentScrollable ?? false);
  }

  double _consumeCollapse(double amount) {
    if (amount <= 0 || _collapseFraction >= 1) return 0;
    final current = _collapseFraction * _collapseExtent;
    final consumed = math.min(amount, _collapseExtent - current);
    _setCollapseFractionPreservingContent(
      (current + consumed) / _collapseExtent,
    );
    return consumed;
  }

  double _consumeExpand(double amount) {
    if (amount <= 0 || _collapseFraction <= 0) return 0;
    final current = _collapseFraction * _collapseExtent;
    final consumed = math.min(amount, current);
    _setCollapseFractionPreservingContent(
      (current - consumed) / _collapseExtent,
    );
    return consumed;
  }

  void _setCollapseFractionPreservingContent(double value) {
    _hasExplicitCollapseState = true;
    final next = value.clamp(0.0, 1.0);
    if ((next - _collapseFraction).abs() < .0001) return;
    _collapseFraction = next;
    _notifyStateAndListeners();
  }

  /// Commits a simulation endpoint without the live-frame de-duplication gap.
  void _setCollapseFractionExact(double value) {
    _hasExplicitCollapseState = true;
    final next = value.clamp(0.0, 1.0);
    if (next == _collapseFraction) return;
    _collapseFraction = next;
    _notifyStateAndListeners();
  }

  void _setContentOffset(double value) {
    if ((value - _contentOffset).abs() < .0001) return;
    _contentOffset = value;
    _notifyStateAndListeners();
  }

  /// Applies the active host's accessibility motion preference.
  ///
  /// A behavior may outlive one concrete TopAppBar, so the widget supplies
  /// this context-dependent signal whenever it builds. An active settle is
  /// stopped immediately and its stable endpoint is committed after the
  /// current frame to avoid notifying an AnimatedBuilder during its build.
  void _setReduceMotion(bool value) {
    if (_reduceMotion == value) return;
    _reduceMotion = value;
    if (!value || _settleSimulation == null) return;
    final target = _collapseFraction < .5 ? 0.0 : 1.0;
    _cancelSettle();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_disposed || !_reduceMotion) return;
      _setCollapseFractionPreservingContent(target);
    });
  }

  /// Continues a released fling with Android's spline decay before snapping.
  ///
  /// `rememberSplineBasedDecay()` uses Android's platform spline. Flutter's
  /// [ClampingScrollSimulation] is derived from the same SplineOverScroller
  /// equations, so the height-offset channel can keep the source release
  /// velocity without inventing a cubic approximation.
  void _settle(double velocity) {
    _cancelSettle();
    // TopAppBar.kt deliberately skips values below one percent as well as the
    // exactly collapsed endpoint to avoid float-noise settle animations.
    if (_collapseFraction < .01 || _collapseFraction == 1) return;
    if (_reduceMotion || snapDuration == Duration.zero) {
      _setCollapseFractionPreservingContent(_collapseFraction < .5 ? 0 : 1);
      return;
    }
    final height = -_collapseFraction * _collapseExtent;
    if (velocity.abs() > 1) {
      _startSettleSimulation(
        ClampingScrollSimulation(position: height, velocity: velocity),
        isDecay: true,
      );
    } else {
      _startSnapFromHeight(height);
    }
  }

  /// Starts the exact default `spring(stiffness = 2500f)` snap channel.
  void _startSnapFromHeight(double height) {
    final targetFraction = _collapseFraction < .5 ? 0.0 : 1.0;
    final targetHeight = -targetFraction * _collapseExtent;
    if ((height - targetHeight).abs() < .01) {
      _setCollapseFractionExact(targetFraction);
      _cancelSettle();
      return;
    }
    _settleTargetHeight = targetHeight;
    _startSettleSimulation(
      SpringSimulation(
        SpringDescription.withDampingRatio(mass: 1, stiffness: 2500, ratio: 1),
        height,
        targetHeight,
        0,
        tolerance: const Tolerance(distance: .01, velocity: .01),
      ),
      isDecay: false,
    );
  }

  /// Installs one frame-synchronized simulation without recreating the ticker.
  void _startSettleSimulation(Simulation simulation, {required bool isDecay}) {
    _settleSimulation = simulation;
    _settleIsDecay = isDecay;
    _settleSimulationStart = null;
    if (!_settleTicker.isActive) _settleTicker.start();
  }

  /// Samples decay and spring state from Flutter's frame clock.
  void _tickSettle(Duration elapsed) {
    final simulation = _settleSimulation;
    if (simulation == null) return;
    _settleSimulationStart ??= elapsed;
    final stageElapsed = elapsed - _settleSimulationStart!;
    final seconds =
        stageElapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final rawHeight = simulation.x(seconds);
    final height = rawHeight.clamp(-_collapseExtent, 0.0);
    _setCollapseFractionPreservingContent(-height / _collapseExtent);

    if (_settleIsDecay) {
      // Compose stops its decay as soon as more than half a pixel is left
      // unconsumed at either height boundary, then applies the snap only when
      // the bar is still between its endpoints.
      final hitBoundary = (rawHeight - height).abs() > .5;
      if (hitBoundary || simulation.isDone(seconds)) {
        if (_collapseFraction > .01 && _collapseFraction < 1) {
          _startSnapFromHeight(height);
          _settleSimulationStart = elapsed;
        } else {
          _cancelSettle();
        }
      }
      return;
    }

    if (simulation.isDone(seconds) || stageElapsed >= snapDuration) {
      _setCollapseFractionExact(
        (-_settleTargetHeight / _collapseExtent).clamp(0.0, 1.0),
      );
      _cancelSettle();
    }
  }

  /// Stops an in-flight settle without changing its last sampled frame.
  void _cancelSettle() {
    _settleSimulation = null;
    _settleSimulationStart = null;
    if (_settleTicker.isActive) _settleTicker.stop();
  }

  void _handleHoistedStateChange() {
    if (_syncingHoistedState || _disposed) return;
    final sourceLimit = state.heightOffsetLimit;
    if (sourceLimit.isFinite && sourceLimit < 0 && sourceLimit > -1000000) {
      _collapseExtent = -sourceLimit;
    }
    final nextFraction = state.collapsedFraction;
    final nextContent = state.contentOffset;
    if ((nextFraction - _collapseFraction).abs() < .0001 &&
        (nextContent - _contentOffset).abs() < .0001) {
      return;
    }
    _cancelSettle();
    _hasExplicitCollapseState = true;
    _collapseFraction = nextFraction;
    _contentOffset = nextContent;
    _notifyStateAndListeners();
  }

  // 把当前字段与通知时点分开控制，不让布局保护造成共享状态滞后。
  void _syncHoistedState({bool notify = true}) {
    if (_syncingHoistedState) return;
    _syncingHoistedState = true;
    state._replace(
      heightOffsetLimit: _pinnedBySmallTopAppBar ? 0 : -_collapseExtent,
      heightOffset: _pinnedBySmallTopAppBar
          ? 0
          : -_collapseFraction * _collapseExtent,
      contentOffset: _contentOffset,
      notify: notify,
    );
    _syncingHoistedState = false;
  }

  void _notifyStateAndListeners() {
    // 滚动边界随视口尺寸变化时，ScrollEnd/无指针更新可能在布局阶段到达。
    // 此时同步通知会让 Scaffold 在布局中 setState，产生框架异常和连锁重建。
    // 内部折叠值已经立即更新；只合并发布通知，不延迟正常手指拖动的状态。
    // 复用既有帧后通道，读取最新值并遵守 dispose，避免保存一份迟到旧状态。
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      // 延迟的是通知，不是共享状态本身；后续公开 setter 必须读到本次高度。
      // 否则先恢复折叠再恢复内容距离时，会把旧的展开高度重新写回控制器。
      _syncHoistedState(notify: false);
      _scheduleListenerNotification();
      return;
    }
    _syncHoistedState();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _cancelSettle();
    state.removeListener(_handleHoistedStateChange);
    _settleTicker.dispose();
    super.dispose();
  }
}

/// MIUIX top application bar with compact and scroll-collapsing large variants.
class MiuixTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Creates a MIUIX top application bar.
  const MiuixTopAppBar({
    super.key,
    required this.title,
    this.largeTitle,
    this.subtitle,
    this.leading,
    this.actions,
    this.large = true,
    // 正文需要完整小标题时显式启用；普通源布局仍采用原紧凑行。
    this.wrapSmallTitle = false,
    this.scrollBehavior,
    this.collapseFraction,
    this.color,
    this.glass = true,
    this.blurStyle = MiuixTopAppBarBlurStyle.gradient,
    this.actionStyle = MiuixTopAppBarActionStyle.glass,
    this.titleColor,
    this.largeTitleColor,
    this.subtitleColor,
    this.defaultWindowInsetsPadding = true,
    this.titlePadding = MiuixTopAppBarDefaults.titlePadding,
    this.navigationIconPadding = MiuixTopAppBarDefaults.navigationIconPadding,
    this.actionIconPadding = MiuixTopAppBarDefaults.actionIconPadding,
    this.expandedHeight,
    this.collapsedTitleAreaHeight,
    this.bottomContent,
    this.bottomContentHeight = 0,
    this.bottomContentExpandedTopPadding = 0,
  });

  /// Compact title and fallback large title.
  final String title;

  /// 小标题空间不足时将完整标题放到图标行下方，保持原操作位置。
  /// 使用MiuixScaffold的上下文尺寸；默认保留既有单行布局契约。
  final bool wrapSmallTitle;
  // 此选项只处理可用空间与字号，不缩短调用方的title字符串。
  // 两种模式复用原leading/actions实例，交互和弹窗锚点不会替换。

  /// Optional text used only by the expanded large-title presentation.
  final String? largeTitle;

  /// Optional supporting title shown below the main title.
  // Retained for source compatibility. Product pages use a single title and
  // place status or explanatory text in their body instead.
  final String? subtitle;

  /// Navigation icon slot.
  final Widget? leading;

  /// Action icon slots.
  final List<Widget>? actions;

  /// Whether this is the source component's collapsible large variant.
  final bool large;

  /// Optional controller used by a large bar to consume body scroll.
  final MiuixTopAppBarScrollBehavior? scrollBehavior;

  /// Optional directly supplied collapse fraction for sliver integration.
  ///
  /// Ordinary scaffold pages should keep using [scrollBehavior]. A
  /// [MiuixSliverTopAppBar] receives its shrink offset during sliver layout,
  /// so passing that normalized value directly avoids notifying a controller
  /// while the render tree is being built.
  final double? collapseFraction;

  /// Background color; defaults to the MIUIX surface color.
  final Color? color;

  /// Whether the bar samples and blurs page content behind its surface.
  final bool glass;

  /// Selects the source uniform or scroll-revealed progressive blur pipeline.
  ///
  /// [MiuixTopAppBarBlurStyle.gaussian] matches `textureBlur` in the sample's
  /// ordinary branch: 25dp blur and an 80% surface blend over the full bar.
  /// [MiuixTopAppBarBlurStyle.progressive] matches its second branch: a 10dp
  /// top-edge blur, a 30% surface blend, and scroll-controlled opacity.
  ///
  /// [MiuixTopAppBarBlurStyle.gradient] is the HyperOS 4 default: it keeps a
  /// real, persistent backdrop sample and smoothly reduces its semantic tint
  /// toward the content edge. Applications can still select the uniform [gaussian] or
  /// older scroll-revealed [progressive] treatment explicitly.
  final MiuixTopAppBarBlurStyle blurStyle;

  /// Shape and material shared by the top-bar action slots.
  ///
  /// The group keeps the existing 40dp icon-center cadence and 48dp semantic
  /// targets. Expanded titles have transparent actions; compact titles use
  /// individual circular surfaces without changing target positions or size.
  /// These values are project-derived
  /// from current Xiaomi application captures rather than official tokens.
  /// The default is [MiuixTopAppBarActionStyle.glass]; choose
  /// [MiuixTopAppBarActionStyle.plain] explicitly for legacy icon-only pages.
  final MiuixTopAppBarActionStyle actionStyle;

  /// Compact title color.
  final Color? titleColor;

  /// Expanded title color.
  final Color? largeTitleColor;

  /// Subtitle color.
  final Color? subtitleColor;

  /// Whether the bar applies the source's optional horizontal window insets.
  ///
  /// Upstream always applies the top `systemBars` inset. This flag controls
  /// only the additional horizontal display-cutout and navigation-bar insets.
  final bool defaultWindowInsetsPadding;

  /// Horizontal title inset from the original component.
  final double titlePadding;

  /// Start inset for the navigation icon.
  final double navigationIconPadding;

  /// End inset for action icons.
  final double actionIconPadding;

  /// Optional explicit expanded height for unusually tall title content.
  final double? expandedHeight;

  /// Optional large-bar collapsed title-area height.
  ///
  /// Sliver integrations use this to keep their public minimum extent and the
  /// visible title surface identical. A null value retains source geometry.
  final double? collapsedTitleAreaHeight;

  /// Optional source-compatible content placed below the title area.
  final Widget? bottomContent;

  /// Reserved height for [bottomContent].
  final double bottomContentHeight;

  /// Extra space above [bottomContent] while a large bar is expanded.
  ///
  /// The source icon catalogue uses this layout-time inset for its search
  /// capsule. It shrinks linearly to zero with the large-title collapse
  /// fraction and is always zero for a compact bar.
  ///
  /// This value is intentionally separate from [bottomContentHeight]. Compose
  /// measures the inset as its own layout node, rounds it to a physical pixel,
  /// then constrains and places the bottom content below it. Combining both
  /// values before rounding would put the search capsule one pixel away from
  /// the source on common fractional Android densities such as 2.625.
  ///
  /// The inset changes only the visible bar measurement. It does not enlarge
  /// the title column consumed by [MiuixTopAppBarScrollBehavior], so the title
  /// keeps the source 38dp collapse extent while the optional bottom content
  /// follows that already normalized fraction. A page that initially pads its
  /// scrollable below an overlaid bar should include the fully expanded value
  /// in that initial padding, as the source Scaffold sample does.
  final double bottomContentExpandedTopPadding;

  static const double collapsedHeight = MiuixTopAppBarDefaults.collapsedHeight;
  static const double smallTopAppBarCenterHeight =
      MiuixTopAppBarDefaults.smallTopAppBarCenterHeight;
  static const double largeTitleBottomPadding =
      MiuixTopAppBarDefaults.largeTitleBottomPadding;
  static const double subtitleBottomPadding =
      MiuixTopAppBarDefaults.subtitleBottomPadding;
  static const double titleMaxWidthFraction = .9;
  static const double collapsedLargeHeight = 56;
  static const double collapsedSubtitleHeight = 62;

  bool get _hasSubtitle => subtitle?.isNotEmpty == true;

  double get _expandedHeight {
    // PreferredSize is read before build and cannot rely on a later layout
    // clamp. Keep this getter as the single source of truth for both phases.
    final fallback = _hasSubtitle ? 114.0 : 94.0;
    final requested = expandedHeight;
    return requested != null && requested.isFinite && requested > 0
        ? requested
        : fallback;
  }

  double get _collapsedTitleAreaHeight {
    // The collapsed height is also used as the interpolation endpoint and
    // must remain positive even when an external editor clears its field.
    // Invalid overrides fall through to the subtitle-aware source defaults.
    if (collapsedTitleAreaHeight case final value?) {
      if (value.isFinite && value > 0) return value;
    }
    if (!large) {
      return _hasSubtitle ? collapsedSubtitleHeight : collapsedHeight;
    }
    return _hasSubtitle ? collapsedSubtitleHeight : collapsedLargeHeight;
  }

  double get _collapseExtent {
    if (collapsedTitleAreaHeight case final value?) {
      if (value.isFinite && value > 0) {
        return math.max(1, _expandedHeight - value);
      }
    }
    // TopAppBar.kt stores the height of the 32sp large-title Column as its
    // nested-scroll limit. Subtracting the 52dp top region and the source
    // bottom padding from the calibrated expanded height reproduces 38dp for
    // a title and 54dp for a title plus 14sp subtitle.
    final padding = _hasSubtitle
        ? subtitleBottomPadding
        : largeTitleBottomPadding;
    return math.max(1, _expandedHeight - collapsedHeight - padding);
  }

  double get _fraction {
    // Scroll controllers publish a finite fraction, but the direct sliver API
    // is public and can receive transient calculation errors from clients.
    // Treat an unusable sample as expanded rather than poisoning every lerp.
    if (!large) return 1;
    final requested = collapseFraction ?? scrollBehavior?.collapseFraction ?? 0;
    return requested.isFinite ? requested.clamp(0.0, 1.0) : 0.0;
  }

  double get _nominalTitleAreaHeight => large
      ? ui.lerpDouble(_expandedHeight, _collapsedTitleAreaHeight, _fraction)!
      : _collapsedTitleAreaHeight;

  double _sourceCollapsedTitleAreaHeight(BuildContext context) {
    if (collapsedTitleAreaHeight case final value?) {
      if (value.isFinite && value > 0) return value;
    }
    if (!large || _hasSubtitle) {
      return _collapsedTitleAreaHeight;
    }
    final density = MediaQuery.devicePixelRatioOf(context);
    // TopAppBar.kt does not measure the title-only collapsed surface as one
    // 56dp box. Its Layout first rounds the 52dp compact row to Int pixels,
    // then rounds and appends the independent 4dp large-title bottom padding.
    // At 420dpi that is 137px + 11px, while a combined 56dp transform is only
    // 147px. Keep the source measurement order at fractional Android density.
    return _miuixRoundLogicalDimension(collapsedHeight, density) +
        _miuixRoundLogicalDimension(largeTitleBottomPadding, density);
  }

  double _sourceTitleAreaHeight(BuildContext context) {
    final collapsed = _sourceCollapsedTitleAreaHeight(context);
    final wrapped = _smallWrappedTitleHeight(context);
    // 这里先参与Scaffold尺寸查询，绘制阶段不能单独画出更高标题后覆盖正文。
    if (wrapped != null) {
      // 只有实际溢出时增加高度，正常字号短标题的既有像素布局保持一致。
      return math.max(collapsed, smallTopAppBarCenterHeight + wrapped + 8);
    }
    return large
        ? ui.lerpDouble(
            _expandedHeight + _largeTitleExtra(context),
            collapsed,
            _fraction,
          )!
        : collapsed;
  }

  double _sourceBottomContentTopPadding(BuildContext context) {
    // Padding is rounded independently because Compose measures this modifier
    // before it appends the child height at fractional Android densities.
    // Reject infinity before multiplication: infinity times a collapsed zero
    // is NaN and would otherwise escape even a later non-negative clamp.
    if (bottomContent == null ||
        !bottomContentExpandedTopPadding.isFinite ||
        bottomContentExpandedTopPadding <= 0) {
      return 0;
    }
    final density = MediaQuery.devicePixelRatioOf(context);
    final expandedPadding = large
        ? bottomContentExpandedTopPadding * (1 - _fraction)
        : 0.0;
    // Compose's custom layout rounds this inset before it measures and places
    // the search capsule, rather than rounding the accumulated bar height.
    // Keeping the rounding here also means the bar's PreferredSize and child
    // placement use the same resolved value during every animation frame.
    return _miuixRoundLogicalDimension(expandedPadding, density);
  }

  // Bottom slots participate in both Scaffold reservation and child layout.
  // Normalize before either path adds the value so NaN cannot make the public
  // PreferredSize diverge from the rendered glass surface.
  double get _safeBottomContentHeight =>
      bottomContentHeight.isFinite ? math.max(0.0, bottomContentHeight) : 0.0;

  double get _safeExpandedBottomPadding =>
      bottomContentExpandedTopPadding.isFinite
      ? math.max(0.0, bottomContentExpandedTopPadding)
      : 0.0;

  double _sourceBottomContentHeight(BuildContext context) =>
      bottomContent == null
      ? 0
      : _safeBottomContentHeight + _sourceBottomContentTopPadding(context);

  /// Returns the source measurement for the current Flutter view.
  ///
  /// [PreferredSizeWidget.preferredSize] cannot read a [BuildContext], so its
  /// public value remains the density-independent nominal dp contract. MIUIX
  /// layout needs one additional step at fractional Android densities:
  ///
  /// - resolve the density belonging to this view rather than the first view;
  /// - round the compact row and trailing padding independently;
  /// - interpolate toward that resolved collapsed target;
  /// - append caller-supplied bottom content after the title measurement.
  ///
  /// [MiuixScaffold] asks for this size before constructing Flutter Scaffold's
  /// tight app-bar constraint. That avoids reading global dispatcher state,
  /// remains correct in multi-window applications, and prevents the final
  /// physical pixel from being clipped even though the child measures it.
  Size _sourcePreferredSize(BuildContext context) => Size.fromHeight(
    _preparedSourceTitleAreaHeight(context) +
        _sourceBottomContentHeight(context),
  );

  /// 返回当前视口与字号下的实际高度，供透明标题栏后方的正文预留空间。
  /// 普通 preferredSize 无法读取 TextScaler，仅保留原有名义尺寸契约。
  Size preferredSizeFor(BuildContext context) => _sourcePreferredSize(context);

  /// Resolves shared compact-to-large state before Scaffold tightens height.
  double _preparedSourceTitleAreaHeight(BuildContext context) {
    if (large) {
      scrollBehavior?._attachCollapseExtent(
        _collapseExtent + _largeTitleExtra(context),
      );
    }
    return _sourceTitleAreaHeight(context);
  }

  @override
  Size get preferredSize {
    // Flutter Scaffold reads this before building its appBar child. Restore a
    // shared state here as well as in the context-aware MiuixScaffold path so
    // the first large frame receives the correct tight height.
    // 无上下文的尺寸查询只恢复大小标题模式，不能覆盖刚测得的缩放行程。
    // 正文可能在同一帧查询此属性，重置行程会造成每帧重复通知与布局。
    final behavior = scrollBehavior;
    if (large && behavior != null) {
      behavior._attachCollapseExtent(behavior._collapseExtent);
    }
    return Size.fromHeight(
      _nominalTitleAreaHeight +
          (bottomContent == null
              ? 0
              : _safeBottomContentHeight +
                    (large ? _safeExpandedBottomPadding * (1 - _fraction) : 0)),
    );
  }

  @override
  Widget build(BuildContext context) {
    scrollBehavior?._setReduceMotion(MediaQuery.disableAnimationsOf(context));
    if (large) {
      // 字号变化后折叠行程与实际展开高度一致，返回按钮保持原触摸位置。
      scrollBehavior?._attachCollapseExtent(
        _collapseExtent + _largeTitleExtra(context),
      );
    } else {
      scrollBehavior?._schedulePinForSmallTopAppBar();
    }
    final bar = scrollBehavior == null
        ? _buildBar(
            context,
            includeHorizontalSafeArea: defaultWindowInsetsPadding,
          )
        : AnimatedBuilder(
            animation: scrollBehavior!,
            builder: (context, _) => _buildBar(
              context,
              includeHorizontalSafeArea: defaultWindowInsetsPadding,
            ),
          );
    return bar;
  }

  Widget _buildBar(
    BuildContext context, {
    required bool includeHorizontalSafeArea,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final fraction = _fraction;
    final height = _sourceTitleAreaHeight(context);
    final supportingText = _hasSubtitle ? subtitle : null;
    final compactVisible = !large || fraction * 3 >= 1;
    final bottomContentTopPadding = _sourceBottomContentTopPadding(context);
    final safeTitlePadding = titlePadding.isFinite
        ? math.max(0.0, titlePadding)
        : MiuixTopAppBarDefaults.titlePadding;
    final safeNavigationIconPadding = navigationIconPadding.isFinite
        ? math.max(0.0, navigationIconPadding)
        : MiuixTopAppBarDefaults.navigationIconPadding;
    final safeActionIconPadding = actionIconPadding.isFinite
        ? math.max(0.0, actionIconPadding)
        : MiuixTopAppBarDefaults.actionIconPadding;
    // Horizontal paddings do not change PreferredSize, yet they still enter
    // Positioned and compact action layout. Normalize them close to both uses
    // so the title and its shaped action group share one finite coordinate
    // system in the opaque, Gaussian, and progressive material branches.
    final largeOpacity = large ? (1 - fraction * 3).clamp(0.0, 1.0) : 0.0;
    final compactStyle = _compactTitleTextStyle(context);
    final wrapSmall = _smallWrappedTitleHeight(context) != null;
    // 与预留尺寸使用同一实际窗口测量，不根据固定手机宽度猜换行。
    final expandedStyle = theme.textTheme.displaySmall?.copyWith(
      color: largeTitleColor ?? titleColor ?? scheme.onSurface,
      fontSize: 32,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
    );
    final supportingStyle = theme.textTheme.bodyMedium?.copyWith(
      color: subtitleColor ?? scheme.onSurfaceVariant,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );

    final titleArea = SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          if (large && largeOpacity > 0)
            PositionedDirectional(
              start: safeTitlePadding,
              end: safeTitlePadding,
              bottom: supportingText == null
                  ? largeTitleBottomPadding
                  : subtitleBottomPadding,
              child: Opacity(
                opacity: largeOpacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(largeTitle ?? title, style: expandedStyle),
                    if (supportingText case final text?)
                      Text(text, style: supportingStyle),
                  ],
                ),
              ),
            ),
          Positioned.fill(
            child: _MiuixCompactTopAppBarContent(
              title: wrapSmall ? '' : title,
              // 下方已完整绘制时不保留一份省略的同名标题，避免语义重复。
              subtitle: wrapSmall ? null : supportingText,
              leading: leading,
              actions: actions,
              centerHeight: large
                  ? collapsedHeight
                  : smallTopAppBarCenterHeight,
              titleStyle: compactStyle,
              subtitleStyle: supportingStyle,
              titlePadding: safeTitlePadding,
              navigationIconPadding: safeNavigationIconPadding,
              actionIconPadding: safeActionIconPadding,
              actionStyle: actionStyle,
              showActionSurfaces: compactVisible,
              includeTopSafeArea: true,
              animateTitle: large,
              titleVisible: compactVisible,
            ),
          ),
          if (wrapSmall)
            PositionedDirectional(
              // 图标行仍保持原50dp位置；完整标题只占用新增的下方阅读区。
              start: safeTitlePadding,
              end: safeTitlePadding,
              top: smallTopAppBarCenterHeight,
              child: Column(
                // 自然高度对应测量结果，长标题和兼容副标题均可完整换行。
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: compactStyle),
                  // 新产品只用主标题；此分支保留已有subtitle调用方的完整阅读。
                  if (supportingText != null)
                    Text(supportingText, style: supportingStyle),
                ],
              ),
            ),
        ],
      ),
    );

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        titleArea,
        if (bottomContent != null)
          SizedBox(
            height: _safeBottomContentHeight + bottomContentTopPadding,
            child: Padding(
              padding: EdgeInsets.only(top: bottomContentTopPadding),
              child: bottomContent,
            ),
          ),
      ],
    );
    // Compose applies its background before all window-inset modifiers. Its
    // top system-bar inset is unconditional; `defaultWindowInsetsPadding`
    // gates only the horizontal display-cutout/navigation-bar modifiers.
    // Keeping SafeArea inside the surface reproduces that paint ordering for
    // opaque and glass variants while retaining the status inset on Android
    // tablets and landscape layouts whose adaptive bar disables side insets.
    content = SafeArea(
      left: includeHorizontalSafeArea,
      right: includeHorizontalSafeArea,
      bottom: false,
      child: content,
    );
    if (glass) {
      if (blurStyle != MiuixTopAppBarBlurStyle.gaussian) {
        final scrollReveal = scrollBehavior != null
            ? (-scrollBehavior!.contentOffset / 48).clamp(0.0, 1.0)
            : collapseFraction != null
            ? (collapseFraction! * _collapseExtent / 48).clamp(0.0, 1.0)
            : 1.0;
        final persistent = blurStyle == MiuixTopAppBarBlurStyle.gradient;
        return _MiuixProgressiveTopBarGlass(
          opacity: persistent ? 1 : scrollReveal,
          blur: persistent
              ? hyperOs4.appBarBlur
              : hyperOs4.progressiveAppBarBlur,
          tintOpacity: persistent
              ? hyperOs4.appBarTintOpacity
              : hyperOs4.progressiveAppBarTintOpacity,
          color: color ?? scheme.surface,
          // The material belongs to the title surface only. Bottom content is
          // laid out by the same app bar for source parity, but must remain as
          // clear as the page body below it.
          materialHeight: MediaQuery.paddingOf(context).top + height,
          child: content,
        );
      }
      return MiuixGlass(
        key: const ValueKey('top-app-bar-glass'),
        // These are centralized project-calibrated HyperOS 4 values. Global
        // intensity adjusts the complete material while preserving contrast.
        blur: hyperOs4.appBarBlur,
        opacity: hyperOs4.appBarTintOpacity,
        color: color ?? scheme.surface,
        radius: 0,
        padding: EdgeInsets.zero,
        // A page app bar is a flush material plane rather than a floating
        // capsule. Painting the navigation recipe's complete rectangular
        // optical edge made its bottom stroke read as a divider below the
        // title. Keep the same calibrated blur/tint response, but let the
        // scrolling content transition provide the boundary instead.
        showSpecular: false,
        optics: MiuixGlassOptics.navigation,
        // A Scaffold paints its app bar after the body. During route motion
        // both live in one transition saveLayer, where srcOver can composite
        // the sampled backdrop twice and erase the body below the bar.
        blendMode: BlendMode.src,
        child: content,
      );
    }
    // Keep the opaque surface addressable in geometry tests just like the
    // glass branch above.  Both branches own the same overlay bounds.
    return ColoredBox(
      key: const ValueKey('top-app-bar-surface'),
      color: color ?? scheme.surface,
      child: content,
    );
  }
}

/// Compact top app bar adapter matching MIUIX `SmallTopAppBar`.
class MiuixSmallTopAppBar extends MiuixTopAppBar {
  /// Creates the compact 52dp source variant.
  const MiuixSmallTopAppBar({
    super.key,
    required super.title,
    super.subtitle,
    super.leading,
    super.actions,
    super.scrollBehavior,
    super.color,
    super.glass,
    super.blurStyle,
    super.titleColor,
    super.subtitleColor,
    super.defaultWindowInsetsPadding,
    super.titlePadding,
    super.navigationIconPadding,
    super.actionIconPadding,
    super.bottomContent,
    super.bottomContentHeight,
    super.bottomContentExpandedTopPadding,
  }) : super(large: false);
}

/// Continuous gradient-glass surface used by HyperOS top bars.
///
/// The blur radius and semantic tint both remain strong around the status and
/// compact-title rows, then continuously reach zero at the body edge. The
/// directly clipped Gaussian passes preserve that profile across renderers. This
/// avoids the hard bottom boundary produced by clipping one uniform
/// [BackdropFilter] at the exact bottom of the bar.
///
/// Title glyphs, navigation icons, search content, and semantics remain the
/// second stack layer, so none of them are faded by the material gradient.
///
/// [opacity] represents the independent scroll reveal from `BlurredBar.kt`.
/// It scales the maximum blur sigma and authored tint colors instead of adding
/// an outer [Opacity]. A zero-offset explicit progressive bar therefore has no
/// saveLayer, while a 48dp upward scroll exposes the complete profile. The
/// default gradient style passes one and stays visible continuously.
///
/// The surface has radius zero because the source passes `RectangleShape` for
/// page bars. Dedicated liquid-glass components retain their separate rounded
/// shapes. Page bars deliberately omit the floating-glass optical outline so
/// the lower edge does not read as a divider beneath the title.
class _MiuixTitleBackdrop extends StatelessWidget {
  const _MiuixTitleBackdrop({super.key, required this.sigma});
  final double sigma;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final height = constraints.maxHeight;
      if (!height.isFinite || height <= 0 || sigma <= 0) {
        return const SizedBox.expand();
      }
      // A ShaderMask creates an isolated saveLayer; on Skia its backdrop blur
      // can sample that empty layer instead of the scrolling page. Clip direct
      // filters into disjoint bands so every pass samples the real backdrop.
      // Keep the title plateau strong and feather only the final 32%. Bands
      // are at least one physical pixel and capped to bound compositor cost.
      final density = MediaQuery.devicePixelRatioOf(context);
      final steps = (height * .32 * density).ceil().clamp(1, 16);
      final edges = <double>[
        0,
        .68,
        for (var i = 1; i <= steps; i++) .68 + .32 * i / steps,
      ];
      return Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < edges.length - 1; i++)
            ClipRect(
              clipper: _MiuixTitleBandClip(edges[i], edges[i + 1]),
              child: BackdropFilter(
                blendMode: BlendMode.src,
                filter: ui.ImageFilter.blur(
                  sigmaX: sigma * _strength((edges[i] + edges[i + 1]) / 2),
                  sigmaY: sigma * _strength((edges[i] + edges[i + 1]) / 2),
                ),
                child: const SizedBox.expand(),
              ),
            ),
        ],
      );
    },
  );

  static double _strength(double position) {
    final t = ((position - .68) / .32).clamp(0.0, 1.0);
    return 1 - math.pow(t * t * (3 - 2 * t), .8).toDouble();
  }
}

class _MiuixTitleBandClip extends CustomClipper<Rect> {
  const _MiuixTitleBandClip(this.start, this.end);
  final double start, end;
  @override
  Rect getClip(Size size) =>
      Rect.fromLTRB(0, size.height * start, size.width, size.height * end);
  @override
  bool shouldReclip(_MiuixTitleBandClip oldClipper) =>
      start != oldClipper.start || end != oldClipper.end;
}

class _MiuixProgressiveTopBarGlass extends StatelessWidget {
  const _MiuixProgressiveTopBarGlass({
    required this.opacity,
    required this.blur,
    required this.tintOpacity,
    required this.color,
    required this.materialHeight,
    required this.child,
  });

  final double opacity;
  final double blur;
  final double tintOpacity;
  final Color color;
  final double materialHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    if (!theme.enableGlass) {
      return ColoredBox(color: color, child: child);
    }
    final reveal = opacity.isFinite ? opacity.clamp(0.0, 1.0) : 0.0;
    final optics = MiuixGlassOptics.navigation;
    final effectiveBlur = optics.resolveBlur(blur, theme.glassIntensity);
    final effectiveTint = optics.resolveOpacity(
      tintOpacity,
      theme.glassIntensity,
    );
    final safeMaterialHeight = materialHeight.isFinite
        ? math.max(0.0, materialHeight)
        : 0.0;
    // These falloff positions are project-calibrated from the HyperOS 4 visual
    // baseline rather than published Xiaomi tokens. Keeping the first 68% at
    // full strength protects title legibility; the remaining area feathers the
    // sampled backdrop into the clear scrolling body without a cutoff line.
    return Stack(
      key: const ValueKey('top-app-bar-progressive-glass'),
      fit: StackFit.passthrough,
      children: [
        if (reveal > 0)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: safeMaterialHeight,
            // BackdropFilter uses the nearest ancestor clip as its actual
            // compositing domain. A positioned size alone is insufficient on
            // every Impeller backend and can still process the scaffold body.
            child: ClipRect(
              key: const ValueKey('top-app-bar-title-material-clip'),
              child: _MiuixTitleBackdrop(
                key: const ValueKey('top-app-bar-gradient-filter'),
                sigma: effectiveBlur * reveal,
              ),
            ),
          ),
        if (reveal > 0)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: safeMaterialHeight,
            child: DecoratedBox(
              key: const ValueKey('top-app-bar-gradient-tint'),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: color.a * effectiveTint * reveal),
                    color.withValues(
                      alpha: color.a * effectiveTint * .72 * reveal,
                    ),
                    color.withValues(
                      alpha: color.a * effectiveTint * .20 * reveal,
                    ),
                    color.withValues(alpha: 0),
                  ],
                  stops: const [0, .62, .84, 1],
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}

/// Reproduces the independent compact-title animation from `TopAppBar.kt`.
///
/// Compose starts this transition only after the collapse fraction crosses
/// one third. The title fades in while moving upward by 20 physical pixels;
/// hiding uses the same critically damped motion with a faster response.
class _MiuixCompactTitleTransition extends StatelessWidget {
  const _MiuixCompactTitleTransition({
    required this.visible,
    required this.child,
  });

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // `graphicsLayer.translationY = 20f` is a raw-pixel value in Compose.
    // Dividing by Flutter's device-pixel ratio preserves that exact travel on
    // Android while naturally remaining 20 logical pixels at density 1.
    final travel = 20 / MediaQuery.devicePixelRatioOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final authoredDuration = visible
        ? const Duration(milliseconds: 300)
        : const Duration(milliseconds: 150);
    final duration = reduceMotion ? Duration.zero : authoredDuration;
    final response = visible ? .3 : .15;
    return TweenAnimationBuilder<double>(
      key: const ValueKey('top-app-bar-compact-title-animation'),
      tween: Tween(begin: 0, end: visible ? 1 : 0),
      duration: duration,
      // MIUIX uses folmeSpring(damping = 1), a critically damped spring with
      // response 0.3s when showing and 0.15s when hiding.
      curve: reduceMotion
          ? Curves.linear
          : _MiuixCriticallyDampedCurve(
              responseSeconds: response,
              durationSeconds:
                  authoredDuration.inMicroseconds /
                  Duration.microsecondsPerSecond,
            ),
      builder: (context, progress, child) {
        return Transform.translate(
          key: const ValueKey('top-app-bar-compact-title-translation'),
          offset: Offset(0, travel * (1 - progress)),
          child: Opacity(
            key: const ValueKey('top-app-bar-compact-title-opacity'),
            opacity: progress,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Unit-interval form of a zero-velocity critically damped spring response.
///
/// MIUIX computes stiffness as `(2π / response)²`. Its corresponding step
/// response is `1 - (1 + ωt)e^(-ωt)`. Normalization makes the Flutter curve
/// finish exactly at one without altering its source-shaped acceleration.
class _MiuixCriticallyDampedCurve extends Curve {
  const _MiuixCriticallyDampedCurve({
    required this.responseSeconds,
    required this.durationSeconds,
  });

  final double responseSeconds;
  final double durationSeconds;

  double _response(double seconds) {
    final omega = 2 * math.pi / responseSeconds;
    return 1 - (1 + omega * seconds) * math.exp(-omega * seconds);
  }

  @override
  double transformInternal(double t) {
    if (t <= 0) return 0;
    if (t >= 1) return 1;
    final terminal = _response(durationSeconds);
    if (terminal <= 0) return t;
    return (_response(t * durationSeconds) / terminal).clamp(0.0, 1.0);
  }
}

class _MiuixTopBarActions extends StatelessWidget {
  const _MiuixTopBarActions({
    required this.children,
    required this.targetOffset,
    required this.targetInsets,
    required this.style,
    required this.showSurfaces,
  });

  final List<Widget> children;
  final Offset targetOffset;
  final EdgeInsets targetInsets;
  final MiuixTopAppBarActionStyle style;
  final bool showSurfaces;

  static const double _circleSize = 44;
  static const double _targetSize = 48;
  static const double _circleGap = 8;
  static const double _targetGap = _circleGap - (_targetSize - _circleSize);

  static double widthFor(int count, MiuixTopAppBarActionStyle style) {
    if (count <= 0) return 0;
    return switch (style) {
      MiuixTopAppBarActionStyle.glass =>
        count * _targetSize + (count - 1) * _targetGap,
      MiuixTopAppBarActionStyle.plain => count * 40 + 8,
    };
  }

  @override
  Widget build(BuildContext context) {
    // Explicit plain/source actions retain Compose's overlapping 40dp center
    // cadence. HyperOS glass actions use the independent circular branch above.
    if (style == MiuixTopAppBarActionStyle.glass) {
      final scheme = Theme.of(context).colorScheme;
      return SizedBox(
        key: const ValueKey('top-app-bar-glass-actions'),
        width: widthFor(children.length, style),
        height: _targetSize,
        child: Row(
          spacing: _targetGap,
          children: [
            for (var index = 0; index < children.length; index++)
              SizedBox.square(
                dimension: _targetSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (showSurfaces)
                      IgnorePointer(
                        child: SizedBox.square(
                          dimension: _circleSize,
                          child: MiuixGlass(
                            key: ValueKey('top-app-bar-glass-action-$index'),
                            blur: MiuixTheme.of(context).hyperOs4.appBarBlur,
                            opacity: MiuixTheme.of(
                              context,
                            ).hyperOs4.appBarTintOpacity,
                            color: scheme.surfaceContainer,
                            shape: const CircleBorder(),
                            padding: EdgeInsets.zero,
                            optics: MiuixGlassOptics.navigation,
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ),
                    _MiuixIconButtonGlassContext(
                      selectedBackgroundColor: showSurfaces
                          ? scheme.primary.withValues(alpha: .14)
                          : Colors.transparent,
                      selectedContentColor: scheme.primary,
                      child: _MiuixIconButtonTargetOffset(
                        offset: targetOffset,
                        insets: targetInsets,
                        child: children[index],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }
    return SizedBox(
      width: widthFor(children.length, style),
      height: 48,
      child: Stack(
        children: [
          for (var index = 0; index < children.length; index++)
            PositionedDirectional(
              start: index * 40,
              width: 48,
              height: 48,
              child: Center(
                child: _MiuixIconButtonTargetOffset(
                  offset: targetOffset,
                  insets: targetInsets,
                  child: children[index],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
