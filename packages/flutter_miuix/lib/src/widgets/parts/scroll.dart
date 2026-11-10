part of '../miuix_widgets.dart';

/// Immutable source color channels for a MIUIX scrollbar.
///
/// Null represents Compose `Color.Unspecified`: an unspecified thumb resolves
/// from the theme, while an unspecified track is not painted.
@immutable
class MiuixScrollBarColors {
  /// Creates a source scrollbar color set.
  const MiuixScrollBarColors({this.thumbColor, this.trackColor});

  /// Explicit thumb color, or null for the themed low/high-alpha behavior.
  final Color? thumbColor;

  /// Explicit track color, or null to hide the track.
  final Color? trackColor;

  /// Returns a value copy, preserving Kotlin data-class behavior.
  MiuixScrollBarColors copyWith({
    Color? thumbColor,
    Color? trackColor,
    bool clearThumbColor = false,
    bool clearTrackColor = false,
  }) {
    return MiuixScrollBarColors(
      thumbColor: clearThumbColor ? null : thumbColor ?? this.thumbColor,
      trackColor: clearTrackColor ? null : trackColor ?? this.trackColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixScrollBarColors &&
          thumbColor == other.thumbColor &&
          trackColor == other.trackColor;

  @override
  int get hashCode => Object.hash(thumbColor, trackColor);
}

/// Public constants copied from MIUIX 1.0.9 `ScrollBarDefaults`.
abstract final class MiuixScrollBarDefaults {
  /// Resting thumb width.
  static const double thumbWidth = 3.64;

  /// Gap from the logical end or physical bottom edge.
  static const double endPadding = 3.46;

  /// Minimum thumb length.
  static const double thumbMinLength = 36;

  /// Null is the source `Dp.Unspecified` half-width corner behavior.
  static const double? cornerRadius = null;

  /// Fully visible hold interval before fading.
  static const Duration fadeDelay = Duration(milliseconds: 1000);

  /// Linear fade duration.
  static const Duration fadeDuration = Duration(milliseconds: 500);

  /// Pointer strip width/height.
  static const double touchTargetWidth = 48;

  /// Highlighted thumb width.
  static const double dragThumbWidth = 6;

  /// Themed resting alpha.
  static const double thumbAlpha = .1;

  /// Themed hover/drag alpha.
  static const double dragThumbAlpha = .3;

  /// Width, alpha, and dynamic-length tween duration.
  static const Duration dragAnimationDuration = Duration(milliseconds: 150);

  /// Creates the source color value object.
  static MiuixScrollBarColors scrollBarColors({
    Color? thumbColor,
    Color? trackColor,
  }) => MiuixScrollBarColors(thumbColor: thumbColor, trackColor: trackColor);
}

/// Flutter counterpart of the source `ScrollBarAdapter` interface.
abstract interface class MiuixScrollBarAdapter implements Listenable {
  /// Current content offset.
  double get scrollOffset;

  /// Estimated or exact complete content extent.
  double get contentSize;

  /// Current viewport extent.
  double get viewportSize;

  /// Moves content to [scrollOffset].
  Future<void> scrollTo(double scrollOffset);
}

/// Adapts a Flutter [ScrollController] without taking ownership of it.
class MiuixScrollControllerAdapter implements MiuixScrollBarAdapter {
  /// Creates an adapter for a list, grid, or ordinary scroll view controller.
  const MiuixScrollControllerAdapter(this.controller);

  /// Controller shared with the associated scrollable.
  final ScrollController controller;

  ScrollPosition? get _position =>
      controller.hasClients ? controller.position : null;

  @override
  double get scrollOffset => _position?.pixels ?? 0;

  @override
  double get viewportSize => _position?.viewportDimension ?? 0;

  @override
  double get contentSize {
    final position = _position;
    if (position == null) return 0;
    return position.viewportDimension +
        math.max(0, position.maxScrollExtent - position.minScrollExtent);
  }

  @override
  Future<void> scrollTo(double scrollOffset) async {
    final position = _position;
    if (position == null) return;
    controller.jumpTo(
      scrollOffset.clamp(position.minScrollExtent, position.maxScrollExtent),
    );
  }

  @override
  void addListener(VoidCallback listener) => controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      controller.removeListener(listener);
}

/// Source-style adapter factory for a shared Flutter scroll controller.
MiuixScrollBarAdapter miuixScrollBarAdapter(ScrollController controller) =>
    MiuixScrollControllerAdapter(controller);

/// Cross-platform MIUIX scrollbar adapter.
///
/// The upstream MIUIX scrollbar is deliberately quieter than Flutter's
/// Material scrollbar. Its resting thumb is only 3.64 logical pixels wide,
/// uses ten-percent foreground opacity, and sits 3.46 logical pixels away
/// from the physical edge. Dragging expands the thumb to six logical pixels
/// and raises its opacity to thirty percent.
///
/// Visibility also follows the source timing rather than Material defaults:
///
/// * a scroll notification reveals the thumb immediately;
/// * the fully visible thumb remains on screen for one second;
/// * it then fades out over five hundred milliseconds;
/// * a direct thumb drag keeps it visible until the drag ends.
///
/// [trackPadding] describes unusable portions of the track. This is useful on
/// pages whose scrollable content passes behind a top app bar or extends above
/// a navigation inset: the content may still occupy that area while the thumb
/// starts and ends inside the source page's safe scrolling region.
///
/// The widget listens to notifications from [child], so [controller] is only
/// required when [interactive] dragging is wanted. Supplying a controller that
/// is also attached to the child lets a pointer drag on the thumb map back to
/// a scroll offset. Upstream checks a 48-pixel end strip inside a component
/// whose default measured cross extent is only 10.56 pixels, so the effective
/// target is the narrow rendered bar. A drag still activates only on the thumb.
///
/// This class supports both axes because several source fixtures use the same
/// algorithm for horizontal containers. Prefer [MiuixVerticalScrollBar] or
/// [MiuixHorizontalScrollBar] when the axis should be obvious at the call site.
///
/// A typical vertical integration keeps one controller for both widgets:
///
/// ```dart
/// final controller = ScrollController();
///
/// MiuixVerticalScrollBar(
///   controller: controller,
///   trackPadding: const EdgeInsets.only(top: 96, bottom: 24),
///   child: ListView(
///     controller: controller,
///     children: const <Widget>[],
///   ),
/// )
/// ```
///
/// The example intentionally does not set [thumbVisibility]. Scrolling reveals
/// the thumb, leaves it fully visible for the MIUIX hold interval, and then
/// fades it. Set [thumbVisibility] to true for an accessibility mode that needs
/// persistent position feedback.
///
/// Layout and interaction obey these guarantees:
///
/// * [child] always receives its original constraints;
/// * painting never adds padding around the scrollable;
/// * an unavailable scroll extent produces no thumb;
/// * a minimum thumb that fills the usable track suppresses all painting;
/// * overscroll values are clamped before painting or dragging;
/// * a vertical bar remains on the physical right edge, including in RTL;
/// * an interactive overlay is absent when no controller is attached;
/// * pointer input outside the actual thumb remains a page gesture;
/// * horizontal and vertical axes share the same visibility timing;
/// * controller movement is clamped to its current position bounds.
///
/// [trackVisibility] is provided for API completeness and diagnostics. The
/// original component normally paints no persistent rail, so application pages
/// should leave it unset unless a product requirement explicitly asks for one.
/// The optional rail uses the current theme's container color and follows the
/// same rounded geometry as the thumb.
///
/// This widget does not create or dispose the supplied [controller]. Ownership
/// remains with the caller, just like Flutter's scrollable widgets. The latest
/// [ScrollMetrics] arrives through bubbling notifications, allowing the bar to
/// paint correctly even when interaction is disabled or the controller is not
/// externally exposed.
///
/// Because the implementation is a stack overlay, clipping is determined by
/// the caller. Wrap the entire scrollbar in a clip only when the source surface
/// itself clips scrolling content; clipping merely the child could leave the
/// thumb outside the intended shape.
class MiuixScrollBar extends StatefulWidget {
  /// Creates a scrollbar wrapper.
  const MiuixScrollBar({
    super.key,
    this.child = const SizedBox.expand(),
    this.controller,
    this.adapter,
    this.thumbVisibility,
    this.trackVisibility,
    this.interactive = true,
    this.trackPadding = EdgeInsets.zero,
    this.colors = const MiuixScrollBarColors(),
    this.reverseLayout = false,
    this.thumbWidth = MiuixScrollBarDefaults.thumbWidth,
    this.cornerRadius = MiuixScrollBarDefaults.cornerRadius,
    this.thumbMinLength = MiuixScrollBarDefaults.thumbMinLength,
    this.endPadding = MiuixScrollBarDefaults.endPadding,
    this.axis = Axis.vertical,
  });

  /// Scrollable child whose notifications drive the painted thumb.
  ///
  /// The child remains the first stack entry and receives normal hit testing.
  final Widget child;

  /// Optional controller used to apply interactive thumb movement.
  ///
  /// It should be the same controller attached to the scrollable child.
  final ScrollController? controller;

  /// Optional source-style adapter for standalone Stack-overlay integration.
  final MiuixScrollBarAdapter? adapter;

  /// Whether the thumb is always visible instead of using timed fading.
  ///
  /// A null value uses the normal source reveal-and-fade behavior.
  final bool? thumbVisibility;

  /// Whether to paint the complete track behind the thumb.
  ///
  /// MIUIX normally leaves this false and paints only its quiet thumb.
  final bool? trackVisibility;

  /// Whether a drag beginning on the thumb can control the scroll position.
  ///
  /// This has no effect without an attached [controller] or [adapter].
  final bool interactive;

  /// Insets removed from the usable scrollbar track.
  ///
  /// This matches MIUIX `trackPadding`, which page fixtures use to keep the
  /// thumb out of their top-app-bar and bottom-system-inset content padding.
  final EdgeInsetsGeometry trackPadding;

  /// Source thumb and optional track colors.
  final MiuixScrollBarColors colors;

  /// Reverses thumb position and drag-to-content direction.
  final bool reverseLayout;

  /// Resting thumb width from `ScrollBarDefaults.ThumbWidth`.
  ///
  /// While dragging, the source component temporarily expands to six pixels.
  final double thumbWidth;

  /// Explicit source corner radius; null follows half the animated width.
  final double? cornerRadius;

  /// Minimum thumb extent from `ScrollBarDefaults.ThumbMinLength`.
  ///
  /// The visible-content fraction can still produce a longer thumb.
  final double thumbMinLength;

  /// Distance between the thumb and the source physical edge.
  ///
  /// The edge is right for a vertical bar and bottom for a horizontal bar.
  final double endPadding;

  /// Expected axis when [adapter] supplies metrics without child notifications.
  final Axis axis;

  @override
  State<MiuixScrollBar> createState() => _MiuixScrollBarState();
}

class _MiuixScrollBarState extends State<MiuixScrollBar>
    with TickerProviderStateMixin {
  // The most recent notification is the painter's source of truth. Reading
  // from the optional controller would exclude non-interactive scrollbars.
  ScrollMetrics? _metrics;

  // MIUIX fades the visual overlay only. The child remains outside this
  // animation, while an explicit track receives the same opacity multiplier.
  late final AnimationController _opacity;

  // Hover and drag share the source 150 ms width/alpha transition.
  late final AnimationController _highlight;

  // Thumb length changes use the same 150 ms source tween.
  late final AnimationController _thumbLength;
  double _thumbLengthStart = 0;
  double _thumbLengthTarget = 0;
  double _displayedThumbLength = 0;
  bool _thumbSyncScheduled = false;
  double _pendingThumbLength = 0;

  // HyperOS accessibility keeps pointer-following scroll movement intact but
  // removes autonomous scrollbar interpolation. The cached inherited value
  // lets an already-running transition settle as soon as the setting changes.
  bool _reduceMotion = false;

  // Opacity is sometimes held at one while its delayed hide timer is pending.
  // Recording the logical destination means a mid-fade accessibility toggle
  // can snap to the intended endpoint instead of guessing from controller
  // status, whose reverse direction alone does not encode a pending delay.
  bool _opacityTargetVisible = false;

  // A cancellable timer implements the source's one-second visible hold.
  Timer? _hideTimer;

  // Drag state controls both expanded thumb geometry and stronger opacity.
  bool _dragging = false;
  bool _hovering = false;

  // Layout-time scroll metrics can arrive during persistent frame callbacks.
  // Coalesce their rebuild into one post-frame update instead of scheduling a
  // new build while Flutter is still laying out an embedded scrollable.
  bool _postFrameRebuildScheduled = false;

  // Public scrollbar geometry can be restored from user settings. Resolve it
  // once per frame so hit testing, drag conversion, and painting use exactly
  // the same finite non-negative values.
  // Scrollbar geometry contract:
  // - Finite positive source dimensions remain unchanged.
  // - Zero remains a valid explicit hidden dimension.
  // - Finite negative dimensions project to zero.
  // - NaN and infinities use the stable source default.
  // - Thumb width drives both painter thickness and the hit strip.
  // - End padding drives both physical placement and hit-strip width.
  // - Minimum length drives both the painter and drag travel calculation.
  // - Null radius continues to derive from half the animated thickness.
  // - Non-finite radius follows that same derived-radius path.
  // - Negative finite radius becomes a square zero-radius edge.
  // - Sanitization occurs before interpolation to keep every frame finite.
  // - Sanitization occurs before division to keep drag conversion stable.
  double _safeGeometry(double value, double fallback) {
    if (!value.isFinite) return fallback;
    return math.max(0.0, value);
  }

  double get _safeThumbWidth =>
      _safeGeometry(widget.thumbWidth, MiuixScrollBarDefaults.thumbWidth);
  double get _safeThumbMinLength => _safeGeometry(
    widget.thumbMinLength,
    MiuixScrollBarDefaults.thumbMinLength,
  );
  double get _safeEndPadding =>
      _safeGeometry(widget.endPadding, MiuixScrollBarDefaults.endPadding);
  double? get _safeCornerRadius {
    final value = widget.cornerRadius;
    if (value == null || !value.isFinite) return null;
    return math.max(0.0, value);
  }

  @override
  void initState() {
    super.initState();
    _opacityTargetVisible = widget.thumbVisibility == true;
    // Both directions use the source 500 ms fade duration. Assigning an
    // initial value avoids a one-frame flash for an always-visible thumb.
    _opacity = AnimationController(
      vsync: this,
      duration: MiuixScrollBarDefaults.fadeDuration,
      reverseDuration: MiuixScrollBarDefaults.fadeDuration,
      value: widget.thumbVisibility == true ? 1 : 0,
    )..addListener(_opacityChanged);
    _highlight = AnimationController(
      vsync: this,
      duration: MiuixScrollBarDefaults.dragAnimationDuration,
    )..addListener(_opacityChanged);
    _thumbLength = AnimationController(
      vsync: this,
      duration: MiuixScrollBarDefaults.dragAnimationDuration,
    )..addListener(_applyThumbLengthFrame);
    widget.adapter?.addListener(_adapterChanged);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _synchronizeAdapter(reveal: false),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (!_reduceMotion) return;

    // Complete every autonomous transition at its logical destination. Direct
    // list and thumb dragging remain notification-driven and are not disabled.
    _opacity
      ..stop()
      ..value = _opacityTargetVisible ? 1 : 0;
    _highlight
      ..stop()
      ..value = _highlighted ? 1 : 0;
    _thumbLength.stop();
    if (_thumbLengthTarget > 0) {
      _displayedThumbLength = _thumbLengthTarget;
      _thumbLengthStart = _thumbLengthTarget;
      _thumbLength.value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant MiuixScrollBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.adapter != widget.adapter) {
      oldWidget.adapter?.removeListener(_adapterChanged);
      widget.adapter?.addListener(_adapterChanged);
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _synchronizeAdapter(reveal: false),
      );
    }
    // Turning persistent visibility on must cancel any pending hide callback.
    if (widget.thumbVisibility == true) {
      _hideTimer?.cancel();
      _opacityTargetVisible = true;
      _opacity.value = 1;
    } else if (oldWidget.thumbVisibility == true && !_highlighted) {
      // Returning to automatic visibility starts with the normal hold period.
      _scheduleHide();
    }
  }

  // The controller is intentionally kept outside AnimatedBuilder. Rebuilding
  // this small stack is cheaper and keeps painter state in one obvious place.
  void _opacityChanged() {
    _rebuildSafely();
  }

  void _rebuildSafely() {
    // User-driven scroll notifications normally arrive before paint and can
    // rebuild immediately, preserving a same-frame thumb response.
    // Initial dimension correction is different: ScrollPosition may emit a
    // start notification while RenderViewport or RenderEditable is laying out.
    // Flutter forbids scheduling another build from that persistent phase.
    // Deferring only that rare path avoids a framework assertion without
    // imposing a frame of latency on ordinary dragging or wheel scrolling.
    // Multiple metrics and opacity events in one layout share one callback.
    // The latest immutable metrics snapshot is therefore the one rendered.
    // Disposal remains safe because the callback checks [mounted] again.
    if (!mounted) return;
    if (SchedulerBinding.instance.schedulerPhase !=
        SchedulerPhase.persistentCallbacks) {
      setState(() {});
      return;
    }
    if (_postFrameRebuildScheduled) return;
    _postFrameRebuildScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _postFrameRebuildScheduled = false;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    // Cancel the timer before disposing the controller so no delayed callback
    // can try to reverse an animation after this State has left the tree.
    _hideTimer?.cancel();
    _opacity
      ..removeListener(_opacityChanged)
      ..dispose();
    _highlight
      ..removeListener(_opacityChanged)
      ..dispose();
    _thumbLength
      ..removeListener(_applyThumbLengthFrame)
      ..dispose();
    widget.adapter?.removeListener(_adapterChanged);
    super.dispose();
  }

  void _adapterChanged() => _synchronizeAdapter();

  void _synchronizeAdapter({bool reveal = true}) {
    if (!mounted) return;
    final adapter = widget.adapter;
    if (adapter == null || adapter.viewportSize <= 0) return;
    final maximum = math.max(0.0, adapter.contentSize - adapter.viewportSize);
    final axisDirection = widget.axis == Axis.vertical
        ? AxisDirection.down
        : AxisDirection.right;
    _metrics = FixedScrollMetrics(
      minScrollExtent: 0,
      maxScrollExtent: maximum,
      pixels: adapter.scrollOffset.clamp(0.0, maximum),
      viewportDimension: adapter.viewportSize,
      axisDirection: axisDirection,
      devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
    );
    _rebuildSafely();
    if (reveal) {
      _show();
      _scheduleHide();
    }
  }

  void _applyThumbLengthFrame() {
    _displayedThumbLength = ui.lerpDouble(
      _thumbLengthStart,
      _thumbLengthTarget,
      _thumbLength.value,
    )!;
    _rebuildSafely();
  }

  void _synchronizeThumbLength(double target) {
    if (_displayedThumbLength == 0) {
      _displayedThumbLength = target;
      _thumbLengthStart = target;
      _thumbLengthTarget = target;
      return;
    }
    if (_reduceMotion) {
      _thumbLength.stop();
      _displayedThumbLength = target;
      _thumbLengthStart = target;
      _thumbLengthTarget = target;
      _thumbLength.value = 1;
      return;
    }
    if ((target - _displayedThumbLength).abs() < 1 ||
        _thumbLength.isAnimating ||
        (target - _thumbLengthTarget).abs() < .01) {
      if (!_thumbLength.isAnimating) {
        _displayedThumbLength = target;
        _thumbLengthTarget = target;
      }
      return;
    }
    _thumbLengthStart = _displayedThumbLength;
    _thumbLengthTarget = target;
    _thumbLength
      ..value = 0
      ..forward();
  }

  void _requestThumbLength(double target) {
    _pendingThumbLength = target;
    if (_thumbSyncScheduled) return;
    _thumbSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _thumbSyncScheduled = false;
      if (mounted) _synchronizeThumbLength(_pendingThumbLength);
    });
  }

  bool get _highlighted => _hovering || _dragging;

  void _synchronizeHighlight() {
    if (_highlighted) {
      _show();
      if (_reduceMotion) {
        _highlight.value = 1;
      } else {
        unawaited(_highlight.animateTo(1, curve: Curves.linear));
      }
      return;
    }
    if (_reduceMotion) {
      _highlight.value = 0;
    } else {
      unawaited(_highlight.animateBack(0, curve: Curves.linear));
    }
    _scheduleHide();
  }

  void _show() {
    // A new scroll or drag restarts the hold period from fully opaque.
    _hideTimer?.cancel();
    _opacityTargetVisible = true;
    _opacity.value = 1;
  }

  void _scheduleHide() {
    // Repeated scroll notifications replace rather than stack hide timers.
    _hideTimer?.cancel();

    // Persistent visibility and active dragging both suppress automatic fade.
    if (widget.thumbVisibility == true || _highlighted) return;

    // The upstream component waits 1000 ms before its 500 ms fade begins.
    _hideTimer = Timer(MiuixScrollBarDefaults.fadeDelay, () {
      if (!mounted || _highlighted) return;
      _opacityTargetVisible = false;
      if (_reduceMotion) {
        _opacity.value = 0;
      } else {
        _opacity.reverse();
      }
    });
  }

  bool _handleNotification(ScrollNotification notification) {
    // Notifications can race with route disposal during overlay transitions.
    if (!mounted) {
      return false;
    }
    // A page list can contain EditableText and other nested scrollables.
    // Their notifications reach this ancestor too, but Compose's adapter is
    // bound only to the supplied LazyListState. Listening to a nested editor
    // would both paint the wrong thumb and can call setState during its layout.
    if (notification.depth != 0) {
      return false;
    }
    // This mirrors Flutter's default scrollbar notification predicate: the
    // direct page scrollable is depth zero, while every nested viewport has a
    // positive depth. The optional controller remains the drag destination.
    // Store metrics before revealing the painter so its first frame is valid.
    _metrics = notification.metrics;
    _rebuildSafely();

    // The source snapshot observes offset changes, not start/end or dimension
    // notifications whose adapter position stays the same.
    if (notification is ScrollUpdateNotification &&
        notification.scrollDelta != null &&
        notification.scrollDelta != 0) {
      _show();
      _scheduleHide();
    }
    return false;
  }

  ({double start, double extent, double travel}) _thumbGeometry(
    ScrollMetrics metrics,
    double trackStart,
    double trackExtent,
  ) {
    // Flutter reports viewport and scroll extents separately. Adding them
    // reconstructs the content extent needed by the source fraction formula.
    final contentExtent =
        metrics.viewportDimension +
        math.max(0, metrics.maxScrollExtent - metrics.minScrollExtent);
    // Degenerate metrics represent fully visible content and avoid division
    // by zero while a scrollable is first being laid out.
    final visibleFraction = contentExtent <= 0
        ? 1.0
        : (metrics.viewportDimension / contentExtent).clamp(.0, 1.0);
    // Source keeps the minimum un-clamped, then hides the bar when it occupies
    // the complete track. Clamping it to the track would paint a false rail.
    final extent = math.max(_safeThumbMinLength, trackExtent * visibleFraction);
    // Travel is the distance available to the thumb, not the content offset.
    final travel = math.max(0.0, trackExtent - extent);
    final scrollExtent = metrics.maxScrollExtent - metrics.minScrollExtent;
    // Normalize pixels into the same zero-to-one range used by the painter.
    final rawFraction = scrollExtent <= 0
        ? 0.0
        : ((metrics.pixels - metrics.minScrollExtent) / scrollExtent).clamp(
            0.0,
            1.0,
          );
    final fraction = widget.reverseLayout ? 1 - rawFraction : rawFraction;
    return (
      start: trackStart + travel * fraction,
      extent: extent,
      travel: travel,
    );
  }

  Widget? _buildDragTarget(
    BuildContext context,
    BoxConstraints constraints,
    EdgeInsets padding,
  ) {
    // A painted-only scrollbar still works without a controller. The pointer
    // layer is omitted entirely unless every interactive prerequisite exists.
    final metrics = _metrics;
    final controller = widget.controller;
    final adapter = widget.adapter;
    if (!widget.interactive ||
        metrics == null ||
        (adapter == null && (controller == null || !controller.hasClients)) ||
        metrics.maxScrollExtent <= metrics.minScrollExtent) {
      return null;
    }
    final crossExtent = math.min(
      MiuixScrollBarDefaults.touchTargetWidth,
      math.max(0.0, _safeThumbWidth + _safeEndPadding * 2),
    );
    if (metrics.axis == Axis.vertical) {
      // Track padding changes both the painted geometry and drag conversion;
      // keeping the formulas identical prevents the pointer from drifting.
      final trackExtent = math.max(
        0.0,
        constraints.maxHeight - padding.top - padding.bottom,
      );
      final geometry = _thumbGeometry(metrics, padding.top, trackExtent);
      if (geometry.extent >= trackExtent) return null;

      // Upstream tests a 48-pixel strip inside its 10.56-pixel-wide default
      // layout. This equivalent narrow target still activates only on the thumb.
      return Positioned(
        key: const ValueKey('miuix-scrollbar-drag-target'),
        top: 0,
        bottom: 0,
        right: 0,
        width: crossExtent,
        child: MouseRegion(
          opaque: true,
          onEnter: _handleHoverEnter,
          onExit: _handleHoverExit,
          child: _miuixVerticalDrag(
            isStartAllowed: (position) =>
                position.dy >= geometry.start &&
                position.dy <= geometry.start + geometry.extent,
            onStart: (details) {
              // The recognizer enters the arena only for a down event inside
              // the painted thumb. The remaining strip is transparent to an
              // ancestor list instead of claiming and then ignoring its drag.
              _dragging = true;
              setState(() {});
              _synchronizeHighlight();
            },
            onUpdate: (details) {
              if (!_dragging || geometry.travel <= 0) return;

              // Convert pointer travel to content travel. Clamping protects
              // bouncing scroll positions and a controller updated mid-gesture.
              final scrollExtent =
                  metrics.maxScrollExtent - metrics.minScrollExtent;
              final direction = widget.reverseLayout ? -1.0 : 1.0;
              final next =
                  metrics.pixels +
                  details.delta.dy * scrollExtent / geometry.travel * direction;
              if (adapter != null) {
                unawaited(adapter.scrollTo(next.clamp(0.0, scrollExtent)));
              } else {
                controller!.jumpTo(
                  next.clamp(
                    controller.position.minScrollExtent,
                    controller.position.maxScrollExtent,
                  ),
                );
              }
            },
            onEnd: (_) => _finishDrag(),
            onCancel: _finishDrag,
            child: const SizedBox.expand(),
          ),
        ),
      );
    }
    final trackExtent = math.max(
      0.0,
      constraints.maxWidth - padding.left - padding.right,
    );
    final geometry = _thumbGeometry(metrics, padding.left, trackExtent);
    if (geometry.extent >= trackExtent) return null;

    // Horizontal behavior mirrors the vertical path so both axes preserve the
    // same source hit target, minimum extent, and drag-to-content ratio.
    return Positioned(
      key: const ValueKey('miuix-scrollbar-drag-target'),
      left: 0,
      right: 0,
      bottom: 0,
      height: crossExtent,
      child: MouseRegion(
        opaque: true,
        onEnter: _handleHoverEnter,
        onExit: _handleHoverExit,
        child: _miuixPriorityHorizontalDrag(
          isStartAllowed: (position) =>
              position.dx >= geometry.start &&
              position.dx <= geometry.start + geometry.extent,
          onStart: (details) {
            // Once admitted, the thumb owns the horizontal stream ahead of an
            // outer pager and remains under direct pointer control.
            _dragging = true;
            setState(() {});
            _synchronizeHighlight();
          },
          onUpdate: (details) {
            // Pointer deltas are scaled by scroll extent divided by thumb travel.
            if (!_dragging || geometry.travel <= 0) return;
            final scrollExtent =
                metrics.maxScrollExtent - metrics.minScrollExtent;
            final direction = widget.reverseLayout ? -1.0 : 1.0;
            final next =
                metrics.pixels +
                details.delta.dx * scrollExtent / geometry.travel * direction;
            if (adapter != null) {
              unawaited(adapter.scrollTo(next.clamp(0.0, scrollExtent)));
            } else {
              controller!.jumpTo(
                next.clamp(
                  controller.position.minScrollExtent,
                  controller.position.maxScrollExtent,
                ),
              );
            }
          },
          onEnd: (_) => _finishDrag(),
          onCancel: _finishDrag,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  void _finishDrag() {
    // A drag that began outside the thumb never entered active state.
    if (!_dragging) return;

    // Source animates the highlighted width/alpha back over 150 ms.
    setState(() => _dragging = false);
    _synchronizeHighlight();
  }

  void _handleHoverEnter(PointerEnterEvent _) {
    if (_hovering) return;
    setState(() => _hovering = true);
    _synchronizeHighlight();
  }

  void _handleHoverExit(PointerExitEvent _) {
    if (!_hovering) return;
    setState(() => _hovering = false);
    _synchronizeHighlight();
  }

  @override
  Widget build(BuildContext context) {
    // Persistent visibility bypasses opacity without mutating the animation.
    final showThumb = widget.thumbVisibility == true || _opacity.value > 0;

    final direction = Directionality.of(context);
    return NotificationListener<ScrollNotification>(
      onNotification: _handleNotification,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final metrics = _metrics;
          // Horizontal source padding is explicitly resolved as LTR. Vertical
          // padding only uses top/bottom, while the bar itself follows end.
          final padding = widget.trackPadding.resolve(
            metrics?.axis == Axis.horizontal ? TextDirection.ltr : direction,
          );
          final opacity = widget.thumbVisibility == true ? 1.0 : _opacity.value;
          final highlightProgress = _highlight.value;
          final thickness = ui.lerpDouble(
            _safeThumbWidth,
            MiuixScrollBarDefaults.dragThumbWidth,
            highlightProgress,
          )!;
          final explicitThumb = widget.colors.thumbColor;
          final thumbColor =
              explicitThumb ?? Theme.of(context).colorScheme.onSurface;
          final sourceAlpha = explicitThumb == null
              ? ui.lerpDouble(
                  MiuixScrollBarDefaults.thumbAlpha,
                  MiuixScrollBarDefaults.dragThumbAlpha,
                  highlightProgress,
                )!
              : explicitThumb.a;
          final explicitTrack = widget.colors.trackColor;
          final showTrack =
              explicitTrack != null || widget.trackVisibility == true;
          final trackColor =
              explicitTrack ??
              Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: .56);

          if (metrics != null) {
            final trackExtent = metrics.axis == Axis.vertical
                ? math.max(
                    0.0,
                    constraints.maxHeight - padding.top - padding.bottom,
                  )
                : math.max(
                    0.0,
                    constraints.maxWidth - padding.left - padding.right,
                  );
            final geometry = _thumbGeometry(metrics, 0, trackExtent);
            _requestThumbLength(geometry.extent);
          }

          return Stack(
            children: [
              // Content remains below paint and pointer overlays in stack order.
              widget.child,
              if (metrics != null && (showThumb || showTrack))
                Positioned.fill(
                  // CustomPaint is visual only; dragging is handled by the
                  // separate source-sized target added below it.
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _MiuixScrollbarPainter(
                        metrics: metrics,
                        showThumb: showThumb,
                        showTrack: showTrack,
                        opacity: opacity,
                        thickness: thickness,
                        thumbAlpha: sourceAlpha,
                        thumbMinLength: _safeThumbMinLength,
                        displayedThumbLength: _displayedThumbLength,
                        endPadding: _safeEndPadding,
                        cornerRadius: _safeCornerRadius,
                        trackPadding: padding,
                        thumbColor: thumbColor,
                        trackColor: trackColor,
                        reverseLayout: widget.reverseLayout,
                      ),
                    ),
                  ),
                ),
              // Pattern matching avoids inserting an empty hit-test layer when
              // this scrollbar is display-only or has no scrollable extent.
              ?_buildDragTarget(context, constraints, padding),
            ],
          );
        },
      ),
    );
  }
}

// Paints source scrollbar geometry without introducing a RenderBox of its own.
//
// Keeping this as a CustomPainter has several useful properties:
//
// * thumb drawing never changes the child's layout constraints;
// * fractional source dimensions remain available at every device pixel ratio;
// * the fade updates only the overlay instead of rebuilding list contents;
// * both axes can reuse exactly the same normalized scroll calculations;
// * hit testing stays in the dedicated accessibility-sized gesture layer.
//
// The painter receives an immutable snapshot for each frame. It does not read a
// controller and therefore cannot become inconsistent with notification-only
// scrollables. The state object owns all timers and animation lifecycle work.
//
// The source component uses physical right/bottom edge placement for its visual
// thumb. Directional padding is already resolved before it reaches this class,
// so painting remains deterministic and contains no BuildContext dependency.
//
// A rounded rectangle is used instead of a stroked line because highlighted
// dragging changes width. Centering a stroke would move half of that difference
// outside the source edge gap; a filled rectangle keeps the outer edge stable.
//
// Opacity multiplication happens at paint time. The resting 0.1 and highlighted
// 0.3 values remain source constants, while the animation supplies a zero-to-one
// multiplier. This prevents a mid-fade drag from suddenly exceeding the source
// highlighted alpha.
//
// The optional track deliberately uses the same current thickness as the thumb.
// It is mainly useful for diagnostics and explicit accessibility presentation;
// default MIUIX pages request only the subtle thumb.
class _MiuixScrollbarPainter extends CustomPainter {
  const _MiuixScrollbarPainter({
    required this.metrics,
    required this.showThumb,
    required this.showTrack,
    required this.opacity,
    required this.thickness,
    required this.thumbAlpha,
    required this.thumbMinLength,
    required this.displayedThumbLength,
    required this.endPadding,
    required this.cornerRadius,
    required this.trackPadding,
    required this.thumbColor,
    required this.trackColor,
    required this.reverseLayout,
  });

  // Snapshot of the scrollable viewport, content range, axis, and offset.
  final ScrollMetrics metrics;

  // The thumb and track have independent visibility in the source API.
  final bool showThumb;
  final bool showTrack;

  // Fade progress is applied after the source resting/dragging alpha.
  final double opacity;

  // Width and alpha are already interpolated through the source 150 ms tween.
  final double thickness;
  final double thumbAlpha;
  final double thumbMinLength;
  final double displayedThumbLength;

  // The physical edge gap is separate from track start/end content padding.
  final double endPadding;
  final double? cornerRadius;
  final EdgeInsets trackPadding;

  // Thumb derives from onSurface; an optional track uses its container tone.
  final Color thumbColor;
  final Color trackColor;
  final bool reverseLayout;

  @override
  void paint(Canvas canvas, Size size) {
    // Non-scrollable content has no meaningful thumb and needs no paint work.
    final scrollExtent = metrics.maxScrollExtent - metrics.minScrollExtent;
    if (scrollExtent <= 0) {
      return;
    }
    // Both branches share normalized content and offset fractions.
    final vertical = metrics.axis == Axis.vertical;
    final viewport = metrics.viewportDimension;
    final content = viewport + scrollExtent;
    final fractionVisible = (viewport / content).clamp(.0, 1.0);
    final scrollFraction =
        ((metrics.pixels - metrics.minScrollExtent) / scrollExtent).clamp(
          0.0,
          1.0,
        );
    final margin = endPadding;
    final radius = cornerRadius ?? thickness / 2;
    final available = vertical
        ? size.height - trackPadding.top - trackPadding.bottom
        : size.width - trackPadding.left - trackPadding.right;
    final targetThumbExtent = math.max(
      thumbMinLength,
      available * fractionVisible,
    );
    // Compose returns before both track and thumb drawing in this case. A
    // minimum thumb that fills a tiny viewport must not look like a solid rail.
    if (targetThumbExtent >= available) return;
    // Explicit source track color keeps its own alpha and follows the same
    // visibility multiplier as the thumb.
    final trackPaint = Paint()
      ..color = trackColor.withValues(alpha: trackColor.a * opacity)
      ..style = PaintingStyle.fill;
    final thumbPaint = Paint()
      ..color = thumbColor.withValues(alpha: thumbAlpha * opacity)
      ..style = PaintingStyle.fill;
    if (vertical) {
      // The source uses `size.width - width - endPadding` directly. It is a
      // physical-right affordance even when surrounding text is RTL.
      final x = size.width - thickness - margin;
      final track = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          x,
          trackPadding.top,
          thickness,
          size.height - trackPadding.top - trackPadding.bottom,
        ),
        Radius.circular(radius),
      );
      if (showTrack) {
        canvas.drawRRect(track, trackPaint);
      }
      if (showThumb) {
        // Track padding reduces both thumb length and the offset travel range.
        final thumbExtent = displayedThumbLength > 0
            ? displayedThumbLength
            : targetThumbExtent;
        final directionFraction = reverseLayout
            ? 1 - scrollFraction
            : scrollFraction;
        final thumbTop =
            trackPadding.top +
            (available - targetThumbExtent) * directionFraction;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, thumbTop, thickness, thumbExtent),
            Radius.circular(radius),
          ),
          thumbPaint,
        );
      }
    } else {
      // The horizontal variant sits above the physical bottom edge.
      final track = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          trackPadding.left,
          size.height - thickness - margin,
          size.width - trackPadding.left - trackPadding.right,
          thickness,
        ),
        Radius.circular(radius),
      );
      if (showTrack) {
        canvas.drawRRect(track, trackPaint);
      }
      if (showThumb) {
        // Left/right track padding mirrors top/bottom behavior above.
        final thumbExtent = displayedThumbLength > 0
            ? displayedThumbLength
            : targetThumbExtent;
        final directionFraction = reverseLayout
            ? 1 - scrollFraction
            : scrollFraction;
        final thumbLeft =
            trackPadding.left +
            (available - targetThumbExtent) * directionFraction;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              thumbLeft,
              size.height - thickness - margin,
              thumbExtent,
              thickness,
            ),
            Radius.circular(radius),
          ),
          thumbPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiuixScrollbarPainter oldDelegate) {
    // Repaint only for observable geometry, visibility, animation, or color
    // changes; unrelated ScrollMetrics fields do not affect this painter.
    return metrics.pixels != oldDelegate.metrics.pixels ||
        metrics.minScrollExtent != oldDelegate.metrics.minScrollExtent ||
        metrics.maxScrollExtent != oldDelegate.metrics.maxScrollExtent ||
        metrics.viewportDimension != oldDelegate.metrics.viewportDimension ||
        metrics.axis != oldDelegate.metrics.axis ||
        showThumb != oldDelegate.showThumb ||
        showTrack != oldDelegate.showTrack ||
        opacity != oldDelegate.opacity ||
        thickness != oldDelegate.thickness ||
        thumbAlpha != oldDelegate.thumbAlpha ||
        thumbMinLength != oldDelegate.thumbMinLength ||
        displayedThumbLength != oldDelegate.displayedThumbLength ||
        endPadding != oldDelegate.endPadding ||
        cornerRadius != oldDelegate.cornerRadius ||
        trackPadding != oldDelegate.trackPadding ||
        thumbColor != oldDelegate.thumbColor ||
        trackColor != oldDelegate.trackColor ||
        reverseLayout != oldDelegate.reverseLayout;
  }
}

/// Horizontal specialization of [MiuixScrollBar].
///
/// This adapter keeps call sites semantically explicit while sharing all source
/// geometry and timing with the base implementation. The wrapped scrollable
/// must report [Axis.horizontal] metrics; the class does not override the
/// child's scroll direction.
///
/// Attach the same [ScrollController] to the child to enable dragging. Without
/// it, the bar remains a notification-driven visual indicator. The interactive
/// target occupies the source's narrow measured bottom bar, but only a gesture
/// beginning on the visible thumb becomes a scrollbar drag.
///
/// [MiuixScrollBar.trackPadding] maps its left and right values to the usable
/// horizontal track. [MiuixScrollBar.endPadding] keeps the thumb above the
/// physical bottom edge, matching the source horizontal implementation.
class MiuixHorizontalScrollBar extends MiuixScrollBar {
  /// Creates a horizontal scrollbar wrapper.
  const MiuixHorizontalScrollBar({
    super.key,
    super.child,
    super.controller,
    super.adapter,
    super.thumbVisibility,
    super.trackVisibility,
    super.interactive,
    super.trackPadding,
    super.colors,
    super.reverseLayout,
    super.thumbWidth,
    super.cornerRadius,
    super.thumbMinLength,
    super.endPadding,
  }) : super(axis: Axis.horizontal);
}

/// Vertical specialization of [MiuixScrollBar].
///
/// This is the normal choice for MIUIX settings, component lists, and long-form
/// pages. The wrapped child must emit [Axis.vertical] scroll notifications.
/// Content can still extend behind translucent chrome because track insets
/// affect only the scrollbar geometry, never the child's layout.
///
/// The pointer target occupies the narrow physical-right bar. A gesture that
/// begins outside the painted thumb is ignored by the drag conversion so page
/// paging and ordinary list input remain available. During a valid drag, the
/// thumb expands and uses the stronger source opacity.
///
/// Top and bottom [MiuixScrollBar.trackPadding] are especially useful with a
/// glass [MiuixTopAppBar] and Android gesture navigation. They keep the thumb
/// below initial title content and above the system gesture area while allowing
/// the list itself to scroll behind those translucent surfaces.
class MiuixVerticalScrollBar extends MiuixScrollBar {
  /// Creates a vertical scrollbar wrapper.
  const MiuixVerticalScrollBar({
    super.key,
    super.child,
    super.controller,
    super.adapter,
    super.thumbVisibility,
    super.trackVisibility,
    super.interactive,
    super.trackPadding,
    super.colors,
    super.reverseLayout,
    super.thumbWidth,
    super.cornerRadius,
    super.thumbMinLength,
    super.endPadding,
  }) : super(axis: Axis.vertical);
}

/// Emits MIUIX's picker-like tick when a vertical fling reaches a boundary.
class MiuixScrollEndHaptic extends StatefulWidget {
  /// Creates a scroll-boundary haptic wrapper.
  const MiuixScrollEndHaptic({
    super.key,
    required this.child,
    this.enabled = true,
    this.hapticType = MiuixHapticType.textHandleMove,
  });

  /// Scrollable subtree whose notifications are observed.
  final Widget child;

  /// Whether feedback is active.
  final bool enabled;

  /// Source feedback role emitted when a fling reaches either boundary.
  ///
  /// This corresponds to the `hapticFeedbackType` argument of
  /// `Modifier.scrollEndHaptic`; MIUIX defaults it to `TextHandleMove`.
  final MiuixHapticType hapticType;

  @override
  State<MiuixScrollEndHaptic> createState() => _MiuixScrollEndHapticState();
}

enum _MiuixScrollBoundary { none, top, bottom }

class _MiuixScrollEndHapticState extends State<MiuixScrollEndHaptic> {
  _MiuixScrollBoundary _lastBoundary = _MiuixScrollBoundary.none;

  bool _handleNotification(ScrollNotification notification) {
    if (!widget.enabled ||
        notification.depth != 0 ||
        notification.metrics.axis != Axis.vertical) {
      return false;
    }
    if (notification case ScrollUpdateNotification(:final scrollDelta)) {
      // Compose resets in onPreScroll as soon as input points away from the
      // boundary by more than one pixel. Waiting for the reported position to
      // enter the content would rearm one notification too late.
      if ((_lastBoundary == _MiuixScrollBoundary.top &&
              (scrollDelta ?? 0) > 1) ||
          (_lastBoundary == _MiuixScrollBoundary.bottom &&
              (scrollDelta ?? 0) < -1)) {
        _lastBoundary = _MiuixScrollBoundary.none;
      }
      return false;
    }
    if (notification is! OverscrollNotification ||
        notification.overscroll.abs() <= 1 ||
        notification.velocity.abs() < 25) {
      // Source post-fling thresholds are strict for the available displacement
      // (> 1px) but inclusive for consumed velocity (abs(value) >= 25px/s).
      // Drag overscroll reports zero velocity and therefore stays silent.
      return false;
    }
    final boundary = notification.overscroll < 0
        ? _MiuixScrollBoundary.top
        : _MiuixScrollBoundary.bottom;
    if (_lastBoundary != boundary) {
      _lastBoundary = boundary;
      unawaited(MiuixHaptics.perform(widget.hapticType));
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleNotification,
      child: widget.child,
    );
  }
}

/// Observable counterpart of source `OverScrollState`.
///
/// The active bit becomes true only after translated content exceeds the
/// source one-pixel threshold. Consumers may observe it, while the effect keeps
/// mutation private just as Kotlin exposes an internal setter.
class MiuixOverScrollState extends ChangeNotifier {
  bool _isOverScrollActive = false;

  /// Whether either overscroll axis is displaced by more than one pixel.
  bool get isOverScrollActive => _isOverScrollActive;

  void _setActive(bool value) {
    if (_isOverScrollActive == value) return;
    _isOverScrollActive = value;
    notifyListeners();
  }
}

/// Scroll behavior adapter for MIUIX scroll and overscroll defaults.
/// MIUIX boundary physics using the source cubic damping derivative.
///
/// `Overscroll.kt` maps raw touch distance with `x - x² + x³ / 3`; its
/// derivative is `(1 - x)²`. Flutter's stock bouncing physics multiplies that
/// derivative by 0.52 and also gives ordinary in-range flings iOS momentum.
/// This class keeps the source resistance while delegating in-range motion to
/// Android-style clamping physics.
class MiuixSpringScrollPhysics extends ScrollPhysics {
  /// Creates MIUIX spring boundary physics.
  const MiuixSpringScrollPhysics({super.parent, this.windowSize});

  /// Source damping range, which is the complete window rather than a popup.
  ///
  /// Directly constructed compatibility instances fall back to the viewport.
  final Size? windowSize;

  @override
  MiuixSpringScrollPhysics applyTo(ScrollPhysics? ancestor) =>
      MiuixSpringScrollPhysics(
        parent: buildParent(ancestor),
        windowSize: windowSize,
      );

  /// Returns the instantaneous derivative of MIUIX's cubic damping curve.
  @visibleForTesting
  double frictionFactor(double overscrollFraction) {
    final remaining = 1 - overscrollFraction.clamp(0.0, 1.0);
    return remaining * remaining;
  }

  /// Converts raw touch distance through `x - x² + x³ / 3`.
  @visibleForTesting
  double dampingDistance(double touchDistance, double range) {
    final x = (touchDistance / range).clamp(0.0, 1.0);
    return (x - x * x + x * x * x / 3) * range;
  }

  /// Applies the exact inverse used by `SpringMath.obtainTouchDistance`.
  @visibleForTesting
  double touchDistance(double pixelOffset, double range) {
    final maximum = dampingDistance(range, range);
    final offset = pixelOffset.abs().clamp(0.0, maximum);
    if (offset == 0) return 0;
    final base = range - 3 * offset;
    final cubeRoot = math.pow(base.abs(), 1 / 3).toDouble();
    final signedRoot = base.sign * cubeRoot;
    return range - math.pow(range, 2 / 3) * signedRoot;
  }

  double _scrollRange(ScrollMetrics position) {
    final sourceWindow = windowSize;
    if (sourceWindow == null) {
      return math.max(1.0, position.viewportDimension);
    }
    return math.max(
      1.0,
      position.axis == Axis.vertical ? sourceWindow.height : sourceWindow.width,
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (!position.outOfRange) return offset;
    final pastStart = math.max(position.minScrollExtent - position.pixels, 0.0);
    final pastEnd = math.max(position.pixels - position.maxScrollExtent, 0.0);
    final outside = math.max(pastStart, pastEnd);
    final easing = (pastStart > 0 && offset < 0) || (pastEnd > 0 && offset > 0);
    final range = _scrollRange(position);
    final rawTouch = touchDistance(outside, range);
    if (easing) {
      final consumedTouch = math.min(rawTouch, offset.abs());
      final nextOutside = dampingDistance(rawTouch - consumedTouch, range);
      final remainder = offset.abs() - consumedTouch;
      return offset.sign * (outside - nextOutside + remainder);
    }
    final nextOutside = dampingDistance(
      math.min(range, rawTouch + offset.abs()),
      range,
    );
    return offset.sign * (nextOutside - outside);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) => 0;

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if (position.outOfRange) {
      final target = position.pixels < position.minScrollExtent
          ? position.minScrollExtent
          : position.maxScrollExtent;
      return _MiuixSpringSimulation(
        start: position.pixels,
        target: target,
        initialVelocity: velocity,
      );
    }
    return const ClampingScrollPhysics().createBallisticSimulation(
      position,
      velocity,
    );
  }

  // 弹簧仅改变用户拖动的边界响应，不能屏蔽框架的光标可见性请求。
  // 键盘缩小 viewport 后，EditableText 通过 showOnScreen 揭示焦点光标。
  // 继承父物理策略，也保留调用者明确禁用隐式滚动的配置。
}

/// Stateful explicit-Euler simulation copied from MIUIX `SpringEngine`.
///
/// Flutter's stock spring solver is analytic and therefore follows a visibly
/// different trajectory even with the same period and critical damping ratio.
class _MiuixSpringSimulation extends Simulation {
  _MiuixSpringSimulation({
    required double start,
    required this.target,
    required double initialVelocity,
  }) : _initialPosition = start,
       _initialVelocity = initialVelocity,
       _position = start,
       _velocity = initialVelocity,
       _period = initialVelocity.abs() > 5000 ? .55 : .4;

  final double target;
  final double _initialPosition;
  final double _initialVelocity;
  final double _period;
  double _position;
  double _velocity;
  double _lastTime = 0;
  bool _finished = false;

  void _advance(double time) {
    if (_finished || time <= _lastTime) return;
    final deltaTime = (time - _lastTime).clamp(.001, .016);
    _lastTime = time;
    final angularFrequency = 2 * math.pi / _period;
    final dampingCoefficient = 2 * angularFrequency;
    final stiffnessOverMass = angularFrequency * angularFrequency;
    _velocity =
        _velocity * (1 - dampingCoefficient * deltaTime) +
        stiffnessOverMass * (target - _position) * deltaTime;
    _position += deltaTime * _velocity;

    final crossedFromBelow = _initialPosition < target && _position > target;
    final sourceSecondBranch =
        _initialPosition <= target || _position >= target;
    final sourceEquilibrium =
        sourceSecondBranch &&
        ((_initialPosition == target &&
                _initialVelocity.sign != _position.sign) ||
            (_position - target).abs() < 1);
    final crossedFromAbove = !sourceSecondBranch;
    if (crossedFromBelow || sourceEquilibrium || crossedFromAbove) {
      _position = target;
      _velocity = 0;
      _finished = true;
    }
  }

  @override
  double x(double time) {
    _advance(time);
    return _position;
  }

  @override
  double dx(double time) {
    _advance(time);
    return _velocity;
  }

  @override
  bool isDone(double time) {
    _advance(time);
    return _finished;
  }
}

class MiuixScrollBehavior extends MaterialScrollBehavior {
  /// Creates a scroll behavior.
  const MiuixScrollBehavior({
    this.showScrollbars = true,
    this.showOverscrollIndicator = true,
  });

  /// Whether platform scrollbars should be built.
  final bool showScrollbars;

  /// Whether MIUIX overscroll affordances should be enabled.
  final bool showOverscrollIndicator;

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (!showScrollbars) {
      return child;
    }
    return MiuixScrollBar(controller: details.controller, child: child);
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    if (!showOverscrollIndicator) {
      return const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    }
    return MiuixSpringScrollPhysics(
      windowSize: MediaQuery.sizeOf(context),
      parent: const AlwaysScrollableScrollPhysics(),
    );
  }
}

/// Factory object for creating MIUIX scroll behaviors.
class MiuixOverscrollFactory {
  /// Creates an overscroll factory.
  const MiuixOverscrollFactory();

  /// Canonical factory value corresponding to the Kotlin singleton object.
  static const MiuixOverscrollFactory instance = MiuixOverscrollFactory();

  /// Creates a locally configured source overscroll effect wrapper.
  MiuixOverscrollEffect createOverscrollEffect({
    required Widget child,
    MiuixOverScrollState? state,
    bool showScrollbars = true,
    bool showOverscrollIndicator = true,
  }) {
    return MiuixOverscrollEffect(
      state: state,
      showScrollbars: showScrollbars,
      showOverscrollIndicator: showOverscrollIndicator,
      child: child,
    );
  }

  /// Builds a scroll behavior configured for a subtree.
  MiuixScrollBehavior behavior({
    bool showScrollbars = true,
    bool showOverscrollIndicator = true,
  }) {
    return MiuixScrollBehavior(
      showScrollbars: showScrollbars,
      showOverscrollIndicator: showOverscrollIndicator,
    );
  }

  @override
  bool operator ==(Object other) => identical(this, other);

  @override
  int get hashCode => 1;
}

/// Overscroll wrapper for local scroll behavior overrides.
class MiuixOverscrollEffect extends StatefulWidget {
  /// Creates an overscroll behavior wrapper.
  const MiuixOverscrollEffect({
    super.key,
    required this.child,
    this.state,
    this.showScrollbars = true,
    this.showOverscrollIndicator = true,
  });

  /// Wrapped subtree.
  final Widget child;

  /// Optional externally observed source overscroll activity state.
  final MiuixOverScrollState? state;

  /// Whether platform scrollbars should be built.
  final bool showScrollbars;

  /// Whether overscroll indicators should be built.
  final bool showOverscrollIndicator;

  @override
  State<MiuixOverscrollEffect> createState() => _MiuixOverscrollEffectState();
}

class _MiuixOverscrollEffectState extends State<MiuixOverscrollEffect> {
  MiuixOverScrollState? _ownedState;

  MiuixOverScrollState get _state =>
      widget.state ?? (_ownedState ??= MiuixOverScrollState());

  @override
  void didUpdateWidget(covariant MiuixOverscrollEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state == null && widget.state != null) {
      _ownedState?.dispose();
      _ownedState = null;
    }
  }

  bool _handleScroll(ScrollNotification notification) {
    if (notification.depth != 0) return false;
    final metrics = notification.metrics;
    final displacement = metrics.pixels < metrics.minScrollExtent
        ? metrics.minScrollExtent - metrics.pixels
        : math.max(0.0, metrics.pixels - metrics.maxScrollExtent);
    _state._setActive(displacement > 1);
    return false;
  }

  @override
  void dispose() {
    _ownedState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: MiuixScrollBehavior(
        showScrollbars: widget.showScrollbars,
        showOverscrollIndicator: widget.showOverscrollIndicator,
      ),
      child: NotificationListener<ScrollNotification>(
        onNotification: _handleScroll,
        child: widget.child,
      ),
    );
  }
}
