import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../effects/miuix_effects.dart';
import '../../platform/miuix_haptics.dart';
import '../../theme/miuix_semantic_colors.dart';
import '../../theme/miuix_theme.dart';
import '../../widgets/miuix_widgets.dart';

/// Logical open states for a swipe-action row.
enum MiuixSwipeActionSide {
  /// The foreground fully covers both action panes.
  closed,

  /// Actions at the reading-direction start are visible.
  start,

  /// Actions at the reading-direction end are visible.
  end,
}

/// Programmatic owner for [MiuixSwipeAction].
class MiuixSwipeActionController extends ChangeNotifier {
  MiuixSwipeActionSide _side = MiuixSwipeActionSide.closed;

  /// Current requested logical side.
  MiuixSwipeActionSide get side => _side;

  /// Opens the start action pane.
  void openStart() => _setSide(MiuixSwipeActionSide.start);

  /// Opens the end action pane.
  void openEnd() => _setSide(MiuixSwipeActionSide.end);

  /// Closes all action panes.
  void close() => _setSide(MiuixSwipeActionSide.closed);

  void _setSide(MiuixSwipeActionSide value) {
    if (value == _side) return;
    _side = value;
    notifyListeners();
  }

  void _publishSettledSide(MiuixSwipeActionSide value) {
    _side = value;
  }
}

/// One equal-width action revealed behind a swipeable row.
@immutable
class MiuixSwipeActionItem {
  /// Creates a swipe action.
  const MiuixSwipeActionItem({
    required this.onPressed,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
    this.icon,
    this.label,
    this.closeOnPressed = true,
  });

  /// Callback invoked after the action is tapped.
  final VoidCallback onPressed;

  /// Action surface and content colors.
  final Color backgroundColor;
  final Color foregroundColor;

  /// Optional vertically arranged icon and label.
  final Widget? icon;
  final String? label;

  /// Whether the row closes after activation.
  final bool closeOnPressed;
}

/// Geometry and palette defaults for swipe rows.
abstract final class MiuixSwipeActionDefaults {
  // Runtime action-pane contract:
  // - Every action in one row retains exactly one equal resolved width.
  // - Invalid authored widths restore the public 76dp action extent.
  // - Open endpoints and direct-drag clamps use that identical extent.
  // - Threshold haptics compare against the same complete pane width.
  // - Dynamic action-list changes retarget the durable logical side.
  // - Empty visual content may still represent a colored application action.
  // - Empty content never changes callback, close, or enabled semantics.
  // - Debug and Release accept the same dynamically decoded geometry.

  /// Equal width reserved for every action.
  static const double actionExtent = 76;

  /// Outer continuous corner radius.
  static const double cornerRadius = 18;

  /// Fraction of a pane that commits on release.
  static const double settleThreshold = .5;

  /// Resolves the foreground surface.
  static Color background(BuildContext context) =>
      MiuixSemanticColors.of(context)['surfaceVariant'];
}

/// Horizontally revealable action row with spring-like MIUIX settling.
///
/// Reduced motion preserves direct horizontal drag and threshold haptics, but
/// controller changes, cancellation, and release settlement jump to endpoints.
class MiuixSwipeAction extends StatefulWidget {
  /// Creates a swipe-action row.
  const MiuixSwipeAction({
    super.key,
    required this.child,
    this.startActions = const <MiuixSwipeActionItem>[],
    this.endActions = const <MiuixSwipeActionItem>[],
    this.controller,
    this.backgroundColor,
    this.actionExtent = MiuixSwipeActionDefaults.actionExtent,
    this.cornerRadius = double.nan,
    this.enabled = true,
    this.onSideChanged,
  }) : _sourceShape = false;

  /// Creates the former fixed-18dp rounded-rectangle compatibility row.
  const MiuixSwipeAction.source({
    super.key,
    required this.child,
    this.startActions = const <MiuixSwipeActionItem>[],
    this.endActions = const <MiuixSwipeActionItem>[],
    this.controller,
    this.backgroundColor,
    this.actionExtent = MiuixSwipeActionDefaults.actionExtent,
    this.enabled = true,
    this.onSideChanged,
  }) : cornerRadius = MiuixSwipeActionDefaults.cornerRadius,
       _sourceShape = true;

  /// Foreground row content.
  final Widget child;

  /// Logical start and end actions.
  final List<MiuixSwipeActionItem> startActions;
  final List<MiuixSwipeActionItem> endActions;

  /// Optional externally owned state controller.
  final MiuixSwipeActionController? controller;

  /// Foreground surface and geometry.
  final Color? backgroundColor;
  final double actionExtent;
  final double cornerRadius;
  final bool _sourceShape;

  /// Whether horizontal dragging is active.
  final bool enabled;

  /// Called after an open or close animation settles.
  final ValueChanged<MiuixSwipeActionSide>? onSideChanged;

  @override
  State<MiuixSwipeAction> createState() => _MiuixSwipeActionState();
}

class _MiuixSwipeActionState extends State<MiuixSwipeAction>
    with SingleTickerProviderStateMixin {
  late MiuixSwipeActionController _controller;
  late bool _ownsController;
  late final AnimationController _animation;
  double _logicalOffset = 0;
  double _animationStart = 0;
  double _animationTarget = 0;
  bool _thresholdHapticSent = false;
  bool _reduceMotion = false;
  int _motionGeneration = 0;

  /// One finite positive width owns endpoint, hit pane, and action layout math.
  double get _actionExtent =>
      widget.actionExtent.isFinite && widget.actionExtent > 0
      ? widget.actionExtent
      : MiuixSwipeActionDefaults.actionExtent;

  double get _startExtent => widget.startActions.length * _actionExtent;
  double get _endExtent => widget.endActions.length * _actionExtent;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(vsync: this, duration: Duration.zero)
      ..addListener(_tickAnimation);
    _attachController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animation.duration = MiuixTheme.of(context).hyperOs4.swipeActionMotion;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion == _reduceMotion) return;
    _reduceMotion = reduceMotion;
    if (!_reduceMotion || !_animation.isAnimating) return;

    _animation.stop();
    final generation = ++_motionGeneration;
    final target = _animationTarget;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_reduceMotion || generation != _motionGeneration) {
        return;
      }
      _settleAt(target);
    });
  }

  void _attachController() {
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? MiuixSwipeActionController();
    _controller.addListener(_handleControllerChanged);
  }

  @override
  void didUpdateWidget(MiuixSwipeAction oldWidget) {
    // Dynamic row update contract:
    // - Logical side belongs to the controller; pixels belong to this layout.
    // - Action-count changes therefore require recalculating the open endpoint.
    // - Action-width changes retarget the same side to its new complete extent.
    // - Removing every action on an open side normalizes that side to closed.
    // - Controller replacement first detaches the former ownership listener.
    // - Caller-owned controllers are never disposed by the swipe row.
    // - Internally owned controllers are disposed before their replacement.
    // - A post-frame retarget avoids changing animation state during build.
    // - Each retarget receives a generation that invalidates older callbacks.
    // - Disabling is a complete interaction transition, not drag-only policy.
    // - A disabled row closes any partially dragged or fully opened pane.
    // - Revealed action surfaces also lose callbacks while the row is disabled.
    // - Re-enabling leaves the durable closed state until explicitly reopened.
    // - Theme-only rebuilds preserve motion and do not restart settlement.
    // - Pointer settlement and programmatic settlement share endpoint mapping.
    // - Reduced-motion policy still snaps through the same logical target.
    // - Directionality changes remain a paint transform of logical displacement.
    // - No example-only coordination is required for dynamic list updates.
    // - Future geometry inputs must participate in this same retarget condition.
    super.didUpdateWidget(oldWidget);
    final controllerChanged = oldWidget.controller != widget.controller;
    final geometryChanged =
        oldWidget.actionExtent != widget.actionExtent ||
        oldWidget.startActions.length != widget.startActions.length ||
        oldWidget.endActions.length != widget.endActions.length;
    final disabled = oldWidget.enabled && !widget.enabled;
    if (controllerChanged) {
      _controller.removeListener(_handleControllerChanged);
      if (_ownsController) _controller.dispose();
      _attachController();
    }
    if (controllerChanged || geometryChanged || disabled) {
      final generation = ++_motionGeneration;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || generation != _motionGeneration) return;
        if (!widget.enabled) {
          _controller.close();
          _animateTo(0);
        } else {
          _handleControllerChanged();
        }
      });
    }
  }

  void _handleControllerChanged() {
    final target = switch (_controller.side) {
      MiuixSwipeActionSide.closed => 0.0,
      MiuixSwipeActionSide.start => _startExtent > 0 ? _startExtent : 0.0,
      MiuixSwipeActionSide.end => _endExtent > 0 ? -_endExtent : 0.0,
    };
    _animateTo(target);
  }

  void _tickAnimation() {
    final eased = Curves.easeOutCubic.transform(_animation.value);
    setState(() {
      _logicalOffset =
          _animationStart + (_animationTarget - _animationStart) * eased;
    });
  }

  Future<void> _animateTo(double target) async {
    final generation = ++_motionGeneration;
    _animation.stop();
    _animationStart = _logicalOffset;
    _animationTarget = target;
    if (_reduceMotion) {
      _settleAt(target);
      return;
    }
    try {
      await _animation.forward(from: 0).orCancel;
    } on TickerCanceled {
      return;
    }
    if (!mounted || generation != _motionGeneration) return;
    _settleAt(target);
  }

  /// Publishes one durable side after either an animation or a direct snap.
  void _settleAt(double target) {
    if (!mounted) return;
    if ((_logicalOffset - target).abs() > 1e-9) {
      setState(() => _logicalOffset = target);
    }
    final side = target > 0
        ? MiuixSwipeActionSide.start
        : target < 0
        ? MiuixSwipeActionSide.end
        : MiuixSwipeActionSide.closed;
    _controller._publishSettledSide(side);
    widget.onSideChanged?.call(side);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!widget.enabled) return;
    _motionGeneration++;
    _animation.stop();
    final direction = Directionality.of(context) == TextDirection.ltr
        ? 1.0
        : -1.0;
    final delta = details.delta.dx * direction;
    setState(() {
      _logicalOffset = (_logicalOffset + delta).clamp(
        -_endExtent,
        _startExtent,
      );
    });
    final relevantExtent = _logicalOffset >= 0 ? _startExtent : _endExtent;
    final crossed =
        relevantExtent > 0 &&
        _logicalOffset.abs() >=
            relevantExtent * MiuixSwipeActionDefaults.settleThreshold;
    if (crossed && !_thresholdHapticSent) {
      _thresholdHapticSent = true;
      MiuixHaptics.perform(MiuixHapticType.gestureThresholdActivate);
    } else if (!crossed) {
      _thresholdHapticSent = false;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!widget.enabled) return;
    final direction = Directionality.of(context) == TextDirection.ltr
        ? 1.0
        : -1.0;
    final velocity = (details.primaryVelocity ?? 0) * direction;
    final target = velocity > 500 && _startExtent > 0
        ? _startExtent
        : velocity < -500 && _endExtent > 0
        ? -_endExtent
        : _logicalOffset >
              _startExtent * MiuixSwipeActionDefaults.settleThreshold
        ? _startExtent
        : _logicalOffset <
              -_endExtent * MiuixSwipeActionDefaults.settleThreshold
        ? -_endExtent
        : 0.0;
    _thresholdHapticSent = false;
    _animateTo(target);
  }

  Widget _buildAction(MiuixSwipeActionItem action) {
    return SizedBox(
      width: _actionExtent,
      child: MiuixSurface(
        color: action.backgroundColor,
        contentColor: action.foregroundColor,
        onTap: widget.enabled
            ? () {
                action.onPressed();
                MiuixHaptics.perform(MiuixHapticType.confirm);
                if (action.closeOnPressed) _controller.close();
              }
            : null,
        enabled: widget.enabled,
        feedbackType: MiuixPressFeedbackType.sink,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (action.icon != null) action.icon!,
              if (action.icon != null && action.label != null)
                const SizedBox(height: 3),
              if (action.label != null)
                Text(
                  action.label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: action.foregroundColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _motionGeneration++;
    _controller.removeListener(_handleControllerChanged);
    if (_ownsController) _controller.dispose();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context) == TextDirection.ltr
        ? 1.0
        : -1.0;
    final background =
        widget.backgroundColor ?? MiuixSwipeActionDefaults.background(context);
    final miuixTheme = MiuixTheme.of(context);
    final radius = widget.cornerRadius.isFinite
        ? widget.cornerRadius.clamp(0.0, double.infinity).toDouble()
        : miuixTheme.hyperOs4.collectionRowCornerRadius;
    final borderRadius = BorderRadius.circular(radius);
    final shape = !widget._sourceShape && miuixTheme.enableSquircle
        ? MiuixSquircleBorder(borderRadius: borderRadius)
        : RoundedRectangleBorder(borderRadius: borderRadius);
    return ClipPath(
      key: const ValueKey('miuix-swipe-action-clip'),
      clipper: ShapeBorderClipper(shape: shape),
      child: Stack(
        children: <Widget>[
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.startActions.map(_buildAction).toList(),
            ),
          ),
          PositionedDirectional(
            end: 0,
            top: 0,
            bottom: 0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: widget.endActions.reversed.map(_buildAction).toList(),
            ),
          ),
          Transform.translate(
            key: const ValueKey('miuix-swipe-action-foreground'),
            offset: Offset(_logicalOffset * direction, 0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Retain the displacement accumulated while the nested gesture
              // arena crosses touch slop. Otherwise a row inside PageView wins
              // correctly but starts roughly one slop-width behind the finger.
              dragStartBehavior: DragStartBehavior.down,
              onHorizontalDragUpdate: widget.enabled ? _handleDragUpdate : null,
              onHorizontalDragEnd: widget.enabled ? _handleDragEnd : null,
              onHorizontalDragCancel: widget.enabled
                  ? () => _animateTo(0)
                  : null,
              child: MiuixSurface(
                key: const ValueKey('miuix-swipe-action-foreground-surface'),
                shape: shape,
                radius: radius,
                color: background,
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
