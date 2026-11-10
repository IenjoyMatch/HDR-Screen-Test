part of '../miuix_widgets.dart';

/// Resolves one slider spring through the inherited motion policy.
void _driveMiuixSliderSpring(
  AnimationController controller,
  double target,
  SpringDescription spring, {
  required bool reduceMotion,
  double visibilityThreshold = .001,
}) {
  if (reduceMotion) {
    controller
      ..stop(canceled: true)
      ..value = target;
    return;
  }
  _animateMiuixSpring(
    controller,
    target,
    spring,
    visibilityThreshold: visibilityThreshold,
  );
}

/// Resolves the drag overlay without changing its semantic drag ownership.
void _driveMiuixSliderOverlay(
  AnimationController controller,
  bool active, {
  required bool reduceMotion,
}) {
  if (reduceMotion) {
    controller
      ..stop(canceled: true)
      ..value = active ? debugMiuixSliderTrackOverlayMotion().alpha : 0;
    return;
  }
  _animateMiuixSliderOverlay(controller, active);
}

/// Stateful horizontal Slider core.
///
/// Public slider values remain controlled by the caller, while this layer owns
/// the transient drag, hover and animation state that Compose keeps through
/// `remember`. Keeping it separate also prevents the already broad selection
/// API file from accumulating the source motion state machines.
class _MiuixHorizontalSliderBody extends StatefulWidget {
  const _MiuixHorizontalSliderBody({
    required this.value,
    required this.range,
    required this.width,
    required this.sliderExtent,
    required this.touchTargetExtent,
    required this.enabled,
    required this.onChanged,
    required this.onChangeFinished,
    required this.divisions,
    required this.keyPoints,
    required this.keyPointFractions,
    required this.magnetThreshold,
    required this.hapticEffect,
    required this.reverseDirection,
    required this.trackScale,
    required this.thumbScale,
    required this.colors,
    required this.onIncrease,
    required this.onDecrease,
  });

  final double value;
  final ({double min, double max}) range;
  final double width;
  final double sliderExtent;
  final double touchTargetExtent;
  final bool enabled;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onChangeFinished;
  final int? divisions;
  final List<double> keyPoints;
  final List<double> keyPointFractions;
  final double magnetThreshold;
  final MiuixSliderHapticEffect hapticEffect;
  final bool reverseDirection;
  final double trackScale;
  final double thumbScale;
  final MiuixSliderColors colors;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  State<_MiuixHorizontalSliderBody> createState() =>
      _MiuixHorizontalSliderBodyState();
}

class _MiuixHorizontalSliderBodyState extends State<_MiuixHorizontalSliderBody>
    with TickerProviderStateMixin {
  late final AnimationController _progress;
  late final AnimationController _thumb;
  late final AnimationController _overlay;
  bool _isDragging = false;
  bool _isHoveringThumb = false;
  bool _overlayActive = false;
  bool _reduceMotion = false;
  late double _lastHapticValue;

  bool get _canChange => widget.enabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController.unbounded(
      vsync: this,
      value: _fractionForValue(widget.value, widget.range),
    );
    _thumb = AnimationController.unbounded(vsync: this, value: 1);
    _overlay = AnimationController.unbounded(vsync: this, value: 0);
    _lastHapticValue = widget.value;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = MediaQuery.disableAnimationsOf(context);
    if (next == _reduceMotion) return;
    _reduceMotion = next;
    if (_reduceMotion) {
      _driveProgress();
      _updateMotionTargets(forceOverlay: true);
    }
  }

  void _driveProgress() {
    _driveMiuixSliderSpring(
      _progress,
      _fractionForValue(widget.value, widget.range),
      debugMiuixSliderProgressSpring(dragging: _isDragging),
      reduceMotion: _reduceMotion,
      visibilityThreshold: _miuixSliderProgressVisibilityThreshold(
        widget.range,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _MiuixHorizontalSliderBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _fractionForValue(widget.value, widget.range);
    if ((target - _fractionForValue(oldWidget.value, oldWidget.range)).abs() >
        .000001) {
      _driveProgress();
    }
    if (!widget.enabled && oldWidget.enabled) {
      _finishInteraction(notify: false);
    }
  }

  double _valueAt(Offset local) {
    final available = (widget.width - widget.sliderExtent).clamp(
      0.0,
      double.infinity,
    );
    final visualFraction = available == 0
        ? 0.0
        : ((local.dx - widget.sliderExtent / 2) / available).clamp(0.0, 1.0);
    final valueFraction = widget.reverseDirection
        ? 1 - visualFraction
        : visualFraction;
    return _valueForFraction(
      valueFraction,
      widget.range,
      widget.divisions,
      keyPoints: widget.keyPoints,
      magnetThreshold: widget.magnetThreshold,
    );
  }

  void _startDrag(DragStartDetails details) {
    if (!_canChange) return;
    _isDragging = true;
    _lastHapticValue = _valueAt(details.localPosition);
    _updateMotionTargets();
    // Slider.kt resolves the pointer in onDragStarted, after the drag slop has
    // been crossed. A stationary press never reaches this callback.
    widget.onChanged?.call(
      _normalizeSliderCallbackValue(_lastHapticValue, widget.range),
    );
  }

  void _updateDrag(DragUpdateDetails details) {
    if (!_canChange) return;
    final next = _valueAt(details.localPosition);
    _dispatchSliderHaptic(
      previous: _lastHapticValue,
      next: next,
      range: widget.range,
      effect: widget.hapticEffect,
      divisions: widget.divisions,
      keyPoints: widget.keyPoints,
    );
    _lastHapticValue = next;
    widget.onChanged?.call(_normalizeSliderCallbackValue(next, widget.range));
  }

  void _finishInteraction({bool notify = true}) {
    final hadDrag = _isDragging;
    _isDragging = false;
    _updateMotionTargets();
    if (notify && hadDrag) {
      widget.onChangeFinished?.call();
    }
  }

  void _updateHover(PointerHoverEvent event) {
    if (!widget.enabled) return;
    final available = (widget.width - widget.sliderExtent).clamp(
      0.0,
      double.infinity,
    );
    final authored = _progress.value.clamp(0.0, 1.0);
    final visual = widget.reverseDirection ? 1 - authored : authored;
    final thumbX = widget.sliderExtent / 2 + visual * available;
    final thumbRadius = widget.sliderExtent / 2;
    final hitRadius = thumbRadius * .72 + thumbRadius * .5;
    final hovering = (event.localPosition.dx - thumbX).abs() <= hitRadius;
    if (hovering != _isHoveringThumb) {
      _isHoveringThumb = hovering;
      _updateMotionTargets();
    }
  }

  void _clearHover(PointerExitEvent _) {
    if (!_isHoveringThumb) return;
    _isHoveringThumb = false;
    _updateMotionTargets();
  }

  void _updateMotionTargets({bool forceOverlay = false}) {
    _driveMiuixSliderSpring(
      _thumb,
      _isDragging || _isHoveringThumb ? debugMiuixSliderActiveThumbScale() : 1,
      debugMiuixSliderThumbScaleSpring(),
      reduceMotion: _reduceMotion,
    );
    if (forceOverlay || _overlayActive != _isDragging) {
      _overlayActive = _isDragging;
      _driveMiuixSliderOverlay(
        _overlay,
        _overlayActive,
        reduceMotion: _reduceMotion,
      );
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _thumb.dispose();
    _overlay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progress, _thumb, _overlay]),
      builder: (context, _) {
        final track = MouseRegion(
          onHover: _updateHover,
          onExit: _clearHover,
          child: SizedBox(
            width: widget.width,
            height: widget.sliderExtent,
            child: CustomPaint(
              painter: _MiuixSliderPainter(
                _MiuixSliderPaintData(
                  startFraction: 0,
                  endFraction: _progress.value,
                  divisions: widget.divisions,
                  keyPointFractions: widget.keyPointFractions,
                  enabled: widget.enabled,
                  vertical: false,
                  reverseDirection: widget.reverseDirection,
                  colors: widget.colors,
                  trackScale: widget.trackScale,
                  thumbScale: widget.thumbScale * _thumb.value,
                  backgroundOverlayAlpha: _overlay.value,
                ),
              ),
            ),
          ),
        );
        return _miuixSliderCrossAxisTarget(
          visualExtent: widget.sliderExtent,
          targetExtent: widget.touchTargetExtent,
          vertical: false,
          child: track,
          interactionBuilder: (visual) => _miuixPriorityHorizontalDrag(
            onStart: _canChange ? _startDrag : null,
            onUpdate: _canChange ? _updateDrag : null,
            onEnd: _canChange ? (_) => _finishInteraction() : null,
            onCancel: _canChange ? _finishInteraction : null,
            excludeFromSemantics: true,
            child: visual,
          ),
          semanticsBuilder: (target) => Semantics(
            key: const ValueKey('miuix-slider-semantics'),
            container: true,
            explicitChildNodes: true,
            enabled: true,
            focusable: false,
            accessibilityFocusBlockType: AccessibilityFocusBlockType.blockNode,
            onIncrease: widget.onIncrease,
            onDecrease: widget.onDecrease,
            child: target,
          ),
        );
      },
    );
  }
}

/// Stateful VerticalSlider core with the same source springs and direction
/// mapping as the horizontal implementation.
class _MiuixVerticalSliderBody extends StatefulWidget {
  const _MiuixVerticalSliderBody({
    required this.value,
    required this.range,
    required this.height,
    required this.width,
    required this.touchTargetExtent,
    required this.enabled,
    required this.onChanged,
    required this.onChangeFinished,
    required this.divisions,
    required this.keyPoints,
    required this.keyPointFractions,
    required this.magnetThreshold,
    required this.hapticEffect,
    required this.reverseDirection,
    required this.trackScale,
    required this.thumbScale,
    required this.colors,
    required this.onIncrease,
    required this.onDecrease,
  });

  final double value;
  final ({double min, double max}) range;
  final double height;
  final double width;
  final double touchTargetExtent;
  final bool enabled;
  final ValueChanged<double>? onChanged;
  final VoidCallback? onChangeFinished;
  final int? divisions;
  final List<double> keyPoints;
  final List<double> keyPointFractions;
  final double magnetThreshold;
  final MiuixSliderHapticEffect hapticEffect;
  final bool reverseDirection;
  final double trackScale;
  final double thumbScale;
  final MiuixSliderColors colors;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  State<_MiuixVerticalSliderBody> createState() =>
      _MiuixVerticalSliderBodyState();
}

class _MiuixVerticalSliderBodyState extends State<_MiuixVerticalSliderBody>
    with TickerProviderStateMixin {
  late final AnimationController _progress;
  late final AnimationController _thumb;
  late final AnimationController _overlay;
  bool _isDragging = false;
  bool _isHoveringThumb = false;
  bool _overlayActive = false;
  bool _reduceMotion = false;
  late double _lastHapticValue;

  bool get _canChange => widget.enabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController.unbounded(
      vsync: this,
      value: _fractionForValue(widget.value, widget.range),
    );
    _thumb = AnimationController.unbounded(vsync: this, value: 1);
    _overlay = AnimationController.unbounded(vsync: this, value: 0);
    _lastHapticValue = widget.value;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = MediaQuery.disableAnimationsOf(context);
    if (next == _reduceMotion) return;
    _reduceMotion = next;
    if (_reduceMotion) {
      _driveProgress();
      _updateMotionTargets(forceOverlay: true);
    }
  }

  void _driveProgress() {
    _driveMiuixSliderSpring(
      _progress,
      _fractionForValue(widget.value, widget.range),
      debugMiuixSliderProgressSpring(dragging: _isDragging),
      reduceMotion: _reduceMotion,
      visibilityThreshold: _miuixSliderProgressVisibilityThreshold(
        widget.range,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant _MiuixVerticalSliderBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = _fractionForValue(widget.value, widget.range);
    if ((target - _fractionForValue(oldWidget.value, oldWidget.range)).abs() >
        .000001) {
      _driveProgress();
    }
    if (!widget.enabled && oldWidget.enabled) {
      _finishInteraction(notify: false);
    }
  }

  double _valueAt(Offset local) {
    final available = (widget.height - widget.width).clamp(
      0.0,
      double.infinity,
    );
    final visualFraction = available == 0
        ? 0.0
        : ((local.dy - widget.width / 2) / available).clamp(0.0, 1.0);
    final valueFraction = widget.reverseDirection
        ? visualFraction
        : 1 - visualFraction;
    return _valueForFraction(
      valueFraction,
      widget.range,
      widget.divisions,
      keyPoints: widget.keyPoints,
      magnetThreshold: widget.magnetThreshold,
    );
  }

  void _startDrag(DragStartDetails details) {
    if (!_canChange) return;
    _isDragging = true;
    _lastHapticValue = _valueAt(details.localPosition);
    _updateMotionTargets();
    widget.onChanged?.call(
      _normalizeSliderCallbackValue(_lastHapticValue, widget.range),
    );
  }

  void _updateDrag(DragUpdateDetails details) {
    if (!_canChange) return;
    final next = _valueAt(details.localPosition);
    _dispatchSliderHaptic(
      previous: _lastHapticValue,
      next: next,
      range: widget.range,
      effect: widget.hapticEffect,
      divisions: widget.divisions,
      keyPoints: widget.keyPoints,
    );
    _lastHapticValue = next;
    widget.onChanged?.call(_normalizeSliderCallbackValue(next, widget.range));
  }

  void _finishInteraction({bool notify = true}) {
    final hadDrag = _isDragging;
    _isDragging = false;
    _updateMotionTargets();
    if (notify && hadDrag) {
      widget.onChangeFinished?.call();
    }
  }

  void _updateHover(PointerHoverEvent event) {
    if (!widget.enabled) return;
    final available = (widget.height - widget.width).clamp(
      0.0,
      double.infinity,
    );
    final authored = 1 - _progress.value.clamp(0.0, 1.0);
    final visual = widget.reverseDirection ? 1 - authored : authored;
    final thumbY = widget.width / 2 + visual * available;
    final thumbRadius = widget.width / 2;
    final hitRadius = thumbRadius * .72 + thumbRadius * .5;
    final hovering = (event.localPosition.dy - thumbY).abs() <= hitRadius;
    if (hovering != _isHoveringThumb) {
      _isHoveringThumb = hovering;
      _updateMotionTargets();
    }
  }

  void _clearHover(PointerExitEvent _) {
    if (!_isHoveringThumb) return;
    _isHoveringThumb = false;
    _updateMotionTargets();
  }

  void _updateMotionTargets({bool forceOverlay = false}) {
    _driveMiuixSliderSpring(
      _thumb,
      _isDragging || _isHoveringThumb ? debugMiuixSliderActiveThumbScale() : 1,
      debugMiuixSliderThumbScaleSpring(),
      reduceMotion: _reduceMotion,
    );
    if (forceOverlay || _overlayActive != _isDragging) {
      _overlayActive = _isDragging;
      _driveMiuixSliderOverlay(
        _overlay,
        _overlayActive,
        reduceMotion: _reduceMotion,
      );
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    _thumb.dispose();
    _overlay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_progress, _thumb, _overlay]),
      builder: (context, _) {
        final authoredFraction = 1 - _progress.value;
        final track = MouseRegion(
          onHover: _updateHover,
          onExit: _clearHover,
          child: CustomPaint(
            painter: _MiuixSliderPainter(
              _MiuixSliderPaintData(
                startFraction: 1,
                endFraction: authoredFraction,
                divisions: widget.divisions,
                keyPointFractions: widget.keyPointFractions,
                enabled: widget.enabled,
                vertical: true,
                reverseDirection: widget.reverseDirection,
                trackScale: widget.trackScale,
                thumbScale: widget.thumbScale * _thumb.value,
                backgroundOverlayAlpha: _overlay.value,
                colors: widget.colors,
              ),
            ),
          ),
        );
        return _miuixSliderCrossAxisTarget(
          visualExtent: widget.width,
          targetExtent: widget.touchTargetExtent,
          vertical: true,
          child: track,
          interactionBuilder: (visual) => _miuixVerticalDrag(
            excludeFromSemantics: true,
            onStart: _canChange ? _startDrag : null,
            onUpdate: _canChange ? _updateDrag : null,
            onEnd: _canChange ? (_) => _finishInteraction() : null,
            onCancel: _canChange ? _finishInteraction : null,
            child: visual,
          ),
          semanticsBuilder: (target) => Semantics(
            key: const ValueKey('miuix-vertical-slider-semantics'),
            container: true,
            explicitChildNodes: true,
            enabled: true,
            focusable: false,
            accessibilityFocusBlockType: AccessibilityFocusBlockType.blockNode,
            onIncrease: widget.onIncrease,
            onDecrease: widget.onDecrease,
            child: target,
          ),
        );
      },
    );
  }
}

/// Stateful RangeSlider core reproducing the source's two-thumb ownership
/// handoff. The selected thumb first clamps against its peer; another movement
/// in the same direction at equality transfers the drag to the other thumb.
class _MiuixRangeSliderBody extends StatefulWidget {
  const _MiuixRangeSliderBody({
    required this.values,
    required this.range,
    required this.width,
    required this.sliderExtent,
    required this.touchTargetExtent,
    required this.enabled,
    required this.onChanged,
    required this.onChangeFinished,
    required this.divisions,
    required this.keyPoints,
    required this.keyPointFractions,
    required this.magnetThreshold,
    required this.hapticEffect,
    required this.isRtl,
    required this.colors,
  });

  final RangeValues values;
  final ({double min, double max}) range;
  final double width;
  final double sliderExtent;
  final double touchTargetExtent;
  final bool enabled;
  final ValueChanged<RangeValues>? onChanged;
  final VoidCallback? onChangeFinished;
  final int? divisions;
  final List<double> keyPoints;
  final List<double> keyPointFractions;
  final double magnetThreshold;
  final MiuixSliderHapticEffect hapticEffect;
  final bool isRtl;
  final MiuixSliderColors colors;

  @override
  State<_MiuixRangeSliderBody> createState() => _MiuixRangeSliderBodyState();
}

class _MiuixRangeSliderBodyState extends State<_MiuixRangeSliderBody>
    with TickerProviderStateMixin {
  late final AnimationController _startProgress;
  late final AnimationController _endProgress;
  late final AnimationController _startThumb;
  late final AnimationController _endThumb;
  late final AnimationController _overlay;
  late double _currentStart;
  late double _currentEnd;
  late RangeValues _lastHapticValues;
  double _startDragOffset = 0;
  double _endDragOffset = 0;
  bool _isDraggingStart = false;
  bool _isDraggingEnd = false;
  bool _lastDraggedIsStart = true;
  bool _isHoveringStart = false;
  bool _isHoveringEnd = false;
  bool _overlayActive = false;
  bool _reduceMotion = false;

  bool get _isDragging => _isDraggingStart || _isDraggingEnd;
  bool get _canChange => widget.enabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _syncCurrentValues(widget.values);
    _startProgress = AnimationController.unbounded(
      vsync: this,
      value: _fractionForValue(_currentStart, widget.range),
    );
    _endProgress = AnimationController.unbounded(
      vsync: this,
      value: _fractionForValue(_currentEnd, widget.range),
    );
    _startThumb = AnimationController.unbounded(vsync: this, value: 1);
    _endThumb = AnimationController.unbounded(vsync: this, value: 1);
    _overlay = AnimationController.unbounded(vsync: this, value: 0);
    _lastHapticValues = RangeValues(_currentStart, _currentEnd);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = MediaQuery.disableAnimationsOf(context);
    if (next == _reduceMotion) return;
    _reduceMotion = next;
    if (_reduceMotion) {
      if (!_isDragging) _syncCurrentValues(widget.values);
      _animateProgress(dragging: _isDragging);
      _updateMotionTargets(forceOverlay: true);
    }
  }

  @override
  void didUpdateWidget(covariant _MiuixRangeSliderBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDragging) {
      _syncCurrentValues(widget.values);
      _animateProgress(dragging: false);
    }
    if (!widget.enabled && oldWidget.enabled) {
      _finishInteraction(notify: false);
    }
  }

  void _syncCurrentValues(RangeValues values) {
    final normalized = _normalizeSliderCallbackRange(values, widget.range);
    _currentStart = normalized.start;
    _currentEnd = normalized.end;
  }

  double get _available =>
      (widget.width - widget.sliderExtent).clamp(0.0, double.infinity);

  double _visualPosition(double value) {
    final fraction = _fractionForValue(value, widget.range);
    final effective = widget.isRtl ? 1 - fraction : fraction;
    return widget.sliderExtent / 2 + effective * _available;
  }

  double _valueAtOffset(double offset) {
    final visualFraction = _available == 0
        ? 0.0
        : ((offset - widget.sliderExtent / 2) / _available).clamp(0.0, 1.0);
    final valueFraction = widget.isRtl ? 1 - visualFraction : visualFraction;
    return _valueForFraction(
      valueFraction,
      widget.range,
      widget.divisions,
      keyPoints: widget.keyPoints,
      magnetThreshold: widget.magnetThreshold,
    );
  }

  void _startDrag(DragStartDetails details) {
    if (!_canChange) return;
    final offset = details.localPosition.dx;
    final startPos = _visualPosition(_currentStart);
    final endPos = _visualPosition(_currentEnd);
    final thumbRadius = widget.sliderExtent / 2;
    final hitRadius = thumbRadius * .72 + thumbRadius * .5;
    final onStart = (offset - startPos).abs() <= hitRadius;
    final onEnd = (offset - endPos).abs() <= hitRadius;

    if (onStart && !onEnd) {
      _isDraggingStart = true;
      _startDragOffset = offset;
    } else if (!onStart && onEnd) {
      _isDraggingEnd = true;
      _endDragOffset = offset;
    } else if (onStart && onEnd) {
      if (_lastDraggedIsStart) {
        _isDraggingStart = true;
        _startDragOffset = offset;
      } else {
        _isDraggingEnd = true;
        _endDragOffset = offset;
      }
    } else if ((offset - startPos).abs() <= (offset - endPos).abs()) {
      _isDraggingStart = true;
      _startDragOffset = offset;
    } else {
      _isDraggingEnd = true;
      _endDragOffset = offset;
    }
    _lastHapticValues = RangeValues(_currentStart, _currentEnd);
    _updateMotionTargets();
  }

  void _updateDrag(DragUpdateDetails details) {
    if (!_canChange) return;
    if (_isDraggingStart) {
      _lastDraggedIsStart = true;
      // The priority recognizer can accept before monodrag has folded the
      // winning move into its pending delta. The absolute local position is
      // the same accumulated offset used by Compose and retains that first
      // coarse Android move.
      final tentative = details.localPosition.dx;
      final motionDelta = tentative - _startDragOffset;
      final resolved = _valueAtOffset(tentative);
      final nextStart = math.min(resolved, _currentEnd);
      final crossesForward = widget.isRtl ? motionDelta < 0 : motionDelta > 0;
      if (nextStart >= _currentEnd &&
          crossesForward &&
          _currentStart == _currentEnd) {
        _isDraggingStart = false;
        _isDraggingEnd = true;
        _endDragOffset = tentative;
        final nextEnd = math.max(_valueAtOffset(_endDragOffset), _currentStart);
        _currentEnd = nextEnd;
      } else {
        _startDragOffset = tentative;
        _currentStart = nextStart;
      }
    } else if (_isDraggingEnd) {
      _lastDraggedIsStart = false;
      final tentative = details.localPosition.dx;
      final motionDelta = tentative - _endDragOffset;
      final resolved = _valueAtOffset(tentative);
      final nextEnd = math.max(resolved, _currentStart);
      final crossesBackward = widget.isRtl ? motionDelta > 0 : motionDelta < 0;
      if (nextEnd <= _currentStart &&
          crossesBackward &&
          _currentStart == _currentEnd) {
        _isDraggingEnd = false;
        _isDraggingStart = true;
        _startDragOffset = tentative;
        final nextStart = math.min(
          _valueAtOffset(_startDragOffset),
          _currentEnd,
        );
        _currentStart = nextStart;
      } else {
        _endDragOffset = tentative;
        _currentEnd = nextEnd;
      }
    }
    final next = RangeValues(_currentStart, _currentEnd);
    if ((next.start - _lastHapticValues.start).abs() >= .0005) {
      _dispatchSliderHaptic(
        previous: _lastHapticValues.start,
        next: next.start,
        range: widget.range,
        effect: widget.hapticEffect,
        divisions: widget.divisions,
        keyPoints: widget.keyPoints,
      );
    }
    if ((next.end - _lastHapticValues.end).abs() >= .0005) {
      _dispatchSliderHaptic(
        previous: _lastHapticValues.end,
        next: next.end,
        range: widget.range,
        effect: widget.hapticEffect,
        divisions: widget.divisions,
        keyPoints: widget.keyPoints,
      );
    }
    _lastHapticValues = next;
    _animateProgress(dragging: true);
    _updateMotionTargets();
    widget.onChanged?.call(_normalizeSliderCallbackRange(next, widget.range));
  }

  void _animateProgress({required bool dragging}) {
    final spring = debugMiuixSliderProgressSpring(dragging: dragging);
    _driveMiuixSliderSpring(
      _startProgress,
      _fractionForValue(_currentStart, widget.range),
      spring,
      reduceMotion: _reduceMotion,
      visibilityThreshold: _miuixSliderProgressVisibilityThreshold(
        widget.range,
      ),
    );
    _driveMiuixSliderSpring(
      _endProgress,
      _fractionForValue(_currentEnd, widget.range),
      spring,
      reduceMotion: _reduceMotion,
      visibilityThreshold: _miuixSliderProgressVisibilityThreshold(
        widget.range,
      ),
    );
  }

  void _finishInteraction({bool notify = true}) {
    final hadDrag = _isDragging;
    _isDraggingStart = false;
    _isDraggingEnd = false;
    _updateMotionTargets();
    if (notify && hadDrag) {
      widget.onChangeFinished?.call();
    }
  }

  void _updateHover(PointerHoverEvent event) {
    if (!widget.enabled) return;
    final position = event.localPosition.dx;
    final thumbRadius = widget.sliderExtent / 2;
    final hitRadius = thumbRadius * .72 + thumbRadius * .5;
    double animatedPosition(AnimationController progress) {
      final fraction = progress.value.clamp(0.0, 1.0);
      final effective = widget.isRtl ? 1 - fraction : fraction;
      return widget.sliderExtent / 2 + effective * _available;
    }

    final overStart =
        (position - animatedPosition(_startProgress)).abs() <= hitRadius;
    final overEnd =
        (position - animatedPosition(_endProgress)).abs() <= hitRadius;
    if (overStart != _isHoveringStart || overEnd != _isHoveringEnd) {
      _isHoveringStart = overStart;
      _isHoveringEnd = overEnd;
      _updateMotionTargets();
    }
  }

  void _clearHover(PointerExitEvent _) {
    if (!_isHoveringStart && !_isHoveringEnd) return;
    _isHoveringStart = false;
    _isHoveringEnd = false;
    _updateMotionTargets();
  }

  void _updateMotionTargets({bool forceOverlay = false}) {
    final activeScale = debugMiuixSliderActiveThumbScale();
    final spring = debugMiuixSliderThumbScaleSpring();
    _driveMiuixSliderSpring(
      _startThumb,
      _isDraggingStart || _isHoveringStart ? activeScale : 1,
      spring,
      reduceMotion: _reduceMotion,
    );
    _driveMiuixSliderSpring(
      _endThumb,
      _isDraggingEnd || _isHoveringEnd ? activeScale : 1,
      spring,
      reduceMotion: _reduceMotion,
    );
    if (forceOverlay || _overlayActive != _isDragging) {
      _overlayActive = _isDragging;
      _driveMiuixSliderOverlay(
        _overlay,
        _overlayActive,
        reduceMotion: _reduceMotion,
      );
    }
  }

  @override
  void dispose() {
    _startProgress.dispose();
    _endProgress.dispose();
    _startThumb.dispose();
    _endThumb.dispose();
    _overlay.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _startProgress,
        _endProgress,
        _startThumb,
        _endThumb,
        _overlay,
      ]),
      builder: (context, _) {
        final track = MouseRegion(
          onHover: _updateHover,
          onExit: _clearHover,
          child: SizedBox(
            width: widget.width,
            height: widget.sliderExtent,
            child: CustomPaint(
              painter: _MiuixSliderPainter(
                _MiuixSliderPaintData(
                  startFraction: _startProgress.value,
                  endFraction: _endProgress.value,
                  divisions: widget.divisions,
                  keyPointFractions: widget.keyPointFractions,
                  enabled: widget.enabled,
                  vertical: false,
                  range: true,
                  reverseDirection: widget.isRtl,
                  startThumbScale: _startThumb.value,
                  endThumbScale: _endThumb.value,
                  backgroundOverlayAlpha: _overlay.value,
                  colors: widget.colors,
                ),
              ),
            ),
          ),
        );
        return _miuixSliderCrossAxisTarget(
          visualExtent: widget.sliderExtent,
          targetExtent: widget.touchTargetExtent,
          vertical: false,
          child: track,
          interactionBuilder: (visual) => _miuixPriorityHorizontalDrag(
            onStart: _canChange ? _startDrag : null,
            onUpdate: _canChange ? _updateDrag : null,
            onEnd: _canChange ? (_) => _finishInteraction() : null,
            onCancel: _canChange ? _finishInteraction : null,
            excludeFromSemantics: true,
            child: visual,
          ),
          semanticsBuilder: (target) => Semantics(
            key: const ValueKey('miuix-range-slider-semantics'),
            container: true,
            explicitChildNodes: true,
            enabled: true,
            focusable: false,
            accessibilityFocusBlockType: AccessibilityFocusBlockType.blockNode,
            child: target,
          ),
        );
      },
    );
  }
}
