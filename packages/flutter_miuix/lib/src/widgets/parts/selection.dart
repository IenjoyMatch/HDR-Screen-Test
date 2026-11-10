part of '../miuix_widgets.dart';

/// Exact position spring from MIUIX `Switch.kt`.
@visibleForTesting
SpringDescription debugMiuixSwitchThumbOffsetSpring() =>
    SpringDescription.withDampingRatio(mass: 1, stiffness: 987, ratio: .7);

/// Exact press/drag/hover scale spring from MIUIX `Switch.kt`.
@visibleForTesting
SpringDescription debugMiuixSwitchThumbScaleSpring() =>
    SpringDescription.withDampingRatio(mass: 1, stiffness: 987, ratio: .6);

/// Exact checked-track color spring from MIUIX `Switch.kt`.
@visibleForTesting
SpringDescription debugMiuixSwitchTrackColorSpring() =>
    SpringDescription.withDampingRatio(mass: 1, stiffness: 438.6, ratio: .99);

/// Compose's default spring used by the switch thumb color.
@visibleForTesting
SpringDescription debugMiuixSwitchThumbColorSpring() =>
    SpringDescription.withDampingRatio(mass: 1, stiffness: 1500, ratio: 1);

/// Returns the toggle roles emitted by the source switch drag state machine.
///
/// This test hook uses the same tracker as [MiuixSwitch], so endpoint returns
/// and the one-dp release dead band remain independently verifiable.
@visibleForTesting
List<bool> debugMiuixSwitchDragFeedbackValues({
  required bool checked,
  required Iterable<double> offsets,
  double? stoppedOffset,
}) {
  final tracker = _MiuixSwitchDragHapticTracker(checked);
  final feedback = <bool>[];
  for (final offset in offsets) {
    final value = tracker.update(offset);
    if (value != null) feedback.add(value);
  }
  if (stoppedOffset != null) {
    final value = tracker.release(stoppedOffset);
    if (value != null) feedback.add(value);
  }
  return feedback;
}

class _MiuixSwitchDragHapticTracker {
  _MiuixSwitchDragHapticTracker(this.checked);

  final bool checked;
  bool _hasVibrated = true;
  bool _hasVibratedOnce = false;

  bool? update(double offset) {
    final crossedMiddleReset =
        (offset >= -11 && offset <= -10) || (offset >= 10 && offset <= 11);
    final travelling =
        (offset >= -20 && offset <= -1) || (offset >= 1 && offset <= 20);

    // These ranges overlap at 10/11 dp. Preserve the source branch order:
    // midpoint crossing rearms release feedback, ordinary travel rearms the
    // two physical endpoints.
    if (crossedMiddleReset) {
      _hasVibratedOnce = false;
    } else if (travelling) {
      _hasVibrated = false;
    } else if (!_hasVibrated) {
      final reachedOffEndpoint =
          (checked && offset == -21) || (!checked && offset == 0);
      final reachedOnEndpoint =
          (checked && offset == 0) || (!checked && offset == 21);
      if (reachedOffEndpoint || reachedOnEndpoint) {
        _hasVibrated = true;
        _hasVibratedOnce = true;
        return reachedOnEndpoint;
      }
    }
    return null;
  }

  bool? release(double offset) {
    if (_hasVibratedOnce || offset.abs() < 1) {
      return null;
    }
    if (checked) {
      if (offset <= -11) return false;
      if (offset >= -10) return true;
    } else {
      if (offset <= 10) return false;
      if (offset >= 11) return true;
    }
    return null;
  }
}

/// Immutable eight-channel source switch colors.
@immutable
class MiuixSwitchColors {
  const MiuixSwitchColors({
    required this.checkedThumbColor,
    required this.uncheckedThumbColor,
    required this.disabledCheckedThumbColor,
    required this.disabledUncheckedThumbColor,
    required this.checkedTrackColor,
    required this.uncheckedTrackColor,
    required this.disabledCheckedTrackColor,
    required this.disabledUncheckedTrackColor,
  });

  final Color checkedThumbColor;
  final Color uncheckedThumbColor;
  final Color disabledCheckedThumbColor;
  final Color disabledUncheckedThumbColor;
  final Color checkedTrackColor;
  final Color uncheckedTrackColor;
  final Color disabledCheckedTrackColor;
  final Color disabledUncheckedTrackColor;

  Color thumb({required bool checked, required bool enabled}) {
    if (checked) {
      return enabled ? checkedThumbColor : disabledCheckedThumbColor;
    }
    return enabled ? uncheckedThumbColor : disabledUncheckedThumbColor;
  }

  Color track({required bool checked, required bool enabled}) {
    if (checked) {
      return enabled ? checkedTrackColor : disabledCheckedTrackColor;
    }
    return enabled ? uncheckedTrackColor : disabledUncheckedTrackColor;
  }

  MiuixSwitchColors copyWith({
    Color? checkedThumbColor,
    Color? uncheckedThumbColor,
    Color? disabledCheckedThumbColor,
    Color? disabledUncheckedThumbColor,
    Color? checkedTrackColor,
    Color? uncheckedTrackColor,
    Color? disabledCheckedTrackColor,
    Color? disabledUncheckedTrackColor,
  }) {
    return MiuixSwitchColors(
      checkedThumbColor: checkedThumbColor ?? this.checkedThumbColor,
      uncheckedThumbColor: uncheckedThumbColor ?? this.uncheckedThumbColor,
      disabledCheckedThumbColor:
          disabledCheckedThumbColor ?? this.disabledCheckedThumbColor,
      disabledUncheckedThumbColor:
          disabledUncheckedThumbColor ?? this.disabledUncheckedThumbColor,
      checkedTrackColor: checkedTrackColor ?? this.checkedTrackColor,
      uncheckedTrackColor: uncheckedTrackColor ?? this.uncheckedTrackColor,
      disabledCheckedTrackColor:
          disabledCheckedTrackColor ?? this.disabledCheckedTrackColor,
      disabledUncheckedTrackColor:
          disabledUncheckedTrackColor ?? this.disabledUncheckedTrackColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixSwitchColors &&
          checkedThumbColor == other.checkedThumbColor &&
          uncheckedThumbColor == other.uncheckedThumbColor &&
          disabledCheckedThumbColor == other.disabledCheckedThumbColor &&
          disabledUncheckedThumbColor == other.disabledUncheckedThumbColor &&
          checkedTrackColor == other.checkedTrackColor &&
          uncheckedTrackColor == other.uncheckedTrackColor &&
          disabledCheckedTrackColor == other.disabledCheckedTrackColor &&
          disabledUncheckedTrackColor == other.disabledUncheckedTrackColor;

  @override
  int get hashCode => Object.hash(
    checkedThumbColor,
    uncheckedThumbColor,
    disabledCheckedThumbColor,
    disabledUncheckedThumbColor,
    checkedTrackColor,
    uncheckedTrackColor,
    disabledCheckedTrackColor,
    disabledUncheckedTrackColor,
  );
}

/// Source `SwitchDefaults`, including dynamic-color-specific thumb roles.
abstract final class MiuixSwitchDefaults {
  static const double width = 49;
  static const double height = 28;
  static const double thumbSize = 20;
  static const double touchTargetHeight = 48;
  static const double uncheckedThumbOffset = 4;
  static const double checkedThumbOffset = 25;
  static const double dragDistance = 21;

  static MiuixSwitchColors switchColors(
    BuildContext context, {
    Color? checkedThumbColor,
    Color? uncheckedThumbColor,
    Color? disabledCheckedThumbColor,
    Color? disabledUncheckedThumbColor,
    Color? checkedTrackColor,
    Color? uncheckedTrackColor,
    Color? disabledCheckedTrackColor,
    Color? disabledUncheckedTrackColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    final dynamic = switch (MiuixTheme.of(context).mode) {
      MiuixColorMode.monetSystem ||
      MiuixColorMode.monetLight ||
      MiuixColorMode.monetDark => true,
      _ => false,
    };
    return MiuixSwitchColors(
      checkedThumbColor: checkedThumbColor ?? semantic['onPrimary'],
      uncheckedThumbColor:
          uncheckedThumbColor ??
          (dynamic
              ? semantic['onSurface'].withValues(alpha: .38)
              : semantic['onSecondary']),
      disabledCheckedThumbColor:
          disabledCheckedThumbColor ??
          (dynamic ? semantic['surface'] : semantic['disabledOnPrimary']),
      disabledUncheckedThumbColor:
          disabledUncheckedThumbColor ?? semantic['disabledOnSecondary'],
      checkedTrackColor: checkedTrackColor ?? semantic['primary'],
      uncheckedTrackColor: uncheckedTrackColor ?? semantic['secondary'],
      disabledCheckedTrackColor:
          disabledCheckedTrackColor ?? semantic['disabledPrimary'],
      disabledUncheckedTrackColor:
          disabledUncheckedTrackColor ?? semantic['disabledSecondary'],
    );
  }
}

/// Horizontal drag recognizer that gives an enabled compact control ownership
/// before an ancestor pager can accept the same pointer sequence.
///
/// Flutter's stock child and parent horizontal recognizers use the same touch
/// slop. A `PageView` can therefore win the arena before a compact MIUIX
/// control, turning a slider drag into a page change. Android may also batch
/// enough motion into one frame for both recognizers to cross their ordinary
/// thresholds together.
///
/// Resolve a clearly horizontal sequence as soon as its direction is known,
/// and reject a clearly vertical sequence just as early. This preserves the
/// source draggable modifier's no-op tap, gives coarse and fine horizontal
/// streams to the compact control, and leaves vertical list scrolling to the
/// ancestor.
class _MiuixPriorityHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer {
  final Map<int, Offset> _pointerOrigins = <int, Offset>{};
  bool _hasQualifiedMotion = false;
  DragStartDetails? _deferredStartDetails;
  bool _qualifiedStartDelivered = false;
  // Flutter 会把已接受的 PointerCancel 送进 onEnd，保留分发原因供调用方区分。
  bool isDispatchingPointerCancel = false;

  /// Optional local-space gate for controls with a smaller active thumb.
  bool Function(Offset localPosition)? isStartAllowed;

  bool get hasQualifiedMotion => _hasQualifiedMotion;

  @override
  bool isPointerAllowed(PointerEvent event) {
    return (isStartAllowed?.call(event.localPosition) ?? true) &&
        super.isPointerAllowed(event);
  }

  void routeStart(
    DragStartDetails details,
    GestureDragStartCallback? callback,
  ) {
    _deferredStartDetails = details;
    if (_hasQualifiedMotion && !_qualifiedStartDelivered) {
      _qualifiedStartDelivered = true;
      callback?.call(details);
    }
  }

  void deliverDeferredStart(GestureDragStartCallback? callback) {
    if (!_hasQualifiedMotion || _qualifiedStartDelivered) return;
    final details = _deferredStartDetails;
    if (details == null) return;
    _qualifiedStartDelivered = true;
    callback?.call(details);
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _pointerOrigins[event.pointer] = event.position;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event case PointerMoveEvent()) {
      final origin = _pointerOrigins[event.pointer];
      // 方向只在开始时判定；横拖已接受后，回到起点附近的纵向抖动不能撤销它。
      // 保留整段指针流的所有权，直到 UP/CANCEL，再允许下一段选择方向。
      if (origin != null && !_hasQualifiedMotion) {
        final displacement = event.position - origin;
        final horizontal = displacement.dx.abs();
        final vertical = displacement.dy.abs();
        final sourceSlop = computeHitSlop(event.kind, gestureSettings);
        // A small intent threshold gets ahead of a surrounding pager without
        // claiming ordinary sub-pixel pointer noise.
        final intentSlop = math.max(1.0, sourceSlop * .15);
        if (horizontal > intentSlop && horizontal > vertical * 1.15) {
          _hasQualifiedMotion = true;
          resolve(GestureDisposition.accepted);
        } else if (vertical > intentSlop && vertical > horizontal * 1.15) {
          _hasQualifiedMotion = false;
          resolve(GestureDisposition.rejected);
          _pointerOrigins.remove(event.pointer);
          // Resolving rejection returns the base recognizer to its ready
          // state, so this event must not be handed back to monodrag.
          return;
        }
      }
    }
    isDispatchingPointerCancel = event is PointerCancelEvent;
    try {
      super.handleEvent(event);
    } finally {
      // 只在本次分发期间标记，下一条指针事件不能继承取消原因。
      isDispatchingPointerCancel = false;
    }
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointerOrigins.remove(event.pointer);
      if (_pointerOrigins.isEmpty) {
        _hasQualifiedMotion = false;
        _deferredStartDetails = null;
        _qualifiedStartDelivered = false;
      }
    }
  }

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    final sourceSlop = computeHitSlop(pointerDeviceKind, gestureSettings);
    final qualified = globalDistanceMoved.abs() > sourceSlop * .5;
    if (qualified) {
      _hasQualifiedMotion = true;
    }
    return qualified;
  }
}

/// Vertical counterpart that lets an enabled `VerticalSlider` own a clearly
/// vertical gesture before its ancestor scrollable accepts the same stream.
///
/// The source Compose `draggable(Orientation.Vertical)` consumes the drag on
/// the compact control. Stock Flutter child and parent vertical recognizers
/// cross the same slop together, allowing the surrounding list to win on a
/// real Android device. Directional early acceptance restores source
/// ownership while early horizontal rejection leaves a root pager available.
class _MiuixPriorityVerticalDragGestureRecognizer
    extends VerticalDragGestureRecognizer {
  final Map<int, Offset> _pointerOrigins = <int, Offset>{};
  bool _hasQualifiedMotion = false;
  DragStartDetails? _deferredStartDetails;
  bool _qualifiedStartDelivered = false;

  /// Optional local-space gate for controls with a smaller active thumb.
  bool Function(Offset localPosition)? isStartAllowed;

  bool get hasQualifiedMotion => _hasQualifiedMotion;

  @override
  bool isPointerAllowed(PointerEvent event) {
    return (isStartAllowed?.call(event.localPosition) ?? true) &&
        super.isPointerAllowed(event);
  }

  void routeStart(
    DragStartDetails details,
    GestureDragStartCallback? callback,
  ) {
    _deferredStartDetails = details;
    if (_hasQualifiedMotion && !_qualifiedStartDelivered) {
      _qualifiedStartDelivered = true;
      callback?.call(details);
    }
  }

  void deliverDeferredStart(GestureDragStartCallback? callback) {
    if (!_hasQualifiedMotion || _qualifiedStartDelivered) return;
    final details = _deferredStartDetails;
    if (details == null) return;
    _qualifiedStartDelivered = true;
    callback?.call(details);
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _pointerOrigins[event.pointer] = event.position;
    super.addAllowedPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event case PointerMoveEvent()) {
      final origin = _pointerOrigins[event.pointer];
      if (origin != null) {
        final displacement = event.position - origin;
        final horizontal = displacement.dx.abs();
        final vertical = displacement.dy.abs();
        final sourceSlop = computeHitSlop(event.kind, gestureSettings);
        final intentSlop = math.max(1.0, sourceSlop * .15);
        if (vertical > intentSlop && vertical > horizontal * 1.15) {
          _hasQualifiedMotion = true;
          resolve(GestureDisposition.accepted);
        } else if (horizontal > intentSlop && horizontal > vertical * 1.15) {
          _hasQualifiedMotion = false;
          resolve(GestureDisposition.rejected);
          _pointerOrigins.remove(event.pointer);
          return;
        }
      }
    }
    super.handleEvent(event);
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _pointerOrigins.remove(event.pointer);
      if (_pointerOrigins.isEmpty) {
        _hasQualifiedMotion = false;
        _deferredStartDetails = null;
        _qualifiedStartDelivered = false;
      }
    }
  }

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    final sourceSlop = computeHitSlop(pointerDeviceKind, gestureSettings);
    final qualified = globalDistanceMoved.abs() > sourceSlop * .5;
    if (qualified) {
      _hasQualifiedMotion = true;
    }
    return qualified;
  }
}

/// Installs the priority recognizer shared by horizontal MIUIX controls that
/// may be embedded in an application pager.
Widget _miuixPriorityHorizontalDrag({
  required Widget child,
  GestureDragStartCallback? onStart,
  GestureDragUpdateCallback? onUpdate,
  GestureDragEndCallback? onEnd,
  GestureDragCancelCallback? onCancel,
  bool Function(Offset localPosition)? isStartAllowed,
  bool excludeFromSemantics = false,
  // 默认保留其他控件既有的结束协议，开关明确选择取消时不提交。
  bool cancelOnPointerCancel = false,
}) {
  if (onStart == null &&
      onUpdate == null &&
      onEnd == null &&
      onCancel == null) {
    return child;
  }
  return RawGestureDetector(
    behavior: HitTestBehavior.opaque,
    excludeFromSemantics: excludeFromSemantics,
    gestures: {
      _MiuixPriorityHorizontalDragGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<
            _MiuixPriorityHorizontalDragGestureRecognizer
          >(_MiuixPriorityHorizontalDragGestureRecognizer.new, (recognizer) {
            recognizer
              // Compose draggable reports the original down position to
              // onDragStarted, then forwards the accumulated slop delta.
              ..dragStartBehavior = DragStartBehavior.down
              ..isStartAllowed = isStartAllowed
              // Flutter's arena sweep may accept the first recognizer on a
              // stationary pointer-up. Gate callbacks on actual qualified
              // horizontal motion while retaining the early intent threshold
              // that lets a compact control beat its ancestor PageView.
              ..onStart = ((details) => recognizer.routeStart(details, onStart))
              ..onUpdate = onUpdate == null
                  ? null
                  : (details) {
                      if (recognizer.hasQualifiedMotion) {
                        recognizer.deliverDeferredStart(onStart);
                        onUpdate(details);
                      }
                    }
              ..onEnd = onEnd == null
                  ? null
                  : (details) {
                      if (recognizer.hasQualifiedMotion) {
                        recognizer.deliverDeferredStart(onStart);
                        if (cancelOnPointerCancel &&
                            recognizer.isDispatchingPointerCancel) {
                          onCancel?.call();
                        } else {
                          onEnd(details);
                        }
                      }
                    }
              ..onCancel = onCancel == null
                  ? null
                  : () {
                      if (recognizer.hasQualifiedMotion) onCancel();
                    };
          }),
    },
    child: child,
  );
}

/// Vertical counterpart used by `VerticalSlider`.
///
/// It gives the compact control ownership ahead of a same-axis list while,
/// like Compose draggable, never turning a stationary tap into a drag start.
Widget _miuixVerticalDrag({
  required Widget child,
  GestureDragStartCallback? onStart,
  GestureDragUpdateCallback? onUpdate,
  GestureDragEndCallback? onEnd,
  GestureDragCancelCallback? onCancel,
  bool Function(Offset localPosition)? isStartAllowed,
  bool excludeFromSemantics = false,
}) {
  if (onStart == null &&
      onUpdate == null &&
      onEnd == null &&
      onCancel == null) {
    return child;
  }
  return RawGestureDetector(
    behavior: HitTestBehavior.opaque,
    excludeFromSemantics: excludeFromSemantics,
    gestures: {
      _MiuixPriorityVerticalDragGestureRecognizer:
          GestureRecognizerFactoryWithHandlers<
            _MiuixPriorityVerticalDragGestureRecognizer
          >(_MiuixPriorityVerticalDragGestureRecognizer.new, (recognizer) {
            recognizer
              ..dragStartBehavior = DragStartBehavior.down
              ..isStartAllowed = isStartAllowed
              ..onStart = ((details) => recognizer.routeStart(details, onStart))
              ..onUpdate = onUpdate == null
                  ? null
                  : (details) {
                      if (recognizer.hasQualifiedMotion) {
                        recognizer.deliverDeferredStart(onStart);
                        onUpdate(details);
                      }
                    }
              ..onEnd = onEnd == null
                  ? null
                  : (details) {
                      if (recognizer.hasQualifiedMotion) {
                        recognizer.deliverDeferredStart(onStart);
                        onEnd(details);
                      }
                    }
              ..onCancel = onCancel == null
                  ? null
                  : () {
                      if (recognizer.hasQualifiedMotion) onCancel();
                    };
          }),
    },
    child: child,
  );
}

/// Expands a slider's cross-axis interaction and child semantics to the
/// platform 48dp target without changing the authored track dimensions.
///
/// Compose keeps the Slider layout at 28dp (25dp in the source vertical
/// sample), then exposes a separately expanded minimum touch target. The
/// reciprocal inner transform leaves painting at its source size while the
/// outer transform enlarges only hit testing and the nested semantics node.
Widget _miuixSliderCrossAxisTarget({
  required Widget child,
  required Widget Function(Widget visual) interactionBuilder,
  required Widget Function(Widget target) semanticsBuilder,
  required double visualExtent,
  required double targetExtent,
  required bool vertical,
}) {
  final safeVisual = _finiteOr(
    visualExtent,
    28,
  ).clamp(.000001, double.infinity);
  final safeTarget = _finiteOr(
    targetExtent,
    48,
  ).clamp(safeVisual, double.infinity);
  final outerScale = safeTarget / safeVisual;
  final innerScale = safeVisual / safeTarget;
  final visual = Transform.scale(
    scaleX: vertical ? innerScale : 1,
    scaleY: vertical ? 1 : innerScale,
    child: child,
  );
  final semantics = Transform.scale(
    scaleX: vertical ? innerScale : 1,
    scaleY: vertical ? 1 : innerScale,
    child: semanticsBuilder(
      Transform.scale(
        scaleX: vertical ? outerScale : 1,
        scaleY: vertical ? 1 : outerScale,
        child: Semantics(
          key: const ValueKey('miuix-slider-touch-target'),
          container: true,
          explicitChildNodes: true,
          enabled: true,
          focusable: false,
          accessibilityFocusBlockType: AccessibilityFocusBlockType.blockNode,
          child: const SizedBox.expand(),
        ),
      ),
    ),
  );
  // The caller places its expanded transform outside every LayoutBuilder or
  // SizedBox. This subtree is therefore reached for pointers in the full 48dp
  // band; an intermediate layout render box would otherwise reject them before
  // its transformed child could participate in hit testing.
  return interactionBuilder(
    Stack(
      clipBehavior: Clip.none,
      fit: StackFit.passthrough,
      children: [
        visual,
        // Keep platform semantics independent from Flutter's hit-test
        // workaround: the reciprocal branch restores the outer Slider node to
        // 28/25dp, then its nested target expands back to 48dp.
        Positioned.fill(child: semantics),
      ],
    ),
  );
}

double _miuixSliderSemanticDelta(
  ({double min, double max}) range,
  int? divisions,
) {
  final span = range.max - range.min;
  final segments = _safeDivisions(divisions) ?? 20;
  return span / segments;
}

double _miuixSliderSemanticValue({
  required double value,
  required ({double min, double max}) range,
  required int? divisions,
  required bool increase,
  required List<double> keyPoints,
  required double magnetThreshold,
}) {
  final delta = _miuixSliderSemanticDelta(range, divisions);
  final target = value + (increase ? delta : -delta);
  final fraction = _fractionForValue(target, range);
  return _valueForFraction(
    fraction,
    range,
    divisions,
    keyPoints: keyPoints,
    magnetThreshold: magnetThreshold,
  );
}

/// Miuix switch wrapper.
class MiuixSwitch extends StatefulWidget {
  /// Creates a switch.
  const MiuixSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.colors,
  });

  factory MiuixSwitch.source({
    Key? key,
    required bool checked,
    required ValueChanged<bool>? onCheckedChange,
    bool enabled = true,
    MiuixSwitchColors? colors,
  }) {
    return MiuixSwitch(
      key: key,
      value: checked,
      onChanged: onCheckedChange,
      enabled: enabled,
      colors: colors,
    );
  }

  /// Current value.
  final bool value;

  /// Change callback.
  final ValueChanged<bool>? onChanged;

  /// Whether the switch is enabled.
  ///
  /// MIUIX treats this independently from [onChanged]. A disabled switch with
  /// a callback retains the platform 48dp toggle target and disabled colors,
  /// while a callback-less switch has only its authored 49×28dp bounds.
  final bool enabled;

  /// Optional source eight-channel switch colors.
  final MiuixSwitchColors? colors;

  @override
  State<MiuixSwitch> createState() => _MiuixSwitchState();
}

class _MiuixSwitchState extends State<MiuixSwitch>
    with TickerProviderStateMixin {
  // Press is kept separately from hover because touch release must not cancel
  // the desktop pointer's hover enlargement.
  bool _pressed = false;

  // MIUIX gives an enabled switch the same thumb enlargement on mouse hover
  // that it gives during a touch press.
  bool _hovered = false;

  // 位移始终限制在两个端点之间，不积压端点外看不见的移动。
  // 因而同一手势反向时，滑块会立即响应，无需先抵消越界距离。
  double _dragOffset = 0;
  // 手指控制期间直接更新位置；弹簧只用于松手、点击和外部状态变化。
  bool _dragging = false;

  // Switch.kt maintains two independent haptic flags for each drag.
  _MiuixSwitchDragHapticTracker? _dragHapticTracker;

  // Position and scale use different upstream spring descriptions, so a
  // single controller cannot faithfully drive both values.
  late final AnimationController _thumbOffsetController;
  late final AnimationController _thumbScaleController;

  // The merged listenable avoids nesting two AnimatedBuilder widgets around
  // the thumb paint subtree.
  late final Listenable _thumbMotion;

  /// Accessibility preference that suppresses all switch-owned springs.
  bool _reduceMotion = false;

  bool get _canActivate => widget.enabled && widget.onChanged != null;
  bool get _hasToggleTarget => widget.onChanged != null;

  // The fixed endpoints are measured from the leading edge of the 49 dp track.
  double get _thumbOffsetTarget =>
      (widget.value
          ? MiuixSwitchDefaults.checkedThumbOffset
          : MiuixSwitchDefaults.uncheckedThumbOffset) +
      _dragOffset;

  // A 20 dp thumb grows to approximately 22.54 dp in the upstream component.
  double get _thumbScaleTarget =>
      widget.enabled && (_pressed || _hovered) ? 1.127 : 1;

  @override
  void initState() {
    super.initState();
    _thumbOffsetController = AnimationController.unbounded(
      vsync: this,
      value: widget.value
          ? MiuixSwitchDefaults.checkedThumbOffset
          : MiuixSwitchDefaults.uncheckedThumbOffset,
    );
    _thumbScaleController = AnimationController.unbounded(
      vsync: this,
      value: 1,
    );
    _thumbMotion = Listenable.merge([
      _thumbOffsetController,
      _thumbScaleController,
    ]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion = MediaQuery.disableAnimationsOf(context);
    if (nextReduceMotion == _reduceMotion) return;
    _reduceMotion = nextReduceMotion;
    if (_reduceMotion) {
      _thumbOffsetController
        ..stop(canceled: true)
        ..value = _thumbOffsetTarget;
      _thumbScaleController
        ..stop(canceled: true)
        ..value = _thumbScaleTarget;
    }
  }

  @override
  void didUpdateWidget(covariant MiuixSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部提交或禁用会终止当前手势，剩余 MOVE/UP 不能再提交旧意图。
    // 生命周期本就会继续 build，无需额外 setState 重建一次。
    if (oldWidget.value != widget.value || !widget.enabled) {
      _dragging = false;
      _dragOffset = 0;
      _dragHapticTracker = null;
      _pressed = false;
    }
    // 禁用后也清除桌面悬停，避免继续显示放大的滑块。
    if (!widget.enabled) _hovered = false;
    _syncThumbOffset();
    _syncThumbScale();
  }

  @override
  void dispose() {
    _thumbOffsetController.dispose();
    _thumbScaleController.dispose();
    super.dispose();
  }

  void _springTo(
    AnimationController controller,
    double target,
    SpringDescription spring,
  ) {
    if (_reduceMotion) {
      controller
        ..stop(canceled: true)
        ..value = target;
      return;
    }
    // Preserve the controller velocity so a quick reversal remains continuous
    // instead of visibly restarting at zero speed.
    controller.animateWith(
      SpringSimulation(spring, controller.value, target, controller.velocity),
    );
  }

  void _syncThumbOffset() {
    // 拖动期间在当前输入帧定位，不启动需要逐帧追赶的弹簧。
    // 值相同也要停止已有动画，避免下一帧仍沿旧方向移动。
    if (_dragging) {
      if (_thumbOffsetController.isAnimating ||
          _thumbOffsetController.value != _thumbOffsetTarget) {
        _thumbOffsetController.value = _thumbOffsetTarget;
      }
      return;
    }
    // 松手或点击仍使用原有位置弹簧。
    _springTo(
      _thumbOffsetController,
      _thumbOffsetTarget,
      debugMiuixSwitchThumbOffsetSpring(),
    );
  }

  void _syncThumbScale() {
    // Press and hover converge on the same source scale target.
    _springTo(
      _thumbScaleController,
      _thumbScaleTarget,
      debugMiuixSwitchThumbScaleSpring(),
    );
  }

  void _setPressed(bool value) {
    // 横拖获胜会取消外层点击识别，但不应取消仍按住的滑块状态。
    if (!value && _dragging) return;
    // Avoid scheduling redundant spring simulations from duplicate pointer
    // notifications.
    if (_pressed != value) {
      setState(() => _pressed = value);
      _syncThumbScale();
    }
  }

  void _setHovered(bool value) {
    // Hover feedback is intentionally suppressed for disabled switches.
    if (widget.enabled && _hovered != value) {
      setState(() => _hovered = value);
      _syncThumbScale();
    }
  }

  void _emitToggleHaptic(bool value) {
    unawaited(
      MiuixHaptics.perform(
        value ? MiuixHapticType.toggleOn : MiuixHapticType.toggleOff,
      ),
    );
  }

  void _toggle({bool haptic = true}) {
    if (!_canActivate) return;
    final next = !widget.value;
    widget.onChanged?.call(next);
    if (haptic) _emitToggleHaptic(next);
  }

  void _startDrag(DragStartDetails details) {
    if (!widget.enabled) {
      return;
    }
    // 从当前可见位置接手，快速接住尚在回弹的滑块也不会跳回端点。
    _thumbOffsetController.stop();
    final visible = _thumbOffsetController.value.clamp(
      MiuixSwitchDefaults.uncheckedThumbOffset,
      MiuixSwitchDefaults.checkedThumbOffset,
    );
    final origin = widget.value
        ? MiuixSwitchDefaults.checkedThumbOffset
        : MiuixSwitchDefaults.uncheckedThumbOffset;
    // 位移相对于受控值的端点，继续共用松手阈值与触觉判断。
    _dragging = true;
    _dragOffset = visible - origin;
    _setPressed(true);
    _dragHapticTracker = _MiuixSwitchDragHapticTracker(widget.value);
    _syncThumbOffset();
  }

  void _updateDrag(DragUpdateDetails details) {
    if (!widget.enabled || !_dragging) {
      return;
    }
    // 手指与滑块使用同一逻辑位移，反向无需等待动画或抵消越界积压。
    // 这里只更新紧凑滑块的控制器，不为每个 MOVE 重建整个开关。
    final delta = details.primaryDelta ?? details.delta.dx;
    final nextOffset = _dragOffset + delta;
    // 两端仍丢弃超出轨道的位移，连续往返不会留下反向死区。
    _dragOffset = widget.value
        ? nextOffset.clamp(-MiuixSwitchDefaults.dragDistance, 0.0)
        : nextOffset.clamp(0.0, MiuixSwitchDefaults.dragDistance);
    _updateDragEndpointHaptics();
    _syncThumbOffset();
  }

  void _updateDragEndpointHaptics() {
    final feedbackValue = _dragHapticTracker?.update(_dragOffset);
    if (feedbackValue != null) {
      _emitToggleHaptic(feedbackValue);
    }
  }

  void _endDrag([DragEndDetails? details]) => _finishDrag(commit: true);

  // 系统取消只复位；不能把中断手势当作用户确认切换。
  void _cancelDrag() => _finishDrag(commit: false);

  void _finishDrag({required bool commit}) {
    if (!_dragging) return;
    final stoppedOffset = _dragOffset;
    // Half the 21 dp endpoint distance is the upstream commit threshold.
    final shouldToggle = commit && widget.enabled && stoppedOffset.abs() > 10.5;
    final tracker = _dragHapticTracker;
    _dragHapticTracker = null;
    setState(() {
      _dragging = false;
      _pressed = false;
      _dragOffset = 0;
    });
    // First return the transient visuals to rest, then notify the owner. The
    // owner-provided value will start the committed endpoint spring.
    _syncThumbOffset();
    _syncThumbScale();
    if (shouldToggle) {
      widget.onChanged?.call(!widget.value);
    }

    // Source Switch.kt deliberately leaves a one-dp haptic dead band between
    // release roles instead of deriving them from the 10.5 dp commit point.
    final feedbackValue = commit ? tracker?.release(stoppedOffset) : null;
    if (feedbackValue != null) {
      _emitToggleHaptic(feedbackValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resolve all eight source channels on each inherited-theme rebuild.
    final colors = widget.colors ?? MiuixSwitchDefaults.switchColors(context);
    final trackColor = colors.track(
      checked: widget.value,
      enabled: widget.enabled,
    );
    final thumbColor = colors.thumb(
      checked: widget.value,
      enabled: widget.enabled,
    );
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final visualWidth = _miuixRoundLogicalDimension(
      MiuixSwitchDefaults.width,
      pixelRatio,
    );
    final visualHeight = _miuixRoundLogicalDimension(
      MiuixSwitchDefaults.height,
      pixelRatio,
    );
    final touchTargetHeight = _miuixRoundLogicalDimension(
      MiuixSwitchDefaults.touchTargetHeight,
      pixelRatio,
    );
    final track = SizedBox(
      // Compose converts the 49×28dp track into integer physical dimensions
      // before platform minimum-target expansion.
      width: visualWidth,
      height: visualHeight,
      child: _MiuixSpringColor(
        // Track and thumb colors deliberately have independent springs.
        color: trackColor,
        spring: debugMiuixSwitchTrackColorSpring(),
        builder: (context, animatedTrackColor) => DecoratedBox(
          key: const ValueKey('miuix-switch-track'),
          decoration: BoxDecoration(
            color: animatedTrackColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: AnimatedBuilder(
            // Repaint only the compact switch subtree while either physical
            // animation is moving.
            animation: _thumbMotion,
            builder: (context, _) => Stack(
              children: [
                Positioned(
                  // The upstream y inset is 4 dp for a 20 dp thumb in a 28 dp
                  // track.
                  left: _thumbOffsetController.value,
                  top: 4,
                  child: _miuixPriorityHorizontalDrag(
                    excludeFromSemantics: true,
                    cancelOnPointerCancel: true,
                    onStart: widget.enabled ? _startDrag : null,
                    onUpdate: widget.enabled ? _updateDrag : null,
                    onEnd: widget.enabled ? _endDrag : null,
                    onCancel: widget.enabled ? _cancelDrag : null,
                    child: Transform.scale(
                      // Transform.scale keeps the spring centered on the logical
                      // thumb position just like Compose graphicsLayer.
                      key: const ValueKey('miuix-switch-thumb-transform'),
                      scale: _thumbScaleController.value,
                      child: _MiuixSpringColor(
                        color: thumbColor,
                        spring: debugMiuixSwitchThumbColorSpring(),
                        builder: (context, animatedThumbColor) => DecoratedBox(
                          key: const ValueKey('miuix-switch-thumb'),
                          decoration: BoxDecoration(
                            color: animatedThumbColor,
                            shape: BoxShape.circle,
                          ),
                          child: const SizedBox.square(
                            dimension: MiuixSwitchDefaults.thumbSize,
                          ),
                        ),
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
    final semanticControl = Semantics(
      key: const ValueKey('miuix-switch-semantics'),
      container: true,
      // RawGestureDetector contributes horizontal-scroll semantics for its
      // drag recognizer. Compose exposes only the outer toggleable node, so
      // discard that implementation-detail child action.
      excludeSemantics: true,
      toggled: widget.value,
      enabled: widget.enabled,
      onTap: _hasToggleTarget
          ? _canActivate
                ? _toggle
                : () {}
          : null,
      child: MouseRegion(
        // MouseRegion supplies desktop hover without altering touch hit tests.
        onEnter: (_) => _setHovered(true),
        onExit: (_) => _setHovered(false),
        child: GestureDetector(
          // The complete 49 x 28 dp source bounds remain tappable, including
          // transparent pixels around the circular thumb.
          behavior: HitTestBehavior.opaque,
          onTap: _canActivate ? _toggle : null,
          onTapDown: _canActivate ? (_) => _setPressed(true) : null,
          onTapCancel: _canActivate ? () => _setPressed(false) : null,
          onTapUp: _canActivate ? (_) => _setPressed(false) : null,
          // Expand only the semantic/gesture height. The reciprocal transform
          // leaves the 49×28dp track visually unchanged.
          child: _hasToggleTarget
              ? Transform.scale(
                  scaleX: 1,
                  scaleY: visualHeight / touchTargetHeight,
                  child: track,
                )
              : track,
        ),
      ),
    );
    if (!_hasToggleTarget) return semanticControl;
    return Transform.scale(
      scaleX: 1,
      scaleY: touchTargetHeight / visualHeight,
      child: semanticControl,
    );
  }
}

/// Animates a resolved semantic color with the same vector spring as Compose.
class _MiuixSpringColor extends StatefulWidget {
  const _MiuixSpringColor({
    required this.color,
    required this.spring,
    required this.builder,
  });

  final Color color;
  final SpringDescription spring;
  final Widget Function(BuildContext context, Color color) builder;

  @override
  State<_MiuixSpringColor> createState() => _MiuixSpringColorState();
}

class _MiuixSpringColorState extends State<_MiuixSpringColor>
    with SingleTickerProviderStateMixin {
  // The interpolation endpoints are retained across interrupted transitions.
  late Color _from;
  late Color _to;

  // An unbounded controller is required because a physical spring may
  // overshoot its nominal zero-to-one progress interval.
  late final AnimationController _controller;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _from = widget.color;
    _to = widget.color;
    _controller = AnimationController.unbounded(vsync: this, value: 1);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion = MediaQuery.disableAnimationsOf(context);
    if (nextReduceMotion == _reduceMotion) return;
    _reduceMotion = nextReduceMotion;
    if (_reduceMotion) {
      _controller
        ..stop(canceled: true)
        ..value = 1;
      _from = widget.color;
      _to = widget.color;
    }
  }

  @override
  void didUpdateWidget(covariant _MiuixSpringColor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color == widget.color) return;
    // Start the next transition at the color currently visible on screen, not
    // at the previous semantic endpoint.
    final progress = _controller.value.clamp(0.0, 1.0);
    _from = Color.lerp(_from, _to, progress) ?? widget.color;
    _to = widget.color;
    if (_reduceMotion) {
      _controller
        ..stop(canceled: true)
        ..value = 1;
      _from = widget.color;
      return;
    }
    // Color channels cannot use an overshooting scalar safely, so rendering
    // clamps progress while the simulation itself remains physically correct.
    _controller.value = 0;
    _controller.animateWith(
      SpringSimulation(widget.spring, 0, 1, _controller.velocity),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        // Compose's vector converter effectively interpolates the color
        // channels at this same normalized spring progress.
        final progress = _controller.value.clamp(0.0, 1.0);
        return widget.builder(context, Color.lerp(_from, _to, progress) ?? _to);
      },
    );
  }
}

double _finiteOr(double value, double fallback) {
  // Painters must never forward NaN or infinity into Canvas operations.
  return value.isFinite ? value : fallback;
}

({double min, double max}) _safeRange(double min, double max) {
  // Invalid bounds degrade to a stable one-unit range instead of throwing.
  final safeMin = _finiteOr(min, 0);
  final safeMax = _finiteOr(max, safeMin + 1);
  if (safeMax <= safeMin) {
    return (min: safeMin, max: safeMin + 1);
  }
  return (min: safeMin, max: safeMax);
}

int? _safeDivisions(int? divisions) {
  // Flutter accepts only positive divisions; MIUIX treats other values as free.
  if (divisions == null || divisions <= 0) {
    return null;
  }
  return divisions;
}

double _fractionForValue(double value, ({double min, double max}) range) {
  // The validated range normally guarantees a positive span; retain the guard
  // for direct internal calls and defensive painter behavior.
  final span = range.max - range.min;
  if (span <= 0) {
    return 0;
  }
  final safeValue = _finiteOr(value, range.min);
  return ((safeValue - range.min) / span).clamp(0.0, 1.0);
}

/// Converts a normalized pointer position to the value emitted by Slider.kt.
///
/// Source-parity contract:
///
/// * Pointer positions are clamped before any other operation.
/// * Non-finite positions resolve from the leading edge.
/// * A positive [divisions] value selects discrete step mode.
/// * Step mode rounds to the nearest one of `divisions + 1` values.
/// * Step mode has priority over every custom magnetic point.
/// * A null or non-positive [divisions] value selects continuous mode.
/// * Continuous mode linearly maps the normalized fraction to the range.
/// * Custom points are interpreted as absolute values, not fractions.
/// * Each point is normalized with the same validated value range.
/// * Non-finite custom points are ignored.
/// * Points outside the range clamp to the nearest edge, as in Compose.
/// * The closest point wins when several magnetic regions overlap.
/// * Equal distances retain the first point because the source uses `<`.
/// * The default magnetic threshold is exactly two percent of the range.
/// * A non-finite threshold falls back to that two-percent default.
/// * Thresholds are constrained to the meaningful normalized interval.
/// * Snapping uses a strict comparison, so equality does not snap.
/// * No custom points means continuous mode remains completely free-moving.
/// * The returned value is expressed in the caller's absolute value range.
///
/// Keeping these decisions together is intentional. Horizontal, vertical and
/// range sliders must resolve the same pointer fraction identically; direction
/// handling belongs to the gesture layer before this shared conversion.
double _valueForFraction(
  double fraction,
  ({double min, double max}) range,
  int? divisions, {
  List<double> keyPoints = const <double>[],
  double magnetThreshold = .02,
}) {
  // Normalize first so both continuous and stepped sliders share edge handling.
  final safeFraction = _finiteOr(fraction, 0).clamp(0.0, 1.0);

  // Discrete steps take precedence over custom magnetic points in Slider.kt.
  final safeDivisions = _safeDivisions(divisions);
  if (safeDivisions != null) {
    final snapped = (safeFraction * safeDivisions).round() / safeDivisions;
    return range.min + (range.max - range.min) * snapped;
  }

  // Continuous sliders remain free-moving except inside the source's strict
  // magnetic threshold around an explicitly supplied key point.
  final safeThreshold = _finiteOr(magnetThreshold, .02).clamp(0.0, 1.0);
  var closestFraction = 0.0;
  var closestDistance = double.infinity;
  for (final point in keyPoints) {
    if (!point.isFinite) continue;
    final pointFraction = _fractionForValue(point, range);
    final distance = (pointFraction - safeFraction).abs();
    if (distance < closestDistance) {
      closestFraction = pointFraction;
      closestDistance = distance;
    }
  }
  final resolvedFraction = closestDistance < safeThreshold
      ? closestFraction
      : safeFraction;
  return range.min + (range.max - range.min) * resolvedFraction;
}

/// Resolves the exact step-or-magnet value used by source slider gestures.
@visibleForTesting
double debugMiuixSliderValueFromFraction({
  required double fraction,
  double min = 0,
  double max = 1,
  int? divisions,
  List<double> keyPoints = const <double>[],
  double magnetThreshold = .02,
}) {
  return _valueForFraction(
    fraction,
    _safeRange(min, max),
    divisions,
    keyPoints: keyPoints,
    magnetThreshold: magnetThreshold,
  );
}

double _normalizeSliderCallbackValue(
  double value,
  ({double min, double max}) range,
) {
  // Public callbacks never receive a non-finite or out-of-range value.
  return _finiteOr(value, range.min).clamp(range.min, range.max).toDouble();
}

RangeValues _normalizeSliderCallbackRange(
  RangeValues values,
  ({double min, double max}) range,
) {
  // Normalize each endpoint independently before restoring ascending order.
  final start = _normalizeSliderCallbackValue(values.start, range);
  final end = _normalizeSliderCallbackValue(values.end, range);
  return start <= end ? RangeValues(start, end) : RangeValues(end, start);
}

/// Resolves source key-point values into painter-space fractions.
///
/// Compose treats value snapping (`steps`) and visible markers
/// (`showKeyPoints`) as separate features. Flutter's `divisions` supplies the
/// former here; markers are generated only when explicitly requested.
List<double> _miuixSliderKeyPointFractions({
  required ({double min, double max}) range,
  required int? divisions,
  required bool showKeyPoints,
  required List<double> keyPoints,
  required bool vertical,
}) {
  if (!showKeyPoints) {
    return const <double>[];
  }
  final List<double> values;
  if (keyPoints.isNotEmpty) {
    values = keyPoints;
  } else {
    final count = _safeDivisions(divisions);
    values = count == null
        ? const <double>[]
        : <double>[
            for (var index = 0; index <= count; index++)
              range.min + (range.max - range.min) * index / count,
          ];
  }
  final fractions = <double>[];
  for (final value in values) {
    if (!value.isFinite) {
      continue;
    }
    final logical = _fractionForValue(value, range);
    final painterFraction = vertical ? 1 - logical : logical;
    if (!fractions.any((entry) => (entry - painterFraction).abs() < .000001)) {
      fractions.add(painterFraction);
    }
  }
  fractions.sort();
  return fractions;
}

/// Exposes key-point normalization for source-parity regression tests.
@visibleForTesting
List<double> debugMiuixSliderKeyPointFractions({
  double min = 0,
  double max = 1,
  int? divisions,
  bool showKeyPoints = false,
  List<double> keyPoints = const <double>[],
  bool vertical = false,
}) {
  return _miuixSliderKeyPointFractions(
    range: _safeRange(min, max),
    divisions: divisions,
    showKeyPoints: showKeyPoints,
    keyPoints: keyPoints,
    vertical: vertical,
  );
}

/// Immutable eight-channel color model from MIUIX `SliderColors`.
class MiuixSliderColors {
  /// Creates an independently configurable slider palette.
  const MiuixSliderColors({
    required this.foregroundColor,
    required this.disabledForegroundColor,
    required this.backgroundColor,
    required this.disabledBackgroundColor,
    required this.thumbColor,
    required this.disabledThumbColor,
    required this.keyPointColor,
    required this.keyPointForegroundColor,
  });

  /// Enabled selected-track channel.
  final Color foregroundColor;

  /// Disabled selected-track channel.
  final Color disabledForegroundColor;

  /// Enabled unselected-track channel.
  final Color backgroundColor;

  /// Disabled unselected-track channel.
  final Color disabledBackgroundColor;

  /// Enabled thumb channel.
  final Color thumbColor;

  /// Disabled thumb channel.
  final Color disabledThumbColor;

  /// Marker channel outside the selected track.
  final Color keyPointColor;

  /// Marker channel inside the selected track.
  final Color keyPointForegroundColor;

  /// Resolves the selected-track channel for the enabled state.
  Color foreground(bool enabled) =>
      enabled ? foregroundColor : disabledForegroundColor;

  /// Resolves the unselected-track channel for the enabled state.
  Color background(bool enabled) =>
      enabled ? backgroundColor : disabledBackgroundColor;

  /// Resolves the thumb channel for the enabled state.
  Color thumb(bool enabled) => enabled ? thumbColor : disabledThumbColor;

  /// Returns a copy with independently replaced source channels.
  MiuixSliderColors copyWith({
    Color? foregroundColor,
    Color? disabledForegroundColor,
    Color? backgroundColor,
    Color? disabledBackgroundColor,
    Color? thumbColor,
    Color? disabledThumbColor,
    Color? keyPointColor,
    Color? keyPointForegroundColor,
  }) {
    return MiuixSliderColors(
      foregroundColor: foregroundColor ?? this.foregroundColor,
      disabledForegroundColor:
          disabledForegroundColor ?? this.disabledForegroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      disabledBackgroundColor:
          disabledBackgroundColor ?? this.disabledBackgroundColor,
      thumbColor: thumbColor ?? this.thumbColor,
      disabledThumbColor: disabledThumbColor ?? this.disabledThumbColor,
      keyPointColor: keyPointColor ?? this.keyPointColor,
      keyPointForegroundColor:
          keyPointForegroundColor ?? this.keyPointForegroundColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MiuixSliderColors &&
        other.foregroundColor == foregroundColor &&
        other.disabledForegroundColor == disabledForegroundColor &&
        other.backgroundColor == backgroundColor &&
        other.disabledBackgroundColor == disabledBackgroundColor &&
        other.thumbColor == thumbColor &&
        other.disabledThumbColor == disabledThumbColor &&
        other.keyPointColor == keyPointColor &&
        other.keyPointForegroundColor == keyPointForegroundColor;
  }

  @override
  int get hashCode => Object.hash(
    foregroundColor,
    disabledForegroundColor,
    backgroundColor,
    disabledBackgroundColor,
    thumbColor,
    disabledThumbColor,
    keyPointColor,
    keyPointForegroundColor,
  );
}

/// Exact public constants and semantic defaults from `SliderDefaults`.
abstract final class MiuixSliderDefaults {
  /// Source minimum cross-axis extent for every slider family member.
  static const double minHeight = 28;

  /// Source marker radius before the painter's cross-axis normalization.
  static const double keyPointRadius = 3.855;

  /// Source default feedback mode.
  static const MiuixSliderHapticEffect defaultHapticEffect =
      MiuixSliderHapticEffect.edge;

  /// Resolves all eight source color roles with independent overrides.
  static MiuixSliderColors sliderColors(
    BuildContext context, {
    Color? foregroundColor,
    Color? disabledForegroundColor,
    Color? backgroundColor,
    Color? disabledBackgroundColor,
    Color? thumbColor,
    Color? disabledThumbColor,
    Color? keyPointColor,
    Color? keyPointForegroundColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixSliderColors(
      foregroundColor: foregroundColor ?? semantic['primary'],
      disabledForegroundColor:
          disabledForegroundColor ?? semantic['disabledPrimarySlider'],
      backgroundColor: backgroundColor ?? semantic['sliderBackground'],
      disabledBackgroundColor:
          disabledBackgroundColor ?? semantic['disabledSecondary'],
      thumbColor: thumbColor ?? semantic['onPrimary'],
      disabledThumbColor: disabledThumbColor ?? semantic['disabledOnPrimary'],
      keyPointColor: keyPointColor ?? semantic['sliderKeyPoint'],
      keyPointForegroundColor:
          keyPointForegroundColor ?? semantic['sliderKeyPointForeground'],
    );
  }
}

/// Resolves the exact MIUIX semantic roles used by slider painting.
@visibleForTesting
Map<String, Color> debugMiuixSliderResolvedColors(
  MiuixSemanticColors semantic, {
  bool enabled = true,
}) {
  return <String, Color>{
    'background': enabled
        ? semantic['sliderBackground']
        : semantic['disabledSecondary'],
    'foreground': enabled
        ? semantic['primary']
        : semantic['disabledPrimarySlider'],
    'thumb': enabled ? semantic['onPrimary'] : semantic['disabledOnPrimary'],
    'keyPoint': semantic['sliderKeyPoint'],
    'keyPointForeground': semantic['sliderKeyPointForeground'],
  };
}

Map<String, Color> _resolvedMiuixSliderColors(
  MiuixSliderColors colors, {
  required bool enabled,
}) {
  return <String, Color>{
    'background': colors.background(enabled),
    'foreground': colors.foreground(enabled),
    'thumb': colors.thumb(enabled),
    'keyPoint': colors.keyPointColor,
    'keyPointForeground': colors.keyPointForegroundColor,
  };
}

class _MiuixSliderPaintData {
  const _MiuixSliderPaintData({
    required this.startFraction,
    required this.endFraction,
    required this.divisions,
    required this.keyPointFractions,
    required this.enabled,
    required this.vertical,
    required this.colors,
    this.range = false,
    this.reverseDirection = false,
    this.trackScale = 1,
    this.thumbScale = 1,
    double? startThumbScale,
    double? endThumbScale,
    this.backgroundOverlayAlpha = 0,
  }) : startThumbScale = startThumbScale ?? thumbScale,
       endThumbScale = endThumbScale ?? thumbScale;

  // Leading selected endpoint in normalized painter coordinates.
  final double startFraction;

  // Trailing selected endpoint or the single slider value.
  final double endFraction;

  // Optional interaction snapping count, independent from visible markers.
  final int? divisions;

  // Pre-normalized marker positions in painter orientation.
  final List<double> keyPointFractions;

  // Controls the dedicated enabled and disabled semantic roles.
  final bool enabled;

  // Swaps the painter's main and cross axes when true.
  final bool vertical;

  // Selects between one-ended and two-ended active track painting.
  final bool range;

  // Mirrors horizontal/vertical painter coordinates after value resolution.
  final bool reverseDirection;

  // Resolved immutable palette shared by all three source variants.
  final MiuixSliderColors colors;

  // Interaction feedback multiplier for the track thickness.
  final double trackScale;

  // Interaction feedback multiplier for the thumb radius.
  final double thumbScale;

  // RangeSlider animates only the thumb that currently owns the drag.
  final double startThumbScale;
  final double endThumbScale;

  // Source track darkening, tweened from 0 to exactly 0.044 while dragging.
  final double backgroundOverlayAlpha;
}

/// Resolves the source track, thumb, and marker radii for one cross axis.
@visibleForTesting
({
  double trackThickness,
  double trackRadius,
  double thumbRadius,
  double keyPointRadius,
})
debugMiuixSliderGeometry({
  required double crossAxisExtent,
  double trackScale = 1,
  double thumbScale = 1,
}) {
  final cross = _finiteOr(crossAxisExtent, 28).clamp(0.0, double.infinity);
  final safeTrackScale = _finiteOr(trackScale, 1).clamp(.25, 1.0);
  final safeThumbScale = _finiteOr(thumbScale, 1).clamp(.25, 4.0);
  // SliderTrack fills the complete Canvas cross axis; there is no 76% or 66%
  // inset in the original horizontal or vertical implementation.
  final trackThickness = cross * safeTrackScale;
  final trackRadius = trackThickness / 2;
  return (
    trackThickness: trackThickness,
    trackRadius: trackRadius,
    thumbRadius: trackRadius * .72 * safeThumbScale,
    // Source key points are based on barHeight/barWidth, not track scaling.
    keyPointRadius: cross / 7.5,
  );
}

class _MiuixSliderPainter extends CustomPainter {
  const _MiuixSliderPainter(this.data);

  // Immutable resolved geometry and semantic input for one paint frame.
  final _MiuixSliderPaintData data;

  /// Exposes the actual widget palette to focused paint regressions.
  @visibleForTesting
  Map<String, Color> get debugResolvedColors =>
      _resolvedMiuixSliderColors(data.colors, enabled: data.enabled);

  @override
  void paint(Canvas canvas, Size size) {
    // Main and cross axes let one implementation serve horizontal and vertical
    // source variants without duplicating the geometry calculations.
    final cross = data.vertical ? size.width : size.height;
    final main = data.vertical ? size.height : size.width;
    // Invalid constraints can occur transiently in animated parent layouts.
    if (!cross.isFinite || !main.isFinite || cross <= 0 || main <= 0) {
      return;
    }
    // Default source geometry consumes the full cross-axis thickness.
    final geometry = debugMiuixSliderGeometry(
      crossAxisExtent: cross,
      trackScale: data.trackScale,
      thumbScale: data.thumbScale,
    );
    final trackThickness = geometry.trackThickness;
    final trackRadius = geometry.trackRadius;
    final thumbRadius = geometry.thumbRadius;
    if (!trackThickness.isFinite ||
        !trackRadius.isFinite ||
        !thumbRadius.isFinite ||
        trackThickness <= 0 ||
        trackRadius <= 0 ||
        thumbRadius <= 0) {
      return;
    }
    final trackStart = trackRadius;
    final trackEnd = main - trackRadius;
    final available = (trackEnd - trackStart).clamp(0.0, double.infinity);
    final authoredStartFraction = _finiteOr(
      data.startFraction,
      0,
    ).clamp(0.0, 1.0);
    final authoredEndFraction = _finiteOr(data.endFraction, 0).clamp(0.0, 1.0);
    final startFraction = data.reverseDirection
        ? 1 - authoredStartFraction
        : authoredStartFraction;
    final endFraction = data.reverseDirection
        ? 1 - authoredEndFraction
        : authoredEndFraction;
    final start = trackStart + startFraction * available;
    final end = trackStart + endFraction * available;
    final centerOffset = cross / 2;
    final trackInset = (cross - trackThickness) / 2;
    if (!start.isFinite ||
        !end.isFinite ||
        !centerOffset.isFinite ||
        !trackInset.isFinite) {
      return;
    }
    // MIUIX owns dedicated slider roles. Using Material primary blends here
    // made the inactive track visibly blue, while the 1.0.9 light palette uses
    // a neutral 6% black track and exact disabled foreground/thumb roles.
    final colors = debugResolvedColors;
    final backgroundColor = colors['background']!;
    final foregroundColor = colors['foreground']!;
    final thumbColor = colors['thumb']!;
    final backgroundPaint = Paint()..color = backgroundColor;
    final activePaint = Paint()
      ..color = foregroundColor
      ..strokeWidth = trackThickness
      ..strokeCap = StrokeCap.round;
    final thumbPaint = Paint()..color = thumbColor;
    final baseRect = data.vertical
        ? Rect.fromLTWH(trackInset, 0, trackThickness, main)
        : Rect.fromLTWH(0, trackInset, main, trackThickness);
    final baseRRect = RRect.fromRectAndRadius(
      baseRect,
      Radius.circular(trackRadius),
    );
    canvas.drawRRect(baseRRect, backgroundPaint);
    final overlayAlpha = _finiteOr(
      data.backgroundOverlayAlpha,
      0,
    ).clamp(0.0, .044);
    if (overlayAlpha > 0) {
      canvas.drawRRect(
        baseRRect,
        Paint()..color = Colors.black.withValues(alpha: overlayAlpha),
      );
    }

    void drawSafeCircle(Offset center, double radius, Paint paint) {
      if (!center.dx.isFinite ||
          !center.dy.isFinite ||
          !radius.isFinite ||
          radius <= 0) {
        return;
      }
      canvas.drawCircle(center, radius, paint);
    }

    canvas.save();
    canvas.clipRRect(baseRRect);
    if (data.range) {
      if (data.vertical) {
        canvas.drawLine(
          Offset(centerOffset, start),
          Offset(centerOffset, end),
          activePaint,
        );
      } else {
        canvas.drawLine(
          Offset(start, centerOffset),
          Offset(end, centerOffset),
          activePaint,
        );
      }
    } else if (!data.range) {
      if (data.vertical) {
        canvas.drawLine(
          Offset(centerOffset, main),
          Offset(centerOffset, end),
          activePaint,
        );
      } else {
        canvas.drawLine(
          Offset(data.reverseDirection ? main : 0, centerOffset),
          Offset(end, centerOffset),
          activePaint,
        );
      }
    }
    canvas.restore();

    if (data.keyPointFractions.isNotEmpty) {
      final tickPaint = Paint();
      for (final fraction in data.keyPointFractions) {
        final authoredFraction = _finiteOr(fraction, 0).clamp(0.0, 1.0);
        final effectiveFraction = data.reverseDirection
            ? 1 - authoredFraction
            : authoredFraction;
        final position = trackStart + effectiveFraction * available;
        final selected = data.range
            ? effectiveFraction >= math.min(startFraction, endFraction) &&
                  effectiveFraction <= math.max(startFraction, endFraction)
            : data.vertical
            ? effectiveFraction >= endFraction
            : data.reverseDirection
            ? effectiveFraction >= endFraction
            : effectiveFraction <= endFraction;
        tickPaint.color = selected
            ? colors['keyPointForeground']!
            : colors['keyPoint']!;
        canvas.drawCircle(
          data.vertical
              ? Offset(centerOffset, position)
              : Offset(position, centerOffset),
          geometry.keyPointRadius,
          tickPaint,
        );
      }
    }

    final startCenter = data.vertical
        ? Offset(centerOffset, start)
        : Offset(start, centerOffset);
    final endCenter = data.vertical
        ? Offset(centerOffset, end)
        : Offset(end, centerOffset);

    void drawThumb(Offset center, double scale) {
      final fillRadius =
          thumbRadius *
          _finiteOr(scale, 1).clamp(.25, 4.0) /
          _finiteOr(data.thumbScale, 1).clamp(.25, 4.0);
      if (!center.dx.isFinite ||
          !center.dy.isFinite ||
          !fillRadius.isFinite ||
          fillRadius <= 0) {
        return;
      }
      drawSafeCircle(center, fillRadius, thumbPaint);
    }

    if (data.range) {
      // RangeSliderTrack draws start first and end second even while thumbs
      // overlap; the source does not reorder them by active ownership.
      drawThumb(startCenter, data.startThumbScale);
      drawThumb(endCenter, data.endThumbScale);
    } else {
      drawThumb(endCenter, data.thumbScale);
    }
  }

  @override
  bool shouldRepaint(covariant _MiuixSliderPainter oldDelegate) {
    final old = oldDelegate.data;
    return data.startFraction != old.startFraction ||
        data.endFraction != old.endFraction ||
        data.divisions != old.divisions ||
        !listEquals(data.keyPointFractions, old.keyPointFractions) ||
        data.enabled != old.enabled ||
        data.vertical != old.vertical ||
        data.range != old.range ||
        data.reverseDirection != old.reverseDirection ||
        data.trackScale != old.trackScale ||
        data.thumbScale != old.thumbScale ||
        data.startThumbScale != old.startThumbScale ||
        data.endThumbScale != old.endThumbScale ||
        data.backgroundOverlayAlpha != old.backgroundOverlayAlpha ||
        data.colors != old.colors;
  }
}

/// Exposes one rendered slider frame for bounded motion-policy regressions.
@visibleForTesting
({
  double startFraction,
  double endFraction,
  double thumbScale,
  double startThumbScale,
  double endThumbScale,
  double backgroundOverlayAlpha,
})
debugMiuixSliderPaintSnapshot(CustomPainter? painter) {
  if (painter is! _MiuixSliderPainter) {
    throw ArgumentError.value(
      painter,
      'painter',
      'Expected MIUIX slider paint',
    );
  }
  final data = painter.data;
  return (
    startFraction: data.startFraction,
    endFraction: data.endFraction,
    thumbScale: data.thumbScale,
    startThumbScale: data.startThumbScale,
    endThumbScale: data.endThumbScale,
    backgroundOverlayAlpha: data.backgroundOverlayAlpha,
  );
}

/// Exposes the slider active-track edge rule for regression tests.
@visibleForTesting
bool debugMiuixSliderHasActiveTrack({
  required bool range,
  required bool vertical,
  required double endFraction,
}) {
  const sliderZeroTolerance = 0.000001;
  return range ||
      (vertical
          ? endFraction < 1 - sliderZeroTolerance
          : endFraction > sliderZeroTolerance);
}

/// Exposes the MIUIX tick selection rule for regression tests.
@visibleForTesting
bool debugMiuixSliderTickSelected({
  required bool range,
  required bool vertical,
  required double fraction,
  required double startFraction,
  required double endFraction,
}) {
  if (range) {
    return fraction >= startFraction && fraction <= endFraction;
  }
  return vertical ? fraction >= endFraction : fraction <= endFraction;
}

/// Source feedback modes shared by MIUIX slider variants.
enum MiuixSliderHapticEffect {
  /// Do not emit feedback while the value changes.
  none,

  /// Emit only when the thumb reaches either value-range edge.
  edge,

  /// Emit at edges and at each discrete step or magnetic key point.
  step,
}

int? _miuixSourceStepsToDivisions(int steps) => steps > 0 ? steps + 1 : null;

void _dispatchSliderHaptic({
  required double previous,
  required double next,
  required ({double min, double max}) range,
  required MiuixSliderHapticEffect effect,
  required int? divisions,
  required List<double> keyPoints,
}) {
  if (effect == MiuixSliderHapticEffect.none || previous == next) return;
  final span = range.max - range.min;
  if (span <= 0) return;
  final tolerance = math.max(.000001, span * .000005);
  final nextAtMin = (next - range.min).abs() <= tolerance;
  final nextAtMax = (next - range.max).abs() <= tolerance;
  final previousAtSameEdge = nextAtMin
      ? (previous - range.min).abs() <= tolerance
      : nextAtMax
      ? (previous - range.max).abs() <= tolerance
      : false;
  if ((nextAtMin || nextAtMax) && !previousAtSameEdge) {
    unawaited(MiuixHaptics.perform(MiuixHapticType.gestureThresholdActivate));
    return;
  }
  if (effect != MiuixSliderHapticEffect.step) return;

  final safeDivisions = _safeDivisions(divisions);
  bool crossedStep;
  if (keyPoints.isNotEmpty && safeDivisions == null) {
    int pointFor(double value) => keyPoints.indexWhere(
      (point) => point.isFinite && (point - value).abs() <= tolerance,
    );
    final previousPoint = pointFor(previous);
    final nextPoint = pointFor(next);
    crossedStep = nextPoint >= 0 && nextPoint != previousPoint;
  } else {
    // Slider.kt uses 100 haptic segments for a continuous Step slider.
    final segments = safeDivisions ?? 100;
    int segmentFor(double value) =>
        (((value - range.min) / span) * segments).round();
    crossedStep = segmentFor(previous) != segmentFor(next);
  }
  if (crossedStep) {
    unawaited(MiuixHaptics.perform(MiuixHapticType.textHandleMove));
  }
}

/// Exact progress spring selected by Slider.kt for the current drag phase.
@visibleForTesting
SpringDescription debugMiuixSliderProgressSpring({required bool dragging}) =>
    SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: dragging ? 1755 : 322,
      ratio: dragging ? .9 : .96,
    );

/// Exact thumb-scale spring shared by all three source slider variants.
@visibleForTesting
SpringDescription debugMiuixSliderThumbScaleSpring() =>
    SpringDescription.withDampingRatio(mass: 1, stiffness: 987, ratio: .6);

/// Exact source thumb emphasis while dragging or hovering.
@visibleForTesting
double debugMiuixSliderActiveThumbScale() => 1.127;

double _miuixSliderProgressVisibilityThreshold(
  ({double min, double max}) range,
) {
  final span = range.max - range.min;
  return span > 0 ? .01 / span : .01;
}

/// Exact source track-darkening target and tween duration.
@visibleForTesting
({double alpha, Duration duration}) debugMiuixSliderTrackOverlayMotion() =>
    (alpha: .044, duration: const Duration(milliseconds: 150));

void _animateMiuixSpring(
  AnimationController controller,
  double target,
  SpringDescription spring, {
  double visibilityThreshold = .01,
}) {
  final safeTarget = _finiteOr(target, controller.value);
  if ((controller.value - safeTarget).abs() < .000001) {
    controller.value = safeTarget;
    return;
  }
  controller.animateWith(
    SpringSimulation(
      spring,
      controller.value,
      safeTarget,
      controller.velocity,
      snapToEnd: true,
      tolerance: Tolerance(
        distance: _finiteOr(visibilityThreshold, .01).clamp(.0000001, .1),
        velocity: .01,
      ),
    ),
  );
}

void _animateMiuixSliderOverlay(AnimationController controller, bool active) {
  final motion = debugMiuixSliderTrackOverlayMotion();
  controller.animateTo(
    active ? motion.alpha : 0,
    duration: motion.duration,
    curve: Curves.fastOutSlowIn,
  );
}

/// Single-value slider.
class MiuixSlider extends StatelessWidget {
  /// Creates a slider.
  const MiuixSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.onChangeFinished,
    this.reverseDirection = false,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.showKeyPoints = false,
    this.keyPoints = const <double>[],
    this.magnetThreshold = .02,
    this.height = MiuixSliderDefaults.minHeight,
    this.trackScale = 1,
    this.thumbScale = 1,
    this.colors,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates the source `Slider` parameter form.
  factory MiuixSlider.source({
    Key? key,
    required double value,
    required ValueChanged<double> onValueChange,
    bool enabled = true,
    double min = 0,
    double max = 1,
    int steps = 0,
    VoidCallback? onValueChangeFinished,
    bool reverseDirection = false,
    double height = MiuixSliderDefaults.minHeight,
    MiuixSliderColors? colors,
    MiuixSliderHapticEffect hapticEffect =
        MiuixSliderDefaults.defaultHapticEffect,
    bool showKeyPoints = false,
    List<double>? keyPoints,
    double magnetThreshold = .02,
  }) {
    return MiuixSlider(
      key: key,
      value: value,
      onChanged: onValueChange,
      enabled: enabled,
      onChangeFinished: onValueChangeFinished,
      reverseDirection: reverseDirection,
      min: min,
      max: max,
      divisions: _miuixSourceStepsToDivisions(steps),
      showKeyPoints: showKeyPoints,
      keyPoints: keyPoints ?? const <double>[],
      magnetThreshold: magnetThreshold,
      height: height,
      colors: colors,
      hapticEffect: hapticEffect,
    );
  }

  /// Current value.
  final double value;

  /// Change callback.
  final ValueChanged<double>? onChanged;

  /// Whether pointer input and enabled colors are active.
  ///
  /// MIUIX keeps this independent from [onChanged]. The source API requires a
  /// callback even for disabled sliders and disables only its pointer
  /// modifiers and color roles.
  final bool enabled;

  /// Called after a pointer drag finishes.
  final VoidCallback? onChangeFinished;

  /// Reverses the visual and pointer direction.
  ///
  /// As in MIUIX, RTL automatically inverts this value, so the default still
  /// increases toward the logical end edge.
  final bool reverseDirection;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Optional divisions.
  final int? divisions;

  /// Whether value markers are painted along the track.
  ///
  /// This is independent from [divisions], matching MIUIX `showKeyPoints`.
  final bool showKeyPoints;

  /// Optional absolute values used as visible track markers.
  ///
  /// When empty, [divisions] supplies evenly spaced marker values.
  final List<double> keyPoints;

  /// Magnetic snap radius expressed as a normalized fraction of the range.
  final double magnetThreshold;

  /// Visual height.
  final double height;

  /// Track thickness scale for compact variants.
  final double trackScale;

  /// Thumb size scale for compact variants.
  final double thumbScale;

  /// Optional source eight-channel palette.
  final MiuixSliderColors? colors;

  /// Source feedback mode, defaulting to edge-only feedback.
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) {
    final range = _safeRange(min, max);
    final safeValue = _finiteOr(value, range.min).clamp(range.min, range.max);
    final safeTrackScale = _finiteOr(trackScale, 1).clamp(.25, 4.0);
    final safeThumbScale = _finiteOr(thumbScale, 1).clamp(.25, 4.0);
    final effectiveReverseDirection =
        Directionality.of(context) == TextDirection.rtl
        ? !reverseDirection
        : reverseDirection;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final sliderExtent = _miuixRoundLogicalDimension(
      _finiteOr(height, 28).clamp(18.0, 36.0),
      pixelRatio,
    );
    final touchTargetExtent = _miuixRoundLogicalDimension(48, pixelRatio);
    void adjustSemantics(bool increase) {
      final callback = onChanged;
      if (callback == null) return;
      callback(
        _normalizeSliderCallbackValue(
          _miuixSliderSemanticValue(
            value: safeValue,
            range: range,
            divisions: divisions,
            increase: increase,
            keyPoints: keyPoints,
            magnetThreshold: magnetThreshold,
          ),
          range,
        ),
      );
    }

    return Transform.scale(
      scaleX: 1,
      scaleY: touchTargetExtent / sliderExtent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 240.0;
          // Modifier.height() becomes an integer-pixel placeable before a
          // Compose parent adds its surrounding padding. Snap the component
          // itself so repeated sliders do not alternate between 73 and 74 px
          // or lose pixels from the enclosing card at fractional densities.
          if (!width.isFinite ||
              width <= 0 ||
              !sliderExtent.isFinite ||
              width < math.min(12.0, sliderExtent * .5)) {
            return const SizedBox.shrink();
          }
          return _MiuixHorizontalSliderBody(
            value: safeValue,
            range: range,
            width: width,
            sliderExtent: sliderExtent,
            touchTargetExtent: touchTargetExtent,
            enabled: enabled,
            onChanged: onChanged,
            onChangeFinished: onChangeFinished,
            divisions: divisions,
            keyPoints: keyPoints,
            keyPointFractions: _miuixSliderKeyPointFractions(
              range: range,
              divisions: divisions,
              showKeyPoints: showKeyPoints,
              keyPoints: keyPoints,
              vertical: false,
            ),
            magnetThreshold: magnetThreshold,
            hapticEffect: hapticEffect,
            reverseDirection: effectiveReverseDirection,
            trackScale: safeTrackScale,
            thumbScale: safeThumbScale,
            colors: colors ?? MiuixSliderDefaults.sliderColors(context),
            onIncrease: onChanged == null ? null : () => adjustSemantics(true),
            onDecrease: onChanged == null ? null : () => adjustSemantics(false),
          );
        },
      ),
    );
  }
}

/// Range slider.
class MiuixRangeSlider extends StatelessWidget {
  /// Creates a range slider.
  const MiuixRangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.enabled = true,
    this.onChangeFinished,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.showKeyPoints = false,
    this.keyPoints = const <double>[],
    this.magnetThreshold = .02,
    this.height = MiuixSliderDefaults.minHeight,
    this.colors,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates the source `RangeSlider` parameter form.
  factory MiuixRangeSlider.source({
    Key? key,
    required RangeValues value,
    required ValueChanged<RangeValues> onValueChange,
    bool enabled = true,
    double min = 0,
    double max = 1,
    int steps = 0,
    VoidCallback? onValueChangeFinished,
    double height = MiuixSliderDefaults.minHeight,
    MiuixSliderColors? colors,
    MiuixSliderHapticEffect hapticEffect =
        MiuixSliderDefaults.defaultHapticEffect,
    bool showKeyPoints = false,
    List<double>? keyPoints,
    double magnetThreshold = .02,
  }) {
    return MiuixRangeSlider(
      key: key,
      values: value,
      onChanged: onValueChange,
      enabled: enabled,
      onChangeFinished: onValueChangeFinished,
      min: min,
      max: max,
      divisions: _miuixSourceStepsToDivisions(steps),
      showKeyPoints: showKeyPoints,
      keyPoints: keyPoints ?? const <double>[],
      magnetThreshold: magnetThreshold,
      height: height,
      colors: colors,
      hapticEffect: hapticEffect,
    );
  }

  /// Current range.
  final RangeValues values;

  /// Change callback.
  final ValueChanged<RangeValues>? onChanged;

  /// Whether pointer input and enabled colors are active.
  final bool enabled;

  /// Called after a pointer drag finishes.
  final VoidCallback? onChangeFinished;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Optional divisions.
  final int? divisions;

  /// Whether value markers are painted along the range track.
  final bool showKeyPoints;

  /// Optional absolute values used as visible range-track markers.
  final List<double> keyPoints;

  /// Magnetic snap radius expressed as a normalized fraction of the range.
  final double magnetThreshold;

  /// Visual height, matching the source `RangeSlider` height parameter.
  final double height;

  /// Optional source eight-channel palette.
  final MiuixSliderColors? colors;

  /// Source feedback mode, defaulting to edge-only feedback.
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) {
    final range = _safeRange(min, max);
    final start = _finiteOr(
      values.start,
      range.min,
    ).clamp(range.min, range.max);
    final end = _finiteOr(values.end, range.max).clamp(range.min, range.max);
    final safeValues = RangeValues(
      start <= end ? start : end,
      start <= end ? end : start,
    );
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final sliderExtent = _miuixRoundLogicalDimension(
      _finiteOr(height, 28).clamp(18.0, 36.0),
      pixelRatio,
    );
    final touchTargetExtent = _miuixRoundLogicalDimension(48, pixelRatio);
    return Transform.scale(
      scaleX: 1,
      scaleY: touchTargetExtent / sliderExtent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 240.0;
          // RangeSlider uses the same separately measured 28dp placeable as
          // Slider in upstream MIUIX, including for caller-supplied heights.
          if (!width.isFinite ||
              width <= 0 ||
              width < math.min(12.0, sliderExtent * .5)) {
            return const SizedBox.shrink();
          }
          return _MiuixRangeSliderBody(
            values: safeValues,
            range: range,
            width: width,
            sliderExtent: sliderExtent,
            touchTargetExtent: touchTargetExtent,
            enabled: enabled,
            onChanged: onChanged,
            onChangeFinished: onChangeFinished,
            divisions: divisions,
            keyPoints: keyPoints,
            keyPointFractions: _miuixSliderKeyPointFractions(
              range: range,
              divisions: divisions,
              showKeyPoints: showKeyPoints,
              keyPoints: keyPoints,
              vertical: false,
            ),
            magnetThreshold: magnetThreshold,
            hapticEffect: hapticEffect,
            isRtl: isRtl,
            colors: colors ?? MiuixSliderDefaults.sliderColors(context),
          );
        },
      ),
    );
  }
}

/// Vertical slider adapter matching MIUIX `VerticalSlider`.
class MiuixVerticalSlider extends StatelessWidget {
  /// Creates a vertical slider.
  const MiuixVerticalSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.onChangeFinished,
    this.reverseDirection = false,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.showKeyPoints = false,
    this.keyPoints = const <double>[],
    this.magnetThreshold = .02,
    this.height = 180,
    this.width = MiuixSliderDefaults.minHeight,
    this.trackScale = 1,
    this.thumbScale = 1,
    this.colors,
    this.effect = false,
    this.hapticEffect = MiuixSliderDefaults.defaultHapticEffect,
  });

  /// Creates the source `VerticalSlider` parameter form.
  factory MiuixVerticalSlider.source({
    Key? key,
    required double value,
    required ValueChanged<double> onValueChange,
    bool enabled = true,
    double min = 0,
    double max = 1,
    int steps = 0,
    VoidCallback? onValueChangeFinished,
    bool reverseDirection = false,
    double width = MiuixSliderDefaults.minHeight,
    double height = 180,
    MiuixSliderColors? colors,
    bool effect = false,
    MiuixSliderHapticEffect hapticEffect =
        MiuixSliderDefaults.defaultHapticEffect,
    bool showKeyPoints = false,
    List<double>? keyPoints,
    double magnetThreshold = .02,
  }) {
    return MiuixVerticalSlider(
      key: key,
      value: value,
      onChanged: onValueChange,
      enabled: enabled,
      onChangeFinished: onValueChangeFinished,
      reverseDirection: reverseDirection,
      min: min,
      max: max,
      divisions: _miuixSourceStepsToDivisions(steps),
      showKeyPoints: showKeyPoints,
      keyPoints: keyPoints ?? const <double>[],
      magnetThreshold: magnetThreshold,
      height: height,
      width: width,
      colors: colors,
      effect: effect,
      hapticEffect: hapticEffect,
    );
  }

  /// Current value.
  final double value;

  /// Change callback.
  final ValueChanged<double>? onChanged;

  /// Whether pointer input and enabled colors are active.
  final bool enabled;

  /// Called after a pointer drag finishes.
  final VoidCallback? onChangeFinished;

  /// When false values increase bottom-to-top; when true they increase
  /// top-to-bottom, matching MIUIX `VerticalSlider`.
  final bool reverseDirection;

  /// Minimum value.
  final double min;

  /// Maximum value.
  final double max;

  /// Optional divisions.
  final int? divisions;

  /// Whether value markers are painted along the vertical track.
  final bool showKeyPoints;

  /// Optional absolute values used as visible vertical-track markers.
  final List<double> keyPoints;

  /// Magnetic snap radius expressed as a normalized fraction of the range.
  final double magnetThreshold;

  /// Visual height.
  final double height;

  /// Visual width.
  final double width;

  /// Track scale multiplier.
  final double trackScale;

  /// Thumb scale multiplier.
  final double thumbScale;

  /// Optional source eight-channel palette.
  final MiuixSliderColors? colors;

  /// Retained source flag; MIUIX 1.0.9 declares but does not read it.
  final bool effect;

  /// Source feedback mode, defaulting to edge-only feedback.
  final MiuixSliderHapticEffect hapticEffect;

  @override
  Widget build(BuildContext context) {
    final range = _safeRange(min, max);
    final safeValue = _finiteOr(value, range.min).clamp(range.min, range.max);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final sliderExtent = _miuixRoundLogicalDimension(
      _finiteOr(width, 28).clamp(24.0, 44.0),
      pixelRatio,
    );
    final visualHeight = _miuixRoundLogicalDimension(
      _finiteOr(height, 180).clamp(48.0, 400.0),
      pixelRatio,
    );
    final touchTargetExtent = _miuixRoundLogicalDimension(48, pixelRatio);
    final safeTrackScale = _finiteOr(trackScale, 1).clamp(.25, 4.0);
    final safeThumbScale = _finiteOr(thumbScale, 1).clamp(.25, 4.0);
    void adjustSemantics(bool increase) {
      final callback = onChanged;
      if (callback == null) return;
      callback(
        _normalizeSliderCallbackValue(
          _miuixSliderSemanticValue(
            value: safeValue,
            range: range,
            divisions: divisions,
            increase: increase,
            keyPoints: keyPoints,
            magnetThreshold: magnetThreshold,
          ),
          range,
        ),
      );
    }

    return Transform.scale(
      scaleX: touchTargetExtent / sliderExtent,
      scaleY: 1,
      child: SizedBox(
        width: sliderExtent,
        height: visualHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final resolvedHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : visualHeight;
            final resolvedWidth = constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : sliderExtent;
            if (!resolvedHeight.isFinite ||
                !resolvedWidth.isFinite ||
                resolvedHeight <= 0 ||
                resolvedWidth <= 0 ||
                resolvedHeight < math.min(36.0, sliderExtent * 1.1) ||
                resolvedWidth < math.min(12.0, sliderExtent * .5)) {
              return const SizedBox.shrink();
            }
            return _MiuixVerticalSliderBody(
              value: safeValue,
              range: range,
              height: resolvedHeight,
              width: resolvedWidth,
              touchTargetExtent: touchTargetExtent,
              enabled: enabled,
              onChanged: onChanged,
              onChangeFinished: onChangeFinished,
              divisions: divisions,
              keyPoints: keyPoints,
              keyPointFractions: _miuixSliderKeyPointFractions(
                range: range,
                divisions: divisions,
                showKeyPoints: showKeyPoints,
                keyPoints: keyPoints,
                vertical: true,
              ),
              magnetThreshold: magnetThreshold,
              hapticEffect: hapticEffect,
              reverseDirection: reverseDirection,
              trackScale: safeTrackScale,
              thumbScale: safeThumbScale,
              colors: colors ?? MiuixSliderDefaults.sliderColors(context),
              onIncrease: onChanged == null
                  ? null
                  : () => adjustSemantics(true),
              onDecrease: onChanged == null
                  ? null
                  : () => adjustSemantics(false),
            );
          },
        ),
      ),
    );
  }
}
