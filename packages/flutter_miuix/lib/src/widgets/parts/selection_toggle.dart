part of '../miuix_widgets.dart';

// Source-parity contract for Checkbox and RadioButton.
//
// - MIUIX 1.0.9 Checkbox.kt is the authority for checkbox state, timing, paint, semantics, and press feedback.
// - MIUIX 1.0.9 RadioButton.kt is the authority for radio state, timing, paint, semantics, and press feedback.
// - The Flutter API keeps value ownership in the caller, matching Compose state hoisting.
// - A null checkbox callback is the Flutter representation of a non-interactive checkbox.
// - A null radio callback is the Flutter representation of a non-interactive radio button.
// - Checkbox exposes Off, On, and Indeterminate as three visually distinct states.
// - RadioButton exposes selected and unselected as two visually distinct states.
// - Checkbox reports null checked semantics while it is indeterminate.
// - RadioButton reports membership in a mutually exclusive group.
// - Both controls keep a 26 dp painted and measured square.
// - Enabled controls expand semantics and pointer input to the source 48 dp minimum touch target.
// - The expanded target is centered and must not change Row measurement or sibling positions.
// - Disabled controls keep the authored 26 dp semantic bounds because no pointer action is installed.
// - Both controls use a circular clip and a circular press-feedback boundary.
// - Both controls use SinkFeedback with a scale target of 0.85.
// - Both controls use a damping ratio of 0.99 for sink feedback.
// - Both controls use a sink stiffness of 986.96.
// - Visual state never mutates the caller-owned selection value internally.
// - A checkbox mixed-state click requests the checked state.
// - A checkbox checked-state click requests the unchecked state.
// - A checkbox unchecked-state click requests the checked state.
// - A radio click reports its own value without toggling the group locally.
// - Disabled controls never install an active tap callback.
// - Initial construction paints the exact endpoint without replaying an entrance animation.
// - State changes after construction animate from the pixels currently on screen.
// - Theme changes re-resolve semantic colors instead of retaining stale Material colors.
// - Enabled-state changes re-resolve dedicated MIUIX disabled roles.
// - Scalar channels and color channels share a 300 ms transition clock only for sampling.
// - Each scalar channel still applies its own independent duration and easing.
// - A channel whose target value is unchanged does not restart.
// - Controller progress is converted to elapsed milliseconds before channel evaluation.
// - Elapsed time is clamped to the source transition's 0 through 300 ms interval.
// - Every completed channel lands on its exact source endpoint.
// - checkbox background resolves its Off endpoint to secondary or disabledSecondary.
// - checkbox background resolves its visible endpoint to primary or disabledPrimary.
// - checkbox background uses 300 ms while entering its active target.
// - checkbox background uses 300 ms while returning toward Off or its inactive target.
// - checkbox background uses FastOutSlowIn easing on its entering interval.
// - checkbox background uses FastOutSlowIn easing on its exiting interval.
// - checkbox background is evaluated independently even though updateTransition owns a shared state.
// - checkbox background fills the 26 dp circular surface.
// - checkbox foreground resolves its Off endpoint to secondary or disabledOnPrimary.
// - checkbox foreground resolves its visible endpoint to onPrimary or disabledOnPrimary.
// - checkbox foreground uses 300 ms while entering its active target.
// - checkbox foreground uses 300 ms while returning toward Off or its inactive target.
// - checkbox foreground uses FastOutSlowIn easing on its entering interval.
// - checkbox foreground uses FastOutSlowIn easing on its exiting interval.
// - checkbox foreground is evaluated independently even though updateTransition owns a shared state.
// - checkbox foreground colors the trimmed check path.
// - checkbox check alpha resolves its Off endpoint to 0.
// - checkbox check alpha resolves its visible endpoint to 1.
// - checkbox check alpha uses 10 ms while entering its active target.
// - checkbox check alpha uses 150 ms while returning toward Off or its inactive target.
// - checkbox check alpha uses FastOutSlowIn easing on its entering interval.
// - checkbox check alpha uses FastOutSlowIn easing on its exiting interval.
// - checkbox check alpha is evaluated independently even though updateTransition owns a shared state.
// - checkbox check alpha controls path visibility separately from path length.
// - checkbox start trim resolves its Off endpoint to 0.1.
// - checkbox start trim resolves its visible endpoint to 0.186.
// - checkbox start trim uses 200 ms while entering its active target.
// - checkbox start trim uses 300 ms while returning toward Off or its inactive target.
// - checkbox start trim uses FastOutSlowIn easing on its entering interval.
// - checkbox start trim uses linear keyframes default easing on its exiting interval.
// - checkbox start trim is evaluated independently even though updateTransition owns a shared state.
// - checkbox start trim delays the leading end of the check stroke.
// - checkbox end trim resolves its Off endpoint to 0.1.
// - checkbox end trim resolves its visible endpoint to 0.803.
// - checkbox end trim uses 300 ms with a 200 ms keyframe while entering its active target.
// - checkbox end trim uses 300 ms while returning toward Off or its inactive target.
// - checkbox end trim uses linear then FastOutSlowIn easing on its entering interval.
// - checkbox end trim uses linear keyframes default easing on its exiting interval.
// - checkbox end trim is evaluated independently even though updateTransition owns a shared state.
// - checkbox end trim reveals and settles the trailing end of the check stroke.
// - checkbox center gravitation resolves its Off endpoint to 0.
// - checkbox center gravitation resolves its visible endpoint to 1 only for Indeterminate.
// - checkbox center gravitation uses 200 ms while entering its active target.
// - checkbox center gravitation uses 150 ms while returning toward Off or its inactive target.
// - checkbox center gravitation uses FastOutSlowIn easing on its entering interval.
// - checkbox center gravitation uses FastOutSlowIn easing on its exiting interval.
// - checkbox center gravitation is evaluated independently even though updateTransition owns a shared state.
// - checkbox center gravitation morphs the check into the centered mixed-state bar.
// - Off to On becomes visible.
// - Off to On moves its background secondary to primary.
// - Off to On moves check alpha 0 to 1 in 10 ms.
// - Off to On moves start trim 0.1 to 0.186 in 200 ms.
// - Off to On moves end trim 0.1 to 0.85 at 200 ms then 0.803 at 300 ms.
// - Off to On moves center gravitation stays 0.
// - Off to On has a longest meaningful channel of 300 ms.
// - Off to On samples every channel from the currently painted interruption value.
// - Off to Indeterminate becomes visible.
// - Off to Indeterminate moves its background secondary to primary.
// - Off to Indeterminate moves check alpha 0 to 1 in 10 ms.
// - Off to Indeterminate moves start trim 0.1 to 0.186 in 200 ms.
// - Off to Indeterminate moves end trim 0.1 to 0.85 at 200 ms then 0.803 at 300 ms.
// - Off to Indeterminate moves center gravitation 0 to 1 in 200 ms.
// - Off to Indeterminate has a longest meaningful channel of 300 ms.
// - Off to Indeterminate samples every channel from the currently painted interruption value.
// - On to Off becomes hidden.
// - On to Off moves its background primary to secondary.
// - On to Off moves check alpha 1 to 0 in 150 ms.
// - On to Off moves start trim 0.186 to 0.1 in 300 ms.
// - On to Off moves end trim 0.803 to 0.1 in 300 ms.
// - On to Off moves center gravitation stays 0.
// - On to Off has a longest meaningful channel of 300 ms.
// - On to Off samples every channel from the currently painted interruption value.
// - On to Indeterminate stays visible.
// - On to Indeterminate moves its background stays primary.
// - On to Indeterminate moves check alpha stays 1.
// - On to Indeterminate moves start trim stays 0.186.
// - On to Indeterminate moves end trim stays 0.803 without a false bump.
// - On to Indeterminate moves center gravitation 0 to 1 in 200 ms.
// - On to Indeterminate has a longest meaningful channel of 200 ms of visible change.
// - On to Indeterminate samples every channel from the currently painted interruption value.
// - Indeterminate to On stays visible.
// - Indeterminate to On moves its background stays primary.
// - Indeterminate to On moves check alpha stays 1.
// - Indeterminate to On moves start trim stays 0.186.
// - Indeterminate to On moves end trim stays 0.803 without a false bump.
// - Indeterminate to On moves center gravitation 1 to 0 in 150 ms.
// - Indeterminate to On has a longest meaningful channel of 150 ms of visible change.
// - Indeterminate to On samples every channel from the currently painted interruption value.
// - Indeterminate to Off becomes hidden.
// - Indeterminate to Off moves its background primary to secondary.
// - Indeterminate to Off moves check alpha 1 to 0 in 150 ms.
// - Indeterminate to Off moves start trim 0.186 to 0.1 in 300 ms.
// - Indeterminate to Off moves end trim 0.803 to 0.1 in 300 ms.
// - Indeterminate to Off moves center gravitation 1 to 0 in 150 ms.
// - Indeterminate to Off has a longest meaningful channel of 300 ms.
// - Indeterminate to Off samples every channel from the currently painted interruption value.
// - enabled Off checkbox background resolves the MIUIX semantic role secondary.
// - enabled Off checkbox background does not apply a generic Opacity wrapper after resolving secondary.
// - enabled Off checkbox background is recomputed when inherited theme dependencies change.
// - enabled On checkbox background resolves the MIUIX semantic role primary.
// - enabled On checkbox background does not apply a generic Opacity wrapper after resolving primary.
// - enabled On checkbox background is recomputed when inherited theme dependencies change.
// - enabled Indeterminate checkbox background resolves the MIUIX semantic role primary.
// - enabled Indeterminate checkbox background does not apply a generic Opacity wrapper after resolving primary.
// - enabled Indeterminate checkbox background is recomputed when inherited theme dependencies change.
// - disabled Off checkbox background resolves the MIUIX semantic role disabledSecondary.
// - disabled Off checkbox background does not apply a generic Opacity wrapper after resolving disabledSecondary.
// - disabled Off checkbox background is recomputed when inherited theme dependencies change.
// - disabled On checkbox background resolves the MIUIX semantic role disabledPrimary.
// - disabled On checkbox background does not apply a generic Opacity wrapper after resolving disabledPrimary.
// - disabled On checkbox background is recomputed when inherited theme dependencies change.
// - disabled Indeterminate checkbox background resolves the MIUIX semantic role disabledPrimary.
// - disabled Indeterminate checkbox background does not apply a generic Opacity wrapper after resolving disabledPrimary.
// - disabled Indeterminate checkbox background is recomputed when inherited theme dependencies change.
// - enabled visible checkbox foreground resolves the MIUIX semantic role onPrimary.
// - enabled visible checkbox foreground does not apply a generic Opacity wrapper after resolving onPrimary.
// - enabled visible checkbox foreground is recomputed when inherited theme dependencies change.
// - disabled visible checkbox foreground resolves the MIUIX semantic role disabledOnPrimary.
// - disabled visible checkbox foreground does not apply a generic Opacity wrapper after resolving disabledOnPrimary.
// - disabled visible checkbox foreground is recomputed when inherited theme dependencies change.
// - enabled selected radio foreground resolves the MIUIX semantic role primary.
// - enabled selected radio foreground does not apply a generic Opacity wrapper after resolving primary.
// - enabled selected radio foreground is recomputed when inherited theme dependencies change.
// - disabled selected radio foreground resolves the MIUIX semantic role disabledPrimary.
// - disabled selected radio foreground does not apply a generic Opacity wrapper after resolving disabledPrimary.
// - disabled selected radio foreground is recomputed when inherited theme dependencies change.
// - The checkbox canvas is exactly 26 by 26 logical pixels.
// - The radio canvas is exactly 26 by 26 logical pixels.
// - The checkbox background radius is half of the shortest canvas side.
// - The checkbox check source viewport is 23 by 23 units.
// - The checkbox source start point is 5.0 by 9.4 in the 23-unit viewport.
// - The checkbox source middle point is 10.3 by 14.9 in the 23-unit viewport.
// - The checkbox source end point is 17.9 by 5.1 in the 23-unit viewport.
// - The checkbox stroke width is 9 percent of the rendered canvas width.
// - Checkbox coordinates are scaled around the rendered canvas center.
// - Checkbox start and end points keep their x coordinate during mixed-state gravitation.
// - The checkbox middle point gravitates toward the exact canvas center on both axes.
// - All checkbox path y coordinates gravitate toward the canvas center line.
// - Mixed-state geometry uses the same trimmed two-segment path as checked geometry.
// - Mixed state is not replaced by a self-designed fixed-width horizontal line.
// - Checkbox trim distances are measured over the combined length of both segments.
// - The checkbox leading trim may begin inside the first path segment.
// - The checkbox trailing trim may finish inside either path segment.
// - The checkbox painter reconnects the two path segments only when the trim window crosses the corner.
// - Round stroke caps match Compose StrokeCap.Round.
// - Round stroke joins match Compose StrokeJoin.Round.
// - The radio check source viewport is 56 by 56 units.
// - The radio source start point is 10.9 by 29.0 in the 56-unit viewport.
// - The radio source middle point is 23.1 by 40.8 in the 56-unit viewport.
// - The radio source end point is 44.0 by 16.0 in the 56-unit viewport.
// - The radio stroke width is 7 divided by 56 of the rendered canvas width.
// - Radio coordinates are scaled around the rendered canvas center.
// - Radio trim distance is measured over both source segments.
// - Radio rendering skips the path when either alpha or trim is zero.
// - Checkbox rendering skips the path when alpha is zero.
// - Checkbox rendering also skips an empty or reversed trim interval.
// - Painter alpha is applied to the resolved semantic foreground color.
// - Painter alpha is not reused as the trim amount.
// - Radio alpha is not multiplied by a second generic disabled opacity.
// - Checkbox disabled colors are already opaque composited palette roles.
// - Radio disabled color is already the palette's disabledPrimary role.
// - CustomPaint size remains independent of surrounding preference row height.
// - Preference placement can move the 26 dp control without changing its authored viewport.
// - RTL layout is handled by the preference slot, not by mirroring the check path.
// - The check path itself retains the upstream orientation in both text directions.
// - Geometry helpers remain visible for tests so source coordinates cannot drift silently.
// - RadioButton check alpha targets 1 while selected.
// - RadioButton check alpha targets 0 while unselected.
// - RadioButton check alpha reaches 1 in 10 ms on selection.
// - RadioButton check alpha reaches 0 in 150 ms on deselection.
// - RadioButton check alpha uses FastOutSlowIn on both directions.
// - RadioButton trim end targets 1 while selected.
// - RadioButton trim end targets 0 while unselected.
// - RadioButton trim end always uses a 300 ms tween.
// - RadioButton trim end uses FastOutSlowIn on both directions.
// - RadioButton color is not an animated transition channel in the source.
// - RadioButton enabled color resolves primary immediately.
// - RadioButton disabled color resolves disabledPrimary immediately.
// - RadioButton selection does not paint a circular background.
// - RadioButton selection paints only the trimmed check stroke.
// - RadioButton initial selected state starts with alpha 1 and trim 1.
// - RadioButton initial unselected state starts with alpha 0 and trim 0.
// - RadioButton interrupted selection begins from the current alpha.
// - RadioButton interrupted selection begins from the current trim distance.
// - RadioButton target selection is stored separately from the newly rebuilt widget.
// - Stored target selection prevents a settled old state from snapping to the new endpoint.
// - RadioButton controller duration covers the longest 300 ms trim channel.
// - RadioButton repaint listeners rebuild only while the controller ticks.
// - RadioButton dispose removes its listener before disposing the controller.
// - RadioButton semantic selected state follows value equality with groupValue.
// - RadioButton semantic enabled state follows callback availability.
// - RadioButton press feedback is independent from selection transition timing.
// - RadioButton pointer feedback can finish before path trim finishes.
// - RadioButton source alpha and trim channels are tested at their 5 ms midpoint.
// - RadioButton trim is tested again at 200 ms to guard duration drift.
// - RadioButton disabled color is inspected directly on the active painter.
// - Checkbox initialization waits for inherited semantic colors before creating its first visual frame.
// - Checkbox stores the current frame before retargeting any interrupted animation.
// - Checkbox stores target checked and target indeterminate flags independently from widget fields.
// - Stored checkbox targets preserve the outgoing state during didUpdateWidget.
// - Checkbox didUpdateWidget retargets when value changes.
// - Checkbox didUpdateWidget retargets when indeterminate changes.
// - Checkbox didUpdateWidget retargets when enabled state changes.
// - Checkbox didChangeDependencies retargets when semantic endpoint colors change.
// - Checkbox theme retargeting does not restart scalar channels whose target is unchanged.
// - Checkbox controller stop occurs before replacing the source frame.
// - Checkbox controller restarts from elapsed time zero after its source frame is captured.
// - Checkbox frame evaluation reads stored targets rather than speculative new widget values.
// - Checkbox color interpolation uses FastOutSlowIn for the complete 300 ms interval.
// - Checkbox color interpolation starts from the exact currently rendered colors.
// - Checkbox color interpolation targets the newly resolved semantic roles.
// - Checkbox controller ticks call setState only while the State remains mounted.
// - Checkbox disposal removes the repaint listener.
// - Checkbox disposal releases the animation controller.
// - Checkbox semantic values are built from the caller's current state, not animation progress.
// - Checkbox hit behavior is enabled only when the callback exists.
// - Checkbox paint progress is allowed to lag semantic state during a transition.
// - Radio initialization can derive selection without inherited theme access.
// - Radio didUpdateWidget compares old and new group membership.
// - Radio captures its current frame before overwriting target selection.
// - Radio controller restarts only when selected membership actually changes.
// - Radio enabled-state changes repaint color without replaying scalar selection channels.
// - Radio theme changes repaint semantic color through the normal inherited rebuild.
// - Both state machines keep endpoint values exact after controller completion.
// - Both state machines support immediate reversal without jumping to the previous endpoint.
// - Both state machines avoid AnimatedContainer's single-duration approximation.
// - Both state machines avoid TweenAnimationBuilder's shared alpha-and-trim progress.
// - Both state machines expose pure frame functions for deterministic unit tests.
// - Pure frame functions clamp invalid elapsed times before interpolation.
// - Pure frame functions preserve unchanged targets exactly.
// - Frame records keep color and scalar values synchronized for one paint.
// - Source-specific comments live with the implementation after the file split.
// - The separate part file keeps unrelated switch and slider code out of the toggle state machine.
// - The split does not create a new public library boundary.
// - The parent widgets library includes the toggle part after the general selection part.
// - Tests continue importing one public flutter_miuix library despite the internal file split.
// - The Checkbox end-trim keyframe reaches 0.85 exactly at 200 ms.
// - The Checkbox end-trim keyframe settles from 0.85 to 0.803 by 300 ms.
// - Compose keyframe easing belongs to the interval starting at the annotated keyframe.
// - The implicit interval from 0 to 200 ms therefore remains linear.
// - FastOutSlowIn begins at the explicit 200 ms keyframe.
// - The easing annotation on the terminal 300 ms keyframe has no following interval.
// - Off-target keyframes declare only the 0.1 endpoint at 300 ms.
// - The Off-target end-trim interpolation is therefore linear.
// - Off-target start-trim interpolation is also linear.
// - Entering start trim is a separate 200 ms FastOutSlowIn tween.
// - Entering alpha completes before a single 60 Hz frame has normally elapsed.
// - Exiting alpha remains visible for up to 150 ms.
// - Background color continues through 300 ms after alpha has completed.
// - Foreground color continues through 300 ms after alpha has completed.
// - Center gravitation can complete at 150 or 200 ms while colors remain active.
// - On-to-Mixed leaves end trim at 0.803 instead of replaying the 0.85 peak.
// - Mixed-to-On leaves end trim at 0.803 instead of replaying the 0.85 peak.
// - Unchanged trim preservation follows updateTransition target-value semantics.
// - Midpoint tests assert the linear first keyframe interval numerically.
// - Midpoint tests assert the eased second keyframe interval numerically.
// - Endpoint tests assert the 0.186 start-trim target.
// - Endpoint tests assert the 0.803 end-trim target.
// - Mixed-state tests assert that only center gravitation changes.
// - Disabled-role tests assert fixed-light palette values directly.
// - Golden tests cover enabled, disabled, pressed, dark, expanded, and animation frames.
// - Component tests cover real widget retargeting at 5 ms.
// - Component tests cover real widget painting at 200 ms.
// - Example tests cover checkbox and radio placement inside localized preference rows.
// - Source geometry tests guard every authored check point.
// - Full-library tests guard composite preferences that embed these controls.
//

/// Returns the scalar channels produced by MIUIX Checkbox's transition specs.
@visibleForTesting
({
  double checkAlpha,
  double trimStart,
  double trimEnd,
  double crossCenterGravitation,
})
debugMiuixCheckboxTransitionFrame({
  required double fromCheckAlpha,
  required double fromTrimStart,
  required double fromTrimEnd,
  required double fromCrossCenterGravitation,
  required bool targetChecked,
  required bool targetIndeterminate,
  required double elapsedMilliseconds,
}) {
  final targetVisible = targetChecked || targetIndeterminate;
  final elapsed = elapsedMilliseconds.clamp(0.0, 300.0);
  final checkAlpha = _miuixTimedValue(
    fromCheckAlpha,
    targetVisible ? 1 : 0,
    elapsed,
    targetVisible ? 10 : 150,
    Curves.fastOutSlowIn,
  );
  final trimStart = _miuixTimedValue(
    fromTrimStart,
    targetVisible ? .186 : .1,
    elapsed,
    targetVisible ? 200 : 300,
    targetVisible ? Curves.fastOutSlowIn : Curves.linear,
  );
  final trimEndTarget = targetVisible ? .803 : .1;
  final trimEnd = fromTrimEnd == trimEndTarget
      ? trimEndTarget
      : targetVisible
      ? elapsed <= 200
            // The upstream keyframe at 200 ms has no easing on the
            // preceding interval, so this first leg is deliberately linear.
            ? ui.lerpDouble(fromTrimEnd, .85, elapsed / 200)!
            // `using FastOutSlowInEasing` belongs to the interval that
            // starts at the 200 ms keyframe and ends at 300 ms.
            : ui.lerpDouble(
                .85,
                .803,
                Curves.fastOutSlowIn.transform((elapsed - 200) / 100),
              )!
      : ui.lerpDouble(fromTrimEnd, .1, elapsed / 300)!;
  final crossCenterGravitation = _miuixTimedValue(
    fromCrossCenterGravitation,
    targetIndeterminate ? 1 : 0,
    elapsed,
    targetIndeterminate ? 200 : 150,
    Curves.fastOutSlowIn,
  );
  return (
    checkAlpha: checkAlpha,
    trimStart: trimStart,
    trimEnd: trimEnd,
    crossCenterGravitation: crossCenterGravitation,
  );
}

/// Returns the independent alpha and path-trim channels used by RadioButton.
@visibleForTesting
({double checkAlpha, double trimEnd}) debugMiuixRadioTransitionFrame({
  required double fromCheckAlpha,
  required double fromTrimEnd,
  required bool targetSelected,
  required double elapsedMilliseconds,
}) {
  final elapsed = elapsedMilliseconds.clamp(0.0, 300.0);
  return (
    checkAlpha: _miuixTimedValue(
      fromCheckAlpha,
      targetSelected ? 1 : 0,
      elapsed,
      targetSelected ? 10 : 150,
      Curves.fastOutSlowIn,
    ),
    trimEnd: _miuixTimedValue(
      fromTrimEnd,
      targetSelected ? 1 : 0,
      elapsed,
      300,
      Curves.fastOutSlowIn,
    ),
  );
}

double _miuixTimedValue(
  double from,
  double target,
  double elapsedMilliseconds,
  double durationMilliseconds,
  Curve curve,
) {
  // updateTransition does not restart a channel whose resolved target value
  // is unchanged, which matters when Checkbox moves between On and Mixed.
  if (from == target) return target;
  final fraction = (elapsedMilliseconds / durationMilliseconds).clamp(0.0, 1.0);
  return ui.lerpDouble(from, target, curve.transform(fraction))!;
}

typedef _MiuixCheckboxFrame = ({
  Color background,
  Color foreground,
  double checkAlpha,
  double trimStart,
  double trimEnd,
  double crossCenterGravitation,
});

/// Immutable source color channels for [MiuixCheckbox].
@immutable
class MiuixCheckboxColors {
  /// Creates all eight enabled and disabled source channels.
  const MiuixCheckboxColors({
    required this.checkedForegroundColor,
    required this.uncheckedForegroundColor,
    required this.disabledCheckedForegroundColor,
    required this.disabledUncheckedForegroundColor,
    required this.checkedBackgroundColor,
    required this.uncheckedBackgroundColor,
    required this.disabledCheckedBackgroundColor,
    required this.disabledUncheckedBackgroundColor,
  });

  final Color checkedForegroundColor;
  final Color uncheckedForegroundColor;
  final Color disabledCheckedForegroundColor;
  final Color disabledUncheckedForegroundColor;
  final Color checkedBackgroundColor;
  final Color uncheckedBackgroundColor;
  final Color disabledCheckedBackgroundColor;
  final Color disabledUncheckedBackgroundColor;

  /// Resolves the source foreground channel for state and availability.
  Color foreground({required bool checked, required bool enabled}) {
    if (checked) {
      return enabled ? checkedForegroundColor : disabledCheckedForegroundColor;
    }
    return enabled
        ? uncheckedForegroundColor
        : disabledUncheckedForegroundColor;
  }

  /// Resolves the source background channel for state and availability.
  Color background({required bool checked, required bool enabled}) {
    if (checked) {
      return enabled ? checkedBackgroundColor : disabledCheckedBackgroundColor;
    }
    return enabled
        ? uncheckedBackgroundColor
        : disabledUncheckedBackgroundColor;
  }

  /// Returns a Kotlin-data-class-equivalent value copy.
  MiuixCheckboxColors copyWith({
    Color? checkedForegroundColor,
    Color? uncheckedForegroundColor,
    Color? disabledCheckedForegroundColor,
    Color? disabledUncheckedForegroundColor,
    Color? checkedBackgroundColor,
    Color? uncheckedBackgroundColor,
    Color? disabledCheckedBackgroundColor,
    Color? disabledUncheckedBackgroundColor,
  }) {
    return MiuixCheckboxColors(
      checkedForegroundColor:
          checkedForegroundColor ?? this.checkedForegroundColor,
      uncheckedForegroundColor:
          uncheckedForegroundColor ?? this.uncheckedForegroundColor,
      disabledCheckedForegroundColor:
          disabledCheckedForegroundColor ?? this.disabledCheckedForegroundColor,
      disabledUncheckedForegroundColor:
          disabledUncheckedForegroundColor ??
          this.disabledUncheckedForegroundColor,
      checkedBackgroundColor:
          checkedBackgroundColor ?? this.checkedBackgroundColor,
      uncheckedBackgroundColor:
          uncheckedBackgroundColor ?? this.uncheckedBackgroundColor,
      disabledCheckedBackgroundColor:
          disabledCheckedBackgroundColor ?? this.disabledCheckedBackgroundColor,
      disabledUncheckedBackgroundColor:
          disabledUncheckedBackgroundColor ??
          this.disabledUncheckedBackgroundColor,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MiuixCheckboxColors &&
            checkedForegroundColor == other.checkedForegroundColor &&
            uncheckedForegroundColor == other.uncheckedForegroundColor &&
            disabledCheckedForegroundColor ==
                other.disabledCheckedForegroundColor &&
            disabledUncheckedForegroundColor ==
                other.disabledUncheckedForegroundColor &&
            checkedBackgroundColor == other.checkedBackgroundColor &&
            uncheckedBackgroundColor == other.uncheckedBackgroundColor &&
            disabledCheckedBackgroundColor ==
                other.disabledCheckedBackgroundColor &&
            disabledUncheckedBackgroundColor ==
                other.disabledUncheckedBackgroundColor;
  }

  @override
  int get hashCode => Object.hash(
    checkedForegroundColor,
    uncheckedForegroundColor,
    disabledCheckedForegroundColor,
    disabledUncheckedForegroundColor,
    checkedBackgroundColor,
    uncheckedBackgroundColor,
    disabledCheckedBackgroundColor,
    disabledUncheckedBackgroundColor,
  );
}

/// Source defaults for checkbox colors and authored dimensions.
abstract final class MiuixCheckboxDefaults {
  /// Authored visible diameter from `requiredSize(26.dp)`.
  static const double size = 26;

  /// Platform accessibility target used when an on-click callback exists.
  static const double touchTargetSize = 48;

  /// Creates colors from current MIUIX semantic roles with optional overrides.
  static MiuixCheckboxColors checkboxColors(
    BuildContext context, {
    Color? checkedForegroundColor,
    Color? uncheckedForegroundColor,
    Color? disabledCheckedForegroundColor,
    Color? disabledUncheckedForegroundColor,
    Color? checkedBackgroundColor,
    Color? uncheckedBackgroundColor,
    Color? disabledCheckedBackgroundColor,
    Color? disabledUncheckedBackgroundColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixCheckboxColors(
      checkedForegroundColor: checkedForegroundColor ?? semantic['onPrimary'],
      uncheckedForegroundColor:
          uncheckedForegroundColor ?? semantic['secondary'],
      disabledCheckedForegroundColor:
          disabledCheckedForegroundColor ?? semantic['disabledOnPrimary'],
      disabledUncheckedForegroundColor:
          disabledUncheckedForegroundColor ?? semantic['disabledOnPrimary'],
      checkedBackgroundColor: checkedBackgroundColor ?? semantic['primary'],
      uncheckedBackgroundColor:
          uncheckedBackgroundColor ?? semantic['secondary'],
      disabledCheckedBackgroundColor:
          disabledCheckedBackgroundColor ?? semantic['disabledPrimary'],
      disabledUncheckedBackgroundColor:
          disabledUncheckedBackgroundColor ?? semantic['disabledSecondary'],
    );
  }
}

/// Miuix checkbox wrapper.
class MiuixCheckbox extends StatefulWidget {
  /// Creates a checkbox.
  const MiuixCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.indeterminate = false,
    this.enabled = true,
    this.colors,
  });

  /// Creates the source tri-state/onClick form without boolean remapping.
  factory MiuixCheckbox.tristate({
    Key? key,
    required bool? state,
    required VoidCallback? onClick,
    bool enabled = true,
    MiuixCheckboxColors? colors,
  }) {
    return MiuixCheckbox(
      key: key,
      value: state ?? false,
      indeterminate: state == null,
      enabled: enabled,
      colors: colors,
      onChanged: onClick == null ? null : (_) => onClick(),
    );
  }

  /// Current value.
  final bool value;

  /// Whether to render the mixed-state horizontal mark.
  final bool indeterminate;

  /// Change callback.
  final ValueChanged<bool?>? onChanged;

  /// Whether the checkbox is enabled.
  ///
  /// This is intentionally independent from [onChanged]. MIUIX keeps the
  /// callback-backed 48dp toggle target when a control is disabled, while a
  /// checkbox without a callback is only its authored 26dp visual size.
  final bool enabled;

  /// Optional source eight-channel color data.
  final MiuixCheckboxColors? colors;

  @override
  State<MiuixCheckbox> createState() => _MiuixCheckboxState();
}

class _MiuixCheckboxState extends State<MiuixCheckbox>
    with SingleTickerProviderStateMixin {
  // Checkbox.kt uses one updateTransition with a longest channel of 300 ms.
  late final AnimationController _transition;
  late _MiuixCheckboxFrame _from;
  late Color _targetBackground;
  late Color _targetForeground;
  late bool _targetChecked;
  late bool _targetIndeterminate;
  bool _initialized = false;
  bool _reduceMotion = false;

  bool get _canActivate => widget.enabled && widget.onChanged != null;
  bool get _hasToggleTarget => widget.onChanged != null;
  bool get _targetVisible => widget.value || widget.indeterminate;

  @override
  void initState() {
    super.initState();
    _transition = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(_repaint);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion = MediaQuery.disableAnimationsOf(context);
    if (nextReduceMotion != _reduceMotion) {
      _reduceMotion = nextReduceMotion;
      if (_reduceMotion && _initialized) {
        _transition
          ..stop(canceled: true)
          ..value = 1;
      }
    }
    final background = _backgroundFor();
    final foreground = _foregroundFor();
    if (!_initialized) {
      _targetBackground = background;
      _targetForeground = foreground;
      _targetChecked = widget.value;
      _targetIndeterminate = widget.indeterminate;
      _from = (
        background: background,
        foreground: foreground,
        checkAlpha: _targetVisible ? 1 : 0,
        trimStart: _targetVisible ? .186 : .1,
        trimEnd: _targetVisible ? .803 : .1,
        crossCenterGravitation: widget.indeterminate ? 1 : 0,
      );
      _initialized = true;
      return;
    }
    if (background != _targetBackground || foreground != _targetForeground) {
      _startTransition();
    }
  }

  @override
  void didUpdateWidget(covariant MiuixCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.indeterminate != widget.indeterminate ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.colors != widget.colors) {
      _startTransition();
    }
  }

  @override
  void dispose() {
    _transition
      ..removeListener(_repaint)
      ..dispose();
    super.dispose();
  }

  void _repaint() {
    if (mounted) setState(() {});
  }

  Color _backgroundFor() {
    final colors =
        widget.colors ?? MiuixCheckboxDefaults.checkboxColors(context);
    return colors.background(checked: _targetVisible, enabled: widget.enabled);
  }

  Color _foregroundFor() {
    final colors =
        widget.colors ?? MiuixCheckboxDefaults.checkboxColors(context);
    return colors.foreground(checked: _targetVisible, enabled: widget.enabled);
  }

  _MiuixCheckboxFrame get _frame {
    final elapsed = _transition.value * 300;
    final scalar = debugMiuixCheckboxTransitionFrame(
      fromCheckAlpha: _from.checkAlpha,
      fromTrimStart: _from.trimStart,
      fromTrimEnd: _from.trimEnd,
      fromCrossCenterGravitation: _from.crossCenterGravitation,
      targetChecked: _targetChecked,
      targetIndeterminate: _targetIndeterminate,
      elapsedMilliseconds: elapsed,
    );
    final colorProgress = Curves.fastOutSlowIn.transform(_transition.value);
    return (
      background: Color.lerp(
        _from.background,
        _targetBackground,
        colorProgress,
      )!,
      foreground: Color.lerp(
        _from.foreground,
        _targetForeground,
        colorProgress,
      )!,
      checkAlpha: scalar.checkAlpha,
      trimStart: scalar.trimStart,
      trimEnd: scalar.trimEnd,
      crossCenterGravitation: scalar.crossCenterGravitation,
    );
  }

  void _startTransition() {
    final current = _frame;
    _transition.stop();
    _from = current;
    _targetChecked = widget.value;
    _targetIndeterminate = widget.indeterminate;
    _targetBackground = _backgroundFor();
    _targetForeground = _foregroundFor();
    if (_reduceMotion) {
      _transition.value = 1;
    } else {
      _transition.forward(from: 0);
    }
  }

  void _activate() {
    if (!_canActivate) return;
    final type = widget.indeterminate
        ? MiuixHapticType.segmentTick
        : widget.value
        ? MiuixHapticType.toggleOff
        : MiuixHapticType.toggleOn;
    widget.onChanged?.call(widget.indeterminate || !widget.value);
    unawaited(MiuixHaptics.perform(type));
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frame;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final visualSize = _miuixRoundedSelectionSize(
      MiuixCheckboxDefaults.size,
      pixelRatio,
    );
    final touchTargetSize = _miuixRoundedSelectionSize(
      MiuixCheckboxDefaults.touchTargetSize,
      pixelRatio,
    );
    final canvas = CustomPaint(
      key: const ValueKey('miuix-checkbox-canvas'),
      size: Size.square(visualSize),
      painter: _MiuixCheckboxPainter(
        background: frame.background,
        foreground: frame.foreground,
        checkAlpha: frame.checkAlpha,
        trimStart: frame.trimStart,
        trimEnd: frame.trimEnd,
        crossCenterGravitation: frame.crossCenterGravitation,
      ),
    );
    final semanticControl = Semantics(
      key: const ValueKey('miuix-checkbox-semantics'),
      checked: widget.indeterminate ? null : widget.value,
      enabled: widget.enabled,
      // Compose keeps the tri-state toggle action in semantics when the
      // callback exists, even while enabled=false. A no-op disabled action
      // preserves that Android CheckBox contract without accepting pointer or
      // accessibility activation.
      onTap: _hasToggleTarget
          ? _canActivate
                ? _activate
                : () {}
          : null,
      child: MiuixPressable(
        scale: .85,
        sinkDampingRatio: .99,
        sinkStiffness: 986.96,
        onTap: _canActivate ? _activate : null,
        feedbackOnly: widget.enabled && widget.onChanged == null,
        borderRadius: BorderRadius.circular(999),
        // The outer transform expands only the gesture/semantic layer. Apply
        // the reciprocal paint transform here so the authored 26dp circle
        // remains 26dp on screen and its press scale still lands at 0.85.
        child: _hasToggleTarget
            ? Transform.scale(
                scale: visualSize / touchTargetSize,
                child: canvas,
              )
            : canvas,
      ),
    );
    if (!_hasToggleTarget) return semanticControl;
    // RenderTransform deliberately hit-tests its transformed child without
    // clipping to its own 26dp layout box. This reproduces Compose's minimum
    // touch-target expansion while Flex continues to measure exactly 26dp.
    return Transform.scale(
      scale: touchTargetSize / visualSize,
      child: semanticControl,
    );
  }
}

/// Immutable selected and disabled colors from source `RadioButtonColors`.
@immutable
class MiuixRadioButtonColors {
  const MiuixRadioButtonColors({
    required this.selectedColor,
    required this.disabledSelectedColor,
  });

  final Color selectedColor;
  final Color disabledSelectedColor;

  /// Resolves the only painted channel for current availability.
  Color color({required bool enabled}) =>
      enabled ? selectedColor : disabledSelectedColor;

  MiuixRadioButtonColors copyWith({
    Color? selectedColor,
    Color? disabledSelectedColor,
  }) {
    return MiuixRadioButtonColors(
      selectedColor: selectedColor ?? this.selectedColor,
      disabledSelectedColor:
          disabledSelectedColor ?? this.disabledSelectedColor,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MiuixRadioButtonColors &&
          selectedColor == other.selectedColor &&
          disabledSelectedColor == other.disabledSelectedColor;

  @override
  int get hashCode => Object.hash(selectedColor, disabledSelectedColor);
}

/// Source radio-button defaults.
abstract final class MiuixRadioButtonDefaults {
  static const double size = 26;
  static const double touchTargetSize = 48;

  static MiuixRadioButtonColors radioButtonColors(
    BuildContext context, {
    Color? selectedColor,
    Color? disabledSelectedColor,
  }) {
    final semantic = MiuixSemanticColors.of(context);
    return MiuixRadioButtonColors(
      selectedColor: selectedColor ?? semantic['primary'],
      disabledSelectedColor:
          disabledSelectedColor ?? semantic['disabledPrimary'],
    );
  }
}

/// Miuix radio button wrapper.
class MiuixRadio<T> extends StatefulWidget {
  /// Creates a radio button.
  const MiuixRadio({
    super.key,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.enabled = true,
    this.colors,
  });

  /// Radio value.
  final T value;

  /// Selected group value.
  final T? groupValue;

  /// Change callback.
  final ValueChanged<T?>? onChanged;

  /// Whether the radio button is enabled.
  ///
  /// A non-null callback still owns the source 48dp toggle target when this is
  /// false, but disabled controls never invoke it or emit press feedback.
  final bool enabled;

  /// Optional source selected and disabled color data.
  final MiuixRadioButtonColors? colors;

  @override
  State<MiuixRadio<T>> createState() => _MiuixRadioState<T>();
}

class _MiuixRadioState<T> extends State<MiuixRadio<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _transition;
  late double _fromCheckAlpha;
  late double _fromTrimEnd;
  late bool _targetSelected;
  bool _reduceMotion = false;

  bool get _selected => widget.value == widget.groupValue;
  bool get _canActivate => widget.enabled && widget.onChanged != null;
  bool get _hasToggleTarget => widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _fromCheckAlpha = _selected ? 1 : 0;
    _fromTrimEnd = _selected ? 1 : 0;
    _targetSelected = _selected;
    _transition = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(_repaint);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final nextReduceMotion = MediaQuery.disableAnimationsOf(context);
    if (nextReduceMotion == _reduceMotion) return;
    _reduceMotion = nextReduceMotion;
    if (_reduceMotion) {
      _transition
        ..stop(canceled: true)
        ..value = 1;
    }
  }

  @override
  void didUpdateWidget(covariant MiuixRadio<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasSelected = oldWidget.value == oldWidget.groupValue;
    if (wasSelected != _selected) {
      final current = _frame;
      _transition.stop();
      _fromCheckAlpha = current.checkAlpha;
      _fromTrimEnd = current.trimEnd;
      _targetSelected = _selected;
      if (_reduceMotion) {
        _transition.value = 1;
      } else {
        _transition.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _transition
      ..removeListener(_repaint)
      ..dispose();
    super.dispose();
  }

  void _repaint() {
    if (mounted) setState(() {});
  }

  ({double checkAlpha, double trimEnd}) get _frame =>
      debugMiuixRadioTransitionFrame(
        fromCheckAlpha: _fromCheckAlpha,
        fromTrimEnd: _fromTrimEnd,
        targetSelected: _targetSelected,
        elapsedMilliseconds: _transition.value * 300,
      );

  void _activate() {
    if (!_canActivate) return;
    widget.onChanged?.call(widget.value);
    unawaited(
      MiuixHaptics.perform(
        _selected ? MiuixHapticType.toggleOff : MiuixHapticType.toggleOn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final frame = _frame;
    final colors =
        widget.colors ?? MiuixRadioButtonDefaults.radioButtonColors(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final visualSize = _miuixRoundedSelectionSize(
      MiuixRadioButtonDefaults.size,
      pixelRatio,
    );
    final touchTargetSize = _miuixRoundedSelectionSize(
      MiuixRadioButtonDefaults.touchTargetSize,
      pixelRatio,
    );
    final canvas = CustomPaint(
      key: const ValueKey('miuix-radio-canvas'),
      size: Size.square(visualSize),
      painter: _MiuixRadioPainter(
        checkAlpha: frame.checkAlpha,
        trimEnd: frame.trimEnd,
        color: colors.color(enabled: widget.enabled),
      ),
    );
    final semanticControl = Semantics(
      key: const ValueKey('miuix-radio-semantics'),
      // Disabled controls have no gesture action to make an implicit boundary.
      // Keep the radio as its own node so it does not merge into the complete
      // preference card and inherit that card's much larger bounds.
      container: true,
      // Android maps checked + mutually-exclusive semantics to an actual
      // RadioButton node. `selected` instead becomes a generic View and lets a
      // disabled radio merge into the enclosing preference/card semantics.
      checked: _selected,
      enabled: widget.enabled,
      inMutuallyExclusiveGroup: true,
      child: MiuixPressable(
        scale: .85,
        sinkDampingRatio: .99,
        sinkStiffness: 986.96,
        onTap: _canActivate ? _activate : null,
        feedbackOnly: widget.enabled && widget.onChanged == null,
        borderRadius: BorderRadius.circular(999),
        child: _hasToggleTarget
            ? Transform.scale(
                scale: visualSize / touchTargetSize,
                child: canvas,
              )
            : canvas,
      ),
    );
    if (!_hasToggleTarget) return semanticControl;
    return Transform.scale(
      scale: touchTargetSize / visualSize,
      child: semanticControl,
    );
  }
}

double _miuixRoundedSelectionSize(double logicalSize, double devicePixelRatio) {
  if (!devicePixelRatio.isFinite || devicePixelRatio <= 0) {
    return logicalSize;
  }
  // requiredSize(26.dp) and the platform 48dp minimum target are converted
  // to integer pixels independently by Compose before alignment and target
  // expansion. Keeping those two rounded sizes removes half-pixel centers.
  return (logicalSize * devicePixelRatio).roundToDouble() / devicePixelRatio;
}

class _MiuixCheckboxPainter extends CustomPainter {
  const _MiuixCheckboxPainter({
    required this.background,
    required this.foreground,
    required this.checkAlpha,
    required this.trimStart,
    required this.trimEnd,
    required this.crossCenterGravitation,
  });

  // Background and foreground are animated independently by the state holder.
  final Color background;
  final Color foreground;

  // The path becomes visible in 10 ms and disappears in 150 ms.
  final double checkAlpha;

  // Trim channels retain their separate source timelines and keyframes.
  final double trimStart;
  final double trimEnd;

  // Mixed state gravitates all three path points toward the horizontal center.
  final double crossCenterGravitation;

  @override
  void paint(Canvas canvas, Size size) {
    // Checkbox bounds are circular in the upstream 1.0.9 implementation.
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.shortestSide / 2,
      Paint()..color = background,
    );
    // No path work is needed while the independent alpha channel is hidden.
    if (checkAlpha <= 0 || trimEnd <= trimStart) {
      return;
    }
    // Source vector coordinates are scaled into the caller's square canvas.
    final metrics = debugMiuixCheckboxMetrics(size);
    final gravity = crossCenterGravitation.clamp(0.0, 1.0);
    final center = Offset(size.width / 2, size.height / 2);
    // This is the same per-coordinate gravitation used by drawTrimmedCheckmark:
    // the endpoints keep their x positions while every y moves to center, and
    // the middle point moves to the exact center in both axes.
    final start = Offset(
      metrics.start.dx,
      ui.lerpDouble(metrics.start.dy, center.dy, gravity)!,
    );
    final middle = Offset(
      ui.lerpDouble(metrics.middle.dx, center.dx, gravity)!,
      ui.lerpDouble(metrics.middle.dy, center.dy, gravity)!,
    );
    final end = Offset(
      metrics.end.dx,
      ui.lerpDouble(metrics.end.dy, center.dy, gravity)!,
    );
    final path = _trimmedMiuixCheckboxPath(
      start: start,
      middle: middle,
      end: end,
      trimStart: trimStart,
      trimEnd: trimEnd,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = foreground.withValues(alpha: checkAlpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = metrics.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MiuixCheckboxPainter oldDelegate) {
    return background != oldDelegate.background ||
        foreground != oldDelegate.foreground ||
        checkAlpha != oldDelegate.checkAlpha ||
        trimStart != oldDelegate.trimStart ||
        trimEnd != oldDelegate.trimEnd ||
        crossCenterGravitation != oldDelegate.crossCenterGravitation;
  }
}

@visibleForTesting
({Offset start, Offset middle, Offset end, double strokeWidth})
debugMiuixCheckboxMetrics(Size size) {
  // MIUIX declares the check path in a 23 by 23 vector viewport.
  const viewportSize = 23.0;

  // Center-based mapping keeps nonstandard test sizes geometrically aligned.
  final center = Offset(size.width / 2, size.height / 2);
  Offset point(double x, double y) => Offset(
    center.dx + ((x - viewportSize / 2) / viewportSize * size.width),
    center.dy + ((y - viewportSize / 2) / viewportSize * size.height),
  );
  return (
    start: point(5, 9.4),
    middle: point(10.3, 14.9),
    end: point(17.9, 5.1),
    strokeWidth: size.width * .09,
  );
}

Path _trimmedMiuixCheckboxPath({
  required Offset start,
  required Offset middle,
  required Offset end,
  required double trimStart,
  required double trimEnd,
}) {
  // Arc-length trimming makes the two-segment tick animate at uniform speed.
  final firstLength = (middle - start).distance;

  // The longer rising segment contributes proportionally to total duration.
  final secondLength = (end - middle).distance;
  final totalLength = firstLength + secondLength;
  // Both trim inputs are normalized before being converted to physical length.
  final startDistance = totalLength * trimStart.clamp(0.0, 1.0);
  final endDistance = totalLength * trimEnd.clamp(0.0, 1.0);
  final path = Path();

  // Reusing this helper avoids constructing temporary OffsetTween instances.
  Offset lerpOffset(Offset a, Offset b, double t) {
    return Offset(ui.lerpDouble(a.dx, b.dx, t)!, ui.lerpDouble(a.dy, b.dy, t)!);
  }

  // Draw the descending segment only while the trim window intersects it.
  if (startDistance < firstLength && endDistance > 0) {
    final segStart = (startDistance / firstLength).clamp(0.0, 1.0);
    final segEnd = (endDistance / firstLength).clamp(0.0, 1.0);
    final firstStart = lerpOffset(start, middle, segStart);
    final firstEnd = lerpOffset(start, middle, segEnd);
    path
      ..moveTo(firstStart.dx, firstStart.dy)
      ..lineTo(firstEnd.dx, firstEnd.dy);
  }

  // Continue onto the rising segment after the end trim crosses the corner.
  if (endDistance > firstLength) {
    final segStart = ((startDistance - firstLength) / secondLength).clamp(
      0.0,
      1.0,
    );
    final segEnd = ((endDistance - firstLength) / secondLength).clamp(0.0, 1.0);
    final secondStart = lerpOffset(middle, end, segStart);
    final secondEnd = lerpOffset(middle, end, segEnd);
    if (startDistance < firstLength) {
      path.lineTo(secondEnd.dx, secondEnd.dy);
    } else {
      path
        ..moveTo(secondStart.dx, secondStart.dy)
        ..lineTo(secondEnd.dx, secondEnd.dy);
    }
  }

  return path;
}

class _MiuixRadioPainter extends CustomPainter {
  const _MiuixRadioPainter({
    required this.checkAlpha,
    required this.trimEnd,
    required this.color,
  });

  // Alpha and trim are separate updateTransition channels in RadioButton.kt.
  final double checkAlpha;
  final double trimEnd;

  // Enabled and disabled states use primary and disabledPrimary respectively.
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // An empty path at zero avoids a stray round stroke-cap pixel.
    if (checkAlpha <= 0 || trimEnd <= 0) {
      return;
    }
    // Metrics translate the original 56 dp viewport into the actual canvas.
    final metrics = debugMiuixRadioMetrics(size);
    final path = _trimmedMiuixRadioPath(
      start: metrics.start,
      middle: metrics.middle,
      end: metrics.end,
      trimEnd: trimEnd,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: checkAlpha.clamp(0.0, 1.0))
        ..style = PaintingStyle.stroke
        ..strokeWidth = metrics.strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MiuixRadioPainter oldDelegate) {
    return checkAlpha != oldDelegate.checkAlpha ||
        trimEnd != oldDelegate.trimEnd ||
        color != oldDelegate.color;
  }
}

@visibleForTesting
({Offset start, Offset middle, Offset end, double strokeWidth})
debugMiuixRadioMetrics(Size size) {
  // The upstream radio asset is authored in a 56 by 56 vector viewport.
  const viewportSize = 56.0;

  // Scaling around the center preserves the exact original visual balance.
  final center = Offset(size.width / 2, size.height / 2);
  Offset point(double x, double y) => Offset(
    center.dx + ((x - viewportSize / 2) / viewportSize * size.width),
    center.dy + ((y - viewportSize / 2) / viewportSize * size.height),
  );
  return (
    start: point(10.9, 29),
    middle: point(23.1, 40.8),
    end: point(44, 16),
    strokeWidth: size.width * 7 / viewportSize,
  );
}

Path _trimmedMiuixRadioPath({
  required Offset start,
  required Offset middle,
  required Offset end,
  required double trimEnd,
}) {
  // Zero progress intentionally returns a path without a current point.
  if (trimEnd <= 0) {
    return Path();
  }
  // Segment lengths convert normalized progress into uniform path distance.
  final firstLength = (middle - start).distance;
  final secondLength = (end - middle).distance;
  final totalLength = firstLength + secondLength;
  // The clamp protects painting from out-of-range animation values.
  final endDistance = totalLength * trimEnd.clamp(0.0, 1.0);
  final path = Path()..moveTo(start.dx, start.dy);

  // Interpolate within whichever check segment contains the reveal endpoint.
  Offset lerpOffset(Offset a, Offset b, double t) {
    return Offset(ui.lerpDouble(a.dx, b.dx, t)!, ui.lerpDouble(a.dy, b.dy, t)!);
  }

  if (endDistance <= firstLength) {
    final ratio = (endDistance / firstLength).clamp(0.0, 1.0);
    final p = lerpOffset(start, middle, ratio);
    path.lineTo(p.dx, p.dy);
  } else {
    path.lineTo(middle.dx, middle.dy);
    final ratio = ((endDistance - firstLength) / secondLength).clamp(0.0, 1.0);
    final p = lerpOffset(middle, end, ratio);
    path.lineTo(p.dx, p.dy);
  }

  return path;
}
