// Copyright 2026 flutter_miuix contributors.
//
// MIUIX 1.0.9 ScrollBar source-parity contract.
//
// Authority
//
// The normative source is basic/ScrollBar.kt from the checked MIUIX 1.0.9 tree.
// Flutter Material Scrollbar behavior is not a visual or timing authority.
// VerticalScrollBar and HorizontalScrollBar share the same internal algorithm.
// ScrollBarAdapter is the sole source-side connection to scroll state.
//
// Public state adapter
//
// scrollOffset is the current logical content offset.
// contentSize is the complete estimated or exact content extent.
// viewportSize is the currently visible content extent.
// scrollTo accepts an absolute logical content offset.
// The Flutter adapter delegates those values to one shared ScrollController.
// The adapter never creates, disposes, or takes ownership of that controller.
// A standalone overlay may use the adapter without wrapping the scrollable.
// The wrapper form may instead learn metrics from depth-zero notifications.
// Nested editor and inner viewport notifications must not replace page metrics.
//
// Source defaults
//
// ThumbWidth is exactly 3.64 logical pixels.
// EndPadding is exactly 3.46 logical pixels.
// ThumbMinLength is exactly 36 logical pixels.
// CornerRadius is unspecified and resolves to half animated thumb width.
// TouchTargetWidth is exactly 48 logical pixels.
// DragThumbWidth is exactly 6 logical pixels.
// ThumbAlpha is exactly 0.1.
// DragThumbAlpha is exactly 0.3.
// FadeDelayMillis is exactly 1000.
// FadeDurationMillis is exactly 500.
// DragAnimationDurationMillis is exactly 150.
//
// Color contract
//
// ScrollBarColors is an immutable two-channel data value.
// An unspecified thumb uses the current theme onSurface color.
// The themed thumb uses alpha 0.1 while resting.
// The themed thumb uses alpha 0.3 while hovered or dragged.
// An explicit thumb retains its own alpha in both interaction states.
// Highlighting still changes the width of an explicitly colored thumb.
// An unspecified track draws no source track.
// An explicit track retains its own color and base alpha.
// Track alpha is multiplied by the same current fade opacity.
// Data equality and copy behavior mirror the Kotlin data class.
//
// Visibility lifecycle
//
// Initial automatic opacity is zero.
// The initial adapter value is skipped and does not reveal the thumb.
// A subsequent scroll-offset change sets opacity to one immediately.
// Every new offset cancels and replaces the previous hide job.
// Fully visible state is held for 1000 milliseconds.
// Opacity then moves linearly from one to zero over 500 milliseconds.
// Hover cancels the hide job and restores opacity immediately.
// A valid thumb drag cancels the hide job and restores opacity immediately.
// Leaving hover schedules the same hold and fade sequence.
// Ending a drag schedules the same hold and fade sequence.
// Persistent compatibility visibility bypasses automatic opacity.
//
// Highlight animation
//
// Hovering and dragging are combined with logical OR.
// The combined highlight state drives width and themed alpha.
// Width moves linearly between 3.64 and 6 over 150 milliseconds.
// Themed alpha moves linearly between 0.1 and 0.3 over 150 milliseconds.
// An explicit thumb alpha is not interpolated.
// Hover applies to the complete measured scrollbar component.
// Drag highlighting begins only after a down point intersects the thumb.
//
// Measurement and edge placement
//
// The source vertical component measures thumbWidth plus twice endPadding.
// Its default cross extent is therefore 10.56 logical pixels.
// The source horizontal component uses the same value as its measured height.
// The pointer code checks a 48-pixel strip within that narrow component.
// Consequently the effective default target is the complete 10.56-pixel bar.
// A wrapper overlay must reproduce that effective target, not steal page width.
// Vertical drawing uses physical right, not logical end.
// RTL therefore does not move the vertical thumb to the left.
// Horizontal drawing uses the physical bottom edge.
// Horizontal track padding is deliberately resolved as LTR.
// Vertical track padding consumes only top and bottom values.
// End padding keeps the highlighted outer edge stable as width changes.
//
// Thumb geometry
//
// Usable track size excludes before and after track padding.
// Visible fraction is viewportSize divided by contentSize.
// Natural thumb size is usable track size times visible fraction.
// Thumb size is the maximum of natural size and ThumbMinLength.
// The minimum is not clamped down to a tiny track.
// If thumb size fills or exceeds the track, painting returns immediately.
// That early return suppresses both an explicit track and the thumb.
// It also suppresses the interactive drag target.
// Scroll fraction uses offset relative to the complete scrollable range.
// Overscroll values are clamped into zero through one before painting.
// Normal position is travel multiplied by the clamped fraction.
// Reverse layout uses one minus that fraction.
// Before-track padding is added after the position calculation.
//
// Dynamic length
//
// The first observed thumb length is installed without animation.
// Changes below one physical logical unit are installed directly.
// Changes of at least one unit animate linearly for 150 milliseconds.
// A running length animation is not restarted by every paint.
// Position continues to use the current target source geometry.
// The rounded rectangle draws the independently animated displayed length.
//
// Track and thumb painting
//
// No painting occurs before valid container metrics exist.
// No painting occurs while automatic opacity is zero.
// The tiny-track early return occurs before explicit track drawing.
// The track uses the current animated thumb width.
// The track uses the same resolved corner radius as the thumb.
// A vertical track spans the padded usable height.
// A horizontal track spans the padded usable width.
// The thumb is a filled rounded rectangle, not a stroked line.
// An unspecified radius follows half of the current animated width.
// An explicit radius remains fixed while width animates.
//
// Pointer and drag behavior
//
// The first down may be observed even if another recognizer saw it.
// The down point must lie inside the source end strip.
// The down point must also lie inside the current thumb pixel range.
// A miss returns without consuming the page gesture.
// A valid down begins drag highlighting and consumes the gesture.
// Pointer delta maps proportionally from thumb travel to content travel.
// Reverse layout negates the drag-to-content direction.
// Destination offsets are clamped to current controller bounds.
// Drag cancellation and normal drag end share the same cleanup.
//
// Flutter compatibility surface
//
// MiuixScrollBar may wrap a child for idiomatic Flutter composition.
// MiuixVerticalScrollBar fixes the expected metric axis to vertical.
// MiuixHorizontalScrollBar fixes the expected metric axis to horizontal.
// trackVisibility is a compatibility aid and is not a source default.
// thumbVisibility is a compatibility aid and is not a source default.
// Compatibility options must not alter source behavior when left unset.
// Child constraints remain unchanged because visuals are stack overlays.
// Paint overlays ignore pointer events; the narrow drag layer owns input.
//
// Regression evidence
//
// Tests cover every exact public default and color value behavior.
// Tests cover a standalone ScrollController adapter and content geometry.
// Tests cover hover width, explicit alpha, and explicit corner radius.
// Tests cover physical-right placement under an RTL Directionality.
// Tests cover reverse position and reverse drag direction.
// Tests cover the 1000 plus 500 millisecond reveal-and-fade lifecycle.
// Tests cover actual thumb dragging through the narrow source target.
// Tests cover nested-notification isolation.
// A pixel test covers the no-track and no-thumb tiny-container return.
//
// Maintenance rule
//
// Future changes must be checked against ScrollBar.kt before implementation.
// Material defaults must never silently replace any value listed above.
// Any intentional compatibility extension must remain opt-in and documented.
// Source mapping gates must include Adapter, Colors, and Defaults types.
