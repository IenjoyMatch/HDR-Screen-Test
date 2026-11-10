part of '../miuix_widgets.dart';

// Source contract for ColorPicker.kt:
// - The authored capsule is 26dp high.
// - Android expands pointer input and semantics to a centered 48dp target.
// - A stationary tap does not change the value because the source installs
//   `draggable` without a clickable/tap modifier.
// - The drag start publishes the down position and resets edge haptics.
// - Subsequent movement emits GestureThresholdActivate only at either edge.
// - The 20dp indicator uses a 6dp white ring and a four-stop radial shadow.

/// Public equivalent of ColorPicker.kt's `drawCheckerboard` modifier.
class MiuixCheckerboard extends StatelessWidget {
  /// Creates a checkerboard painted behind [child].
  const MiuixCheckerboard({
    super.key,
    required this.child,
    this.cellSize = 3,
    this.lightColor = const Color(0xFFCCCCCC),
    this.darkColor = const Color(0xFFAAAAAA),
  });

  /// Content painted over the transparency grid.
  final Widget child;

  /// Logical cell size. The source default is 3dp.
  final double cellSize;

  /// Background square color.
  final Color lightColor;

  /// Alternating square color.
  final Color darkColor;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MiuixCheckerboardPainter(
        cellSize: _finiteOr(cellSize, 3).clamp(1.0, double.infinity),
        lightColor: lightColor,
        darkColor: darkColor,
      ),
      child: child,
    );
  }
}

/// Resolves the source `miuixShape`/`miuixCapsuleShape` theme switch.
///
/// Color controls paint their own gradients, so the clip must surround the
/// complete painted child. This also clips an end-position indicator exactly
/// as Compose clips the complete ColorSlider Box.
Widget _miuixColorShapeClip(
  BuildContext context, {
  required Widget child,
  required double radius,
  Key? clipKey,
}) {
  final borderRadius = BorderRadius.circular(math.max(0, radius));
  return MiuixSquircleSurface(
    key: clipKey,
    color: Colors.transparent,
    borderRadius: borderRadius,
    enabled: MiuixTheme.of(context).enableSquircle,
    child: child,
  );
}

class _MiuixHsvAlphaSlider extends StatefulWidget {
  const _MiuixHsvAlphaSlider({
    required this.value,
    required this.baseColor,
    required this.onChanged,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  final double value;
  final Color baseColor;
  final ValueChanged<double>? onChanged;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  State<_MiuixHsvAlphaSlider> createState() => _MiuixHsvAlphaSliderState();
}

class _MiuixHsvAlphaSliderState extends State<_MiuixHsvAlphaSlider> {
  int _lastEdge = 0;
  double _lastStep = 0;

  void _handleDragStart(
    Offset localPosition,
    Size size,
    TextDirection textDirection,
  ) {
    final fraction = _fractionForCompactTrackPosition(
      localPosition,
      size,
      textDirection,
    );
    // SliderHapticState.reset(newValue) does not vibrate at drag start.
    _lastEdge = 0;
    _lastStep = fraction;
    widget.onChanged?.call(fraction);
  }

  void _handleDragUpdate(
    Offset localPosition,
    Size size,
    TextDirection textDirection,
  ) {
    final fraction = _fractionForCompactTrackPosition(
      localPosition,
      size,
      textDirection,
    );
    widget.onChanged?.call(fraction);
    _emitEdgeHaptic(fraction);
  }

  void _emitEdgeHaptic(double fraction) {
    if (widget.hapticEffect == MiuixSliderHapticEffect.none) {
      return;
    }
    final edge = fraction <= 0 ? -1 : (fraction >= 1 ? 1 : 0);
    if (edge == 0) {
      _lastEdge = 0;
    } else if (edge != _lastEdge) {
      _lastEdge = edge;
      unawaited(MiuixHaptics.perform(MiuixHapticType.gestureThresholdActivate));
    }
    if (widget.hapticEffect == MiuixSliderHapticEffect.step &&
        edge == 0 &&
        fraction != _lastStep) {
      _lastStep = fraction;
      unawaited(MiuixHaptics.perform(MiuixHapticType.textHandleMove));
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeValue = _finiteOr(widget.value, 0).clamp(0.0, 1.0);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final sourceSliderHeight = _miuixRoundLogicalDimension(26, pixelRatio);
    final touchTargetHeight = _miuixRoundLogicalDimension(48, pixelRatio);
    return _MiuixColorSliderHitTarget(
      key: const ValueKey('miuix-color-slider-hit-target'),
      targetExtent: touchTargetHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textDirection = Directionality.of(context);
          final sliderSize = Size(
            constraints.maxWidth.isFinite ? constraints.maxWidth : 320,
            sourceSliderHeight,
          );
          return _miuixColorSliderDragTarget(
            visualExtent: sourceSliderHeight,
            targetExtent: touchTargetHeight,
            enabled: widget.onChanged != null,
            onStart: widget.onChanged == null
                ? null
                : (details) => _handleDragStart(
                    details.localPosition,
                    sliderSize,
                    textDirection,
                  ),
            onUpdate: widget.onChanged == null
                ? null
                : (details) => _handleDragUpdate(
                    details.localPosition,
                    sliderSize,
                    textDirection,
                  ),
            child: _miuixColorShapeClip(
              context,
              clipKey: const ValueKey('miuix-color-slider-shape-clip'),
              radius: sourceSliderHeight / 2,
              child: SizedBox(
                key: const ValueKey('miuix-hsv-alpha-slider'),
                height: sourceSliderHeight,
                child: CustomPaint(
                  painter: _MiuixHsvAlphaSliderPainter(
                    value: safeValue,
                    baseColor: widget.baseColor,
                    textDirection: textDirection,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiuixHsvChannelSlider extends StatefulWidget {
  const _MiuixHsvChannelSlider({
    required this.value,
    required this.colors,
    required this.onChanged,
    this.sliderKey = const ValueKey('miuix-color-channel-slider'),
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  final double value;
  final List<Color> colors;
  final ValueChanged<double>? onChanged;
  final Key sliderKey;
  final MiuixSliderHapticEffect hapticEffect;

  @override
  State<_MiuixHsvChannelSlider> createState() => _MiuixHsvChannelSliderState();
}

class _MiuixHsvChannelSliderState extends State<_MiuixHsvChannelSlider> {
  int _lastEdge = 0;
  double _lastStep = 0;

  void _handleDragStart(
    Offset localPosition,
    Size size,
    TextDirection textDirection,
  ) {
    final fraction = _fractionForCompactTrackPosition(
      localPosition,
      size,
      textDirection,
    );
    // The source publishes the start value before haptic tracking begins.
    _lastEdge = 0;
    _lastStep = fraction;
    widget.onChanged?.call(fraction);
  }

  void _handleDragUpdate(
    Offset localPosition,
    Size size,
    TextDirection textDirection,
  ) {
    final fraction = _fractionForCompactTrackPosition(
      localPosition,
      size,
      textDirection,
    );
    widget.onChanged?.call(fraction);
    _emitEdgeHaptic(fraction);
  }

  void _emitEdgeHaptic(double fraction) {
    if (widget.hapticEffect == MiuixSliderHapticEffect.none) {
      return;
    }
    final edge = fraction <= 0 ? -1 : (fraction >= 1 ? 1 : 0);
    if (edge == 0) {
      _lastEdge = 0;
    } else if (edge != _lastEdge) {
      _lastEdge = edge;
      unawaited(MiuixHaptics.perform(MiuixHapticType.gestureThresholdActivate));
    }
    if (widget.hapticEffect == MiuixSliderHapticEffect.step &&
        edge == 0 &&
        fraction != _lastStep) {
      _lastStep = fraction;
      unawaited(MiuixHaptics.perform(MiuixHapticType.textHandleMove));
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeValue = _finiteOr(widget.value, 0).clamp(0.0, 1.0);
    final safeColors = widget.colors.length < 2
        ? const [Colors.black, Colors.white]
        : widget.colors;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final sourceSliderHeight = _miuixRoundLogicalDimension(26, pixelRatio);
    final touchTargetHeight = _miuixRoundLogicalDimension(48, pixelRatio);
    return _MiuixColorSliderHitTarget(
      key: const ValueKey('miuix-color-slider-hit-target'),
      targetExtent: touchTargetHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textDirection = Directionality.of(context);
          final sliderSize = Size(
            constraints.maxWidth.isFinite ? constraints.maxWidth : 320,
            sourceSliderHeight,
          );
          return _miuixColorSliderDragTarget(
            visualExtent: sourceSliderHeight,
            targetExtent: touchTargetHeight,
            enabled: widget.onChanged != null,
            onStart: widget.onChanged == null
                ? null
                : (details) => _handleDragStart(
                    details.localPosition,
                    sliderSize,
                    textDirection,
                  ),
            onUpdate: widget.onChanged == null
                ? null
                : (details) => _handleDragUpdate(
                    details.localPosition,
                    sliderSize,
                    textDirection,
                  ),
            child: _miuixColorShapeClip(
              context,
              clipKey: const ValueKey('miuix-color-slider-shape-clip'),
              radius: sourceSliderHeight / 2,
              child: SizedBox(
                key: widget.sliderKey,
                height: sourceSliderHeight,
                child: CustomPaint(
                  painter: _MiuixHsvChannelSliderPainter(
                    value: safeValue,
                    colors: safeColors,
                    textDirection: textDirection,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Keeps the 26dp color track in layout while exposing Compose's 48dp target.
///
/// The outer transform expands hit testing. Its reciprocal visual branch keeps
/// painting at 26dp, while the independently re-expanded semantics branch
/// reports the one 48dp Android View node produced by the source draggable.
Widget _miuixColorSliderDragTarget({
  required Widget child,
  required double visualExtent,
  required double targetExtent,
  required bool enabled,
  GestureDragStartCallback? onStart,
  GestureDragUpdateCallback? onUpdate,
}) {
  final safeVisual = _finiteOr(
    visualExtent,
    26,
  ).clamp(.000001, double.infinity);
  final safeTarget = _finiteOr(
    targetExtent,
    48,
  ).clamp(safeVisual, double.infinity);
  final outerScale = safeTarget / safeVisual;

  final target = Stack(
    clipBehavior: Clip.none,
    fit: StackFit.passthrough,
    children: [
      child,
      Positioned.fill(
        child: Transform.scale(
          scaleY: outerScale,
          child: Semantics(
            key: const ValueKey('miuix-color-slider-touch-target'),
            container: true,
            explicitChildNodes: true,
            enabled: enabled,
            focusable: false,
            accessibilityFocusBlockType: AccessibilityFocusBlockType.blockNode,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    ],
  );

  return _miuixPriorityHorizontalDrag(
    onStart: onStart,
    onUpdate: onUpdate,
    excludeFromSemantics: true,
    child: target,
  );
}

/// Expands hit testing vertically without increasing the child's layout size.
///
/// RenderBox normally rejects a point before a transformed child can see an
/// out-of-bounds event. This proxy accepts the source 48dp rectangle and maps
/// its extra top/bottom bands to the nearest point inside the 26dp detector.
class _MiuixColorSliderHitTarget extends SingleChildRenderObjectWidget {
  const _MiuixColorSliderHitTarget({
    super.key,
    required this.targetExtent,
    required super.child,
  });

  final double targetExtent;

  @override
  _RenderMiuixColorSliderHitTarget createRenderObject(BuildContext context) {
    return _RenderMiuixColorSliderHitTarget(targetExtent);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderMiuixColorSliderHitTarget renderObject,
  ) {
    renderObject.targetExtent = targetExtent;
  }
}

class _RenderMiuixColorSliderHitTarget extends RenderProxyBox {
  _RenderMiuixColorSliderHitTarget(this._targetExtent);

  double _targetExtent;

  double get targetExtent => _targetExtent;

  set targetExtent(double value) {
    final next = _finiteOr(value, 48).clamp(0.0, double.infinity);
    if (next == _targetExtent) return;
    _targetExtent = next;
    markNeedsSemanticsUpdate();
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final currentChild = child;
    if (currentChild == null || !hasSize || size.isEmpty) return false;
    final effectiveExtent = math.max(size.height, _targetExtent);
    final expandedRect = Rect.fromLTWH(
      0,
      (size.height - effectiveExtent) / 2,
      size.width,
      effectiveExtent,
    );
    if (!expandedRect.contains(position)) return false;

    // Preserve the real horizontal coordinate used by ColorSlider, and only
    // clamp the expanded cross-axis coordinate into the detector's RenderBox.
    final mappedPosition = Offset(
      position.dx.clamp(0.0, math.max(0.0, size.width - .000001)),
      size.height / 2,
    );
    return currentChild.hitTest(result, position: mappedPosition);
  }
}

class _MiuixHsvChannelSliderPainter extends CustomPainter {
  const _MiuixHsvChannelSliderPainter({
    required this.value,
    required this.colors,
    required this.textDirection,
  });

  final double value;
  final List<Color> colors;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final isRtl = textDirection == TextDirection.rtl;
    canvas.drawRect(
      rect,
      Paint()
        ..shader =
            LinearGradient(
              colors: isRtl ? colors.reversed.toList() : colors,
              tileMode: TileMode.clamp,
            ).createShader(
              Rect.fromLTRB(
                size.height / 2,
                0,
                size.width - size.height / 2,
                size.height,
              ),
            ),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.grey.withValues(alpha: .1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .5,
    );

    final effectiveWidth = math.max(0.0, size.width - size.height);
    final visualValue = isRtl ? 1 - value : value;
    final center = Offset(
      size.height / 2 + effectiveWidth * visualValue,
      size.height / 2,
    );
    _paintMiuixColorSliderIndicator(canvas, center);
  }

  @override
  bool shouldRepaint(covariant _MiuixHsvChannelSliderPainter oldDelegate) {
    return value != oldDelegate.value ||
        colors != oldDelegate.colors ||
        textDirection != oldDelegate.textDirection;
  }
}

double _fractionForCompactTrackPosition(
  Offset localPosition,
  Size size,
  TextDirection textDirection,
) {
  final width = _finiteOr(size.width, 0);
  if (width <= 0) {
    return 0;
  }
  final fraction = width <= 26
      ? (localPosition.dx / width).clamp(0.0, 1.0)
      : ((localPosition.dx.clamp(13.0, width - 13) - 13) / (width - 26)).clamp(
          0.0,
          1.0,
        );
  return textDirection == TextDirection.rtl ? 1 - fraction : fraction;
}

class _MiuixHsvAlphaSliderPainter extends CustomPainter {
  const _MiuixHsvAlphaSliderPainter({
    required this.value,
    required this.baseColor,
    required this.textDirection,
  });

  final double value;
  final Color baseColor;
  final TextDirection textDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    _paintCheckerboard(canvas, size);
    final isRtl = textDirection == TextDirection.rtl;
    final gradient =
        LinearGradient(
          colors: isRtl
              ? [baseColor.withValues(alpha: 1), baseColor.withValues(alpha: 0)]
              : [
                  baseColor.withValues(alpha: 0),
                  baseColor.withValues(alpha: 1),
                ],
          tileMode: TileMode.clamp,
        ).createShader(
          Rect.fromLTRB(
            size.height / 2,
            0,
            size.width - size.height / 2,
            size.height,
          ),
        );
    canvas.drawRect(rect, Paint()..shader = gradient);
    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.grey.withValues(alpha: .1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .5,
    );

    final effectiveWidth = math.max(0.0, size.width - size.height);
    final visualValue = isRtl ? 1 - value : value;
    final center = Offset(
      size.height / 2 + effectiveWidth * visualValue,
      size.height / 2,
    );
    _paintMiuixColorSliderIndicator(canvas, center);
  }

  void _paintCheckerboard(Canvas canvas, Size size) {
    _paintMiuixCheckerboard(
      canvas,
      size,
      cell: 3,
      lightColor: const Color(0xFFCCCCCC),
      darkColor: const Color(0xFFAAAAAA),
    );
  }

  @override
  bool shouldRepaint(covariant _MiuixHsvAlphaSliderPainter oldDelegate) {
    return value != oldDelegate.value ||
        baseColor != oldDelegate.baseColor ||
        textDirection != oldDelegate.textDirection;
  }
}

class _MiuixCheckerboardPainter extends CustomPainter {
  const _MiuixCheckerboardPainter({
    required this.cellSize,
    required this.lightColor,
    required this.darkColor,
  });

  final double cellSize;
  final Color lightColor;
  final Color darkColor;

  @override
  void paint(Canvas canvas, Size size) {
    _paintMiuixCheckerboard(
      canvas,
      size,
      cell: cellSize,
      lightColor: lightColor,
      darkColor: darkColor,
    );
  }

  @override
  bool shouldRepaint(covariant _MiuixCheckerboardPainter oldDelegate) {
    return cellSize != oldDelegate.cellSize ||
        lightColor != oldDelegate.lightColor ||
        darkColor != oldDelegate.darkColor;
  }
}

void _paintMiuixCheckerboard(
  Canvas canvas,
  Size size, {
  required double cell,
  required Color lightColor,
  required Color darkColor,
}) {
  if (size.isEmpty) {
    return;
  }
  final safeCell = _finiteOr(cell, 3).clamp(1.0, double.infinity);
  final lightPaint = Paint()..color = lightColor;
  final darkPaint = Paint()..color = darkColor;
  canvas.drawRect(Offset.zero & size, lightPaint);
  for (var row = 0; row * safeCell < size.height; row++) {
    var x = row.isEven ? safeCell : 0.0;
    final y = row * safeCell;
    while (x < size.width) {
      canvas.drawRect(
        Rect.fromLTWH(
          x,
          y,
          math.min(safeCell, size.width - x),
          math.min(safeCell, size.height - y),
        ),
        darkPaint,
      );
      x += safeCell * 2;
    }
  }
}

/// Paints the exact four-stop radial shadow and 6dp source indicator ring.
void _paintMiuixColorSliderIndicator(
  Canvas canvas,
  Offset center, {
  double indicatorRadius = 10,
}) {
  const halfStroke = 3.0;
  const glowSpread = 2.0;
  final ringCenterRadius = math.max(0.0, indicatorRadius - halfStroke);
  final gradientRadius = ringCenterRadius + halfStroke + glowSpread;
  if (gradientRadius <= 0) return;
  final glowPaint = Paint()
    ..shader = RadialGradient(
      colors: const [
        Colors.transparent,
        Color(0x40000000),
        Color(0x40000000),
        Colors.transparent,
      ],
      stops: [
        math.max(0, ringCenterRadius - halfStroke - glowSpread) /
            gradientRadius,
        math.max(0, ringCenterRadius - halfStroke) / gradientRadius,
        math.min(1, (ringCenterRadius + halfStroke) / gradientRadius),
        1,
      ],
    ).createShader(Rect.fromCircle(center: center, radius: gradientRadius));
  canvas.drawCircle(center, gradientRadius, glowPaint);
  canvas.drawCircle(
    center,
    ringCenterRadius,
    Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = halfStroke * 2,
  );
}
