// BreadcrumbBar v1.0.9 source-parity contract.
//
// This note records behavior that is easy to "simplify" in Flutter while
// accidentally moving away from the current Compose MIUIX implementation.
// Keep it near the implementation so future geometry or animation work can
// distinguish an intentional source quirk from an ordinary layout mistake.
//
// Source ownership
// ----------------
// The authoritative component is basic/BreadcrumbBar.kt.
// The authoritative fixture is component/BreadcrumbBarSection.kt.
// The Android evidence device is 1080 x 2400 at 420 dpi.
// That density is 2.625 physical pixels per logical dp.
// Measurements in this note are physical Android pixels unless stated.
// The Flutter example translates visible labels but does not alter paths.
// Path joining remains a model operation and never reads display text.
//
// Public model
// ------------
// Every item owns one required path and one optional display string.
// A null display string falls back to the path segment.
// The default highlighted index is the final item.
// A negative highlighted index disables highlight and auto-centering.
// The enabled flag controls clicks and colors, not horizontal scrolling.
// An externally supplied scroll controller preserves caller ownership.
// A null interaction source creates an independent source per segment.
// A null indication keeps clicks active and only removes the overlay.
// The item maximum is replaceable and defaults to 160dp.
// The inside margin is replaceable and defaults to 12dp by 8dp.
//
// Horizontal composition
// ----------------------
// The content is one non-wrapping horizontal row.
// The row scrolls instead of shrinking or wrapping overflowing segments.
// Inside horizontal padding is 12dp on both ends by default.
// Each non-first item is preceded by exactly one separator.
// A separator owns 4dp horizontal padding on both sides.
// The separator vector is exactly 10dp wide and 16dp high.
// Separator occupied width is therefore 18dp.
// LTR uses the original right arrow orientation.
// RTL mirrors only the separator vector on the x axis.
// RTL does not reverse path strings or display text manually.
// Disabled state changes separator tint but not separator geometry.
//
// Segment measurement
// -------------------
// The painted capsule height is exactly 32dp.
// Capsule shape is a circle-derived stadium, not an arbitrary fixed radius.
// Horizontal content padding is exactly 10dp on each side.
// Short segments use intrinsic text width plus 20dp.
// Short segments must never expand to the supplied maximum width.
// Long segments are constrained to the item maximum.
// Overflowing text uses one line and an ellipsis.
// Text remains vertically centered inside the 32dp painted capsule.
// The source text size is the MIUIX body2 size of 14sp.
// Normal and disabled segments use normal font weight.
// The highlighted segment uses medium font weight.
// The Android Flutter shaper advances these glyphs slightly farther.
// A -0.12sp component-local tracking compensation matches normal short widths.
// The same -0.12sp compensation is used for normal and medium labels.
// It does not change the documented font size.
// It does not affect a capsule already clamped to 160dp.
// On the reference device the 160dp maximum is exactly 420px.
// Normal apps is 131px wide in both native and Flutter fixtures.
// DataBackup is 247px wide in both native and Flutter fixtures.
// Selected visible fills retain the source width instead of being contracted.
// Skia and Compose still differ by one antialiased row at fractional density.
// The correction never uses a weight-specific or per-string width table.
// A per-string width table would break localization and custom caller data.
//
// Colors
// ------
// Enabled normal text uses onBackground at 55 percent alpha.
// Enabled normal background uses onBackground at 10 percent alpha.
// Highlighted text uses the current semantic primary color.
// Highlight background uses primary at 20 percent alpha.
// Disabled text uses disabledOnSecondaryVariant.
// Disabled background uses disabledSecondaryVariant.
// Enabled separators use onSurfaceVariantActions.
// Disabled separators use the same disabled text role.
// Caller-supplied color sets replace each role independently.
// Highlight changes must not animate colors unless upstream adds animation.
//
// Minimum interaction target
// --------------------------
// Compose measures the visible Box at 32dp.
// Android minimum interactive enforcement exposes a 48dp click target.
// The extra touch area is 8dp above and 8dp below the capsule.
// Those bands overlap the default vertical inside margin.
// They do not increase the default BreadcrumbBar beyond 48dp total height.
// Flutter therefore separates the touch render box from the painted surface.
// The touch render box participates in row layout at 48dp.
// The painted MiuixSurface remains centered at 32dp.
// Default vertical padding is reduced by the occupied overlap.
// The visual surface still owns center taps and source indication feedback.
// The outer recognizer owns only the two non-painted touch bands.
// Center taps must not enter two competing tap recognizers.
// A disabled item installs no pointer target in either region.
// Disabled horizontal drag remains available through the scroll viewport.
// The outer touch target is one accessibility semantics boundary.
// Its label is the visible segment text.
// Its role is button only while enabled.
// Its semantic height is exactly 48dp at the reference density.
// Excluding child semantics prevents duplicate text and button nodes.
// Keyboard activation uses the semantic tap action supplied by the boundary.
// The reference emulator successfully selected apps from the upper band.
// That tap was ten pixels below the semantic top.
// The painted surface began about twenty-one pixels below the semantic top.
// The verified tap was therefore outside paint and inside the 48dp target.
//
// Initial positioning
// -------------------
// Initial auto-positioning is a non-animated ScrollState.scrollTo operation.
// It runs only after the highlighted segment has global coordinates.
// It runs only after the viewport has a positive measured width.
// A missing or negative highlight skips initial positioning entirely.
// The destination is clamped to the scroll state's valid extent.
// The destination is converted to an integer physical pixel.
// Conversion truncates instead of rounding to nearest.
// Flutter converts the truncated physical value back to a logical offset.
// This prevents a persistent subpixel transform on later child capsules.
// The first and last segments commonly clamp to the minimum or maximum.
// Rebuilding identical items must not restart initial positioning endlessly.
// Replacing the external controller invalidates previous positioning state.
// Detaching a controller cancels an active programmatic animation.
// An internally created controller is disposed only by its owning bar.
//
// Root-space centering
// --------------------
// Upstream records each highlighted segment with positionInRoot().x.
// Upstream then adds the current ScrollState value.
// It does not subtract the horizontal viewport's root-space origin.
// The viewport width remains a local size in the centering equation.
// This mixes root-space position with a local-space width intentionally here.
// The result looks left-shifted when the viewport begins at a positive x.
// Correcting that shift in Flutter would diverge from the current source.
// The standalone native viewport begins at x=32 on the reference device.
// The inset card native viewport begins at x=74.
// After selecting apps, native standalone apps begins at x=443.
// After selecting apps, Flutter standalone apps also begins at x=443.
// After selecting apps, native inset-card apps begins at x=401.
// After selecting apps, Flutter inset-card apps also begins at x=401.
// These x origins are stronger evidence than visually guessed centering.
// A regression test places the bar inside an explicit left inset.
// That test expects the source root-space shift, not corrected centering.
// Integer target truncation permits less than one pixel of center remainder.
// The regression tolerance must allow that source truncation remainder.
//
// Highlight motion
// ----------------
// Highlight changes use ScrollState.animateScrollTo in current Compose.
// With no animationSpec argument, Compose uses its default scroll spring.
// That spring has mass 1 and stiffness 1500.
// Its damping ratio is 1, so the motion is critically damped.
// The previous Flutter 300ms easeInOut tween was not source-equivalent.
// A 50ms sample distinguishes the critical spring from that old tween.
// The spring begins from the currently rendered scroll offset.
// Retargeting while active carries the current spring velocity.
// A generation token prevents an old completion from snapping a new target.
// Spring distance tolerance is 0.01 physical pixel in the source float model.
// Velocity tolerance is 0.625 physical pixel per second equivalent here.
// Flutter scales both tolerances back into logical units.
// When the spring completes, the controller snaps to the exact target.
// That final snap removes simulation tolerance residue.
// The snap still respects min and max scroll extents.
// A detached controller silently skips the frame instead of throwing.
//
// Scroll ownership
// ----------------
// Compose user input has higher mutation priority than animateScrollTo.
// A user horizontal drag cancels programmatic centering.
// An external controller jump likewise cancels programmatic centering.
// Canceled motion must not later snap to its stale destination.
// Internal animation frames must not cancel their own animation.
// The implementation guards controller writes with an applying flag.
// A scroll notification outside that guarded write stops the ticker.
// Controller replacement increments the same motion generation token.
// Disposal also invalidates all pending animation completion callbacks.
//
// State updates
// -------------
// Changing the effective highlighted index schedules source motion.
// Changing item values also schedules source motion.
// Rebuilding with equal items does not create needless motion.
// The click callback is read from the latest widget instance.
// Selecting a segment is caller state; the bar does not mutate its model.
// The example updates its selected index in response to the callback.
// The example's full path always keeps all five source segments.
// The example's current path takes items through the selected index.
// Selecting apps therefore changes the localized current path to /apps.
// The standalone and card-enabled bars share the same selected state.
// The disabled bar keeps its negative highlight and never auto-centers.
//
// Test obligations
// ----------------
// Defaults test checks 12dp by 8dp inside margin.
// Defaults test checks 32dp painted height.
// Defaults test checks 10dp horizontal segment padding.
// Defaults test checks the 160dp maximum width.
// Geometry test checks total default bar height is 48dp.
// Geometry test checks a short surface is narrower than 160dp.
// Geometry test checks the long package segment is exactly 160dp.
// Geometry test checks painted surface height remains 32dp.
// Semantics test checks the exposed target is exactly 48dp high.
// Pointer test taps four dp above paint and expects the item callback.
// Disabled test taps a visible item and expects no callback.
// Disabled test still checks horizontal scroll direction.
// Spring test uses a fractional 2.625 density.
// Spring test checks initial target physical-pixel truncation.
// Spring test checks the 50ms position against SpringSimulation.
// Spring test checks exact final settling.
// Spring test checks external scrolling cancels stale completion.
// Root-space test checks the intentional inset displacement.
// Interaction test checks the caller's shared interaction source.
// Interaction test checks custom indication color forwarding.
// Interaction test checks null indication still permits clicks.
// Full library tests include all component golden baselines.
// Full example tests cover localized Home fixture integration.
// Static analysis must remain warning-free.
// Scope verification must retain at least 50 percent comments.
//
// Runtime evidence
// ----------------
// Evidence lives in artifacts/parity/breadcrumb_current_2026-08-08.
// Native full and selected screenshots come from the current source build.
// Flutter final screenshots come from the same emulator and density.
// UI XML provides physical bounds independently from screenshot scaling.
// Before evidence records short items stretched to the 160dp maximum.
// Final evidence records intrinsic-width short items.
// Final evidence records both enabled bars moving after one click.
// Final evidence records the disabled bar remaining stationary.
// Final evidence records localized Chinese fixture labels.
// The native fixture remains English because only Flutter is localized.
// Temporary package suffixes isolate native, Flutter, and user applications.
// Every temporary suffix is removed from Gradle source after its build.
// Test packages may be uninstalled after evidence capture.
// The user's unrelated application data must never be cleared for this test.
//
// Maintenance boundary
// --------------------
// Re-check upstream before changing any constant in this contract.
// Re-check source and example because fixture behavior can add constraints.
// Name/API coverage alone is not proof of behavior parity.
// Widget tests alone are not proof of Android physical geometry.
// Screenshots alone are not proof of pointer or scroll behavior.
// UI XML alone is not proof of motion timing.
// Keep source inspection, tests, and same-device evidence together.
// If upstream fixes root-space centering, update both code and evidence.
// If upstream changes its default scroll spring, update sampled motion tests.
// If Flutter changes Android glyph shaping, remeasure the tracking correction.
// If minimum touch behavior changes, re-test the non-painted bands directly.
// Do not update a golden to hide a geometry regression.
// Repair the implementation first, then refresh evidence if source changed.
