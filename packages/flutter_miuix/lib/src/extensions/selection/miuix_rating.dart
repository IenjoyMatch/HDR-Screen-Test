import '../../icons/miuix_icon_theme.dart';
import 'package:flutter/material.dart';

import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';

/// Controlled numeric owner for [MiuixRating].
class MiuixRatingController extends ChangeNotifier {
  /// Creates a controller with an initial rating.
  MiuixRatingController({double value = 0})
    : _value = value.isFinite ? value : 0;

  double _value;

  /// Current unclamped rating; the widget clamps it to its own range.
  double get value => _value;

  /// Replaces the rating.
  set value(double next) {
    if (next == _value || !next.isFinite) return;
    _value = next;
    notifyListeners();
  }
}

/// Theme colors for [MiuixRating].
@immutable
class MiuixRatingColors {
  /// Creates a complete rating palette.
  const MiuixRatingColors({
    required this.active,
    required this.inactive,
    required this.disabled,
  });

  /// Filled, empty, and disabled icon roles.
  final Color active;
  final Color inactive;
  final Color disabled;
}

/// Geometry and palette defaults for ratings.
abstract final class MiuixRatingDefaults {
  // HyperOS 4 rating implementation contract:
  // - Rating is one logical slider, not five unrelated toggle buttons.
  // - The authored item count defines the inclusive semantic upper bound.
  // - Whole and half-step policies affect pointer and semantic adjustment.
  // - Pointer position is resolved in logical reading direction.
  // - RTL therefore fills each item from its logical start edge.
  // - Direct horizontal manipulation must remain owned by the control.
  // - Parent page swipes cannot replace an already accepted rating drag.
  // - Direct drag retargeting bypasses autonomous interpolation.
  // - Programmatic controller changes interpolate every affected item.
  // - Filled and unfilled geometry share the same star silhouette.
  // - Fractional fill is represented by clipping, not icon substitution.
  // - A custom item builder receives the continuously interpolated fraction.
  // - Disabled state preserves the value shape with a disabled color role.
  // - One haptic step is emitted only when the quantized value changes.
  // - Drag completion resets haptic coalescing for the next interaction.
  // - Semantic increase and decrease use the same quantized value path.
  // - Boundary semantic actions do not republish unchanged values.
  // - Caller-controlled values are never written into an internal owner.
  // - Caller-owned controllers are observed but never disposed by the widget.
  // - Controller replacement removes the previous listener synchronously.
  // - Runtime geometry remains equivalent in debug and compiled Release code.
  // - A non-positive item count restores the public five-item contract.
  // - A non-finite or non-positive item extent restores the 32dp contract.
  // - Negative or non-finite spacing restores the public four-dp gap.
  // - One resolved total width owns layout and logical pointer conversion.
  // - One resolved count owns item generation and semantic endpoint clamping.
  // - A non-finite direct value yields to the observed controller value.
  // - A non-finite controller seed starts at zero before widget clamping.
  // - Conflicting direct and controller forms retain direct-value precedence.
  // - Invalid direct values are the sole exception and cannot hide valid state.
  // - Internal controllers exist only for the uncontrolled compatibility form.
  // - Reduced motion replaces any in-flight fill with its logical endpoint.
  // - The motion token governs autonomous state, not direct pointer tracking.
  // - All item regions retain stable size throughout state interpolation.
  // These constraints are project rules derived from the design specification;
  // they do not claim an unpublished Xiaomi star size or motion constant.

  /// Default item count and visual size.
  static const int itemCount = 5;
  static const double itemSize = 32;
  static const double spacing = 4;

  /// Resolves MIUIX semantic roles.
  static MiuixRatingColors colors(BuildContext context) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixRatingColors(
      active: semantic['primary'],
      inactive: semantic['onSurfaceContainerVariant'],
      disabled: semantic['disabledOnSurface'],
    );
  }
}

/// Builds a custom rating item from a zero-to-one fill fraction.
typedef MiuixRatingItemBuilder =
    Widget Function(BuildContext context, int index, double fill);

/// Drag- and tap-adjustable MIUIX rating control.
class MiuixRating extends StatefulWidget {
  /// Creates a controlled or internally owned rating.
  const MiuixRating({
    super.key,
    this.controller,
    this.value,
    this.initialValue = 0,
    this.onChanged,
    this.itemCount = MiuixRatingDefaults.itemCount,
    this.itemSize = MiuixRatingDefaults.itemSize,
    this.spacing = MiuixRatingDefaults.spacing,
    this.allowHalf = false,
    this.enabled = true,
    this.colors,
    this.itemBuilder,
  });

  /// Optional package controller or direct controlled value.
  final MiuixRatingController? controller;
  final double? value;

  /// Initial value used only when neither controlled form is supplied.
  final double initialValue;

  /// Called after user interaction changes the rating.
  final ValueChanged<double>? onChanged;

  /// Item count, size, and gap.
  final int itemCount;
  final double itemSize;
  final double spacing;

  /// Whether half-step values can be selected.
  final bool allowHalf;

  /// Whether pointer and semantic adjustments are enabled.
  final bool enabled;

  /// Optional palette and item renderer.
  final MiuixRatingColors? colors;
  final MiuixRatingItemBuilder? itemBuilder;

  @override
  State<MiuixRating> createState() => _MiuixRatingState();
}

class _MiuixRatingState extends State<MiuixRating> {
  MiuixRatingController? _ownedController;
  int? _lastHapticStep;
  bool _directManipulation = false;

  /// Keeps dynamically decoded item geometry usable in Release builds.
  int get _itemCount =>
      widget.itemCount > 0 ? widget.itemCount : MiuixRatingDefaults.itemCount;

  double get _itemSize => widget.itemSize.isFinite && widget.itemSize > 0
      ? widget.itemSize
      : MiuixRatingDefaults.itemSize;

  double get _spacing => widget.spacing.isFinite && widget.spacing >= 0
      ? widget.spacing
      : MiuixRatingDefaults.spacing;

  /// One shared extent feeds gesture math, layout, and paint item placement.
  double get _totalWidth =>
      _itemCount * _itemSize + (_itemCount - 1) * _spacing;

  MiuixRatingController get _controller =>
      widget.controller ??
      (_ownedController ??= MiuixRatingController(value: widget.initialValue));

  double get _value {
    final direct = widget.value;
    final candidate = direct != null && direct.isFinite
        ? direct
        : _controller.value;
    return candidate.clamp(0, _itemCount.toDouble());
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) widget.controller!.addListener(_rebuild);
  }

  @override
  void didUpdateWidget(MiuixRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller?.removeListener(_rebuild);
    widget.controller?.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  void _updateFromPosition(double dx) {
    if (!widget.enabled) return;
    final width = _totalWidth;
    final visualX = Directionality.of(context) == TextDirection.ltr
        ? dx
        : width - dx;
    final raw = (visualX / width * _itemCount).clamp(
      0.0,
      _itemCount.toDouble(),
    );
    final value = widget.allowHalf ? (raw * 2).ceil() / 2 : raw.ceilToDouble();
    if (value == _value) return;
    if (widget.value == null) _controller.value = value;
    widget.onChanged?.call(value);
    final step = (value * (widget.allowHalf ? 2 : 1)).round();
    if (step != _lastHapticStep) {
      _lastHapticStep = step;
      MiuixHaptics.perform(MiuixHapticType.textHandleMove);
    }
    setState(() {});
  }

  void _adjust(double delta) {
    final step = widget.allowHalf ? .5 : 1.0;
    final next = (_value + delta * step).clamp(0.0, _itemCount.toDouble());
    if (next == _value) return;
    if (widget.value == null) _controller.value = next;
    widget.onChanged?.call(next);
    MiuixHaptics.perform(MiuixHapticType.textHandleMove);
    setState(() {});
  }

  void _beginDirectManipulation() {
    if (!widget.enabled) return;
    if (_directManipulation) return;
    setState(() => _directManipulation = true);
  }

  void _endDirectManipulation() {
    _lastHapticStep = null;
    if (!_directManipulation) return;
    setState(() => _directManipulation = false);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_rebuild);
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.colors ?? MiuixRatingDefaults.colors(context);
    final totalWidth = _totalWidth;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final motion = MiuixTheme.of(context).hyperOs4.selectionControlMotion;
    final textDirection = Directionality.of(context);
    return Semantics(
      slider: true,
      enabled: widget.enabled,
      value: _value.toString(),
      increasedValue: mathMin(_value + (widget.allowHalf ? .5 : 1)).toString(),
      decreasedValue: mathMax(_value - (widget.allowHalf ? .5 : 1)).toString(),
      onIncrease: widget.enabled ? () => _adjust(1) : null,
      onDecrease: widget.enabled ? () => _adjust(-1) : null,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: SizedBox(
          width: totalWidth,
          height: _itemSize,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: widget.enabled
                ? (details) {
                    _beginDirectManipulation();
                    _updateFromPosition(details.localPosition.dx);
                  }
                : null,
            onTapUp: widget.enabled ? (_) => _endDirectManipulation() : null,
            onTapCancel: widget.enabled ? _endDirectManipulation : null,
            onHorizontalDragStart: widget.enabled
                ? (details) {
                    _beginDirectManipulation();
                    _updateFromPosition(details.localPosition.dx);
                  }
                : null,
            onHorizontalDragUpdate: widget.enabled
                ? (details) => _updateFromPosition(details.localPosition.dx)
                : null,
            onHorizontalDragEnd: widget.enabled
                ? (_) => _endDirectManipulation()
                : null,
            onHorizontalDragCancel: widget.enabled
                ? _endDirectManipulation
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List<Widget>.generate(_itemCount, (index) {
                final fill = (_value - index).clamp(0.0, 1.0);
                return Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: index == _itemCount - 1 ? 0 : _spacing,
                  ),
                  child: SizedBox.square(
                    dimension: _itemSize,
                    child: TweenAnimationBuilder<double>(
                      // Direct drag uses a zero-duration retarget so fill stays
                      // under the pointer. Programmatic changes use the shared
                      // selection-control clock, while a policy-key change
                      // discards any sample left in flight.
                      key: ValueKey<(int, bool)>((index, reduceMotion)),
                      tween: Tween<double>(end: fill),
                      duration: reduceMotion || _directManipulation
                          ? Duration.zero
                          : motion,
                      curve: Curves.easeOutCubic,
                      builder: (context, animatedFill, _) {
                        final animatedCustom = widget.itemBuilder?.call(
                          context,
                          index,
                          animatedFill,
                        );
                        if (animatedCustom != null) return animatedCustom;
                        final inactiveColor = widget.enabled
                            ? palette.inactive
                            : palette.disabled;
                        final activeColor = widget.enabled
                            ? palette.active
                            : palette.disabled;
                        return Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            MiuixThemedIcon(
                              Icons.star_border_rounded,
                              size: _itemSize,
                              color: inactiveColor,
                            ),
                            ClipRect(
                              clipper: _MiuixRatingFillClipper(
                                fraction: animatedFill,
                                textDirection: textDirection,
                              ),
                              child: MiuixThemedIcon(
                                Icons.star_rounded,
                                size: _itemSize,
                                color: activeColor,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  double mathMin(double value) => value.clamp(0, _itemCount.toDouble());
  double mathMax(double value) => value.clamp(0, _itemCount.toDouble());
}

// Fractional-star rendering contract:
// - Clipping changes paint only and never changes the item's measured size.
// - Zero produces an empty active layer while the outline remains visible.
// - One exposes the complete active star without an overlapping replacement.
// - Intermediate values preserve the exact active glyph geometry.
// - LTR grows from the physical left and RTL grows from the physical right.
// - The fraction is clamped defensively before deriving physical pixels.
// - Repaint invalidation depends only on fraction and resolved direction.
// - The clip owns no gesture, semantics, compositing, or controller state.
// - Both layers remain centered on the same square item coordinate space.
// - No fractional icon asset or fabricated half-star geometry is required.
// - Caller-provided spacing remains outside the clipped square.
// - The inactive outline is never clipped away by the active fraction.
// - Theme color changes repaint both layers at the current visible fraction.
// - Text scaling cannot distort the explicitly sized rating glyph geometry.
// - Hit testing remains on the parent rating rectangle, not either paint layer.
// - The implementation therefore retains one continuous horizontal gesture.
// - Golden tests can inspect the deterministic physical clip rectangle.
// - Future icon changes must preserve this single-silhouette relationship.
class _MiuixRatingFillClipper extends CustomClipper<Rect> {
  const _MiuixRatingFillClipper({
    required this.fraction,
    required this.textDirection,
  });

  final double fraction;
  final TextDirection textDirection;

  @override
  Rect getClip(Size size) {
    final width = size.width * fraction.clamp(0.0, 1.0);
    return textDirection == TextDirection.ltr
        ? Rect.fromLTWH(0, 0, width, size.height)
        : Rect.fromLTWH(size.width - width, 0, width, size.height);
  }

  @override
  bool shouldReclip(_MiuixRatingFillClipper oldClipper) =>
      oldClipper.fraction != fraction ||
      oldClipper.textDirection != textDirection;
}
