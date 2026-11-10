// Copyright 2026 flutter_miuix contributors.
//
// MIUIX 1.0.9 Checkbox source-parity contract.
//
// Authority
//
// The normative implementation is basic/Checkbox.kt.
// Press indication behavior is defined by utils/Pressable.kt and SinkFeedback.
// Theme channels are defined by CheckboxDefaults.checkboxColors.
// Flutter Material Checkbox is not a geometry or animation authority.
//
// Public state
//
// Source state is ToggleableState Off, On, or Indeterminate.
// Flutter's source-named adapter accepts false, true, or null respectively.
// The legacy value plus indeterminate form remains available for compatibility.
// Source onClick does not choose or mutate the next state.
// The caller remains responsible for updating state after onClick.
// A null onClick omits tri-state toggle semantics and click handling.
// enabled controls colors, toggle action, press handling, and semantics.
// enabled remains independent from the presence of onClick.
//
// Public colors
//
// CheckboxColors is an immutable eight-channel data value.
// checkedForegroundColor is used by enabled On and Indeterminate states.
// uncheckedForegroundColor is used by enabled Off.
// disabledCheckedForegroundColor is used by disabled On and Indeterminate.
// disabledUncheckedForegroundColor is used by disabled Off.
// checkedBackgroundColor is used by enabled On and Indeterminate.
// uncheckedBackgroundColor is used by enabled Off.
// disabledCheckedBackgroundColor is used by disabled On and Indeterminate.
// disabledUncheckedBackgroundColor is used by disabled Off.
// Equality and copy behavior mirror the Kotlin data class.
//
// Default color roles
//
// Checked foreground defaults to onPrimary.
// Unchecked foreground defaults to secondary.
// Disabled checked foreground defaults to disabledOnPrimary.
// Disabled unchecked foreground defaults to disabledOnPrimary.
// Checked background defaults to primary.
// Unchecked background defaults to secondary.
// Disabled checked background defaults to disabledPrimary.
// Disabled unchecked background defaults to disabledSecondary.
// Every channel can be overridden independently.
//
// Layout
//
// Authored visible size is requiredSize(26.dp).
// The visual circle remains exactly 26dp at every supported density.
// Compose converts 26dp to integer physical pixels before centering.
// Flutter reproduces that conversion before returning to logical coordinates.
// A callback-backed toggle receives the platform 48dp minimum touch target.
// Compose converts that 48dp target independently to integer physical pixels.
// The expanded target must not enlarge the authored Flex layout slot.
// A checkbox without onClick keeps only its authored 26dp layout and hit area.
//
// Shape and background
//
// The source capsule shape resolves to a circle for the square 26dp bounds.
// Background is drawn as one filled circle.
// No Material border, splash, elevation, or state-layer overlay participates.
// Disabled appearance comes from dedicated semantic colors, not Opacity.
//
// Check path geometry
//
// The authored path viewport is exactly 23 by 23.
// Start point is exactly (5, 9.4).
// Middle point is exactly (10.3, 14.9).
// End point is exactly (17.9, 5.1).
// Points are mapped around the center of the actual square.
// Stroke width is exactly 9 percent of the visible width.
// Stroke cap is round.
// Stroke join is round.
// The source miter value is immaterial for the round two-segment path.
//
// Arc-length trimming
//
// The first and second segment lengths are calculated independently.
// Total length is their sum.
// trimStart and trimEnd multiply total path length.
// The first segment draws only where the trim interval intersects it.
// The second segment draws only where the trim interval intersects it.
// Crossing the middle point produces one continuous path.
// Starting within the second segment begins a new subpath there.
//
// Transition colors
//
// Background uses a 300ms FastOutSlowIn tween for every state change.
// Foreground uses a 300ms FastOutSlowIn tween for every state change.
// On and Indeterminate share the same checked color targets.
// Off uses the unchecked color targets.
// Theme and custom-color changes retarget from the current animated frame.
//
// Check alpha
//
// Entering either visible state reaches alpha one over 10ms.
// Exiting to Off reaches alpha zero over 150ms.
// Both alpha tweens use FastOutSlowIn easing.
// A state change whose resolved alpha target is unchanged does not restart it.
//
// Start trim
//
// Visible start trim target is exactly 0.186.
// Off start trim target is exactly 0.1.
// Entering uses a 200ms FastOutSlowIn tween.
// Exiting uses a 300ms keyframe endpoint with linear interpolation.
// On and Indeterminate share the same start-trim target.
//
// End trim
//
// Visible end trim target is exactly 0.803.
// Off end trim target is exactly 0.1.
// Entering first moves linearly to exactly 0.85 at 200ms.
// Entering then eases from 0.85 to 0.803 over the final 100ms.
// Exiting moves linearly to 0.1 over 300ms.
// On-to-Indeterminate does not replay the overshoot keyframe.
// Indeterminate-to-On does not replay the overshoot keyframe.
//
// Indeterminate gravitation
//
// On and Off gravitation target is zero.
// Indeterminate gravitation target is one.
// Entering Indeterminate uses a 200ms FastOutSlowIn tween.
// Leaving Indeterminate uses a 150ms FastOutSlowIn tween.
// Endpoint x coordinates stay authored while endpoint y moves to center.
// The middle point moves to the exact visual center on both axes.
// Full gravitation therefore produces the source horizontal mixed mark.
//
// Press feedback
//
// Sink target scale is exactly 0.85.
// Sink damping ratio is exactly 0.99.
// Sink stiffness is exactly 986.96.
// Press indication has no artificial delay.
// Pressable is installed even when onClick is null.
// A read-only enabled checkbox therefore still sinks while pressed.
// That feedback-only press must not add a semantic tap action.
// A disabled checkbox emits no press feedback.
//
// Toggle and haptics
//
// Callback invocation occurs before haptic feedback.
// Off emits ToggleOn.
// On emits ToggleOff.
// Indeterminate emits SegmentTick.
// A disabled checkbox invokes neither callback nor haptic.
// A null callback invokes neither callback nor haptic.
//
// Semantics
//
// Interactive source role is Checkbox.
// Off reports checked false.
// On reports checked true.
// Indeterminate reports mixed checked state.
// Disabled state remains explicitly represented.
// A callback-backed disabled control retains its no-op toggle boundary.
// A callback-free control has no tap action.
//
// Regression evidence
//
// Tests cover every authored path coordinate and stroke ratio.
// Tests cover every transition channel and both entering keyframes.
// Tests cover unchanged On and Indeterminate trim targets.
// Tests cover enabled and disabled semantic palette roles.
// Tests cover all eight explicit custom color channels.
// Tests cover data equality and copy behavior.
// Tests cover the source tri-state constructor and direct onClick.
// Tests cover read-only press feedback without semantic activation.
// Tests cover state-specific native haptic roles.
// Goldens cover normal, disabled, pressed, dark, and animation frames.
//
// Maintenance rule
//
// Future changes must be compared directly against Checkbox.kt.
// Stock Flutter Checkbox geometry or animation must not replace this painter.
// Every new color option must preserve eight-channel independent resolution.
// Compatibility APIs must delegate to the same source state machine.
