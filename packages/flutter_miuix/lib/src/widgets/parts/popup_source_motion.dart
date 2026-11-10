part of '../miuix_widgets.dart';

/// Source popup content transition and reveal clip.
class MiuixListPopupContent extends StatelessWidget {
  /// Creates list-popup content driven by independent fraction and alpha values.
  const MiuixListPopupContent({
    super.key,
    required this.fractionProgress,
    required this.alphaProgress,
    required this.popupLayoutPosition,
    required this.localTransformOrigin,
    required this.child,
    this.popupContentSize = Size.zero,
    this.onPopupContentSizeChange,
    this.paintSurface = true,
  });

  /// Last known popup size.
  final Size popupContentSize;

  /// Called after the rendered size changes.
  final ValueChanged<Size>? onPopupContentSizeChange;

  /// Current spring fraction.
  final ValueGetter<double> fractionProgress;

  /// Current opacity fraction.
  final ValueGetter<double> alphaProgress;

  /// Actual above/below/middle placement.
  final MiuixPopupLayoutPosition popupLayoutPosition;

  /// Popup-local transform origin.
  final MiuixTransformOrigin localTransformOrigin;

  /// Popup body.
  final Widget child;

  /// Whether this widget paints the source surface behind [child].
  ///
  /// Internal popup routes pass false because [MiuixListPopup] already owns
  /// that surface; public standalone use keeps the source default.
  final bool paintSurface;

  @override
  Widget build(BuildContext context) {
    final rawFraction = fractionProgress();
    final fraction = rawFraction.isNaN
        ? 0.0
        : rawFraction == double.infinity
        ? 1.0
        : rawFraction == double.negativeInfinity
        ? 0.0
        : rawFraction;
    final rawAlpha = alphaProgress();
    final alpha = rawAlpha.isNaN ? 0.0 : rawAlpha.clamp(0.0, 1.0);
    final scale = .15 + .85 * fraction;
    final transformOrigin = safeMiuixTransformOrigin(
      localTransformOrigin.pivotFractionX,
      localTransformOrigin.pivotFractionY,
    );
    final decorated = paintSurface
        ? MiuixSurface(
            key: const ValueKey('miuix-list-popup-content-glass'),
            color: MiuixSemanticColors.of(context)['surfaceContainer'],
            radius: MiuixListPopupDefaults.cornerRadius,
            glass: true,
            glassBlur: MiuixTheme.of(context).hyperOs4.popupBlur,
            glassOpacity: MiuixTheme.of(context).hyperOs4.popupTintOpacity,
            glassOptics: MiuixGlassOptics.transient,
            showGlassSpecular: true,
            child: child,
          )
        : child;
    // Once settled, preserve the child's own 16dp surface clip. Applying a
    // second identical antialiased path changes only the fringe pixels.
    final revealed = fraction >= 1
        ? decorated
        : _MiuixPopupReveal(
            progress: fraction,
            position: popupLayoutPosition,
            child: decorated,
          );
    final transformed = Opacity(
      key: const ValueKey('miuix-list-popup-content-opacity'),
      opacity: alpha,
      child: Transform.scale(
        key: const ValueKey('miuix-list-popup-content-transform'),
        scale: scale,
        alignment: transformOrigin.alignment,
        // Compose graphicsLayer changes drawing only; pointerInput continues
        // to use the popup's settled layout coordinates.
        transformHitTests: false,
        child: revealed,
      ),
    );
    return _MiuixPopupSizeReporter(
      lastReportedSize: popupContentSize,
      onSizeChanged: onPopupContentSizeChange,
      child: transformed,
    );
  }
}

class _MiuixListPopupRevealClipper extends CustomClipper<Path> {
  const _MiuixListPopupRevealClipper({
    required this.progress,
    required this.position,
  });

  final double progress;
  final MiuixPopupLayoutPosition position;

  @override
  Path getClip(Size size) {
    final p = progress.clamp(0.0, 1.0);
    if (p <= 0 || size.isEmpty) {
      return Path();
    }
    late final double top;
    late final double bottom;
    if (position.showAbove) {
      top = size.height * (1 - p);
      bottom = size.height;
    } else if (position.showBelow) {
      top = 0;
      bottom = size.height * p;
    } else {
      top = size.height * (.5 - .5 * p);
      bottom = size.height * (.5 + .5 * p);
    }
    final rect = Rect.fromLTRB(0, top, size.width, bottom);
    return Path()..addRRect(
      RRect.fromRectAndRadius(
        rect,
        const Radius.circular(MiuixListPopupDefaults.cornerRadius),
      ),
    );
  }

  @override
  bool shouldReclip(covariant _MiuixListPopupRevealClipper oldClipper) =>
      progress != oldClipper.progress || position != oldClipper.position;
}

/// Paint-only reveal clip matching Compose `drawWithContent`.
///
/// Flutter's ClipPath also clips hit testing, which would make an in-flight
/// menu row temporarily untappable. The upstream draw modifier affects only
/// pixels, so this render proxy clips its paint and leaves hit testing intact.
class _MiuixPopupReveal extends SingleChildRenderObjectWidget {
  const _MiuixPopupReveal({
    required this.progress,
    required this.position,
    required super.child,
  });

  final double progress;
  final MiuixPopupLayoutPosition position;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMiuixPopupReveal(progress: progress, position: position);

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMiuixPopupReveal renderObject,
  ) {
    renderObject
      ..progress = progress
      ..position = position;
  }
}

class _RenderMiuixPopupReveal extends RenderProxyBox {
  _RenderMiuixPopupReveal({
    required double progress,
    required MiuixPopupLayoutPosition position,
  }) : _progress = progress,
       _position = position;

  double _progress;
  MiuixPopupLayoutPosition _position;

  set progress(double value) {
    if (value == _progress) return;
    _progress = value;
    markNeedsPaint();
  }

  set position(MiuixPopupLayoutPosition value) {
    if (value == _position) return;
    _position = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final clip = _MiuixListPopupRevealClipper(
      progress: _progress,
      position: _position,
    ).getClip(size);
    context.canvas.save();
    context.canvas.translate(offset.dx, offset.dy);
    context.canvas.clipPath(clip);
    context.canvas.translate(-offset.dx, -offset.dy);
    super.paint(context, offset);
    context.canvas.restore();
  }
}

class _MiuixPopupSizeReporter extends SingleChildRenderObjectWidget {
  const _MiuixPopupSizeReporter({
    required this.lastReportedSize,
    required this.onSizeChanged,
    required super.child,
  });

  final Size lastReportedSize;
  final ValueChanged<Size>? onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMiuixPopupSizeReporter(
        lastReportedSize: lastReportedSize,
        onSizeChanged: onSizeChanged,
      );

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMiuixPopupSizeReporter renderObject,
  ) {
    renderObject
      ..lastReportedSize = lastReportedSize
      ..onSizeChanged = onSizeChanged;
  }
}

class _RenderMiuixPopupSizeReporter extends RenderProxyBox {
  _RenderMiuixPopupSizeReporter({
    required Size lastReportedSize,
    required ValueChanged<Size>? onSizeChanged,
  }) : _lastReportedSize = lastReportedSize,
       _onSizeChanged = onSizeChanged;

  Size _lastReportedSize;
  ValueChanged<Size>? _onSizeChanged;

  set lastReportedSize(Size value) => _lastReportedSize = value;
  set onSizeChanged(ValueChanged<Size>? value) => _onSizeChanged = value;

  @override
  void performLayout() {
    super.performLayout();
    if (_onSizeChanged != null && size != _lastReportedSize) {
      final reported = size;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (attached) _onSizeChanged?.call(reported);
      });
    }
  }
}

/// Closed-form response for ListPopupDefaults' underdamped fraction spring.
class _MiuixListPopupFractionCurve extends Curve {
  const _MiuixListPopupFractionCurve();

  double _response(double seconds) {
    const dampingRatio = MiuixListPopupDefaults.fractionDampingRatio;
    const stiffness = MiuixListPopupDefaults.fractionStiffness;
    final naturalFrequency = math.sqrt(stiffness);
    final dampedFactor = math.sqrt(1 - dampingRatio * dampingRatio);
    final dampedFrequency = naturalFrequency * dampedFactor;
    final envelope = math.exp(-dampingRatio * naturalFrequency * seconds);
    final oscillation =
        math.cos(dampedFrequency * seconds) +
        dampingRatio / dampedFactor * math.sin(dampedFrequency * seconds);
    return 1 - envelope * oscillation;
  }

  @override
  double transformInternal(double t) {
    final seconds =
        t *
        MiuixListPopupDefaults.fractionDuration.inMicroseconds /
        Duration.microsecondsPerSecond;
    return _response(seconds);
  }
}

/// Reset uses the same spring but travels from one back to zero.
class _MiuixListPopupResetCurve extends Curve {
  const _MiuixListPopupResetCurve();

  @override
  double transformInternal(double t) =>
      1 - const _MiuixListPopupFractionCurve().transform(1 - t);
}

/// Gesture-owned progress used by both Window and Overlay list-popup hosts.
///
/// The listenable value is the inverse because the source multiplies the
/// settled dim layer by `1 - backProgress`. The raw progress remains available
/// to the content surface, which applies the same inverse to fraction and alpha.
class _MiuixListPopupBackProgress extends ChangeNotifier
    implements _MiuixPredictiveBackProgress {
  double _progress = 0;

  @override
  double get progress => _progress;

  @override
  double get value => 1 - _progress;

  @override
  void update(double progress) {
    final next = progress.clamp(0.0, 1.0);
    if ((next - _progress).abs() <= 1e-9) return;
    _progress = next;
    notifyListeners();
  }
}

/// Claims one predictive-Back gesture and freezes its cascading depth.
///
/// At depth zero the gesture drives the popup entrance tree backwards. At
/// depth one it drives only the cascading expansion tree backwards. Freezing
/// that choice at gesture start mirrors NavigationBackHandler: a submenu that
/// finishes opening or closing mid-gesture cannot transfer ownership.
class _MiuixListPopupPredictiveBackObserver extends StatefulWidget {
  const _MiuixListPopupPredictiveBackObserver({
    required this.controller,
    required this.canStart,
    required this.onCommit,
    required this.child,
    this.cascadingController,
  });

  final _MiuixListPopupBackProgress controller;
  final MiuixCascadingPopupController? cascadingController;
  final bool Function() canStart;
  final VoidCallback onCommit;
  final Widget child;

  @override
  State<_MiuixListPopupPredictiveBackObserver> createState() =>
      _MiuixListPopupPredictiveBackObserverState();
}

class _MiuixListPopupPredictiveBackObserverState
    extends State<_MiuixListPopupPredictiveBackObserver>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late final AnimationController _resetAnimation;
  _MiuixPredictiveBackProgress? _activeController;
  double _resetStart = 0;
  bool _activeCascadingDepth = false;

  @override
  void initState() {
    super.initState();
    _resetAnimation = AnimationController(vsync: this)..addListener(_tickReset);
    _MiuixPredictiveBackOwnerRegistry.instance.register(
      this,
      (event) => widget.canStart(),
      context: () => context,
    );
    WidgetsBinding.instance.addObserver(this);
  }

  void _tickReset() {
    final curve = _activeCascadingDepth
        ? const _MiuixCascadingBackResetCurve()
        : const _MiuixListPopupFractionCurve();
    final eased = curve.transform(_resetAnimation.value).clamp(0.0, 1.0);
    _activeController?.update(_resetStart * (1 - eased));
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    if (backEvent.isButtonEvent ||
        !_MiuixPredictiveBackOwnerRegistry.instance.isTop(this, backEvent) ||
        !widget.canStart()) {
      return false;
    }
    _resetAnimation.stop();
    final cascading = widget.cascadingController;
    _activeCascadingDepth = cascading?._secondaryExpanded == true;
    _activeController = _activeCascadingDepth
        ? cascading!._backExpandProgress
        : widget.controller;
    _activeController!.update(backEvent.progress);
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    _activeController?.update(backEvent.progress);
  }

  @override
  void handleCancelBackGesture() {
    final active = _activeController;
    if (active == null) return;
    _resetStart = active.progress;
    if (_resetStart <= 1e-9) {
      active.update(0);
      _activeController = null;
      return;
    }
    _resetAnimation.duration = _activeCascadingDepth
        ? const Duration(milliseconds: 450)
        : MiuixListPopupDefaults.fractionDuration;
    // Keep the settled controller reference until the next start atomically
    // replaces it. TickerFuture completion callbacks can otherwise run after a
    // new platform start message and clear that newer gesture's ownership.
    _resetAnimation.forward(from: 0);
  }

  @override
  void handleCommitBackGesture() {
    // 拖动期间出现保护层时只取消，不关闭其后的浮层。
    if (MiuixBackGestureScope.blockedOf(context)) {
      handleCancelBackGesture();
      return;
    }
    if (_activeController == null) return;
    _resetAnimation.stop();
    if (_activeCascadingDepth) {
      widget.cascadingController?.collapseSecondary();
    } else {
      widget.onCommit();
    }
    _activeController = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _MiuixPredictiveBackOwnerRegistry.instance.unregister(this);
    _resetAnimation
      ..removeListener(_tickReset)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _MiuixBackGuard(child: widget.child);
}

/// Closed-form Folme response used to cancel a depth-one Back preview.
class _MiuixCascadingBackResetCurve extends Curve {
  const _MiuixCascadingBackResetCurve();

  @override
  double transformInternal(double t) {
    const response = .45;
    const dampingRatio = .99;
    const naturalFrequency = 2 * math.pi / response;
    final dampedFactor = math.sqrt(1 - dampingRatio * dampingRatio);
    final dampedFrequency = naturalFrequency * dampedFactor;
    final seconds = t * response;
    final envelope = math.exp(-dampingRatio * naturalFrequency * seconds);
    final oscillation =
        math.cos(dampedFrequency * seconds) +
        dampingRatio / dampedFactor * math.sin(dampedFrequency * seconds);
    return 1 - envelope * oscillation;
  }
}

/// MIUIX `SinOutEasing`.
class _MiuixSinOutCurve extends Curve {
  const _MiuixSinOutCurve();

  @override
  double transformInternal(double t) => math.sin(math.pi * .5 * t);
}

/// Predicts the first-frame origin before the popup has reported its size.
///
/// MIUIX performs the same prediction so a newly mounted popup never flashes
/// from the center while waiting for the first layout result.
MiuixPopupLayoutPosition _miuixPredictedPopupLayoutPosition(
  MiuixPopupAlignment alignment,
  TextDirection textDirection,
) {
  final requestedEnd = switch (alignment) {
    MiuixPopupAlignment.end ||
    MiuixPopupAlignment.topEnd ||
    MiuixPopupAlignment.bottomEnd => true,
    _ => false,
  };
  final rightAligned = textDirection == TextDirection.rtl
      ? !requestedEnd
      : requestedEnd;
  return MiuixPopupLayoutPosition(
    showBelow:
        alignment == MiuixPopupAlignment.topStart ||
        alignment == MiuixPopupAlignment.topEnd ||
        alignment == MiuixPopupAlignment.bottomStart ||
        alignment == MiuixPopupAlignment.bottomEnd,
    showAbove: false,
    isRightAligned: rightAligned,
  );
}

/// Converts actual placement into ListPopupContent's local transform origin.
MiuixTransformOrigin _miuixLocalPopupTransformOrigin(
  MiuixPopupLayoutPosition position,
) {
  final middle = !position.showBelow && !position.showAbove;
  return MiuixTransformOrigin(
    position.isRightAligned ? 1 : 0,
    middle
        ? .5
        : position.showAbove
        ? 1
        : 0,
  );
}

/// Samples the independent ListPopup fraction, alpha, and dim specifications
/// from the route or hosted-popup timeline.
///
/// The fraction consumes the complete 620ms spring window. Alpha and dim stop
/// at their own 200/300ms entrance clocks and leave on their 150ms clocks.
({double fraction, double alpha, double dim}) _miuixListPopupProgress(
  Animation<double> animation,
) {
  if (animation.status == AnimationStatus.completed) {
    return (fraction: 1, alpha: 1, dim: 1);
  }
  if (animation.status == AnimationStatus.dismissed) {
    return (fraction: 0, alpha: 0, dim: 0);
  }
  final reversing = animation.status == AnimationStatus.reverse;
  final totalMicros = MiuixListPopupDefaults.fractionDuration.inMicroseconds
      .toDouble();
  final t = animation.value.clamp(0.0, 1.0);
  if (!reversing) {
    final elapsedMicros = t * totalMicros;
    final alpha =
        (elapsedMicros /
                MiuixListPopupDefaults.alphaEnterDuration.inMicroseconds)
            .clamp(0.0, 1.0);
    final dimTime =
        (elapsedMicros / MiuixListPopupDefaults.dimEnterDuration.inMicroseconds)
            .clamp(0.0, 1.0);
    return (
      fraction: const _MiuixListPopupFractionCurve().transform(t),
      alpha: alpha,
      dim: const _MiuixSinOutCurve().transform(dimTime),
    );
  }

  final elapsedMicros = (1 - t) * totalMicros;
  final alpha =
      (1 -
              elapsedMicros /
                  MiuixListPopupDefaults.alphaExitDuration.inMicroseconds)
          .clamp(0.0, 1.0);
  final dimTime =
      (elapsedMicros / MiuixListPopupDefaults.dimExitDuration.inMicroseconds)
          .clamp(0.0, 1.0);
  return (
    fraction: const _MiuixListPopupResetCurve().transform(t),
    alpha: alpha,
    dim: 1 - const _MiuixSinOutCurve().transform(dimTime),
  );
}

/// Wraps a popup body with the source spring, alpha, reveal, and pivot.
class _MiuixAnimatedListPopupSurface extends StatelessWidget {
  const _MiuixAnimatedListPopupSurface({
    required this.animation,
    required this.position,
    required this.child,
    this.backProgress,
  });

  final Animation<double> animation;
  final MiuixPopupLayoutPosition position;
  final Widget child;
  final _MiuixListPopupBackProgress? backProgress;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        Widget buildSurface() {
          final progress = _miuixListPopupProgress(animation);
          final backFraction = 1 - (backProgress?.progress ?? 0);
          return MiuixListPopupContent(
            fractionProgress: () => progress.fraction * backFraction,
            alphaProgress: () => progress.alpha * backFraction,
            popupLayoutPosition: position,
            localTransformOrigin: _miuixLocalPopupTransformOrigin(position),
            paintSurface: false,
            child: child!,
          );
        }

        final back = backProgress;
        if (back == null) return buildSurface();
        // One stable Listenable per AnimatedBuilder avoids detaching and then
        // reattaching a merged controller while the popup host is unmounting.
        return AnimatedBuilder(
          animation: back,
          builder: (context, _) => buildSurface(),
        );
      },
    );
  }
}

/// Exposes source motion tokens and sample values for regression tests.
@visibleForTesting
({
  double dampingRatio,
  double stiffness,
  double visibilityThreshold,
  Duration fractionDuration,
  Duration alphaEnterDuration,
  Duration alphaExitDuration,
  Duration dimEnterDuration,
  Duration dimExitDuration,
  double fractionAt200ms,
})
debugMiuixListPopupMotion() {
  final t =
      const Duration(milliseconds: 200).inMicroseconds /
      MiuixListPopupDefaults.fractionDuration.inMicroseconds;
  return (
    dampingRatio: MiuixListPopupDefaults.fractionDampingRatio,
    stiffness: MiuixListPopupDefaults.fractionStiffness,
    visibilityThreshold: MiuixListPopupDefaults.fractionVisibilityThreshold,
    fractionDuration: MiuixListPopupDefaults.fractionDuration,
    alphaEnterDuration: MiuixListPopupDefaults.alphaEnterDuration,
    alphaExitDuration: MiuixListPopupDefaults.alphaExitDuration,
    dimEnterDuration: MiuixListPopupDefaults.dimEnterDuration,
    dimExitDuration: MiuixListPopupDefaults.dimExitDuration,
    fractionAt200ms: const _MiuixListPopupFractionCurve().transform(t),
  );
}
