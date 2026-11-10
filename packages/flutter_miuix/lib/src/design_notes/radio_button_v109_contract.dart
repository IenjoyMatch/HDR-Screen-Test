// Copyright 2026 flutter_miuix contributors.
//
// MIUIX 1.0.9 RadioButton source-parity contract.
//
// Authority
//
// Normative behavior comes from basic/RadioButton.kt.
// Press motion comes from utils/Pressable.kt and SinkFeedback.
// The check path comes from miuix-classic SingleChoicePreference.
// Flutter Material Radio is not a visual or timing authority.
//
// Source API
//
// selected is a boolean owned by the caller.
// onClick is a direct callback and does not mutate selected.
// A null onClick removes selectable interaction.
// enabled controls selection action, haptic, color, and press feedback.
// MiuixRadioButton.source exposes this exact selected plus onClick form.
// MiuixRadio retains the group-value Flutter compatibility form.
// Both public forms share one painter, motion, semantics, and haptic path.
//
// Colors
//
// RadioButtonColors is an immutable two-channel data value.
// selectedColor is used whenever the control is enabled.
// disabledSelectedColor is used whenever the control is disabled.
// Unselected paint uses the same channel but is hidden by animated alpha.
// selectedColor defaults to the MIUIX primary semantic role.
// disabledSelectedColor defaults to disabledPrimary.
// Each default can be overridden independently.
// Equality and copy behavior mirror the Kotlin data class.
// Source changes to enabled or colors update the painted channel immediately.
//
// Layout
//
// Visible required size is exactly 26dp square.
// Platform minimum interactive target is exactly 48dp.
// The two sizes are independently rounded to physical pixels.
// The 48dp target exists only when onClick is non-null.
// Expanded hit bounds must not enlarge the authored Flex slot.
// A callback-free radio keeps only the authored 26dp slot and pointer bounds.
// The capsule clip resolves to a circle for the square visual.
//
// Check path source coordinates
//
// Authored vector viewport is exactly 56 by 56.
// Start point is exactly (10.9, 29).
// Middle point is exactly (23.1, 40.8).
// End point is exactly (44, 16).
// Mapping is center-relative in both axes.
// Stroke width is exactly 7 divided by 56 times visible width.
// Stroke cap is round.
// Stroke join is round.
// No circle, border, or Material state layer is drawn behind the check.
//
// Trim algorithm
//
// First and second segment lengths are calculated independently.
// Total path length is their sum.
// trimEnd multiplies total path length.
// The path always begins at the authored start point.
// A trim inside segment one interpolates only that segment.
// A trim beyond segment one draws the complete first segment.
// Remaining trim then interpolates the second segment.
// Second-segment ratio is clamped to one.
// Alpha or trimEnd at zero returns without drawing.
//
// Transition
//
// updateTransition is keyed by selected.
// Selecting targets check alpha one.
// Deselecting targets check alpha zero.
// Selecting alpha uses a 10ms FastOutSlowIn tween.
// Deselecting alpha uses a 150ms FastOutSlowIn tween.
// Selecting trimEnd targets one.
// Deselecting trimEnd targets zero.
// Both trim directions use a 300ms FastOutSlowIn tween.
// Alpha and trim remain independent transition channels.
// Rapid retargeting begins at the currently displayed frame.
//
// Press feedback
//
// Sink target scale is exactly 0.85.
// Sink damping ratio is exactly 0.99.
// Sink stiffness is exactly 986.96.
// Press indication begins without delay.
// Pressable is installed even when onClick is null.
// An enabled read-only radio therefore retains source sink motion.
// Feedback-only motion does not create a semantic tap action.
// A disabled radio emits no sink motion.
//
// Toggle and haptics
//
// onClick runs before haptic feedback.
// An unselected click emits ToggleOn.
// A selected click emits ToggleOff.
// Source intentionally permits clicking an already selected radio.
// A disabled radio invokes neither callback nor haptic.
// A null callback invokes neither callback nor haptic.
//
// Semantics
//
// Interactive role is RadioButton.
// selected maps to checked state.
// The node reports membership in a mutually exclusive group.
// enabled state is explicit.
// A callback-free radio has no tap action.
// A disabled node stays independently bounded instead of merging into its row.
// Compatibility group-value selection resolves before semantics are built.
//
// Regression evidence
//
// Tests cover both immutable color channels.
// Tests cover default semantic role resolution.
// Tests cover copy and value equality.
// Tests cover the source selected plus onClick adapter.
// Tests cover a custom painter color.
// Tests cover read-only feedback without a semantic action.
// Tests cover the independent alpha and trim timelines.
// Tests cover exact viewport points and stroke width.
// Tests cover ToggleOn and ToggleOff native haptic roles.
// Tests cover source preference placement in the localized example.
//
// Maintenance rule
//
// Future changes must be checked directly against RadioButton.kt.
// Do not add Material Radio circles or splash behavior.
// Do not couple alpha duration to trim duration.
// Do not remove press feedback solely because onClick is absent.
// Compatibility group APIs must delegate to the source painter and motion.
