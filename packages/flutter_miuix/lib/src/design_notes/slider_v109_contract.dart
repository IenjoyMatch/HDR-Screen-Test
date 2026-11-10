// Copyright 2026 flutter_miuix contributors.
//
// MIUIX 1.0.9 Slider family source-parity contract.
//
// Authority
//
// Normative behavior comes from basic/Slider.kt.
// This contract covers Slider, VerticalSlider, and RangeSlider.
// Flutter Material sliders are not geometry, color, or gesture authorities.
//
// Public source adapters
//
// Slider.source exposes value and onValueChange.
// VerticalSlider.source exposes value and onValueChange.
// RangeSlider.source exposes value and onValueChange.
// Source onValueChange is required even when enabled is false.
// The existing onChanged forms remain Flutter compatibility APIs.
// Source onValueChangeFinished maps to the shared completion callback.
// Source nullable keyPoints maps to an empty compatibility list.
// The caller remains responsible for committing every emitted value.
//
// Steps conversion
//
// Source steps counts allowable values strictly between both endpoints.
// Compatibility divisions counts intervals across the complete range.
// A positive source steps value therefore maps to steps plus one divisions.
// Source steps zero maps to a continuous slider with null divisions.
// Discrete steps take precedence over custom magnetic key points.
// The step result uses the nearest interval with Kotlin-style rounding.
//
// Colors
//
// SliderColors is an immutable eight-channel data value.
// foregroundColor paints the enabled selected track.
// disabledForegroundColor paints the disabled selected track.
// backgroundColor paints the enabled unselected track.
// disabledBackgroundColor paints the disabled unselected track.
// thumbColor paints every enabled thumb.
// disabledThumbColor paints every disabled thumb.
// keyPointColor paints a marker outside selected fill.
// keyPointForegroundColor paints a marker inside selected fill.
// Every channel can be overridden independently.
// Equality and copy behavior mirror the Kotlin data class.
// All three slider variants consume the same public color model.
//
// Default color roles
//
// Enabled foreground defaults to primary.
// Disabled foreground defaults to disabledPrimarySlider.
// Enabled background defaults to sliderBackground.
// Disabled background defaults to disabledSecondary.
// Enabled thumb defaults to onPrimary.
// Disabled thumb defaults to disabledOnPrimary.
// Key points default to sliderKeyPoint.
// Selected key points default to sliderKeyPointForeground.
//
// Public defaults
//
// MinHeight is exactly 28dp.
// KeyPointRadius is exactly 3.855dp.
// DefaultHapticEffect is Edge.
// Flutter names use lower camel case while retaining the exact values.
// The vertical source `effect` argument is retained publicly.
// MIUIX 1.0.9 declares but does not read that `effect` argument.
//
// Track geometry
//
// The ordinary and range slider default cross axis is exactly 28dp.
// VerticalSlider default width is exactly 28dp.
// The track fills the complete authored cross-axis extent.
// Track radius is one half of that extent.
// Thumb radius is track radius multiplied by 0.72.
// Hover or drag multiplies only the owning thumb by 1.127.
// Visible key-point radius is current cross-axis extent divided by 7.5.
// The declared 3.855dp public constant remains exposed independently.
// Main-axis travel excludes one cross-axis radius at each endpoint.
// The complete authored track is clipped by the source smooth capsule.
// No Material rail, overlay, tick, or state layer is painted.
//
// Horizontal direction
//
// LTR default increases from left to right.
// Horizontal reverseDirection swaps that mapping.
// RTL inverts the authored reverseDirection value.
// Active fill begins at the effective minimum edge.
// The minimum value leaves the active fill visually empty.
// Pointer mapping and painting share the same effective direction.
//
// Vertical direction
//
// Default increases from bottom to top.
// reverseDirection true increases from top to bottom.
// Vertical behavior is independent from layout direction.
// Active fill begins at the physical bottom in the default direction.
// Minimum value leaves the vertical active fill visually empty.
//
// Range direction and ownership
//
// RangeSlider mirrors automatically in RTL.
// Start and end values cannot cross.
// The closest thumb owns a gesture that starts away from both hit radii.
// The previously active thumb wins when both overlap.
// Moving an equal start forward transfers ownership to the end thumb.
// Moving an equal end backward transfers ownership to the start thumb.
// Only the active or directly hovered thumb receives emphasis scaling.
// Start thumb paints first and end thumb paints second when overlapping.
//
// Pointer target
//
// Authored horizontal cross-axis size remains 28dp by default.
// A centered transparent 48dp target owns horizontal pointer motion.
// VerticalSlider analogously expands its horizontal target to 48dp.
// Target expansion does not change the painted size or parent layout slot.
// A stationary pointer produces no source value callback.
// A qualified drag begins by resolving the original down coordinate.
// Horizontal slider intent wins against an ancestor PageView.
// VerticalSlider intent likewise wins against an ancestor vertical viewport.
// Its recognizer accepts clearly vertical motion before the shared Flutter
// slop lets a parent ListView win, and rejects clearly horizontal motion so a
// surrounding root pager remains available outside the slider's orientation.
// Disabled variants install no priority recognizer and remain inert.
//
// Vertical gesture-arena translation
//
// Flutter places a child VerticalDragGestureRecognizer and its parent
// Scrollable recognizer in one arena for the same pointer identifier.
// Both stock recognizers normally wait for the same platform touch slop.
// Android can batch the first meaningful movement far enough that both cross
// that threshold during one dispatch, after which arena ordering may select
// the parent list even though the pointer began on the narrow slider.
// Compose's draggable modifier instead owns the matching orientation at the
// compact control, so leaving the stock Flutter race is not source-equivalent.
//
// The priority recognizer records each allowed pointer's global down origin.
// It compares cumulative horizontal and vertical displacement on every move.
// Intent checking begins at fifteen percent of the platform hit slop, with a
// one-logical-pixel floor so stationary noise cannot start a source drag.
// Vertical displacement must exceed horizontal displacement by factor 1.15.
// Such a sequence is accepted immediately for the VerticalSlider.
// Horizontal displacement with the symmetric ratio is rejected immediately.
// Diagonal motion inside that band keeps waiting for ordinary direction data.
// This matches the horizontal control's already verified pager arbitration.
//
// DragStartBehavior.down preserves the original pointer-down coordinate.
// The callback itself is deferred until qualified motion has been observed.
// This separation prevents Flutter's pointer-up arena sweep from converting a
// stationary press into a drag-start value change absent from Slider.kt.
// The deferred start is delivered once before the first update or end event.
// Qualified cancel and end callbacks preserve completion and motion teardown.
// Pointer origin, deferred details, qualification, and delivery state are all
// cleared when the final pointer ends, so no gesture leaks into the next drag.
//
// The recognizer changes ownership only, not source value mathematics.
// `_valueAt` still excludes one cross-axis radius at each main-axis endpoint.
// Default direction still maps bottom to maximum and top to minimum visually.
// Discrete steps, custom magnets, haptics, springs, paint, and semantics remain
// on the shared VerticalSlider body after the gesture has been accepted.
// The transparent 48dp cross-axis target is also unchanged by this repair.
// Transform.scale expands that target only across the horizontal axis.
// Pointer details delivered below the transform remain in authored local
// coordinates, so value mapping continues to use the 25dp visual width and
// 160dp example height rather than the 48dp semantic hit width.
// The parent Column's equal-weight allocation therefore cannot change.
// A disabled slider supplies no start, update, end, or cancel callback.
// The helper consequently returns the visual child without a recognizer.
// This prevents an inert control from blocking ordinary page scrolling.
// Each pointer has an independent origin entry until it ends or is rejected.
// Acceptance still resolves Flutter's complete arena for that pointer only.
// Multi-touch bookkeeping is cleared only after the final active pointer.
// No global pointer route or Listener consumes events outside the target.
// Mouse hover continues through MouseRegion and does not enter this arena.
// Keyboard accessibility increase/decrease remains independent of dragging.
//
// Runtime verification must use an actual Android pointer stream inside Home.
// A widget test alone cannot reproduce Android batching or engine arena order.
// The pre-fix scene must demonstrate that the page moved while value did not.
// The post-fix scene must show a changed localized value with identical five
// target rectangles, identical selected root destination, and a clean log.
//
// Value animation
//
// While dragging, progress uses damping ratio 0.9 and stiffness 1755.
// At rest, progress uses damping ratio 0.96 and stiffness 322.
// Progress retargeting preserves current velocity.
// Visibility threshold is 0.01 in value units normalized by range span.
// External value updates animate through the resting spring.
// Both range endpoints animate through independent progress controllers.
//
// Thumb and track feedback
//
// Thumb scale uses damping ratio 0.6 and stiffness 987.
// Enabled drag or thumb hover targets scale 1.127.
// Rest and disabled state target scale one.
// Dragging darkens the background with black at alpha 0.044.
// Overlay entry and exit use a 150ms FastOutSlowIn tween.
// The overlay is clipped to the same authored capsule.
//
// Key points and magnetism
//
// Visible markers require showKeyPoints.
// Custom key points are normalized and clamped into the value range.
// With no custom points, visible markers come from discrete steps.
// Duplicate normalized markers are removed by the compatibility adapter.
// Continuous values snap only strictly inside magnetThreshold.
// Equality with the threshold does not snap.
// Default magnetThreshold is exactly 0.02 of normalized range.
// Marker selection follows the physical active-fill direction.
//
// Haptics
//
// None emits no feedback.
// Edge emits GestureThresholdActivate at each newly entered endpoint.
// Leaving an endpoint rearms its feedback.
// Step additionally emits TextHandleMove on a changed discrete step.
// Custom key points emit TextHandleMove only when newly entered.
// Custom key-point haptic proximity is strictly below 0.005 fraction.
// Range thumbs retain independent edge, step, and key-point state.
//
// Semantics
//
// The source node reports clamped value and range.
// Positive source steps are reported as interior step count.
// Set-progress clamps the requested value before callback.
// Compatibility increase and decrease actions follow steps or magnetism.
// Disabled state suppresses pointer changes without altering paint bounds.
// Internal drag recognizers do not expose duplicate scroll semantics.
//
// Regression evidence
//
// Tests cover all eight explicit color channels and defaults.
// Tests prove custom colors reach horizontal, vertical, and range painters.
// Tests cover source steps conversion.
// Tests cover all three physical springs and the track overlay tween.
// Tests cover 28dp geometry, 0.72 thumb, and marker radius.
// Tests cover RTL, reverseDirection, vertical direction, and range handoff.
// Tests cover key-point display, strict magnetism, and step precedence.
// Tests cover pager gesture ownership, 48dp targets, and haptic roles.
// A nested-list regression proves VerticalSlider changes while scroll offset
// remains fixed, matching Compose draggable ownership on the compact control.
//
// Maintenance rule
//
// Future changes must be checked directly against Slider.kt.
// Do not substitute Material Slider or RangeSlider painters.
// Do not equate source steps with Flutter divisions.
// Do not collapse the eight source color channels into enabled opacity.
// Do not change the declared-but-unused vertical effect behavior.
// Compatibility APIs must delegate to the same source painter and motion.
