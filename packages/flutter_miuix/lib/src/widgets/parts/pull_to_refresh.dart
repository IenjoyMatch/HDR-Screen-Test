part of '../miuix_widgets.dart';

/// Visual phases used by the source pull-to-refresh state machine.
enum MiuixRefreshState {
  /// No indicator is visible and the list owns normal scrolling.
  idle,

  /// The pointer is below the refresh threshold.
  pulling,

  /// The threshold has been crossed but the pointer is still held.
  thresholdReached,

  /// The callback is running and the orbit indicator is rotating.
  refreshing,

  /// The short success-collapse animation is being shown.
  refreshComplete,
}

/// Observable source-compatible state for [MiuixPullToRefresh].
///
/// The Compose API exposes its drag offset, pull progress and visual phase.
/// Keeping those values public makes custom headers possible without making
/// the widget's gesture and animation machinery public.
class MiuixPullToRefreshState extends ChangeNotifier {
  double _dragOffset = 0;
  double _refreshThresholdOffset = 0;
  double _triggerProgressOffset = 0;
  double _fullDragRange = 0;
  double _refreshThreshold = .25;
  double _maxDragDistance = 0;
  double _completeProgress = 1;
  MiuixRefreshState _refreshState = MiuixRefreshState.idle;

  /// Current damped indicator displacement in logical pixels.
  double get dragOffset => _dragOffset;

  /// Screen-derived trigger threshold used by the original component.
  double get refreshThresholdOffset => _refreshThresholdOffset;

  /// User-configured trigger offset across the complete damped drag range.
  double get triggerProgressOffset => _triggerProgressOffset;

  /// Configured refresh threshold as a normalized value from zero to one.
  double get refreshThreshold => _refreshThreshold;

  /// Full viewport range used by the MIUIX damping curve.
  double get maxDragDistance => _maxDragDistance;

  /// Current visual state.
  MiuixRefreshState get refreshState => _refreshState;

  /// Pull progress relative to the larger visual or configured threshold.
  double get pullProgress =>
      math.max(_refreshThresholdOffset, _triggerProgressOffset) <= 0
      ? 0
      : (_dragOffset /
                math.max(_refreshThresholdOffset, _triggerProgressOffset))
            .clamp(0.0, 1.0);

  /// Progress across the entire damped range, including threshold over-pull.
  double get fullDragProgress =>
      _fullDragRange <= 0 ? 0 : (_dragOffset / _fullDragRange).clamp(0.0, 1.0);

  /// Progress of the 200 ms source completion animation.
  double get refreshCompleteProgress => _completeProgress;

  void _synchronize({
    required double dragOffset,
    required double visualThreshold,
    required double triggerThreshold,
    required double fullDragRange,
    required double refreshThreshold,
    required double maxDrag,
    required double completeProgress,
    required MiuixRefreshState refreshState,
    bool notify = true,
  }) {
    _dragOffset = dragOffset;
    _refreshThresholdOffset = visualThreshold;
    _triggerProgressOffset = triggerThreshold;
    _fullDragRange = fullDragRange;
    _refreshThreshold = refreshThreshold;
    _maxDragDistance = maxDrag;
    _completeProgress = completeProgress;
    _refreshState = refreshState;
    if (notify) {
      notifyListeners();
    }
  }
}

/// Defaults copied from MIUIX 1.0.9 `PullToRefreshDefaults`.
abstract final class MiuixPullToRefreshDefaults {
  /// Compose `Color.Gray`, the exact upstream neutral indicator color.
  static const Color color = Color(0xFF888888);

  /// Diameter of the ring painted above the status text.
  static const double circleSize = 20;

  /// Source state labels; localized examples can replace all four entries.
  static const List<String> refreshTexts = [
    'Pull down to refresh',
    'Release to refresh',
    'Refreshing...',
    'Refreshed successfully',
  ];

  /// Source text uses a 14sp bold face.
  static const TextStyle refreshTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: color,
  );
}

// Compose's nested-scroll connection consumes downward top-edge movement
// before the child can move outside its range. This adapter preserves MIUIX
// spring physics at the bottom while clamping the top for PullToRefresh.
class _MiuixPullRefreshScrollPhysics extends ScrollPhysics {
  const _MiuixPullRefreshScrollPhysics({
    required this.isRefreshLocked,
    super.parent,
  });

  final bool Function() isRefreshLocked;

  @override
  _MiuixPullRefreshScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      _MiuixPullRefreshScrollPhysics(
        isRefreshLocked: isRefreshLocked,
        parent: buildParent(ancestor),
      );

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // While a header is visible, source onPreScroll consumes movement in both
    // directions so the list cannot drift underneath the expanding header.
    if (isRefreshLocked() && value != position.pixels) {
      return value - position.pixels;
    }
    // At rest, clamp only the leading edge. The unconsumed amount becomes an
    // OverscrollNotification that drives the source-compatible header.
    if (value < position.pixels &&
        position.pixels <= position.minScrollExtent) {
      return value - position.pixels;
    }
    if (value < position.minScrollExtent &&
        position.minScrollExtent < position.pixels) {
      return value - position.minScrollExtent;
    }
    return super.applyBoundaryConditions(position, value);
  }
}

/// MIUIX pull-to-refresh container with the original five-state header.
class MiuixPullToRefresh extends StatefulWidget {
  /// Creates a source-compatible refresh container.
  const MiuixPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.state,
    this.isRefreshing,
    this.contentPadding = EdgeInsets.zero,
    this.topAppBarScrollBehavior,
    this.color,
    this.circleSize = double.nan,
    this.refreshTexts = MiuixPullToRefreshDefaults.refreshTexts,
    this.refreshTextStyle = MiuixPullToRefreshDefaults.refreshTextStyle,
    this.refreshThreshold = .25,
    this.onPullProgress,
  }) : _sourceMotion = false;

  /// Creates the exact MIUIX 1.0.9 refresh geometry and motion clocks.
  const MiuixPullToRefresh.source({
    super.key,
    required this.onRefresh,
    required this.child,
    this.state,
    this.isRefreshing,
    this.contentPadding = EdgeInsets.zero,
    this.topAppBarScrollBehavior,
    this.color,
    this.refreshTexts = MiuixPullToRefreshDefaults.refreshTexts,
    this.refreshTextStyle = MiuixPullToRefreshDefaults.refreshTextStyle,
    this.refreshThreshold = .25,
    this.onPullProgress,
  }) : circleSize = MiuixPullToRefreshDefaults.circleSize,
       _sourceMotion = true;

  /// Starts data loading after the pointer is released past the threshold.
  ///
  /// The upstream callback itself is synchronous because [isRefreshing] is
  /// hoisted. [FutureOr] also preserves the package's earlier convenient
  /// future-driven form when [isRefreshing] is omitted.
  final FutureOr<void> Function() onRefresh;

  /// Scrollable content placed below the expanding refresh header.
  final Widget child;

  /// Optional observable UI state, equivalent to `rememberPullToRefreshState`.
  final MiuixPullToRefreshState? state;

  /// Optional hoisted loading state; null uses the callback future as truth.
  final bool? isRefreshing;

  /// Insets used to place the indicator below an overlaid top application bar.
  final EdgeInsetsGeometry contentPadding;

  /// Optional large-title behavior coordinated with the contained scrollable.
  final MiuixTopAppBarScrollBehavior? topAppBarScrollBehavior;

  /// Ring and status-label color.
  final Color? color;

  /// Refresh ring diameter in logical pixels.
  final double circleSize;

  /// Pull, release, loading and success labels in that order.
  final List<String> refreshTexts;

  /// Typography for the refresh label.
  final TextStyle refreshTextStyle;

  /// Fraction of the complete damped drag range required to refresh.
  ///
  /// The source clamps this value to `0...1`; zero makes any non-empty pull
  /// eligible, while one requires the complete visual drag range.
  final double refreshThreshold;

  /// Reports progress across the complete damped drag range from zero to one.
  final ValueChanged<double>? onPullProgress;

  final bool _sourceMotion;

  @override
  State<MiuixPullToRefresh> createState() => _MiuixPullToRefreshState();
}

class _MiuixPullToRefreshState extends State<MiuixPullToRefresh>
    with TickerProviderStateMixin {
  Duration _safeMotionDuration(Duration duration) =>
      duration < Duration.zero ? Duration.zero : duration;

  // SpringMath.STANDARD_SPRING_PERIOD is 0.4 s. The normal path resolves the
  // corresponding project token while source mode remains fixed at 400 ms.
  SpringDescription _settleSpring() {
    final duration = widget._sourceMotion
        ? const Duration(milliseconds: 400)
        : MiuixTheme.of(context).hyperOs4.pullRefreshSettleMotion;
    final seconds = math.max(duration.inMicroseconds / 1000000, .001);
    return SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: math.pow(2 * math.pi / seconds, 2).toDouble(),
      ratio: 1,
    );
  }

  late MiuixPullToRefreshState _publicState;
  late final AnimationController _motionController;
  late final AnimationController _completeController;

  double _dragOffset = 0;
  double _rawTouch = 0;
  double _visualThreshold = 0;
  double _triggerThreshold = 0;
  double _fullDragRange = 0;
  double _resolvedRefreshThreshold = .25;
  double _maxDrag = 1;
  double _motionStart = 0;
  double _motionTarget = 0;
  double _completeProgress = 1;
  bool _processingRelease = false;
  bool _startingRefresh = false;
  bool _reduceMotion = false;
  MiuixRefreshState _refreshState = MiuixRefreshState.idle;

  // Flutter's Scrollable starts reporting drag notifications only after its
  // gesture recognizer crosses touch slop. Compose nested scroll receives the
  // complete pointer displacement, so a parent Listener restores that missing
  // first segment while notifications continue to drive scrolling semantics.
  ScrollMetrics? _latestMetrics;
  int? _activePointer;
  Offset? _pointerOrigin;
  double _pointerRawStart = 0;
  bool _directPointerDrag = false;
  bool _awaitingTop = false;
  bool _progressCallbackScheduled = false;
  double _pendingFullDragProgress = 0;
  double? _lastReportedFullDragProgress;

  bool get _refreshLocked =>
      _startingRefresh ||
      _refreshState == MiuixRefreshState.refreshing ||
      _refreshState == MiuixRefreshState.refreshComplete;

  // Android Compose inherits ViewConfiguration.scaledTouchSlop, whose base
  // value is 8dp. Flutter's vertical recognizer falls back to 18dp, which is
  // why its first overscroll notification is visibly later on the same device.
  double get _sourceTouchSlop =>
      defaultTargetPlatform == TargetPlatform.android ? 8 : kTouchSlop;

  @override
  void initState() {
    super.initState();
    _publicState = widget.state ?? MiuixPullToRefreshState();
    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..addListener(_applyMotionFrame);
    _completeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(_applyCompleteFrame);
    if (widget.isRefreshing == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startRefresh(invokeCallback: false);
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion) {
      return;
    }
    _reduceMotion = reduceMotion;
    if (!reduceMotion) {
      return;
    }
    // Completing, rather than canceling, the ticker futures lets the existing
    // release/finish coroutine advance through the same state transitions.
    // Publishing controller value one also commits the exact logical target.
    if (_motionController.isAnimating) {
      _motionController.stop(canceled: false);
      _motionController.value = 1;
    }
    if (_completeController.isAnimating) {
      _completeController.stop(canceled: false);
      _completeController.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant MiuixPullToRefresh oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _publicState = widget.state ?? MiuixPullToRefreshState();
      _publishState();
    }
    if (oldWidget.onPullProgress != widget.onPullProgress) {
      _lastReportedFullDragProgress = null;
      _scheduleProgressCallback();
    }
    // A non-null value follows the hoisted Compose contract. Starting and
    // finishing are driven solely by changes from the owning application.
    if (widget.isRefreshing == true && oldWidget.isRefreshing != true) {
      _startRefresh(invokeCallback: false);
    } else if (widget.isRefreshing == false &&
        oldWidget.isRefreshing == true &&
        _refreshState == MiuixRefreshState.refreshing) {
      _finishRefresh();
    }
  }

  @override
  void dispose() {
    _motionController.dispose();
    _completeController.dispose();
    super.dispose();
  }

  /// MIUIX derives both visual and configurable thresholds from the window.
  ///
  /// The indicator's fixed visual offset is `height / 24`. The trigger is a
  /// configurable fraction of the full damped range, whose maximum is exactly
  /// one third of a complete-window pointer drag.
  void _updateViewportGeometry() {
    final windowHeight = MediaQuery.sizeOf(context).height;
    final nextMax = math.max(windowHeight, 1).toDouble();
    final requestedThreshold = widget.refreshThreshold.isFinite
        ? widget.refreshThreshold
        : .25;
    final nextResolvedThreshold = requestedThreshold.clamp(0.0, 1.0);
    final nextFullDragRange = nextMax / 3;
    final nextVisualThreshold = nextMax / 24;
    final nextTriggerThreshold = nextResolvedThreshold * nextFullDragRange;
    if ((_maxDrag - nextMax).abs() < .01 &&
        (_visualThreshold - nextVisualThreshold).abs() < .01 &&
        (_triggerThreshold - nextTriggerThreshold).abs() < .01) {
      return;
    }
    _maxDrag = nextMax;
    _visualThreshold = nextVisualThreshold;
    _triggerThreshold = nextTriggerThreshold;
    _fullDragRange = nextFullDragRange;
    _resolvedRefreshThreshold = nextResolvedThreshold;
    // Geometry is calculated while the widget builds. Publish the values
    // immediately for synchronous getters, then notify listeners after the
    // frame so an AnimatedBuilder never receives setState-during-build.
    _publishState(notify: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _publishState();
      }
    });
  }

  void _publishState({bool notify = true}) {
    _publicState._synchronize(
      dragOffset: _dragOffset,
      visualThreshold: _visualThreshold,
      triggerThreshold: _triggerThreshold,
      fullDragRange: _fullDragRange,
      refreshThreshold: _resolvedRefreshThreshold,
      maxDrag: _maxDrag,
      completeProgress: _completeProgress,
      refreshState: _refreshState,
      notify: notify,
    );
    if (notify) {
      _scheduleProgressCallback();
    }
  }

  /// Coalesces the source progress observer to one delivery per rendered frame.
  void _scheduleProgressCallback() {
    final callback = widget.onPullProgress;
    if (callback == null || _fullDragRange <= 0) {
      return;
    }
    _pendingFullDragProgress = (_dragOffset / _fullDragRange).clamp(0.0, 1.0);
    if (_progressCallbackScheduled) {
      return;
    }
    _progressCallbackScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _progressCallbackScheduled = false;
      if (!mounted || widget.onPullProgress == null) {
        return;
      }
      final progress = _pendingFullDragProgress;
      if (_lastReportedFullDragProgress == progress) {
        return;
      }
      _lastReportedFullDragProgress = progress;
      widget.onPullProgress!(progress);
    });
  }

  void _commit(VoidCallback update) {
    if (!mounted) {
      return;
    }
    setState(update);
    _publishState();
  }

  /// Source damping is `x - x² + x³ / 3` over the full window range.
  double _dampedDistance(double touch) {
    final normalized = (touch.abs() / _maxDrag).clamp(0.0, 1.0);
    final factor =
        normalized -
        normalized * normalized +
        normalized * normalized * normalized / 3;
    return factor * _maxDrag * touch.sign;
  }

  /// Restores raw pointer distance when a spring animation is interrupted.
  double _rawDistanceFor(double offset) {
    if (offset == 0) {
      return 0;
    }
    final maximum = _maxDrag / 3;
    final clamped = offset.abs().clamp(0.0, maximum);
    final base = _maxDrag - 3 * clamped;
    final cubeRoot = base == 0
        ? 0.0
        : base.sign * math.pow(base.abs(), 1 / 3).toDouble();
    final restored = _maxDrag - math.pow(_maxDrag, 2 / 3).toDouble() * cubeRoot;
    return restored * offset.sign;
  }

  void _applyDrag(double delta) {
    if (delta == 0 || _refreshLocked) {
      return;
    }
    _motionController.stop();
    final oldState = _refreshState;
    _commit(() {
      _rawTouch = (_rawTouch + delta).clamp(0.0, _maxDrag);
      _dragOffset = _dampedDistance(_rawTouch).clamp(0.0, _maxDrag / 3);
      _completeProgress = 1;
      _refreshState = _dragOffset > 0 && _dragOffset >= _triggerThreshold
          ? MiuixRefreshState.thresholdReached
          : _dragOffset > 0
          ? MiuixRefreshState.pulling
          : MiuixRefreshState.idle;
    });
    // Compose emits the gesture-threshold haptic once on phase entry.
    if (oldState != MiuixRefreshState.thresholdReached &&
        _refreshState == MiuixRefreshState.thresholdReached) {
      unawaited(MiuixHaptics.perform(MiuixHapticType.gestureThresholdActivate));
    }
  }

  bool _handleNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }
    _latestMetrics = notification.metrics;
    // The source nested-scroll connection lets the top bar consume ordinary
    // list movement first while refresh is idle. Calling the same controller
    // here preserves that contract when this widget is used outside Scaffold.
    if (_refreshState == MiuixRefreshState.idle) {
      widget.topAppBarScrollBehavior?.handleNotification(notification);
    }
    if (_refreshLocked) {
      return false;
    }
    final atTop = notification.metrics.extentBefore <= .5;
    if (notification is ScrollStartNotification && atTop) {
      _processingRelease = false;
      if (_dragOffset <= .5) {
        _commit(() {
          _dragOffset = 0;
          _rawTouch = 0;
          _refreshState = MiuixRefreshState.idle;
        });
      }
    } else if (notification is OverscrollNotification &&
        atTop &&
        !_directPointerDrag) {
      // Flutter reports top-edge pull as negative overscroll. A positive
      // overscroll hides any header that is already being held open.
      if (notification.overscroll < 0 || _dragOffset > 0) {
        _applyDrag(-notification.overscroll);
      }
    } else if (notification is ScrollUpdateNotification &&
        notification.dragDetails != null &&
        !_directPointerDrag) {
      final delta = notification.scrollDelta;
      // Null deltas are valid synthetic notifications and must stay inert.
      if (delta != null && ((atTop && delta < 0) || _dragOffset > 0)) {
        _applyDrag(-delta);
      }
    } else if (notification is ScrollEndNotification && _dragOffset > 0) {
      _handleRelease();
    }
    return false;
  }

  bool _handleMetricsNotification(ScrollMetricsNotification notification) {
    if (notification.metrics.axis == Axis.vertical) {
      _latestMetrics = notification.metrics;
    }
    return false;
  }

  void _handlePointerDown(PointerDownEvent event) {
    // A second contact must not replace the pointer whose displacement owns
    // the current pull gesture.
    if (_activePointer != null) {
      return;
    }
    _activePointer = event.pointer;
    _pointerOrigin = event.position;
    _pointerRawStart = _rawTouch;
    _directPointerDrag = false;
    // When a gesture begins inside a scrolled list, Compose first lets the
    // child consume movement back to its top. Only later unconsumed movement
    // belongs to pull-to-refresh.
    _awaitingTop =
        _dragOffset <= .5 &&
        (_latestMetrics?.extentBefore ?? double.infinity) > .5;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_activePointer != event.pointer || _pointerOrigin == null) {
      return;
    }
    final atTop = (_latestMetrics?.extentBefore ?? double.infinity) <= .5;
    if (_awaitingTop) {
      if (atTop) {
        // Do not reuse the movement that brought the child to its boundary.
        // Any leftover overscroll from this event was already applied by the
        // notification fallback and becomes the next direct-drag baseline.
        _awaitingTop = false;
        _pointerOrigin = event.position;
        _pointerRawStart = _rawTouch;
      }
      return;
    }
    if (!atTop && _dragOffset <= .5) {
      _pointerOrigin = event.position;
      _pointerRawStart = _rawTouch;
      return;
    }

    final displacement = event.position - _pointerOrigin!;
    if (!_directPointerDrag) {
      final verticalIntent =
          displacement.dy.abs() > kTouchSlop &&
          displacement.dy.abs() > displacement.dx.abs();
      final canOpen = displacement.dy > 0;
      final canClose = _pointerRawStart > .5;
      if (!verticalIntent || (!canOpen && !canClose)) {
        return;
      }
      _directPointerDrag = true;
    }

    // Correct towards the source recognizer's post-slop displacement instead
    // of adding a second delta. This remains exact whether Flutter delivered
    // an OverscrollNotification before or after the parent Listener.
    final sourceDisplacement =
        (displacement.dy.abs() - _sourceTouchSlop).clamp(0.0, _maxDrag) *
        displacement.dy.sign;
    final desiredRaw = (_pointerRawStart + sourceDisplacement).clamp(
      0.0,
      _maxDrag,
    );
    _applyDrag(desiredRaw - _rawTouch);
  }

  void _handlePointerEnd(PointerEvent event) {
    if (_activePointer != event.pointer) {
      return;
    }
    final shouldRelease = _directPointerDrag && _dragOffset > 0;
    _activePointer = null;
    _pointerOrigin = null;
    _directPointerDrag = false;
    _awaitingTop = false;
    if (shouldRelease) {
      unawaited(_handleRelease());
    }
  }

  Future<void> _handleRelease() async {
    if (_processingRelease || _refreshLocked) {
      return;
    }
    _processingRelease = true;
    try {
      if (_dragOffset > 0 && _dragOffset >= _triggerThreshold) {
        await _startRefresh();
      } else {
        await _animateOffsetTo(0);
        if (mounted) {
          _commit(() => _refreshState = MiuixRefreshState.idle);
        }
      }
    } finally {
      _processingRelease = false;
    }
  }

  Future<void> _animateOffsetTo(double target) async {
    _motionStart = _dragOffset;
    _motionTarget = target;
    if ((_motionStart - target).abs() < .01) {
      _commit(() {
        _dragOffset = target;
        _rawTouch = _rawDistanceFor(target);
      });
      return;
    }
    if (_reduceMotion) {
      // Pointer-driven drag remains direct manipulation. Only the autonomous
      // release spring is skipped after the pointer has left the screen.
      _motionController.stop(canceled: false);
      _commit(() {
        _dragOffset = target;
        _rawTouch = _rawDistanceFor(target);
      });
      return;
    }
    _motionController.value = 0;
    final simulation = SpringSimulation(_settleSpring(), 0, 1, 0);
    // Upstream declares equilibrium once displacement is below one physical
    // content pixel and does not require velocity to reach a second threshold.
    simulation.tolerance = Tolerance(
      distance: 1 / math.max((_motionTarget - _motionStart).abs(), 1),
      velocity: double.infinity,
    );
    await _motionController.animateWith(simulation);
    if (mounted) {
      // SpringEngine writes the exact target after its equilibrium test so
      // subsequent inverse-damping calculations never retain a subpixel tail.
      _commit(() {
        _dragOffset = target;
        _rawTouch = _rawDistanceFor(target);
      });
    }
  }

  void _applyMotionFrame() {
    if (!mounted) {
      return;
    }
    final value = ui.lerpDouble(
      _motionStart,
      _motionTarget,
      _motionController.value,
    )!;
    _commit(() {
      _dragOffset = value;
      _rawTouch = _rawDistanceFor(value);
    });
  }

  Future<void> _startRefresh({bool invokeCallback = true}) async {
    // Refresh operation ownership contract:
    // - Drag release and external controlled state share one operation lock.
    // - The lock starts before the threshold spring awaits its first frame.
    // - A hoisted true update cannot start a second spring during that await.
    // - One accepted gesture therefore invokes at most one refresh callback.
    // - Programmatic starts may suppress callback invocation explicitly.
    // - The callback reference is captured with the operation that accepted it.
    // - Parent rebuilds cannot redirect an in-flight gesture to a new callback.
    // - Synchronous throws are converted into the same Future error channel.
    // - Uncontrolled mode awaits completion before starting the finish motion.
    // - Controlled mode leaves completion timing to the caller's boolean level.
    // - Controlled callback Futures are observed even though they are not awaited.
    // - Every observed callback error is reported through FlutterError once.
    // - Reporting does not force the caller's controlled visual state to false.
    // - The refresh orbit starts only after the threshold spring has landed.
    // - Mounted checks guard every state transition after an asynchronous wait.
    // - A synchronous true-to-false pulse receives two visible frame boundaries.
    // - An owner that remains true keeps the indicator in refreshing state.
    // - An owner that becomes false requests the normal completion transition.
    // - The start lock is cleared in finally for success, error and disposal.
    // - The regular refreshing lock remains active after the start lock clears.
    // - Motion cancellation cannot create a second accepted refresh operation.
    // - Direct drag input remains rejected throughout both locked phases.
    // - Indicator geometry continues to use the shared visual threshold.
    // - Callback errors never bypass cleanup of the operation ownership flag.
    // - This method does not dispose controllers or mutate caller-owned objects.
    // - Haptic threshold feedback remains owned by the drag transition path.
    // - Accessibility announcements remain tied to refresh state transitions.
    // - Nested scroll notifications still pass through the existing depth guard.
    // - The example application has no special branch in this behavior.
    // - Regression coverage lifts controlled state during the release spring.
    // - Future entry points must consult _refreshLocked before starting work.
    if (_refreshLocked) {
      return;
    }
    _startingRefresh = true;
    final refreshCallback = widget.onRefresh;
    try {
      // Source keeps ThresholdReached visible while the spring returns from an
      // over-pull. Only landing at the threshold starts the orbit and callback.
      await _animateOffsetTo(_visualThreshold);
      if (!mounted) {
        return;
      }
      _commit(() => _refreshState = MiuixRefreshState.refreshing);
      // With a hoisted boolean the owner decides when loading ends. The legacy
      // Future-based form remains convenient and completes automatically.
      if (invokeCallback) {
        try {
          final operation = Future<void>.sync(refreshCallback);
          if (widget.isRefreshing == null) {
            await operation;
          } else {
            unawaited(
              operation.catchError((Object error, StackTrace stackTrace) {
                _reportRefreshError(error, stackTrace);
              }),
            );
          }
        } catch (error, stackTrace) {
          _reportRefreshError(error, stackTrace);
        }
      }
      if (mounted && widget.isRefreshing == null) {
        await _finishRefresh();
      } else if (mounted && widget.isRefreshing != null) {
        // Let a synchronous owner callback publish its hoisted `true` level.
        // This also re-samples a short true-to-false pulse that ends while the
        // programmatic expansion spring is still running, as upstream does.
        // The first boundary renders the state change when completion arrived
        // between frames; the second guarantees one complete visible frame.
        await WidgetsBinding.instance.endOfFrame;
        await WidgetsBinding.instance.endOfFrame;
        if (mounted &&
            widget.isRefreshing != true &&
            _refreshState == MiuixRefreshState.refreshing) {
          await _finishRefresh();
        }
      }
    } finally {
      _startingRefresh = false;
    }
  }

  void _reportRefreshError(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'flutter_miuix',
        context: ErrorDescription('while running MiuixPullToRefresh'),
      ),
    );
  }

  Future<void> _finishRefresh() async {
    if (!mounted || _refreshState != MiuixRefreshState.refreshing) {
      return;
    }
    _completeController.stop();
    _completeController.value = 0;
    _commit(() {
      _completeProgress = 0;
      _refreshState = MiuixRefreshState.refreshComplete;
    });
    if (_reduceMotion) {
      // Keep the success phase for one rendered frame so its text and semantic
      // state are not erased merely because the visual collapse is disabled.
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted || _refreshState != MiuixRefreshState.refreshComplete) {
        return;
      }
      _completeController.value = 1;
      _commit(() => _refreshState = MiuixRefreshState.idle);
      await _animateOffsetTo(0);
      return;
    }
    await _completeController.animateTo(
      1,
      duration: _safeMotionDuration(
        widget._sourceMotion
            ? const Duration(milliseconds: 200)
            : MiuixTheme.of(context).hyperOs4.pullRefreshCompleteMotion,
      ),
      curve: const Cubic(0, 0, 0, .37),
    );
    if (!mounted) {
      return;
    }
    _commit(() => _refreshState = MiuixRefreshState.idle);
    await _animateOffsetTo(0);
  }

  void _applyCompleteFrame() {
    if (mounted) {
      _commit(() => _completeProgress = _completeController.value);
    }
  }

  @override
  Widget build(BuildContext context) {
    _updateViewportGeometry();
    final hyperOs4 = MiuixTheme.of(context).hyperOs4;
    final themeCircleSize = hyperOs4.pullRefreshIndicatorSize.isFinite
        ? hyperOs4.pullRefreshIndicatorSize
              .clamp(0.0, double.infinity)
              .toDouble()
        : MiuixPullToRefreshDefaults.circleSize;
    final circleSize = widget.circleSize.isFinite
        ? widget.circleSize.clamp(0.0, double.infinity).toDouble()
        : themeCircleSize;
    final orbitDuration = widget._sourceMotion
        ? const Duration(milliseconds: 800)
        : _safeMotionDuration(hyperOs4.pullRefreshOrbitMotion);
    final scaleEndThreshold = math.min(_visualThreshold, _triggerThreshold);
    final progress = scaleEndThreshold > 0
        ? (_dragOffset / scaleEndThreshold).clamp(0.0, 1.0)
        : _dragOffset > 0
        ? 1.0
        : 0.0;
    final headerHeight = _headerExtent(
      baseExtent: circleSize + 36,
      progress: progress,
    );
    final indicatorHeight = _headerExtent(
      baseExtent: circleSize,
      progress: progress,
    );
    final resolvedPadding = widget.contentPadding.resolve(
      Directionality.of(context),
    );
    final indicatorColor = widget.color ?? MiuixPullToRefreshDefaults.color;
    // PullToRefresh owns the top-edge feedback. Leaving Flutter's Android
    // stretching indicator enabled paints a second displacement over the
    // source header, so preserve every inherited behavior except overscroll.
    final inheritedScrollBehavior = ScrollConfiguration.of(context);
    final childScrollBehavior = inheritedScrollBehavior.copyWith(
      overscroll: false,
      physics: _MiuixPullRefreshScrollPhysics(
        isRefreshLocked: () => _dragOffset > .5 || _refreshLocked,
        parent: inheritedScrollBehavior.getScrollPhysics(context),
      ),
    );
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: _handlePointerEnd,
      onPointerCancel: _handlePointerEnd,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableHeight = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : headerHeight;
          final contentHeight = math
              .max(0, availableHeight - headerHeight)
              .toDouble();
          // A Stack preserves the source Column geometry without RenderFlex
          // diagnostics when a deliberately extreme pull grows taller than a
          // compact test host. In normal pages the second Positioned is exactly
          // equivalent to Column(header, Expanded(content)).
          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: headerHeight,
                child: SizedBox(
                  key: const ValueKey('miuix-pull-refresh-header'),
                  child: Transform.translate(
                    offset: Offset(0, resolvedPadding.top),
                    child: _MiuixPullRefreshHeader(
                      state: _refreshState,
                      progress: progress,
                      completeProgress: _completeProgress,
                      dragOffset: _dragOffset,
                      threshold: _visualThreshold,
                      maxDrag: _maxDrag,
                      indicatorHeight: indicatorHeight,
                      circleSize: circleSize,
                      orbitDuration: orbitDuration,
                      color: indicatorColor,
                      refreshTexts: widget.refreshTexts,
                      textStyle: widget.refreshTextStyle,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: math.min(headerHeight, availableHeight),
                left: 0,
                right: 0,
                height: contentHeight,
                child: ScrollConfiguration(
                  behavior: childScrollBehavior,
                  child: NotificationListener<ScrollMetricsNotification>(
                    onNotification: _handleMetricsNotification,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _handleNotification,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  double _headerExtent({required double baseExtent, required double progress}) {
    return switch (_refreshState) {
      MiuixRefreshState.idle => 0,
      MiuixRefreshState.pulling => baseExtent * progress,
      MiuixRefreshState.thresholdReached =>
        baseExtent + math.max(0, _dragOffset - _visualThreshold),
      MiuixRefreshState.refreshing => baseExtent,
      MiuixRefreshState.refreshComplete => baseExtent * (1 - _completeProgress),
    };
  }
}

class _MiuixPullRefreshHeader extends StatelessWidget {
  const _MiuixPullRefreshHeader({
    required this.state,
    required this.progress,
    required this.completeProgress,
    required this.dragOffset,
    required this.threshold,
    required this.maxDrag,
    required this.indicatorHeight,
    required this.circleSize,
    required this.orbitDuration,
    required this.color,
    required this.refreshTexts,
    required this.textStyle,
  });

  final MiuixRefreshState state;
  final double progress;
  final double completeProgress;
  final double dragOffset;
  final double threshold;
  final double maxDrag;
  final double indicatorHeight;
  final double circleSize;
  final Duration orbitDuration;
  final Color color;
  final List<String> refreshTexts;
  final TextStyle textStyle;

  /// Compose uses `getOrElse(index) { "" }`, so incomplete localization lists
  /// hide only the missing phase instead of rejecting the whole component.
  String _refreshText(int index) =>
      index < refreshTexts.length ? refreshTexts[index] : '';

  String get _label => switch (state) {
    MiuixRefreshState.idle => '',
    MiuixRefreshState.pulling => progress > .5 ? _refreshText(0) : '',
    MiuixRefreshState.thresholdReached => _refreshText(1),
    MiuixRefreshState.refreshing => _refreshText(2),
    MiuixRefreshState.refreshComplete => _refreshText(3),
  };

  double get _labelOpacity => switch (state) {
    MiuixRefreshState.idle => 0,
    MiuixRefreshState.pulling =>
      progress > .6 ? ((progress - .5) * 2).clamp(0.0, 1.0) : 0,
    MiuixRefreshState.thresholdReached || MiuixRefreshState.refreshing => 1,
    MiuixRefreshState.refreshComplete => (1 - completeProgress * 1.95).clamp(
      0.0,
      1.0,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => OverflowBox(
        alignment: Alignment.topCenter,
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0,
        maxHeight: double.infinity,
        // Compose permits the fading label to paint beyond a partially grown
        // header. A Stack expresses that placement without RenderFlex overflow
        // diagnostics in very short hosts or during the first pull pixels.
        child: SizedBox(
          width: constraints.maxWidth,
          height: indicatorHeight + 36,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: indicatorHeight,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _MiuixPullRefreshIndicator(
                    state: state,
                    progress: progress,
                    completeProgress: completeProgress,
                    dragOffset: dragOffset,
                    threshold: threshold,
                    maxDrag: maxDrag,
                    circleSize: circleSize,
                    duration: orbitDuration,
                    color: color,
                  ),
                ),
              ),
              Positioned(
                top: indicatorHeight + 6,
                left: 0,
                right: 0,
                child: Opacity(
                  opacity: _labelOpacity,
                  child: Text(
                    _label,
                    key: const ValueKey('miuix-pull-refresh-label'),
                    textAlign: TextAlign.center,
                    style: textStyle.copyWith(color: color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiuixPullRefreshIndicator extends StatefulWidget {
  const _MiuixPullRefreshIndicator({
    required this.state,
    required this.progress,
    required this.completeProgress,
    required this.dragOffset,
    required this.threshold,
    required this.maxDrag,
    required this.circleSize,
    required this.duration,
    required this.color,
  });

  final MiuixRefreshState state;
  final double progress;
  final double completeProgress;
  final double dragOffset;
  final double threshold;
  final double maxDrag;
  final double circleSize;
  final Duration duration;
  final Color color;

  @override
  State<_MiuixPullRefreshIndicator> createState() =>
      _MiuixPullRefreshIndicatorState();
}

class _MiuixPullRefreshIndicatorState extends State<_MiuixPullRefreshIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final double _initialRotation;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    // The source remembers a random initial degree, then advances exactly one
    // revolution every 800 ms. Keeping the phase separate lets stopping the
    // controller restore the same remembered angle for the next refresh.
    _initialRotation = math.Random().nextInt(361) / 360;
    _rotationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion == reduceMotion && _rotationController.isAnimating) {
      return;
    }
    _reduceMotion = reduceMotion;
    _synchronizeRotation();
  }

  @override
  void didUpdateWidget(covariant _MiuixPullRefreshIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _rotationController.duration = widget.duration;
    }
    if (oldWidget.state != widget.state) {
      _synchronizeRotation();
    }
  }

  void _synchronizeRotation() {
    if (widget.state == MiuixRefreshState.refreshing &&
        !_reduceMotion &&
        widget.duration > Duration.zero) {
      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
    } else {
      _rotationController.stop();
      _rotationController.value = 0;
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.circleSize,
      child: AnimatedBuilder(
        animation: _rotationController,
        builder: (context, _) => CustomPaint(
          key: const ValueKey('miuix-pull-refresh-indicator'),
          painter: _MiuixPullRefreshPainter(
            state: widget.state,
            progress: widget.progress,
            completeProgress: widget.completeProgress,
            dragOffset: widget.dragOffset,
            threshold: widget.threshold,
            maxDrag: widget.maxDrag,
            rotation: (_initialRotation + _rotationController.value) % 1,
            color: widget.color,
          ),
        ),
      ),
    );
  }
}

class _MiuixPullRefreshPainter extends CustomPainter {
  const _MiuixPullRefreshPainter({
    required this.state,
    required this.progress,
    required this.completeProgress,
    required this.dragOffset,
    required this.threshold,
    required this.maxDrag,
    required this.rotation,
    required this.color,
  });

  final MiuixRefreshState state;
  final double progress;
  final double completeProgress;
  final double dragOffset;
  final double threshold;
  final double maxDrag;
  final double rotation;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.shortestSide / 11;
    final radius = math.max(size.shortestSide / 2, size.shortestSide / 3.5);
    final center = Offset(size.width / 2, size.height / 1.8);
    switch (state) {
      case MiuixRefreshState.idle:
        return;
      case MiuixRefreshState.pulling:
        _drawPulling(canvas, center, radius, strokeWidth);
        return;
      case MiuixRefreshState.thresholdReached:
        _drawThreshold(canvas, center, radius, strokeWidth);
        return;
      case MiuixRefreshState.refreshing:
        _drawRefreshing(canvas, center, radius, strokeWidth);
        return;
      case MiuixRefreshState.refreshComplete:
        _drawComplete(canvas, center, radius, strokeWidth);
        return;
    }
  }

  Paint _stroke(Color paintColor, double width) => Paint()
    ..color = paintColor
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = width;

  void _drawPulling(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
  ) {
    final alpha = math.max(0, progress - .2).clamp(0.0, 1.0).toDouble();
    canvas.drawCircle(
      center,
      radius,
      _stroke(color.withValues(alpha: alpha), strokeWidth),
    );
  }

  void _drawThreshold(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
  ) {
    final length = (dragOffset - threshold).clamp(
      0.0,
      math.max(0, maxDrag - threshold),
    );
    final top = center.dy;
    final bottom = center.dy + length;
    final paint = _stroke(color, strokeWidth);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, top), radius: radius),
      math.pi,
      math.pi,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(center.dx, bottom), radius: radius),
      0,
      math.pi,
      false,
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius, top),
      Offset(center.dx - radius, bottom),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius, top),
      Offset(center.dx + radius, bottom),
      paint,
    );
  }

  void _drawRefreshing(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
  ) {
    canvas.drawCircle(center, radius, _stroke(color, strokeWidth));
    final orbitRadius = radius - 2 * strokeWidth;
    final angle = rotation * math.pi * 2;
    canvas.drawCircle(
      center + Offset(math.cos(angle), math.sin(angle)) * orbitRadius,
      strokeWidth,
      Paint()..color = color,
    );
  }

  void _drawComplete(
    Canvas canvas,
    Offset center,
    double radius,
    double strokeWidth,
  ) {
    final animatedRadius = radius * math.max(.9, 1 - completeProgress);
    final alpha = math.max(0, 1 - completeProgress - .35).toDouble();
    final y = center.dy - radius - strokeWidth + animatedRadius;
    canvas.drawCircle(
      Offset(center.dx, y),
      animatedRadius,
      _stroke(color.withValues(alpha: alpha), strokeWidth),
    );
  }

  @override
  bool shouldRepaint(covariant _MiuixPullRefreshPainter oldDelegate) {
    return state != oldDelegate.state ||
        progress != oldDelegate.progress ||
        completeProgress != oldDelegate.completeProgress ||
        dragOffset != oldDelegate.dragOffset ||
        threshold != oldDelegate.threshold ||
        maxDrag != oldDelegate.maxDrag ||
        rotation != oldDelegate.rotation ||
        color != oldDelegate.color;
  }
}
