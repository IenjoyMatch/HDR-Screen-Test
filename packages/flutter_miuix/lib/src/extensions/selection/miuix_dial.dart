import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';

/// Controlled numeric owner for [MiuixDial].
class MiuixDialController extends ChangeNotifier {
  /// Creates a controller with an initial value.
  MiuixDialController({double value = 0}) : _value = value.isFinite ? value : 0;

  double _value;

  /// Current raw value; each dial applies its own bounds.
  double get value => _value;

  /// Replaces the value.
  set value(double next) {
    if (!next.isFinite || next == _value) return;
    _value = next;
    notifyListeners();
  }
}

/// Theme colors for [MiuixDial].
@immutable
class MiuixDialColors {
  /// Creates a complete dial palette.
  const MiuixDialColors({
    required this.track,
    required this.activeTrack,
    required this.thumb,
    required this.foreground,
    required this.disabled,
  });

  /// Arc, thumb, label, and disabled roles.
  final Color track;
  final Color activeTrack;
  final Color thumb;
  final Color foreground;
  final Color disabled;
}

/// Geometry and palette defaults for rotary controls.
abstract final class MiuixDialDefaults {
  // HyperOS 4 rotary-control implementation contract:
  // - The dial exposes one slider semantic node and excludes label echo.
  // - The visible arc and semantic value share one inclusive numeric range.
  // - Optional divisions quantize pointer and assistive adjustments identically.
  // - Pointer angle is clamped to the nearest end across the inactive arc gap.
  // - Direct pan updates bypass autonomous interpolation and follow the pointer.
  // - Programmatic controller updates interpolate track, thumb, and label.
  // - A custom center label receives the same interpolated visible value.
  // - Semantics publishes the logical endpoint immediately for responsiveness.
  // - Reduced motion snaps the visible state to that semantic endpoint.
  // - Track and thumb retain stable geometry during every transition.
  // - Active, inactive, foreground, and disabled colors use semantic roles.
  // - One text-handle haptic is emitted per distinct quantized drag division.
  // - Continuous dials coalesce feedback to a safe tenth-unit sampling key.
  // - Semantic adjustment emits the matching haptic only for a real change.
  // - Change-end is published once when a drag ends or is cancelled.
  // - Semantic adjustment publishes live and settled callbacks together.
  // - Boundary adjustments do not repeat callbacks or haptics.
  // - Caller-controlled values never mutate the internal compatibility owner.
  // - Caller-owned controllers are listened to but never disposed here.
  // - Controller replacement removes stale listeners before observing the new one.
  // - Release builds accept the same runtime values as debug builds.
  // - Reversed finite endpoints are sorted before value projection.
  // - Equal or non-finite endpoints restore the public zero-to-100 range.
  // - A non-positive division count deliberately selects continuous mode.
  // - A non-finite direct value yields to the observed controller value.
  // - A non-finite controller seed starts at zero instead of poisoning paint.
  // - Invalid square extents restore the public 168dp fallback.
  // - Invalid stroke widths restore the public 12dp fallback.
  // - Oversized strokes stop at the resolved radius so arcs never invert.
  // - Gesture, semantic, callback, animation, and painter math share bounds.
  // - The default arc preserves a clear inactive gap for endpoint perception.
  // - Thumb position is derived from the same animated progress as active paint.
  // - Disabled rendering keeps value geometry instead of resetting the dial.
  // - Autonomous timing is independent from row and panel transition clocks.
  // These are auditable project-calibrated behavior rules, not private Xiaomi
  // measurements or an assertion that every official app uses a rotary dial.

  /// Default square extent and arc thickness.
  static const double size = 168;
  static const double trackWidth = 12;

  /// Default 270-degree arc begins at 135 degrees.
  static const double startAngle = math.pi * .75;
  static const double sweepAngle = math.pi * 1.5;

  /// Resolves semantic colors for the current theme.
  static MiuixDialColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixDialColors(
      track: semantic['sliderBackground'],
      activeTrack: semantic['primary'],
      thumb: semantic['onPrimary'],
      foreground: semantic['onSurface'],
      disabled: semantic['disabledOnSurface'],
    );
  }
}

/// Rotary MIUIX value control suitable for volume, temperature, or intensity.
class MiuixDial extends StatefulWidget {
  /// Creates a dial.
  const MiuixDial({
    super.key,
    this.controller,
    this.value,
    this.initialValue = 0,
    this.minimum = 0,
    this.maximum = 100,
    this.divisions,
    this.size = MiuixDialDefaults.size,
    this.trackWidth = MiuixDialDefaults.trackWidth,
    this.enabled = true,
    this.colors,
    this.labelBuilder,
    this.semanticLabel,
    this.semanticValueFormatter,
    this.onChanged,
    this.onChangeEnd,
  });

  /// Optional package controller or direct controlled value.
  final MiuixDialController? controller;
  final double? value;

  /// Initial value used by the internally owned controller.
  final double initialValue;

  /// Inclusive numeric range and optional discrete divisions.
  final double minimum;
  final double maximum;
  final int? divisions;

  /// Visual geometry and enabled state.
  final double size;
  final double trackWidth;
  final bool enabled;

  /// Optional palette and center-label builder.
  final MiuixDialColors? colors;
  final Widget Function(BuildContext context, double value)? labelBuilder;

  /// Optional accessible name and value formatter for unit-bearing dials.
  ///
  /// The visible center label is excluded from the slider subtree to prevent
  /// Android from announcing the same numeric value twice.
  final String? semanticLabel;
  final String Function(double value)? semanticValueFormatter;

  /// Live and settled value callbacks.
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeEnd;

  @override
  State<MiuixDial> createState() => _MiuixDialState();
}

class _MiuixDialState extends State<MiuixDial> {
  MiuixDialController? _ownedController;
  int? _lastDivision;
  bool _dragging = false;

  /// Normalizes decoded or bridged bounds before any range arithmetic.
  (double, double) get _bounds {
    final first = widget.minimum;
    final second = widget.maximum;
    if (!first.isFinite || !second.isFinite || first == second) return (0, 100);
    return first < second ? (first, second) : (second, first);
  }

  double get _minimum => _bounds.$1;
  double get _maximum => _bounds.$2;

  /// Non-positive divisions mean continuous adjustment in every build mode.
  int? get _divisions => switch (widget.divisions) {
    final value? when value > 0 => value,
    _ => null,
  };

  /// Protects both layout constraints and pointer-center calculations.
  double get _size => widget.size.isFinite && widget.size > 0
      ? widget.size
      : MiuixDialDefaults.size;

  /// A stroke cannot be wider than the dial radius without inverting its arc.
  double get _trackWidth {
    final requested = widget.trackWidth;
    final resolved = requested.isFinite && requested > 0
        ? requested
        : MiuixDialDefaults.trackWidth;
    return math.min(resolved, _size / 2);
  }

  MiuixDialController get _controller =>
      widget.controller ??
      (_ownedController ??= MiuixDialController(value: widget.initialValue));

  double get _value {
    final direct = widget.value;
    final candidate = direct != null && direct.isFinite
        ? direct
        : _controller.value;
    return candidate.clamp(_minimum, _maximum);
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(MiuixDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller?.removeListener(_rebuild);
    widget.controller?.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  double _valueFromPosition(Offset position) {
    final center = Offset(_size / 2, _size / 2);
    var angle = math.atan2(position.dy - center.dy, position.dx - center.dx);
    if (angle < 0) angle += math.pi * 2;
    var relative = angle - MiuixDialDefaults.startAngle;
    if (relative < 0) relative += math.pi * 2;
    if (relative > MiuixDialDefaults.sweepAngle) {
      final distanceToEnd = relative - MiuixDialDefaults.sweepAngle;
      final distanceToStart = math.pi * 2 - relative;
      relative = distanceToEnd < distanceToStart
          ? MiuixDialDefaults.sweepAngle
          : 0;
    }
    var normalized = (relative / MiuixDialDefaults.sweepAngle).clamp(0.0, 1.0);
    final divisions = _divisions;
    if (divisions != null) {
      normalized = (normalized * divisions).round() / divisions;
    }
    return _minimum + normalized * (_maximum - _minimum);
  }

  void _update(Offset position) {
    if (!widget.enabled) return;
    final next = _valueFromPosition(position);
    if (next == _value) return;
    if (widget.value == null) _controller.value = next;
    widget.onChanged?.call(next);
    final divisions = _divisions;
    final division = divisions == null
        ? (next * 10).round()
        : ((next - _minimum) / (_maximum - _minimum) * divisions).round();
    if (division != _lastDivision) {
      _lastDivision = division;
      MiuixHaptics.perform(MiuixHapticType.textHandleMove);
    }
    setState(() {});
  }

  void _end() {
    _lastDivision = null;
    if (_dragging && widget.enabled) widget.onChangeEnd?.call(_value);
    if (_dragging) setState(() => _dragging = false);
  }

  void _adjust(double direction) {
    final divisions = _divisions;
    final step = divisions == null
        ? (_maximum - _minimum) / 20
        : (_maximum - _minimum) / divisions;
    final next = (_value + direction * step).clamp(_minimum, _maximum);
    if (next == _value) return;
    if (widget.value == null) _controller.value = next;
    widget.onChanged?.call(next);
    widget.onChangeEnd?.call(next);
    MiuixHaptics.perform(MiuixHapticType.textHandleMove);
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_rebuild);
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.colors ?? MiuixDialDefaults.colors(context);
    final normalized = (_value - _minimum) / (_maximum - _minimum);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final motion = MiuixTheme.of(context).hyperOs4.selectionControlMotion;
    final divisions = _divisions;
    final semanticsStep = divisions == null
        ? (_maximum - _minimum) / 20
        : (_maximum - _minimum) / divisions;
    String semanticValue(double value) =>
        widget.semanticValueFormatter?.call(value) ??
        value.toStringAsFixed(divisions == null ? 1 : 0);
    return Semantics(
      container: true,
      excludeSemantics: true,
      slider: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      value: semanticValue(_value),
      increasedValue: semanticValue(
        (_value + semanticsStep).clamp(_minimum, _maximum),
      ),
      decreasedValue: semanticValue(
        (_value - semanticsStep).clamp(_minimum, _maximum),
      ),
      onIncrease: widget.enabled ? () => _adjust(1) : null,
      onDecrease: widget.enabled ? () => _adjust(-1) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: widget.enabled
            ? (details) {
                if (!_dragging) setState(() => _dragging = true);
                _update(details.localPosition);
              }
            : null,
        onPanUpdate: widget.enabled
            ? (details) => _update(details.localPosition)
            : null,
        onPanEnd: widget.enabled ? (_) => _end() : null,
        onPanCancel: widget.enabled ? _end : null,
        child: SizedBox.square(
          dimension: _size,
          child: TweenAnimationBuilder<double>(
            key: ValueKey<bool>(reduceMotion),
            tween: Tween<double>(end: normalized),
            duration: reduceMotion || _dragging ? Duration.zero : motion,
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              final animatedValue =
                  _minimum + animatedProgress * (_maximum - _minimum);
              return CustomPaint(
                painter: _MiuixDialPainter(
                  progress: animatedProgress,
                  trackWidth: _trackWidth,
                  colors: palette,
                  enabled: widget.enabled,
                ),
                child: Center(
                  child:
                      widget.labelBuilder?.call(context, animatedValue) ??
                      Text(
                        animatedValue.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: widget.enabled
                                  ? palette.foreground
                                  : palette.disabled,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// Rotary painter contract:
// - Paint consumes a normalized sample already resolved by widget state.
// - The painter never quantizes, clamps callbacks, or owns animation time.
// - Base and active arcs use the same center, radius, width, and round caps.
// - Active sweep is the default sweep multiplied by visible progress.
// - Thumb angle derives from that identical visible-progress sample.
// - Track radius leaves one complete stroke width inside the square bounds.
// - Disabled colors preserve the same paths for stable spatial understanding.
// - A color or geometry change invalidates paint without rebuilding semantics.
// - The inactive gap remains transparent and never becomes a filled backing.
// - Painting introduces no rectangular surface or shadow outside the arc.
// - Device-pixel rasterization remains Flutter's responsibility at the edge.
// - Center-label layout is a child and cannot alter painter coordinates.
// - Progress changes repaint only this compact dial layer.
// - Repaint equality includes every visual input used by paint.
// - Semantics updates remain independent from raster scheduling.
// - Future material effects must retain the inactive arc gap.
class _MiuixDialPainter extends CustomPainter {
  const _MiuixDialPainter({
    required this.progress,
    required this.trackWidth,
    required this.colors,
    required this.enabled,
  });

  final double progress;
  final double trackWidth;
  final MiuixDialColors colors;
  final bool enabled;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2 - trackWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackWidth
      ..strokeCap = StrokeCap.round
      ..color = enabled ? colors.track : colors.disabled.withValues(alpha: .25);
    final activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackWidth
      ..strokeCap = StrokeCap.round
      ..color = enabled ? colors.activeTrack : colors.disabled;
    canvas.drawArc(
      rect,
      MiuixDialDefaults.startAngle,
      MiuixDialDefaults.sweepAngle,
      false,
      basePaint,
    );
    canvas.drawArc(
      rect,
      MiuixDialDefaults.startAngle,
      MiuixDialDefaults.sweepAngle * progress,
      false,
      activePaint,
    );
    final thumbAngle =
        MiuixDialDefaults.startAngle + MiuixDialDefaults.sweepAngle * progress;
    final thumb =
        center + Offset(math.cos(thumbAngle), math.sin(thumbAngle)) * radius;
    canvas.drawCircle(
      thumb,
      trackWidth * .38,
      Paint()..color = enabled ? colors.thumb : colors.disabled,
    );
  }

  @override
  bool shouldRepaint(_MiuixDialPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackWidth != trackWidth ||
      oldDelegate.colors != colors ||
      oldDelegate.enabled != enabled;
}
