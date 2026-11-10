part of '../miuix_widgets.dart';

/// Colors used by [MiuixNumberPicker].
@immutable
class MiuixNumberPickerColors {
  /// Creates number-picker colors.
  const MiuixNumberPickerColors({
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.disabledSelectedTextColor,
    required this.disabledUnselectedTextColor,
  });

  /// Color of the centered item.
  final Color selectedTextColor;

  /// Color of items outside the center.
  final Color unselectedTextColor;

  /// Centered-item color while disabled.
  final Color disabledSelectedTextColor;

  /// Unselected-item color while disabled.
  final Color disabledUnselectedTextColor;

  /// Resolves the selected channel for the enabled state.
  Color selected(bool enabled) =>
      enabled ? selectedTextColor : disabledSelectedTextColor;

  /// Resolves the unselected channel for the enabled state.
  Color unselected(bool enabled) =>
      enabled ? unselectedTextColor : disabledUnselectedTextColor;

  /// Returns a copy with independently replaced source channels.
  MiuixNumberPickerColors copyWith({
    Color? selectedTextColor,
    Color? unselectedTextColor,
    Color? disabledSelectedTextColor,
    Color? disabledUnselectedTextColor,
  }) {
    return MiuixNumberPickerColors(
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      unselectedTextColor: unselectedTextColor ?? this.unselectedTextColor,
      disabledSelectedTextColor:
          disabledSelectedTextColor ?? this.disabledSelectedTextColor,
      disabledUnselectedTextColor:
          disabledUnselectedTextColor ?? this.disabledUnselectedTextColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MiuixNumberPickerColors &&
        other.selectedTextColor == selectedTextColor &&
        other.unselectedTextColor == unselectedTextColor &&
        other.disabledSelectedTextColor == disabledSelectedTextColor &&
        other.disabledUnselectedTextColor == disabledUnselectedTextColor;
  }

  @override
  int get hashCode => Object.hash(
    selectedTextColor,
    unselectedTextColor,
    disabledSelectedTextColor,
    disabledUnselectedTextColor,
  );
}

/// Defaults shared by number-picker instances.
abstract final class MiuixNumberPickerDefaults {
  /// Height of one wheel item in logical pixels.
  static const double itemHeight = 45;

  /// Builds the source-equivalent colors from the active theme.
  static MiuixNumberPickerColors colors(
    BuildContext context, {
    Color? selectedTextColor,
    Color? unselectedTextColor,
    Color? disabledSelectedTextColor,
    Color? disabledUnselectedTextColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixNumberPickerColors(
      selectedTextColor: selectedTextColor ?? semantic['onSurface'],
      unselectedTextColor:
          unselectedTextColor ?? semantic['onSurfaceSecondary'],
      disabledSelectedTextColor:
          disabledSelectedTextColor ?? semantic['disabledOnSecondary'],
      disabledUnselectedTextColor:
          disabledUnselectedTextColor ?? semantic['disabledOnSecondary'],
    );
  }
}

/// Kotlin `Float.roundToInt`: ties are rounded toward positive infinity.
@visibleForTesting
int debugMiuixNumberPickerRoundToInt(double value) {
  if (!value.isFinite) return 0;
  return (value + .5).floor();
}

/// Resolves the exact distance-based item treatment from `NumberPicker.kt`.
///
/// Compose renders the wheel as a flat stack. Distance from the center affects
/// opacity, scale, and the interpolation between selected and unselected text
/// colors; it does not enable a cylindrical perspective or magnifier.
@visibleForTesting
({double opacity, double scale, Color color}) debugMiuixNumberPickerItemVisual({
  required double distanceFromCenter,
  required int visibleItemCount,
  required Color selectedColor,
  required Color unselectedColor,
}) {
  final safeCount = math.max(3, visibleItemCount);
  final oddCount = safeCount.isEven ? safeCount + 1 : safeCount;
  final halfVisibleCount = oddCount ~/ 2;
  final normalizedDistance =
      (distanceFromCenter.abs() / (halfVisibleCount + .5)).clamp(0.0, 1.0);
  return (
    opacity: (1 - normalizedDistance) * (1 - normalizedDistance * .5),
    scale: 1 - .2 * normalizedDistance,
    color: Color.lerp(selectedColor, unselectedColor, normalizedDistance)!,
  );
}

/// Vertically scrolling numeric wheel matching MIUIX `NumberPicker`.
class MiuixNumberPicker extends StatefulWidget {
  /// Creates a number-picker wheel.
  const MiuixNumberPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 10,
    this.step = 1,
    this.enabled = true,
    this.label,
    this.visibleItemCount = 5,
    this.wrapAround = false,
    this.colors,
    this.textStyle,
    this.itemHeight = MiuixNumberPickerDefaults.itemHeight,
  });

  /// Creates the source `NumberPicker` parameter form.
  factory MiuixNumberPicker.source({
    Key? key,
    required int value,
    required ValueChanged<int> onValueChange,
    bool enabled = true,
    ({int first, int last}) range = (first: 0, last: 10),
    String Function(int value)? label,
    int visibleItemCount = 5,
    bool wrapAround = false,
    MiuixNumberPickerColors? colors,
    TextStyle? textStyle,
    double itemHeight = MiuixNumberPickerDefaults.itemHeight,
  }) {
    return MiuixNumberPicker(
      key: key,
      value: value,
      onChanged: onValueChange,
      min: range.first,
      max: range.last,
      enabled: enabled,
      label: label,
      visibleItemCount: visibleItemCount,
      wrapAround: wrapAround,
      colors: colors,
      textStyle: textStyle,
      itemHeight: itemHeight,
    );
  }

  /// Current numeric value.
  final int value;

  /// Change callback.
  final ValueChanged<int> onChanged;

  /// Minimum value.
  final int min;

  /// Maximum value.
  final int max;

  /// Step size.
  final int step;

  /// Whether the wheel accepts pointer scrolling.
  final bool enabled;

  /// Converts a numeric value to display text.
  final String Function(int value)? label;

  /// Number of visible rows. Even or too-small values are normalized safely.
  final int visibleItemCount;

  /// Whether scrolling continues from the last value back to the first.
  final bool wrapAround;

  /// Optional color override.
  final MiuixNumberPickerColors? colors;

  /// Optional item text style.
  final TextStyle? textStyle;

  /// Height of each wheel row.
  final double itemHeight;

  @override
  State<MiuixNumberPicker> createState() => _MiuixNumberPickerState();
}

/// State machine for the source-style flat number picker.
///
/// The upstream component is controlled: [MiuixNumberPicker.value] remains the
/// durable selection, while this state owns only a short-lived drag offset.
/// That distinction matters on Android because a synthetic infinite list can
/// choose a different initial child during its first layout pass.
///
/// Value model:
///
/// * [_valueAt] calculates each legal ascending value from its index.
/// * [_currentIndex] resolves the externally controlled value into that list.
/// * [_motion] stores an offset measured in rows, never in physical pixels.
/// * Positive offsets move toward larger values.
/// * A settled offset is committed through [MiuixNumberPicker.onChanged].
/// * After the parent accepts the callback, the offset returns to zero.
///
/// Keeping the offset row-relative lets a custom [MiuixNumberPicker.itemHeight]
/// change geometry without changing velocity, snapping, or boundary behavior.
///
/// Gesture model:
///
/// * Dragging upward subtracts a negative pixel delta and advances the value.
/// * Each crossed row emits the source `TextHandleMove` haptic role.
/// * Release first runs the source-equivalent exponential decay.
/// * A critically damped 400-stiffness spring then snaps to the nearest row.
/// * A canceled gesture restores the controlled value without a callback.
/// * Disabling the widget also cancels any active transient motion.
///
/// Wrapping model:
///
/// * Wrapped pickers normalize indexes with modulo arithmetic.
/// * Non-wrapped pickers clamp offsets at the first and last legal rows.
/// * [_MiuixBoundedPickerSimulation] stops velocity at either hard boundary.
/// * Reversed min/max inputs are normalized before values are generated.
/// * A zero or negative step is normalized to a positive non-zero step.
/// * A value outside the range resolves to the nearest available entry.
///
/// Rendering model:
///
/// * Rows are a flat [Stack], matching `NumberPicker.kt` rather than iOS wheel
///   perspective or Flutter's [ListWheelScrollView].
/// * The controlled value is the stack's geometric center.
/// * Neighboring rows translate by exact item-height multiples.
/// * Distance from center independently controls opacity and scale.
/// * Text color interpolates between selected and unselected source roles.
/// * One extra row is painted beyond each visible edge for smooth dragging.
/// * [ClipRect] prevents those preparation rows from leaking outside bounds.
/// * Rows retain the source negative-to-positive slot paint order.
///
/// Lifecycle model:
///
/// * Range changes rebuild legal values and reset transient motion.
/// * External value changes become the new zero point when idle.
/// * An internal settle is guarded so parent rebuilds cannot reset it early.
/// * Ticker cancellation is expected during replacement gestures and disposal.
/// * No timer, scroll controller, or synthetic list origin survives disposal.
///
/// Accessibility model:
///
/// * Semantics always reports the controlled value, not a passing animation.
/// * Disabled state is exposed through the same semantics node.
/// * Labels are formatted through the caller's formatter in every row.
/// * Visual normalization never changes the public numeric selection.
///
/// Large-domain contract:
///
/// * Domain size is independent of heap allocation.
/// * Build cost depends on visible rows, not the numeric span.
/// * Index zero always represents the normalized lower bound.
/// * The last index is the greatest stepped value not above the upper bound.
/// * A non-divisible upper bound remains part of semantics, not the value set.
/// * Values below the lower bound select index zero.
/// * Values above the upper bound select the last legal index.
/// * Interior values use integer quotient and remainder arithmetic.
/// * A value exactly halfway between entries resolves toward the lower one.
/// * Distance comparison avoids multiplying large integers.
/// * Row keys continue to describe logical indexes rather than values.
/// * Wrapping applies modulo to indexes before a value is calculated.
/// * Bounded motion derives both limits from the same cached count.
/// * Range replacement invalidates every pending settle generation.
/// * Step replacement rebuilds four scalars and never walks the old domain.
/// * Visible labels are calculated only after a slot passes its bounds check.
/// * Accessibility formats the resolved legal center value.
/// * Callback values therefore always belong to the represented domain.
/// * No sentinel item is needed because every normalized range has one value.
/// * Reversed endpoints preserve ascending visual and gesture direction.
/// * The public step sign does not reverse that direction.
/// * A zero step becomes one before count arithmetic is performed.
/// * The state owns no collection proportional to caller-controlled input.
///
/// These invariants deliberately keep input, animation, rendering, haptics,
/// and semantics tied to the same small offset. Maintaining one source of
/// transient truth prevents the initial-value drift that motivated this port.
class _MiuixNumberPickerState extends State<MiuixNumberPicker>
    with SingleTickerProviderStateMixin {
  // The legal domain is represented by three integers rather than a generated
  // list. A picker spanning every 32-bit value still paints only its visible
  // rows and therefore must not allocate billions of entries.
  late int _rangeLow;
  late int _rangeHigh;
  late int _rangeStep;
  late int _valueCount;
  // Motion is expressed in row units; zero always means the controlled value.
  late final AnimationController _motion;
  // Dragging distinguishes live pointer movement from ballistic settling.
  bool _dragging = false;
  // User scrolling gates haptics so programmatic resets stay silent.
  bool _userScrolling = false;
  // Settling prevents a parent callback rebuild from clearing motion early.
  bool _settling = false;
  // Reduced motion is read once per dependency update so pointer callbacks can
  // choose settlement policy without consulting inherited state out of build.
  bool _reduceMotion = false;
  // Every new drag or dependency-driven endpoint invalidates older async
  // decay/spring continuations before they can publish a stale selection.
  int _settleGeneration = 0;
  // The last crossed index de-duplicates haptics within a single row.
  int? _lastHapticIndex;

  int get _safeVisibleCount {
    final atLeastThree = math.max(3, widget.visibleItemCount);
    return atLeastThree.isEven ? atLeastThree + 1 : atLeastThree;
  }

  double get _safeItemHeight {
    return widget.itemHeight.isFinite && widget.itemHeight > 0
        ? widget.itemHeight
        : MiuixNumberPickerDefaults.itemHeight;
  }

  double get _sourceTotalHeight {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    return _miuixRoundLogicalDimension(
      _safeItemHeight * _safeVisibleCount,
      pixelRatio,
    );
  }

  double get _sourceItemHeight {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    if (!pixelRatio.isFinite || pixelRatio <= 0) {
      return _safeItemHeight;
    }
    // NumberPicker.kt rounds its complete `itemHeight * visibleItemCount`
    // layout first. onSizeChanged then performs integer division to obtain
    // each row's motion distance, so a 225 dp wheel at 420 dpi is 591 px tall
    // while its five row offsets are 118 px apart.
    final totalPhysicalHeight = (_sourceTotalHeight * pixelRatio).round();
    final itemPhysicalHeight = totalPhysicalHeight ~/ _safeVisibleCount;
    return itemPhysicalHeight / pixelRatio;
  }

  void _rebuildDomain() {
    _rangeLow = math.min(widget.min, widget.max);
    _rangeHigh = math.max(widget.min, widget.max);
    _rangeStep = math.max(1, widget.step.abs());
    _valueCount = ((_rangeHigh - _rangeLow) ~/ _rangeStep) + 1;
  }

  int _valueAt(int index) => _rangeLow + index * _rangeStep;

  int _valueIndex(int value) {
    if (value <= _rangeLow) return 0;
    if (value >= _rangeHigh) return _valueCount - 1;
    final delta = value - _rangeLow;
    final lowerIndex = delta ~/ _rangeStep;
    final remainder = delta % _rangeStep;
    // Preserve the old list scan's lower-value tie break without multiplying
    // the remainder, which could overflow on fixed-width runtimes.
    final nearest = remainder > _rangeStep - remainder
        ? lowerIndex + 1
        : lowerIndex;
    return nearest.clamp(0, _valueCount - 1);
  }

  @override
  void initState() {
    super.initState();
    _rebuildDomain();
    // The Compose source keeps a small item-relative offset around the
    // controlled value. Using a million-item ListWheel origin looked similar
    // in widget tests but drifted to a different initial value on Android.
    _motion = AnimationController.unbounded(vsync: this)
      ..addListener(_handleMotionTick);
  }

  @override
  void didUpdateWidget(covariant MiuixNumberPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final rangeChanged =
        oldWidget.min != widget.min ||
        oldWidget.max != widget.max ||
        oldWidget.step != widget.step;
    if (rangeChanged) {
      _settleGeneration++;
      _rebuildDomain();
      _motion
        ..stop()
        ..value = 0;
      return;
    }
    // An external controlled-value update becomes the new zero point. During
    // our own settle callback the reset is performed explicitly after the
    // parent accepts the value, so no intermediate frame can jump twice.
    if (oldWidget.value != widget.value && !_dragging && !_settling) {
      _motion
        ..stop()
        ..value = 0;
    }
    if (oldWidget.enabled && !widget.enabled) {
      _settleGeneration++;
      _dragging = false;
      _userScrolling = false;
      _motion
        ..stop()
        ..value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion = MediaQuery.disableAnimationsOf(context);
    if (nextReduceMotion == _reduceMotion) {
      return;
    }
    _reduceMotion = nextReduceMotion;
    if (!_reduceMotion || !_settling) {
      return;
    }

    // The wheel may be in its decay phase or its final spring. Preserve the
    // nearest item at the moment policy changes, cancel autonomous movement,
    // and publish that endpoint after the inherited-widget build is complete.
    final generation = ++_settleGeneration;
    final target = _nearestSettledOffset();
    _motion.stop(canceled: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_reduceMotion || generation != _settleGeneration) {
        return;
      }
      _finishSettlement(target);
    });
  }

  @override
  void dispose() {
    _motion
      ..removeListener(_handleMotionTick)
      ..dispose();
    super.dispose();
  }

  int _normalizedIndex(int rawIndex) {
    if (widget.wrapAround && _valueCount > 1) {
      return rawIndex % _valueCount;
    }
    return rawIndex.clamp(0, _valueCount - 1);
  }

  int get _currentIndex => _valueIndex(widget.value);

  int get _effectiveIndex => _normalizedIndex(
    _currentIndex + debugMiuixNumberPickerRoundToInt(_motion.value),
  );

  double _clampOffset(double value) {
    if (widget.wrapAround || _valueCount <= 1) {
      return value;
    }
    return value.clamp(
      -_currentIndex.toDouble(),
      (_valueCount - 1 - _currentIndex).toDouble(),
    );
  }

  void _handleMotionTick() {
    if (!_userScrolling || _valueCount == 0) {
      return;
    }
    final effective = _effectiveIndex;
    if (_lastHapticIndex == effective) {
      return;
    }
    _lastHapticIndex = effective;
    unawaited(MiuixHaptics.perform(MiuixHapticType.textHandleMove));
  }

  void _startDrag(DragStartDetails details) {
    if (!widget.enabled) {
      return;
    }
    _settleGeneration++;
    _motion.stop(canceled: true);
    _dragging = true;
    _userScrolling = true;
    _lastHapticIndex = _effectiveIndex;
  }

  void _updateDrag(DragUpdateDetails details) {
    if (!widget.enabled || !_dragging) {
      return;
    }
    // Compose subtracts pointer delta measured in item heights: dragging up
    // advances to larger values and dragging down moves to smaller values.
    _motion.value = _clampOffset(
      _motion.value - details.delta.dy / _sourceItemHeight,
    );
  }

  Future<void> _endDrag(DragEndDetails details) async {
    if (!widget.enabled || !_dragging) {
      return;
    }
    _dragging = false;
    _settling = true;
    final generation = ++_settleGeneration;
    try {
      if (_reduceMotion) {
        _finishSettlement(_nearestSettledOffset());
        return;
      }
      final velocityItems =
          -details.velocity.pixelsPerSecond.dy / _sourceItemHeight;
      if (velocityItems.abs() > .1) {
        final decay = FrictionSimulation(
          // Compose exponentialDecay uses a -4.2 coefficient; the source
          // doubles it with frictionMultiplier=2. Flutter expresses the same
          // coefficient as drag^time, hence exp(-8.4).
          math.exp(-8.4),
          _motion.value,
          velocityItems,
          tolerance: const Tolerance(distance: .001, velocity: .1),
        );
        final simulation = widget.wrapAround
            ? decay
            : _MiuixBoundedPickerSimulation(
                decay,
                lower: -_currentIndex.toDouble(),
                upper: (_valueCount - 1 - _currentIndex).toDouble(),
              );
        await _motion.animateWith(simulation).orCancel;
        if (!mounted || generation != _settleGeneration) {
          return;
        }
      }

      final target = _nearestSettledOffset();
      final spring = SpringSimulation(
        const SpringDescription(mass: 1, stiffness: 400, damping: 40),
        _motion.value,
        target,
        _motion.velocity,
        tolerance: const Tolerance(distance: .001, velocity: .1),
      );
      await _motion.animateWith(spring).orCancel;
      if (!mounted || generation != _settleGeneration) {
        return;
      }
      _finishSettlement(target);
    } on TickerCanceled {
      // A new drag or widget disposal legitimately cancels the old settle.
    } finally {
      // A replacement drag owns these flags after incrementing the generation.
      // Its canceled predecessor must not silently disable haptic tracking or
      // clear the new gesture's settlement state from an async finally block.
      if (generation == _settleGeneration) {
        _settling = false;
        _userScrolling = false;
        _lastHapticIndex = null;
      }
    }
  }

  double _nearestSettledOffset() =>
      _clampOffset(debugMiuixNumberPickerRoundToInt(_motion.value).toDouble());

  void _finishSettlement(double target) {
    final nextIndex = _normalizedIndex(
      _currentIndex + debugMiuixNumberPickerRoundToInt(target),
    );
    final nextValue = _valueAt(nextIndex);
    // Stop haptic tracking before the controlled callback. A synchronous
    // parent rebuild can then accept the new center without a reverse tick.
    _userScrolling = false;
    if (nextValue != widget.value) {
      widget.onChanged(nextValue);
    }
    _motion.value = 0;
    _settling = false;
    _lastHapticIndex = null;
  }

  void _cancelDrag() {
    if (!_dragging) {
      return;
    }
    _dragging = false;
    _settleGeneration++;
    _userScrolling = false;
    _lastHapticIndex = null;
    _motion
      ..stop()
      ..value = 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors ?? MiuixNumberPickerDefaults.colors(context);
    // Source `title1` is 32sp. NumberPicker supplies SemiBold only when the
    // caller's style does not already choose a weight.
    final sourceTitle =
        Theme.of(context).textTheme.displayLarge ??
        const TextStyle(fontSize: 32);
    final requestedStyle = widget.textStyle;
    final resolvedStyle = requestedStyle ?? sourceTitle;
    final baseStyle = resolvedStyle.copyWith(
      // NumberPicker.kt only fills the missing weight. It does not overwrite
      // a caller style's unspecified size with title1.
      // Flutter's theme bridge stores title1's unspecified Compose weight as
      // w400, so the source default must still take the SemiBold fallback.
      fontWeight: requestedStyle?.fontWeight ?? FontWeight.w600,
    );
    final selectedValueIndex = _valueIndex(widget.value);
    final labelBuilder = widget.label ?? (value) => '$value';
    final displayValue = labelBuilder(_valueAt(selectedValueIndex));
    final rangeFirst = math.min(widget.min, widget.max);
    final rangeLast = math.max(widget.min, widget.max);
    final sourceItemHeight = _sourceItemHeight;
    return Semantics(
      // NumberPicker.kt publishes one contentDescription rather than range
      // semantics or increment/decrement actions. Using a Flutter label (and
      // not a duplicate value) produces the same TalkBack announcement.
      label: '$displayValue, $rangeFirst - $rangeLast',
      excludeSemantics: true,
      child: SizedBox(
        key: const ValueKey('miuix-number-picker-wheel'),
        height: _sourceTotalHeight,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onVerticalDragStart: widget.enabled ? _startDrag : null,
          onVerticalDragUpdate: widget.enabled ? _updateDrag : null,
          onVerticalDragEnd: widget.enabled ? _endDrag : null,
          onVerticalDragCancel: widget.enabled ? _cancelDrag : null,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _motion,
              builder: (context, _) {
                final totalOffset = _motion.value;
                final roundedOffset = debugMiuixNumberPickerRoundToInt(
                  totalOffset,
                );
                final centerItemOffset = totalOffset - roundedOffset;
                final selectedColor = colors.selected(widget.enabled);
                final unselectedColor = colors.unselected(widget.enabled);
                final halfVisibleCount = _safeVisibleCount ~/ 2;
                final items = <Widget>[];
                for (
                  var slot = -halfVisibleCount - 1;
                  slot <= halfVisibleCount + 1;
                  slot++
                ) {
                  final rawIndex = selectedValueIndex + slot + roundedOffset;
                  if (!widget.wrapAround &&
                      (rawIndex < 0 || rawIndex >= _valueCount)) {
                    continue;
                  }
                  final valueIndex = _normalizedIndex(rawIndex);
                  final distance = slot - centerItemOffset;
                  final visual = debugMiuixNumberPickerItemVisual(
                    distanceFromCenter: distance,
                    visibleItemCount: _safeVisibleCount,
                    selectedColor: selectedColor,
                    unselectedColor: unselectedColor,
                  );
                  final item = Positioned.fill(
                    child: Center(
                      child: Transform.translate(
                        offset: Offset(0, distance * sourceItemHeight),
                        child: Opacity(
                          key: ValueKey('miuix-number-picker-item-$rawIndex'),
                          opacity: visual.opacity,
                          child: Transform.scale(
                            scale: visual.scale,
                            child: Text(
                              labelBuilder(_valueAt(valueIndex)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: baseStyle.copyWith(color: visual.color),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                  // Preserve the exact negative-to-positive source loop order;
                  // later positive slots paint after the center just as they
                  // do in the Compose Box.
                  items.add(item);
                }
                return Stack(clipBehavior: Clip.none, children: items);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Stops the source-style exponential decay exactly when a non-wrapping wheel
/// reaches either end of its controlled range.
class _MiuixBoundedPickerSimulation extends Simulation {
  _MiuixBoundedPickerSimulation(
    this.parent, {
    required this.lower,
    required this.upper,
  });

  final Simulation parent;
  final double lower;
  final double upper;

  @override
  double x(double time) => parent.x(time).clamp(lower, upper);

  @override
  double dx(double time) {
    final position = parent.x(time);
    final velocity = parent.dx(time);
    if ((position <= lower && velocity < 0) ||
        (position >= upper && velocity > 0)) {
      return 0;
    }
    return velocity;
  }

  @override
  bool isDone(double time) {
    final position = parent.x(time);
    return position <= lower || position >= upper || parent.isDone(time);
  }
}

/// Compose's BasicComponent text metrics occupy about 1.17 em per line.
///
/// Flutter's Material text theme otherwise contributes a 1.4 line-height to
/// these descendants. With both a 17sp title and 14sp summary that made every
/// row roughly seven logical pixels taller than the upstream BasicComponent.
/// Keeping the source line box explicit also makes localized CJK text preserve
/// the same component geometry as the original English sample.
const double _miuixPreferenceLineHeight = 1.17;

/// Enabled and disabled foregrounds used by MIUIX `BasicComponent`.
///
/// The source keeps title and summary channels in independent immutable
/// values. The same model can also color arbitrary source-style slot content.
@immutable
class MiuixBasicComponentColors {
  /// Creates a two-state foreground palette.
  const MiuixBasicComponentColors({
    required this.color,
    required this.disabledColor,
  });

  /// Foreground used while the component is enabled.
  final Color color;

  /// Foreground used while the component is disabled.
  final Color disabledColor;

  /// Resolves the active foreground for [enabled].
  Color resolve(bool enabled) => enabled ? color : disabledColor;

  /// Returns a copy with independently replaced channels.
  MiuixBasicComponentColors copyWith({Color? color, Color? disabledColor}) {
    return MiuixBasicComponentColors(
      color: color ?? this.color,
      disabledColor: disabledColor ?? this.disabledColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixBasicComponentColors &&
            other.color == color &&
            other.disabledColor == disabledColor;
  }

  @override
  int get hashCode => Object.hash(color, disabledColor);
}

/// Source defaults for [MiuixBasicComponent] and preference wrappers.
abstract final class MiuixBasicComponentDefaults {
  /// Padding applied on every edge by upstream `BasicComponent`.
  static const EdgeInsets insideMargin = EdgeInsets.all(16);

  /// Resolves the title foreground pair from the active MIUIX theme.
  static MiuixBasicComponentColors titleColor(
    BuildContext context, {
    Color? color,
    Color? disabledColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixBasicComponentColors(
      color: color ?? semantic['onBackground'],
      disabledColor: disabledColor ?? semantic['disabledOnSecondaryVariant'],
    );
  }

  /// Resolves the summary foreground pair from the active MIUIX theme.
  static MiuixBasicComponentColors summaryColor(
    BuildContext context, {
    Color? color,
    Color? disabledColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixBasicComponentColors(
      color: color ?? semantic['onSurfaceVariantSummary'],
      disabledColor: disabledColor ?? semantic['disabledOnSecondaryVariant'],
    );
  }
}

/// Preference row base used by settings screens.
class MiuixPreference extends StatelessWidget {
  /// Creates a preference row using the HyperOS 4 content hierarchy.
  const MiuixPreference({
    super.key,
    required this.title,
    this.summary,
    this.titleStyle,
    this.summaryStyle,
    this.titleColors,
    this.summaryColors,
    this.showTitle = true,
    this.leading,
    this.trailing,
    this.centerContent,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.onTap,
    this.onTapHint,
    this.role,
    this.semanticChecked,
    this.semanticToggled,
    this.holdDown = false,
    this.enabled = true,
    this.interactionSource,
    this.sourceStyle = false,
  });

  /// Creates a preference row using the MIUIX 1.0.9 text and row metrics.
  const MiuixPreference.source({
    super.key,
    required this.title,
    this.summary,
    this.titleStyle,
    this.summaryStyle,
    this.titleColors,
    this.summaryColors,
    this.showTitle = true,
    this.leading,
    this.trailing,
    this.centerContent,
    this.bottomAction,
    this.insideMargin = MiuixBasicComponentDefaults.insideMargin,
    this.onTap,
    this.onTapHint,
    this.role,
    this.semanticChecked,
    this.semanticToggled,
    this.holdDown = false,
    this.enabled = true,
    this.interactionSource,
  }) : sourceStyle = true;

  /// Main title.
  final String title;

  /// Optional summary text.
  final String? summary;

  /// Optional style merged over the source title metrics and semantic color.
  ///
  /// This is useful when the content requires a platform typeface while the
  /// surrounding localized application uses a bundled fallback font.
  final TextStyle? titleStyle;

  /// Optional style merged over the source summary metrics and semantic color.
  final TextStyle? summaryStyle;

  /// Optional source title foreground pair.
  final MiuixBasicComponentColors? titleColors;

  /// Optional source summary foreground pair.
  final MiuixBasicComponentColors? summaryColors;

  /// Whether the compatibility title node is emitted.
  final bool showTitle;

  /// Optional leading widget.
  final Widget? leading;

  /// Optional trailing widget.
  final Widget? trailing;

  /// Optional arbitrary source center slot.
  ///
  /// When supplied, this replaces the compatibility title/summary column.
  final Widget? centerContent;

  /// Optional content displayed eight pixels below the main preference row.
  final Widget? bottomAction;

  /// Padding around the row and optional bottom action.
  ///
  /// This is the Flutter equivalent of MIUIX `insideMargin`; blur controls use
  /// a zero bottom inset so their slider reaches the component's lower edge.
  final EdgeInsetsGeometry insideMargin;

  /// Tap callback.
  final VoidCallback? onTap;

  /// Optional accessibility hint that describes the tap action.
  final String? onTapHint;

  /// Optional accessibility role installed on an interactive source row.
  final MiuixAccessibilityRole? role;

  /// Current checked state for checkbox and radio-button row semantics.
  final bool? semanticChecked;

  /// Current toggled state for switch row semantics.
  final bool? semanticToggled;

  /// Whether the row keeps its MIUIX pressed feedback after pointer release.
  final bool holdDown;

  /// Whether the row is enabled.
  final bool enabled;

  /// Optional observer shared with the source press indication.
  final MiuixInteractionSource? interactionSource;

  /// Whether this row uses the explicit MIUIX 1.0.9 visual metrics.
  ///
  /// Application code should normally use [MiuixPreference.source]. This
  /// forwarding flag lets composite preference widgets preserve their own
  /// named source constructors without duplicating the complete row API.
  final bool sourceStyle;

  @override
  Widget build(BuildContext context) {
    final theme = MiuixTheme.of(context);
    final semantic = MiuixSemanticColors.of(context);
    final titleColor =
        titleColors?.resolve(enabled) ??
        (enabled
            ? semantic[sourceStyle ? 'onBackground' : 'onSurface']
            : semantic['disabledOnSecondaryVariant']);
    final summaryColor =
        summaryColors?.resolve(enabled) ??
        (enabled
            ? semantic['onSurfaceVariantSummary']
            : semantic['disabledOnSecondaryVariant']);
    final materialTextTheme = Theme.of(context).textTheme;
    final resolvedTitleStyle =
        (sourceStyle
                ? const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 17,
                    height: _miuixPreferenceLineHeight,
                  )
                : (materialTextTheme.bodyMedium ??
                          const TextStyle(fontSize: 16))
                      .copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        height: 1.2,
                      ))
            .copyWith(color: titleColor)
            .merge(titleStyle);
    final resolvedSummaryStyle =
        (sourceStyle
                ? const TextStyle(
                    fontSize: 14,
                    height: _miuixPreferenceLineHeight,
                  )
                : (materialTextTheme.bodySmall ?? const TextStyle(fontSize: 13))
                      .copyWith(fontSize: 13, height: 1.25))
            .copyWith(color: summaryColor)
            .merge(summaryStyle);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final rawTitle = Text(
      title,
      style: resolvedTitleStyle,
      // A mixed CJK/Latin label such as "选项 A" otherwise chooses the tallest
      // glyph run and becomes two physical pixels taller than Compose.
      strutStyle: StrutStyle.fromTextStyle(
        resolvedTitleStyle,
        forceStrutHeight: true,
      ),
    );
    final sourceTitle = !sourceStyle || bottomAction == null
        ? rawTitle
        : _MiuixPixelRoundedHeight(
            devicePixelRatio: pixelRatio,
            // SkParagraph reports the translated 17sp line at exactly half a
            // physical pixel on 420dpi. Compose's integer placeable truncates
            // that line to 52px before it measures the following 8dp gap and
            // slider, so preserve the same ordering for bottom-action rows.
            roundDown: true,
            child: rawTitle,
          );
    final row = _MiuixPreferenceRow(
      gap: theme.spacing.sm,
      devicePixelRatio: pixelRatio,
      leading: leading == null
          ? null
          : DefaultTextStyle.merge(
              style:
                  (sourceStyle
                          ? materialTextTheme.bodyLarge
                          : materialTextTheme.bodyMedium)
                      ?.copyWith(
                        color: titleColor,
                        fontSize: sourceStyle ? 17 : 16,
                        height: sourceStyle ? _miuixPreferenceLineHeight : 1.2,
                      ),
              child: IconTheme.merge(
                // Compose Icon keeps its standard 24dp viewport inside a
                // BasicComponent start action. A smaller inherited size made
                // source icons such as Contacts visibly undersized and pulled
                // the title several pixels toward the start edge.
                data: IconThemeData(
                  color: titleColor,
                  size: sourceStyle ? 24 : 22,
                ),
                child: leading!,
              ),
            ),
      trailing: trailing == null
          ? null
          : DefaultTextStyle.merge(
              style:
                  (sourceStyle
                          ? materialTextTheme.bodyLarge
                          : materialTextTheme.bodyMedium)
                      ?.copyWith(
                        color: titleColor,
                        fontSize: sourceStyle ? 17 : 16,
                        height: sourceStyle ? _miuixPreferenceLineHeight : 1.2,
                      ),
              textAlign: TextAlign.end,
              child: IconTheme.merge(
                data: IconThemeData(color: titleColor),
                child: trailing!,
              ),
            ),
      center:
          centerContent ??
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showTitle) sourceTitle,
              if (summary != null)
                Text(
                  summary!,
                  style: resolvedSummaryStyle,
                  strutStyle: StrutStyle.fromTextStyle(
                    resolvedSummaryStyle,
                    forceStrutHeight: true,
                  ),
                ),
            ],
          ),
    );
    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: sourceStyle ? 56 : 60),
      child: Padding(
        padding: insideMargin,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            row,
            if (bottomAction != null) ...[
              const SizedBox(height: 8),
              bottomAction!,
            ],
          ],
        ),
      ),
    );
    final sourceMeasuredContent = sourceStyle
        ? _MiuixPixelRoundedHeight(
            devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
            child: content,
          )
        : content;
    if (!enabled || onTap == null) {
      return sourceMeasuredContent;
    }
    final pressable = MiuixPressable(
      onTap: onTap,
      holdDown: holdDown,
      borderRadius: BorderRadius.circular(theme.radius.md),
      feedbackType: MiuixPressFeedbackType.none,
      showIndication: true,
      interactionSource: interactionSource,
      child: sourceMeasuredContent,
    );
    if (onTapHint == null && role == null) return pressable;
    // Compose supplies both values to clickable itself. A non-container
    // Semantics wrapper merges them into GestureDetector's existing tap node
    // instead of creating a second accessibility stop.
    // Flutter models several Compose roles as flags rather than enum values.
    // These annotations share GestureDetector's tap node because Semantics is
    // deliberately not a container, matching clickable's merged source node.
    return Semantics(
      onTapHint: onTapHint,
      button:
          role == MiuixAccessibilityRole.button ||
              role == MiuixAccessibilityRole.dropdownList
          ? true
          : null,
      toggled: role == MiuixAccessibilityRole.switchControl
          ? semanticToggled ?? false
          : null,
      inMutuallyExclusiveGroup: role == MiuixAccessibilityRole.radioButton
          ? true
          : null,
      checked: switch (role) {
        MiuixAccessibilityRole.checkbox ||
        MiuixAccessibilityRole.radioButton => semanticChecked ?? false,
        _ => null,
      },
      image: role == MiuixAccessibilityRole.image ? true : null,
      selected: role == MiuixAccessibilityRole.tab ? false : null,
      role: switch (role) {
        MiuixAccessibilityRole.tab => SemanticsRole.tab,
        _ => null,
      },
      child: pressable,
    );
  }
}

/// Finalizes one Compose measurable at an integer physical-pixel height.
///
/// Compose lays out each `BasicComponent` independently with integer pixel
/// constraints. Flutter normally lets several 68dp preference rows retain
/// fractional physical heights until their parent paints, which makes two
/// rows total 357px instead of the source's 179px + 179px = 358px at 420dpi.
class _MiuixPixelRoundedHeight extends SingleChildRenderObjectWidget {
  const _MiuixPixelRoundedHeight({
    required this.devicePixelRatio,
    this.roundDown = false,
    required super.child,
  });

  final double devicePixelRatio;
  final bool roundDown;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMiuixPixelRoundedHeight(devicePixelRatio, roundDown);

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMiuixPixelRoundedHeight renderObject,
  ) {
    renderObject
      ..devicePixelRatio = devicePixelRatio
      ..roundDown = roundDown;
  }
}

/// Render stage that preserves the child's width and snaps only its height.
class _RenderMiuixPixelRoundedHeight extends RenderProxyBox {
  _RenderMiuixPixelRoundedHeight(this._devicePixelRatio, this._roundDown);

  double _devicePixelRatio;
  bool _roundDown;

  set devicePixelRatio(double value) {
    if (_devicePixelRatio == value) return;
    _devicePixelRatio = value;
    markNeedsLayout();
  }

  set roundDown(bool value) {
    if (_roundDown == value) return;
    _roundDown = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final currentChild = child;
    if (currentChild == null) {
      size = constraints.smallest;
      return;
    }
    currentChild.layout(constraints, parentUsesSize: true);
    final childSize = currentChild.size;
    final ratio = _devicePixelRatio;
    final roundedHeight = ratio.isFinite && ratio > 0
        ? (_roundDown
                  ? (childSize.height * ratio).floorToDouble()
                  : (childSize.height * ratio).roundToDouble()) /
              ratio
        : childSize.height;
    size = constraints.constrain(Size(childSize.width, roundedHeight));
  }
}

class _MiuixPreferenceRow extends MultiChildRenderObjectWidget {
  _MiuixPreferenceRow({
    required Widget center,
    required this.gap,
    required this.devicePixelRatio,
    Widget? leading,
    Widget? trailing,
  }) : super(
         children: [
           if (leading != null)
             _MiuixPreferenceSlotWidget(
               slot: _MiuixPreferenceSlot.leading,
               child: leading,
             ),
           _MiuixPreferenceSlotWidget(
             slot: _MiuixPreferenceSlot.center,
             child: center,
           ),
           if (trailing != null)
             _MiuixPreferenceSlotWidget(
               slot: _MiuixPreferenceSlot.trailing,
               child: trailing,
             ),
         ],
       );

  final double gap;
  final double devicePixelRatio;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderMiuixPreferenceRow(
      gap: gap,
      devicePixelRatio: devicePixelRatio,
      textDirection: Directionality.of(context),
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderMiuixPreferenceRow renderObject,
  ) {
    renderObject
      ..gap = gap
      ..devicePixelRatio = devicePixelRatio
      ..textDirection = Directionality.of(context);
  }
}

enum _MiuixPreferenceSlot { leading, center, trailing }

class _MiuixPreferenceParentData extends ContainerBoxParentData<RenderBox> {
  _MiuixPreferenceSlot? slot;
}

class _MiuixPreferenceSlotWidget
    extends ParentDataWidget<_MiuixPreferenceParentData> {
  const _MiuixPreferenceSlotWidget({required this.slot, required super.child});

  final _MiuixPreferenceSlot slot;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as _MiuixPreferenceParentData;
    if (parentData.slot == slot) {
      return;
    }
    parentData.slot = slot;
    final parent = renderObject.parent;
    if (parent is RenderObject) {
      parent.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => _MiuixPreferenceRow;
}

class _MiuixPreferenceWidths {
  const _MiuixPreferenceWidths({
    required this.leading,
    required this.center,
    required this.trailing,
  });

  final double leading;
  final double center;
  final double trailing;
}

/// Three-slot layout used by upstream MIUIX `BasicComponent`.
///
/// Compose measures maximum and minimum intrinsic widths before it constrains
/// the start, center, and end slots. A normal Flutter [Row] cannot reproduce
/// that contract because flex allocation happens before those intrinsic widths
/// are compared, so this render object ports the source allocation literally.
class _RenderMiuixPreferenceRow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _MiuixPreferenceParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _MiuixPreferenceParentData> {
  _RenderMiuixPreferenceRow({
    required double gap,
    required double devicePixelRatio,
    required TextDirection textDirection,
  }) : _gap = gap,
       _devicePixelRatio = devicePixelRatio,
       _textDirection = textDirection;

  double _gap;
  double _devicePixelRatio;
  TextDirection _textDirection;

  double get gap => _gap;

  set gap(double value) {
    if (_gap == value) {
      return;
    }
    _gap = value;
    markNeedsLayout();
  }

  double get devicePixelRatio => _devicePixelRatio;

  set devicePixelRatio(double value) {
    if (_devicePixelRatio == value) {
      return;
    }
    _devicePixelRatio = value;
    markNeedsLayout();
  }

  TextDirection get textDirection => _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection == value) {
      return;
    }
    _textDirection = value;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _MiuixPreferenceParentData) {
      child.parentData = _MiuixPreferenceParentData();
    }
  }

  RenderBox? _childFor(_MiuixPreferenceSlot slot) {
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as _MiuixPreferenceParentData;
      if (parentData.slot == slot) {
        return child;
      }
      child = parentData.nextSibling;
    }
    return null;
  }

  double _sourceCenteredOffset(RenderBox? child) {
    if (child == null) return 0;
    final ratio = devicePixelRatio;
    if (!ratio.isFinite || ratio <= 0) {
      return (size.height - child.size.height) / 2;
    }
    // Compose performs center alignment after both placeables have integer
    // pixel sizes. Its Int division keeps the leading/top half of an odd
    // spare pixel, while Flutter's fractional half was rasterized downward.
    final parentPixels = (size.height * ratio).round();
    final childPixels = (child.size.height * ratio).round();
    return ((parentPixels - childPixels) ~/ 2) / ratio;
  }

  _MiuixPreferenceWidths _resolveWidths({
    required double availableWidth,
    required RenderBox? leading,
    required RenderBox center,
    required RenderBox? trailing,
    required double intrinsicHeight,
  }) {
    final requestedLeading =
        leading?.getMaxIntrinsicWidth(intrinsicHeight) ?? 0;
    final requestedCenter = center.getMaxIntrinsicWidth(intrinsicHeight);
    final requestedTrailing =
        trailing?.getMaxIntrinsicWidth(intrinsicHeight) ?? 0;
    final requestedTotal =
        requestedLeading + requestedCenter + requestedTrailing;

    var targetLeading = 0.0;
    var targetCenter = 0.0;
    var targetTrailing = 0.0;

    // When every slot fits, MIUIX gives all unused width to the text column.
    if (requestedTotal <= availableWidth) {
      targetLeading = requestedLeading;
      targetTrailing = requestedTrailing;
      targetCenter = math.max(
        0,
        availableWidth - requestedLeading - requestedTrailing,
      );
    } else {
      final minimumLeading =
          leading?.getMinIntrinsicWidth(intrinsicHeight) ?? 0;
      final minimumCenter = center.getMinIntrinsicWidth(intrinsicHeight);
      final minimumTrailing =
          trailing?.getMinIntrinsicWidth(intrinsicHeight) ?? 0;

      // The source assigns 2/5/3 pressure weights to occupied slots.
      final leadingWeight = leading == null ? 0 : 2;
      const centerWeight = 5;
      final trailingWeight = trailing == null ? 0 : 3;
      final totalWeight = leadingWeight + centerWeight + trailingWeight;
      final baseLeading = availableWidth * leadingWeight / totalWeight;
      final baseCenter = availableWidth * centerWeight / totalWeight;
      final baseTrailing = availableWidth * trailingWeight / totalWeight;
      final hugeLeading = leading != null && requestedLeading > baseLeading;
      final hugeCenter = requestedCenter > baseCenter;
      final hugeTrailing = trailing != null && requestedTrailing > baseTrailing;
      final hugeCount =
          (hugeLeading ? 1 : 0) + (hugeCenter ? 1 : 0) + (hugeTrailing ? 1 : 0);

      if (hugeCount == 3) {
        targetLeading = baseLeading;
        targetCenter = baseCenter;
        targetTrailing = baseTrailing;
      } else if (hugeCount == 2) {
        var remainingWidth = availableWidth;
        if (!hugeLeading) {
          targetLeading = requestedLeading;
          remainingWidth -= targetLeading;
        }
        if (!hugeCenter) {
          targetCenter = requestedCenter;
          remainingWidth -= targetCenter;
        }
        if (!hugeTrailing) {
          targetTrailing = requestedTrailing;
          remainingWidth -= targetTrailing;
        }
        final hugeTotal =
            (hugeLeading ? requestedLeading : 0) +
            (hugeCenter ? requestedCenter : 0) +
            (hugeTrailing ? requestedTrailing : 0);
        if (hugeTotal > 0) {
          if (hugeLeading) {
            targetLeading = remainingWidth * requestedLeading / hugeTotal;
          }
          if (hugeCenter) {
            targetCenter = remainingWidth * requestedCenter / hugeTotal;
          }
          if (hugeTrailing) {
            targetTrailing = remainingWidth * requestedTrailing / hugeTotal;
          }
        }
      } else if (hugeCount == 1) {
        var remainingWidth = availableWidth;
        if (!hugeLeading) {
          targetLeading = requestedLeading;
          remainingWidth -= targetLeading;
        }
        if (!hugeCenter) {
          targetCenter = requestedCenter;
          remainingWidth -= targetCenter;
        }
        if (!hugeTrailing) {
          targetTrailing = requestedTrailing;
          remainingWidth -= targetTrailing;
        }
        if (hugeLeading) targetLeading = remainingWidth;
        if (hugeCenter) targetCenter = remainingWidth;
        if (hugeTrailing) targetTrailing = remainingWidth;
      } else {
        targetLeading = requestedLeading;
        targetCenter = requestedCenter;
        targetTrailing = requestedTrailing;
        final used = targetLeading + targetCenter + targetTrailing;
        if (used < availableWidth) {
          targetCenter += availableWidth - used;
        }
      }

      // Protect the center minimum by taking proportional outer-slot slack.
      if (minimumCenter > targetCenter && minimumCenter <= availableWidth) {
        final need = minimumCenter - targetCenter;
        final leadingSlack = math.max(0, targetLeading - minimumLeading);
        final trailingSlack = math.max(0, targetTrailing - minimumTrailing);
        final totalSlack = leadingSlack + trailingSlack;
        if (totalSlack > 0) {
          final useLeading = math.min(
            leadingSlack,
            need * leadingSlack / totalSlack,
          );
          final useTrailing = math.min(
            trailingSlack,
            math.max(0, need - useLeading),
          );
          targetLeading -= useLeading;
          targetTrailing -= useTrailing;
          targetCenter += useLeading + useTrailing;
        }
      }

      // Then protect the end minimum using remaining start and center slack.
      if (minimumTrailing > targetTrailing &&
          minimumTrailing <= availableWidth) {
        final need = minimumTrailing - targetTrailing;
        final leadingSlack = math.max(0, targetLeading - minimumLeading);
        final centerSlack = math.max(0, targetCenter - minimumCenter);
        final totalSlack = leadingSlack + centerSlack;
        if (totalSlack > 0) {
          final useLeading = math.min(
            leadingSlack,
            need * leadingSlack / totalSlack,
          );
          final useCenter = math.min(
            centerSlack,
            math.max(0, need - useLeading),
          );
          targetLeading -= useLeading;
          targetCenter -= useCenter;
          targetTrailing += useLeading + useCenter;
        }
      }
    }

    return _MiuixPreferenceWidths(
      leading: math.max(0, targetLeading),
      center: math.max(0, targetCenter),
      trailing: math.max(0, targetTrailing),
    );
  }

  @override
  void performLayout() {
    final leading = _childFor(_MiuixPreferenceSlot.leading);
    final center = _childFor(_MiuixPreferenceSlot.center)!;
    final trailing = _childFor(_MiuixPreferenceSlot.trailing);
    final gapCount = (leading == null ? 0 : 1) + (trailing == null ? 0 : 1);
    final requestedWidth =
        (leading?.getMaxIntrinsicWidth(0) ?? 0) +
        center.getMaxIntrinsicWidth(0) +
        (trailing?.getMaxIntrinsicWidth(0) ?? 0) +
        gap * gapCount;
    final layoutWidth = constraints.hasBoundedWidth
        ? constraints.maxWidth
        : constraints.constrainWidth(requestedWidth);
    final availableWidth = math.max(0.0, layoutWidth - gap * gapCount);
    // Flutter's vertical flex intrinsics interpret infinite height as room to
    // wrap every word. Zero requests the same natural single-line width that
    // Compose returns for an unbounded `Constraints.Infinity` height.
    final intrinsicHeight = constraints.hasBoundedHeight
        ? constraints.maxHeight
        : 0.0;
    final widths = _resolveWidths(
      availableWidth: availableWidth,
      leading: leading,
      center: center,
      trailing: trailing,
      intrinsicHeight: intrinsicHeight,
    );
    final childConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
    leading?.layout(
      childConstraints.copyWith(maxWidth: widths.leading),
      parentUsesSize: true,
    );
    center.layout(
      childConstraints.copyWith(maxWidth: widths.center),
      parentUsesSize: true,
    );
    trailing?.layout(
      childConstraints.copyWith(maxWidth: widths.trailing),
      parentUsesSize: true,
    );
    final rowHeight = math.max(
      center.size.height,
      math.max(leading?.size.height ?? 0, trailing?.size.height ?? 0),
    );
    size = constraints.constrain(Size(layoutWidth, rowHeight));

    final leadingWidth = leading?.size.width ?? 0;
    final centerWidth = center.size.width;
    final trailingWidth = trailing?.size.width ?? 0;
    final leadingY = _sourceCenteredOffset(leading);
    final centerY = _sourceCenteredOffset(center);
    final trailingY = _sourceCenteredOffset(trailing);
    if (textDirection == TextDirection.ltr) {
      if (leading != null) {
        (leading.parentData! as _MiuixPreferenceParentData).offset = Offset(
          0,
          leadingY,
        );
      }
      (center.parentData! as _MiuixPreferenceParentData).offset = Offset(
        leadingWidth + (leading == null ? 0 : gap),
        centerY,
      );
      if (trailing != null) {
        (trailing.parentData! as _MiuixPreferenceParentData).offset = Offset(
          size.width - trailingWidth,
          trailingY,
        );
      }
    } else {
      if (leading != null) {
        (leading.parentData! as _MiuixPreferenceParentData).offset = Offset(
          size.width - leadingWidth,
          leadingY,
        );
      }
      (center.parentData! as _MiuixPreferenceParentData).offset = Offset(
        size.width - leadingWidth - (leading == null ? 0 : gap) - centerWidth,
        centerY,
      );
      if (trailing != null) {
        (trailing.parentData! as _MiuixPreferenceParentData).offset = Offset(
          0,
          trailingY,
        );
      }
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }
}
