part of '../miuix_widgets.dart';

/// Geometry recipes for the liquid floating navigation surface.
enum MiuixIosLiquidNavigationGeometry {
  /// Compact, wide HyperOS 4 project calibration used by new applications.
  hyperOs4,

  /// Original compose-miuix liquid sample geometry retained for migration.
  source,
}

/// iOS-like liquid-glass navigation used by the current upstream MIUIX demo.
///
/// The example exposes this as its single floating-navigation presentation.
/// The older [MiuixFloatingNavigationBar] remains public for compatibility,
/// while this widget owns the upstream spring, drag, refraction, highlight,
/// inset, and display-mode behavior.
class MiuixIosLiquidGlassNavigationBar extends StatefulWidget {
  /// Creates the source-compatible iOS-like floating navigation surface.
  const MiuixIosLiquidGlassNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.showBlur = true,
    this.defaultWindowInsetsPadding = true,
    this.displayMode = MiuixFloatingNavigationBarDisplayMode.iconAndText,
    this.trailingAction,
    this.geometry = MiuixIosLiquidNavigationGeometry.hyperOs4,
  });

  /// Creates the explicit 64/56dp compose-miuix sample geometry.
  const MiuixIosLiquidGlassNavigationBar.source({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.showBlur = true,
    this.defaultWindowInsetsPadding = true,
    this.displayMode = MiuixFloatingNavigationBarDisplayMode.iconAndText,
    this.trailingAction,
  }) : geometry = MiuixIosLiquidNavigationGeometry.source;

  /// Destinations displayed at equal widths.
  ///
  /// HyperOS applications normally use two to five. Empty and transitional
  /// lists remain safe so asynchronously loaded navigation cannot crash a
  /// frame; an empty list paints no bar.
  final List<MiuixNavigationItem> items;

  /// Index selected by the owning pager.
  final int selectedIndex;

  /// Called after a tap or after a horizontal drag settles on a destination.
  final ValueChanged<int> onDestinationSelected;

  /// Whether the liquid surface may sample and blur the content behind it.
  final bool showBlur;

  /// Whether to retain the source system-navigation bottom inset behavior.
  final bool defaultWindowInsetsPadding;

  /// Controls whether each equal-width destination shows icon, text, or both.
  final MiuixFloatingNavigationBarDisplayMode displayMode;

  /// Optional independent action displayed beside the destination capsule.
  ///
  /// HyperOS 4 applications use this slot for a page-level action such as
  /// search. It is intentionally not a destination: tapping it neither moves
  /// the liquid selector nor changes [selectedIndex]. The 64dp circle, 12dp
  /// separation, and 80dp preferred destination width are project-calibrated
  /// from current Xiaomi application captures, not published official tokens.
  ///
  /// Layout contract:
  ///
  /// - The action uses the same 64dp visible height as the main capsule.
  /// - The action is separated from the destination panel by a transparent
  ///   12dp gap, so neither shadow can read as a rectangular bridge.
  /// - Two destinations prefer a 168dp panel: two 80dp slots plus the panel's
  ///   two 4dp insets. More destinations use the same preferred slot width.
  /// - The complete split group is centered, rather than pinning the action to
  ///   the window edge and leaving the navigation capsule optically off-axis.
  /// - A narrow window first contracts the equal destination slots. It never
  ///   gives a longer localized label more width than its siblings.
  /// - The 24dp outer allowance remains reserved before width is calculated,
  ///   so a display cutout cannot force the circle against the window edge.
  ///
  /// Interaction contract:
  ///
  /// - [trailingAction] owns its callback, focus, tooltip, and semantics.
  /// - Pointer events in the action never enter the navigation drag arena.
  /// - Destination haptics are therefore emitted only by actual destinations.
  /// - The action remains usable when [showBlur] is false; only its material
  ///   changes from sampled glass to an opaque semantic surface.
  /// - System bottom insets move the complete group together and do not paint
  ///   a background behind the Android gesture indicator.
  ///
  /// Rendering contract:
  ///
  /// - Blur, tint, border, and shadow are clipped to the exact circle.
  /// - The shadow is outside the filtered child so the circular silhouette is
  ///   not clipped and cannot become a square at the corners.
  /// - Global five-level glass intensity affects tint and blur consistently
  ///   with the main capsule.
  /// - The optional action does not change legacy geometry when it is null.
  final Widget? trailingAction;

  /// Selects compact HyperOS 4 or explicit source-compatible geometry.
  final MiuixIosLiquidNavigationGeometry geometry;

  @override
  State<MiuixIosLiquidGlassNavigationBar> createState() =>
      _MiuixIosLiquidGlassNavigationBarState();
}

class _MiuixIosLiquidGlassNavigationBarState
    extends State<MiuixIosLiquidGlassNavigationBar>
    with TickerProviderStateMixin {
  // Source geometry from LiquidGlassNavigationBar.kt. Keeping the numbers in
  // one block makes an upstream metric change visible during parity reviews.
  static const double _outsideHorizontalPadding = 24;
  static const double _panelPadding = 4;
  static const double _splitActionGap = 12;
  static const double _preferredSplitTabWidth = 80;
  static const double _iconSize = 22;
  static const double _labelSize = 11;
  // HyperOS 4 project calibration: dragging insets the travelling thumb by
  // 2dp on every side. The default resting selector is a tab-wide 48dp pill;
  // the explicit source geometry retains the upstream 56dp selector.
  static const double _rubberBandReach = 4;

  double get _panelHeight =>
      widget.geometry == MiuixIosLiquidNavigationGeometry.source ? 64 : 56;

  double get _indicatorHeight =>
      widget.geometry == MiuixIosLiquidNavigationGeometry.source ? 56 : 48;

  double get _pressedIndicatorScale =>
      widget.geometry == MiuixIosLiquidNavigationGeometry.source ? 52 / 56 : 1;

  // Compose spring(dampingRatio, stiffness) maps to a unit-mass Flutter
  // spring whose damping coefficient is 2 * ratio * sqrt(stiffness).
  static SpringDescription _spring(double ratio, double stiffness) =>
      SpringDescription(
        mass: 1,
        stiffness: stiffness,
        damping: 2 * ratio * math.sqrt(stiffness),
      );

  // The independent channels intentionally match DampedDragAnimation:
  // value (1/1000), press (1/1000), X scale (.6/250), Y scale (.7/250), and
  // panel release (1/300). Merging them gives one deterministic paint tick.
  late final AnimationController _position;
  late final AnimationController _pressProgress;
  late final AnimationController _scaleX;
  late final AnimationController _scaleY;
  late final AnimationController _panelDrag;
  late final AnimationController _spotProgress;
  late final Listenable _indicatorMotion;
  late final Listenable _highlightMotion;
  late final Listenable _tabContentMotion;

  // The source derives specular direction from a quantized in-plane gravity
  // angle. A notifier repaints the narrow highlight paths without rebuilding
  // the complete navigation tree for every native sensor sample.
  late final ValueNotifier<double> _gravityAngle;
  StreamSubscription<MiuixDeviceTilt>? _tiltSubscription;

  // A GlobalKey lets an indicator-owned drag reject movement once the pointer
  // leaves the complete panel, matching canDrag() in DampedDragAnimation.
  final GlobalKey _panelKey = GlobalKey();

  double _tabWidth = 0;
  double _panelWidth = 0;
  double _positionTarget = 0;
  bool _releaseWaiting = false;
  bool _dragging = false;
  bool _pointerDown = false;
  bool _reduceMotion = false;
  int _releaseEpoch = 0;
  int _motionPreferenceGeneration = 0;
  int _currentIndex = 0;
  int _pointerTargetIndex = 0;
  double _dragVelocity = 0;
  Duration _lastDragFrame = Duration.zero;

  int get _safeSelected => widget.items.isEmpty
      ? -1
      : widget.selectedIndex.clamp(0, widget.items.length - 1);

  double get _positionSpan => math.max(1, widget.items.length - 1).toDouble();

  @override
  void initState() {
    super.initState();
    _currentIndex = _safeSelected;
    _positionTarget = math.max(0, _currentIndex).toDouble();
    _position = AnimationController.unbounded(
      vsync: this,
      value: _positionTarget,
    )..addListener(_checkDeferredRelease);
    _pressProgress = AnimationController.unbounded(vsync: this, value: 0);
    _scaleX = AnimationController.unbounded(vsync: this, value: 1);
    _scaleY = AnimationController.unbounded(vsync: this, value: 1);
    _panelDrag = AnimationController.unbounded(vsync: this, value: 0);
    _spotProgress = AnimationController.unbounded(vsync: this, value: 0);
    // Split invalidation domains so a horizontal pointer sample moves only the
    // selector and highlight. The expensive outer lens remains a stable child
    // instead of being reconstructed for every spring tick.
    _indicatorMotion = Listenable.merge([_position, _scaleX, _scaleY]);
    _highlightMotion = Listenable.merge([_position, _spotProgress]);
    _tabContentMotion = Listenable.merge([_position, _pressProgress]);
    _gravityAngle = ValueNotifier<double>(-math.pi / 2);
    _tiltSubscription = MiuixDeviceTiltSensor.events.listen(_updateGravity);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion) return;
    _reduceMotion = reduceMotion;
    final generation = ++_motionPreferenceGeneration;
    if (!reduceMotion) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          !_reduceMotion ||
          generation != _motionPreferenceGeneration) {
        return;
      }
      _settleReducedMotion();
    });
  }

  @override
  void didUpdateWidget(covariant MiuixIosLiquidGlassNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selected = _safeSelected;
    if (selected < 0) {
      _releaseEpoch++;
      _releaseWaiting = false;
      _dragging = false;
      _pointerDown = false;
      _currentIndex = -1;
      _pointerTargetIndex = -1;
      _positionTarget = 0;
      _position
        ..stop()
        ..value = 0;
      _pressProgress
        ..stop()
        ..value = 0;
      _scaleX
        ..stop()
        ..value = 1;
      _scaleY
        ..stop()
        ..value = 1;
      _panelDrag
        ..stop()
        ..value = 0;
      _spotProgress
        ..stop()
        ..value = 0;
      return;
    }
    if (selected != _currentIndex) {
      _currentIndex = selected;
    }
    final target = selected.toDouble();
    if ((target - _positionTarget).abs() > .001 ||
        (target - _position.value).abs() > .001) {
      if (_reduceMotion) {
        final generation = ++_motionPreferenceGeneration;
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              _reduceMotion &&
              generation == _motionPreferenceGeneration) {
            _animateToValue(target);
          }
        });
      } else {
        _animateToValue(target);
      }
    }
  }

  @override
  void dispose() {
    _motionPreferenceGeneration++;
    _tiltSubscription?.cancel();
    _gravityAngle.dispose();
    _position.dispose();
    _pressProgress.dispose();
    _scaleX.dispose();
    _scaleY.dispose();
    _panelDrag.dispose();
    _spotProgress.dispose();
    super.dispose();
  }

  // The source ignores near-flat gravity, pins the light upward, and otherwise
  // quantizes direction in 3-degree steps to avoid 50 Hz highlight shimmer.
  void _updateGravity(MiuixDeviceTilt tilt) {
    final magnitudeSquared =
        tilt.gravityX * tilt.gravityX + tilt.gravityY * tilt.gravityY;
    final raw = magnitudeSquared > .01
        ? math.atan2(tilt.gravityY, tilt.gravityX)
        : -math.pi / 2;
    const step = 3 * math.pi / 180;
    final quantized = (raw / step).round() * step;
    if ((_gravityAngle.value - quantized).abs() > .0001) {
      _gravityAngle.value = quantized;
    }
  }

  // Retargeting a spring starts from the currently painted value and physical
  // velocity. This is the Flutter equivalent of interrupting Animatable and
  // prevents a cusp during a rapid tap sequence or a direction-reversing drag.
  void _springTo(
    AnimationController controller,
    double target,
    SpringDescription description, {
    double? velocity,
  }) {
    if (_reduceMotion) {
      controller
        ..stop()
        ..value = target;
      return;
    }
    final currentVelocity = velocity ?? controller.velocity;
    controller.stop();
    controller.animateWith(
      SpringSimulation(description, controller.value, target, currentVelocity),
    );
  }

  void _animatePosition(double target, {double? velocity}) {
    if (widget.items.isEmpty) return;
    _positionTarget = target.clamp(0.0, widget.items.length - 1.0);
    _springTo(_position, _positionTarget, _spring(1, 1000), velocity: velocity);
  }

  /// Stops every autonomous liquid channel at the current logical endpoint.
  void _settleReducedMotion() {
    _releaseEpoch++;
    _releaseWaiting = false;
    _position
      ..stop()
      ..value = _positionTarget;
    _pressProgress.stop();
    _scaleX.stop();
    _scaleY.stop();
    _spotProgress.stop();
    _panelDrag.stop();
    if (_pointerDown) {
      _pressProgress.value = 1;
      _scaleX.value = _pressedIndicatorScale;
      _scaleY.value = _pressedIndicatorScale;
      _spotProgress.value = 1;
    } else {
      _pressProgress.value = 0;
      _scaleX.value = 1;
      _scaleY.value = 1;
      _spotProgress.value = 0;
      _panelDrag.value = 0;
    }
  }

  // A source programmatic selection performs the same press-in animation as a
  // direct interaction; release waits until the selector is near its target.
  void _animateToValue(double target) {
    _press();
    _animatePosition(target);
    _releaseAfterPositionSettles();
  }

  void _press() {
    _releaseEpoch++;
    _releaseWaiting = false;
    _springTo(_pressProgress, 1, _spring(1, 1000));
    _springTo(_scaleX, _pressedIndicatorScale, _spring(.6, 250));
    _springTo(_scaleY, _pressedIndicatorScale, _spring(.7, 250));
    _springTo(_spotProgress, 1, _spring(.5, 300));
  }

  // DampedDragAnimation waits one frame and then waits until the value is
  // within 2.5 percent of its full range. The guard avoids an early shrink
  // while the liquid selector is still travelling across several tabs.
  void _releaseAfterPositionSettles() {
    if (_reduceMotion) {
      _releaseVisuals();
      return;
    }
    final epoch = ++_releaseEpoch;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || epoch != _releaseEpoch) return;
      _releaseWaiting = true;
      _checkDeferredRelease();
    });
  }

  void _checkDeferredRelease() {
    if (!_releaseWaiting) return;
    final threshold = _positionSpan * .025;
    if ((_position.value - _positionTarget).abs() >= threshold) return;
    _releaseVisuals();
  }

  void _releaseVisuals() {
    _releaseEpoch++;
    _releaseWaiting = false;
    _springTo(_pressProgress, 0, _spring(1, 1000));
    _springTo(_scaleX, 1, _spring(.6, 250));
    _springTo(_scaleY, 1, _spring(.7, 250));
    _springTo(_spotProgress, 0, _spring(.5, 300));
  }

  /// Commits one user-originated destination change and its semantic haptic.
  void _commitSelection(int target) {
    if (target == _currentIndex) return;
    setState(() => _currentIndex = target);
    unawaited(MiuixHaptics.perform(MiuixHapticType.segmentTick));
    widget.onDestinationSelected(target);
  }

  void _select(int index) {
    final target = index.clamp(0, widget.items.length - 1);
    _commitSelection(target);
    // Current upstream animates even a repeated keyboard or semantics
    // activation so the liquid press response is never skipped.
    _animateToValue(target.toDouble());
  }

  /// Converts a physical panel coordinate to the current logical tab index.
  int _indexAt(double physicalX) {
    if (_tabWidth <= 0) return _currentIndex;
    final logicalX = Directionality.of(context) == TextDirection.ltr
        ? physicalX
        : _panelWidth - physicalX;
    return ((logicalX - _panelPadding) / _tabWidth).truncate().clamp(
      0,
      widget.items.length - 1,
    );
  }

  /// Starts the current source's whole-panel liquid interaction on raw down.
  void _panelPointerDown(PointerDownEvent event) {
    _dragging = false;
    _pointerDown = true;
    _position.stop();
    _positionTarget = _position.value;
    _dragVelocity = 0;
    _lastDragFrame = event.timeStamp;
    _press();
    final touched = _indexAt(event.localPosition.dx);
    _pointerTargetIndex = widget.items[touched].enabled
        ? touched
        : _currentIndex;
  }

  /// Supplies a release fallback when Android's gesture arena does not send a
  /// tap-up or drag-end callback after a system gesture interruption.
  ///
  /// Listener receives the raw pointer-up before GestureDetector dispatches
  /// its semantic callback. Waiting until the next frame lets the ordinary
  /// tap/drag path win first; only an otherwise stranded press is released.
  void _panelPointerUp(PointerUpEvent event) {
    _pointerDown = false;
    final epoch = _releaseEpoch;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          _pointerDown ||
          epoch != _releaseEpoch ||
          _releaseWaiting) {
        return;
      }
      _springTo(_panelDrag, 0, _spring(1, 300));
      _releaseAfterPositionSettles();
    });
  }

  /// Commits a tap after the whole-panel gesture reaches pointer up.
  void _panelTapUp() {
    _pointerDown = false;
    final target = _pointerTargetIndex.clamp(0, widget.items.length - 1);
    if (widget.items[target].enabled) _commitSelection(target);
    final settled = widget.items[target].enabled ? target : _currentIndex;
    _animatePosition(settled.toDouble());
    _springTo(_panelDrag, 0, _spring(1, 300));
    _releaseAfterPositionSettles();
  }

  void _dragStart(DragStartDetails details) {
    _dragging = true;
    _dragVelocity = 0;
    _lastDragFrame = details.sourceTimeStamp ?? Duration.zero;
    _updateDragPosition(details.localPosition.dx);
  }

  /// Maps the pointer center directly to the continuous destination axis.
  ///
  /// A drag must track the finger without starting a new spring for every
  /// sample. Springs are reserved for click travel and the final release snap.
  void _updateDragPosition(double physicalX) {
    if (_tabWidth <= 0) return;
    final logicalX = Directionality.of(context) == TextDirection.ltr
        ? physicalX
        : _panelWidth - physicalX;
    final position = ((logicalX - _panelPadding) / _tabWidth - .5).clamp(
      0.0,
      widget.items.length - 1.0,
    );
    _positionTarget = position;
    _position.value = position;
  }

  // Both current and previous pointer positions must remain inside the panel.
  // This reproduces source canDrag() while Flutter keeps the original arena
  // winner even after a pointer has moved beyond the indicator's paint bounds.
  bool _dragSegmentIsInsidePanel(DragUpdateDetails details) {
    final panel = _panelKey.currentContext?.findRenderObject();
    if (panel is! RenderBox || !panel.hasSize) return true;
    final current = panel.globalToLocal(details.globalPosition);
    final previous = current - details.delta;
    return current.dx >= 0 &&
        current.dx <= panel.size.width &&
        previous.dx >= 0 &&
        previous.dx <= panel.size.width;
  }

  void _dragUpdate(DragUpdateDetails details) {
    if (_tabWidth <= 0 || !_dragSegmentIsInsidePanel(details)) return;
    final delta = details.primaryDelta ?? 0;
    final direction = Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    final timestamp = details.sourceTimeStamp ?? Duration.zero;
    final elapsedMicros = (timestamp - _lastDragFrame).inMicroseconds;
    if (elapsedMicros > 0) {
      final instantaneous =
          direction * delta / _tabWidth / (elapsedMicros / 1000000);
      _dragVelocity = ui.lerpDouble(_dragVelocity, instantaneous, .35) ?? 0;
    }
    _lastDragFrame = timestamp;
    _updateDragPosition(details.localPosition.dx);
    _panelDrag.value += delta;
  }

  void _dragEnd(DragEndDetails details) {
    _dragging = false;
    _pointerDown = false;
    // The upstream liquid bar commits the tab nearest its final drag target;
    // release velocity deforms and seeds the settle spring, but must not move
    // the semantic destination into an adjacent tab. Predicting another .45
    // index here made a finger released inside the Icon slot select Home on a
    // real 440-dpi device, especially after a long right-to-left gesture.
    var target = _position.value.round().clamp(0, widget.items.length - 1);
    if (!widget.items[target].enabled) {
      target = _currentIndex;
    }
    final direction = Directionality.of(context) == TextDirection.ltr ? 1 : -1;
    final reportedVelocity = _tabWidth <= 0
        ? 0.0
        : direction * (details.primaryVelocity ?? 0) / _tabWidth;
    final velocity = reportedVelocity == 0 ? _dragVelocity : reportedVelocity;
    _animatePosition(target.toDouble(), velocity: velocity);
    _springTo(_panelDrag, 0, _spring(1, 300));
    _commitSelection(target);
    _releaseAfterPositionSettles();
    _dragVelocity = 0;
  }

  void _dragCancel() {
    _dragging = false;
    _pointerDown = false;
    _animatePosition(_currentIndex.toDouble());
    _springTo(_panelDrag, 0, _spring(1, 300));
    _releaseAfterPositionSettles();
  }

  double get _panelOffset {
    if (_panelWidth <= 0) return 0;
    final fraction = (_panelDrag.value / _panelWidth).clamp(-1.0, 1.0);
    final magnitude = Curves.easeOut.transform(fraction.abs());
    return _rubberBandReach * fraction.sign * magnitude;
  }

  @override
  Widget build(BuildContext context) {
    // Navigation destinations are commonly populated after an asynchronous
    // session restore. Returning no surface for that transitional frame avoids
    // divide-by-zero geometry and stale item indexing.
    //
    // Empty-list lifecycle contract:
    //
    // * No transparent hit target remains where the panel used to be.
    // * No bottom safe-area spacer is emitted without destinations.
    // * An in-flight pointer may still deliver an up event after removal.
    // * didUpdateWidget has already invalidated that pointer generation.
    // * Every spring is stopped before the render subtree disappears.
    // * Selector position returns to a deterministic zero origin.
    // * Press, scale, highlight, and rubber-band channels return to rest.
    // * Restoring one item is supported even though normal designs use 2-5.
    // * The restored selected index is clamped before any item is addressed.
    // * A later expansion preserves equal-width destination layout.
    // * This transitional support does not redefine HyperOS design guidance.
    // * Applications should still present two to five stable destinations.
    if (widget.items.isEmpty) return const SizedBox.shrink();
    return _MiuixNavigationInsetsBuilder(
      builder: (context, nativeInsets) {
        final mediaBottom = MediaQuery.paddingOf(context).bottom;
        final navigationBottom =
            nativeInsets?.navigationBarBottom ?? mediaBottom;
        final bottomPadding = !widget.defaultWindowInsetsPadding
            ? 0.0
            : switch (defaultTargetPlatform) {
                TargetPlatform.iOS => 20.0,
                _ => navigationBottom == 0 ? 36.0 : 8.0 + navigationBottom,
              };
        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = math.max(
                0.0,
                constraints.maxWidth - _outsideHorizontalPadding * 2,
              );
              final hasTrailingAction = widget.trailingAction != null;
              // Reserve the independent circle and the transparent gap before
              // deriving destination width. This keeps every destination
              // equal and prevents the action from overlaying the final tab.
              final maximumPanelWidth = hasTrailingAction
                  ? math.max(
                      0.0,
                      availableWidth - _panelHeight - _splitActionGap,
                    )
                  : availableWidth;
              final preferredPanelWidth =
                  widget.items.length * _preferredSplitTabWidth +
                  _panelPadding * 2;
              // A split two-item bar should stay compact like the reference
              // capture. A five-item bar may consume all remaining width, but
              // it still contracts by one shared factor rather than by label.
              _panelWidth = hasTrailingAction
                  ? math.min(preferredPanelWidth, maximumPanelWidth)
                  : maximumPanelWidth;
              _tabWidth = math.max(
                0,
                (_panelWidth - _panelPadding * 2) / widget.items.length,
              );
              final panel = SizedBox(
                width: _panelWidth,
                child: _buildPanel(context),
              );
              return SizedBox(
                height: _panelHeight,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: _outsideHorizontalPadding,
                    ),
                    child: hasTrailingAction
                        ? Row(
                            key: const ValueKey('ios-liquid-split-group'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              panel,
                              const SizedBox(width: _splitActionGap),
                              _buildTrailingAction(context),
                            ],
                          )
                        : panel,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTrailingAction(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final miuixTheme = MiuixTheme.of(context);
    final intensity = miuixTheme.glassIntensity;
    final glassEnabled = widget.showBlur && miuixTheme.enableGlass;
    final surfaceColor = glassEnabled
        ? scheme.surfaceContainer.withValues(
            alpha: intensity.resolveOpacity(.4),
          )
        : scheme.surfaceContainer;
    final circle = CircleBorder(
      side: glassEnabled
          ? BorderSide(
              color: scheme.onSurface.withValues(alpha: .10),
              width: .5,
            )
          : BorderSide.none,
    );
    final action = SizedBox.square(
      dimension: _panelHeight,
      child: Center(child: widget.trailingAction),
    );
    return SizedBox.square(
      key: const ValueKey('ios-liquid-trailing-action'),
      dimension: _panelHeight,
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: circle,
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: scheme.brightness == Brightness.dark ? .2 : .1,
              ),
              blurRadius: 10,
            ),
          ],
        ),
        child: glassEnabled
            ? MiuixGlass(
                blur: 4,
                opacity: .4,
                color: scheme.surfaceContainer,
                shape: circle,
                padding: EdgeInsets.zero,
                optics: MiuixGlassOptics.navigation,
                child: action,
              )
            : Material(shape: circle, color: surfaceColor, child: action),
      ),
    );
  }

  Widget _buildPanel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final miuixTheme = MiuixTheme.of(context);
    final intensity = miuixTheme.glassIntensity;
    final glassEnabled = widget.showBlur && miuixTheme.enableGlass;
    final sourceInteraction =
        widget.geometry == MiuixIosLiquidNavigationGeometry.source;
    final radius = BorderRadius.circular(_panelHeight / 2);
    final surfaceColor = glassEnabled
        ? scheme.surfaceContainer.withValues(
            alpha: intensity.resolveOpacity(.4),
          )
        : scheme.surfaceContainer;
    // The background tint remains a separately keyed ColoredBox because its
    // alpha is part of the public five-level glass contract and regression
    // tests inspect this channel independently from blur/refraction.
    Widget background = Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          key: const ValueKey('ios-liquid-surface'),
          color: surfaceColor,
        ),
        // BloomStroke is part of the explicit upstream-source rendering. Its
        // secondary light concentrates on the long lower edge of this capsule;
        // over a bright Android backdrop that reads as a solid white divider
        // through the floating bar. HyperOS uses the shared refracting surface
        // without that authored outline, so its content stays visually whole.
        if (glassEnabled && sourceInteraction)
          KeyedSubtree(
            key: const ValueKey('ios-liquid-panel-source-specular'),
            child: _buildSpecular(
              extraDegrees: -45,
              alpha: .75,
              radius: _panelHeight / 2,
            ),
          ),
      ],
    );

    // AndroidLiquidGlass builds its bottom-tab material as vibrancy, 8dp blur,
    // then a 24/24dp rounded-rectangle lens. Keep that optical order while the
    // existing HyperOS geometry, selection and gesture state remain unchanged.
    // The shader state gracefully falls back to blur on Skia or a host that
    // cannot compile runtime image filters. The signed lens displacement points
    // into the capsule, so the complete panel must use its exact paint bounds.
    // Expanding this backdrop past the bottom of the window gives Impeller a
    // truncated input texture and can split the pill into transparent and
    // blurred horizontal halves.
    if (glassEnabled) {
      background = _MiuixLiquidLensBackdrop(
        key: const ValueKey('ios-liquid-backdrop-filter'),
        radius: _panelHeight / 2,
        blurSigma: intensity.resolveBlur(8),
        refractionHeight: 24,
        refractionAmount: 24,
        samplePadding: 0,
        vibrancy: 1.5,
        child: background,
      );
    }

    // Keep the moving indicator as a sibling of the 64dp Row. The root remains
    // unclipped so the specular edge and velocity deformation can paint cleanly
    // without introducing rectangular clipping around the glass capsule.
    final panel = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _panelPointerDown,
      onPointerUp: _panelPointerUp,
      onPointerCancel: (_) {
        if (!_dragging) _dragCancel();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (_) => _panelTapUp(),
        onHorizontalDragStart: _dragStart,
        onHorizontalDragUpdate: _dragUpdate,
        onHorizontalDragEnd: _dragEnd,
        onHorizontalDragCancel: () {
          if (_dragging) _dragCancel();
        },
        child: SizedBox(
          key: const ValueKey('ios-liquid-panel'),
          height: _panelHeight,
          child: SizedBox(
            key: _panelKey,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.none,
                    children: [
                      // Compose applies dropShadow before the press-scaled
                      // backdrop layer. Keep this footprint fixed so pressing
                      // the glass never drags its shadow away from the resting
                      // capsule or the unscaled tab contents behind it.
                      DecoratedBox(
                        key: const ValueKey('ios-liquid-panel-shadow'),
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: scheme.brightness == Brightness.dark
                                    ? .2
                                    : .1,
                              ),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      AnimatedBuilder(
                        animation: _pressProgress,
                        child: ClipRRect(
                          borderRadius: radius,
                          child: background,
                        ),
                        builder: (context, child) {
                          // HyperOS keeps one stable backdrop sampling plane.
                          // Expanding that plane during selection changes both
                          // its apparent size and the page region sampled by
                          // the blur. The explicit source geometry retains the
                          // authored whole-panel liquid press deformation.
                          final scale =
                              glassEnabled &&
                                  sourceInteraction &&
                                  _panelWidth > 0
                              ? 1 +
                                    16 /
                                        _panelWidth *
                                        _pressProgress.value.clamp(0.0, 1.0)
                              : 1.0;
                          return Transform.scale(
                            key: const ValueKey('ios-liquid-panel-press-scale'),
                            scale: scale,
                            child: child,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                if (glassEnabled)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _highlightMotion,
                        builder: (context, _) => ClipRRect(
                          borderRadius: radius,
                          child: CustomPaint(
                            key: const ValueKey('ios-liquid-press-highlight'),
                            painter: _MiuixIosInteractiveHighlightPainter(
                              progress: _spotProgress.value.clamp(0.0, 1.0),
                              center: Offset(
                                _panelPadding +
                                    (_position.value + .5) * _tabWidth,
                                _panelHeight / 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                PositionedDirectional(
                  start: _panelPadding,
                  top: _panelPadding,
                  width: _tabWidth,
                  height: _indicatorHeight,
                  child: _buildDraggableIndicator(
                    scheme: scheme,
                    glassEnabled: glassEnabled,
                  ),
                ),
                // Destination content is painted above the travelling lens.
                // The lens may blur the page and panel behind it, but must not
                // resample and smear the labels it is currently selecting.
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(_panelPadding),
                    child: AnimatedBuilder(
                      animation: _tabContentMotion,
                      builder: (context, _) => _buildTabRow(
                        color: scheme.onSurface,
                        selectedColor: scheme.primary,
                        selectionPosition: _position.value,
                        interactive: true,
                        useSelectedIcons: true,
                        // Scale only content near the travelling lens. Keeping
                        // every item in its own slot prevents the selected row
                        // from sliding over the stationary labels underneath.
                        itemScale: glassEnabled && sourceInteraction
                            ? 1 + .2 * _pressProgress.value
                            : 1,
                        itemScaleKeyPrefix: 'ios-liquid-selected-item-scale',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Only the cheap transform listens to accumulated drag distance. The lens,
    // tab row, and semantics remain stable across pointer samples.
    return AnimatedBuilder(
      animation: _panelDrag,
      child: panel,
      builder: (context, child) => Transform.translate(
        key: const ValueKey('ios-liquid-panel-rubber-band'),
        offset: Offset(_panelOffset, 0),
        child: child,
      ),
    );
  }

  Widget _buildDraggableIndicator({
    required ColorScheme scheme,
    required bool glassEnabled,
  }) {
    final sourceOptics =
        widget.geometry == MiuixIosLiquidNavigationGeometry.source;
    final indicatorAppearance = AnimatedBuilder(
      animation: _pressProgress,
      builder: (context, _) =>
          _buildIndicator(scheme: scheme, glassEnabled: glassEnabled),
    );
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _indicatorMotion,
        child: indicatorAppearance,
        builder: (context, child) {
          // Source velocity is normalized by the complete index span before
          // anisotropic deformation. Only this transform updates while moving;
          // the costly refraction subtree above is retained as the same child.
          final velocity =
              (_dragging ? _dragVelocity : _position.velocity) /
              _positionSpan /
              10;
          var scaleX = _scaleX.value;
          var scaleY = _scaleY.value;
          if (glassEnabled && sourceOptics) {
            scaleX /= 1 - (velocity * .75).clamp(-.2, .2);
            scaleY *= 1 - (velocity * .25).clamp(-.2, .2);
            if (_pointerDown || _dragging) {
              // Velocity may stretch the travelling thumb, but neither axis is
              // allowed to become as large as the resting selected lens.
              scaleX = math.min(scaleX, .96);
              scaleY = math.min(scaleY, .96);
            }
          } else {
            scaleX = 1;
            scaleY = 1;
          }
          final ltr = Directionality.of(context) == TextDirection.ltr;
          return Transform.translate(
            offset: Offset((ltr ? 1 : -1) * _position.value * _tabWidth, 0),
            child: KeyedSubtree(
              key: const ValueKey('ios-liquid-indicator'),
              child: Transform.scale(
                key: const ValueKey('ios-liquid-indicator-shape'),
                scaleX: scaleX,
                scaleY: scaleY,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicator({
    required ColorScheme scheme,
    required bool glassEnabled,
  }) {
    final progress = _pressProgress.value.clamp(0.0, 1.0);
    final sourceOptics =
        widget.geometry == MiuixIosLiquidNavigationGeometry.source;
    final isDark = scheme.brightness == Brightness.dark;
    final intensity = MiuixTheme.of(context).glassIntensity;
    // Surface intensity controls how much page content is visible through the
    // complete panel, but it must not erase destination identity. HyperOS 4
    // therefore keeps a stable project-calibrated contrast wash: a little
    // stronger over dark glass and quieter over light glass. These are visual
    // calibration values, not published Xiaomi tokens.
    final restingAlpha = sourceOptics
        ? intensity.resolveOpacity(.10)
        : (isDark ? .14 : .08);
    final restingColor = (isDark ? Colors.white : Colors.black).withValues(
      alpha: restingAlpha,
    );
    final pressedColor = Colors.black.withValues(
      alpha: intensity.resolveOpacity(.03),
    );
    Widget contents = Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(
          key: const ValueKey('ios-liquid-indicator-single-fill'),
          color: glassEnabled
              ? sourceOptics
                    ? Color.alphaBlend(
                        pressedColor.withValues(
                          alpha: pressedColor.a * progress,
                        ),
                        restingColor.withValues(
                          alpha: restingColor.a * (1 - progress),
                        ),
                      )
                    // The default HyperOS selector moves between equal slots
                    // without changing its tint density. A press may retain a
                    // local light response, but it must not make the selected
                    // destination look more blurred or differently sized.
                    : restingColor
              : scheme.primary.withValues(alpha: .15),
        ),
        if (glassEnabled && sourceOptics)
          KeyedSubtree(
            key: const ValueKey('ios-liquid-indicator-source-specular'),
            child: _buildSpecular(
              extraDegrees: 90,
              // The explicit Compose-source mode retains its authored pressed
              // edge light. HyperOS 4 uses one travelling selection material;
              // adding this contour there reads as a second nested capsule.
              alpha: progress,
              radius: _indicatorHeight / 2,
            ),
          ),
        if (glassEnabled && sourceOptics)
          IgnorePointer(
            key: const ValueKey('ios-liquid-indicator-source-inner-depth'),
            child: CustomPaint(
              foregroundPainter: _MiuixIosInnerShadowPainter(
                progress: progress,
                radius: _indicatorHeight / 2,
              ),
            ),
          ),
      ],
    );

    // The selected destination remains a real glass lens in both geometries.
    // The complete panel supplies the broad background blur; this lighter,
    // exact-bounds pass restores the local focus blur that distinguishes the
    // selected tab. HyperOS omits the source refraction and depth channels so
    // it does not regain the old cloudy double-capsule appearance.
    if (glassEnabled) {
      contents = _MiuixLiquidLensBackdrop(
        key: const ValueKey('ios-liquid-indicator-lens-filter'),
        radius: _indicatorHeight / 2,
        blurSigma: intensity.resolveBlur(sourceOptics ? 4 : 2.5),
        refractionHeight: sourceOptics ? 10 * progress : 0,
        refractionAmount: sourceOptics ? 14 * progress : 0,
        samplePadding: sourceOptics ? null : 0,
        depthEffect: sourceOptics,
        chromaticAberration: sourceOptics ? .5 : 0,
        child: contents,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(_indicatorHeight / 2),
      child: contents,
    );
  }

  Widget _buildTabRow({
    required Color color,
    required bool interactive,
    required bool useSelectedIcons,
    Color? selectedColor,
    double? selectionPosition,
    double itemScale = 1,
    String? itemScaleKeyPrefix,
  }) {
    return Row(
      children: [
        for (var index = 0; index < widget.items.length; index++)
          Builder(
            builder: (context) {
              final selectionWeight = selectionPosition == null
                  ? 0.0
                  : (1 - (selectionPosition - index).abs()).clamp(0.0, 1.0);
              final itemColor = selectedColor == null
                  ? color
                  : Color.lerp(color, selectedColor, selectionWeight)!;
              return SizedBox(
                width: _tabWidth,
                child: Transform.scale(
                  key: itemScaleKeyPrefix == null
                      ? null
                      : ValueKey('$itemScaleKeyPrefix-$index'),
                  scale: 1 + (itemScale - 1) * selectionWeight,
                  child: _buildTab(
                    index: index,
                    color: itemColor,
                    interactive: interactive,
                    selected: selectionWeight >= .5,
                    useSelectedIcon: useSelectedIcons && selectionWeight >= .5,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  // The current source rotates the primary BloomStroke light around the
  // reference point (.5, .7), while retaining a weaker fixed secondary light.
  // ValueListenableBuilder rebuilds only this narrow overlay at each quantized
  // three-degree gravity step; the navigation layout and tab content stay put.
  Widget _buildSpecular({
    required double extraDegrees,
    required double alpha,
    required double radius,
  }) {
    return ValueListenableBuilder<double>(
      valueListenable: _gravityAngle,
      builder: (context, gravity, _) {
        final angle = gravity + extraDegrees * math.pi / 180;
        return MiuixHighlightOverlay(
          highlight: MiuixHighlight(
            width: 1,
            alpha: alpha,
            blur: 2,
            color: Colors.white.withValues(alpha: .12),
            position: MiuixLightPosition(
              dx: .5 + math.cos(angle),
              dy: .7 + math.sin(angle),
              z: -.05,
            ),
            primaryIntensity: 1,
            secondaryPosition: const MiuixLightPosition(dx: .5, dy: .8, z: -.5),
            secondaryColor: Colors.white,
            secondaryIntensity: .4,
          ),
          radius: radius,
          child: const SizedBox.expand(),
        );
      },
    );
  }

  Widget _buildTab({
    required int index,
    required Color color,
    required bool interactive,
    required bool selected,
    required bool useSelectedIcon,
  }) {
    final item = widget.items[index];
    final itemInteractive = interactive && item.enabled;
    final icon = useSelectedIcon ? (item.selectedIcon ?? item.icon) : item.icon;
    final iconAnchor = IconTheme(
      data: IconThemeData(color: color, size: _iconSize),
      child: SizedBox(width: _iconSize, height: _iconSize, child: icon),
    );
    Widget label([double size = _labelSize]) => Text(
      item.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: color,
        fontSize: size,
        fontWeight: FontWeight.w400,
        height: 1,
        // Navigation labels are plain source text. Reset both fields so a host
        // style cannot leak decoration into normal and selected paint layers.
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
      ),
    );
    final content = switch (widget.displayMode) {
      MiuixFloatingNavigationBarDisplayMode.iconOnly => Center(
        child: _miuixNavigationIconWithBadge(
          icon: iconAnchor,
          badge: item.badge,
        ),
      ),
      MiuixFloatingNavigationBarDisplayMode.textOnly => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: label(13),
        ),
      ),
      MiuixFloatingNavigationBarDisplayMode.iconAndText => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _miuixNavigationIconWithBadge(icon: iconAnchor, badge: item.badge),
          const SizedBox(height: 1),
          label(),
        ],
      ),
      MiuixFloatingNavigationBarDisplayMode.iconWithSelectedLabel =>
        selected
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _miuixNavigationIconWithBadge(
                    icon: iconAnchor,
                    badge: item.badge,
                  ),
                  const SizedBox(height: 1),
                  label(),
                ],
              )
            : Center(
                child: _miuixNavigationIconWithBadge(
                  icon: iconAnchor,
                  badge: item.badge,
                ),
              ),
    };
    // The clipped selected copy is paint-only. Excluding it from semantics
    // avoids duplicate labels, keys, and accessibility automation targets.
    if (!interactive) {
      return ExcludeSemantics(child: IgnorePointer(child: content));
    }
    return Semantics(
      key: ValueKey('ios-liquid-tab-$index'),
      button: true,
      selected: index == _currentIndex,
      enabled: item.enabled,
      label: item.label,
      onTap: itemInteractive ? () => _select(index) : null,
      child: FocusableActionDetector(
        enabled: itemInteractive,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.numpadEnter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _select(index);
              return null;
            },
          ),
        },
        child: content,
      ),
    );
  }
}

/// Backdrop filter that combines ordinary blur with the source lens shader.
///
/// ImageFilter automatically provides the first two `u_size` floats and the
/// input sampler. The six fields configured below therefore begin at slot 2.
/// A compilation failure is contained locally so unsupported renderers retain
/// a useful blurred surface instead of losing navigation entirely.
class _MiuixLiquidLensBackdrop extends StatefulWidget {
  const _MiuixLiquidLensBackdrop({
    super.key,
    required this.radius,
    required this.blurSigma,
    required this.refractionHeight,
    required this.refractionAmount,
    required this.child,
    this.samplePadding,
    this.depthEffect = false,
    this.chromaticAberration = 0,
    this.vibrancy = 1,
  });

  final double radius;
  final double blurSigma;
  final double refractionHeight;
  final double refractionAmount;
  final double? samplePadding;
  final bool depthEffect;
  final double chromaticAberration;
  final double vibrancy;
  final Widget child;

  @override
  State<_MiuixLiquidLensBackdrop> createState() =>
      _MiuixLiquidLensBackdropState();
}

class _MiuixLiquidLensBackdropState extends State<_MiuixLiquidLensBackdrop> {
  ui.FragmentShader? _shader;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    if (_loading || _shader != null) return;
    // Android Impeller still exposes device-dependent backdrop-input origins
    // for ImageFilter.shader. Real arm64 screenshots have shown a horizontal
    // split where one half samples a different texture region. Keep Android on
    // the stable engine BackdropFilter path below.
    if (defaultTargetPlatform == TargetPlatform.android) return;
    _loading = true;
    ui.FragmentProgram? program;
    try {
      // Package users resolve the namespaced asset; package-local tests and
      // examples may expose the root asset directly, so both are supported.
      try {
        program = await ui.FragmentProgram.fromAsset(
          'packages/flutter_miuix/shaders/miuix_liquid_lens.frag',
        );
      } catch (_) {
        program = await ui.FragmentProgram.fromAsset(
          'shaders/miuix_liquid_lens.frag',
        );
      }
      if (!mounted) return;
      setState(() => _shader = program!.fragmentShader());
    } catch (error) {
      // The ordinary blur path below is also the documented renderer fallback.
      debugPrint('flutter_miuix: liquid lens shader unavailable: $error');
    } finally {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _shader?.dispose();
    super.dispose();
  }

  bool get _useRuntimeLens =>
      defaultTargetPlatform != TargetPlatform.android &&
      _shader != null &&
      ui.ImageFilter.isShaderFilterSupported;

  ui.ImageFilter _filter({
    required Size shapeSize,
    required double padding,
    required double devicePixelRatio,
  }) {
    final shader = _shader;
    // Android and unsupported shader-filter backends deliberately retain one
    // ordinary blur plane. Android's runtime shader input transform is not
    // stable across Vulkan/GLES devices and can divide the pill horizontally.
    if (!_useRuntimeLens) {
      return ui.ImageFilter.blur(
        sigmaX: widget.blurSigma,
        sigmaY: widget.blurSigma,
      );
    }
    // ImageFilter's bound texture and fragment coordinates are physical
    // pixels. Compose receives physical values from Density as well, so scale
    // every logical geometry input exactly once at this boundary.
    final scale = devicePixelRatio;
    final radius = widget.radius * scale;
    // Slots 0-1 are reserved for the bound texture's u_size. Shape size and a
    // negative padding offset reproduce Lens.kt's size/offset uniforms while
    // allowing the texture itself to contain the larger sampling perimeter.
    shader!
      ..setFloat(2, shapeSize.width * scale)
      ..setFloat(3, shapeSize.height * scale)
      ..setFloat(4, -padding * scale)
      ..setFloat(5, -padding * scale)
      ..setFloat(6, radius)
      ..setFloat(7, radius)
      ..setFloat(8, radius)
      ..setFloat(9, radius)
      ..setFloat(10, widget.refractionHeight * scale)
      // Lens.kt passes the physical refraction amount with a negative sign.
      ..setFloat(11, -widget.refractionAmount * scale)
      ..setFloat(12, widget.depthEffect ? 1 : 0)
      ..setFloat(13, widget.chromaticAberration)
      ..setFloat(14, widget.vibrancy);
    final lens = ui.ImageFilter.shader(shader);
    if (widget.blurSigma <= 0) return lens;
    // Upstream performs vibrancy, blur, then lens. Compose's ImageFilter order
    // maps to a blur inner filter and lens outer filter in Flutter.
    return ui.ImageFilter.compose(
      outer: lens,
      inner: ui.ImageFilter.blur(
        sigmaX: widget.blurSigma,
        sigmaY: widget.blurSigma,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shapeSize = constraints.biggest;
        final useRuntimeLens = _useRuntimeLens;
        // Lens.kt raises effect padding to at least refractionAmount. Callers
        // whose signed displacement samples inward may explicitly use zero so
        // a bottom-aligned backdrop is not truncated by the window boundary.
        // The stable Android/fallback material never expands its blur plane.
        final requestedPadding =
            widget.samplePadding ?? widget.refractionAmount.abs();
        final padding = useRuntimeLens ? requestedPadding : 0.0;
        final filter = _filter(
          shapeSize: shapeSize,
          padding: padding,
          devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
        );
        if (padding <= 0) {
          // Keep the blur directly attached to the already-painted page and
          // draw the translucent surface as its child. Wrapping BackdropFilter
          // in ColorFiltered creates an offscreen transparent layer on some
          // Android Impeller devices, leaving nothing for the blur to sample.
          // This canonical ordering keeps one visible, exact-bounds blur plane.
          return BackdropFilter(
            key: const ValueKey('ios-liquid-stable-backdrop'),
            filter: filter,
            blendMode: BlendMode.srcOver,
            child: widget.child,
          );
        }
        // Capture an expanded transparent layer, then paint the actual surface
        // over it. The surrounding ClipRRect restricts output to the pill, but
        // the shader can sample real neighboring pixels instead of clamping to
        // a synthetic rectangular edge.
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -padding,
              top: -padding,
              right: -padding,
              bottom: -padding,
              child: BackdropFilter(
                filter: filter,
                child: const SizedBox.expand(),
              ),
            ),
            widget.child,
          ],
        );
      },
    );
  }
}

/// Paints InteractiveHighlight's additive wash and press-centered radial spot.
class _MiuixIosInteractiveHighlightPainter extends CustomPainter {
  const _MiuixIosInteractiveHighlightPainter({
    required this.progress,
    required this.center,
  });

  final double progress;
  final Offset center;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final wash = Paint()
      ..blendMode = BlendMode.plus
      ..color = Colors.white.withValues(alpha: .06 * progress);
    canvas.drawRect(Offset.zero & size, wash);
    final radius = math.max(1.0, size.shortestSide * 1.2);
    final clamped = Offset(
      center.dx.clamp(0.0, size.width),
      center.dy.clamp(0.0, size.height),
    );
    final spot = Paint()
      ..blendMode = BlendMode.plus
      ..shader = ui.Gradient.radial(
        clamped,
        radius,
        [
          Colors.white.withValues(alpha: .12 * progress),
          Colors.white.withValues(alpha: .12 * progress),
          Colors.transparent,
        ],
        const [0, .5, 1],
      );
    canvas.drawRect(Offset.zero & size, spot);
  }

  @override
  bool shouldRepaint(covariant _MiuixIosInteractiveHighlightPainter old) =>
      old.progress != progress || old.center != center;
}

/// Approximates the source pressed selector's 8dp black inner shadow.
class _MiuixIosInnerShadowPainter extends CustomPainter {
  const _MiuixIosInnerShadowPainter({
    required this.progress,
    required this.radius,
  });

  final double progress;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final blur = 8 * progress;
    final shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, blur * 2)
      ..color = Colors.black.withValues(alpha: .15 * progress)
      ..maskFilter = MaskFilter.blur(BlurStyle.inner, blur);
    // Draw on the actual outer boundary and clip the blurred half outside.
    // Deflating the stroke first produced a second, visibly separate oval.
    canvas
      ..save()
      ..clipRRect(shape)
      ..drawRRect(shape, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(covariant _MiuixIosInnerShadowPainter old) =>
      old.progress != progress || old.radius != radius;
}
