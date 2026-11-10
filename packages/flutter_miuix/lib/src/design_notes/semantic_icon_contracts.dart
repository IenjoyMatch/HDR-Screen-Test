// Semantic color and icon fidelity contracts.
//
// These notes document the non-obvious rules shared by the generated icon
// catalogue, the theme extension, the component library, and the example app.
// They live beside the other implementation contracts so future refactors do
// not accidentally replace source-accurate assets with Material substitutes.
//
// Icon catalogue contract.
// Every extended icon comes from the Compose MIUIX 0.9.3 Kotlin source.
// The original file name remains the public English technical identifier.
// Catalogue order follows the original AllIcons list and is deterministic.
// Every entry must expose Light, Normal, Regular, Medium, and Demibold weights.
// A missing weight is a generation failure and must never fall back silently.
// Glyph code points live in the private-use area and are stable by list index.
// All five fonts use a square 1000-unit em to match the 24 dp vector viewport.
// Non-square upstream viewports are centered without stretching their paths.
// Apply each source group transform before converting to TrueType coordinates.
// The source scaleY and translationY are part of the glyph, not metadata.
// Compose's downward Y axis is converted once after the source group transform.
// Each glyph's horizontal left-side bearing equals its outline xMin.
// This keeps the source vector centered instead of shifting its ink left.
// Cubic curves are converted to quadratic curves with a one-unit error bound.
// Line, horizontal, vertical, quadratic, cubic, and close nodes are supported.
// Any new upstream path-node kind must stop generation until it is implemented.
// The generated font family names include the optical weight explicitly.
// IconData also declares fontPackage so downstream applications load assets.
// The generated Dart chunks are intentionally small enough for code review.
// Generated chunks must not be hand-edited because regeneration replaces them.
// Ordinary Flutter builds depend only on committed fonts and generated Dart.
// Python and fonttools are development-time inputs, not runtime dependencies.
// The icon page uses the Regular weight for each collapsed catalogue row.
// Expanding a row must show exactly one icon from each of the five font files.
// Only one row may be expanded at a time, matching the source accordion state.
// Search filters technical names without changing their stable catalogue index.
//
// Semantic color contract.
// Material ColorScheme does not contain every role required by MIUIX widgets.
// MiuixSemanticColors therefore keeps the complete named source-role table.
// The default light table uses the literal values in lightColorScheme.
// The default dark table uses the literal values in darkColorScheme.
// Alpha-bearing roles retain their source alpha instead of being precomposited.
// Primary and onPrimary form a foreground/background contrast pair.
// PrimaryVariant and onPrimaryVariant form a second contrast pair.
// Error and onError form the direct error-content contrast pair.
// ErrorContainer and onErrorContainer form the contained error contrast pair.
// Disabled primary roles are distinct for controls, buttons, and sliders.
// Secondary and secondary-variant disabled roles remain separate tokens.
// Container and on-container roles must not be swapped for generic surfaces.
// TertiaryContainerVariant intentionally has no matching on-role in the source.
// Background and surface remain distinct even when a platform palette merges them.
// Summary and action content use different source opacity levels.
// SurfaceContainerHigh and Highest are separate elevation-like semantic levels.
// DividerLine is not interchangeable with the stronger Outline color.
// WindowDimming retains 30 percent light and 60 percent dark source opacity.
// SliderKeyPoint is translucent and must be painted over the slider background.
// SliderKeyPointForeground remains opaque for the focused key-point treatment.
// Dynamic palettes start from platform or generated Material roles when present.
// Roles absent from a dynamic ColorScheme retain safe MIUIX semantic fallbacks.
// Theme construction installs the semantic palette beside MiuixThemeData.
// MiuixSemanticColors.of derives a palette only when no extension is installed.
// Role lookup asserts on misspellings instead of returning an unrelated color.
// Palette interpolation covers the union of both role maps during theme changes.
// The color catalogue displays roles in the original declaration order.
// Its preview intentionally excludes sliderBackground because the source page does.
// Each preview block is 100 dp high with a 12 dp squircle corner radius.
// Preview columns use a 16 dp gap and the card uses a 16 dp inside margin.
// A matching on-role supplies text and border color whenever that role exists.
// Unpaired translucent roles choose black or white from computed luminance.
// Visible catalogue labels are localized while programmatic role keys stay stable.
// Custom card colors remain opt-in so existing component surfaces do not change.
// Fidelity tests should compare source constants, role order, and rendered geometry.
