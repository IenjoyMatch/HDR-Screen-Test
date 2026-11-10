// Copyright 2026 flutter_miuix contributors.
//
// MIUIX 1.0.9 NumberPicker source-parity contract.
//
// Authority
//
// Normative behavior comes from basic/NumberPicker.kt.
// Example placement comes from component/NumberPickerSection.kt.
// Flutter ListWheelScrollView and CupertinoPicker are not authorities.
//
// Public state
//
// value is an externally controlled integer.
// onValueChange reports a settled selection.
// Values outside the source range are visually coerced into that range.
// The source callback remains required even when enabled is false.
// MiuixNumberPicker.source exposes value, onValueChange, and range.
// The min, max, onChanged, and optional step form remains compatible.
// Source adapters always use a contiguous integer range.
// Compatibility step values do not alter the source adapter.
//
// Validation and compatibility
//
// Source visibleItemCount must be odd and at least three.
// Compatibility input below three is raised to three.
// Compatibility even counts are raised to the next odd count.
// Source ranges must be non-empty and ascending.
// Compatibility reversed bounds are normalized into ascending order.
// Compatibility zero or negative steps become a positive non-zero step.
// An off-grid controlled value resolves to its nearest available entry.
// Ties between compatibility entries retain the lower entry.
//
// Colors
//
// NumberPickerColors is an immutable four-channel data value.
// selectedTextColor paints the enabled center row.
// unselectedTextColor supplies enabled off-center interpolation.
// disabledSelectedTextColor paints the disabled center row.
// disabledUnselectedTextColor supplies disabled off-center interpolation.
// Every channel can be overridden independently.
// Equality and copy behavior mirror the Kotlin data class.
// enabled selects channels directly; no generic opacity wrapper is applied.
//
// Default color roles
//
// Selected text defaults to onSurface.
// Unselected text defaults to onSurfaceSecondary.
// Disabled selected text defaults to disabledOnSecondary.
// Disabled unselected text also defaults to disabledOnSecondary.
// Light fixed defaults are black, 80 percent black, and FCFCFC disabled.
//
// Layout
//
// Default item height is exactly 45dp.
// Default visible item count is exactly five.
// Total authored height is itemHeight multiplied by visibleItemCount.
// Compose rounds that total into one integer physical placeable.
// onSizeChanged divides the physical total by visibleItemCount using integers.
// At 420dpi, 225dp becomes 591px while row motion uses a 118px pitch.
// The component fills available width and clips all prepared overflow rows.
// It does not draw a selection capsule, divider, mask, or magnifier.
//
// Text
//
// Default style is MIUIX title1 at exactly 32sp.
// Missing font weight is replaced with SemiBold.
// A caller-provided weight is retained unchanged.
// A caller style with unspecified font size remains unspecified.
// NumberPicker does not replace the caller style with title1.
// Text is centered, single-line, and ellipsized.
// Every displayed and semantic value passes through the same label function.
//
// Prepared rows
//
// One extra row is prepared beyond both visible edges.
// Slots iterate from negative half-count minus one.
// Slots end at positive half-count plus one.
// Non-wrapping out-of-range slots are skipped.
// Wrapped indexes use positive modulo normalization.
// Rows retain this exact negative-to-positive source paint order.
// The center is not artificially moved to the top compositing layer.
//
// Distance visuals
//
// distanceFromCenter is slot minus the fractional center offset.
// Normalized distance divides absolute distance by halfCount plus 0.5.
// Normalized distance is clamped into zero through one.
// Alpha is (1 - distance) times (1 - distance times 0.5).
// Scale is 1 - 0.2 times distance.
// Color linearly interpolates selected into unselected by distance.
// Translation is distance times the integer-derived row pitch.
// No cylindrical perspective or nonlinear vertical projection participates.
//
// Offset state
//
// The controlled value is always the zero-offset center.
// Drag offset and fling offset combine into one item-relative total.
// Dragging upward increases the selected integer.
// Dragging downward decreases the selected integer.
// Non-wrapping offsets clamp against the first and last legal indexes.
// Wrapped offsets remain unbounded until commitment.
// External value changes reset idle transient motion.
//
// Kotlin rounding
//
// Effective index uses Kotlin Float.roundToInt.
// Snap target also uses Kotlin Float.roundToInt.
// Positive and negative half ties round toward positive infinity.
// Therefore +0.5 becomes +1 while -0.5 becomes zero.
// Dart double.round cannot replace this behavior for negative half ties.
// Rendering, haptics, and commitment share the same rounding helper.
//
// Drag and replacement
//
// Drag start stops any active fling.
// The visible fling remainder remains the new drag origin.
// Drag updates subtract pointer delta divided by row pitch.
// Drag cancellation restores the controlled center without callback.
// Disabling during interaction stops and clears transient motion.
// A replacement drag may legitimately cancel the previous ticker future.
//
// Decay and snap
//
// Release velocity converts from pixels per second into items per second.
// Its sign is inverted so upward velocity advances values.
// Exponential decay uses frictionMultiplier exactly two.
// The source exponential coefficient is therefore negative 8.4.
// Flutter FrictionSimulation receives exp(-8.4) as its drag base.
// Non-wrap decay stops exactly at its current legal boundary.
// Wrap decay remains unbounded.
// The nearest item then uses a critically damped spring.
// Snap stiffness is exactly 400.
// Unit mass and critical damping produce damping coefficient exactly 40.
// Callback runs only when the settled value differs from controlled value.
//
// Haptics
//
// Effective index changes emit TextHandleMove only during user scrolling.
// Repeated frames inside one rounded row do not emit duplicates.
// Crossing multiple rows can emit one tick for every observed index.
// Programmatic and external value resets remain silent.
// User-scrolling state clears before the post-callback offset reset.
// That order prevents a false reverse tick when the owner ignores a callback.
//
// Semantics
//
// The component publishes one content description.
// Its exact form is `displayValue, first - last`.
// It does not publish progress range or increment/decrement actions.
// Passing rows are excluded from the semantic tree.
// Semantics always describes the controlled value.
// The caller's label output, not the raw integer, is announced.
//
// Localized example
//
// The section title is localized as 数字选择器.
// Initial hour remains 16 and initial minute remains 30.
// Hour range is 0 through 23 and minute range is 0 through 59.
// Both wheels wrap and render two-digit labels.
// A bold 20sp colon remains centered between equal-width wheels.
// At 420dpi, Compose measures that colon as a 15px text placeable.
// The localized example density-ceils that text measurement, then distributes
// the odd weighted remainder as integer placeables to retain the source
// 468px / 15px / 469px split without a one-pixel semantic gap.
// Card, 12dp outside bottom margin, and 12dp inner padding match source.
//
// Regression evidence
//
// Tests cover exact geometry and 420dpi physical row pitch.
// Tests cover flat Stack rendering and source slot paint order.
// Tests cover all four custom and default color channels.
// Tests cover immutable copy and value equality.
// Tests cover source adapter parameter forwarding.
// Tests cover custom text styles without invented font size.
// Tests cover Kotlin positive and negative half ties.
// Tests cover bounded, wrapping, disabled, drag, fling, and initial state.
// Tests cover displayed-label semantics and TextHandleMove feedback.
// Six component goldens cover normal, dark, disabled, pressed, expanded, and
// animation-midpoint fixtures.
//
// Maintenance rule
//
// Future changes must be compared directly against NumberPicker.kt.
// Do not substitute ListWheelScrollView or CupertinoPicker.
// Do not use Dart round for item commitment.
// Do not move the center row after the source paint loop.
// Do not add a selector surface that the source does not draw.
// Compatibility extensions must delegate to the same source state machine.
