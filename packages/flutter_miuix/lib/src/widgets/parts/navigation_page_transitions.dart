part of '../miuix_widgets.dart';

/// Damped navigation response used by HyperOS page changes.
///
/// The response is intentionally expressed as a [Curve] so applications can
/// reuse the same motion outside [MiuixNavigationPageTransitionsBuilder]. The
/// numerical values are project calibrations from current app behavior; Xiaomi
/// does not publish them as a developer-facing timing function.
class MiuixNavigationTransitionCurve extends Curve {
  /// Creates the standard HyperOS navigation response.
  const MiuixNavigationTransitionCurve();

  @override
  double transformInternal(double t) {
    // NavTransitionEasing uses a response of .8 and damping ratio of .95.
    // Converting that oscillator to a closed form keeps deterministic frames
    // on Android and Windows without relying on wall-clock spring completion.
    const response = .8;
    const damping = .95;
    const omega = 2 * math.pi / response;
    const spring = omega * omega;
    const friction = damping * 4 * math.pi / response;
    final frequency = math.sqrt(4 * spring - friction * friction) / 2;
    const decay = -friction / 2;
    final sineCoefficient = decay / frequency;
    return math.exp(decay * t) *
            (-math.cos(frequency * t) +
                sineCoefficient * math.sin(frequency * t)) +
        1;
  }
}

/// Resolves forward and reverse page motion without time-reversing the spring.
abstract final class MiuixNavigationTransitionMotion {
  /// Complete calibrated route duration.
  static const Duration duration = Duration(milliseconds: 500);

  /// Shared displacement response.
  static const Curve curve = MiuixNavigationTransitionCurve();

  /// Resolves the visible progress of one route animation.
  static double resolve(
    Animation<double> animation, {
    Curve curve = MiuixNavigationTransitionMotion.curve,
  }) => resolveValue(
    value: animation.value,
    status: animation.status,
    curve: curve,
  );

  /// Resolves a deterministic progress sample for testing or custom routes.
  static double resolveValue({
    required double value,
    required AnimationStatus status,
    Curve curve = MiuixNavigationTransitionMotion.curve,
  }) {
    final clamped = value.clamp(0.0, 1.0);
    if (status != AnimationStatus.reverse) {
      return curve.transform(clamped);
    }
    // A route controller counts from one down to zero while popping. Applying
    // curve(value) directly traverses the settled tail first, whose velocity is
    // nearly zero; users see a pause and then a late jump. Instead, convert to
    // elapsed pop time, run a fresh spring response, and invert displacement.
    final elapsed = 1 - clamped;
    return 1 - curve.transform(elapsed);
  }

  /// Programmatic route curve selected by a source-style motion recipe.
  static Curve programmaticCurve(MiuixNavMotion motion) {
    final spec = motion.programmatic;
    return spec is MiuixNavTweenSettleSpec ? spec.curve : curve;
  }

  /// Programmatic route duration selected by a source-style motion recipe.
  static Duration programmaticDuration(MiuixNavMotion motion) {
    final spec = motion.programmatic;
    if (spec is! MiuixNavTweenSettleSpec) return duration;
    return spec.duration < Duration.zero ? Duration.zero : spec.duration;
  }
}

enum _MiuixRouteBackPhase { idle, drag, cancel, commit }

class _MiuixRouteBackGestureState extends ChangeNotifier {
  PageRoute<dynamic>? owner;
  SwipeEdge? swipeEdge;
  _MiuixRouteBackPhase phase = _MiuixRouteBackPhase.idle;
  double releaseTopProgress = 1;

  void start(PageRoute<dynamic> route, SwipeEdge edge) {
    owner = route;
    swipeEdge = edge;
    phase = _MiuixRouteBackPhase.drag;
    releaseTopProgress = 1;
    notifyListeners();
  }

  void cancel(PageRoute<dynamic> route) {
    if (!identical(owner, route)) return;
    releaseTopProgress = route.animation?.value.clamp(0.0, 1.0) ?? 1;
    phase = _MiuixRouteBackPhase.cancel;
    notifyListeners();
  }

  void commit(PageRoute<dynamic> route) {
    if (!identical(owner, route)) return;
    releaseTopProgress = route.animation?.value.clamp(0.0, 1.0) ?? 1;
    phase = _MiuixRouteBackPhase.commit;
    notifyListeners();
  }

  void clear(PageRoute<dynamic> route, {bool notify = true}) {
    if (!identical(owner, route)) return;
    owner = null;
    swipeEdge = null;
    phase = _MiuixRouteBackPhase.idle;
    releaseTopProgress = 1;
    if (notify) notifyListeners();
  }

  double resolveTrack(double rawValue, Curve curve) {
    final raw = rawValue.clamp(0.0, 1.0);
    final release = releaseTopProgress.clamp(0.0, 1.0);
    return switch (phase) {
      _MiuixRouteBackPhase.drag => raw,
      _MiuixRouteBackPhase.cancel =>
        release >= 1 - 1e-9
            ? 1
            : release +
                  (1 - release) *
                      curve.transform(
                        ((raw - release) / (1 - release)).clamp(0.0, 1.0),
                      ),
      _MiuixRouteBackPhase.commit =>
        release * (1 - curve.transform((1 - raw).clamp(0.0, 1.0))),
      _MiuixRouteBackPhase.idle => raw,
    };
  }
}

final Expando<_MiuixRouteBackGestureState> _miuixRouteBackStates =
    Expando<_MiuixRouteBackGestureState>('miuix route predictive back');

typedef _MiuixPredictiveTransitionBuilder =
    Widget Function(
      BuildContext context,
      _MiuixRouteBackGestureState backGesture,
      Widget child,
    );

class _MiuixPredictivePageTransition extends StatefulWidget {
  const _MiuixPredictivePageTransition({
    required this.route,
    required this.builder,
    required this.child,
  });

  final PageRoute<dynamic> route;
  final _MiuixPredictiveTransitionBuilder builder;
  final Widget child;

  @override
  State<_MiuixPredictivePageTransition> createState() =>
      _MiuixPredictivePageTransitionState();
}

class _MiuixPredictivePageTransitionState
    extends State<_MiuixPredictivePageTransition>
    with WidgetsBindingObserver {
  late _MiuixRouteBackGestureState _backGesture;
  bool _ownsGesture = false;

  void _handleBackGestureChanged() {
    if (mounted) setState(() {});
  }

  void _clearAfterCancel(AnimationStatus status) {
    if (status != AnimationStatus.completed &&
        status != AnimationStatus.dismissed) {
      return;
    }
    widget.route.animation?.removeStatusListener(_clearAfterCancel);
    _backGesture.clear(widget.route);
  }

  @override
  void initState() {
    super.initState();
    final navigator = widget.route.navigator;
    if (navigator == null) {
      throw StateError('A MIUIX page transition requires an attached route.');
    }
    _backGesture = _miuixRouteBackStates[navigator] ??=
        _MiuixRouteBackGestureState();
    _backGesture.addListener(_handleBackGestureChanged);
    _MiuixPredictiveBackOwnerRegistry.instance.register(
      this,
      (_) => widget.route.isCurrent && widget.route.popGestureEnabled,
      context: () => context,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (backEvent.isButtonEvent ||
        !_MiuixPredictiveBackOwnerRegistry.instance.isTop(this, backEvent) ||
        !widget.route.isCurrent ||
        !widget.route.popGestureEnabled) {
      return false;
    }
    _backGesture.start(widget.route, backEvent.swipeEdge);
    _ownsGesture = true;
    widget.route.handleStartBackGesture(progress: 1 - backEvent.progress);
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    if (!identical(_backGesture.owner, widget.route)) return;
    widget.route.handleUpdateBackGestureProgress(
      progress: 1 - backEvent.progress,
    );
  }

  @override
  void handleCancelBackGesture() {
    if (!_ownsGesture || !identical(_backGesture.owner, widget.route)) return;
    _ownsGesture = false;
    _backGesture.cancel(widget.route);
    widget.route.animation?.addStatusListener(_clearAfterCancel);
    widget.route.handleCancelBackGesture();
    final status = widget.route.animation?.status;
    if (status != null) _clearAfterCancel(status);
  }

  @override
  void handleCommitBackGesture() {
    if (MiuixBackGestureScope.blockedOf(context)) {
      handleCancelBackGesture();
      return;
    }
    if (!_ownsGesture || !identical(_backGesture.owner, widget.route)) return;
    _ownsGesture = false;
    _backGesture.commit(widget.route);
    widget.route.handleCommitBackGesture();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      handleCancelBackGesture();
    }
  }

  @override
  Widget build(BuildContext context) => _MiuixBackGuard(
    child: widget.builder(context, _backGesture, widget.child),
  );

  @override
  void dispose() {
    if (_ownsGesture) {
      _ownsGesture = false;
      final route = widget.route;
      // A theme change can replace the transition while retaining its route.
      // Do not mutate the Navigator while the old subtree is being unmounted.
      scheduleMicrotask(() {
        if (route.isActive) route.handleCancelBackGesture();
      });
    }
    WidgetsBinding.instance.removeObserver(this);
    _MiuixPredictiveBackOwnerRegistry.instance.unregister(this);
    widget.route.animation?.removeStatusListener(_clearAfterCancel);
    _backGesture.removeListener(_handleBackGestureChanged);
    _backGesture.clear(widget.route, notify: false);
    super.dispose();
  }
}

/// HyperOS page transition builder for a Flutter [ThemeData].
///
/// Install this builder in [PageTransitionsTheme] and use [MiuixPageRoute] for
/// the matching 500ms route duration. The entering page moves from logical end
/// while the retained page shifts by one quarter toward logical start.
class MiuixNavigationPageTransitionsBuilder extends PageTransitionsBuilder {
  /// Creates a configurable HyperOS page transition.
  const MiuixNavigationPageTransitionsBuilder({
    this.enableDim = true,
    this.enableCornerClip = true,
    this.blockInput = false,
    this.cornerRadius = 32,
    this.navMotion = MiuixNavMotion.defaults,
  });

  /// Whether the retained page receives the source half-black overlay.
  final bool enableDim;

  /// Whether the moving top page receives a continuous leading-edge clip.
  final bool enableCornerClip;

  /// Whether pointer input is absorbed during autonomous route motion.
  final bool blockInput;

  /// Project-calibrated moving-page corner radius.
  final double cornerRadius;

  /// Motion shared by the entering and retained route layers.
  final MiuixNavMotion navMotion;

  @override
  Duration get transitionDuration =>
      MiuixNavigationTransitionMotion.programmaticDuration(navMotion);

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final routeCurve = MiuixNavigationTransitionMotion.programmaticCurve(
      navMotion,
    );
    // 有明确内容来源时使用容器展开，普通页面仍保持原有横向导航。
    final shared = _miuixSharedRoutes[route];
    if (shared != null) {
      return _MiuixSharedViewTransition(
        route: route,
        capture: shared,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        child: child,
      );
    }
    return _MiuixPredictivePageTransition(
      route: route,
      child: child,
      builder: (context, backGesture, child) => AnimatedBuilder(
        animation: Listenable.merge([animation, secondaryAnimation]),
        child: child,
        builder: (context, child) {
          // 普通进出场仍按阅读方向；系统手势必须按物理边缘跟随手指。
          // 页内历史已遵循这个约定，独立路由不能在同一右侧手势中反向移动。
          final isRtl = Directionality.of(context) == TextDirection.rtl;
          // Both channels must use the direction-aware resolver. Fixing only the
          // outgoing page still leaves the retained page and dim layer paused.
          final ownsBackGesture = identical(backGesture.owner, route);
          final hasCoveredPredictiveTrack =
              backGesture.owner != null &&
              !ownsBackGesture &&
              secondaryAnimation.value > 1e-9;
          // 只让本轮上层与下层共享物理方向，不影响同时出现的其他新路由。
          // 取消和提交收尾期间继续保留同一方向，不能在松手时突然翻转。
          final motionDirection = ownsBackGesture || hasCoveredPredictiveTrack
              ? (backGesture.swipeEdge == SwipeEdge.right ? -1.0 : 1.0)
              : (isRtl ? -1.0 : 1.0);
          // 当前页向哪侧离开，反向一侧就会露出；圆角跟随真实露出的边缘。
          final roundLeft = motionDirection > 0;
          final primary = ownsBackGesture
              ? backGesture.resolveTrack(animation.value, routeCurve)
              : MiuixNavigationTransitionMotion.resolve(
                  animation,
                  curve: routeCurve,
                );
          // 共享展开覆盖的来源页不做侧滑，保持真实卡片落点不动。
          final secondary = _miuixSharedCovers[route] != null
              ? 0.0
              : hasCoveredPredictiveTrack
              ? backGesture.resolveTrack(secondaryAnimation.value, routeCurve)
              : MiuixNavigationTransitionMotion.resolve(
                  secondaryAnimation,
                  curve: routeCurve,
                );
          final translation = 1 - primary - secondary / 4;

          // MiuixDefault fades a covered entry from alpha 1 to .9 while its
          // depth moves from zero to one. This is separate from the stronger
          // fullscreen scrim and therefore belongs to the translated page only.
          // Omitting it made the previous page jump from a fully opaque cached
          // frame when pop began instead of recovering continuously with depth.
          Widget scene = Opacity(
            key: const ValueKey('miuix-navigation-covered-opacity'),
            opacity: (1 - secondary * .1).clamp(.9, 1.0),
            child: child!,
          );

          // Only the top scene moves a full page width. The retained scene owns
          // secondaryAnimation and stays rectangular behind the outgoing page.
          final topSceneMoving =
              secondaryAnimation.value == 0 &&
              animation.status != AnimationStatus.completed &&
              animation.status != AnimationStatus.dismissed;
          // Keep the page at the same element depth across motion boundaries.
          // Inserting/removing a clip reparents the route's keyed subtree and
          // invalidates inherited dependencies throughout the retained page.
          scene = ClipPath(
            clipBehavior: enableCornerClip && topSceneMoving && cornerRadius > 0
                ? Clip.antiAlias
                : Clip.none,
            clipper: ShapeBorderClipper(
              shape: MiuixSquircleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: roundLeft
                      ? Radius.circular(cornerRadius)
                      : Radius.zero,
                  topRight: roundLeft
                      ? Radius.zero
                      : Radius.circular(cornerRadius),
                  bottomLeft: roundLeft
                      ? Radius.circular(cornerRadius)
                      : Radius.zero,
                  bottomRight: roundLeft
                      ? Radius.zero
                      : Radius.circular(cornerRadius),
                ),
              ),
            ),
            child: scene,
          );

          final transitioning =
              secondaryAnimation.status == AnimationStatus.forward ||
              animation.status == AnimationStatus.reverse;
          final translatedScene = FractionalTranslation(
            key: const ValueKey('miuix-navigation-transition-scene'),
            translation: Offset(translation * motionDirection, 0),
            child: AbsorbPointer(
              key: const ValueKey('miuix-navigation-transition-input-block'),
              absorbing: blockInput && transitioning,
              child: scene,
            ),
          );

          // NavDisplay paints its dim as a fullscreen sibling immediately below
          // the moving top entry. It is not part of the covered entry's quarter-
          // width parallax layer. Translating the scrim with that page exposed a
          // bright edge strip and made the restored page appear to snap late on
          // pop, especially over glass or animated content.
          return Stack(
            fit: StackFit.passthrough,
            children: [
              translatedScene,
              if (enableDim)
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      key: secondary > 0
                          ? const ValueKey('miuix-navigation-transition-dim')
                          : null,
                      color: Colors.black.withValues(
                        alpha: (secondary * .5).clamp(0.0, .5),
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
}

/// Material route with the duration expected by HyperOS page transitions.
class MiuixPageRoute<T> extends MaterialPageRoute<T> {
  /// Creates a route that uses the library navigation motion duration.
  MiuixPageRoute({
    required super.builder,
    this.navMotion = MiuixNavMotion.defaults,
    super.settings,
    super.requestFocus,
    super.maintainState,
    super.fullscreenDialog,
    super.allowSnapshotting = false,
    super.barrierDismissible,
    super.traversalEdgeBehavior,
    super.directionalTraversalEdgeBehavior,
  });

  /// Source-style motion recipe used for this route's autonomous transition.
  final MiuixNavMotion navMotion;

  NavigatorState? _gestureNavigator;

  // Own the start/stop pair at route lifetime, not transition-widget lifetime.
  // Flutter's default completion callback can disappear when removeRoute or
  // replacement disposes the animation before Android sends cancel/commit.
  // An unmatched start makes every route in this Navigator ignore pointers.
  @override
  void handleStartBackGesture({double progress = 0.0}) {
    if (_gestureNavigator != null || !isCurrent) return;
    controller?.value = progress;
    _gestureNavigator = navigator;
    _gestureNavigator?.didStartUserGesture();
  }

  @override
  void handleCancelBackGesture() => _finishBackGesture(commit: false);

  @override
  void handleCommitBackGesture() => _finishBackGesture(commit: true);

  void _finishBackGesture({required bool commit}) {
    if (_gestureNavigator == null) return;
    controller?.removeStatusListener(_settleBackGesture);
    if (commit && isCurrent) {
      navigator?.pop();
      if (controller?.isAnimating ?? false) {
        controller!.reverse(from: controller!.upperBound);
      }
    } else if (isActive && !(controller?.isCompleted ?? true)) {
      // A dialog or another page may cover the owner during the drag. Restore
      // the retained page too, without popping the new top route.
      controller!.forward();
    }
    if (controller?.isAnimating ?? false) {
      controller!.addStatusListener(_settleBackGesture);
    } else {
      _releaseBackGesture();
    }
  }

  void _settleBackGesture(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _releaseBackGesture();
    }
  }

  void _releaseBackGesture() {
    controller?.removeStatusListener(_settleBackGesture);
    final owner = _gestureNavigator;
    _gestureNavigator = null;
    if (owner != null && owner.mounted) owner.didStopUserGesture();
  }

  @override
  void dispose() {
    _releaseBackGesture();
    super.dispose();
  }

  @override
  Duration get transitionDuration =>
      MiuixNavigationTransitionMotion.programmaticDuration(navMotion);

  @override
  Duration get reverseTransitionDuration => transitionDuration;
}
