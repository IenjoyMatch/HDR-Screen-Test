// ColorPalette.kt and ColorPicker.kt v1.0.9 maintenance contract.
//
// This file is deliberately comment-only. It records the upstream behavior
// that must remain true when the Flutter implementation is refactored.
//
// Public family.
// - MiuixColorPalette.source maps the complete upstream ColorPalette entry.
// - The earlier finite-list MiuixColorPalette remains a compatibility mode.
// - MiuixColorPicker.source maps the complete upstream ColorPicker entry.
// - HSV, OKHSV, OKLab, and OKLCH picker adapters remain public.
// - Every public channel slider has a source-named constructor.
// - Source constructors retain the upstream channel names and units.
// - MiuixCheckerboard maps the public drawCheckerboard modifier behavior.
// - Compatibility constructors remain available without changing source mode.
//
// ColorPalette state.
// - The default grid contains seven rows and twelve hue columns.
// - The default final column is a gray-value column.
// - The default preview is visible and exactly 26dp high.
// - Preview, palette, and alpha controls have 12dp vertical gaps.
// - The palette grid is exactly 180dp high.
// - The default grid corner radius is 16dp.
// - The default indicator radius is 10dp.
// - Seven-row saturation values are .10, .35, .70, 1, 1, 1, 1.
// - Seven-row value values are 1, 1, 1, .85, .65, .45, .20.
// - Non-seven-row ramps retain the upstream top-bright cutoff formula.
// - Gray values run linearly from one to zero.
// - Hue cells advance by 360 divided by hueColumns.
// - Colors below .05 saturation initially select the gray column.
// - Initial hue selection uses Kotlin-compatible nearest-column rounding.
// - Initial row selection minimizes squared saturation/value distance.
// - Gray row selection minimizes squared value distance.
// - External alpha is clamped to zero through one.
// - The most recently emitted color drives preview immediately.
// - Preview does not wait for a controlled parent to echo the color.
// - A parent echo within 1.5 hue degrees and .02 S/V keeps the cell.
// - That accepted echo may still refresh alpha.
// - A genuinely different external color recalculates row and column.
// - Every pointer-down sample emits a color callback.
// - Every subsequent pressed move sample emits a color callback.
// - Repeated samples in one cell are not suppressed.
// - Pointer down is published exactly once, not by two recognizers.
// - Real pointer movement is consumed before a parent pager can claim it.
// - Stationary pointer input remains a valid palette selection.
// - LTR maps the visual first column to hue index zero.
// - RTL maps the visual first column to the logical final column.
// - RTL reverses cell placement and pointer mapping together.
// - Cell edges use integer division of complete measured pixels.
// - The indicator uses the selected cell's integer edge midpoint.
// - The indicator has a 6dp white ring.
// - Its shadow uses the upstream four radial stops at 25% black.
// - Alpha changes retain the authored base cell.
// - Alpha changes update preview before a parent echo.
// - Palette alpha uses the standard source edge-haptic policy.
//
// ColorPicker state.
// - ColorPicker selects one of four independent color-space implementations.
// - Changing color space recreates channel state from the external color.
// - Each picker initializes its channel state only once for that branch.
// - User changes update local channel state before invoking the callback.
// - The callback is skipped only when the resulting ARGB equals external ARGB.
// - A controlled parent echo equal to internal ARGB does not reset channels.
// - A genuinely different external ARGB replaces every channel and alpha.
// - The preview uses the current internal selected color.
// - Preview is 26dp and uses the active capsule/G2 shape.
// - Four channel sliders are separated by exact 12dp gaps.
// - showPreview false removes both the preview and its following gap.
// - The haptic policy is forwarded identically to all four sliders.
//
// HSV contract.
// - HSV picker state stores hue in degrees.
// - HSV picker stores saturation, value, and alpha from zero through one.
// - HsvHueSlider currentHue is zero through 360.
// - HsvHueSlider source callback is normalized zero through one.
// - The compatibility hue callback may retain degree output.
// - Hue gradients cover the complete pure-HSV cycle.
// - Saturation runs from white-at-hue to fully saturated hue.
// - Value runs from black to the selected full-value HSV color.
// - Alpha runs from transparent to opaque selected HSV color.
//
// OKHSV contract.
// - OKHSV hue, saturation, value, and alpha are normalized.
// - OKHSV hue uses the upstream perceptually uniform hue sequence.
// - Saturation endpoints are generated at the current hue.
// - Value endpoints are generated at current hue and saturation.
// - Alpha preserves current H, S, and V while changing only opacity.
//
// OKLab contract.
// - OKLab lightness is normalized zero through one.
// - OKLab A and B are physical opponent values, not normalized values.
// - The authored A slider range is exactly -0.3 through 0.3.
// - The authored B slider range is exactly -0.3 through 0.3.
// - Neither channel may silently expand to -0.4 through 0.4.
// - A and B callbacks publish physical opponent values.
// - Lightness uses eight gradient colors from zero through one.
// - A uses nine gradient colors across -0.3 through 0.3.
// - B uses nine gradient colors across -0.3 through 0.3.
// - Alpha converts current L/A/B without changing those channels.
// - Parent picker normalization maps -0.3..0.3 to the painted zero..one track.
//
// OKLCH contract.
// - Public source currentL is normalized.
// - Public source currentC is normalized and scales internally by .4.
// - Public source currentH is normalized and scales internally by 360.
// - Lightness endpoints preserve current chroma and hue.
// - Chroma endpoints preserve current lightness and hue.
// - Hue uses the upstream generated perceptual hue sequence.
// - Alpha preserves L, C, and H and changes only opacity.
// - Compatibility constructors may expose physical chroma and degree hue.
// - Source constructors must convert those units at their boundary.
//
// ColorSlider geometry and gestures.
// - The authored visual capsule is exactly 26dp high.
// - Android interaction and semantics expand to a centered 48dp target.
// - Expanded hit testing does not stretch the painted track.
// - The gradient begins after the leading 13dp radius.
// - The gradient ends before the trailing 13dp radius.
// - The indicator is a 20dp box centered on normalized value.
// - The indicator ring is 6dp and therefore has a 7dp center radius.
// - The complete capsule clips the indicator at either endpoint.
// - A stationary track tap is not a ColorSlider action.
// - A horizontal drag publishes its down-position value after acceptance.
// - Horizontal intent is claimed before an ancestor pager's normal slop.
// - Vertical intent remains available to an ancestor scrolling page.
// - RTL reverses pointer values, indicator placement, and gradient colors.
// - Zero-width and narrower-than-26dp constraints remain finite.
//
// ColorSlider haptics.
// - MiuixSliderHapticEffect.none emits no feedback.
// - MiuixSliderHapticEffect.edge is the public default.
// - Edge mode emits GestureThresholdActivate on first arrival at either edge.
// - Leaving an edge rearms the next edge event.
// - Drag start resets haptic state without vibrating.
// - Step mode also emits TextHandleMove for each distinct interior update.
// - Step mode does not emit a text-handle tick at an edge.
// - Programmatic color restoration never emits feedback.
//
// Checkerboard.
// - Default cells are exactly 3dp.
// - Default light squares are #CCCCCC.
// - Default dark squares are #AAAAAA.
// - The light color fills the complete area first.
// - Even rows begin with a light square then a dark square.
// - Odd rows begin with a dark square.
// - Partial trailing and bottom cells are clipped to bounds.
// - The alpha gradient paints over, rather than instead of, checkerboard.
//
// Localized example.
// - Section order remains HSV, OKHSV, OKLAB, OKLCH, then ColorPalette.
// - Every picker begins from the active MIUIX primary color.
// - Visible section labels are Chinese while parameter order is unchanged.
// - RGBA RGB channels use truncation exactly like Float.toInt.
// - Alpha rounds to two decimal places without fixed trailing zero padding.
// - Each card disables the picker preview like the upstream sample.
// - Every HEX field begins with the source leading text slot.
// - The leading text owns an exact 16dp start padding.
// - No compatibility prefix gap or icon constraint is inserted.
// - Hex proposals longer than eight characters are rejected whole.
// - Hex proposals containing any invalid character are rejected whole.
// - Accepted hex proposals are uppercased immediately.
// - Exactly eight accepted digits update the corresponding selected color.
//
// Verification.
// - Focused tests cover palette emission, local preview, and parent echoes.
// - Focused tests cover LTR and RTL cell mapping.
// - Focused tests cover parent-pager gesture ownership.
// - Focused tests cover 26dp visuals and 48dp interaction targets.
// - Focused tests cover OKLab channel range and source constructor units.
// - Focused tests cover none, edge, and step feedback.
// - Example tests cover localized RGBA and controlled HEX behavior.
// - Component goldens cover palette and all four picker color spaces.
// - Same-device captures remain authoritative for 420dpi pixel placement.
//
// Controlled-value reconciliation.
// - A pointer sample is first committed to the widget's transient visual state.
// - The callback is published only after that transient state is available.
// - A synchronous parent rebuild with the same color keeps the transient state.
// - A delayed parent rebuild with the same color also keeps the selected cell.
// - Parent values are compared in HSV because authored cells originate in HSV.
// - Hue comparison wraps around the zero-degree and 360-degree boundary.
// - Near-achromatic colors do not let an unstable hue erase a valid selection.
// - Hue tolerance is 1.5 degrees, matching the source reconciliation window.
// - Saturation tolerance is .02, matching the source reconciliation window.
// - Value tolerance is .02, matching the source reconciliation window.
// - Alpha remains an exact channel in the emitted selected color.
// - A true external replacement clears stale pointer-derived assumptions.
// - Reconciliation must never invoke an application callback by itself.
// - Reconciliation must never emit haptics by itself.
//
// Pointer sampling.
// - Pointer down maps immediately to a palette cell.
// - Every pressed move maps independently to the cell under that sample.
// - Repeated samples in one cell still publish repeated source callbacks.
// - Repeated callbacks are observable and therefore cannot be deduplicated.
// - The down sample is not duplicated by a second pan-start callback.
// - Samples outside the grid are clamped to the nearest valid cell.
// - The last physical column remains reachable despite floating-point rounding.
// - The last physical row remains reachable despite floating-point rounding.
// - RTL changes logical hue order without changing the physical grid bounds.
// - Pressed movement consumes the horizontal event from an ancestor pager.
// - Before acceptance, vertical scrolling remains available to the page.
// - Multi-pointer input follows the active recognizer instead of merging values.
// - Pointer cancellation leaves the last accepted visible color intact.
//
// Palette authored rows.
// - The default table has seven authored saturation/value rows.
// - The default hue table has twelve authored columns.
// - The optional gray column is appended after the hue columns in LTR.
// - RTL mirrors the complete logical table including the gray column.
// - Row zero uses the lightest authored saturation/value pair.
// - Each following row follows the upstream saturation/value lookup table.
// - The table is data-driven so custom row and column counts remain supported.
// - A custom empty dimension is guarded before cell-size division.
// - Grid clipping owns the outer 16dp default corner radius.
// - Internal cells have no artificial spacing or seams.
// - The selection ring is centered on the selected cell center.
// - The selection ring does not alter grid layout or hit testing.
// - The indicator's inner color is the exact selected cell color.
// - The indicator shadow is visual only and does not enlarge semantics.
//
// Alpha composition.
// - Palette selection preserves the externally controlled alpha channel.
// - Alpha dragging preserves the currently selected RGB channels.
// - A later palette selection preserves the latest locally dragged alpha.
// - Checkerboard is drawn below the transparent-to-opaque gradient.
// - Transparent endpoints reveal the checkerboard without an opaque underlay.
// - Opaque endpoints fully cover the checkerboard with selected RGB.
// - Alpha indicator fill uses the composed selected color.
// - Alpha endpoint clipping matches the slider's 13dp radius.
// - Alpha callbacks use the same pointer and haptic rules as other channels.
//
// Public source adapters.
// - Source constructors use upstream parameter names wherever Dart permits.
// - Compatibility constructors remain available for existing Flutter callers.
// - Source adapters convert units exactly once at their public boundary.
// - Internal painters receive physical units suited to their color spaces.
// - HSV source hue input remains degrees because currentHue is authored so.
// - HSV source hue output is normalized because onHueChanged is authored so.
// - OKHSV inputs and outputs stay normalized in both directions.
// - OKLab A and B remain physical signed values in both directions.
// - OKLCH C source input and output are normalized around the .4 maximum.
// - OKLCH H source input and output are normalized around a full 360 degrees.
// - Alpha remains normalized for every color-space adapter.
// - Adapter callbacks never expose the private track-normalization units.
// - Haptic policy forwarding is lossless through every adapter layer.
// - Preview visibility forwarding is lossless through the parent picker.
//
// Color conversion safety.
// - Conversion output channels are clamped before constructing a Flutter Color.
// - Non-finite transient math cannot become a non-finite slider position.
// - Black has a stable fallback hue when converted back into cylindrical space.
// - Achromatic HSV colors retain a useful previous hue during interaction.
// - OKLab endpoints may leave sRGB and are clipped only at display conversion.
// - Gradient sampling uses the upstream authored sample counts.
// - Gradient endpoints are included rather than approximated by interior stops.
// - Alpha does not participate in conversion between solid color spaces.
// - Converting a controlled color restores alpha after solid-channel conversion.
// - Equality decisions use the final ARGB value visible to the application.
//
// Layout invariants.
// - Picker width follows the finite width supplied by its parent card.
// - Palette grid width and height remain the authored 180dp by default.
// - Preview, grid, and alpha track keep exact 12dp vertical gaps.
// - ColorPicker preview and channel tracks keep exact 12dp vertical gaps.
// - Hiding a preview removes its associated gap as one source branch.
// - Expanded 48dp gesture targets overlap only empty gap, never adjacent paint.
// - Cards own outer horizontal padding; picker internals do not add another one.
// - Text scale affects labels outside the color controls, not track geometry.
// - System insets are handled by the page scaffold, not individual sliders.
//
// Semantics and accessibility.
// - The expanded 48dp region is also the channel's semantic interaction target.
// - Decorative checkerboard cells do not create individual semantic nodes.
// - Decorative gradient samples do not create individual semantic nodes.
// - The selected color remains represented by the owning control.
// - Disabled presentation never leaves an active drag recognizer behind.
// - Keyboard and assistive actions may update values without pointer haptics.
// - Programmatic parent updates remain silent for accessibility consistency.
// - RTL semantics report the logical value even while the physical track flips.
//
// Localized sample fidelity.
// - Localization changes only user-facing strings and never authored ordering.
// - HSV, OKHSV, OKLAB, and OKLCH acronyms retain their upstream spelling.
// - The palette label is translated while retaining the final section position.
// - HEX stays a leading field label rather than becoming hint text.
// - Invalid pasted text leaves both field text and selected color unchanged.
// - A valid lowercase paste is accepted and displayed as uppercase.
// - Fewer than eight valid digits update text but do not update selected color.
// - Deletion follows the same incomplete-value rule without restoring old text.
// - More than eight pasted digits are rejected rather than truncated.
// - RGBA display follows Kotlin truncation and rounding, not fixed formatting.
// - Picker cards do not add an invented color preview absent from the source.
// - Localized SmallTitle lines use the declared subtitle strut rather than a
//   taller Android CJK fallback line box; the 420dpi section stride is 821px.
//
// Regression gates.
// - Mapping verification must include every public upstream picker symbol.
// - Scope verification must include every mapped Flutter public symbol.
// - Static analysis must remain warning-free in both library and example.
// - Focused interaction tests must run before accepting new golden images.
// - Golden updates require an explained source-driven visual difference.
// - Unrelated golden hashes must remain unchanged during a targeted update.
// - The complete root suite guards visual and behavioral compatibility.
// - The complete example suite guards localization and section structure.
// - Android release installation must preserve the existing application data.
// - Runtime logs must contain no Flutter framework or rendering exceptions.
// - Windows release startup must be smoke-tested after every packaging wave.
//
// Same-device checkpoint (2026-08-10).
// - Native and Flutter track bounds are x=76..1004 inside x=32..1048 cards.
// - A real OKLCH channel drag changes RGBA without moving the root pager.
// - The leading edge emits Android constant 23 / Prebaked TICK / TOUCH.
// - Evidence lives in artifacts/parity/color_picker_current_2026-08-10.
