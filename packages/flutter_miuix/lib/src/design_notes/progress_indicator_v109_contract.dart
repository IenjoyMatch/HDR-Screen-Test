// Copyright 2026, flutter_miuix contributors
// SPDX-License-Identifier: Apache-2.0
//
// MIUIX 1.0.9 ProgressIndicator source-parity contract.
//
// Source inventory
//
// The authority is basic/ProgressIndicator.kt in the checked local source.
// It defines LinearProgressIndicator, CircularProgressIndicator, and
// InfiniteProgressIndicator.
// It also defines ProgressIndicatorDefaults and ProgressIndicatorColors.
// MiuixProgressIndicator is a Flutter compatibility dispatcher, not upstream.
// The three source-named adapters remain the preferred public entry points.
//
// Public progress values
//
// Linear and circular source functions name their value `progress`.
// Null progress selects the indeterminate branch.
// Non-null progress is clamped to the inclusive zero-to-one interval.
// The Flutter adapters expose progress as the source-named argument.
// The older value argument remains a compatibility alias.
// The resolved public progress getter returns the same stored value.
// NaN and infinity are normalized by the existing Flutter stability guard.
// That normalization is an extension and does not alter ordinary source input.
//
// Color model
//
// Source ProgressIndicatorColors is an immutable Kotlin data class.
// Its channels are foreground, disabledForeground, and background.
// Linear and circular indicators currently request foreground with true.
// The disabled channel remains part of the public defaults contract.
// Default foreground reads the active MIUIX primary semantic color.
// Default disabled foreground reads disabledPrimarySlider.
// Default background reads secondaryContainer.
// progressIndicatorColors permits independent overrides of all three channels.
// The Flutter value object implements equality, hashCode, and copyWith.
// Equal reconstructed color sets therefore do not trigger needless repainting.
// InfiniteProgressIndicator does not use this color model.
// Its independent default is Compose Color.Gray, exactly ARGB FF888888.
//
// Default dimensions
//
// Linear height is 6dp.
// Circular size is 30dp.
// Circular stroke width is 4dp.
// Infinite size is 20dp.
// Infinite stroke width is 2dp.
// Infinite orbiting-dot radius is 2dp.
// Descriptive source-name constants expose all six values.
// Existing concise constants remain exact aliases.
// Compose rounds measured dp placeables to physical pixels.
// Canvas stroke and dot dimensions remain floating-point logical dimensions.
// The Flutter layout rounds only the measured height or diameter.
//
// Linear finite drawing
//
// The source appends fillMaxWidth and height after caller modifiers.
// The track fills the complete measured width.
// Track corner radius equals half of its measured height.
// The track uses the active background channel.
// The foreground uses the active foreground channel.
// Zero progress still paints a capsule one track-height wide.
// Full progress paints the complete track width.
// Intermediate width is height plus remaining width times progress.
// No Material ProgressIndicator painter or theme residue participates.
//
// Linear indeterminate drawing
//
// The transition advances from zero to one over 1250ms.
// Easing is linear and RepeatMode is Restart.
// Three segments are generated.
// Each segment occupies 45 percent of the complete width.
// Segment phase spacing is 45 percent plus 55 percent, exactly one cycle.
// Negative phase is normalized with positive modulo.
// Before 55 percent, the segment paints its complete width.
// After 55 percent, it splits at the right edge and wraps to the left edge.
// Both split pieces retain the source half-height rounded corners.
// Switching to finite progress removes the conditional remembered transition.
// Switching back to null therefore creates a fresh transition at zero.
//
// Circular finite drawing
//
// Track radius is (size minus strokeWidth) divided by two.
// Track center is half of the declared source size on both axes.
// The track is painted with drawCircle and a butt-cap Stroke.
// A synthetic 360-degree drawArc is not an interchangeable primitive.
// Foreground starts at minus 90 degrees.
// Foreground uses a round-cap Stroke.
// Minimum sweep is 0.1 degrees.
// Sweep is 0.1 plus 359.9 times clamped progress.
// Progress zero therefore remains visible as the source minimum cap.
//
// Circular indeterminate drawing
//
// Rotation advances zero to 360 degrees over 1000ms.
// Rotation uses linear easing and Restart repeat mode.
// Sweep begins at 30 degrees.
// Sweep reaches 120 degrees at 800ms.
// Sweep returns to 30 degrees at 1600ms.
// Both sweep keyframe legs use linear easing.
// Track geometry is identical to the finite branch.
// Foreground start angle is the current rotation value.
// Switching through a finite value recreates both source transitions at zero.
//
// Infinite orbit drawing
//
// The orbit transition advances zero to 360 degrees over 800ms.
// It uses linear easing and Restart repeat mode.
// Ring radius is (size minus strokeWidth) divided by two.
// Ring stroke uses round caps.
// Dot orbit radius is ring radius minus twice the dot radius.
// Dot x is orbit radius times cosine of the current angle.
// Dot y is orbit radius times sine of the current angle.
// InfiniteProgressIndicator adds no progress-range semantics in the source.
//
// Accessibility
//
// Finite linear and circular indicators publish ProgressBarRangeInfo.
// The range is zero through one and the current value is clamped progress.
// Flutter exposes SemanticsRole.progressBar with minValue zero and maxValue one.
// Its spoken value is the rounded percentage.
// Indeterminate linear and circular indicators publish Indeterminate range info.
// Flutter maps that nonnumeric state to SemanticsRole.loadingSpinner.
// InfiniteProgressIndicator intentionally remains without a progress node.
//
// Example contract
//
// The source section title is ProgressIndicator and is localized in Flutter.
// It prepares values zero, quarter, half, three-quarters, one, and null.
// One animated value travels zero to one over 1000ms and reverses forever.
// Compose tween without an easing argument uses FastOutSlowInEasing.
// The Flutter example uses the matching cubic instead of a linear controller.
// The animated linear indicator precedes six fixed/indeterminate linear rows.
// Each linear modifier has 15dp horizontal and 12dp bottom padding.
// The translated page owns a separately placed 12dp horizontal inset.
// The section therefore subtracts rounded 12dp pixels from rounded 15dp.
// At 420dpi that is 39px minus 32px, leaving seven physical pixels per side.
// Independently rounding the logical 3dp remainder would incorrectly add 8px.
// The final FlowRow owns 12dp total horizontal padding.
// Its horizontal arrangement is SpaceEvenly.
// It contains one animated circular indicator, six values, and one orbit.
// The orbit is vertically centered against the 30dp circular indicators.
// Only the two reversing pictures rebuild on each source-animation frame.
// Their stable outer semantics prevent the retained lazy-list accessibility
// subtree from being invalidated continuously while paint still animates.
// Visible section text is localized; numeric order and geometry are unchanged.
//
// Regression obligations
//
// Tests must compile the source progress argument on both adapters.
// Tests must retain compatibility with the older value argument.
// Tests must assert all six public dimension constants.
// Tests must assert data-class color equality, hash, and copy behavior.
// Tests must assert finite progress role, value, minimum, and maximum.
// Tests must assert the indeterminate loading role.
// Tests must assert the 30-to-120-to-30 sweep keyframes.
// The example test must retain seven circular children plus one orbit.
// FlowRow outer bounds and all nine SpaceEvenly gaps remain exact.
// At 420dpi every linear track must occupy physical x=39 through x=1041.
// Golden changes are accepted only for a confirmed source primitive difference.
// Root and example analyze must report zero issues.
// Root and example full test suites must pass.
// The hand-maintained comment ratio must remain at least fifty percent.
